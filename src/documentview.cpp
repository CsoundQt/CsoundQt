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
#include "findreplace.h"
#include "opentryparser.h"
#include "node.h"
#include "types.h"

#include "highlighter.h"
#include "texteditor.h"

DocumentView::DocumentView(QWidget * parent, OpEntryParser *opcodeTree) :
    BaseView(parent,opcodeTree)
{
  for (int i = 0; i < editors.size(); i++) {
    connect(editors[i], SIGNAL(textChanged()), this, SLOT(setModified()));
    splitter->addWidget(editors[i]);
    editors[i]->setContextMenuPolicy(Qt::CustomContextMenu);
    connect(editors[i], SIGNAL(customContextMenuRequested(QPoint)),
            this, SLOT(createContextMenu(QPoint)));
  }
  setFocusProxy(mainEditor);  // for comment action from main application
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

  errorMarked = false;
  m_isModified = false;

  syntaxMenu = new MySyntaxMenu(mainEditor);
//  syntaxMenu->setFocusPolicy(Qt::NoFocus);
  syntaxMenu->setAutoFillBackground(true);
  QPalette p =syntaxMenu-> palette();
  p.setColor(QPalette::WindowText, Qt::blue);
  p.setColor(static_cast<QPalette::ColorRole>(9), Qt::yellow);
  syntaxMenu->setPalette(p);
  connect(syntaxMenu,SIGNAL(keyPressed(QString)),
          mainEditor, SLOT(insertPlainText(QString)));
//  connect(syntaxMenu,SIGNAL(aboutToHide()),
//          this, SLOT(destroySyntaxMenu()));

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

void DocumentView::print(QPrinter *printer)
{
  mainEditor->print(printer);
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
    cursor = mainEditor->textCursor();
    cursor.insertText(text);
    mainEditor->setTextCursor(cursor);
    break;
//  case 1:
    //    scoreEditor;
//    break;
//  case 2:
    //    optionsEditor;
//    break;
//  case 3:
    //    filebEditor;
//    break;
//  case 4:
    //    versionEditor;
//    break;
//  case 5:
    //    licenceEditor;
//    break;
//  case 6:
    //    otherEditor;
//    break;
//  case 7:
    //    widgetEditor;
//    break;
//  case 8:
    //    ladspaEditor;
//    break;
//  case 9:
//    break;
  default:
    qDebug() <<"DocumentView::insertText section " << section << " not implemented.";
  }
}

void DocumentView::setBasicText(QString text)
{
  QTextCursor cursor = mainEditor->textCursor();
  cursor.select(QTextCursor::Document);
  cursor.insertText(text);
  mainEditor->setTextCursor(cursor);  // TODO implment for multiple views
}

