/*
	Copyright (C) 2010 Andres Cabrera
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

#include "documentview.h"
#include "findreplace.h"
#include "opentryparser.h"
#include "node.h"
#include "types.h"

#include "highlighter.h"
#include "texteditor.h"


static const QStringList tagWords = {"CsInstruments", "CsScore", "CsoundSynthesizer", "CsOptions"};

DocumentView::DocumentView(QWidget * parent, OpEntryParser *opcodeTree) :
	BaseView(parent,opcodeTree)
{
	m_autoComplete = true;

	m_hoverWidget = new HoverWidget(m_mainEditor);
	m_hoverText= new QLabel("Hello", m_hoverWidget);
	m_hoverText->show();
	m_hoverText->setStyleSheet(
				"QLabel {"
                "  border: 1px solid black;"
                "  border-radius: 4px;"
                "  padding: 2px;"
                "  background-color: #eaeac5;"
                "  color: #202020; "
				"};");
	m_hoverText->setWordWrap(true);
	m_hoverWidget->hide();

	for (int i = 0; i < editors.size(); i++) {
		if (editors[i]!=m_filebEditor) { // FilebEditor does not have this slot
            connect(editors[i], SIGNAL(textChanged()), this, SLOT(setModified()));
		}
		splitter->addWidget(editors[i]);
		editors[i]->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);
		editors[i]->setContextMenuPolicy(Qt::CustomContextMenu);
		connect(editors[i], SIGNAL(customContextMenuRequested(QPoint)),
				this, SLOT(createContextMenu(QPoint)));
	}
	connect(m_orcEditor, SIGNAL(textChanged()), this, SLOT(textChanged()));
	connect(m_orcEditor, SIGNAL(cursorPositionChanged()),
            this, SLOT(syntaxCheck()));
	setFocusProxy(m_mainEditor);  // for comment action from main application
	internalChange = false;

    //  m_highlighter = new Highlighter();
	connect(m_mainEditor, SIGNAL(textChanged()),
			this, SLOT(textChanged()));
	connect(m_mainEditor, SIGNAL(cursorPositionChanged()),
			this, SLOT(updateContext()));
	connect(m_mainEditor, SIGNAL(cursorPositionChanged()),
			this, SLOT(syntaxCheck()));
	connect(m_mainEditor, SIGNAL(escapePressed()),
			this, SLOT(escapePressed()));
	connect(m_mainEditor, SIGNAL(newLine()),
			this, SLOT(indentNewLine()));
	connect(m_mainEditor, SIGNAL(requestIndent()),
			this, SLOT(indent()));
	connect(m_mainEditor, SIGNAL(requestUnindent()),
			this, SLOT(unindent()));
	connect(m_mainEditor, SIGNAL(tabPressed()),
			this, SLOT(nextParameter()));
	connect(m_mainEditor, SIGNAL(backtabPressed()),
			this, SLOT(prevParameter()));
	connect(m_mainEditor, SIGNAL(arrowPressed()),
			this, SLOT(exitParameterMode()));
	connect(m_mainEditor, SIGNAL(enterPressed()),
			this, SLOT(finishParameterMode()));
	connect(m_mainEditor, SIGNAL(showParameterInfo()),
			this, SLOT(showHoverText()));
	connect(m_mainEditor, SIGNAL(requestParameterModeExit()),
			this, SLOT(exitParameterMode()));
	connect(m_mainEditor,SIGNAL(arrowPressed()), this, SLOT(restoreCursorPosition()) );

	//TODO put this for line reporting for score editor
	//  connect(scoreEditor, SIGNAL(textChanged()),
	//          this, SLOT(syntaxCheck()));
	//  connect(scoreEditor, SIGNAL(cursorPositionChanged()),
	//          this, SLOT(syntaxCheck()));

	errorMarked = false;
	m_isModified = false;

	syntaxMenu = new MySyntaxMenu(m_mainEditor);
	//  syntaxMenu->setFocusPolicy(Qt::NoFocus);
	syntaxMenu->setAutoFillBackground(true);
    // QPalette p = syntaxMenu->palette();
    // p.setColor(QPalette::WindowText, Qt::blue);
    // p.setColor(static_cast<QPalette::ColorRole>(9), QColor("#eaeac5")); // was: Qt::yellow
    // syntaxMenu->setPalette(p);
	connect(syntaxMenu,SIGNAL(keyPressed(QString)),
			m_mainEditor, SLOT(insertPlainText(QString)));

	setViewMode(1);
	setViewMode(0);  // To force a change
	setAcceptDrops(true);

	m_oldCursorPosition = -1; // 0 or positive, if cursor needs to be moved there
    markCurrentPosition();

}

DocumentView::~DocumentView()
{
	disconnect(this, 0,0,0);
}

bool DocumentView::isModified()
{
	return m_isModified;
}

void DocumentView::markCurrentPosition() {
    int pos = this->currentLine();
    cursorPositions.push_back(pos);
    if(cursorPositions.size() > 1000) {
        cursorPositions.pop_front();
    }
}

bool DocumentView::childHasFocus()
{
	if (this->hasFocus() || m_scoreEditor->hasFocus()
			|| m_optionsEditor->hasFocus()
			|| m_otherEditor->hasFocus()
			|| m_otherCsdEditor->hasFocus()
			|| m_widgetEditor->hasFocus()) {
		return true;
	}
	return false;
}

void DocumentView::print(QPrinter *printer)
{
	m_mainEditor->print(printer);
}

void DocumentView::updateContext()
{
    // this code is too expensive to be run at EACH keystroke. We need to think of something better
    // Until then I am disabling it (EM, Nov. 21)
    return;
	QStringList contextStart;
	contextStart << "<CsInstruments>" << "<CsScore" << "<CsOptions>";
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::LineUnderCursor);
	QString line = cursor.selection().toPlainText().simplified();
	while (!cursor.atStart()) {
		foreach(QString startText, contextStart) {
			if (line.startsWith(startText)) {
				m_currentContext = contextStart.indexOf(startText) + 1;
				break;
			}
		}
		cursor.movePosition(QTextCursor::Up);
		cursor.select(QTextCursor::BlockUnderCursor);
		line = cursor.selection().toPlainText();
		cursor.movePosition(QTextCursor::StartOfBlock);
	}
	if (m_currentContext == DocumentView::ORC_CONTEXT) { // Instrument section
		QString endText = "</CsInstruments>";
		QTextCursor linecursor = cursor;
		linecursor.select(QTextCursor::LineUnderCursor);
		line = linecursor.selection().toPlainText();
		linecursor.movePosition(QTextCursor::EndOfLine);
		while (!linecursor.atEnd() && !line.contains(endText)) {
			cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
			cursor.movePosition(QTextCursor::EndOfLine, QTextCursor::KeepAnchor);
			linecursor = cursor;
			linecursor.select(QTextCursor::LineUnderCursor);
			line = linecursor.selection().toPlainText();
			linecursor.movePosition(QTextCursor::EndOfLine);
		}
		QString orc = cursor.selection().toPlainText();
        updateOrcContext(orc);
	}
}

void DocumentView::updateOrcContext(QString orc)
{
    (void) orc;
	// TODO: add string as context
	QStringList innerContextStart;
	innerContextStart << "instr" << "opcode";
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::LineUnderCursor);
	QString line = cursor.selection().toPlainText().trimmed();
    while (!cursor.atStart()) {
		foreach(QString startText, innerContextStart) {
			if (line.startsWith(startText)) {
				break;
			}
		}
		cursor.movePosition(QTextCursor::Up);
		cursor.select(QTextCursor::BlockUnderCursor);
		line = cursor.selection().toPlainText().trimmed();
		cursor.movePosition(QTextCursor::StartOfBlock);
	}
	cursor.movePosition(QTextCursor::NextBlock);
	QString endText = "endin";
	QTextCursor linecursor = cursor;
	linecursor.select(QTextCursor::LineUnderCursor);
	line = linecursor.selection().toPlainText().trimmed();
	linecursor.movePosition(QTextCursor::EndOfLine);
	while (!linecursor.atEnd() && !line.startsWith(endText)) {
		cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
		cursor.movePosition(QTextCursor::EndOfLine, QTextCursor::KeepAnchor);
		linecursor = cursor;
		linecursor.select(QTextCursor::LineUnderCursor);
		line = linecursor.selection().toPlainText().trimmed();
		linecursor.movePosition(QTextCursor::EndOfLine);
	}
	QString instr = cursor.selection().toPlainText();
	QStringList lines = instr.split("\n", QString::SkipEmptyParts);

	m_localVariables.clear();
	foreach(QString line, lines) {
		if (line.trimmed().startsWith(";")) {
			continue;
		}
		QStringList words = line.split(QRegExp("[\\s,]"), QString::SkipEmptyParts);
		int opcodeIndex = -1;
		foreach(QString word, words) {
			if (m_opcodeTree->isOpcode(word)) {
				opcodeIndex = words.indexOf(word);
			}
		}
		if(opcodeIndex > 0) {
			words = words.mid(0, opcodeIndex);
			foreach(QString word, words) {
				if (word.at(0).isLetter()) {
					m_localVariables << word.remove(QRegExp("[\\(\\)]"));
				}
			}
		}
	}
	m_localVariables.removeDuplicates();
	m_localVariables.sort();
}

void DocumentView::nextParameter()
{
	QChar character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	// First move forward a word
	while(!m_mainEditor->textCursor().atBlockEnd() &&
		  !(character.isSpace() || character == ',' || character == '(' || character == ')'
			|| character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::NextCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	// Then move forward all white space
	while(!m_mainEditor->textCursor().atBlockEnd() &&
		  (character.isSpace() || character == ',' || character == '(' || character == ')'
		   || character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::NextCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	if (m_mainEditor->textCursor().atBlockStart()) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::WordUnderCursor);
	if (cursor.selectedText() == "\"") {
		cursor.movePosition(QTextCursor::NextCharacter);
		while (!(cursor.selectedText().endsWith("\"") || cursor.atBlockEnd())) {
			cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
		}
		if (cursor.selectedText().endsWith("\"")) {
			cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
		}
	}
	m_mainEditor->blockSignals(true); // To avoid triggering the position changed action which hides the text cursor and disables parameter mode
	m_mainEditor->setTextCursor(cursor);
	m_mainEditor->blockSignals(false);
	showHoverText();
}

void DocumentView::prevParameter()
{
	if (!m_mainEditor->textCursor().atBlockStart()) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
	}
	QChar character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	while(!m_mainEditor->textCursor().atBlockStart() &&
		  !(character.isSpace() || character == ',' || character == '(' || character == ')'
			|| character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	while(!m_mainEditor->textCursor().atBlockStart() &&
		  (character.isSpace() || character == ',' || character == '(' || character == ')'
		   || character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::WordUnderCursor);
	if (cursor.selectedText().startsWith("\"")) {
		cursor.movePosition(QTextCursor::PreviousCharacter);
		while (!(cursor.selectedText().startsWith("\"") || cursor.atBlockEnd())) {
			cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
		}
		if (cursor.selectedText().startsWith("\"")) {
			cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
		}
	}
	m_mainEditor->blockSignals(true); // To avoid triggering the position changed action which hides the text cursor and disables parameter mode
	m_mainEditor->setTextCursor(cursor);
	m_mainEditor->blockSignals(false);
	showHoverText();
}

void DocumentView::showHoverText()
{
	QTextCursor cursor  = m_mainEditor->textCursor();
	QRect cursorRect = m_mainEditor->cursorRect();
	updateHoverText(cursorRect.x(), cursorRect.y(), cursor.selectedText());
}

void DocumentView::hideHoverText()
{
	m_hoverWidget->hide();
}

void DocumentView::updateHoverText(int x, int y, QString text)
{
	QString displayText = m_currentOpcodeText;
	if (!text.isEmpty()) {
		displayText.replace(text, "<b>" + text + "</b>");
	}
	m_hoverText->setText(displayText);
	m_hoverText->adjustSize();
	QRect textRect = m_hoverText->contentsRect();
	int textWidth = textRect.width() + 10;
	if (textRect.width() + 10 > this->width()) {
		textRect.setWidth(this->width());
		textWidth = this->width();
	}
	int xoffset = 0;
	if (m_currentOpcodeText.contains(text)) {
		xoffset = 10 + textRect.width() * (m_currentOpcodeText.indexOf(text)/(float) (m_currentOpcodeText.indexOf("<br />") + 5));
	}
	if (xoffset > x) {
		xoffset = x;
	} else if (textWidth + x - xoffset > this->width()) {
		xoffset = - (this->width() - (textWidth + x - xoffset));
	}
	m_hoverWidget->setGeometry(x - xoffset, y-textRect.height() - 10, textWidth, textRect.height() + 10);

	m_hoverWidget->show();
}

void DocumentView::setModified(bool mod)
{
    // auto sender = static_cast<QTextEdit*>(this->sender());
    // auto senderName = sender != nullptr ? sender->property("name").toString() : "";
    // QDEBUG << "sender: " << senderName << "modified:"<<mod;
    emit contentsChanged();
	m_isModified = mod;
}

void DocumentView::insertText(QString text, int section)
{
	if (section == -1 || section < 0) {
		section = 0;  // TODO implment for multiple views
	}
	QTextCursor cursor;
	switch(section) {
	case 0:
		cursor = m_mainEditor->textCursor();
		cursor.insertText(text);
		m_mainEditor->setTextCursor(cursor);
		break;
		//  case 1:
		//    orcEditor;
		//    break;
		//  case 2:
		//    scoreEditor;
		//    break;
		//  case 3:
		//    optionsEditor;
		//    break;
		//  case 4:
		//    filebEditor;
		//    break;
		//  case 5:
		//    versionEditor;
		//    break;
		//  case 6:
		//    licenceEditor;
		//    break;
		//  case 7:
		//    otherEditor;
		//    break;
		//  case 8:
		//    widgetEditor;
		//    break;
		//  case 9:
		//    ladspaEditor;
		//    break;
		//  case 10:
		//    break;
	default:
		qDebug() <<"Section " << section << " not implemented.";
	}
}

void DocumentView::setAutoComplete(bool autoComplete)
{
	m_autoComplete = autoComplete;
}

void DocumentView::setAutoParameterMode(bool autoParameterMode)
{
	m_autoParameterMode = autoParameterMode;
}

void DocumentView::setViewMode(int mode)
{
	if (m_viewMode == mode)
		return;
	QString fullText = getFullText();
	m_viewMode = mode;
	setFullText(fullText); // Update text for new mode
	hideAllEditors();

	// TODO implement modes properly
	switch (m_viewMode) {
	case 0: // csd without extra sections
		m_mainEditor->show();
		m_highlighter.setDocument(m_mainEditor->document());
        break;
	case 1: // full plain text
		m_mainEditor->show();
		m_highlighter.setDocument(m_mainEditor->document());

		break;
	default:
		m_highlighter.setDocument(m_orcEditor->document());
		m_orcEditor->setVisible(m_viewMode & 2);
		m_scoreEditor->setVisible(m_viewMode & 4);
		m_optionsEditor->setVisible(m_viewMode & 8);
		m_filebEditor->setVisible(m_viewMode & 16);
		m_otherEditor->setVisible(m_viewMode & 32);
		m_otherCsdEditor->setVisible(m_viewMode & 64);
		m_widgetEditor->setVisible(m_viewMode & 128);
		m_appEditor->setVisible(m_viewMode & 256);
        auto defaultFormat = m_highlighter.getFormat("default");
        auto sheet =  QString("QTextEdit { color: %1; background-color: %2}")
                .arg(defaultFormat.foreground().color().name())
                .arg(defaultFormat.background().color().name());
        if(m_viewMode & 2) {
            m_orcEditor->setStyleSheet(sheet);
        }

	}
}

QString DocumentView::getSelectedText(int section)
{
	if (section < 0) {
		section = 0;  // TODO implment for multiple views
	}
	QString text;
	switch(section) {
	case 0:
		text = m_mainEditor->textCursor().selectedText();
		break;
	case 1:
		text = m_orcEditor->textCursor().selectedText();
		break;
	case 2:
		text = m_scoreEditor->getSelection();
		break;
	case 3:
		text = m_optionsEditor->textCursor().selectedText();
		//    ;
		break;
	case 4:
		//    filebEditor;
		break;
	case 5:
		text = m_otherEditor->textCursor().selectedText();
		break;
	case 6:
		text = m_otherCsdEditor->textCursor().selectedText();
		break;
	case 7:
		text = m_widgetEditor->textCursor().selectedText();
		break;
	case 8:
		text = m_appEditor->textCursor().selectedText();
		break;
	default:
		qDebug() << "Section " << section << " not implemented.";
	}
	return text;
}

QString DocumentView::getMacWidgetsText()
{
	// With tags including presets. For text that is being edited in the text editor
	// Includes presets text
	qDebug() << "Not implemented and will crash!";
    return "Not implemented.";
}

QString DocumentView::getWidgetsText()
{
	// With tags including presets, in new xml format. For text that is being edited in the text editor
	// Includes presets text
	qDebug() << "Not implemented and will crash!";
    return "Not implemented.";
}

int DocumentView::getViewMode()
{
	return m_viewMode;
}

int DocumentView::currentLine()
{
	// Returns text without tags
	int line = -1;
	if (m_viewMode < 2) {// A single editor (orc and sco are not split)
		QTextCursor cursor = m_mainEditor->textCursor();
		line = cursor.blockNumber() + 1;
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		QWidget *w = this->focusWidget(); // Gives last child of this widget that has had focus.
		if (w == m_scoreEditor || w == m_filebEditor) {
			qDebug() << "Not implemented for score and fileb editor.";
		}
		else if (w != 0 && editors.contains(w)) { // Somehow this widget can sometimes be invalid... so must check if it is one of the editors
			QTextCursor cursor = static_cast<TextEditor *>(w)->textCursor();
			line = cursor.blockNumber() + 1;
		}
	}
	return line;
}

QString DocumentView::wordUnderCursor()
{
	QString word;
	if (m_viewMode < 2) {// A single editor (orc and sco are not split)
		QTextCursor cursor = m_mainEditor->textCursor();
		word = cursor.selectedText();
		if (word.isEmpty()) {
			cursor.select(QTextCursor::WordUnderCursor);
			word = cursor.selectedText();
		}
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
	return word;
}

QString DocumentView::getActiveSection()
{
	// Will return all document if there are no ## boundaries (for any kind of file)
	QString section;
	if (m_viewMode < 2) {
		if (m_mode == EDIT_PYTHON_MODE) {
			QTextCursor cursor = m_mainEditor->textCursor();
			m_oldCursorPosition = cursor.position(); // to move back there on next keypress
			cursor.select(QTextCursor::LineUnderCursor);
			bool sectionStart = cursor.selectedText().simplified().startsWith("##");
			while (!sectionStart && !cursor.anchor() == 0) {
				cursor.movePosition(QTextCursor::PreviousBlock);
				cursor.select(QTextCursor::LineUnderCursor);
				sectionStart = cursor.selectedText().simplified().startsWith("##");
			}
			int start = cursor.anchor();
			cursor = m_mainEditor->textCursor();
			cursor.movePosition(QTextCursor::NextBlock);
			cursor.select(QTextCursor::LineUnderCursor);
			bool sectionEnd = cursor.selectedText().simplified().startsWith("##");
			while (!sectionEnd && !cursor.atEnd()) {
				cursor.movePosition(QTextCursor::NextBlock);
				cursor.select(QTextCursor::LineUnderCursor);
				sectionEnd = cursor.selectedText().simplified().startsWith("##");
			}
			cursor.movePosition(QTextCursor::EndOfLine);
			cursor.setPosition(start, QTextCursor::KeepAnchor);
			m_mainEditor->setTextCursor(cursor);
			section = cursor.selectedText();
			section.replace(QChar(0x2029), QChar('\n'));
		} else if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE) {
			QTextCursor cursor = m_mainEditor->textCursor();
			m_oldCursorPosition = cursor.position(); // to move back there on next keypress
			cursor.select(QTextCursor::LineUnderCursor);
			QString text = cursor.selectedText().simplified();
			bool sectionStart = text.startsWith("instr") || text.startsWith(";;");
			while (!sectionStart && !cursor.anchor() == 0) {
				cursor.movePosition(QTextCursor::PreviousBlock);
				cursor.select(QTextCursor::LineUnderCursor);
				text = cursor.selectedText().simplified();
				sectionStart = text.startsWith("instr") || text.startsWith(";;");
			}
			int start = cursor.anchor();
			cursor = m_mainEditor->textCursor();
			cursor.movePosition(QTextCursor::NextBlock);
			cursor.select(QTextCursor::LineUnderCursor);
			text = cursor.selectedText().simplified();
			bool sectionEnd = text.startsWith("endin") || text.startsWith(";;");
			while (!sectionEnd && !cursor.atEnd()) {
				cursor.movePosition(QTextCursor::NextBlock);
				cursor.select(QTextCursor::LineUnderCursor);
				text = cursor.selectedText().simplified();
				sectionEnd = text.startsWith("endin") || text.startsWith(";;");
			}
			cursor.movePosition(QTextCursor::EndOfLine);
			cursor.setPosition(start, QTextCursor::KeepAnchor);
			m_mainEditor->setTextCursor(cursor);
			section = cursor.selectedText();
			section.replace(QChar(0x2029), QChar('\n'));
		}
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
	return section;
}

QString DocumentView::getActiveText()
{
	QString selection;
	if (m_viewMode < 2) {
		QTextCursor cursor = m_mainEditor->textCursor();
		selection = cursor.selectedText();
		if (selection == "") {
			cursor.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
			cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
			selection = cursor.selectedText();
		}
		selection.replace(QChar(0x2029), QChar('\n'));
		if (!selection.endsWith("\n")) {
			selection.append("\n");
		}
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
	return selection;
}

void DocumentView::syntaxCheck()
{
	// TODO implment for multiple views

	TextEditor *editor;
	if (m_viewMode < 2) {
		// TODO rather than check this, store the current active one?
		editor = m_mainEditor;
	}
	else { //  Split view
		editor = (TextEditor *) sender();
	}

	m_currentEditor = editor ; // for parenthesis functions

	QTextCursor cursor = editor->textCursor();

	// matchparenthesis. Code by Geir Vatterkar see https://doc.qt.io/archives/qq/QtQuarterly31.pdf
	// some corrections by Heinz van Saanen http://qt-apps.org/content/show.php/CLedit?content=125532 ; comments: http://www.qtcentre.org/archive/index.php/t-31084.html

	QList<QTextEdit::ExtraSelection> selections;
	editor->setExtraSelections(selections);

	TextBlockData *data = static_cast<TextBlockData *>(editor->textCursor().block().userData());

	if (data) {
		QVector<ParenthesisInfo *> infos = data->parentheses();

		int pos = editor->textCursor().block().position();
		for (int i = 0; i < infos.size(); ++i) {
			ParenthesisInfo *info = infos.at(i);

			int curPos = editor->textCursor().position() - editor->textCursor().block().position();
			if (info->position == curPos && info->character == '(') {
				if (matchLeftParenthesis(editor->textCursor().block(), i + 1, 0))
					createParenthesisSelection(pos + info->position, true); // found, mark as pair
				else
					createParenthesisSelection(pos + info->position, false); // no pair, mark as single
			} else if (info->position == curPos - 1 && info->character == ')') {
				if (matchRightParenthesis(editor->textCursor().block(), i - 1, 0))
					createParenthesisSelection(pos + info->position, true);
				else
					createParenthesisSelection(pos + info->position, false);
			}
		}
	}

	// syntax check
	cursor.movePosition(QTextCursor::EndOfWord, QTextCursor::MoveAnchor);
	cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
	QStringList words = cursor.selectedText().split(QRegExp("\\b"),
													QString::SkipEmptyParts);
	bool showHover = false;
	for(int i = 0; i < words.size(); i++) {
		QString word = words[words.size() - i - 1];
		if (m_opcodeTree->isOpcode(word)) {
			QString syntax = m_opcodeTree->getSyntax(word);
			if(!syntax.isEmpty()) {
				emit(opcodeSyntaxSignal(syntax));
				m_currentOpcodeText = syntax;
				if (i == 0 && editor->textCursor().hasSelection()) {
					showHover = true;
				}
				break;
			}
		}
	}
	if (showHover) {
		showHoverText();
	} else {
		hideHoverText();
	}
}

// parentheses matching functions -------------

bool DocumentView::matchLeftParenthesis(QTextBlock currentBlock, int i, int numLeftParentheses)
{
	TextBlockData *data = static_cast<TextBlockData *>(currentBlock.userData());
	QVector<ParenthesisInfo *> infos = data->parentheses();

	int docPos = currentBlock.position();
	for (; i < infos.size(); ++i) {
		ParenthesisInfo *info = infos.at(i);

		if (info->character == '(') {
			++numLeftParentheses;
			continue;
		}

		if (info->character == ')' && numLeftParentheses == 0) {
			createParenthesisSelection(docPos + info->position);
			return true;
		} else
			--numLeftParentheses;
	}

	currentBlock = currentBlock.next();
	if (currentBlock.isValid())
		return matchLeftParenthesis(currentBlock, 0, numLeftParentheses);

	return false;
}


bool DocumentView::matchRightParenthesis(QTextBlock currentBlock, int index, int numRightParentheses)
{
	TextBlockData *data = static_cast<TextBlockData *>(currentBlock.userData());
	QVector<ParenthesisInfo *> parentheses = data->parentheses();

	// Match in same line?
	int docPos = currentBlock.position();
	for (int j=index; j>=0; --j ) {
		ParenthesisInfo *info = parentheses.at(j);
		if (info->character == ')') {
			++numRightParentheses;
			continue;
		}
		if (info->character == '(' && numRightParentheses == 0) {
			createParenthesisSelection(docPos + info->position);
			return true;
		} else
			--numRightParentheses;
	}

	// No match yet? Then try previous block
	currentBlock = currentBlock.previous();
	if (currentBlock.isValid()) {
		// Recalculate correct index first
		TextBlockData *data = static_cast<TextBlockData *>( currentBlock.userData() );
		QVector<ParenthesisInfo *> infos = data->parentheses();

		return matchRightParenthesis(currentBlock, infos.size()-1, numRightParentheses);
	}

	// No match at all
	return false;
}

void DocumentView::createParenthesisSelection(int pos, bool paired)
{
	//TODO: get editor from parameters
	QTextEdit * editor = (!m_currentEditor) ? m_mainEditor : m_currentEditor ; // if currentEditor not set, use mainEditor

	QList<QTextEdit::ExtraSelection> selections = editor->extraSelections();

	QTextEdit::ExtraSelection selection;
	QTextCharFormat format = selection.format;
	format.setBackground( (paired) ? Qt::lightGray: Qt::magenta); // if single parenthesis, mark with magenta
	selection.format = format;

	QTextCursor cursor = editor->textCursor();
	cursor.setPosition(pos);
	cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
	selection.cursor = cursor;

	selections.append(selection);

	editor->setExtraSelections(selections);
}


void DocumentView::textChanged()
{
	if (internalChange) {
        internalChange = false;
		return;
	}
	TextEditor *editor = m_mainEditor;
	unmarkErrorLines();

	if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE) {  // CSD or ORC mode
		if (m_autoComplete) {
			QTextCursor cursor = editor->textCursor();
			int curIndex = cursor.position();
//			if (cursor) {
//				word.chop(1);
//			}
			cursor.select(QTextCursor::WordUnderCursor);
			QString word = cursor.selectedText();
            QString wordlow = word.toLower();
			if (word == ",") {
				cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::MoveAnchor, 2);
				cursor.movePosition(QTextCursor::StartOfWord);
				cursor.select(QTextCursor::WordUnderCursor);
				word = cursor.selectedText();
			}
			QTextCursor lineCursor = editor->textCursor();
			lineCursor.select(QTextCursor::LineUnderCursor);
			QString line = lineCursor.selectedText();

			int commentIndex = -1;
			bool useFunction = false;
			if (line.indexOf(";") != -1) {
				commentIndex = lineCursor.position() - line.length() + line.indexOf(";");
				if (commentIndex < curIndex)
					return;
			}
            if(line.indexOf(QRegExp("^\\s*(opcode|instr)")) >= 0) {
            // if (line.contains("opcode") || line.contains("instr")) { // Don't pop menu in these cases.
				return;
			}
			if (line.indexOf(QRegExp("\\s*\\w+\\s+\\w+\\s+")) >= 0) {
				useFunction = true;
			}
			if (cursor.position() > cursor.anchor()) { // Only at the end of the word
				if (word.size() > 0 && !word.startsWith("\"")) {
					QStringList vars;
					syntaxMenu->clear();
					foreach(QString var, m_localVariables) {
						if (var.endsWith(',')) {
							var.chop(1);
						}
						if (var.startsWith(word) && word != var) {
							vars << var;
						}
					}
					foreach(QString var, vars) {
                        QAction *a = syntaxMenu->addAction(var, this,
                                                           SLOT(insertAutoCompleteText())); // was: insertParameterText that does not exist any more
						a->setData(var);
						if(vars.indexOf(var) == 0) {
							syntaxMenu->setDefaultAction(a);
						}
					}
                    if (word.size() > 2) {
                        // qDebug() << "word: " << word << "\n";
						// check for autcompletion from all words in text editor
						QString wholeText = editor->toPlainText();
                        wholeText.replace(QRegularExpression("[" + QRegularExpression::escape("+-*/=#&,\"\'|[]()<>.;0123456789:") + "]"), " ");
                        QStringList allWords = wholeText.simplified().split(" ");
						QStringList menuWords;
						allWords.removeDuplicates();
                        // allWords.replaceInStrings(QRegExp("^\\d*$"),""); // remove numbers - not good enough regexp, '.' stays
						allWords.removeAll("");
						foreach(QString theWord, allWords) {
                            if (theWord.toLower().startsWith(wordlow) && word != theWord) {
								menuWords << theWord;
							}
						}
                        foreach(QString tag, tagWords) {
                            if(tag.toLower().startsWith(wordlow) && word != tag) {
                                menuWords << tag;
                            }

                        }
                        foreach(QString theWord, menuWords) {
							QAction *a = syntaxMenu->addAction(theWord,
															   this, SLOT(insertAutoCompleteText()));
							a->setData(theWord);
							if(menuWords.indexOf(theWord) == 0) {
								syntaxMenu->setDefaultAction(a); // vaata, et allpool seda ei tühistaks
							}
						}
						// and then for opcodes and parameters
						QVector<Opcode> syntax = m_opcodeTree->getPossibleSyntax(word);
						if (syntax.size() > 0) {
							syntaxMenu->addSeparator();
							bool allEqual = true;
							for(int i = 0; i < syntax.size(); i++) {
								if (syntax[i].opcodeName != word) {
									allEqual = false;
								}
							}
							if (!allEqual && syntax.size() > 0) {
								for(int i = 0; i < syntax.size(); i++) {
									QString text = syntax[i].opcodeName;
									if (syntax[i].outArgs.simplified().startsWith("a")) {
										text += " (audio-rate)";
									}
									else if (syntax[i].outArgs.simplified().startsWith("k")) {
										text += " (control-rate)";
									}
									else if (syntax[i].outArgs.simplified().startsWith("x")) {
										text += " (multi-rate)";
									}
									else if (syntax[i].outArgs.simplified().startsWith("S")) {
										text += " (string output)";
									}
									else if (syntax[i].outArgs.simplified().startsWith("f")) {
										text += " (pvs)";
									}
									QString syntaxText;
									if (useFunction) {
										syntaxText = syntax[i].opcodeName.simplified();
										syntaxText += "(";
										syntaxText += syntax[i].inArgs.simplified();
										syntaxText += ")";
									} else {
										syntaxText= syntax[i].outArgs.simplified();
										if (!syntax[i].outArgs.isEmpty())
											syntaxText += " ";
										syntaxText += syntax[i].opcodeName.simplified();
										if (!syntax[i].inArgs.isEmpty()) {
											if (syntax[i].inArgs.contains("(x)") ) {
												syntaxText += "(x)"; // avoid other text like (with no rate restriction)
											} else {
												syntaxText += " " + syntax[i].inArgs.simplified();
											}
										}
									}
									QAction *a = syntaxMenu->addAction(text,
																	   this, SLOT(insertAutoCompleteText()));
									a->setData(syntaxText);
									a->setToolTip(syntaxText);
									if (i == 0) {
										syntaxMenu->setDefaultAction(a);
									}
								}
							}
						}
					}
					if (syntaxMenu->defaultAction() != NULL) {
						QRect r =  editor->cursorRect();
						QPoint p = QPoint(r.x() + r.width(), r.y() + r.height());
						QPoint globalPoint =  editor->mapToGlobal(p);
						//syntaxMenu->setWindowModality(Qt::NonModal);
						//syntaxMenu->popup(globalPoint);
						syntaxMenu->move(globalPoint);
						syntaxMenu->show();
					}
					//						editor->setFocus(Qt::OtherFocusReason);
				}
				else {
					destroySyntaxMenu();
				}
			}
		}
		syntaxCheck();
	}
	else if (m_mode == EDIT_PYTHON_MODE) { // Python Mode
		// Nothing for now
	}
}

