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
#ifdef QCS_PYTHONQT
class PythonConsole;
#endif
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
class EventSheet;
class CsoundEngine;
#ifdef QCS_RTMIDI
class RtMidiIn;
#endif

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

    // Editor
    QString setDocument(int index); // Returns document name
    void insertText(QString text, int index = -1, int section = -1);
    void setCsd(QString text, int index = -1);
    void setFullText(QString text, int index = -1);
    void setOrc(QString text, int index = -1);
    void setSco(QString text, int index = -1);
    void setWidgetsText(QString text, int index = -1);
    void setPresetsText(QString text, int index = -1);
    void setOptionsText(QString text, int index = -1);

    int getDocument(QString name = ""); // Returns document index. -1 if not current open
    QString getSelectedText(int index = -1, int section = 0);
    QString getCsd(int index);
    QString getFullText(int index);
    QString getOrc(int index);
    QString getSco(int index);
    QString getWidgetsText(int index);
    QString getPresetsText(int index);
    QString getOptionsText(int index);
    QString getFileName(int index);
    QString getFilePath(int index);

    // Widgets
    void setChannelValue(QString channel, double value, int index = -1);
    double getChannelValue(QString channel, int index = -1);
    void setChannelString(QString channel, QString value, int index = -1);
    QString getChannelString(QString channel, int index = -1);
    void setWidgetProperty(QString channel, QString property, QVariant value, int index= -1);
    QVariant getWidgetProperty(QString channel, QString property, int index= -1);

    QString createNewLabel(int x = -1, int y = -1, int index = -1);
    QString createNewDisplay(int x = -1, int y = -1, int index = -1);
    QString createNewScrollNumber(int x = -1, int y = -1, int index = -1);
    QString createNewLineEdit(int x = -1, int y = -1, int index = -1);
    QString createNewSpinBox(int x = -1, int y = -1, int index = -1);
    QString createNewSlider(int x = -1, int y = -1, int index = -1);
    QString createNewButton(int x = -1, int y = -1, int index = -1);
    QString createNewKnob(int x = -1, int y = -1, int index = -1);
    QString createNewCheckBox(int x = -1, int y = -1, int index = -1);
    QString createNewMenu(int x = -1, int y = -1, int index = -1);
    QString createNewMeter(int x = -1, int y = -1, int index = -1);
    QString createNewConsole(int x = -1, int y = -1, int index = -1);
    QString createNewGraph(int x = -1, int y = -1, int index = -1);
    QString createNewScope(int x = -1, int y = -1, int index = -1);
//    int popKeyPressEvent(); // return ASCII code of key press event for Csound or -1 if no event
//    int popKeyReleaseEvent(); // return ASCII code of key release event for Csound -1 if no

    //Live Event Sheets
    EventSheet* getSheet(int index = -1, int sheetIndex = -1);
    EventSheet* getSheet(int index = -1, QString sheetName = QString());

    // Engine
    CsoundEngine *getEngine(int index = -1);

    OpEntryParser *opcodeTree;

  public slots:
    bool loadFile(QString fileName, bool runNow = false);
    void play(bool realtime = true, int index = -1);
    void runInTerm(bool realtime = true);
    void pause(int index = -1);
    void stop(int index = -1);
    void stopAll();
    void perfEnded();
    void render();
    void record();
    void sendEvent(QString eventLine, double delay = 0);
    void sendEvent(int index, QString line, double delay = 0);
    void changePage(int index);
    void setWidgetTooltipsVisible(bool visible);
//    void updateWidgets();
    void openExample();
    void logMessage(QString msg);
//    void registerLiveEvent(QWidget *e);

  protected:
    virtual void closeEvent(QCloseEvent *event);
//    virtual void keyPressEvent(QKeyEvent *event);

  private slots:
    void newFile();
    void open();
    void reload();
    void openFromAction();
    void openFromAction(QString fileName);
    void runScriptFromAction();
    void runScript(QString fileName);
    void createCodeGraph();
    void closeGraph();
    bool save();
    bool saveAs();
    void createApp();
    bool saveNoWidgets();
    void info();
    // Edition
    void copy();
    void cut();
    void paste();
    void undo();
    void redo();
    void evaluateSection();
    void evaluatePython(QString code = QString());
    void setWidgetEditMode(bool);  // This is not necessary as the action is passed and connected in the widget layout
    void setWidgetClipboard(QString text);
    void duplicate();
    bool closeTab(bool askCloseApp = false);
    void print();
    void findReplace();  // Direct to current Page
    void findString();  // Direct to current Page
    void autoComplete();  // Direct to current Page
    bool join(bool ask = true);
    void showUtilities(bool);
    void getToIn();
    void inToGet();
    void putCsladspaText();
    void exportCabbage();
    void setCurrentAudioFile(const QString fileName);
    void openExternalEditor();
    void openExternalPlayer();
    void setEditorFocus();
    void setHelpEntry();
    void setFullScreen(bool full);
    void openManualExample(QString fileName);
    void openExternalBrowser(QUrl url = QUrl());
    void openQuickRef();
    void resetPreferences();
    void openShortcutDialog();
    void statusBarMessage(QString message);
    void about();
    void donate();
    void documentWasModified();
    void configure();
    void applySettings();
    void setCurrentOptionsForPage(DocumentPage *p);
    void runUtility(QString flags);
