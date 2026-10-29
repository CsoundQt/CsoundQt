
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

#include "codescan.h"

class TreeItem : public QTreeWidgetItem
{
public:
	TreeItem(QTreeWidget *parent, QStringList columnslist) : QTreeWidgetItem(parent, columnslist) {;}
	TreeItem(QTreeWidgetItem *parent, QStringList columnslist) : QTreeWidgetItem(parent, columnslist) {;}
	~TreeItem() {;}

	int getLine() {return m_line;}
	void setLine(int line) {m_line = line;}

private:
	int m_line = -1;
};


// The tree view of the current document: opcodes, macros, instruments,
// f-tables and the score. The panel only renders what CodeScan found; it does
// not parse anything itself, so it can be shown and hidden freely while the
// scanning runs elsewhere.
class Inspector : public QDockWidget
{
	Q_OBJECT
public:
	Inspector(QWidget *parent);
	~Inspector();
	// Show the result of scanning the current document. The tree is only
	// built while the dock is visible; a scan that arrives while it is hidden
	// is kept and the tree is built when the dock is shown.
	void setScan(const CodeScan::ResultPtr &scan);
	void clearScan() { setScan(CodeScan::empty()); }
	// Give keyboard focus to the inspector's tree, for the Focus Inspector
	// action. Showing/raising the dock itself is the caller's job.
	void focusTree();
	// Mark the instrument/opcode whose declaration is on this line as the
	// current one. -1 clears the mark. Called after the editor's debounce.
	void setCurrentScopeLine(int line);

protected:
	virtual void focusInEvent (QFocusEvent * event);
	virtual void closeEvent (QCloseEvent * event);
	virtual void showEvent (QShowEvent * event);
	// Intercept Space (navigate like a click, keep focus) and Tab (always
	// move focus to the editor) on the tree.
	virtual bool eventFilter(QObject *obj, QEvent *event);

private:
	// Replaces the tree with the entries of the scan, keeping the expansion
	// state of the groups and of the instruments across rebuilds.
	void buildTree(const CodeScan::Result &scan);
	// Paint/clear the subtle background on the tree entry for m_scopeLine.
	void applyScopeHighlight();
	void clearScopeHighlight();
	bool isItemVisible(const QTreeWidgetItem *item) const;
	QTreeWidgetItem *findScopeItem(int line) const;

	QTreeWidget *m_treeWidget;
	TreeItem *treeItem1;
	TreeItem *treeItem2;
	TreeItem *treeItem3;
	TreeItem *treeItem4;
	TreeItem *treeItem5;

	CodeScan::ResultPtr m_scan = CodeScan::empty();
	bool m_treeDirty = true;
	int m_scopeLine = -1;
	QTreeWidgetItem *m_highlightedItem = nullptr;

private slots:
	void itemActivated(QTreeWidgetItem * item, int column = 0);
	void itemClicked(QTreeWidgetItem * item, int column = 0);

private:
	// Navigate the editor to the line of the given/current tree item.
	// focusEditor=true also moves keyboard focus to the editor.
	void activateItem(QTreeWidgetItem *item, bool focusEditor);

signals:
	void Close(bool visible);
	// Navigate without stealing focus (mouse click, Space).
	void jumpToLine(int line);
	// Navigate and move keyboard focus to the editor (Enter, double-click).
	void jumpToLineAndFocus(int line);
	// Move keyboard focus to the editor without navigating (Tab).
	void focusEditorRequested();
};

#endif // INSPECTOR_H
