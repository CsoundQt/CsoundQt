/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
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
#include "widgetpanel.h"
#include "qutewidget.h"
#include "quteslider.h"
#include "qutetext.h"
#include "qutebutton.h"
#include "quteknob.h"
#include "qutedummy.h"


WidgetPanel::WidgetPanel(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Widgets");
  setMinimumSize(200, 140);
  layoutWidget = new QWidget(this);
  layoutWidget->setGeometry(QRect(0, 0, 800, 600));
  layoutWidget->setAutoFillBackground(true);
  createSliderAct = new QAction(tr("Create Slider"),this);
  connect(createSliderAct, SIGNAL(triggered()), this, SLOT(createSlider()));
  createLabelAct = new QAction(tr("Create Label"),this);
  connect(createLabelAct, SIGNAL(triggered()), this, SLOT(createLabel()));
  createButtonAct = new QAction(tr("Create Button"),this);
  connect(createButtonAct, SIGNAL(triggered()), this, SLOT(createButton()));
  createKnobAct = new QAction(tr("Create Knob"),this);
  connect(createKnobAct, SIGNAL(triggered()), this, SLOT(createKnob()));

  setWidget(layoutWidget);
  resize(200, 100);

  eventQueue.resize(QUTECSOUND_MAX_EVENTS);
  eventQueueSize = 0;
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
}

void WidgetPanel::setValue(QString channelName, double value)
{
  for (int i = 0; i < widgets.size(); i++) {
    if (widgets[i]->getChannelName() == channelName) {
      widgets[i]->setValue(value);
    }
  }
}

