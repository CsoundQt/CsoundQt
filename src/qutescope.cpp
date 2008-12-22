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
#include "qutescope.h"
// #include <cmath>

QuteScope::QuteScope(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new ScopeWidget(this);
  m_widget->show();
  m_widget->setAutoFillBackground(true);
  m_label = new QLabel(this);
  QPalette palette = m_widget->palette();
  palette.setColor(QPalette::WindowText, Qt::white);
  m_label->setPalette(palette);
  m_label->setText("Scope");
  m_label->move(85, 0);
  m_label->resize(500, 25);

  connect(dynamic_cast<ScopeWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteScope::~QuteScope()
{
}

QString QuteScope::getWidgetLine()
{
  QString line = "ioGraph {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += m_type;
  return line;
}

void QuteScope::setType(QString type)
{
  m_type = type;
}

void QuteScope::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x,y,width, height);
//   dynamic_cast<ScopeWidget *>(m_widget)->setWidgetGeometry(0,0,width, height);
  if (index < 0)
    return;
}

void QuteScope::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Graph");
  channelLabel->hide();
  nameLineEdit->hide();
}

