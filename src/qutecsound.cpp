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

// Structs for csound graphs
#include <cwindow.h>
#include "curve.h"

#ifdef WIN32
static const QString SCRIPT_NAME = "qutecsound_run_script.bat";
#else
static const QString SCRIPT_NAME = "./qutecsound_run_script.sh";
#endif

//csound performance thread function prototype
uintptr_t csThread(void *clientData);

//FIXME why does qutecsound not end when it receives a terminate signal?
qutecsound::qutecsound(QStringList fileNames)
{
  setWindowTitle("QuteCsound[*]");
  resize(660,350);
  setWindowIcon(QIcon(":/images/qtcs.png"));
  documentTabs = new QTabWidget (this);
  connect(documentTabs, SIGNAL(currentChanged(int)), this, SLOT(changePage(int)));
  curPage = -1;
  setCentralWidget(documentTabs);

  //TODO: free ud if switched to non threaded use
  ud = (CsoundUserData *)malloc(sizeof(CsoundUserData));
  ud->PERF_STATUS = 0;
  ud->qcs = this;
  perfMutex = csoundCreateMutex(0);

  exampleFiles.append(":/examples/miditest.csd");
  exampleFiles.append(":/examples/circle.csd");
  exampleFiles.append(":/examples/lineedit.csd");
  exampleFiles.append(":/examples/rms.csd");
  exampleFiles.append(":/examples/reinit.csd");
  exampleFiles.append(":/examples/noreinit.csd");
  exampleFiles.append(":/examples/stringchannels.csd");
  exampleFiles.append(":/examples/reservedchannels.csd");
  exampleFiles.append(":/examples/noisered.csd");

  m_options = new Options();

//   _configlists = new ConfigLists;

  m_console = new DockConsole(this);
  m_console->setObjectName("m_console");
//   m_console->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea);
  addDockWidget(Qt::BottomDockWidgetArea, m_console);
  helpPanel = new DockHelp(this);
  helpPanel->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea | Qt::LeftDockWidgetArea);
  helpPanel->setObjectName("helpPanel");
  helpPanel->show();
  connect(helpPanel, SIGNAL(openManualExample(QString)), this, SLOT(openManualExample(QString)));
  addDockWidget(Qt::RightDockWidgetArea, helpPanel);

  // WidgetPanel must be created before createAcctions since it contains the editAct action
  widgetPanel = new WidgetPanel(this);
  widgetPanel->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea |Qt::LeftDockWidgetArea);
  widgetPanel->setObjectName("widgetPanel");
  addDockWidget(Qt::RightDockWidgetArea, widgetPanel);
  connect(widgetPanel,SIGNAL(topLevelChanged(bool)), this, SLOT(widgetDockStateChanged(bool)));
  connect(widgetPanel,SIGNAL(dockLocationChanged(Qt::DockWidgetArea)),
          this, SLOT(widgetDockLocationChanged(Qt::DockWidgetArea)));

  readSettings();

  utilitiesDialog = new UtilitiesDialog(this, m_options/*, _configlists*/);
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

  if (!lastFiles.isEmpty()) {
    foreach (QString lastFile, lastFiles) {
      if (lastFile!="" and !lastFile.startsWith("untitled")) {
        loadFile(lastFile);
      }
    }
  }
  foreach (QString fileName, fileNames) {
    if (fileName!="") {
      loadFile(fileName);
    }
  }
  if (fileNames.size() > 0 and m_options->autoPlay) {
    play();
  }
  if (documentPages.size() == 0) {
    newFile();
  }

  changeFont();
  modIcon.addFile(":/images/modIcon2.png", QSize(), QIcon::Normal);
  modIcon.addFile(":/images/modIcon.png", QSize(), QIcon::Disabled);

  helpPanel->docDir = m_options->csdocdir;
  QString index = m_options->csdocdir + QString("/index.html");
  helpPanel->loadFile(index);

  applySettings();

  csound = NULL;
  int init = csoundInitialize(0,0,0);
  if (init<0) {
    qDebug("Error initializing Csound!");
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("Error initializing Csound!\nQutecsound will probably crash if you try to run Csound."));
  }
  else if (init>0) {
    qDebug("Csound already initialized.");
  }
  queueTimer = new QTimer(this);
  queueTimer->setSingleShot (true);
  connect(queueTimer, SIGNAL(timeout()), this, SLOT(dispatchQueues()));
}

qutecsound::~qutecsound()
{
}

void qutecsound::messageCallback_NoThread(CSOUND *csound,
                                          int /*attr*/,
                                          const char *fmt,
                                          va_list args)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  DockConsole *console = ud->qcs->m_console;
  QString msg;
  msg = msg.vsprintf(fmt, args);
  console->appendMessage(msg);
  ud->qcs->widgetPanel->appendMessage(msg);
  console->update();
}

void qutecsound::messageCallback_Thread(CSOUND *csound,
                                          int /*attr*/,
                                          const char *fmt,
                                          va_list args)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  QString msg;
  msg = msg.vsprintf(fmt, args);
//   csoundLockMutex(ud->qcs->perfMutex);
  ud->qcs->queueMessage(msg);
//   csoundUnlockMutex(ud->qcs->perfMutex);
}

void qutecsound::messageCallback_Devices(CSOUND *csound,
                                         int /*attr*/,
                                         const char *fmt,
                                         va_list args)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  QStringList *messages = &ud->qcs->m_deviceMessages;
  QString msg;
  msg = msg.vsprintf(fmt, args);
  messages->append(msg);
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
  textEdit->setTabStopWidth(m_options->tabWidth);
  m_highlighter->setColorVariables(m_options->colorVariables);
  m_highlighter->setDocument(textEdit->document());
  curPage = index;
  setCurrentFile(documentPages[curPage]->fileName);
  connectActions();
  setWidgetPanelGeometry();
}

void qutecsound::updateWidgets()
{
  widgetPanel->loadWidgets(textEdit->getMacWidgetsText());
}

void qutecsound::openExample()
{
  QObject *sender = QObject::sender();
  if (sender == 0)
    return;
  QAction *action = dynamic_cast<QAction *>(sender);
  loadFile(action->data().toString());
  saveAs();
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
  loadFile(":/default.csd");
  documentPages[curPage]->fileName = "";
  setWindowModified(false);
  documentTabs->setTabIcon(curPage, modIcon);
  documentPages[curPage]->setTabStopWidth(m_options->tabWidth);
  connectActions();
}