void DocumentView::escapePressed()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		if (m_mainEditor->getParameterMode()) {
			// Force unselecting
			m_mainEditor->moveCursor(QTextCursor::NextCharacter);
			m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
			exitParameterMode();
		} else if (m_hoverText->isVisible()){
			hideHoverText();
		} else {
            qDebug()<<"closeExtraPanels now omitted -  let know, if it should be brought back.";
            //emit closeExtraPanels();
		}
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::finishParameterMode()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		if (m_mainEditor->getParameterMode()) {
			killToEnd();
			exitParameterMode();
		} else {
			hideHoverText();
		}
	} else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::exitParameterMode()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		m_mainEditor->setParameterMode(false);
	} else {
		qDebug() << "Not implemented for split view";
	}
	hideHoverText();
//	parameterButton->setVisible(false);
}

void DocumentView::indentNewLine()
{
	QTextCursor linecursor = m_mainEditor->textCursor();
	if (m_mode == EDIT_PYTHON_MODE){
		linecursor.movePosition(QTextCursor::PreviousCharacter);
		linecursor.select(QTextCursor::LineUnderCursor);
		QString line = linecursor.selectedText();
		if (line.endsWith(":")) {
			m_mainEditor->insertPlainText("    ");
		}
	} else if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
			   || m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
		linecursor.movePosition(QTextCursor::PreviousBlock);
		linecursor.select(QTextCursor::LineUnderCursor);
		QString line = linecursor.selectedText();
		QRegExp regex = QRegExp("\\s+");
		if (line.indexOf(regex) == 0) {
			m_mainEditor->insertPlainText(regex.cap());
		}
	}
}

