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
#ifndef QUTEMETER_H
#define QUTEMETER_H

#include "qutewidget.h"

class QuteMeter : public QuteWidget
{
  Q_OBJECT
  public:
    QuteMeter(QWidget *parent);

    ~QuteMeter();

    virtual QString getWidgetLine();
    virtual void createPropertiesDialog();
    virtual void applyProperties();
    virtual void setWidgetGeometry(int x,int y,int width,int height);

    void popUpMenu(QPoint pos);

    virtual void setValue(double value);
    virtual double getValue();
    virtual double getValue2();
    virtual QString getChannelName();
    virtual QString getChannel2Name();

    void setChannel2Name(QString name);
    void setValue2(double value);
    void setColor(QColor color);
    void setType(QString type);
    void setPointSize(int size);
    void setFadeSpeed(int speed);
    void setBehavior(QString behavior);

  protected:
    QColor m_color;
    int m_fadeSpeed;
    QString m_behavior;

  private:
    QLineEdit* name2LineEdit;
    QPushButton*  colorButton;
    QComboBox* typeComboBox;
    QSpinBox* pointSizeSpinBox;
    QSpinBox* fadeSpeedSpinBox;
    QComboBox* behaviorComboBox;

  private slots:
    void selectTextColor();
    void setValuesFromWidget(double value1, double value2);

};

class MeterWidget : public QGraphicsView
{
  Q_OBJECT
  public:
    MeterWidget(QWidget *parent);

    ~MeterWidget();

    void setValue(double value);
    void setValue2(double value2);
    void setType(QString type);
    void setPointSize(int size);
    void setColor(QColor color);
    void setWidgetGeometry(int x,int y,int width,int height);

    QColor getColor();
    QString getType() {return m_type;};
    int getPointSize() {return m_pointSize;};
    double getValue();
    double getValue2();

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {emit(popUpMenu(event->globalPos()));}
    virtual void mouseMoveEvent(QMouseEvent* event);
    virtual void mousePressEvent(QMouseEvent* event);
    virtual void mouseReleaseEvent(QMouseEvent* event);

  private:
    double m_value, m_value2;
    QString m_type;
    int m_pointSize;
    bool m_mouseDown;

    QGraphicsScene* m_scene;

//     QGraphicsRectItem* m_background;
    QGraphicsRectItem* m_block;
    QGraphicsEllipseItem* m_point;
    QGraphicsLineItem* m_vline;
    QGraphicsLineItem* m_hline;

  signals:
    void popUpMenu(QPoint pos);
    void newValues(double value1, double value2);
};

#endif
