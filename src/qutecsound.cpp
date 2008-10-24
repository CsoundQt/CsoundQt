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


#include <QtGui>
#include <QCloseEvent>
#include <QFileDialog>

#include <QTextEdit>
#include <QTextCursor>

#include "qutecsound.h"
#include "console.h"
#include "dockhelp.h"
#include "widgetpanel.h"
#include "opentryparser.h"
#include "options.h"
#include "highlighter.h"
#include "configdialog.h"
#include "configlists.h"
#include "documentpage.h"
#include "utilitiesdialog.h"
#include "findreplace.h"

//#include <string>

#ifdef WIN32
static const QString SCRIPT_NAME = "qutecsound_run_script.bat";
#else
static const QString SCRIPT_NAME = "./qutecsound_run_script.sh";
#endif

//csound performance thread function prototype
uintptr_t csThread(void *clientData);

qutecsound::qutecsound(QString fileName)
{
  setWindowTitle("QuteCsound[*]");
  resize(660,350);
  setWindowIcon(QIcon(":/images/qtcs.png"));
  documentTabs = new QTabWidget (this);
  connect(documentTabs, SIGNAL(currentChanged(int)), this, SLOT(changePage(int)));
  curPage = -1;
  running = false;
  setCentralWidget(documentTabs);

  m_options = new Options();

  m_configlists = new ConfigLists;

  m_console = new Console(this);
  m_console->setObjectName("m_console");
//   m_console->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea);
  addDockWidget(Qt::BottomDockWidgetArea, m_console);
  helpPanel = new DockHelp(this);
  helpPanel->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea);
  addDockWidget(Qt::RightDockWidgetArea, helpPanel);

  widgetPanel = new WidgetPanel(this);
  widgetPanel->setAllowedAreas(Qt::RightDockWidgetArea | Qt::LeftDockWidgetArea);
  widgetPanel->setObjectName("widgetPanel");
  addDockWidget(Qt::RightDockWidgetArea, widgetPanel);

  helpPanel->show();
  helpPanel->setObjectName("helpPanel");

  readSettings();

  utilitiesDialog = new UtilitiesDialog(this, m_options, m_configlists);
  connect(utilitiesDialog, SIGNAL(runUtility(QString)), this, SLOT(runUtility(QString)));

  createActions();
  createMenus();
  createToolBars();
  createStatusBar();


  fillFileMenu(); //Must be placed after readSettings to include recent Files
  if (m_options->opcodexmldir == "") {
#ifdef MACOSX
    opcodeTree = new OpEntryParser(":/opcodes.xml");
#else
    opcodeTree = new OpEntryParser(":/opcodes.xml");
#endif
  }
  else
    opcodeTree = new OpEntryParser(QString(m_options->opcodexmldir + "/opcodes.xml"));
  m_highlighter = new Highlighter();
  configureHighlighter();

  if (fileName!="") {
    loadFile(fileName);
    if (m_options->autoPlay)
      play();
  }
  else if (lastFile!="" and !lastFile.startsWith("untitled")) {
    if (!loadFile(lastFile))
     newFile();
  }
  else {
    newFile();
  }

  changeFont();
  modIcon.addFile(":/images/modIcon2.png", QSize(), QIcon::Normal);
  modIcon.addFile(":/images/modIcon.png", QSize(), QIcon::Disabled);

  helpPanel->docDir = m_options->csdocdir;
  QString index = m_options->csdocdir + QString("/index.html");
  helpPanel->loadFile(index);

  applySettings();

  //TODO: free ud if switched to non threaded use
  ud = (csoundUserData *)malloc(sizeof(csoundUserData));
  ud->qcs = this;
  csound = NULL;
  int init = csoundInitialize(0,0,0);
  if (init<0) {
    qDebug("Error initializing Csound!");
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("Error initializing Csound!\nQutecsound will probably crash if you try to run Csound."));
//     return;
  }
  else if (init>0) {
    qDebug("Csound already initialized.");
  }
}

qutecsound::~qutecsound()
{
}

void qutecsound::messageCallback_NoThread(CSOUND *csound,
                                          int attr,
                                          const char *fmt,
                                          va_list args)
{
  Console *console = (Console *) csoundGetHostData(csound);
  QString msg;
  msg = msg.vsprintf(fmt, args);
  console->appendMessage(msg);
  console->update();
}

void qutecsound::changeFont()
{
  for (int i = 0; i < documentPages.size(); i++) {
    documentPages[i]->document()->setDefaultFont(QFont(m_options->font, (int) m_options->fontPointSize));
  }
  m_console->setDefaultFont(QFont(m_options->consoleFont,
                                      (int) m_options->consoleFontPointSize));
}

void qutecsound::changePage(int index)
{
  stop();
  textEdit = documentPages[index];
  m_highlighter->setColorVariables(m_options->colorVariables);
  m_highlighter->setDocument(textEdit->document());
  curPage = index;
  setCurrentFile(documentPages[curPage]->fileName);
  connectActions();
}

void qutecsound::updateWidgets()
{
  widgetPanel->loadWidgets(textEdit->getMacWidgetsText());
}

void qutecsound::closeEvent(QCloseEvent *event)
{
  stop();
  if (maybeSave()) {
    writeSettings();
    event->accept();
  } else {
    event->ignore();
  }
}

void qutecsound::newFile()
{
  /* for (int i = 0 ; i < documentPages.size(); i++) {
    if (documentPages[i]->fileName == "") {
	  documentTabs->setCurrentIndex(i);
	  return;
    }
  }
  if (documentPages.size() > 0)
    if (maybeSave())
      return; */
#ifdef MACOSX
  QFile file(":/default.csd");
#else
  QFile file(":/default.csd");
#endif
  if (!file.open(QFile::ReadOnly | QFile::Text)) {
    QMessageBox::warning(this, tr("QuteCsound"),
                          tr("Cannot read default template:\n%1.")
                              .arg(file.errorString()));
    return;
  }
//   QTextStream in(&file);
//   DocumentPage *newPage = new DocumentPage(this);
//   documentPages.append(newPage);
//   documentTabs->addTab(newPage,"");
//   curPage = documentPages.size() - 1;
//   documentTabs->setCurrentIndex(curPage);
//   documentPages[curPage]->setText(in.readAll());
//   textEdit = newPage;
//   m_highlighter->setColorVariables(m_options->colorVariables);
//   m_highlighter->setDocument(textEdit->document());
//   textEdit->document()->setModified(false);
  loadFile(":/default.csd");
  documentPages[curPage]->fileName = "";
  setWindowModified(false);
  documentTabs->setTabIcon(curPage, modIcon);
//   changeFont();
//   setCurrentFile("");
  connectActions();
}

void qutecsound::open()
{
  QString fileName = "";
  if (maybeSave()) {
    fileName = QFileDialog::getOpenFileName(this, tr("Open File"), lastUsedDir , tr("Csound Files (*.csd *.orc *.sco)"));
    if (!fileName.isEmpty()) {
      loadCompanionFile(fileName);
      loadFile(fileName);
    }
  }
  for (int i = 0; i < documentPages.size(); i++) {
    if (fileName == documentPages[i]->fileName) {
      documentTabs->setCurrentIndex(i);
      changePage(i);
      statusBar()->showMessage(tr("File already open"), 10000);
      return;
    }
  }
}

void qutecsound::reload()
{
  if (documentPages[curPage]->document()->isModified()) {
    QString fileName = documentPages[curPage]->fileName;
    documentPages.remove(curPage);
    documentTabs->removeTab(curPage);
    loadFile(fileName);
  }
}

void qutecsound::openRecent0()
{
  if (maybeSave()) {
    QString fileName = recentFiles[0];
    if (!fileName.isEmpty()) {
      loadCompanionFile(fileName);
      loadFile(fileName);
    }
  }
}

void qutecsound::openRecent1()
{
  if (maybeSave()) {
    QString fileName = recentFiles[1];
    if (!fileName.isEmpty()) {
      loadCompanionFile(fileName);
      loadFile(fileName);
    }
  }
}

