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

class QuteWidget;
class QuteConsole;

class WidgetPanel : public QDockWidget
{
  Q_OBJECT
  public:
    WidgetPanel(QWidget *parent);
    ~WidgetPanel();

    unsigned int widgetCount();
    void getValues(QVector<QString> *channelNames, QVector<double> *values);
    void setValue(QString channelName, double value);
    void setValue(int index, double value);
    int loadWidgets(QString macWidgets);
    int newWidget(QString widgetLine);
    QString widgetsText();
	void appendMessage(QString message);

    QVector<QString> eventQueue;
    int eventQueueSize;

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event);

  private:
    QVector<QuteWidget *> widgets;
	QVector<QuteConsole *> consoleWidgets;
    QWidget *layoutWidget;

    QPoint currentPosition;
    QAction *createSliderAct;
    QAction *createLabelAct;
    QAction *createButtonAct;
    QAction *createKnobAct;
    QAction *createCheckBoxAct;
    QAction *createMenuAct;
    QAction *createMeterAct;
    QAction *createConsoleAct;
    QAction *createGraphAct;
    QAction *clearAct;
    QAction *propertiesAct;

    // For the properties dialog
    QCheckBox *bgCheckBox;
    QPushButton *bgButton;

    int createSlider(int x, int y, int width, int height, QString widgetLine);
    int createLabel(int x, int y, int width, int height, QString widgetLine);
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

  signals:
    void widgetsChanged(QString text);
    void Close(bool visible);

};

#endif
