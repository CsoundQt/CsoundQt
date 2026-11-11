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

#ifndef EMBEDDEDFILESDIALOG_H
#define EMBEDDEDFILESDIALOG_H

#include <QDialog>
#include <QStringList>
#include <QVector>

#include "embeddedfiles.h"

class BaseView;
class QTableWidgetItem;

namespace Ui {
class EmbeddedFilesDialog;
}

// Lists the <CsFileB> entries of one document. Each row can remove or extract
// the file; the Add button encodes a file from disk and appends it (or
// replaces an entry with the same name).
class EmbeddedFilesDialog : public QDialog
{
	Q_OBJECT
public:
	EmbeddedFilesDialog(BaseView *view, const QString &documentName,
	                    const QString &targetDirectory, QWidget *parent = nullptr);
	~EmbeddedFilesDialog();

private slots:
	void addFile();
	void removeFile(int row);
	void extractFile(int row);

private:
	void refresh();
	void updateSummary();
	QString targetFor(const EmbeddedFile &file) const;

	Ui::EmbeddedFilesDialog *ui;
	BaseView *m_view;
	QString m_documentName;
	QString m_targetDirectory;
	QVector<EmbeddedFile> m_files;
	QString m_lastAddDirectory;
};

#endif // EMBEDDEDFILESDIALOG_H
