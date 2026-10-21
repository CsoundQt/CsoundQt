
/*
	Copyright (C) 2008-2010 Andres Cabrera
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

#include <cwindow.h>
#include <csound.hpp>  // TODO These two are necessary for the WINDAT struct. Can they be moved?


#include "documentpage.h"
#include "documentview.h"
#include "csoundengine.h"
#include "csoundqt.h" // For playParent and renderParent functions (called from button
                        // reserved channels) and for connecting from console to log file
#include "opentryparser.h"
#include "types.h"
#include "highlighter.h"
#include "widgetlayout.h"
#include "console.h"
#include "midilearndialog.h"
#include "qutebutton.h"
#include "notification.h"

#include <QMessageBox>

// TODO is is possible to move the editor to a separate child class, to be able to use a cleaner class?
DocumentPage::DocumentPage(QWidget *parent, OpEntryParser *opcodeTree,
                           ConfigLists *configlists, MidiLearnDialog *midiLearn):
	BaseDocument(parent, opcodeTree, configlists)
{
	init(parent, opcodeTree);
	m_view->showLineArea(true);
	m_midiLearn = midiLearn;
    m_colorTheme = "";
    m_parseUdosNeeded = true;
	foreach(WidgetLayout* wl, m_widgetLayouts) {
		connect(wl, SIGNAL(changed()), this, SLOT(setModified()));
        connect(wl, SIGNAL(widgetSelectedSignal(QuteWidget*)),
                this, SLOT(passSelectedWidget(QuteWidget*)));
        connect(wl, SIGNAL(widgetUnselectedSignal(QuteWidget*)),
                this, SLOT(passUnselectedWidget(QuteWidget*)));
		connect(wl,SIGNAL(showMidiLearn(QuteWidget*)),this, SLOT(showMidiLearn(QuteWidget*)));
	}
}

DocumentPage::~DocumentPage()
{
	//  qDebug();
	disconnect(m_console, 0,0,0);
	disconnect(m_view, 0,0,0);
	//  deleteAllLiveEvents(); // FIXME This is also crashing...
}

void DocumentPage::setCompanionFileName(QString name)
{
	companionFile = name;
}

void DocumentPage::loadTextString(QString &text)
{
	setTextString(text);
	m_view->clearUndoRedoStack();
}

void DocumentPage::toggleLineArea()
{
	m_view->toggleLineArea();
}

void DocumentPage::toggleParameterMode()
{
	m_view->toggleParameterMode();
}

//void DocumentPage::showParametersInEditor()
//{
//	m_view->parameterShowShortcutPressed();
//}

int DocumentPage::setTextString(QString &text)
{
	int ret = 0;
	if (!fileName.endsWith(".csd") && !fileName.isEmpty()) {
        // Put all text since not a csd file (and not default file which has no name)
        m_view->setFullText(text, true);
		m_view->setModified(false);
		return ret;
	}
    // auto t0 = std::chrono::high_resolution_clock::now();
    parseAndRemoveWidgetText(text);
    // auto t1 = std::chrono::high_resolution_clock::now();
    // auto diff = std::chrono::duration<double, std::milli>(t1-t0).count();
    // QDEBUG << "parseAndRemoveWidgetText:" << diff << "ms";

    // This must be last as some of the text has been removed along the way
    m_view->setFullText(text,true);
    m_view->setModified(false);
    // This ensures that modifications triggered later by the maineditor
    // do not set the modified status of the page when a file is first
    // loaded
    // auto t2 = std::chrono::high_resolution_clock::now();
    // QDEBUG << "finished parsing in (ms)" <<
    //          std::chrono::duration<double, std::milli>(t2-t1).count();
    // QTimer::singleShot(1000, this, [this](){this->setModified(false);});
	return ret;
}

void DocumentPage::setEditorFocus()
{
	m_view->setFocus();
}

void DocumentPage::showLineNumbers(bool show)
{
	m_view->showLineArea(show);
}

void DocumentPage::setLineNumberContrast(int contrast)
{
	m_view->setLineNumberContrast(contrast);
}

void DocumentPage::setEditorPadding(int padding)
{
	m_view->setEditorPadding(padding);
}

void DocumentPage::insertText(QString text, int section)
{
	return m_view->insertText(text, section);
}

void DocumentPage::insertPathAtCursor(const QString &path)
{
	return m_view->insertPathAtCursor(path);
}

void DocumentPage::insertOrchestraGlobal(QString text)
{
	return m_view->insertOrchestraGlobal(text);
}

void DocumentPage::insertAtScoreStart(QString text)
{
	return m_view->insertAtScoreStart(text);
}

void DocumentPage::setFullText(QString text)
{
	return m_view->setFullText(text);
}

void DocumentPage::setBasicText(QString text)
{
	return m_view->setBasicText(text);
}

void DocumentPage::setOrc(QString text)
{
	return m_view->setOrc(text);
}

void DocumentPage::setSco(QString text)
{
	return m_view->setSco(text);
}

void DocumentPage::setWidgetsText(QString text)
{
	// TODO support multiple layouts
    qDebug() << "DocumentPage. calling loadXmlWidgets";
	return m_widgetLayouts.at(0)->loadXmlWidgets(text);
}

void DocumentPage::setPresetsText(QString text)
{
	// TODO support multiple layouts
	return m_widgetLayouts.at(0)->loadXmlPresets(text);
}

void DocumentPage::setOptionsText(QString text)
{
	m_view->setOptionsText(text);
}

QString DocumentPage::getFullText()
{
	QString fullText = BaseDocument::getFullText();
/*
    QString liveEventsText = "";
	if (saveLiveEvents) { // Only add live events sections if file is a csd file
		for (int i = 0; i < m_liveFrames.size(); i++) {
			liveEventsText += m_liveFrames[i]->getPlainText();
			//        qDebug() << panel;
		}
		fullText += liveEventsText;
	}
*/
	// Always write Unix line endings; reading normalizes CRLF/CR to LF.
    fullText.replace("\r\r\n", "\r\n");
    fullText.replace("\r\n", "\n");
    fullText.replace("\r", "\n");
	return fullText;
}

