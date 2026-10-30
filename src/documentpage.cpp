
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
#include "scanservice.h"
#include "includecache.h"
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

#include <QDir>
#include <QFileInfo>
#include <QMessageBox>

// TODO is is possible to move the editor to a separate child class, to be able to use a cleaner class?
DocumentPage::DocumentPage(QWidget *parent, OpEntryParser *opcodeTree,
                           ConfigLists *configlists, MidiLearnDialog *midiLearn):
	BaseDocument(parent, opcodeTree, configlists)
{
	init(parent, opcodeTree);
	m_view->showLineArea(true);
	// The widget layout is the source of truth for chnget/chnset completion;
	// read it on demand so a renamed channel is picked up immediately.
	m_view->setWidgetChannelsProvider([this]() { return getWidgetChannels(); });
	m_view->setWidgetPropertiesProvider([this](const QString &channelOrName) {
		return getWidgetProperties(channelOrName);
	});
	m_view->setDocumentDirectoryProvider([this]() {
		if (fileName.isEmpty() || fileName.startsWith(QLatin1String(":/")))
			return QDir::currentPath();
		return QFileInfo(fileName).absolutePath();
	});
	m_view->setIncludeSearchPathsProvider([this]() {
		return includeSearchPaths();
	});
	m_view->setVariableTypeProvider([this](int line, const QString &name) {
		return variableTypeAt(line, name);
	});
	m_view->setCurrentBlockVariablesProvider([this](int line) {
		return localVariableTypesAt(line);
	});
	connect(m_view, &DocumentView::channelHighlightRequested,
	        this, [this](const QString &channel) {
		WidgetLayout *layout = getWidgetLayout();
		if (!layout)
			return;
		if (channel.isEmpty())
			layout->clearChannelHighlights();
		else
			layout->highlightChannel(channel);
	});
	connect(m_view, &DocumentView::editorEscapePressed,
	        this, &DocumentPage::clearWidgetChannelHighlights);
	m_midiLearn = midiLearn;
    m_colorTheme = "";
	foreach(WidgetLayout* wl, m_widgetLayouts) {
		connect(wl, SIGNAL(changed()), this, SLOT(setModified()));
        connect(wl, SIGNAL(widgetSelectedSignal(QuteWidget*)),
                this, SLOT(passSelectedWidget(QuteWidget*)));
        connect(wl, SIGNAL(widgetUnselectedSignal(QuteWidget*)),
                this, SLOT(passUnselectedWidget(QuteWidget*)));
        connect(wl, &WidgetLayout::widgetSelectedSignal,
                this, [this](QuteWidget *) { updateWidgetChannelLineHighlights(); });
        connect(wl, &WidgetLayout::widgetUnselectedSignal,
                this, [this](QuteWidget *) { updateWidgetChannelLineHighlights(); });
        connect(wl, &WidgetLayout::widgetHovered,
                this, [this](QuteWidget *) { updateWidgetChannelLineHighlights(); });
        connect(wl, &WidgetLayout::widgetChannelsHighlightRequested,
                this, &DocumentPage::togglePinnedWidgetChannelHighlights);
        connect(wl, &WidgetLayout::editingEscapePressed,
                this, &DocumentPage::clearWidgetChannelHighlights);
        connect(wl, &WidgetLayout::editModeChanged,
                this, [this](bool) { updateWidgetChannelLineHighlights(); });
		connect(wl,SIGNAL(showMidiLearn(QuteWidget*)),this, SLOT(showMidiLearn(QuteWidget*)));
	}
}

DocumentPage::~DocumentPage()
{
	//  qDebug();
	// The service keys its state by the page; it must not keep a pointer to a
	// page that is going away.
	if (m_scanService != nullptr)
		m_scanService->forget(this);
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
    updateWidgetChannels();
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
	m_widgetLayouts.at(0)->loadXmlWidgets(text);
	updateWidgetChannels();
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
    static const  QRegularExpression instrRegex(uR"(\n[ \t]*instr\s)"_s);
    return text.count(instrRegex);
}

