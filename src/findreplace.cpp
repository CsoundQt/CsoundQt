/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/
#include "findreplace.h"
#include "documentpage.h"

FindReplace::FindReplace(QWidget *parent, DocumentPage *document)
  : QDialog(parent), m_document(document)
{
  setupUi(this);
  connect(findPushButton, SIGNAL(released()), this, SLOT(find()));
  connect(replacePushButton, SIGNAL(released()), this, SLOT(replace()));
  connect(replaceAllPushButton, SIGNAL(released()), this, SLOT(replaceAll()));
}

FindReplace::~FindReplace()
{
}

void FindReplace::find()
{
  if (caseCheckBox->isChecked()) {
    m_document->find(findLineEdit->text(),
                     QTextDocument::FindCaseSensitively);
  }
  else
    m_document->find(findLineEdit->text());
}

void FindReplace::replace()
{
  if (m_document->textCursor().selectedText() == findLineEdit->text()) {
    qDebug("Not implemented yet.");
  }
  else
    find();
}

void FindReplace::replaceAll()
{
  qDebug("Not implemented yet.");
}


