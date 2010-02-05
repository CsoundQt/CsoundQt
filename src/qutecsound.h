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

#define QUTECSOUND_VERSION "0.5.0-pre"

#include <QtGui>

#include "types.h"

#ifdef MACOSX_PRE_SNOW
// Needed to be able to grab menus back from FLTK
#include <Carbon/Carbon.h>
#endif


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
    static void devicesMessageCallback(CSOUND *csound,
                                       int attr,
                                       const char *fmt,
                                       va_list args);
    static void utilitiesMessageCallback(CSOUND *csound,
                                         int /*attr*/,
                                         const char *fmt,
                                         va_list args);

    QStringList runCsoundInternally(QStringList flags); //returns csound messages
//    void newCurve(Curve *curve);  //New graphs
//    void updateCurve(WINDAT *windat); //graph updates
//    int killCurves(CSOUND *csound);
//    int popKeyPressEvent(); // return ASCII code of key press event for Csound or -1 if no event
//    int popKeyReleaseEvent(); // return ASCII code of key release event for Csound -1 if no event

    OpEntryParser *opcodeTree;

  public slots:
    bool loadFile(QString fileName, bool runNow = false);
    void play();
    void runInTerm(bool realtime = true);
    void pause();
    void stop();
    void render();
    void record();
//     void selectMidiInDevice(QPoint pos);
//     void selectMidiOutDevice(QPoint pos);
//     void selectAudioInDevice(QPoint pos);
//     void selectAudioOutDevice(QPoint pos);
    void changeFont();
    void changePage(int index);
    void setWidgetTooltipsVisible(bool visible);
//    void updateWidgets();
    void openExample();
//    void registerLiveEvent(QWidget *e);

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
    void setWidgetEditMode(bool);  // This is not necessary as the action is passed and connected in the widget layout
    void controlD();
    void del();
    bool closeTab(bool askCloseApp = false);
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
//    void syntaxCheck();
    void configure();
    void applySettings();
    void setCurrentOptionsForPage(DocumentPage *p);
    void runUtility(QString flags);
//     void widgetDockStateChanged(bool topLevel);
//     void widgetDockLocationChanged(Qt::DockWidgetArea area);
    void showLineNumber(int lineNumber);
    void updateInspector();
    void setDefaultKeyboardShortcuts();

  private:
    void createActions();
    void setKeyboardShortcutsList();
    void connectActions();
    void createMenus();
    void fillFileMenu();
    void createToolBars();
    void createStatusBar();
    void readSettings();
    void writeSettings();
    int execute(QString executable, QString options);
//    bool saveCurrent();
    void loadCompanionFile(const QString &fileName);
    bool saveFile(const QString &fileName, bool saveWidgets = true);
    void setCurrentFile(const QString &fileName);
    QString strippedName(const QString &fullFileName);
    QString generateScript(bool realtime = true, QString tempFileName = "");
    void getCompanionFileName();
    void setWidgetPanelGeometry();
    int isOpen(QString fileName);  // Returns index of document if open -1 if not open
//    void markErrorLine();
    QString getSaveFileName();
    void createQuickRefPdf();

//     QHash<QString, double> outValueQueue;
//    QHash<QString, double> inValueQueue;
//    QHash<QString, QString> outStringQueue;

    QTabWidget *documentTabs;
    GraphicWindow *m_graphic;  // To display the code graph images
    QVector<DocumentPage *> documentPages;
    Options *m_options;
    DockConsole *m_console;
    DockHelp *helpPanel;
    WidgetPanel *widgetPanel;  // Dock widget, for containing the widget layout
    Inspector *m_inspector;
    QToolButton *closeTabButton;

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

    int curPage;  // TODO use this or textEdit but not both!
    int configureTab; // Tab in last configure dialog accepted
    QString lastUsedDir;
    QString lastFileDir;
    QString quickRefFileName;
    QStringList recentFiles;
    QStringList lastFiles;

    QStringList tempScriptFiles; //Remember temp files to delete them later
    int lastTabIndex;
    QStringList m_deviceMessages; //stores messages from csound for device discovery

    UtilitiesDialog *utilitiesDialog;

    QIcon modIcon;
    QLabel *lineNumberLabel;

    QString currentAudioFile;

#ifdef MACOSX_PRE_SNOW
    MenuBarHandle menuBarHandle;
#endif
};

class FileOpenEater : public QObject
{
  Q_OBJECT
  public:
    FileOpenEater() {m_mw = 0;}
    void setMainWindow(qutecsound *mainWindow) {m_mw = mainWindow;}

    QList<QFileOpenEvent> fileEventQueue;
  protected:
    bool eventFilter(QObject *obj, QEvent *event)
    {
      if (event->type() == QEvent::FileOpen) {
          QFileOpenEvent *fileEvent = static_cast<QFileOpenEvent*>(event);
          if (m_mw == 0) {
              fileEventQueue << *fileEvent;  // FIXME this queue is not being processed
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
};

#endif
