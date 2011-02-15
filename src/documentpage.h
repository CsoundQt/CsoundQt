/*
    Copyright (C) 2008-2010 Andres Cabrera
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

#ifndef DOCUMENTPAGE_H
#define DOCUMENTPAGE_H

#include <QTextEdit>
#include <QDomElement>
#include <QStack>
#include <QDockWidget>
#include <vector>

#include "basedocument.h"

class OpEntryParser;
class DocumentView;
class LiveEventFrame;
class EventSheet;
class LiveEventControl;
class SndfileHandle;


class DocumentPage : public BaseDocument
{
  Q_OBJECT
  public:
    DocumentPage(QWidget *parent, OpEntryParser *opcodeTree);
    ~DocumentPage();

    void setFileName(QString name);
    virtual void setTextString(QString &text);
    int setTextString(QString text, bool autoCreateMacCsoundSections);
    void setCompanionFileName(QString name);
    void setEditorFocus();
    void insertText(QString text, int section = -1);
    void setFullText(QString text);
    void setBasicText(QString text);
    void setOrc(QString text);
    void setSco(QString text);
    void setLadspaText(QString text);

    QString getFullText();
    QString getBasicText();
    QString getSelectedText(int section = -1);
    QString getOrc();
    QString getSco();
    QString getOptionsText();
    QString getDotText();
    QString getWidgetsText();
    QString getPresetsText();
    QString getMacWidgetsText();
    QString getMacPresetsText();
    QString getMacOptionsText();
    QString getMacOptions(QString option);
    int getViewMode();
    QString getLiveEventsText();
    QString wordUnderCursor();
    QRect getWidgetPanelGeometry();

    void setLineEnding(int lineEndingMode);

    void setChannelValue(QString channel, double value);
    double getChannelValue(QString channel);
    void setChannelString(QString channel, QString value);
    QString getChannelString(QString channel);
    void setWidgetProperty(QString channel, QString property, QVariant value);
    QVariant getWidgetProperty(QString channel, QString property);

    QString createNewLabel(int x = -1, int y = -1);
    QString createNewDisplay(int x = -1, int y = -1);
    QString createNewScrollNumber(int x = -1, int y = -1);
    QString createNewLineEdit(int x = -1, int y = -1);
    QString createNewSpinBox(int x = -1, int y = -1);
    QString createNewSlider(int x = -1, int y = -1);
    QString createNewButton(int x = -1, int y = -1);
    QString createNewKnob(int x = -1, int y = -1);
    QString createNewCheckBox(int x = -1, int y = -1);
    QString createNewMenu(int x = -1, int y = -1);
    QString createNewMeter(int x = -1, int y = -1);
    QString createNewConsole(int x = -1, int y = -1);
    QString createNewGraph(int x = -1, int y = -1);
    QString createNewScope(int x = -1, int y = -1);

    EventSheet* getSheet(int sheetIndex);
    EventSheet* getSheet(QString sheetName);

    int lineCount(bool countExtras = false);
    int characterCount(bool countExtras = false);
    int instrumentCount();
    int udoCount();
    int widgetCount();
    QString embeddedFiles();
    QString getFilePath();
    QStringList getScheduledEvents(unsigned long ksmpscount);
    bool isModified();
    bool isRunning();
    bool isRecording();
    bool usesFltk();
    void updateCsLadspaText();
    void focusWidgets();
    QString getFileName();
    QString getCompanionFileName();

    // Edition- are routed to section with focus
    void copy();
    void cut();
    void paste();
    void undo();
    void redo();

    // Get internal components
    DocumentView *getView();  // Needed to pass view for placing it as tab widget in main application
    CsoundEngine *getEngine(); // Needed to pass to python interpreter
//    void *getCsound();

    // Document view properties and actions
    void setTextFont(QFont font);
    void setTabStopWidth(int tabWidth);
    void setLineWrapMode(QTextEdit::LineWrapMode wrapLines);
    void setColorVariables(bool colorVariables);
//    void setOpcodeNameList(QStringList opcodeNameList);
    void setAutoComplete(bool autoComplete);
    QString getActiveSection();
    QString getActiveText();
    void print(QPrinter *printer);
    void findReplace();
    void findString();  // For find again
    void getToIn();
    void inToGet();

    // Widget Layout properties
    void showWidgetTooltips(bool visible);
    void setKeyRepeatMode(bool keyRepeat);  // Also for console widget
    void setOpenProperties(bool open);
    void setFontOffset(double offset);
    void setFontScaling(double offset);
//    void passWidgetClipboard(QString text);

    // Console properties
    void setConsoleFont(QFont font);
    void setConsoleColors(QColor fontColor, QColor bgColor);

    //Engine Properties
    void setInitialDir(QString initialDir);

    // Event Sheet Properties
    void setScriptDirectory(QString dir);
    void setDebugLiveEvents(bool debug);

    // Internal Options setters
    void setConsoleBufferSize(int size);
    void setWidgetEnabled(bool enabled);
    void setRunThreaded(bool thread);
    void useInvalue(bool use);
    void useOldFormat(bool use);
    void setPythonExecutable(QString pythonExec);

    virtual void registerButton(QuteButton *button);

    // Member public variables
    bool askForFile;
    bool readOnly; // Used for manual files and internal examples

    QVector<QString> widgetHistory;  // Undo/ Redo history
    int widgetHistoryIndex; // Current point in history

  public slots:
    virtual int play(CsoundOptions *options);
    void stop();
    int record(int format);
    void perfEnded();
    int runPython();  // Called when file is a python file

    void showWidgets(bool show = true);
    void hideWidgets();
//    void detachWidgets();
//    void attachWidgets(QDockWidget *panel);

    void applyMacOptions(QStringList options);
    void setMacOption(QString option, QString newValue);
    void setWidgetPanelPosition(QPoint position);
    void setWidgetPanelSize(QSize size);
    void setModified(bool mod = true);

    //Passed directly to widget layout
    void setWidgetEditMode(bool active);
    void duplicateWidgets();

    // Passed directly to document view
    void jumpToLine(int line);
    void comment();
    void uncomment();
    void indent();
    void unindent();
    void killLine();
    void killToEnd();
    void autoComplete();
    void setViewMode(int mode);

    // Slots for live events
    void newLiveEventPanel(QString text = QString());
    LiveEventFrame * createLiveEventPanel(QString text = QString());
    void deleteLiveEventPanel(LiveEventFrame *frame);
    void showLiveEventPanels(bool visible);
    void stopAllSlot();
    void newPanelSlot();
    void playPanelSlot(int index);
    void loopPanelSlot(int index, bool loop);
    void stopPanelSlot(int index);
    void setPanelVisibleSlot(int index, bool visible);
    void setPanelSyncSlot(int index, int mode);
    void setPanelNameSlot(int index, QString name);
    void setPanelTempoSlot(int index, double tempo);
    void setPanelLoopLengthSlot(int index, double length);
    void setPanelLoopRangeSlot(int index, double start, double end);

  protected:
//    virtual void keyPressEvent(QKeyEvent *event);
//    virtual void contextMenuEvent(QContextMenuEvent *event);
//    virtual void closeEvent(QCloseEvent *event);

  private:
    virtual void init(QWidget *parent,OpEntryParser *opcodeTree);
    CsoundOptions getParentOptions();
    void deleteAllLiveEvents();
    virtual WidgetLayout* newWidgetLayout();

    QString fileName;
    QString companionFile;
    QStringList m_macOptions;
    QString m_macPresets;
    QString m_macGUI;
    bool m_pythonRunning;

    QString m_pythonExecutable;

    QList<LiveEventFrame *> m_liveFrames;
    LiveEventControl *m_liveEventControl;

    DocumentView *m_view;

    // Options
    bool saveLiveEvents;
    bool saveOldFormat;
    int m_lineEnding;

  private slots:
    void textChanged();
    void liveEventControlClosed();
    void renamePanel(LiveEventFrame *panel,QString newName);

    void setPanelLoopRange(LiveEventFrame *panel, double start, double end);
    void setPanelLoopLength(LiveEventFrame *panel, double length);
    void setPanelTempo(LiveEventFrame *panel, double tempo);

    void opcodeSyntax(QString message);
//    void setWidgetClipboard(QString text);
    void evaluatePython(QString code);

  signals:
    void currentLineChanged(int);
    void currentTextUpdated();  // To let inspector know it must update
    void setCurrentAudioFile(QString name);
    void liveEventsVisible(bool);  // To change the action in the main window
    void modified();  // Triggered whenever the children change
    void stopSignal(); // To tell main application that running has stopped
    void opcodeSyntaxSignal(QString message); // Propagated from view
    void setWidgetClipboardSignal(QString text);
    void evaluatePythonSignal(QString code);
};

#endif