void qutecsound::open()
{
  QString fileName = "";
  fileName = QFileDialog::getOpenFileName(this, tr("Open File"), lastUsedDir , tr("Csound Files (*.csd *.orc *.sco)"));
  for (int i = 0; i < documentPages.size(); i++) {
    if (fileName == documentPages[i]->fileName) {
      documentTabs->setCurrentIndex(i);
      changePage(i);
      statusBar()->showMessage(tr("File already open"), 10000);
      return;
    }
  }
  if (!fileName.isEmpty()) {
    loadCompanionFile(fileName);
    loadFile(fileName);
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
  if (documentPages[curPage]->fileName.isEmpty()) {
    return saveAs();
  }
  else if (documentPages[curPage]->readOnly){
    if (saveAs()) {
      documentPages[curPage]->readOnly = false;
      return true;
    }
    else {
      return false;
    }
  }
  else {
    return saveFile(documentPages[curPage]->fileName);
  }
}

void qutecsound::copy()
{
  if (documentPages[curPage]->hasFocus()) {
    documentPages[curPage]->copy();
  }
  else if (helpPanel->hasFocus()) {
    helpPanel->copy();
  }
  else
    widgetPanel->copy();
}

void qutecsound::cut()
{
  if (documentPages[curPage]->hasFocus()) {
    documentPages[curPage]->cut();
  }
  else
    widgetPanel->cut();
}

void qutecsound::paste()
{
  if (documentPages[curPage]->hasFocus()) {
    documentPages[curPage]->paste();
  }
  else
    widgetPanel->paste();
}

void qutecsound::undo()
{
  if (documentPages[curPage]->hasFocus()) {
    documentPages[curPage]->undo();
  }
  else
    widgetPanel->undo();
}

void qutecsound::redo()
{
  if (documentPages[curPage]->hasFocus()) {
    documentPages[curPage]->redo();
  }
  else
    widgetPanel->redo();
}

void qutecsound::controlD()
{
  if (documentPages[curPage]->hasFocus()) {
    documentPages[curPage]->comment();
  }
  else
    widgetPanel->duplicate();
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
    else {
      newFile();
      curPage = 0;
    }
  }
  documentPages.remove(curPage);
  documentTabs->removeTab(curPage);
//   if (curPage > 0) {
//     curPage--;
//   }
  documentTabs->setCurrentIndex(curPage);
  textEdit = documentPages[curPage];
  textEdit->setTabStopWidth(m_options->tabWidth);
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
  QDialog dialog(this);
  dialog.resize(700, 350);
  dialog.setModal(true);
  QPushButton *okButton = new QPushButton(tr("Ok"));
  QPushButton *cancelButton = new QPushButton(tr("Cancel"));

  connect(okButton, SIGNAL(released()), &dialog, SLOT(accept()));
  connect(cancelButton, SIGNAL(released()), &dialog, SLOT(reject()));

  QGridLayout *layout = new QGridLayout(&dialog);
  QListWidget *list1 = new QListWidget(&dialog);
  QListWidget *list2 = new QListWidget(&dialog);
  layout->addWidget(list1, 0, 0);
  layout->addWidget(list2, 0, 1);
  layout->addWidget(okButton, 1,0);
  layout->addWidget(cancelButton, 1,1);
//   layout->resize(400, 200);

  for (int i = 0; i < documentPages.size(); i++) {
    QString name = documentPages[i]->fileName;
    if (documentPages[i]->fileName.endsWith(".orc"))
      list1->addItem(documentPages[i]->fileName);
    else if (documentPages[i]->fileName.endsWith(".sco"))
      list2->addItem(documentPages[i]->fileName);
  }
  QList<QListWidgetItem *> itemList = list1->findItems(documentPages[curPage]->fileName,
      Qt::MatchExactly);
  if (itemList.size() > 0)
    list1->setCurrentItem(itemList[0]);
  QString name = documentPages[curPage]->fileName;
  QList<QListWidgetItem *> itemList2 = list2->findItems(name.replace(".orc", ".sco"),
      Qt::MatchExactly);
  if (itemList2.size() > 0)
    list2->setCurrentItem(itemList2[0]);
  if (itemList.size() == 0 or itemList.size() == 0) {
    QMessageBox::warning(this, tr("Join"),
                        tr("Please open the orc and sco files in QuteCsound first!"));
    return;
  }
  if (dialog.exec() == QDialog::Accepted) {
    QString orcText = "";
    QString scoText = "";
    for (int i = 0; i < documentPages.size(); i++) {
      QString name = documentPages[i]->fileName;
      if (name == list1->currentItem()->text())
        orcText = documentPages[i]->getFullText();
      else if (name == list2->currentItem()->text())
        scoText = documentPages[i]->getFullText();
    }
    QString text = "<CsoundSynthesizer>\n<CsOptions>\n</CsOptions>\n<CsInstruments>\n";
    text += orcText;
    text += "</CsInstruments>\n<CsScore>\n";
    text += scoText;
    text += "</CsScore>\n</CsoundSynthesizer>\n";
    newFile();
    documentPages[curPage]->setTextString(text);
  }
  else {
//     qDebug("qutecsound::join() : No Action");
  }
}

// void qutecsound::edit(bool active)
// {
//   widgetPanel->activateEditMode(active);
// }

void qutecsound::play(bool realtime)
{
  if (ud->PERF_STATUS == 1) {
    stop();
    return;
  }
  widgetPanel->eventQueueSize = 0; //Flush events gathered while idle
  outValueQueue.clear();
  outStringQueue.clear();
  messageQueue.clear();
  if (documentPages[curPage]->fileName.isEmpty()) {
    if (!saveAs()) {
      playAct->setChecked(false);
      return;
    }
  }
  else if (documentPages[curPage]->document()->isModified()) {
    if (m_options->saveChanges)
      if (!save()) {
        playAct->setChecked(false);
        return;
      }
  }
  QString fileName, fileName2;
  fileName = documentPages[curPage]->fileName;
  if (!fileName.endsWith(".csd")) {
    if (documentPages[curPage]->askForFile)
      getCompanionFileName();
    fileName2 = documentPages[curPage]->companionFile;
  }
  if (m_options->enableWidgets and m_options->showWidgetsOnRun) {
    widgetPanel->setVisible(true);
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
      playAct->setChecked(false);
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
    // TODO use: PUBLIC int csoundSetGlobalEnv(const char *name, const char *value);
    int argc = m_options->generateCmdLine(argv, realtime, fileName, fileName2);
    widgetPanel->clearGraphs();
    csound=csoundCreate(0);
    csoundReset(csound);
    csoundSetHostData(csound, (void *) ud);

    if(m_options->thread) {
      csoundSetMessageCallback(csound, &qutecsound::messageCallback_Thread);
    }
    else {
      csoundSetMessageCallback(csound, &qutecsound::messageCallback_NoThread);
    }
    qDebug("Command Line:");
    for (int index=0; index< argc; index++) {
      fprintf(stderr, "%s ",argv[index]);
    }
    fprintf(stderr, "\n");
    int result=csoundCompile(csound,argc,argv);

    csoundSetIsGraphable(csound, true);
    csoundSetMakeGraphCallback(csound, &qutecsound::makeGraphCallback);
    csoundSetDrawGraphCallback(csound, &qutecsound::drawGraphCallback);
    csoundSetKillGraphCallback(csound, &qutecsound::killGraphCallback);
    csoundSetExitGraphCallback(csound, &qutecsound::exitGraphCallback);

    emit(dispatchQueues()); //To dispatch messages produced in compilation.
    if (result!=CSOUND_SUCCESS) {
      qDebug("Csound compile failed!");
      csoundStop(csound);
      free(argv);
      csoundCleanup(csound);
      csoundDestroy(csound);  //FIXME Had to destroy csound every run otherwise FLTK widgets crash...
      playAct->setChecked(false);
      return;
    }
    if (m_options->invalueEnabled and m_options->enableWidgets) {
      csoundSetInputValueCallback(csound, &qutecsound::inputValueCallback);
      csoundSetOutputValueCallback(csound, &qutecsound::outputValueCallback);
    }
    else {
      csoundSetInputValueCallback(csound, NULL);
      csoundSetOutputValueCallback(csound, NULL);
    }
    ud->csound = csound;
//     ud->realtime = realtime;
    ud->result = result;
    ud->PERF_STATUS=1;
    unsigned int numWidgets = widgetPanel->widgetCount();
    ud->qcs->channelNames.resize(numWidgets*2);
    ud->qcs->values.resize(numWidgets*2);
    ud->qcs->stringValues.resize(numWidgets*2);
    queueTimer->start(QCS_QUEUETIMER_TIME);
    if(m_options->thread) {
#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
      perfThread = new CsoundPerformanceThread(csound);
      perfThread->SetProcessCallback(qutecsound::csThread, (void*)ud);
      perfThread->Play();
#else
      ThreadID = csoundCreateThread(qutecsound::csThread, (void*)ud);
#endif
    }
    else {
      while(ud->PERF_STATUS == 1 && csoundPerformKsmps(csound)==0) {
        qApp->processEvents();
        if (ud->qcs->m_options->enableWidgets) {
          widgetPanel->getValues(&channelNames, &values, &stringValues);
          if (ud->qcs->m_options->chngetEnabled) {
            readWidgetValues(ud);
            writeWidgetValues(ud);
          }
          processEventQueue(ud);
        }
      }
      stop();
    }
    free(argv);
#ifdef MACOSX
// Put menu bar back
    SetMenuBar(menuBarHandle);
#endif
  }
  else {  // Run in external shell (useAPI == false)
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
    playAct->setChecked(false);
  }
}

