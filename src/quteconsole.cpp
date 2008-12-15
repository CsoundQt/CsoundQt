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
#include "quteconsole.h"

QuteConsole::QuteConsole(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new ConsoleWidget(this);
  m_widget->setAutoFillBackground(true);
  connect(static_cast<ConsoleWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteConsole::~QuteConsole()
{
}

QString QuteConsole::getWidgetLine()
{
  QString line = "ioListing {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"}";
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

void QuteConsole::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}

void QuteConsole::appendMessage(QString message)
{
  static_cast<ConsoleWidget *>(m_widget)->appendMessage(message);
}

void QuteConsole::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x,y,width, height);
  static_cast<ConsoleWidget *>(m_widget)->setWidgetGeometry(x,y,width, height);
}

