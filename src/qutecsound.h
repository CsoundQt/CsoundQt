/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
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


#ifndef QUTECSOUND_H
#define QUTECSOUND_H

#define QUTECSOUND_VERSION "0.4RC2"

#include <QtGui>

#include "types.h"

#ifdef USE_LIBSNDFILE
#include    <sndfile.hh>
#endif

// #include <csound.h>
#ifdef MACOSX
// Needed to be able to grab menus back from FLTK
#include <Carbon/Carbon.h>
#endif

#ifdef WIN32
// Needed for the CreateProcess function in execute()
#include <windows.h>
#endif

#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
#include <csound.hpp>
#include <csPerfThread.hpp>
#endif

// #define QUTECSOUND_DESTROY_CSOUND

class QAction;
class QMenu;
class QTextEdit;

class DockHelp;
class WidgetPanel;
class DockConsole;
class OpEntryParser;
class Options;
class Highlighter;
class ConfigLists;
class DocumentPage;
class UtilitiesDialog;
class Curve;
class GraphicWindow;

class qutecsound:public QMainWindow
{
  Q_OBJECT

  friend class WidgetPanel; //to pass ud
  public:
    qutecsound(QStringList fileNames);
    ~qutecsound();
    static void messageCallback_NoThread(CSOUND *csound,
                                         int attr,
                                         const char *fmt,
                                         va_list args);
    static void messageCallback_Thread(CSOUND *csound,
                                         int attr,
                                         const char *fmt,
                                         va_list args);
    static void messageCallback_Devices(CSOUND *csound,
                                       int attr,
                                       const char *fmt,
                                       va_list args);

    //callbacks for graph drawing based on J. Ramsdell's flcsound
    static void makeGraphCallback(CSOUND *csound, WINDAT *windat, const char *name);
    static void drawGraphCallback(CSOUND *csound, WINDAT *windat);
    static void killGraphCallback(CSOUND *csound, WINDAT *windat);
    static int exitGraphCallback(CSOUND *csound);

#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
    static void  csThread(void *data);
#else
    static uintptr_t csThread(void *data);
#endif
    QMutex perfMutex;
    static void outputValueCallback (CSOUND *csound,
                                    const char *channelName,
                                    MYFLT value);
    static void inputValueCallback (CSOUND *csound,
                                   const char *channelName,
                                   MYFLT *value);
    static void readWidgetValues(CsoundUserData *ud);
    static void writeWidgetValues(CsoundUserData *ud);
    static void processEventQueue(CsoundUserData *ud);
    void queueOutValue(QString channelName, double value);
    void queueOutString(QString channelName, QString value);
    void queueMessage(QString message);
    QStringList runCsoundInternally(QStringList flags); //returns csound messages
    void newCurve(Curve *curve);  //New graphs
    void updateCurve(WINDAT *windat); //graph updates
    int killCurves(CSOUND *csound);

    QVector<QString> channelNames;
    QVector<double> values;
    QVector<QString> stringValues;
    OpEntryParser *opcodeTree;
    RingBuffer audioOutputBuffer;

  public slots:
    void runCsound(bool realtime=true);
    void stop();
    void stopCsound();
    void record();
    void recordBuffer();
//     void selectMidiInDevice(QPoint pos);
//     void selectMidiOutDevice(QPoint pos);
//     void selectAudioInDevice(QPoint pos);
//     void selectAudioOutDevice(QPoint pos);
    void changeFont();
    void changePage(int index);
    void updateWidgets();
    void openExample();

  protected:
    void closeEvent(QCloseEvent *event);

  private slots:
    void newFile();
    void open();
    void reload();
    void openRecent0();
    void openRecent1();
    void openRecent2();
    void openRecent3();
    void openRecent4();
    void openRecent5();
    void createGraph();
    void closeGraph();
    bool save();
    bool saveAs();
    void copy();
    void cut();
    void paste();
    void undo();
    void redo();
    void controlD();
    bool closeTab();
    void findReplace();
    void join();
    void getToIn();
    void inToGet();
    void putCsladspaText();
    void exportCabbage();
    void render();
    void openExternalEditor();
    void openExternalPlayer();
    void setHelpEntry();
    void openManualExample(QString fileName);
    void openExternalBrowser();
    void utilitiesDialogOpen();
    void about();
//     void aboutExamples();
    void documentWasModified();
    void syntaxCheck();
    void autoComplete();
    void configure();
    void applySettings(int result = 0);
    void checkSelection();
    void runUtility(QString flags);
    void dispatchQueues();
    void dispatchOfflineQueues();
    void widgetDockStateChanged(bool topLevel);
    void widgetDockLocationChanged(Qt::DockWidgetArea area);

