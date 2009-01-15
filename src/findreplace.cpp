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
  connect(closePushButton, SIGNAL(released()), this, SLOT(close()));
}

FindReplace::~FindReplace()
{
}

void FindReplace::find()
{
  bool found = false;
  if (caseCheckBox->isChecked()) {
    found = m_document->find(findLineEdit->text(),
                     QTextDocument::FindCaseSensitively);
  }
  else
    found = m_document->find(findLineEdit->text());
  if (!found) {
    int ret = QMessageBox::question(this, tr("Find and replace"),
                                   tr("The string was not found.\n"
                                      "Would you like to start from the top?"),
                                      QMessageBox::Yes | QMessageBox::No,
                                      QMessageBox::No
                                   );
    if (ret == QMessageBox::Yes) {
      m_document->moveCursor(QTextCursor::Start);
      find();
    }
  }
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


