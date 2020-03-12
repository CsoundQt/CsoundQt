/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "framewidget.h"
#include "qutewidget.h"

#include <QColor>

FrameWidget::FrameWidget(QWidget* parent) : QFrame(parent)
{
	this->setMinimumSize(2,2);
	m_resizeBox = new QFrame(this);
	m_resizeBox->setAutoFillBackground(true);
    QPalette palette = QPalette((QColor(Qt::red)),(QColor(Qt::red)));
	palette.setColor(QPalette::WindowText, QColor(Qt::red));
    m_resizeBox->setPalette(palette);
	m_resizeBox->show();
	m_resizeBox->setMinimumSize(2,2);
	m_selected = false;
	m_changed = false;
    this->setStyleSheet("QFrame, QLabel, QToolTip{color:black; border:2px solid green;}");
}

FrameWidget::~FrameWidget()
{
}

void FrameWidget::select()
{
	m_selected = true;
    this->setStyleSheet("QFrame, QLabel, QToolTip {color:black; border:3px solid rgb(30, 150, 240);}");

	emit widgetSelected(m_widget);
}

void FrameWidget::deselect()
{
	m_selected = false;
    this->setStyleSheet("QFrame, QLabel, QToolTip {color:black; border:2px solid green;}");
	emit widgetUnselected(m_widget);
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
	QFrame::mousePressEvent(event);
	this->setFocus(Qt::MouseFocusReason);
	if (event->button() & Qt::LeftButton) {
		startx = event->x();
		starty = event->y();
		oldx = event->x();
		oldy = event->y();
        if (startx > (width()-7) && starty > (height()-7))
			m_resize = true;
		else
			m_resize = false;
        if (event->modifiers() & Qt::ShiftModifier) {
            this->select();
        } else if (event->modifiers() & Qt::ControlModifier) {
            if(this->isSelected())
                this->deselect();
            else
                this->select();
        } else {
            emit deselectAllSignal();
            this->select();
		}
    }
	event->accept(); //to avoid propagation of the event to parent widgets
}

void FrameWidget::mouseReleaseEvent ( QMouseEvent * event )
{
	QFrame::mouseReleaseEvent(event);
	emit mouseReleased();
	event->accept(); //to avoid propagation of the event to parent widgets
}

void FrameWidget::mouseMoveEvent (QMouseEvent* event)
{
	if (m_resize) {
        if(event->modifiers() & Qt::ShiftModifier) {
            auto dx = event->x() - oldx;
            auto dy = event->y() - oldy;
            if(qAbs(dx) > qAbs(dy)) {
                QPair<int,int> pair(dx, 0);
                emit resized(pair);
            } else {
                QPair<int, int> pair(0, dy);
                emit resized(pair);
            }
        } else {
            QPair<int, int> pair(event->x()- oldx, event->y()- oldy);
            emit resized(pair);
        }
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

void FrameWidget::mouseDoubleClickEvent (QMouseEvent * event)
{
	event->accept();
	emit editWidget();
}

void FrameWidget::resizeEvent (QResizeEvent* event)
{
	QWidget::resizeEvent(event);
	m_resizeBox->move(width()-7, height()-7);
	m_resizeBox->resize(7,7);
}
