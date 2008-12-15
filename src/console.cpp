/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
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
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.             *
 ***************************************************************************/
#include "console.h"

Console::Console()
{
}

Console::~Console()
{
}

void Console::appendMessage(QString msg)
{
  if (msg.contains("B ") or msg.contains("rtevent", Qt::CaseInsensitive)) {
    text->setTextColor(QColor("blue"));
  }
  if (msg.contains("error", Qt::CaseInsensitive)
      or msg.contains("overall samples out of range")) {
    text->setTextColor(QColor("red"));
  }
  if (msg.contains("warning", Qt::CaseInsensitive)) {
    text->setTextColor(QColor("orange"));
  }
  text->insertPlainText(msg);
  text->moveCursor(QTextCursor::End);
  text->setTextColor(QColor("black"));
}

void Console::clear()
{
  text->clear();
}

void DockConsole::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

void ConsoleWidget::setWidgetGeometry(int /*x*/,int /*y*/,int width,int height)
{
  text->setGeometry(QRect(0,0,width, height));
}
