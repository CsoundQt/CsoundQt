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
  qDebug() << "BaseView::BaseView";
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

  QStackedLayout *l = new QStackedLayout(this);
  l->addWidget(splitter);
  setLayout(l);
  m_mode = 0;
  setViewMode(0);
  m_highlighter.setOpcodeNameList(opcodeTree->opcodeNameList());
  m_highlighter.setDocument(mainEditor->document());
}

BaseView::~BaseView()
{

}

void BaseView::setFullText(QString text, bool goToTop)
{
  QTextCursor cursor = editors[0]->textCursor();
  cursor.select(QTextCursor::Document);
  cursor.insertText(text);
  editors[0]->setTextCursor(cursor);  // TODO implment for multiple views
  if (goToTop) {
    editors[0]->moveCursor(QTextCursor::Start);
  }
}

void BaseView::setViewMode(int mode)
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

void BaseView::setFileType(int mode)
{
  m_highlighter.setMode(mode);
  m_mode = mode;
}

void BaseView::setFont(QFont font)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setFont(font);
  }
}

void BaseView::setFontPointSize(float size)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setFontPointSize(size);
  }
}

void BaseView::setTabWidth(int width)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setTabStopWidth(width);
  }
}

void BaseView::setTabStopWidth(int width)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setTabStopWidth(width);
  }
}

void BaseView::setLineWrapMode(QTextEdit::LineWrapMode mode)
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->setLineWrapMode(mode);
  }
}

void BaseView::setColorVariables(bool color)
{
  m_highlighter.setColorVariables(color);
}

void BaseView::setOpcodeNameList(QStringList list)
{
  m_highlighter.setOpcodeNameList(list);
}

void BaseView::setOpcodeTree(OpEntryParser *opcodeTree)
{
  m_opcodeTree = opcodeTree;
}

void BaseView::hideAllEditors()
{
  for (int i = 0; i < editors.size(); i++) {
    editors[i]->hide();
    QSplitterHandle *h = splitter->handle(i);
    if (h) {
      h->hide();
    }
  }
}
