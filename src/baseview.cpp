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
  m_mainEditor = new TextEditor(this);
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
  editors << m_mainEditor << m_orcEditor << m_scoreEditor << m_optionsEditor << m_filebEditor
      << m_otherEditor << m_otherCsdEditor << m_widgetEditor;
  splitter = new QSplitter(this); // Deleted with parent
  splitter->setOrientation(Qt::Vertical);
  splitter->setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
  splitter->setContextMenuPolicy (Qt::NoContextMenu);

  QStackedLayout *l = new QStackedLayout(this);  // Deleted with parent
  l->addWidget(splitter);
  setLayout(l);
  m_mode = 0;
  m_highlighter.setOpcodeNameList(opcodeTree->opcodeNameList());
  m_highlighter.setDocument(m_mainEditor->document());
}

BaseView::~BaseView()
{
}

void BaseView::setFullText(QString text, bool goToTop)
{
  // Load Embedded Files ------------------------
  // Must be done initially to remove the files for both view modes
  clearFileBText();
  while (text.contains("<CsFileB ") and text.contains("</CsFileB>")) {
    bool endsWithBreak = false;
	if (text.indexOf("</CsFileB>") > text.indexOf("<CsFileB>")) {
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
    int startIndex,endIndex, offset, endoffset;
    QString tag, sectionText;
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

void BaseView::setFileType(int mode)
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
  m_mainEditor->setTabStopWidth(width);
  m_orcEditor->setTabStopWidth(width);
  m_scoreEditor->setTabStopWidth(width);
  m_optionsEditor->setTabStopWidth(width);
//  m_filebEditor->setTabStopWidth(width);
  m_otherEditor->setTabStopWidth(width);
  m_otherCsdEditor->setTabStopWidth(width);
  m_widgetEditor->setTabStopWidth(width);
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

void BaseView::setBackgroundColor(QColor color)
{
  QPalette p = m_mainEditor->palette();
  p.setColor(static_cast<QPalette::ColorRole>(9), color);
  m_mainEditor->setPalette(p);
//  p = m_orcEditor->palette();
//  p.setColor(static_cast<QPalette::ColorRole>(9), color);
//  m_orcEditor->setPalette(p);
//  p = m_scoreEditor->palette();
//  p.setColor(static_cast<QPalette::ColorRole>(9), color);
//  m_scoreEditor->setPalette(p);
//  p = m_optionsEditor->palette();
//  p.setColor(static_cast<QPalette::ColorRole>(9), color);
//  m_optionsEditor->setPalette(p);
//  p = m_filebEditor->palette();
//  p.setColor(static_cast<QPalette::ColorRole>(9), color);
//  m_filebEditor->setPalette(p);
//  p = m_otherCsdEditor->palette();
//  p.setColor(static_cast<QPalette::ColorRole>(9), color);
//  m_otherCsdEditor->setPalette(p);
//  p = m_otherEditor->palette();
//  p.setColor(static_cast<QPalette::ColorRole>(9), color);
//  m_otherEditor->setPalette(p);
//  p = m_widgetEditor->palette();
//  p.setColor(static_cast<QPalette::ColorRole>(9), color);
//  m_widgetEditor->setPalette(p);
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
      qDebug() << "DocumentView::setLadspaText Current file is not a csd file. Text not inserted!";
      return;
    }
    QTextCursor cursor;
    cursor = m_mainEditor->textCursor();
    // FIXME must remove old options tag if present!
    m_mainEditor->moveCursor(QTextCursor::Start);
    m_mainEditor->find("<CsoundSynthesizer>"); //cursor moves there
    m_mainEditor->moveCursor(QTextCursor::EndOfLine);
    m_mainEditor->insertPlainText(QString("\n") + text + QString("\n"));
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
