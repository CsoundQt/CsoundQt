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

#include "pythonconsole.h"
#include "PythonQt.h"
//#include "PythonQtGui.h"
#include "PythonQt_QtAll.h"
#include "gui/PythonQtScriptingConsole.h"
#include "pyqcsobject.h"
#include "qutesheet.h"

#include "qutecsound.h"

PythonConsole::PythonConsole(QWidget *parent)
  : QDockWidget(parent), m_pqcs(0), m_console(0)
{
//  m_text = new QTextEdit(this);
//  m_text->setReadOnly(true);

  setWindowTitle(tr("Python Console"));
  PythonQt::init(PythonQt::RedirectStdOut);
  PythonQt_QtAll::init();
  initializeInterpreter();
}

PythonConsole::~PythonConsole()
{
  delete m_console;
  delete m_pqcs;
}


void PythonConsole::evaluate(QString evalCode, bool notify)
{
  PythonQtObjectPtr  mainContext = PythonQt::self()->getMainModule();
//  PythonQtObjectPtr  mainContext = m_pqcs->getMainModule();
  mainContext.evalScript(evalCode.trimmed() + "\n");
  if (notify) {
    QString printScript = "print 'Evaluated " + QString::number(evalCode.count("\n") + 1 );
    printScript += " lines.'";
    mainContext.evalScript(printScript);
    m_console->appendCommandPrompt();
  }
}

void PythonConsole::runScript(QString fileName)
{
  QDir dir = QDir::currentPath();
  QDir newDir = QDir(fileName.mid(0, fileName.lastIndexOf(QDir::separator())));
  qDebug() << newDir.absolutePath();
  bool set = QDir::setCurrent(newDir.absolutePath());
  PythonQtObjectPtr  mainContext = PythonQt::self()->getMainModule();
//  PythonQtObjectPtr  mainContext = m_pqcs->getMainModule();
  QFile file(fileName);
  if (!file.open(QIODevice::ReadOnly)) {
    QString printScript = "print 'Error opening file: " + fileName + "'";
    mainContext.evalScript(printScript);
  }
  QString evalCode = QString(file.readAll());
  mainContext.evalScript(evalCode);
  QString printScript = "print 'Evaluated " + QString::number(evalCode.count("\n") + 1 );
  printScript += " lines.'";
  mainContext.evalScript(printScript);
  m_console->appendCommandPrompt();
  QDir::setCurrent (dir.absolutePath());
}

void PythonConsole::initializeInterpreter()
{
  PythonQtObjectPtr  mainContext = PythonQt::self()->getMainModule();
  if (m_console != 0) {
    delete m_console;
  }
  if (m_pqcs != 0) {
    delete m_pqcs;
  }
  m_console = new PythonQtScriptingConsole(this, mainContext);

  // add a QObject to the namespace of the main python context
  m_pqcs = new PyQcsObject() ;
  m_pqcs->setQuteCsound(static_cast<qutecsound *>(parentWidget()));
  PythonQt::self()->registerCPPClass("QuteSheet", "","qs", PythonQtCreateObject<QuteSheet>);
  mainContext.addObject("q", m_pqcs);
  mainContext.evalScript("from PythonQt.qs import QuteSheet");
//  mainContext.evalScript("print 'QuteCsound Python Interpreter Initialized.'");
  //  mainContext.evalScript("s = q.schedule");
  //  mainContext.evalScript("import os");

    setWidget(m_console);
  //  m_console->setCurrentFont(QFont("Courier New"));
  //  m_console->setFontFamily("Courier New");
  //  m_console->setAcceptRichText (false);
    m_console->show();
}

void PythonConsole::closeEvent(QCloseEvent * /*event*/)
{
  emit Close(false);
}

//void PythonConsole::runCommand(QString command)
//{
//  qDebug() << "PythonConsole::runCommand " << command;
//}

//void PythonConsole::keyPressEvent(QKeyEvent * event)
//{
//  qDebug() << "PythonConsole::keyPressEvent";
//  if (event->key() == Qt::Key_Return || event->key() == Qt::Key_Return) {
//    runCurrentCommand();
//  }
//  else {
//    m_text->insertPlainText(event->text());
//    m_command.append(event->text());
//  }
//}

//void PythonConsole::runCurrentCommand()
//{
//  runCommand(m_command);
//  m_command = "";
//}
