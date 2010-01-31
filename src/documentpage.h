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

//TODO when refactoring is done, organize the methods in the correct order

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
    QString getMacWidgetsText();
    QString getMacPresetsText();
    QString getMacOptionsText();
    QString getMacOptions(QString option);
    QString wordUnderCursor();
    QRect getWidgetPanelGeometry();
//    void getToIn();
//    void inToGet();
//    void updateCsladspaText(QString text);
    QString getFilePath();
    QStringList getScheduledEvents(unsigned long ksmpscount);
    void setModified(bool mod);
    bool isModified();
    bool usesFltk();
    void updateCsLadspaText();
    void focusWidgets();

    void copy();  // This actions are passed here for distribution
    void cut();  // Can it be done better?
    void paste();
    void undo();
    void redo();

    DocumentView *getView();  // Needed to pass view for placing it as tab widget in main application
    WidgetLayout *getWidgetLayout();  // Needed to pass for placing in widget dock panel

    // Document view properties and actions
    void setTextFont(QFont font);
    void setTabStopWidth(int tabWidth);
    void setLineWrapMode(QTextEdit::LineWrapMode wrapLines);
    void setColorVariables(bool colorVariables);
    void setOpcodeNameList(QStringList opcodeNameList);
    void print(QPrinter *printer);
//    void setEditAct(QAction *editAct);

    // Widget Layout properties
    void showWidgetTooltips(bool visible);
    void setKeyRepeatMode(bool keyRepeat);  // Also for console widget

    //Engine Properties
//    void setCsoundOptions(CsoundOptions &options);

    // Internal Options setters
    void setConsoleBufferSize(int size);
    void setWidgetEnabled(bool enabled);
    void setRunThreaded(bool thread);
    void useInvalue(bool use);

    // Member public variables
    QString fileName;
    QString companionFile;
    bool askForFile;
    bool readOnly; // Used for manual files and internal examples

    QVector<QString> widgetHistory;  // Undo/ Redo history
    int widgetHistoryIndex; // Current point in history

    // Actions from parent for passing to children
//    QAction *runAct;
//    QAction *copyAct;
//    QAction *cutAct;
//    QAction *pasteAct;
    // Actions from widget layout
//    QAction *editAct;

  public slots:
    int play(CsoundOptions *options);
    void pause();
    void stop();
    void render(CsoundOptions *options);
    void record(int mode); // 0=16 bit int  1=32 bit int  2=float

    void setMacWidgetsText(QString widgetText);
    void setMacOptionsText(QString text);
    void setMacOption(QString option, QString newValue);
    void setWidgetPanelPosition(QPoint position);
    void setWidgetPanelSize(QSize size);

    //Passed directly to widget layout
    void setWidgetEditMode(bool active);
    void duplicateWidgets();

    // Passed directly to document view
    void jumpToLine(int line);

//    void opcodeFromMenu();
    void newLiveEventFrame(QString text = QString());
    LiveEventFrame * createLiveEventFrame(QString text = QString());
    void deleteLiveEventFrame(LiveEventFrame *frame);
    void showLiveEventFrames(bool visible);

  protected:
    virtual void keyPressEvent(QKeyEvent *event);
//    virtual void contextMenuEvent(QContextMenuEvent *event);
//    virtual void closeEvent(QCloseEvent *event);

  private:
    QStringList macOptions;
    QString macPresets;
//    QString macGUI;
    QDomElement widgetsXml;

    WidgetLayout * m_widgetLayout;
    DocumentView *m_view;
    CsoundEngine *m_csEngine;
    ConsoleWidget *m_console;  // TODO have a single console widget which is duplicated across all places! Is it possible? due to parenting issues
    QVector<LiveEventFrame *> m_liveFrames;

    OpEntryParser *m_opcodeTree;


    // Options
    bool saveLiveEvents;
//    bool saveChanges;

  private slots:
    void textChanged();
    void liveEventFrameClosed();
//    void dispatchQueues();
//    void queueMessage(QString message);
    void queueEvent(QString line, int delay = 0);
//    void clearMessageQueue();
//     void moved();

  signals:
    void currentLineChanged(int);
    void currentTextUpdated();
    void doCopy();
    void doCut();
    void doPaste();
//    void registerLiveEvent(QWidget *e);
    void setCurrentAudioFile(QString name);
    void liveEventsVisible(bool);  // To change the action in the main window
};

#endif
