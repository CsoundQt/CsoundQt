/*
	Copyright (C) 2010 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/
#include "additionalfilespage.h"
#include "ui_additionalfilespage.h"

#include <QFile>
#include <QDir>

AdditionalFilesPage::AdditionalFilesPage(QWidget *parent) :
	QWizardPage(parent),
	ui(new Ui::AdditionalFilesPage)
{
	ui->setupUi(this);
	connect(ui->additionalListWidget, SIGNAL(itemSelectionChanged () ), this, SLOT(selectionChanged()));
	registerField("dataFiles", ui->additionalListWidget);
}

AdditionalFilesPage::~AdditionalFilesPage()
{
	delete ui;
}

void AdditionalFilesPage::setFiles(QStringList files)
{
	foreach (QString file, files) {
		ui->additionalListWidget->addItem(file);
	}
	ui->additionalListWidget->selectAll();
}

void AdditionalFilesPage::setSearchDirectories(QStringList directories)
{
	m_searchDirectories = directories;
}

void AdditionalFilesPage::changeEvent(QEvent *e)
{
	QWizardPage::changeEvent(e);
	switch (e->type()) {
	case QEvent::LanguageChange:
		ui->retranslateUi(this);
		break;
	default:
		break;
	}
}

void AdditionalFilesPage::selectionChanged()
{
	QList<QListWidgetItem *> selected = ui->additionalListWidget->selectedItems();
	QStringList files;
	foreach (QListWidgetItem *item, selected) {
		QString name = item->text();
		files << name;
	}
	setProperty("dataFiles", files);
}
