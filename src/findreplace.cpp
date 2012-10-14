/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of QuteCsound.

	QuteCsound is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	QuteCsound is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "findreplace.h"
#include "documentpage.h"

FindReplace::FindReplace(QWidget *parent,
						 QTextEdit *document,
						 QString *lastSearch,
						 QString *lastReplace,
						 bool *lastCaseSensitive)
	: QDialog(parent), m_document(document), m_lastSearch(lastSearch),
	  m_lastReplace(lastReplace),
	  m_lastCaseSensitive(lastCaseSensitive)
{
	setupUi(this);
	this->setModal(false);
	connect(findPushButton, SIGNAL(released()), this, SLOT(find()));
	connect(replacePushButton, SIGNAL(released()), this, SLOT(replace()));
	connect(replaceAllPushButton, SIGNAL(released()), this, SLOT(replaceAll()));
	connect(closePushButton, SIGNAL(released()), this, SLOT(close()));

	findLineEdit->setText(*m_lastSearch);
	findLineEdit->setFocus(Qt::PopupFocusReason);
	replaceLineEdit->setText(*m_lastReplace);
	caseCheckBox->setChecked(*m_lastCaseSensitive);
}

FindReplace::~FindReplace()
{
}

void FindReplace::find()
{
	*m_lastCaseSensitive = caseCheckBox->isChecked();
	*m_lastSearch = findLineEdit->text();
	*m_lastReplace = replaceLineEdit->text();
	emit(findString(*m_lastSearch));
}

void FindReplace::replace()
{
	if (m_document->textCursor().selectedText() == findLineEdit->text()) {
		m_document->insertPlainText(replaceLineEdit->text());
		find();
	}
	else {
		find();
	}
}

void FindReplace::replaceAll()
{
	int count = 0;
	if (m_document->textCursor().selectedText() != findLineEdit->text())
		find();
	while (m_document->textCursor().selectedText() == findLineEdit->text()) {
		m_document->insertPlainText(replaceLineEdit->text());
		find();
		count++;
	}
	QMessageBox::information (this, "Replace All", QString("String replaced %1 times").arg(count));
	close();
}


