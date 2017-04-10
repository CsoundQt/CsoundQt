/***************************************************************************
 *   Copyright (C) 2010 by Andres Cabrera                                  *
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

#include "baseview.h"
#include "highlighter.h"
#include "texteditor.h"
#include "opentryparser.h"

BaseView::BaseView(QWidget *parent, OpEntryParser *opcodeTree) :
	QScrollArea(parent), m_opcodeTree(opcodeTree)
{
	QPalette p = palette();
	m_mainEditor = new TextEditLineNumbers(this);
	m_orcEditor = new TextEditor(this);
	m_scoreEditor = new ScoreEditor(this);
	m_optionsEditor = new TextEditor(this);
	m_optionsEditor->setMaximumHeight(60);
	p.setColor(QPalette::WindowText, QColor("darkRed"));
	p.setColor(static_cast<QPalette::ColorRole>(9), QColor(200, 200, 200));
	m_optionsEditor->setPalette(p);
	m_optionsEditor->setTextColor(QColor("darkGreen"));
	m_filebEditor = new FileBEditor(this);
	m_otherEditor = new TextEditor(this);
	p.setColor(QPalette::WindowText, QColor("darkGreen"));
	p.setColor(static_cast<QPalette::ColorRole>(9), QColor(200, 200, 200));
	m_otherEditor->setPalette(p);
	m_otherEditor->setTextColor(QColor("darkGreen"));
	m_otherCsdEditor = new TextEditor(this);
	p.setColor(QPalette::WindowText, QColor("gray"));
	p.setColor(static_cast<QPalette::ColorRole>(9), QColor(200, 200, 200));
	m_otherCsdEditor->setPalette(p);
	m_otherCsdEditor->setTextColor(QColor("gray"));
	m_widgetEditor = new TextEditor(this);
	m_appEditor = new TextEditor(this);
	editors << m_mainEditor << m_orcEditor << m_scoreEditor << m_optionsEditor << m_filebEditor
			<< m_otherEditor << m_otherCsdEditor << m_widgetEditor << m_appEditor;
	splitter = new QSplitter(this); // Deleted with parent
	splitter->setOrientation(Qt::Vertical);
	splitter->setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
	splitter->setContextMenuPolicy (Qt::NoContextMenu);

	QStackedLayout *l = new QStackedLayout(this);  // Deleted with parent
	l->addWidget(splitter);
	setLayout(l);
	m_mode = EDIT_CSOUND_MODE;
	m_highlighter.setOpcodeNameList(opcodeTree->opcodeNameList());
	m_highlighter.setDocument(m_mainEditor->document());
	m_viewMode = 0;
	m_appProperties.used = false;
}

BaseView::~BaseView()
{
}

void BaseView::setFullText(QString text, bool goToTop)
{
	// Load Embedded Files ------------------------
	// Must be done initially to remove the files for both view modes
	clearFileBText();
    while (text.contains("<CsFileB ") && text.contains("</CsFileB>")) {
		bool endsWithBreak = false;
		if (text.indexOf("</CsFileB>") < text.indexOf("<CsFileB ")) {
			qDebug() << "BaseView::setFullText: File corrupt, not loading remaining CsFileB sections.";
			break;
		}
		if (text.indexOf("</CsFileB>") + 10 < text.size() && text[text.indexOf("</CsFileB>") + 10] == '\n' ) {
			endsWithBreak = true;
		}
		QString currentFileText = text.mid(text.indexOf("<CsFileB "),
										   text.indexOf("</CsFileB>") - text.indexOf("<CsFileB ") + 10
										   + (endsWithBreak ? 1:0));
		text.remove(text.indexOf("<CsFileB "), currentFileText.size());
		appendFileBText(currentFileText);
	}
	int startIndex,endIndex, offset, endoffset;
	QString tag, sectionText;
	// Get app info text. This text will never be visible in the full editor, so it is here
	sectionText = "";
	tag = "CsApp";
	startIndex = text.indexOf("<" + tag + ">");
	endIndex = text.indexOf("</" + tag + ">", startIndex) + tag.size() + 3;
	endoffset = text.size() > endIndex
			&& text[endIndex] == '\n' ? 1: 0;
	if (startIndex >= 0 && endIndex > startIndex) {
		sectionText = text.mid(startIndex, endIndex - startIndex + endoffset);
		text.remove(sectionText);
		QDomDocument d;
		if (!d.setContent(sectionText)) {
			qDebug() << "BaseView::setFullText error parsing CsApp. Section will be discarded.";
		} else {
			QDomNodeList csapp = d.elementsByTagName("CsApp");
			QDomElement p = csapp.item(0).toElement();
			m_appProperties.appName = p.firstChildElement("appName").firstChild().nodeValue();
			m_appProperties.targetDir = p.firstChildElement("targetDir").firstChild().nodeValue();
			m_appProperties.author = p.firstChildElement("author").firstChild().nodeValue();
			m_appProperties.version = p.firstChildElement("version").firstChild().nodeValue();
			m_appProperties.date = p.firstChildElement("date").firstChild().nodeValue();
			m_appProperties.email = p.firstChildElement("email").firstChild().nodeValue();
			m_appProperties.website = p.firstChildElement("website").firstChild().nodeValue();
			m_appProperties.instructions = p.firstChildElement("instructions").firstChild().nodeValue();
			m_appProperties.autorun = p.firstChildElement("autorun").firstChild().nodeValue() == "true";
			m_appProperties.showRun = p.firstChildElement("showRun").firstChild().nodeValue() == "true";
			m_appProperties.saveState = p.firstChildElement("saveState").firstChild().nodeValue() == "true";
			m_appProperties.runMode = p.firstChildElement("runMode").firstChild().nodeValue().toInt();
			m_appProperties.newParser = p.firstChildElement("newParser").firstChild().nodeValue() == "true";
			m_appProperties.useSdk = p.firstChildElement("useSdk").firstChild().nodeValue() == "true";
			m_appProperties.useCustomPaths = p.firstChildElement("useCustomPaths").firstChild().nodeValue() == "true";
			m_appProperties.libDir = p.firstChildElement("libDir").firstChild().nodeValue();
			m_appProperties.opcodeDir = p.firstChildElement("opcodeDir").firstChild().nodeValue();
			m_appProperties.used = true;
		}
	}
	if (m_viewMode < 2) {  // Unified view
		m_mainEditor->setUndoRedoEnabled(false);
		QTextCursor cursor = m_mainEditor->textCursor();
		cursor.select(QTextCursor::Document);
		cursor.insertText(text);
		m_mainEditor->setTextCursor(cursor);  // TODO implement for multiple views
		if (goToTop) {
			m_mainEditor->moveCursor(QTextCursor::Start);
		}
		m_mainEditor->setUndoRedoEnabled(true);
	}
	else { // Split view
		// Find orchestra section
		sectionText = "";
		tag = "CsInstruments";
		startIndex = text.indexOf("<" + tag + ">");
		offset = text.size() > startIndex + tag.size() + 2
				&& text[startIndex +  tag.size() + 2] == '\n' ? 1: 0;
		endIndex = text.indexOf("</" + tag + ">") + tag.size() + 3;
		endoffset = text.size() > endIndex
				&& text[endIndex] == '\n' ? 1: 0;
		if (startIndex >= 0 && endIndex > startIndex) {
			sectionText = text.mid(startIndex, endIndex - startIndex + endoffset);
			text.remove(sectionText);
		}
		m_orcEditor->setUndoRedoEnabled(false);
		setOrc(sectionText.mid(tag.size() + 2 + offset, sectionText.size() - (tag.size()*2) - 5 - offset - endoffset));
		m_orcEditor->setUndoRedoEnabled(true);
		// Find score section
		sectionText = "";
		tag = "CsScore";
		startIndex = text.indexOf("<" + tag + ">");
		offset = text.size() > startIndex + tag.size() + 2
				&& text[startIndex +  tag.size() + 2] == '\n' ? 1: 0;
		endIndex = text.indexOf("</" + tag + ">") + tag.size() + 3;
		endoffset = text.size() > endIndex
				&& text[endIndex] == '\n' ? 1: 0;
		if (startIndex >= 0 && endIndex > startIndex) {
			sectionText = text.mid(startIndex, endIndex - startIndex + endoffset);
			text.remove(sectionText);
		}
		//	m_scoreEditor->setUndoRedoEnabled(false);
		setSco(sectionText.mid(tag.size() + 2 + offset, sectionText.size() - (tag.size()*2) - 5 - offset - endoffset));
		//	m_scoreEditor->setUndoRedoEnabled(true);
		// Set options text
		sectionText = "";
		tag = "CsOptions";
		startIndex = text.indexOf("<" + tag + ">");
		offset = text.size() > startIndex + tag.size() + 2
				&& text[startIndex +  tag.size() + 2] == '\n' ? 1: 0;
		endIndex = text.indexOf("</" + tag + ">") + tag.size() + 3;
		endoffset = text.size() > endIndex
				&& text[endIndex] == '\n' ? 1: 0;
		if (startIndex >= 0 && endIndex > startIndex) {
			sectionText = text.mid(startIndex, endIndex - startIndex + endoffset);
			text.remove(sectionText);
		}
		m_optionsEditor->setUndoRedoEnabled(false);
		setOptionsText(sectionText.mid(tag.size() + 2 + offset, sectionText.size() - (tag.size()*2) - 5 - offset - endoffset));
		m_optionsEditor->setUndoRedoEnabled(true);

		// Remaining text inside CsSynthesizer tags
		sectionText = "";
		tag = "CsoundSynthesizer";
		startIndex = text.indexOf("<" + tag + ">");
		offset = text.size() > startIndex + tag.size() + 2
				&& text[startIndex +  tag.size() + 2] == '\n' ? 1: 0;
		endIndex = text.indexOf("</" + tag + ">") + tag.size() + 3;
		endoffset = text.size() > endIndex
				&& text[endIndex] == '\n' ? 1: 0;
		if (startIndex >= 0 && endIndex > startIndex) {
			sectionText = text.mid(startIndex, endIndex - startIndex + endoffset);
			text.remove(sectionText);
		}
		m_otherCsdEditor->setUndoRedoEnabled(false);
		setOtherCsdText(sectionText.mid(tag.size() + 2 + offset, sectionText.size() - (tag.size()*2) - 5 - offset - endoffset));
		m_otherCsdEditor->setUndoRedoEnabled(true);
		// Remaining text after all this
		m_otherEditor->setUndoRedoEnabled(false);
		setOtherText(text);
		m_otherEditor->setUndoRedoEnabled(true);
	}
}

void BaseView::setBasicText(QString text)
{
	if (m_viewMode < 2) {  // Unified view
		QTextCursor cursor = m_mainEditor->textCursor();
		cursor.select(QTextCursor::Document);
		cursor.insertText(text);
		m_mainEditor->setTextCursor(cursor);  // TODO implement for multiple views
	}
	else {
		qDebug() << "BaseView::setBasicText not implemented for Split view.";
	}
}

void BaseView::setFileType(editor_mode_t mode)
{
	m_highlighter.setMode(mode);
	m_mode = mode;
}

void BaseView::setFont(QFont font)
{
	m_mainEditor->setFont(font);
	m_orcEditor->setFont(font);
	m_scoreEditor->setFont(font);
	m_optionsEditor->setFont(font);
	//  m_filebEditor->setFont(font);
	m_otherEditor->setFont(font);
	m_otherCsdEditor->setFont(font);
	m_widgetEditor->setFont(font);
	m_appEditor->setFont(font);
}

void BaseView::setFontPointSize(float size)
{
	m_mainEditor->setFontPointSize(size);
	m_orcEditor->setFontPointSize(size);
	m_scoreEditor->setFontPointSize(size);
	m_optionsEditor->setFontPointSize(size);
	//  m_filebEditor->setFontPointSize(size);
	m_otherEditor->setFontPointSize(size);
	m_otherCsdEditor->setFontPointSize(size);
	m_widgetEditor->setFontPointSize(size);
	m_appEditor->setFontPointSize(size);
}

void BaseView::setTabStopWidth(int width)
{
	m_mainEditor->setTabStopWidth(width);
	m_orcEditor->setTabStopWidth(width);
	m_scoreEditor->setTabStopWidth(width);
	m_optionsEditor->setTabStopWidth(width);
	//  m_filebEditor->setTabStopWidth(width);
	m_otherEditor->setTabStopWidth(width);
	m_otherCsdEditor->setTabStopWidth(width);
	m_widgetEditor->setTabStopWidth(width);
	m_appEditor->setTabStopWidth(width);
}

void BaseView::setTabIndents(bool indents)
{
	m_mainEditor->setTabIndents(indents);
}

void BaseView::setLineWrapMode(QTextEdit::LineWrapMode mode)
{
	m_mainEditor->setLineWrapMode(mode);
	m_orcEditor->setLineWrapMode(mode);
	m_scoreEditor->setLineWrapMode(mode);
	m_optionsEditor->setLineWrapMode(mode);
	//  m_filebEditor->setLineWrapMode(mode);
	m_otherEditor->setLineWrapMode(mode);
	m_otherCsdEditor->setLineWrapMode(mode);
	m_widgetEditor->setLineWrapMode(mode);
	m_appEditor->setLineWrapMode(mode);
}

void BaseView::setColorVariables(bool color)
{
	m_highlighter.setColorVariables(color);
}

void BaseView::setBackgroundColor(QColor color)
{
	m_mainEditor->setStyleSheet("QTextEdit { background-color: "+color.name() + "}"); // before it was setPalette, but that does not work runtime.
}

void BaseView::setOrc(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "DocumentView::setOrc Current file is not a csd file. Text not inserted!";
			return;
		}
		QString csdText = getBasicText();
        if (csdText.contains("<CsInstruments>") && csdText.contains("</CsInstruments>")) {
			QString preText = csdText.mid(0, csdText.indexOf("<CsInstruments>") + 15);
			QString postText = csdText.mid(csdText.lastIndexOf("</CsInstruments>"));
			if (!text.startsWith("\n")) {
				text.prepend("\n");
			}
			if (!text.endsWith("\n")) {
				text.append("\n");
			}
			csdText = preText + text + postText;
			setBasicText(csdText);
		}
		else {
			qDebug() << "DocumentView::setOrc Orchestra section not found in csd. Text not inserted!";
		}
	}
	else { // Split view
		m_orcEditor->setPlainText(text);
	}
}

void BaseView::setSco(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "DocumentView::setSco Current file is not a csd file. Text not inserted!";
			return;
		}
		QString csdText = getBasicText();
        if (csdText.contains("<CsScore") && csdText.contains("</CsScore>")) {
			int scoreTag = csdText.indexOf("<CsScore");
			QString preText = csdText.mid(0, csdText.indexOf(">",scoreTag) + 1);
			QString postText = csdText.mid(csdText.lastIndexOf("</CsScore>"));
			if (!text.startsWith("\n")) {
				text.prepend("\n");
			}
			if (!text.endsWith("\n")) {
				text.append("\n");
			}
			csdText = preText + text + postText;
			setBasicText(csdText);
		}
		else {
			qDebug() << "DocumentView::setSco Orchestra section not found in csd. Text not inserted!";
		}
	}
	else {
		m_scoreEditor->setPlainText(text);
	}
}

void BaseView::clearFileBText()
{
	m_filebEditor->clear();
}

void BaseView::appendFileBText(QString text)
{
	m_filebEditor->appendText(text);
}

void BaseView::setOptionsText(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "BaseView::setOptionsText Current file is not a csd file. Text not inserted!";
			return;
		}
		// It would be better just to select the CsOptions portion and change that but this should do the trick too.
		QString csdText = getBasicText();
        if (csdText.contains("<CsOptions>") && csdText.contains("</CsOptions>")) {
			QString preText = csdText.mid(0, csdText.indexOf("<CsOptions>") + 11);
			QString postText = csdText.mid(csdText.lastIndexOf("</CsOptions>"));
			if (!text.startsWith("\n")) {
				text.prepend("\n");
			}
			if (!text.endsWith("\n")) {
				text.append("\n");
			}
			csdText = preText + text + postText;
			setBasicText(csdText);
		}
		else {
			qDebug() << "DocumentView::setSco Orchestra section not found in csd. Text not inserted!";
		}
	}
	else {
		m_optionsEditor->setText(text);
		m_optionsEditor->moveCursor(QTextCursor::Start);
	}

}

void BaseView::setLadspaText(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "DocumentView::setLadspaText Current file is not a csd file. Text not inserted!";
			return;
		}
		QTextCursor cursor;
		cursor = m_mainEditor->textCursor();
		m_mainEditor->moveCursor(QTextCursor::Start);
		if (m_mainEditor->find("<csLADSPA>") && m_mainEditor->find("</csLADSPA>")) {
			QString curText = getBasicText();
			int index = curText.indexOf("<csLADSPA>");
			int endIndex = curText.indexOf("</csLADSPA>") + 11;
			if (curText.size() > endIndex + 1 && curText[endIndex + 1] == '\n') {
				endIndex++; // Include last line break
			}
			curText.remove(index, endIndex - index);
			curText.insert(index, text);
			setBasicText(curText);
			m_mainEditor->moveCursor(QTextCursor::Start);
		}
		else { //csLADSPA section not present, or incomplete
			m_mainEditor->find("<CsoundSynthesizer>"); //cursor moves there
			m_mainEditor->moveCursor(QTextCursor::EndOfLine);
			m_mainEditor->insertPlainText(QString("\n") + text + QString("\n"));
		}
	}
	else {
		qDebug() << "BaseView::setLadspaText() not implemented for split view";
	}
}

void BaseView::setCabbageText(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "DocumentView::setLadspaText Current file is not a csd file. Text not inserted!";
			return;
		}
		QTextCursor cursor;
		cursor = m_mainEditor->textCursor();
		m_mainEditor->moveCursor(QTextCursor::Start);
		if (m_mainEditor->find("<Cabbage>") && m_mainEditor->find("</Cabbage>")) {
			QString curText = getBasicText();
			int index = curText.indexOf("<Cabbage>");
			int endIndex = curText.indexOf("</Cabbage>") + 10;
			if (curText.size() > endIndex + 1 && curText[endIndex + 1] == '\n') {
				endIndex++; // Include last line break
			}
			curText.remove(index, endIndex - index);
			curText.insert(index, text);
			setBasicText(curText);
			m_mainEditor->moveCursor(QTextCursor::Start);
		}
		else { //Cabbage section not present, or incomplete
			m_mainEditor->find("<CsoundSynthesizer>"); //cursor moves there
			m_mainEditor->moveCursor(QTextCursor::EndOfLine);
			m_mainEditor->insertPlainText(QString("\n") + text + QString("\n"));
		}
	}
	else {
		qDebug() << "BaseView::setCabbageText() not implemented for split view";
	}
}



QString BaseView::getCabbageText()
{
	QString cabbageText = QString();
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "DocumentView::getLadspaText Current file is not a csd file.";
			return cabbageText;
		}
		QTextCursor cursor;
		//cursor = m_mainEditor->textCursor();
		//m_mainEditor->moveCursor(QTextCursor::Start); // is it necessary?
		if (m_mainEditor->find("<Cabbage>") && m_mainEditor->find("</Cabbage>")) {
			QString curText = getBasicText();

			int startIndex = curText.indexOf("<Cabbage>");
			int endIndex = curText.indexOf("</Cabbage>") + 10;
			cabbageText = curText.mid(startIndex, endIndex-startIndex);
			m_mainEditor->moveCursor(QTextCursor::Start);
		}
		else { //Cabbage section not present, or incomplete
			qDebug()<<"BaseView::getCabbageText() - no <Cabbage> section found.";
		}

	}
	else {
		qDebug() << "BaseView::getCabbageText() not implemented for split view";
	}
	return cabbageText;
}



void BaseView::setOtherCsdText(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "DocumentView::setOtherCsdText Current file is not a csd file. Text not inserted!";
			return;
		}
		QTextCursor cursor;
		cursor = m_mainEditor->textCursor();
		m_mainEditor->moveCursor(QTextCursor::Start);
		m_mainEditor->find("</CsoundSynthesizer>");
		m_mainEditor->insertPlainText(text); // TODO this is a bit flakey. What happens if there is already text there?
	}
	else {
		m_otherCsdEditor->setText(text);
		m_otherCsdEditor->moveCursor(QTextCursor::Start);
	}
}

void BaseView::setOtherText(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug() << "DocumentView::setOtherText Current file is not a csd file. Text not inserted!";
			return;
		}
		QTextCursor cursor;
		cursor = m_mainEditor->textCursor();
		m_mainEditor->moveCursor(QTextCursor::Start);
		m_mainEditor->insertPlainText(text); // TODO this is a bit flakey. What happens if there is already text there?
	}
	else {
		m_otherEditor->setText(text);
		m_otherEditor->moveCursor(QTextCursor::Start);
	}
}

void BaseView::setAppText(QString text)
{
	m_appEditor->setPlainText(text);
}

void BaseView::setAppProperties(AppProperties properties)
{
	m_appProperties = properties;
}

void BaseView::toggleLineArea()
{
	showLineArea(!m_mainEditor->lineAreaVisble());
}

void BaseView::toggleParameterMode()
{
	m_mainEditor->setParameterMode(!m_mainEditor->getParameterMode());
}

void BaseView::showLineArea(bool visible)
{
	m_mainEditor->setLineAreaVisble(visible);
}

QString BaseView::getBasicText()
{
	//   What Csound needs (no widgets, misc text, etc.)
	// TODO implement modes
	QString text;
	if (m_viewMode < 2) {
		text = m_mainEditor->toPlainText(); // csd without extra sections
		if (m_viewMode & 16) {
			text += m_filebEditor->toPlainText();
		}
	}
	else {
		text = m_orcEditor->toPlainText();
	}
	return text;
}

QString BaseView::getFullText()
{
	QString text;
	if (m_viewMode < 2) { // View is not split
		text = m_mainEditor->toPlainText();
		int closeIndex = text.lastIndexOf("</CsoundSynthesizer>");
		QString fileBText = getFileB();
		if (!fileBText.isEmpty()) {
			if (closeIndex > 0) { // Embedded files must be within synthesizer
				text.insert(closeIndex,fileBText);
			}
			else {
				text += getFileB();
			}
		}
	}
	else { // Split view
		QString sectionText;
		sectionText = m_otherEditor->toPlainText();
		if (!sectionText.isEmpty()) {
			text += sectionText;
		}
		text += "<CsoundSynthesizer>\n";
		sectionText = m_optionsEditor->toPlainText();
		if (!sectionText.isEmpty()) {
			text += "<CsOptions>\n" + sectionText + "</CsOptions>\n";
		}
		text += "<CsInstruments>\n" + m_orcEditor->toPlainText() + "</CsInstruments>\n";
		text += "<CsScore>\n" + m_scoreEditor->getPlainText() + "</CsScore>\n";
		sectionText = getFileB();
		if (!sectionText.isEmpty()) {
			text += sectionText;
		}
		sectionText = m_otherCsdEditor->toPlainText();
		if (!sectionText.isEmpty()) {
			text += sectionText;
		}
		text += "</CsoundSynthesizer>";
	}
	if (!text.endsWith("\n")) {
		text += "\n";
	}
	text += getAppText();
	return text;
}

QString BaseView::getOrc()
{
	QString text = "";
	if (m_viewMode < 2) { // A single editor (orc and sco are not split)
		text = m_mainEditor->toPlainText();
		text = text.mid(text.lastIndexOf("<CsInstruments>" )+ 15);
		text.remove(text.lastIndexOf("</CsInstruments>"), text.size());
	}
	else {
		text = m_orcEditor->toPlainText();
	}
	return text;
}

QString BaseView::getSco()
{
	QString text = "";
	if (m_viewMode < 2) {
		text = m_mainEditor->toPlainText();
		int scoreTag = text.lastIndexOf("<CsScore");
		text = text.mid(text.indexOf(">",scoreTag) + 1);
		text.remove(text.lastIndexOf("</CsScore>"), text.size());
	}
	else { // Split view
		text = m_scoreEditor->getPlainText();
	}
	return text;
}

QString BaseView::getOptionsText()
{
	// Returns text without tags
	QString text = "";
	if (m_viewMode < 2) {// A single editor (orc and sco are not split)
		QString edText = m_mainEditor->toPlainText();
		int index = edText.indexOf("<CsOptions>");
		if (index >= 0 && edText.contains("</CsOptions>")) {
			text = edText.mid(index + 11, edText.indexOf("</CsOptions>") - index - 11);
		}
	}
	else { //  Split view
		text = m_optionsEditor->toPlainText();
	}
	return text;
}

QString BaseView::getFileB()
{
	return m_filebEditor->toPlainText();
}

QString BaseView::getExtraCsdText()
{
	// All other tags like version and licence with tags. For text that is being edited in the text editor
	return m_otherCsdEditor->toPlainText();
}

QString BaseView::getExtraText()
{
	// Text outside any known tags. For text that is being edited in the text editor
	return m_otherEditor->toPlainText();
}

QString BaseView::getAppText()
{
	if (!m_appProperties.used) {
		return QString();
	}
	QString appText;
	QXmlStreamWriter s(&appText);
	s.setAutoFormatting(true);
	s.writeStartElement("CsApp");
	//  s.writeAttribute("type", getWidgetType());

	s.writeTextElement("appName", m_appProperties.appName);
	s.writeTextElement("targetDir", m_appProperties.targetDir);
	s.writeTextElement("author", m_appProperties.author);
	s.writeTextElement("version", m_appProperties.version);
	s.writeTextElement("date", m_appProperties.date);
	s.writeTextElement("email", m_appProperties.email);
	s.writeTextElement("website", m_appProperties.website);
	s.writeTextElement("instructions", m_appProperties.instructions);

	s.writeTextElement("autorun", m_appProperties.autorun ? "true" : "false");
	s.writeTextElement("showRun", m_appProperties.showRun ? "true" : "false");
	s.writeTextElement("saveState", m_appProperties.saveState ? "true" : "false");
	s.writeTextElement("runMode", QString::number((int)m_appProperties.runMode));
	s.writeTextElement("newParser", m_appProperties.newParser ? "true" : "false");

	s.writeTextElement("useSdk", m_appProperties.useSdk ? "true" : "false");

	s.writeTextElement("useCustomPaths", m_appProperties.useCustomPaths ? "true" : "false");
	s.writeTextElement("libDir", m_appProperties.libDir);
	s.writeTextElement("opcodeDir", m_appProperties.opcodeDir);

	s.writeEndElement();

	appText += "\n";
	return appText;
}

AppProperties BaseView::getAppProperties()
{
	return m_appProperties;
}


//void BaseView::setOpcodeNameList(QStringList list)
//{
//  m_highlighter.setOpcodeNameList(list);
//}

//void BaseView::setOpcodeTree(OpEntryParser *opcodeTree)
//{
//  m_opcodeTree = opcodeTree;
//}

void BaseView::hideAllEditors()
{
	m_mainEditor->hide();
	m_orcEditor->hide();
	m_scoreEditor->hide();
	m_optionsEditor->hide();
	m_filebEditor->hide();
	m_otherEditor->hide();
	m_otherCsdEditor->hide();
	m_widgetEditor->hide();
	m_appEditor->hide();
	for (int i = 0; i < 9; i++) {
		QSplitterHandle *h = splitter->handle(i);
		if (h) {
			h->hide();
		}
	}
}

void BaseView::clearUndoRedoStack()
{
	if (m_viewMode < 2) {
		m_mainEditor->document()->setModified(false);
		//		m_mainEditor->document()->clearUndoRedoStacks();
	} else {
		m_orcEditor->document()->setModified(false);
		m_scoreEditor->clearUndoRedoStacks();
		m_optionsEditor->document()->setModified(false);
		m_filebEditor->clearUndoRedoStacks();
		m_otherEditor->document()->setModified(false);
		m_otherCsdEditor->document()->setModified(false);
		m_widgetEditor->document()->setModified(false);
		m_appEditor->document()->setModified(false);
		//		m_orcEditor->document()->clearUndoRedoStacks();
		//		m_scoreEditor->clearUndoRedoStacks();
		//		m_optionsEditor->document()->clearUndoRedoStacks();
		//		m_filebEditor->clearUndoRedoStacks();
		//		m_otherEditor->document()->clearUndoRedoStacks();
		//		m_otherCsdEditor->document()->clearUndoRedoStacks();
		//		m_widgetEditor->document()->clearUndoRedoStacks();
	}
}
