/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "qutecsound.h"
#include "console.h"
#include "dockhelp.h"
#include "widgetpanel.h"
#include "inspector.h"
#include "opentryparser.h"
#include "options.h"
#include "highlighter.h"
#include "configdialog.h"
#include "documentpage.h"
#include "utilitiesdialog.h"
#include "graphicwindow.h"
#include "keyboardshortcuts.h"
#include "liveeventframe.h"
#include "about.h"
#include "eventsheet.h"
#include "appwizard.h"

#ifdef QCS_PYTHONQT
#include "pythonconsole.h"
#endif

#ifdef QCS_RTMIDI
#include "RtMidi.h"
#endif

// One day remove these from here for nicer abstraction....
#include "csoundengine.h"
#include "documentview.h"
#include "widgetlayout.h"

#ifdef Q_OS_WIN32
static const QString SCRIPT_NAME = "csoundqt_run_script-XXXXXX.bat";
#else
static const QString SCRIPT_NAME = "csoundqt_run_script-XXXXXX.sh";
#endif


#ifdef QCS_RTMIDI
static void midiMessageCallback(double deltatime,
								std::vector< unsigned char > *message,
								void *userData)
{
	WidgetLayout *d = (WidgetLayout *) userData;
	unsigned int nBytes = message->size();
	if ( ((d->midiWriteCounter + 1) % QCS_MAX_MIDI_QUEUE) != d->midiReadCounter) {
		int index = d->midiWriteCounter;
		d->midiWriteCounter++;
		d->midiWriteCounter = d->midiWriteCounter % QCS_MAX_MIDI_QUEUE;
		for (unsigned int i = 0; i < nBytes; i++) {
			d->midiQueue[index][i] = (int)message->at(i);
		}
	}
	//  if (nBytes > 0) {
	//    qDebug() << "stamp = " << deltatime;
	//  }
}
#endif

#define MAX_THREAD_COUNT 12 // to enable up to MAX_THREAD_COUNT documents/consoles have messageDispatchers

CsoundQt::CsoundQt(QStringList fileNames)
{
	m_closing = false;
	m_resetPrefs = false;
	utilitiesDialog = 0;
	curCsdPage = -1;
    configureTab = 0;
#ifdef QCS_RTMIDI
	m_midiin = 0;
#endif
//	initialDir = QDir::current().path();
	initialDir = QCoreApplication::applicationDirPath();
	setWindowTitle("CsoundQt[*]");
	resize(780,550);
	setWindowIcon(QIcon(":/images/qtcs.png"));

	QLocale::setDefault(QLocale::system());  //Does this take care of the decimal separator for different locales?
	curPage = -1;

	m_options = new Options(&m_configlists);
	// Create GUI panels
	lineNumberLabel = new QLabel("Line 1"); // Line number display
	statusBar()->addPermanentWidget(lineNumberLabel); // This must be done before a file is loaded
	m_console = new DockConsole(this);
	m_console->setObjectName("m_console");
	//   m_console->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea);
	addDockWidget(Qt::BottomDockWidgetArea, m_console);
	helpPanel = new DockHelp(this);
	helpPanel->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea | Qt::LeftDockWidgetArea);
	helpPanel->setObjectName("helpPanel");
	helpPanel->show();
	addDockWidget(Qt::RightDockWidgetArea, helpPanel);

	widgetPanel = new WidgetPanel(this);
	widgetPanel->setFocusPolicy(Qt::NoFocus);
	widgetPanel->setAllowedAreas(Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea |Qt::LeftDockWidgetArea);
	widgetPanel->setObjectName("widgetPanel");
	widgetPanel->show();
	addDockWidget(Qt::RightDockWidgetArea, widgetPanel);

	m_inspector = new Inspector(this);
	m_inspector->parseText(QString());
	m_inspector->setObjectName("Inspector");
	m_inspector->show();
	addDockWidget(Qt::LeftDockWidgetArea, m_inspector);

#ifdef QCS_PYTHONQT
	m_pythonConsole = new PythonConsole(this);
	addDockWidget(Qt::LeftDockWidgetArea, m_pythonConsole);
	m_pythonConsole->setObjectName("Python Console");
	m_pythonConsole->show();
#endif
	m_scratchPad = new QDockWidget(this);
	addDockWidget(Qt::LeftDockWidgetArea, m_scratchPad);
	m_scratchPad->setObjectName("Scratch Pad");
	m_scratchPad->setWindowTitle(tr("Scratch Pad"));

	connect(helpPanel, SIGNAL(openManualExample(QString)), this, SLOT(openManualExample(QString)));
	QSettings settings("csound", "qutecsound");
	settings.beginGroup("GUI");
	m_options->theme = settings.value("theme", "boring").toString();

	createActions(); // Must be before readSettings as this sets the default shortcuts, and after widgetPanel
	readSettings();

	bool widgetsVisible = widgetPanel->isVisible(); // Must be after readSettings() to save last state
	showWidgetsAct->setChecked(false); // To avoid showing and reshowing panels during initial load
	widgetPanel->hide();  // Hide until CsoundQt has finished loading

	bool scratchPadVisible = !m_scratchPad->isHidden(); // Must be after readSettings() to save last state
	if (scratchPadVisible)
		m_scratchPad->hide();  // Hide until CsoundQt has finished loading

	createMenus();
	createToolBars();
	createStatusBar();

	documentTabs = new QTabWidget (this);
	documentTabs->setTabsClosable(true);
	connect(documentTabs, SIGNAL(currentChanged(int)), this, SLOT(changePage(int)));
	connect(documentTabs, SIGNAL(tabCloseRequested(int)), documentTabs, SLOT(setCurrentIndex(int))); // To force changing to clicked tab before closing
	connect(documentTabs, SIGNAL(tabCloseRequested(int)), closeTabAct, SLOT(trigger()));
	setCentralWidget(documentTabs);
	documentTabs->setDocumentMode(true);
	modIcon.addFile(":/images/modIcon2.png", QSize(), QIcon::Normal);
	modIcon.addFile(":/images/modIcon.png", QSize(), QIcon::Disabled);

	fillFileMenu(); // Must be placed after readSettings to include recent Files
	fillFavoriteMenu(); // Must be placed after readSettings to know directory
	fillScriptsMenu(); // Must be placed after readSettings to know directory
	if (m_options->opcodexmldir == "") {
		m_opcodeTree = new OpEntryParser(":/opcodes.xml");
	}
	else
		m_opcodeTree = new OpEntryParser(QString(m_options->opcodexmldir + "/opcodes.xml"));

	DocumentView *padview = new DocumentView(m_scratchPad, m_opcodeTree);
	padview->setBackgroundColor(QColor(240, 230, 230));
	padview->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);
	padview->setFileType(EDIT_PYTHON_MODE); // Python type (for highlighting and completion)
	padview->show();
	padview->showLineArea(true);
	padview->setFullText("");
	connect(padview, SIGNAL(evaluate(QString)), this, SLOT(evaluate(QString)));
	m_scratchPad->setWidget(padview);
	m_scratchPad->setFocusProxy(padview);
	scratchPadCsdModeAct->setChecked(true);

	// Open files saved from last session
	if (!lastFiles.isEmpty()) {
		foreach (QString lastFile, lastFiles) {
			if (lastFile!="" and !lastFile.startsWith("untitled")) {
				loadFile(lastFile);
			}
		}
	}

	if (documentPages.size() == 0) { // No files yet open. Open default
		newFile();
	}

	QString index = m_options->csdocdir + QString("/index.html");
#ifdef Q_OS_MAC
	if (!QFile::exists(index)) {
		index = initialDir + QString("/../Frameworks/CsoundLib64.framework/Resources/Manual/index.html");
		if (!QFile::exists(index)) {
			index = "/Library/Frameworks/CsoundLib64.framework/Resources/Manual/index.html";
		}
	}
#endif
	helpPanel->docDir = m_options->csdocdir;
	helpPanel->loadFile(index);

	applySettings();
	createQuickRefPdf();

	openLogFile();

	// FIXME is there still need for no atexit?
#ifdef CSOUND6
	int init = csoundInitialize(0);
#else
	int init = csoundInitialize(0,0,0);
#endif
	if (init < 0) {
		qDebug("CsoundEngine::CsoundEngine() Error initializing Csound!\nCsoundQt will probably crash if you try to run Csound.");
	}
	qApp->processEvents(); // To finish settling dock widgets and other stuff before messing with them (does it actually work?)

	if (lastTabIndex < documentPages.size() && documentTabs->currentIndex() != lastTabIndex) {
		changePage(lastTabIndex);
		documentTabs->setCurrentIndex(lastTabIndex);
	}
	else {
		changePage(documentTabs->currentIndex());
	}
	// Open files passed in the command line. Here to make sure they are the active tab.
	foreach (QString fileName, fileNames) {
		if (QFile::exists(fileName)) {
			loadFile(fileName, m_options->autoPlay);
		}
		else {
			qDebug() << "CsoundQt::CsoundQt could not open file:" << fileName;
		}
	}

	m_closing = false;
	updateInspector(); //Starts update inspector thread

	showWidgetsAct->setChecked(widgetsVisible);
	if (!m_options->widgetsIndependent) {
		// FIXME: for some reason this produces a move event for widgetlayout with pos (0,0)
		widgetPanel->setVisible(widgetsVisible);
	}

	if (scratchPadVisible) { // Reshow scratch panel if necessary
		m_scratchPad->show();
	}
	// Initialize buttons to current state of panels
	showConsoleAct->setChecked(!m_console->isHidden());
	showHelpAct->setChecked(!helpPanel->isHidden());
	showInspectorAct->setChecked(!m_inspector->isHidden());
#ifdef QCS_PYTHONQT
	showPythonConsoleAct->setChecked(!m_pythonConsole->isHidden());
#endif
	showScratchPadAct->setChecked(!m_scratchPad->isHidden());

    //qDebug()<<"Max thread count: "<< QThreadPool::globalInstance()->maxThreadCount();
    QThreadPool::globalInstance()->setMaxThreadCount(MAX_THREAD_COUNT);

}

CsoundQt::~CsoundQt()
{
	qDebug() << "CsoundQt::~CsoundQt()";
	// This function is not called... see closeEvent()
}

void CsoundQt::utilitiesMessageCallback(CSOUND *csound,
										int /*attr*/,
										const char *fmt,
										va_list args)
{
	DockConsole *console = (DockConsole *) csoundGetHostData(csound);
	QString msg;
	msg = msg.vsprintf(fmt, args);
	//  qDebug() << msg;
	console->appendMessage(msg);
}

void CsoundQt::changePage(int index)
{
	// Previous page has already been destroyed here (if it was closed)
	// Remember this is called when opening, closing or switching tabs (including loading)
	if (documentPages.size() > curPage && documentPages.size() > 0 && documentPages[curPage]) {
		disconnect(showLiveEventsAct, 0,0,0);
		disconnect(documentPages[curPage], SIGNAL(stopSignal()),0,0);
		documentPages[curPage]->showLiveEventPanels(false);
		documentPages[curPage]->hideWidgets();
		if (!m_options->widgetsIndependent) {
			QRect panelGeometry = widgetPanel->geometry();
			if (!widgetPanel->isFloating()) {
				panelGeometry.setX(-1);
				panelGeometry.setY(-1);
			}
			widgetPanel->takeWidgetLayout(panelGeometry);
		} else {
			documentPages[curPage]->setWidgetLayoutOuterGeometry(QRect());
		}
	}
	if (index < 0) { // No tabs left
		qDebug() << "CsoundQt::changePage index < 0";
		return;
	}
	curPage = index;
	if (curPage >= 0 && curPage < documentPages.size() && documentPages[curPage] != NULL) {
		setCurrentFile(documentPages[curPage]->getFileName());
		connectActions();
		documentPages[curPage]->showLiveEventPanels(showLiveEventsAct->isChecked());
		//    documentPages[curPage]->passWidgetClipboard(m_widgetClipboard);
		if (!m_options->widgetsIndependent) {
			WidgetLayout *w = documentPages[curPage]->getWidgetLayout();
			widgetPanel->addWidgetLayout(w);
			setWidgetPanelGeometry();
		} else {
			WidgetLayout *w = documentPages[curPage]->getWidgetLayout();
			w->adjustWidgetSize();
		}
		if (!documentPages[curPage]->getFileName().endsWith(".csd")
				&& !documentPages[curPage]->getFileName().isEmpty()) {
			widgetPanel->hide();
		}
		else {
			if (!m_options->widgetsIndependent) {
				documentPages[curPage]->showWidgets();
				widgetPanel->setVisible(showWidgetsAct->isChecked());
			}
			else {
				documentPages[curPage]->showWidgets(showWidgetsAct->isChecked());
			}
		}
		m_console->setWidget(documentPages[curPage]->getConsole());
//		updateInspector();
		runAct->setChecked(documentPages[curPage]->isRunning());
		recAct->setChecked(documentPages[curPage]->isRecording());
		splitViewAct->setChecked(documentPages[curPage]->getViewMode() > 1);
#ifdef QCS_RTMIDI
		if (m_midiin != 0) {
			m_midiin->cancelCallback();
			m_midiin->setCallback(&midiMessageCallback, documentPages[curPage]->getWidgetLayout());  //TODO enable multiple layouts
		}
#endif
		if (documentPages[curPage]->getFileName().endsWith(".csd")) {
			curCsdPage = curPage;
		}
	}
	m_inspectorNeedsUpdate = true;
}

void CsoundQt::setWidgetTooltipsVisible(bool visible)
{
	documentPages[curPage]->showWidgetTooltips(visible);
}

void CsoundQt::closeExtraPanels()
{
	if (m_console->isVisible()) {
		m_console->hide();
		showConsoleAct->setChecked(false);
	} else if (helpPanel->isVisible()) {
		helpPanel->hide();
		showHelpAct->setChecked(false);
	}
}

void CsoundQt::openExample()
{
	QObject *sender = QObject::sender();
	if (sender == 0)
		return;
	QAction *action = static_cast<QAction *>(sender);
	loadFile(action->data().toString());
	//   saveAs();
}

void CsoundQt::logMessage(QString msg)
{
	if (logFile.isOpen()) {
		logFile.write(msg.toLatin1());
	}
}

void CsoundQt::closeEvent(QCloseEvent *event)
{
	m_closing = true;
	this->showNormal();  // Don't store full screen size in preferences
	qApp->processEvents();
	QStringList files;
	if (m_options->rememberFile) {
		for (int i = 0; i < documentPages.size(); i++ ) {
			files.append(documentPages[i]->getFileName());
		}
	}
	int lastIndex = documentTabs->currentIndex();
	writeSettings(files, lastIndex);
	showWidgetsAct->setChecked(false);
	showLiveEventsAct->setChecked(false); // These two give faster shutdown times as the panels don't have to be called up as the tabs close

	while (!documentPages.isEmpty()) {
		//    if (!saveCurrent()) {
		//      event->ignore();
		//      return; // Action canceled
		//    }
		if (!closeTab(true)) { // Don't ask for closing app
			event->ignore();
			return;
		}
	}
	//delete quickRefFile;quickRefFile = 0;
	// Delete all temporary files.
	foreach (QString tempFile, tempScriptFiles) {
		QDir().remove(tempFile);
	}
	if (logFile.isOpen()) {
		logFile.close();
	}
	showUtilities(false);  // Close utilities dialog if open
	delete helpPanel;
	//  delete closeTabButton;
	delete m_options;

	m_closing = true;
	widgetPanel->close();
	m_inspector->close();
	m_console->close();
	documentTabs->close();
	m_console->close();
	delete m_opcodeTree;
	event->accept();
	close();
}

void CsoundQt::newFile()
{
	loadFile(":/default.csd");
	documentPages[curPage]->loadTextString(m_options->csdTemplate);
	documentPages[curPage]->setFileName("");
	setWindowModified(false);
	documentTabs->setTabIcon(curPage, modIcon);
	documentTabs->setTabText(curPage, "default.csd");
	//   documentPages[curPage]->setTabStopWidth(m_options->tabWidth);
	connectActions();
}

void CsoundQt::open()
{
	QStringList fileNames;
	bool widgetsVisible = widgetPanel->isVisible();
	if (widgetsVisible && widgetPanel->isFloating())
		widgetPanel->hide(); // Necessary for Mac, as widget Panel covers open dialog
	bool helpVisible = helpPanel->isVisible();
	if (helpVisible && helpPanel->isFloating())
		helpPanel->hide(); // Necessary for Mac, as widget Panel covers open dialog
	bool inspectorVisible = m_inspector->isVisible();
	if (inspectorVisible && m_inspector->isFloating())
		m_inspector->hide(); // Necessary for Mac, as widget Panel covers open dialog
	fileNames = QFileDialog::getOpenFileNames(this, tr("Open File"), lastUsedDir ,
                                              tr("Known Files (*.csd *.orc *.sco *.py *.inc);;Csound Files (*.csd *.orc *.sco *.inc *.CSD *.ORC *.SCO *.INC);;Python Files (*.py);;All Files (*)",
												 "Be careful to respect spacing parenthesis and usage of punctuation"));
//	if (widgetsVisible) {
//		if (!m_options->widgetsIndependent) {
//			//      widgetPanel->show();
//		}
//	}
	if (helpVisible)
		helpPanel->show();
	if (inspectorVisible)
		m_inspector->show();
	foreach (QString fileName, fileNames) {
		if (!fileName.isEmpty()) {
			loadFile(fileName, m_options->autoPlay);
		}
	}
}

void CsoundQt::reload()
{
	if (documentPages[curPage]->isModified()) {
		QString fileName = documentPages[curPage]->getFileName();
		deleteTab();
		loadFile(fileName);
	}
}

void CsoundQt::openFromAction()
{
	QString fileName = static_cast<QAction *>(sender())->data().toString();
	openFromAction(fileName);
}

void CsoundQt::openFromAction(QString fileName)
{
	if (!fileName.isEmpty()) {
		if ( (fileName.endsWith(".sco") || fileName.endsWith(".orc"))
			 && m_options->autoJoin) {

		}
		else {
			loadCompanionFile(fileName);
			loadFile(fileName);
		}
	}
}

void CsoundQt::runScriptFromAction()
{
	QString fileName = static_cast<QAction *>(sender())->data().toString();
	runScript(fileName);
}

void CsoundQt::runScript(QString fileName)
{
	if (!fileName.isEmpty()) {
#ifdef QCS_PYTHONQT
		m_pythonConsole->runScript(fileName);
#endif
	}
}

void CsoundQt::createCodeGraph()
{
	QString command = m_options->dot + " -V";
#ifdef Q_OS_WIN32
	// add quotes surrounding dot command if it has spaces in it
	if (m_options->dot.contains(" "))
		command.replace(m_options->dot, "\"" + m_options->dot + "\"");
	// replace linux/mac style directory separators with windows style separators
	command.replace("/", "\\");
#endif

	int ret = system(command.toLatin1());
	if (ret != 0) {
		QMessageBox::warning(this, tr("CsoundQt"),
							 tr("Dot executable not found.\n"
								"Please install graphviz from\n"
								"www.graphviz.org"));
		return;
	}
	QString dotText = documentPages[curPage]->getDotText();
	if (dotText.isEmpty()) {
		qDebug() << "Empty dot text.";
		return;
	}
	qDebug() << dotText;
	QTemporaryFile file(QDir::tempPath() + QDir::separator() + "CsoundQt-GraphXXXXXX.dot");
	QTemporaryFile pngFile(QDir::tempPath() + QDir::separator() + "CsoundQt-GraphXXXXXX.png");
	if (!file.open() || !pngFile.open()) {
		QMessageBox::warning(this, tr("CsoundQt"),
							 tr("Cannot create temp dot/png file."));
		return;
	}

	QTextStream out(&file);
	out << dotText;
	file.close();
	file.open();

	command = "\"" + m_options->dot + "\"" + " -Tpng -o \"" + pngFile.fileName() + "\" \"" + file.fileName() + "\"";

#ifdef Q_OS_WIN32
	// remove quotes surrounding dot command if it doesn't have spaces in it
	if (!m_options->dot.contains(" "))
		command.replace("\"" + m_options->dot + "\"", m_options->dot);
	// replace linux/mac style directory separators with windows style separators
	command.replace("/", "\\");
	command.prepend("\"");
	command.append("\"");
#endif

	//   qDebug() << command;
	ret = system(command.toLatin1());
	if (ret != 0) {
		qDebug() << "CsoundQt::createCodeGraph() Error running dot";
	}
	m_graphic = new GraphicWindow(this);
	m_graphic->show();
	m_graphic->openPng(pngFile.fileName());
	connect(m_graphic, SIGNAL(destroyed()), this, SLOT(closeGraph()));
}

void CsoundQt::closeGraph()
{
	qDebug("CsoundQt::closeGraph()");
}

bool CsoundQt::save()
{
	QString fileName = documentPages[curPage]->getFileName();
	if (fileName.isEmpty() or fileName.startsWith(":/examples/", Qt::CaseInsensitive)) {
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
		return saveFile(fileName);
	}
}

void CsoundQt::copy()
{
	if (helpPanel->hasFocus()) {
		helpPanel->copy();
	}
	else if (m_console->widgetHasFocus()) {
		m_console->copy();
	}
	else {
		documentPages[curPage]->copy();
	}
}

void CsoundQt::cut()
{
	documentPages[curPage]->cut();
}

void CsoundQt::paste()
{
	documentPages[curPage]->paste();
}

void CsoundQt::undo()
{
	//  qDebug() << "CsoundQt::undo()";
	documentPages[curPage]->undo();
}

void CsoundQt::redo()
{
	documentPages[curPage]->redo();
}

void CsoundQt::evaluateSection()
{
	QString text;
	if (!m_scratchPad->hasFocus()) {
		text = documentPages[curPage]->getActiveSection();
	}
	else {
		text = static_cast<DocumentView *>(m_scratchPad->widget())->getActiveSection();
	}

	evaluateString(text);
}

void CsoundQt::evaluate(QString code)
{
	QString evalCode;
	if (code.isEmpty()) { //evaluate current selection in current document
		if (!m_scratchPad->hasFocus()) {
			evalCode = documentPages[curPage]->getActiveText();
			if (evalCode.count("\n") <= 1) {
				documentPages[curPage]->gotoNextRow();
			}
		}
		else {
			evalCode = static_cast<DocumentView *>(m_scratchPad->widget())->getActiveText();
		}
	}
	else {
		evalCode = code;
	}	
	evaluateString(evalCode);
}


void CsoundQt::evaluateCsound(QString code)
{
#ifdef CSOUND6
	documentPages[curPage]->sendCodeToEngine(code);
#else
	qDebug() << "evaluateCsound only available in Csound6";
#endif
}

void CsoundQt::evaluatePython(QString code)
{
#ifdef QCS_PYTHONQT
	m_pythonConsole->evaluate(code);
#else
	showNoPythonQtWarning();
#endif
}

void CsoundQt::evaluateString(QString evalCode)
{
#ifdef CSOUND6
    TREE *testTree = NULL;
    if  (documentPages[curPage]->isRunning()) { // is it best way to if csound is running?
        CSOUND *csound = getEngine(curPage)->getCsound();
        if (csound!=NULL) {
            testTree = csoundParseOrc(csound,evalCode.toLocal8Bit()); // return not NULL, if the code is valid
            if (testTree == NULL)
                qDebug("Not Csound code or cannot compile");
        }
    }
#endif

    // first check if it is a scoreline, then if it is csound code, if that also that fails, try with python
    if (QRegExp("[if]\\s*-*[0-9]+\\s+[0-9]+\\s+[0-9]+.*\\n").indexIn(evalCode) >= 0) {
        sendEvent(evalCode);
    }
#ifdef CSOUND6
    else if (testTree!=NULL) { // the problem is, when the code is csound code, but with errors, it will be sent to python interpreter too
        evaluateCsound(evalCode);
    }
#endif
    else {
        evaluatePython(evalCode);
    }
}

void CsoundQt::setScratchPadMode(bool csdMode)
{
	DocumentView *view = static_cast<DocumentView *>(m_scratchPad->widget());
	view->setFileType(csdMode ? EDIT_CSOUND_MODE : EDIT_PYTHON_MODE);
	if (csdMode) {
		view->setBackgroundColor(QColor(240, 230, 230));
	} else {
		view->setBackgroundColor(QColor(230, 240, 230));
	}
}

void CsoundQt::setWidgetEditMode(bool active)
{
	for (int i = 0; i < documentPages.size(); i++) {
		documentPages[i]->setWidgetEditMode(active);
	}
}

//void CsoundQt::setWidgetClipboard(QString text)
//{
//  m_widgetClipboard = text;
//  for (int i = 0; i < documentPages.size(); i++) {
//    documentPages[i]->passWidgetClipboard(m_widgetClipboard);
//  }
//}

void CsoundQt::duplicate()
{
	qDebug() << "CsoundQt::duplicate()";
	documentPages[curPage]->duplicateWidgets();
}

