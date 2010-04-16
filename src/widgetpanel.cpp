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

#include "qutecsound.h"

WidgetPanel::WidgetPanel(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle("Widgets");
  setMinimumSize(200, 140);
//   connect(this,SIGNAL(dockLocationChanged(Qt::DockWidgetArea)), this, SLOT(dockLocationChanged(Qt::DockWidgetArea)));
  connect(this,SIGNAL(topLevelChanged(bool)), this, SLOT(dockStateChanged(bool)));

  stack = new QStackedWidget(this);
  stack->show();
  setWidget(stack);

  m_sbActive = false;
  setWidgetScrollBarsActive(true);
  setMouseTracking(true);

//  setFocusPolicy(Qt::NoFocus);
}

WidgetPanel::~WidgetPanel()
{
}

void WidgetPanel::addWidgetLayout(WidgetLayout *w)
{
  QScrollArea *scrollArea;
  if (m_sbActive) {
    scrollArea = new QScrollArea(this);
    scrollArea->setWidget(w);
    stack->addWidget(scrollArea);
    stack->setFocusProxy(w);
    scrollArea->setFocusProxy(w);
//    QHBoxLayout *l = new QHBoxLayout(this);
//    l->addWidget(scrollArea);
//    stack->setLayout(l);
    scrollArea->show();
    w->show();
    w->setContained(true);
//    qDebug() << "WidgetPanel::addWidgetLayout  " << w << " s=" << scrollArea;
  }
//  else {
//    qDebug() << " WidgetPanel::setWidgetLayout  not sb active";
//    setWidget(w);
//    w->setContained(true);
//    this->setAutoFillBackground(w->autoFillBackground());
//    this->setBackgroundRole(QPalette::Window);
//    this->setPalette(w->palette());
//    w->setAutoFillBackground(false);
//    this->setFocusProxy(w);
//    w->show();
//  }
//  connect(w, SIGNAL(resized()), this, SLOT(widgetChanged()));
//  widgetChanged();
//  connect(layoutWidget, SIGNAL(deselectAll()), this, SLOT(deselectAll()));
}

//WidgetLayout * WidgetPanel::getWidgetLayout()
//{
//  QScrollArea *s = (QScrollArea*) stack->currentWidget();
//  if (!s) // scroll area is sometimes null during startup and shutdown
//      return 0;
//  qDebug() << "WidgetPanel::getWidgetLayout() " << s->widget();
//  return (WidgetLayout *) s->widget();
//}

WidgetLayout * WidgetPanel::takeWidgetLayout()
{
//  qDebug() << "WidgetPanel::takeWidgetLayout()";
  disconnect(this,SIGNAL(topLevelChanged(bool)));
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return 0;
  WidgetLayout * w = (WidgetLayout *) s->widget();
  if (w != 0) {
    w->setContained(false);  // Must set before removing from container to get background
    disconnect(w, SIGNAL(selection(QRect)));
  }
  w = (WidgetLayout *) s->takeWidget();
  stack->removeWidget(s);
  delete s;
//  if (m_sbActive) {
//    w = static_cast<WidgetLayout *>(scrollArea->takeWidget());
//    if (w != 0)
//      w->setParent(0);
//  }
//  else {
//    w = static_cast<WidgetLayout *>(widget());
//  }
//  disconnect(layoutWidget, SIGNAL(deselectAll()));
  return w;
}

void WidgetPanel::setCurrentLayout(WidgetLayout *layoutWidget)
{
//  QWidget *w = layoutWidget->parentWidget();
  for (int i = 0; i < stack->count(); i++) {
    QScrollArea *s = (QScrollArea*) stack->widget(i);
    qDebug() << "WidgetPanel::setCurrentLayout checking " << s;
    if (s->widget() == layoutWidget) {
      stack->setCurrentIndex(i);
      s->show();
      s->widget()->show();
      return;
    }
  }
  qDebug() << "WidgetPanel::setCurrentLayout widget not contained!! " << layoutWidget;
}