void qutecsound::openRecent2()
{
  if (maybeSave()) {
    QString fileName = recentFiles[2];
    if (!fileName.isEmpty()) {
      loadCompanionFile(fileName);
      loadFile(fileName);
    }
  }
}

void qutecsound::openRecent3()
{
  if (maybeSave()) {
    QString fileName = recentFiles[3];
    if (!fileName.isEmpty()) {
      loadCompanionFile(fileName);
      loadFile(fileName);
    }
  }
}

void qutecsound::openRecent4()
{
  if (maybeSave()) {
    QString fileName = recentFiles[4];
    if (!fileName.isEmpty()) {
      loadCompanionFile(fileName);
      loadFile(fileName);
    }
  }
}

void qutecsound::openRecent5()
{
  if (maybeSave()) {
    QString fileName = recentFiles[5];
    if (!fileName.isEmpty()) {
      loadCompanionFile(fileName);
      loadFile(fileName);
    }
  }
}

bool qutecsound::save()
{
  widgetPanel->widgetChanged();  //To make sure the values of the widgets are stored
  if (documentPages[curPage]->fileName.isEmpty()) {
    return saveAs();
  } else {
    return saveFile(documentPages[curPage]->fileName);
  }
}

bool qutecsound::saveAs()
{
  QString fileName = QFileDialog::getSaveFileName(this, tr("Save File As"), lastUsedDir , tr("Csound Files (*.csd *.orc *.sco)"));
  if (fileName.isEmpty())
    return false;
  if (!fileName.endsWith(".csd") && !fileName.endsWith(".orc") && !fileName.endsWith(".sco"))
    fileName += ".csd";

  return saveFile(fileName);
}

bool qutecsound::closeTab()
{
  qDebug("qutecsound::closeTab() curPage = %i documentPages.size()=%i", curPage, documentPages.size());
  if (documentPages[curPage]->document()->isModified()) {
    int ret = QMessageBox::warning(this, tr("QuteCsound"),
                                   tr("File has been modified.\nDo you want to save it?"),
                                      QMessageBox::Yes | QMessageBox::Default,
                                      QMessageBox::No,
                                      QMessageBox::Cancel);
    if (ret == QMessageBox::Cancel)
      return false;
    else if (ret == QMessageBox::Yes) {
      if (!saveAs())
        return false;
    }
  }
  if (documentPages.size() <= 1) {
    if (QMessageBox::warning(this, tr("QuteCsound"),
        tr("Do you want to exit QuteCsound?"),
           QMessageBox::Yes | QMessageBox::Default,
           QMessageBox::No) == QMessageBox::Yes)
    {
      close();
      return false;
    }
    newFile();
    curPage = 0;
  }
  documentPages.remove(curPage);
  documentTabs->removeTab(curPage);
  if (curPage > 0) {
    curPage--;
  }
  documentTabs->setCurrentIndex(curPage);
  textEdit = documentPages[curPage];
  setCurrentFile(documentPages[curPage]->fileName);
  m_highlighter->setColorVariables(m_options->colorVariables);
  m_highlighter->setDocument(documentPages[curPage]->document());
  connectActions();
  return true;
}

void qutecsound::findReplace()
{
  FindReplace *dialog = new FindReplace(this, documentPages[curPage]);
  dialog->show();
}

void qutecsound::join()
{
  qDebug("join() not implemented");
}

