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

#ifndef QUTECSOUND_H
#define QUTECSOUND_H

#define QUTECSOUND_VERSION "0.4.5.2"

#include <QtGui>

#include "types.h"

#ifdef USE_LIBSNDFILE
#include    <sndfile.hh>
#endif

#ifdef MACOSX_PRE_SNOW
// Needed to be able to grab menus back from FLTK
#include <Carbon/Carbon.h>
#endif

#include <csound.hpp>
#include <csPerfThread.hpp>

// Csound 5.10 needs to be destroyed for opcodes like ficlose to flush the output

#define QUTECSOUND_DESTROY_CSOUND

class QAction;
class QMenu;
class QTextEdit;

class DockHelp;
class WidgetPanel;
class Inspector;
class DockConsole;
class OpEntryParser;
class Options;
class ConfigLists;
class DocumentPage;
class UtilitiesDialog;
class Curve;
class GraphicWindow;
class KeyboardShortcuts;
class EventDispatcher;

class qutecsound:public QMainWindow
{
  Q_OBJECT

    friend class WidgetPanel; //to pass ud
    friend class FileOpenEater; //to pass curPage
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
    static void outputValueCallback (CSOUND *csound,
                                    const char *channelName,
                                    MYFLT value);
    static void inputValueCallback (CSOUND *csound,
                                   const char *channelName,
                                   MYFLT *value);
//     static void ioCallback (CSOUND *csound,
//                             const char *channelName,
//                             MYFLT *value,
//                             int channelType);
    static int keyEventCallback(void *userData,
                                void *p,
                                unsigned int type);

    static void  csThread(void *data);  //Thread function
    QMutex perfMutex;
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
    int popKeyPressEvent(); // return ASCII code of key press event for Csound or -1 if no event
    int popKeyReleaseEvent(); // return ASCII code of key release event for Csound -1 if no event

    QVector<QString> channelNames;
    QVector<double> values;
    QVector<QString> stringValues;
    QVector<double> mouseValues;
    OpEntryParser *opcodeTree;
    RingBuffer audioOutputBuffer;

  public slots:
    bool loadFile(QString fileName, bool runNow = false);
    void runCsound(bool realtime=true);
    void play();
    void pause();
    void stop();
    void stopCsound();
    void render();
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
    void findString(QString query = QString());
    void registerLiveEvent(QWidget *e);

  protected:
    virtual void closeEvent(QCloseEvent *event);

  private slots:
    void newFile();
    void open();
    void reload();
    void openRecent();
    void openRecent(QString fileName);
    void createCodeGraph();
    void closeGraph();
    bool save();
    bool saveAs();
    bool saveNoWidgets();
    void copy();
    void cut();
    void paste();
    void undo();
    void redo();
    void controlD();
    void del();
    bool closeTab();
    void print();
    void findReplace();
    void join();
    void getToIn();
    void inToGet();
    void putCsladspaText();
    void exportCabbage();
    void openExternalEditor();
    void openExternalPlayer();
    void setHelpEntry();
    void openManualExample(QString fileName);
    void openExternalBrowser();
    void openQuickRef();
    void openShortcutDialog();
    void utilitiesDialogOpen();
    void about();
    void documentWasModified();
    void syntaxCheck();
    void autoComplete();
    void configure();
    void applySettings();
    void checkSelection();
    void runUtility(QString flags);
    void dispatchQueues();
//     void widgetDockStateChanged(bool topLevel);
//     void widgetDockLocationChanged(Qt::DockWidgetArea area);
    void showLineNumber(int lineNumber);
    void updateGUI();
    void setDefaultKeyboardShortcuts();
    void keyPressForCsound(QString key);
    void keyReleaseForCsound(QString key);

  private:
    void createActions();
    void setKeyboardShortcuts();
    void connectActions();
    void createMenus();
    void fillFileMenu();
    void createToolBars();
    void createStatusBar();
    void readSettings();
    void writeSettings();
    int execute(QString executable, QString options);
    bool maybeSave();
    void loadCompanionFile(const QString &fileName);
    bool saveFile(const QString &fileName, bool saveWidgets = true);
    void setCurrentFile(const QString &fileName);
    QString strippedName(const QString &fullFileName);
    QString generateScript(bool realtime = true, QString tempFileName = "");
    void getCompanionFileName();
    void setWidgetPanelGeometry();
    int isOpen(QString fileName);
    void markErrorLine();
    QString getSaveFileName();
    void createQuickRefPdf();