void qutecsound::stop()
{
  qDebug("qutecsound::stop()");
  if (ud->PERF_STATUS == 1) {
    ud->PERF_STATUS = 0;
  }
  else {
    return;
  }
  if (m_options->thread) {
#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
  perfThread->Stop();
  perfThread->Join();
#else
  csoundStop(csound);
  csoundJoinThread(ThreadID);

#endif
  csoundCleanup(csound);
#ifdef MACOSX
// Put menu bar back
    SetMenuBar(menuBarHandle);
#endif
  }
  csoundDestroy(csound);
  playAct->setChecked(false);
  if (m_options->enableWidgets and m_options->showWidgetsOnRun) {
    //widgetPanel->setVisible(false);
  }
}

// void qutecsound::selectMidiOutDevice(QPoint pos)
// {
//   QList<QPair<QString, QString> > devs = ConfigDialog::getMidiInputDevices();
//   QMenu menu;
// 
//   for (int i = 0; i < devs.size(); i++) {
//     QAction *action = menu.addAction(devs[i].first/*, this, SLOT()*/);
//     action->setData(devs[i].second);
//   }
//   menu.exec();
// }
// 
// void qutecsound::selectMidiInDevice(QPoint pos)
// {
// }
// 
// void qutecsound::selectAudioOutDevice(QPoint pos)
// {
// }
// 
// void qutecsound::selectAudioInDevice(QPoint pos)
// {
// }

