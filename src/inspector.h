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

#ifndef INSPECTOR_H
#define INSPECTOR_H

#include <QDockWidget>
#include <QTreeWidget>

class TreeItem : public QTreeWidgetItem
{
  public:
    TreeItem(QTreeWidget *parent, QStringList columnslist) : QTreeWidgetItem(parent, columnslist) {;}
    ~TreeItem() {;}

    int getLine() {return m_line;}
    void setLine(int line) {m_line = line;}

  private:
    int m_line;
};

class Inspector : public QDockWidget
{
  Q_OBJECT
  public:
    Inspector(QWidget *parent);
    ~Inspector();
    void parseText(const QString &text);

  private:
    QTreeWidget *m_treeWidget;

  private slots:
    void itemActivated(QTreeWidgetItem * item, int column);

  signals:
    void jumpToLine(int line);
};

#endif // INSPECTOR_H
