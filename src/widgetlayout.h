/*
    Copyright (C) 2010 Andres Cabrera
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

#ifndef WIDGETLAYOUT_H
#define WIDGETLAYOUT_H

#include <QtGui>

#define QCS_MAX_EVENTS 4096

#include "qutewidget.h"
#include "curve.h"
#include "widgetpreset.h"

class QuteConsole;
class QuteGraph;
class QuteScope;
class QuteButton;
class FrameWidget;

class WidgetLayout : public QWidget
{
  Q_OBJECT
  public:
    WidgetLayout(QWidget* parent);
    ~WidgetLayout();
    unsigned int widgetCount();
    void loadWidgets(QString macWidgets);
    QString getWidgetsText(); // With full tags
    QString getPresetsText();
    QString getSelectedWidgetsText();
    QString getMacWidgetsText(); // With full tags
    QStringList getSelectedMacWidgetsText();

    void setValue(QString channelName, double value);
    void setValue(QString channelName, QString value);
    void setValue(int index, double value);
    void setValue(int index, QString value);

    void setKeyRepeatMode(bool repeat);
    void setOuterGeometry(int newx, int newy, int neww, int newh); // Will only set if component >= 0
    QRect getOuterGeometry();

    void getValues(QVector<QString> *channelNames,
                   QVector<double> *values,
                   QVector<QString> *stringValues);
    void getMouseValues(QVector<double> *values);
    int getMouseX();
    int getMouseY();
    int getMouseRelX();
    int getMouseRelY();
    int getMouseBut1();
    int getMouseBut2();

    int newWidget(QString widgetLine, bool offset = false);
    void appendMessage(QString message);
    void flush();
    void engineStopped(); // To let the widgets know engine has stopped (to free unused curve buffers)
    void showWidgetTooltips(bool show);
    void setWidgetToolTip(QuteWidget *widget, bool show);
    void setContained(bool contained);

    void appendCurve(WINDAT *windat);
    void killCurve(WINDAT *windat);
    void newCurve(Curve* curve);
    void setCurveData(Curve *curve);
    uintptr_t getCurveById(uintptr_t id);
    void updateCurve(WINDAT *windat);
    int killCurves(CSOUND *csound);
    void clearGraphs();

    void refreshConsoles();
    QString getCsladspaLines();
    bool isModified();
    void passWidgetClipboard(QString text);

    void createContextMenu(QContextMenuEvent *event);  // When done outside container widget

    // Edition Actions
    QAction *clearAct;
    QAction *selectAllAct;
    QAction *duplicateAct;
    QAction *deleteAct;
    QAction *propertiesAct;
    
    // Alignment Actions
    QAction *alignLeftAct;
    QAction *alignRightAct;
    QAction *alignTopAct;
    QAction *alignBottomAct;
    QAction *sendToBackAct;
    QAction *distributeHorizontalAct;
    QAction *distributeVerticalAct;

  public slots:
    void createNewLabel();
    void createNewDisplay();
    void createNewScrollNumber();
    void createNewLineEdit();
    void createNewSpinBox();
    void createNewSlider();
    void createNewButton();
    void createNewKnob();
    void createNewCheckBox();
    void createNewMenu();
    void createNewMeter();
    void createNewConsole();
    void createNewGraph();
    void createNewScope();
    void clearWidgets();
    void clearWidgetLayout();
    void propertiesDialog();
    void applyProperties();
    void selectBgColor();
    void setEditEnabled(bool enabled);
    void setEditMode(bool active);
    void deselectAll();
    void selectAll();
    void widgetMoved(QPair<int, int>);
    void widgetResized(QPair<int, int>);
    void mousePressEventParent(QMouseEvent *event); // To receive events from ancestors when outside the widget area
    void mouseReleaseEventParent(QMouseEvent *event);
    void mouseMoveEventParent(QMouseEvent *event);
    void selectionChanged(QRect selection);
    void adjustLayoutSize();
    void setModified(bool mod = true);
    void setMouseOffset(int x, int y);

    void copy();
    void cut();
    void paste();
    void paste(QPoint pos);
    void duplicate();
    void deleteSelected();
    void undo();
    void redo();
    void alignLeft();
    void alignRight();
    void alignTop();
    void alignBottom();
    void sendToBack();
    void distributeHorizontal();
    void distributeVertical();
    void markHistory();
    void createEditFrame(QuteWidget* widget);

    void widgetChanged(QuteWidget* widget = 0);
    void deleteWidget(QuteWidget *widget);

    void newValue(QPair<QString, double> channelValue);
    void newValue(QPair<QString, QString> channelValue);
    void processNewValues();
    void queueEvent(QString eventLine);

  protected:
    virtual void mousePressEvent(QMouseEvent *event);
    virtual void mouseMoveEvent(QMouseEvent *event);
    virtual void mouseReleaseEvent(QMouseEvent *event);
    virtual void keyPressEvent(QKeyEvent *event);
    virtual void keyReleaseEvent(QKeyEvent *event);
    virtual void contextMenuEvent(QContextMenuEvent *event);
    QRubberBand *selectionFrame;
    int startx, starty;

  private:
    QHash<QString, double> newValues;
    QHash<QString, QString> newStringValues;
    QMutex valueMutex;
    QMutex stringValueMutex;
    QMutex layoutMutex;
    QList<Curve *> newCurveBuffer;  // To store curves from Csound for widget panel Graph widgets
    QVector<WINDAT *> curveUpdateBuffer;
    QVector<Curve *> curves;

    bool m_repeatKeys;
    int m_x, m_y, m_w, m_h; // Position and size of panel (not this widget)
    bool m_trackMouse;
    int mouseX, mouseY, mouseRelX, mouseRelY, mouseBut1, mouseBut2;
    int xOffset, yOffset;

    // Create new widget Actions
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

    // For the properties dialog - they store the configuration data for the widget panel
    QPoint currentPosition;
    QCheckBox *bgCheckBox;
    QPushButton *bgButton;
    int closing; // to control timer when destroying this object

    QVector<QString> m_history;  // Undo/ Redo history
    int m_historyIndex; // Current point in history
    bool m_modified;
    bool m_editMode;
    bool m_enableEdit; // Enable editing and properties dialog
    QString m_clipboard;
    bool m_contained; // Whether contained in another widget (e.g. scrollbar in widget panel or widget panel)

    // Contained Widgets
    QVector<QuteWidget *> m_widgets;
    QVector<FrameWidget *> editWidgets;
    // These vectors must be used with care since they are not reentrant and will
    // cause problems when accessed simultaneously
    // They are pointers to widgets already in widgets vector
    // TODO check where these are accessed for problems
    QVector<QuteConsole *> consoleWidgets;
    QVector<QuteGraph *> graphWidgets;
    QVector<QuteScope *> scopeWidgets;

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

    bool m_tooltips;
    QVector<WidgetPreset> presets;
    unsigned long m_ksmpscount;

    //Undo history
    void clearHistory();

    // Preset methods
    void loadPreset(int num);
    void newPreset(QString name);
    void savePreset(int num, QString name);
    void setPresetName(int num, QString name);

  private slots:
    void updateData();

  signals:
    void selection(QRect area);
    void keyPressed(QString key);
    void keyReleased(QString key);
    void resized(); // To let widget panel know widget layout has changed size
    void changed(); // Should be triggered whenever widgets change, to let main document know
    void registerScope(QuteScope *scope);
    void registerGraph(QuteGraph *graph);
    void registerButton(QuteButton *button);
    void queueEventSignal(QString eventLine);
    void setWidgetClipboardSignal(QString text);  // To propagate clipboard for sharing between pages
};

#endif // WIDGETLAYOUT_H