void qutecsound::play(bool realtime)
{
  stop();
  if (documentPages[curPage]->fileName.isEmpty()) {
    if (!saveAs())
      return;
  }
  else if (documentPages[curPage]->document()->isModified()) {
    if (m_options->saveChanges)
      saveFile(documentPages[curPage]->fileName);
  }
  QString fileName, fileName2;
  fileName = documentPages[curPage]->fileName;
  if (!fileName.endsWith(".csd")) {
    if (documentPages[curPage]->askForFile)
      getCompanionFileName();
    fileName2 = documentPages[curPage]->companionFile;
  }

  if (m_options->useAPI) {
#ifdef MACOSX
//Remember menu bar to set it after FLTK grabs it
    menuBarHandle = GetMenuBar();
#endif
    m_console->clear();
    QTemporaryFile csdFile;
    QString tmpFileName = QDir::tempPath();
    if (!tmpFileName.endsWith("/") and !tmpFileName.endsWith("\\")) {
      tmpFileName += QDir::separator();
    }
    tmpFileName += QString("csound-tmpXXXXXXXX.csd");
    csdFile.setFileTemplate(tmpFileName);
    if (!csdFile.open()) {
      QMessageBox::critical(this,
                            tr("PostQC"),
                            tr("Error creating temporary file."),
                            QMessageBox::Ok);
      return;
    }
    if (documentPages[curPage]->fileName.endsWith(".csd")) {
      QString csdText = textEdit->document()->toPlainText();
      QString fileName = csdFile.fileName();
      csdFile.write(csdText.toAscii());
      csdFile.flush();
    }
    char **argv;
    argv = (char **) calloc(33, sizeof(char*));
    MYFLT *pvalue;
    // TODO use: PUBLIC int csoundSetGlobalEnv(const char *name, const char *value);
    int argc = m_options->generateCmdLine(argv, realtime, fileName, fileName2);
    if (m_options->thread) {
//       if (!csound) {
        csound=csoundCreate(0);
        //TODO make sure csound has been freed when switched from non threaded
//         csoundSetIsGraphable(csound, 0);
        ud->csound = csound;
        ud->realtime = realtime;
//       }
    }
    else {
      //TODO make sure that csound has been freed from threaded operation
//       if (!csound) {
      csound=csoundCreate(0);
//       csoundSetIsGraphable(csound, 1);
//         qDebug("Message level = %i", csoundGetMessageLevel(csound));
//       }
    }
    csoundReset(csound);
    csoundSetHostData(csound, (void *)m_console);
    csoundSetMessageCallback(csound, &qutecsound::messageCallback_NoThread);
    int result=csoundCompile(csound,argc,argv);

    if (result!=CSOUND_SUCCESS) {
      qDebug("Csound compile failed!");
      csoundStop(csound);
      free(argv);
      csoundCleanup(csound);
      csoundDestroy(csound);  //Had to destroy csound every run otherwise FLTK widgets crash...
//       csound = NULL;
      return;
    }
    qDebug("Command Line:");
    for (int index=0; index< argc; index++) {
      fprintf(stderr, "%s ",argv[index]);
    }
    fprintf(stderr, "\n");
    running = true;
    if(m_options->thread)
    {
      ud->result = result;
      ud->PERF_STATUS=1;
      ThreadID = csoundCreateThread(csThread, (void*)ud);
    }
    else {
      unsigned int numWidgets = widgetPanel->widgetCount();
      QVector<QString> channelNames;
      QVector<double> values;
      channelNames.resize(numWidgets);
      values.resize(numWidgets);
      while(csoundPerformKsmps(csound)==0 && running) {
        qApp->processEvents();
        if (realtime && m_options->rtEnableWidgets) {
          widgetPanel->getValues(&channelNames, &values);
          for (int i = 0; i<channelNames.size(); i++) {
            if(csoundGetChannelPtr(csound, &pvalue, channelNames[i].toStdString().c_str(),
              CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0)
            {
    //           qDebug("%s-%i", values[i].first.toStdString().c_str(), values[i].second);
              *pvalue = (MYFLT) values[i];
            }
          }
        }
      }
      csoundStop(csound);
      csoundCleanup(csound);
      csoundDestroy(csound);  //Had to destroy csound every run otherwise FLTK widgets crash...
      csound = NULL;
      running = false;
    }
    free(argv);
//     int hold;
//
//     CsoundPerformanceThread thread(csound.GetCsound());
//     cout << "Press 1 to play, 2 to pause and 0 to quit\n";
//     while(1){
//       cin >> hold;
//       if(hold==1){
//         thread.Play();
//         hold = 0;
//       }
//       else if(hold==2){
//         thread.Pause();
//         hold=0;
//
//       }
//     }
#ifdef MACOSX
// Put menu bar back
    SetMenuBar(menuBarHandle);
#endif
  }
  else {
    QString script = generateScript(realtime);
    QFile file(SCRIPT_NAME);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
      return;

    QTextStream out(&file);
    out << script;
    file.flush();
    file.close();
    file.setPermissions (QFile::ExeOwner| QFile::WriteOwner| QFile::ReadOwner);

    QString options;
#ifdef LINUX
    options = "-e " + SCRIPT_NAME;
#endif
#ifdef MACOSX
    options = SCRIPT_NAME;
#endif
#ifdef WIN32
    options = SCRIPT_NAME;
#endif
    execute(m_options->terminal, options);
  }
}

void qutecsound::stop()
{
  if (running) {
    if (m_options->thread) {
      ud->PERF_STATUS = 0;
      csoundStop(csound);
      csoundCleanup(csound);
      csoundJoinThread((void *) ThreadID);
      csoundDestroy(csound);  //Had to destroy csound every run otherwise FLTK widgets crash...
//     csound = NULL;
    }
  }
  else if (csound) {
    csoundDestroy(csound);  //Had to destroy csound every run otherwise FLTK widgets crash...
  }
  running = false;
}

void qutecsound::render()
{
  if (m_options->fileAskFilename) {
    QFileDialog dialog(this,tr("Output Filename"),lastFileDir);
    dialog.setAcceptMode(QFileDialog::AcceptSave);
	dialog.setConfirmOverwrite(false);
    QString filter = QString(m_configlists->fileTypeLongNames[m_options->fileFileType] + " Files ("
        + m_configlists->fileTypeExtensions[m_options->fileFileType] + ")");
    dialog.setFilter(filter);
    if (dialog.exec()) {
      QString extension = m_configlists->fileTypeExtensions[m_options->fileFileType];
      // Remove the '*' from the extension
      extension.remove(0,1);
      m_options->fileOutputFilename = dialog.selectedFiles()[0];
      if (!m_options->fileOutputFilename.endsWith(extension))
        m_options->fileOutputFilename += extension;
      if (QFile::exists(m_options->fileOutputFilename)) {
        int ret = QMessageBox::warning(this, tr("QuteCsound"),
                tr("The file %1 \nalready exists.\n"
                  "Do you want to overwrite it?").arg(m_options->fileOutputFilename),
                QMessageBox::Save | QMessageBox::Cancel,
                QMessageBox::Save);
        if (ret == QMessageBox::Cancel)
          return;
      }
      lastFileDir = dialog.directory().path();
    }
  }
  play(false);
}

void qutecsound::openExternalEditor()
{
  QString options;
  options = m_options->fileOutputFilename;
  execute(m_options->waveeditor, options);
}

void qutecsound::openExternalPlayer()
{
  QString options;
  options = m_options->fileOutputFilename;
  execute(m_options->waveplayer, options);
}

void qutecsound::setHelpEntry()
{
  QTextCursor cursor = textEdit->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  if (m_options->csdocdir != "") {
    QString file =  m_options->csdocdir + "/" + cursor.selectedText() + ".html";
	helpPanel->docDir = m_options->csdocdir;
    helpPanel->loadFile(file);
    helpPanel->show();
  }
  else {
    QMessageBox::critical(this,
                          tr("Error"),
                          tr("HTML Documentation directory not set!\n"
                             "Please go to Edit->Options->Environment and select directory\n"));
  }
}

void qutecsound::utilitiesDialogOpen()
{
  qDebug("qutecsound::utilitiesDialog()");

}

// void qutecsound::showWidgets()
// {
//   qDebug("qutecsound::showWidgets()");
// }

void qutecsound::about()
{
  QString text = tr("by: Andres Cabrera\nReleased under the GPL V3\nVersion ");
  text += QUTECSOUND_VERSION;
  QMessageBox::about(this, tr("About QuteCsound"), text);
}

void qutecsound::documentWasModified()
{
  //TODO setWindowModified when widgets change
  setWindowModified(textEdit->document()->isModified());
//   documentTabs->setTabIcon(curPage, QIcon(":/images/modIcon.png"));
}

void qutecsound::syntaxCheck()
{
  QTextCursor cursor = textEdit->textCursor();
  cursor.select(QTextCursor::LineUnderCursor);
  QStringList words = cursor.selectedText().split(QRegExp("\\b"));
  foreach( QString word, words) {
       // We need to remove all not possibly opcode
    word.remove(QRegExp("[^\\d\\w]"));
    if(word=="")
      continue;
    QString syntax = opcodeTree->getSyntax(word);
    if(syntax!="") {
      statusBar()->showMessage(syntax, 20000);
      return;
    }
  }
}

void qutecsound::autoComplete()
{
  QTextCursor cursor = textEdit->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  QString opcodeName = cursor.selectedText();
  if (opcodeName=="")
    return;
  textEdit->setTextCursor(cursor);
  textEdit->cut();
  QString syntax = opcodeTree->getSyntax(opcodeName);
  textEdit->insertPlainText (syntax);
}

void qutecsound::configure()
{
  ConfigDialog *dialog = new ConfigDialog(this, m_options, m_configlists);
  connect(dialog, SIGNAL(finished(int)), this, SLOT(applySettings(int)));
  dialog->show();
}

void qutecsound::applySettings(int result)
{
  m_highlighter->setDocument(textEdit->document());
  m_highlighter->setColorVariables(m_options->colorVariables);
  widgetPanel->setEnabled(m_options->rtEnableWidgets);
}

void qutecsound::checkSelection()
{
  //TODO add highlighting of words
}

void qutecsound::runUtility(QString flags)
{
  qDebug("qutecsound::runUtility");
//   if (m_options->useAPI) {
// #ifdef MACOSX
// //Remember menu bar to set it after FLTK grabs it
//     menuBarHandle = GetMenuBar();
// #endif
//     m_console->clear();
//     CppSound csound;
//     static char *argv[33];
//     QStringList indFlags= flags.split(" ",QString::SkipEmptyParts);
//     int index = 0;
//     foreach (QString flag, indFlags) {
//       argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
//       strcpy(argv[index],flag.toStdString().c_str());
//       index++;
//     }
//     int argc = indFlags.size();
//
//     csound.SetMessageCallback(&qutecsound::messageCallback_NoThread);
//     csound.SetHostData((void *)m_console);
//     csound.compile(argc, argv);
//     if (!csound.getIsCompiled()) {
//       qDebug("Csound compile failed!");
//       csound.Stop();
//       csound.cleanup();
//       return;
//     }
//     running = true;
//     csound.perform();
//     csound.Stop();
//     csound.cleanup();
// #ifdef MACOSX
// // Put menu bar back
//     SetMenuBar(menuBarHandle);
// #endif
//   }
//   else {
    QString script;
#ifdef WIN32
    script = "";
    if (m_options->opcodedirActive)
      script += "set OPCODEDIR=" + m_options->opcodedir + "\n";
    if (m_options->sadirActive)
      script += "set SADIR=" + m_options->sadir + "\n";
    if (m_options->ssdirActive)
      script += "set SSDIR=" + m_options->ssdir + "\n";
    if (m_options->sfdirActive)
      script += "set SFDIR=" + m_options->sfdir + "\n";
    if (m_options->ssdirActive)
      script += "set INCDIR=" + m_options->incdir + "\n";

    script += "cd " + QFileInfo(documentPages[curPage]->fileName).absoluteFilePath() + "\n";
    script += "csound " + flags + "\n";
#else
    script = "#!/bin/sh\n";
    if (m_options->opcodedirActive)
      script += "export OPCODEDIR=" + m_options->opcodedir + "\n";
    if (m_options->sadirActive)
      script += "export SADIR=" + m_options->sadir + "\n";
    if (m_options->ssdirActive)
      script += "export SSDIR=" + m_options->ssdir + "\n";
    if (m_options->sfdirActive)
      script += "export SFDIR=" + m_options->sfdir + "\n";
    if (m_options->ssdirActive)
      script += "export INCDIR=" + m_options->incdir + "\n";

    script += "cd " + QFileInfo(documentPages[curPage]->fileName).absoluteFilePath() + "\n";
#ifdef MACOSX
    script += "/usr/local/bin/csound " + flags + "\n";
#else
    script += "csound " + flags + "\n";
#endif
    script += "echo \"\nPress return to continue\"\n";
    script += "dummy_var=\"\"\n";
    script += "read dummy_var\n";
    script += "rm $0\n";
#endif
    QFile file(SCRIPT_NAME);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
      return;

    QTextStream out(&file);
    out << script;
    file.flush();
    file.close();
    file.setPermissions (QFile::ExeOwner| QFile::WriteOwner| QFile::ReadOwner);

    QString options;
#ifdef LINUX
    options = "-e " + SCRIPT_NAME;
#endif
#ifdef MACOSX
    options = SCRIPT_NAME;
#endif
#ifdef WIN32
    options = SCRIPT_NAME;
#endif
    execute(m_options->terminal, options);
//   }
}

void qutecsound::createActions()
{
  newAct = new QAction(QIcon(":/images/gtk-new.png"), tr("&New"), this);
  newAct->setShortcut(tr("Ctrl+N"));
  newAct->setStatusTip(tr("Create a new file"));
  connect(newAct, SIGNAL(triggered()), this, SLOT(newFile()));

  openAct = new QAction(QIcon(":/images/gnome-folder.png"), tr("&Open..."), this);
  openAct->setShortcut(tr("Ctrl+O"));
  openAct->setStatusTip(tr("Open an existing file"));
  connect(openAct, SIGNAL(triggered()), this, SLOT(open()));

  reloadAct = new QAction(QIcon(":/images/gtk-reload.png"), tr("Reload"), this);
//   reloadAct->setShortcut(tr("Ctrl+O"));
  reloadAct->setStatusTip(tr("Reload file from disk, discarding changes"));
  connect(reloadAct, SIGNAL(triggered()), this, SLOT(reload()));

  saveAct = new QAction(QIcon(":/images/gnome-dev-floppy.png"), tr("&Save"), this);
  saveAct->setShortcut(tr("Ctrl+S"));
  saveAct->setStatusTip(tr("Save the document to disk"));
  connect(saveAct, SIGNAL(triggered()), this, SLOT(save()));

  saveAsAct = new QAction(tr("Save &As..."), this);
  saveAsAct->setStatusTip(tr("Save the document under a new name"));
  connect(saveAsAct, SIGNAL(triggered()), this, SLOT(saveAs()));

  closeTabAct = new QAction(tr("Close current tab"), this);
  closeTabAct->setShortcut(tr("Ctrl+W"));
  closeTabAct->setStatusTip(tr("Close current tab"));
  connect(closeTabAct, SIGNAL(triggered()), this, SLOT(closeTab()));

  exitAct = new QAction(tr("E&xit"), this);
  exitAct->setShortcut(tr("Ctrl+Q"));
  exitAct->setStatusTip(tr("Exit the application"));
  connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

//   for (int i = 0; i < recentFiles.size(); i++) {
//     openRecentAct[i] = new QAction(tr("Recent 0"), this);
//     connect(openRecentAct[i], SIGNAL(triggered()), this, SLOT(openRecent()));
//   }

  undoAct = new QAction(QIcon(":/images/gtk-undo.png"), tr("Undo"), this);
  undoAct->setShortcut(tr("Ctrl+Z"));
  undoAct->setStatusTip(tr("Undo last action"));

  redoAct = new QAction(QIcon(":/images/gtk-redo.png"), tr("Redo"), this);
  redoAct->setShortcut(tr("Shift+Ctrl+Z"));
  redoAct->setStatusTip(tr("Redo last action"));

  cutAct = new QAction(QIcon(":/images/gtk-cut.png"), tr("Cu&t"), this);
  cutAct->setShortcut(tr("Ctrl+X"));
  cutAct->setStatusTip(tr("Cut the current selection's contents to the "
      "clipboard"));

  copyAct = new QAction(QIcon(":/images/gtk-copy.png"), tr("&Copy"), this);
  copyAct->setShortcut(tr("Ctrl+C"));
  copyAct->setStatusTip(tr("Copy the current selection's contents to the "
      "clipboard"));

  pasteAct = new QAction(QIcon(":/images/gtk-paste.png"), tr("&Paste"), this);
  pasteAct->setShortcut(tr("Ctrl+V"));
  pasteAct->setStatusTip(tr("Paste the clipboard's contents into the current "
      "selection"));

  joinAct = new QAction(/*QIcon(":/images/gtk-paste.png"),*/ tr("&Join orc/sco"), this);
//   joinAct->setShortcut(tr("Ctrl+V"));
  joinAct->setStatusTip(tr("Join orc/sco files in a single csd file"));
  connect(joinAct, SIGNAL(triggered()), this, SLOT(join()));

  findAct = new QAction(/*QIcon(":/images/gtk-paste.png"),*/ tr("&Find and Replace"), this);
  findAct->setShortcut(tr("Ctrl+F"));
  findAct->setStatusTip(tr("Find and replace strings in file"));
  connect(findAct, SIGNAL(triggered()), this, SLOT(findReplace()));

  autoCompleteAct = new QAction(tr("AutoComplete"), this);
  autoCompleteAct->setShortcut(tr("Alt+C"));
  autoCompleteAct->setStatusTip(tr("Autocomplete according to Status bar display"));
  connect(autoCompleteAct, SIGNAL(triggered()), this, SLOT(autoComplete()));

  configureAct = new QAction(QIcon(":/images/control-center2.png"), tr("Configuration"), this);
//   autoCompleteAct->setShortcut(tr("Ctrl+ "));
  configureAct->setStatusTip(tr("Open configuration dialog"));
  connect(configureAct, SIGNAL(triggered()), this, SLOT(configure()));

  playAct = new QAction(QIcon(":/images/gtk-media-play-ltr.png"), tr("Play"), this);
  playAct->setShortcut(tr("Alt+R"));
  playAct->setStatusTip(tr("Play"));
  connect(playAct, SIGNAL(triggered()), this, SLOT(play()));

  stopAct = new QAction(QIcon(":/images/gtk-media-stop.png"), tr("Stop"), this);
  stopAct->setShortcut(tr("Alt+S"));
  stopAct->setStatusTip(tr("Stop"));
  connect(stopAct, SIGNAL(triggered()), this, SLOT(stop()));

  renderAct = new QAction(QIcon(":/images/render.png"), tr("Render to file"), this);
  renderAct->setShortcut(tr("Alt+F"));
  renderAct->setStatusTip(tr("Render to file"));
  connect(renderAct, SIGNAL(triggered()), this, SLOT(render()));

  externalPlayerAct = new QAction(QIcon(":/images/playfile.png"), tr("Play Audiofile"), this);
//   externalPlayerAct->setShortcut(tr("Alt+F"));
  externalPlayerAct->setStatusTip(tr("Play rendered audiofile in External Editor"));
  connect(externalPlayerAct, SIGNAL(triggered()), this, SLOT(openExternalPlayer()));

  externalEditorAct = new QAction(QIcon(":/images/editfile.png"), tr("Edit Audiofile"), this);
//   externalEditorAct->setShortcut(tr("Alt+F"));
  externalEditorAct->setStatusTip(tr("Edit rendered audiofile in External Editor"));
  connect(externalEditorAct, SIGNAL(triggered()), this, SLOT(openExternalEditor()));

  showHelpAct = new QAction(QIcon(":/images/gtk-info.png"), tr("Help Panel"), this);
  showHelpAct->setShortcut(tr("Alt+W"));
  showHelpAct->setCheckable(true);
  showHelpAct->setChecked(true);
  showHelpAct->setStatusTip(tr("Show the Csound Manual Panel"));
  connect(showHelpAct, SIGNAL(toggled(bool)), helpPanel, SLOT(setVisible(bool)));
  connect(helpPanel, SIGNAL(Close(bool)), showHelpAct, SLOT(setChecked(bool)));

  showConsole = new QAction(QIcon(":/images/gksu-root-terminal.png"), tr("Output Console"), this);
  showConsole->setShortcut(tr("Alt+A"));
  showConsole->setCheckable(true);
  showConsole->setChecked(true);
  showConsole->setStatusTip(tr("Show Csound's message console"));
  connect(showConsole, SIGNAL(toggled(bool)), m_console, SLOT(setVisible(bool)));
  connect(m_console, SIGNAL(Close(bool)), showConsole, SLOT(setChecked(bool)));

  setHelpEntryAct = new QAction(QIcon(":/images/gtk-info.png"), tr("Show Opcode Entry"), this);
  setHelpEntryAct->setShortcut(tr("Shift+F1"));
  setHelpEntryAct->setStatusTip(tr("Show Opcode Entry in help panel"));
  connect(setHelpEntryAct, SIGNAL(triggered()), this, SLOT(setHelpEntry()));

  showUtilitiesAct = new QAction(QIcon(":/images/gnome-devel.png"), tr("Utilities"), this);
//   showUtilitiesAct->setShortcut(tr("Alt+W"));
  showUtilitiesAct->setCheckable(true);
  showUtilitiesAct->setChecked(false);
  showUtilitiesAct->setStatusTip(tr("Show the Csound Utilities dialog"));
  connect(showUtilitiesAct, SIGNAL(triggered(bool)), utilitiesDialog, SLOT(setVisible(bool)));
  connect(utilitiesDialog, SIGNAL(Close(bool)), showUtilitiesAct, SLOT(setChecked(bool)));

  showWidgetsAct = new QAction(QIcon(":/images/gnome-mime-application-x-diagram.png"), tr("Widgets"), this);
  showWidgetsAct->setCheckable(true);
  showWidgetsAct->setChecked(true);
//   externalEditorAct->setShortcut(tr("Alt+F"));
  showWidgetsAct->setStatusTip(tr("Show Realtime Widgets"));
  connect(showWidgetsAct, SIGNAL(triggered(bool)), widgetPanel, SLOT(setVisible(bool)));
  connect(widgetPanel, SIGNAL(Close(bool)), showWidgetsAct, SLOT(setChecked(bool)));

  aboutAct = new QAction(tr("&About QuteCsound"), this);
  aboutAct->setStatusTip(tr("Show the application's About box"));
  connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));

  aboutQtAct = new QAction(tr("About &Qt"), this);
  aboutQtAct->setStatusTip(tr("Show the Qt library's About box"));
  connect(aboutQtAct, SIGNAL(triggered()), qApp, SLOT(aboutQt()));

  cutAct->setEnabled(false);
  copyAct->setEnabled(false);

}

