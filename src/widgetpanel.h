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

class Curve;
class QuteConsole;
class QuteGraph;
class QuteScope;
class FrameWidget;
class LayoutWidget;

class WidgetPanel : public QDockWidget
{
  Q_OBJECT

  friend class qutecsound;  //necessary?
  friend class QuteWidget;
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
    int newWidget(QString widgetLine, bool offset = false);
    QString widgetsText();
    void appendMessage(QString message);
    void showTooltips(bool show);
    void newCurve(Curve* curve);
    void clearGraphs();

    QVector<QString> eventQueue;
    int eventQueueSize;

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);
    virtual void resizeEvent(QResizeEvent * event);
    virtual void moveEvent(QMoveEvent * event);

  private:
    QVector<QuteWidget *> widgets;
    QVector<QuteConsole *> consoleWidgets;
    QVector<QuteGraph *> graphWidgets;
    QVector<QuteScope *> scopeWidgets;
    QVector<FrameWidget *> editWidgets;
    LayoutWidget *layoutWidget;

    QPoint currentPosition;
    QAction *createSliderAct;
    QAction *createLabelAct;
    QAction *createDisplayAct;
    QAction *createScrollNumberAct;
    QAction *createLineEditAct;
    QAction *createSpinBoxAct;
    QAction *createButtonAct;
    QAction *createKnobAct;
    QAction *createCheckBoxAct;
    QAction *createMenuAct;
    QAction *createMeterAct;
    QAction *createConsoleAct;
    QAction *createGraphAct;
    QAction *createScopeAct;
    QAction *editAct;
    QAction *clearAct;
    QAction *copyAct;
    QAction *cutAct;
    QAction *pasteAct;
    QAction *duplicateAct;
    QAction *propertiesAct;

    // For the properties dialog
    QCheckBox *bgCheckBox;
    QPushButton *bgButton;

    QStringList clipboard;
    QSize oldSize;

    int createSlider(int x, int y, int width, int height, QString widgetLine);
    int createText(int x, int y, int width, int height, QString widgetLine);
    int createScrollNumber(int x, int y, int width, int height, QString widgetLine);
    int createLineEdit(int x, int y, int width, int height, QString widgetLine);
    int createSpinBox(int x, int y, int width, int height, QString widgetLine);
    int createButton(int x, int y, int width, int height, QString widgetLine);
    int createKnob(int x, int y, int width, int height, QString widgetLine);
    int createCheckBox(int x, int y, int width, int height, QString widgetLine);
    int createMenu(int x, int y, int width, int height, QString widgetLine);
    int createMeter(int x, int y, int width, int height, QString widgetLine);
    int createConsole(int x, int y, int width, int height, QString widgetLine);
    int createGraph(int x, int y, int width, int height, QString widgetLine);
    int createScope(int x, int y, int width, int height, QString widgetLine);
    int createDummy(int x, int y, int width, int height, QString widgetLine);

    void setBackground(bool bg, QColor bgColor);

    virtual void closeEvent(QCloseEvent * event);

  public slots:
    void newValue(QHash<QString, double> channelValue);
    void widgetChanged(QuteWidget* widget = 0);
    void deleteWidget(QuteWidget *widget);
    void queueEvent(QString eventLine);
    void createLabel();
    void createDisplay();
    void createScrollNumber();
    void createLineEdit();
    void createSpinBox();
    void createSlider();
    void createButton();
    void createKnob();
    void createCheckBox();
    void createMenu();
    void createMeter();
    void createConsole();
    void createGraph();
    void createScope();
    void propertiesDialog();
    void clearWidgets();
    void clearWidgetPanel();
    void applyProperties();
    void selectBgColor();
    void activateEditMode(bool active);
    void createEditFrame(QuteWidget* widget);
    void deselectAll();
    void widgetMoved(QPair<int, int>);
    void widgetResized(QPair<int, int>);

  private slots:
    void copy();
    void cut();
    void paste();
    void paste(QPoint pos);
    void duplicate();
    void undo();
    void redo();
//     void dockStateChanged(bool topLevel);

  signals:
    void widgetsChanged(QString text);
    void Close(bool visible);
    void moved(QPoint position);
    void resized(QSize size);

};

class LayoutWidget : public QWidget
{
  Q_OBJECT
  public:
    LayoutWidget(QWidget* parent) : QWidget(parent)
    {
      selectionFrame = new QRubberBand(QRubberBand::Rectangle, this);
      selectionFrame->hide();
    }
    ~LayoutWidget() {}

  protected:
    virtual void mousePressEvent(QMouseEvent *event)
    {
      QWidget::mousePressEvent(event);
      this->setFocus(Qt::MouseFocusReason);
//       selectionFrame->show();
//       startx = event->x();
//       starty = event->y();
//       selectionFrame->setGeometry(startx, starty, 0,0);
    }
    virtual void mouseMoveEvent(QMouseEvent *event)
    {
      QWidget::mouseMoveEvent(event);
//       int x = startx;
//       int y = starty;
//       int height = abs(event->y() - starty);
//       int width = abs(event->x() - startx);
//       if (event->x() < startx) {
//         x = event->x();
//       }
//       if (event->y() < starty) {
//         y = event->y();
//       }
//       selectionFrame->setGeometry(x, y, width, height);
    }
    virtual void mouseReleaseEvent(QMouseEvent *event)
    {
      QWidget::mouseReleaseEvent(event);
      selectionFrame->hide();
      if (event->button() & Qt::LeftButton) {
        emit deselectAll();
      }
    }
    QRubberBand *selectionFrame;
    int startx, starty;

  signals:
    void deselectAll();
};

#endif