void DocumentView::setOrc(QString text)
{
  if (m_viewMode < 2) { // View is not split
    if (m_mode != 0) {
      qDebug() << "DocumentView::setOrc Current file is not a csd file. Text not inserted!";
      return;
    }
    QString csdText = getBasicText();
    if (csdText.contains("<CsInstruments>") and csdText.contains("</CsInstruments>")) {
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
  else {
    mainEditor->setPlainText(text);
  }
}

void DocumentView::setSco(QString text)
{
  if (m_viewMode < 2) { // View is not split
    if (m_mode != 0) {
      qDebug() << "DocumentView::setSco Current file is not a csd file. Text not inserted!";
      return;
    }
    QString csdText = getBasicText();
    if (csdText.contains("<CsScore>") and csdText.contains("</CsScore>")) {
      QString preText = csdText.mid(0, csdText.indexOf("<CsScore>") + 9);
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
    scoreEditor->setPlainText(text);
  }
}

void DocumentView::setFileB(QString text)
{
  filebEditor->setPlainText(text);
}

void DocumentView::setLadspaText(QString text)
{
  if (m_viewMode < 2) { // View is not split
    if (m_mode != 0) {
      qDebug() << "DocumentView::setLadspaText Current file is not a csd file. Text not inserted!";
      return;
    }
    QTextCursor cursor;
    cursor = mainEditor->textCursor();
    mainEditor->moveCursor(QTextCursor::Start);
    if (mainEditor->find("<csLADSPA>") and mainEditor->find("</csLADSPA>")) {
      QString curText = getBasicText();
      int index = curText.indexOf("<csLADSPA>");
      int endIndex = curText.indexOf("</csLADSPA>") + 11;
      if (curText.size() > endIndex + 1 && curText[endIndex + 1] == '\n') {
        endIndex++; // Include last line break
      }
      curText.remove(index, endIndex - index);
      curText.insert(index, text);
      setBasicText(curText);
      mainEditor->moveCursor(QTextCursor::Start);
    }
    else { //csLADSPA section not present, or incomplete
      mainEditor->find("<CsoundSynthesizer>"); //cursor moves there
      mainEditor->moveCursor(QTextCursor::EndOfLine);
      mainEditor->insertPlainText(QString("\n") + text + QString("\n"));
    }
  }
  else {
    ladspaEditor->setText(text);
    ladspaEditor->moveCursor(QTextCursor::Start);
  }
}

void DocumentView::setAutoComplete(bool autoComplete)
{
  m_autoComplete = autoComplete;
}

QString DocumentView::getSelectedText(int section)
{
  if (section < 0) {
    section = 0;  // TODO implment for multiple views
  }
  QString text;
  switch(section) {
  case 0:
    text = mainEditor->textCursor().selectedText();
    break;
  case 1:
    text = scoreEditor->getSelection();
    break;
  case 2:
    text = optionsEditor->textCursor().selectedText();
    //    ;
    break;
  case 3:
    //    filebEditor;
    break;
  case 4:
    text = versionEditor->textCursor().selectedText();
    break;
  case 5:
    text = licenceEditor->textCursor().selectedText();
    break;
  case 6:
    text = otherEditor->textCursor().selectedText();
    break;
  case 7:
    text = widgetEditor->textCursor().selectedText();
    break;
  case 8:
    text = ladspaEditor->textCursor().selectedText();
    break;
//  case 9:
//    break;
  default:
    qDebug() <<"DocumentView::insertText section " << section << " not implemented.";
  }
  return text;
}

QString DocumentView::getFullText()
{
  QString text;
  if (m_viewMode < 2) { // View is not split
    text = mainEditor->toPlainText();
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
    text += otherEditor->toPlainText();
    sectionText = ladspaEditor->toPlainText();
    if (!sectionText.isEmpty()) {
      text += "<csLADSPA>\n" + sectionText + "</csLADSPA>\n";
    }
    text += "<CsoundSynthesizer>\n";
    sectionText = optionsEditor->toPlainText();
    if (!sectionText.isEmpty()) {
      text += "<CsOptions>\n" + sectionText + "</CsOptions>\n";
    }
    sectionText = versionEditor->toPlainText();
    if (!sectionText.isEmpty()) {
      text += "<CsVersion>\n" + sectionText + "</CsVersion>\n";
    }
    sectionText = versionEditor->toPlainText();
    if (!sectionText.isEmpty()) {
      text += "<CsLicense>\n" + sectionText + "</CsLicense>\n";
    }
    text += "<CsInstruments>\n" + mainEditor->toPlainText() + "</CsInstruments>\n";
    text += "<CsScore>\n" + mainEditor->toPlainText() + "</CsScore>\n";
    sectionText = getFileB();
    if (!sectionText.isEmpty()) {
      text += getFileB();
    }
  }
  return text;
}

QString DocumentView::getBasicText()
{
//   What Csound needs (no widgets, misc text, etc.)
  // TODO implement modes
  QString text;
  text = mainEditor->toPlainText(); // csd without extra sections
  if (m_viewMode & 16) {
    text += getFileB();
  }
  return text;
}

QString DocumentView::getOrc()
{
  QString text = "";
  if (m_viewMode < 2) { // A single editor (orc and sco are not split)
    text = mainEditor->toPlainText();
    text = text.mid(text.lastIndexOf("<CsInstruments>" )+ 15);
    qDebug() << text;
    text.remove(text.lastIndexOf("</CsInstruments>"), text.size());
  }
  else {
    text = mainEditor->toPlainText();
  }
  return text;
}

QString DocumentView::getSco()
{
  QString text = "";
  if (m_viewMode < 2) {
    text = mainEditor->toPlainText();
    text = text.mid(text.lastIndexOf("<CsScore>") + 9);
    text.remove(text.lastIndexOf("</CsScore>"), text.size());
  }
  else { // Split view
    text = scoreEditor->getPlainText();
  }
  return text;
}

QString DocumentView::getOptionsText()
{
  // Returns text without tags
  QString text = "";
  if (m_viewMode < 2) {// A single editor (orc and sco are not split)
    QString edText = mainEditor->toPlainText();
    int index = edText.indexOf("<CsOptions>");
    if (index >= 0 && edText.contains("</CsOptions>")) {
      text = edText.mid(index + 11, edText.indexOf("</CsOptions>") - index - 11);
    }
  }
  else { //  Split view
    text = optionsEditor->toPlainText();
  }
  return text;
}

QString DocumentView::getFileB()
{
  return filebEditor->toPlainText();
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
  // Returns text without tags
  int line = -1;
  if (m_viewMode < 2) {// A single editor (orc and sco are not split)
    QTextCursor cursor = mainEditor->textCursor();
    line = cursor.blockNumber() + 1;
  }
  else { //  Split view
    // TODO check properly for line number also from other editors
    qDebug() << "DocumentView::currentLine() not implemented for split view.";
  }
  return line;
}

QString DocumentView::wordUnderCursor()
{
  QString word;
  if (m_viewMode < 2) {// A single editor (orc and sco are not split)
    QTextCursor cursor = mainEditor->textCursor();
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
    QTextCursor cursor = mainEditor->textCursor();
    cursor.select(QTextCursor::LineUnderCursor);
    bool sectionStart = cursor.selectedText().simplified().startsWith("##");
    while (!sectionStart && !cursor.anchor() == 0) {
      cursor.movePosition(QTextCursor::PreviousBlock);
      cursor.select(QTextCursor::LineUnderCursor);
      sectionStart = cursor.selectedText().simplified().startsWith("##");
    }
    int start = cursor.anchor();
    cursor = mainEditor->textCursor();
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
    mainEditor->setTextCursor(cursor);
    section = cursor.selectedText();
    section.replace(QChar(0x2029), QChar('\n'));
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
    QTextCursor cursor = mainEditor->textCursor();
    QString selection = cursor.selectedText();
    if (selection == "") {
      cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::MoveAnchor);
      cursor.movePosition(QTextCursor::EndOfLine, QTextCursor::KeepAnchor);
      selection = cursor.selectedText();

    }
    selection.replace(QChar(0x2029), QChar('\n'));
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
            QRect r =  mainEditor->cursorRect();
            QPoint p = QPoint(r.x() + r.width(), r.y() + r.height());
            QPoint globalPoint =  mainEditor->mapToGlobal(p);
            //syntaxMenu->setWindowModality(Qt::NonModal);
            //syntaxMenu->popup(globalPoint);
            syntaxMenu->move(globalPoint);
            syntaxMenu->show();
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
  if (m_viewMode < 2) {
    QTextCursor cursor = mainEditor->textCursor();
    QString word = cursor.selectedText();
    cursor.select(QTextCursor::WordUnderCursor);
    QString word2 = cursor.selectedText();
    if (word == word2 && word!= "") {
      lastSearch = word;
    }
    FindReplace *dialog = new FindReplace(this,
                                          mainEditor,
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
    mainEditor->setPlainText(changeToInvalue(mainEditor->toPlainText()));
    mainEditor->document()->setModified(true);  // Necessary, or is setting it locally enough?
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
    mainEditor->setPlainText(changeToChnget(mainEditor->toPlainText()));
    mainEditor->document()->setModified(true);
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
  else { //  Split view
    // TODO check properly for line number also from other editors
    qDebug() << "DocumentView::autoComplete() not implemented for split view.";
  }
}

void DocumentView::insertTextFromAction()
{
  if (m_viewMode < 2) {
    internalChange = true;
    QAction *action = static_cast<QAction *>(QObject::sender());
    bool insertComplete = static_cast<MySyntaxMenu *>(action->parent())->insertComplete;
    QTextCursor cursor = mainEditor->textCursor();
    cursor.select(QTextCursor::WordUnderCursor);
    cursor.insertText("");
    mainEditor->setTextCursor(cursor);

    QTextCursor cursor2 = mainEditor->textCursor();
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
        mainEditor->insertPlainText(syntaxText.mid(index + 1).trimmed());  // right returns the whole string if index < 0
      }
      else {
        mainEditor->insertPlainText(action->data().toString());
      }
    }
    else {
      int index = action->text().indexOf(" ");
      if (index > 0) {
        mainEditor->insertPlainText(action->text().left(index));
      }
      else {
        mainEditor->insertPlainText(action->text());
      }
    }
  }
  else { //  Split view
    // TODO check properly for line number also from other editors
    qDebug() << "DocumentView::insertTextFromAction() not implemented for split view.";
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
      found = mainEditor->find(query,
                               QTextDocument::FindCaseSensitively);
    }
    else
      found = mainEditor->find(query);
    if (!found) {
      int ret = QMessageBox::question(this, tr("Find and replace"),
                                      tr("The string was not found.\n"
                                          "Would you like to start from the top?"),
                                          QMessageBox::Yes | QMessageBox::No,
                                          QMessageBox::No
                                     );
      if (ret == QMessageBox::Yes) {
        mainEditor->moveCursor(QTextCursor::Start);
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
    QMenu *menu = mainEditor->createStandardContextMenu();
    menu->addSeparator();
    menu->addAction(tr("Evaluate Selection"), this, SLOT(evaluate()));
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
    menu->exec(mainEditor->mapToGlobal(pos));
    delete menu;
  }
  else { //  Split view
    // TODO check properly for line number also from other editors
    qDebug() << "DocumentView::createContextMenu() not implemented for split view.";
  }
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
  if (m_viewMode < 2) {
    internalChange = true;
    QString commentChar = "";
    if (m_mode == 0) {
      commentChar = ";";
    }
    else if (m_mode == 1) { // Python Mode
      commentChar = "#";
    }
    QTextCursor cursor = mainEditor->textCursor();
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
    mainEditor->setTextCursor(cursor);
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
    if (m_mode == 0) {
      commentChar = ";";
    }
    else if (m_mode == 1) { // Python Mode
      commentChar = "#";
    }
    QTextCursor cursor = mainEditor->textCursor();
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
    mainEditor->setTextCursor(cursor);
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
    if (m_mode == 0) {
      indentChar = "\t";
    }
    else if (m_mode == 1) { // Python Mode
      indentChar = "    ";
    }
    QTextCursor cursor = mainEditor->textCursor();
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
    mainEditor->setTextCursor(cursor);
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
    if (m_mode == 0) {
      indentChar = "\t";
    }
    else if (m_mode == 1) { // Python Mode
      indentChar = "    ";
    }
    QTextCursor cursor = mainEditor->textCursor();
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
    mainEditor->setTextCursor(cursor);
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
    QTextCursor cursor = mainEditor->textCursor();
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
    QTextCursor cursor = mainEditor->textCursor();
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
  // TODO implment for multiple views
  if (m_viewMode < 2) {
    bool originallyMod = mainEditor->document()->isModified();
    internalChange = true;
    QTextCharFormat errorFormat;
    errorFormat.setBackground(QBrush(QColor(255, 182, 193)));
    QTextCursor cur = mainEditor->textCursor();
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
        mainEditor->setTextCursor(cur);
        cur.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor);
        cur.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor);
        cur.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor);
        cur.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor);
        cur.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor); // go up 5 lines
        cur.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
      }
      else {
        qDebug() << "DocumentView::markErrorLines: Error line text doesn't match\n" << text;
      }
    }
    //  internalChange = true;
    //  editors[0]->setTextCursor(cur);
    errorMarked = true;
    if (!originallyMod) {
      mainEditor->document()->setModified(false);
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
    int position = mainEditor->verticalScrollBar()->value();
    QTextCursor currentCursor = mainEditor->textCursor();
    errorMarked = false;
    mainEditor->selectAll();
    internalChange = true;
    QTextCursor cur = mainEditor->textCursor();
    QTextCharFormat format = cur.blockCharFormat();
    format.clearBackground();
    cur.setCharFormat(format);
    internalChange = true;
    mainEditor->setTextCursor(cur);  //sets format
    internalChange = true;
    mainEditor->setTextCursor(currentCursor); //returns cursor to initial position
    mainEditor->verticalScrollBar()->setValue(position); //return document display to initial position
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
    QTextCursor cur = mainEditor->textCursor();
    cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
    while (lineCount < line) {
      lineCount++;
      //       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
      cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
    }
    mainEditor->moveCursor(QTextCursor::End); // go to end to make sure line is put at the top of text
    mainEditor->setTextCursor(cur);
  }
  else {
    qDebug() << "DocumentView::jumpToLine() not implemented for split view";
  }
}

void DocumentView::opcodeFromMenu()
{
  QAction *action = (QAction *) QObject::sender();
  if (m_viewMode < 2) {
    QTextCursor cursor = mainEditor->textCursor();
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
