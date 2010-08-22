/*
    Copyright (C) 2009 Andres Cabrera
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

#include "inspector.h"

#include <QtCore>

Inspector::Inspector(QWidget *parent)
  : QDockWidget(parent)
{
  setWindowTitle(tr("Inspector"));
  m_treeWidget = new QTreeWidget(this);
  m_treeWidget->setHeaderLabel(tr("Inspector"));
  m_treeWidget->show();
  setWidget(m_treeWidget);
  connect(m_treeWidget, SIGNAL(itemClicked(QTreeWidgetItem*,int)),
          this, SLOT(itemActivated(QTreeWidgetItem*,int)));
//  connect(m_treeWidget, SIGNAL(itemDoubleClicked(QTreeWidgetItem*,int)),
//          this, SLOT(itemActivated(QTreeWidgetItem*,int)));
  opcodeItem = new TreeItem(m_treeWidget, QStringList(tr("Opcodes")));
  macroItem = new TreeItem(m_treeWidget, QStringList(tr("Macros")));
  instrItem = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
  ftableItem = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
  scoreItem = new TreeItem(m_treeWidget, QStringList(tr("Score")));
  m_treeWidget->expandItem(opcodeItem);
  m_treeWidget->expandItem(macroItem);
  m_treeWidget->expandItem(instrItem);
  m_treeWidget->expandItem(ftableItem);
  m_treeWidget->expandItem(scoreItem);
}


Inspector::~Inspector()
{
  delete m_treeWidget;
}

void Inspector::parseText(const QString &text)
{
//  qDebug() << "Inspector::parseText";
  inspectorMutex.lock();
  bool opcodeItemExpanded = true;
  bool macroItemExpanded = true;
  bool instrItemExpanded = true;
  bool ftableItemExpanded = true;
  bool scoreItemExpanded = true;
  if  (opcodeItem != 0) {
    opcodeItemExpanded = opcodeItem->isExpanded();
    macroItemExpanded = macroItem->isExpanded();
    instrItemExpanded = instrItem->isExpanded();
    ftableItemExpanded = ftableItem->isExpanded();
    scoreItemExpanded = scoreItem->isExpanded();
  }
  QHash<QString, bool> instrumentExpanded;  // Remember if instrument is expanded in menu
  for (int i = 0; i < instrItem->childCount(); i++) {
    QTreeWidgetItem * instr = instrItem->child(i);
    instrumentExpanded[instr->text(0)] = instr->isExpanded();
  }

  m_treeWidget->clear();
  opcodeItem = new TreeItem(m_treeWidget, QStringList(tr("Opcodes")));
  opcodeItem->setLine(-1);
  macroItem = new TreeItem(m_treeWidget, QStringList(tr("Macros")));
  macroItem->setLine(-1);
  instrItem = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
  instrItem->setLine(-1);
  ftableItem = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
  ftableItem->setLine(-1);
  scoreItem = new TreeItem(m_treeWidget, QStringList(tr("Score")));
  scoreItem->setLine(-1);  // This might be overridden below
  TreeItem *currentInstrument = instrItem;
  QStringList lines = text.split(QRegExp("[\n\r]"));
  for (int i = 0; i< lines.size(); i++) {
    if (lines[i].trimmed().startsWith("instr")) {
      QString text = lines[i].mid(lines[i].indexOf("instr") + 6);
      QStringList columnslist(QString("instr %1").arg(text).simplified());
      TreeItem *newItem = new TreeItem(instrItem, columnslist);
      newItem->setLine(i + 1);
      newItem->setForeground (0, QBrush(Qt::darkMagenta) );
      currentInstrument = newItem;
    }
    if (lines[i].trimmed().startsWith(";;")) {
      QStringList columnslist(lines[i].trimmed().remove(0,2));
      TreeItem *newItem = new TreeItem(currentInstrument, columnslist);
      newItem->setForeground (0, QBrush(Qt::darkGreen) );
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().startsWith("endin")) {
      currentInstrument = instrItem; // everything between instruments is placed in the main instrument menu
    }
    else if (lines[i].trimmed().startsWith("opcode")) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(opcodeItem, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().startsWith("#define") or lines[i].trimmed().startsWith("# define")) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(macroItem, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().contains(QRegExp("^f\\s*\\d")) ||
        lines[i].trimmed().contains(QRegExp("^[\\w]*[\\s]*ftgen"))) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(ftableItem, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().contains(QRegExp("^s\\s*\\b")) ||
        lines[i].trimmed().contains(QRegExp("^m\\s*\\b"))) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(scoreItem, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().contains(QRegExp("\\w+:"))) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      if (currentInstrument != 0) {
        TreeItem *newItem = new TreeItem(currentInstrument, columnslist);
        newItem->setLine(i + 1);
      }
    }
    else if (lines[i].trimmed().contains("<CsScore>")) {
      scoreItem->setLine(i + 1);
      currentInstrument = scoreItem;
    }
    else if (lines[i].trimmed().contains("<CsInstruments>")) {
      instrItem->setLine(i + 1);
    }
  }
  opcodeItem->setExpanded(opcodeItemExpanded);
  macroItem->setExpanded(macroItemExpanded);
  instrItem->setExpanded(instrItemExpanded);
  ftableItem->setExpanded(ftableItemExpanded);
  scoreItem->setExpanded(scoreItemExpanded);

  for (int i = 0; i < instrItem->childCount(); i++) {
    QTreeWidgetItem * instr = instrItem->child(i);
    if (instrumentExpanded.contains(instr->text(0))) {
      instr->setExpanded(instrumentExpanded[instr->text(0)]);
    }
  }
  inspectorMutex.unlock();
}

void Inspector::parsePythonText(const QString &text)
{
//  qDebug() << "Inspector:parseText";
  inspectorMutex.lock();
  m_treeWidget->clear();
  opcodeItem = 0;
  TreeItem *importItem = new TreeItem(m_treeWidget, QStringList(tr("Imports")));
  importItem->setLine(-1);
  TreeItem *classItem = new TreeItem(m_treeWidget, QStringList(tr("Classes")));
  classItem->setLine(-1);
  TreeItem *functionItem = new TreeItem(m_treeWidget, QStringList(tr("Functions")));
  functionItem->setLine(-1);
  TreeItem *currentParent = 0;
  QStringList lines = text.split(QRegExp("[\\n\\r]"));
  for (int i = 0; i< lines.size(); i++) {
    if (lines[i].trimmed().startsWith("class ")) {
      QStringList columnslist(lines[i].simplified());
      TreeItem *newItem = new TreeItem(classItem, columnslist);
      currentParent = newItem;
      m_treeWidget->expandItem(newItem);
//      QFont itemFont = newItem->font(0);
//      itemFont.setBold(true);
//      newItem->setBackground(1, QBrush(Qt::darkRed) );
//      newItem->setFont(1, itemFont);
      newItem->setLine(i + 1);
    }
    else if (lines[i].contains(QRegExp("[\\s]+def "))) {
      QStringList columnslist(lines[i].simplified());
      if (currentParent != 0) {
        TreeItem *newItem = new TreeItem(currentParent, columnslist);
        newItem->setLine(i + 1);
      }
    }
    else if (lines[i].trimmed().contains(QRegExp("\\bimport\\b"))) {
      QStringList columnslist(lines[i].simplified());
      TreeItem *newItem = new TreeItem(importItem, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().startsWith("def ")) {
      QStringList columnslist(lines[i].simplified());
      TreeItem *newItem = new TreeItem(functionItem, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].contains("##")) {
      QStringList columnslist(lines[i].simplified());
      TreeItem *newItem = new TreeItem(functionItem, columnslist);
      newItem->setForeground (0, QBrush(Qt::darkGreen) );
      newItem->setLine(i + 1);
    }
  }
  m_treeWidget->expandItem(importItem);
  m_treeWidget->expandItem(functionItem);
  m_treeWidget->expandItem(classItem);
  inspectorMutex.unlock();
}

void Inspector::focusInEvent (QFocusEvent * event)
{
  QWidget::focusInEvent(event);
//  parseText();
}

void Inspector::closeEvent(QCloseEvent * /*event*/)
{
//  qDebug() << "Inspector::closeEvent";
  emit Close(false);
}

void Inspector::itemActivated(QTreeWidgetItem * item, int /*column*/)
{
  int line = static_cast<TreeItem *>(item)->getLine();
  if (line >= 0) {
    emit jumpToLine(line);
  }
}
