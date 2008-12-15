/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
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

#include "framewidget.h"
#include "qutewidget.h"


FrameWidget::FrameWidget(QWidget* parent) : QFrame(parent)
{
  m_resizeBox = new QFrame(this);
  m_resizeBox->setAutoFillBackground(true);
  QPalette palette(QColor(Qt::red),QColor(Qt::red));
  palette.setColor(QPalette::WindowText, QColor(Qt::red));
  m_resizeBox->setPalette(palette);
  m_resizeBox->show();
  m_selected = false;
  m_changed = false;
}

FrameWidget::~FrameWidget()
{
}

void FrameWidget::select()
{
  m_selected = true;
  this->setLineWidth(2);
}

void FrameWidget::deselect()
{
  m_selected = false;
  this->setLineWidth(1);
}

bool FrameWidget::isSelected()
{
  return m_selected;
}

void FrameWidget::contextMenuEvent(QContextMenuEvent *event)
{
  emit(popUpMenu(event->globalPos()));
}

void FrameWidget::mousePressEvent ( QMouseEvent * event )
{
  QWidget::mousePressEvent(event);
  startx = event->x();
  starty = event->y();
  oldx = event->x();
  oldy = event->y();
  if (startx > (width()-7) and starty > (height()-7))
    m_resize = true;
  else
    m_resize = false;
  if (!(event->modifiers() & (Qt::ControlModifier | Qt::ShiftModifier)) ) {
    if (!this->isSelected())
      emit deselectAllSignal();
  }
  this->select();
}

void FrameWidget::mouseReleaseEvent ( QMouseEvent * /*event */)
{
}

void FrameWidget::mouseMoveEvent (QMouseEvent* event)
{
  if (m_resize) {
//     qDebug("FrameWidget::mouseMoveEvent %i, %i", event->x()- startx,event->y()- starty );
    QPair<int, int> pair(event->x()- oldx, event->y()- oldy);
    emit resized(pair);
  }
  else {
    QPair<int, int> pair(event->x()- startx, event->y()- starty);
    emit moved(pair);
  }
  oldx = event->x();
  oldy = event->y();
  m_widget->markChanged();
  m_changed = true;
}

void FrameWidget::resizeEvent (QResizeEvent* event)
{
  QWidget::resizeEvent(event);
  m_resizeBox->move(width()-7, height()-7);
  m_resizeBox->resize(7,7);
}