QString DocumentPage::getSelectedText(int section)
{
	QString text = m_view->getSelectedText(section);
	return text;
}

QString DocumentPage::getSelectedWidgetsText()
{
	//FIXME allow multiple
	QString text = m_widgetLayouts[0]->getSelectedWidgetsText();
	return text;
}

QString DocumentPage::getHtmlText()
{
    QString fullText = BaseDocument::getFullText();
    // does windows need /r/n replacemant? then probably this.getFullText();
	// get the <html> </html> element:
	QString::SectionFlags sectionflags = QString::SectionIncludeLeadingSep |
					QString::SectionIncludeTrailingSep | QString::SectionCaseInsensitiveSeps;
	QString element = fullText.section("<html", 1, 1, sectionflags);
	element = element.section("</html>", 0, 0, sectionflags);
	return element;

}

int DocumentPage::getViewMode()
{
	return m_view->getViewMode();
}


QString DocumentPage::wordUnderCursor()
{
	return m_view->wordUnderCursor();
}

QString DocumentPage::lineUnderCursor() {
    return m_view->lineUnderCursor();
}

QRect DocumentPage::getWidgetLayoutOuterGeometry()
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->getOuterGeometry();
}

void DocumentPage::setWidgetLayoutOuterGeometry(QRect r)
{
	m_widgetLayouts[0]->setOuterGeometry(r);
}

void DocumentPage::setChannelValue(QString channel, double value)
{
	for (int i = 0; i < m_widgetLayouts.size(); i++) {
        m_widgetLayouts[i]->newValue(QPair<QString,double>(channel, value));
	}
}

