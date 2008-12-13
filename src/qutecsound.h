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


#ifndef QUTECSOUND_H
#define QUTECSOUND_H

#define QUTECSOUND_VERSION "0.3.9"

#include <QtGui>
#include <csound.h>

#include "types.h"

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

class qutecsound;

struct CsoundUserData{
  /*result of csoundCompile()*/
  int result;
  /*instance of csound*/
  CSOUND *csound;
  /*performance status*/
  bool PERF_STATUS; //0= stopped 1=running
//   bool realtime;
  /*pass main application to check widgets*/
  qutecsound *qcs;
};


class qutecsound:public QMainWindow
{
  Q_OBJECT

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
    void *perfMutex;
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
    QStringList runCsound(QStringList flags); //returns csound messages

    QVector<QString> channelNames;
    QVector<double> values;
    QVector<QString> stringValues;

  public slots:
    void changeFont();
    void changePage(int index);
    void updateWidgets();

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
    bool save();
    bool saveAs();
    bool closeTab();
    void findReplace();
    void join();
//     void edit(bool active);
    void play(bool realtime=true);
    void stop();
    void render();
    void openExternalEditor();
    void openExternalPlayer();
    void setHelpEntry();
    void openManualExample(QString fileName);
    void openExternalBrowser();
    void utilitiesDialogOpen();
    void about();
    void documentWasModified();
    void syntaxCheck();
    void autoComplete();
    void configure();
    void applySettings(int result = 0);
    void checkSelection();
    void runUtility(QString flags);
    void dispatchQueues();

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

    CSOUND *csound;
#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
    CsoundPerformanceThread *perfThread;
#else
    void* ThreadID;
#endif
    CsoundUserData* ud;

    QHash<QString, double> outValueQueue;
    QHash<QString, QString> outStringQueue;
    QStringList messageQueue;
    QTimer *queueTimer;
    QTabWidget *documentTabs;
    QVector<DocumentPage *> documentPages;
    //TODO remove this variable? or make it DocumentPage
    DocumentPage *textEdit;
    OpEntryParser *opcodeTree;
    Options *m_options;
    DockConsole *m_console;
    Highlighter *m_highlighter;
    DockHelp *helpPanel;
    WidgetPanel *widgetPanel;

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
    QAction *exitAct;
    QList<QAction *> openRecentAct;
    QAction *undoAct;
    QAction *redoAct;
    QAction *cutAct;
    QAction *copyAct;
    QAction *pasteAct;
    QAction *joinAct;
    QAction *findAct;
    QAction *autoCompleteAct;
    QAction *configureAct;
    QAction *editAct;
    QAction *playAct;
    QAction *stopAct;
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
    ConfigLists *m_configlists;
    QStringList recentFiles;
    QStringList lastFiles;
    QStringList m_deviceMessages; //stores messages from csound for device discovery

    UtilitiesDialog *utilitiesDialog;

    QIcon modIcon;

#ifdef MACOSX
    MenuBarHandle menuBarHandle;
#endif
};

#endif
