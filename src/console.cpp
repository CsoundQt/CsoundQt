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
  errorLine = false;
  setReadOnly(true);
}

Console::~Console()
{
  disconnect(this, 0,0,0);
}

struct CursorUpdater
{
    Console &console;
    CursorUpdater(Console &console_) : console(console_)
    {
    }
    ~CursorUpdater()
    {
        console.moveCursor(QTextCursor::End);
        console.ensureCursorVisible();
    }
};

void Console::appendMessage(QString msg)
{
  logMessage(msg);
  // Filter unnecessary messages
  if (msg.startsWith("libsndfile-1") || msg.startsWith("UnifiedCSD: ")
     || msg.startsWith("orchname: ") || msg.startsWith("scorename: ")
     || msg.startsWith("PortMIDI real time MIDI plugin for Csound")
    || msg.startsWith("PortAudio real-time audio module for Csound")
    || msg.startsWith("virtual_keyboard real time MIDI plugin for Csound")
    || msg.startsWith("Removing temporary file") ) {
    return;
  }
  CursorUpdater cursorUpdater(*this);
  setTextColor(m_textColor);
  if (errorLine) {  // Hack to capture strange message organization from Csound
    errorLineText.append(msg);
    if (msg == "\n" || errorLineText.contains("\n")) {
      errorTexts.append(errorLineText.remove("\n"));
      errorLineText.clear();
      errorLine = false;
    }
  }
  if (error) {
    setTextColor(QColor("red"));
    if (msg.contains("line ")) {
      QStringList parts = msg.split("line ");
      int lineNumber = parts.last().remove(":").trimmed().toInt();
      errorLines.append(lineNumber);
      qDebug() << "error line appended --- " << lineNumber;  //FIXME why are lines appended twice? (two consoles??)
      error = false;
      errorLine = true;
    }
  }
  if (msg.startsWith("B ") or msg.contains("rtevent", Qt::CaseInsensitive)) {
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
  setTextColor(m_textColor);
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
  p.setColor(static_cast<QPalette::ColorRole>(9), bgColor);
  setPalette(p);
  setAutoFillBackground(true);
  m_textColor = textColor;
  m_bgColor = bgColor;
}

void Console::reset()
{
  clear();
  errorLines.clear();
  errorTexts.clear();
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
}

// ---------------------------------------------------------------

DockConsole::DockConsole(QWidget * parent): QDockWidget(parent)
{
  setWindowTitle(tr("Output Console"));
//  text = new Console(parent);
//  text->setReadOnly(true);
//  text->setContextMenuPolicy(Qt::NoContextMenu);
//  text->document()->setDefaultFont(QFont("Courier", 10));
//  setWidget(text);
  //      QStackedLayout *l = new QStackedLayout(this);
  //      l->addWidget(text);
  //      setLayout(l);
}

DockConsole::~DockConsole()
{;}

void DockConsole::copy()
{
  qDebug() << "DockConsole::copy()";
  static_cast<Console *>(widget())->copy();
}

bool DockConsole::widgetHasFocus()
{
  return widget()->hasFocus();
}

void DockConsole::appendMessage(QString msg)
{
  static_cast<Console *>(widget())->appendMessage(msg);
  static_cast<Console *>(widget())->scrollToEnd();
}

//void DockConsole::reset()
//{
//  widget()->clear();
//}

void DockConsole::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

// ---------------------------------------------------------------

void ConsoleWidget::setWidgetGeometry(int /*x*/,int /*y*/,int width,int height)
{
  setGeometry(QRect(0,0,width, height));
}
