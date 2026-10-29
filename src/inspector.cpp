
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

#include "inspector.h"

#include <QShowEvent>

using namespace Qt::StringLiterals;

Inspector::Inspector(QWidget *parent)
	: QDockWidget(parent)
{
	setWindowTitle(tr("Inspector"));
	m_treeWidget = new QTreeWidget(this);
//	m_treeWidget->setHeaderLabel(tr("Inspector"));
	m_treeWidget->setHeaderHidden(true);
	m_treeWidget->show();
	setWidget(m_treeWidget);
	// Jump on mouse click and on Enter/double-click. Deliberately NOT on
	// currentItemChanged: that also fires while merely moving around the tree
	// with the arrow keys, which must not move the editor or the focus.
	// A click navigates but keeps focus in the tree; Enter/double-click also
	// hands focus to the editor.
	connect(m_treeWidget, SIGNAL(itemClicked(QTreeWidgetItem*,int)),
	        this, SLOT(itemClicked(QTreeWidgetItem*,int)));
	connect(m_treeWidget, SIGNAL(itemActivated(QTreeWidgetItem*,int)),
	        this, SLOT(itemActivated(QTreeWidgetItem*,int)));
	m_treeWidget->installEventFilter(this);
	m_treeWidget->viewport()->installEventFilter(this);
	treeItem1 = new TreeItem(m_treeWidget, QStringList(tr("Opcodes")));
	treeItem2 = new TreeItem(m_treeWidget, QStringList(tr("Macros")));
	treeItem3 = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
	treeItem4 = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
	treeItem5 = new TreeItem(m_treeWidget, QStringList(tr("Score")));

    m_treeWidget->expandItem(treeItem1);    // opcodes
    m_treeWidget->collapseItem(treeItem2);  // macros
    m_treeWidget->expandItem(treeItem3);    // instruments
    m_treeWidget->collapseItem(treeItem4);  // ftables
    m_treeWidget->collapseItem(treeItem5);    // score
}


Inspector::~Inspector()
{
	delete m_treeWidget;
}


void Inspector::setScan(const CodeScan::ResultPtr &scan)
{
    if (scan == m_scan)
        return;
    m_scan = scan;
    if (isHidden()) {
        // Nothing is rendered while the dock is hidden; the tree is built from
        // the latest scan when it is shown again.
        m_treeDirty = true;
        return;
    }
    buildTree(*m_scan);
}


void Inspector::buildTree(const CodeScan::Result &scan)
{
    m_treeDirty = false;

    // The expansion state belongs to the user, not to the document: keep the
    // groups and the instruments open or closed as they were.
    bool opcodesExpanded = true;
    bool macrosExpanded = true;
    bool instrumentsExpanded = true;
    bool ftablesExpanded = true;
    bool scoreExpanded = true;
    QHash<QString, bool> instrumentExpanded;
    if (treeItem1 != nullptr) {
        opcodesExpanded = treeItem1->isExpanded();
        macrosExpanded = treeItem2->isExpanded();
        instrumentsExpanded = treeItem3->isExpanded();
        ftablesExpanded = treeItem4->isExpanded();
        scoreExpanded = treeItem5->isExpanded();
        for (int i = 0; i < treeItem3->childCount(); ++i) {
            QTreeWidgetItem *instrument = treeItem3->child(i);
            if (instrument->columnCount() > 0)
                instrumentExpanded[instrument->text(0)] = instrument->isExpanded();
        }
    }

    m_treeWidget->clear();
    m_highlightedItem = nullptr;
    treeItem1 = new TreeItem(m_treeWidget, QStringList(tr("Opcodes")));
    treeItem1->setLine(-1);
    treeItem2 = new TreeItem(m_treeWidget, QStringList(tr("Macros")));
    treeItem2->setLine(-1);
    treeItem3 = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
    treeItem3->setLine(-1);
    treeItem4 = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
    treeItem4->setLine(-1);
    treeItem5 = new TreeItem(m_treeWidget, QStringList(tr("Score")));
    treeItem5->setLine(-1);

    // The scan also carries the symbols declared in the files the document
    // includes: completion, highlighting and "Go to Source" use them. The tree
    // describes the document the user is editing, so it lists only the
    // definitions whose file is the document itself.
    for (const CodeScan::Definition &udo : scan.udos) {
        if (!udo.file.isEmpty())
            continue;
        if (treeItem1->getLine() < 0)
            treeItem1->setLine(udo.line);
        TreeItem *item = new TreeItem(treeItem1, QStringList(udo.text));
        item->setLine(udo.line);
        // A Csound 7 signature already shows the arguments in the declaration
        // line; there are no xin/xout lines to list below it.
        if (!udo.newStyle) {
            if (!udo.inArgs.isEmpty()) {
                TreeItem *args = new TreeItem(item, QStringList(udo.inArgs + u" xin"_s));
                args->setLine(udo.inArgsLine);
            }
            if (!udo.outArgs.isEmpty()) {
                TreeItem *args = new TreeItem(item, QStringList(u"xout "_s + udo.outArgs));
                args->setLine(udo.outArgsLine);
            }
        }
    }

    for (const CodeScan::Definition &entry : scan.preprocessor) {
        if (!entry.file.isEmpty())
            continue;
        if (treeItem2->getLine() < 0)
            treeItem2->setLine(entry.line);
        TreeItem *item = new TreeItem(treeItem2, QStringList(entry.text));
        item->setLine(entry.line);
    }

    treeItem3->setLine(scan.orchestraLine);
    for (const CodeScan::Definition &instrument : scan.instruments) {
        if (!instrument.file.isEmpty())
            continue;
        TreeItem *item = new TreeItem(treeItem3, QStringList(instrument.text));
        item->setLine(instrument.line);
    }

    for (const CodeScan::Definition &ftable : scan.ftables) {
        if (!ftable.file.isEmpty())
            continue;
        if (treeItem4->getLine() < 0)
            treeItem4->setLine(ftable.line);
        TreeItem *item = new TreeItem(treeItem4, QStringList(ftable.text));
        item->setLine(ftable.line);
    }

    treeItem5->setLine(scan.scoreLine);

    treeItem1->setExpanded(opcodesExpanded);
    treeItem2->setExpanded(macrosExpanded);
    treeItem3->setExpanded(instrumentsExpanded);
    treeItem4->setExpanded(ftablesExpanded);
    treeItem5->setExpanded(scoreExpanded);
    for (int i = 0; i < treeItem3->childCount(); ++i) {
        QTreeWidgetItem *instrument = treeItem3->child(i);
        if (instrumentExpanded.contains(instrument->text(0)))
            instrument->setExpanded(instrumentExpanded[instrument->text(0)]);
    }
    applyScopeHighlight();
}