void DocumentView::findReplace()
{
	// TODO implment for multiple views
	internalChange = true;
	if (m_viewMode < 2) {
		QTextCursor cursor = m_mainEditor->textCursor();
		QString word = cursor.selectedText();
		cursor.select(QTextCursor::WordUnderCursor);
		QString word2 = cursor.selectedText();
		if (word == word2 && word!= "") {
			lastSearch = word;
		}
		FindReplace *dialog = new FindReplace(this,
											  m_mainEditor,
											  &lastSearch,
											  &lastReplace,
											  &lastCaseSensitive);
		// lastSearch and lastReplace are passed by reference to be
		// updated by FindReplace dialog
		connect(dialog, SIGNAL(findString(QString)), this, SLOT(findString(QString)));
		dialog->show();
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
}

void DocumentView::gotoLineDialog()
{
    auto dialog = new QDialog(this);
    dialog->resize(300, 120);
    dialog->setModal(true);
    dialog->setWindowTitle(tr("Go to Line"));

    auto layout = new QGridLayout(dialog);

    auto label = new QLabel(tr("Go To Line: "));
    layout->addWidget(label, 0, 0, Qt::AlignRight|Qt::AlignVCenter);

    auto lineSpinBox = new QSpinBox(dialog);
    lineSpinBox->setRange(0, 99999999);
    layout->addWidget(lineSpinBox, 0, 1, Qt::AlignLeft|Qt::AlignVCenter);

    auto okButton = new QPushButton(tr("Ok"));
    layout->addWidget(okButton, 10, 1, Qt::AlignCenter|Qt::AlignVCenter);
    connect(okButton, &QPushButton::clicked,
            [this, lineSpinBox](){ this->jumpToLine(lineSpinBox->value()); });
    connect(okButton, &QPushButton::clicked, [dialog](){ dialog->close(); });

    lineSpinBox->setFocus();
    lineSpinBox->selectAll();
    dialog->show();
}

void DocumentView::getToIn()
{
    // Change chnget/chnset to invalue/outvalue
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		internalChange = true;
		m_mainEditor->setPlainText(changeToInvalue(m_mainEditor->toPlainText()));
        m_mainEditor->document()->setModified(true);  // Necessary, or is setting it locally enough?
	}
	else { //  Split view
		qDebug() << "Not implemented for split view.";
	}
}