void WidgetPanel::setWidgetScrollBarsActive(bool act)
{
  act = true;
//  qDebug() << "WidgetPanel::setScrollBarsActive" << act;
//  if (act && !m_sbActive) {
//    scrollArea = new QScrollArea(this);
//    scrollArea->setWidget(widget());
//    scrollArea->setFocusPolicy(Qt::NoFocus);
//    scrollArea->setAutoFillBackground(false);
//    scrollArea->setBackgroundRole(QPalette::Window);
////    this->setAutoFillBackground(false);
//    scrollArea->show();
//    scrollArea->setMouseTracking(true);
//    connect(scrollArea->horizontalScrollBar(), SIGNAL(valueChanged(int)),
//            this, SLOT(scrollBarMoved(int)) );
//    connect(scrollArea->verticalScrollBar(), SIGNAL(valueChanged(int)),
//            this, SLOT(scrollBarMoved(int)) );
//    setWidget(scrollArea);
////    layoutWidget->setMouseTracking(false);
//  }
//  else if (!act && m_sbActive) {
//    QWidget *w = scrollArea->takeWidget();
//  stack->setPalette(QPalette());
//  stack->setAutoFillBackground(false);
//    if (w != 0) {
//      setWidget(w);
//      scrollArea->deleteLater();
//      w->setMouseTracking(true);
//      static_cast<WidgetLayout *>(w)->setMouseOffset(0,0);
//    }
//  }
  m_sbActive = act;
}

//void WidgetPanel::widgetChanged()
//{
////  QWidget *w;
////  if (m_sbActive) {
////    w = scrollArea->widget();
////  }
////  else {
////    w = widget();
////  }
////  this->setAutoFillBackground(true);
////  this->setBackgroundRole(QPalette::Window);
////  this->setPalette(w->palette());
////  w->setAutoFillBackground(false);
//}

void WidgetPanel::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

void WidgetPanel::contextMenuEvent(QContextMenuEvent *event)
{
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return;
  if (m_sbActive) {
    static_cast<WidgetLayout *>(s->widget())->createContextMenu(event);
  }
//  else {
//    static_cast<WidgetLayout *>(widget())->createContextMenu(event);
//  }
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

void WidgetPanel::mousePressEvent(QMouseEvent * event)
{
//  QMouseEvent e(QEvent::MouseButtonPress,
//                QPoint(event->x(), event->y()),
//                event->button(),
//                event->buttons(),
//                Qt::NoModifier );

  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return;
  if (m_sbActive) {
    static_cast<WidgetLayout *>(s->widget())->mousePressEventParent(event);
  }
//  else {
//    static_cast<WidgetLayout *>(widget())->mousePressEventParent(event);
//  }
}

void WidgetPanel::mouseReleaseEvent(QMouseEvent * event)
{
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return;
  if (m_sbActive) {
    static_cast<WidgetLayout *>(s->widget())->mouseReleaseEventParent(event);
  }
  else {
    static_cast<WidgetLayout *>(widget())->mouseReleaseEventParent(event);
  }
}

void WidgetPanel::mouseMoveEvent(QMouseEvent * event)
{
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return;
  if (m_sbActive) {
    WidgetLayout *w  = static_cast<WidgetLayout *>(s->widget());
    if (w != 0) {
      w->mouseMoveEventParent(event);
    }
  }
//  else {
//    WidgetLayout *w  = static_cast<WidgetLayout *>(scrollArea->widget());
//    if (w != 0) {
//      w->mouseMoveEventParent(event);
//    }
//  }
//  qApp->processEvents();
}

void WidgetPanel::dockStateChanged(bool undocked)
{
  qDebug() << "WidgetPanel::dockStateChanged" << undocked;
}

void WidgetPanel::scrollBarMoved(int /*value*/)
{
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return;
  if (m_sbActive) {
    int v = s->verticalScrollBar()->value();
    int h = s->horizontalScrollBar()->value();
    static_cast<WidgetLayout *>(s->widget())->setMouseOffset(h, v);
  }
}
