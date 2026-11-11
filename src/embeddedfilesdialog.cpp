/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
*/

#include "embeddedfilesdialog.h"
#include "ui_embeddedfilesdialog.h"

#include "baseview.h"

#include <QApplication>
#include <QDir>
#include <QFile>
#include <QFileDialog>
#include <QFileInfo>
#include <QHeaderView>
#include <QInputDialog>
#include <QLocale>
#include <QMessageBox>
#include <QPushButton>
#include <QTableWidgetItem>

using namespace Qt::StringLiterals;

namespace {

class WaitCursor
{
public:
	WaitCursor() { QApplication::setOverrideCursor(Qt::WaitCursor); }
	~WaitCursor() { QApplication::restoreOverrideCursor(); }
};

} // namespace

EmbeddedFilesDialog::EmbeddedFilesDialog(BaseView *view,
                                         const QString &documentName,
                                         const QString &targetDirectory,
                                         QWidget *parent)
	: QDialog(parent)
	, ui(new Ui::EmbeddedFilesDialog)
	, m_view(view)
	, m_documentName(documentName)
	, m_targetDirectory(targetDirectory)
	, m_lastAddDirectory(targetDirectory)
{
	ui->setupUi(this);

	ui->documentLabel->setText(
		tr("Document: %1").arg(m_documentName.isEmpty() ? tr("Untitled")
	                                                    : m_documentName));

	QString targetText = tr("Files are extracted to: %1")
			.arg(QDir::toNativeSeparators(m_targetDirectory));
	if (!QFileInfo(m_targetDirectory).isWritable())
		targetText += u"\n"_s + tr("Warning: this directory is not writable.");
	ui->targetLabel->setText(targetText);

	QHeaderView *header = ui->tableWidget->horizontalHeader();
	header->setSectionResizeMode(0, QHeaderView::Stretch);
	header->setSectionResizeMode(1, QHeaderView::ResizeToContents);
	header->setSectionResizeMode(2, QHeaderView::ResizeToContents);

	connect(ui->addButton, &QPushButton::clicked,
	        this, &EmbeddedFilesDialog::addFile);
	connect(ui->buttonBox, &QDialogButtonBox::rejected,
	        this, &QDialog::reject);

	refresh();
}

EmbeddedFilesDialog::~EmbeddedFilesDialog()
{
	delete ui;
}

void EmbeddedFilesDialog::refresh()
{
	m_files = m_view->embeddedFiles();
	ui->tableWidget->setRowCount(m_files.size());
	ui->addButton->setEnabled(!m_view->isReadOnly());

	for (int row = 0; row < m_files.size(); ++row) {
		const EmbeddedFile &file = m_files.at(row);

		QString displayName = file.name;
		const QString nameError = EmbeddedFiles::validateName(file.name);
		if (!nameError.isEmpty()) {
			displayName = tr("%1 (invalid: %2)")
					.arg(file.name.isEmpty() ? tr("(no name)") : file.name,
					     nameError);
		}

		auto *nameItem = new QTableWidgetItem(displayName);
		nameItem->setToolTip(tr("Size: %1")
		                     .arg(QLocale().formattedDataSize(file.decodedSize)));
		ui->tableWidget->setItem(row, 0, nameItem);

		auto *removeButton = new QPushButton(tr("Remove"));
		removeButton->setEnabled(!m_view->isReadOnly());
		connect(removeButton, &QPushButton::clicked, this,
		        [this, row]() { removeFile(row); });
		ui->tableWidget->setCellWidget(row, 1, removeButton);

		auto *extractButton = new QPushButton(tr("Extract"));
		connect(extractButton, &QPushButton::clicked, this,
		        [this, row]() { extractFile(row); });
		ui->tableWidget->setCellWidget(row, 2, extractButton);
	}

	ui->tableWidget->resizeRowsToContents();
	updateSummary();
}

void EmbeddedFilesDialog::updateSummary()
{
	if (m_files.isEmpty()) {
		ui->summaryLabel->setText(tr("This document has no embedded files."));
		return;
	}

	qint64 total = 0;
	for (const EmbeddedFile &file : m_files)
		total += file.decodedSize;

	const QString count = m_files.size() == 1
			? tr("1 embedded file")
			: tr("%1 embedded files").arg(m_files.size());
	ui->summaryLabel->setText(
		tr("%1, %2 total").arg(count, QLocale().formattedDataSize(total)));
}

QString EmbeddedFilesDialog::targetFor(const EmbeddedFile &file) const
{
	return QDir(m_targetDirectory).filePath(file.name);
}

