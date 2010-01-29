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

Console::Console(QWidget *parent) : QTextEdit(parent)
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
    setTextColor(QColor("red"));
    if (msg.contains("line ")) {
      QStringList parts = msg.split("line ");
      int lineNumber = parts.last().remove(":").trimmed().toInt();
      errorLines.append(lineNumber);
      error = false;
    }
  }
  if (msg.contains("B ") or msg.contains("rtevent", Qt::CaseInsensitive)) {
    setTextColor(QColor("blue"));
  }
  if (msg.contains("error:", Qt::CaseInsensitive)) {
    error = true;
    setTextColor(QColor("red"));
  }
  if (msg.contains("overall samples out of range")
      or msg.contains("disabled")) {
    setTextColor(QColor("red"));
  }
  if (msg.contains("warning", Qt::CaseInsensitive)) {
    setTextColor(QColor("orange"));
  }
  insertPlainText(msg);
//   text->moveCursor(QTextCursor::Start);
//   text->moveCursor(QTextCursor::End);
  setTextColor(m_textColor);
  // Necessary hack to make sure Console show text properly. It's not working...
  //text->repaint(QRect(0,0, text->width(), text->height()));
//   lock.unlock();
}

void Console::setDefaultFont(QFont font) 
{
  document()->setDefaultFont(font);
}

void Console::setColors(QColor textColor, QColor bgColor)
{
  setTextColor(textColor);
//       text->setTextBackgroundColor(bgColor);
  QPalette p = palette();
  p.setColor(QPalette::WindowText, textColor);
  p.setColor(QPalette::Active, static_cast<QPalette::ColorRole>(9), bgColor);
  setPalette(p);
  setAutoFillBackground(true);
  m_textColor = textColor;
  m_bgColor = bgColor;
}

void Console::reset()
{
  clear();
  errorLines.clear();
  error = false;
}

void Console::scrollToEnd()
{
  moveCursor(QTextCursor::End);
}

void Console::setKeyRepeatMode(bool repeat)
{
  m_repeatKeys = repeat;
}

// void Console::refresh()
// {
//   // This is a necessary hack since QTextEdit appears to not refresh correctly
//   // Not working...
//   //text->repaint(QRect(0,0, text->width(), text->height()));
// }

void Console::contextMenuEvent(QContextMenuEvent *event)
{
  QMenu *menu = createStandardContextMenu();
  menu->addAction("Clear", this, SLOT(reset()));
  menu->exec(event->globalPos());
  delete menu;
}

void Console::keyPressEvent(QKeyEvent *event)
{
  if (!event->isAutoRepeat() or m_repeatKeys) {
    QString key = event->text();
    if (key != "") {
      appendMessage(key);
      emit keyPressed(key);
    }
  }
  // FIXME propagate keys to parent for keyboard shortcut actions from console
}

void Console::keyReleaseEvent(QKeyEvent *event)
{
  if (!event->isAutoRepeat() or m_repeatKeys) {
    QString key = event->text();
    if (key != "") {
      //           appendMessage("rel:" + key);
      emit keyReleased(key);
    }
  }
  // FIXME propagate keys to parent for keyboard shortcut actions from console
}

void DockConsole::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

void ConsoleWidget::setWidgetGeometry(int /*x*/,int /*y*/,int width,int height)
{
  setGeometry(QRect(0,0,width, height));
}
