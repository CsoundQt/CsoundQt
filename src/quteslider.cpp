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
#include "quteslider.h"

QuteSlider::QuteSlider(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QSlider(this);
  m_max = 1.0;
  m_min = 0.0;
  if (width() > height())
    ((QSlider *)m_widget)->setOrientation(Qt::Horizontal);
  else
    ((QSlider *)m_widget)->setOrientation(Qt::Vertical);
}

QuteSlider::~QuteSlider()
{
}

double QuteSlider::getValue()
{
  QSlider *slider = (QSlider *)m_widget;
  double normalized = (double) (slider->value() - slider->minimum())
        / (double) (slider->maximum() - slider->minimum());
  m_value = m_min + (normalized * (m_max-m_min));
  return m_value;
}

void QuteSlider::setRange(double min, double max)
{
  // TODO when slider is resized, its internal range should be adjusted to accomodate one value per pixel. There are currently 100 values no matter how many pixels...
  if (max < min) {
    double temp = max;
	max = min;
	min = temp;
  }
  m_min = min;
  m_max = max;
  if (m_value > m_max)
    m_value = m_max;
  else if (m_value > m_min)
    m_value = m_min;
}

void QuteSlider::setValue(double value)
{
  if (value > m_max)
    m_value = m_max;
  else if (value > m_min)
    m_value = m_min;
  else
    m_value = value;
  int val = (int) (((QSlider *)m_widget)->maximum() * (m_value - m_min)/(m_max-m_min));
  ((QSlider *)m_widget)->setValue(val);
}

void QuteSlider::setWidgetGeometry(int x, int y, int w, int h)
{
  setWidgetGeometry(QRect(x,y,w,h));
  if (width() > height())
    ((QSlider *)m_widget)->setOrientation(Qt::Horizontal);
  else
    ((QSlider *)m_widget)->setOrientation(Qt::Vertical);
}

void QuteSlider::setWidgetGeometry(QRect rect)
{
  QuteWidget::setWidgetGeometry(rect);
}

void QuteSlider::setWidgetLine(QString line)
{
  m_line = line;
}

QString QuteSlider::getWidgetLine()
{
  QString line = "ioSlider {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(m_min, 'f', 6) + " " + QString::number(m_max, 'f', 6) + " ";
  line += QString::number(m_value, 'f', 6) + " " + m_name;
  qDebug("QuteSlider::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

void QuteSlider::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  QLabel *label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Min =");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 2, 0, Qt::AlignRight|Qt::AlignVCenter);
  minSpinBox = new QDoubleSpinBox(dialog);
  minSpinBox->setDecimals(6);
  minSpinBox->setRange(-99999.0, 99999.0);
  minSpinBox->setValue(m_min);
  layout->addWidget(minSpinBox, 2,1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Max =");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 2, 2, Qt::AlignRight|Qt::AlignVCenter);
  maxSpinBox = new QDoubleSpinBox(dialog);
  maxSpinBox->setDecimals(6);
  maxSpinBox->setRange(-99999.0, 99999.0);
  maxSpinBox->setValue(m_max);
  layout->addWidget(maxSpinBox, 2,3, Qt::AlignLeft|Qt::AlignVCenter);
}

void QuteSlider::applyProperties()
{
  setRange(maxSpinBox->value(), minSpinBox->value());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}
