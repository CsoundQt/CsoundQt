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

DocumentView::DocumentView(QWidget * parent, OpEntryParser *opcodeTree) :
    QWidget(parent),  m_opcodeTree(opcodeTree)
{
  mainEditor = new QTextEdit(this);
  scoreEditor = new QTextEdit(this);
  optionsEditor = new QTextEdit(this);
  filebEditor = new QTextEdit(this);
  versionEditor = new QTextEdit(this);
  licenceEditor = new QTextEdit(this);
  otherEditor = new QTextEdit(this);
  widgetEditor = new QTextEdit(this);
  editors << mainEditor << scoreEditor << optionsEditor << filebEditor
      << versionEditor << licenceEditor << otherEditor << widgetEditor;
  splitter = new QSplitter(this);
  splitter->setOrientation(Qt::Vertical);
  for (int i = 0; editors.size(); i++) {
    connect(editors[i], SIGNAL(textChanged()), this, SLOT(setModified()));
    splitter->addWidget(editors[i]);
  }

  m_highlighter = new Highlighter();

  connect(mainEditor, SIGNAL(textChanged()),
          this, SLOT(syntaxCheck()));
  connect(mainEditor, SIGNAL(cursorPositionChanged()),
          this, SLOT(syntaxCheck()));

  //FIXME put this for line reporting for score editor
//  connect(scoreEditor, SIGNAL(textChanged()),
//          this, SLOT(syntaxCheck()));
//  connect(scoreEditor, SIGNAL(cursorPositionChanged()),
//          this, SLOT(syntaxCheck()));

  setViewMode(0);
  m_highlighter->setDocument(editor[0]);
}

DocumentView::~DocumentView()
{
  // FIXME check if this is being called
  delete m_highlighter;
}

void DocumentView::setViewMode(int mode)
{
  if (m_viewMode == mode)
    return;
  m_viewMode = mode;
  hideAllEditors();

  // FIXME implement modes properly
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

void DocumentView::setFont(QString font)
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
    editors[i]->setTabWidth(width);
  }
}

void DocumentView::setTabStopWidth(int width)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setTabStopWidth(width);
  }
}

void DocumentView::setLineWrapMode(int mode)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setLineWrapMode(mode);
  }
}

void DocumentView::setColorVariables(bool color)
{
  m_highlighter->setColorVariables(color);
}

void DocumentView::setOpcodeNameList(QStringList list)
{
  // FIXME highlighter should be moved to main application class and this should only be done once!
  m_highlighter->setOpcodeNameList(list);
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
  m_isModified = mod;
}

void DocumentView::setOpcodeTree(OpEntryParser *opcodeTree)
{
  m_opcodeTree = opcodeTree;
}

QString DocumentView::wordUnderCursor()
{
  QTextCursor cursor = editors[0]->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  return cursor->selectedText();
}

void DocumentView::updateDocumentModel()
{
  // FIXME this should update the document model when needed
  // e.g. on run or save or when widgets or presets have been modified in text format
  // maybe the document model pointer should be passed and processed here.
}

void DocumentView::updateFromDocumentModel()
{
  // FIXME this should update from the document model when needed
  // e.g. on loading, widget changes from widget layout
}

void DocumentView::syntaxCheck()
{
  // FIXME check properly for line number also from second editor
  emit lineNumberSignal(mainEditor->currentLine());
  //FIXME connect this signal to main class showLineNumber
  QTextCursor cursor = mainEditor->textCursor();
  cursor.select(QTextCursor::LineUnderCursor);
  QStringList words = cursor.selectedText().split(QRegExp("\\b"));
  foreach(QString word, words) {
    // We need to remove all not possibly opcode
    word.remove(QRegExp("[^\\d\\w]"));
    if (!word.isEmpty()) {
      QString syntax = opcodeTree->getSyntax(word);
      if(!syntax.isEmpty()) {
        emit opcodeSyntaxSignal(syntax);
        return;
      }
    }
  }
}

void DocumentView::findReplace()
{
  FindReplace *dialog = new FindReplace(this,
                                        editors[0],
                                        &lastSearch,
                                        &lastReplace,
                                        &lastCaseSensitive);
  // lastSearch and lastReplace are passed by reference so they are
  // updated by FindReplace dialog
  connect(dialog, SIGNAL(findString(QString)), this, SLOT(findString(QString)));
  dialog->show();
}

void DocumentView::getToIn()
{
  editors[0]->setPlainText(changeToInvalue(editors[0]->toPlainText()));
  editors[0]->document()->setModified(true);  // Necessary, or is setting it locally enough?
}

void DocumentView::inToGet()
{
  editors[0]->setPlainText(changeToChnget(editors[0]->toPlainText()));
  editors[0]->document()->setModified(true);
}

void DocumentView::comment()
{
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
  text.prepend(";");
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n;"));
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);
}

void DocumentView::uncomment()
{
  QTextCursor cursor = editors[0]->textCursor();
  if (cursor.position() > cursor.anchor()) {
    int temp = cursor.anchor();
    cursor.setPosition(cursor.position());
    cursor.setPosition(temp, QTextCursor::KeepAnchor);
  }
  QString text = cursor.selectedText();
  if (!cursor.atBlockStart() && !text.startsWith(";")) {
    cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
    text = cursor.selectedText();
  }
  if (text.startsWith(";"))
    text.remove(0,1);
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
  text.replace(QString("\n;"), QString("\n")); //TODO make more robust
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);
}

void DocumentView::indent()
{
//   qDebug("DocumentPage::indent");
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
//   if (text[0] == '\n')
  text.prepend("\t"); //TODO check if previous character is \n
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n\t"));
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);
}

void DocumentView::unindent()
{
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
  if (text.startsWith("\t"))
    text.remove(0,1);
  text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
  text.replace(QString("\n\t"), QString("\n")); //TODO make more robust
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);
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

void DocumentView::autoComplete()
{
  QTextCursor cursor = mainEditor->textCursor();
  cursor.select(QTextCursor::WordUnderCursor);
  QString opcodeName = cursor.selectedText();
  if (opcodeName=="")
    return;
  mainEditor->setTextCursor(cursor);
  mainEditor->cut();
  QString syntax = opcodeTree->getSyntax(opcodeName);
  mainEditor->insertPlainText (syntax);
}

void DocumentView::hideAllEditors()
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->hide();
  }
}

void DocumentView::findString(QString query)
{
  //FIXME search across all editors
  qDebug() << "qutecsound::findString " << query;
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