void qutecsound::connectActions()
{
  disconnect(undoAct, 0, 0, 0);
  disconnect(redoAct, 0, 0, 0);
  disconnect(cutAct, 0, 0, 0);
  disconnect(copyAct, 0, 0, 0);
  disconnect(pasteAct, 0, 0, 0);
  connect(undoAct, SIGNAL(triggered()), textEdit, SLOT(undo()));
  connect(redoAct, SIGNAL(triggered()), textEdit, SLOT(redo()));
  connect(cutAct, SIGNAL(triggered()), textEdit, SLOT(cut()));
  connect(copyAct, SIGNAL(triggered()), textEdit, SLOT(copy()));
  connect(pasteAct, SIGNAL(triggered()), textEdit, SLOT(paste()));
  disconnect(textEdit, SIGNAL(copyAvailable(bool)), 0, 0);
  disconnect(textEdit, SIGNAL(copyAvailable(bool)), 0, 0);
  connect(textEdit, SIGNAL(copyAvailable(bool)),
          cutAct, SLOT(setEnabled(bool)));
  connect(textEdit, SIGNAL(copyAvailable(bool)),
          copyAct, SLOT(setEnabled(bool)));

  disconnect(textEdit, SIGNAL(textChanged()), 0, 0);
  disconnect(textEdit, SIGNAL(cursorPositionChanged()), 0, 0);
  connect(textEdit, SIGNAL(textChanged()),
          this, SLOT(documentWasModified()));
  connect(textEdit, SIGNAL(textChanged()),
          this, SLOT(syntaxCheck()));
  connect(textEdit, SIGNAL(cursorPositionChanged()),
          this, SLOT(syntaxCheck()));
  connect(textEdit, SIGNAL(selectionChanged()),
          this, SLOT(checkSelection()));

  disconnect(widgetPanel, SIGNAL(widgetsChanged(QString)),0,0);
  connect(widgetPanel, SIGNAL(widgetsChanged(QString)),
          textEdit, SLOT(setMacWidgetsText(QString)) );
}

