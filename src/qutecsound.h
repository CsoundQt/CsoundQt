/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/


#ifndef QUTECSOUND_H
#define QUTECSOUND_H

#include <QMainWindow>
#include <QCloseEvent>
#include <QTabWidget>

#include <CppSound.hpp>

#include "types.h"

#ifdef MACOSX
// Needed to be able to grab menus back from FLTK
#include <Carbon/Carbon.h>
#endif

class QAction;
class QMenu;
class QTextEdit;

class DockHelp;
class Console;
class OpEntryParser;
class Options;
class Highlighter;
class ConfigLists;
class DocumentPage;

class qutecsound:public QMainWindow
{
  Q_OBJECT

  public:
    qutecsound(QString fileName);
    ~qutecsound();
    static void messageCallback_NoThread(CSOUND *csound,
                                         int attr,
                                         const char *fmt,
                                         va_list args);

  public slots:
    void changeFont();
    void changePage(int index);

  protected:
    void closeEvent(QCloseEvent *event);

  private slots:
    void newFile();
    void open();
    void openRecent0();
    void openRecent1();
    void openRecent2();
    void openRecent3();
    void openRecent4();
    void openRecent5();
    bool save();
    bool saveAs();
    bool closeTab();
    void play(bool realtime=true);
    void stop();
    void render();
    void setHelpEntry();
    void about();
    void documentWasModified();
    void syntaxCheck();
    void autoComplete();
    void configure();

  private:
    void createActions();
    void connectActions();
    void createMenus();
    void fillFileMenu();
    void createToolBars();
    void createStatusBar();
    void readSettings();
    void writeSettings();
    void configureHighlighter();
    bool maybeSave();
	QString fixLineEndings(const QString &text);
    void loadFile(const QString &fileName);
    void loadCompanionFile(const QString &fileName);
    bool saveFile(const QString &fileName);
    void setCurrentFile(const QString &fileName);
    QString strippedName(const QString &fullFileName);
    QString generateScript(bool realtime = true);
    void getCompanionFileName();

    QTabWidget *documentTabs;
    QVector<DocumentPage *> documentPages;
    QTextEdit *textEdit;
    OpEntryParser *opcodeTree;
    Options *m_options;
    Console *m_console;
    Highlighter *m_highlighter;
    DockHelp *helpPanel;

    QMenu *fileMenu;
    QMenu *recentMenu;
    QMenu *editMenu;
    QMenu *controlMenu;
    QMenu *viewMenu;
    QMenu *helpMenu;
    QToolBar *fileToolBar;
    QToolBar *editToolBar;
    QToolBar *controlToolBar;
    QAction *newAct;
    QAction *openAct;
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
    QAction *autoCompleteAct;
    QAction *configureAct;
    QAction *playAct;
    QAction *stopAct;
    QAction *renderAct;
    QAction *showHelpAct;
    QAction *showConsole;
    QAction *setHelpEntryAct;
    QAction *aboutAct;
    QAction *aboutQtAct;

    int curPage;
//     QString curFile;
    QString lastUsedDir;
    QString lastFileDir;
    viewMode m_mode;
    ConfigLists *m_configlists;
    QStringList recentFiles;

    bool running;
	
#ifdef MACOSX
	MenuBarHandle menuBarHandle;
#endif
};

#endif