void DocumentView::inToGet()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		internalChange = true;
		m_mainEditor->setPlainText(changeToChnget(m_mainEditor->toPlainText()));
        m_mainEditor->document()->setModified(true);
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
}

void DocumentView::insertAutoCompleteText()
{
	TextEditor *editor;
	if (m_viewMode < 2) {
		editor = m_mainEditor;
	}
	else { //  Split view
		editor = (TextEditor *) focusWidget();
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
	if (editor != 0) {
		internalChange = true;
		QAction *action = static_cast<QAction *>(QObject::sender());
		bool insertComplete = static_cast<MySyntaxMenu *>(action->parent())->insertComplete;

		QTextCursor cursor = editor->textCursor();
		cursor.select(QTextCursor::WordUnderCursor);
		while ((cursor.selectedText() == "" || cursor.selectedText() == ",") && !cursor.atBlockStart()) {
			cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::MoveAnchor, 2);
			cursor.select(QTextCursor::WordUnderCursor);
		}
		cursor.insertText("");
		editor->setTextCursor(cursor);

		QTextCursor cursor2 = editor->textCursor();
		cursor2.movePosition(QTextCursor::StartOfLine,QTextCursor::KeepAnchor);
		bool noOutargs = false;
		if (!cursor2.selectedText().simplified().isEmpty()) { // Text before cursor, don't put outargs
			noOutargs = true;
		}
		internalChange = true;
		if (insertComplete) {
			if (noOutargs) {
				QString syntaxText = action->data().toString();
				int index =syntaxText.indexOf(QRegExp("\\w\\s+\\w"));
				editor->insertPlainText(syntaxText.mid(index + 1).trimmed());  // right returns the whole string if index < 0
			}
			else {
				editor->insertPlainText(action->data().toString());
			}
            QString syntaxText = action->data().toString();
			QStringList syntaxSections = syntaxText.simplified().split(" "); // was split("")
            QString actionText = action->text();
            actionText = actionText.split(" ").at(0);
            if (m_autoParameterMode && m_opcodeTree->isOpcode(actionText) && syntaxSections.size() > 1) {
				m_mainEditor->moveCursor(QTextCursor::StartOfBlock);
				m_mainEditor->setParameterMode(true);
				prevParameter();
			}
		} else {
			int index = action->text().indexOf(" ");
			if (index > 0) {
				editor->insertPlainText(action->text().left(index));
			}
			else {
				editor->insertPlainText(action->text());
			}
		}
	}
}

