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

#include <QRegularExpression>

// Matches a line that starts an instrument or opcode definition.
static const QRegularExpression &orchestraDefinitionRx()
{
	static const QRegularExpression defRx(
				QStringLiteral(R"(^[ \t]*(?:instr|opcode)\b)"),
				QRegularExpression::MultilineOption);
	return defRx;
}

// Position of the first line that starts an instrument or opcode definition at
// or after `from`, or -1 if there is none. Used to place global orchestra code
// (e.g. an ftgen) after the header and before the first definition.
static int firstDefinitionPosition(const QString &text, int from)
{
	auto it = orchestraDefinitionRx().globalMatch(text, from);
	if (it.hasNext()) {
		return it.next().capturedStart();
	}
	return -1;
}

static bool isDefinitionLine(const QString &line)
{
	return orchestraDefinitionRx().match(line).hasMatch();
}

BaseView::BaseView(QWidget *parent, OpEntryParser *opcodeTree) :
	QScrollArea(parent), m_opcodeTree(opcodeTree)
{
	QPalette p = palette();
	m_mainEditor = new TextEditLineNumbers(this);
    m_mainEditor->setProperty("name", "mainEditor");
	m_orcEditor = new TextEditor(this);
    m_orcEditor->setProperty("name", "orcEditor");
	m_scoreEditor = new ScoreEditor(this);
    m_scoreEditor->setProperty("name", "scoreEditor");
	m_optionsEditor = new TextEditor(this);
    m_optionsEditor->setProperty("name", "optionsEditor");
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
    editors << m_mainEditor << m_orcEditor << m_scoreEditor << m_optionsEditor << m_filebEditor
			<< m_otherEditor << m_otherCsdEditor << m_widgetEditor;
    for (QWidget *w : editors) {
        if (TextEditor *te = qobject_cast<TextEditor *>(w)) {
            connect(te, &TextEditor::fileDropped, this,
                    [this, te](QList<QUrl> urls, QPoint pos) {
                        m_lastDropEditor = te;
                        emit fileDropped(urls, pos);
                    });
        }
    }
    // The score editor embeds its own text editor; forward its drops too.
    connect(m_scoreEditor->textEditor(), &TextEditor::fileDropped, this,
            [this](QList<QUrl> urls, QPoint pos) {
                m_lastDropEditor = m_scoreEditor->textEditor();
                emit fileDropped(urls, pos);
            });
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
			qDebug()  << " File corrupt, not loading remaining CsFileB sections.";
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
		qDebug()  << "Not implemented for Split view.";
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
    //m_scoreEditor->setFont(font);
    m_scoreEditor->setFontPointSize(font.pointSize());
    m_optionsEditor->setFont(font);
	//  m_filebEditor->setFont(font);
	m_otherEditor->setFont(font);
	m_otherCsdEditor->setFont(font);
	m_widgetEditor->setFont(font);
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
}

void BaseView::setTabStopWidth(int width)
{
    m_mainEditor->setTabStopDistance(width);
    m_orcEditor->setTabStopDistance(width);
    m_scoreEditor->setTabStopWidth(width);
    m_optionsEditor->setTabStopDistance(width);
    //  m_filebEditor->setTabStopDistance(width);
    m_otherEditor->setTabStopDistance(width);
    m_otherCsdEditor->setTabStopDistance(width);
    m_widgetEditor->setTabStopDistance(width);
}

void BaseView::setTabIndents(bool indents)
{
	m_mainEditor->setTabIndents(indents);
}

void BaseView::setTabUseSpaces(bool useSpaces)
{
	m_mainEditor->setTabUseSpaces(useSpaces);
	m_orcEditor->setTabUseSpaces(useSpaces);
	m_scoreEditor->setTabUseSpaces(useSpaces);
	m_optionsEditor->setTabUseSpaces(useSpaces);
	m_otherEditor->setTabUseSpaces(useSpaces);
	m_otherCsdEditor->setTabUseSpaces(useSpaces);
	m_widgetEditor->setTabUseSpaces(useSpaces);
}

void BaseView::setTabSpaces(int spaces)
{
	m_mainEditor->setTabSpaces(spaces);
	m_orcEditor->setTabSpaces(spaces);
	m_scoreEditor->setTabSpaces(spaces);
	m_optionsEditor->setTabSpaces(spaces);
	m_otherEditor->setTabSpaces(spaces);
	m_otherCsdEditor->setTabSpaces(spaces);
	m_widgetEditor->setTabSpaces(spaces);
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
}

