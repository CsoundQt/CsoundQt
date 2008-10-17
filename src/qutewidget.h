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
#ifndef QUTEWIDGET_H
#define QUTEWIDGET_H

#include <QString>
// #include <QWidget>

#include <QtGui>

enum widgetType {
  QUTE_SLIDER,
  QUTE_KNOB,
  QUTE_CHECKBOX,
  QUTE_BUTTON,
  QUTE_LABEL,
  QUTE_LINEEDIT,
  QUTE_DISPLAY,
  QUTE_SCROLLNUMBER,
  QUTE_COMBOBOX,
  NONE
};

class QuteWidget : public QWidget
{
  Q_OBJECT
  public:
    QuteWidget(QWidget* parent, widgetType type = QUTE_SLIDER);

    ~QuteWidget();

    widgetType type() {return m_type;}
    const QString name() {return m_name;}
//     const int x() {return widget->x();};
//     const int y() {return widget->y();};
//     const int width() {return widget->width();};
//     const int height() {return widget->height();};

//     double value() {return m_value;}
//     double value2() {return m_value2;}

    void setWidgetLine(QString line);
    void setChannelName(QString name);
    void setWidgetGeometry(int x, int y, int w, int h);
    void setWidgetGeometry(QRect rect);
    virtual void setRange(int min, int max);
    virtual void setValue(double value);
    void setResolution(double resolution);
    virtual void setChecked(bool checked);
    void setText(QString text);

    QString getChannelName();
    QString getWidgetLine();
    virtual double getValue();

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);

    widgetType m_type;
    QWidget *m_layoutWidget;
    QWidget *m_widget;

    QString m_name;
    double m_min, m_max;
    double m_value, m_value2;

  private:
    QAction *propertiesAct;
    QString m_line;

  private slots:
    void openProperties();
    void applyProperties();

//     double m_min,m_max;
//     double m_min2,m_max2;

};

#endif
