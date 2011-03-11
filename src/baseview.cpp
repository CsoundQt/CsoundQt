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
  mainEditor = new TextEditor(this);
  orcEditor = new TextEditor(this);
  scoreEditor = new ScoreEditor(this);
  optionsEditor = new TextEditor(this);
  optionsEditor->setMaximumHeight(60);
  filebEditor = new TextEditor(this);
  otherEditor = new TextEditor(this);
  otherCsdEditor = new TextEditor(this);
  widgetEditor = new TextEditor(this);
  editors << mainEditor << orcEditor << scoreEditor << optionsEditor << filebEditor
      << otherEditor << otherCsdEditor << widgetEditor;
  splitter = new QSplitter(this); // Deleted with parent
  splitter->setOrientation(Qt::Vertical);
  splitter->setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
  splitter->setContextMenuPolicy (Qt::NoContextMenu);

  QStackedLayout *l = new QStackedLayout(this);  // Deleted with parent
  l->addWidget(splitter);
  setLayout(l);
  m_mode = 0;
  m_highlighter.setOpcodeNameList(opcodeTree->opcodeNameList());
  m_highlighter.setDocument(mainEditor->document());
}

BaseView::~BaseView()
{
}

void BaseView::setFullText(QString text, bool goToTop)
{
  // Load Embedded Files ------------------------
  // Must be done here to remove the files for single file view
  QString fileText = "";
  while (text.contains("<CsFileB ") and text.contains("</CsFileB>")) {
    bool endsWithBreak = false;
    if (text.indexOf("</CsFileB>") + 10 < text.size() && text[text.indexOf("</CsFileB>") + 10] == '\n' ) {
      endsWithBreak = true;
    }
    QString currentFileText = text.mid(text.indexOf("<CsFileB "),
                                       text.indexOf("</CsFileB>") - text.indexOf("<CsFileB ") + 10
                                       + (endsWithBreak ? 1:0));
    text.remove(text.indexOf("<CsFileB "), currentFileText.size());
    fileText += currentFileText;
  }
  setFileB(fileText);
  if (m_viewMode < 2) {  // Unified view
    QTextCursor cursor = mainEditor->textCursor();
    cursor.select(QTextCursor::Document);
    cursor.insertText(text);
    mainEditor->setTextCursor(cursor);  // TODO implement for multiple views
    if (goToTop) {
      mainEditor->moveCursor(QTextCursor::Start);
    }
  }
  else { // Split view
    int startIndex,endIndex;
    QString sectionText = "";
    // Find orchestra section
    QString tag = "CsInstruments";
    startIndex = text.indexOf("<" + tag + ">");
    if (text.size() > startIndex + tag.size() + 2
        && text[startIndex +  tag.size() + 2] == '\n') {
      startIndex++;
    }
    endIndex = text.indexOf("</" + tag + ">") + tag.size() + 3;
    if (text.size() > endIndex + 1 && text[endIndex+1] == '\n') {
      endIndex++;
    }
    if (startIndex >= 0 && endIndex > startIndex) {
      sectionText = text.mid(startIndex, endIndex - startIndex);
      text.remove(sectionText);
    }
    setOrc(sectionText.mid(tag.size() + 2, sectionText.size() - (tag.size()*2) - 5));
    // Find score section
    sectionText = "";
    tag = "CsScore";
    startIndex = text.indexOf("<" + tag + ">");
    if (text.size() > startIndex + tag.size() + 2
        && text[startIndex +  tag.size() + 2] == '\n') {
      startIndex++;
    }
    endIndex = text.indexOf("</" + tag + ">") + tag.size() + 3;
    if (text.size() > endIndex + 1 && text[endIndex+1] == '\n') {
      endIndex++;
    }
    if (startIndex >= 0 && endIndex > startIndex) {
      sectionText = text.mid(startIndex, endIndex - startIndex);
      text.remove(sectionText);
    }
    setSco(sectionText.mid(tag.size() + 2, sectionText.size() - (tag.size()*2) - 5));
    // Set options text
    sectionText = "";
    tag = "CsOptions";
    startIndex = text.indexOf("<" + tag + ">");
    if (text.size() > startIndex + tag.size() + 2
        && text[startIndex +  tag.size() + 2] == '\n') {
      startIndex++;
    }
    endIndex = text.indexOf("</" + tag + ">") + tag.size() + 3;
    if (text.size() > endIndex + 1 && text[endIndex+1] == '\n') {
      endIndex++;
    }
    if (startIndex >= 0 && endIndex > startIndex) {
      sectionText = text.mid(startIndex, endIndex - startIndex);
      text.remove(sectionText);
    }
    setOptionsText(sectionText.mid(tag.size() + 2, sectionText.size() - (tag.size()*2) - 5));
//    otherEditor->setText(text); // Any remaining text
  }
}