  private:
    void createActions();
    void connectActions();
    void createMenus();
    void fillFileMenu();
    void createToolBars();
    void createStatusBar();
    void readSettings();
    void writeSettings();
    int execute(QString executable, QString options);
    void configureHighlighter();
    bool maybeSave();
    QString fixLineEndings(const QString &text);
    bool loadFile(QString fileName);
    void loadCompanionFile(const QString &fileName);
    bool saveFile(const QString &fileName);
    void setCurrentFile(const QString &fileName);
    QString strippedName(const QString &fullFileName);
    QString generateScript(bool realtime = true);
    void getCompanionFileName();
    void setWidgetPanelGeometry();
    int isOpen(QString fileName);
    void markErrorLine();

    CSOUND *csound;
#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
    CsoundPerformanceThread *perfThread;
#else
    void* ThreadID;
#endif
    CsoundUserData* ud;

//     QHash<QString, double> outValueQueue;
    QHash<QString, double> inValueQueue;
    QHash<QString, QString> outStringQueue;
    QStack<Curve *> newCurveBuffer;
    QVector<WINDAT *> curveBuffer;
    QStringList messageQueue;
    QStringList exampleFiles;
    QStringList widgetFiles;
    QTimer *queueTimer;
    QTimer *offlineTimer;
    QTabWidget *documentTabs;
    GraphicWindow *m_graphic;
    QVector<DocumentPage *> documentPages;
    //TODO remove this variable? or make it DocumentPage
    DocumentPage *textEdit;
    Options *m_options;
    DockConsole *m_console;
    Highlighter *m_highlighter;
    DockHelp *helpPanel;
    WidgetPanel *widgetPanel;
    QToolButton *closeTabButton;

    QMenu *fileMenu;
    QMenu *recentMenu;
    QMenu *editMenu;
    QMenu *controlMenu;
    QMenu *viewMenu;
    QMenu *helpMenu;
    QToolBar *fileToolBar;
    QToolBar *editToolBar;
    QToolBar *controlToolBar;
    QToolBar *configureToolBar;
    QAction *newAct;
    QAction *openAct;
    QAction *reloadAct;
    QAction *saveAct;
    QAction *saveAsAct;
    QAction *closeTabAct;
    QAction *createGraphAct;
    QAction *exitAct;
    QList<QAction *> openRecentAct;
    QAction *undoAct;
    QAction *redoAct;
    QAction *cutAct;
    QAction *copyAct;
    QAction *pasteAct;
    QAction *joinAct;
    QAction *getToInAct;
    QAction *inToGetAct;
    QAction *csladspaAct;
    QAction *cabbageAct;
    QAction *findAct;
    QAction *autoCompleteAct;
    QAction *configureAct;
    QAction *editAct;
    QAction *runAct;
    QAction *runTermAct;
    QAction *stopAct;
    QAction *recAct;
    QAction *renderAct;
    QAction *externalEditorAct;
    QAction *externalPlayerAct;
    QAction *showHelpAct;
    QAction *showGenAct;
    QAction *showOverviewAct;
    QAction *showConsoleAct;
    QAction *setHelpEntryAct;
    QAction *browseBackAct;
    QAction *browseForwardAct;
    QAction *externalBrowserAct;
    QAction *showUtilitiesAct;
    QAction *showWidgetsAct;
    QAction *commentAct;
    QAction *uncommentAct;
    QAction *indentAct;
    QAction *unindentAct;
    QAction *aboutAct;
    QAction *aboutQtAct;

    int curPage;
    QString lastUsedDir;
    QString lastFileDir;
    viewMode m_mode;
//     ConfigLists *m_configlists;
    QStringList recentFiles;
    QStringList lastFiles;
    QStringList m_deviceMessages; //stores messages from csound for device discovery

    UtilitiesDialog *utilitiesDialog;

    QIcon modIcon;

#ifdef USE_LIBSNDFILE
    SndfileHandle *outfile;
#endif
    QString currentAudioFile;
    long samplesWritten;

#ifdef MACOSX
    MenuBarHandle menuBarHandle;
#endif
};

#endif
