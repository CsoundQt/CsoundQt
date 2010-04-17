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

#ifndef DOCUMENTPAGE_H
#define DOCUMENTPAGE_H

#include <QWidget>
#include <QTextEdit>
#include <QDomElement>
#include <QStack>

#include "types.h"
#include "csoundoptions.h"

class OpEntryParser;
class DocumentView;
class WidgetLayout;
class LiveEventFrame;
class CsoundEngine;
class ConsoleWidget;
class SndfileHandle;

class Curve;
class QuteButton; // For registering buttons with main application

//TODO when refactoring is done, organize the methods in the nice order

class DocumentPage : public QObject
{
  Q_OBJECT
  public:
    DocumentPage(QWidget *parent, OpEntryParser *opcodeTree);
    ~DocumentPage();

    int setTextString(QString text, bool autoCreateMacCsoundSections = true);
    QString getFullText();
    QString getBasicText();
    QString getOptionsText();
    QString getDotText();
    QString getWidgetsText();
    QString getPresetsText();
    QString getMacWidgetsText();
    QString getMacPresetsText();
    QString getMacOptionsText();
    QString getMacOptions(QString option);
    QString getLiveEventsText();
    QString wordUnderCursor();
    QRect getWidgetPanelGeometry();

    int lineCount(bool countExtras = false);
    int characterCount(bool countExtras = false);
    int instrumentCount();
    int udoCount();
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
    void setFileName(QString name);
    void setCompanionFileName(QString name);

    void copy();
    void cut();
    void paste();
    void undo();
    void redo();

    DocumentView *getView();  // Needed to pass view for placing it as tab widget in main application
    WidgetLayout *getWidgetLayout();  // Needed to pass for placing in widget dock panel
    ConsoleWidget *getConsole();  // Needed to pass for placing in console dock panel

    // Document view properties and actions
    void setTextFont(QFont font);
    void setTabStopWidth(int tabWidth);
    void setLineWrapMode(QTextEdit::LineWrapMode wrapLines);
    void setColorVariables(bool colorVariables);
    void setOpcodeNameList(QStringList opcodeNameList);
    void setAutoComplete(bool autoComplete);
    void print(QPrinter *printer);
    void findReplace();
    void findString();  // For find again
    void getToIn();
    void inToGet();

    // Widget Layout properties
    void showWidgetTooltips(bool visible);
    void setKeyRepeatMode(bool keyRepeat);  // Also for console widget
    void passWidgetClipboard(QString text);

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

    // Member public variables
    bool askForFile;
    bool readOnly; // Used for manual files and internal examples

    QVector<QString> widgetHistory;  // Undo/ Redo history
    int widgetHistoryIndex; // Current point in history

  public slots:
    int play(CsoundOptions *options);
    void pause();
    void stop();
    void perfEnded();
    int record(int mode); // 0=16 bit int  1=32 bit int  2=float
    void stopRecording();
    void playParent(); // Triggered from button, ask parent for options
    void renderParent();
    int runPython();  // Called when file is a python file

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
    void autoComplete();

    void newLiveEventFrame(QString text = QString());
    LiveEventFrame * createLiveEventFrame(QString text = QString());
    void deleteLiveEventFrame(LiveEventFrame *frame);
    void showLiveEventFrames(bool visible);

    void registerButton(QuteButton *button);

  protected:
//    virtual void keyPressEvent(QKeyEvent *event);
//    virtual void contextMenuEvent(QContextMenuEvent *event);
//    virtual void closeEvent(QCloseEvent *event);

  private:
    CsoundOptions getParentOptions();
    void deleteAllLiveEvents();

    QStringList m_macOptions;
    QString m_macPresets;
    QString m_macGUI;
    QDomElement widgetsXml;
    bool m_pythonRunning;

    WidgetLayout * m_widgetLayout;
    DocumentView *m_view;
    CsoundEngine *m_csEngine;
    ConsoleWidget *m_console;
    QVector<LiveEventFrame *> m_liveFrames;

    OpEntryParser *m_opcodeTree;

    QString fileName;
    QString companionFile;

    // Options
    bool saveLiveEvents;
    bool saveOldFormat;

  private slots:
    void textChanged();
    void liveEventFrameClosed();
    void opcodeSyntax(QString message);
    void setWidgetClipboard(QString text);
    void queueEvent(QString line, int delay = 0);

  signals:
    void currentLineChanged(int);
    void currentTextUpdated();  // To let inspector know it must update
    void setCurrentAudioFile(QString name);
    void liveEventsVisible(bool);  // To change the action in the main window
    void modified();  // Triggered whenever the children change
    void stopSignal(); // To tell main application that running has stopped
    void opcodeSyntaxSignal(QString message); // Propagated from view
    void setWidgetClipboardSignal(QString text);
};

#endif
