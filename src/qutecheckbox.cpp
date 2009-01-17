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
#include "qutecheckbox.h"

QuteCheckBox::QuteCheckBox(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QCheckBox(this);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);

  connect(static_cast<QCheckBox *>(m_widget), SIGNAL(stateChanged(int)), this, SLOT(stateChanged(int)));
}

QuteCheckBox::~QuteCheckBox()
{
}

void QuteCheckBox::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  while (!mutex.tryLock()) {
    sleep(1);
  }
#endif
  // value is 1 is checked, 0 if not
  static_cast<QCheckBox *>(m_widget)->setChecked(value == 1);
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

double QuteCheckBox::getValue()
{
  return (static_cast<QCheckBox *>(m_widget)->isChecked()? 1.0:0.0);
}

QString QuteCheckBox::getWidgetLine()
{
  QString line = "ioCheckbox {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += (static_cast<QCheckBox *>(m_widget)->isChecked()? QString("on "):QString("off "));
  line += m_name;
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

void QuteCheckBox::stateChanged(int state)
{
  if (state == Qt::Unchecked)
    emit valueChanged(0);
  else if (state == Qt::Checked)
    emit valueChanged(1);
}

void QuteCheckBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Check Box");
}
