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
  m_max = 1.0;
  m_min = 0.0;
}

QuteSlider::~QuteSlider()
{
}

double QuteSlider::getValue()
{
  QSlider *slider = (QSlider *)m_widget;
  double normalized = (double) (slider->value() - slider->minimum())
        / (double) (slider->maximum() - slider->minimum());
  double value = m_min + (normalized * (m_max-m_min));
  return value;
}

// QString QuteSlider::getChannelName()
// {
//   return QuteWidget::getChannelName();
// }

void QuteSlider::setRange(int min, int max)
{
  m_min = min;
  m_max = max;
}

void QuteSlider::setValue(double value)
{
  m_value = value;
  int val = (int) (((QSlider *)m_widget)->maximum() * (m_value - m_min)/(m_max-m_min));
  ((QSlider *)m_widget)->setValue(val);
}

