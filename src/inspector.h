/*
	Copyright (C) 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
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
#include <QMutex>
#include "types.h"

class TreeItem : public QTreeWidgetItem
{
public:
	TreeItem(QTreeWidget *parent, QStringList columnslist) : QTreeWidgetItem(parent, columnslist) {;}
	TreeItem(QTreeWidgetItem *parent, QStringList columnslist) : QTreeWidgetItem(parent, columnslist) {;}
	~TreeItem() {;}

	int getLine() {return m_line;}
	void setLine(int line) {m_line = line;}
    void setInputArgs(QString args) { inargs = args; }
    void setOutputArgs(QString args) { outargs = args; }

private:
	int m_line;
    QString inargs;
    QString outargs;
};


class Inspector : public QDockWidget
{
	Q_OBJECT
public:
	Inspector(QWidget *parent);
	~Inspector();
	void parseText(const QString &text);
	void parsePythonText(const QString &text);
    QStringList getParsedUDOs() { return m_opcodes; }
    QVector<Opcode*> getUdosVector() { return udosVector; }
    QHash<QString, Opcode>*getUdosMap() { return &udosMap; }


protected:
	virtual void focusInEvent (QFocusEvent * event);
	virtual void closeEvent(QCloseEvent * event);

private:
	QTreeWidget *m_treeWidget;
	TreeItem *treeItem1;
	TreeItem *treeItem2;
	TreeItem *treeItem3;
	TreeItem *treeItem4;
	TreeItem *treeItem5;

	QMutex inspectorMutex;
    // QVector<QString> m_opcodes;
    QStringList m_opcodes;
    QRegExp opcodeRegexp;
    QRegularExpression rxOpcode;
    bool inspectLabels;
    QHash<QString, Opcode>udosMap;
    QVector<Opcode *>udosVector;

    QRegularExpression xinRx;
    QRegularExpression xoutRx;
    QRegularExpression ftableRx1;
    QRegularExpression ftableRx2;


private slots:
	void itemActivated(QTreeWidgetItem * item, int column = 0);
	void itemChanged(QTreeWidgetItem * newItem, QTreeWidgetItem * oldItem);

signals:
	void Close(bool visible);
	void jumpToLine(int line);
    void parsedUDOs();
};

#endif // INSPECTOR_H
