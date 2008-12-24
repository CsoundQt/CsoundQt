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
#ifndef QUTEGRAPH_H
#define QUTEGRAPH_H

#include "qutewidget.h"

class Curve;

class QuteGraph : public QuteWidget
{
  Q_OBJECT
  public:
    QuteGraph(QWidget *parent);

    ~QuteGraph();

    virtual QString getWidgetLine();
    virtual void setWidgetGeometry(int x,int y,int width,int height);
    virtual void setValue(double value);
    void setZoom(double zoom);
    void clearCurves();
    void addCurve(Curve *curve);
    int getCurveIndex(Curve * curve);
    void setCurveData(Curve * curve);
    Curve* getCurveById(uintptr_t id);

  protected:
    double m_zoom;
    QLabel * m_label;
    QComboBox *m_pageComboBox;
    QDoubleSpinBox *zoomBox;
    QVector<Curve *> curves;
    QVector<QVector <QGraphicsLineItem *> > lines;
    QVector<QGraphicsPolygonItem *> polygons;

    virtual void createPropertiesDialog();
    virtual void applyProperties();

  public slots:
    void changeCurve(int index);
};

class StackedLayoutWidget : public QStackedWidget
{
  Q_OBJECT
  public:
    StackedLayoutWidget(QWidget* parent) : QStackedWidget(parent)
    {
      setFrameShape(QFrame::StyledPanel);
    }
    ~StackedLayoutWidget() {};

    void setWidgetGeometry(int x,int y,int width,int height)
    {
      setGeometry(x,y,width, height);
      setMaximumSize(width, height);
    }

    void clearCurves()
    {
      QWidget *widget;
      widget = currentWidget();
      while (widget != 0) {
        removeWidget(widget);
        widget = currentWidget();
      }
    }
/*
  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {emit(popUpMenu(event->globalPos()));}

  signals:
    void popUpMenu(QPoint pos);*/
};

#endif