double DocumentPage::getChannelValue(QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->getValueForChannel(channel);
}

void DocumentPage::setChannelString(QString channel, QString value)
{
	for (int i = 0; i < m_widgetLayouts.size(); i++) {
		m_widgetLayouts[i]->newValue(QPair<QString,QString>(channel, value));
	}
}

QString DocumentPage::getChannelString(QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->getStringForChannel(channel);
}

void DocumentPage::setWidgetProperty(QString widgetid, QString property, QVariant value)
{
	for (int i = 0; i < m_widgetLayouts.size(); i++) {
		m_widgetLayouts[i]->setWidgetProperty(widgetid, property, value);
	}
}

QVariant DocumentPage::getWidgetProperty(QString widgetid, QString property)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->getWidgetProperty(widgetid, property);
}


QStringList DocumentPage::getWidgetUuids()
{   QStringList uuids = QStringList();
	for (int i = 0; i < m_widgetLayouts.size(); i++) {
		uuids <<  m_widgetLayouts[i]->getUuids();  // add up all widgets from all layouts
	}
	return uuids;
}

bool DocumentPage::destroyWidget(QString widgetid)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->destroyWidget(widgetid);

}

QStringList DocumentPage::listWidgetProperties(QString widgetid)
{
    // widgetid can be eihter uuid (prefered) or channel
	//FIXME allow multiple
	return m_widgetLayouts[0]->listProperties(widgetid);
}


void DocumentPage::loadPreset(int preSetIndex) {
	//FIXME allow multiple
	return m_widgetLayouts[0]->loadPresetFromIndex(preSetIndex);
}

QString DocumentPage::createNewLabel(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewLabel(x, y, channel);
}

QString DocumentPage::createNewDisplay(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewDisplay(x, y, channel);
}

QString DocumentPage::createNewScrollNumber(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewScrollNumber(x, y, channel);
}

QString DocumentPage::createNewLineEdit(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewLineEdit(x, y, channel);
}

QString DocumentPage::createNewSpinBox(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewSpinBox(x, y, channel);
}

QString DocumentPage::createNewSlider(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewSlider(x, y, channel);
}

QString DocumentPage::createNewButton(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewButton(x, y, channel);
}

QString DocumentPage::createNewKnob(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewKnob(x, y, channel);
}

QString DocumentPage::createNewCheckBox(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewCheckBox(x, y, channel);
}

QString DocumentPage::createNewMenu(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewMenu(x, y, channel);
}

QString DocumentPage::createNewMeter(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewMeter(x, y, channel);
}

QString DocumentPage::createNewConsole(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewConsole(x, y, channel);
}

QString DocumentPage::createNewGraph(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewGraph(x, y, channel);
}

QString DocumentPage::createNewScope(int x, int y, QString channel)
{
	//FIXME allow multiple
	return m_widgetLayouts[0]->createNewScope(x, y, channel);
}

int DocumentPage::lineCount(bool countExtras)
{
	QString text;
	if (countExtras) {
		text = this->getBasicText();
	}
	else
	{
		text = this->getFullText();
	}
	return text.count("\n");
}

int DocumentPage::characterCount(bool countExtras)
{
	QString text;
	if (countExtras) {
		text = this->getBasicText();
	}
	else
	{
		text = this->getFullText();
	}
	return text.size();
}

int DocumentPage::instrumentCount()
{
	QString text = this->getBasicText();
    static const  QRegularExpression instrRegex("\\n[ \\t]*instr\\s");
    return text.count(instrRegex);
}

int DocumentPage::udoCount()
{
	QString text = this->getBasicText();
    static const  QRegularExpression opcodeRegex("\\n[ \\t]*opcode\\s");
    return text.count(opcodeRegex);
}

int DocumentPage::widgetCount()
{
	QString text = this->getWidgetsText();
	return text.count("<bsbObject");
}

