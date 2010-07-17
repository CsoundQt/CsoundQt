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

#include "documentview.h"
#include "highlighter.h"
#include "findreplace.h"
#include "opentryparser.h"
#include "node.h"
#include "types.h"
#include "texteditor.h"

DocumentView::DocumentView(QWidget * parent, OpEntryParser *opcodeTree) :
    QScrollArea(parent),  m_opcodeTree(opcodeTree)
{
  mainEditor = new TextEditor(this);
  scoreEditor = new TextEditor(this);
  optionsEditor = new TextEditor(this);
  filebEditor = new TextEditor(this);
  versionEditor = new TextEditor(this);
  licenceEditor = new TextEditor(this);
  otherEditor = new TextEditor(this);
  widgetEditor = new TextEditor(this);
  ladspaEditor = new TextEditor(this);
  editors << mainEditor << scoreEditor << optionsEditor << filebEditor
      << versionEditor << licenceEditor << otherEditor << widgetEditor
      << ladspaEditor;
  splitter = new QSplitter(this);
  splitter->setOrientation(Qt::Vertical);
  splitter->setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
  splitter->setContextMenuPolicy (Qt::NoContextMenu);
  for (int i = 0; i < editors.size(); i++) {
    connect(editors[i], SIGNAL(textChanged()), this, SLOT(setModified()));
    splitter->addWidget(editors[i]);
    editors[i]->setContextMenuPolicy(Qt::CustomContextMenu);
    connect(editors[i], SIGNAL(customContextMenuRequested(QPoint)),
            this, SLOT(createContextMenu(QPoint)));
  }
  QStackedLayout *l = new QStackedLayout(this);
  l->addWidget(splitter);
  setLayout(l);
  setFocusProxy(mainEditor);  // for comment action from main application

  m_mode = 0;
  internalChange = false;

//  m_highlighter = new Highlighter();

  connect(mainEditor, SIGNAL(textChanged()),
          this, SLOT(textChanged()));
  connect(mainEditor, SIGNAL(cursorPositionChanged()),
          this, SLOT(syntaxCheck()));

  //TODO put this for line reporting for score editor
//  connect(scoreEditor, SIGNAL(textChanged()),
//          this, SLOT(syntaxCheck()));
//  connect(scoreEditor, SIGNAL(cursorPositionChanged()),
//          this, SLOT(syntaxCheck()));

  setViewMode(0);

  errorMarked = false;
  m_isModified = false;
  m_highlighter.setDocument(mainEditor->document());

  syntaxMenu = 0;
  setAcceptDrops(true);
}

DocumentView::~DocumentView()
{
  disconnect(this, 0,0,0);
//  delete m_highlighter;
}

void DocumentView::setViewMode(int mode)
{
//  if (m_viewMode == mode)
//    return;
  m_viewMode = mode;
  hideAllEditors();

  // TODO implement modes properly
  switch (m_viewMode) {
    case 0: // csd without extra sections
      mainEditor->show();
      break;
    case 1: // full plain text
      mainEditor->show();
      break;
    default:
      mainEditor->setVisible(m_viewMode & 2);
      scoreEditor->setVisible(m_viewMode & 4);
      optionsEditor->setVisible(m_viewMode & 8);
      filebEditor->setVisible(m_viewMode & 16);
      versionEditor->setVisible(m_viewMode & 32);
      licenceEditor->setVisible(m_viewMode & 64);
      otherEditor->setVisible(m_viewMode & 128);
      widgetEditor->setVisible(m_viewMode & 256);
  }

}

void DocumentView::setFileType(int mode)
{
  m_highlighter.setMode(mode);
  m_mode = mode;
}

void DocumentView::setFont(QFont font)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setFont(font);
  }
}

void DocumentView::setFontPointSize(float size)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setFontPointSize(size);
  }
}

void DocumentView::setTabWidth(int width)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setTabStopWidth(width);
  }
}

void DocumentView::setTabStopWidth(int width)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setTabStopWidth(width);
  }
}

void DocumentView::setLineWrapMode(QTextEdit::LineWrapMode mode)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setLineWrapMode(mode);
  }
}

void DocumentView::setAutoComplete(bool autoComplete)
{
  m_autoComplete = autoComplete;
}

void DocumentView::setColorVariables(bool color)
{
  m_highlighter.setColorVariables(color);
}

void DocumentView::setOpcodeNameList(QStringList list)
{
  m_highlighter.setOpcodeNameList(list);
}