    CSOUND *csound;
    CsoundPerformanceThread *perfThread;
    CsoundUserData* ud;
    MYFLT *pFields; // array of pfields for score and rt events

//     QHash<QString, double> outValueQueue;
    QHash<QString, double> inValueQueue;
    QHash<QString, QString> outStringQueue;
    QStack<Curve *> newCurveBuffer;
    QVector<WINDAT *> curveBuffer;
    QStringList messageQueue;
    QStringList keyPressBuffer; // protected by keyMutex
    QStringList keyReleaseBuffer; // protected by keyMutex
    QTimer *queueTimer;
    int refreshTime;

    QTabWidget *documentTabs;
    GraphicWindow *m_graphic;
    QVector<DocumentPage *> documentPages;
    DocumentPage *textEdit;
    Options *m_options;
    DockConsole *m_console;
    DockHelp *helpPanel;
    WidgetPanel *widgetPanel;
    Inspector *m_inspector;
    QToolButton *closeTabButton;

    QMutex stringValueMutex;
    QMutex messageMutex;
    QMutex keyMutex; // For keys pressed in the console to pass to Csound
    QStringList tempScriptFiles; //Remember temp files to delete them later
    QVector<QAction *> m_keyActions; //Actions which have keyboard shortcuts

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
    QAction *saveNoWidgetsAct;
    QAction *closeTabAct;
    QAction *printAct;
    QAction *createCodeGraphAct;
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
    QAction *findAgainAct;
    QAction *autoCompleteAct;
    QAction *configureAct;
    QAction *setShortcutsAct;
    QAction *editAct;
    QAction *runAct;
    QAction *runTermAct;
    QAction *stopAct;
    QAction *recAct;
    QAction *renderAct;
    QAction *externalEditorAct;
    QAction *externalPlayerAct;
    QAction *showHelpAct;
    QAction *showManualAct;
    QAction *showGenAct;
    QAction *showOverviewAct;
    QAction *showConsoleAct;
    QAction *setHelpEntryAct;
    QAction *browseBackAct;
    QAction *browseForwardAct;
    QAction *externalBrowserAct;
    QAction *openQuickRefAct;
    QAction *showUtilitiesAct;
    QAction *showWidgetsAct;
    QAction *showInspectorAct;
    QAction *showLiveEventsAct;
    QAction *commentAct;
    QAction *uncommentAct;
    QAction *indentAct;
    QAction *unindentAct;
    QAction *aboutAct;
    QAction *aboutQtAct;

    int curPage;
    int configureTab; // Tab in last configure dialog
    QString lastUsedDir;
    QString lastFileDir;
    bool lastCaseSensitive; // These last three are for search and replace
    QString quickRefFileName;
    viewMode m_mode;
    QStringList recentFiles;
    QStringList lastFiles;
    int lastTabIndex;
    QStringList m_deviceMessages; //stores messages from csound for device discovery
    QString lastSearch;
    QString lastReplace;

    UtilitiesDialog *utilitiesDialog;
    //QTemporaryFile *quickRefFile;
    QTemporaryFile *executionFile;

    QIcon modIcon;
    QLabel *lineNumberLabel;

#ifdef USE_LIBSNDFILE
    SndfileHandle *outfile;
#endif
    QString currentAudioFile;
    long samplesWritten;

#ifdef MACOSX_PRE_SNOW
    MenuBarHandle menuBarHandle;
#endif
#ifdef QUTECSOUND_COPYPASTE
    QTextCursor m_clipboard;
    QString m_clipboardText;
#endif
};

class FileOpenEater : public QObject
{
  Q_OBJECT
  public:
    FileOpenEater() {noEvent=true; mwSet = false;}
    void setMainWindow(qutecsound *mainWindow) {m_mw = mainWindow; mwSet = true;}

    bool noEvent;
    QList<QFileOpenEvent> eventQueue;
  protected:
    bool eventFilter(QObject *obj, QEvent *event)
    {
      if (event->type() == QEvent::FileOpen) {
          noEvent=false;
          QFileOpenEvent *fileEvent = static_cast<QFileOpenEvent*>(event);
          if (mwSet == false || m_mw->curPage == -1) {
              eventQueue << *fileEvent;
          }
          else {
              m_mw->loadFile(fileEvent->file(), true);
          }
          qDebug() << "FileOpenEater::eventFilter " << fileEvent->file();
          return true;
      } else {
// standard event processing
        return QObject::eventFilter(obj, event);
      }
    }

    qutecsound *m_mw;
    bool mwSet;
};

#endif