void BaseView::setBasicText(QString text)
{
  if (m_viewMode < 2) {  // Unified view
    QTextCursor cursor = mainEditor->textCursor();
    cursor.select(QTextCursor::Document);
    cursor.insertText(text);
    mainEditor->setTextCursor(cursor);  // TODO implement for multiple views
  }
  else {
    qDebug() << "BaseView::setBasicText not implemented for Split view.";
  }
}

void BaseView::setFileType(int mode)
{
  m_highlighter.setMode(mode);
  m_mode = mode;
}

void BaseView::setFont(QFont font)
{
  mainEditor->setFont(font);
  orcEditor->setFont(font);
  scoreEditor->setFont(font);
  optionsEditor->setFont(font);
  filebEditor->setFont(font);
  otherEditor->setFont(font);
  otherCsdEditor->setFont(font);
  widgetEditor->setFont(font);
}

void BaseView::setFontPointSize(float size)
{
  mainEditor->setFontPointSize(size);
  orcEditor->setFontPointSize(size);
  scoreEditor->setFontPointSize(size);
  optionsEditor->setFontPointSize(size);
  filebEditor->setFontPointSize(size);
  otherEditor->setFontPointSize(size);
  otherCsdEditor->setFontPointSize(size);
  widgetEditor->setFontPointSize(size);
}

void BaseView::setTabStopWidth(int width)
{
  mainEditor->setTabStopWidth(width);
  orcEditor->setTabStopWidth(width);
  scoreEditor->setTabStopWidth(width);
  optionsEditor->setTabStopWidth(width);
  filebEditor->setTabStopWidth(width);
  otherEditor->setTabStopWidth(width);
  otherCsdEditor->setTabStopWidth(width);
  widgetEditor->setTabStopWidth(width);
}

void BaseView::setLineWrapMode(QTextEdit::LineWrapMode mode)
{
  mainEditor->setLineWrapMode(mode);
  orcEditor->setLineWrapMode(mode);
  scoreEditor->setLineWrapMode(mode);
  optionsEditor->setLineWrapMode(mode);
  filebEditor->setLineWrapMode(mode);
  otherEditor->setLineWrapMode(mode);
  otherCsdEditor->setLineWrapMode(mode);
  widgetEditor->setLineWrapMode(mode);
}

void BaseView::setColorVariables(bool color)
{
  m_highlighter.setColorVariables(color);
}

void BaseView::setBackgroundColor(QColor color)
{
  QPalette p = mainEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  mainEditor->setPalette(p);
  p = orcEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  orcEditor->setPalette(p);
  p = scoreEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  scoreEditor->setPalette(p);
  p = optionsEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  optionsEditor->setPalette(p);
  p = filebEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  filebEditor->setPalette(p);
  p = otherCsdEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  otherCsdEditor->setPalette(p);
  p = otherEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  otherEditor->setPalette(p);
  p = widgetEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  widgetEditor->setPalette(p);
}

void BaseView::setOrc(QString text)
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
  else { // Split view
    orcEditor->setPlainText(text);
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

void BaseView::setFileB(QString text)
{
  filebEditor->setPlainText(text);
}

void BaseView::setOptionsText(QString text)
{
  if (m_viewMode < 2) { // View is not split
    if (m_mode != 0) {
      qDebug() << "DocumentView::setLadspaText Current file is not a csd file. Text not inserted!";
      return;
    }
    QTextCursor cursor;
    cursor = mainEditor->textCursor();
    mainEditor->moveCursor(QTextCursor::Start);
    mainEditor->find("<CsoundSynthesizer>"); //cursor moves there
    mainEditor->moveCursor(QTextCursor::EndOfLine);
    mainEditor->insertPlainText(QString("\n") + text + QString("\n"));
  }
  else {
    optionsEditor->setText(text);
    optionsEditor->moveCursor(QTextCursor::Start);
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
    qDebug() << "BaseView::setLadspaText() not implemented for split view";
  }
}


QString BaseView::getBasicText()
{
//   What Csound needs (no widgets, misc text, etc.)
  // TODO implement modes
  QString text;
  if (m_viewMode < 2) {
    text = mainEditor->toPlainText(); // csd without extra sections
    if (m_viewMode & 16) {
      text += filebEditor->toPlainText();
    }
  }
  else {
    qDebug() << "BaseView::getBasicText() not implemented for split view";
  }
  return text;
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
    mainEditor->hide();
    orcEditor->hide();
    scoreEditor->hide();
    optionsEditor->hide();
    filebEditor->hide();
    otherEditor->hide();
    otherCsdEditor->hide();
    widgetEditor->hide();
    for (int i = 0; i < 9; i++) {
      QSplitterHandle *h = splitter->handle(i);
      if (h) {
        h->hide();
      }
    }
}