bool DocumentView::isModified()
{
  return m_isModified;
}

void DocumentView::print(QPrinter *printer)
{
  editors[0]->print(printer);
}

void DocumentView::setModified(bool mod)
{
//  qDebug() << "DocumentView::setModified";
  emit contentsChanged();
  m_isModified = mod;
}

void DocumentView::setOpcodeTree(OpEntryParser *opcodeTree)
{
  m_opcodeTree = opcodeTree;
}

void DocumentView::setFullText(QString text)
{
  editors[0]->setText(text);
  setModified(false);
}

void DocumentView::setLadspaText(QString text)
{
  QTextCursor cursor;
  QTextDocument *doc;
  QTextEdit *edit;
  if (m_mode == 0 || m_mode == 1) {
    cursor = editors[0]->textCursor();
    doc = editors[0]->document();
    edit = editors[0];
    editors[0]->moveCursor(QTextCursor::Start);
  }
  else {
    cursor = ladspaEditor->textCursor();
    doc = ladspaEditor->document();
    edit = ladspaEditor;
    ladspaEditor->moveCursor(QTextCursor::Start);
  }
  if (edit->find("<csLADSPA>") and edit->find("</csLADSPA>")) {
    QString curText = doc->toPlainText();
    int index = curText.indexOf("<csLADSPA>");
    curText.remove(index, curText.indexOf("</csLADSPA>") + 11 - index);
    curText.insert(index, text);
    doc->setPlainText(curText);
  }
  else { //csLADSPA section not present, or incomplete
    edit->find("<CsoundSynthesizer>"); //cursor moves there
    edit->moveCursor(QTextCursor::EndOfLine);
    edit->insertPlainText(QString("\n") + text + QString("\n"));
  }
  edit->moveCursor(QTextCursor::Start);
}

QString DocumentView::getFullText()
{
  QString text;
  text += mainEditor->toPlainText();
  return text;
}

QString DocumentView::getBasicText()
{
//   What Csound needs (no widgets, misc text, etc.)
  // TODO implement modes
  QString text;
  switch (m_viewMode) {
    case 0: // csd without extra sections
      text = mainEditor->toPlainText();
    case 1:
      break;
    default:
      break;
    }
  return text;
}

QString DocumentView::getOrcText()
{// Without tags
  qDebug() << "DocumentView::getOrcText() not implemented and will crash!";
}

QString DocumentView::getScoText()
{
  // Without tags
  qDebug() << "DocumentView::getScoText() not implemented and will crash!";
}

QString DocumentView::getOptionsText()
{
  // Without tags. For text that is being edited in the text editor
  QString text = "";
  if (m_mode > 1) { // Split view
    text = optionsEditor->toPlainText();
  }
  else { // Non Split view
    QString edText = mainEditor->toPlainText();
    int index = edText.indexOf("<CsOptions>");
    if (index >= 0 && edText.contains("</CsOptions>")) {
      text = edText.mid(index + 11, edText.indexOf("</CsOptions>") - index - 11);
    }
  }
  qDebug() << "DocumentView::getOptionsText() " << text;
  return text;
}

QString DocumentView::getMiscText()
{
  // All other tags like version and licence with tags. For text that is being edited in the text editor
  qDebug() << "DocumentView::getMiscText() not implemented and will crash!";
}

