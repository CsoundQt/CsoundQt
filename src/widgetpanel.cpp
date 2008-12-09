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
#include "qutecheckbox.h"
#include "qutecombobox.h"
#include "qutemeter.h"
#include "quteconsole.h"
#include "qutegraph.h"
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
  createCheckBoxAct = new QAction(tr("Create Checkbox"),this);
  connect(createCheckBoxAct, SIGNAL(triggered()), this, SLOT(createCheckBox()));
  createMenuAct = new QAction(tr("Create Menu"),this);
  connect(createMenuAct, SIGNAL(triggered()), this, SLOT(createMenu()));
  createMeterAct = new QAction(tr("Create Controller"),this);
  connect(createMeterAct, SIGNAL(triggered()), this, SLOT(createMeter()));
  createConsoleAct = new QAction(tr("Create Console"),this);
  connect(createConsoleAct, SIGNAL(triggered()), this, SLOT(createConsole()));
  createGraphAct = new QAction(tr("Create Graph"),this);
  connect(createGraphAct, SIGNAL(triggered()), this, SLOT(createGraph()));
  propertiesAct = new QAction(tr("Properties"),this);
  connect(propertiesAct, SIGNAL(triggered()), this, SLOT(propertiesDialog()));
  editAct = new QAction(tr("Edit Mode"), this);
  editAct->setCheckable(true);
  connect(editAct, SIGNAL(triggered(bool)), this, SLOT(activateEditMode(bool)));
  clearAct = new QAction(tr("Clear all widgets"), this);
  connect(clearAct, SIGNAL(triggered()), this, SLOT(clearWidgets()));

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
  if (channelNames->size() < widgets.size()*2)
    return;
  for (int i = 0; i < widgets.size(); i++) {
    (*channelNames)[i*2] = widgets[i]->getChannelName();
    (*values)[i*2] = widgets[i]->getValue();
    (*channelNames)[i*2 + 1] = widgets[i]->getChannel2Name();
    (*values)[i*2 + 1] = widgets[i]->getValue2();
  }
}

void WidgetPanel::setValue(QString channelName, double value)
{
  for (int i = 0; i < widgets.size(); i++) {
    if (widgets[i]->getChannelName() == channelName) {
      widgets[i]->setValue(value);
    }
    if (widgets[i]->getChannel2Name() == channelName) {
      widgets[i]->setValue2(value);
    }
  }
}

void WidgetPanel::setValue(QString channelName, QString value)
{
  for (int i = 0; i < widgets.size(); i++) {
    if (widgets[i]->getChannelName() == channelName) {
      widgets[i]->setValue(value);
    }
//     if (widgets[i]->getChannel2Name() == channelName) {
//       widgets[i]->setValue2(value);
//     }
  }
}

void WidgetPanel::setValue(int index, double value)
{
  //index can be greater that widgets.size for value2
  if (index >= widgets.size() * 2)
    return;
  widgets[index/2]->setValue(value);
}