//     void widgetDockLocationChanged(Qt::DockWidgetArea area);
    void showLineNumber(int lineNumber);
    void updateInspector();
    void markInspectorUpdate(); // Notification that inspector needs update
    void setDefaultKeyboardShortcuts();
    void showNoPythonQtWarning();

  private:
    void createActions();
    void setKeyboardShortcutsList();
    void connectActions();
    void createMenus();
    void fillFileMenu();
    void fillFavoriteMenu();
    void fillFavoriteSubMenu(QDir dir, QMenu *m, int depth);
    void fillScriptsMenu();
    void fillScriptsSubMenu(QDir dir, QMenu *m, int depth);
    void fillEditScriptsSubMenu(QDir dir, QMenu *m, int depth);
    void createToolBars();
    void createStatusBar();
    void readSettings();
    void writeSettings(QStringList openFiles=QStringList(), int lastIndex = 0);
    void clearSettings();
    int execute(QString executable, QString options);
//    bool saveCurrent();
    void makeNewPage(QString fileName, QString text);
    bool loadCompanionFile(const QString &fileName);
    bool saveFile(const QString &fileName, bool saveWidgets = true);
    void setCurrentFile(const QString &fileName);
    QString strippedName(const QString &fullFileName);
    QString generateScript(bool realtime = true, QString tempFileName = "", QString executable = "");
    void getCompanionFileName();
    void setWidgetPanelGeometry();
    int isOpen(QString fileName);  // Returns index of document if open -1 if not open
//    void markErrorLine();
    QString getSaveFileName();
    void createQuickRefPdf();
    void deleteCurrentTab();
    void openLogFile();

    void setMidiInterface(int number);
    void openMidiPort(int port);
    void closeMidiPort();
    void showNewFormatWarning();

    QTabWidget *documentTabs;
    GraphicWindow *m_graphic;  // To display the code graph images
    QVector<DocumentPage *> documentPages;
    Options *m_options;
    DockConsole *m_console;
    DockHelp *helpPanel;
    WidgetPanel *widgetPanel;  // Dock widget, for containing the widget layout
    QString m_widgetClipboard;
    Inspector *m_inspector;
#ifdef QCS_PYTHONQT
    PythonConsole *m_pythonConsole;
#endif
#ifdef QCS_RTMIDI
    RtMidiIn *m_midiin;
#endif
    QToolButton *closeTabButton;
    QFile logFile;

    QVector<QAction *> m_keyActions; //Actions which have keyboard shortcuts

    QMenu *fileMenu;
    QMenu *recentMenu;
    QMenu *editMenu;
    QMenu *controlMenu;
    QMenu *viewMenu;
    QMenu *favoriteMenu;
    QMenu *scriptsMenu;
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
    QAction *createAppAct;
    QAction *saveNoWidgetsAct;
    QAction *closeTabAct;
    QAction *printAct;
    QAction *createCodeGraphAct;
    QAction *infoAct;
    QAction *exitAct;
    QList<QAction *> openRecentAct;
    QAction *undoAct;
    QAction *redoAct;
    QAction *cutAct;
    QAction *copyAct;
    QAction *pasteAct;
    QAction *duplicateAct;
    QAction *joinAct;
    QAction *evaluateAct;
    QAction *evaluateSectionAct;
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
    QAction *stopAllAct;
    QAction *recAct;
    QAction *renderAct;
    QAction *externalEditorAct;
    QAction *externalPlayerAct;
    QAction *focusEditorAct;
    QAction *showHelpAct;
    QAction *showManualAct;
    QAction *showGenAct;
    QAction *showOverviewAct;
    QAction *showOpcodeQuickRefAct;
    QAction *showConsoleAct;
    QAction *viewFullScreenAct;
    QAction *setHelpEntryAct;
    QAction *browseBackAct;
    QAction *browseForwardAct;
    QAction *externalBrowserAct;
    QAction *openQuickRefAct;
    QAction *showUtilitiesAct;
    QAction *showWidgetsAct;
    QAction *showInspectorAct;
    QAction *showLiveEventsAct;
    QAction *showPythonConsoleAct;
    QAction *commentAct;
//    QAction *uncommentAct;
    QAction *indentAct;
    QAction *unindentAct;
    QAction *killLineAct;
    QAction *killToEndAct;
    QAction *aboutAct;
    QAction *donateAct;
    QAction *aboutQtAct;
    QAction *resetPreferencesAct;

    int curPage;
    int curCsdPage;  // To recall last csd visited
    int configureTab; // Tab in last configure dialog accepted
    QString lastUsedDir;
    QString lastFileDir;
    QString quickRefFileName;
    QStringList recentFiles;
    QStringList lastFiles;

    QStringList tempScriptFiles; //Remember temp files to delete them later
    int lastTabIndex;
    QStringList m_deviceMessages; //stores messages from csound for device discovery
    bool m_startingUp; // set while starting up
    bool m_resetPrefs; // Flag to reset preferences to default when closing
    bool m_inspectorNeedsUpdate;
    bool m_closing; // QuteCsound is closing (to inform timer threads)

    UtilitiesDialog *utilitiesDialog;

    QIcon modIcon;
    QLabel *lineNumberLabel;

    QString currentAudioFile;
    QString initialDir;

#ifdef MACOSX_PRE_SNOW
    MenuBarHandle menuBarHandle;
#endif
};

class FileOpenEater : public QObject
{
  Q_OBJECT
  public:
    FileOpenEater() {m_mw = 0;}
    void setMainWindow(qutecsound *mainWindow) {
      m_mw = mainWindow;
      while (!fileEventQueue.isEmpty()) {
        QString fileName = fileEventQueue.takeFirst();
        m_mw->loadFile(fileName, true);
      }
    }
    QStringList fileEventQueue;
  protected:
    bool eventFilter(QObject *obj, QEvent *event)
    {
      if (event->type() == QEvent::FileOpen) {
          QFileOpenEvent *fileEvent = static_cast<QFileOpenEvent*>(event);
          if (m_mw == 0) {
              fileEventQueue << fileEvent->file();
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