QString DocumentView::getExtraText()
{// Text outside any known tags. For text that is being edited in the text editor
  qDebug() << "DocumentView::getFullOptionsText() not implemented and will crash!";
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


int DocumentView::currentLine()
{
  // TODO check properly for line number also from other editors
  QTextCursor cursor = editors[0]->textCursor();
//   cursor.clearSelection();
//   cursor.setPosition(0,QTextCursor::KeepAnchor);
//   QString section = cursor.selectedText();
//   qDebug() << section;
//   return section.count('\n');
  return cursor.blockNumber() + 1;
}

QString DocumentView::wordUnderCursor()
{
  QTextCursor cursor = editors[0]->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  QString word = cursor.selectedText();
  if (word.startsWith('#')) {
    word.remove(0,1);
  }
  return word;
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
  // TODO implement for multiple views

  int line = currentLine();
  emit(lineNumberSignal(line));

  if (m_mode == 0 || m_mode == 3) {  // CSD or ORC mode
    QTextCursor cursor = mainEditor->textCursor();
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
}

void DocumentView::textChanged()
{
  if (internalChange) {
    internalChange = false;
    return;
  }
  unmarkErrorLines();
  if (m_mode == 0 || m_mode == 3) {  // CSD or ORC mode
    if (m_autoComplete) {
      QTextCursor cursor = mainEditor->textCursor();
      int curIndex = cursor.position();
      cursor.select(QTextCursor::WordUnderCursor);
      QString word = cursor.selectedText();
      QTextCursor lineCursor = mainEditor->textCursor();
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
          if (syntaxMenu == 0) {
            createSyntaxMenu();
          }
          syntaxMenu->clear();
          bool allEqual = true;
          for(int i = 0; i < syntax.size(); i++) {
            if (syntax[i].opcodeName != word) {
              allEqual = false;
            }
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
            QAction *a = syntaxMenu->addAction(text,
                                               this, SLOT(insertTextFromAction()));
            QString syntaxText = syntax[i].outArgs.simplified();
            if (!syntax[i].outArgs.isEmpty())
              syntaxText += " ";
            syntaxText += syntax[i].opcodeName.simplified();
            if (!syntax[i].inArgs.isEmpty()) {
              syntaxText += " " + syntax[i].inArgs.simplified();
            }
            a->setData(syntaxText);
          }
          if (!allEqual) {
            QRect r =  mainEditor->cursorRect();
            QPoint p = QPoint(r.x() + r.width(), r.y() + r.height());
            QPoint globalPoint =  mainEditor->mapToGlobal(p);
            syntaxMenu->setWindowModality(Qt::NonModal);
            syntaxMenu->popup(globalPoint);
            //    syntaxMenu->move(QPoint(r.x() + r.width(), r.y() + r.height()));
            //    syntaxMenu->show();
            mainEditor->setFocus(Qt::OtherFocusReason);
          }
          else {
            destroySyntaxMenu();
          }
        }
      }
    }
    syntaxCheck();
  }
  else if (m_mode == 1) { // Python Mode
    // Nothing for now
  }

}

void DocumentView::findReplace()
{
  // TODO implment for multiple views
  internalChange = true;
  QTextCursor cursor = mainEditor->textCursor();
  QString word = cursor.selectedText();
  cursor.select(QTextCursor::WordUnderCursor);
  QString word2 = cursor.selectedText();
  if (word == word2 && word!= "") {
    lastSearch = word;
  }
  FindReplace *dialog = new FindReplace(this,
                                        editors[0],
                                        &lastSearch,
                                        &lastReplace,
                                        &lastCaseSensitive);
  // lastSearch and lastReplace are passed by reference to be
  // updated by FindReplace dialog
  connect(dialog, SIGNAL(findString(QString)), this, SLOT(findString(QString)));
  dialog->show();
}

void DocumentView::getToIn()
{
  // TODO implment for multiple views
  internalChange = true;
  editors[0]->setPlainText(changeToInvalue(editors[0]->toPlainText()));
  editors[0]->document()->setModified(true);  // Necessary, or is setting it locally enough?
}

void DocumentView::inToGet()
{
  // TODO implment for multiple views
  internalChange = true;
  editors[0]->setPlainText(changeToChnget(editors[0]->toPlainText()));
  editors[0]->document()->setModified(true);
}

void DocumentView::autoComplete()
{
  internalChange = true;
  QTextCursor cursor = mainEditor->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  QString opcodeName = cursor.selectedText();
  if (opcodeName=="")
    return;
  mainEditor->setTextCursor(cursor);
  mainEditor->cut();
  QString syntax = m_opcodeTree->getSyntax(opcodeName);
  internalChange = true;
  mainEditor->insertPlainText(syntax);
}

void DocumentView::insertTextFromAction()
{
  internalChange = true;
  QAction *action = static_cast<QAction *>(QObject::sender());
  bool insertComplete = static_cast<MySyntaxMenu *>(action->parent())->insertComplete;
  QTextCursor cursor = editors[0]->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  cursor.insertText("");
  editors[0]->setTextCursor(cursor);
  
  QTextCursor cursor2 = editors[0]->textCursor();
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
      editors[0]->insertPlainText(syntaxText.mid(index + 1).trimmed());  // right returns the whole string if index < 0
    }
    else {
      editors[0]->insertPlainText(action->data().toString());
    }
  }
  else {
    int index = action->text().indexOf(" ");
    if (index > 0) {
      editors[0]->insertPlainText(action->text().left(index));
    }
    else {
      editors[0]->insertPlainText(action->text());
    }
  }
}

