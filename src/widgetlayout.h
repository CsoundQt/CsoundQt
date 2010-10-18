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
#define QCS_CURVE_BUFFER_MAX 4096

#include "qutewidget.h"
#include "curve.h"
#include "widgetpreset.h"

class QuteConsole;
class QuteGraph;
class QuteScope;
class QuteButton;
class FrameWidget;

class RegisteredController {
public:
  RegisteredController(QuteWidget * _widget, int _chan,int  _cc) {
    widget = _widget;
    chan = _chan;
    cc = _cc;
  }
  int chan;
  int cc;
  QuteWidget * widget;
};

class WidgetLayout : public QWidget
{
  Q_OBJECT
  Q_PROPERTY(bool openProperties READ getOpenProperties WRITE setOpenProperties); // To make sure only one properties dialog is displayed at any one time
  public:
    WidgetLayout(QWidget* parent);
    ~WidgetLayout();
//    unsigned int widgetCount();
//    void loadWidgets(QString widgets);
    void loadXmlWidgets(QString xmlWidgets);
    void loadXmlPresets(QString xmlPresets);
    void loadMacWidgets(QString macWidgets);
    QString getWidgetsText(); // With full tags
    QString getPresetsText();
    QString getSelectedWidgetsText();
    QString getMacWidgetsText(); // With full tags
    QStringList getSelectedMacWidgetsText();
    QString getCsladspaLines();
    bool openMidiPort(int port);
    void closeMidiPort();

    // Data to/from widgets
    void setValue(QString channelName, double value);
    void setValue(QString channelName, QString value);
    void setValue(int index, double value);
    void setValue(int index, QString value);
    QString getStringForChannel(QString channelName);
    double getValueForChannel(QString channelName);
    void getMouseValues(QVector<double> *values);
    int getMouseX();
    int getMouseY();
    int getMouseRelX();
    int getMouseRelY();
    int getMouseBut1();
    int getMouseBut2();

    // Behavior
    void setKeyRepeatMode(bool repeat);
    void showWidgetTooltips(bool show);
    void setWidgetToolTip(QuteWidget *widget, bool show);
    void setContained(bool contained);
    void setCurrentPosition(QPoint pos); // To set the mouse position for new widgets
    void setFontOffset(double offset);
    void setFontScaling(double scaling);
    void setWidgetsLocked(bool lock);

    // Properties
    bool getOpenProperties() { return m_openProperties; }
    void setOpenProperties(bool open) {m_openProperties = open; }
    void setOuterGeometry(int newx = -1 , int newy = -1 , int neww = -1, int newh = -1); // Will only set if component >= 0
    QRect getOuterGeometry();

//    void getValues(QVector<QString> *channelNames,
//                   QVector<double> *values,
//                   QVector<QString> *stringValues);

    bool uuidFree(QString uuid);
    int newXmlWidget(QDomNode node, bool offset = false, bool newId = false);
    int newMacWidget(QString widgetLine, bool offset = false);  // Offset is used when pasting duplicated widgets
    void registerWidget(QuteWidget *widget);

    QVector<QVector<int> > midiQueue;
    int midiWriteCounter;
    int midiReadCounter;

    // Messages
    void appendMessage(QString message);
    void flush();

    // Notifiations
    void engineStopped(); // To let the widgets know engine has stopped (to free unused curve buffers)

    // Preset methods
    void setPresetName(int num, QString name);
    QList<int> getPresetNums();
    QString getPresetName(int num);
    bool presetExists(int num);

    // Curves from API
    void appendCurve(WINDAT *windat);
    void killCurve(WINDAT *windat);
    void newCurve(Curve* curve);
    void setCurveData(Curve *curve);
    uintptr_t getCurveById(uintptr_t id);
    void updateCurve(WINDAT *windat);
    int killCurves(CSOUND *csound);
    void clearGraphs(); // This also frees the memory allocated by curves.
    void flushGraphBuffer();

    void refreshConsoles();
    void refreshWidgets();
    bool isModified();
    void passWidgetClipboard(QString text);

    void createContextMenu(QContextMenuEvent *event);  // When done outside container widget

    // Edition Actions  (Local edit actions without keyboard shortcuts as the main application handles that)
    QAction *cutAct;
    QAction *copyAct;
    QAction *pasteAct;
    QAction *clearAct;
    QAction *selectAllAct;
    QAction *duplicateAct;
    QAction *deleteAct;
    QAction *propertiesAct;

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
    
    // Alignment Actions
    QAction *alignLeftAct;
    QAction *alignRightAct;
    QAction *alignTopAct;
    QAction *alignBottomAct;
    QAction *sendToBackAct;
    QAction *distributeHorizontalAct;
    QAction *distributeVerticalAct;
    QAction *alignCenterHorizontalAct;
    QAction *alignCenterVerticalAct;

    // Preset actions
    QAction *storePresetAct;
    QAction *newPresetAct;
    QAction *recallPresetAct;