void qutecsound::render()
{
  if (m_options->fileAskFilename) {
    QFileDialog dialog(this,tr("Output Filename"),lastFileDir);
    dialog.setAcceptMode(QFileDialog::AcceptSave);
    dialog.setConfirmOverwrite(false);
    QString filter = QString(_configlists.fileTypeLongNames[m_options->fileFileType] + " Files ("
        + _configlists.fileTypeExtensions[m_options->fileFileType] + ")");
    dialog.setFilter(filter);
    if (dialog.exec()) {
      QString extension = _configlists.fileTypeExtensions[m_options->fileFileType];
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

void qutecsound::openManualExample(QString fileName)
{
  loadFile(fileName);
}

void qutecsound::openExternalBrowser()
{
  QTextCursor cursor = textEdit->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  if (m_options->csdocdir != "") {
    QString file =  m_options->csdocdir + "/" + cursor.selectedText() + ".html";
    execute(m_options->browser, file);
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

void qutecsound::about()
{
  QString text = tr("by: Andres Cabrera\nReleased under the GPL V3\nVersion ");
  text += QUTECSOUND_VERSION;
  QMessageBox::about(this, tr("About QuteCsound"), text);
}

void qutecsound::documentWasModified()
{
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
  ConfigDialog *dialog = new ConfigDialog(this, m_options/*, _configlists*/);
  connect(dialog, SIGNAL(finished(int)), this, SLOT(applySettings(int)));
  dialog->show();
}

void qutecsound::applySettings(int /*result*/)
{
  m_highlighter->setDocument(textEdit->document());
  m_highlighter->setColorVariables(m_options->colorVariables);
  documentPages[curPage]->setTabStopWidth(m_options->tabWidth);
  widgetPanel->setEnabled(m_options->enableWidgets);
  Qt::ToolButtonStyle toolButtonStyle = (m_options->iconText?
      Qt::ToolButtonTextUnderIcon: Qt::ToolButtonIconOnly);
  fileToolBar->setToolButtonStyle(toolButtonStyle);
  editToolBar->setToolButtonStyle(toolButtonStyle);
  controlToolBar->setToolButtonStyle(toolButtonStyle);
  configureToolBar->setToolButtonStyle(toolButtonStyle);
  widgetPanel->showTooltips(m_options->showTooltips);

  QString currentOptions = (m_options->useAPI ? tr("API") : tr("Console")) + " ";
  if (m_options->useAPI) {
    currentOptions +=  (m_options->thread ? tr("Thread") : tr("NoThread")) + " ";
  }
  currentOptions +=  (m_options->saveWidgets ? tr("SaveWidgets") : tr("DontSaveWidgets")) + " ";
  QString playOptions = " (Audio:" + _configlists.rtAudioNames[m_options->rtAudioModule] + " ";
  playOptions += "MIDI:" +  _configlists.rtMidiNames[m_options->rtMidiModule] + ")";
  playOptions += " (" + (m_options->rtUseOptions? tr("UseQuteCsoundOptions"): tr("DiscardQuteCsoundOptions"));
  playOptions += " " + (m_options->rtOverrideOptions? tr("OverrideCsOptions"): tr("")) + ") ";
  playOptions += currentOptions;
  QString renderOptions = " (" + (m_options->fileUseOptions? tr("UseQuteCsoundOptions"): tr("DiscardQuteCsoundOptions")) + " ";
  renderOptions +=  "" + (m_options->fileOverrideOptions? tr("OverrideCsOptions"): tr("")) + ") ";
  renderOptions += currentOptions;
  playAct->setStatusTip(tr("Play") + playOptions);
  renderAct->setStatusTip(tr("Render to file") + renderOptions);
}

void qutecsound::checkSelection()
{
  //TODO add highlighting of words
}

void qutecsound::runUtility(QString flags)
{
  //TODO Run utilities from API using soundRunUtility(CSOUND *, const char *name, int argc, char **argv)
  qDebug("qutecsound::runUtility");
  if (m_options->useAPI) {
#ifdef MACOSX
//Remember menu bar to set it after FLTK grabs it
    menuBarHandle = GetMenuBar();
#endif
    m_console->clear();
    static char *argv[33];
    QString name = "";
    QStringList indFlags= flags.split(" ",QString::SkipEmptyParts);
    if (indFlags.size() < 2) {
      qDebug("qutecsound::runUtility: Error: empty flags");
      return;
    }
    if (indFlags[0] == "-U") {
      indFlags.removeAt(0);
      name = indFlags[0];
      indFlags.removeAt(0);
    }
    else {
      qDebug("qutecsound::runUtility: Error: unexpected flag!");
      return;
    }
    int index = 0;
    foreach (QString flag, indFlags) {
      argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
      strcpy(argv[index],flag.toStdString().c_str());
      index++;
      qDebug("%s",flag.toStdString().c_str());
    }
    int argc = indFlags.size();
    CSOUND *csoundU;
    csoundU=csoundCreate(0);
    csoundReset(csoundU);
    csoundSetHostData(csoundU, (void *) ud);
    csoundPreCompile(csoundU);
    // Utilities always run in the same thread as QuteCsound
    csoundSetMessageCallback(csoundU, &qutecsound::messageCallback_NoThread);
    csoundRunUtility(csoundU, name.toStdString().c_str(), argc, argv);
    csoundCleanup(csoundU);
    csoundDestroy(csoundU);
//     free(argv);
#ifdef MACOSX
// Put menu bar back
    SetMenuBar(menuBarHandle);
#endif
  }
  else {
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
  }
}

void qutecsound::dispatchQueues()
{
//   csoundLockMutex(perfMutex);
  foreach (QString msg, messageQueue) {
    m_console->appendMessage(msg);
    widgetPanel->appendMessage(msg);
  }
  QList<QString> channels = outValueQueue.keys();
  foreach (QString channel, channels) {
    widgetPanel->setValue(channel, outValueQueue[channel]);
  }
  channels = outStringQueue.keys();
  foreach (QString channel, channels) {
    widgetPanel->setValue(channel, outStringQueue[channel]);
  }
  processEventQueue(ud);
//   csoundUnlockMutex(perfMutex);
  messageQueue.clear();
  while (!curveBuffer.isEmpty()) {
    widgetPanel->newCurve(curveBuffer.pop());
  }
  if (ud->PERF_STATUS == 1) {
    queueTimer->start(QCS_QUEUETIMER_TIME);
  }
}

void qutecsound::widgetDockStateChanged(bool topLevel)
{
  qDebug("qutecsound::widgetDockStateChanged()");
  qApp->processEvents();
  if (documentPages.size() < 1)
    return; //necessary check, since widget panel is created early by consructor
  if (topLevel) {
//     widgetPanel->setGeometry(documentPages[curPage]->getWidgetPanelGeometry());
    QRect geometry = documentPages[curPage]->getWidgetPanelGeometry();
    widgetPanel->move(geometry.x(), geometry.y());
    widgetPanel->widget()->resize(geometry.width(), geometry.height());
    qDebug(" %i %i %i %i",geometry.x(), geometry.y(), geometry.width(), geometry.height());
  }
}

void qutecsound::widgetDockLocationChanged(Qt::DockWidgetArea area)
{
  qDebug("qutecsound::widgetDockLocationChanged() %i", area);
}

void qutecsound::createActions()
{
  // Actions that are not connected here depend on the active document, so they are
  // connected with connectActions() and are changed when the document changes.
  newAct = new QAction(QIcon(":/images/gtk-new.png"), tr("&New"), this);
  newAct->setShortcut(tr("Ctrl+N"));
  newAct->setStatusTip(tr("Create a new file"));
  newAct->setIconText("New");
  connect(newAct, SIGNAL(triggered()), this, SLOT(newFile()));

  openAct = new QAction(QIcon(":/images/gnome-folder.png"), tr("&Open..."), this);
  openAct->setShortcut(tr("Ctrl+O"));
  openAct->setStatusTip(tr("Open an existing file"));
  openAct->setIconText("Open");
  connect(openAct, SIGNAL(triggered()), this, SLOT(open()));

  reloadAct = new QAction(QIcon(":/images/gtk-reload.png"), tr("Reload"), this);
//   reloadAct->setShortcut(tr("Ctrl+O"));
  reloadAct->setStatusTip(tr("Reload file from disk, discarding changes"));
  reloadAct->setIconText("Reload");
  connect(reloadAct, SIGNAL(triggered()), this, SLOT(reload()));

  saveAct = new QAction(QIcon(":/images/gnome-dev-floppy.png"), tr("&Save"), this);
  saveAct->setShortcut(tr("Ctrl+S"));
  saveAct->setStatusTip(tr("Save the document to disk"));
  saveAct->setIconText("Save");
  connect(saveAct, SIGNAL(triggered()), this, SLOT(save()));

  saveAsAct = new QAction(tr("Save &As..."), this);
  saveAsAct->setStatusTip(tr("Save the document under a new name"));
  saveAsAct->setIconText("Save as");
  connect(saveAsAct, SIGNAL(triggered()), this, SLOT(saveAs()));

  closeTabAct = new QAction(tr("Close current tab"), this);
  closeTabAct->setShortcut(tr("Ctrl+W"));
  closeTabAct->setStatusTip(tr("Close current tab"));
  closeTabAct->setIconText("Close");
  connect(closeTabAct, SIGNAL(triggered()), this, SLOT(closeTab()));

  exitAct = new QAction(tr("E&xit"), this);
  exitAct->setShortcut(tr("Ctrl+Q"));
  exitAct->setStatusTip(tr("Exit the application"));
  exitAct->setIconText("Exit");
  connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

//   for (int i = 0; i < recentFiles.size(); i++) {
//     openRecentAct[i] = new QAction(tr("Recent 0"), this);
//     connect(openRecentAct[i], SIGNAL(triggered()), this, SLOT(openRecent()));
//   }

  undoAct = new QAction(QIcon(":/images/gtk-undo.png"), tr("Undo"), this);
  undoAct->setShortcut(tr("Ctrl+Z"));
  undoAct->setStatusTip(tr("Undo last action"));
  exitAct->setIconText("Undo");
  connect(undoAct, SIGNAL(triggered()), this, SLOT(undo()));

  redoAct = new QAction(QIcon(":/images/gtk-redo.png"), tr("Redo"), this);
  redoAct->setShortcut(tr("Shift+Ctrl+Z"));
  redoAct->setStatusTip(tr("Redo last action"));
  redoAct->setIconText("Redo");
  connect(redoAct, SIGNAL(triggered()), this, SLOT(redo()));

  cutAct = new QAction(QIcon(":/images/gtk-cut.png"), tr("Cu&t"), this);
  cutAct->setShortcut(tr("Ctrl+X"));
  cutAct->setStatusTip(tr("Cut the current selection's contents to the "
      "clipboard"));
  cutAct->setIconText("Cut");
  connect(cutAct, SIGNAL(triggered()), this, SLOT(cut()));

  copyAct = new QAction(QIcon(":/images/gtk-copy.png"), tr("&Copy"), this);
  copyAct->setShortcut(tr("Ctrl+C"));
  copyAct->setStatusTip(tr("Copy the current selection's contents to the "
      "clipboard"));
  copyAct->setIconText("Copy");
  connect(copyAct, SIGNAL(triggered()), this, SLOT(copy()));

  pasteAct = new QAction(QIcon(":/images/gtk-paste.png"), tr("&Paste"), this);
  pasteAct->setShortcut(tr("Ctrl+V"));
  pasteAct->setStatusTip(tr("Paste the clipboard's contents into the current "
      "selection"));
  pasteAct->setIconText("Paste");
  connect(pasteAct, SIGNAL(triggered()), this, SLOT(paste()));

  joinAct = new QAction(/*QIcon(":/images/gtk-paste.png"),*/ tr("&Join orc/sco"), this);
//   joinAct->setShortcut(tr("Ctrl+V"));
  joinAct->setStatusTip(tr("Join orc/sco files in a single csd file"));
  joinAct->setIconText("Join");
  connect(joinAct, SIGNAL(triggered()), this, SLOT(join()));

  findAct = new QAction(/*QIcon(":/images/gtk-paste.png"),*/ tr("&Find and Replace"), this);
  findAct->setShortcut(tr("Ctrl+F"));
  findAct->setStatusTip(tr("Find and replace strings in file"));
  findAct->setIconText("Find");
  connect(findAct, SIGNAL(triggered()), this, SLOT(findReplace()));

  autoCompleteAct = new QAction(tr("AutoComplete"), this);
  autoCompleteAct->setShortcut(tr("Alt+C"));
  autoCompleteAct->setStatusTip(tr("Autocomplete according to Status bar display"));
  autoCompleteAct->setIconText("AutoComplete");
  connect(autoCompleteAct, SIGNAL(triggered()), this, SLOT(autoComplete()));

  configureAct = new QAction(QIcon(":/images/control-center2.png"), tr("Configuration"), this);
//   autoCompleteAct->setShortcut(tr("Ctrl+ "));
  configureAct->setStatusTip(tr("Open configuration dialog"));
  configureAct->setIconText("Configure");
  connect(configureAct, SIGNAL(triggered()), this, SLOT(configure()));

//   editAct = new QAction(/*QIcon(":/images/gtk-media-play-ltr.png"),*/ tr("Widget Edit Mode"), this);
//   editAct->setShortcut(tr("Ctrl+E"));
//   editAct->setStatusTip(tr("Activate Edit Mode for Widget Panel"));
// //   editAct->setIconText("Play");
//   editAct->setCheckable(true);
//   connect(editAct, SIGNAL(triggered(bool)), this, SLOT(edit(bool)));
  editAct = static_cast<WidgetPanel *>(widgetPanel)->editAct;

  playAct = new QAction(QIcon(":/images/gtk-media-play-ltr.png"), tr("Play"), this);
  playAct->setShortcut(tr("Alt+R"));
  playAct->setStatusTip(tr("Play"));
  playAct->setIconText("Play");
  playAct->setCheckable(true);
  connect(playAct, SIGNAL(triggered()), this, SLOT(play()));

  stopAct = new QAction(QIcon(":/images/gtk-media-stop.png"), tr("Stop"), this);
  stopAct->setShortcut(tr("Alt+S"));
  stopAct->setStatusTip(tr("Stop"));
  stopAct->setIconText("Stop");
  connect(stopAct, SIGNAL(triggered()), this, SLOT(stop()));

  renderAct = new QAction(QIcon(":/images/render.png"), tr("Render to file"), this);
  renderAct->setShortcut(tr("Alt+F"));
  renderAct->setStatusTip(tr("Render to file"));
  renderAct->setIconText("Render");
  connect(renderAct, SIGNAL(triggered()), this, SLOT(render()));

  externalPlayerAct = new QAction(QIcon(":/images/playfile.png"), tr("Play Audiofile"), this);
//   externalPlayerAct->setShortcut(tr("Alt+F"));
  externalPlayerAct->setStatusTip(tr("Play rendered audiofile in External Editor"));
  externalPlayerAct->setIconText("Ext. Player");
  connect(externalPlayerAct, SIGNAL(triggered()), this, SLOT(openExternalPlayer()));

  externalEditorAct = new QAction(QIcon(":/images/editfile.png"), tr("Edit Audiofile"), this);
//   externalEditorAct->setShortcut(tr("Alt+F"));
  externalEditorAct->setStatusTip(tr("Edit rendered audiofile in External Editor"));
  externalEditorAct->setIconText("Ext. Editor");
  connect(externalEditorAct, SIGNAL(triggered()), this, SLOT(openExternalEditor()));

  showWidgetsAct = new QAction(QIcon(":/images/gnome-mime-application-x-diagram.png"), tr("Widgets"), this);
  showWidgetsAct->setCheckable(true);
  showWidgetsAct->setChecked(true);
  showWidgetsAct->setShortcut(tr("Alt+1"));
  showWidgetsAct->setStatusTip(tr("Show Realtime Widgets"));
  showWidgetsAct->setIconText("Widgets");
  connect(showWidgetsAct, SIGNAL(triggered(bool)), widgetPanel, SLOT(setVisible(bool)));
  connect(widgetPanel, SIGNAL(Close(bool)), showWidgetsAct, SLOT(setChecked(bool)));

  showHelpAct = new QAction(QIcon(":/images/gtk-info.png"), tr("Help Panel"), this);
  showHelpAct->setShortcut(tr("Alt+2"));
  showHelpAct->setCheckable(true);
  showHelpAct->setChecked(true);
  showHelpAct->setStatusTip(tr("Show the Csound Manual Panel"));
  showHelpAct->setIconText("Manual");
  connect(showHelpAct, SIGNAL(toggled(bool)), helpPanel, SLOT(setVisible(bool)));
  connect(helpPanel, SIGNAL(Close(bool)), showHelpAct, SLOT(setChecked(bool)));

  showGenAct = new QAction(/*QIcon(":/images/gtk-info.png"), */tr("GEN Routines"), this);
//   showGenAct->setShortcut(tr("Alt+1"));
  showGenAct->setStatusTip(tr("Show the GEN Routines Manual page"));
  connect(showGenAct, SIGNAL(triggered()), helpPanel, SLOT(showGen()));

  showOverviewAct = new QAction(/*QIcon(":/images/gtk-info.png"), */tr("Opcode Overview"), this);
//   showOverviewAct->setShortcut(tr("Alt+1"));
  showOverviewAct->setStatusTip(tr("Show opcode overview"));
  connect(showOverviewAct, SIGNAL(triggered()), helpPanel, SLOT(showOverview()));

  showConsoleAct = new QAction(QIcon(":/images/gksu-root-terminal.png"), tr("Output Console"), this);
  showConsoleAct->setShortcut(tr("Alt+3"));
  showConsoleAct->setCheckable(true);
  showConsoleAct->setChecked(true);
  showConsoleAct->setStatusTip(tr("Show Csound's message console"));
  showConsoleAct->setIconText("Console");
  connect(showConsoleAct, SIGNAL(toggled(bool)), m_console, SLOT(setVisible(bool)));
  connect(m_console, SIGNAL(Close(bool)), showConsoleAct, SLOT(setChecked(bool)));

  setHelpEntryAct = new QAction(QIcon(":/images/gtk-info.png"), tr("Show Opcode Entry"), this);
  setHelpEntryAct->setShortcut(tr("Shift+F1"));
  setHelpEntryAct->setStatusTip(tr("Show Opcode Entry in help panel"));
  setHelpEntryAct->setIconText("Manual for opcode");
  connect(setHelpEntryAct, SIGNAL(triggered()), this, SLOT(setHelpEntry()));

  browseBackAct = new QAction(tr("Help Back"), this);
  browseBackAct->setShortcut(QKeySequence(Qt::CTRL + Qt::Key_Left));
  browseBackAct->setStatusTip(tr("Go back in help page"));
  connect(browseBackAct, SIGNAL(triggered()), helpPanel, SLOT(browseBack()));

  browseForwardAct = new QAction(tr("Help Forward"), this);
  browseForwardAct->setShortcut(QKeySequence(Qt::CTRL + Qt::Key_Right));
  browseForwardAct->setStatusTip(tr("Go forward in help page"));
  connect(browseForwardAct, SIGNAL(triggered()), helpPanel, SLOT(browseForward()));

  externalBrowserAct = new QAction(/*QIcon(":/images/gtk-info.png"), */ tr("Show Opcode Entry in External Browser"), this);
  externalBrowserAct->setShortcut(tr("Shift+Alt+F1"));
  externalBrowserAct->setStatusTip(tr("Show Opcode Entry in external browser"));
  connect(externalBrowserAct, SIGNAL(triggered()), this, SLOT(openExternalBrowser()));

  showUtilitiesAct = new QAction(QIcon(":/images/gnome-devel.png"), tr("Utilities"), this);
  showUtilitiesAct->setShortcut(tr("Alt+4"));
  showUtilitiesAct->setCheckable(true);
  showUtilitiesAct->setChecked(false);
  showUtilitiesAct->setStatusTip(tr("Show the Csound Utilities dialog"));
  showUtilitiesAct->setIconText("Utilities");
  connect(showUtilitiesAct, SIGNAL(triggered(bool)), utilitiesDialog, SLOT(setVisible(bool)));
  connect(utilitiesDialog, SIGNAL(Close(bool)), showUtilitiesAct, SLOT(setChecked(bool)));

  commentAct = new QAction(tr("Comment"), this);
  commentAct->setStatusTip(tr("Comment selection"));
  commentAct->setShortcut(tr("Ctrl+D"));
  commentAct->setIconText("Comment");
  connect(commentAct, SIGNAL(triggered()), this, SLOT(controlD()));

  uncommentAct = new QAction(tr("Uncomment"), this);
  uncommentAct->setStatusTip(tr("Uncomment selection"));
  uncommentAct->setShortcut(tr("Shift+Ctrl+D"));
  uncommentAct->setIconText("Uncomment");
//   connect(uncommentAct, SIGNAL(triggered()), this, SLOT(uncomment()));

  indentAct = new QAction(tr("Indent"), this);
  indentAct->setStatusTip(tr("Indent selection"));
  indentAct->setShortcut(tr("Ctrl+I"));
  indentAct->setIconText("Indent");
//   connect(indentAct, SIGNAL(triggered()), this, SLOT(indent()));

  unindentAct = new QAction(tr("Unindent"), this);
  unindentAct->setStatusTip(tr("Unindent selection"));
  unindentAct->setShortcut(tr("Shift+Ctrl+I"));
  unindentAct->setIconText("Unindent");
//   connect(unindentAct, SIGNAL(triggered()), this, SLOT(unindent()));

  aboutAct = new QAction(tr("&About QuteCsound"), this);
  aboutAct->setStatusTip(tr("Show the application's About box"));
  aboutAct->setIconText("About");
  connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));

  aboutQtAct = new QAction(tr("About &Qt"), this);
  aboutQtAct->setStatusTip(tr("Show the Qt library's About box"));
  aboutQtAct->setIconText("About Qt");
  connect(aboutQtAct, SIGNAL(triggered()), qApp, SLOT(aboutQt()));

  //TODO Put this back when documentpage has focus
//   cutAct->setEnabled(false);
//   copyAct->setEnabled(false);

}

void qutecsound::connectActions()
{
//   disconnect(undoAct, 0, 0, 0);
//   disconnect(redoAct, 0, 0, 0);
//   disconnect(cutAct, 0, 0, 0);
//   disconnect(copyAct, 0, 0, 0);
//   disconnect(pasteAct, 0, 0, 0);

//   disconnect(commentAct, 0, 0, 0);
  disconnect(uncommentAct, 0, 0, 0);
  disconnect(indentAct, 0, 0, 0);
  disconnect(unindentAct, 0, 0, 0);
//   connect(commentAct, SIGNAL(triggered()), textEdit, SLOT(comment()));
  connect(uncommentAct, SIGNAL(triggered()), textEdit, SLOT(uncomment()));
  connect(indentAct, SIGNAL(triggered()), textEdit, SLOT(indent()));
  connect(unindentAct, SIGNAL(triggered()), textEdit, SLOT(unindent()));

  disconnect(textEdit, SIGNAL(copyAvailable(bool)), 0, 0);
  disconnect(textEdit, SIGNAL(copyAvailable(bool)), 0, 0);
  //TODO put these back but only when document has focus
//   connect(textEdit, SIGNAL(copyAvailable(bool)),
//           cutAct, SLOT(setEnabled(bool)));
//   connect(textEdit, SIGNAL(copyAvailable(bool)),
//           copyAct, SLOT(setEnabled(bool)));

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
  disconnect(widgetPanel, SIGNAL(moved(QPoint)),0,0);
  connect(widgetPanel, SIGNAL(moved(QPoint)),
          textEdit, SLOT(setWidgetPanelPosition(QPoint)) );
  disconnect(widgetPanel, SIGNAL(resized(QSize)),0,0);
  connect(widgetPanel, SIGNAL(resized(QSize)),
          textEdit, SLOT(setWidgetPanelSize(QSize)) );
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
  editMenu->addAction(commentAct);
  editMenu->addAction(uncommentAct);
  editMenu->addAction(indentAct);
  editMenu->addAction(unindentAct);
  editMenu->addSeparator();
  editMenu->addAction(joinAct);
  editMenu->addSeparator();
  editMenu->addAction(editAct);
  editMenu->addSeparator();
  editMenu->addAction(configureAct);

  controlMenu = menuBar()->addMenu(tr("Control"));
  controlMenu->addAction(playAct);
  controlMenu->addAction(renderAct);
  controlMenu->addAction(externalEditorAct);
  controlMenu->addAction(externalPlayerAct);

  viewMenu = menuBar()->addMenu(tr("View"));
  viewMenu->addAction(showWidgetsAct);
  viewMenu->addAction(showHelpAct);
  viewMenu->addAction(showConsoleAct);
  viewMenu->addAction(showUtilitiesAct);

  QMenu *examplesMenu = menuBar()->addMenu(tr("Examples"));
  foreach (QString fileName, exampleFiles) {
    QString name = fileName.mid(fileName.lastIndexOf("/") + 1);
    QAction *newAction = examplesMenu->addAction(name);
    newAction->setData(fileName);
    connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
  }

  menuBar()->addSeparator();

  helpMenu = menuBar()->addMenu(tr("Help"));
  helpMenu->addAction(setHelpEntryAct);
  helpMenu->addAction(externalBrowserAct);
  helpMenu->addSeparator();
  helpMenu->addAction(showOverviewAct);
  helpMenu->addAction(showGenAct);
  helpMenu->addSeparator();
  helpMenu->addAction(browseBackAct);
  helpMenu->addAction(browseForwardAct);
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
  configureToolBar->addAction(showHelpAct);
  configureToolBar->addAction(showConsoleAct);
  configureToolBar->addAction(showUtilitiesAct);

  Qt::ToolButtonStyle toolButtonStyle = (m_options->iconText?
      Qt::ToolButtonTextUnderIcon: Qt::ToolButtonIconOnly);
  fileToolBar->setToolButtonStyle(toolButtonStyle);
  editToolBar->setToolButtonStyle(toolButtonStyle);
  controlToolBar->setToolButtonStyle(toolButtonStyle);
  configureToolBar->setToolButtonStyle(toolButtonStyle);
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
  m_options->tabWidth = settings.value("tabWidth", 40).toInt();
  m_options->colorVariables = settings.value("colorvariables", true).toBool();
  m_options->autoPlay = settings.value("autoplay", false).toBool();
  m_options->saveChanges = settings.value("savechanges", true).toBool();
  m_options->rememberFile = settings.value("rememberfile", true).toBool();
  m_options->saveWidgets = settings.value("savewidgets", true).toBool();
  m_options->iconText = settings.value("iconText", true).toBool();
  m_options->invalueEnabled = settings.value("invalueEnabled", true).toBool();
  m_options->chngetEnabled = settings.value("chngetEnabled", false).toBool();
  m_options->showWidgetsOnRun = settings.value("showWidgetsOnRun", true).toBool();
  m_options->showTooltips = settings.value("showTooltips", true).toBool();
  lastFiles = settings.value("lastfiles", "").toStringList();
  settings.endGroup();
  settings.beginGroup("Run");
  m_options->useAPI = settings.value("useAPI", true).toBool();
  m_options->thread = settings.value("thread", false).toBool();
  m_options->bufferSize = settings.value("bufferSize", 1024).toInt();
  m_options->bufferSizeActive = settings.value("bufferSizeActive", false).toBool();
  m_options->HwBufferSize = settings.value("HwBufferSize", 1024).toInt();
  m_options->HwBufferSizeActive = settings.value("HwBufferSizeActive", false).toBool();
  m_options->dither = settings.value("dither", false).toBool();
  m_options->additionalFlags = settings.value("additionalFlags", "-d").toString();
  // FIXME Suppress displays for Mac by default as it crashes running in a separate thread.
#ifdef MACOSX
  m_options->additionalFlagsActive = settings.value("additionalFlagsActive", true).toBool();
#else
  m_options->additionalFlagsActive = settings.value("additionalFlagsActive", false).toBool();
#endif
  m_options->fileUseOptions = settings.value("fileUseOptions", true).toBool();
  m_options->fileOverrideOptions = settings.value("fileOverrideOptions", false).toBool();
  m_options->fileAskFilename = settings.value("fileAskFilename", false).toBool();
  m_options->filePlayFinished = settings.value("filePlayFinished", false).toBool();
  m_options->fileFileType = settings.value("fileFileType", 0).toInt();
  m_options->fileSampleFormat = settings.value("fileSampleFormat", 1).toInt();
  m_options->fileInputFilenameActive = settings.value("fileInputFilenameActive", false).toBool();
  m_options->fileInputFilename = settings.value("fileInputFilename", "").toString();
  m_options->fileOutputFilenameActive = settings.value("fileOutputFilenameActive", false).toBool();
  m_options->fileOutputFilename = settings.value("fileOutputFilename", "").toString();
  m_options->rtUseOptions = settings.value("rtUseOptions", true).toBool();
  m_options->rtOverrideOptions = settings.value("rtOverrideOptions", false).toBool();
  m_options->enableWidgets = settings.value("enableWidgets", true).toBool();
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
  m_options->browser = settings.value("browser", DEFAULT_BROWSER_EXECUTABLE).toString();
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
  settings.setValue("tabWidth", m_options->tabWidth );
  settings.setValue("colorvariables", m_options->colorVariables);
  settings.setValue("autoplay", m_options->autoPlay);
  settings.setValue("savechanges", m_options->saveChanges);
  settings.setValue("rememberfile", m_options->rememberFile);
  settings.setValue("savewidgets", m_options->saveWidgets);
  settings.setValue("iconText", m_options->iconText);
  settings.setValue("enableWidgets", m_options->enableWidgets);
  settings.setValue("invalueEnabled", m_options->invalueEnabled);
  settings.setValue("chngetEnabled", m_options->chngetEnabled);
  settings.setValue("showWidgetsOnRun", m_options->showWidgetsOnRun);
  settings.setValue("showTooltips", m_options->showWidgetsOnRun);
  QStringList files;
  for (int i=0; i < documentPages.size(); i++ ) {
    files.append(documentPages[i]->fileName);
  }
  settings.setValue("lastfiles", files);
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
  settings.setValue("fileUseOptions", m_options->fileUseOptions);
  settings.setValue("fileOverrideOptions", m_options->fileOverrideOptions);
  settings.setValue("fileAskFilename", m_options->fileAskFilename);
  settings.setValue("filePlayFinished", m_options->filePlayFinished);
  settings.setValue("fileFileType", m_options->fileFileType);
  settings.setValue("fileSampleFormat", m_options->fileSampleFormat);
  settings.setValue("fileInputFilenameActive", m_options->fileInputFilenameActive);
  settings.setValue("fileInputFilename", m_options->fileInputFilename);
  settings.setValue("fileOutputFilenameActive", m_options->fileOutputFilenameActive);
  settings.setValue("fileOutputFilename", m_options->fileOutputFilename);
  settings.setValue("rtUseOptions", m_options->rtUseOptions);
  settings.setValue("rtOverrideOptions", m_options->rtOverrideOptions);
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
  settings.setValue("browser", m_options->browser);
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
  QString commandLine = executable + " " + options + "&";
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
        if (!save())
          return false;
//         closeTab();
      }
      else if (ret == QMessageBox::Cancel) {
        return false;
      }
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
  QApplication::setOverrideCursor(Qt::WaitCursor);
  DocumentPage *newPage = new DocumentPage(this);
  documentPages.append(newPage);
  documentTabs->addTab(newPage,"");
  curPage = documentPages.size() - 1;
  documentTabs->setCurrentIndex(curPage);
  textEdit = newPage;
  textEdit->setTabStopWidth(m_options->tabWidth);
  connectActions();
  if (fileName.startsWith(m_options->csdocdir))
    documentPages[curPage]->readOnly = true;
  QString text;
  while (!file.atEnd()) {
    QByteArray line = file.readLine();
    line.replace("\r\n", "\n");
    line.replace("\r", "\n");  //Change Mac returns to line endings
    QTextDecoder decoder(QTextCodec::codecForLocale());
    text = text + decoder.toUnicode(line);
    if (!line.endsWith("\n"))
      text += "\n";
  }
  //textEdit->setPlainText(fixLineEndings(in.readAll()));
//   textEdit->setPlainText(text);
  textEdit->setTextString(text);
  textEdit->setTabStopWidth(m_options->tabWidth);
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
  setWidgetPanelGeometry();
  return true;
}

void qutecsound::loadCompanionFile(const QString &fileName)
{
  QString companionFileName = fileName;
  if (fileName.endsWith(".orc")) {
    companionFileName.replace(".orc", ".sco");
  }
  else if (fileName.endsWith(".sco")) {
    companionFileName.replace(".sco", ".orc");
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
  if (fileName.isEmpty())
    shownName = "untitled.csd";
  else
    shownName = strippedName(fileName);

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
void qutecsound::setWidgetPanelGeometry()
{
  QRect geometry = documentPages[curPage]->getWidgetPanelGeometry();
  if (geometry.width() == 0)
    return;
  widgetPanel->setGeometry(geometry);
}

void qutecsound::readWidgetValues(CsoundUserData *ud)
{
  MYFLT* pvalue;
  for (int i = 0; i < ud->qcs->channelNames.size(); i++) {
    if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->values[i];
    }
    if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
       CSOUND_INPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
      char *string = (char *) pvalue;
      strcpy(string, ud->qcs->stringValues[i].toStdString().c_str());
    }
  }
}

void qutecsound::writeWidgetValues(CsoundUserData *ud)
{
  MYFLT* pvalue;
  for (int i = 0; i < ud->qcs->channelNames.size(); i++) {
    if (ud->qcs->channelNames[i] != "") {
      if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
          CSOUND_OUTPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
        ud->qcs->widgetPanel->setValue(i,*pvalue);
      }
      else if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
        CSOUND_OUTPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
        ud->qcs->widgetPanel->setValue(i,QString((char *)pvalue));
      }
    }
  }
}