QString CsoundQt::getSaveFileName()
{
	bool widgetsVisible = widgetPanel->isVisible();
	if (widgetsVisible && widgetPanel->isFloating())
		widgetPanel->hide(); // Necessary for Mac, as widget Panel covers open dialog
	bool helpVisible = helpPanel->isVisible();
	if (helpVisible && helpPanel->isFloating())
		helpPanel->hide(); // Necessary for Mac, as widget Panel covers open dialog
	bool inspectorVisible = m_inspector->isVisible();
	if (inspectorVisible && m_inspector->isFloating())
		m_inspector->hide(); // Necessary for Mac, as widget Panel covers open dialog
	QString dir = lastUsedDir;
	QString name = documentPages[curPage]->getFileName();
	dir += name.mid(name.lastIndexOf("/") + 1);
	QString fileName = QFileDialog::getSaveFileName(this, tr("Save File As"),
													dir,
													tr("Known Files (*.csd *.orc *.sco *.py);;Csound Files (*.csd *.orc *.sco *.CSD *.ORC *.SCO);;Python Files (*.py);;All Files (*)",
													   "Be careful to respect spacing parenthesis and usage of punctuation"));
	if (widgetsVisible) {
		if (!m_options->widgetsIndependent) {
			widgetPanel->show(); // Necessary for Mac, as widget Panel covers open dialog
		}
	}
	if (helpVisible)
		helpPanel->show(); // Necessary for Mac, as widget Panel covers open dialog
	if (inspectorVisible)
		m_inspector->show(); // Necessary for Mac, as widget Panel covers open dialog
	if (fileName.isEmpty())
		return QString("");
	if (isOpen(fileName) != -1 && isOpen(fileName) != curPage) {
		QMessageBox::critical(this, tr("CsoundQt"),
							  tr("The file is already open in another tab.\nFile not saved!"),
							  QMessageBox::Ok | QMessageBox::Default);
		return QString("");
	}
	//  if (!fileName.endsWith(".csd",Qt::CaseInsensitive) && !fileName.endsWith(".orc",Qt::CaseInsensitive)
	//    && !fileName.endsWith(".sco",Qt::CaseInsensitive) && !fileName.endsWith(".txt",Qt::CaseInsensitive)
	//    && !fileName.endsWith(".udo",Qt::CaseInsensitive))
	//    fileName += ".csd";
	if (fileName.isEmpty())
		fileName = name;
	if (!fileName.contains("."))
		fileName += ".csd";
	return fileName;
}

void CsoundQt::createQuickRefPdf()
{
	QString tempFileName(QDir::tempPath() + QDir::separator() + "QuteCsound Quick Reference.pdf");
	//  if (QFile::exists(tempFileName))
	//  {
	//
	//  }
	QString internalFileName = ":/doc/QuteCsound Quick Reference (0.4)-";
	internalFileName += m_configlists.languageCodes[m_options->language];
	internalFileName += ".pdf";
	if (!QFile::exists(internalFileName)) {
		internalFileName = ":/doc/QuteCsound Quick Reference (0.4).pdf";
	}
	//  qDebug() << "CsoundQt::createQuickRefPdf() Opening " << internalFileName;
	QFile file(internalFileName);
	file.open(QIODevice::ReadOnly);
	QFile quickRefFile(tempFileName);
	quickRefFile.open(QFile::WriteOnly);
	QDataStream quickRefIn(&quickRefFile);
	quickRefIn << file.readAll();
	quickRefFileName = tempFileName;
}

void CsoundQt::deleteTab(int index)
{
	if (index == -1) {
		index = curPage;
	}
	//  qDebug() << "CsoundQt::deleteCurrentTab()";
	disconnect(showLiveEventsAct, 0,0,0);
	documentPages[index]->stop();
	documentPages[index]->showLiveEventPanels(false);
	DocumentPage *d = documentPages[index];
	if (!m_options->widgetsIndependent) {
		QRect panelGeometry = widgetPanel->geometry();
		if (!widgetPanel->isFloating()) {
			panelGeometry.setX(-1);
			panelGeometry.setY(-1);
		}
		widgetPanel->takeWidgetLayout(panelGeometry);
	}
	documentPages.remove(index);
	documentTabs->removeTab(index);
	delete  d;
	if (curPage >= documentPages.size()) {
		curPage = documentPages.size() - 1;
	}
	if (curPage < 0)
		curPage = 0; // deleting the document page decreases curPage, so must check
}

void CsoundQt::openLogFile()
{
	if (logFile.isOpen()) {
		logFile.close();
	}
	logFile.setFileName(m_options->logFile);
	if (m_options->logFile.isEmpty())
		return;
	if (logFile.open(QIODevice::ReadWrite | QIODevice::Text)) {
		logFile.readAll();
		QString text = "--**-- " + QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss")
				+ " CsoundQt Logging Started: "
				+ "\n";
		logFile.write(text.toLatin1());
	}
	else {
		qDebug() << "CsoundQt::openLogFile() Error. Could not open log file! NO logging. " << logFile.fileName();
	}
}


void CsoundQt::setMidiInterface(int number)
{
	if (number >= 0 && number < 9998) {
		openMidiPort(number);
	}
	else {
		closeMidiPort();
	}
}

void CsoundQt::openMidiPort(int port)
{
#ifdef QCS_RTMIDI
	try {
		closeMidiPort();
	}
	catch ( RtError &error ) {
		error.printMessage();
	}

	m_midiin = new RtMidiIn();
	try {
		m_midiin->openPort(port, std::string("CsoundQt"));
	}
	catch ( RtError &error ) {
		qDebug() << "WidgetLayout::openMidiPort Error opening port";
		error.printMessage();
		m_midiin = 0;
		return;
	}
	//  qDebug() << "CsoundQt::openMidiPort opened port " << port;
	m_midiin->cancelCallback();
	m_midiin->setCallback(&midiMessageCallback, documentPages[curPage]->getWidgetLayout());  //TODO enable multiple layouts
#endif
	//  m_midiin->ignoreTypes(false, false, false);
}

void CsoundQt::closeMidiPort()
{
#ifdef QCS_RTMIDI
	if (m_midiin != 0) {
		m_midiin->closePort();
		delete m_midiin;
	}
	m_midiin = 0;
#endif
}

void CsoundQt::showNewFormatWarning()
{
	QMessageBox::warning(this, tr("New widget format"),
						 tr("  This version of CsoundQt implements a new format for storing widgets, which "
							"enables many of the new widget features you will find now.\n"
							"  The old format is still read and saved, so you will be able to open files in older versions "
							"but some of the features will not be passed to older versions.\n"),
						 QMessageBox::Ok);
}

void CsoundQt::setupEnvironment()
{
	if (m_options->sadirActive){
		int ret = csoundSetGlobalEnv("SADIR", m_options->sadir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting SADIR";
		}
	}
	else {
		csoundSetGlobalEnv("SADIR", "");
	}
	if (m_options->ssdirActive){
		int ret = csoundSetGlobalEnv("SSDIR", m_options->ssdir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting SSDIR";
		}
	}
	else {
		csoundSetGlobalEnv("SSDIR", "");
	}
	if (m_options->sfdirActive){
		int ret = csoundSetGlobalEnv("SFDIR", m_options->sfdir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting SFDIR";
		}
	}
	else {
		csoundSetGlobalEnv("SFDIR", "");
	}
	if (m_options->incdirActive){
		int ret = csoundSetGlobalEnv("INCDIR", m_options->incdir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting INCDIR";
		}
	}
	else {
		csoundSetGlobalEnv("INCDIR", "");
	}
	// csoundGetEnv must be called after Compile or Precompile,
	// But I need to set OPCODEDIR before compile.... So I can't know keep the old OPCODEDIR
	if (m_options->opcodedirActive) {
		csoundSetGlobalEnv("OPCODEDIR", m_options->opcodedir.toLatin1().constData());
	}
	if (m_options->opcodedir64Active) {
		csoundSetGlobalEnv("OPCODEDIR64", m_options->opcodedir64.toLatin1().constData());
	}
	if (m_options->opcode6dir64Active) {
		csoundSetGlobalEnv("OPCODE6DIR64", m_options->opcode6dir64.toLatin1().constData());
	}
#ifdef Q_OS_MAC
	// Use bundled opcodes if available
#ifdef USE_DOUBLE
	QString opcodedir = initialDir + "/../Frameworks/CsoundLib64.framework/Resources/Opcodes64";
#else
	QString opcodedir = initialDir + "/../Frameworks/CsoundLib.framework/Resources/Opcodes";
#endif
	if (QFile::exists(opcodedir)) {
#ifdef CSOUND6
#ifdef USE_DOUBLE
		csoundSetGlobalEnv("OPCODE6DIR64", opcodedir.toLocal8Bit().constData());
#else
		csoundSetGlobalEnv("OPCODE6DIR", opcodedir.toLocal8Bit().constData());
#endif
#else
#ifdef USE_DOUBLE
		csoundSetGlobalEnv("OPCODEDIR64", opcodedir.toLocal8Bit().constData());
#else
		csoundSetGlobalEnv("OPCODEDIR", opcodedir.toLocal8Bit().constData());
#endif
#endif
	}
#endif
}

bool CsoundQt::saveAs()
{
	QString fileName = getSaveFileName();
	if (!fileName.isEmpty() && saveFile(fileName)) {
		return true;
	}
	return false;
}

