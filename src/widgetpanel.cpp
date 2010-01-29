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

#include "widgetpanel.h"
#include "widgetlayout.h"
// #include "curve.h"

#include "qutecsound.h"

WidgetPanel::WidgetPanel(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Widgets");
  setMinimumSize(200, 140);
//   connect(this,SIGNAL(dockLocationChanged(Qt::DockWidgetArea)), this, SLOT(dockLocationChanged(Qt::DockWidgetArea)));
  connect(this,SIGNAL(topLevelChanged(bool)), this, SLOT(dockStateChanged(bool)));

  m_sbActive = false;
  QTimer::singleShot(30, this, SLOT(updateData()));
  this->setMouseTracking(true);
//  mouseBut1 = 0;
//  mouseBut2 = 0;

//  clearHistory();
}

WidgetPanel::~WidgetPanel()
{
}

//unsigned int WidgetPanel::widgetCount()
//{//FIXME get rid of ths function (as intermediary)
//  return layoutWidget->widgetCount();
//}

void WidgetPanel::setWidgetLayout(WidgetLayout *w)
{
//  layoutWidget = w;
  setWidgetScrollBarsActive(true);
  if (m_sbActive) {
    scrollArea->setWidget(w);
  }
  else {
    setWidget(w);
  }
//  connect(layoutWidget, SIGNAL(deselectAll()), this, SLOT(deselectAll()));
  connect(w, SIGNAL(selection(QRect)), this, SLOT(selectionChanged(QRect)));
}

WidgetLayout * WidgetPanel::popWidgetLayout()
{
  disconnect(this,SIGNAL(topLevelChanged(bool)));
  WidgetLayout * w;
  if (m_sbActive) {
    w = static_cast<WidgetLayout *>(scrollArea->takeWidget());
  }
  else {
    w = static_cast<WidgetLayout *>(widget());
  }
//  disconnect(layoutWidget, SIGNAL(deselectAll()));
  disconnect(w, SIGNAL(selection(QRect)));
  return w;
}

//void WidgetPanel::getValues(QVector<QString> *channelNames,
//                            QVector<double> *values,
//                            QVector<QString> *stringValues)
//{
//  layoutWidget->getValues(channelNames, values, stringValues);
//}

//void WidgetPanel::getMouseValues(QVector<double> *values)
//{
//  layoutWidget->getMouseValues(values);
//}
//
//int WidgetPanel::getMouseX()
//{
//  return layoutWidget->getMouseX();
//}
//
//int WidgetPanel::getMouseY()
//{
//  return layoutWidget->getMouseY();
//}
//
//int WidgetPanel::getMouseRelX()
//{
//  return layoutWidget->getMouseRelX();
//}
//
//int WidgetPanel::getMouseRelY()
//{
//  return layoutWidget->getMouseRelY();
//}
//
//int WidgetPanel::getMouseBut1()
//{
//  return layoutWidget->getMouseBut1();
//}
//
//int WidgetPanel::getMouseBut2()
//{
//  return layoutWidget->getMouseBut2();
//}


//void WidgetPanel::setValue(QString channelName, double value)
//{
//  layoutWidget->setValue(channelName, value);
//}
//
//void WidgetPanel::setValue(QString channelName, QString value)
//{
//  layoutWidget->setValue(channelName, value);
//}
//
//void WidgetPanel::setValue(int index, double value)
//{
//  layoutWidget->setValue(index, value);
//}
//
//void WidgetPanel::setValue(int index, QString value)
//{
//  layoutWidget->setValue(index, value);
//}

void WidgetPanel::setWidgetScrollBarsActive(bool active)
{
//   qDebug() << "WidgetPanel::setScrollBarsActive" << active;
  if (active && !m_sbActive) {
    scrollArea = new QScrollArea(this);
    scrollArea->setWidget(widget());
    scrollArea->setFocusPolicy(Qt::NoFocus);
    setWidget(scrollArea);
    scrollArea->setAutoFillBackground(false);
    scrollArea->show();
    scrollArea->setMouseTracking(true);
//    layoutWidget->setMouseTracking(false);
  }
  else if (!active && m_sbActive) {
    setWidget(scrollArea->takeWidget());
    delete scrollArea;
    widget()->setMouseTracking(true);
  }
  m_sbActive = active;
}

