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

DocumentView::DocumentView(QWidget * parent, OpEntryParser *opcodeTree) :
	BaseView(parent,opcodeTree)
{
	m_autoComplete = true;
	for (int i = 0; i < editors.size(); i++) {
		connect(editors[i], SIGNAL(textChanged()), this, SLOT(setModified()));
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
			this, SLOT(syntaxCheck()));

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
	QPalette p =syntaxMenu-> palette();
	p.setColor(QPalette::WindowText, Qt::blue);
	p.setColor(static_cast<QPalette::ColorRole>(9), Qt::yellow);
	syntaxMenu->setPalette(p);
	connect(syntaxMenu,SIGNAL(keyPressed(QString)),
			m_mainEditor, SLOT(insertPlainText(QString)));
	//  connect(syntaxMenu,SIGNAL(aboutToHide()),
	//          this, SLOT(destroySyntaxMenu()));

	setViewMode(1);
	setViewMode(0);  // To force a change
	setAcceptDrops(true);
}

DocumentView::~DocumentView()
{
	disconnect(this, 0,0,0);
	//  delete m_highlighter;
}

bool DocumentView::isModified()
{
	return m_isModified;
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

void DocumentView::setModified(bool mod)
{
	//  qDebug() << "DocumentView::setModified";
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
		qDebug() <<"DocumentView::insertText section " << section << " not implemented.";
	}
}

void DocumentView::setAutoComplete(bool autoComplete)
{
	m_autoComplete = autoComplete;
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
		qDebug() <<"DocumentView::insertText section " << section << " not implemented.";
	}
	return text;
}

QString DocumentView::getMacWidgetsText()
{
	// With tags including presets. For text that is being edited in the text editor
	// Includes presets text
	qDebug() << "DocumentView::getMacWidgetsText() not implemented and will crash!";
}

QString DocumentView::getWidgetsText()
{
	// With tags including presets, in new xml format. For text that is being edited in the text editor
	// Includes presets text
	qDebug() << "DocumentView::getWidgetsText() not implemented and will crash!";
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
			qDebug() << "DocumentView::currentLine() not implemented for score and fileb editor.";
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
		qDebug() << "DocumentView::wordUnderCursor() not implemented for split view.";
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
			cursor.select(QTextCursor::LineUnderCursor);
			bool sectionStart = cursor.selectedText().simplified().startsWith("instr");
			while (!sectionStart && !cursor.anchor() == 0) {
				cursor.movePosition(QTextCursor::PreviousBlock);
				cursor.select(QTextCursor::LineUnderCursor);
				sectionStart = cursor.selectedText().simplified().startsWith("instr");
			}
			int start = cursor.anchor();
			cursor = m_mainEditor->textCursor();
			cursor.movePosition(QTextCursor::NextBlock);
			cursor.select(QTextCursor::LineUnderCursor);
			bool sectionEnd = cursor.selectedText().simplified().startsWith("endin");
			while (!sectionEnd && !cursor.atEnd()) {
				cursor.movePosition(QTextCursor::NextBlock);
				cursor.select(QTextCursor::LineUnderCursor);
				sectionEnd = cursor.selectedText().simplified().startsWith("endin");
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
		qDebug() << "DocumentView::getActiveSection() not implemented for split view.";
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
			cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::MoveAnchor);
			cursor.movePosition(QTextCursor::EndOfLine, QTextCursor::KeepAnchor);
			selection = cursor.selectedText();
		}
		selection.replace(QChar(0x2029), QChar('\n'));
		if (!selection.endsWith("\n")) {
			selection.append("\n");
		}
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "DocumentView::getActiveText() not implemented for split view.";
	}
	return selection;
}


//void DocumentView::updateDocumentModel()
//{
//  // this should update the document model when needed
//  // e.g. on run or save or when widgets or presets have been modified in text format
//  // maybe the document model pointer should be passed and processed here.
//}
//
//void DocumentView::updateFromDocumentModel()
//{
//  // this should update from the document model when needed
//  // e.g. on loading, widget changes from widget layout
//}

void DocumentView::syntaxCheck()
{
	// TODO implment for multiple views

	int line = currentLine();
	emit(lineNumberSignal(line));

	TextEditor *editor;
	if (m_viewMode < 2) {
		editor = m_mainEditor;
	}
	else { //  Split view
		editor = (TextEditor *) sender();
	}
	QTextCursor cursor = editor->textCursor();
	cursor.select(QTextCursor::LineUnderCursor);
	QStringList words = cursor.selectedText().split(QRegExp("\\b"));
	foreach(QString word, words) {
		// We need to remove all not possibly opcode
		word.remove(QRegExp("[^\\d\\w]"));
		if (!word.isEmpty()) {
			QString syntax = m_opcodeTree->getSyntax(word);
			if(!syntax.isEmpty()) {
				emit(opcodeSyntaxSignal(syntax));
				return;
			}
		}
	}
}

