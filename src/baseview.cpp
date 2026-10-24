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
	m_mainEditor = new TextEditLineNumbers(this);
    m_mainEditor->setProperty("name", "mainEditor");
    connect(m_mainEditor, &TextEditor::fileDropped, this,
            [this](QList<QUrl> urls, QPoint pos) {
                emit fileDropped(urls, pos);
            });

    QStackedLayout *l = new QStackedLayout(this);  // Deleted with parent
    l->addWidget(m_mainEditor);
    setLayout(l);
	m_mode = EDIT_CSOUND_MODE;
    m_highlighter.setOpcodeNameList(opcodeTree->opcodeNameList());
	m_highlighter.setDocument(m_mainEditor->document());
}

BaseView::~BaseView()
{
}

void BaseView::setFullText(QString text, bool goToTop)
{
	// Load Embedded Files ------------------------
	// Keep them out of the editable text and the scanner; getFullText() puts
	// them back when the document is saved or played.
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
	m_mainEditor->setUndoRedoEnabled(false);
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::Document);
	cursor.insertText(text);
	m_mainEditor->setTextCursor(cursor);
	if (goToTop) {
		m_mainEditor->moveCursor(QTextCursor::Start);
	}
	m_mainEditor->setUndoRedoEnabled(true);
}

void BaseView::setBasicText(QString text)
{
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::Document);
	cursor.insertText(text);
	m_mainEditor->setTextCursor(cursor);
}

void BaseView::setFileType(editor_mode_t mode)
{
	m_highlighter.setMode(mode);
	m_mode = mode;
}

void BaseView::setFont(QFont font)
{
	m_mainEditor->setFont(font);
	// The tab stop is in pixels, so it depends on the font.
	applyTabSize();
}

void BaseView::setFontPointSize(float size)
{
	m_mainEditor->setFontPointSize(size);
	// The tab stop is in pixels, so it depends on the font size.
	applyTabSize();
}

/**
 * Set the tab size in spaces. It is used both for the number of spaces the Tab
 * key inserts (see TextEditor::setTabSpaces) and for the display width of tab
 * characters, so files indented with tab characters and files indented with
 * spaces line up the same way.
 */
void BaseView::setTabSize(int tabSize)
{
	m_tabSize = tabSize > 0 ? tabSize : 1;
	applyTabSize();
}

void BaseView::applyTabSize()
{
	m_mainEditor->setTabStopDistance(
				tabStopDistanceForFont(m_mainEditor->font(), m_tabSize));
}

void BaseView::setTabUseSpaces(bool useSpaces)
{
	m_mainEditor->setTabUseSpaces(useSpaces);
}

void BaseView::setTabSpaces(int spaces)
{
	m_mainEditor->setTabSpaces(spaces);
}

void BaseView::setLineWrapMode(QTextEdit::LineWrapMode mode)
{
	m_mainEditor->setLineWrapMode(mode);
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
    // Clear the stylesheet first: re-polishing it after setting the palette
    // can reset the widget palette to the application colours.
    m_mainEditor->setStyleSheet("");
    QPalette palette = m_mainEditor->palette();
    palette.setColor(QPalette::Base, color);
    m_mainEditor->setPalette(palette);
    m_mainEditor->setEditorBackground(color);
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
    // Clear the stylesheet before setting the palette; doing it afterwards
    // can reset the palette again.
    m_mainEditor->setStyleSheet("");
    QPalette palette = m_mainEditor->palette();
    palette.setColor(QPalette::Text, text);
    palette.setColor(QPalette::Base, background);
    m_mainEditor->setPalette(palette);
    m_mainEditor->setEditorBackground(background);
}


void BaseView::setOrc(QString text)
{
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

void BaseView::setSco(QString text)
{
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

void BaseView::clearFileBText()
{
	m_filebText.clear();
}

void BaseView::appendFileBText(QString text)
{
	m_filebText += text;
	if (!m_filebText.endsWith(QLatin1Char('\n'))) {
		m_filebText += QLatin1Char('\n');
	}
}

void BaseView::setOptionsText(QString text)
{
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

void BaseView::setLineNumberContrast(int contrast)
{
    m_lineNumberContrast = qBound(0, contrast, 100);
    updateLineAreaColors();
}

void BaseView::setEditorPadding(int padding)
{
    m_mainEditor->setEditorPadding(padding);
}

void BaseView::updateLineAreaColors()
{
    const auto defaultFormat = m_highlighter.getFormat(QStringLiteral("default"));
    QColor foreground = defaultFormat.foreground().color();
    QColor background = defaultFormat.background().color();
    if (foreground.lightness() < background.lightness()) {
        // light
        foreground = foreground.lighter(120);
        background = background.darker(100);
    }
    else {
        // dark
        foreground = foreground.darker(140);
        background = background.lighter(125);
    }
    m_mainEditor->setLineAreaColors(foreground, background, m_lineNumberContrast);
}

QString BaseView::getBasicText()
{
	// What Csound needs: no widgets, presets or embedded files.
	return m_mainEditor->toPlainText();
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
	TextEditor *editor = m_mainEditor;
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

void BaseView::insertAtScoreStart(QString text)
{
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

QString BaseView::getFullText()
{
	QString text = m_mainEditor->toPlainText();
	const int closeIndex = text.lastIndexOf("</CsoundSynthesizer>");
	const QString fileBText = getFileB();
	if (!fileBText.isEmpty()) {
		if (closeIndex > 0) { // Embedded files must be within synthesizer
			text.insert(closeIndex, fileBText);
		}
		else {
			text += fileBText;
		}
	}
	if (!text.endsWith("\n")) {
		text += "\n";
	}
	return text;
}

QString BaseView::getOrc()
{
	QString text = m_mainEditor->toPlainText();
	text = text.mid(text.lastIndexOf("<CsInstruments>" )+ 15);
	text.remove(text.lastIndexOf("</CsInstruments>"), text.size());
	return text;
}

QString BaseView::getSco()
{
	QString text = m_mainEditor->toPlainText();
	const int scoreTag = text.lastIndexOf("<CsScore");
	text = text.mid(text.indexOf(">",scoreTag) + 1);
	text.remove(text.lastIndexOf("</CsScore>"), text.size());
	return text;
}

QString BaseView::getOptionsText()
{
	// Returns text without tags
	QString text = "";
	const QString edText = m_mainEditor->toPlainText();
	const int index = edText.indexOf("<CsOptions>");
	if (index >= 0 && edText.contains("</CsOptions>")) {
		text = edText.mid(index + 11, edText.indexOf("</CsOptions>") - index - 11);
	}
	return text;
}

QString BaseView::getFileB()
{
	return m_filebText;
}

//void BaseView::setOpcodeNameList(QStringList list)
//{
//  m_highlighter.setOpcodeNameList(list);
//}

//void BaseView::setOpcodeTree(OpEntryParser *opcodeTree)
//{
//  m_opcodeTree = opcodeTree;
//}

void BaseView::clearUndoRedoStack()
{
	m_mainEditor->document()->setModified(false);
	//		m_mainEditor->document()->clearUndoRedoStacks();
}