void BaseView::setColorVariables(bool color)
{
	m_highlighter.setColorVariables(color);
}

// orig:
// void BaseView::setBackgroundColor(QColor color)
// {
//     // before it was setPalette, but that does not work runtime.
//     m_mainEditor->setStyleSheet("QTextEdit { background-color: "+color.name() + "}");
// }

// void BaseView::setTextColor(QColor color)
// {
//     // before it was setPalette, but that does not work runtime.
//     m_mainEditor->setStyleSheet("QTextEdit { color: " + color.name() + "}");
// }

// void BaseView::setColors(QColor text, QColor background) {
//     auto sheet = QString("QTextEdit { color: %1; background-color: %2; }")
//             .arg(text.name())
//             .arg(background.name());
//     m_mainEditor->setStyleSheet(sheet);
// }

void BaseView::setBackgroundColor(QColor color)
{
    QPalette palette = m_mainEditor->palette();
    palette.setColor(QPalette::Base, color);
    m_mainEditor->setPalette(palette);
    m_mainEditor->setStyleSheet(""); // Clear stylesheet to ensure palette applies
}

void BaseView::setTextColor(QColor color)
{
    QPalette palette = m_mainEditor->palette();
    palette.setColor(QPalette::Text, color);
    m_mainEditor->setPalette(palette);
    m_mainEditor->setStyleSheet("");
}

void BaseView::setColors(QColor text, QColor background)
{
    QPalette palette = m_mainEditor->palette();
    palette.setColor(QPalette::Text, text);
    palette.setColor(QPalette::Base, background);
    m_mainEditor->setPalette(palette);
    m_mainEditor->setStyleSheet("");
}


void BaseView::setOrc(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug()  << "Current file is not a csd file. Text not inserted!";
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
			qDebug()  << "Orchestra section not found in csd. Text not inserted!";
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
			qDebug()  << "Current file is not a csd file. Text not inserted!";
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
			qDebug()  << "Orchestra section not found in csd. Text not inserted!";
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
			qDebug()  << "Current file is not a csd file. Text not inserted!";
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
			qDebug()  << "Orchestra section not found in csd. Text not inserted!";
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
			qDebug()  << "Current file is not a csd file. Text not inserted!";
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
		qDebug()  << "Not implemented for split view";
	}
}

void BaseView::setCabbageText(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug()  << "Current file is not a csd file. Text not inserted!";
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
		qDebug()  << "Not implemented for split view";
	}
}



QString BaseView::getCabbageText()
{
	QString cabbageText = QString();
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug()  << "Current file is not a csd file.";
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
			qDebug() << "No <Cabbage> section found.";
		}

	}
	else {
		qDebug()  << "Not implemented for split view";
	}
	return cabbageText;
}



