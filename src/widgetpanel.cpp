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
#include "quteslider.h"

#include <QSlider>

WidgetPanel::WidgetPanel(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Widgets");
  setMinimumSize(200, 140);
  layoutWidget = new QWidget(this);
  layoutWidget->setGeometry(QRect(0, 0, 800, 600));
  layoutWidget->setAutoFillBackground(true);
//  QPalette palette(Qt::darkGreen);
//  layoutWidget->setPalette(palette);

//   QuteWidget *widget = new QuteWidget(layoutWidget, QUTE_SLIDER);
//   widget->setWidgetGeometry(QRect(5, 5, 20, 100));
//   widget->setRange(0,99);
//   widget->setChannelName ("slider1");
//   widgets.append(widget);
//   layoutWidget2 = new QWidget(layoutWidget);
//   layoutWidget2->setGeometry(QRect(5, 105, 20, 200));
//   label = new QLabel("test",layoutWidget2);

  setWidget(layoutWidget);
  resize(200, 100);
}

WidgetPanel::~WidgetPanel()
{
}

unsigned int WidgetPanel::widgetCount()
{
  return widgets.size();
}

void WidgetPanel::getValues(QVector<QString> *channelNames, QVector<double> *values)
{
  if (channelNames->size() < widgets.size())
    return;
  for (int i = 0; i < widgets.size(); i++) {
    (*channelNames)[i] = widgets[i]->getChannelName();
    (*values)[i] = widgets[i]->getValue();
  }
//   label->setText(QString::number(((QSlider *)widgets[0])->value() ));
//   return values;
}

int WidgetPanel::loadWidgets(QString macWidgets)
{
  clearWidgets();
  QStringList widgetLines = macWidgets.split(QRegExp("[\n\r]"), QString::SkipEmptyParts);
  foreach (QString line, widgetLines) {
    qDebug("WidgetLine: %s", line.toStdString().c_str());
    if (line.startsWith("i"))
      newWidget(line);
  }
  return 0;
}

int WidgetPanel::newWidget(QString widgetLine)
{
  QStringList parts = widgetLine.split(QRegExp("[\{\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (parts[0]=="ioView") {
    if (parts[1]=="background") {
      QColor bgColor(parts[2].toDouble()/65535., parts[3].toDouble()/65535., parts[4].toDouble()/65535.);
    //TODO set bg color;
    }
    else { // =="nobackground"
    }
    return 0;
  }
  else {
    int x,y,width,height;
    x = parts[1].toInt();
    y = parts[2].toInt();
    width = parts[3].toInt();
    height = parts[4].toInt();
    if (parts[0]=="ioSlider") {
      qDebug("ioSlider x=%i y=%i w=%i h=%i", x,y, width, height);
      QuteWidget *widget= new QuteSlider(layoutWidget);
      widget->setWidgetGeometry(x,y,width, height);
      widget->show();
      widgets.append(widget);
      widget->setRange(parts[5].toDouble(), parts[6].toDouble());
      widget->setValue(parts[7].toDouble());
      if (parts.size()>8) {
        int i=8;
        QString channelName = "";
        while (parts.size()>i) {
          channelName += parts[i] + " ";
          i++;
        }
        channelName.chop(1);  //remove last space
        widget->setChannelName(channelName);
      }
    }
    else if (parts[0]=="ioKnob") {
      QuteWidget *widget= new QuteWidget(this, QUTE_KNOB);
      widget->setWidgetGeometry(x,y,width, height);
      widget->show();
      widgets.append(widget);
      widget->setRange(parts[5].toDouble(), parts[6].toDouble());
      widget->setResolution(parts[7].toDouble());
      widget->setValue(parts[8].toDouble());
      if (parts.size()>9) {
        int i=9;
        QString channelName = "";
        while (parts.size()>i) {
          channelName += parts[i] + " ";
          i++;
        }
        channelName.chop(1);  //remove last space
        widget->setChannelName(channelName);
      }
    }
    else if (parts[0]=="ioCheckbox") {
      QuteWidget *widget= new QuteWidget(this, QUTE_CHECKBOX);
      widget->setWidgetGeometry(x,y,width, height);
      widget->show();
      widgets.append(widget);
      widget->setChecked(parts[5]=="on");
      if (parts.size()>5) {
        int i=5;
        QString channelName = "";
        while (parts.size()>i) {
          channelName += parts[i] + " ";
          i++;
        }
        channelName.chop(1);  //remove last space
        widget->setChannelName(channelName);
      }
    }
    else if (parts[0]=="ioButton") {
      QuteWidget *widget= new QuteWidget(this, QUTE_BUTTON);
      widget->setWidgetGeometry(x,y,width, height);
      widget->show();
      widgets.append(widget);
//       widget->setType(parts[5]);
      widget->setValue(parts[6].toDouble());  //value produced by button
      widget->setChannelName(quoteParts[1]);
      widget->setText(quoteParts[3]);
//       widget->setImage(quoteParts[5]);
      if (quoteParts.size()>6) {
        quoteParts[6].remove(0,1); //remove initial space
        widget->setChannelName(quoteParts[6]);
      }
    }
    else if (parts[0]=="ioText") {
      if (parts[5]=="label") {
        QuteWidget *widget= new QuteWidget(this, QUTE_LABEL);
        widget->setWidgetGeometry(x,y,width, height);
        widget->show();
        widgets.append(widget);
      }
      else if (parts[5]=="edit") {
        QuteWidget *widget= new QuteWidget(this, QUTE_LINEEDIT);
        widget->setWidgetGeometry(x,y,width, height);
        widget->show();
        widgets.append(widget);
      }
      else if (parts[5]=="display") {
        QuteWidget *widget= new QuteWidget(this, QUTE_DISPLAY);
        widget->setWidgetGeometry(x,y,width, height);
        widget->show();
        widgets.append(widget);
      }
      else if (parts[5]=="scrolleditnum") {
        QuteWidget *widget= new QuteWidget(this, QUTE_SCROLLNUMBER);
        widget->setWidgetGeometry(x,y,width, height);
        widget->show();
        widgets.append(widget);
      }
    }
    else if (parts[0]=="ioMenu") {
      QuteWidget *widget= new QuteWidget(this, QUTE_COMBOBOX);
      widget->setWidgetGeometry(x,y,width, height);
      widget->show();
	  widgets.append(widget);
      widget->setValue(parts[5].toInt());  //current Menu item
//       widget->setSize(parts[6].toInt());  // can be 201, 202, 203, 204, 205
      QStringList items= quoteParts[1].split(","); // menu items
    //TODO add menu items
      if (quoteParts.size()>2) {
        quoteParts[2].remove(0,1); //remove initial space
        widget->setChannelName(quoteParts[2]);
      }
    }
    else if (parts[0]=="ioMeter") {
//TODO implement MacCsound ioMeter
    }
    else {
  // Unknown widget...
    }
  }

    return 0;
  }

int WidgetPanel::clearWidgets()
{
  qDebug("WidgetPanel::clearWidgets()");
  foreach (QuteWidget *widget, widgets) {
    delete widget;
  }
  widgets.clear();
  return 0;
}

void WidgetPanel::closeEvent(QCloseEvent * event)
{
  emit Close(false);
}