void CsoundQt::createApp()
{
	QString opcodeDir;
	if (!documentPages[curPage]->getFileName().endsWith(".csd")) {
		QMessageBox::critical(this, tr("Error"), tr("You can only create an app with a csd file."));
		return;
	}
	if (documentPages[curPage]->isModified() || documentPages[curPage]->getFileName().startsWith(":/")) {
		QMessageBox::StandardButton but =
				QMessageBox::question(this, tr("Save"), tr("Do you want to save before creating app?"),
									  QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
		if (but == QMessageBox::Yes) {
			bool ret = save();
			if (!ret) {
				qDebug() << "CsoundQt::createApp() Error saving file";
				return;
			}
		} else {
			QMessageBox::critical(this, tr("Abort"), tr("You must save the csd before creating the App!"));
			return;
		}
	}

	if (m_options->opcodedirActive) {
		// FIXME allow for OPCODEDIR64 if built for doubles
		opcodeDir = m_options->opcodedir.toLocal8Bit();
	}
	else {
#ifdef USE_DOUBLE
#ifdef Q_OS_LINUX
#endif
#ifdef Q_OS_SOLARIS
#endif
#ifdef Q_OS_WIN32
#endif
#ifdef Q_OS_MAC
		opcodeDir = "/Library/Frameworks/CsoundLib64.framework/Resources/Opcodes";
		//    opcodeDir = initialDir + "/CsoundQt.app/Contents/Frameworks/CsoundLib64.framework/Resources/Opcodes";
#endif
#else

#ifdef Q_OS_LINUX
#endif
#ifdef Q_OS_SOLARS
#endif
#ifdef Q_OS_WIN32
#endif
#ifdef Q_OS_MAC
#ifdef USE_DOUBLE
		opcodeDir = "/Library/Frameworks/CsoundLib.framework/Resources/Opcodes";
#else
		opcodeDir = "/Library/Frameworks/CsoundLib64.framework/Resources/Opcodes";
#endif
		//    opcodeDir = initialDir + "/CsoundQt.app/Contents/Frameworks/CsoundLib.framework/Resources/Opcodes";
#endif


#endif
	}
	QString fullPath = documentPages[curPage]->getFileName();
	AppWizard wizard(this, opcodeDir, fullPath, m_options->sdkDir);
	AppProperties existingProperties = documentPages[curPage]->getAppProperties();
	if (existingProperties.used) {
		wizard.setField("appName", QVariant(existingProperties.appName));
		wizard.setField("targetDir", QVariant(existingProperties.targetDir));
		wizard.setField("author", QVariant(existingProperties.author));
		wizard.setField("version", QVariant(existingProperties.version));
		wizard.setField("email", QVariant(existingProperties.email));
		wizard.setField("website", QVariant(existingProperties.website));
		wizard.setField("instructions", QVariant(existingProperties.instructions));
		wizard.setField("autorun", QVariant(existingProperties.autorun));
		wizard.setField("showRun", QVariant(existingProperties.showRun));
		wizard.setField("saveState", QVariant(existingProperties.saveState));
		wizard.setField("runMode", QVariant(existingProperties.runMode));
		wizard.setField("newParser", QVariant(existingProperties.newParser));
		wizard.setField("useSdk", QVariant(existingProperties.useSdk ? 1 : 0));
		wizard.setField("useCustomPaths", QVariant(existingProperties.useCustomPaths));
		wizard.setField("libDir", QVariant(existingProperties.libDir));
		wizard.setField("opcodeDir", QVariant(existingProperties.opcodeDir));
	} else { // Put in default values
		QString appDir = fullPath.left(fullPath.lastIndexOf(QDir::separator()) );
		if (appDir.startsWith(":/")) { // For embedded examples
			appDir = QDir::homePath();
		}
		QString appName = fullPath.mid(fullPath.lastIndexOf(QDir::separator()) + 1);
		appName = appName.remove(".csd");
		wizard.setField("appName", appName);
		wizard.setField("targetDir", appDir);
		if (m_options->sdkDir.isEmpty()) { // No sdk,
			wizard.setField("customPaths", true);
#if defined(Q_OS_LINUX) || defined(Q_OS_SOLARIS)
			wizard.setField("libDir", "/usr/lib");
			if (opcodeDir.isEmpty()) {
				wizard.setField("opcodeDir", "/usr/lib/csound/plugins");
			}
#endif
#ifdef Q_OS_WIN32
			wizard.setField("libDir", "");
			if (opcodeDir.isEmpty()) {
				wizard.setField("opcodeDir", "");
			}
#endif
#ifdef Q_OS_MAC
			wizard.setField("libDir", "/Library/Frameworks");
#endif
		}
	}
	wizard.exec();
	if (wizard.result() == QDialog::Accepted) {
		AppProperties properties;
		properties.used = true;
		properties.appName = wizard.field("appName").toString();
		properties.targetDir = wizard.field("targetDir").toString();
		properties.author = wizard.field("author").toString();
		properties.version = wizard.field("version").toString();
		properties.date = QDateTime::currentDateTime().toString("MMMM d yyyy");
		properties.email = wizard.field("email").toString();
		properties.website = wizard.field("website").toString();
		properties.instructions = wizard.field("instructions").toString();
		properties.autorun = wizard.field("autorun").toBool();
		properties.showRun = wizard.field("showRun").toBool();
		properties.saveState = wizard.field("saveState").toBool();
		properties.runMode = wizard.field("runMode").toInt();
		properties.newParser = wizard.field("newParser").toBool();
		properties.useSdk = wizard.field("useSdk").toBool();
		properties.useCustomPaths = wizard.field("useCustomPaths").toBool();
		properties.libDir = wizard.field("libDir").toString();
		properties.opcodeDir = wizard.field("opcodeDir").toString();

		documentPages[curPage]->setAppProperties(properties);
		bool ret = save(); // Must save to apply properties to file on disk.
		if (!ret) {
			qDebug() << "CsoundQt::createApp() Error saving file";
			return;
		}
		wizard.makeApp();
	}
}

bool CsoundQt::saveNoWidgets()
{
	QString fileName = getSaveFileName();
	if (fileName != "")
		return saveFile(fileName, false);
	else
		return false;
}

void CsoundQt::info()
{
	QString text = tr("Full Path:") + " " + documentPages[curPage]->getFileName() + "\n\n";
	text += tr("Number of lines (Csound Text):") + " " + QString::number(documentPages[curPage]->lineCount(true)) + "\n";
	text += tr("Number of characters (Csound Text):") + " " + QString::number(documentPages[curPage]->characterCount(true)) + "\n";
	text += tr("Number of lines (total):") + " " + QString::number(documentPages[curPage]->lineCount()) + "\n";
	text += tr("Number of characters (total):") + " " + QString::number(documentPages[curPage]->characterCount()) + "\n";
	text += tr("Number of instruments:") + " " + QString::number(documentPages[curPage]->instrumentCount()) + "\n";
	text += tr("Number of UDOs:") + " " + QString::number(documentPages[curPage]->udoCount()) + "\n";
	text += tr("Number of Widgets:") + " " + QString::number(documentPages[curPage]->widgetCount()) + "\n";
	text += tr("Embedded Files:") + " " + documentPages[curPage]->embeddedFiles() + "\n";
	QMessageBox::information(this, tr("File Information"),
							 text,
							 QMessageBox::Ok,
							 QMessageBox::Ok);
}

bool CsoundQt::closeTab(bool forceCloseApp, int index)
{
	if (index == -1) {
		index = curPage;
	}
	//   qDebug("CsoundQt::closeTab() curPage = %i documentPages.size()=%i", curPage, documentPages.size());
	if (documentPages.size() > 0 && documentPages[index]->isModified()) {
		QString message = tr("The document ")
				+ (documentPages[index]->getFileName() != ""
				? documentPages[index]->getFileName(): "untitled.csd")
				+ tr("\nhas been modified.\nDo you want to save the changes before closing?");
		int ret = QMessageBox::warning(this, tr("CsoundQt"),
									   message,
									   QMessageBox::Yes | QMessageBox::Default,
									   QMessageBox::No,
									   QMessageBox::Cancel | QMessageBox::Escape);
		if (ret == QMessageBox::Cancel)
			return false;
		else if (ret == QMessageBox::Yes) {
			if (!save())
				return false;
		}
	}
	if (!forceCloseApp) {
		if (documentPages.size() <= 1) {
			if (QMessageBox::warning(this, tr("CsoundQt"),
									 tr("Do you want to exit CsoundQt?"),
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
	}
	deleteTab(index);
	changePage(curPage);
	return true;
}

void CsoundQt::print()
{
	QPrinter printer;
	QPrintDialog *dialog = new QPrintDialog(&printer, this);
	dialog->setWindowTitle(tr("Print Document"));
	//   if (editor->textCursor().hasSelection())
	//     dialog->addEnabledOption(QAbstractPrintDialog::PrintSelection);
	if (dialog->exec() != QDialog::Accepted)
		return;
	documentPages[curPage]->print(&printer);
}

void CsoundQt::findReplace()
{
	documentPages[curPage]->findReplace();
}

void CsoundQt::findString()
{
	documentPages[curPage]->findString();
}

bool CsoundQt::join(bool ask)
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
		QString name = documentPages[i]->getFileName();
		if (name.endsWith(".orc"))
			list1->addItem(name);
		else if (name.endsWith(".sco"))
			list2->addItem(name);
	}
	QString name = documentPages[curPage]->getFileName();
	QList<QListWidgetItem *> itemList = list1->findItems(name, Qt::MatchExactly);
	if (itemList.size() == 0) {
		itemList = list1->findItems(name.replace(".sco", ".orc"),Qt::MatchExactly);
	}
	if (itemList.size() > 0) {
		list1->setCurrentItem(itemList[0]);
	}
	QList<QListWidgetItem *> itemList2 = list2->findItems(name.replace(".orc", ".sco"),
														  Qt::MatchExactly);
	if (itemList2.size() == 0) {
		itemList2 = list1->findItems(name,Qt::MatchExactly);
	}
	if (itemList2.size() > 0)
		list2->setCurrentItem(itemList2[0]);
	if (itemList.size() == 0 or itemList.size() == 0) {
		if (!ask) {
			QMessageBox::warning(this, tr("Join"),
								 tr("Please open the orc and sco files in CsoundQt first!"));
		}
		return false;
	}
	if (!ask || dialog.exec() == QDialog::Accepted) {
		QString orcText = "";
		QString scoText = "";
		for (int i = 0; i < documentPages.size(); i++) {
			QString name = documentPages[i]->getFileName();
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
		documentPages[curPage]->loadTextString(text);
		return true;
	}
	//   else {
	//     qDebug("CsoundQt::join() : No Action");
	//   }
	return false;
}

void CsoundQt::showUtilities(bool show)
{
	//  qDebug() << "CsoundQt::showUtilities" << show;
	if (!show) {
		if (utilitiesDialog != 0 && utilitiesDialog->close()) {
			utilitiesDialog = 0;
		}
	}
	else {
		utilitiesDialog = new UtilitiesDialog(this, m_options/*, _configlists*/);
		connect(utilitiesDialog, SIGNAL(Close(bool)), showUtilitiesAct, SLOT(setChecked(bool)));
		connect(utilitiesDialog, SIGNAL(runUtility(QString)), this, SLOT(runUtility(QString)));
		utilitiesDialog->setModal(false);
		utilitiesDialog->show();
	}
}

void CsoundQt::inToGet()
{
	documentPages[curPage]->inToGet();
}

void CsoundQt::getToIn()
{
	documentPages[curPage]->getToIn();
}

void CsoundQt::updateCsladspaText()
{
	documentPages[curPage]->updateCsLadspaText();
}

void CsoundQt::updateCabbageText()
{
	documentPages[curPage]->updateCabbageText();
}

void CsoundQt::setCurrentAudioFile(const QString fileName)
{
	currentAudioFile = fileName;
}

void CsoundQt::play(bool realtime, int index)
{
	// TODO make csound pause if it is already running
	int oldPage = curPage;
	if (index == -1) {
		index = curPage;
	}
	if (index < 0 && index >= documentPages.size()) {
		qDebug() << "CsoundQt::play index out of range " << index;
		return;
	}
	curPage = index;
	if (documentPages[curPage]->getFileName().isEmpty()) {
		QMessageBox::warning(this, tr("CsoundQt"),
							 tr("This file has not been saved\nPlease select name and location."));
		if (!saveAs()) {
			if (curPage == oldPage) {
				runAct->setChecked(false);
			}
			curPage = oldPage;
			return;
		}
	}
	else if (documentPages[curPage]->isModified()) {
		if (m_options->saveChanges && !save()) {
			if (curPage == oldPage) {
				runAct->setChecked(false);
			}
			curPage = oldPage;
			return;
		}
	}
	QString fileName = documentPages[curPage]->getFileName();
	QString fileName2;
	QString msg = "__**__ " + QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss");
	msg += " Play: " + fileName + "\n";
	logMessage(msg);
	m_options->csdPath = "";
	if (fileName.contains('/')) {
		//FIXME is it necessary to set the csdPath here?
		//    m_options->csdPath =
		//        documentPages[curPage]->fileName.left(documentPages[curPage]->fileName.lastIndexOf('/'));
		QDir::setCurrent(fileName.left(fileName.lastIndexOf('/')));
	}
#ifdef QCS_PYTHONQT
	if (fileName.endsWith(".py",Qt::CaseInsensitive)) {
		m_pythonConsole->runScript(fileName);
		runAct->setChecked(false);
		curPage = documentTabs->currentIndex();
		return;
	}
#endif
	if (!fileName.endsWith(".csd",Qt::CaseInsensitive) && !fileName.endsWith(".py",Qt::CaseInsensitive))  {
		if (documentPages[curPage]->askForFile)
			getCompanionFileName();
		// FIXME run orc file when sco companion is currently active
		if (fileName.endsWith(".sco",Qt::CaseInsensitive)) {
			//Must switch filename order when open file is a sco file
			fileName2 = fileName;
			fileName = documentPages[curPage]->getCompanionFileName();
		}
		else
			fileName2 = documentPages[curPage]->getCompanionFileName();
	}
	QString runFileName1, runFileName2;
	QTemporaryFile csdFile, csdFile2; // TODO add support for orc/sco pairs
	if (fileName.startsWith(":/examples/", Qt::CaseInsensitive) || !m_options->saveChanges) {
		QString tmpFileName = QDir::tempPath();
		if (!tmpFileName.endsWith("/") and !tmpFileName.endsWith("\\")) {
			tmpFileName += QDir::separator();
		}
		if (fileName.endsWith(".csd",Qt::CaseInsensitive)) {
			tmpFileName += QString("csound-tmpXXXXXXXX.csd");
			csdFile.setFileTemplate(tmpFileName);
			if (!csdFile.open()) {
				qDebug() << "Error creating temporary file " << tmpFileName;
				QMessageBox::critical(this,
									  tr("CsoundQt"),
									  tr("Error creating temporary file."),
									  QMessageBox::Ok);
				return;
			}
			QString csdText = documentPages[curPage]->getBasicText();
			runFileName1 = csdFile.fileName();
			csdFile.write(csdText.toLatin1());
			csdFile.flush();
		}
	}
	else {
		runFileName1 = fileName;
	}
	runFileName2 = documentPages[curPage]->getCompanionFileName();
	m_options->fileName1 = runFileName1;
	m_options->fileName2 = runFileName2;
	m_options->rt = realtime;
	if (!m_options->simultaneousRun) {
		stopAll();
	}
	if (curPage == oldPage) {
		runAct->setChecked(true);  // In case the call comes from a button
	}
	if (documentPages[curPage]->usesFltk() && m_options->terminalFLTK) {
		runInTerm();
		curPage = oldPage;
		return;
	}
	int ret = documentPages[curPage]->play(m_options);
	if (ret == -1) {
		QMessageBox::critical(this,
							  tr("CsoundQt"),
							  tr("Internal error running Csound."),
							  QMessageBox::Ok);
	} else if (ret == -2) { // Error creating temporary file
		runAct->setChecked(false);
		qDebug() << "CsoundQt::play - Error creating temporary file";
	} else if (ret == -3) { // Csound compilation failed
		runAct->setChecked(false);
	} else if (ret == 0) { // No problem
		if (m_options->enableWidgets and m_options->showWidgetsOnRun && fileName.endsWith(".csd")) {
			showWidgetsAct->setChecked(true);
			if (!documentPages[curPage]->usesFltk()) { // Don't bring up widget panel if there's an FLTK panel
				if (!m_options->widgetsIndependent) {
					widgetPanel->setVisible(true);
				}
				else {
					documentPages[curPage]->widgetsVisible(true);
				}
				widgetPanel->setFocus(Qt::OtherFocusReason);
				documentPages[curPage]->showLiveEventPanels(showLiveEventsAct->isChecked());
				documentPages[curPage]->focusWidgets();
			}
		}
	}
	curPage = oldPage;
}

void CsoundQt::runInTerm(bool realtime)
{
	QString fileName = documentPages[curPage]->getFileName();
	QTemporaryFile tempFile(QDir::tempPath() + QDir::separator() + "CsoundQtExample-XXXXXX.csd");
	tempFile.setAutoRemove(false);
	if (fileName.startsWith(":/")) {
		if (!tempFile.open()) {
			qDebug() << "CsoundQt::runCsound() : Error creating temp file";
			runAct->setChecked(false);
			return;
		}
		QString csdText = documentPages[curPage]->getBasicText();
		fileName = tempFile.fileName();
		tempFile.write(csdText.toLatin1());
		tempFile.flush();
		if (!tempScriptFiles.contains(fileName))
			tempScriptFiles << fileName;
	}
	//  QString script = generateScript(m_options->realtime, fileName);
	QString executable = fileName.endsWith(".py") ? m_options->pythonExecutable : "";
	QString script = generateScript(realtime, fileName, executable);
	QTemporaryFile scriptFile(QDir::tempPath() + QDir::separator() + SCRIPT_NAME);
	scriptFile.setAutoRemove(false);
	if (!scriptFile.open()) {
		runAct->setChecked(false);
		return;
	}
	QTextStream out(&scriptFile);
	out << script;
	//     file.flush();
	scriptFile.close();
	scriptFile.setPermissions (QFile::ExeOwner| QFile::WriteOwner| QFile::ReadOwner);
	QString scriptFileName = scriptFile.fileName();

	QString options;
#ifdef Q_OS_LINUX
	options = "-e " + scriptFileName;
#endif
#ifdef Q_OS_SOLARIS
	options = "-e " + scriptFileName;
#endif
#ifdef Q_OS_MAC
	options = scriptFileName;
#endif
#ifdef Q_OS_WIN32
	options = scriptFileName;
	qDebug() << "m_options->terminal == " << m_options->terminal;
#endif
	if (execute(m_options->terminal, options)) {
		QMessageBox::critical(this, tr("Error running terminal"),
							  tr("Could not run terminal program:\n   %1\n"
								 "Check environment tab in preferences.").arg(m_options->terminal));
	}
	runAct->setChecked(false);
	if (!tempScriptFiles.contains(scriptFileName))
		tempScriptFiles << scriptFileName;
}

void CsoundQt::pause(int index)
{
	int docIndex = index;
	if (docIndex == -1) {
		docIndex = curPage;
	}
	if (docIndex >= 0 && docIndex < documentPages.size()) {
		documentPages[docIndex]->pause();
	}
	//  if (ud->isRunning()) {
	//    perfThread->TogglePause();
	//  }
}

void CsoundQt::stop(int index)
{
	// Must guarantee that csound has stopped when it returns
	qDebug() <<"CsoundQt::stop() " <<  index;
	int docIndex = index;
	if (docIndex == -1) {
		docIndex = curPage;
	}
	if (curPage >= documentPages.size()) {
		return; // A bit of a hack to avoid crashing when documents are deleted very quickly...
	}
	Q_ASSERT(docIndex >= 0);
	if (docIndex < documentPages.size()) {
		if (documentPages[docIndex]->isRunning()) {
			documentPages[docIndex]->stop();
		}
	}
	markStopped();
}

void CsoundQt::stopAll()
{
	for (int i = 0; i < documentPages.size(); i++) {
		documentPages[i]->stop();
	}
	markStopped();
}

void CsoundQt::markStopped()
{
	runAct->setChecked(false);
	recAct->setChecked(false);
}

void CsoundQt::perfEnded()
{
	runAct->setChecked(false);
}

void CsoundQt::record(bool rec)
{
	if (rec) {
		if (!documentPages[curPage]->isRunning()) {
			play();
		}
		int ret = documentPages[curPage]->record(m_options->sampleFormat);
		if (ret != 0) {
			recAct->setChecked(false);
		}
	}
	else {
		documentPages[curPage]->stopRecording();
	}
}


void CsoundQt::sendEvent(QString eventLine, double delay)
{
	sendEvent(curCsdPage, eventLine, delay);
}

void CsoundQt::sendEvent(int index, QString eventLine, double delay)
{
	int docIndex = index;
	if (docIndex == -1) {
		docIndex = curPage;
	}
	if (docIndex >= 0 && docIndex < documentPages.size()) {
		documentPages[docIndex]->queueEvent(eventLine, delay);
	}
}

void CsoundQt::render()
{
	if (m_options->fileAskFilename) {
		QString defaultFile;
		if (m_options->fileOutputFilenameActive) {
			defaultFile = m_options->fileOutputFilename;
		}
		else {
			defaultFile = lastFileDir;
		}
		QFileDialog dialog(this,tr("Output Filename"),defaultFile);
		dialog.setAcceptMode(QFileDialog::AcceptSave);
		//    dialog.setConfirmOverwrite(false);
		QString filter = QString(m_configlists.fileTypeLongNames[m_options->fileFileType] + " Files ("
								 + m_configlists.fileTypeExtensions[m_options->fileFileType] + ")");
		dialog.selectNameFilter(filter);
		if (dialog.exec() == QDialog::Accepted) {
			QString extension = m_configlists.fileTypeExtensions[m_options->fileFileType].left(m_configlists.fileTypeExtensions[m_options->fileFileType].indexOf(";"));
			//       // Remove the '*' from the extension
			extension.remove(0,1);
			m_options->fileOutputFilename = dialog.selectedFiles()[0];
			if (!m_options->fileOutputFilename.endsWith(".wav")
					&& !m_options->fileOutputFilename.endsWith(".aif")
					&& !m_options->fileOutputFilename.endsWith(extension) ) {
				m_options->fileOutputFilename += extension;
			}
			if (QFile::exists(m_options->fileOutputFilename)) {
				int ret = QMessageBox::warning(this, tr("CsoundQt"),
											   tr("The file %1 \nalready exists.\n"
												  "Do you want to overwrite it?").arg(m_options->fileOutputFilename),
											   QMessageBox::Save | QMessageBox::Cancel,
											   QMessageBox::Save);
				if (ret == QMessageBox::Cancel)
					return;
			}
			lastFileDir = dialog.directory().path();
		}
		else {
			return;
		}
	}
	QString outName = m_options->fileOutputFilename;
#ifdef Q_OS_WIN32
	outName = outName.replace('\\', '/');
#endif
	if (outName.isEmpty()) {
		outName = "test.wav";
	}
	setCurrentAudioFile(outName);
	play(false);
}

void CsoundQt::openExternalEditor()
{
	QString name = "";
	if (m_options->sfdirActive) {
		name = m_options->sfdir + (m_options->sfdir.endsWith("/") ? "" : "/");
	}
	name += currentAudioFile;
	QString optionsText = documentPages[curPage]->getOptionsText();
	if (currentAudioFile == "") {
		if (!optionsText.contains(QRegExp("\\W-o"))) {
			name += "test.wav";
		}
		else {
			optionsText = optionsText.mid(optionsText.indexOf(QRegExp("\\W-o")) + 3);
			optionsText = optionsText.left(optionsText.indexOf("\n")).trimmed();
			optionsText = optionsText.left(optionsText.indexOf("-")).trimmed();
			if (!optionsText.startsWith("dac"))
				name += optionsText;
		}
	}
	if (!QFile::exists(name)) {
		QMessageBox::critical(this, tr("Render not available"),
							  tr("Could not find rendered file. Please render before calling external editor."));
	}
	if (!m_options->waveeditor.isEmpty()) {
		name = "\"" + name + "\"";
		execute(m_options->waveeditor, name);
	}
	else {
		QDesktopServices::openUrl(QUrl::fromLocalFile (name));
	}
}

void CsoundQt::openExternalPlayer()
{
	QString name = "";
	if (m_options->sfdirActive) {
		name = m_options->sfdir + (m_options->sfdir.endsWith("/") ? "" : "/");
	}
	name += currentAudioFile;
	QString optionsText = documentPages[curPage]->getOptionsText();
	if (currentAudioFile == "") {
		if (!optionsText.contains(QRegExp("\\W-o"))) {
			name += "test.wav";
		}
		else {
			optionsText = optionsText.mid(optionsText.indexOf(QRegExp("\\W-o")) + 3);
			optionsText = optionsText.left(optionsText.indexOf("\n")).trimmed();
			optionsText = optionsText.left(optionsText.indexOf(QRegExp("-"))).trimmed();
			if (!optionsText.startsWith("dac"))
				name += optionsText;
		}
	}
	if (!QFile::exists(name)) {
		QMessageBox::critical(this, tr("Render not available"),
							  tr("Could not find rendered file. Please render before calling external player."));
	}
	if (!m_options->waveplayer.isEmpty()) {
		name = "\"" + name + "\"";
		execute(m_options->waveplayer, name);
	}
	else {
		QDesktopServices::openUrl(QUrl::fromLocalFile (name));
	}
}

void CsoundQt::setEditorFocus()
{
	documentPages[curPage]->setEditorFocus();
	this->raise();
}

void CsoundQt::setHelpEntry()
{
	QString text = documentPages[curPage]->wordUnderCursor();
	if (text.startsWith('#')) { // For #define and friends
		text.remove(0,1);
	}
	QString dir = m_options->csdocdir;
	// For self contained app on OS X
#ifdef Q_OS_MAC
	if (dir == "") {
#ifdef USE_DOUBLE
		dir = initialDir + "/CsoundQt.app/Contents/Frameworks/CsoundLib64.framework/Versions/5.2/Resources/Manual";
#else
		dir = initialDir + "/CsoundQt.app/Contents/Frameworks/CsoundLib.framework/Versions/5.2/Resources/Manual";
#endif
	}
#endif
	if (text.startsWith("http://")) {
		openExternalBrowser(QUrl(text));
	}
	else if (dir != "") {
		if (text == "0dbfs")
			text = "Zerodbfs";
		else if (text.contains("CsOptions"))
			text = "CommandUnifile";
		else if (text.startsWith("chn_"))
			text = "chn";
		helpPanel->docDir = dir;
		QString fileName = dir + "/" + text + ".html";
		if (QFile::exists(fileName)) {
			helpPanel->loadFile(fileName);
		}
		//    else {
		//        helpPanel->loadFile(dir + "/index.html");
		//    }
		helpPanel->show();
	}
	else {
		QMessageBox::critical(this,
							  tr("Error"),
							  tr("HTML Documentation directory not set!\n"
								 "Please go to Edit->Options->Environment and select directory\n"));
	}
}

void CsoundQt::setFullScreen(bool full)
{
	if (full) {
		this->showFullScreen();
	}
	else {
		this->showNormal();
	}
}

void CsoundQt::splitView(bool split)
{
	if (split) {
		int mode = showOrcAct->isChecked() ? 2 : 0 ;
		mode |= showScoreAct->isChecked() ? 4 : 0 ;
		mode |= showOptionsAct->isChecked() ? 8 : 0 ;
		mode |= showFileBAct->isChecked() ? 16 : 0 ;
		mode |= showOtherAct->isChecked() ? 32 : 0 ;
		mode |= showOtherCsdAct->isChecked() ? 64 : 0 ;
		mode |= showWidgetEditAct->isChecked() ? 128 : 0 ;
		if (mode == 0) {
			mode = 2+4+8;
		}
		documentPages[curPage]->setViewMode(mode);
	}
	else {
		documentPages[curPage]->setViewMode(0);
	}
}

void CsoundQt::openManualExample(QString fileName)
{
	loadFile(fileName);
}

void CsoundQt::openExternalBrowser(QUrl url)
{
	if (!url.isEmpty()) {
		if (!m_options->browser.isEmpty()) {
			if (QFile::exists(m_options->browser)) {
				execute(m_options->browser,"\"" + url.toString() + "\"");
			}
			else {
				QMessageBox::critical(this, tr("Error"),
									  tr("Could not open external browser:\n%1\nPlease check preferences.").arg(m_options->browser));
			}
		}
		else {
			QDesktopServices::openUrl(url);
		}
	}
	else {
		if (m_options->csdocdir != "") {
			url = QUrl ("file://" + m_options->csdocdir + "/"
						+ documentPages[curPage]->wordUnderCursor() + ".html");
			if (!m_options->browser.isEmpty()) {
				execute(m_options->browser, "\"" + url.toString() + "\"");
			}
			else {
				QDesktopServices::openUrl(url);
			}
		}
		else {
			QMessageBox::critical(this,
								  tr("Error"),
								  tr("HTML Documentation directory not set!\n"
									 "Please go to Edit->Options->Environment and select directory\n"));
		}
	}
}

void CsoundQt::openFLOSSManual()
{
	openExternalBrowser(QUrl("http://en.flossmanuals.net/csound/"));
}

void CsoundQt::openQuickRef()
{
	if (!m_options->pdfviewer.isEmpty()) {
#ifndef Q_OS_MAC
		if (!QFile::exists(m_options->pdfviewer)) {
			QMessageBox::critical(this,
								  tr("Error"),
								  tr("PDF viewer not found!\n"
									 "Please go to Edit->Options->Environment and select directory\n"));
		}
#endif
		QString arg = "\"" + quickRefFileName + "\"";
		//    qDebug() << arg;
		execute(m_options->pdfviewer, arg);
	}
	else {
		QDesktopServices::openUrl(QUrl::fromLocalFile (quickRefFileName));
	}
}

void CsoundQt::resetPreferences()
{
	int ret = QMessageBox::question (this, tr("Reset Preferences"),
									 tr("Are you sure you want to revert CsoundQt's preferences\nto their initial default values? "),
									 QMessageBox::Ok | QMessageBox::Cancel, QMessageBox::Ok);
	if (ret ==  QMessageBox::Ok) {
		m_resetPrefs = true;
		QMessageBox::information(this, tr("Reset Preferences"),
								 tr("Preferences have been reset.\nYou must restart CsoundQt."),
								 QMessageBox::Ok, QMessageBox::Ok);
	}
}

void CsoundQt::reportBug()
{
	QUrl url("http://sourceforge.net/tracker/?group_id=227265&atid=1070588");
	if (!m_options->browser.isEmpty()) {
		execute(m_options->browser,"\"" + url.toString() + "\"");
	}
	else {
		QDesktopServices::openUrl(url);
	}
}

void CsoundQt::requestFeature()
{
	QUrl url("http://sourceforge.net/tracker/?atid=1070591&group_id=227265&func=browse");
	if (!m_options->browser.isEmpty()) {
		execute(m_options->browser,"\"" + url.toString() + "\"");
	}
	else {
		QDesktopServices::openUrl(url);
	}
}

void CsoundQt::chat()
{
	QUrl url("http://webchat.freenode.net/?channels=#csound");
	if (!m_options->browser.isEmpty()) {
		execute(m_options->browser,"\"" + url.toString() + "\"");
	}
	else {
		QDesktopServices::openUrl(url);
	}
}

void CsoundQt::openShortcutDialog()
{
	KeyboardShortcuts dialog(this, m_keyActions);
	connect(&dialog, SIGNAL(restoreDefaultShortcuts()), this, SLOT(setDefaultKeyboardShortcuts()));
	dialog.exec();
}

void CsoundQt::statusBarMessage(QString message)
{
	statusBar()->showMessage(message);
}

void CsoundQt::about()
{
	About *msgBox = new About(this);
	msgBox->setWindowFlags(msgBox->windowFlags() | Qt::FramelessWindowHint);
	QString text ="<h1>";
	text += tr("by: Andres Cabrera and others") +"</h1><h2>",
			text += tr("Version %1").arg(QCS_VERSION) + "</h2><h2>";
	text += tr("Released under the LGPLv2 or GPLv3") + "</h2>";
	text += tr("Using Csound version:") + QString::number(csoundGetVersion()) + " ";
	text += tr("Precision:") + (csoundGetSizeOfMYFLT() == 8 ? "double (64-bit)" : "float (32-bit)") + "<br />";
#ifdef QCS_PYTHONQT
	text += tr("Built with PythonQt support.")+ "<br />";
#endif
	text += tr("French translation: Fran&ccedil;ois Pinot") + "<br />";
	text += tr("German translation: Joachim Heintz") + "<br />";
	text += tr("Portuguese translation: Victor Lazzarini") + "<br />";
	text += tr("Italian translation: Francesco") + "<br />";
	text += tr("Turkish translation: Ali Isciler") + "<br />";
	text += tr("Finnish translation: Niko Humalam&auml;ki") + "<br />";
	text += tr("Russian translation: Gleb Rogozinsky") + "<br />";
	text += QString("<center><a href=\"http://qutecsound.sourceforge.net\">qutecsound.sourceforge.net</a></center>");
	text += QString("<center><a href=\"mailto:mantaraya36@gmail.com\">mantaraya36@gmail.com</a></center><br />");
	text += tr("If you find CsoundQt useful, please consider donating to the project:");
	text += "<br /><center><a href=\"http://sourceforge.net/donate/index.php?group_id=227265\"><img src=\":/images/project-support.jpg\" width=\"88\" height=\"32\" border=\"0\" alt=\"Support This Project\" /></a></center>";

	text += tr("Please file bug reports and feature suggestions in the ");
	text += "<a href=\"http://sourceforge.net/tracker/?group_id=227265\">";
	text += tr("CsoundQt tracker") + "</a>.<br />";

	text +=tr("Mailing Lists:");
	text += "<br /><a href=\"http://lists.sourceforge.net/lists/listinfo/qutecsound-users\">Join/Read CsoundQt Mailing List</a><br />";
	text += "<a href=\"http://old.nabble.com/Csound-f480.html\">Join/Read Csound Mailing List</a><br />";
	text += "<a href=\"https://lists.sourceforge.net/lists/listinfo/csound-devel\"> Join/Read Csound Developer List</a><br />";

	text += "<br />"+ tr("Other Resources:") + "<br />";
	text += "<a href=\"http://www.csounds.com\">cSounds.com</a><br />";
	text += "<a href=\"http://csound.sourceforge.net\">Csound Page at SourceForge</a><br />";
	text += "<a href=\"http://csound.sourceforge.net\">Csound Journal</a><br />";
	text += "<a href=\"http://csound.noisepages.com/\">The Csound Blog</a><br />";
	text +=  "<br />" + tr("Supported by:") +"<br />";
	text +=  "<a href=\"http://www.incontri.hmt-hannover.de/\">Incontri - HMT Hannover</a><br />";
	text += "<a href=\"http://sourceforge.net/project/project_donations.php?group_id=227265\">";
	text +=  tr("And other generous users.") + "</a><br />";

	msgBox->getTextEdit()->setOpenLinks(false);
	msgBox->setHtmlText(text);
	connect(msgBox->getTextEdit(), SIGNAL(anchorClicked(QUrl)), this, SLOT(openExternalBrowser(QUrl)));
	msgBox->exec();
	delete msgBox;
}

void CsoundQt::donate()
{
	openExternalBrowser(QUrl("http://sourceforge.net/donate/index.php?group_id=227265"));
}

void CsoundQt::documentWasModified()
{
	setWindowModified(true);
	//  qDebug() << "CsoundQt::documentWasModified()";
	documentTabs->setTabIcon(curPage, modIcon);
}

void CsoundQt::configure()
{
	ConfigDialog dialog(this, m_options, &m_configlists);
	dialog.setCurrentTab(configureTab);
	dialog.newParserCheckBox->setEnabled(csoundGetVersion() > 5125);
	dialog.multicoreCheckBox->setEnabled(csoundGetVersion() > 5125);
	dialog.numThreadsSpinBox->setEnabled(csoundGetVersion() > 5125);
	if (dialog.exec() == QDialog::Accepted) {
		applySettings();
	}
	configureTab = dialog.currentTab();
}

void CsoundQt::applySettings()
{
	for (int i = 0; i < documentPages.size(); i++) {
		setCurrentOptionsForPage(documentPages[i]);
	}
	Qt::ToolButtonStyle toolButtonStyle = (m_options->iconText?
											   Qt::ToolButtonTextUnderIcon: Qt::ToolButtonIconOnly);
	
	setUnifiedTitleAndToolBarOnMac(m_options->iconText);
//	fileToolBar->setToolButtonStyle(toolButtonStyle);
//	editToolBar->setToolButtonStyle(toolButtonStyle);
	controlToolBar->setToolButtonStyle(toolButtonStyle);
	configureToolBar->setToolButtonStyle(toolButtonStyle);
//	fileToolBar->setVisible(m_options->showToolbar);
//	editToolBar->setVisible(m_options->showToolbar);
	controlToolBar->setVisible(m_options->showToolbar);
	configureToolBar->setVisible(m_options->showToolbar);

	QString currentOptions = (m_options->useAPI ? tr("API") : tr("Console")) + " ";
	//  if (m_options->useAPI) {
	//    currentOptions +=  (m_options->thread ? tr("Thread") : tr("NoThread")) + " ";
	//  }

	// Display a summary of options on the status bar
	currentOptions +=  (m_options->saveWidgets ? tr("SaveWidgets") : tr("DontSaveWidgets")) + " ";
	QString playOptions = " (Audio:" + m_options->rtAudioModule + " ";
	playOptions += "MIDI:" +  m_options->rtMidiModule + ")";
	playOptions += " (" + (m_options->rtUseOptions? tr("UseCsoundQtOptions"): tr("DiscardCsoundQtOptions"));
	playOptions += " " + (m_options->rtOverrideOptions? tr("OverrideCsOptions"): tr("")) + ") ";
	playOptions += currentOptions;
	QString renderOptions = " (" + (m_options->fileUseOptions? tr("UseCsoundQtOptions"): tr("DiscardCsoundQtOptions")) + " ";
	renderOptions +=  "" + (m_options->fileOverrideOptions? tr("OverrideCsOptions"): tr("")) + ") ";
	renderOptions += currentOptions;
	runAct->setStatusTip(tr("Play") + playOptions);
	renderAct->setStatusTip(tr("Render to file") + renderOptions);
	setMidiInterface(m_options->midiInterface);
	fillFavoriteMenu();
	fillScriptsMenu();
#ifdef QCS_PYTHONQT
	DocumentView *pad =  static_cast<DocumentView *>(
				m_scratchPad->widget());
	pad->setFont(QFont(m_options->font,
					   (int) m_options->fontPointSize));
#endif
	if (m_options->logFile != logFile.fileName()) {
		openLogFile();
	}
	if (csoundGetVersion() < 5140) {
		m_options->newParser = -1; // Don't use new parser flags
	}
	setupEnvironment();
}

void CsoundQt::setCurrentOptionsForPage(DocumentPage *p)
{
	p->setColorVariables(m_options->colorVariables);
	p->setTabStopWidth(m_options->tabWidth);
	p->setTabIndents(m_options->tabIndents);
	p->setLineWrapMode(m_options->wrapLines ? QTextEdit::WidgetWidth : QTextEdit::NoWrap);
	p->setAutoComplete(m_options->autoComplete);
	p->setAutoParameterMode(m_options->autoParameterMode);
	p->setWidgetEnabled(m_options->enableWidgets);
	p->showWidgetTooltips(m_options->showTooltips);
	p->setKeyRepeatMode(m_options->keyRepeat);
	p->setOpenProperties(m_options->openProperties);
	p->setFontOffset(m_options->fontOffset);
	p->setFontScaling(m_options->fontScaling);
	p->setDebugLiveEvents(m_options->debugLiveEvents);
	p->setTextFont(QFont(m_options->font,
						 (int) m_options->fontPointSize));
	p->setLineEnding(m_options->lineEnding);
	p->setConsoleFont(QFont(m_options->consoleFont,
							(int) m_options->consoleFontPointSize));
	p->setConsoleColors(m_options->consoleFontColor,
						m_options->consoleBgColor);
	p->setScriptDirectory(m_options->pythonDir);
	p->setPythonExecutable(m_options->pythonExecutable);
	p->useOldFormat(m_options->oldFormat);
	p->setConsoleBufferSize(m_options->consoleBufferSize);
	p->showLineNumbers(m_options->showLineNumberArea);

	int flags = m_options->noBuffer ? QCS_NO_COPY_BUFFER : 0;
	flags |= m_options->noPython ? QCS_NO_PYTHON_CALLBACK : 0;
	flags |= m_options->noMessages ? QCS_NO_CONSOLE_MESSAGES : 0;
	flags |= m_options->noEvents ? QCS_NO_RT_EVENTS : 0;
	p->setFlags(flags);
}

void CsoundQt::runUtility(QString flags)
{
	qDebug("CsoundQt::runUtility");
	if (m_options->useAPI) {
#ifdef MACOSX_PRE_SNOW
		//Remember menu bar to set it after FLTK grabs it
		menuBarHandle = GetMenuBar();
#endif
		//    m_console->reset();
		static char *argv[33];
		QString name = "";
		QString fileFlags = flags.mid(flags.indexOf("\""));
		flags.remove(fileFlags);
		QStringList indFlags= flags.split(" ",QString::SkipEmptyParts);
		QStringList files = fileFlags.split("\"", QString::SkipEmptyParts);
		if (indFlags.size() < 2) {
			qDebug("CsoundQt::runUtility: Error: empty flags");
			return;
		}
		if (indFlags[0] == "-U") {
			indFlags.removeAt(0);
			name = indFlags[0];
			indFlags.removeAt(0);
		}
		else {
			qDebug("CsoundQt::runUtility: Error: unexpected flag!");
			return;
		}
		int index = 0;
		foreach (QString flag, indFlags) {
			argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
			strcpy(argv[index], flag.toLocal8Bit());
			index++;
		}
		argv[index] = (char *) calloc(files[0].size()+1, sizeof(char));
		strcpy(argv[index++], files[0].toLocal8Bit());
		argv[index] = (char *) calloc(files[2].size()+1, sizeof(char));
		strcpy(argv[index++],files[2].toLocal8Bit());
		int argc = index;
		CSOUND *csoundU;
		csoundU=csoundCreate(0);
		csoundSetHostData(csoundU, (void *) m_console);
		csoundSetMessageCallback(csoundU, &CsoundQt::utilitiesMessageCallback);
		// Utilities always run in the same thread as CsoundQt
		csoundRunUtility(csoundU, name.toLocal8Bit(), argc, argv);
		csoundDestroy(csoundU);
		for (int i = 0; i < argc; i++) {
			free(argv[i]);
		}
#ifdef MACOSX_PRE_SNOW
		// Put menu bar back
		SetMenuBar(menuBarHandle);
#endif
	}
	else {
		QString script;
#ifdef Q_OS_WIN32
		script = "";
#ifdef USE_DOUBLE
		if (m_options->opcodedir64Active)
			script += "set OPCODEDIR64=" + m_options->opcodedir64 + "\n";
		if (m_options->opcode6dir64Active)
			script += "set OPCODE6DIR64=" + m_options->opcode6dir64 + "\n";
#else
		if (m_options->opcodedirActive)
			script += "set OPCODEDIR=" + m_options->opcodedir + "\n";
#endif
		// Only OPCODEDIR left here as it must be present before csound initializes

		script += "cd " + QFileInfo(documentPages[curPage]->getFileName()).absolutePath() + "\n";
		script += "csound " + flags + "\n";
#else
		script = "#!/bin/sh\n";
#ifdef USE_DOUBLE
		if (m_options->opcodedir64Active)
			script += "set OPCODEDIR64=" + m_options->opcodedir64 + "\n";
		if (m_options->opcode6dir64Active)
			script += "set OPCODE6DIR64=" + m_options->opcode6dir64 + "\n";
#else
		if (m_options->opcodedirActive)
			script += "export OPCODEDIR=" + m_options->opcodedir + "\n";
#endif
		// Only OPCODEDIR left here as it must be present before csound initializes

		script += "cd " + QFileInfo(documentPages[curPage]->getFileName()).absolutePath() + "\n";
#ifdef Q_OS_MAC
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
#ifdef Q_OS_LINUX
		options = "-e " + SCRIPT_NAME;
#endif
#ifdef Q_OS_SOLARIS
		options = "-e " + SCRIPT_NAME;
#endif
#ifdef Q_OS_MAC
		options = SCRIPT_NAME;
#endif
#ifdef Q_OS_WIN32
		options = SCRIPT_NAME;
#endif
		execute(m_options->terminal, options);
	}
}

void CsoundQt::displayLineNumber(int lineNumber)
{
	lineNumberLabel->setText(tr("Line %1").arg(lineNumber));
}

void CsoundQt::updateInspector()
{
	if (m_closing) {
		return;  // And don't call this again from the timer
	}
	Q_ASSERT(documentPages.size() > curPage);
	if (!m_inspectorNeedsUpdate) {
		QTimer::singleShot(2000, this, SLOT(updateInspector()));
		return; // Retrigger timer, but do no update
	}
	//  qDebug() << "CsoundQt::updateInspector";
	if (!documentPages[curPage]->getFileName().endsWith(".py")) {
		m_inspector->parseText(documentPages[curPage]->getBasicText());
	}
	else {
		m_inspector->parsePythonText(documentPages[curPage]->getBasicText());
	}
	m_inspectorNeedsUpdate = false;
	QTimer::singleShot(2000, this, SLOT(updateInspector()));
}

void CsoundQt::markInspectorUpdate()
{
	//  qDebug() << "CsoundQt::markInspectorUpdate()";
	m_inspectorNeedsUpdate = true;
}

void CsoundQt::setDefaultKeyboardShortcuts()
{
	//   m_keyActions.append(createCodeGraphAct);
	newAct->setShortcut(tr("Ctrl+N"));
	openAct->setShortcut(tr("Ctrl+O"));
	reloadAct->setShortcut(tr(""));
	saveAct->setShortcut(tr("Ctrl+S"));
	saveAsAct->setShortcut(tr("Shift+Ctrl+S"));
	createAppAct->setShortcut(tr(""));
	closeTabAct->setShortcut(tr("Ctrl+W"));

	printAct->setShortcut(tr("Ctrl+P"));
	exitAct->setShortcut(tr("Ctrl+Q"));

	undoAct->setShortcut(tr("Ctrl+Z"));
	redoAct->setShortcut(tr("Shift+Ctrl+Z"));

	cutAct->setShortcut(tr("Ctrl+X"));
	copyAct->setShortcut(tr("Ctrl+C"));
	pasteAct->setShortcut(tr("Ctrl+V"));
	duplicateAct->setShortcut(tr("Ctrl+D"));
	joinAct->setShortcut(tr(""));
	inToGetAct->setShortcut(tr(""));
	getToInAct->setShortcut(tr(""));
	csladspaAct->setShortcut(tr(""));
	findAct->setShortcut(tr("Ctrl+F"));
	findAgainAct->setShortcut(tr("Ctrl+G"));
	configureAct->setShortcut(tr(""));
	editAct->setShortcut(tr("CTRL+E"));
	runAct->setShortcut(tr("CTRL+R"));
	runTermAct->setShortcut(tr(""));
	stopAct->setShortcut(tr("Alt+S"));
	pauseAct->setShortcut(tr(""));
	stopAllAct->setShortcut(tr("Ctrl+."));
	recAct->setShortcut(tr("Ctrl+Space"));
	renderAct->setShortcut(tr("Alt+F"));
	externalPlayerAct->setShortcut(tr(""));
	externalEditorAct->setShortcut(tr(""));
	focusEditorAct->setShortcut(tr("Alt+0"));
	showWidgetsAct->setShortcut(tr("Alt+1"));
	showHelpAct->setShortcut(tr("Alt+2"));
	showGenAct->setShortcut(tr(""));
	showOverviewAct->setShortcut(tr(""));
	showConsoleAct->setShortcut(tr("Alt+3"));
#ifdef Q_OS_MAC
	viewFullScreenAct->setShortcut(tr("Ctrl+Alt+F"));
#else
	viewFullScreenAct->setShortcut(tr("F11"));
#endif
	splitViewAct->setShortcut(tr("Ctrl+Shift+A"));
	createCodeGraphAct->setShortcut(tr("Alt+4"));
	showInspectorAct->setShortcut(tr("Alt+5"));
	showLiveEventsAct->setShortcut(tr("Alt+6"));
	showUtilitiesAct->setShortcut(tr("Alt+9"));
	setHelpEntryAct->setShortcut(tr("Shift+F1"));
	browseBackAct->setShortcut(QKeySequence(Qt::CTRL + Qt::Key_Left));
	browseForwardAct->setShortcut(QKeySequence(Qt::CTRL + Qt::Key_Right));
	externalBrowserAct->setShortcut(tr("Shift+Alt+F1"));
	openQuickRefAct->setShortcut(tr(""));
	commentAct->setShortcut(tr("Ctrl+/"));
	//  uncommentAct->setShortcut(tr("Shift+Ctrl+/"));
	indentAct->setShortcut(tr("Ctrl+I"));
	unindentAct->setShortcut(tr("Shift+Ctrl+I"));
	evaluateAct->setShortcut(tr("Shift+Ctrl+E"));
	evaluateSectionAct->setShortcut(tr("Shift+Ctrl+W"));
	scratchPadCsdModeAct->setShortcut(tr("Shift+Alt+S"));
	showPythonConsoleAct->setShortcut(tr("Alt+7"));
	showScratchPadAct->setShortcut(tr("Alt+8"));
	killLineAct->setShortcut(tr("Ctrl+K"));
	killToEndAct->setShortcut(tr("Shift+Alt+K"));
	showOrcAct->setShortcut(tr("Shift+Alt+1"));
	showScoreAct->setShortcut(tr("Shift+Alt+2"));
	showOptionsAct->setShortcut(tr("Shift+Alt+3"));
	showFileBAct->setShortcut(tr("Shift+Alt+4"));
	showOtherAct->setShortcut(tr("Shift+Alt+5"));
	showOtherCsdAct->setShortcut(tr("Shift+Alt+6"));
	showWidgetEditAct->setShortcut(tr("Shift+Alt+7"));
	lineNumbersAct->setShortcut(tr("Shift+Alt+L"));
	parameterModeAct->setShortcut(tr("Shift+Alt+P"));
	showParametersAct->setShortcut(tr("Alt+P"));
}

void CsoundQt::showNoPythonQtWarning()
{
	QMessageBox::warning(this, tr("No PythonQt support"),
						 tr("This version of CsoundQt has been compiled without PythonQt support.\n"
							"Extended Python features are not available"));
	qDebug() << "CsoundQt::showNoPythonQtWarning()";
}

void CsoundQt::showOrc(bool show)
{
	documentPages[curPage]->showOrc(show);
}

void CsoundQt::showScore(bool show)
{
	documentPages[curPage]->showScore(show);
}

void CsoundQt::showOptions(bool show)
{
	documentPages[curPage]->showOptions(show);
}

void CsoundQt::showFileB(bool show)
{
	documentPages[curPage]->showFileB(show);
}

void CsoundQt::showOther(bool show)
{
	documentPages[curPage]->showOther(show);
}

void CsoundQt::showOtherCsd(bool show)
{
	documentPages[curPage]->showOtherCsd(show);
}

void CsoundQt::showWidgetEdit(bool show)
{
	documentPages[curPage]->showWidgetEdit(show);
}

void CsoundQt::toggleLineArea()
{
	documentPages[curPage]->toggleLineArea();
}

void CsoundQt::toggleParameterMode()
{
	documentPages[curPage]->toggleParameterMode();
}

void CsoundQt::showParametersInEditor()
{
	documentPages[curPage]->showParametersInEditor();
}

void CsoundQt::createActions()
{
	// Actions that are not connected here depend on the active document, so they are
	// connected with connectActions() and are changed when the document changes.
	QString theme = m_options->theme;
	QString prefix = ":/themes/" + theme + "/";
	newAct = new QAction(QIcon(prefix + "gtk-new.png"), tr("&New"), this);
	newAct->setStatusTip(tr("Create a new file"));
	newAct->setIconText(tr("New"));
	newAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(newAct, SIGNAL(triggered()), this, SLOT(newFile()));

	openAct = new QAction(QIcon(prefix + "gnome-folder.png"), tr("&Open..."), this);
	openAct->setStatusTip(tr("Open an existing file"));
	openAct->setIconText(tr("Open"));
	openAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(openAct, SIGNAL(triggered()), this, SLOT(open()));

	reloadAct = new QAction(QIcon(prefix + "gtk-reload.png"), tr("Reload"), this);
	reloadAct->setStatusTip(tr("Reload file from disk, discarding changes"));
	//   reloadAct->setIconText(tr("Reload"));
	reloadAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(reloadAct, SIGNAL(triggered()), this, SLOT(reload()));

	saveAct = new QAction(QIcon(prefix + "gnome-dev-floppy.png"), tr("&Save"), this);
	saveAct->setStatusTip(tr("Save the document to disk"));
	saveAct->setIconText(tr("Save"));
	saveAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(saveAct, SIGNAL(triggered()), this, SLOT(save()));

	saveAsAct = new QAction(tr("Save &As..."), this);
	saveAsAct->setStatusTip(tr("Save the document under a new name"));
	saveAsAct->setIconText(tr("Save as"));
	saveAsAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(saveAsAct, SIGNAL(triggered()), this, SLOT(saveAs()));

	createAppAct = new QAction(tr("Create App..."), this);
	createAppAct->setStatusTip(tr("Create Standalone application"));
	createAppAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(createAppAct, SIGNAL(triggered()), this, SLOT(createApp()));

	saveNoWidgetsAct = new QAction(tr("Export without widgets"), this);
	saveNoWidgetsAct->setStatusTip(tr("Save to new file without including widget sections"));
	//   saveNoWidgetsAct->setIconText(tr("Save as"));
	saveNoWidgetsAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(saveNoWidgetsAct, SIGNAL(triggered()), this, SLOT(saveNoWidgets()));

	closeTabAct = new QAction(tr("Close current tab"), this);
	closeTabAct->setStatusTip(tr("Close current tab"));
	//   closeTabAct->setIconText(tr("Close"));
	closeTabAct->setIcon(QIcon(prefix + "gtk-close.png"));
	closeTabAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(closeTabAct, SIGNAL(triggered()), this, SLOT(closeTab()));

	printAct = new QAction(tr("Print"), this);
	printAct->setStatusTip(tr("Print current document"));
	//   printAct->setIconText(tr("Print"));
	//   closeTabAct->setIcon(QIcon(prefix + "gtk-close.png"));
	printAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(printAct, SIGNAL(triggered()), this, SLOT(print()));

	//  for (int i = 0; i < QCS_MAX_RECENT_FILES; i++) {
	//    QAction *newAction = new QAction(this);
	//    openRecentAct.append(newAction);
	//    connect(newAction, SIGNAL(triggered()), this, SLOT(openFromAction()));
	//  }

	infoAct = new QAction(tr("File Information"), this);
	infoAct->setStatusTip(tr("Show information for the current file"));
	//   exitAct->setIconText(tr("Exit"));
	infoAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(infoAct, SIGNAL(triggered()), this, SLOT(info()));

	exitAct = new QAction(tr("E&xit"), this);
	exitAct->setStatusTip(tr("Exit the application"));
	//   exitAct->setIconText(tr("Exit"));
	exitAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

	createCodeGraphAct = new QAction(tr("View Code &Graph"), this);
	createCodeGraphAct->setStatusTip(tr("View Code Graph"));
	//   createCodeGraphAct->setIconText("Exit");
	createCodeGraphAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(createCodeGraphAct, SIGNAL(triggered()), this, SLOT(createCodeGraph()));

	undoAct = new QAction(QIcon(prefix + "gtk-undo.png"), tr("Undo"), this);
	undoAct->setStatusTip(tr("Undo last action"));
	undoAct->setIconText(tr("Undo"));
	undoAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(undoAct, SIGNAL(triggered()), this, SLOT(undo()));

	redoAct = new QAction(QIcon(prefix + "gtk-redo.png"), tr("Redo"), this);
	redoAct->setStatusTip(tr("Redo last action"));
	redoAct->setIconText(tr("Redo"));
	redoAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(redoAct, SIGNAL(triggered()), this, SLOT(redo()));

	cutAct = new QAction(QIcon(prefix + "gtk-cut.png"), tr("Cu&t"), this);
	cutAct->setStatusTip(tr("Cut the current selection's contents to the "
							"clipboard"));
	cutAct->setIconText(tr("Cut"));
	cutAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(cutAct, SIGNAL(triggered()), this, SLOT(cut()));

	copyAct = new QAction(QIcon(prefix + "gtk-copy.png"), tr("&Copy"), this);
	copyAct->setStatusTip(tr("Copy the current selection's contents to the "
							 "clipboard"));
	copyAct->setIconText(tr("Copy"));
	copyAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(copyAct, SIGNAL(triggered()), this, SLOT(copy()));

	pasteAct = new QAction(QIcon(prefix + "gtk-paste.png"), tr("&Paste"), this);
	pasteAct->setStatusTip(tr("Paste the clipboard's contents into the current "
							  "selection"));
	pasteAct->setIconText(tr("Paste"));
	pasteAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(pasteAct, SIGNAL(triggered()), this, SLOT(paste()));

	joinAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("&Join orc/sco"), this);
	joinAct->setStatusTip(tr("Join orc/sco files in a single csd file"));
	//   joinAct->setIconText(tr("Join"));
	joinAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(joinAct, SIGNAL(triggered()), this, SLOT(join()));

	evaluateAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("Evaluate selection"), this);
	evaluateAct->setStatusTip(tr("Evaluate selection in Python Console"));
	evaluateAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(evaluateAct, SIGNAL(triggered()), this, SLOT(evaluate()));

	evaluateSectionAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("Evaluate section"), this);
	evaluateSectionAct->setStatusTip(tr("Evaluate current section in Python Console"));
	evaluateSectionAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(evaluateSectionAct, SIGNAL(triggered()), this, SLOT(evaluateSection()));

	scratchPadCsdModeAct = new QAction(tr("Scratch Pad in Csound Mode"), this);
	scratchPadCsdModeAct->setStatusTip(tr("Toggle the mode for the scratch pad between python and csound"));
	scratchPadCsdModeAct->setShortcutContext(Qt::ApplicationShortcut);
	scratchPadCsdModeAct->setCheckable(true);
	connect(scratchPadCsdModeAct, SIGNAL(toggled(bool)), this, SLOT(setScratchPadMode(bool)));

	inToGetAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("Invalue->Chnget"), this);
	inToGetAct->setStatusTip(tr("Convert invalue/outvalue to chnget/chnset"));
	inToGetAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(inToGetAct, SIGNAL(triggered()), this, SLOT(inToGet()));

	getToInAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("Chnget->Invalue"), this);
	getToInAct->setStatusTip(tr("Convert chnget/chnset to invalue/outvalue"));
	getToInAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(getToInAct, SIGNAL(triggered()), this, SLOT(getToIn()));

	csladspaAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("Insert/Update CsLADSPA text"), this);
	csladspaAct->setStatusTip(tr("Insert/Update CsLADSPA section to csd file"));
	csladspaAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(csladspaAct, SIGNAL(triggered()), this, SLOT(updateCsladspaText()));

	cabbageAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("Insert/Update Cabbage text"), this);
	cabbageAct->setStatusTip(tr("Insert/Update Cabbage section to csd file"));
	cabbageAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(cabbageAct, SIGNAL(triggered()), this, SLOT(updateCabbageText()));

	findAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("&Find and Replace"), this);
	findAct->setStatusTip(tr("Find and replace strings in file"));
	//   findAct->setIconText(tr("Find"));
	findAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(findAct, SIGNAL(triggered()), this, SLOT(findReplace()));

	findAgainAct = new QAction(/*QIcon(prefix + "gtk-paste.png"),*/ tr("Find a&gain"), this);
	findAgainAct->setStatusTip(tr("Find next appearance of string"));
	//   findAct->setIconText(tr("Find"));
	findAgainAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(findAgainAct, SIGNAL(triggered()), this, SLOT(findString()));

	configureAct = new QAction(QIcon(prefix + "control-center2.png"), tr("Configuration"), this);
	configureAct->setStatusTip(tr("Open configuration dialog"));
	configureAct->setIconText(tr("Configure"));
	configureAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(configureAct, SIGNAL(triggered()), this, SLOT(configure()));

	editAct = new QAction(/*QIcon(prefix + "gtk-media-play-ltr.png"),*/ tr("Widget Edit Mode"), this);
	editAct->setStatusTip(tr("Activate Edit Mode for Widget Panel"));
	//   editAct->setIconText("Play");
	editAct->setCheckable(true);
	editAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(editAct, SIGNAL(triggered(bool)), this, SLOT(setWidgetEditMode(bool)));

	runAct = new QAction(QIcon(prefix + "gtk-media-play-ltr.png"), tr("Run Csound"), this);
	runAct->setStatusTip(tr("Run current file"));
	runAct->setIconText(tr("Run"));
	runAct->setCheckable(true);
	runAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(runAct, SIGNAL(triggered()), this, SLOT(play()));

	runTermAct = new QAction(QIcon(prefix + "gtk-media-play-ltr2.png"), tr("Run in Terminal"), this);
	runTermAct->setStatusTip(tr("Run in external shell"));
	runTermAct->setIconText(tr("Run in Term"));
	runTermAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(runTermAct, SIGNAL(triggered()), this, SLOT(runInTerm()));

	stopAct = new QAction(QIcon(prefix + "gtk-media-stop.png"), tr("Stop"), this);
	stopAct->setStatusTip(tr("Stop"));
	stopAct->setIconText(tr("Stop"));
	stopAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(stopAct, SIGNAL(triggered()), this, SLOT(stop()));

	pauseAct = new QAction(QIcon(prefix + "gtk-media-pause.png"), tr("Pause"), this);
	pauseAct->setStatusTip(tr("Pause"));
	pauseAct->setIconText(tr("Pause"));
	pauseAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(pauseAct, SIGNAL(triggered()), this, SLOT(pause()));

	stopAllAct = new QAction(QIcon(prefix + "gtk-media-stop.png"), tr("Stop All"), this);
	stopAllAct->setStatusTip(tr("Stop all running documents"));
	stopAllAct->setIconText(tr("Stop All"));
	stopAllAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(stopAllAct, SIGNAL(triggered()), this, SLOT(stopAll()));

	recAct = new QAction(QIcon(prefix + "gtk-media-record.png"), tr("Record"), this);
	recAct->setStatusTip(tr("Record"));
	recAct->setIconText(tr("Record"));
	recAct->setCheckable(true);
	recAct->setShortcutContext(Qt::ApplicationShortcut);
	recAct->setChecked(false);
	connect(recAct, SIGNAL(toggled(bool)), this, SLOT(record(bool)));

	renderAct = new QAction(QIcon(prefix + "render.png"), tr("Render to file"), this);
	renderAct->setStatusTip(tr("Render to file"));
	renderAct->setIconText(tr("Render"));
	renderAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(renderAct, SIGNAL(triggered()), this, SLOT(render()));

	externalPlayerAct = new QAction(QIcon(prefix + "playfile.png"), tr("Play Audiofile"), this);
	externalPlayerAct->setStatusTip(tr("Play rendered audiofile in External Editor"));
	externalPlayerAct->setIconText(tr("Ext. Player"));
	externalPlayerAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(externalPlayerAct, SIGNAL(triggered()), this, SLOT(openExternalPlayer()));

	externalEditorAct = new QAction(QIcon(prefix + "editfile.png"), tr("Edit Audiofile"), this);
	externalEditorAct->setStatusTip(tr("Edit rendered audiofile in External Editor"));
	externalEditorAct->setIconText(tr("Ext. Editor"));
	externalEditorAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(externalEditorAct, SIGNAL(triggered()), this, SLOT(openExternalEditor()));

	showWidgetsAct = new QAction(QIcon(prefix + "gnome-mime-application-x-diagram.png"), tr("Widgets"), this);
	showWidgetsAct->setCheckable(true);
	//showWidgetsAct->setChecked(true);
	showWidgetsAct->setStatusTip(tr("Show Realtime Widgets"));
	showWidgetsAct->setIconText(tr("Widgets"));
	showWidgetsAct->setShortcutContext(Qt::ApplicationShortcut);

	showInspectorAct = new QAction(QIcon(prefix + "edit-find.png"), tr("Inspector"), this);
	showInspectorAct->setCheckable(true);
	showInspectorAct->setStatusTip(tr("Show Inspector"));
	showInspectorAct->setIconText(tr("Inspector"));
	showInspectorAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showInspectorAct, SIGNAL(triggered(bool)), m_inspector, SLOT(setVisible(bool)));
	connect(m_inspector, SIGNAL(Close(bool)), showInspectorAct, SLOT(setChecked(bool)));

	focusEditorAct = new QAction(tr("Focus Text Editor", "Give keyboard focus to the text editor"), this);
	focusEditorAct->setStatusTip(tr("Give keyboard focus to the text editor"));
	focusEditorAct->setIconText(tr("Editor"));
	focusEditorAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(focusEditorAct, SIGNAL(triggered()), this, SLOT(setEditorFocus()));

	showHelpAct = new QAction(QIcon(prefix + "gtk-info.png"), tr("Help Panel"), this);
	showHelpAct->setCheckable(true);
	showHelpAct->setChecked(true);
	showHelpAct->setStatusTip(tr("Show the Csound Manual Panel"));
	showHelpAct->setIconText(tr("Manual"));
	showHelpAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showHelpAct, SIGNAL(toggled(bool)), helpPanel, SLOT(setVisible(bool)));
	connect(helpPanel, SIGNAL(Close(bool)), showHelpAct, SLOT(setChecked(bool)));

	showLiveEventsAct = new QAction(QIcon(prefix + "note.png"), tr("Live Events"), this);
	showLiveEventsAct->setCheckable(true);
	//  showLiveEventsAct->setChecked(true);  // Unnecessary because it is set by options
	showLiveEventsAct->setStatusTip(tr("Show Live Events Panels"));
	showLiveEventsAct->setIconText(tr("Live Events"));
	showLiveEventsAct->setShortcutContext(Qt::ApplicationShortcut);

	showPythonConsoleAct = new QAction(QIcon(prefix + "pyroom.png"), tr("Python Console"), this);
	showPythonConsoleAct->setCheckable(true);
	//  showPythonConsoleAct->setChecked(true);  // Unnecessary because it is set by options
	showPythonConsoleAct->setStatusTip(tr("Show Python Console"));
	showPythonConsoleAct->setIconText(tr("Python"));
	showPythonConsoleAct->setShortcutContext(Qt::ApplicationShortcut);