void DocumentView::textChanged()
{
	if (internalChange) {
		internalChange = false;
		return;
	}
	TextEditor *editor = (TextEditor *) sender();
	unmarkErrorLines();
	if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE) {  // CSD or ORC mode
		if (m_autoComplete) {
			QTextCursor cursor = editor->textCursor();
			int curIndex = cursor.position();
			cursor.select(QTextCursor::WordUnderCursor);
			QString word = cursor.selectedText();
			QTextCursor lineCursor = editor->textCursor();
			lineCursor.select(QTextCursor::LineUnderCursor);
			QString line = lineCursor.selectedText();
			int commentIndex = -1;
			if (line.indexOf(";") != -1) {
				commentIndex = lineCursor.position() - line.length() + line.indexOf(";");
				if (commentIndex < curIndex)
					return;
			}
			if (line.contains("opcode") || line.contains("instr")  || line.contains("=") || line.contains("\"")) { // Don't pop menu in these cases.
				return;
			}
			if (line.indexOf(QRegExp("^\\s*[^kaigSf]\\w+\\s+\\w")) >= 0 || line.indexOf(QRegExp("\\s+\\w+\\s+\\w")) >= 0) {
				return;
			}
			if (word.size() > 2 && !word.startsWith("\"")
					&& cursor.position() > cursor.anchor() // Only at the end of the word
					) {
				QVector<Opcode> syntax = m_opcodeTree->getPossibleSyntax(word);
				if (syntax.size() > 0) {
					//          if (syntaxMenu == 0) {
					//            createSyntaxMenu();
					//          }
					bool allEqual = true;
					for(int i = 0; i < syntax.size(); i++) {
						if (syntax[i].opcodeName != word) {
							allEqual = false;
						}
					}
					if (!allEqual && syntax.size() > 0) {
						syntaxMenu->clear();
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
							QString syntaxText = syntax[i].outArgs.simplified();
							if (!syntax[i].outArgs.isEmpty())
								syntaxText += " ";
							syntaxText += syntax[i].opcodeName.simplified();
							if (!syntax[i].inArgs.isEmpty()) {
								syntaxText += " " + syntax[i].inArgs.simplified();
							}
							QAction *a = syntaxMenu->addAction(text,
															   this, SLOT(insertTextFromAction()));
							a->setData(syntaxText);
						}
						QRect r =  editor->cursorRect();
						QPoint p = QPoint(r.x() + r.width(), r.y() + r.height());
						QPoint globalPoint =  editor->mapToGlobal(p);
						//syntaxMenu->setWindowModality(Qt::NonModal);
						//syntaxMenu->popup(globalPoint);
						syntaxMenu->move(globalPoint);
						syntaxMenu->show();
						editor->setFocus(Qt::OtherFocusReason);
					}
					else {
						destroySyntaxMenu();
					}
				}
			}
		}
		syntaxCheck();
	}
	else if (m_mode == EDIT_PYTHON_MODE) { // Python Mode
		// Nothing for now
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
		qDebug() << "DocumentView::findReplace() not implemented for split view.";
	}
}

void DocumentView::getToIn()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		internalChange = true;
		m_mainEditor->setPlainText(changeToInvalue(m_mainEditor->toPlainText()));
		m_mainEditor->document()->setModified(true);  // Necessary, or is setting it locally enough?
	}
	else { //  Split view
		qDebug() << "DocumentView::getToIn() not implemented for split view.";
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
		qDebug() << "DocumentView::inToGet() not implemented for split view.";
	}
}

void DocumentView::autoComplete()
{
	if (m_viewMode < 2) {
		internalChange = true;
		QTextCursor cursor = m_mainEditor->textCursor();
		cursor.select(QTextCursor::WordUnderCursor);
		QString opcodeName = cursor.selectedText();
		if (opcodeName=="")
			return;
		m_mainEditor->setTextCursor(cursor);
		m_mainEditor->cut();
		QString syntax = m_opcodeTree->getSyntax(opcodeName);
		internalChange = true;
		m_mainEditor->insertPlainText(syntax);
	}
	else { //  Split view
		// TODO check properly for line number also from other editors
		qDebug() << "DocumentView::autoComplete() not implemented for split view.";
	}
}