void qutecsound::processEventQueue(CsoundUserData *ud)
{
  while (ud->qcs->widgetPanel->eventQueueSize > 0) {
    ud->qcs->widgetPanel->eventQueueSize--;
    ud->qcs->widgetPanel->eventQueue[ud->qcs->widgetPanel->eventQueueSize];
    char type = ud->qcs->widgetPanel->eventQueue[ud->qcs->widgetPanel->eventQueueSize][0].unicode();
    QStringList eventElements = ud->qcs->widgetPanel->eventQueue[ud->qcs->widgetPanel->eventQueueSize].remove(0,1).split(" ",QString::SkipEmptyParts);
            qDebug("type %c line: %s", type, ud->qcs->widgetPanel->eventQueue[ud->qcs->widgetPanel->eventQueueSize].toStdString().c_str());
    MYFLT pFields[eventElements.size()];
    for (int j = 0; j < eventElements.size(); j++) {
      pFields[j] = (MYFLT) eventElements[j].toDouble();
    }
    if (ud->PERF_STATUS == 1) {
      if (ud->qcs->m_options->thread) {
// #ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
//         ud->qcs->perfThread->ScoreEvent(0, type, eventElements.size(), pFields);
// #else
        csoundLockMutex(ud->qcs->perfMutex);
        csoundScoreEvent(ud->csound,type ,pFields, eventElements.size());
        csoundUnlockMutex(ud->qcs->perfMutex);
// #endif
      }
      else {
        csoundScoreEvent(ud->csound,type ,pFields, eventElements.size());
      }
    }
  }
}