int DocumentPage::udoCount()
{
	QString text = this->getBasicText();
    static const  QRegularExpression opcodeRegex(uR"(\n[ \t]*opcode\s)"_s);
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
        // Clear the children before announcing it: the listeners of
        // unmodified() call isModified() to update the tab marker, and must
        // see the saved document, or they put the '*' back.
		m_view->setModified(false);
		foreach (WidgetLayout  *wl, m_widgetLayouts) {
			wl->setModified(false);
		}
        emit unmodified();
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

void DocumentPage::setFileName(QString name)
{
    const QString previous = fileName;
    BaseDocument::setFileName(name);
    // The path is part of how #include directives resolve and how the file
    // type is highlighted. A Save As therefore invalidates the scan.
    if (name != previous && m_scanService != nullptr)
        m_scanService->sourceChanged(this);
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

void DocumentPage::setScrollBarVisible(bool visible)
{
	m_view->setScrollBarVisible(visible);
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

void DocumentPage::setAutoCompleteMenuMaxLines(int lines)
{
    m_view->setAutoCompleteMenuMaxLines(lines);
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
	connect(m_view, &DocumentView::goToSourceIncludeRequested,
	        this, &DocumentPage::openIncludedFile);


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

void DocumentPage::setWidgetDrawingEnabled(bool enabled)
{
	foreach (WidgetLayout *wl, m_widgetLayouts) {
		wl->setDrawingEnabled(enabled);
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

void DocumentPage::jumpToDefinition(int line, int column)
{
	m_view->jumpToDefinition(line, column);
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

void DocumentPage::duplicateLine()
{
	m_view->duplicateLine();
}

void DocumentPage::moveLineUp()
{
	m_view->moveLineUp();
}

void DocumentPage::moveLineDown()
{
	m_view->moveLineDown();
}

void DocumentPage::applyEditorActions(const QList<QAction *> &actions)
{
	m_view->applyEditorActions(actions);
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

void DocumentPage::textChanged()
{
    if (m_scanService != nullptr)
        m_scanService->sourceChanged(this);
    // Keep the page's modified state in sync with the editor. Loading a file
    // also inserts text, but loadFile()/setTextString() clear the state again
    // right afterwards. isModified() additionally covers modified widget
    // layouts, so clearing an undone text change must not forget about them.
    setModified(isModified());
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

void DocumentPage::setGlobalVariables(const QStringList &variables) {
    m_view->setGlobalVariables(variables);
}

void DocumentPage::setGlobalStringVariables(const QStringList &variables) {
    m_view->setGlobalStringVariables(variables);
}

void DocumentPage::setInstrumentNames(const QStringList &names) {
    m_view->setInstrumentNames(names);
}

QStringList DocumentPage::getWidgetChannels() {
    QStringList channels;
    if (WidgetLayout *layout = getWidgetLayout()) {
        for (QuteWidget *widget : layout->getWidgets()) {
            if (!widget)
                continue;
            const QString channel = widget->getChannelName();
            const QString channel2 = widget->getChannel2Name();
            if (!channel.isEmpty())
                channels.append(channel);
            if (!channel2.isEmpty())
                channels.append(channel2);
        }
    }
    channels.removeDuplicates();
    channels.sort(Qt::CaseInsensitive);
    return channels;
}

QString DocumentPage::variableTypeAt(int line, const QString &name) const
{
    if (!m_scan || line < 1 || name.isEmpty())
        return {};
    const CodeScan::Definition::Variable *variable =
            m_scan->variableAt(line, name);
    if (variable == nullptr)
        return {};
    QString type = variable->type;
    if (variable->array)
        type += u"[]"_s;
    return type;
}

QHash<QString, QString> DocumentPage::localVariableTypesAt(int line) const
{
    QHash<QString, QString> types;
    if (!m_scan)
        return types;
    const CodeScan::Definition *block = m_scan->blockAt(line);
    if (block == nullptr)
        return types;
    for (auto it = block->localVariables.cbegin();
         it != block->localVariables.cend(); ++it) {
        types.insert(it.key(), it.value().type);
    }
    return types;
}

QList<WidgetPropertyInfo> DocumentPage::getWidgetProperties(
        const QString &channelOrName) {
    if (channelOrName.isEmpty())
        return {};
    if (WidgetLayout *layout = getWidgetLayout()) {
        for (QuteWidget *widget : layout->getWidgets()) {
            if (!widget)
                continue;
            if (widget->getChannelName().compare(channelOrName,
                                                  Qt::CaseInsensitive) == 0
                    || widget->getChannel2Name().compare(channelOrName,
                                                         Qt::CaseInsensitive) == 0
                    || widget->getWidgetName().compare(channelOrName,
                                                       Qt::CaseInsensitive) == 0) {
                // If several widgets share a channel, the first one visible
                // in the layout is the one whose properties are offered.
                return widget->getPropertyInfo();
            }
        }
    }
    return {};
}

void DocumentPage::updateWidgetChannels() {
    m_view->setWidgetChannels(getWidgetChannels());
}

QString DocumentPage::scanText()
{
    return getBasicText();
}

QString DocumentPage::scanFilePath() const
{
    return fileName;
}

QStringList DocumentPage::includeSearchPaths()
{
    // Only CsoundQt's own INCDIR setting and the document's <CsOptions> count.
    // The process environment and .csound7rc are intentionally ignored: they
    // are not portable and the editor must not depend on them.
    return IncludeCache::includePathsFromOptions(getOptionsText(),
                                                 m_includeSearchPaths);
}

CodeScan::Mode DocumentPage::scanMode() const
{
    const QString name = fileName.toLower();
    // HTML panels are not Csound source; a .sco is score text, which the
    // orchestra scanner has nothing to say about.
    if (name.endsWith(".html") || name.endsWith(".sco"))
        return CodeScan::Mode::None;
    if (name.isEmpty() || name.endsWith(".csd"))
        return CodeScan::Mode::Csd;
    // .orc, .udo and .inc (and anything else that is Csound code) are
    // orchestra code; a .udo is the same thing with only opcodes in it.
    return CodeScan::Mode::Orc;
}

void DocumentPage::applyScan(const CodeScan::ResultPtr &scan)
{
    m_scan = scan;
    bool needRehighlight = false;

    // The highlighter colours calls of the opcodes defined in the document.
    // Re-running it is only necessary when that set changed.
    QSet<QString> udos;
    udos.reserve(scan->udos.size());
    for (const CodeScan::Definition &udo : scan->udos)
        udos.insert(udo.name);
    if (udos != m_parsedUdos) {
        m_parsedUdos = udos;
        m_view->getHighlighter()->setUDOs(QStringList(udos.begin(), udos.end()));
        needRehighlight = true;
    }

    // Local variables are kept per block so the same name can have different
    // types in different instruments/opcodes. Included-file blocks are skipped:
    // their line numbers belong to another document.
    QVector<Highlighter::VariableScope> scopes;
    QString variableSignature;
    const auto collectVariables = [&scopes, &variableSignature](
            const CodeScan::Definition &definition) {
        if (!definition.file.isEmpty())
            return;
        Highlighter::VariableScope scope;
        scope.startLine = definition.line;
        scope.endLine = definition.endLine;
        QStringList names;
        for (auto it = definition.localVariables.cbegin();
             it != definition.localVariables.cend(); ++it) {
            const CodeScan::Definition::Variable &variable = it.value();
            scope.variables.insert(it.key(), variable.type);
            names.append(it.key() + QLatin1Char(':') + variable.type
                         + (variable.array ? u"[]"_s : QString()));
        }
        names.sort();
        variableSignature += QString::number(scope.startLine) + QLatin1Char('-')
                + QString::number(scope.endLine) + QLatin1Char(':')
                + names.join(QLatin1Char(',')) + QLatin1Char('\n');
        scopes.append(scope);
    };
    for (const CodeScan::Definition &instrument : scan->instruments)
        collectVariables(instrument);
    for (const CodeScan::Definition &udo : scan->udos)
        collectVariables(udo);

    if (variableSignature != m_localVariableSignature) {
        m_localVariableSignature = variableSignature;
        m_view->getHighlighter()->setLocalVariableScopes(scopes);
        needRehighlight = true;
    }
    if (needRehighlight)
        m_view->rehighlightSyntax();

    setGlobalVariables(scan->globalVariables);
    setGlobalStringVariables(scan->globalStringVariables);
    setInstrumentNames(scan->instrumentNames);
    m_view->setUdoNames(QStringList(udos.begin(), udos.end()));
}

bool DocumentPage::udoInfo(const QString &name, QString *signature, QString *docstring)
{
    if (name.isEmpty())
        return false;
    // The help action may arrive before the debounced scan has run; make sure
    // the information reflects the text as it is now.
    if (m_scanService != nullptr)
        m_scanService->scanNow(this);

    bool found = false;
    for (const CodeScan::Definition &udo : m_scan->udos) {
        if (udo.name != name)
            continue;
        found = true; // a later definition wins
        if (signature != nullptr)
            *signature = udo.callSignature;
        if (docstring != nullptr)
            *docstring = udo.docstring;
    }
    return found;
}

bool DocumentPage::instrInfo(const QString &name, QString *signature, QString *docstring)
{
    if (name.isEmpty())
        return false;
    // The help action may arrive before the debounced scan has run; make sure
    // the information reflects the text as it is now.
    if (m_scanService != nullptr)
        m_scanService->scanNow(this);

    bool found = false;
    for (const CodeScan::Definition &instrument : m_scan->instruments) {
        if (instrument.name != name)
            continue;
        found = true; // a later definition wins
        if (signature != nullptr)
            *signature = instrument.callSignature;
        if (docstring != nullptr)
            *docstring = instrument.docstring;
    }
    return found;
}

void DocumentPage::showQuickHelp(const QString &title, const QString &html)
{
    m_view->showQuickHelp(title, html);
}

void DocumentPage::showQuickHelpAt(const QString &title, const QString &html,
                                   const QPoint &globalAnchor, bool passive)
{
    m_view->showQuickHelpAt(title, html, globalAnchor, passive);
}

void DocumentPage::goToSourceAtCursor()
{
    // Inside the file name of an #include directive the cursor points at the
    // included file, not at a Csound name.
    const QString includePath = m_view->includePathAtCursor();
    if (!includePath.isEmpty()) {
        openIncludedFile(includePath);
        return;
    }
    goToSource(m_view->identifierAtCursor(),
               m_view->isScheduleArgumentAtCursor(),
               m_view->currentLineNumber());
}

void DocumentPage::openIncludedFile(const QString &includePath)
{
    const QString file = m_scanService != nullptr
            ? m_scanService->resolveInclude(includePath, getFileName(),
                                            includeSearchPaths())
            : QString();
    if (!file.isEmpty()) {
        emit goToSourceFileRequested(file, 1, 0);
        return;
    }
    Notification::showTransient(static_cast<QWidget *>(parent()),
        tr("Go to source: included file \"%1\" not found").arg(includePath),
        4000);
}

void DocumentPage::goToSource(const QString &name, bool isScheduleArgument,
                              int line)
{
    // Only the current page can be edited, so the applied scan may be older
    // than the text: bring it up to date before looking anything up.
    if (m_scanService != nullptr)
        m_scanService->scanNow(this);
    const CodeScan::Result *scan = m_scan.data();

    if (name.isEmpty()) {
        qDebug() << "Go to source: there is no name at the cursor";
        return;
    }
    if (line < 0)
        line = m_view->currentLineNumber();

    const CodeScan::Definition *definition = scan->find(name);
    // A schedule() argument names an instrument even if a local variable with
    // the same name exists. In every other position a local variable wins over
    // the document-level definition index.
    const bool instrumentTarget = isScheduleArgument && definition != nullptr
            && definition->kind == CodeScan::Kind::Instrument;
    if (!instrumentTarget) {
        if (const CodeScan::Definition::Variable *variable =
                scan->variableAt(line, name)) {
            if (!variable->file.isEmpty()) {
                emit goToSourceFileRequested(variable->file, variable->line,
                                             variable->column);
            } else {
                m_view->jumpToDefinition(variable->line, variable->column);
            }
            return;
        }
    }

    if (definition == nullptr) {
        qDebug() << "Go to source:" << name << "is not defined in this document";
        Notification::showTransient(static_cast<QWidget *>(parent()),
            tr("Go to source: \"%1\" not defined").arg(name), 4000);
        return;
    }
    if (definition->kind == CodeScan::Kind::Instrument && !isScheduleArgument) {
        // An instrument is only reached through a schedule() or schedulek()
        // call: anywhere else the name may be a variable or a string. This
        // holds for instruments defined in an included file too.
        qDebug() << "Go to source:" << name << "is an instrument but is not scheduled here";
        return;
    }
    if (!definition->file.isEmpty()) {
        // Defined in an included file: the application opens that file.
        emit goToSourceFileRequested(definition->file, definition->line,
                                     definition->column);
        return;
    }
    m_view->jumpToDefinition(definition->line, definition->column);
}

void DocumentPage::autocomplete() {
    m_view->autoCompleteAtCursor(true);
}

void DocumentPage::insertOpcode() {
    m_view->showOpcodeInsertBar();
}

void DocumentPage::highlightWidgetChannel() {
    m_view->highlightWidgetChannel();
}

void DocumentPage::setChannelHighlightMode(ChannelHighlightMode mode) {
    m_view->setChannelHighlightMode(mode);
}

void DocumentPage::setQuickHelpOnHover(bool enabled) {
    m_view->setQuickHelpOnHover(enabled);
}

void DocumentPage::setShowVariableOccurrences(bool enabled) {
    m_view->setShowVariableOccurrences(enabled);
}

void DocumentPage::showWordOccurrences() {
    m_view->showWordOccurrences();
}

void DocumentPage::setQuickHelpHoverDelay(int milliseconds) {
    m_view->setQuickHelpHoverDelay(milliseconds);
}

void DocumentPage::setChannelReferenceHighlightMode(ChannelReferenceHighlightMode mode) {
    if (m_channelReferenceHighlightMode == mode)
        return;
    m_channelReferenceHighlightMode = mode;
    if (!m_widgetChannelHighlightPinned)
        updateWidgetChannelLineHighlights();
}

void DocumentPage::highlightSelectedWidgetChannels() {
    WidgetLayout *layout = getWidgetLayout();
    if (!layout)
        return;
    const QList<QuteWidget *> selected = layout->getSelectedWidgets();
    if (selected.size() != 1)
        return;
    QStringList channels;
    const QString channel = selected.first()->getChannelName();
    const QString channel2 = selected.first()->getChannel2Name();
    if (!channel.isEmpty())
        channels.append(channel);
    if (!channel2.isEmpty())
        channels.append(channel2);
    togglePinnedWidgetChannelHighlights(channels);
}

void DocumentPage::togglePinnedWidgetChannelHighlights(const QStringList &channels) {
    QStringList unique = channels;
    unique.removeAll(QString());
    unique.removeDuplicates();
    if (m_widgetChannelHighlightPinned && unique == m_pinnedWidgetChannels) {
        clearWidgetChannelHighlights();
        return;
    }
    m_pinnedWidgetChannels = unique;
    m_widgetChannelHighlightPinned = !unique.isEmpty();
    if (unique.isEmpty())
        m_view->clearWidgetChannelHighlights();
    else
        m_view->highlightWidgetChannels(unique, true);
}

void DocumentPage::clearWidgetChannelHighlights() {
    m_widgetChannelHighlightPinned = false;
    m_pinnedWidgetChannels.clear();
    m_view->clearWidgetChannelHighlights();
}

void DocumentPage::updateWidgetChannelLineHighlights() {
    if (m_widgetChannelHighlightPinned)
        return;
    WidgetLayout *layout = getWidgetLayout();
    if (!layout) {
        m_view->clearWidgetChannelHighlights();
        return;
    }
    if (m_channelReferenceHighlightMode == ChannelReferenceHighlightMode::Never
            || (m_channelReferenceHighlightMode
                == ChannelReferenceHighlightMode::EditMode
                && !layout->isEditMode())) {
        m_view->clearWidgetChannelHighlights();
        return;
    }
    QuteWidget *hovered = layout->getHoveredWidget();
    QList<QuteWidget *> widgets;
    if (hovered)
        widgets.append(hovered);
    else
        widgets = layout->getSelectedWidgets();

    QStringList channels;
    for (QuteWidget *widget : widgets) {
        if (!widget)
            continue;
        if (!widget->getChannelName().isEmpty())
            channels.append(widget->getChannelName());
        if (!widget->getChannel2Name().isEmpty())
            channels.append(widget->getChannel2Name());
    }
    channels.removeDuplicates();
    m_view->highlightWidgetChannels(channels);
}