void BaseView::setOtherCsdText(QString text)
{
	if (m_viewMode < 2) { // View is not split
		if (m_mode != 0) {
			qDebug()  << "Current file is not a csd file. Text not inserted!";
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
			qDebug()  << "Current file is not a csd file. Text not inserted!";
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
    m_mainEditor->setLineAreaVisible(visible);
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

// True when the cursor sits inside a double-quoted string on its line. A
// backslash escapes the following character, so \" does not toggle the state.
static bool cursorIsInsideQuotes(const QTextCursor &cursor)
{
	const QString line = cursor.block().text();
	const int column = cursor.positionInBlock();
	bool inside = false;
	for (int i = 0; i < column && i < line.size(); ++i) {
		const QChar c = line.at(i);
		if (c == QLatin1Char('\\')) {
			++i; // skip the escaped character
			continue;
		}
		if (c == QLatin1Char('"')) {
			inside = !inside;
		}
	}
	return inside;
}

void BaseView::insertPathAtCursor(const QString &path)
{
	// Insert at the cursor of the editor that received the drop. The cursor is
	// not moved by the drop, so this is the position the user was editing at.
	// Fall back to the main editor if the drop target is unknown.
	TextEditor *editor = m_lastDropEditor;
	if (!editor || !editor->isVisible()) {
		editor = m_mainEditor;
	}
	QTextCursor cursor = editor->textCursor();
	// If the cursor is already inside a quoted string, insert the bare path
	// instead of adding another pair of quotes.
	if (cursorIsInsideQuotes(cursor)) {
		cursor.insertText(path);
	}
	else {
		cursor.insertText(QStringLiteral("\"%1\"").arg(path));
	}
	editor->setTextCursor(cursor);
}

void BaseView::insertOrchestraGlobal(QString text)
{
	// Global orchestra code (the implicit "instr 0") lives after the header and
	// before the first instr/opcode definition. If the cursor is already in
	// that region, insert there; otherwise insert just before the first
	// definition so the code still ends up in the global region.
	auto insertAt = [](QTextCursor &cursor, const QString &document, int pos, QString text) {
		if (pos > 0 && pos <= document.size()
				&& document.at(pos - 1) != QLatin1Char('\n')) {
			text.prepend(QLatin1Char('\n'));
		}
		cursor.setPosition(pos);
		cursor.insertText(text);
		// Always keep at least one blank line between the inserted code and
		// the first instr/opcode definition.
		if (isDefinitionLine(cursor.block().text())) {
			cursor.insertText(QStringLiteral("\n"));
		}
	};
	if (m_viewMode < 2) { // Unified view: the whole document lives in the main editor
		QTextCursor cursor = m_mainEditor->textCursor();
		const QString document = m_mainEditor->toPlainText();
		const int orcStart = document.indexOf(QStringLiteral("<CsInstruments>"));
		const int orcEnd = document.indexOf(QStringLiteral("</CsInstruments>"));
		int globalStart;
		int globalEnd;
		if (orcStart >= 0 && orcEnd > orcStart) {
			globalStart = orcStart;
			const int defPos = firstDefinitionPosition(document, orcStart);
			globalEnd = (defPos >= 0 && defPos < orcEnd) ? defPos : orcEnd;
		}
		else {
			// Orchestra-only file (or no tags): the whole text is the orchestra.
			globalStart = 0;
			const int defPos = firstDefinitionPosition(document, 0);
			globalEnd = defPos >= 0 ? defPos : document.size();
		}
		const int cursorPos = cursor.position();
		const int insertPos = (cursorPos >= globalStart && cursorPos <= globalEnd)
				? cursorPos : globalEnd;
		insertAt(cursor, document, insertPos, text);
		m_mainEditor->setTextCursor(cursor);
	}
	else { // Split view: the orchestra has its own editor.
		QTextCursor cursor = m_orcEditor->textCursor();
		const QString document = m_orcEditor->toPlainText();
		const int defPos = firstDefinitionPosition(document, 0);
		const int globalEnd = defPos >= 0 ? defPos : document.size();
		const int cursorPos = cursor.position();
		const int insertPos = (cursorPos >= 0 && cursorPos <= globalEnd)
				? cursorPos : globalEnd;
		insertAt(cursor, document, insertPos, text);
		m_orcEditor->setTextCursor(cursor);
	}
}

void BaseView::insertAtScoreStart(QString text)
{
	if (m_viewMode < 2) { // Unified view
		QTextCursor cursor = m_mainEditor->textCursor();
		const QString document = m_mainEditor->toPlainText();
		const int tagIndex = document.indexOf(QStringLiteral("<CsScore"));
		if (tagIndex >= 0) {
			const int tagEnd = document.indexOf(QLatin1Char('>'), tagIndex);
			int insertPos = tagEnd >= 0 ? document.indexOf(QLatin1Char('\n'), tagEnd) : -1;
			insertPos = insertPos >= 0 ? insertPos + 1 : tagEnd + 1;
			cursor.setPosition(insertPos);
		}
		else {
			// No score section: append at the end of the document.
			cursor.movePosition(QTextCursor::End);
		}
		cursor.insertText(text);
		m_mainEditor->setTextCursor(cursor);
	}
	else { // Split view: the score has its own editor.
		m_scoreEditor->insertTextAtStart(text);
	}
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
		//		m_orcEditor->document()->clearUndoRedoStacks();
		//		m_scoreEditor->clearUndoRedoStacks();
		//		m_optionsEditor->document()->clearUndoRedoStacks();
		//		m_filebEditor->clearUndoRedoStacks();
		//		m_otherEditor->document()->clearUndoRedoStacks();
		//		m_otherCsdEditor->document()->clearUndoRedoStacks();
		//		m_widgetEditor->document()->clearUndoRedoStacks();
	}
}