void DocumentView::findString(QString query)
{
	// TODO search across all editors
	if (m_viewMode < 2) {
//		qDebug() << "DocumentView::findString " << query;
		if (query == "") {
			query = lastSearch;
		}
		bool found = false;
        if (lastCaseSensitive) {
            found = m_mainEditor->find(query,
									   QTextDocument::FindCaseSensitively);
		}
		else
			found = m_mainEditor->find(query);

		if (!found) {
			int ret = QMessageBox::question(this, tr("Find and replace"),
											tr("The string was not found.\n"
											   "Would you like to start from the top?"),
											QMessageBox::Yes | QMessageBox::No,
											QMessageBox::No
											);
			if (ret == QMessageBox::Yes) {
				m_mainEditor->moveCursor(QTextCursor::Start);
				findString();
			}
        }
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
}

void DocumentView::evaluate()
{
	emit evaluate(getActiveText());
}

void DocumentView::createContextMenu(QPoint pos)
{
	if (m_viewMode < 2) {
		QMenu *menu = m_mainEditor->createStandardContextMenu();
		menu->addSeparator();
		menu->addAction(tr("Evaluate Selection"), this, SLOT(evaluate()));
		menu->addAction(tr("Opcode Help"), this, SLOT(opcodeHelp()));
		menu->addAction(tr("Show/hide line numbers"), this, SLOT(toggleLineArea()));
		menu->addSeparator();
		QMenu *opcodeMenu = menu->addMenu("Opcodes");
		QMenu *mainMenu = 0;
		QMenu *subMenu;
		QString currentMain = "";
		for (int i = 0; i < m_opcodeTree->getCategoryCount(); i++) {
			QString category = m_opcodeTree->getCategory(i);
			QStringList categorySplit = category.split(":");
			if (!categorySplit.isEmpty() && categorySplit[0] != currentMain) {
				mainMenu = opcodeMenu->addMenu(categorySplit[0]);
				currentMain = categorySplit[0];
			}
			if (categorySplit.size() < 2) {
				subMenu = mainMenu;
			}
			else {
				subMenu = mainMenu->addMenu(categorySplit[1]);
			}
			foreach(Opcode opcode, m_opcodeTree->getOpcodeList(i)) {
				QAction *action = subMenu->addAction(opcode.opcodeName, this, SLOT(opcodeFromMenu()));
				QString opcodeText = opcode.outArgs;
				opcodeText += (!opcode.outArgs.isEmpty()
							   && !opcode.outArgs.endsWith(" ")
							   && !opcode.opcodeName.startsWith(" ") ?
								   " " : "");
				opcodeText += opcode.opcodeName;
				opcodeText += (!opcode.inArgs.isEmpty()
							   && !opcode.inArgs.startsWith(" ")
							   && !opcode.opcodeName.endsWith(" ") ?
								   " " : "");
				opcodeText += opcode.inArgs;
				action->setData(opcodeText);
			}
		}
		menu->exec(m_mainEditor->mapToGlobal(pos));
		delete menu;
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "Not implemented for split view.";
	}
}


void DocumentView::showOrc(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_orcEditor->setVisible(show);
	}
}

