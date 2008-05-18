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


#include <QtGui>
#include <QCloseEvent>
#include <QFileDialog>

#include <QTextEdit>
#include <QTextCursor>

#include "qutecsound.h"
#include "dockhelp.h"
#include "opentryparser.h"
#include "options.h"
#include "highlighter.h"
#include "configdialog.h"
#include "configlists.h"

#include <csound/CppSound.hpp>

#include <string>

#ifdef WIN32
static const QString SCRIPT_NAME = "qutecsound_run_script.bat";
#else
static const QString SCRIPT_NAME = "./qutecsound_run_script.sh";
#endif

#define DEFAULT_HTML_DIR "/home/andres/src/manual/html"
#define DEFAULT_TERM_EXECUTABLE "/usr/bin/xterm"

qutecsound::qutecsound(QString fileName)
{
  resize(660,350);
  textEdit = new QTextEdit;
  m_configlists = new ConfigLists;

  setCentralWidget(textEdit);

  helpPanel = new DockHelp(this);
  helpPanel->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea);
  addDockWidget(Qt::RightDockWidgetArea, helpPanel);

  helpPanel->show();

  createActions();
  createMenus();
  createToolBars();
  createStatusBar();

  m_options = new Options();

  readSettings();
  opcodeTree = new OpEntryParser(QString(m_options->opcodexmldir + "opcodes.xml"));
  m_highlighter = new Highlighter(textEdit->document());
  configureHighlighter();
  changeFont();

  fillFileMenu(); //Must be placed after readSettings to include recent Files

  connect(textEdit, SIGNAL(textChanged()),
          this, SLOT(documentWasModified()));
  connect(textEdit, SIGNAL(textChanged()),
          this, SLOT(syntaxCheck()));
  connect(textEdit, SIGNAL(cursorPositionChanged()),
          this, SLOT(syntaxCheck()));

  if (fileName=="")
    newFile();
  else
    loadFile(fileName);
}

qutecsound::~qutecsound()
{

}

void qutecsound::changeFont()
{
  textEdit->document()->setDefaultFont(QFont(m_options->font, m_options->fontPointSize));
}

void qutecsound::closeEvent(QCloseEvent *event)
{
  if (maybeSave()) {
    writeSettings();
    event->accept();
  } else {
    event->ignore();
  }
}

void qutecsound::newFile()
{
  if (maybeSave()) {
    QFile file("default.csd");
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
      QMessageBox::warning(this, tr("Application"),
                           tr("Cannot read default template:\n%1.")
                               .arg(file.errorString()));
      return;
    }
    QTextStream in(&file);
    textEdit->setText(in.readAll());
    setCurrentFile("");
    setMode(VIEW_CSD);
  }
}

void qutecsound::open()
{
  if (maybeSave()) {
    QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"), lastUsedDir , tr("Csound Files (*.csd *.orc *.sco)"));
    if (!fileName.isEmpty())
      loadFile(fileName);
  }
}

void qutecsound::openRecent0()
{
  if (maybeSave()) {
    QString fileName = recentFiles[0];
    if (!fileName.isEmpty())
      loadFile(fileName);
  }
}

void qutecsound::openRecent1()
{
  if (maybeSave()) {
    QString fileName = recentFiles[1];
    if (!fileName.isEmpty())
      loadFile(fileName);
  }
}

void qutecsound::openRecent2()
{
  if (maybeSave()) {
    QString fileName = recentFiles[2];
    if (!fileName.isEmpty())
      loadFile(fileName);
  }
}

void qutecsound::openRecent3()
{
  if (maybeSave()) {
    QString fileName = recentFiles[3];
    if (!fileName.isEmpty())
      loadFile(fileName);
  }
}

void qutecsound::openRecent4()
{
  if (maybeSave()) {
    QString fileName = recentFiles[4];
    if (!fileName.isEmpty())
      loadFile(fileName);
  }
}

void qutecsound::openRecent5()
{
  if (maybeSave()) {
    QString fileName = recentFiles[5];
    if (!fileName.isEmpty())
      loadFile(fileName);
  }
}