void WidgetPanel::setValue(int index, double value)
{
  if (index>widgets.size())
    return;
  widgets[index]->setValue(value);
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
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"'); //Remove this line whe not needed
  if (parts.size()<5)
    return -1;
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
	  return createSlider(x,y,width,height, widgetLine);
    }
    else if (parts[0]=="ioText") {
      if (parts[5]=="label") {
        return createLabel(x,y,width,height, widgetLine);
      }
      else if (parts[5]=="edit") {
        return createDummy(x,y,width, height, widgetLine);
      }
      else if (parts[5]=="display") {
        return createDummy(x,y,width, height, widgetLine);
      }
      else if (parts[5]=="scrolleditnum") {
        return createDummy(x,y,width, height, widgetLine);
      }
    }
    else if (parts[0]=="ioButton") {
      return createButton(x,y,width,height, widgetLine);
    }
    else if (parts[0]=="ioKnob") {
      return createKnob(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioCheckbox") {
      return createDummy(x,y,width, height, widgetLine);
//       widget->setChecked(parts[5]=="on");
//       if (parts.size()>5) {
//         int i=5;
//         QString channelName = "";
//         while (parts.size()>i) {
//           channelName += parts[i] + " ";
//           i++;
//         }
//         channelName.chop(1);  //remove last space
//         widget->setChannelName(channelName);
//       }
//       connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
    }
    else if (parts[0]=="ioMenu") {
      return createDummy(x,y,width, height, widgetLine);
//       connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
//       widget->setValue(parts[5].toInt());  //current Menu item
// //       widget->setSize(parts[6].toInt());  // can be 201, 202, 203, 204, 205
//       QStringList items= quoteParts[1].split(","); // menu items
//     //TODO add menu items
//       if (quoteParts.size()>2) {
//         quoteParts[2].remove(0,1); //remove initial space
//         widget->setChannelName(quoteParts[2]);
//       }
    }
    else if (parts[0]=="ioMeter") {
      return createDummy(x,y,width, height, widgetLine);
    }
    else {
      return createDummy(x,y,width, height, widgetLine);
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

void WidgetPanel::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

QString WidgetPanel::widgetsText()
{
  QString text = "<MacGUI>\n";
  for (int i = 0; i < widgets.size(); i++) {
    text += widgets[i]->getWidgetLine() + "\n";
  }
  text += "</MacGUI>";
  return text;
}

void WidgetPanel::deleteWidget(QuteWidget *widget)
{
  int number = widgets.indexOf(widget);
  qDebug("WidgetPanel::deleteWidget %i", number);
  widgets.remove(number);
  widget->close();
  widgetChanged();
}

void WidgetPanel::queueEvent(QString eventLine)
{
  qDebug("WidgetPanel::queueEvent %s", eventLine.toStdString().c_str());
  if (eventQueueSize < QUTECSOUND_MAX_EVENTS) {
    eventQueue[eventQueueSize] = eventLine;
    eventQueueSize++;
  }
  else
    qDebug("Warning: event queue full, event not processed");
}

void WidgetPanel::contextMenuEvent(QContextMenuEvent *event)
{
  QMenu menu;
  menu.addAction(createSliderAct);
  menu.addAction(createLabelAct);
  menu.addAction(createButtonAct);
  menu.addAction(createKnobAct);
  currentPosition = event->pos();
  menu.exec(event->globalPos());
}

void WidgetPanel::widgetChanged()
{
  QString text = widgetsText();
  emit widgetsChanged(text);
}

int WidgetPanel::createSlider(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioSlider x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteSlider *widget= new QuteSlider(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
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
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createLabel(int x, int y, int width, int height, QString widgetLine)
{
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (parts.size()<20 or quoteParts.size()<5)
    return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (lastParts.size() < 9)
    return -1;
  QuteText *widget= new QuteText(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setResolution(parts[7].toDouble());
  widget->setChannelName(quoteParts[1]);
  if (quoteParts[2] == " left ")
    widget->setAlignment(0);
  else if (quoteParts[2] == " center ")
    widget->setAlignment(1);
  else if (quoteParts[2] == " right ")
    widget->setAlignment(2);
  widget->setFont(quoteParts[3]);
  widget->setFontSize(lastParts[0].toInt());
  widget->setTextColor(QColor(lastParts[1].toDouble()/256.0,
                       lastParts[2].toDouble()/256.0,
                                             lastParts[3].toDouble()/256.0));
  widget->setBgColor(QColor(lastParts[4].toDouble()/256.0,
                     lastParts[5].toDouble()/256.0,
                                           lastParts[6].toDouble()/256.0));
  widget->setBg(lastParts[7] == "background");
  widget->setBorder(lastParts[8] == "border");
  QString labelText = "";
  int i = 9;
  while (lastParts.size() > i) {
    labelText += lastParts[i] + " ";
    i++;
  }
  labelText.chop(1);
  widget->setText(labelText);
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createButton(int x, int y, int width, int height, QString widgetLine)
{
  qDebug("WidgetPanel::createButton");
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
//   if (parts.size()<20 or quoteParts.size()>5)
//     return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
//   if (lastParts.size() < 9)
//     return -1;
  QuteButton *widget= new QuteButton(this);
  widget->setWidgetLine(widgetLine);
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
    widget->setEventLine(quoteParts[6]);
  }
  connect(widget, SIGNAL(queueEvent(QString)), this, SLOT(queueEvent(QString)));
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));

  return 1;
}

int WidgetPanel::createKnob(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioKnob x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteKnob *widget= new QuteKnob(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setRange(parts[5].toDouble(), parts[6].toDouble());
  //TODO set resolution of knob
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
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createDummy(int x, int y, int width, int height, QString widgetLine)
{
  QuteWidget *widget= new QuteDummy(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->show();
  widgets.append(widget);
  return 1;
}

void WidgetPanel::createSlider()
{
  createSlider(currentPosition.x(), currentPosition.y() - 20, 20, 100, QString("ioSlider {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {20, 100} 0.000000 1.000000 0.000000 slider" +QString::number(widgets.size())));
}

void WidgetPanel::createLabel()
{
  QString line = "ioText {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) +"} {80, 25} label 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground border New Label";
  createLabel(currentPosition.x(), currentPosition.y() - 20, 80, 25, line);
}

void WidgetPanel::createButton()
{
  QString line = "ioButton {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) +"} {100, 40} event 1.000000 \"button1\" \"New Button\" \"/\" i1 0 10";
  createButton(currentPosition.x(), currentPosition.y() - 20, 100, 40, line);
}

void WidgetPanel::createKnob()
{
  createKnob(currentPosition.x(), currentPosition.y() - 20, 80, 80, QString("ioKnob {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {80, 80} 0.000000 1.000000 0.010000 0.000000 knob" +QString::number(widgets.size())));
}