void qutecsound::createMenus()
{
  fileMenu = menuBar()->addMenu(tr("File"));

  editMenu = menuBar()->addMenu(tr("Edit"));
  editMenu->addAction(undoAct);
  editMenu->addAction(redoAct);
  editMenu->addSeparator();
  editMenu->addAction(cutAct);
  editMenu->addAction(copyAct);
  editMenu->addAction(pasteAct);
  editMenu->addSeparator();
  editMenu->addAction(findAct);
  editMenu->addAction(autoCompleteAct);
  editMenu->addSeparator();
  editMenu->addAction(configureAct);

  controlMenu = menuBar()->addMenu(tr("Control"));
  controlMenu->addAction(playAct);
  controlMenu->addAction(renderAct);
  controlMenu->addAction(externalEditorAct);
  controlMenu->addAction(externalPlayerAct);

  viewMenu = menuBar()->addMenu(tr("View"));
  viewMenu->addAction(showHelpAct);
  viewMenu->addAction(showConsole);
  viewMenu->addAction(showUtilitiesAct);
  viewMenu->addAction(showWidgetsAct);

  menuBar()->addSeparator();

  helpMenu = menuBar()->addMenu(tr("Help"));
  helpMenu->addAction(setHelpEntryAct);
  helpMenu->addSeparator();
  helpMenu->addAction(aboutAct);
  helpMenu->addAction(aboutQtAct);
}

void qutecsound::fillFileMenu()
{
  fileMenu->clear();
  fileMenu->addAction(newAct);
  fileMenu->addAction(openAct);
  fileMenu->addAction(saveAct);
  fileMenu->addAction(saveAsAct);
  fileMenu->addAction(reloadAct);
  fileMenu->addAction(closeTabAct);
  fileMenu->addSeparator();
  fileMenu->addAction(exitAct);
  fileMenu->addSeparator();
  recentMenu = fileMenu->addMenu(tr("Recent files"));
  for (int i = 0; i< recentFiles.size(); i++) {
    if (recentFiles[i] != "") {
      openRecentAct[i]->setText(recentFiles[i]);
      recentMenu->addAction(openRecentAct[i]);
    }
  }
}

void qutecsound::createToolBars()
{
  fileToolBar = addToolBar(tr("File"));
  fileToolBar->setObjectName("fileToolBar");
  fileToolBar->addAction(newAct);
  fileToolBar->addAction(openAct);
  fileToolBar->addAction(saveAct);

  editToolBar = addToolBar(tr("Edit"));
  editToolBar->setObjectName("editToolBar");
  editToolBar->addAction(undoAct);
  editToolBar->addAction(redoAct);
  editToolBar->addAction(cutAct);
  editToolBar->addAction(copyAct);
  editToolBar->addAction(pasteAct);

  controlToolBar = addToolBar(tr("Control"));
  controlToolBar->setObjectName("controlToolBar");
  controlToolBar->addAction(playAct);
  controlToolBar->addAction(stopAct);
  controlToolBar->addAction(renderAct);
  controlToolBar->addAction(externalEditorAct);
  controlToolBar->addAction(externalPlayerAct);

  configureToolBar = addToolBar(tr("Configure"));
  configureToolBar->setObjectName("configureToolBar");
  configureToolBar->addAction(configureAct);
  configureToolBar->addAction(showWidgetsAct);
  configureToolBar->addAction(showUtilitiesAct);
  configureToolBar->addAction(showConsole);
  configureToolBar->addAction(showHelpAct);
}

