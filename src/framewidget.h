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

#ifndef FRAMEWIDGET_H
#define FRAMEWIDGET_H

#include <QFrame>
#include <QWidget>

class QuteWidget;

class FrameWidget : public QFrame
{
  Q_OBJECT
  public:
    FrameWidget(QWidget* parent);
    ~FrameWidget();

    void select();
    void deselect();
    bool isSelected();

    void setWidget(QuteWidget* widget) {m_widget = widget;}
    QuteWidget* getWidget() {return m_widget;}

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);
    virtual void mousePressEvent ( QMouseEvent * event );
    virtual void mouseReleaseEvent ( QMouseEvent * event );
    virtual void mouseMoveEvent (QMouseEvent* event);
    virtual void mouseDoubleClickEvent (QMouseEvent * event);
    virtual void resizeEvent (QResizeEvent* event);

  private:
    int startx, starty, oldx, oldy;
    QFrame *m_resizeBox;
    QuteWidget *m_widget;
    bool m_resize;
    bool m_selected;
    bool m_changed;

  signals:
    void popUpMenu(QPoint pos);
    void deselectAllSignal();
    void moved(QPair<int, int>);
    void resized(QPair<int, int>);
    void editWidget();
    void mouseReleased();  // When mouse released, send to set undo history
 };

#endif