#ifdef QCS_PYTHONQT
	connect(showPythonConsoleAct, SIGNAL(triggered(bool)), m_pythonConsole, SLOT(setVisible(bool)));
	connect(m_pythonConsole, SIGNAL(Close(bool)), showPythonConsoleAct, SLOT(setChecked(bool)));
#else
	connect(showPythonConsoleAct, SIGNAL(triggered()), this, SLOT(showNoPythonQtWarning()));
#endif

	showScratchPadAct = new QAction(QIcon(prefix + "scratchpad.png"), tr("ScratchPad"), this);
	showScratchPadAct->setCheckable(true);
	//  showPythonConsoleAct->setChecked(true);  // Unnecessary because it is set by options
	showScratchPadAct->setStatusTip(tr("Show Scratch Pad"));
	showScratchPadAct->setIconText(tr("ScratchPad"));
	showScratchPadAct->setShortcutContext(Qt::ApplicationShortcut);
#ifdef QCS_PYTHONQT
	connect(showScratchPadAct, SIGNAL(triggered(bool)), m_scratchPad, SLOT(setVisible(bool)));
	connect(m_scratchPad, SIGNAL(visibilityChanged(bool)), showScratchPadAct, SLOT(setChecked(bool)));
#else
	connect(showScratchPadAct, SIGNAL(triggered()), this, SLOT(showNoPythonQtWarning()));