  public slots:
    void createNewLabel(int x = -1, int y = -1);
    void createNewDisplay(int x = -1, int y = -1);
    void createNewScrollNumber(int x = -1, int y = -1);
    void createNewLineEdit(int x = -1, int y = -1);
    void createNewSpinBox(int x = -1, int y = -1);
    void createNewSlider(int x = -1, int y = -1);
    void createNewButton(int x = -1, int y = -1);
    void createNewKnob(int x = -1, int y = -1);
    void createNewCheckBox(int x = -1, int y = -1);
    void createNewMenu(int x = -1, int y = -1);
    void createNewMeter(int x = -1, int y = -1);
    void createNewConsole(int x = -1, int y = -1);
    void createNewGraph(int x = -1, int y = -1);
    void createNewScope(int x = -1, int y = -1);
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
    QSize getUsedSize();
    void adjustLayoutSize();
    void setModified(bool mod = true);
    void setMouseOffset(int x, int y);

    // Preset slots
    void loadPreset(); // Show dialog and ask
    void loadPresetFromAction();  // Triggered from menu item
    void loadPresetFromItem(QTreeWidgetItem * item, int column);  // Triggered from tree widget
    void loadPreset(int num);
    void loadPresetFromIndex(int index);
    void newPreset(); // Show dialog asking for name
//    void newPreset(int num, QString name);
    void savePreset(); // Show dialog asking for name
    void savePreset(int num, QString name);

    // Editing
    void copy();
    void cut();
    void paste();
//    void paste(QPoint pos);
    void duplicate();
    void deleteSelected();
    void undo();
    void redo();

    // Alignment
    void alignLeft();
    void alignRight();
    void alignTop();
    void alignBottom();
    void sendToBack();
    void distributeHorizontal();
    void distributeVertical();
    void alignCenterVertical();
    void alignCenterHorizontal();

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
    virtual void resizeEvent(QResizeEvent * event);
    virtual void moveEvent(QMoveEvent * event);
//    virtual void showEvent(QShowEvent * event);
    QRubberBand *selectionFrame;
    int startx, starty;

  private:
    QHash<QString, double> newValues;
    QHash<QString, QString> newStringValues;
    QMutex valueMutex;
    QMutex stringValueMutex;
    QMutex widgetsMutex;
    QMutex layoutMutex;
    QList<Curve *> newCurveBuffer;  // To store curves from Csound for widget panel Graph widgets
    QVector<WINDAT> curveUpdateBuffer; // FIXME move these buffers to documentpage to avoid duplication when having multiple panels
    int curveUpdateBufferCount;
    QList<Curve *> curves;
    QTimer updateTimer;

    unsigned long m_ksmpscount;  // Ksmps counter for Csound engine (Really needed here?)

    // Properties of the panel (saved to xml file)
    int m_posx, m_posy, m_w, m_h; // Position and size of panel (not this widget)
    QString m_objectName;
    QString m_uuid;
    bool m_visible;

    // Configuration
    bool m_repeatKeys;
    bool m_xmlFormat;
    bool m_trackMouse;
    bool m_openProperties; // Open widget properties when creating widgets
    bool m_enableEdit; // Enable editing and properties dialog
    bool m_tooltips;  // Show widget tooltips
    int mouseX, mouseY, mouseRelX, mouseRelY, mouseBut1, mouseBut2;
    int xOffset, yOffset;
    double m_fontOffset, m_fontScaling;

    // For the properties dialog - they store the configuration data for the widget panel
    QPoint currentPosition;  //TODO use proper variables instead of storing data in the widgets...
    QCheckBox *bgCheckBox;
    QPushButton *bgButton;
    int closing; // to control timer when destroying this object

    QVector<QString> m_history;  // Undo/ Redo history
    int m_historyIndex; // Current point in history
    bool m_modified;
    bool m_editMode;
    QString m_clipboard;
    bool m_contained; // Whether contained in another widget (e.g. scrollbar in widget panel or widget panel)

    QVector<WidgetPreset> presets;
    int m_currentPreset; // If -1 no current preset

    QList<RegisteredController> registeredControllers;

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
    int m_activeWidgets; // Keeps a number of widgets that can be currently accessed by value callbacks (e.g. set to 0 during paste). This is done to avoid locking the callbacks, which are called from a realtime thread

    int parseXmlNode(QDomNode node);
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
    FrameWidget *getEditWidget(QuteWidget *widget);

    void registerWidgetController(QuteWidget *widget, int cc);
    void registerWidgetChannel(QuteWidget *widget, int chan);
    void unregisterWidgetController(QuteWidget *widget);
    void clearWidgetControllers();

    //Undo history
    void clearHistory();

    // Preset Methods
    int getPresetIndex(int number);

    //XML helper functions
    QColor getColorFromElement(QDomElement elem);  // Converts an XML color element to a QColor structure

  private slots:
    void updateData();

  signals:
    void selection(QRect area);
    void keyPressed(QString key);
    void keyReleased(QString key);
    void changed(); // Should be triggered whenever widgets change, to let main document know
    void registerScope(QuteScope *scope);
    void registerGraph(QuteGraph *graph);
    void registerButton(QuteButton *button);
    void queueEventSignal(QString eventLine);
    void setWidgetClipboardSignal(QString text);  // To propagate clipboard for sharing between pages
};

#endif // WIDGETLAYOUT_H