QString DocumentPage::embeddedFiles()
{
	QString text = m_view->getFileB();
	return QString::number(text.count("<CsFileB "));
}

QString DocumentPage::getFilePath()
{
	return fileName.left(fileName.lastIndexOf("/"));
}

void DocumentPage::setModified(bool mod)
{
	// This slot is triggered by the document children whenever they are modified
	// It is also called from the main application when the file is saved to set as unmodified.
	// FIXME live frame modification should also affect here
    // qDebug() << "DocumentPage::setModified :" << mod;
    if (mod == true) {
        emit modified();
	}
	else {
        emit unmodified();
		m_view->setModified(false);
		foreach (WidgetLayout  *wl, m_widgetLayouts) {
			wl->setModified(false);
		}
	}
}

void DocumentPage::sendCodeToEngine(QString code)
{
	m_csEngine->evaluate(code);
}

bool DocumentPage::isModified()
{
    if (m_view->isModified()) {
        return true;
    }
	foreach (WidgetLayout *wl, m_widgetLayouts) {
        if (wl->isModified()) {
            return true;
        }
	}
	return false;
}

bool DocumentPage::isRunning()
{
	// TODO what to do with pause?
	return m_csEngine->isRunning();
}

bool DocumentPage::isRecording()
{
	// TODO what to do with pause?
	return m_csEngine->isRecording();
}

bool DocumentPage::usesFltk()
{
	return m_view->getBasicText().contains("FLpanel");
}

QString DocumentPage::getQml()
{
    QString qml = m_widgetLayouts[0]->getQml();
	return qml;
}

QString DocumentPage::getMidiControllerInstrument()
{
	return m_widgetLayouts[0]->getMidiControllerInstrument();
}

void DocumentPage::focusWidgets()
{
	//FIXME allow multiple
	//TODO is this really required?
	m_widgetLayouts[0]->setFocus();
}

QString DocumentPage::getFileName()
{
	return fileName;
}

QString DocumentPage::getCompanionFileName()
{
	return companionFile;
}

void DocumentPage::copy()
{
    qDebug() << m_widgetLayouts[0]->hasFocus();

    if (m_view->childHasFocus()) {
        m_view->copy();
    }
    else  { // FIXME allow multiple layouts
        m_widgetLayouts[0]->copy();
    }

}

void DocumentPage::cut()
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		if (wl->hasFocus()) {
			wl->cut();
			return;
		}
	}
	if (m_view->childHasFocus()) {
		m_view->cut();
    }
}

void DocumentPage::paste()
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		if (wl->hasFocus()) {
			wl->paste();
			return;
		}
	}
	if (m_view->childHasFocus()) {
		m_view->paste();
	}
}

void DocumentPage::undo()
{
	//  qDebug()";
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		if (wl->hasFocus()) {
			wl->undo();
			wl->setFocus(Qt::OtherFocusReason);  // Why is this here?
			return;
		}
	}
	if (m_view->childHasFocus()) {
		m_view->undo();
    }
}

void DocumentPage::redo()
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		if (wl->hasFocus()) {
			wl->redo();
			wl->setFocus(Qt::OtherFocusReason);  // Why is this here?
			return;
		}
	}
	if (m_view->childHasFocus())
		m_view->redo();
}

void DocumentPage::gotoNextRow()
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		if (wl->hasFocus()) {
			wl->redo();
			wl->setFocus(Qt::OtherFocusReason);  // Why is this here?
			return;
		}
	}
    if (m_view->childHasFocus()) {
		m_view->gotoNextLine();
	}
}


DocumentView *DocumentPage::getView()
{
	Q_ASSERT(m_view != 0);
	return m_view;
}

void DocumentPage::setTextFont(QFont font)
{
	m_view->setFont(font);

}

void DocumentPage::setTabSize(int tabSize)
{
	m_view->setTabSize(tabSize);
}

void DocumentPage::setTabUseSpaces(bool useSpaces)
{
	m_view->setTabUseSpaces(useSpaces);
}

