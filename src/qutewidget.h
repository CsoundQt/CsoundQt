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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#ifndef QUTEWIDGET_H
#define QUTEWIDGET_H

#include <QString>
// #include <QWidget>

#include <QtGui>

enum widgetType {
  QUTE_SLIDER,
  QUTE_BUTTON,
  QUTE_LABEL,
  QUTE_COMBOBOX,
  QUTE_TEXTEDIT,
  NONE
};

class QuteWidget : public QWidget
{
  Q_OBJECT
  public:
    QuteWidget(QWidget* parent, widgetType type);

    ~QuteWidget();

    widgetType type() {return m_type;}
    const QString name() {return m_name;}
//     const int x() {return widget->x();};
//     const int y() {return widget->y();};
//     const int width() {return widget->width();};
//     const int height() {return widget->height();};

    double value() {return m_value;}
    double value2() {return m_value2;}

    void setChannelName(QString name);
    void setWidgetGeometry(QRect rect);
    void setRange(int min, int max);

    QString getChannelName();
    double getValue();

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);

  private:
    widgetType m_type;
    QWidget *m_layoutWidget;
    QWidget *m_widget;

    QString m_name;
    double m_value;
    double m_value2;

    QAction *propertiesAct;

  private slots:
    void openProperties();
    void applyProperties();

//     double m_min,m_max;
//     double m_min2,m_max2;

};

#endif