#endif

	showManualAct = new QAction(/*QIcon(prefix + "gtk-info.png"), */tr("Csound Manual"), this);
	showManualAct->setStatusTip(tr("Show the Csound manual in the help panel"));
	showManualAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showManualAct, SIGNAL(triggered()), helpPanel, SLOT(showManual()));

	showGenAct = new QAction(/*QIcon(prefix + "gtk-info.png"), */tr("GEN Routines"), this);
	showGenAct->setStatusTip(tr("Show the GEN Routines Manual page"));
	showGenAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showGenAct, SIGNAL(triggered()), helpPanel, SLOT(showGen()));

	showOverviewAct = new QAction(/*QIcon(prefix + "gtk-info.png"), */tr("Opcode Overview"), this);
	showOverviewAct->setStatusTip(tr("Show opcode overview"));
	showOverviewAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showOverviewAct, SIGNAL(triggered()), helpPanel, SLOT(showOverview()));

	showOpcodeQuickRefAct = new QAction(/*QIcon(prefix + "gtk-info.png"), */tr("Opcode Quick Reference"), this);
	showOpcodeQuickRefAct->setStatusTip(tr("Show opcode quick reference page"));
	showOpcodeQuickRefAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showOpcodeQuickRefAct, SIGNAL(triggered()), helpPanel, SLOT(showOpcodeQuickRef()));

	showConsoleAct = new QAction(QIcon(prefix + "gksu-root-terminal.png"), tr("Output Console"), this);
	showConsoleAct->setCheckable(true);
	showConsoleAct->setChecked(true);
	showConsoleAct->setStatusTip(tr("Show Csound's message console"));
	showConsoleAct->setIconText(tr("Console"));
	showConsoleAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showConsoleAct, SIGNAL(toggled(bool)), m_console, SLOT(setVisible(bool)));
	connect(m_console, SIGNAL(Close(bool)), showConsoleAct, SLOT(setChecked(bool)));

	viewFullScreenAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("View Full Screen"), this);
	viewFullScreenAct->setCheckable(true);
	viewFullScreenAct->setChecked(false);
	viewFullScreenAct->setStatusTip(tr("Have CsoundQt occupy all the available screen space"));
	viewFullScreenAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(viewFullScreenAct, SIGNAL(toggled(bool)), this, SLOT(setFullScreen(bool)));

	splitViewAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Split View"), this);
	splitViewAct->setCheckable(true);
	splitViewAct->setChecked(false);
	splitViewAct->setStatusTip(tr("Toggle between full csd and split text display"));
	splitViewAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(splitViewAct, SIGNAL(toggled(bool)), this, SLOT(splitView(bool)));

	showOrcAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Show Orchestra"), this);
	showOrcAct->setCheckable(true);
	showOrcAct->setChecked(true);
	showOrcAct->setEnabled(false);
	showOrcAct->setStatusTip(tr("Show orchestra panel in split view"));
	showOrcAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showOrcAct, SIGNAL(toggled(bool)), this, SLOT(showOrc(bool)));
	connect(splitViewAct, SIGNAL(toggled(bool)), showOrcAct, SLOT(setEnabled(bool)));

	showScoreAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Show Score"), this);
	showScoreAct->setCheckable(true);
	showScoreAct->setChecked(true);
	showScoreAct->setEnabled(false);
	showScoreAct->setStatusTip(tr("Show orchestra panel in split view"));
	showScoreAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showScoreAct, SIGNAL(toggled(bool)), this, SLOT(showScore(bool)));
	connect(splitViewAct, SIGNAL(toggled(bool)), showScoreAct, SLOT(setEnabled(bool)));

	showOptionsAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Show CsOptions"), this);
	showOptionsAct->setCheckable(true);
	showOptionsAct->setChecked(true);
	showOptionsAct->setEnabled(false);
	showOptionsAct->setStatusTip(tr("Show CsOptions section panel in split view"));
	showOptionsAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showOptionsAct, SIGNAL(toggled(bool)), this, SLOT(showOptions(bool)));
	connect(splitViewAct, SIGNAL(toggled(bool)), showOptionsAct, SLOT(setEnabled(bool)));

	showFileBAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Show Embedded files"), this);
	showFileBAct->setCheckable(true);
	showFileBAct->setChecked(false);
	showFileBAct->setEnabled(false);
	showFileBAct->setStatusTip(tr("Show Embedded files panel in split view"));
	showFileBAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showFileBAct, SIGNAL(toggled(bool)), this, SLOT(showFileB(bool)));
	connect(splitViewAct, SIGNAL(toggled(bool)), showFileBAct, SLOT(setEnabled(bool)));

	showOtherAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Show Information Text"), this);
	showOtherAct->setCheckable(true);
	showOtherAct->setChecked(false);
	showOtherAct->setEnabled(false);
	showOtherAct->setStatusTip(tr("Show information text panel in split view"));
	showOtherAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showOtherAct, SIGNAL(toggled(bool)), this, SLOT(showOther(bool)));
	connect(splitViewAct, SIGNAL(toggled(bool)), showOtherAct, SLOT(setEnabled(bool)));

	showOtherCsdAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Show Extra Tags"), this);
	showOtherCsdAct->setCheckable(true);
	showOtherCsdAct->setChecked(false);
	showOtherCsdAct->setEnabled(false);
	showOtherCsdAct->setStatusTip(tr("Show extra tags panel in split view"));
	showOtherCsdAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showOtherCsdAct, SIGNAL(toggled(bool)), this, SLOT(showOtherCsd(bool)));
	connect(splitViewAct, SIGNAL(toggled(bool)), showOtherCsdAct, SLOT(setEnabled(bool)));

	showWidgetEditAct = new QAction(/*QIcon(prefix + "gksu-root-terminal.png"),*/ tr("Show Widgets Text"), this);
	showWidgetEditAct->setCheckable(true);
	showWidgetEditAct->setChecked(false);
	showWidgetEditAct->setEnabled(false);
	showWidgetEditAct->setStatusTip(tr("Show Widgets text panel in split view"));
	showWidgetEditAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showWidgetEditAct, SIGNAL(toggled(bool)), this, SLOT(showWidgetEdit(bool)));
	connect(splitViewAct, SIGNAL(toggled(bool)), showWidgetEditAct, SLOT(setEnabled(bool)));

	setHelpEntryAct = new QAction(QIcon(prefix + "gtk-info.png"), tr("Show Opcode Entry"), this);
	setHelpEntryAct->setStatusTip(tr("Show Opcode Entry in help panel"));
	setHelpEntryAct->setIconText(tr("Manual for opcode"));
	setHelpEntryAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(setHelpEntryAct, SIGNAL(triggered()), this, SLOT(setHelpEntry()));

	browseBackAct = new QAction(tr("Help Back"), this);
	browseBackAct->setStatusTip(tr("Go back in help page"));
	browseBackAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(browseBackAct, SIGNAL(triggered()), helpPanel, SLOT(browseBack()));

	browseForwardAct = new QAction(tr("Help Forward"), this);
	browseForwardAct->setStatusTip(tr("Go forward in help page"));
	browseForwardAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(browseForwardAct, SIGNAL(triggered()), helpPanel, SLOT(browseForward()));

	externalBrowserAct = new QAction(/*QIcon(prefix + "gtk-info.png"), */ tr("Show Opcode Entry in External Browser"), this);
	externalBrowserAct->setStatusTip(tr("Show Opcode Entry in external browser"));
	externalBrowserAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(externalBrowserAct, SIGNAL(triggered()), this, SLOT(openExternalBrowser()));

	openQuickRefAct = new QAction(/*QIcon(prefix + "gtk-info.png"), */ tr("Open Quick Reference Guide"), this);
	openQuickRefAct->setStatusTip(tr("Open Quick Reference Guide in PDF viewer"));
	openQuickRefAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(openQuickRefAct, SIGNAL(triggered()), this, SLOT(openQuickRef()));

	showUtilitiesAct = new QAction(QIcon(prefix + "gnome-devel.png"), tr("Utilities"), this);
	showUtilitiesAct->setCheckable(true);
	showUtilitiesAct->setChecked(false);
	showUtilitiesAct->setStatusTip(tr("Show the Csound Utilities dialog"));
	showUtilitiesAct->setIconText(tr("Utilities"));
	showUtilitiesAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(showUtilitiesAct, SIGNAL(triggered(bool)), this, SLOT(showUtilities(bool)));

	setShortcutsAct = new QAction(tr("Set Keyboard Shortcuts"), this);
	setShortcutsAct->setStatusTip(tr("Set Keyboard Shortcuts"));
	setShortcutsAct->setIconText(tr("Set Shortcuts"));
	setShortcutsAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(setShortcutsAct, SIGNAL(triggered()), this, SLOT(openShortcutDialog()));

	commentAct = new QAction(tr("Comment/Uncomment"), this);
	commentAct->setStatusTip(tr("Comment/Uncomment selection"));
	commentAct->setShortcutContext(Qt::ApplicationShortcut);
	//  commentAct->setIconText(tr("Comment"));
	//  connect(commentAct, SIGNAL(triggered()), this, SLOT(controlD()));

	//  uncommentAct = new QAction(tr("Uncomment"), this);
	//  uncommentAct->setStatusTip(tr("Uncomment selection"));
	//  uncommentAct->setShortcutContext(Qt::ApplicationShortcut);
	//   uncommentAct->setIconText(tr("Uncomment"));
	//   connect(uncommentAct, SIGNAL(triggered()), this, SLOT(uncomment()));

	indentAct = new QAction(tr("Indent"), this);
	indentAct->setStatusTip(tr("Indent selection"));
	indentAct->setShortcutContext(Qt::ApplicationShortcut);
	//   indentAct->setIconText(tr("Indent"));
	//   connect(indentAct, SIGNAL(triggered()), this, SLOT(indent()));

	unindentAct = new QAction(tr("Unindent"), this);
	unindentAct->setStatusTip(tr("Unindent selection"));
	unindentAct->setShortcutContext(Qt::ApplicationShortcut);
	//   unindentAct->setIconText(tr("Unindent"));
	//   connect(unindentAct, SIGNAL(triggered()), this, SLOT(unindent()));

	killLineAct = new QAction(tr("Kill Line"), this);
	killLineAct->setStatusTip(tr("Completely delete current line"));
	killLineAct->setShortcutContext(Qt::ApplicationShortcut);

	killToEndAct = new QAction(tr("Kill to End of Line"), this);
	killToEndAct->setStatusTip(tr("Delete everything from cursor to the end of the current line"));
	killToEndAct->setShortcutContext(Qt::ApplicationShortcut);

	aboutAct = new QAction(tr("&About CsoundQt"), this);
	aboutAct->setStatusTip(tr("Show the application's About box"));
	//   aboutAct->setIconText(tr("About"));
	aboutAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));

	donateAct = new QAction(tr("Donate to CsoundQt"), this);
	donateAct->setStatusTip(tr("Donate to support development of CsoundQt"));
	//   aboutAct->setIconText(tr("About"));
	donateAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(donateAct, SIGNAL(triggered()), this, SLOT(donate()));

	//  aboutQtAct = new QAction(tr("About &Qt"), this);
	//  aboutQtAct->setStatusTip(tr("Show the Qt library's About box"));
	////   aboutQtAct->setIconText(tr("About Qt"));
	//  aboutQtAct->setShortcutContext(Qt::ApplicationShortcut);
	//  connect(aboutQtAct, SIGNAL(triggered()), qApp, SLOT(aboutQt()));

	resetPreferencesAct = new QAction(tr("Reset Preferences"), this);
	resetPreferencesAct->setStatusTip(tr("Reset CsoundQt's preferences to their original default state"));
	resetPreferencesAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(resetPreferencesAct, SIGNAL(triggered()), this, SLOT(resetPreferences()));

	reportBugAct = new QAction(tr("Report a Bug"), this);
	reportBugAct->setStatusTip(tr("Report a bug in CsoundQt's Bug Tracker"));
	reportBugAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(reportBugAct, SIGNAL(triggered()), this, SLOT(reportBug()));

	requestFeatureAct = new QAction(tr("Request a Feature"), this);
	requestFeatureAct->setStatusTip(tr("Request a feature in CsoundQt's Feature Tracker"));
	requestFeatureAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(requestFeatureAct, SIGNAL(triggered()), this, SLOT(requestFeature()));

	chatAct = new QAction(tr("Csound IRC Chat"), this);
	chatAct->setStatusTip(tr("Open the IRC chat channel #csound in your browser"));
	chatAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(chatAct, SIGNAL(triggered()), this, SLOT(chat()));

	duplicateAct = new QAction(tr("Duplicate Widgets"), this);
	duplicateAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(duplicateAct, SIGNAL(triggered()), this, SLOT(duplicate()));

	lineNumbersAct = new QAction(tr("Show/hide line number area"),this);
	lineNumbersAct->setShortcutContext(Qt::ApplicationShortcut);
	connect(lineNumbersAct,SIGNAL(triggered()), this, SLOT(toggleLineArea()));

	parameterModeAct = new QAction(tr("Toggle parameter mode"),this);
	connect(parameterModeAct,SIGNAL(triggered()), this, SLOT(toggleParameterMode()));

	showParametersAct = new QAction(tr("Show available parameters"),this);
	connect(showParametersAct,SIGNAL(triggered()), this, SLOT(showParametersInEditor()));

	setKeyboardShortcutsList();
}

void CsoundQt::setKeyboardShortcutsList()
{
	m_keyActions.append(newAct);
	m_keyActions.append(openAct);
	m_keyActions.append(reloadAct);
	m_keyActions.append(saveAct);
	m_keyActions.append(saveAsAct);
	m_keyActions.append(createAppAct);
	m_keyActions.append(closeTabAct);
	m_keyActions.append(printAct);
	m_keyActions.append(exitAct);
	m_keyActions.append(createCodeGraphAct);
	m_keyActions.append(undoAct);
	m_keyActions.append(redoAct);
	m_keyActions.append(cutAct);
	m_keyActions.append(copyAct);
	m_keyActions.append(pasteAct);
	m_keyActions.append(duplicateAct);
	m_keyActions.append(joinAct);
	m_keyActions.append(inToGetAct);
	m_keyActions.append(getToInAct);
	m_keyActions.append(csladspaAct);
	m_keyActions.append(findAct);
	m_keyActions.append(configureAct);
	m_keyActions.append(editAct);
	m_keyActions.append(runAct);
	m_keyActions.append(runTermAct);
	m_keyActions.append(stopAct);
	m_keyActions.append(pauseAct);
	m_keyActions.append(stopAllAct);
	m_keyActions.append(recAct);
	m_keyActions.append(renderAct);
	m_keyActions.append(commentAct);
	m_keyActions.append(indentAct);
	m_keyActions.append(unindentAct);
	m_keyActions.append(externalPlayerAct);
	m_keyActions.append(externalEditorAct);
	m_keyActions.append(focusEditorAct);
	m_keyActions.append(showWidgetsAct);
	m_keyActions.append(showHelpAct);
	m_keyActions.append(showGenAct);
	m_keyActions.append(showOverviewAct);
	m_keyActions.append(showConsoleAct);
	m_keyActions.append(showInspectorAct);
	m_keyActions.append(showLiveEventsAct);
	m_keyActions.append(showPythonConsoleAct);
	m_keyActions.append(showScratchPadAct);
	m_keyActions.append(showUtilitiesAct);
	m_keyActions.append(setHelpEntryAct);
	m_keyActions.append(browseBackAct);
	m_keyActions.append(browseForwardAct);
	m_keyActions.append(externalBrowserAct);
	m_keyActions.append(openQuickRefAct);
	m_keyActions.append(showOpcodeQuickRefAct);
	m_keyActions.append(infoAct);
	m_keyActions.append(viewFullScreenAct);
	m_keyActions.append(splitViewAct);
	m_keyActions.append(killLineAct);
	m_keyActions.append(killToEndAct);
	m_keyActions.append(evaluateAct);
	m_keyActions.append(evaluateSectionAct);
	m_keyActions.append(scratchPadCsdModeAct);
	m_keyActions.append(showOrcAct);
	m_keyActions.append(showScoreAct);
	m_keyActions.append(showOptionsAct);
	m_keyActions.append(showFileBAct);
	m_keyActions.append(showOtherAct);
	m_keyActions.append(showOtherCsdAct);
	m_keyActions.append(showWidgetEditAct);
	m_keyActions.append(lineNumbersAct);
	m_keyActions.append(parameterModeAct);
	m_keyActions.append(showParametersAct);
}

void CsoundQt::connectActions()
{
	DocumentPage * doc = documentPages[curPage];

	disconnect(commentAct, 0, 0, 0);
	//  disconnect(uncommentAct, 0, 0, 0);
	disconnect(indentAct, 0, 0, 0);
	disconnect(unindentAct, 0, 0, 0);
	disconnect(killLineAct, 0, 0, 0);
	disconnect(killToEndAct, 0, 0, 0);
	//  disconnect(findAct, 0, 0, 0);
	//  disconnect(findAgainAct, 0, 0, 0);
	connect(commentAct, SIGNAL(triggered()), doc, SLOT(comment()));
	//  connect(uncommentAct, SIGNAL(triggered()), doc, SLOT(uncomment()));
	connect(indentAct, SIGNAL(triggered()), doc, SLOT(indent()));
	connect(unindentAct, SIGNAL(triggered()), doc, SLOT(unindent()));
	connect(killLineAct, SIGNAL(triggered()), doc, SLOT(killLine()));
	connect(killToEndAct, SIGNAL(triggered()), doc, SLOT(killToEnd()));

	//  disconnect(doc, SIGNAL(copyAvailable(bool)), 0, 0);
	//  disconnect(doc, SIGNAL(copyAvailable(bool)), 0, 0);
	//TODO put these back
	//   connect(doc, SIGNAL(copyAvailable(bool)),
	//           cutAct, SLOT(setEnabled(bool)));
	//   connect(doc, SIGNAL(copyAvailable(bool)),
	//           copyAct, SLOT(setEnabled(bool)));

	//  disconnect(doc, SIGNAL(textChanged()), 0, 0);
	//  disconnect(doc, SIGNAL(cursorPositionChanged()), 0, 0);

	//  disconnect(widgetPanel, SIGNAL(widgetsChanged(QString)),0,0);
	//   connect(widgetPanel, SIGNAL(widgetsChanged(QString)),
	//           doc, SLOT(setMacWidgetsText(QString)) );

	// Connect inspector actions to document
	disconnect(m_inspector, 0, 0, 0);
	connect(m_inspector, SIGNAL(jumpToLine(int)),
			doc, SLOT(jumpToLine(int)));
	disconnect(m_inspector, 0, 0, 0);
	connect(m_inspector, SIGNAL(jumpToLine(int)),
			doc, SLOT(jumpToLine(int)));
	connect(m_inspector, SIGNAL(Close(bool)), showInspectorAct, SLOT(setChecked(bool)));

	disconnect(showLiveEventsAct, 0,0,0);
	connect(showLiveEventsAct, SIGNAL(toggled(bool)), doc, SLOT(showLiveEventPanels(bool)));
	disconnect(doc, 0,0,0);
	connect(doc, SIGNAL(liveEventsVisible(bool)), showLiveEventsAct, SLOT(setChecked(bool)));
	connect(doc, SIGNAL(stopSignal()), this, SLOT(markStopped()));
	connect(doc, SIGNAL(opcodeSyntaxSignal(QString)), this, SLOT(statusBarMessage(QString)));
	connect(doc, SIGNAL(setHelpSignal()), this, SLOT(setHelpEntry()));
	connect(doc, SIGNAL(closeExtraPanelsSignal()), this, SLOT(closeExtraPanels()));
	connect(doc, SIGNAL(currentTextUpdated()), this, SLOT(markInspectorUpdate()));

	connect(doc, SIGNAL(modified()), this, SLOT(documentWasModified()));
	connect(doc, SIGNAL(currentLineChanged(int)), this, SLOT(displayLineNumber(int)));
	//  connect(documentPages[curPage], SIGNAL(setWidgetClipboardSignal(QString)),
	//          this, SLOT(setWidgetClipboard(QString)));
	connect(doc, SIGNAL(setCurrentAudioFile(QString)),
			this, SLOT(setCurrentAudioFile(QString)));
//	connect(doc->getView(), SIGNAL(lineNumberSignal(int)),
//			this, SLOT(displayLineNumber(int)));
	connect(doc, SIGNAL(evaluatePythonSignal(QString)),
			this, SLOT(evaluatePython(QString)));



	disconnect(showWidgetsAct, 0,0,0);
	if (m_options->widgetsIndependent) {
		connect(showWidgetsAct, SIGNAL(triggered(bool)), doc, SLOT(showWidgets(bool)));
		//    connect(widgetPanel, SIGNAL(Close(bool)), showWidgetsAct, SLOT(setChecked(bool)));
	}
	else {
		connect(showWidgetsAct, SIGNAL(triggered(bool)), widgetPanel, SLOT(setVisible(bool)));
		connect(widgetPanel, SIGNAL(Close(bool)), showWidgetsAct, SLOT(setChecked(bool)));
	}
}

