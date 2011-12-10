/*
    Copyright (C) 2010 Andres Cabrera
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

#include <QtGui>
#include "quteapp.h"
#include "types.h"
#include "csoundoptions.h"
#include "simpledocument.h"
#include "opentryparser.h"
#include "widgetlayout.h"
#include "console.h"
#include "aboutwidget.h"

#define CSD_NAME "data/quteapp.csd"

QuteApp::QuteApp(QWidget *parent)
    : QMainWindow(parent)
{
  // TODO remove these test values!
  m_appName = "My App!";
  m_author = "Great Author";
  m_version = "Version 1.0.2";
  m_email = "email@email.com";
  m_website = "http://www.hello.com";
  m_date = "October 10, 1999";
  m_instructions = "Follow these instructions";


  m_autorun = false;

  QDir::setCurrent("/data");
  loadLocalPrefs(); // Must load first as this sets values used later
  m_options = new CsoundOptions;
  m_options->fileName1 = CSD_NAME;
  OpEntryParser *m_opcodeTree = new OpEntryParser(":/main/opcodes.xml");
  m_doc = new SimpleDocument(this, m_opcodeTree);
  m_console = m_doc->getConsole();
  m_console->setWindowTitle(tr("Csound Console"));
  m_console->setWindowFlags(Qt::Window | Qt::WindowStaysOnTopHint);
  m_aboutWidget = new AboutWidget(this);
  setAboutTexts();
  createMenus();
  loadCsd();
  setCentralWidget((QWidget *) m_doc->getWidgetLayout());
//  m_aboutWidget->setWindowFlags(Qt::Window | Qt::WindowStaysOnTopHint);
//  m_console->show();
//  start();

    if (m_autorun) {
      start();
    }
}

QuteApp::~QuteApp()
{
  m_doc->stop();
  if (m_saveState) {
    QFile f(CSD_NAME);
    if (f.open(QIODevice::WriteOnly)) {
      QString fullText = m_doc->getFullText();
      f.write(fullText.toLocal8Bit());
      f.close();
    } else {
      QMessageBox::critical(this, tr("Error"), tr("Error saving file!"));
    }
  }
  delete m_doc;
  delete m_options;
//  delete m_opcodeTree;
}

void QuteApp::createMenus()
{
  QMenu *menu = menuBar()->addMenu(tr("&File"));
  if (m_showRunOptions) {
    menu->addAction(tr("Run"), this, SLOT(start()), QKeySequence("Ctrl+R"));
    menu->addAction(tr("Stop"), this, SLOT(stop()), QKeySequence("Ctrl+."));
  }
  menu->addAction(tr("Show Console Output"), this, SLOT(showConsole()));
  QMenu *about = menuBar()->addMenu(tr("&Help"));
  about->addAction(tr("About ..."), m_aboutWidget, SLOT(open()));
}

void QuteApp::start()
{
  m_doc->play(m_options);
}

void QuteApp::pause()
{
  m_doc->pause();
}

void QuteApp::stop()
{
  m_doc->stop();
}

void QuteApp::save()
{
  qDebug() << "QuteApp::save() not implemented yet.";
}

void QuteApp::showConsole()
{
  m_console->setVisible(!m_console->isVisible());
}

bool QuteApp::loadCsd()
{
  QString fileName = m_options->fileName1;
  QFile file(fileName);
  if (!file.open(QFile::ReadOnly)) {
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("Cannot read file %1:\n%2.")
                             .arg(fileName)
                             .arg(file.errorString()));
    return false;
  }
  QApplication::setOverrideCursor(Qt::WaitCursor);

  QString text;
  bool inEncFile = false;
  while (!file.atEnd()) {
    QByteArray line = file.readLine();
    if (line.contains("<CsFileB ")) {
      inEncFile = true;
    }
    if (!inEncFile) {
      while (line.contains("\r\n")) {
        line.replace("\r\n", "\n");  //Change Win returns to line endings
      }
      while (line.contains("\r")) {
        line.replace("\r", "\n");  //Change Mac returns to line endings
      }
      QTextDecoder decoder(QTextCodec::codecForLocale());
      text = text + decoder.toUnicode(line);
      if (!line.endsWith("\n"))
        text += "\n";
    }
    else {
      text += line;
      if (line.contains("</CsFileB>" && !line.contains("<CsFileB " )) ) {
        inEncFile = false;
      }
    }
  }

//  m_doc->setInitialDir(initialDir);
//  m_doc->showLiveEventPanels(false);

//  setCurrentOptionsForPage(m_doc);
//  setCurrentFile(fileName);

//  m_doc->setFileName(fileName);  // Must set before sending text to set highlighting mode

//  connectActions();
//  connect(documentPages[curPage], SIGNAL(currentTextUpdated()), this, SLOT(markInspectorUpdate()));
//  connect(documentPages[curPage], SIGNAL(modified()), this, SLOT(documentWasModified()));
//  connect(documentPages[curPage], SIGNAL(currentLineChanged(int)), this, SLOT(showLineNumber(int)));
//  connect(documentPages[curPage], SIGNAL(setWidgetClipboardSignal(QString)),
//          this, SLOT(setWidgetClipboard(QString)));
//  connect(documentPages[curPage], SIGNAL(setCurrentAudioFile(QString)),
//          this, SLOT(setCurrentAudioFile(QString)));
//  connect(documentPages[curPage]->getView(), SIGNAL(lineNumberSignal(int)),
//          this, SLOT(showLineNumber(int)));
//  connect(documentPages[curPage], SIGNAL(evaluatePythonSignal(QString)),
//          this, SLOT(evaluatePython(QString)));

  m_doc->setTextString(text);

//  m_doc->readOnly = true;
  QApplication::restoreOverrideCursor();
//  setWidgetPanelGeometry();

  this->resize(m_doc->getWidgetLayout()->size());
  return true;
}

bool QuteApp::loadLocalPrefs()
{
  // FIXME load from csd file!
//    QFile f("prefs.inf");
//    if (!f.open(QIODevice::ReadOnly)) {
//        QMessageBox::warning(this, tr("Warning"), tr("Could not find preferences file!"));
//        return false;
//    }
//    QStringList lines = QString(f.readAll()).split("\n");
//    int index = lines.indexOf("[appName]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_appName = lines.takeAt(index);
//    }
//    index = lines.indexOf("[author]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_author = lines.takeAt(index);
//    }
//    index = lines.indexOf("[email]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_email = lines.takeAt(index);
//    }
//    index = lines.indexOf("[website]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_website = lines.takeAt(index);
//    }
//    index = lines.indexOf("[date]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_date = lines.takeAt(index);
//    }
//    index = lines.indexOf("[version]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_version = lines.takeAt(index);
//    }
//    index = lines.indexOf("[autorun]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_autorun = lines.takeAt(index) == "true";
//    }
//    index = lines.indexOf("[showRunOptions]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_showRunOptions = lines.takeAt(index) == "true";
//    }
//    index = lines.indexOf("[saveOnClose]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_saveOnClose = lines.takeAt(index) == "true";
//    }
//    index = lines.indexOf("[newParser]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_newParser = lines.takeAt(index) == "true";
//    }
//    index = lines.indexOf("[runMode]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_runMode = (RunMode) lines.takeAt(index).toInt();
//    }
//    index = lines.indexOf("[saveState]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_saveState = lines.takeAt(index) == "true";
//    }
//    index = lines.indexOf("[instructions]");
//    if (index) {
//      lines.takeAt(index); // remove label
//      m_instructions = "";
//      QString line = lines.at(index);
//      while (!(line.startsWith("[") && line.startsWith("]"))) {
//        m_instructions.append(line + "\n");
//        lines.takeAt(index);
//        if (index == lines.size()) {
//          break;
//        }
//        line = lines.at(index);
//      }
//    }
//    if (lines.size() > 0) {
//      qDebug() << "QuteApp::loadLocalPrefs() extraneous information in prefs file";
//    }
    return true;
}

void QuteApp::setAboutTexts()
{
  QString templateText = "<h1>%1<h1><h2>%2</h2><h2>%3</h2><h3>%4</h3><h3>%5</h3>";
  QString intro = templateText.arg(m_appName).arg(m_author).arg(m_version)
      .arg(m_date).arg(m_email);
  m_aboutWidget->setIntroText(intro);
  m_aboutWidget->setInstructions(m_instructions);
}
