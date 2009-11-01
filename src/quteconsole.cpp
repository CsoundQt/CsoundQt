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

#include "quteconsole.h"

QuteConsole::QuteConsole(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new ConsoleWidget(this);
  m_widget->setAutoFillBackground(true);
  m_widget->setFocusPolicy(Qt::NoFocus);
//   connect(static_cast<ConsoleWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteConsole::~QuteConsole()
{
}

void QuteConsole::loadFromXml(QString xmlText)
{
  qDebug() << "loadFromXml not implemented for this widget yet";
}

QString QuteConsole::getWidgetLine()
{
  QString line = "ioListing {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"}";
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteConsole::getWidgetXmlText()
{
  // Consoles are not implemented in blue
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);
  // Nothing else needed here

  s.writeEndElement();
  return xmlText;
}

QString QuteConsole::getWidgetType()
{
  return QString("BSBConsole");
}

// void QuteConsole::popUpMenu(QPoint pos)
// {
//   QuteWidget::popUpMenu(pos);
// }

void QuteConsole::appendMessage(QString message)
{
  static_cast<ConsoleWidget *>(m_widget)->appendMessage(message);
}

void QuteConsole::scrollToEnd()
{
//qDebug() << "QuteConsole::refresh()";
  static_cast<ConsoleWidget *>(m_widget)->scrollToEnd();
}

void QuteConsole::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x,y,width, height);
  static_cast<ConsoleWidget *>(m_widget)->setWidgetGeometry(x,y,width, height);
}

