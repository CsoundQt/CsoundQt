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
//  connect(m_treeWidget, SIGNAL(itemClicked(QTreeWidgetItem*,int)),
//          this, SLOT(itemActivated(QTreeWidgetItem*,int)));
  connect(m_treeWidget, SIGNAL(currentItemChanged(QTreeWidgetItem*, QTreeWidgetItem*)),
          this, SLOT(itemChanged(QTreeWidgetItem*, QTreeWidgetItem*)));
//  connect(m_treeWidget, SIGNAL(itemDoubleClicked(QTreeWidgetItem*,int)),
//          this, SLOT(itemActivated(QTreeWidgetItem*,int)));
  treeItem1 = new TreeItem(m_treeWidget, QStringList(tr("Opcodes")));
  treeItem2 = new TreeItem(m_treeWidget, QStringList(tr("Macros")));
  treeItem3 = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
  treeItem4 = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
  treeItem5 = new TreeItem(m_treeWidget, QStringList(tr("Score")));
  
  m_treeWidget->expandItem(treeItem1);
  m_treeWidget->expandItem(treeItem2);
  m_treeWidget->expandItem(treeItem3);
  m_treeWidget->expandItem(treeItem4);
  m_treeWidget->expandItem(treeItem5);
}


Inspector::~Inspector()
{
  delete m_treeWidget;
}

void Inspector::parseText(const QString &text)
{
//  qDebug() << "Inspector::parseText";
  inspectorMutex.lock();
  bool treeItem1Expanded = true;
  bool treeItem2Expanded = true;
  bool treeItem3Expanded = true;
  bool treeItem4Expanded = true;
  bool treeItem5Expanded = true;
  if  (treeItem1 != 0) {
    treeItem1Expanded = treeItem1->isExpanded();
    treeItem2Expanded = treeItem2->isExpanded();
    treeItem3Expanded = treeItem3->isExpanded();
    treeItem4Expanded = (treeItem4 != 0 ? treeItem4->isExpanded() : false);
    treeItem5Expanded = (treeItem5 != 0 ? treeItem5->isExpanded() : false);
  }
  QHash<QString, bool> instrumentExpanded;  // Remember if instrument is expanded in menu
  for (int i = 0; i < treeItem3->childCount(); i++) {
    QTreeWidgetItem * instr = treeItem3->child(i);
    Q_ASSERT(instr->columnCount() > 0);
    instrumentExpanded[instr->text(0)] = instr->isExpanded();
  }

  m_treeWidget->clear();
  treeItem1 = new TreeItem(m_treeWidget, QStringList(tr("Opcodes")));
  treeItem1->setLine(-1);
  treeItem2 = new TreeItem(m_treeWidget, QStringList(tr("Macros")));
  treeItem2->setLine(-1);
  treeItem3 = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
  treeItem3->setLine(-1);
  treeItem4 = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
  treeItem4->setLine(-1);
  treeItem5 = new TreeItem(m_treeWidget, QStringList(tr("Score")));
  treeItem5->setLine(-1);  // This might be overridden below
  TreeItem *currentInstrument = treeItem3;
  QStringList lines = text.split(QRegExp("[\n\r]"));
  for (int i = 0; i< lines.size(); i++) {
    if (lines[i].trimmed().startsWith("instr")) {
      QString text = lines[i].mid(lines[i].indexOf("instr") + 6);
      QStringList columnslist(QString("instr %1").arg(text).simplified());
      TreeItem *newItem = new TreeItem(treeItem3, columnslist);
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
      currentInstrument = treeItem3; // everything between instruments is placed in the main instrument menu
    }
    else if (lines[i].trimmed().startsWith("opcode")) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(treeItem1, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().startsWith("#define") or lines[i].trimmed().startsWith("# define")) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(treeItem2, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().contains(QRegExp("^f\\s*\\d")) ||
        lines[i].trimmed().contains(QRegExp("^[\\w]*[\\s]*ftgen"))) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(treeItem4, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().contains(QRegExp("^s\\s*\\b")) ||
        lines[i].trimmed().contains(QRegExp("^m\\s*\\b"))) {
      QString text = lines[i].trimmed();
      QStringList columnslist(text.simplified());
      TreeItem *newItem = new TreeItem(treeItem5, columnslist);
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
      treeItem5->setLine(i + 1);
      currentInstrument = treeItem5;
    }
    else if (lines[i].trimmed().contains("<CsInstruments>")) {
      treeItem3->setLine(i + 1);
    }
  }
  treeItem1->setExpanded(treeItem1Expanded);
  treeItem2->setExpanded(treeItem2Expanded);
  treeItem3->setExpanded(treeItem3Expanded);
  treeItem4->setExpanded(treeItem4Expanded);
  treeItem5->setExpanded(treeItem5Expanded);

  for (int i = 0; i < treeItem3->childCount(); i++) {
    QTreeWidgetItem * instr = treeItem3->child(i);
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
  treeItem1 = 0;
  treeItem1 = new TreeItem(m_treeWidget, QStringList(tr("Imports")));
  treeItem1->setLine(-1);
  treeItem2 = new TreeItem(m_treeWidget, QStringList(tr("Classes")));
  treeItem2->setLine(-1);
  treeItem3 = new TreeItem(m_treeWidget, QStringList(tr("Functions")));
  treeItem3->setLine(-1);
  treeItem4 = 0;
  treeItem5 = 0;
  TreeItem *currentParent = 0;
  QStringList lines = text.split(QRegExp("[\\n\\r]"));
  for (int i = 0; i< lines.size(); i++) {
    if (lines[i].trimmed().startsWith("class ")) {
      QStringList columnslist(lines[i].simplified());
      TreeItem *newItem = new TreeItem(treeItem2, columnslist);
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
      TreeItem *newItem = new TreeItem(treeItem1, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].trimmed().startsWith("def ")) {
      QStringList columnslist(lines[i].simplified());
      TreeItem *newItem = new TreeItem(treeItem3, columnslist);
      newItem->setLine(i + 1);
    }
    else if (lines[i].contains("##")) {
      QStringList columnslist(lines[i].simplified());
      TreeItem *newItem = new TreeItem(treeItem3, columnslist);
      newItem->setForeground (0, QBrush(Qt::darkGreen) );
      newItem->setLine(i + 1);
    }
  }
  m_treeWidget->expandItem(treeItem1);
  m_treeWidget->expandItem(treeItem2);
  m_treeWidget->expandItem(treeItem3);
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

void Inspector::itemChanged(QTreeWidgetItem * newItem, QTreeWidgetItem * /*oldItem*/)
{
  int line = static_cast<TreeItem *>(newItem)->getLine();
  if (line >= 0) {
    emit jumpToLine(line);
  }
}