void DocumentView::showScore(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_scoreEditor->setVisible(show);
	}
}

void DocumentView::showOptions(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_optionsEditor->setVisible(show);
	}
}

void DocumentView::showFileB(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_filebEditor->setVisible(show);
	}
}

void DocumentView::showOther(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_otherEditor->setVisible(show);
	}
}

void DocumentView::showOtherCsd(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_otherCsdEditor->setVisible(show);
	}
}

void DocumentView::showWidgetEdit(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_widgetEditor->setVisible(show);
	}
}

void DocumentView::showAppEdit(bool show)
{
	// FIXME set m_viewmode
	if (m_viewMode >= 2) {
		m_appEditor->setVisible(show);
	}
}

void DocumentView::cut()
{
	if (m_viewMode < 2) {
		m_mainEditor->cut();
	}
	else {
		if (m_scoreEditor->hasFocus()) {
			m_scoreEditor->cut();
		}
		else if (m_optionsEditor->hasFocus()) {
			m_optionsEditor->cut();
		}
		else if (m_otherEditor->hasFocus() ) {
			m_otherEditor->cut();
		}
		else if (m_otherCsdEditor->hasFocus()) {
			m_otherCsdEditor->cut();
		}
		else if (m_widgetEditor->hasFocus()) {
			m_widgetEditor->cut();
		}
	}
}

void DocumentView::copy()
{
	if (m_viewMode < 2) {
		m_mainEditor->copy();
	}
	else {
		if (m_scoreEditor->hasFocus()) {
			m_scoreEditor->copy();
		}
		else if (m_optionsEditor->hasFocus()) {
			m_optionsEditor->copy();
		}
		else if (m_otherEditor->hasFocus() ) {
			m_otherEditor->copy();
		}
		else if (m_otherCsdEditor->hasFocus()) {
			m_otherCsdEditor->copy();
		}
		else if (m_widgetEditor->hasFocus()) {
			m_widgetEditor->copy();
		}
	}
}

void DocumentView::paste()
{
	if (m_viewMode < 2) {
		m_mainEditor->paste();
	}
	else {
		if (m_scoreEditor->hasFocus()) {
			m_scoreEditor->paste();
		}
		else if (m_optionsEditor->hasFocus()) {
			m_optionsEditor->paste();
		}
		else if (m_otherEditor->hasFocus() ) {
			m_otherEditor->paste();
		}
		else if (m_otherCsdEditor->hasFocus()) {
			m_otherCsdEditor->paste();
		}
		else if (m_widgetEditor->hasFocus()) {
			m_widgetEditor->paste();
		}
	}
}

void DocumentView::undo()
{
	if (m_viewMode < 2) {
		m_mainEditor->undo();
	}
	else {
		if (m_scoreEditor->hasFocus()) {
			m_scoreEditor->undo();
		}
		else if (m_optionsEditor->hasFocus()) {
			m_optionsEditor->undo();
		}
		else if (m_otherEditor->hasFocus() ) {
			m_otherEditor->undo();
		}
		else if (m_otherCsdEditor->hasFocus()) {
			m_otherCsdEditor->undo();
		}
		else if (m_widgetEditor->hasFocus()) {
			m_widgetEditor->undo();
		}
	}
	escapePressed();
}

