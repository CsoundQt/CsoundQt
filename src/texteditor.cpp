/*
    Copyright (C) 2010 Andres Cabrera
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

#include "texteditor.h"
#include <QtGui>

TextEditor::TextEditor(QWidget *parent) :
    QTextEdit(parent)
{
  setAcceptDrops(true);
  setAcceptRichText(false);
//  qDebug() << "TextEditor::TextEditor" << acceptDrops();
}

void TextEditor::keyPressEvent (QKeyEvent * event)
{
//  if (event->key() == Qt::Tab) {
//
//  }
  QTextEdit::keyPressEvent(event);
  if (event->key() == Qt::Key_Return || event->key() == Qt::Key_Enter) {
    QTextCursor cursor = textCursor();
    if (!cursor.atStart()) {
      cursor.movePosition(QTextCursor::PreviousBlock);
      QTextCursor linecursor = cursor;
      linecursor.select(QTextCursor::LineUnderCursor);
      QString line = linecursor.selectedText().trimmed();
      if (line.endsWith(":")) {
        textCursor().insertText("    ");
      }
      cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
      while (cursor.selectedText().endsWith(" ") || cursor.selectedText().endsWith("\t") ) {
        cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
      }
      cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
      insertPlainText(cursor.selectedText());
    }
  }
}

//The following makes the editor almost accept drop events on OS X, but breaks all dragging on the same document on linux
//void TextEditor::dropEvent(QDropEvent *event)
//{
//  qDebug() << "TextEditor::dropEvent" << event->format();
////  QString fileName = QString(event->encodedData("text/uri-list")).remove("file://");
////  event->;
//
//  event->acceptProposedAction();
//}
//
//void TextEditor::dragEnterEvent(QDragEnterEvent *event)
//{
////  qDebug() << "TextEditor::dragEnterEvent" << event->format();
//  // TODO remove file:// text from text
//  event->acceptProposedAction();
//}
//
//void TextEditor::dragMoveEvent(QDragMoveEvent *event)
//{
////  qDebug() << "TextEditor::dragMoveEvent" << event->mimeData()->text();
//  event->acceptProposedAction();
//}