void EmbeddedFilesDialog::addFile()
{
	const QString startDirectory = QDir(m_lastAddDirectory).exists()
			? m_lastAddDirectory : m_targetDirectory;
	const QString path = QFileDialog::getOpenFileName(
		this, tr("Add Embedded File"), startDirectory, tr("All files (*)"));
	if (path.isEmpty())
		return;

	QString suggestedName = QFileInfo(path).fileName();
	QString name = suggestedName;

	while (true) {
		bool ok = false;
		name = QInputDialog::getText(this, tr("Embedded File"),
		                             tr("File name in the CSD:"),
		                             QLineEdit::Normal, suggestedName, &ok).trimmed();
		if (!ok)
			return;

		const QString nameError = EmbeddedFiles::validateName(name);
		if (!nameError.isEmpty()) {
			QMessageBox::warning(this, tr("Embedded File"), nameError);
			suggestedName = name;
			continue;
		}

		int existing = -1;
		for (int i = 0; i < m_files.size(); ++i) {
			if (m_files.at(i).name == name) {
				existing = i;
				break;
			}
		}
		if (existing >= 0) {
			const auto answer = QMessageBox::question(
				this, tr("Replace Embedded File"),
				tr("An embedded file named \"%1\" already exists.\n"
				   "Replace its data with \"%2\"?").arg(name, path),
				QMessageBox::Yes | QMessageBox::No | QMessageBox::Cancel);
			if (answer == QMessageBox::Cancel)
				return;
			if (answer == QMessageBox::No) {
				suggestedName = name;
				continue;
			}
		}

		QFile input(path);
		if (!input.open(QIODevice::ReadOnly)) {
			QMessageBox::warning(this, tr("Embedded File"),
			                     tr("Cannot read \"%1\":\n%2")
			                     .arg(path, input.errorString()));
			return;
		}

		QByteArray data;
		QString error;
		{
			WaitCursor wait;
			data = input.readAll();
			if (input.error() != QFileDevice::NoError)
				error = input.errorString();
			else if (data.size() != input.size())
				error = tr("Could not read the whole file.");
			else if (!m_view->setEmbeddedFile(name, data, &error)
			         && error.isEmpty())
				error = tr("Could not add the file.");
		}
		if (!error.isEmpty()) {
			QMessageBox::warning(this, tr("Embedded File"),
			                     tr("Cannot embed \"%1\":\n%2").arg(path, error));
			return;
		}

		m_lastAddDirectory = QFileInfo(path).absolutePath();
		refresh();
		return;
	}
}

void EmbeddedFilesDialog::removeFile(int row)
{
	if (row < 0 || row >= m_files.size())
		return;
	const EmbeddedFile &file = m_files.at(row);
	if (QMessageBox::question(
			this, tr("Remove Embedded File"),
			tr("Remove the embedded file \"%1\"?").arg(file.name),
			QMessageBox::Yes | QMessageBox::No, QMessageBox::No)
			!= QMessageBox::Yes) {
		return;
	}

	m_view->removeEmbeddedFile(row);
	refresh();
}

void EmbeddedFilesDialog::extractFile(int row)
{
	if (row < 0 || row >= m_files.size())
		return;
	const EmbeddedFile &file = m_files.at(row);

	const QString nameError = EmbeddedFiles::validateName(file.name);
	if (!nameError.isEmpty()) {
		QMessageBox::warning(this, tr("Extract Embedded File"),
		                     tr("Cannot extract \"%1\":\n%2")
		                     .arg(file.name, nameError));
		return;
	}

	const QString target = targetFor(file);
	if (QFileInfo::exists(target)) {
		const auto answer = QMessageBox::question(
			this, tr("Replace File"),
			tr("A file named \"%1\" already exists in:\n%2\n\nReplace it?")
				.arg(file.name, QDir::toNativeSeparators(m_targetDirectory)),
			QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
		if (answer != QMessageBox::Yes)
			return;
	}

	QString error;
	{
		WaitCursor wait;
		if (!EmbeddedFiles::extract(file, m_targetDirectory, true, &error)
		        && error.isEmpty())
			error = tr("Could not extract the file.");
	}
	if (!error.isEmpty()) {
		QMessageBox::warning(this, tr("Extract Embedded File"),
		                     tr("Cannot extract \"%1\":\n%2")
		                     .arg(file.name, error));
		return;
	}

	QMessageBox::information(
		this, tr("Extract Embedded File"),
		tr("Extracted \"%1\" to:\n%2")
			.arg(file.name, QDir::toNativeSeparators(target)));
}