//void WidgetPanel::setKeyRepeatMode(bool repeat)
//{
//  layoutWidget->setKeyRepeatMode(repeat);
//}

void WidgetPanel::focusWidgets()
{
  if (m_sbActive) {
    scrollArea->widget()->setFocus();
  }
  else  {
    widget()->setFocus();
  }
}

//int WidgetPanel::newWidget(QString widgetLine, bool offset)
//{
//  return layoutWidget->newWidget(widgetLine, offset);
//}

void WidgetPanel::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

//QString WidgetPanel::widgetsText(bool tags)
//{
//  return layoutWidget->widgetsText(tags);
//}

//void WidgetPanel::appendMessage(QString message)
//{
//  layoutWidget->appendMessage(message);
//}

//void WidgetPanel::setWidgetToolTip(QuteWidget *widget, bool show)
//{
//  layoutWidget->setWidgetToolTip(widget, show);
//}

//void WidgetPanel::newCurve(Curve* curve)
//{
//  layoutWidget->newCurve(curve);
//}

//void WidgetPanel::setCurveData(Curve *curve)
//{
//  layoutWidget->setCurveData(curve);
//}

//void WidgetPanel::clearGraphs()
//{
//  layoutWidget->clearGraphs();
//}

//Curve * WidgetPanel::getCurveById(uintptr_t id)
//{
//  return layoutWidget->getCurveById(id);
//}

//void WidgetPanel::flush()
//{
//  return layoutWidget->flush();
//}

//void WidgetPanel::refreshConsoles()
//{
//  layoutWidget->refreshConsoles();
//}

//void WidgetPanel::newValue(QPair<QString, double> channelValue)
//{
//  layoutWidget->newValue(channelValue);
//}
//
//void WidgetPanel::newValue(QPair<QString, QString> channelValue)
//{
//  layoutWidget->newValue(channelValue);
//}


//QString WidgetPanel::getCabbageLines()
//{
//  QString text = "";
//  int unsupported = 0;
//  foreach(QuteWidget *widget, widgets) {
//    QString line = widget->getCabbageLine();
//    if (line != "") {
//      text += line;
//    }
//    else {
//      unsupported++;
//    }
//  }
//  qDebug() << "WidgetPanel:getCabbageLines() " << unsupported << " Unsupported widgets";
//  return text;
//}


//void WidgetPanel::deleteWidget(QuteWidget *widget)
//{
//  int index = widgets.indexOf(widget);
////   qDebug("WidgetPanel::deleteWidget %i", number);
//  widget->close();
//  widgets.remove(index);
//  if (!editWidgets.isEmpty()) {
//    delete(editWidgets[index]);
//    editWidgets.remove(index);
//  }
//  index = consoleWidgets.indexOf(dynamic_cast<QuteConsole *>(widget));
//  if (index >= 0) {
//    consoleWidgets.remove(index);
//  }
//  index = graphWidgets.indexOf(dynamic_cast<QuteGraph *>(widget));
//  if (index >= 0)
//    graphWidgets.remove(index);
//  index = scopeWidgets.indexOf(dynamic_cast<QuteScope *>(widget));
//  if (index >= 0)
//    scopeWidgets.remove(index);
//  widgetChanged(widget);
//}
//
//void WidgetPanel::queueEvent(QString eventLine)
//{
////   qDebug("WidgetPanel::queueEvent %s", eventLine.toStdString().c_str());
//  if (eventQueueSize < QUTECSOUND_MAX_EVENTS) {
////     eventMutex.lock();
//    eventQueue[eventQueueSize] = eventLine;
//    eventQueueSize++;
////     eventMutex.unlock();
//  }
//  else
//    qDebug("Warning: event queue full, event not processed");
//}

