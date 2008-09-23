/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#include "widgetpanel.h"

#include <QSlider>

WidgetPanel::WidgetPanel(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Widgets");
  setMinimumSize(200, 140);
  QWidget *layoutWidget = new QWidget(this);
  layoutWidget->setGeometry(QRect(0, 0, 200, 100));

  QWidget *layoutWidget2 = new QWidget(layoutWidget);
  layoutWidget2->setGeometry(QRect(5, 5, 20, 200));
  QSlider *slider = new QSlider(layoutWidget2);
  slider->setMinimumSize(20, 100);
  slider->setObjectName ("slider1");
  widgets.append(slider);

  layoutWidget2 = new QWidget(layoutWidget);
  layoutWidget2->setGeometry(QRect(45, 5, 20, 200));
  slider = new QSlider(layoutWidget2);
  slider->setMinimumSize(20, 100);
  slider->setObjectName ("slider2");
  widgets.append(slider);

  layoutWidget2 = new QWidget(layoutWidget);
  layoutWidget2->setGeometry(QRect(85, 5, 20, 200));
  slider = new QSlider(layoutWidget2);
  slider->setMinimumSize(20, 100);
  slider->setObjectName ("slider3");
  widgets.append(slider);

  layoutWidget2 = new QWidget(layoutWidget);
  layoutWidget2->setGeometry(QRect(125, 5, 20, 200));
  slider = new QSlider(layoutWidget2);
  slider->setMinimumSize(20, 100);
  slider->setObjectName ("slider4");
  widgets.append(slider);

  layoutWidget2 = new QWidget(layoutWidget);
  layoutWidget2->setGeometry(QRect(165, 5, 20, 200));
  slider = new QSlider(layoutWidget2);
  slider->setMinimumSize(20, 100);
  slider->setObjectName ("slider5");
  widgets.append(slider);

  setWidget(layoutWidget);
  resize(200, 100);
}


WidgetPanel::~WidgetPanel()
{
}

QVector< QPair<QString, int> > WidgetPanel::getValues()
{
  QVector<QPair<QString, int> > values;
  for (int i = 0; i < widgets.size(); i++) {
    values.append(qMakePair(widgets[i]->objectName (), ((QSlider *)widgets[i])->value() ));
  }
  return values;
}
