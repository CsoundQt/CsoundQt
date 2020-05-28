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

#include <QtGui>

Inspector::Inspector(QWidget *parent)
	: QDockWidget(parent)
{
	setWindowTitle(tr("Inspector"));
	m_treeWidget = new QTreeWidget(this);
//	m_treeWidget->setHeaderLabel(tr("Inspector"));
	m_treeWidget->setHeaderHidden(true);
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

    m_treeWidget->expandItem(treeItem1);    // opcodes
    m_treeWidget->collapseItem(treeItem2);  // macros
    m_treeWidget->expandItem(treeItem3);    // instruments
    m_treeWidget->collapseItem(treeItem4);  // ftables
    m_treeWidget->collapseItem(treeItem5);    // score
    opcodeRegexp = QRegExp("\\bopcode\\s+(\\w+)\\b");
    inspectLabels = false;

	QPalette palette = QGuiApplication::palette();
	bool isLight =  (palette.color(QPalette::Text).lightness() <
			palette.color(QPalette::Window).lightness());
	setColors(isLight);
}


Inspector::~Inspector()
{
	delete m_treeWidget;
}

void Inspector::parseText(const QString &text)
{
	//  qDebug() << "Inspector::parseText";
    // m_opcodes.clear();
    udosMap.clear();
    udosVector.clear();
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
	treeItem1->setBackground(0, QBrush(headingBgColor));
	treeItem2 = new TreeItem(m_treeWidget, QStringList(tr("Macros")));
	treeItem2->setLine(-1);
	treeItem3 = new TreeItem(m_treeWidget, QStringList(tr("Instruments")));
	treeItem3->setLine(-1);
	treeItem3->setBackground(0, QBrush(headingBgColor));
	treeItem4 = new TreeItem(m_treeWidget, QStringList(tr("F-tables")));
	treeItem4->setLine(-1);
	treeItem5 = new TreeItem(m_treeWidget, QStringList(tr("Score")));
	treeItem5->setLine(-1);  // This might be overridden below
	treeItem5->setBackground(0, QBrush(headingBgColor));
	TreeItem *currentInstrument = treeItem3;
    Opcode *currentOpcode = nullptr;
	int commentIndex = 0;
    int index;
	bool partOfComment = false;
	QStringList lines = text.split(QRegExp("[\n\r]"));
    QString line;
    auto xinRegexp = QRegExp("\\bxin\\b");
	for (int i = 0; i< lines.size(); i++) {
        line = lines[i].trimmed();
		if (!partOfComment && lines[i].indexOf("/*") != -1) {
			partOfComment = true;
			commentIndex = lines[i].indexOf("/*");
		}
		if (partOfComment) {
			if (lines[i].indexOf("*/") != -1) {
				partOfComment = false;
				commentIndex = -1;
			} else {
				commentIndex = 0;
			}
		}
        if (line.startsWith("instr")) {
            QString text = line.mid(line.indexOf("instr") + 6);
            QStringList columnslist(text.simplified());
			TreeItem *newItem = new TreeItem(treeItem3, columnslist);
			newItem->setLine(i + 1);
			newItem->setForeground (0, QBrush(instrColor) );
			newItem->setBackground(0, QBrush(itemBgColor));
			currentInstrument = newItem;
		}
        else if (line.startsWith(";; ")) {
			QStringList columnslist(lines[i].trimmed().remove(0,2));
			TreeItem *newItem = new TreeItem(currentInstrument, columnslist);
			newItem->setForeground (0, QBrush(commentColor) );
			newItem->setLine(i + 1);
		}
        else if (line.startsWith("endin")) {
            // everything between instruments is placed in the main instrument menu
            currentInstrument = treeItem3;
		}
        else if (line.startsWith("endop")) {
            if(currentOpcode != nullptr) {
                udosMap.insert(currentOpcode->opcodeName, *currentOpcode);
                udosVector << currentOpcode;
                currentOpcode = nullptr;
            }

        }
        else if ((index = opcodeRegexp.indexIn(line, 0)) != -1) {
            auto opcodeName = opcodeRegexp.cap(1);
            QString text = line.simplified();
            QStringList columnslist(text.mid(7));
            // m_opcodes.append(opcodeName);
            if (treeItem1->childCount() == 0) { // set line for element to the first one found
                treeItem1->setLine(i + 1);
            }
            TreeItem *newItem = new TreeItem(treeItem1, columnslist);
            newItem->setLine(i + 1);
            currentInstrument = newItem;
			newItem->setBackground(0, itemBgColor);
            currentOpcode = new Opcode();
            currentOpcode->opcodeName = opcodeName;
        }
        else if ((index = xinRegexp.indexIn(line, 0)) != -1
                 && !partOfComment
                 && currentOpcode != nullptr) {
            currentOpcode->inArgs = line.mid(0, index).simplified();
            QStringList columnslist(line.simplified());
            TreeItem *newItem = new TreeItem(currentInstrument, columnslist);
            newItem->setLine(i + 1);
			newItem->setForeground(0, parameterColor);
        }
        else if ((index = QRegExp("\\bxout\\b").indexIn(line, 0)) != -1
                 && !partOfComment
                 && currentOpcode != nullptr) {
            currentOpcode->outArgs = line.mid(0, index).simplified();
            QStringList columnslist(line.simplified());
            TreeItem *newItem = new TreeItem(currentInstrument, columnslist);
            newItem->setLine(i + 1);
			newItem->setForeground(0, parameterColor);
        }
        else if (line.startsWith("#define")) {
            QString text = line.simplified().mid(8);
            QStringList columnslist(text);
			if (treeItem2->childCount() == 0) { // set line for element to the first one found
				treeItem2->setLine(i + 1);
			}
			TreeItem *newItem = new TreeItem(treeItem2, columnslist);
			newItem->setLine(i + 1);
		}
        // table
        else if (line.contains(QRegExp("^f\\s*\\d")) ||
                 line.contains(QRegExp("^[\\w]*[\\s]*ftgen"))) {
            QString text = line;
			QStringList columnslist(text.simplified());
			if (treeItem4->childCount() == 0) { // set line for element to the first one found
				treeItem4->setLine(i + 1);
			}
			TreeItem *newItem = new TreeItem(treeItem4, columnslist);
			newItem->setLine(i + 1);
		}
        else if (line.contains(QRegExp("^s\\s*\\b")) ||
                 line.contains(QRegExp("^m\\s*\\b"))) {
            QString text = line;
			QStringList columnslist(text.simplified());
			TreeItem *newItem = new TreeItem(treeItem5, columnslist);
			newItem->setLine(i + 1);
		}
        // label
        else if (inspectLabels
                 && line.contains(QRegExp("^\\s*\\b\\w+:"))
				 && (!partOfComment || commentIndex > lines[i].indexOf(":")) ) {
            QString text = line;
			QStringList columnslist(text.simplified());
			if (currentInstrument != 0) {
				TreeItem *newItem = new TreeItem(currentInstrument, columnslist);
				newItem->setLine(i + 1);
			}
		}
        else if (line.contains("<CsScore>")) {
			treeItem5->setLine(i + 1);
			currentInstrument = treeItem5;
		}
        else if (line.contains("<CsInstruments>")) {
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
			newItem->setForeground (0, QBrush(commentColor) );
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

void Inspector::setColors(bool light)
{
	if (light) {
		headingBgColor = QColor(Qt::lightGray);
		instrColor = QColor(Qt::darkMagenta);
		itemBgColor = QColor(240,240,240);
		commentColor = QColor(Qt::darkGreen);
		parameterColor = QColor(Qt::darkBlue);
	} else {
		headingBgColor = QColor(Qt::darkGray);
		instrColor = QColor("#ff8ff4"); // #d298fb
		itemBgColor = QColor(Qt::transparent); //QColor(15,15,15);
		commentColor = QColor("#ae9ed6");
		parameterColor = QColor("#45c6d6");

	}
	this->update();
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
	if (newItem == 0) {
		return;
	}
	int line = static_cast<TreeItem *>(newItem)->getLine();
	if (line >= 0) {
		emit jumpToLine(line);
	}
}
