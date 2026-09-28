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
// To get AppProperties:
#include "documentview.h"
#include "opentryparser.h"
#include "widgetlayout.h"
#include "console.h"
#include "aboutwidget.h"
#include "settingsdialog.h"
#include "csound.h"
#include "csoundengine.h"
#include "types.h"

#define CSD_NAME "quteapp.csd"

QuteApp::QuteApp(QWidget *parent)
	: QMainWindow(parent)
{
	m_options = new CsoundOptions;
	m_options->fileName1 = CSD_NAME;
	m_options->rtAudioModule = _configlists.rtAudioNames.indexOf("portaudio");
	OpEntryParser *m_opcodeTree = new OpEntryParser(":/main/opcodes.xml");
	m_doc = new SimpleDocument(this, m_opcodeTree);
	m_doc->getEngine()->setThreaded(true);
	m_console = m_doc->getConsole();
	m_console->setWindowTitle(tr("Csound Console"));
	m_console->setWindowFlags(Qt::Window | Qt::WindowStaysOnTopHint);
	m_aboutWidget = new AboutWidget(this);
}

QuteApp::~QuteApp()
{
	m_doc->stop();
	if (m_saveState && QFile::exists(CSD_NAME)) {
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

void QuteApp::setRunPath(QString path)
{
#ifdef Q_OS_MAC
	path = path.left(path.lastIndexOf("/"));
#ifdef USE_DOUBLE
	QString opcodeDir = path + QDir::separator() + "../Frameworks/CsoundLib64.framework/Resources/Opcodes64";
#else
	QString opcodeDir = path + QDir::separator() + "../Frameworks/CsoundLib.framework/Resources/Opcodes";
#endif
	QDir::setCurrent(path + QDir::separator() + "../Resources/");
#else //not Q_OS_MAC
	QDir::setCurrent(QDir::current().absolutePath() + QDir::separator() + "data");
	QString opcodeDir = QDir::currentPath();
#endif
	qDebug() << QDir::current() << qApp->applicationFilePath();
	qDebug() << "opcodeDir" << opcodeDir;
	csoundSetGlobalEnv("OPCODEDIR", opcodeDir.toLocal8Bit().data());
	csoundSetGlobalEnv("OPCODEDIR64", opcodeDir.toLocal8Bit().data());

	loadCsd();
	setAboutTexts();
	createMenus();
	setCentralWidget((QWidget *) m_doc->getWidgetLayout());
	//  m_aboutWidget->setWindowFlags(Qt::Window | Qt::WindowStaysOnTopHint);
	//  m_console->show();
	//  start();
	setWindowTitle(m_appName);
	//  setAttribute(Qt::WA_DeleteOnClose); // Will cause crashing!
	if (m_autorun) {
		start();
	}
}

void QuteApp::createMenus()
{
	QMenu *menu = menuBar()->addMenu(tr("&File"));
	if (m_showRunOptions) {
		menu->addAction(tr("Run"), this, SLOT(start()), QKeySequence("Ctrl+R"));
		menu->addAction(tr("Stop"), this, SLOT(stop()), QKeySequence("Ctrl+."));
	}
	menu->addAction(tr("Configure..."), this, SLOT(configure()));
	menu->addAction(tr("Show Console Output"), this, SLOT(showConsole()));
	menu->addSeparator();
	menu->addAction(tr("Quit"), qApp, SLOT(quit()));
	QMenu *about = menuBar()->addMenu(tr("&Help"));
	about->addAction(tr("About ..."), m_aboutWidget, SLOT(open()));
	about->addAction(tr("Info"), this, SLOT(info()));
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
	qDebug() << "Not implemented yet.";
}

void QuteApp::showConsole()
{
	m_console->setVisible(!m_console->isVisible());
}

void QuteApp::configure()
{
	SettingsDialog d(this, m_options);
	d.exec();
	if (d.result() == QDialog::Accepted) {
	}
}

void QuteApp::info()
{
	QString message = tr("This application was built using CsoundQt\n");
	bool doubles;
#ifdef USE_DOUBLE
	doubles = true;
#else
	doubles = false;
#endif
	message += tr("Using Csound %1 version %2\n").arg(doubles ? "doubles" : "floats").arg(csoundGetVersion());
	QMessageBox::information(this, tr("CsoundQt Application"), message);
}

bool QuteApp::loadCsd()
{
	QString fileName = m_options->fileName1;
	QFile file(fileName);
	if (!file.open(QFile::ReadOnly)) {
		QMessageBox::warning(this, tr("QuteApp"),
							 tr("Application not built correctly.\ncsd file not in bundle.\n%1").arg(QDir::currentPath()));
		return false;
	}
	//  QApplication::setOverrideCursor(Qt::WaitCursor);

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

	AppProperties props = m_doc->getAppProperties();
	m_appName = props.appName;
	m_author = props.author;
	m_version = props.version;
	m_email = props.email;
	m_website = props.website;
	m_date = props.date;
	m_instructions = props.instructions;
	m_autorun = props.autorun;

	this->resize(m_doc->getWidgetLayout()->size());
	//  m_doc->readOnly = true;
	//  QApplication::restoreOverrideCursor();

	return true;
}

void QuteApp::setAboutTexts()
{
	QString templateText = "<h1>%1<h1><h2>%2</h2><h2>%3</h2>%4<br />%5<br />%6<br />";
	QString intro = templateText.arg(m_appName).arg(m_author).arg(m_version)
			.arg(m_date).arg(m_website).arg(m_email);
	m_aboutWidget->setIntroText(intro);
	m_aboutWidget->setInstructions(m_instructions);
}
