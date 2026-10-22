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
#include "types.h"
#include <chrono>
#include <QtGui>

Inspector::Inspector(QWidget *parent)
	: QDockWidget(parent)
{
    QDEBUG << "setWindowTitle Inspector";
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
    // Matches both the old opcode syntax ("opcode name, outtypes, intypes")
    // and the new-style syntax ("opcode name(inargs):(outargs)").
    rxOpcode.setPattern("\\bopcode\\s+(\\w+)\\s*(?:,|\\()");
    xinRx.setPattern("\\bxin\\b");
    // xinRx.setPattern("[akiS]\\w+[,\\w\\d\\s_]+\\bxin\\s*$");
    xoutRx.setPattern("\\bxout\\s+");
    // ftableRx1.setPattern("^f\\s*\\d");
    ftableRx2.setPattern("^\\w*\\s*ftgen");
    inspectLabels = false;
}


Inspector::~Inspector()
{
	delete m_treeWidget;
}


void Inspector::parseText(const QString &text)
{
    udosMap.clear();
    inspectorMutex.lock();
    QSet<QString> globalVariables;
    QSet<QString> globalStringVariables;
    QSet<QString> explicitGlobals;
    QSet<QString> explicitLocals;
    QSet<QString> instrumentNames;
    // Global variables are either g + a type character (the classic syntax)
    // or names annotated with @global:<type> (Csound 7). An explicit type
    // suffix takes precedence over the prefix: gkfoo:a is a local audio
    // variable, not a global control variable.
    static const QRegularExpression globalVariableRx(
                QStringLiteral("\\b(g[akiSpfxbw][A-Za-z0-9_]*)\\b"));
    static const QRegularExpression annotatedGlobalRx(
                QStringLiteral("\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                               "@global\\s*:\\s*([akiSpfxbw])\\b(?:\\s*\\[\\])?"));
    static const QRegularExpression annotatedLocalRx(
                QStringLiteral("(?<!@)\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                               ":\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"));

    // auto t1 = std::chrono::high_resolution_clock::now();

    bool treeItem1Expanded = true;
    bool treeItem2Expanded = true;
    bool treeItem3Expanded = true;
    bool treeItem4Expanded = true;
    bool treeItem5Expanded = true;
    bool insideOrc = false;
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
    treeItem2 = new TreeItem(m_treeWidget, QStringList(tr("Preprocessor")));
    treeItem2->setLine(-1);
    treeItem3 = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
    treeItem3->setLine(-1);
    treeItem4 = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
    treeItem4->setLine(-1);
    treeItem5 = new TreeItem(m_treeWidget, QStringList(tr("Score")));
    treeItem5->setLine(-1);  // This might be overridden below
    TreeItem *currentInstrument = nullptr;
    TreeItem *currentItem = treeItem3;
    Opcode *currentOpcode = nullptr;
    int commentIndex = 0;
    bool partOfComment = false;
    int i = 0;
    auto lines = text.split('\n'); // was (old): splitRef
    // could be: auto lines = QStringView{text}.split(u'\n'); -  this requires a lot of changes below.
    // Since this function is not called so often, let's not overcomplicate.
    QRegularExpressionMatch match;
    static QRegularExpression orcStartRx("^\\s*<CsInstruments>");

    for(; i<lines.size(); i++) {
        if(orcStartRx.match(lines[i]).hasMatch()) {
            i++;
            treeItem3->setLine(i);
            insideOrc = true;
            break;
        }
    }

    // Parsing orchestra

    if(insideOrc) {
        for (; i< lines.size(); i++) {
            auto line = lines[i].trimmed();
            if (line.isEmpty() || line[0] == ';' || line.startsWith("//"))
                continue;

            if (partOfComment) {
                if (line.indexOf("*/") != -1)
                    partOfComment = false;
                continue;
            }
            if (!partOfComment && (commentIndex=line.indexOf("/*")) != -1) {
                partOfComment = line.indexOf("*/", commentIndex) == -1;
                continue;
            }
            if (line[0] == '<') {
                if (!line.startsWith("</CsInstruments>"))
                    QDEBUG << "Malformed orchestra, tag" << line << "is invalid";
                break;
            }

            QString codeLine = line;
            const int semicolon = codeLine.indexOf(QLatin1Char(';'));
            const int slashes = codeLine.indexOf(QLatin1String("//"));
            const int comment = (semicolon >= 0 && slashes >= 0)
                    ? qMin(semicolon, slashes) : qMax(semicolon, slashes);
            if (comment >= 0)
                codeLine.truncate(comment);
            for (auto globalMatch = globalVariableRx.globalMatch(codeLine);
                 globalMatch.hasNext(); ) {
                const QString name = globalMatch.next().captured(1);
                globalVariables.insert(name);
                if (name.size() > 1 && name.at(1) == QLatin1Char('S'))
                    globalStringVariables.insert(name);
            }
            for (auto globalMatch = annotatedGlobalRx.globalMatch(codeLine);
                 globalMatch.hasNext(); ) {
                const auto match = globalMatch.next();
                const QString name = match.captured(1);
                globalVariables.insert(name);
                explicitGlobals.insert(name);
                if (match.captured(2) == QLatin1String("S"))
                    globalStringVariables.insert(name);
            }
            for (auto localMatch = annotatedLocalRx.globalMatch(codeLine);
                 localMatch.hasNext(); ) {
                explicitLocals.insert(localMatch.next().captured(1));
            }

            if(currentOpcode == nullptr && currentInstrument == nullptr) {
                // we are at instr 0
                if (line.startsWith("instr")) {
                    auto instrline = line.mid(6).trimmed();
                    // Keep the name for schedule() completion. Instrument names
                    // may be quoted; quotes are not part of the name.
                    QString instrName = instrline;
                    const int semicolon = instrName.indexOf(QLatin1Char(';'));
                    const int slashes = instrName.indexOf(QLatin1String("//"));
                    const int commentPos = (semicolon >= 0 && slashes >= 0)
                            ? qMin(semicolon, slashes) : qMax(semicolon, slashes);
                    if (commentPos >= 0)
                        instrName.truncate(commentPos);
                    instrName = instrName.trimmed();
                    if (instrName.startsWith(QLatin1Char('"'))) {
                        const int close = instrName.indexOf(QLatin1Char('"'), 1);
                        instrName = close > 0 ? instrName.mid(1, close - 1) : instrName.mid(1);
                    } else {
                        static const QRegularExpression nameRx(
                                    QStringLiteral("^([^\\s(,;]+)"));
                        const auto match = nameRx.match(instrName);
                        instrName = match.hasMatch() ? match.captured(1) : QString();
                    }
                    if (!instrName.isEmpty() && !instrName.at(0).isDigit())
                        instrumentNames.insert(instrName);
                    auto newItem = new TreeItem(treeItem3, QStringList(instrline));
                    newItem->setLine(i + 1);
                    currentInstrument = newItem;
                    currentItem = newItem;
                }
                else if(line.startsWith("opcode") && (match=rxOpcode.match(line)).hasMatch()) {
                    auto opcodeName = match.captured(1);
                    auto itemtext = line.mid(7);
                    QStringList columnslist(itemtext);
                    if (treeItem1->childCount() == 0) { // set line for element to the first one found
                        treeItem1->setLine(i + 1);
                    }
                    TreeItem *newItem = new TreeItem(treeItem1, columnslist);
                    newItem->setLine(i + 1);
                    currentItem = newItem;
                    udosMap.insert(opcodeName, Opcode(opcodeName));
                    currentOpcode = &udosMap[opcodeName];
                }
                else if (line[0] == '#') {
                    if (line.startsWith("#define")) {
                        QString item = line.mid(8);
                        if (treeItem2->childCount() == 0) { // set line for element to the first one found
                            treeItem2->setLine(i + 1);
                        }
                        TreeItem *newItem = new TreeItem(treeItem2, QStringList(item));
                        newItem->setLine(i + 1);
                    } else if (line.startsWith("#include")) {
                        // TODO: parse include file
                        if (treeItem2->childCount() == 0) { // set line for element to the first one found
                            treeItem2->setLine(i + 1);
                        }
                        TreeItem *newItem = new TreeItem(treeItem2, QStringList(line));
                        newItem->setLine(i + 1);

                    }
                }
                else if(ftableRx2.match(line).hasMatch()) {
                    QStringList columnslist(line);
                    if (treeItem4->childCount() == 0) { // set line for element to the first one found
                        treeItem4->setLine(i + 1);
                    }
                    TreeItem *newItem = new TreeItem(treeItem4, columnslist);
                    newItem->setLine(i + 1);
                }
            }
            else if(currentOpcode != nullptr) {
                if (line == "endop") {
                    if(currentOpcode != nullptr) {
                        currentOpcode = nullptr;
                        currentItem = treeItem3;
                    }
                    else {
                        qDebug() << "endop found outside opcode definition, line" << (i+1);
                    }
                }
                else if(currentOpcode->inArgs.isEmpty() && (match=xinRx.match(line)).hasMatch()) {
                    currentOpcode->inArgs = line.mid(0, match.capturedStart()).simplified();
                    QStringList columnslist(currentOpcode->inArgs + " xin");
                    TreeItem *newItem = new TreeItem(currentItem, columnslist);
                    newItem->setLine(i + 1);
                }
                else if(currentOpcode->outArgs.isEmpty() && (match=xoutRx.match(line)).hasMatch()) {
                    currentOpcode->outArgs = line.mid(match.capturedEnd()).simplified();
                    QStringList columnslist("xout " + currentOpcode->outArgs);
                    TreeItem *newItem = new TreeItem(currentItem, columnslist);
                    newItem->setLine(i + 1);
                }
            }
            else if (line == "endin") {
                // everything between instruments is placed in the main instrument menu
                currentInstrument = nullptr;
                currentItem = treeItem3;
            }
        }
    }


    static QRegularExpression rxCsScore("^\\s*<CsScore>");
    for(; i< lines.size(); i++) {
        if (rxCsScore.match(lines[i]).hasMatch()) {
            treeItem5->setLine(i + 1);
            currentItem = treeItem5;
            break;
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
    m_globalVariables.clear();
    for (const QString &name : globalVariables) {
        // An explicit local type wins over the g prefix: gkfoo:a is local.
        if (explicitLocals.contains(name) && !explicitGlobals.contains(name))
            continue;
        // A UDO can have a g-prefixed name too; it is not a variable.
        if (!udosMap.contains(name))
            m_globalVariables.append(name);
    }
    m_globalVariables.sort(Qt::CaseInsensitive);

    m_globalStringVariables.clear();
    for (const QString &name : globalStringVariables) {
        if (explicitLocals.contains(name) && !explicitGlobals.contains(name))
            continue;
        if (!udosMap.contains(name))
            m_globalStringVariables.append(name);
    }
    m_globalStringVariables.sort(Qt::CaseInsensitive);

    m_instrumentNames = instrumentNames.values();
    m_instrumentNames.sort(Qt::CaseInsensitive);

    // std::chrono::duration<double, std::milli> ms_double = std::chrono::high_resolution_clock::now() - t1;
    // qDebug() << "Inspector::parseText: "<< ms_double.count() << "ms\n";
    inspectorMutex.unlock();

}


void Inspector::focusInEvent (QFocusEvent * event)
{
	QWidget::focusInEvent(event);
	//  parseText();
}

void Inspector::focusTree()
{
    m_treeWidget->setFocus(Qt::ActiveWindowFocusReason);
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
	int line = static_cast<TreeItem *>(item)->getLine();
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