void DocumentView::insertTextFromAction()
{
	TextEditor *editor;
	if (m_viewMode < 2) {
		editor = m_mainEditor;
	}
	else { //  Split view
		editor = (TextEditor *) focusWidget();
		// TODO check properly for line number also from other editors
		qDebug() << "DocumentView::insertTextFromAction() not implemented for split view.";
	}
	if (editor != 0) {
		internalChange = true;
		QAction *action = static_cast<QAction *>(QObject::sender());
		bool insertComplete = static_cast<MySyntaxMenu *>(action->parent())->insertComplete;
		QTextCursor cursor = editor->textCursor();
		cursor.select(QTextCursor::WordUnderCursor);
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
		}
		else {
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
		qDebug() << "DocumentView::findString " << query;
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
		qDebug() << "DocumentView::findString() not implemented for split view.";
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
		qDebug() << "DocumentView::createContextMenu() not implemented for split view.";
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
		qDebug() << "DocumentView::comment() not implemented for split view";
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
		qDebug() << "DocumentView::uncomment() not implemented for split view";
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
		text.prepend(indentChar);
		text.replace(QChar(QChar::ParagraphSeparator), "\n" + indentChar);
		if (text.endsWith("\n" + indentChar) ) {
			text.chop(1);
		}
		cursor.insertText(text);
		cursor.setPosition(start);
		cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, text.size());
		m_mainEditor->setTextCursor(cursor);
	}
	else {
		qDebug() << "DocumentView::indent() not implemented for split view";
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
		qDebug() << "DocumentView::unindent() not implemented for split view";
	}
}

void DocumentView::killLine()
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		//  internalChange = true;
		//    QString indentChar = "";
		//  if (m_mode == 0) {
		//    indentChar = "\t";
		//  }
		//  else if (m_mode == 1) { // Python Mode
		//    indentChar = "    ";
		//  }
		QTextCursor cursor = m_mainEditor->textCursor();
		if (!cursor.atBlockStart()) {
			cursor.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
		}
		cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
		cursor.insertText("");
	}
	else {
		qDebug() << "DocumentView::killLine() not implemented for split view";
	}
}

void DocumentView::killToEnd()
{
	// TODO implment for multiple views
	//  internalChange = true;
	if (m_viewMode < 2) {
		QString indentChar = "";
		//  if (m_mode == 0) {
		//    indentChar = "\t";
		//  }
		//  else if (m_mode == 1) { // Python Mode
		//    indentChar = "    ";
		//  }
		QTextCursor cursor = m_mainEditor->textCursor();
		if (!cursor.atBlockEnd()) {
			cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
		}
		cursor.insertText("");
	}
	else {
		qDebug() << "DocumentView::killToEnd() not implemented for split view";
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
		cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor); // TODO: viimane line
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
		qDebug() << "DocumentView::markErrorLines() not implemented for split view";
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
		qDebug() << "DocumentView::unmarkErrorLines() not implemented for split view";
	}
}

void DocumentView::jumpToLine(int line)
{
	// TODO implment for multiple views
	if (m_viewMode < 2) {
		int lineCount = 1;
		QTextCursor cur = m_mainEditor->textCursor();
		cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
		while (lineCount < line) {
			lineCount++;
			//       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
			cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
		}
		m_mainEditor->moveCursor(QTextCursor::End); // go to end to make sure line is put at the top of text
		m_mainEditor->setTextCursor(cur);
	}
	else {
		int lineCount = 1;
		QTextCursor cur = m_orcEditor->textCursor();
		cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
		while (lineCount < line) {
			lineCount++;
			//       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
			cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
		}
		m_orcEditor->moveCursor(QTextCursor::End); // go to end to make sure line is put at the top of text
		m_orcEditor->setTextCursor(cur);
	}
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
		qDebug() << "DocumentView::opcodeFromMenu() not implemented for split view";
	}
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

//void DocumentView::createSyntaxMenu()
//{
//  syntaxMenu->show();
//}

void DocumentView::destroySyntaxMenu()
{
	syntaxMenu->hide();
	//  syntaxMenu = 0;
}

void DocumentView::opcodeHelp()
{
	emit setHelp();
}

MySyntaxMenu::MySyntaxMenu(QWidget * parent) :
	QMenu(parent)
{

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
		insertComplete = false;
		QAction * a = activeAction();
		this->hide();
		if (a != 0) {
			a->trigger();
			return;
		}
		else {
			emit keyPressed(event->text());
		}
	}
	else if (event->key() != Qt::Key_Up && event->key() != Qt::Key_Down
			 && event->key() != Qt::Key_Return) {
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
	insertComplete = true;
	QMenu::keyPressEvent(event);
}
