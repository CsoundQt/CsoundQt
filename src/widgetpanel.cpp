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

  setMouseTracking(true);

//  setFocusPolicy(Qt::NoFocus);
}

WidgetPanel::~WidgetPanel()
{
}

void WidgetPanel::addWidgetLayout(WidgetLayout *w)
{
  QScrollArea *scrollArea;
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
}

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
  w = (WidgetLayout *) s->takeWidget();  //This transfers ownership of the widget to the caller
  if (w) {
    w->setParent(0);
  }
  stack->removeWidget(s);
  delete s;
  return w;
}

//void WidgetPanel::setCurrentLayout(WidgetLayout *layoutWidget)
//{
////  QWidget *w = layoutWidget->parentWidget();
//  for (int i = 0; i < stack->count(); i++) {
//    QScrollArea *s = (QScrollArea*) stack->widget(i);
//    qDebug() << "WidgetPanel::setCurrentLayout checking " << s;
//    if (s->widget() == layoutWidget) {
//      stack->setCurrentIndex(i);
//      s->show();
//      s->widget()->show();
//      return;
//    }
//  }
//  qDebug() << "WidgetPanel::setCurrentLayout widget not contained!! " << layoutWidget;
//}

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
  Q_ASSERT(s != 0);
  static_cast<WidgetLayout *>(s->widget())->createContextMenu(event);
}

void WidgetPanel::resizeEvent(QResizeEvent * event)
{
//   qDebug( ) << "WidgetPanel::resizeEvent() " << event->oldSize() << event->size() ;
  QDockWidget::resizeEvent(event);
  oldSize = event->oldSize();
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (s != 0) {
    emit resized(s->maximumViewportSize());
  }
}

void WidgetPanel::moveEvent(QMoveEvent * event)
{
  QDockWidget::moveEvent(event);
  emit moved(event->pos());
}

void WidgetPanel::mousePressEvent(QMouseEvent * event)
{
  qDebug() << "WidgetPanel::mousePressEvent";
//  QMouseEvent e(QEvent::MouseButtonPress,
//                QPoint(event->x(), event->y()),
//                event->button(),
//                event->buttons(),
//                Qt::NoModifier );

  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return;
  static_cast<WidgetLayout *>(s->widget())->mousePressEventParent(event);
}

void WidgetPanel::mouseReleaseEvent(QMouseEvent * event)
{
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
      return;
  static_cast<WidgetLayout *>(s->widget())->mouseReleaseEventParent(event);
}

void WidgetPanel::mouseMoveEvent(QMouseEvent * event)
{
  QScrollArea *s = (QScrollArea*) stack->currentWidget();
  if (!s) // scroll area is sometimes null during startup and shutdown
    return;
  WidgetLayout *w  = static_cast<WidgetLayout *>(s->widget());
  if (w != 0) {
    w->mouseMoveEventParent(event);
  }
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
  int v = s->verticalScrollBar()->value();
  int h = s->horizontalScrollBar()->value();
  static_cast<WidgetLayout *>(s->widget())->setMouseOffset(h, v);
}
