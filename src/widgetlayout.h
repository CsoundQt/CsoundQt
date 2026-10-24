/*
	Copyright (C) 2010 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
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
#include <atomic>

#define CSQT_MAX_EVENTS 4096
#define CSQT_CURVE_BUFFER_MAX 4096

#include "qutewidget.h"
#include "curve.h"
#include "widgetpreset.h"

// Single-producer / single-consumer lock free ring buffer.
// Used to hand values from Csound's performance thread to the GUI thread
// without blocking the audio callback and without allocating.
template <typename T, unsigned N>
class CsqtSpscQueue
{
public:
	// Only the producer (audio thread) calls this. Returns false if full.
	bool push(const T &item) {
		const unsigned tail = m_tail.load(std::memory_order_relaxed);
		const unsigned next = (tail + 1) % N;
		if (next == m_head.load(std::memory_order_acquire)) {
			return false;
		}
		m_data[tail] = item;
		m_tail.store(next, std::memory_order_release);
		return true;
	}

	// Only the consumer (GUI thread) calls this. Returns false if empty.
	bool pop(T &item) {
		const unsigned head = m_head.load(std::memory_order_relaxed);
		if (head == m_tail.load(std::memory_order_acquire)) {
			return false;
		}
		item = m_data[head];
		m_head.store((head + 1) % N, std::memory_order_release);
		return true;
	}

private:
	T m_data[N];
	std::atomic<unsigned> m_head{0};
	std::atomic<unsigned> m_tail{0};
};

class QuteConsole;
class QuteGraph;
class QuteScope;
class QuteButton;
class FrameWidget;
class QuteTable;
class QuteWaveform;
class QuteVUMeter;

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
	Q_PROPERTY(bool openProperties READ getOpenProperties WRITE setOpenProperties) // To make sure only one properties dialog is displayed at any one time
public:
	WidgetLayout(QWidget* parent);
	~WidgetLayout();
	//    unsigned int widgetCount();
	//    void loadWidgets(QString widgets);
	void loadXmlWidgets(QString xmlWidgets);
	void loadXmlPresets(QString xmlPresets);
	QString getWidgetsText(); // With full tags
	QString getPresetsText();
	QString getSelectedWidgetsText();
	QString getCsladspaLines();
	bool openMidiPort(int port);
	void closeMidiPort();
	QVector<QuteWidget *> getWidgets() {return m_widgets;}
	// Widgets currently selected in the editor (empty when not editing)
	QList<QuteWidget *> getSelectedWidgets();
	bool isEditMode() const { return m_editMode; }
	QuteWidget *getHoveredWidget() const { return m_hoveredWidget; }
	// Ask the document to mark editor lines for this widget (or the current
	// selection when widget is nullptr).
	void highlightWidgetChannels(QuteWidget *widget = nullptr);

	// Data to/from widgets
	void setValue(QString channelName, double value);
	void setValue(QString channelName, QString value);
	void setValue(int index, double value);
	void setValue(int index, QString value);
	void setDisplayValue(QString channelName, double value);
	QString getStringForChannel(QString channelName, bool *modified = 0);
    double getValueForChannel(QString channelName, bool *modified = 0, double notfound = 0.0);
	// Rebuild and atomically publish the lock-free channel snapshot read by the
	// realtime input callbacks. Must be called on the GUI thread after the
	// channel map / widget set changed (e.g. after setupChannels()).
	void publishChannelSnapshot();
	void getMouseValues(QVector<double> *values);
	int getMouseX();
	int getMouseY();
	int getMouseRelX();
	int getMouseRelY();
	int getMouseBut1();
	int getMouseBut2();
	void setWidgetProperty(QString widgetid, QString property, QVariant value);
	QVariant getWidgetProperty(QString widgetid, QString property);
	void flush();

	// Behavior
	void setKeyRepeatMode(bool repeat);
	void showWidgetTooltips(bool show);
	void setWidgetToolTip(QuteWidget *widget, bool show);
	void setContained(bool contained);
	void setCurrentPosition(QPoint pos); // To set the mouse position for new widgets
	void setWidgetsLocked(bool lock);
    void setUpdateRate(int rate) { m_updateRate = rate; }

	// Experimental channel probe: outline every widget whose channel (or
	// secondary channel) matches. The outline is temporary and is removed by
	// clearChannelHighlights(), Escape, a mouse click, or moving away from it.
	void highlightChannel(const QString &channel);
	void clearChannelHighlights();

	// Properties
	bool getOpenProperties() { return m_openProperties; }
	void setOpenProperties(bool open) {m_openProperties = open; }
	// Outer geometry refers to the geometry of the parent panel if not separate window
	void setOuterGeometry(QRect r);
	QRect getOuterGeometry();

	//    void getValues(QVector<QString> *channelNames,
	//                   QVector<double> *values,
	//                   QVector<QString> *stringValues);

	bool uuidFree(QString uuid);
	bool widgetNameFree(const QString &name, QuteWidget *exclude = nullptr); // empty names are always free
	bool renameWidget(QuteWidget *widget, const QString &newName); // Sets the widget name if free, updates the name->widget map. Returns false if the name is taken by another widget.

	// Called from Csound's performance thread (outvalue callback). These only
	// copy the raw name/value into a lock free queue; the widgets themselves are
	// updated later on the GUI thread by processCsoundUpdates() (see updateData()).
	bool enqueueOutputValue(const char *channelName, double value);
	bool enqueueOutputString(const char *channelName, const char *value);
	int newXmlWidget(QDomNode node, bool offset = false, bool newId = false);
	void registerWidget(QuteWidget *widget);

	// TEST: try to get midiBingins info
	QString getMidiControllerInstrument();

	QVector<QVector<int> > midiQueue;
	int midiWriteCounter;
	int midiReadCounter;

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

	void refreshWidgets();
	bool isModified();
	//    void passWidgetClipboard(QString text);

	void createContextMenu(QContextMenuEvent *event);  // When done outside container widget

	// Show (once) an informational dialog about widget fonts that are not
	// bundled and were replaced; called after a file is loaded.
	void reportUnknownWidgetFonts();

	// Edition Actions  (Local edit actions without keyboard shortcuts as the main application handles that)
	QAction *cutAct;
	QAction *copyAct;
	QAction *pasteAct;
    QAction *reloadWidgetsAct;
	QAction *clearAct;
	QAction *selectAllAct;
	QAction *duplicateAct;
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
    QAction *createTableDisplayAct;
	QAction *createWaveformAct;
	QAction *createVUMeterAct;

	// Alignment Actions
	QAction *alignLeftAct;
	QAction *alignRightAct;
	QAction *alignTopAct;
	QAction *alignBottomAct;
	QAction *sendToBackAct;
    QAction *sendToFrontAct;
	// Directional selection (edit mode, Ctrl+arrows)
	QAction *selectLeftAct;
	QAction *selectRightAct;
	QAction *selectUpAct;
	QAction *selectDownAct;
	QAction *distributeHorizontalAct;
	QAction *distributeVerticalAct;
	QAction *alignCenterHorizontalAct;
	QAction *alignCenterVerticalAct;

	// Preset actions
	QAction *storePresetAct;
	QAction *newPresetAct;
	QAction *recallPresetAct;

    // Value changes buffer to store all value changes from widgets that
    // have been triggered from the GUI
	QHash<QString, double> newValues;
	QHash<QString, QString> newStringValues;
	QMutex valueMutex;
	QMutex stringValueMutex;
	QReadWriteLock mouseLock;
	
	

    QString getQml();

    QuteWidgetType widgetNameToType(QString widgetName);
    void addCreateWidgetActionsToMenu(QMenu &menu);
    
    QHash<QString, QList<QuteWidget *>> channelNameToWidgets;
    

public slots:
	QString createNewLabel(int x = -1, int y = -1, QString channel = QString());
	QString createNewDisplay(int x = -1, int y = -1, QString channel = QString());
	QString createNewScrollNumber(int x = -1, int y = -1, QString channel = QString());
	QString createNewLineEdit(int x = -1, int y = -1, QString channel = QString());
	QString createNewSpinBox(int x = -1, int y = -1, QString channel = QString());
	QString createNewSlider(int x = -1, int y = -1, QString channel = QString());
	QString createNewButton(int x = -1, int y = -1, QString channel = QString());
	QString createNewKnob(int x = -1, int y = -1, QString channel = QString());
	QString createNewCheckBox(int x = -1, int y = -1, QString channel = QString());
	QString createNewMenu(int x = -1, int y = -1, QString channel = QString());
	QString createNewMeter(int x = -1, int y = -1, QString channel = QString());
	QString createNewConsole(int x = -1, int y = -1, QString channel = QString());
	QString createNewGraph(int x = -1, int y = -1, QString channel = QString());
	QString createNewScope(int x = -1, int y = -1, QString channel = QString());
    QString createNewTableDisplay(int x= -1, int y= -1, QString channel = QString());
    QString createNewWaveform(int x = -1, int y = -1, QString channel = QString());
    QString createNewVUMeter(int x = -1, int y = -1, QString channel = QString());

	void clearWidgets();
	void clearWidgetLayout();


	QStringList getUuids();
	QStringList listProperties(QString widgetid); // widgetid can be eihter uuid (prefered) or channel
	bool destroyWidget(QString widgetid);

	void propertiesDialog();
	void applyProperties();
	void selectBgColor();
	void setEditEnabled(bool enabled);
	void setEditMode(bool active);
	// Offline render: keep receiving values and keep sending input values to
	// Csound, but do not update or paint the widget displays.
	void setDrawingEnabled(bool enabled);
	bool drawingEnabled() const { return m_drawingEnabled; }
	void setFrameColors(const QColor &unselected, const QColor &selected);
	void deselectAll();
	void selectAll();
	void widgetMoved(QPair<int, int>);
	void widgetResized(QPair<int, int>);
	void widgetResizedTopLeft(QPair<int, int>);
	void mousePressEventParent(QMouseEvent *event); // To receive events from ancestors when outside the widget area
	void mouseReleaseEventParent(QMouseEvent *event);
	void mouseMoveEventParent(QMouseEvent *event);
	void selectionChanged(QRect selection);
	// Rubber-band selection driven by a widget frame (Shift+drag started on a
	// widget); positions are global screen coordinates.
	void beginSelection(QPoint globalPos);
	void continueSelection(QPoint globalPos);
	void endSelection();
	// Selection navigation (edit mode): next/previous in widget order, or the
	// nearest widget in a direction, or the next widget below the cursor.
	void selectNextWidget(bool forward);
	void selectInDirection(int dx, int dy);
	void selectThroughWidgets(QPoint globalPos);
	QSize getUsedSize();
	void adjustLayoutSize();
	void adjustWidgetSize();
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
    void moveSelected(int horiz, int vert, int grid=1);
	void undo();
	void redo();
    void reloadWidgets();

	// Alignment
	void alignLeft();
	void alignRight();
	void alignTop();
	void alignBottom();
	void sendToBack();
    void sendToFront();
	void distributeHorizontal();
	void distributeVertical();
	void alignCenterVertical();
	void alignCenterHorizontal();

	void markHistory();
	// Like markHistory(), but records that the state was reached by changing
	// widget geometry only (move/resize). Undo/redo can then restore the
	// positions in place instead of destroying and rebuilding the whole panel.
	void markHistoryGeometry();
	void createEditFrame(QuteWidget* widget);

	void widgetChanged(QuteWidget* widget = 0);
	void widgetPropertyApplied(QuteWidget* widget, const QString &property); // Focused update for a runtime property change (no full widgetChanged)
	void deleteWidget(QuteWidget *widget);

	void newValue(QPair<QString, double> channelValue);
	void newValue(QPair<QString, QString> channelValue);
	void queueEvent(QString eventLine);

    void processUpdateCurve(Curve *curve);
	// Messages
	void appendMessage(QString message);
	void appendMessage(QString message, int role);
	


protected:
	virtual void mousePressEvent(QMouseEvent *event);
	virtual void mouseMoveEvent(QMouseEvent *event);
	virtual void mouseReleaseEvent(QMouseEvent *event);
	virtual void keyPressEvent(QKeyEvent *event);
	virtual void keyReleaseEvent(QKeyEvent *event);
	virtual bool focusNextPrevChild(bool next) override;
	virtual void contextMenuEvent(QContextMenuEvent *event);
	virtual bool eventFilter(QObject *watched, QEvent *event) override;
	void setHoveredWidget(QuteWidget *widget);
	QuteWidget *hoveredWidgetFor(QObject *watched) const;
    virtual void closeEvent(QCloseEvent *event);
	QRubberBand *selectionFrame;
	int startx, starty;
	QList<QFrame *> m_channelHighlightFrames;
	QString m_channelHighlightChannel;
	bool m_channelHighlightActive = false;
	bool m_channelHighlightMouseInside = false;

private:

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
	bool m_trackMouse;
	bool m_openProperties; // Open widget properties when creating widgets
	bool m_enableEdit; // Enable editing and properties dialog
	bool m_tooltips;  // Show widget tooltips
	int mouseX, mouseY, mouseRelX, mouseRelY, mouseBut1, mouseBut2;
	int xOffset, yOffset;
    int m_updateRate;
	QuteWidget *m_hoveredWidget = nullptr;

	// For the properties dialog - they store the configuration data for the widget panel
	QPoint currentPosition;  //TODO use proper variables instead of storing data in the widgets...
	QCheckBox *bgCheckBox;
	QPushButton *bgButton;
	int closing; // to control timer when destroying this object
    // XXXX: flag to control updateData
    bool m_updating;

	// One undo/redo state. Besides the serialized panel, each entry stores the
	// geometry of every widget at that state plus whether the transition into it
	// only changed widget geometry (move/resize). Geometry-only states are
	// restored by moving widgets in place, avoiding a destructive reload.
	struct HistoryEntry {
		QString xml;
		bool geometryOnly = false;
		QHash<QString, QRect> geometry; // widget uuid -> geometry
	};
	QVector<HistoryEntry> m_history;  // Undo/ Redo history
	int m_historyIndex; // Current point in history
	void markHistoryInternal(bool geometryOnly);
	QHash<QString, QRect> currentWidgetGeometry();
	void applyHistoryGeometry(const QHash<QString, QRect> &geometry);
	// Apply a history entry: geometry-only states move widgets in place,
	// structural changes add/remove only the affected widgets, anything else
	// falls back to a full reload.
	void applyHistoryEntry(int targetIndex, bool geometryOnly);
	bool tryApplyStructuralChange(int targetIndex);
	bool m_modified;
	bool m_editMode;
	bool m_drawingEnabled = true;
	//    QString m_clipboard;
    // Whether contained in another widget (scrollbar in widget panel or widget panel)
    bool m_contained;

	QVector<WidgetPreset> presets;
	int m_currentPreset; // If -1 no current preset

	QList<RegisteredController> registeredControllers;

	// Contained Widgets
	QVector<QuteWidget *> m_widgets;
	// Per-file map of user-defined widget Name -> widget. A Name is unique within
	// the file (empty names are not stored). Unlike a channel, which can be shared
	// by several widgets, the Name identifies exactly one widget and is used only
	// to address that widget directly, via outvalue "<name>/<property>", <value>.
	QHash<QString, QuteWidget *> m_widgetNameToWidget;
    QVector<FrameWidget *> editWidgets;

	// Widget fonts found while loading that are neither bundled nor known
	// equivalents (raw -> replacement). Reported once per load, then cleared.
	QMap<QString, QString> m_unknownWidgetFonts;

	// Deferred outvalue updates (Csound performance thread -> GUI thread)
	static const unsigned CSQT_MAX_CHANNEL_NAME = 256;
	static const unsigned CSQT_MAX_STRING_VALUE = 4096;
	struct OutputValueUpdate {
		char channelName[CSQT_MAX_CHANNEL_NAME];
		double value;
	};
	struct OutputStringUpdate {
		char channelName[CSQT_MAX_CHANNEL_NAME];
		char value[CSQT_MAX_STRING_VALUE];
	};
	CsqtSpscQueue<OutputValueUpdate, 256> m_outputValueQueue;
	CsqtSpscQueue<OutputStringUpdate, 32> m_outputStringQueue;
	void processCsoundUpdates(); // GUI thread: drain the queues into newValue()
	// These vectors must be used with care since they are not reentrant and will
	// cause problems when accessed simultaneously
	// They are pointers to widgets already in widgets vector
	// TODO check where these are accessed for problems
	QVector<QuteConsole *> consoleWidgets;
	QVector<QuteGraph *> graphWidgets;
	QVector<QuteScope *> scopeWidgets;
	QVector<QuteWaveform *> waveformWidgets;
	int m_activeWidgets; // Keeps a number of widgets that can be currently accessed by value callbacks (e.g. set to 0 during paste). This is done to avoid locking the callbacks, which are called from a realtime thread

	// Lock-free snapshot read by the Csound performance thread's input channel
	// callbacks (getValueForChannel/getStringForChannel). Instead of touching
	// m_widgets / channelNameToWidgets directly - which the GUI thread mutates
	// and whose widgets it may delete during undo/redo/reload - the realtime
	// callbacks read this immutable snapshot. A new snapshot is published
	// whenever the widget set changes; the previous one, and the widgets it
	// points to, are kept alive in the "retired" lists until
	// pruneRetiredWidgets() runs, which only happens when no performance is
	// running. This makes widget teardown safe with respect to the realtime thread.
	struct ChannelSnapshot {
		QHash<QString, QList<QuteWidget *>> channelNameToWidgets;
		QVector<QuteWidget *> widgets;
		int activeWidgets = 0;
	};
	QAtomicPointer<ChannelSnapshot> m_channelSnapshot; // current snapshot (owned here)
	QList<ChannelSnapshot *> m_retiredSnapshots;       // superseded snapshots
	QList<QuteWidget *> m_retiredWidgets;              // widgets removed from the panel
	QList<FrameWidget *> m_retiredFrames;              // their edit frames
	bool m_loadingWidgets;                             // suppress snapshot publishing while rebuilding

	void publishChannelSnapshotLocked();               // widgetsMutex must be held
	void retireWidgetLocked(QuteWidget *widget);       // widgetsMutex must be held
	void retireFrameLocked(FrameWidget *frame);        // widgetsMutex must be held
	void pruneRetiredWidgets();                        // frees retired widgets/frames/snapshots

	// Runtime (not serialized) widget state, used to keep instruments and
	// display widgets alive across a full reload triggered by undo/redo.
	struct RuntimeState {
		double value = 0.0;
		double value2 = 0.0;
		QString stringValue;
	};
	QHash<QString, RuntimeState> captureRuntimeState();                 // uuid -> state
	void restoreRuntimeState(const QHash<QString, RuntimeState> &state);

	int parseXmlNode(QDomNode node);
	QString createSlider(int x, int y, int width, int height, const QString &channel, double minimum, double maximum, double value);
	QString createText(int x, int y, int width, int height, const QString &textType, const QString &channel, const QString &alignment, const QString &font, int fontSize, const QColor &fgColor, const QColor &bgColor, bool bgMode, const QString &borderMode, const QString &labelText);
	QString createScrollNumber(int x, int y, int width, int height, const QString &channel, const QString &alignment, const QString &font, int fontSize, const QColor &fgColor, const QColor &bgColor, bool bgMode, const QString &borderMode, double resolution, double value);
	QString createLineEdit(int x, int y, int width, int height, const QString &channel, const QString &alignment, const QString &font, int fontSize, const QColor &fgColor, const QColor &bgColor, bool bgMode, const QString &borderMode, const QString &labelText);
	QString createSpinBox(int x, int y, int width, int height, const QString &channel, const QString &alignment, const QString &font, int fontSize, const QColor &fgColor, const QColor &bgColor, bool bgMode, const QString &borderMode, double resolution, double value);
	QString createButton(int x, int y, int width, int height, const QString &channel, const QString &buttonType, double pressedValue, const QString &text, const QString &image, const QString &eventLine);
	QString createKnob(int x, int y, int width, int height, const QString &channel, double minimum, double maximum, double resolution, double value);
	QString createCheckBox(int x, int y, int width, int height, const QString &channel, bool checked);
	QString createMenu(int x, int y, int width, int height, const QString &channel, const QString &items, int selectedIndex);
	QString createMeter(int x, int y, int width, int height, const QString &channel, const QString &channel2, const QColor &color, const QString &meterType, double xValue, double yValue, int pointSize, int fadeSpeed);
	QString createConsole(int x, int y, int width, int height);
	QString createGraph(int x, int y, int width, int height);
	QString createScope(int x, int y, int width, int height, const QString &scopeType, double zoom, int channels);
    QString createTableDisplay(int x, int y, int width, int height);
    QString createWaveform(int x, int y, int width, int height);
    QString createVUMeter(int x, int y, int width, int height);


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

    QHash<QString, QuteWidgetType> m_widgetNameToType;

private slots:
	void updateData();
	void widgetSelected(QuteWidget *widget);
	void widgetUnselected(QuteWidget *widget);

signals:
	void selection(QRect area);
	void keyPressed(int key);
	void keyReleased(int key);
	void changed(); // Should be triggered whenever widgets change, to let main document know
	void registerScope(QuteScope *scope);
	void registerGraph(QuteGraph *graph);
	void registerButton(QuteButton *button);
    void requestCsoundUserData(QuteWidget *widget);
    void queueEventSignal(QString eventLine);
	void widgetSelectedSignal(QuteWidget *widget);
	void widgetUnselectedSignal(QuteWidget *widget);
	void showMidiLearn(QuteWidget *);
	void logMessage(const QString &message, int role); // User facing message from a widget, forwarded to the Csound console (role: MessageRole)
    void windowStatus(bool);
	void widgetHovered(QuteWidget *widget);
	void widgetChannelsHighlightRequested(const QStringList &channels);
	void editingEscapePressed();
	void editModeChanged(bool active);
	//    void setWidgetClipboardSignal(QString text);  // To propagate clipboard for sharing between pages
};

#endif // WIDGETLAYOUT_H