void qutecsound::createStatusBar()
{
  statusBar()->showMessage(tr("Ready"));
}

void qutecsound::readSettings()
{
  QSettings settings("csound", "qutecsound");
  settings.beginGroup("GUI");
  QPoint pos = settings.value("pos", QPoint(200, 200)).toPoint();
  QSize size = settings.value("size", QSize(600, 500)).toSize();
  resize(size);
  move(pos);
  restoreState(settings.value("dockstate").toByteArray());
  lastUsedDir = settings.value("lastuseddir", "").toString();
  lastFileDir = settings.value("lastfiledir", "").toString();
  recentFiles.clear();
  QAction *newAct;
  recentFiles.append(settings.value("recentFiles0", "").toString());
  newAct = new QAction(this);
  openRecentAct.append(newAct);
  connect(newAct, SIGNAL(triggered()), this, SLOT(openRecent0()));
  recentFiles.append(settings.value("recentFiles1", "").toString());
  newAct = new QAction(this);
  openRecentAct.append(newAct);
  connect(newAct, SIGNAL(triggered()), this, SLOT(openRecent1()));
  recentFiles.append(settings.value("recentFiles2", "").toString());
  newAct = new QAction(this);
  openRecentAct.append(newAct);
  connect(newAct, SIGNAL(triggered()), this, SLOT(openRecent2()));
  recentFiles.append(settings.value("recentFiles3", "").toString());
  newAct = new QAction(this);
  openRecentAct.append(newAct);
  connect(newAct, SIGNAL(triggered()), this, SLOT(openRecent3()));
  recentFiles.append(settings.value("recentFiles4", "").toString());
  newAct = new QAction(this);
  openRecentAct.append(newAct);
  connect(newAct, SIGNAL(triggered()), this, SLOT(openRecent4()));
  recentFiles.append(settings.value("recentFiles5", "").toString());
  newAct = new QAction(this);
  openRecentAct.append(newAct);
  connect(newAct, SIGNAL(triggered()), this, SLOT(openRecent5()));
  settings.endGroup();
  settings.beginGroup("Options");
  settings.beginGroup("Editor");
  m_options->font = settings.value("font", "Courier").toString();
  m_options->fontPointSize = settings.value("fontsize", 12).toDouble();
  m_options->consoleFont = settings.value("consolefont", "Courier").toString();
  m_options->consoleFontPointSize = settings.value("consolefontsize", 10).toDouble();
  m_options->colorVariables = settings.value("colorvariables", true).toBool();
  m_options->autoPlay = settings.value("autoplay", false).toBool();
  m_options->saveChanges = settings.value("savechanges", true).toBool();
  m_options->rememberFile = settings.value("rememberfile", true).toBool();
  m_options->saveWidgets = settings.value("savewidgets", true).toBool();
  lastFile = settings.value("lastfile", "").toString();
  settings.endGroup();
  settings.beginGroup("Run");
  m_options->useAPI = settings.value("useAPI", true).toBool();
  m_options->thread = settings.value("thread", false).toBool();
  m_options->bufferSize = settings.value("bufferSize", 1024).toInt();
  m_options->bufferSizeActive = settings.value("bufferSizeActive", false).toBool();
  m_options->HwBufferSize = settings.value("HwBufferSize", 1024).toInt();
  m_options->HwBufferSizeActive = settings.value("HwBufferSizeActive", false).toInt();
  m_options->dither = settings.value("dither", false).toBool();
  m_options->additionalFlags = settings.value("additionalFlags", "-d").toString();
  // Suppress displays for Mac by default as it crashes running in a separate thread.
#ifdef MACOSX
  m_options->additionalFlagsActive = settings.value("additionalFlagsActive", true).toBool();
#else
  m_options->additionalFlagsActive = settings.value("additionalFlagsActive", false).toBool();
#endif
  m_options->fileOverrideOptions = settings.value("fileOverrideOptions", true).toBool();
  m_options->fileAskFilename = settings.value("fileAskFilename", false).toBool();
  m_options->filePlayFinished = settings.value("filePlayFinished", false).toBool();
  m_options->fileFileType = settings.value("fileFileType", 0).toInt();
  m_options->fileSampleFormat = settings.value("fileSampleFormat", 1).toInt();
  m_options->fileInputFilenameActive = settings.value("fileInputFilenameActive", false).toBool();
  m_options->fileInputFilename = settings.value("fileInputFilename", "").toString();
  m_options->fileOutputFilenameActive = settings.value("fileOutputFilenameActive", false).toBool();
  m_options->fileOutputFilename = settings.value("fileOutputFilename", "").toString();
  m_options->rtOverrideOptions = settings.value("rtOverrideOptions", true).toBool();
  m_options->rtEnableWidgets = settings.value("rtEnableWidgets", true).toBool();
  m_options->rtAudioModule = settings.value("rtAudioModule", 0).toInt();
  m_options->rtInputDevice = settings.value("rtInputDevice", "adc").toString();
  m_options->rtOutputDevice = settings.value("rtOutputDevice", "dac").toString();
  m_options->rtJackName = settings.value("rtJackName", "").toString();
  m_options->rtMidiModule = settings.value("rtMidiModule", 0).toInt();
  m_options->rtMidiInputDevice = settings.value("rtMidiInputDevice", "0").toString();
  m_options->rtMidiOutputDevice = settings.value("rtMidiOutputDevice", "").toString();
  settings.endGroup();
  settings.beginGroup("Environment");
  m_options->csdocdir = settings.value("csdocdir", DEFAULT_HTML_DIR).toString();
  m_options->opcodedir = settings.value("opcodedir","").toString();
  m_options->opcodedirActive = settings.value("opcodedirActive","").toBool();
  m_options->sadir = settings.value("sadir","").toString();
  m_options->sadirActive = settings.value("sadirActive","").toBool();
  m_options->ssdir = settings.value("ssdir","").toString();
  m_options->ssdirActive = settings.value("ssdirActive","").toBool();
  m_options->sfdir = settings.value("sfdir","").toString();
  m_options->sfdirActive = settings.value("sfdirActive","").toBool();
  m_options->incdir = settings.value("incdir","").toString();
  m_options->incdirActive = settings.value("incdirActive","").toBool();
  m_options->opcodexmldir = settings.value("opcodexmldir", "").toString();
  m_options->opcodexmldirActive = settings.value("opcodexmldirActive","").toBool();
  settings.endGroup();
  settings.beginGroup("External");
  m_options->terminal = settings.value("terminal", DEFAULT_TERM_EXECUTABLE).toString();
//   m_options->browser = settings.value("browser", DEFAULT_BROWSER_EXECUTABLE).toString();
  m_options->waveeditor = settings.value("waveeditor",
                                         DEFAULT_WAVEEDITOR_EXECUTABLE
                                        ).toString();
  m_options->waveplayer = settings.value("waveplayer",
                                         DEFAULT_WAVEPLAYER_EXECUTABLE
                                        ).toString();
  settings.endGroup();
  settings.endGroup();
}