void DocumentPage::setTabSpaces(int spaces)
{
	m_view->setTabSpaces(spaces);
}

void DocumentPage::setLineWrapMode(QTextEdit::LineWrapMode wrapLines)
{
	m_view->setLineWrapMode(wrapLines);
}

void DocumentPage::setColorVariables(bool colorVariables)
{
	m_view->setColorVariables(colorVariables);
}

void DocumentPage::setAutoComplete(bool autoComplete, int delay)
{
    m_view->setAutoComplete(autoComplete, delay);
}

void DocumentPage::setAutoCompleteMenuWidth(int width)
{
    m_view->setAutoCompleteMenuWidth(width);
}

void DocumentPage::setAutoParameterMode(bool autoParameterMode)
{
	m_view->setAutoParameterMode(autoParameterMode);
}

QString DocumentPage::getActiveSection()
{
	return m_view->getActiveSection();
}

QString DocumentPage::getActiveText()
{
	return m_view->getActiveText();
}

void DocumentPage::print(QPrinter *printer)
{
	m_view->print(printer);
}

void DocumentPage::findReplace()
{
	m_view->findReplace();
}

void DocumentPage::findString()
{
	m_view->findString();
}

void DocumentPage::findPrevious()
{
	m_view->findPrevious();
}

void DocumentPage::getToIn()
{
	m_view->getToIn();
}

void DocumentPage::inToGet()
{
	m_view->inToGet();
}

void DocumentPage::showWidgetTooltips(bool visible)
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->showWidgetTooltips(visible);
	}
}

void DocumentPage::setKeyRepeatMode(bool keyRepeat)
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setKeyRepeatMode(keyRepeat);
	}
	m_console->setKeyRepeatMode(keyRepeat);
}

void DocumentPage::setOpenProperties(bool open)
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setProperty("openProperties", open);
	}
}

void DocumentPage::setFontOffset(double offset)
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setFontOffset(offset);
	}
}

void DocumentPage::setFontScaling(double offset)
{
    foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setFontScaling(offset);
	}
}

void DocumentPage::setGraphUpdateRate(int rate) {
    foreach (WidgetLayout *wl, m_widgetLayouts) {
        wl->setUpdateRate(rate);
    }
}

void DocumentPage::setConsoleFont(QFont font)
{
	m_console->setDefaultFont(font);
}

void DocumentPage::setConsoleColors(QColor fontColor, QColor bgColor)
{
	m_console->setColors(fontColor, bgColor);
}

void DocumentPage::setEditorColors(QColor text, QColor bg) {
    this->setProperty("textColor", text);
    this->setProperty("backgroundColor", bg);
    m_view->setColors(text, bg);
}

void DocumentPage::setConsoleBufferSize(int size)
{
	m_csEngine->setConsoleBufferSize(size);
}

void DocumentPage::setWidgetEnabled(bool enabled)
{
	// TODO disable widgetLayout if its not being used?
	//  m_widgetLayout->setEnabled(enabled);
	m_csEngine->enableWidgets(enabled);
}

void DocumentPage::registerButton(QuteButton *b)
{
	//  qDebug();
	connect(b, SIGNAL(play()), static_cast<CsoundQt *>(parent()), SLOT(play()));
	connect(b, SIGNAL(render()), static_cast<CsoundQt *>(parent()), SLOT(render()));
	connect(b, SIGNAL(pause()), static_cast<CsoundQt *>(parent()), SLOT(pause()));
	connect(b, SIGNAL(stop()), static_cast<CsoundQt *>(parent()), SLOT(stop()));
}