bool qutecsound::save()
{
  if (curFile.isEmpty()) {
    return saveAs();
  } else {
    return saveFile(curFile);
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

void qutecsound::play(bool realtime)
{
  if (curFile.isEmpty() || textEdit->document()->isModified())
    if (!saveAs())
      return;

  if (m_options->useAPI) {
    std::string csdText = textEdit->document()->toPlainText().toStdString();
    qDebug("%s", csdText.c_str());
    CppSound csound;
//     int argc = 1;
//     char *argv[] = {"csound"};
//     csound.initialize(argc, argv, 0);
    csound.setCSD(csdText);
    csound.exportForPerformance();
    csound.compile();
    if (csound.getIsCompiled())
      qDebug("IsCompiled");
    csound.perform();
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
  }
  else {
    QString script = generateScript(realtime);
    qDebug("%s", script.toStdString().c_str());
    QFile file(SCRIPT_NAME);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
      return;

    QTextStream out(&file);
    out << script;
    file.flush();
    file.close();
    file.setPermissions (QFile::ExeOwner| QFile::WriteOwner| QFile::ReadOwner);

    pid_t pid = fork();
    if( pid == 0 )  {
      //This has been tested to work with xterm and gnome-terminal
      // It doesn't work with konsole for some reason....
      execl(m_options->terminal.toStdString().c_str(),
            m_options->terminal.toStdString().c_str(),
            "-e",
            SCRIPT_NAME.toStdString().c_str(),
            NULL);
    }
  }

}

void qutecsound::render()
{
  if (m_options->fileAskFilename) {
    QString filename = QFileDialog::QFileDialog::getSaveFileName(this,tr("Output Filename"),m_options->ssdir);
    if (filename == "")
      return;
    m_options->fileOutputFilename = filename;
  }
  play(false);
}

void qutecsound::setHelpEntry()
{
  QTextCursor cursor = textEdit->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  if (m_options->csdocdir != "") {
    QString file =  m_options->csdocdir + "/" +cursor.selectedText() + ".html";
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

void qutecsound::about()
{
  QMessageBox::about(this, tr("About qutecsound"),
                     tr("by: Andres Cabrera\n"
                         "Based on the QScintilla example\n"
                         "Released under the GPL V3\n"));
}

void qutecsound::documentWasModified()
{
  setWindowModified(textEdit->document()->isModified());
}

void qutecsound::syntaxCheck()
{
  QTextCursor cursor = textEdit->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  QString opcodeName = cursor.selectedText();
  if (opcodeName=="")
    return;
  QString syntax = opcodeTree->getSyntax(opcodeName);
//   qDebug("syntax %s",syntax.toStdString().c_str());
  statusBar()->showMessage(syntax, 20000);
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
  dialog->show();
}

void qutecsound::createActions()
{
  //TODO improve and create missing actions
  newAct = new QAction(QIcon(":/filenew.xpm"), tr("&New"), this);
  newAct->setShortcut(tr("Ctrl+N"));
  newAct->setStatusTip(tr("Create a new file"));
  connect(newAct, SIGNAL(triggered()), this, SLOT(newFile()));

  openAct = new QAction(QIcon(":/fileopen.xpm"), tr("&Open..."), this);
  openAct->setShortcut(tr("Ctrl+O"));
  openAct->setStatusTip(tr("Open an existing file"));
  connect(openAct, SIGNAL(triggered()), this, SLOT(open()));

  saveAct = new QAction(QIcon(":/filesave.xpm"), tr("&Save"), this);
  saveAct->setShortcut(tr("Ctrl+S"));
  saveAct->setStatusTip(tr("Save the document to disk"));
  connect(saveAct, SIGNAL(triggered()), this, SLOT(save()));

  saveAsAct = new QAction(tr("Save &As..."), this);
  saveAsAct->setStatusTip(tr("Save the document under a new name"));
  connect(saveAsAct, SIGNAL(triggered()), this, SLOT(saveAs()));

  exitAct = new QAction(tr("E&xit"), this);
  exitAct->setShortcut(tr("Ctrl+Q"));
  exitAct->setStatusTip(tr("Exit the application"));
  connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

  for (int i = 0; i < recentFiles.size(); i++) {
    openRecentAct[i] = new QAction(tr("Recent 0"), this);
    connect(openRecentAct[i], SIGNAL(triggered()), this, SLOT(openRecent()));
  }

  undoAct = new QAction(/*QIcon(":/editcut.xpm"),*/ tr("Undo"), this);
  undoAct->setShortcut(tr("Ctrl+Z"));
  undoAct->setStatusTip(tr("Undo last action"));
  connect(undoAct, SIGNAL(triggered()), textEdit, SLOT(undo()));

  redoAct = new QAction(/*QIcon(":/editcut.xpm"),*/ tr("Redo"), this);
  redoAct->setShortcut(tr("Shift+Ctrl+Z"));
  redoAct->setStatusTip(tr("Redo last action"));
  connect(redoAct, SIGNAL(triggered()), textEdit, SLOT(redo()));

  cutAct = new QAction(QIcon(":/editcut.xpm"), tr("Cu&t"), this);
  cutAct->setShortcut(tr("Ctrl+X"));
  cutAct->setStatusTip(tr("Cut the current selection's contents to the "
      "clipboard"));
  connect(cutAct, SIGNAL(triggered()), textEdit, SLOT(cut()));

  copyAct = new QAction(QIcon(":/editcopy.xpm"), tr("&Copy"), this);
  copyAct->setShortcut(tr("Ctrl+C"));
  copyAct->setStatusTip(tr("Copy the current selection's contents to the "
      "clipboard"));
  connect(copyAct, SIGNAL(triggered()), textEdit, SLOT(copy()));

  pasteAct = new QAction(QIcon(":/editpaste.xpm"), tr("&Paste"), this);
  pasteAct->setShortcut(tr("Ctrl+V"));
  pasteAct->setStatusTip(tr("Paste the clipboard's contents into the current "
      "selection"));
  connect(pasteAct, SIGNAL(triggered()), textEdit, SLOT(paste()));

  autoCompleteAct = new QAction(tr("AutoComplete"), this);
  autoCompleteAct->setShortcut(tr("Ctrl+ "));
  autoCompleteAct->setStatusTip(tr("Autocomplete according to Status bar display"));
  connect(autoCompleteAct, SIGNAL(triggered()), this, SLOT(autoComplete()));

  configureAct = new QAction(tr("Configuration"), this);
//   autoCompleteAct->setShortcut(tr("Ctrl+ "));
  configureAct->setStatusTip(tr("Open configuration dialog"));
  connect(configureAct, SIGNAL(triggered()), this, SLOT(configure()));

  playAct = new QAction(tr("Play"), this);
//   playAct->setShortcut(tr("Ctrl+Q"));
//   playAct->setStatusTip(tr("Play"));
  connect(playAct, SIGNAL(triggered()), this, SLOT(play()));

  renderAct = new QAction(tr("Render"), this);
//   playAct->setShortcut(tr("Ctrl+Q"));
//   playAct->setStatusTip(tr("Play"));
  connect(renderAct, SIGNAL(triggered()), this, SLOT(render()));

  showHelpAct = new QAction(tr("Show Help Panel"), this);
//   playAct->setShortcut(tr("Ctrl+Q"));
//   playAct->setStatusTip(tr("Play"));
  showHelpAct->setCheckable(true);
  showHelpAct->setChecked(true);
  connect(showHelpAct, SIGNAL(toggled(bool)), helpPanel, SLOT(setVisible(bool)));

  setHelpEntryAct = new QAction(tr("Show Opcode Entry"), this);
  setHelpEntryAct->setShortcut(tr("Shift+F1"));
  setHelpEntryAct->setStatusTip(tr("Show Opcode Entry in help panel"));
  connect(setHelpEntryAct, SIGNAL(triggered()), this, SLOT(setHelpEntry()));

  aboutAct = new QAction(tr("&About"), this);
  aboutAct->setStatusTip(tr("Show the application's About box"));
  connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));

  aboutQtAct = new QAction(tr("About &Qt"), this);
  aboutQtAct->setStatusTip(tr("Show the Qt library's About box"));
  connect(aboutQtAct, SIGNAL(triggered()), qApp, SLOT(aboutQt()));

  cutAct->setEnabled(false);
  copyAct->setEnabled(false);
  connect(textEdit, SIGNAL(copyAvailable(bool)),
          cutAct, SLOT(setEnabled(bool)));
  connect(textEdit, SIGNAL(copyAvailable(bool)),
          copyAct, SLOT(setEnabled(bool)));
}

void qutecsound::createMenus()
{
  fileMenu = menuBar()->addMenu(tr("&File"));

  editMenu = menuBar()->addMenu(tr("&Edit"));
  editMenu->addAction(undoAct);
  editMenu->addAction(redoAct);
  editMenu->addSeparator();
  editMenu->addAction(cutAct);
  editMenu->addAction(copyAct);
  editMenu->addAction(pasteAct);
  editMenu->addSeparator();
  editMenu->addAction(autoCompleteAct);
  editMenu->addSeparator();
  editMenu->addAction(configureAct);

  controlMenu = menuBar()->addMenu(tr("Control"));
  controlMenu->addAction(playAct);
  controlMenu->addAction(renderAct);

  viewMenu = menuBar()->addMenu(tr("View"));
  viewMenu->addAction(showHelpAct);

  menuBar()->addSeparator();

  helpMenu = menuBar()->addMenu(tr("&Help"));
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
  fileToolBar->addAction(newAct);
  fileToolBar->addAction(openAct);
  fileToolBar->addAction(saveAct);

  editToolBar = addToolBar(tr("Edit"));
  editToolBar->addAction(undoAct);
  editToolBar->addAction(redoAct);
  editToolBar->addAction(cutAct);
  editToolBar->addAction(copyAct);
  editToolBar->addAction(pasteAct);

  controlToolBar = addToolBar(tr("Control"));
  controlToolBar->addAction(playAct);
  controlToolBar->addAction(renderAct);
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
  QSize size = settings.value("size", QSize(400, 400)).toSize();
  resize(size);
  move(pos);
  lastUsedDir = settings.value("lastuseddir", "").toString();
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
  m_options->fontPointSize = settings.value("fontsize", 10).toDouble();
  settings.endGroup();
  settings.beginGroup("Run");
  m_options->useAPI = settings.value("useAPI", false).toBool();
  m_options->bufferSize = settings.value("bufferSize", 1024).toInt();
  m_options->bufferSizeActive = settings.value("bufferSizeActive", false).toBool();
  m_options->HwBufferSize = settings.value("HwBufferSize", 1024).toInt();
  m_options->HwBufferSizeActive = settings.value("HwBufferSizeActive", false).toInt();
  m_options->dither = settings.value("dither", false).toBool();
  m_options->additionalFlags = settings.value("additionalFlags", "").toString();
  m_options->additionalFlagsActive = settings.value("additionalFlagsActive", false).toBool();
  m_options->fileOverrideOptions = settings.value("fileOverrideOptions", false).toBool();
  m_options->fileAskFilename = settings.value("fileAskFilename", false).toBool();
  m_options->filePlayFinished = settings.value("filePlayFinished", false).toBool();
  m_options->fileFileType = settings.value("fileFileType", 0).toInt();
  m_options->fileSampleFormat = settings.value("fileSampleFormat", 0).toInt();
  m_options->fileInputFilenameActive = settings.value("fileInputFilenameActive", false).toBool();
  m_options->fileInputFilename = settings.value("fileInputFilename", "").toString();
  m_options->fileOutputFilenameActive = settings.value("fileOutputFilenameActive", false).toBool();
  m_options->fileOutputFilename = settings.value("fileOutputFilename", "").toString();
  m_options->rtAudioModule = settings.value("rtAudioModule", 0).toInt();
  m_options->rtOverrideOptions = settings.value("rtOverrideOptions", false).toBool();
  m_options->rtInputDevice = settings.value("rtInputDevice", "").toString();
  m_options->rtOutputDevice = settings.value("rtOutputDevice", "").toString();
  m_options->rtJackName = settings.value("rtJackName", "").toString();
  m_options->rtAudioModule = settings.value("rtAudioModule", 0).toInt();
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
  m_options->browser = settings.value("browser", "/usr/bin/firefox").toString();
  m_options->waveeditor = settings.value("waveeditor", "/usr/bin/audacity").toString();
  m_options->waveplayer = settings.value("waveplayer", "/usr/bin/aplay").toString();
  settings.endGroup();
  settings.endGroup();
}

void qutecsound::writeSettings()
{
  QSettings settings("csound", "qutecsound");
  settings.beginGroup("GUI");
  settings.setValue("pos", pos());
  settings.setValue("size", size());
  settings.setValue("lastuseddir", lastUsedDir);
  for (int i = 0; i < recentFiles.size();i++) {
    QString key = "recentFiles" + QString::number(i);
    settings.setValue(key, recentFiles[i]);
  }
  settings.endGroup();
  settings.beginGroup("Options");
  settings.beginGroup("Editor");
  settings.setValue("font", m_options->font );
  settings.setValue("fontsize", m_options->fontPointSize);
  settings.endGroup();
  settings.beginGroup("Run");
  settings.setValue("useAPI", m_options->useAPI);
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
  settings.setValue("rtAudioModule", m_options->rtAudioModule);
  settings.setValue("rtOverrideOptions", m_options->rtOverrideOptions);
  settings.setValue("rtInputDevice", m_options->rtInputDevice);
  settings.setValue("rtOutputDevice", m_options->rtOutputDevice);
  settings.setValue("rtJackName", m_options->rtJackName);
  settings.setValue("rtAudioModule", m_options->rtAudioModule);
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

void qutecsound::configureHighlighter()
{
  m_highlighter->setOpcodeNameList(opcodeTree->opcodeNameList());
}

bool qutecsound::maybeSave()
{
  if (textEdit->document()->isModified()) {
    int ret = QMessageBox::warning(this, tr("Application"),
                                   tr("The document has been modified.\n"
                                       "Do you want to save your changes?"),
                                       QMessageBox::Yes | QMessageBox::Default,
                                       QMessageBox::No,
                                       QMessageBox::Cancel | QMessageBox::Escape);
    if (ret == QMessageBox::Yes)
      return save();
    else if (ret == QMessageBox::Cancel)
      return false;
  }
  return true;
}

void qutecsound::loadFile(const QString &fileName)
{
  QFile file(fileName);
  if (fileName.endsWith(".csd"))
    setMode(VIEW_CSD);
  else
    setMode(VIEW_ORC_SCO);
  if (!file.open(QFile::ReadOnly | QFile::Text)) {
    QMessageBox::warning(this, tr("Application"),
                         tr("Cannot read file %1:\n%2.")
                             .arg(fileName)
                             .arg(file.errorString()));
    return;
  }

  QTextStream in(&file);
  QApplication::setOverrideCursor(Qt::WaitCursor);
  textEdit->setText(in.readAll());
  QApplication::restoreOverrideCursor();

  setCurrentFile(fileName);
  lastUsedDir = fileName;
  lastUsedDir.resize(fileName.lastIndexOf(QRegExp("[/]")));
  if (recentFiles.count(fileName) == 0) {
    recentFiles.prepend(fileName);
    recentFiles.removeLast();
    fillFileMenu();
  }
  statusBar()->showMessage(tr("File loaded"), 2000);
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
  out << textEdit->toPlainText();
  QApplication::restoreOverrideCursor();

  setCurrentFile(fileName);
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
  curFile = fileName;
  textEdit->document()->setModified(false);
  setWindowModified(false);

  QString shownName;
  if (curFile.isEmpty())
    shownName = "untitled.csd";
  else
    shownName = strippedName(curFile);

  setWindowTitle(tr("%1[*] - %2").arg(shownName).arg(tr("Application")));
}

void qutecsound::setMode(viewMode mode)
{
  m_mode = mode;
  //TODO: change csd -> orc/sco mode
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

  script += "cd " + QFileInfo(curFile).absoluteFilePath() + "\n";

  cmdLine = "csound " + curFile + m_options->generateCmdLineFlags(realtime);
  script += "echo \"" + cmdLine + "\"\n";
  script += cmdLine + "\n";
  script += "echo \"\nPress return to continue\"\n";
  script += "dummy_var=\"\"\n";
  script += "read dummy_var\n";
  script += "rm $0\n";
  return script;
}

