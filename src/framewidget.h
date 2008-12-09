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
};

#endif