void CsoundQt::createMenus()
{
	fileMenu = menuBar()->addMenu(tr("File"));
	fileMenu->addAction(newAct);
	fileMenu->addAction(openAct);
	fileMenu->addAction(saveAct);
	fileMenu->addAction(saveAsAct);
	fileMenu->addAction(saveNoWidgetsAct);
	//  fileMenu->addAction(createAppAct);
	fileMenu->addAction(reloadAct);
	fileMenu->addAction(cabbageAct);
	fileMenu->addAction(closeTabAct);
	fileMenu->addAction(printAct);
	fileMenu->addAction(infoAct);
	fileMenu->addSeparator();
	fileMenu->addAction(exitAct);
	fileMenu->addSeparator();

	recentMenu = fileMenu->addMenu(tr("Recent files"));

	editMenu = menuBar()->addMenu(tr("Edit"));
	editMenu->addAction(undoAct);
	editMenu->addAction(redoAct);
	editMenu->addSeparator();
	editMenu->addAction(cutAct);
	editMenu->addAction(copyAct);
	editMenu->addAction(pasteAct);
	editMenu->addAction(evaluateAct);
	editMenu->addAction(evaluateSectionAct);
	editMenu->addAction(scratchPadCsdModeAct);

	editMenu->addSeparator();
	editMenu->addAction(findAct);
	editMenu->addAction(findAgainAct);
	editMenu->addSeparator();
	editMenu->addAction(commentAct);
	//  editMenu->addAction(uncommentAct);
	editMenu->addAction(indentAct);
	editMenu->addAction(unindentAct);
	editMenu->addAction(killLineAct);
	editMenu->addAction(killToEndAct);
	editMenu->addAction(lineNumbersAct);
	editMenu->addAction(parameterModeAct);
	editMenu->addSeparator();
	editMenu->addAction(joinAct);
	editMenu->addAction(inToGetAct);
	editMenu->addAction(getToInAct);
	editMenu->addAction(csladspaAct);
	editMenu->addAction(cabbageAct);
	editMenu->addSeparator();
	editMenu->addAction(editAct);
	editMenu->addSeparator();
	editMenu->addAction(configureAct);
	editMenu->addAction(setShortcutsAct);

	controlMenu = menuBar()->addMenu(tr("Control"));
	controlMenu->addAction(runAct);
	controlMenu->addAction(runTermAct);
	controlMenu->addAction(pauseAct);
	controlMenu->addAction(renderAct);
	controlMenu->addAction(recAct);
	controlMenu->addAction(stopAct);
	controlMenu->addAction(stopAllAct);
	controlMenu->addAction(externalEditorAct);
	controlMenu->addAction(externalPlayerAct);

	viewMenu = menuBar()->addMenu(tr("View"));
	viewMenu->addAction(focusEditorAct);
	viewMenu->addAction(showWidgetsAct);
	viewMenu->addAction(showHelpAct);
	viewMenu->addAction(showConsoleAct);
	viewMenu->addAction(showUtilitiesAct);
	viewMenu->addAction(createCodeGraphAct);
	viewMenu->addAction(showInspectorAct);
	viewMenu->addAction(showLiveEventsAct);
#ifdef QCS_PYTHONQT
	viewMenu->addAction(showPythonConsoleAct);
	viewMenu->addAction(showScratchPadAct);
#endif
	viewMenu->addAction(showUtilitiesAct);
	viewMenu->addSeparator();
	viewMenu->addAction(viewFullScreenAct);
	viewMenu->addSeparator();
	viewMenu->addAction(splitViewAct);
	viewMenu->addSeparator();
	viewMenu->addAction(showOrcAct);
	viewMenu->addAction(showScoreAct);
	viewMenu->addAction(showOptionsAct);
	viewMenu->addAction(showFileBAct);
	viewMenu->addAction(showOtherAct);
	viewMenu->addAction(showOtherCsdAct);
	viewMenu->addAction(showWidgetEditAct);

	QStringList tutFiles;
	QStringList basicsFiles;
	QStringList realtimeInteractionFiles;
	QStringList featuresFiles;
	QStringList flossman01Files;
	QStringList flossman02Files;
	QStringList flossman03Files;
	QStringList flossman04Files;
	QStringList flossman05Files;
	QStringList flossman06Files;
	QStringList flossman07Files;
	QStringList flossman08Files;
	QStringList flossman09Files;
	QStringList flossman12Files;
	QStringList flossmanScFiles;
	QStringList livecollFiles;
	QStringList widgetFiles;
	QStringList synthFiles;
	QStringList musicFiles;
	QStringList usefulFiles;
	QStringList exampleFiles;
	QList<QStringList> subMenus;
	QStringList subMenuNames;


	livecollFiles.append(":/examples/Live Collection/Live_Accordizer.csd");
	livecollFiles.append(":/examples/Live Collection/Live_Delay_Feedback.csd");
	livecollFiles.append(":/examples/Live Collection/Live_Granular.csd");
	livecollFiles.append(":/examples/Live Collection/Live_RM_AM.csd");

	subMenus << livecollFiles;
	subMenuNames << tr("Live Collection");

	widgetFiles.append(":/examples/Widgets/Widget_Panel.csd");
	widgetFiles.append(":/examples/Widgets/Label_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Display_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Slider_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Scrollnumber_Widget.csd");
	widgetFiles.append(":/examples/Widgets/SpinBox_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Graph_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Button_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Checkbox_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Menu_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Controller_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Lineedit_Widget.csd");
	widgetFiles.append(":/examples/Widgets/Scope_Widget.csd");
	widgetFiles.append(":/examples/Widgets/String_Channels.csd");
	widgetFiles.append(":/examples/Widgets/Presets.csd");
	widgetFiles.append(":/examples/Widgets/Reserved_Channels.csd");

	subMenus << widgetFiles;
	subMenuNames << "Widgets";

	synthFiles.append(":/examples/Synths/Additive_Synth.csd");
	synthFiles.append(":/examples/Synths/Imitative_Additive.csd");
	synthFiles.append(":/examples/Synths/Simple_Subtractive.csd");
	synthFiles.append(":/examples/Synths/Simple_FM_Synth.csd");
	synthFiles.append(":/examples/Synths/Phase_Mod_Synth.csd");
	synthFiles.append(":/examples/Synths/Formant_Synth.csd");
	synthFiles.append(":/examples/Synths/Mono_Synth.csd");
	synthFiles.append(":/examples/Synths/B6_Hammond.csd");
	synthFiles.append(":/examples/Synths/Diffamator.csd");
	synthFiles.append(":/examples/Synths/Sruti-Drone_Box.csd");
	synthFiles.append(":/examples/Synths/Pipe_Synth.csd");
	synthFiles.append(":/examples/Synths/Piano_phase.csd");
	synthFiles.append(":/examples/Synths/String_Phaser.csd");
	synthFiles.append(":/examples/Synths/Waveform_Mix.csd");
	subMenus << synthFiles;
	subMenuNames << "Synths";


	musicFiles.append(":/examples/Music/Boulanger-Trapped_in_Convert.csd");
	musicFiles.append(":/examples/Music/Chowning-Stria.csd");
	musicFiles.append(":/examples/Music/Kung-Xanadu.csd");
	musicFiles.append(":/examples/Music/Riley-In_C.csd");
	musicFiles.append(":/examples/Music/Stockhausen-Studie_II.csd");
	musicFiles.append(":/examples/Music/Bach-Invention_1.csd");

	subMenus << musicFiles;
	subMenuNames << tr("Music");

	usefulFiles.append(":/examples/Useful/IO_Test.csd");
	usefulFiles.append(":/examples/Useful/MIDI_IO_Test.csd");
	usefulFiles.append(":/examples/Useful/Audio_Input_Test.csd");
	usefulFiles.append(":/examples/Useful/Audio_Output_Test.csd");
	usefulFiles.append(":/examples/Useful/Audio_Thru_Test.csd");
	usefulFiles.append(":/examples/Useful/MIDI_Recorder.csd");
	usefulFiles.append(":/examples/Useful/MIDI_Layering.csd");
	usefulFiles.append(":/examples/Useful/ASCII_Key.csd");
	usefulFiles.append(":/examples/Useful/Monome_basic.csd");
	usefulFiles.append(":/examples/Useful/SF_Play_from_buffer.csd");
	usefulFiles.append(":/examples/Useful/SF_Play_from_buffer_2.csd");
	usefulFiles.append(":/examples/Useful/SF_Play_from_HD.csd");
	usefulFiles.append(":/examples/Useful/SF_Play_from_HD_2.csd");
	usefulFiles.append(":/examples/Useful/SF_Snippets_Player.csd");
	usefulFiles.append(":/examples/Useful/Jukebox.csd");
	usefulFiles.append(":/examples/Useful/Multichannel_Player.csd");
	usefulFiles.append(":/examples/Useful/Mixdown_Player.csd");
	usefulFiles.append(":/examples/Useful/SF_Record.csd");
	usefulFiles.append(":/examples/Useful/File_to_Text.csd");
	usefulFiles.append(":/examples/Useful/Envelope_Extractor.csd");
	usefulFiles.append(":/examples/Useful/Pitch_Tracker.csd");
	usefulFiles.append(":/examples/Useful/SF_Splitter.csd");
	usefulFiles.append(":/examples/Useful/SF_Merger.csd");

	subMenus << usefulFiles;
	subMenuNames << tr("Useful");

	exampleFiles.append(":/examples/Miscellaneous/MIDI_Tunings.csd");
	exampleFiles.append(":/examples/Miscellaneous/Keyboard_Control.csd");
	exampleFiles.append(":/examples/Miscellaneous/Just_Intonation.csd");
	exampleFiles.append(":/examples/Miscellaneous/Mouse_Control.csd");
	exampleFiles.append(":/examples/Miscellaneous/Autotuner.csd");
	exampleFiles.append(":/examples/Miscellaneous/Event_Panel.csd");
	exampleFiles.append(":/examples/Miscellaneous/Score_Tricks.csd");
	exampleFiles.append(":/examples/Miscellaneous/Simple_Convolution.csd");
	exampleFiles.append(":/examples/Miscellaneous/Universal_Convolution.csd");
	exampleFiles.append(":/examples/Miscellaneous/Cross_Synthesis.csd");
	exampleFiles.append(":/examples/Miscellaneous/SF_Granular.csd");
	exampleFiles.append(":/examples/Miscellaneous/Oscillator_Aliasing.csd");
	exampleFiles.append(":/examples/Miscellaneous/Filter_lab.csd");
	exampleFiles.append(":/examples/Miscellaneous/Pvstencil.csd");
	exampleFiles.append(":/examples/Miscellaneous/Rms.csd");
	exampleFiles.append(":/examples/Miscellaneous/Reinit_Example.csd");
	exampleFiles.append(":/examples/Miscellaneous/No_Reinit.csd");
	exampleFiles.append(":/examples/Miscellaneous/Mincer_Loop.csd");
	exampleFiles.append(":/examples/Miscellaneous/Circle_Map.csd");
	exampleFiles.append(":/examples/Miscellaneous/Binaural_Panning.csd");
	exampleFiles.append(":/examples/Miscellaneous/Spatialization.csd");
    exampleFiles.append(":/examples/Miscellaneous/Pseudostereo.csd");
	exampleFiles.append(":/examples/Miscellaneous/Noise_Reduction.csd");

	subMenus << exampleFiles;
	subMenuNames << tr("Miscellaneous");

	QMenu *examplesMenu = menuBar()->addMenu(tr("Examples"));
	QAction *newAction;
	QMenu *submenu;

	basicsFiles.append(":/examples/Getting Started/Basics/Hello World.csd");
	basicsFiles.append(":/examples/Getting Started/Basics/Document Structure.csd");
	basicsFiles.append(":/examples/Getting Started/Basics/Basic Elements Opcodes.csd");
	basicsFiles.append(":/examples/Getting Started/Basics/Basic Elements Variables.csd");
	basicsFiles.append(":/examples/Getting Started/Basics/Getting Help.csd");
	basicsFiles.append(":/examples/Getting Started/Basics/Instrument Control.csd");
	basicsFiles.append(":/examples/Getting Started/Basics/Realtime Instrument Control.csd");
	basicsFiles.append(":/examples/Getting Started/Basics/Routing.csd");

	QMenu *tutorialMenu = examplesMenu->addMenu(tr("Getting Started"));
	submenu = tutorialMenu->addMenu(tr("Basics"));
	foreach (QString fileName, basicsFiles) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/Creating_Widgets.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/Widgets_Invalue.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/Widgets_Outvalue.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/Widgets_Buttontypes.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/Widgets_Checkbox.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/Live_Audio_Input.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/MIDI_Receiving_Notes.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/MIDI_Synth.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/MIDI_Control_Data.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/MIDI_Assign_Controllers.csd");
	realtimeInteractionFiles.append(":/examples/Getting Started/Realtime_Interaction/OpenSoundControl.csd");

	submenu = tutorialMenu->addMenu(tr("Realtime Interaction"));
	foreach (QString fileName, realtimeInteractionFiles) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

	featuresFiles.append(":/examples/Getting Started/Language_Features/Function_Tables_1.csd");
	featuresFiles.append(":/examples/Getting Started/Language_Features/Function_Tables_2.csd");
	featuresFiles.append(":/examples/Getting Started/Language_Features/Loops_1.csd");
	featuresFiles.append(":/examples/Getting Started/Language_Features/Loops_2.csd");
	featuresFiles.append(":/examples/Getting Started/Language_Features/Console_Print.csd");
	featuresFiles.append(":/examples/Getting Started/Language_Features/Writing_Audio_Files.csd");
	featuresFiles.append(":/examples/Getting Started/Language_Features/Using_Udos.csd");

	submenu = tutorialMenu->addMenu(tr("Language Features"));
	foreach (QString fileName, featuresFiles) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

	tutFiles.append(":/examples/Getting Started/Toots/Toot1.csd");
	tutFiles.append(":/examples/Getting Started/Toots/Toot2.csd");
	tutFiles.append(":/examples/Getting Started/Toots/Toot3.csd");
	tutFiles.append(":/examples/Getting Started/Toots/Toot4.csd");
	tutFiles.append(":/examples/Getting Started/Toots/Toot5.csd");

	submenu = tutorialMenu->addMenu("Toots");
	foreach (QString fileName, tutFiles) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

	//FLOSS Manual Examples
	QMenu *flossmanMenu = examplesMenu->addMenu(tr("FLOSS Manual Examples"));

	flossmanMenu->addAction(tr("Read FLOSS Manual Online"),this, SLOT(openFLOSSManual()));
	flossmanMenu->addSeparator();

//re-new the following section if the examples have changed
//for completely new chapters, you must also add a line like
//	QStringList flossman01Files;
//in the listing some lines above

//01
flossman01Files.append(":/examples/FLOSS Manual Examples/01 Basics/01A01_Aliasing.csd");
flossman01Files.append(":/examples/FLOSS Manual Examples/01 Basics/01B01_BordersForHearing.csd");
flossman01Files.append(":/examples/FLOSS Manual Examples/01 Basics/01B02_Adding_vs_ratio.csd");
flossman01Files.append(":/examples/FLOSS Manual Examples/01 Basics/01C01_db_vs_linear.csd");
flossman01Files.append(":/examples/FLOSS Manual Examples/01 Basics/01C02_rms_feedback_system.csd");
flossman01Files.append(":/examples/FLOSS Manual Examples/01 Basics/01C03_FletcherMunson.csd");
	submenu = flossmanMenu->addMenu(tr("01 Basics"));
	foreach (QString fileName, flossman01Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//02
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02A01_HelloWorld.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02B01_DocStruct.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02C01_Midi_Keybd_in.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02C02_Midi_Ctl_in.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02C03_Midi_all_in.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02D01_GetDeviceList.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02D02_LiveInput.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02E01_Render.csd");
flossman02Files.append(":/examples/FLOSS Manual Examples/02 Quick Start/02E02_RecordRT.csd");
	submenu = flossmanMenu->addMenu(tr("02 Quick Start"));
	foreach (QString fileName, flossman02Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//03
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A01_Init-pass.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A02_Perf-pass_incr.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A03_Perf-pass_incr_listen.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A04_Perf-pass_no_incr.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A05_Audio_vector.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A06_Init_perf_audio.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A07_Init-values_of_k-variables.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A08_Init_no_incr.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A09_Re-init.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A10_Order_of_calc.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A11_Order_of_calc_named.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A12_Random_at_ika.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A13_Zipper.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03A14_Time_Impossible.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B01_Variable_types.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B02_Local_scope.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B03_Global_scope.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B04_Global_audio_intro.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B05_Global_audio_overwritten.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B06_Global_audio_added.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B07_Global_control_added.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B08_Local_audio_add.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B09_Global_audio_add.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B10_Global_with_clear.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03B11_Chn_demo.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C01_IfThen_i.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C02_IfThen_k.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C03_IfThen_short_form.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C04_IfGoto_i.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C05_IfGoto_ik.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C06_IfGoto_k.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C07_Loops_with_if.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C08_Loop_opcodes_i.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C09_Random_string.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C10_Random_ftable_fill.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C11_Table_random_dev.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C12_Timout_pre.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C13_Timout_basics.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C14_Timeloop_and_not.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C15_Timout_different_durations.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C16_Timout_random_durations.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C17_Timout_trigger_events.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C18_Timout_random_envelope.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C19_Timeloop_metro.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03C20_Metro_trigger_events.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D01_Table_norm_notNorm.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D02_Table_ftgen.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D03_Sample_to_table.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D04_Standard_waveforms_with_GEN10.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D05_Write_Fibo_to_table.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D06_Record_ksig_to_table.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D07_Record_audio_to_table.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D08_RecPlay_ak_signals.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D09_ftsave.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03D10_Table_to_soundfile.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03E01_Array_to_table.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03E02_norm_to_max.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03E03_FFT_peaks_arpegg.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F01_OrderOfExc_event_i.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F02_OrderOfExc_event_k.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F03_Score_tricks.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F04_Midi_triggered_events.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F05_FLTK_triggered_events.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F06_Commandline_rt_events.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F07_Event_by_condition.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F08_Generate_event_pool.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F09_Events_sprintf.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F10_Events_collected.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03F11_Events_time_loop.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G01_Pre_UDO.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G02_All_to_UDO.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G03_UDO_more_flex.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G04_UDO_calls_UDO.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G06_UDO_setksmps.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G07_UDO_default_args.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G08_Recursive_UDO.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G09_UDO_FilePlay.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G10_UDO_rand_dev.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G11_TabPermRnd.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G12_TableDumpSimp.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03G13_UDO_Recursive_AddSynth.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03H01_Macros_basic.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03H02_Macro_6partials.csd");
flossman03Files.append(":/examples/FLOSS Manual Examples/03 Csound Language/03H03_Score_macro.csd");
	submenu = flossmanMenu->addMenu(tr("03 Csound Language"));
	foreach (QString fileName, flossman03Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//04
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A01_AddSynth_simple.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A02_AddSynth_score.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A03_AddSynth_GEN.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A04_Standard_waveforms.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A05_Flexible_number_of_partials.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A06_Play_it_with_Midi.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A07_Risset_variations.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A08_Risset_played_by_Midi.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A09_Wobble_bass.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A10_gbuzz.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A11_gbuzz_partials_rise.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04A12_gbuzz_amp_coeff_rise.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04B01_Subtractive_Midi.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04B02_Subtractive_timbres.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04B03_Subtractive_vowels.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04E01_Simple_waveshaping.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04F01_GranSynth_basic.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04F02_Fof_vowels.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04F03_Asynchronous_GS.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04F04_grain3.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04F05_grain3_random.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G01_Mass_spring_sine.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G02_MS_sine_audible.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G03_MS_variable_constant.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G04_KarplusStrong.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G05_Plucked.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G06_wgbow.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G07_barmodel.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G07_wgbow_enhanced.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04G08_PhiSEM.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H01_scantable.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H02_Dynamic_tables.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H03_Scantable_pvsmaska.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H04_Hammer.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H05_Scan_trajectories.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H06_Scan_trajectories2.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H07_Scan_matrices.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H08_Scan_tablesize.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H09_Scan_extreme_amplitude.csd");
flossman04Files.append(":/examples/FLOSS Manual Examples/04 Sound Synthesis/04H10_Scan_balanced_amplitudes.csd");
	submenu = flossmanMenu->addMenu(tr("04 Sound Synthesis"));
	foreach (QString fileName, flossman04Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//05
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A01_line.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A02_line_p3.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A03_linseg.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A04_linseg_p3_fractions.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A05_line_vs_linseg.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A06_line_vs_expon.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A07_expon_pings.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A08_linsegr.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A09_sine_env.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05A10_lpshold_loopseg.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B01_Pan_stereo.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B02_pan2.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B03_Different_pan_layers.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B04_hrtfmove.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B05_VBAP_circle.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B06_VBAP_spread.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B07_VBAP_new.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B08_Ambi_circle.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05B09_Ambi_orders.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05C01_tone_butlp_moogladder.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05C02_atone_buthp_bqrez.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05C03_reson_butbp.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05C04_comb.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05D01_delay.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05D02_delay_feedback.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05D03_deltapi.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05D04_multi-tap_delay.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05D05_flanger.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05E01_freeverb.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05E02_reverbsc.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05E03_reverb_with_chn.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05E04_schroeder_reverb.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05F02_Wvshp_bit_crunch.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05F03_Wvshp_different_transfer_funs.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05F04_distort.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05G01_sndwarp.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05G02_selfmade_grain.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05G03_granule.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05G04_grain_delay.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05G05_grain.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05H01_pconvolve.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05I01_pvsanal.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05I02_pvscale.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05I04_phase_vocoder.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05I05_pvscross.csd");
flossman05Files.append(":/examples/FLOSS Manual Examples/05 Sound Modification/05I06_pvsfilter.csd");
	submenu = flossmanMenu->addMenu(tr("05 Sound Modification"));
	foreach (QString fileName, flossman05Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//06
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06A01_Play_soundfile.csd");
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06A02_Write_soundfile.csd");
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06A06_pdcs_tabset_tabget.csd");
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06B01_flooper2.csd");
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06B02_sndloop.csd");
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06B03_RecPlayToTable.csd");
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06B04_BufRecPlay_UDO.csd");
flossman06Files.append(":/examples/FLOSS Manual Examples/06 Samples/06B05_BufRecPlay_complex.csd");
	submenu = flossmanMenu->addMenu(tr("06 Samples"));
	foreach (QString fileName, flossman06Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//07
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07A01_midiin_print.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07B01_MidiInstrTrigger.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07B04_MidiMultiTrigg.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07D01_ReadMidiFile.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07E01_midiout.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07E02_score_to_midiout.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07E03_midiout_cc.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07E04_midion.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07E05_midion2.csd");
flossman07Files.append(":/examples/FLOSS Manual Examples/07 MIDI/07E06_moscil.csd");
	submenu = flossmanMenu->addMenu(tr("07 MIDI"));
	foreach (QString fileName, flossman07Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//08
flossman08Files.append(":/examples/FLOSS Manual Examples/08 Other Communication/08A01_osc.csd");
flossman08Files.append(":/examples/FLOSS Manual Examples/08 Other Communication/08B01_Pd_to_Csound.csd");
flossman08Files.append(":/examples/FLOSS Manual Examples/08 Other Communication/08B02_Processing_to_Csound.csd");
flossman08Files.append(":/examples/FLOSS Manual Examples/08 Other Communication/08B03_Serial_Read.csd");
	submenu = flossmanMenu->addMenu(tr("08 Other Communication"));
	foreach (QString fileName, flossman08Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//09
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09A01_pdcs_control_in.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09A02_pdcs_live_in.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09A03_pdcs_midi.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09A04_pdcs_events.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09A05_pdcs_control_out.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09B01_maxcs_helloworld.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09B02_maxcs_audio_io.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09B03_maxcs_control_in.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09B04_maxcs_midi.csd");
flossman09Files.append(":/examples/FLOSS Manual Examples/09 Csound in other Applications/09B05_maxcs_events.csd");
	submenu = flossmanMenu->addMenu(tr("09 Csound in other Applications"));
	foreach (QString fileName, flossman09Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//12
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B01_pyinit.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B02_python_global.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B03_pyrun.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B04_pyevali.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B05_pyassigni.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B06_pycall.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B07_local_vs_global.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12B08_markov.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12C01_run_pause_stop.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12C02_score_generated.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12C03_presets.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12C04_dialog.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12C05_string_sound.csd");
flossman12Files.append(":/examples/FLOSS Manual Examples/12 Csound and other Languages/12C06_color_controller.csd");
	submenu = flossmanMenu->addMenu(tr("12 Csound and other Languages"));
	foreach (QString fileName, flossman12Files) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}

//Sc
flossmanScFiles.append(":/examples/FLOSS Manual Examples/Score Methods/Score_methods_01.csd");
flossmanScFiles.append(":/examples/FLOSS Manual Examples/Score Methods/Score_methods_02.csd");
flossmanScFiles.append(":/examples/FLOSS Manual Examples/Score Methods/Score_methods_03.csd");
	submenu = flossmanMenu->addMenu(tr("Score Methods"));
	foreach (QString fileName, flossmanScFiles) {
		QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
		newAction = submenu->addAction(name);
		newAction->setData(fileName);
		connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
	}


	QString mcCurdyPath;
#ifdef Q_OS_WIN32
	mcCurdyPath = qApp->applicationDirPath() + "/Examples/McCurdy Collection";
#endif
#ifdef Q_OS_MAC
	mcCurdyPath = qApp->applicationDirPath() + "/../Resources/McCurdy Collection";
	qDebug() << mcCurdyPath;
#endif
#ifdef Q_OS_LINUX
	mcCurdyPath = qApp->applicationDirPath() + "/Examples/McCurdy Collection";
	if (!QDir(mcCurdyPath).exists()) {
		mcCurdyPath = "/usr/share/qutecsound/Examples/McCurdy Collection";
	}
	if (!QDir(mcCurdyPath).exists()) {
		mcCurdyPath = qApp->applicationDirPath() + "/../src/Examples/McCurdy Collection";
	}
	if (!QDir(mcCurdyPath).exists()) { // for out of tree builds
		mcCurdyPath = qApp->applicationDirPath() + "/../../csoundqt/src/Examples/McCurdy Collection";
	}
	if (!QDir(mcCurdyPath).exists()) { // for out of tree builds
		mcCurdyPath = qApp->applicationDirPath() + "/../../qutecsound/src/Examples/McCurdy Collection";
	}
#endif
#ifdef Q_OS_SOLARIS
	mcCurdyPath = qApp->applicationDirPath() + "/Examples/McCurdy Collection";
	if (!QDir(mcCurdyPath).exists()) {
		mcCurdyPath = "/usr/share/qutecsound/Examples/McCurdy Collection";
	}
	if (!QDir(mcCurdyPath).exists()) {
		mcCurdyPath = qApp->applicationDirPath() + "/../src/Examples/McCurdy Collection";
	}
#endif

	if (QDir(mcCurdyPath).exists()) {
		QMenu *mccurdyMenu = examplesMenu->addMenu(tr("McCurdy Collection"));
		QStringList subDirs = QDir(mcCurdyPath).entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
		foreach (QString subDir, subDirs) {
			QString dirName = subDir.mid(subDir.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
			submenu = mccurdyMenu->addMenu(dirName);
			QStringList filters;
			filters << "*.csd";
			QStringList mcCurdyFiles = QDir(mcCurdyPath + "/" + subDir).entryList(filters,QDir::Files);
			foreach (QString fileName, mcCurdyFiles) {
				//        QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
				newAction = submenu->addAction(fileName);
				newAction->setData(mcCurdyPath + "/" + subDir + "/" + fileName);
				connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
			}
		}
	}

	// Add the rest
	for (int i = 0; i < subMenus.size(); i++) {
		submenu = examplesMenu->addMenu(subMenuNames[i]);
		foreach (QString fileName, subMenus[i]) {
			QString name = fileName.mid(fileName.lastIndexOf("/") + 1).replace("_", " ").remove(".csd");
			newAction = submenu->addAction(name);
			newAction->setData(fileName);
			connect(newAction,SIGNAL(triggered()), this, SLOT(openExample()));
		}
	}

	favoriteMenu = menuBar()->addMenu(tr("Favorites"));
#ifdef QCS_PYTHONQT
	scriptsMenu = menuBar()->addMenu(tr("Scripts"));
	scriptsMenu->hide();
#endif

	menuBar()->addSeparator();

	helpMenu = menuBar()->addMenu(tr("Help"));
	helpMenu->addAction(setHelpEntryAct);
	helpMenu->addAction(externalBrowserAct);
	helpMenu->addSeparator();
	helpMenu->addAction(browseBackAct);
	helpMenu->addAction(browseForwardAct);
	helpMenu->addSeparator();
	helpMenu->addAction(showManualAct);
	helpMenu->addAction(showOverviewAct);
	helpMenu->addAction(showOpcodeQuickRefAct);
	helpMenu->addAction(showGenAct);
	helpMenu->addAction(openQuickRefAct);
	helpMenu->addSeparator();
	helpMenu->addAction(resetPreferencesAct);
	helpMenu->addSeparator();
	helpMenu->addAction(reportBugAct);
	helpMenu->addAction(requestFeatureAct);
	helpMenu->addAction(chatAct);
	helpMenu->addSeparator();
	helpMenu->addAction(aboutAct);
	helpMenu->addAction(donateAct);
	//  helpMenu->addAction(aboutQtAct);

}

void CsoundQt::fillFileMenu()
{
	recentMenu->clear();
	for (int i = 0; i < recentFiles.size(); i++) {
		if (i < recentFiles.size() && recentFiles[i] != "") {
			QAction *a = recentMenu->addAction(recentFiles[i], this, SLOT(openFromAction()));
			a->setData(recentFiles[i]);
		}
	}
}

void CsoundQt::fillFavoriteMenu()
{
	favoriteMenu->clear();
	if (!m_options->favoriteDir.isEmpty()) {
		QDir dir(m_options->favoriteDir);
		fillFavoriteSubMenu(dir.absolutePath(), favoriteMenu, 0);
	}
	else {
		favoriteMenu->addAction(tr("Set the Favourites folder in the Configuration Window"),
								this, SLOT(configure()));
	}
}

void CsoundQt::fillFavoriteSubMenu(QDir dir, QMenu *m, int depth)
{
	QStringList filters;
	filters << "*.csd" << "*.orc" << "*.sco" << "*.udo" << "*.inc" << "*.py";
	dir.setNameFilters(filters);
	QStringList files = dir.entryList(QDir::Files,QDir::Name);
	QStringList dirs = dir.entryList(QDir::AllDirs,QDir::Name);
	if (depth > m_options->menuDepth)
		return;
	for (int i = 0; i < dirs.size() && i < 64; i++) {
		QDir newDir(dir.absolutePath() + "/" + dirs[i]);
		newDir.setNameFilters(filters);
		QStringList newFiles = dir.entryList(QDir::Files,QDir::Name);
		QStringList newDirs = dir.entryList(QDir::AllDirs,QDir::Name);
		if (newFiles.size() > 0 ||  newDirs.size() > 0) {
			if (dirs[i] != "." && dirs[i] != "..") {
				QMenu *menu = m->addMenu(dirs[i]);
				fillFavoriteSubMenu(newDir.absolutePath(), menu, depth + 1);
			}
		}
	}
	for (int i = 0; i < files.size() &&  i < 64; i++) {
		QAction *newAction = m->addAction(files[i],
										  this, SLOT(openFromAction()));
		newAction->setData(dir.absoluteFilePath(files[i]));
	}
}

void CsoundQt::fillScriptsMenu()
{
#ifdef QCS_PYTHONQT
	scriptsMenu->clear();
	QString dirName = m_options->pythonDir.isEmpty() ? DEFAULT_SCRIPT_DIR : m_options->pythonDir;
	QDir dir(dirName);
	if (dir.count() > 0) {
		fillScriptsSubMenu(dir.absolutePath(), scriptsMenu, 0);
		scriptsMenu->addSeparator();
		QMenu *editMenu = scriptsMenu->addMenu("Edit");
		fillEditScriptsSubMenu(dir.absolutePath(), editMenu, 0);
	}
#endif
}

void CsoundQt::fillScriptsSubMenu(QDir dir, QMenu *m, int depth)
{
	QStringList filters;
	filters << "*.py";
	dir.setNameFilters(filters);
	QStringList files = dir.entryList(QDir::Files,QDir::Name);
	QStringList dirs = dir.entryList(QDir::AllDirs,QDir::Name);
	if (depth > m_options->menuDepth)
		return;
	for (int i = 0; i < dirs.size() && i < 64; i++) {
		QDir newDir(dir.absolutePath() + "/" + dirs[i]);
		newDir.setNameFilters(filters);
		QStringList newFiles = dir.entryList(QDir::Files,QDir::Name);
		QStringList newDirs = dir.entryList(QDir::AllDirs,QDir::Name);
		if (newFiles.size() > 0 ||  newDirs.size() > 0) {
			if (dirs[i] != "." && dirs[i] != "..") {
				QMenu *menu = m->addMenu(dirs[i]);
				fillScriptsSubMenu(newDir.absolutePath(), menu, depth + 1);
			}
		}
	}
	for (int i = 0; i < files.size() &&  i < 64; i++) {
		QAction *newAction = m->addAction(files[i],
										  this, SLOT(runScriptFromAction()));
		newAction->setData(dir.absoluteFilePath(files[i]));
	}
}

void CsoundQt::fillEditScriptsSubMenu(QDir dir, QMenu *m, int depth)
{
	QStringList filters;
	filters << "*.py";
	dir.setNameFilters(filters);
	QStringList files = dir.entryList(QDir::Files,QDir::Name);
	QStringList dirs = dir.entryList(QDir::AllDirs,QDir::Name);
	if (depth > m_options->menuDepth)
		return;
	for (int i = 0; i < dirs.size() && i < 64; i++) {
		QDir newDir(dir.absolutePath() + "/" + dirs[i]);
		newDir.setNameFilters(filters);
		QStringList newFiles = dir.entryList(QDir::Files,QDir::Name);
		QStringList newDirs = dir.entryList(QDir::AllDirs,QDir::Name);
		if (newFiles.size() > 0 ||  newDirs.size() > 0) {
			if (dirs[i] != "." && dirs[i] != "..") {
				QMenu *menu = m->addMenu(dirs[i]);
				fillEditScriptsSubMenu(newDir.absolutePath(), menu, depth + 1);
			}
		}
	}
	for (int i = 0; i < files.size() &&  i < 64; i++) {
		QAction *newAction = m->addAction(files[i],
										  this, SLOT(openFromAction()));
		newAction->setData(dir.absoluteFilePath(files[i]));
	}
}

void CsoundQt::createToolBars()
{
//	fileToolBar = addToolBar(tr("File"));
//	fileToolBar->setObjectName("fileToolBar");
//	fileToolBar->addAction(newAct);
//	fileToolBar->addAction(openAct);
//	fileToolBar->addAction(saveAct);

//	editToolBar = addToolBar(tr("Edit"));
//	editToolBar->setObjectName("editToolBar");
//	editToolBar->addAction(undoAct);
//	editToolBar->addAction(redoAct);
//	editToolBar->addAction(cutAct);
//	editToolBar->addAction(copyAct);
//	editToolBar->addAction(pasteAct);

	controlToolBar = addToolBar(tr("Control"));
	controlToolBar->setObjectName("controlToolBar");
	controlToolBar->addAction(runAct);
	controlToolBar->addAction(pauseAct);
	controlToolBar->addAction(stopAct);
	controlToolBar->addAction(recAct);
	controlToolBar->addAction(runTermAct);
	controlToolBar->addAction(renderAct);
	controlToolBar->addAction(externalEditorAct);
	controlToolBar->addAction(externalPlayerAct);

	configureToolBar = addToolBar(tr("Configure"));
	configureToolBar->setObjectName("configureToolBar");
	configureToolBar->addAction(configureAct);
	configureToolBar->addAction(showWidgetsAct);
	configureToolBar->addAction(showHelpAct);
	configureToolBar->addAction(showConsoleAct);
	configureToolBar->addAction(showInspectorAct);
	configureToolBar->addAction(showLiveEventsAct);
#ifdef QCS_PYTHONQT
	configureToolBar->addAction(showPythonConsoleAct);
	configureToolBar->addAction(showScratchPadAct);
#endif
	configureToolBar->addAction(showUtilitiesAct);

	Qt::ToolButtonStyle toolButtonStyle = (m_options->iconText?
											   Qt::ToolButtonTextUnderIcon: Qt::ToolButtonIconOnly);
//	fileToolBar->setToolButtonStyle(toolButtonStyle);
//	editToolBar->setToolButtonStyle(toolButtonStyle);
	controlToolBar->setToolButtonStyle(toolButtonStyle);
	configureToolBar->setToolButtonStyle(toolButtonStyle);
}

void CsoundQt::createStatusBar()
{
	statusBar()->showMessage(tr("Ready"));
}

void CsoundQt::readSettings()
{
	QSettings settings("csound", "qutecsound");
	int settingsVersion = settings.value("settingsVersion", 0).toInt();
	// Version 1 to remove "-d" from additional command line flags
	// Version 2 to save default keyboard shortcuts (weren't saved previously)
	// Version 2 to add "*" to jack client name
	settings.beginGroup("GUI");
	m_options->theme = settings.value("theme", "boring").toString();
	QPoint pos = settings.value("pos", QPoint(200, 200)).toPoint();
	QSize size = settings.value("size", QSize(600, 500)).toSize();
	resize(size);
	move(pos);
	if (settings.contains("dockstate")) {
		restoreState(settings.value("dockstate").toByteArray());
	}
	lastUsedDir = settings.value("lastuseddir", "").toString();
	lastFileDir = settings.value("lastfiledir", "").toString();
	//  showLiveEventsAct->setChecked(settings.value("liveEventsActive", true).toBool());
	m_options->language = m_configlists.languageCodes.indexOf(settings.value("language", QLocale::system().name()).toString());
	if (m_options->language < 0)
		m_options->language = 0;
	recentFiles.clear();
	recentFiles = settings.value("recentFiles").toStringList();
	QHash<QString, QVariant> actionList = settings.value("shortcuts").toHash();
	if (actionList.count() != 0) {
		QHashIterator<QString, QVariant> i(actionList);
		while (i.hasNext()) {
			i.next();
			QString shortcut = i.value().toString();
			foreach (QAction *act, m_keyActions) {
				if (act->text().remove("&") == i.key()) {
					act->setShortcut(shortcut);
					break;
				}
			}
		}
	}
	else { // No shortcuts are stored
		setDefaultKeyboardShortcuts();
	}
	settings.endGroup();
	settings.beginGroup("Options");
	settings.beginGroup("Editor");
	m_options->font = settings.value("font", "Courier").toString();
	m_options->fontPointSize = settings.value("fontsize", 12).toDouble();
	m_options->showLineNumberArea = settings.value("showLineNumberArea", true).toBool();
#ifdef Q_OS_WIN32
	m_options->lineEnding = settings.value("lineEnding", 1).toInt();
#else
	m_options->lineEnding = settings.value("lineEnding", 0).toInt();
#endif
	m_options->consoleFont = settings.value("consolefont", "Courier").toString();
	m_options->consoleFontPointSize = settings.value("consolefontsize", 10).toDouble();

	m_options->consoleFontColor = settings.value("consoleFontColor", QVariant(QColor(Qt::black))).value<QColor>();
	m_options->consoleBgColor = settings.value("consoleBgColor", QVariant(QColor(Qt::white))).value<QColor>();
	m_options->tabWidth = settings.value("tabWidth", 40).toInt();
	m_options->tabIndents = settings.value("tabIndents", true).toBool();
	m_options->colorVariables = settings.value("colorvariables", true).toBool();
	m_options->autoPlay = settings.value("autoplay", false).toBool();
	m_options->autoJoin = settings.value("autoJoin", true).toBool();
	m_options->menuDepth = settings.value("menuDepth", 3).toInt();
	m_options->saveChanges = settings.value("savechanges", true).toBool();
	m_options->rememberFile = settings.value("rememberfile", true).toBool();
	m_options->saveWidgets = settings.value("savewidgets", true).toBool();
	m_options->widgetsIndependent = settings.value("widgetsIndependent", false).toBool();
	m_options->iconText = settings.value("iconText", true).toBool();
	m_options->showToolbar = settings.value("showToolbar", true).toBool();
	m_options->wrapLines = settings.value("wrapLines", true).toBool();
	m_options->autoComplete = settings.value("autoComplete", true).toBool();
	m_options->autoParameterMode = settings.value("autoParameterMode", true).toBool();
	m_options->enableWidgets = settings.value("enableWidgets", true).toBool();
	m_options->showWidgetsOnRun = settings.value("showWidgetsOnRun", true).toBool();
	m_options->showTooltips = settings.value("showTooltips", true).toBool();
	m_options->enableFLTK = settings.value("enableFLTK", true).toBool();
	m_options->terminalFLTK = settings.value("terminalFLTK", true).toBool();
	m_options->oldFormat = settings.value("oldFormat", false).toBool();
	m_options->openProperties = settings.value("openProperties", true).toBool();
	m_options->fontOffset = settings.value("fontOffset", 0.0).toDouble();
	m_options->fontScaling = settings.value("fontScaling", 1.0).toDouble();
	lastFiles = settings.value("lastfiles", QStringList()).toStringList();
	lastTabIndex = settings.value("lasttabindex", "").toInt();
	settings.endGroup();
	settings.beginGroup("Run");
	m_options->useAPI = settings.value("useAPI", true).toBool();
	m_options->keyRepeat = settings.value("keyRepeat", false).toBool();
	m_options->debugLiveEvents = settings.value("debugLiveEvents", false).toBool();
	m_options->consoleBufferSize = settings.value("consoleBufferSize", 1024).toInt();
	m_options->midiInterface = settings.value("midiInterface", 9999).toInt();
	m_options->noBuffer = settings.value("noBuffer", false).toBool();
	m_options->noPython = settings.value("noPython", false).toBool();
	m_options->noMessages = settings.value("noMessages", false).toBool();
	m_options->noEvents = settings.value("noEvents", false).toBool();

	m_options->bufferSize = settings.value("bufferSize", 1024).toInt();
	m_options->bufferSizeActive = settings.value("bufferSizeActive", false).toBool();
	m_options->HwBufferSize = settings.value("HwBufferSize", 1024).toInt();
	m_options->HwBufferSizeActive = settings.value("HwBufferSizeActive", false).toBool();
	m_options->dither = settings.value("dither", false).toBool();
	m_options->newParser = settings.value("newParser", false).toBool();
	m_options->multicore = settings.value("multicore", false).toBool();
	m_options->numThreads = settings.value("numThreads", 1).toInt();
	m_options->additionalFlags = settings.value("additionalFlags", "").toString();
	if (settingsVersion < 1)
		m_options->additionalFlags.remove("-d");  // remove old -d preference, as it is fixed now.
	m_options->additionalFlagsActive = settings.value("additionalFlagsActive", false).toBool();
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
	m_options->rtAudioModule = settings.value("rtAudioModule", "pa_bl").toString();
	if (m_options->rtAudioModule.isEmpty()) { m_options->rtAudioModule = "pa_bl"; }
	m_options->rtInputDevice = settings.value("rtInputDevice", "adc").toString();
	m_options->rtOutputDevice = settings.value("rtOutputDevice", "dac").toString();
	m_options->rtJackName = settings.value("rtJackName", "").toString();
	if (settingsVersion < 2) {
		if (!m_options->rtJackName.endsWith("*"))
			m_options->rtJackName.append("*");
	}
	m_options->rtMidiModule = settings.value("rtMidiModule", "portmidi").toString();
	if (m_options->rtMidiModule.isEmpty()) { m_options->rtMidiModule = "portmidi"; }
	m_options->rtMidiInputDevice = settings.value("rtMidiInputDevice", "0").toString();
	m_options->rtMidiOutputDevice = settings.value("rtMidiOutputDevice", "").toString();
	m_options->simultaneousRun = settings.value("simultaneousRun", "").toBool();
	m_options->sampleFormat = settings.value("sampleFormat", 0).toInt();
	settings.endGroup();
	settings.beginGroup("Environment");
#ifdef Q_OS_MAC
	m_options->csdocdir = settings.value("csdocdir", DEFAULT_HTML_DIR).toString();
#else
	m_options->csdocdir = settings.value("csdocdir", "").toString();
#endif
	m_options->opcodedir = settings.value("opcodedir","").toString();
	m_options->opcodedirActive = settings.value("opcodedirActive",false).toBool();
	m_options->opcodedir64 = settings.value("opcodedir64","").toString();
	m_options->opcodedir64Active = settings.value("opcodedir64Active",false).toBool();
	m_options->opcode6dir64 = settings.value("opcode6dir64","").toString();
	m_options->opcode6dir64Active = settings.value("opcode6dir64Active",false).toBool();
	m_options->sadir = settings.value("sadir","").toString();
	m_options->sadirActive = settings.value("sadirActive","").toBool();
	m_options->ssdir = settings.value("ssdir","").toString();
	m_options->ssdirActive = settings.value("ssdirActive","").toBool();
	m_options->sfdir = settings.value("sfdir","").toString();
	m_options->sfdirActive = settings.value("sfdirActive","").toBool();
	m_options->incdir = settings.value("incdir","").toString();
	m_options->incdirActive = settings.value("incdirActive","").toBool();
	m_options->defaultCsd = settings.value("defaultCsd","").toString();
	m_options->defaultCsdActive = settings.value("defaultCsdActive","").toBool();
	m_options->favoriteDir = settings.value("favoriteDir","").toString();
	m_options->pythonDir = settings.value("pythonDir","").toString();
	m_options->pythonExecutable = settings.value("pythonExecutable","python").toString();
	m_options->csoundExecutable = settings.value("csoundExecutable","csound").toString();
	m_options->logFile = settings.value("logFile",DEFAULT_LOG_FILE).toString();
	m_options->sdkDir = settings.value("sdkDir","").toString();
	m_options->opcodexmldir = settings.value("opcodexmldir", "").toString();
	m_options->opcodexmldirActive = settings.value("opcodexmldirActive","").toBool();
	settings.endGroup();
	settings.beginGroup("External");
	m_options->terminal = settings.value("terminal", DEFAULT_TERM_EXECUTABLE).toString();
	m_options->browser = settings.value("browser", DEFAULT_BROWSER_EXECUTABLE).toString();
	m_options->dot = settings.value("dot", DEFAULT_DOT_EXECUTABLE).toString();
	m_options->waveeditor = settings.value("waveeditor",
										   DEFAULT_WAVEEDITOR_EXECUTABLE
										   ).toString();
	m_options->waveplayer = settings.value("waveplayer",
										   DEFAULT_WAVEPLAYER_EXECUTABLE
										   ).toString();
	m_options->pdfviewer = settings.value("pdfviewer",
										  DEFAULT_PDFVIEWER_EXECUTABLE
										  ).toString();
	settings.endGroup();
	settings.beginGroup("Template");
	m_options->csdTemplate = settings.value("csdTemplate", QCS_DEFAULT_TEMPLATE).toString();
	settings.endGroup();
	settings.endGroup();
	if (settingsVersion < 3 && settingsVersion > 0) {
		showNewFormatWarning();
		m_options->csdTemplate = QCS_DEFAULT_TEMPLATE;
	}
}

void CsoundQt::writeSettings(QStringList openFiles, int lastIndex)
{
	QSettings settings("csound", "qutecsound");
	if (!m_resetPrefs) {
		// Version 1 when clearing additional flags, version 2 when setting jack client to *
		// version 3 to store that new widget format warning has been shown.
		settings.setValue("settingsVersion", 3);
	}
	else {
		settings.remove("");
	}
	settings.beginGroup("GUI");
	if (!m_resetPrefs) {
		settings.setValue("pos", pos());
		settings.setValue("size", size());
		settings.setValue("dockstate", saveState());
		settings.setValue("lastuseddir", lastUsedDir);
		settings.setValue("lastfiledir", lastFileDir);
		settings.setValue("language", m_configlists.languageCodes[m_options->language]);
		//  settings.setValue("liveEventsActive", showLiveEventsAct->isChecked());
		settings.setValue("recentFiles", recentFiles);
		settings.setValue("theme", m_options->theme);
	}
	else {
		settings.remove("");
	}
	QHash<QString, QVariant> shortcuts;
	foreach (QAction *act, m_keyActions) {
		shortcuts[act->text().remove("&")] = QVariant(act->shortcut().toString());
	}
	settings.setValue("shortcuts", QVariant(shortcuts));
	settings.endGroup();
	settings.beginGroup("Options");
	settings.beginGroup("Editor");
	if (!m_resetPrefs) {
		settings.setValue("font", m_options->font );
		settings.setValue("fontsize", m_options->fontPointSize);
		settings.setValue("showLineNumberArea", m_options->showLineNumberArea);
		settings.setValue("lineEnding", m_options->lineEnding);
		settings.setValue("consolefont", m_options->consoleFont );
		settings.setValue("consolefontsize", m_options->consoleFontPointSize);
		settings.setValue("consoleFontColor", QVariant(m_options->consoleFontColor));
		settings.setValue("consoleBgColor", QVariant(m_options->consoleBgColor));
		settings.setValue("tabWidth", m_options->tabWidth );
		settings.setValue("tabIndents", m_options->tabIndents);
		settings.setValue("colorvariables", m_options->colorVariables);
		settings.setValue("autoplay", m_options->autoPlay);
		settings.setValue("autoJoin", m_options->autoJoin);
		settings.setValue("menuDepth", m_options->menuDepth);
		settings.setValue("savechanges", m_options->saveChanges);
		settings.setValue("rememberfile", m_options->rememberFile);
		settings.setValue("savewidgets", m_options->saveWidgets);
		settings.setValue("widgetsIndependent", m_options->widgetsIndependent);
		settings.setValue("iconText", m_options->iconText);
		settings.setValue("showToolbar", m_options->showToolbar);
		settings.setValue("wrapLines", m_options->wrapLines);
		settings.setValue("autoComplete", m_options->autoComplete);
		settings.setValue("autoParameterMode", m_options->autoParameterMode);
		settings.setValue("enableWidgets", m_options->enableWidgets);
		settings.setValue("showWidgetsOnRun", m_options->showWidgetsOnRun);
		settings.setValue("showTooltips", m_options->showTooltips);
		settings.setValue("enableFLTK", m_options->enableFLTK);
		settings.setValue("terminalFLTK", m_options->terminalFLTK);
		settings.setValue("oldFormat", m_options->oldFormat);
		settings.setValue("openProperties", m_options->openProperties);
		settings.setValue("fontOffset", m_options->fontOffset);
		settings.setValue("fontScaling", m_options->fontScaling);
		settings.setValue("lastfiles", openFiles);
		settings.setValue("lasttabindex", lastIndex);
	}
	else {
		settings.remove("");
	}
	settings.endGroup();
	settings.beginGroup("Run");
	if (!m_resetPrefs) {
		settings.setValue("useAPI", m_options->useAPI);
		settings.setValue("keyRepeat", m_options->keyRepeat);
		settings.setValue("debugLiveEvents", m_options->debugLiveEvents);
		settings.setValue("consoleBufferSize", m_options->consoleBufferSize);
		settings.setValue("midiInterface", m_options->midiInterface);
		settings.setValue("noBuffer", m_options->noBuffer);
		settings.setValue("noPython", m_options->noPython);
		settings.setValue("noMessages", m_options->noMessages);
		settings.setValue("noEvents", m_options->noEvents);
		settings.setValue("bufferSize", m_options->bufferSize);
		settings.setValue("bufferSizeActive", m_options->bufferSizeActive);
		settings.setValue("HwBufferSize",m_options->HwBufferSize);
		settings.setValue("HwBufferSizeActive", m_options->HwBufferSizeActive);
		settings.setValue("dither", m_options->dither);
		settings.setValue("newParser", m_options->newParser);
		settings.setValue("multicore", m_options->multicore);
		settings.setValue("numThreads", m_options->numThreads);

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
		settings.setValue("simultaneousRun", m_options->simultaneousRun);
		settings.setValue("sampleFormat", m_options->sampleFormat);
	}
	else {
		settings.remove("");
	}
	settings.endGroup();
	settings.beginGroup("Environment");
	if (!m_resetPrefs) {
		settings.setValue("csdocdir", m_options->csdocdir);
		settings.setValue("opcodedir",m_options->opcodedir);
		settings.setValue("opcodedirActive",m_options->opcodedirActive);
		settings.setValue("opcodedir64",m_options->opcodedir64);
		settings.setValue("opcodedir64Active",m_options->opcodedir64Active);
		settings.setValue("opcode6dir64",m_options->opcode6dir64);
		settings.setValue("opcode6dir64Active",m_options->opcode6dir64Active);
		settings.setValue("sadir",m_options->sadir);
		settings.setValue("sadirActive",m_options->sadirActive);
		settings.setValue("ssdir",m_options->ssdir);
		settings.setValue("ssdirActive",m_options->ssdirActive);
		settings.setValue("sfdir",m_options->sfdir);
		settings.setValue("sfdirActive",m_options->sfdirActive);
		settings.setValue("incdir",m_options->incdir);
		settings.setValue("incdirActive",m_options->incdirActive);
		settings.setValue("defaultCsd",m_options->defaultCsd);
		settings.setValue("defaultCsdActive",m_options->defaultCsdActive);
		settings.setValue("favoriteDir",m_options->favoriteDir);
		settings.setValue("pythonDir",m_options->pythonDir);
		settings.setValue("pythonExecutable",m_options->pythonExecutable);
		settings.setValue("csoundExecutable", m_options->csoundExecutable);
		settings.setValue("logFile",m_options->logFile);
		settings.setValue("sdkDir",m_options->sdkDir);
		settings.setValue("opcodexmldir", m_options->opcodexmldir);
		settings.setValue("opcodexmldirActive",m_options->opcodexmldirActive);
	}
	else {
		settings.remove("");
	}
	settings.endGroup();
	settings.beginGroup("External");
	if (!m_resetPrefs) {
		settings.setValue("terminal", m_options->terminal);
		settings.setValue("browser", m_options->browser);
		settings.setValue("dot", m_options->dot);
		settings.setValue("waveeditor", m_options->waveeditor);
		settings.setValue("waveplayer", m_options->waveplayer);
		settings.setValue("pdfviewer", m_options->pdfviewer);
	}
	else {
		settings.remove("");
	}
	settings.endGroup();
	settings.beginGroup("Template");
	settings.setValue("csdTemplate", m_options->csdTemplate);
	settings.endGroup();
	settings.endGroup();
}

void CsoundQt::clearSettings()
{
	QSettings settings("csound", "qutecsound");
	settings.remove("");
	settings.beginGroup("GUI");
	settings.beginGroup("Shortcuts");
	settings.remove("");
	settings.endGroup();
	settings.endGroup();
	settings.beginGroup("Options");
	settings.remove("");
	settings.beginGroup("Editor");
	settings.remove("");
	settings.endGroup();
	settings.beginGroup("Run");
	settings.remove("");
	settings.endGroup();
	settings.beginGroup("Environment");
	settings.remove("");
	settings.endGroup();
	settings.beginGroup("External");
	settings.remove("");
	settings.endGroup();
	settings.endGroup();
}

int CsoundQt::execute(QString executable, QString options)
{
	int ret;

#ifdef Q_OS_MAC
	QString commandLine = "open -a \"" + executable + "\" " + options;
#endif
#ifdef Q_OS_LINUX
	QString commandLine = "\"" + executable + "\" " + options;
#endif
#ifdef Q_OS_HAIKU
  QString commandLine = "\"" + executable + "\" " + options;
#endif
#ifdef Q_OS_SOLARIS
	QString commandLine = "\"" + executable + "\" " + options;
#endif
#ifdef Q_OS_WIN32
	QString commandLine = "\"" + executable + "\" " + (executable.startsWith("cmd")? " /k ": " ") + options;
	ret = !QProcess::startDetached(commandLine) ? 1: 0;
#else
	qDebug() << "CsoundQt::execute   " << commandLine << documentPages[curPage]->getFilePath();
	QProcess *p = new QProcess(this);
	p->setWorkingDirectory(documentPages[curPage]->getFilePath());
	p->start(commandLine);
	Q_PID id = p->pid();
	qDebug() << "Launched external program with id:" << id;
	ret = !p->waitForStarted() ? 1 : 0;
#endif
	return ret;
}

int CsoundQt::loadFileFromSystem(QString fileName)
{
	return loadFile(fileName,m_options->autoPlay);
}

int CsoundQt::loadFile(QString fileName, bool runNow)
{
	//  qDebug() << "CsoundQt::loadFile" << fileName;
	int index = isOpen(fileName);
	if (index != -1) {
		documentTabs->setCurrentIndex(index);
		changePage(index);
		statusBar()->showMessage(tr("File already open"), 10000);
		return index;
	}
	QFile file(fileName);
	if (!file.open(QFile::ReadOnly)) {
		QMessageBox::warning(this, tr("CsoundQt"),
							 tr("Cannot read file %1:\n%2.")
							 .arg(fileName)
							 .arg(file.errorString()));
		return -1;
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
	if (m_options->autoJoin) {
		QString companionFileName = fileName;
		if (fileName.endsWith(".orc")) {
			companionFileName = companionFileName.replace(".orc", ".sco");
			if (QFile::exists(companionFileName)) {
				text.prepend("<CsoundSynthesizer>\n<CsOptions>\n</CsOptions>\n<CsInstruments>\n");
				text += "\n</CsInstruments>\n<CsScore>\n";
				QFile companionFile(companionFileName);
				if (companionFile.open(QFile::ReadOnly)) {
					while (!companionFile.atEnd()) {
						QByteArray line = companionFile.readLine();
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
				}
				text += "</CsScore>\n</CsoundSynthesizer>\n";
			}
		}
		else if (fileName.endsWith(".sco")) {
			companionFileName = companionFileName.replace(".sco", ".orc");
			if (QFile::exists(companionFileName)) {
				QFile companionFlle(companionFileName);
				QString orcText = "";
				if (companionFlle.open(QFile::ReadOnly)) {
					while (!companionFlle.atEnd()) {
						QByteArray line = companionFlle.readLine();
						while (line.contains("\r\n")) {
							line.replace("\r\n", "\n");  //Change Win returns to line endings
						}
						while (line.contains("\r")) {
							line.replace("\r", "\n");  //Change Mac returns to line endings
						}
						QTextDecoder decoder(QTextCodec::codecForLocale());
						orcText = orcText + decoder.toUnicode(line);
						if (!line.endsWith("\n"))
							orcText += "\n";
					}
				}
				text.prepend("\n</CsInstruments>\n<CsScore>\n");
				text.prepend(orcText);
				text.prepend("<CsoundSynthesizer>\n<CsOptions>\n</CsOptions>\n<CsInstruments>\n");
				text += "</CsScore>\n</CsoundSynthesizer>\n";
			}
		}
	}
    //else {
    //    loadCompanionFile(fileName); // If here and autojoin unchecked and you open an sco or orc, it falls to endless loop loadFile<->loadCompanionFile
    //}

	if (fileName == ":/default.csd")
		fileName = QString("");

	makeNewPage(fileName, text);
    if (!m_options->autoJoin && (fileName.endsWith(".sco") || fileName.endsWith(".orc")) ) { // load companion, when the new page is made, otherwise isOpen works uncorrect
        loadCompanionFile(fileName);
    }
	if (!m_options->autoJoin) {
		documentPages[curPage]->setModified(false);
		setWindowModified(false);
		documentTabs->setTabIcon(curPage, QIcon());
	}
	else {
		if (fileName.endsWith(".sco") || fileName.endsWith(".orc")) {
			fileName.chop(4);
			fileName +=  ".csd";
			documentPages[curPage]->setFileName(fileName);  // Must update internal name
			setCurrentFile(fileName);
			if (!QFile::exists(fileName)) {
				save();
			}
			else {
				saveAs();
			}
		}
		else {
			documentPages[curPage]->setModified(false);
			setWindowModified(false);
			documentTabs->setTabIcon(curPage, QIcon());
		}
	}
	if (fileName.startsWith(m_options->csdocdir)) {
		documentPages[curPage]->readOnly = true;
	}
	QApplication::restoreOverrideCursor();
	statusBar()->showMessage(tr("File loaded"), 2000);

	// FIXME put back
	//  widgetPanel->clearHistory();
	if (runNow) {
		play();
	}
	return curPage;
}

void CsoundQt::makeNewPage(QString fileName, QString text)
{
	DocumentPage *newPage = new DocumentPage(this, m_opcodeTree, &m_configlists);
	int insertPoint = curPage + 1;
	curPage += 1;
	if (documentPages.size() == 0) {
		insertPoint = 0;
		curPage = 0;
	}
	documentPages.insert(insertPoint, newPage);
	//  documentPages[curPage]->setOpcodeNameList(m_opcodeTree->opcodeNameList());
	documentPages[curPage]->showLiveEventPanels(false);
	setCurrentOptionsForPage(documentPages[curPage]);

	documentPages[curPage]->setFileName(fileName);  // Must set before sending text to set highlighting mode
#ifdef QCS_PYTHONQT
	documentPages[curPage]->getEngine()->setPythonConsole(m_pythonConsole);
#endif

	connectActions();
//	connect(documentPages[curPage], SIGNAL(currentTextUpdated()), this, SLOT(markInspectorUpdate()));
//	connect(documentPages[curPage], SIGNAL(modified()), this, SLOT(documentWasModified()));
//	connect(documentPages[curPage], SIGNAL(currentLineChanged(int)), this, SLOT(displayLineNumber(int)));
//	//  connect(documentPages[curPage], SIGNAL(setWidgetClipboardSignal(QString)),
//	//          this, SLOT(setWidgetClipboard(QString)));
//	connect(documentPages[curPage], SIGNAL(setCurrentAudioFile(QString)),
//			this, SLOT(setCurrentAudioFile(QString)));
//	connect(documentPages[curPage], SIGNAL(evaluatePythonSignal(QString)),
//			this, SLOT(evaluatePython(QString)));
	connect(documentPages[curPage]->getView(), SIGNAL(lineNumberSignal(int)),
			this, SLOT(displayLineNumber(int)));
	
	documentPages[curPage]->loadTextString(text);
	if (m_options->widgetsIndependent) {
//		documentPages[curPage]->setWidgetLayoutOuterGeometry(documentPages[curPage]->getWidgetLayoutOuterGeometry());
		documentPages[curPage]->getWidgetLayout()->setGeometry(documentPages[curPage]->getWidgetLayoutOuterGeometry());
	}
//	setWidgetPanelGeometry();

	if (!fileName.startsWith(":/")) {  // Don't store internal examples in recents menu
		lastUsedDir = fileName;
		lastUsedDir.resize(fileName.lastIndexOf(QRegExp("[/]")) + 1);
	}
	if (recentFiles.count(fileName) == 0 && fileName!="" && !fileName.startsWith(":/")) {
		recentFiles.prepend(fileName);
		if (recentFiles.size() > QCS_MAX_RECENT_FILES)
			recentFiles.removeLast();
		fillFileMenu();
	}
	documentTabs->insertTab(curPage, documentPages[curPage]->getView(),"");
	documentTabs->setCurrentIndex(curPage);
}

bool CsoundQt::loadCompanionFile(const QString &fileName)
{
	QString companionFileName = fileName;
	if (fileName.endsWith(".orc")) {
		companionFileName.replace(".orc", ".sco");
	}
	else if (fileName.endsWith(".sco")) {
		companionFileName.replace(".sco", ".orc");
	}
	else {
		return false;
	}
	if (QFile::exists(companionFileName)) {
		return (loadFile(companionFileName) != -1);
	}
	return false;
}

bool CsoundQt::saveFile(const QString &fileName, bool saveWidgets)
{
	//  qDebug("CsoundQt::saveFile");
	QString text;
	QApplication::setOverrideCursor(Qt::WaitCursor);
	if (!m_options->widgetsIndependent) { // Update outer geometry information for writing
		QWidget *s = widgetPanel->widget();
//			widgetPanel->applySize(); //Store size of outer panel as size of widget
		if (s != 0) {
			QRect panelGeometry = widgetPanel->geometry();
			if (!widgetPanel->isFloating()) {
				panelGeometry.setX(-1);
				panelGeometry.setY(-1);
			}
			documentPages[curPage]->setWidgetLayoutOuterGeometry(panelGeometry);
		} else {
			documentPages[curPage]->setWidgetLayoutOuterGeometry(QRect());
		}
	}
	if (m_options->saveWidgets && saveWidgets)
		text = documentPages[curPage]->getFullText();
	else
		text = documentPages[curPage]->getBasicText();
	QApplication::restoreOverrideCursor();

	if (fileName != documentPages[curPage]->getFileName()) {
		documentPages[curPage]->setFileName(fileName);
		setCurrentFile(fileName);
	}
	lastUsedDir = fileName;
	lastUsedDir.resize(fileName.lastIndexOf("/") + 1);
	if (recentFiles.count(fileName) == 0) {
		recentFiles.prepend(fileName);
		recentFiles.removeLast();
		fillFileMenu();
	}
	QFile file(fileName);
	if (!file.open(QFile::WriteOnly | QFile::Text)) {
		QMessageBox::warning(this, tr("Application"),
							 tr("Cannot write file %1:\n%2.")
							 .arg(fileName)
							 .arg(file.errorString()));
		return false;
	}

	QTextStream out(&file);
	out << text;
	documentPages[curPage]->setModified(false);
	setWindowModified(false);
	documentTabs->setTabIcon(curPage, QIcon());
	statusBar()->showMessage(tr("File saved"), 2000);
	return true;
}

void CsoundQt::setCurrentFile(const QString &fileName)
{
	QString shownName;
	if (fileName.isEmpty())
		shownName = "untitled.csd";
	else
		shownName = strippedName(fileName);

	setWindowTitle(tr("%1[*] - %2").arg(shownName).arg(tr("CsoundQt")));
	documentTabs->setTabText(curPage, shownName);
	//  updateWidgets();
}

QString CsoundQt::strippedName(const QString &fullFileName)
{
	return QFileInfo(fullFileName).fileName();
}

QString CsoundQt::generateScript(bool realtime, QString tempFileName, QString executable)
{
#ifndef Q_OS_WIN32
	QString script = "#!/bin/sh\n";
#else
	QString script = "";
#endif
	QString cmdLine = "";
	// Only OPCODEDIR left here as it must be present before csound initializes
	// The problem is that it can't be passed when using the API...
#ifdef USE_DOUBLE
	if (m_options->opcodedir64Active)
		script += "export OPCODEDIR64=" + m_options->opcodedir64 + "\n";
	if (m_options->opcode6dir64Active)
		script += "export OPCODE6DIR64=" + m_options->opcode6dir64 + "\n";
#else
	if (m_options->opcodedirActive)
		script += "export OPCODEDIR=" + m_options->opcodedir + "\n";
#endif

#ifndef Q_OS_WIN32
	script += "cd " + QFileInfo(documentPages[curPage]->getFileName()).absolutePath() + "\n";
#else
	QString script_cd = "@pushd " + QFileInfo(documentPages[curPage]->getFileName()).absolutePath() + "\n";
	script_cd.replace("/", "\\");
	script += script_cd;
#endif

	if (executable.isEmpty()) {
		cmdLine = m_options->csoundExecutable+ " ";
		qDebug()<<cmdLine;
//#ifdef Q_OS_MAC
//		cmdLine = "/usr/local/bin/csound ";
//#else
//		cmdLine = "csound ";
//#endif
		m_options->rt = (realtime and m_options->rtUseOptions)
				or (!realtime and m_options->fileUseOptions);
		cmdLine += m_options->generateCmdLineFlags() + " ";
	}
	else {
		cmdLine = executable + " ";
	}

	if (tempFileName == ""){
		QString fileName = documentPages[curPage]->getFileName();
		if (documentPages[curPage]->getCompanionFileName() != "") {
			QString companionFile = documentPages[curPage]->getCompanionFileName();
			if (fileName.endsWith(".orc"))
				cmdLine += "\""  + fileName
						+ "\" \""+ companionFile + "\" ";
			else
				cmdLine += "\""  + companionFile
						+ "\" \""+ fileName + "\" ";
		}
		else if (fileName.endsWith(".csd",Qt::CaseInsensitive)) {
			cmdLine += "\""  + fileName + "\" ";
		}
	}
	else {
		cmdLine += "\""  + tempFileName + "\" ";
	}
	//  m_options->rt = (realtime and m_options->rtUseOptions)
	//                  or (!realtime and m_options->fileUseOptions);
	//  cmdLine += m_options->generateCmdLineFlags();
	script += "echo \"" + cmdLine + "\"\n";
	script += cmdLine + "\n";

#ifndef Q_OS_WIN32
	script += "echo \"\nPress return to continue\"\n";
	script += "dummy_var=\"\"\n";
	script += "read dummy_var\n";
	script += "rm $0\n";
#else
	script += "@echo.\n";
	script += "@pause\n";
	script += "@exit\n";
#endif
	return script;
}

void CsoundQt::getCompanionFileName()
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
	if (documentPages[curPage]->getFileName().endsWith(".orc"))
		extensionComplement = ".sco";
	else if (documentPages[curPage]->getFileName().endsWith(".sco"))
		extensionComplement = ".orc";
	else if (documentPages[curPage]->getFileName().endsWith(".udo"))
		extensionComplement = ".csd";
	else if (documentPages[curPage]->getFileName().endsWith(".inc"))
		extensionComplement = ".csd";

	for (int i = 0; i < documentPages.size(); i++) {
		QString name = documentPages[i]->getFileName();
		if (name.endsWith(extensionComplement))
			list->addItem(name);
	}
	QList<QListWidgetItem *> itemList = list->findItems(
				documentPages[curPage]->getCompanionFileName(),
				Qt::MatchExactly);
	if (itemList.size() > 0)
		list->setCurrentItem(itemList[0]);
	dialog.exec();
	QListWidgetItem *item = list->currentItem();
	QString itemText = item->text();
	if (checkbox->isChecked())
		documentPages[curPage]->askForFile = false;
	documentPages[curPage]->setCompanionFileName(itemText);
	for (int i = 0; i < documentPages.size(); i++) {
		if (documentPages[i]->getFileName() == documentPages[curPage]->getCompanionFileName()
				&& !documentPages[i]->getFileName().endsWith(".csd")) {
			documentPages[i]->setCompanionFileName(documentPages[curPage]->getFileName());
			documentPages[i]->askForFile = documentPages[curPage]->askForFile;
			break;
		}
	}
}

void CsoundQt::setWidgetPanelGeometry()
{
	QRect geometry = documentPages[curPage]->getWidgetLayoutOuterGeometry();
//	qDebug() << "CsoundQt::setWidgetPanelGeometry() " << geometry;
	if (geometry.width() <= 0 || geometry.width() > 4096) {
		geometry.setWidth(400);
		qDebug() << "CsoundQt::setWidgetPanelGeometry() Warning: width invalid.";
	}
	if (geometry.height() <= 0 || geometry.height() > 4096) {
		geometry.setHeight(300);
		qDebug() << "CsoundQt::setWidgetPanelGeometry() Warning: height invalid.";
	}
	if (geometry.x() < 0 || geometry.x() > 4096) {
		geometry.setX(20);
		qDebug() << "CsoundQt::setWidgetPanelGeometry() Warning: X position invalid.";
	}
	if (geometry.y() < 0 || geometry.y() > 4096) {
		geometry.setY(0);
		qDebug() << "CsoundQt::setWidgetPanelGeometry() Warning: Y position invalid.";
	}
//	qDebug() << "geom " << widgetPanel->geometry() << " frame " << widgetPanel->frameGeometry();
	widgetPanel->setGeometry(geometry);
}

int CsoundQt::isOpen(QString fileName)
{
	int open = -1;
	int i = 0;
	for (i = 0; i < documentPages.size(); i++) {
		if (documentPages[i]->getFileName() == fileName) {
			open = i;
			break;
		}
	}
	return open;
}

//void *CsoundQt::getCurrentCsound()
//{
//  return (void *)documentPages[curCsdPage]->getCsound();
//}

QString CsoundQt::setDocument(int index)
{
	QString name = QString();
	if (index < documentTabs->count() && index >= 0) {
		documentTabs->setCurrentIndex(index);
		name = documentPages[index]->getFileName();
	}
	return name;
}

void CsoundQt::insertText(QString text, int index, int section)
{
	if (index == -1) {
		index = curPage;
	}
	if (section == -1) {
		if (index < documentTabs->count() && index >= 0) {
			documentPages[index]->insertText(text);
		}
	}
	else {
		qDebug() << "CsoundQt::insertText not implemented for sections";
	}
}

void CsoundQt::setCsd(QString text, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setBasicText(text);
	}
}

void CsoundQt::setFullText(QString text, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setFullText(text);
	}
}

void CsoundQt::setOrc(QString text, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setOrc(text);
	}
}

void CsoundQt::setSco(QString text, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setSco(text);
	}
}

void CsoundQt::setWidgetsText(QString text, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setWidgetsText(text);
	}
}

void CsoundQt::setPresetsText(QString text, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setPresetsText(text);
	}
}

void CsoundQt::setOptionsText(QString text, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setOptionsText(text);
	}
}

int CsoundQt::getDocument(QString name)
{
	int index = curPage;
	if (!name.isEmpty()) {
		index = -1;
		for (int i = 0; i < documentPages.size(); i++) {
			QString fileName = documentPages[i]->getFileName();
			QString relName = fileName.mid(fileName.lastIndexOf("/")+1);
			if (name == fileName  || name == relName  ) {
				index = i;
				break;
			}
		}
	}
	return index;
}

QString CsoundQt::getSelectedText(int index, int section)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getSelectedText(section);
	}
	return text;
}

QString CsoundQt::getCsd(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getBasicText();
	}
	return text;
}

