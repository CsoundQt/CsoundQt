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
  setWidgetScrollBarsActive(true);
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
  // function will delete the set widget in scrollarea->setWidget().
//  qDebug() << "WidgetPanel::setWidgetLayout";
  if (m_sbActive) {
    scrollArea->setWidget(w);
    w->setContained(true);
    this->setPalette(QPalette());
    this->setAutoFillBackground(false);
    this->setFocusProxy(w);
    scrollArea->setFocusProxy(w);
    w->show();
    scrollArea->show();
  }
  else {
    qDebug() << " WidgetPanel::setWidgetLayout  not sb active";
    setWidget(w);
    w->setContained(true);
    this->setAutoFillBackground(w->autoFillBackground());
    this->setBackgroundRole(QPalette::Window);
    this->setPalette(w->palette());
    w->setAutoFillBackground(false);
    this->setFocusProxy(w);
    w->show();
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
    if (w != 0)
      w->setParent(0);
  }
  else {
    w = static_cast<WidgetLayout *>(widget());
  }
//  disconnect(layoutWidget, SIGNAL(deselectAll()));
  if (w != 0)
    disconnect(w, SIGNAL(selection(QRect)));
  return w;
}


void WidgetPanel::setWidgetScrollBarsActive(bool act)
{
  qDebug() << "WidgetPanel::setScrollBarsActive" << act;
  if (act && !m_sbActive) {
    scrollArea = new QScrollArea(this);
    scrollArea->setWidget(widget());
    scrollArea->setFocusPolicy(Qt::NoFocus);
    scrollArea->setAutoFillBackground(false);
    scrollArea->setBackgroundRole(QPalette::Window);
//    this->setAutoFillBackground(false);
    scrollArea->show();
    scrollArea->setMouseTracking(true);
    connect(scrollArea->horizontalScrollBar(), SIGNAL(valueChanged(int)),
            this, SLOT(scrollBarMoved(int)) );
    connect(scrollArea->verticalScrollBar(), SIGNAL(valueChanged(int)),
            this, SLOT(scrollBarMoved(int)) );
    setWidget(scrollArea);
//    layoutWidget->setMouseTracking(false);
  }
  else if (!act && m_sbActive) {
    setWidget(scrollArea->takeWidget());
    scrollArea->deleteLater();
    widget()->setMouseTracking(true);
    static_cast<WidgetLayout *>(widget())->setMouseOffset(0,0);
  }
  m_sbActive = act;
}

//void WidgetPanel::duplicate()
//{
//  qDebug() << "WidgetPanel::duplicate()";
//  QWidget *w;
//  if (m_sbActive) {
//    w = scrollArea->widget();
//  }
//  else {
//    w = widget();
//  }
//  static_cast<WidgetLayout *>(w)->duplicate();
//}

void WidgetPanel::widgetChanged()
{
  QWidget *w;
  if (m_sbActive) {
    w = scrollArea->widget();
  }
  else {
    w = widget();
  }
//  this->setAutoFillBackground(true);
//  this->setBackgroundRole(QPalette::Window);
//  this->setPalette(w->palette());
//  w->setAutoFillBackground(false);
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

void WidgetPanel::resizeEvent(QResizeEvent * event)
{
//   qDebug( ) << "WidgetPanel::resizeEvent() " << event->oldSize() << event->size() ;
  QDockWidget::resizeEvent(event);
  oldSize = event->oldSize();
  emit resized(event->size());
//  adjustLayoutSize();
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
void WidgetPanel::mousePressEvent(QMouseEvent * event)
{
//  QMouseEvent e(QEvent::MouseButtonPress,
//                QPoint(event->x(), event->y()),
//                event->button(),
//                event->buttons(),
//                Qt::NoModifier );
  if (m_sbActive) {
    static_cast<WidgetLayout *>(scrollArea->widget())->mousePressEventParent(event);
  }
  else {
    static_cast<WidgetLayout *>(widget())->mousePressEventParent(event);
  }
}

void WidgetPanel::mouseReleaseEvent(QMouseEvent * event)
{
  if (m_sbActive) {
    static_cast<WidgetLayout *>(scrollArea->widget())->mouseReleaseEventParent(event);
  }
  else {
    static_cast<WidgetLayout *>(widget())->mouseReleaseEventParent(event);
  }
}

void WidgetPanel::mouseMoveEvent(QMouseEvent * event)
{
  if (m_sbActive) {
    WidgetLayout *w  = static_cast<WidgetLayout *>(scrollArea->widget());
    if (w != 0) {
      w->mouseMoveEventParent(event);
    }
  }
  else {
    WidgetLayout *w  = static_cast<WidgetLayout *>(scrollArea->widget());
    if (w != 0) {
      w->mouseMoveEventParent(event);
    }
  }
//  qApp->processEvents();
}

void WidgetPanel::dockStateChanged(bool undocked)
{
  qDebug() << "WidgetPanel::dockStateChanged" << undocked;
}

void WidgetPanel::scrollBarMoved(int value)
{
  if (m_sbActive) {
    int v = scrollArea->verticalScrollBar()->value();
    int h = scrollArea->horizontalScrollBar()->value();
    static_cast<WidgetLayout *>(scrollArea->widget())->setMouseOffset(h, v);
  }
}
