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
#include "qutewidget.h"

#include <QSlider>

WidgetPanel::WidgetPanel(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Widgets");
  setMinimumSize(200, 140);
  QWidget *layoutWidget = new QWidget(this);
  layoutWidget->setGeometry(QRect(0, 0, 200, 100));


  QuteWidget *widget = new QuteWidget(layoutWidget, QUTE_SLIDER);
  widget->setWidgetGeometry(QRect(5, 5, 20, 100));
  widget->setRange(0,99);
  widget->setChannelName ("slider1");
  widgets.append(widget);

  widget = new QuteWidget(layoutWidget, QUTE_SLIDER);
  widget->setWidgetGeometry(QRect(45, 5, 20, 100));
  widget->setRange(0,99);
  widget->setChannelName ("slider2");
  widgets.append(widget);

  widget = new QuteWidget(layoutWidget, QUTE_SLIDER);
  widget->setWidgetGeometry(QRect(85, 5, 20, 100));
  widget->setRange(0,99);
  widget->setChannelName ("slider3");
  widgets.append(widget);

  widget = new QuteWidget(layoutWidget, QUTE_SLIDER);
  widget->setWidgetGeometry(QRect(125, 5, 20, 100));
  widget->setRange(0,99);
  widget->setChannelName ("slider4");
  widgets.append(widget);

  widget = new QuteWidget(layoutWidget, QUTE_SLIDER);
  widget->setWidgetGeometry(QRect(165, 5, 20, 100));
  widget->setRange(0,99);
  widget->setChannelName ("slider5");
  widgets.append(widget);

//   layoutWidget2 = new QWidget(layoutWidget);
//   layoutWidget2->setGeometry(QRect(5, 105, 20, 200));
//   label = new QLabel("test",layoutWidget2);

  setWidget(layoutWidget);
  resize(200, 100);
}


WidgetPanel::~WidgetPanel()
{
}

QVector< QPair<QString, double> > WidgetPanel::getValues()
{
  QVector<QPair<QString, double> > values;
  for (int i = 0; i < widgets.size(); i++) {
    values.append(qMakePair(widgets[i]->getChannelName(), widgets[i]->getValue() ));
  }
//   label->setText(QString::number(((QSlider *)widgets[0])->value() ));
  return values;
}

void WidgetPanel::closeEvent(QCloseEvent * event)
{
  emit Close(false);
}