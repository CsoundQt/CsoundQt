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

#ifndef WIDGETPANEL_H
#define WIDGETPANEL_H

#include <QtGui>

#include "qutewidget.h"//FIXME this shoudl be removed from here
//#include "widgetpreset.h"

class WidgetLayout;

class WidgetPanel : public QDockWidget
{
  Q_OBJECT

  // FIXME are these friendings still needed???
  friend class qutecsound;  // To allow edit actions- TODO- can this be done all here?
  friend class QuteWidget;  // To allow edit actions
  public:
    WidgetPanel(QWidget *parent);
    ~WidgetPanel();

    unsigned int widgetCount();
    void setWidgetLayout(WidgetLayout *layoutWidget);
    WidgetLayout * popWidgetLayout();
//    void getValues(QVector<QString> *channelNames, QVector<double> *values, QVector<QString> *stringValues);
//    void getMouseValues(QVector<double> *values);
//    int getMouseX();
//    int getMouseY();
//    int getMouseRelX();
//    int getMouseRelY();
//    int getMouseBut1();
//    int getMouseBut2();
//    unsigned long getKsmpsCount();

    void setValue(QString channelName, double value);
    void setValue(QString channelName, QString value);
    void setValue(int index, double value);
    void setValue(int index, QString value);

    void setScrollBarsActive(bool active);
    void setKeyRepeatMode(bool repeat);
    void focusWidgets();
//    void loadWidgets(QString macWidgets);
    int newWidget(QString widgetLine, bool offset = false);
//    QString widgetsText(bool tags = true);
//    void appendMessage(QString message);
    void showTooltips(bool show);
    void setWidgetToolTip(QuteWidget *widget, bool show);
//    void newCurve(Curve* curve);
//     int getCurveIndex(Curve *curve);
//    void setCurveData(Curve *curve);
//    void clearGraphs();
//    Curve * getCurveById(uintptr_t id);
    void flush();
    void refreshConsoles();
//    QString getCabbageLines();
    void newValue(QPair<QString, double> channelValue);
    void newValue(QPair<QString, QString> channelValue);

  protected:
//    virtual void contextMenuEvent(QContextMenuEvent *event);
    virtual void resizeEvent(QResizeEvent * event);
    virtual void moveEvent(QMoveEvent * event);
    virtual void mouseMoveEvent (QMouseEvent * event);
    virtual void mousePressEvent(QMouseEvent * event);
    virtual void mouseReleaseEvent(QMouseEvent * event);
    virtual void keyPressEvent(QKeyEvent *event);
    virtual void keyReleaseEvent(QKeyEvent *event);
    virtual void closeEvent(QCloseEvent * event);

  private:

    QAction *editAct;
    WidgetLayout *layoutWidget;   // Always owned by documentpage,, is this needed here?
    QScrollArea *scrollArea;

    QStringList clipboard;
    QSize oldSize;
//    bool m_tooltips;
    int m_width;
    int m_height;
    bool m_sbActive; // Scroll bars active

  public slots:
//    void newValue(QPair<QString, double> channelValue);
//    void newValue(QPair<QString, QString> channelValue);
//    void processNewValues();
//    void widgetChanged(QuteWidget* widget = 0);
//     void updateWidgetText();
//    void deleteWidget(QuteWidget *widget);
//    void queueEvent(QString eventLine);

//    void selectionChanged(QRect selection);
    void widgetMoved(QPair<int, int>);
    void widgetResized(QPair<int, int>);
    void adjustLayoutSize();

  private slots:
    void copy();
    void cut();
    void paste();
//    void paste(QPoint pos);
    void dockStateChanged(bool);

  signals:
    void widgetsChanged(QString text);
    void Close(bool visible);
    void moved(QPoint position);
    void resized(QSize size);
};

#endif