void WidgetPanel::setValue(int index, QString value)
{
  //index can be greater that widgets.size for value2
  if (index >= widgets.size() * 2)
    return;
  widgets[index/2]->setValue(value);
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
  if (editAct->isChecked()) {
    activateEditMode(true);
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
  // Colors in MacCsound have a range of 0-65535
    setBackground(parts[1]=="background",
                  QColor(parts[2].toInt()/256,
                         parts[3].toInt()/256,
                         parts[4].toInt()/256
                        )
                 );
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
      if (parts[5]=="label" or parts[5]=="display") {
        return createLabel(x,y,width,height, widgetLine);
      }
      else if (parts[5]=="edit" or parts[5]=="scrolleditnum") {
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
      return createCheckBox(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioMenu") {
      return createMenu(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioListing") {
      return createConsole(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioMeter") {
      return createMeter(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioGraph") {
      return createGraph(x,y,width, height, widgetLine);
    }
    else {
      // Unknown widget...
      qDebug("WidgetPanel::newWidget Warning: unknown widget!");
      return createDummy(x,y,width, height, widgetLine);
    }
  }
    return 0;
  }

void WidgetPanel::clearWidgets()
{
  qDebug("WidgetPanel::clearWidgets()");
  foreach (QuteWidget *widget, widgets) {
    delete widget;
  }
  for(int i = 0; i< editWidgets.size(); i++){
    delete(editWidgets[i]);
  }
  editWidgets.clear();
  widgets.clear();
  consoleWidgets.clear();
}

void WidgetPanel::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

QString WidgetPanel::widgetsText()
{
  QString text = "<MacGUI>\n";
  text += "ioView " + (autoFillBackground()? QString("background "):QString("nobackground "));
  text += "{" + QString::number((int) (palette().button().color().redF()*65535.)) + ", ";
  text +=  QString::number((int) (palette().button().color().greenF()*65535.)) + ", ";
  text +=  QString::number((int) (palette().button().color().blueF()*65535.)) +"}\n";

  for (int i = 0; i < widgets.size(); i++) {
    text += widgets[i]->getWidgetLine() + "\n";
  }
  text += "</MacGUI>";
  return text;
}

void WidgetPanel::appendMessage(QString message)
{
  for (int i=0; i < consoleWidgets.size(); i++) {
    consoleWidgets[i]->appendMessage(message);
  }
}

void WidgetPanel::showTooltips(bool show)
{
  for (int i=0; i < widgets.size(); i++) {
    if (show) {
      if (widgets[i]->getChannel2Name() != "") {
        widgets[i]->setToolTip(tr("ChannelV:") + widgets[i]->getChannelName()
            + tr("\nChannelH:")+ widgets[i]->getChannel2Name());
      }
      else {
        widgets[i]->setToolTip(tr("Channel:") + widgets[i]->getChannelName());
      }
    }
    else
      widgets[i]->setToolTip("");
  }
}

void WidgetPanel::deleteWidget(QuteWidget *widget)
{
  int number = widgets.indexOf(widget);
  //if (consoleWidgets.contains((QuteConsole *)widget));
  //  consoleWidgets.remove(consoleWidgets.indexOf((QuteConsole *)widget));
  qDebug("WidgetPanel::deleteWidget %i", number);
  widget->close();
  widgets.remove(number);
  if (!editWidgets.isEmpty()) {
    delete(editWidgets[number]);
    editWidgets.remove(number);
  }
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
  menu.addAction(createCheckBoxAct);
  menu.addAction(createMenuAct);
  menu.addAction(createMeterAct);
  menu.addAction(createConsoleAct);
  menu.addAction(createGraphAct);
  menu.addSeparator();
  menu.addAction(editAct);
  menu.addSeparator();
  menu.addAction(clearAct);
  menu.addSeparator();
  menu.addAction(propertiesAct);
  currentPosition = event->pos();
  menu.exec(event->globalPos());
}

void WidgetPanel::newValue(QHash<QString, double> channelValue)
{
//   //qDebug("WidgetPanel::newValue");
  widgetChanged();
}

void WidgetPanel::widgetChanged()
{
  QString text = widgetsText();
  if (widgets.size() > 0 and widgets[0]->toolTip() != "")
    showTooltips(true);
  if (editAct->isChecked()) {
    activateEditMode(false);
    activateEditMode(true); // recreate widget edit boxes
  }
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
  connect(widget, SIGNAL(newValue(QHash<QString,double>)), this, SLOT(newValue(QHash<QString,double>)));
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
  widget->setType(parts[5]);
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
//   qDebug("WidgetPanel::createButton");
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
//   if (parts.size()<20 or quoteParts.size()>5)
//     return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
//   if (lastParts.size() < 9)
//     return -1;
  QuteButton *widget= new QuteButton(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->show();
  widgets.append(widget);
  widget->setValue(parts[6].toDouble());  //value produced by button
  widget->setChannelName(quoteParts[1]);
  widget->setText(quoteParts[3]);
  widget->setFilename(quoteParts[5]);
  widget->setType(parts[5]); // setType must come after setFilename so image is loaded
  if (quoteParts.size()>6) {
    quoteParts[6].remove(0,1); //remove initial space
    widget->setEventLine(quoteParts[6]);
  }
  connect(widget, SIGNAL(queueEvent(QString)), this, SLOT(queueEvent(QString)));
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));

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
  connect(widget, SIGNAL(newValue(QHash<QString,double>)), this, SLOT(newValue(QHash<QString,double>)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createCheckBox(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioCheckBox x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteCheckBox *widget= new QuteCheckBox(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setValue(parts[5]=="on");
  if (parts.size()>6) {
    int i=6;
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
  connect(widget, SIGNAL(newValue(QHash<QString,double>)), this, SLOT(newValue(QHash<QString,double>)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createMenu(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioMenu x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  QuteComboBox *widget= new QuteComboBox(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setSize(parts[6].toInt());
  widget->setText(quoteParts[1]);
  widget->setValue(parts[5].toDouble()); //setValue must be after setText otherwise ComboBox is empty
  if (quoteParts.size() > 2)
    widget->setChannelName(quoteParts[2].remove(0,1)); //remove initial space from channel name
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QHash<QString,double>)), this, SLOT(newValue(QHash<QString,double>)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createMeter(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioMenu x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (quoteParts.size() < 5) {
    qDebug("WidgetPanel::createMeter ERROR parsing widget line!");
    return 0;
  }
  QStringList parts2 = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (parts2.size() < 5) {
    qDebug("WidgetPanel::createMeter ERROR parsing widget line!");
    return 0;
  }
  QuteMeter *widget= new QuteMeter(layoutWidget);
  //TODO is setWidgetLine actually necessary?
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setColor(QColor(parts[5].toDouble()/256.0,
                       parts[6].toDouble()/256.0,
                                         parts[7].toDouble()/256.0));
  widget->setType(parts2[1]); // Important to set type before setting values since values are inverted for crosshair and point
  widget->setChannelName(quoteParts[1]);
  widget->setValue(quoteParts[2].toDouble());
  widget->setChannel2Name(quoteParts[3]);
  widget->setValue2(parts2[0].toDouble());
  widget->setPointSize(parts2[2].toInt());
  widget->setFadeSpeed(parts2[3].toInt());
  widget->setBehavior(parts2[4]);
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QHash<QString,double>)), this, SLOT(newValue(QHash<QString,double>)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createConsole(int x, int y, int width, int height, QString widgetLine)
{
//    qDebug("ioListing x=%i y=%i w=%i h=%i", x,y, width, height);
   QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
   QuteConsole *widget= new QuteConsole(layoutWidget);
   widget->setWidgetLine(widgetLine);
   widget->setWidgetGeometry(x,y,width, height);
   connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
   connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
   widgets.append(widget);
   widget->show();
   consoleWidgets.append(widget);
   return 1;
}

int WidgetPanel::createGraph(int x, int y, int width, int height, QString widgetLine)
{
  qDebug("ioGraph x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteGraph *widget= new QuteGraph(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  connect(widget, SIGNAL(widgetChanged()), this, SLOT(widgetChanged()));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  widgets.append(widget);
  widget->show();
  return 1;
}

int WidgetPanel::createDummy(int x, int y, int width, int height, QString widgetLine)
{
  QuteWidget *widget= new QuteDummy(layoutWidget);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->show();
  widgets.append(widget);
  return 1;
}

void WidgetPanel::setBackground(bool bg, QColor bgColor)
{
  if (bg) {
    setPalette(QPalette(bgColor));
    setAutoFillBackground(true);
  }
  else { // =="nobackground"
    setPalette(QPalette());
    setAutoFillBackground(false);
  }
}

void WidgetPanel::activateEditMode(bool active)
{
  if (active) {
    foreach (QuteWidget * widget, widgets) {
      FrameWidget * frame = new FrameWidget(layoutWidget);
      QPalette palette(QColor(Qt::red),QColor(Qt::red));
      palette.setColor(QPalette::WindowText, QColor(Qt::red));
      frame->setWidget(widget);
      frame->setPalette(palette);
      frame->setGeometry(widget->x(), widget->y(), widget->width(), widget->height());
      frame->setFrameShape(QFrame::Box);
//       frame->setMouseTracking(false);  //Only track mouse when buttons are pressed
      frame->show();
      editWidgets.append(frame);
      connect(frame, SIGNAL(popUpMenu(QPoint)), widget, SLOT(popUpMenu(QPoint)));
    }
  }
  else {
    foreach (QFrame* frame, editWidgets) {
      delete(frame);
    }
    editWidgets.clear();
  }
//   this line breaks movement of widgets....
//   editAct->setChecked(active);
}

void WidgetPanel::createSlider()
{
  createSlider(currentPosition.x(), currentPosition.y() - 20, 20, 100, QString("ioSlider {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {20, 100} 0.000000 1.000000 0.000000 slider" +QString::number(widgets.size())));
  widgetChanged();
}

void WidgetPanel::createLabel()
{
  QString line = "ioText {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) +"} {80, 25} label 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground border New Label";
  createLabel(currentPosition.x(), currentPosition.y() - 20, 80, 25, line);
  widgetChanged();
}

void WidgetPanel::createButton()
{
  QString line = "ioButton {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) +"} {100, 40} event 1.000000 \"button1\" \"New Button\" \"/\" i1 0 10";
  createButton(currentPosition.x(), currentPosition.y() - 20, 100, 40, line);
  widgetChanged();
}

void WidgetPanel::createKnob()
{
  createKnob(currentPosition.x(), currentPosition.y() - 20, 80, 80, QString("ioKnob {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {80, 80} 0.000000 1.000000 0.010000 0.000000 knob" +QString::number(widgets.size())));
  widgetChanged();
}

void WidgetPanel::createCheckBox()
{
  createCheckBox(currentPosition.x(), currentPosition.y() - 20, 20, 20, QString("ioCheckbox {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {20, 20} off checkbox" +QString::number(widgets.size())));
  widgetChanged();
}

void WidgetPanel::createMenu()
{
  createMenu(currentPosition.x(), currentPosition.y() - 20, 80, 30, QString("ioMenu {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {80, 30} 1 303 \"item1,item2,item3\" menu" +QString::number(widgets.size())));
  widgetChanged();
}

void WidgetPanel::createMeter()
{
  createMeter(currentPosition.x(), currentPosition.y() - 20, 30, 80, QString("ioMeter {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {30, 80} {0, 60000, 0} \"vert" + QString::number(widgets.size()) + "\" 0.000000 \"hor" + QString::number(widgets.size()) + "\" 0.000000 fill 1 0 mouse"));
  widgetChanged();
}

void WidgetPanel::createConsole()
{
  createConsole(currentPosition.x(), currentPosition.y() - 20, 320, 400, QString("ioListing {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {320, 400}"));
  widgetChanged();
}

void WidgetPanel::createGraph()
{
  createGraph(currentPosition.x(), currentPosition.y() - 20, 400, 200, QString("ioGraph {"+ QString::number(currentPosition.x()) +", "+ QString::number(currentPosition.y() - 20) + "} {400, 200}"));
  widgetChanged();
}

void WidgetPanel::propertiesDialog()
{
  QDialog *dialog = new QDialog(this);
  dialog->resize(300, 300);
  dialog->setModal(true);
  QGridLayout *layout = new QGridLayout(dialog);
  bgCheckBox = new QCheckBox(dialog);
  bgCheckBox->setText("Enable Background");
  bgCheckBox->setChecked(autoFillBackground());
  layout->addWidget(bgCheckBox, 0, 0, Qt::AlignRight|Qt::AlignVCenter);
  QLabel *label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Color");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 1, 0, Qt::AlignRight|Qt::AlignVCenter);
  bgButton = new QPushButton(dialog);
  QPixmap pixmap = QPixmap(64,64);
  pixmap.fill(palette().button().color());
  bgButton->setIcon(pixmap);
  layout->addWidget(bgButton, 1, 1, Qt::AlignLeft|Qt::AlignVCenter);
  QPushButton *applyButton = new QPushButton(tr("Apply"));
  layout->addWidget(applyButton, 9, 1, Qt::AlignCenter|Qt::AlignVCenter);
  QPushButton *cancelButton = new QPushButton(tr("Cancel"));
  layout->addWidget(cancelButton, 9, 2, Qt::AlignCenter|Qt::AlignVCenter);
  QPushButton *acceptButton = new QPushButton(tr("Ok"));
  layout->addWidget(acceptButton, 9, 3, Qt::AlignCenter|Qt::AlignVCenter);
  connect(acceptButton, SIGNAL(released()), dialog, SLOT(accept()));
  connect(dialog, SIGNAL(accepted()), this, SLOT(applyProperties()));
  connect(applyButton, SIGNAL(released()), this, SLOT(applyProperties()));
  connect(cancelButton, SIGNAL(released()), dialog, SLOT(close()));
  connect(bgButton, SIGNAL(released()), this, SLOT(selectBgColor()));
  dialog->exec();
}

void WidgetPanel::applyProperties()
{
  setBackground(bgCheckBox->isChecked(), palette().button().color());
}

void WidgetPanel::selectBgColor()
{
  QColor color = QColorDialog::getColor(palette().button().color(), this);
  if (color.isValid()) {
    setPalette(QPalette(color));
    QPixmap pixmap(64,64);
    pixmap.fill(palette().button().color());
    bgButton->setIcon(pixmap);
  }
}