void qutecsound::writeSettings()
{
  QSettings settings("csound", "qutecsound");
  settings.beginGroup("GUI");
  settings.setValue("pos", pos());
  settings.setValue("size", size());
  settings.setValue("dockstate", saveState());
  settings.setValue("lastuseddir", lastUsedDir);
  settings.setValue("lastfiledir", lastFileDir);
  for (int i = 0; i < recentFiles.size();i++) {
    QString key = "recentFiles" + QString::number(i);
    settings.setValue(key, recentFiles[i]);
  }
  settings.endGroup();
  settings.beginGroup("Options");
  settings.beginGroup("Editor");
  settings.setValue("font", m_options->font );
  settings.setValue("fontsize", m_options->fontPointSize);
  settings.setValue("consolefont", m_options->consoleFont );
  settings.setValue("consolefontsize", m_options->consoleFontPointSize);
  settings.setValue("colorvariables", m_options->colorVariables);
  settings.setValue("autoplay", m_options->autoPlay);
  settings.setValue("savechanges", m_options->saveChanges);
  settings.setValue("rememberfile", m_options->rememberFile);
  settings.setValue("savewidgets", m_options->saveWidgets);
  settings.setValue("lastfile", documentPages[curPage]->fileName);
  settings.endGroup();
  settings.beginGroup("Run");
  settings.setValue("useAPI", m_options->useAPI);
  settings.setValue("thread", m_options->thread);
  settings.setValue("bufferSize", m_options->bufferSize);
  settings.setValue("bufferSizeActive", m_options->bufferSizeActive);
  settings.setValue("HwBufferSize",m_options->HwBufferSize);
  settings.setValue("HwBufferSizeActive", m_options->HwBufferSizeActive);
  settings.setValue("dither", m_options->dither);
  settings.setValue("additionalFlags", m_options->additionalFlags);
  settings.setValue("additionalFlagsActive", m_options->additionalFlagsActive);
  settings.setValue("fileOverrideOptions", m_options->fileOverrideOptions);
  settings.setValue("fileAskFilename", m_options->fileAskFilename);
  settings.setValue("filePlayFinished", m_options->filePlayFinished);
  settings.setValue("fileFileType", m_options->fileFileType);
  settings.setValue("fileSampleFormat", m_options->fileSampleFormat);
  settings.setValue("fileInputFilenameActive", m_options->fileInputFilenameActive);
  settings.setValue("fileInputFilename", m_options->fileInputFilename);
  settings.setValue("fileOutputFilenameActive", m_options->fileOutputFilenameActive);
  settings.setValue("fileOutputFilename", m_options->fileOutputFilename);
  settings.setValue("rtOverrideOptions", m_options->rtOverrideOptions);
  settings.setValue("rtEnableWidgets", m_options->rtEnableWidgets);
  settings.setValue("rtAudioModule", m_options->rtAudioModule);
  settings.setValue("rtInputDevice", m_options->rtInputDevice);
  settings.setValue("rtOutputDevice", m_options->rtOutputDevice);
  settings.setValue("rtJackName", m_options->rtJackName);
  settings.setValue("rtMidiModule", m_options->rtMidiModule);
  settings.setValue("rtMidiInputDevice", m_options->rtMidiInputDevice);
  settings.setValue("rtMidiOutputDevice", m_options->rtMidiOutputDevice);
  settings.endGroup();
  settings.beginGroup("Environment");
  settings.setValue("csdocdir", m_options->csdocdir);
  settings.setValue("opcodedir",m_options->opcodedir);
  settings.setValue("opcodedirActive",m_options->opcodedirActive);
  settings.setValue("sadir",m_options->sadir);
  settings.setValue("sadirActive",m_options->sadirActive);
  settings.setValue("ssdir",m_options->ssdir);
  settings.setValue("ssdirActive",m_options->ssdirActive);
  settings.setValue("sfdir",m_options->sfdir);
  settings.setValue("sfdirActive",m_options->sfdirActive);
  settings.setValue("incdir",m_options->incdir);
  settings.setValue("incdirActive",m_options->incdirActive);
  settings.setValue("opcodexmldir", m_options->opcodexmldir);
  settings.setValue("opcodexmldirActive",m_options->opcodexmldirActive);
  settings.endGroup();
  settings.beginGroup("External");
  settings.setValue("terminal", m_options->terminal);
//   settings.setValue("browser", m_options->browser);
  settings.setValue("waveeditor", m_options->waveeditor);
  settings.setValue("waveplayer", m_options->waveplayer);
  settings.endGroup();
  settings.endGroup();
}

int qutecsound::execute(QString executable, QString options)
{
  QStringList optionlist;
  optionlist = options.split(QRegExp("\\s+"));

#ifdef MACOSX
  QString commandLine = "open -a '" + executable + "' '" + options + "'";
  system(commandLine.toStdString().c_str());
#endif
#ifdef LINUX
  QString commandLine = executable + " " + options;
  system(commandLine.toStdString().c_str());
#endif
#ifdef WIN32
  QString commandLine = executable + (executable.startsWith("cmd")? " /k ": " ") + options;
  system(commandLine.toStdString().c_str());
#endif
  return 1;
}

void qutecsound::configureHighlighter()
{
  m_highlighter->setOpcodeNameList(opcodeTree->opcodeNameList());
}

bool qutecsound::maybeSave()
{
  for (int i = 0; i< documentPages.size(); i++) {
    if (documentPages[i]->document()->isModified()) {
      documentTabs->setCurrentIndex(i);
      changePage(i);
      QString message = tr("The document ")
          + (documentPages[i]->fileName != "" ? documentPages[i]->fileName: "untitled.csd")
          + tr("\nhas been modified.\nDo you want to save the changes before closing?");
      int ret = QMessageBox::warning(this, tr("QuteCsound"),
                                     message,
                                     QMessageBox::Yes | QMessageBox::Default,
                                     QMessageBox::No,
                                     QMessageBox::Cancel | QMessageBox::Escape);
      if (ret == QMessageBox::Yes) {
        save();
        closeTab();
      }
      else if (ret == QMessageBox::Cancel)
        return false;
    }
  }
  return true;
}

QString qutecsound::fixLineEndings(const QString &text)
{
  qDebug("n = %i  r = %i", text.count("\n"), text.count("\r"));
  return text;
}

bool qutecsound::loadFile(QString fileName)
{
  QFile file(fileName);
  if (!file.open(QFile::ReadOnly | QFile::Text)) {
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("Cannot read file %1:\n%2.")
                             .arg(fileName)
                             .arg(file.errorString()));
    return false;
  }
  //QTextStream in(&file);
  QApplication::setOverrideCursor(Qt::WaitCursor);
  DocumentPage *newPage = new DocumentPage(this);
  documentPages.append(newPage);
  documentTabs->addTab(newPage,"");
  curPage = documentPages.size() - 1;
  documentTabs->setCurrentIndex(curPage);
  textEdit = newPage;
  connectActions();
  QString text;
  while (!file.atEnd()) {
    QByteArray line = file.readLine().trimmed();
    text = text + QString(line);
    if (!line.contains("\n"))
      text += "\r\n";
  }
  //textEdit->setPlainText(fixLineEndings(in.readAll()));
//   textEdit->setPlainText(text);
  textEdit->setTextString(text);
  m_highlighter->setColorVariables(m_options->colorVariables);
  m_highlighter->setDocument(textEdit->document());
  QApplication::restoreOverrideCursor();

  textEdit->document()->setModified(false);
  if (fileName == ":/default.csd")
    fileName = QString("");
  documentPages[curPage]->fileName = fileName;
  setCurrentFile(fileName);
  setWindowModified(false);
  documentTabs->setTabIcon(curPage, modIcon);
  lastUsedDir = fileName;
  lastUsedDir.resize(fileName.lastIndexOf(QRegExp("[/]")));
  if (recentFiles.count(fileName) == 0 and fileName!="") {
    recentFiles.prepend(fileName);
    recentFiles.removeLast();
    fillFileMenu();
  }
  changeFont();
  statusBar()->showMessage(tr("File loaded"), 2000);
  return true;
}

void qutecsound::loadCompanionFile(const QString &fileName)
{
  QString companionFileName = fileName;
  if (fileName.endsWith(".orc")) {
   // fileName.replace(".orc", ".sco");
  }
  else if (fileName.endsWith(".sco")) {
    //fileName.replace(".sco", ".orc");
  }
  else
    return;
  if (QFile::exists(companionFileName))
    loadFile(companionFileName);
}