QString CsoundQt::getFullText(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getFullText();
	}
	return text;
}

QString CsoundQt::getOrc(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getOrc();
	}
	return text;
}

QString CsoundQt::getSco(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getSco();
	}
	return text;
}

QString CsoundQt::getWidgetsText(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getWidgetsText();
	}
	return text;
}

QString CsoundQt::getSelectedWidgetsText(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getSelectedWidgetsText();
	}
	return text;
}

QString CsoundQt::getPresetsText(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getPresetsText();
	}
	return text;
}

QString CsoundQt::getOptionsText(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getOptionsText();
	}
	return text;
}

QString CsoundQt::getFileName(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getFileName();
	}
	return text;
}

QString CsoundQt::getFilePath(int index)
{
	QString text = QString();
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		text = documentPages[index]->getFilePath();
	}
	return text;
}



void CsoundQt::setChannelValue(QString channel, double value, int index)
{

	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setChannelValue(channel, value);
	}
}

double CsoundQt::getChannelValue(QString channel, int index)
{
	double value = 0.0;
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		value = documentPages[index]->getChannelValue(channel);
	}
	return value;
}

void CsoundQt::setChannelString(QString channel, QString value, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setChannelString(channel, value);
	}
}

QString CsoundQt::getChannelString(QString channel, int index)
{
	QString value = "";
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		value = documentPages[index]->getChannelString(channel);
	}
	return value;
}

