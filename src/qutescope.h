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
#ifndef QUTESCOPE_H
#define QUTESCOPE_H

#include "qutewidget.h"
#include "types.h"  //necessary for the CsoundUserData struct

class QuteScope : public QuteWidget
{
  Q_OBJECT
  public:
    QuteScope(QWidget *parent);

    ~QuteScope();

    virtual QString getWidgetLine();
    virtual void setWidgetGeometry(int x,int y,int width,int height);
    virtual void createPropertiesDialog();
    void setType(QString type);
    void setValue(double value); //Value for this widget indicates zoom level
    void setChannel(int channel);
    void setUd(CsoundUserData *ud);
    void updateLabel();

  protected:
    QLabel * m_label;
//     QString m_type;
    CsoundUserData *m_ud;
    int m_channel;
    int m_zoom;
    QComboBox *typeComboBox;
    QComboBox *channelBox;
    QSpinBox *decimationBox;
    QPolygonF curveData;
    QGraphicsPolygonItem *curve;

    virtual void resizeEvent(QResizeEvent * event);
    virtual void applyProperties();

  public slots:
    void updateData();
};

class ScopeWidget : public QGraphicsView
{
  Q_OBJECT
  public:
    ScopeWidget(QWidget* parent) : QGraphicsView(parent)
    {
      setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
      setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
      freeze = false;
    }
    ~ScopeWidget() {}

    bool freeze;

  protected:
//     virtual void contextMenuEvent(QContextMenuEvent *event)
//     {emit(popUpMenu(event->globalPos()));}
    virtual void mousePressEvent(QMouseEvent *event)
    {
      if (event->button() & Qt::LeftButton)
        freeze = true;
    }
    virtual void mouseReleaseEvent(QMouseEvent *event)
    {
      freeze = false;
    }

//   signals:
//     void popUpMenu(QPoint pos);
};

#endif