void qutecsound::queueOutValue(QString channelName, double value)
{
  outValueQueue.insert(channelName, value);
}

void qutecsound::queueOutString(QString channelName, QString value)
{
  outStringQueue.insert(channelName, value);
}

void qutecsound::queueMessage(QString message)
{
  messageQueue << message;
}

#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
void qutecsound::csThread(void *data)
#else
uintptr_t qutecsound::csThread(void *data)
#endif
{
  CsoundUserData* udata = (CsoundUserData*)data;
  if(!udata->result) {
    unsigned int numWidgets = udata->qcs->widgetPanel->widgetCount();
    udata->qcs->channelNames.resize(numWidgets*2);
    udata->qcs->values.resize(numWidgets*2);
    udata->qcs->stringValues.resize(numWidgets*2);
    int perform = csoundPerformKsmps(udata->csound);
    while((perform == 0) and (udata->PERF_STATUS == 1)) {
      if (udata->qcs->m_options->enableWidgets) {
        udata->qcs->widgetPanel->getValues(&udata->qcs->channelNames,
                                            &udata->qcs->values,
                                            &udata->qcs->stringValues);
        if (udata->qcs->m_options->chngetEnabled) {
          writeWidgetValues(udata);
          readWidgetValues(udata);
        }
//         processEventQueue(udata);
      }
      perform = csoundPerformKsmps(udata->csound);
    }
  }
//   udata->qcs->perfThread->Stop();
//   udata->qcs->stop();
#ifdef QUTE_USE_CSOUNDPERFORMANCETHREAD
#else
  return 1;
#endif
}