void DocumentView::findString(QString query)
{
  // TODO search across all editors
  qDebug() << "DocumentView::findString " << query;
  if (query == "") {
    query = lastSearch;
  }
  bool found = false;
  if (lastCaseSensitive) {
    found = editors[0]->find(query,
                             QTextDocument::FindCaseSensitively);
  }
  else
    found = editors[0]->find(query);
  if (!found) {
    int ret = QMessageBox::question(this, tr("Find and replace"),
                                    tr("The string was not found.\n"
                                        "Would you like to start from the top?"),
                                        QMessageBox::Yes | QMessageBox::No,
                                        QMessageBox::No
                                   );
    if (ret == QMessageBox::Yes) {
      editors[0]->moveCursor(QTextCursor::Start);
      findString();
    }
  }
}

void DocumentView::createContextMenu(QPoint pos)
{
  QMenu *menu = editors[0]->createStandardContextMenu();
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
  menu->exec(editors[0]->mapToGlobal(pos));
  delete menu;
}

void DocumentView::cut()
{
  if (m_viewMode < 2) {
    mainEditor->cut();
  }
  else {
    qDebug() << "DocumentView::cut() not implemented for split view";
  }
}

void DocumentView::copy()
{
  if (m_viewMode < 2) {
    mainEditor->copy();
  }
  else {
    qDebug() << "DocumentView::copy() not implemented for split view";
  }
}

void DocumentView::paste()
{
  if (m_viewMode < 2) {
    mainEditor->paste();
  }
  else {
    qDebug() << "DocumentView::paste() not implemented for split view";
  }
}

void DocumentView::undo()
{
  if (m_viewMode < 2) {
    mainEditor->undo();
  }
  else {
    qDebug() << "DocumentView::undo() not implemented for split view";
  }
}

void DocumentView::redo()
{
  if (m_viewMode < 2) {
    mainEditor->redo();
  }
  else {
    qDebug() << "DocumentView::redo() not implemented for split view";
  }
}

void DocumentView::comment()
{
  // TODO implment for multiple views
//  qDebug() << "DocumentView::comment()";
  internalChange = true;
  QString commentChar = "";
  if (m_mode == 0) {
    commentChar = ";";
  }
  else if (m_mode == 1) { // Python Mode
    commentChar = "#";
  }
  QTextCursor cursor = editors[0]->textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  if (!cursor.atBlockStart()) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
  }
  QString text = cursor.selectedText();
  text.prepend(commentChar);
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n" + commentChar));
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);
}

void DocumentView::uncomment()
{
  // TODO implment for multiple views
  internalChange = true;
  QString commentChar = "";
  if (m_mode == 0) {
    commentChar = ";";
  }
  else if (m_mode == 1) { // Python Mode
    commentChar = "#";
  }
  QTextCursor cursor = editors[0]->textCursor();
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
  if (text.startsWith(commentChar))
    text.remove(0,1);
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
  text.replace(QString("\n" + commentChar), QString("\n")); //TODO make more robust
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);
}

void DocumentView::indent()
{
  // TODO implment for multiple views
//   qDebug("DocumentPage::indent");
  internalChange = true;
  QString indentChar = "";
  if (m_mode == 0) {
    indentChar = "\t";
  }
  else if (m_mode == 1) { // Python Mode
    indentChar = "    ";
  }
  QTextCursor cursor = editors[0]->textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  if (!cursor.atBlockStart()) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
  }
  QString text = cursor.selectedText();
  text.prepend(indentChar);
  text.replace(QChar(QChar::ParagraphSeparator), "\n" + indentChar);
  text.replace(QChar(QChar::ParagraphSeparator), "\n" + indentChar);
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);
}

void DocumentView::unindent()
{
  // TODO implment for multiple views
  internalChange = true;
  QString indentChar = "";
  if (m_mode == 0) {
    indentChar = "\t";
  }
  else if (m_mode == 1) { // Python Mode
    indentChar = "    ";
  }
  QTextCursor cursor = editors[0]->textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  if (!cursor.atBlockStart()) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
  }
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
  editors[0]->setTextCursor(cursor);
}

void DocumentView::killLine()
{
  // TODO implment for multiple views
//  internalChange = true;
  QString indentChar = "";
//  if (m_mode == 0) {
//    indentChar = "\t";
//  }
//  else if (m_mode == 1) { // Python Mode
//    indentChar = "    ";
//  }
  QTextCursor cursor = editors[0]->textCursor();
  if (!cursor.atBlockStart()) {
    cursor.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
  }
  cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
  cursor.insertText("");
}

