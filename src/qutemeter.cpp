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
#include "qutemeter.h"

QuteMeter::QuteMeter(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new MeterWidget(this);
  m_widget->setAutoFillBackground(true);
  connect(((MeterWidget *)m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteMeter::~QuteMeter()
{
}

void QuteMeter::setValue(double /*value*/)
{
  // No action
}

double QuteMeter::getValue()
{
//This widget has no value
  return 0.0;
}

QString QuteMeter::getWidgetLine()
{
  QString line = "ioListing {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"}";
  qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

void QuteMeter::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}

void QuteMeter::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x,y,width, height);
//   ((MeterWidget *)m_widget)->setWidgetGeometry(x,y,width, height);
}

