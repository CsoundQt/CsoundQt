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
//#include "PythonQt_QtAll.h"
#include "gui/PythonQtScriptingConsole.h"
#include "pyqcsobject.h"

#include "qutecsound.h"

PythonConsole::PythonConsole(QWidget *parent) : QDockWidget(parent)
{
//  m_text = new QTextEdit(this);
//  m_text->setReadOnly(true);

  setWindowTitle(tr("Python Console"));
  PythonQt::init(PythonQt::RedirectStdOut);
//  PythonQt_QtAll::init();

  PythonQtObjectPtr  mainContext = PythonQt::self()->getMainModule();
  m_console = new PythonQtScriptingConsole(this, mainContext);

  // add a QObject to the namespace of the main python context
  m_pqcs = new PyQcsObject() ;
  m_pqcs->setQuteCsound(static_cast<qutecsound *>(parentWidget()));
  mainContext.addObject("q", m_pqcs);
//  mainContext.evalScript("print 'QuteCsound Python Console.'");
  mainContext.evalScript("s = q.schedule");
  mainContext.evalScript("import os");

  // TODO is pyqcs.py necessary since everything is being done in C++?
//  mainContext.evalFile(":python/pyqcs.py");

  setWidget(m_console);
//  console->setCurrentFont(QFont("Courier New"));
//  console->setFontFamily("Courier New");
  m_console->setAcceptRichText (false);
  m_console->show();
}

PythonConsole::~PythonConsole()
{
  delete m_console;
  delete m_pqcs;
}

void PythonConsole::evaluate(QString evalCode)
{
  PythonQtObjectPtr  mainContext = m_pqcs->getMainModule();
  mainContext.evalScript(evalCode);
  QString printScript = "print 'Evaluated " + QString::number(evalCode.count("\n") + 1 );
  printScript += " lines.'";
  mainContext.evalScript(printScript);
  m_console->appendCommandPrompt();
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
