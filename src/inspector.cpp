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
  setWindowTitle("Inspector");
  m_treeWidget = new QTreeWidget(this);
  m_treeWidget->setHeaderLabel("Instruments");
  m_treeWidget->show();
  setWidget(m_treeWidget);
  connect(m_treeWidget, SIGNAL(itemDoubleClicked(QTreeWidgetItem*,int)),
          this, SLOT(itemActivated(QTreeWidgetItem*,int)));
}

Inspector::~Inspector()
{
  delete m_treeWidget;
}

void Inspector::parseText(const QString &text)
{
//  qDebug() << "Inspector:parseText";
  m_treeWidget->clear();
  QStringList lines = text.split(QRegExp("[\n\r]"));
  QList<QTreeWidgetItem *> items;
  for (int i = 0; i< lines.size(); i++) {
    if (lines[i].trimmed().contains(QRegExp("^[\s]*instr"))) {
      QString text = lines[i].mid(lines[i].indexOf("instr") + 6);
      QStringList columnslist(QString("instr %1").arg(text).simplified());
      TreeItem *newItem = new TreeItem(m_treeWidget, columnslist);
      newItem->setLine(i + 1);
    }
  }
}

void Inspector::itemActivated(QTreeWidgetItem * item, int column)
{
  int line = static_cast<TreeItem *>(item)->getLine();
  emit jumpToLine(line);
}