void Inspector::setCurrentScopeLine(int line)
{
    m_scopeLine = line;
    applyScopeHighlight();
}

bool Inspector::isItemVisible(const QTreeWidgetItem *item) const
{
    if (item == nullptr || item->isHidden())
        return false;
    for (const QTreeWidgetItem *parent = item->parent(); parent != nullptr;
         parent = parent->parent()) {
        if (parent->isHidden() || !parent->isExpanded())
            return false;
    }
    return true;
}

QTreeWidgetItem *Inspector::findScopeItem(int line) const
{
    // Only instruments and user-defined opcodes are tracked; macros, ftables,
    // includes and score entries are not.
    for (QTreeWidgetItem *group : {treeItem1, treeItem3}) {
        if (group == nullptr)
            continue;
        for (int i = 0; i < group->childCount(); ++i) {
            QTreeWidgetItem *item = group->child(i);
            auto *treeItem = static_cast<TreeItem *>(item);
            if (treeItem->getLine() == line)
                return item;
        }
    }
    return nullptr;
}

void Inspector::clearScopeHighlight()
{
    if (m_highlightedItem != nullptr) {
        m_highlightedItem->setBackground(0, QBrush());
        m_highlightedItem = nullptr;
    }
}

void Inspector::applyScopeHighlight()
{
    clearScopeHighlight();
    if (isHidden() || m_treeDirty || m_scopeLine < 0)
        return;

    QTreeWidgetItem *item = findScopeItem(m_scopeLine);
    // If the group or the entry is folded, there is nothing to see; do not
    // unfold it or scroll the tree.
    if (item == nullptr || !isItemVisible(item))
        return;

    // A light tint rather than a full selection: the selection belongs to
    // keyboard navigation and must not be moved by the editor cursor.
    const QColor base = m_treeWidget->palette().color(QPalette::Base);
    const QColor accent = m_treeWidget->palette().color(QPalette::Highlight);
    const auto mix = [](int from, int to) { return (from * 4 + to) / 5; };
    const QColor tint(mix(base.red(), accent.red()),
                      mix(base.green(), accent.green()),
                      mix(base.blue(), accent.blue()));
    item->setBackground(0, QBrush(tint));
    m_highlightedItem = item;
}

void Inspector::focusInEvent (QFocusEvent * event)
{
	QWidget::focusInEvent(event);
}


void Inspector::focusTree()
{
	m_treeWidget->setFocus(Qt::ActiveWindowFocusReason);
}


void Inspector::showEvent(QShowEvent *event)
{
    QDockWidget::showEvent(event);
    // Scans that arrived while the dock was hidden only replaced the data.
    // Build the tree now that it can actually be seen.
    if (m_treeDirty) {
        m_treeDirty = false;
        buildTree(*m_scan);
    }
    // The cursor may have moved (and the scope changed) while the dock was
    // hidden. Apply the stored line now that the tree is visible.
    applyScopeHighlight();
}


void Inspector::closeEvent(QCloseEvent * /*event*/)
{
	//  qDebug() << "Inspector::closeEvent";
	emit Close(false);
}

void Inspector::itemActivated(QTreeWidgetItem * item, int /*column*/)
{
	// Enter / double-click: navigate and move focus to the editor.
	activateItem(item, true);
}

void Inspector::itemClicked(QTreeWidgetItem * item, int /*column*/)
{
	// Mouse click: navigate only, keep focus in the tree.
	activateItem(item, false);
}

void Inspector::activateItem(QTreeWidgetItem *item, bool focusEditor)
{
	if (item == nullptr)
		return;
	TreeItem *treeItem = static_cast<TreeItem *>(item);
	int line = treeItem->getLine();
	if (line < 0)
		return;
	if (focusEditor)
		emit jumpToLineAndFocus(line);
	else
		emit jumpToLine(line);
}

bool Inspector::eventFilter(QObject *obj, QEvent *event)
{
	if (event->type() == QEvent::KeyPress
	        && (obj == m_treeWidget || obj == m_treeWidget->viewport())) {
		QKeyEvent *ke = static_cast<QKeyEvent *>(event);
		if (ke->key() == Qt::Key_Space) {
			// Space behaves like a mouse click: navigate, keep focus here.
			activateItem(m_treeWidget->currentItem(), false);
			return true;
		}
		if (ke->key() == Qt::Key_Tab || ke->key() == Qt::Key_Backtab) {
			// Tab always hands focus to the editor (never cycles widgets).
			emit focusEditorRequested();
			return true;
		}
	}
	return QDockWidget::eventFilter(obj, event);
}