void CsoundQt::setWidgetProperty(QString widgetid, QString property, QVariant value, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		documentPages[index]->setWidgetProperty(widgetid, property, value);
	}
}

QVariant CsoundQt::getWidgetProperty(QString widgetid, QString property, int index)
{
	QVariant value;
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		value = documentPages[index]->getWidgetProperty(widgetid, property);
	}
	return value;
}


QString CsoundQt::createNewLabel(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewLabel(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewDisplay(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewDisplay(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewScrollNumber(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewScrollNumber(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewLineEdit(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewLineEdit(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewSpinBox(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewSpinBox(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewSlider(int x, int y, QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewSlider(x,y, channel);
	}
	return QString();
}

QString CsoundQt::createNewButton(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewButton(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewKnob(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewKnob(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewCheckBox(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewCheckBox(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewMenu(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewMenu(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewMeter(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewMeter(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewConsole(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewConsole(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewGraph(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewGraph(x,y,channel);
	}
	return QString();
}

QString CsoundQt::createNewScope(int x , int y , QString channel, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->createNewScope(x,y,channel);
	}
	return QString();
}

QStringList CsoundQt::getWidgetUuids(int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->getWidgetUuids();
	}
	return QStringList();
}

QStringList CsoundQt::listWidgetProperties(QString widgetid, int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->listWidgetProperties(widgetid);
	}
	return QStringList();
}

bool CsoundQt::destroyWidget(QString widgetid,int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->destroyWidget(widgetid);
	}
	return false;
}

EventSheet* CsoundQt::getSheet(int index, int sheetIndex)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->getSheet(sheetIndex);
	}
	else {
		return NULL;
	}
}

CsoundEngine *CsoundQt::getEngine(int index)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->getEngine();
	}
	else {
		return NULL;
	}
}

EventSheet* CsoundQt::getSheet(int index, QString sheetName)
{
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->getSheet(sheetName);
	}
	else {
		return NULL;
	}
}

//void CsoundQt::newCurve(Curve * curve)
//{
//  newCurveBuffer.append(curve);
//}
//

void CsoundQt::loadPreset(int preSetIndex, int index) {
	if (index == -1) {
		index = curPage;
	}
	if (index < documentTabs->count() && index >= 0) {
		return documentPages[index]->loadPreset(preSetIndex);
	}
	else {
		return;
	}
}