void DocumentPage::queueMidiIn(std::vector< unsigned char > *message)
{
    WidgetLayout *d = m_widgetLayouts[0];
    unsigned int nBytes = message->size();
    if (nBytes > 3 || nBytes < 1) {
        qDebug() << "MIDI message ignored. nBytes=" << nBytes << " status =" << (int)message->at(0);
        return;
    }
	if ( (((d->midiWriteCounter + 1) % CSQT_MAX_MIDI_QUEUE) != d->midiReadCounter) && acceptsMidiCC) {
        int index = d->midiWriteCounter;
        for (unsigned int i = 0; i < nBytes; i++) {
            d->midiQueue[index][i] = (int)message->at(i);
        }
        d->midiWriteCounter = (d->midiWriteCounter + 1) % CSQT_MAX_MIDI_QUEUE;
    }
    m_csEngine->queueMidiIn(message);
}

void DocumentPage::queueVirtualMidiIn(std::vector< unsigned char > &message)
{
    m_csEngine->queueVirtualMidiIn(message);
}

void DocumentPage::init(QWidget *parent, OpEntryParser *opcodeTree)
{
	fileName = "";
	companionFile = "";
	askForFile = true;
	readOnly = false;

	//TODO this should be set from CsoundQt configuration
	saveLiveEvents = true;

	m_view = new DocumentView(parent, opcodeTree);

	//connect(m_view, SIGNAL(evaluate(QString)), this, SLOT(evaluate(QString)));
	connect(m_view,SIGNAL(setHelp()), this, SLOT(setHelp()));
	// The definition index lives in the page, so the view only asks for the
	// jump. The new style of connect is used on purpose: it is checked when
	// the program is compiled and does not depend on the meta-object at run
	// time, so the request cannot get lost.
	connect(m_view, &DocumentView::goToSourceRequested, this, &DocumentPage::goToSource);


	// Connect for clearing marked lines and letting inspector know text has changed
	connect(m_view, SIGNAL(contentsChanged()), this, SLOT(textChanged()));

	connect(m_csEngine, SIGNAL(errorLines(QList<QPair<int, QString> >)),
			m_view, SLOT(markErrorLines(QList<QPair<int, QString> >)));
	connect(m_csEngine, SIGNAL(sampleRateMismatch(int, int, QString)),
			this, SLOT(sampleRateMismatch(int, int, QString)), Qt::QueuedConnection);
	connect(m_csEngine, SIGNAL(stopSignal()),
			this, SLOT(perfEnded()));

	//  detachWidgets();
}

WidgetLayout* DocumentPage::newWidgetLayout()
{
	WidgetLayout* wl = BaseDocument::newWidgetLayout();
	connect(wl, SIGNAL(changed()), this, SLOT(setModified()));
    connect(wl, SIGNAL(widgetSelectedSignal(QuteWidget*)),
            this, SLOT(passSelectedWidget(QuteWidget*)));
    connect(wl, SIGNAL(widgetUnselectedSignal(QuteWidget*)),
            this, SLOT(passUnselectedWidget(QuteWidget*)));
	//  connect(wl, SIGNAL(setWidgetClipboardSignal(QString)),
	//        this, SLOT(setWidgetClipboard(QString)));
	connect(wl,SIGNAL(showMidiLearn(QuteWidget *)),this, SLOT(showMidiLearn(QuteWidget *)));
    return wl;
}

int DocumentPage::play(CsoundOptions *options)
{
	m_view->unmarkErrorLines();  // Clear error lines when running
	return BaseDocument::play(options);
}

void DocumentPage::stop()
{
	BaseDocument::stop();
}

int DocumentPage::record(int format)
{
#ifdef	PERFTHREAD_RECORD
	if (fileName.startsWith(":/")) {
		QMessageBox::critical(static_cast<QWidget *>(parent()),
							  tr("CsoundQt"),
							  tr("You must save the examples to use Record."),
							  QMessageBox::Ok);
		return -1;
	}
	int number = 0;
	QString recName = fileName + "-000.wav";
	while (QFile::exists(recName)) {
		number++;
		recName = fileName + "-";
		if (number < 10)
			recName += "0";
		if (number < 100)
			recName += "0";
		recName += QString::number(number) + ".wav";
	}
	emit setCurrentAudioFile(recName);
	return m_csEngine->startRecording(format, recName);
#else
    (void) format;
    QMessageBox::warning(nullptr, tr("Recording not possible"), tr("This version of CsoundQt was not built with recording support."));
	return 0;
#endif
}

