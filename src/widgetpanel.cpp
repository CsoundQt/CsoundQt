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
//  setWidgetScrollBarsActive(false);
  setMouseTracking(true);

//  setFocusPolicy(Qt::NoFocus);
//  l = new QStackedLayout(this);
//  setLayout(l);
}

WidgetPanel::~WidgetPanel()
{
}

//unsigned int WidgetPanel::widgetCount()
//{
//  return layoutWidget->widgetCount();
//}

void WidgetPanel::setWidgetLayout(WidgetLayout *w)
{
  // When this function is called, there must be no widget layout set, as this
  // function will delete the set widget.
  if (m_sbActive) {
    scrollArea->setWidget(w);
    this->setAutoFillBackground(true);
    this->setPalette(w->palette());
    w->setAutoFillBackground(false);
    scrollArea->show();
  }
  else {
    setWidget(w);
  }
  connect(w, SIGNAL(resized()), this, SLOT(widgetChanged()));
  widgetChanged();
//  connect(layoutWidget, SIGNAL(deselectAll()), this, SLOT(deselectAll()));
}

WidgetLayout * WidgetPanel::takeWidgetLayout()
{
  disconnect(this,SIGNAL(topLevelChanged(bool)));
  WidgetLayout * w;
//  l->removeWidget(widget());
  if (m_sbActive) {
    w = static_cast<WidgetLayout *>(scrollArea->takeWidget());
    w->setParent(0);
  }
  else {
    w = static_cast<WidgetLayout *>(widget());
  }
//  disconnect(layoutWidget, SIGNAL(deselectAll()));
  disconnect(w, SIGNAL(selection(QRect)));
  disconnect(w, SIGNAL(resized(QRect)));
  return w;
}


void WidgetPanel::setWidgetScrollBarsActive(bool act)
{
//   qDebug() << "WidgetPanel::setScrollBarsActive" << active;
  if (act && !m_sbActive) {
    scrollArea = new QScrollArea(this);
    scrollArea->setWidget(widget());
    scrollArea->setFocusPolicy(Qt::NoFocus);
    setWidget(scrollArea);
    scrollArea->setAutoFillBackground(false);
    scrollArea->show();
    scrollArea->setMouseTracking(true);
//    layoutWidget->setMouseTracking(false);
  }
  else if (!act && m_sbActive) {
    setWidget(scrollArea->takeWidget());
    delete scrollArea;
    widget()->setMouseTracking(true);
  }
  m_sbActive = act;
}

void WidgetPanel::widgetChanged()
{
  QWidget *w;
  if (m_sbActive) {
    w = scrollArea->widget();
  }
  else {
    w = widget();
  }
  this->setAutoFillBackground(true);
  this->setPalette(w->palette());
  w->setAutoFillBackground(false);
}


//void WidgetPanel::setKeyRepeatMode(bool repeat)
//{
//  layoutWidget->setKeyRepeatMode(repeat);
//}

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

void WidgetPanel::contextMenuEvent(QContextMenuEvent *event)
{
  if (m_sbActive) {
    static_cast<WidgetLayout *>(scrollArea->widget())->createContextMenu(event);
  }
  else {
    static_cast<WidgetLayout *>(widget())->createContextMenu(event);
  }
}

//void WidgetPanel::resizeEvent(QResizeEvent * event)
//{
////   qDebug("WidgetPanel::resizeEvent()");
//  QDockWidget::resizeEvent(event);
//  oldSize = event->oldSize();
//  emit resized(event->size());
////  adjustLayoutSize();
//}

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
//void WidgetPanel::adjustLayoutSize()
//{
//  if (m_sbActive) {
//    if (scrollArea->widget() != 0)
//      static_cast<WidgetLayout *>(scrollArea->widget())->adjustLayoutSize();
//  }
//  else  {
//    if (widget() != 0)
//      static_cast<WidgetLayout *>(widget())->adjustLayoutSize();
//  }
//}

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