QStringList qutecsound::runCsoundInternally(QStringList flags)
{
  static char *argv[33];
  int index = 0;
  foreach (QString flag, flags) {
    argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
    strcpy(argv[index],flag.toStdString().c_str());
    index++;
  }
  int argc = flags.size();
#ifdef MACOSX
//Remember menu bar to set it after FLTK grabs it
  menuBarHandle = GetMenuBar();
#endif
  CSOUND *csoundD;
  csoundD=csoundCreate(0);
  csoundReset(csoundD);
  csoundSetHostData(csoundD, (void *) ud);
  m_deviceMessages.clear();
  csoundSetMessageCallback(csoundD, &qutecsound::messageCallback_Devices);
  int result = csoundCompile(csoundD,argc,argv);
  if(!result){
    while(csoundPerformKsmps(csound)==0);
  }

  csoundCleanup(csoundD);
  csoundDestroy(csoundD);

#ifdef MACOSX
// Put menu bar back
  SetMenuBar(menuBarHandle);
#endif
  return m_deviceMessages;
}

void qutecsound::newCurve(Curve * curve)
{
  curveBuffer.append(curve);
}

void qutecsound::outputValueCallback (CSOUND *csound,
                                     const char *channelName,
                                     MYFLT value)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  if (ud->PERF_STATUS == 1) {
    QString name = QString(channelName);
    csoundLockMutex(ud->qcs->perfMutex);
    if (name.startsWith('$')) {
      QString channelName = name;
      channelName.chop(name.size() - (int) value + 1);
      QString sValue = name;
      sValue = sValue.right(name.size() - (int) value);
      channelName.remove(0,1);
      ud->qcs->queueOutString(channelName, sValue);
    }
    else {
      ud->qcs->queueOutValue(name, value);
    }
    csoundUnlockMutex(ud->qcs->perfMutex);
  }
}