void DocumentPage::perfEnded()
{
	emit stopSignal();
}

void DocumentPage::sampleRateMismatch(int orchestraSr, int backendSr, const QString &backendName)
{
	Notification::showTransient(static_cast<QWidget *>(parent()),
		tr("Orchestra <b>%1 Hz</b> != audio backend <b>%2 Hz</b>. "
		   "Backend (%3) has a fixed sample rate &mdash; set the orchestra's <b>sr</b> to %2 "
		   "or choose <b>System</b> as the sample rate.")
		.arg(orchestraSr).arg(backendSr).arg(backendName), tr("Sample rate mismatch"), 30000, true, Notification::Horizontal::Center);
}

void DocumentPage::setHelp()
{
	emit setHelpSignal();
}

void DocumentPage::showWidgets(bool show)
{
    if (!show || (!fileName.endsWith(".csd") && !fileName.isEmpty())) {
		hideWidgets();
		return;
	}
	foreach (WidgetLayout *wl, m_widgetLayouts) {
        wl->adjustWidgetSize();
		wl->setVisible(true);
		wl->raise();
	}
}

void DocumentPage::hideWidgets()
{
	//  qDebug();
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setVisible(false);
	}
}

void DocumentPage::passSelectedWidget(QuteWidget *widget) // necessary only when ML is opened from edit menu and a widget is selected.
{
	m_midiLearn->setCurrentWidget(widget);
}

void DocumentPage::passUnselectedWidget(QuteWidget *widget) // necessary only when ML is opened from edit menu and a widget is selected.
{
	// TODO: Better options for unselecting widgets.
    (void) widget;
    m_midiLearn->setCurrentWidget(nullptr);
}

void DocumentPage::showMidiLearn(QuteWidget *widget)
{
	//qDebug();
	m_midiLearn->setCurrentWidget(widget);
	m_midiLearn->setModal(true); // not to leave the dialog floating around
	m_midiLearn->show();
}

void DocumentPage::setWidgetEditMode(bool active)
{
	//  qDebug();
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setEditMode(active);
	}
}

void DocumentPage::setWidgetFrameColors(const QColor &unselected, const QColor &selected)
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setFrameColors(unselected, selected);
	}
}

//void DocumentPage::toggleWidgetEditMode()
//{
//  qDebug() <<;
//  m_widgetLayout->toggleEditMode();
//}

void DocumentPage::duplicateWidgets()
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		if (wl->hasFocus()) {
			wl->duplicate();
		}
	}
}

void DocumentPage::jumpToLine(int line)
{
	//  qDebug() << line;
	m_view->jumpToLine(line);
}

void DocumentPage::jumpToLineWithoutFocus(int line)
{
	m_view->jumpToLineWithoutFocus(line);
}

void DocumentPage::comment()
{
	//  qDebug();
	m_view->comment();
}

void DocumentPage::uncomment()
{
	m_view->uncomment();
}

void DocumentPage::indent()
{
	m_view->indent();
}

void DocumentPage::unindent()
{
	m_view->unindent();
}

void DocumentPage::tabsToSpaces()
{
	m_view->tabsToSpaces();
}

void DocumentPage::killToEnd()
{
	m_view->killToEnd();
}

void DocumentPage::killLine()
{
	m_view->killLine();
}

void DocumentPage::gotoLine(int line)
{
    m_view->jumpToLine(line);
    // m_view->gotoLine(line);
}

void DocumentPage::gotoLineDialog()
{
    m_view->gotoLineDialog();
}

void DocumentPage::goBackToPreviousPosition() {
    m_view->goBackToPreviousPosition();
}