//void WidgetPanel::contextMenuEvent(QContextMenuEvent *event)
//{
//  QMenu menu;
//  menu.addAction(createSliderAct);
//  menu.addAction(createLabelAct);
//  menu.addAction(createDisplayAct);
//  menu.addAction(createScrollNumberAct);
//  menu.addAction(createLineEditAct);
//  menu.addAction(createSpinBoxAct);
//  menu.addAction(createButtonAct);
//  menu.addAction(createKnobAct);
//  menu.addAction(createCheckBoxAct);
//  menu.addAction(createMenuAct);
//  menu.addAction(createMeterAct);
//  menu.addAction(createConsoleAct);
//  menu.addAction(createGraphAct);
//  menu.addAction(createScopeAct);
//  menu.addSeparator();
//  menu.addAction(editAct);
//  menu.addSeparator();
//  menu.addAction(copyAct);
//  menu.addAction(pasteAct);
//  menu.addAction(selectAllAct);
//  menu.addAction(duplicateAct);
//  menu.addAction(cutAct);
//  menu.addAction(deleteAct);
//  menu.addAction(clearAct);
//  menu.addSeparator();
//  menu.addAction(propertiesAct);
//  currentPosition = event->pos();
//  if (m_sbActive) {
//    currentPosition.setX(currentPosition.x() + scrollArea->horizontalScrollBar()->value());
//    currentPosition.setY(currentPosition.y() + scrollArea->verticalScrollBar()->value() - 20);
//  }
//  menu.exec(event->globalPos());
//}

void WidgetPanel::resizeEvent(QResizeEvent * event)
{
//   qDebug("WidgetPanel::resizeEvent()");
  QDockWidget::resizeEvent(event);
  oldSize = event->oldSize();
  emit resized(event->size());
  adjustLayoutSize();
}

void WidgetPanel::moveEvent(QMoveEvent * event)
{
  QDockWidget::moveEvent(event);
  emit moved(event->pos());
}

//void WidgetPanel::mouseMoveEvent(QMouseEvent * event)
//{
//  QWidget::mouseMoveEvent(event);
//}
//
//void WidgetPanel::mousePressEvent(QMouseEvent * event)
//{
//  QWidget::mousePressEvent(event);
//}
//
//void WidgetPanel::mouseReleaseEvent(QMouseEvent * event)
//{
//  QWidget::mousePressEvent(event);
//}
//
//void WidgetPanel::keyPressEvent(QKeyEvent *event)
//{
//  QDockWidget::keyPressEvent(event); // Propagate event if not used
//}
//
//void WidgetPanel::keyReleaseEvent(QKeyEvent *event)
//{
//  QDockWidget::keyReleaseEvent(event); // Propagate event if not used
//}

//void WidgetPanel::widgetChanged(QuteWidget* widget)
//{
//  if (widget != 0) {
//    int index = widgets.indexOf(widget);
//    if (index >= 0 and editWidgets.size() > index) {
//      int newx = widget->x();
//      int newy = widget->y();
//      int neww = widget->width();
//      int newh = widget->height();
//      editWidgets[index]->move(newx, newy);
//      editWidgets[index]->resize(neww, newh);
//    }
//    setWidgetToolTip(widget, m_tooltips);
//  }
//  adjustLayoutSize();
//}

// void WidgetPanel::updateWidgetText()
// {
//   emit widgetsChanged(widgetsText());
// }


//void WidgetPanel::widgetMoved(QPair<int, int> delta)
//{
//  layoutWidget->widgetMoved(delta);
//}
//
//void WidgetPanel::widgetResized(QPair<int, int> delta)
//{
//  layoutWidget->widgetResized(delta);
//}
//
void WidgetPanel::adjustLayoutSize()
{
  if (m_sbActive) {
    static_cast<WidgetLayout *>(scrollArea->widget())->adjustLayoutSize();
  }
  else  {
    static_cast<WidgetLayout *>(widget())->adjustLayoutSize();
  }
}

//void WidgetPanel::copy()
//{
//  clipboard.clear();
//  // FIXME fix undo!
//  QStringList l = layoutWidget->getSelectedWidgetsText();
//  for (int i = 0; i < l.size(); i++) {
//    clipboard.append(l[i]);
////       qDebug("WidgetPanel::copy() %s", clipboard.last().toStdString().c_str());
//  }
//}
//
//void WidgetPanel::cut()
//{
//  WidgetPanel::copy();
//  // FIXME fix undo!
////  for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
////    if (editWidgets[i]->isSelected()) {
////      deleteWidget(widgets[i]);
////    }
////  }
////  markHistory();
//}
//
//void WidgetPanel::paste()
//{
//  if (editAct->isChecked()) {
//    layoutWidget->deselectAll();
//    foreach (QString line, clipboard) {
//      layoutWidget->newWidget(line);
//    }
//  }
//  //FIXME check if undo is working properly here
////  markHistory();
//}

void WidgetPanel::dockStateChanged(bool undocked)
{
  qDebug() << "WidgetPanel::dockStateChanged" << undocked;
}