bool qutecsound::saveFile(const QString &fileName)
{
  QFile file(fileName);
  if (!file.open(QFile::WriteOnly | QFile::Text)) {
    QMessageBox::warning(this, tr("Application"),
                         tr("Cannot write file %1:\n%2.")
                             .arg(fileName)
                             .arg(file.errorString()));
    return false;
  }

  QTextStream out(&file);
  QApplication::setOverrideCursor(Qt::WaitCursor);
  if (m_options->saveWidgets)
    out << documentPages[curPage]->getFullText();
  else
    out << documentPages[curPage]->toPlainText();
  QApplication::restoreOverrideCursor();

  textEdit->document()->setModified(false);
  documentPages[curPage]->fileName = fileName;
  setCurrentFile(fileName);
  setWindowModified(false);
  documentTabs->setTabIcon(curPage, QIcon());
  lastUsedDir = fileName;
  lastUsedDir.resize(fileName.lastIndexOf(QRegExp("[/\\]")));
  if (recentFiles.count(fileName) == 0) {
    recentFiles.prepend(fileName);
    recentFiles.removeLast();
    fillFileMenu();
  }
  statusBar()->showMessage(tr("File saved"), 2000);
  return true;
}

void qutecsound::setCurrentFile(const QString &fileName)
{
  QString shownName;
  if (documentPages[curPage]->fileName.isEmpty())
    shownName = "untitled.csd";
  else
    shownName = strippedName(documentPages[curPage]->fileName);

  setWindowTitle(tr("%1[*] - %2").arg(shownName).arg(tr("QuteCsound")));
  documentTabs->setTabText(curPage, shownName);
  updateWidgets();
}

QString qutecsound::strippedName(const QString &fullFileName)
{
  return QFileInfo(fullFileName).fileName();
}

QString qutecsound::generateScript(bool realtime)
{
  QString script = "#!/bin/sh\n";
  QString cmdLine = "";
  if (m_options->opcodedirActive)
    script += "export OPCODEDIR=" + m_options->opcodedir + "\n";
  if (m_options->sadirActive)
    script += "export SADIR=" + m_options->sadir + "\n";
  if (m_options->ssdirActive)
    script += "export SSDIR=" + m_options->ssdir + "\n";
  if (m_options->sfdirActive)
    script += "export SFDIR=" + m_options->sfdir + "\n";
  if (m_options->ssdirActive)
    script += "export INCDIR=" + m_options->incdir + "\n";

  script += "cd " + QFileInfo(documentPages[curPage]->fileName).absoluteFilePath() + "\n";
#ifdef MACOSX
  cmdLine = "/usr/local/bin/csound ";
#else
  cmdLine = "csound ";
#endif
  if (documentPages[curPage]->companionFile != "") {
    if (documentPages[curPage]->fileName.endsWith(".orc"))
      cmdLine += "\""  + documentPages[curPage]->fileName
          + "\" \""+ documentPages[curPage]->companionFile + "\"";
    else
      cmdLine += "\""  + documentPages[curPage]->companionFile
          + "\" \""+ documentPages[curPage]->fileName + "\"";
  }
  else if (documentPages[curPage]->fileName.endsWith(".csd"))
    cmdLine += "\""  + documentPages[curPage]->fileName + "\"";
  cmdLine += m_options->generateCmdLineFlags(realtime);
  script += "echo \"" + cmdLine + "\"\n";
  script += cmdLine + "\n";
  script += "echo \"\nPress return to continue\"\n";
  script += "dummy_var=\"\"\n";
  script += "read dummy_var\n";
  script += "rm $0\n";
  return script;
}

void qutecsound::getCompanionFileName()
{
  QString fileName = "";
  QDialog dialog(this);
  dialog.resize(400, 200);
  dialog.setModal(true);
  QPushButton *button = new QPushButton(tr("Ok"));

  connect(button, SIGNAL(released()), &dialog, SLOT(accept()));
//   QVBoxLayout *layout = new QVBoxLayout(this)
//   layout->addWidget(button);

  QSplitter *splitter = new QSplitter(&dialog);
  QListWidget *list = new QListWidget(&dialog);
  QCheckBox *checkbox = new QCheckBox(tr("Do not ask again"), &dialog);
  splitter->addWidget(list);
  splitter->addWidget(checkbox);
  splitter->addWidget(button);
  splitter->resize(400, 200);
  splitter->setOrientation(Qt::Vertical);
  QString extensionComplement = "";
  if (documentPages[curPage]->fileName.endsWith(".orc"))
    extensionComplement = ".sco";
  else if (documentPages[curPage]->fileName.endsWith(".sco"))
    extensionComplement = ".orc";

  for (int i = 0; i < documentPages.size(); i++) {
    QString name = documentPages[i]->fileName;
    if (documentPages[i]->fileName.endsWith(extensionComplement))
      list->addItem(documentPages[i]->fileName);
  }
  QList<QListWidgetItem *> itemList = list->findItems(documentPages[curPage]->companionFile,
      Qt::MatchExactly);
  if (itemList.size() > 0)
    list->setCurrentItem(itemList[0]);
  dialog.exec();
  QListWidgetItem *item = list->currentItem();
  QString itemText = item->text();
  if (checkbox->isChecked())
    documentPages[curPage]->askForFile = false;
  documentPages[curPage]->companionFile = itemText;
  for (int i = 0; i < documentPages.size(); i++) {
    if (documentPages[i]->fileName == documentPages[curPage]->companionFile) {
      documentPages[i]->companionFile = documentPages[curPage]->fileName;
      documentPages[i]->askForFile = documentPages[curPage]->askForFile;
      break;
    }
  }
}


uintptr_t qutecsound::csThread(void *data)
{
  csoundUserData* udata = (csoundUserData*)data;
  MYFLT* pvalue;
  if(!udata->result) {
    unsigned int numWidgets = udata->qcs->widgetPanel->widgetCount();
    QVector<QString> channelNames;
    QVector<double> values;
    channelNames.resize(numWidgets);
    values.resize(numWidgets);
    while((csoundPerformKsmps(udata->csound) == 0)
        and (udata->PERF_STATUS == 1)) {
      if (udata->realtime && udata->qcs->m_options->rtEnableWidgets) {
        udata->qcs->widgetPanel->getValues(&channelNames, &values);
        for (int i = 0; i<channelNames.size(); i++) {
          if(csoundGetChannelPtr(udata->csound, &pvalue, channelNames[i].toStdString().c_str(),
             CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0)
          {
    //           qDebug("%s-%i", values[i].first.toStdString().c_str(), values[i].second);
            *pvalue = (MYFLT) values[i];
          }
          while (udata->qcs->widgetPanel->eventQueueSize > 0) {
            udata->qcs->widgetPanel->eventQueueSize--;
            udata->qcs->widgetPanel->eventQueue[udata->qcs->widgetPanel->eventQueueSize];
            char type = udata->qcs->widgetPanel->eventQueue[udata->qcs->widgetPanel->eventQueueSize][0].unicode();
            QStringList eventElements = udata->qcs->widgetPanel->eventQueue[udata->qcs->widgetPanel->eventQueueSize].remove(0,1).split(" ",QString::SkipEmptyParts);
//             qDebug("type %c line: %s", type, udata->qcs->widgetPanel->eventQueue[udata->qcs->widgetPanel->eventQueueSize].toStdString().c_str());
            MYFLT pFields[eventElements.size()];
            for (int j = 0; j < eventElements.size(); j++) {
              qDebug("%f", eventElements[j].toDouble());
              pFields[j] = (MYFLT) eventElements[j].toDouble();
            }
            csoundScoreEvent(udata->csound,type ,pFields, eventElements.size());

          }
        }
      }
    }
    csoundStop(udata->csound);
    csoundCleanup(udata->csound);
  }
  return 1;
}
