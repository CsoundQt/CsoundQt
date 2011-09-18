/*
    Copyright (C) 2011 Andres Cabrera
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

#ifndef SCOREEDITOR_H
#define SCOREEDITOR_H

#include <QWidget>
#include <QContextMenuEvent>
#include "texteditor.h"
#include "eventsheet.h"

class ScoreEditor : public QWidget
{
  Q_OBJECT
public:
  explicit ScoreEditor(QWidget *parent = 0);

public slots:
  void setMode(int mode);
  void setPlainText(QString text);
  void setFontPointSize(float size);
  void setTabStopWidth(int width);
  void setLineWrapMode(QTextEdit::LineWrapMode mode);

  QString getPlainText();
  QString getSelection();

  void clearUndoRedoStacks();

protected:

private:
  int m_mode; // 0=text 1=sheet
  TextEditor *m_textEditor;
  EventSheet *m_sheet;

signals:

};

#endif // SCOREEDITOR_H
