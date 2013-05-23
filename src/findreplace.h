/*
	Copyright (C) 2008, 2009 Andres Cabrera
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

#ifndef FINDREPLACE_H
#define FINDREPLACE_H

#ifdef USE_QT5
#include <QtWidgets>
#else
#include <QtGui>
#endif

#include "ui_findreplace.h"

class DocumentPage;

class FindReplace : public QDialog, private Ui::FindReplace
{
	Q_OBJECT
public:
	FindReplace(QWidget *parent,
				QTextEdit *document,
				QString *lastSearch,
				QString *lastReplace,
				bool *lastCaseSensitive);

	~FindReplace();

private:
	QTextEdit *m_document;
	QString *m_lastSearch, *m_lastReplace;
	bool *m_lastCaseSensitive;

private slots:
	void find();
	void replace();
	void replaceAll();

signals:
	void findString(QString query);

};

#endif
