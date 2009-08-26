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

#include "console.h"

Console::Console()
{
  error = false;
}

Console::~Console()
{
}

void Console::appendMessage(QString msg)
{
//   lock.lock(); // This operation is already locked in qutecsound class
  if (error) {
    text->setTextColor(QColor("red"));
    if (msg.contains("line ")) {
      QStringList parts = msg.split("line ");
      int lineNumber = parts.last().remove(":").trimmed().toInt();
      errorLines.append(lineNumber);
      error = false;
    }
  }
  if (msg.contains("B ") or msg.contains("rtevent", Qt::CaseInsensitive)) {
    text->setTextColor(QColor("blue"));
  }
  if (msg.contains("error:", Qt::CaseInsensitive)) {
    error = true;
    text->setTextColor(QColor("red"));
  }
  if (msg.contains("overall samples out of range")
      or msg.contains("disabled")) {
    text->setTextColor(QColor("red"));
  }
  if (msg.contains("warning", Qt::CaseInsensitive)) {
    text->setTextColor(QColor("orange"));
  }
  text->insertPlainText(msg);
//   text->moveCursor(QTextCursor::Start);
//   text->moveCursor(QTextCursor::End);
  text->setTextColor(m_textColor);
  // Necessary hack to make sure Console show text properly. It's not working...
  //text->repaint(QRect(0,0, text->width(), text->height()));
//   lock.unlock();
}

void Console::setDefaultFont(QFont font) 
{
  text->document()->setDefaultFont(font);
}

void Console::setColors(QColor textColor, QColor bgColor)
{
  text->setTextColor(textColor);
//       text->setTextBackgroundColor(bgColor);
  QPalette palette = text->palette();
  palette.setColor(QPalette::WindowText, textColor);
  palette.setColor(QPalette::Active, static_cast<QPalette::ColorRole>(9), bgColor);
  text->setPalette(palette);
  text->setAutoFillBackground(true);
  m_textColor = textColor;
  m_bgColor = bgColor;
}

void Console::clear()
{
  text->clear();
  errorLines.clear();
  error = false;
}

void Console::scrollToEnd()
{
  text->moveCursor(QTextCursor::End);
}

// void Console::refresh()
// {
//   // This is a necessary hack since QTextEdit appears to not refresh correctly
//   // Not working...
//   //text->repaint(QRect(0,0, text->width(), text->height()));
// }

void DockConsole::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

void ConsoleWidget::setWidgetGeometry(int /*x*/,int /*y*/,int width,int height)
{
  text->setGeometry(QRect(0,0,width, height));
}