void DocumentPage::setViewMode(int mode)
{
	m_view->setViewMode(mode);
    // this->setHighlightingTheme(m_colorTheme);
}

void DocumentPage::showOrc(bool show)
{
	m_view->showOrc(show);
}

void DocumentPage::showScore(bool show)
{
	m_view->showScore(show);
}

void DocumentPage::showOptions(bool show)
{
	m_view->showOptions(show);
}

void DocumentPage::showFileB(bool show)
{
	m_view->showFileB(show);
}

void DocumentPage::showOther(bool show)
{
	m_view->showOther(show);
}

void DocumentPage::showOtherCsd(bool show)
{
	m_view->showOtherCsd(show);
}

void DocumentPage::showWidgetEdit(bool show)
{
	m_view->showWidgetEdit(show);
}


void DocumentPage::textChanged()
{
    m_parseUdosNeeded = true;
    // Keep the page's modified state in sync with the editor. Loading a file
    // also inserts text, but loadFile()/setTextString() clear the state again
    // right afterwards. isModified() additionally covers modified widget
    // layouts, so clearing an undone text change must not forget about them.
    setModified(isModified());
    // This signal triggers an inspector update
	emit currentTextUpdated();
}


void DocumentPage::setHighlightingTheme(QString theme) {
    if(m_view == nullptr)
        return;
    m_colorTheme = theme;
    bool modified = isModified();
    m_view->setTheme(theme);
    setModified(modified);
    auto defaultFormat = m_view->getDefaultFormat();
    this->setEditorColors(defaultFormat.foreground().color(),
                          defaultFormat.background().color());
    /*
    m_console->setColors(defaultFormat.foreground().color(),
                         defaultFormat.background().color());
    */
}

void DocumentPage::enableScoreSyntaxHighlighting(bool status) {
    m_view->enableScoreSyntaxHighlighting(status);
}

void DocumentPage::setParsedUDOs(QStringList udos) {
    m_view->setParsedUDOs(udos);
}

void DocumentPage::parseUdos(bool force) {
    if(!m_parseUdosNeeded && !force)
        return;
    const QStringList oldUdos = m_parsedUdos;
    m_definitions.scan(this->getBasicText());
    m_parsedUdos = m_definitions.udoNames();
    auto highlighter = m_view->getHighlighter();
    highlighter->setUDOs(m_parsedUdos);
    if(oldUdos != m_parsedUdos) {
        highlighter->rehighlight();
    }
    m_parseUdosNeeded = false;
}

void DocumentPage::goToSourceAtCursor()
{
    goToSource(m_view->identifierAtCursor(), m_view->isScheduleArgumentAtCursor());
}

void DocumentPage::goToSource(const QString &name, bool isScheduleArgument)
{
    // The index of definitions is refreshed on every text change, but only
    // when the timer gets to it, so it is brought up to date here.
    m_definitions.scan(this->getBasicText());

    if (name.isEmpty()) {
        qDebug() << "Go to source: there is no name at the cursor";
        return;
    }
    const SourceDefinitions::Definition *definition = m_definitions.find(name);
    if (definition == nullptr) {
        qDebug() << "Go to source:" << name << "is not defined in this document";
        Notification::showTransient(static_cast<QWidget *>(parent()),
            tr("Go to source: \"%1\" not defined").arg(name), 4000);
        return;
    }
    if (definition->kind == SourceDefinitions::Instrument && !isScheduleArgument) {
        // An instrument is only reached through a schedule() or schedulek()
        // call: anywhere else the name may be a variable or a string.
        qDebug() << "Go to source:" << name << "is an instrument but is not scheduled here";
        return;
    }
    m_view->jumpToDefinition(definition->line, definition->column);
}

void DocumentPage::autocomplete() {
    m_view->autoCompleteAtCursor();
}

void DocumentPage::insertOpcode() {
    m_view->showOpcodeInsertBar();
}