void DocumentView::killToEnd()
{
  // TODO implment for multiple views
//  internalChange = true;
  QString indentChar = "";
//  if (m_mode == 0) {
//    indentChar = "\t";
//  }
//  else if (m_mode == 1) { // Python Mode
//    indentChar = "    ";
//  }
  QTextCursor cursor = editors[0]->textCursor();
  if (!cursor.atBlockEnd()) {
    cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
  }
  cursor.insertText("");
}

void DocumentView::markErrorLines(QList<QPair<int, QString> > lines)
{
  // TODO implment for multiple views
  bool originallyMod = editors[0]->document()->isModified();
  internalChange = true;
  QTextCharFormat errorFormat;
  errorFormat.setBackground(QBrush(QColor(255, 182, 193)));
  QTextCursor cur = editors[0]->textCursor();
  cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
  int lineCount = 1;
  for(int i = 0; i < lines.size(); i++) {
    int line = lines[i].first;
    QString text = lines[i].second;
    while (lineCount < line) {
      lineCount++;
//       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
      cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
    }
    cur.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
    if (cur.selectedText().simplified() == text.simplified()) {
      cur.mergeCharFormat(errorFormat);
      internalChange = true;
      editors[0]->setTextCursor(cur);
      cur.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
    }
    else {
      qDebug() << "DocumentView::markErrorLines: Error line text doesn't match\n" << text;
    }
  }
  internalChange = true;
  editors[0]->setTextCursor(cur);
  errorMarked = true;
  if (!originallyMod) {
    editors[0]->document()->setModified(false);
  }
}

void DocumentView::unmarkErrorLines()
{
  // TODO implment for multiple views
  if (!errorMarked)
    return;
//   qDebug("DocumentPage::unmarkErrorLines()");
  int position = editors[0]->verticalScrollBar()->value();
  QTextCursor currentCursor = editors[0]->textCursor();
  errorMarked = false;
  editors[0]->selectAll();
  internalChange = true;
  QTextCursor cur = editors[0]->textCursor();
  QTextCharFormat format = cur.blockCharFormat();
  format.clearBackground();
  cur.setCharFormat(format);
  internalChange = true;
  editors[0]->setTextCursor(cur);  //sets format
  internalChange = true;
  editors[0]->setTextCursor(currentCursor); //returns cursor to initial position
  editors[0]->verticalScrollBar()->setValue(position); //return document display to initial position
}

void DocumentView::jumpToLine(int line)
{
  // TODO implment for multiple views
  int lineCount = 1;
  QTextCursor cur = editors[0]->textCursor();
  cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
  while (lineCount < line) {
    lineCount++;
    //       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
    cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
  }
  editors[0]->moveCursor(QTextCursor::End); // go to end to make sure line is put at the top of text
  editors[0]->setTextCursor(cur);
}

void DocumentView::opcodeFromMenu()
{
  QAction *action = (QAction *) QObject::sender();
  QTextCursor cursor = editors[0]->textCursor();
  QString text = action->data().toString();
  cursor.insertText(text);
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

void DocumentView::createSyntaxMenu()
{
  syntaxMenu = new MySyntaxMenu(mainEditor);
//  syntaxMenu->setFocusPolicy(Qt::NoFocus);
  syntaxMenu->setAutoFillBackground(true);
  QPalette p =syntaxMenu-> palette();
  p.setColor(QPalette::WindowText, Qt::blue);
  p.setColor(QPalette::Active, static_cast<QPalette::ColorRole>(9), Qt::yellow);
  syntaxMenu->setPalette(p);
  connect(syntaxMenu,SIGNAL(keyPressed(QString)),
          mainEditor, SLOT(insertPlainText(QString)));
  connect(syntaxMenu,SIGNAL(aboutToHide()),
          this, SLOT(destroySyntaxMenu()));
}

void DocumentView::hideAllEditors()
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->hide();
    splitter->handle(i)->hide();
  }
}

void DocumentView::destroySyntaxMenu()
{
  syntaxMenu->deleteLater();
  syntaxMenu = 0;
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
    this->hide();
    if (event->key() != Qt::Key_Backspace) {
      emit keyPressed(event->text());
    }
  }
  insertComplete = true;
  QMenu::keyPressEvent(event);
}
