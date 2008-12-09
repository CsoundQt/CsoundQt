/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
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
#ifndef WIDGETPANEL_H
#define WIDGETPANEL_H

#include <QtGui>

#define QUTECSOUND_MAX_EVENTS 32

#include "qutewidget.h"
class QuteConsole;

class WidgetPanel : public QDockWidget
{
  Q_OBJECT

  friend class qutecsound;
  public:
    WidgetPanel(QWidget *parent);
    ~WidgetPanel();

    unsigned int widgetCount();
    void getValues(QVector<QString> *channelNames, QVector<double> *values, QVector<QString> *stringValues);
    void setValue(QString channelName, double value);
    void setValue(QString channelName, QString value);
    void setValue(int index, double value);
    void setValue(int index, QString value);
    int loadWidgets(QString macWidgets);
    int newWidget(QString widgetLine);
    QString widgetsText();
    void appendMessage(QString message);
    void showTooltips(bool show);

    QVector<QString> eventQueue;
    int eventQueueSize;

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);

  private:
    QVector<QuteWidget *> widgets;
    QVector<QuteConsole *> consoleWidgets;
    QVector<QFrame *> editWidgets;
    QWidget *layoutWidget;

    QPoint currentPosition;
    QAction *createSliderAct;
    QAction *createLabelAct;
    QAction *createLineEditAct;
    QAction *createButtonAct;
    QAction *createKnobAct;
    QAction *createCheckBoxAct;
    QAction *createMenuAct;
    QAction *createMeterAct;
    QAction *createConsoleAct;
    QAction *createGraphAct;
    QAction *editAct;
    QAction *clearAct;
    QAction *propertiesAct;

    // For the properties dialog
    QCheckBox *bgCheckBox;
    QPushButton *bgButton;

    int createSlider(int x, int y, int width, int height, QString widgetLine);
    int createLabel(int x, int y, int width, int height, QString widgetLine);
    int createLineEdit(int x, int y, int width, int height, QString widgetLine);
    int createButton(int x, int y, int width, int height, QString widgetLine);
    int createKnob(int x, int y, int width, int height, QString widgetLine);
    int createCheckBox(int x, int y, int width, int height, QString widgetLine);
    int createMenu(int x, int y, int width, int height, QString widgetLine);
    int createMeter(int x, int y, int width, int height, QString widgetLine);
    int createConsole(int x, int y, int width, int height, QString widgetLine);
    int createGraph(int x, int y, int width, int height, QString widgetLine);
    int createDummy(int x, int y, int width, int height, QString widgetLine);

    void setBackground(bool bg, QColor bgColor);

    virtual void closeEvent(QCloseEvent * event);

  public slots:
    void newValue(QHash<QString, double> channelValue);
    void widgetChanged();
    void deleteWidget(QuteWidget *widget);
    void queueEvent(QString eventLine);
    void createLabel();
    void createLineEdit();
    void createSlider();
    void createButton();
    void createKnob();
    void createCheckBox();
    void createMenu();
    void createMeter();
    void createConsole();
    void createGraph();
    void propertiesDialog();
    void clearWidgets();
    void applyProperties();
    void selectBgColor();
    void activateEditMode(bool active);
    void createEditFrame(QuteWidget* widget);

  signals:
    void widgetsChanged(QString text);
    void Close(bool visible);

};

class FrameWidget : public QFrame
{
  Q_OBJECT
  public:
    FrameWidget(QWidget* parent) : QFrame(parent) {
      m_resizeBox = new QFrame(this);
      m_resizeBox->setAutoFillBackground(true);
//       m_resizeBox->move(width()-7, height()-7);
//       m_resizeBox->resize(7,7);
      QPalette palette(QColor(Qt::red),QColor(Qt::red));
      palette.setColor(QPalette::WindowText, QColor(Qt::red));
      m_resizeBox->setPalette(palette);
      m_resizeBox->show();
    }
    ~FrameWidget() {}

    void setWidget(QuteWidget* widget) {m_widget = widget;}

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {emit(popUpMenu(event->globalPos()));}
    virtual void mousePressEvent ( QMouseEvent * event )
    {
      QWidget::mousePressEvent(event);
      startx = event->x();
      widgetx = x();;
      starty = event->y();
      widgety = y();
      widgetw = width();
      widgeth = height();
      if (startx > (width()-7) and starty > (height()-7))
        m_resize = true;
      else
        m_resize = false;
    }
    virtual void mouseMoveEvent (QMouseEvent* event)
    {
//       qDebug("pos %i, %i", startx - event->x(), starty - event->y());
      if (m_resize) {
        int neww = widgetw - startx + event->x();
        int newh = widgeth - starty + event->y();
        resize(neww, newh);
        m_widget->setWidgetGeometry(m_widget->x(), m_widget->y(),neww, newh);
      }
      else {
        int newx = widgetx - startx + event->x();
        int newy = widgety - starty + event->y();
        move(newx, newy);
        m_widget->move(newx, newy);
      }
      widgetx = x();
      widgety = y();
      m_widget->markChanged();
//       widgetw = width();
//       widgeth = height();
    }
    virtual void resizeEvent (QResizeEvent* event)
    {
      QWidget::resizeEvent(event);
      m_resizeBox->move(width()-7, height()-7);
      m_resizeBox->resize(7,7);
    }

  private:
    int startx, starty, widgetx, widgety, widgetw, widgeth;
    QFrame *m_resizeBox;
    QuteWidget *m_widget;
    bool m_resize;

  signals:
    void popUpMenu(QPoint pos);
};


#endif