void qutecsound::inputValueCallback (CSOUND *csound,
                                     const char *channelName,
                                     MYFLT *value)
{
  // from csound to host
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  if (ud->PERF_STATUS == 1) {
    QString name = QString(channelName);
    csoundLockMutex(ud->qcs->perfMutex);
    if (name.startsWith('$')) {
      int index = ud->qcs->channelNames.indexOf(name.mid(1));
      char *string = (char *) value;
      if (index>=0) {
        strcpy(string, ud->qcs->stringValues[index].toStdString().c_str());
      }
      else {
        string[0] = '\0'; //empty c string
      }
    }
    else {
      int index = ud->qcs->channelNames.indexOf(name);
      if (index>=0)
        *value = (MYFLT) ud->qcs->values[index];
      else {
        *value = 0;
      }
    }
    csoundUnlockMutex(ud->qcs->perfMutex);
  }
}


void qutecsound::makeGraphCallback(CSOUND *csound, WINDAT *windat, const char *name)
{
  qDebug("qutecsound::makeGraph()");
}

void qutecsound::drawGraphCallback(CSOUND *csound, WINDAT *windat)
{
  qDebug("qutecsound::drawGraph()");
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  windat->caption[CAPSIZE - 1] = 0; // Just in case...
  Polarity polarity;
    // translate polarities and hope the definition in Csound doesn't change.
  switch (windat->polarity) {
    case NEGPOL:
      polarity = POLARITY_NEGPOL;
      break;
    case POSPOL:
      polarity = POLARITY_POSPOL;
      break;
    case BIPOL:
      polarity = POLARITY_BIPOL;
      break;
    default:
      polarity = POLARITY_NOPOL;
  }
  Curve *curve
      = new Curve(windat->fdata,
                  windat->npts,
                  windat->caption,
                  polarity,
                  windat->max,
                  windat->min,
                  windat->absmax,
                  windat->oabsmax,
                  windat->danflag);
  ud->qcs->newCurve(curve);
}

void qutecsound::killGraphCallback(CSOUND *csound, WINDAT *windat)
{
  qDebug("qutecsound::killGraph()");
}

int qutecsound::exitGraphCallback(CSOUND *csound)
{
  qDebug("qutecsound::exitGraph()");
  return 0;
}