void DocumentView::redo()
{
	if (m_viewMode < 2) {
		m_mainEditor->redo();
	}
	else {
		if (m_scoreEditor->hasFocus()) {
			m_scoreEditor->redo();
		}
		else if (m_optionsEditor->hasFocus()) {
			m_optionsEditor->redo();
		}
		else if (m_otherEditor->hasFocus() ) {
			m_otherEditor->redo();
		}
		else if (m_otherCsdEditor->hasFocus()) {
			m_otherCsdEditor->redo();
		}
		else if (m_widgetEditor->hasFocus()) {
			m_widgetEditor->redo();
		}
	}
}

void DocumentView::comment()
{
	// TODO implment for multiple views
	//  qDebug() << "DocumentView::comment()";
	if (m_viewMode < 2) {
		internalChange = true;
		QString commentChar = "";
		if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
				|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
			commentChar = ";";
		}
		else if (m_mode == EDIT_PYTHON_MODE) { // Python Mode
			commentChar = "#";
		}
		QTextCursor cursor = m_mainEditor->textCursor();
		if (cursor.position() > cursor.anchor()) {
			int temp = cursor.anchor();
			cursor.setPosition(cursor.position());
			cursor.setPosition(temp, QTextCursor::KeepAnchor);
		}
		if (!cursor.atBlockStart()) {
			cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
		}
		int start = cursor.selectionStart();
		QString text = cursor.selectedText();
		if (text.startsWith(commentChar)) {
			uncomment();
			return;
		}
		text.prepend(commentChar);
		text.replace(QChar(QChar::ParagraphSeparator), QString("\n" + commentChar));
		if (text.endsWith("\n" + commentChar) ) {
			text.chop(1);
		}
		cursor.insertText(text);
		cursor.setPosition(start);
		cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, text.size());
		m_mainEditor->setTextCursor(cursor);
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::uncomment()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		internalChange = true;
		QString commentChar = "";
		if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
				|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
			commentChar = ";";
		}
		else if (m_mode == EDIT_PYTHON_MODE) { // Python Mode
			commentChar = "#";
		}
		QTextCursor cursor = m_mainEditor->textCursor();
		if (cursor.position() > cursor.anchor()) {
			int temp = cursor.anchor();
			cursor.setPosition(cursor.position());
			cursor.setPosition(temp, QTextCursor::KeepAnchor);
		}
		QString text = cursor.selectedText();
		if (!cursor.atBlockStart() && !text.startsWith(commentChar)) {
			cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
			text = cursor.selectedText();
		}
		if (text.startsWith(commentChar)) {
			text.remove(0,1);
		}
		int start = cursor.selectionStart();
		text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
		text.replace(QString("\n" + commentChar), QString("\n")); //TODO make more robust
		cursor.insertText(text);
		cursor.setPosition(start);
		cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, text.size());
		m_mainEditor->setTextCursor(cursor);
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::indent()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		//   qDebug("DocumentPage::indent");
		internalChange = true;
		QString indentChar = "";
		if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
				|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
			indentChar = "\t";
		}
		else if (m_mode == EDIT_PYTHON_MODE) { // Python Mode
			indentChar = "    ";
		}
		QTextCursor cursor = m_mainEditor->textCursor();
		QTextCursor::MoveMode moveMode = cursor.selectedText().isEmpty() ? QTextCursor::MoveAnchor : QTextCursor::KeepAnchor;
		if (cursor.position() > cursor.anchor()) {
			int temp = cursor.anchor();
			cursor.setPosition(cursor.position());
			cursor.setPosition(temp, QTextCursor::KeepAnchor);
		}
		if (!cursor.atBlockStart()) {
			cursor.movePosition(QTextCursor::StartOfLine, moveMode);
		}
		int start = cursor.selectionStart();
		QString text = cursor.selectedText();
		text.prepend(indentChar);
		text.replace(QChar(QChar::ParagraphSeparator), "\n" + indentChar);
		if (text.endsWith("\n" + indentChar) ) {
			text.chop(1);
		}
		cursor.insertText(text);
		cursor.setPosition(start);
		cursor.movePosition(QTextCursor::NextCharacter, moveMode, text.size());
		m_mainEditor->setTextCursor(cursor);
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::unindent()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		internalChange = true;
		QString indentChar = "";
		if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
				|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
			indentChar = "\t";
		}
		else if (m_mode == EDIT_PYTHON_MODE) { // Python Mode
			indentChar = "    ";
		}
		QTextCursor cursor = m_mainEditor->textCursor();
		if (cursor.position() > cursor.anchor()) {
			int temp = cursor.anchor();
			cursor.setPosition(cursor.position());
			cursor.setPosition(temp, QTextCursor::KeepAnchor);
		}
		if (!cursor.atBlockStart()) {
			cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
		}
		int start = cursor.selectionStart();
		QString text = cursor.selectedText();
		while (indentChar == "    "  && text.startsWith("\t")) {
			text.remove(0,1);
		}
		if (text.startsWith(indentChar)) {
			text.remove(0,indentChar.size());
		}
		text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
		text.replace("\n" + indentChar, QString("\n")); //TODO make more robust
		cursor.insertText(text);
		cursor.setPosition(start);
		cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, text.size());
		m_mainEditor->setTextCursor(cursor);
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::killLine()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		QTextCursor cursor = m_mainEditor->textCursor();
		if (!cursor.atBlockStart()) {
			cursor.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
		}
		cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
		cursor.insertText("");
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::killToEnd()
{
	// TODO implment for multiple views
	//  internalChange = true;
	if (m_viewMode < 2) {
		QTextCursor cursor = m_mainEditor->textCursor();
		if (!cursor.atBlockEnd()) {
			cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
		}
		cursor.insertText("");
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::markErrorLines(QList<QPair<int, QString> > lines)
{
	// TODO implement for multiple views
	if (m_viewMode < 2) {
		bool originallyMod = m_mainEditor->document()->isModified();
		internalChange = true;
		QTextCharFormat errorFormat;
		errorFormat.setBackground(QBrush(QColor(255, 182, 193)));
		QTextCursor cur = m_mainEditor->textCursor();
		cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
		for(int i = 0; i < lines.size(); i++) {
			int line = lines[i].first;
			QString text = lines[i].second;
			qDebug() <<"Line: " << line << " error: " << text;
			cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor,line-1);
			cur.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
			cur.mergeCharFormat(errorFormat);
			internalChange = true;
			m_mainEditor->setTextCursor(cur);
			errorMarked = true;
			if (!originallyMod) {
				m_mainEditor->document()->setModified(false);
			}
		}
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::unmarkErrorLines()
{
	// TODO implment for multiple views
	if (!errorMarked)
		return;
	//   qDebug("DocumentPage::unmarkErrorLines()");
	if (m_viewMode < 2) {
		int position = m_mainEditor->verticalScrollBar()->value();
		QTextCursor currentCursor = m_mainEditor->textCursor();
		errorMarked = false;
		m_mainEditor->selectAll();
		internalChange = true;
		QTextCursor cur = m_mainEditor->textCursor();
		QTextCharFormat format = cur.blockCharFormat();
		format.clearBackground();
		cur.setCharFormat(format);
		internalChange = true;
		m_mainEditor->setTextCursor(cur);  //sets format
		internalChange = true;
		m_mainEditor->setTextCursor(currentCursor); //returns cursor to initial position
		m_mainEditor->verticalScrollBar()->setValue(position); //return document display to initial position
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}


void editorJumpToLine(TextEditor *editor, int line) {
    int maxlines = editor->document()->blockCount();
    if(line > maxlines)
        line = maxlines;
    QTextCursor cursor(editor->document()->findBlockByLineNumber(line-1));
    editor->moveCursor(QTextCursor::End);
    editor->setTextCursor(cursor);
}

void DocumentView::jumpToLine(int line, bool mark)
{
    if(mark)
        markCurrentPosition();
	// TODO implment for multiple views
    if (m_viewMode < 2) {
        editorJumpToLine(m_mainEditor, line);
	}
	else {
        editorJumpToLine(m_orcEditor, line);
	}
}

void DocumentView::goBackToPreviousPosition() {
    if(cursorPositions.isEmpty())
        return;
    int lastPos = cursorPositions.takeLast();
    this->jumpToLine(lastPos, false);
}

void DocumentView::gotoNextLine()
{
	m_mainEditor->moveCursor(QTextCursor::Down);
}

void DocumentView::opcodeFromMenu()
{
	QAction *action = (QAction *) QObject::sender();
	if (m_viewMode < 2) {
		QTextCursor cursor = m_mainEditor->textCursor();
		QString text = action->data().toString();
		cursor.insertText(text);
	}
	else {
		qDebug() << "Not implemented for split view";
	}
}

void DocumentView::insertChn_k(QString channel)
{
	QTextCursor cursor;
	cursor = m_mainEditor->textCursor();
	m_mainEditor->moveCursor(QTextCursor::Start);
	if (m_mainEditor->find(";;channels")) {
		m_mainEditor->moveCursor(QTextCursor::NextBlock);
	} else if (m_mainEditor->find("0dbfs")) { // if no ;;channels try to put under 0dbfs line in options
		m_mainEditor->moveCursor(QTextCursor::NextBlock);
		m_mainEditor->insertPlainText("\n;;channels\n");
	} else if (m_mainEditor->find("instr ")) { // or before last instrument
		m_mainEditor->moveCursor(QTextCursor::PreviousBlock);
		m_mainEditor->insertPlainText("\n");
		m_mainEditor->moveCursor(QTextCursor::PreviousBlock);
		m_mainEditor->insertPlainText("\n;;channels\n");
	} else { // or ask if current cursor position is OK
		int response = QMessageBox::question(this, tr("Where to insert?"),tr("Could find section ;;channels\nIs it OK to insert ;;channels and chn_k declaration before in the current position?"));
		if (response==QMessageBox::Yes) {
			m_mainEditor->setTextCursor(cursor);
			m_mainEditor->moveCursor(QTextCursor::StartOfLine);
			m_mainEditor->insertPlainText("\n;;channels\n");
		} else {
			m_mainEditor->setTextCursor(cursor);
			return;
		}
	}

	if (getBasicText().contains("chn_k \""+channel)) {
		QMessageBox::information(this, tr("chn_kdeclaration"),tr("This channel is already declared."));
	} else {
		m_mainEditor->insertPlainText(QString("chn_k \"%1\",3\n").arg(channel));
	}

	m_mainEditor->setTextCursor(cursor);
}

void DocumentView::contextMenuEvent(QContextMenuEvent *event)
{
	qDebug() << "DocumentView::contextMenuEvent";
	createContextMenu(event->globalPos());
}

QString DocumentView::changeToChnget(QString text)
{
	QStringList lines = text.split("\n");
	QString newText = "";
	foreach (QString line, lines) {
		if (line.contains("invalue")) {
			line.replace("invalue", "chnget");
		}
		else if (line.contains("outvalue")) {
			line.replace("outvalue", "chnset");
			int arg1Index = line.indexOf("chnset") + 7;
			int arg2Index = line.indexOf(",") + 1;
			int arg2EndIndex = line.indexOf(QRegExp("[\\s]*[;]"), arg2Index);
			QString arg1 = line.mid(arg1Index, arg2Index-arg1Index - 1).trimmed();
			QString arg2 = line.mid(arg2Index, arg2EndIndex-arg2Index).trimmed();
			QString comment = line.mid(arg2EndIndex);
			qDebug() << arg1 << arg2 << arg2EndIndex;
			line = line.mid(0, arg1Index) + " " +  arg2 + ", " + arg1;
			if (arg2EndIndex > 0)
				line += " " + comment;
		}
		newText += line + "\n";
	}
	return newText;
}

QString DocumentView::changeToInvalue(QString text)
{
	QStringList lines = text.split("\n");
	QString newText = "";
	foreach (QString line, lines) {
		if (line.contains("chnget")) {
			line.replace("chnget", "invalue");
		}
		else if (line.contains("chnset")) {
			line.replace("chnset", "outvalue");
			int arg1Index = line.indexOf("outvalue") + 8;
			int arg2Index = line.indexOf(",") + 1;
			int arg2EndIndex = line.indexOf(QRegExp("[\\s]*[;]"), arg2Index);
			QString arg1 = line.mid(arg1Index, arg2Index-arg1Index - 1).trimmed();
			QString arg2 = line.mid(arg2Index, arg2EndIndex-arg2Index).trimmed();
			QString comment = line.mid(arg2EndIndex);
			qDebug() << arg1 << arg2 << arg2EndIndex;
			line = line.mid(0, arg1Index) + " " + arg2 + ", " + arg1;
			if (arg2EndIndex > 0)
				line += " " + comment;
		}
		newText += line + "\n";
	}
	return newText;
}

void DocumentView::destroySyntaxMenu()
{
	syntaxMenu->hide();
	//  syntaxMenu = 0;
}

void DocumentView::opcodeHelp()
{
	emit setHelp();
}

void DocumentView::restoreCursorPosition()
{
	// check if cursor must be moved to old position (after evaluateSection)
	if (m_oldCursorPosition>=0) {
		qDebug()<<"Restoring cursor position to "<<m_oldCursorPosition;
		QTextCursor cursor = m_mainEditor->textCursor();
		cursor.setPosition(m_oldCursorPosition); // TODO: check also for pyuthonEditor
		m_mainEditor->setTextCursor(cursor);
		m_oldCursorPosition = -1;
	}
}

void DocumentView::setParsedUDOs(QStringList udos) {
    m_highlighter.setUDOs(udos);
}

MySyntaxMenu::MySyntaxMenu(QWidget * parent) :
	QMenu(parent)

{
    this->setStyleSheet("QMenu {"
                        "  background-color: #f8f8f8;"
                        "  color: #5050A0 !important; "
                        "  border-radius: 4px; "
                        "  line-height: 95%; "
                        "}");

}

MySyntaxMenu::~MySyntaxMenu()
{

}

void MySyntaxMenu::keyPressEvent(QKeyEvent * event)
{
	if (event->key() == Qt::Key_Escape) {
		this->hide();
	}
	else if (event->key() == Qt::Key_Tab) {
		QAction * a = activeAction();
		insertComplete = false;
		this->close();
		if (a != 0) {
			a->trigger();
			return;
		}
		else {
			Q_ASSERT(defaultAction() != NULL);
			defaultAction()->trigger();
			return;
		}
	} else if (event->key() == Qt::Key_Return) {
		QAction * a = activeAction();
		insertComplete = true;
		this->close();
		if (a != 0) {
			a->trigger();
			return;
		}
		else {
			Q_ASSERT(defaultAction() != NULL);
			defaultAction()->trigger();
			return;
		}
	} else if (event->key() != Qt::Key_Up && event->key() != Qt::Key_Down) {
		this->close();
		if (event->key() != Qt::Key_Backspace) {
			emit keyPressed(event->text());
		}
		else {
			QObject *par = parent();
			if (par)
				par->event(event);
		}
	}
	insertComplete = false;
	QMenu::keyPressEvent(event);
}

HoverWidget::HoverWidget(QWidget *parent) :
	QWidget(parent)
{

}

void HoverWidget::mousePressEvent(QMouseEvent *ev)
{
    (void) ev;
	this->hide();
}
