/*
	Copyright (C) 2026 CsoundQt contributors

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

#include "opcodeinsertbar.h"

#include <QApplication>
#include <QKeyEvent>
#include <QLineEdit>
#include <QListWidget>
#include <QScrollBar>
#include <QTextEdit>
#include <QVBoxLayout>


OpcodeInsertBar::OpcodeInsertBar(QTextEdit *editor)
	: QFrame(editor), m_editor(editor)
{
	setObjectName("opcodeInsertBar");
	setFrameShape(QFrame::StyledPanel);
	setFrameShadow(QFrame::Raised);
	setAutoFillBackground(true);
	// The bar is a child of the (monospace) editor, from which it would inherit
	// the editor font. Use the normal UI font instead.
	setFont(QApplication::font());
	buildUi();

	if (m_editor) {
		m_editor->installEventFilter(this);
		if (m_editor->viewport())
			m_editor->viewport()->installEventFilter(this);
	}
	hide();
}

void OpcodeInsertBar::buildUi()
{
	auto *outer = new QVBoxLayout(this);
	outer->setContentsMargins(6, 4, 6, 4);
	outer->setSpacing(3);

	m_searchEdit = new QLineEdit(this);
	m_searchEdit->setPlaceholderText(tr("Insert opcode..."));
	m_searchEdit->setClearButtonEnabled(true);
	m_searchEdit->installEventFilter(this);
	outer->addWidget(m_searchEdit);

	m_list = new QListWidget(this);
	m_list->setUniformItemSizes(true);
	m_list->setMinimumHeight(200);
	m_list->installEventFilter(this);
	outer->addWidget(m_list);

	connect(m_searchEdit, &QLineEdit::textChanged, this, [this](const QString &) { refilter(); });
	connect(m_list, &QListWidget::itemDoubleClicked, this, [this](QListWidgetItem *) { acceptCurrent(); });
}

void OpcodeInsertBar::setOpcodes(const QStringList &opcodes)
{
	m_opcodes = opcodes;
}

void OpcodeInsertBar::showBar()
{
	m_searchEdit->clear();
	refilter();
	show();
	raise();
	reposition();
	m_searchEdit->setFocus(Qt::ShortcutFocusReason);
}

void OpcodeInsertBar::hideBar()
{
	hide();
	if (m_editor)
		m_editor->setFocus(Qt::OtherFocusReason);
}

void OpcodeInsertBar::refilter()
{
	const QString filter = m_searchEdit->text();
	const int previousRow = m_list->currentRow();
	m_list->setUpdatesEnabled(false);
	m_list->clear();
	int matchCount = 0;
	for (const QString &opcode : m_opcodes) {
		if (filter.isEmpty() || opcode.contains(filter, Qt::CaseInsensitive)) {
			auto *item = new QListWidgetItem(opcode, m_list);
			item->setData(Qt::UserRole, opcode);
			matchCount++;
		}
	}
	if (matchCount == 0)
		new QListWidgetItem(tr("No matches."), m_list); // status row carries no data
	// Select the first match by default so Enter/Tab inserts it; keep the
	// current row if it is still valid (cf. LiteHtmlView::runManualSearch).
	m_list->setCurrentRow((previousRow >= 0 && previousRow < matchCount) ? previousRow : 0);
	m_list->setUpdatesEnabled(true);
}

void OpcodeInsertBar::moveSelection(int delta)
{
	if (m_list->count() == 0)
		return;
	const int row = m_list->currentRow();
	m_list->setCurrentRow(qBound(0, row + delta, m_list->count() - 1));
}

void OpcodeInsertBar::pageSelection(int delta)
{
	if (m_list->count() == 0)
		return;
	int rowHeight = m_list->sizeHintForRow(0);
	if (rowHeight <= 0)
		rowHeight = m_list->fontMetrics().height();
	const int page = qMax(1, m_list->viewport()->height() / rowHeight);
	moveSelection(delta * page);
}

void OpcodeInsertBar::acceptCurrent()
{
	QListWidgetItem *item = m_list->currentItem();
	if (!item)
		return;
	const QVariant data = item->data(Qt::UserRole); // status rows have no data
	if (!data.isValid())
		return;
	emit opcodeChosen(data.toString());
}

bool OpcodeInsertBar::eventFilter(QObject *watched, QEvent *event)
{
	const bool fromEditor = m_editor
			&& (watched == m_editor || watched == m_editor->viewport());
	if (fromEditor && event->type() == QEvent::Resize) {
		if (isVisible())
			reposition();
		return false;
	}

	if ((watched == m_searchEdit || watched == m_list)
			&& event->type() == QEvent::KeyPress) {
		auto *ke = static_cast<QKeyEvent *>(event);
		switch (ke->key()) {
		case Qt::Key_Return:
		case Qt::Key_Enter:
		case Qt::Key_Tab:
			acceptCurrent();
			return true;
		case Qt::Key_Escape:
			hideBar();
			emit closed();
			return true;
		case Qt::Key_Up:
			moveSelection(-1);
			return true;
		case Qt::Key_Down:
			moveSelection(1);
			return true;
		case Qt::Key_PageUp:
			pageSelection(-1);
			return true;
		case Qt::Key_PageDown:
			pageSelection(1);
			return true;
		default:
			break;
		}
	}
	return QFrame::eventFilter(watched, event);
}

void OpcodeInsertBar::reposition()
{
	if (!m_editor || !m_editor->viewport())
		return;
	adjustSize();
	// The bar is a child of the editor itself (a sibling of its viewport), so
	// it does not move when the editor scrolls its viewport. The viewport
	// rect is expressed in editor coordinates.
	const QRect vp = m_editor->viewport()->geometry();
	const int margin = 10;
	const int maxWidth = qMax(0, vp.width() - 2 * margin);
	const int maxHeight = qMax(0, vp.height() - 2 * margin);
	const int preferredWidth = 420;
	QSize s = size();
	s.setWidth(qMin(qMax(preferredWidth, s.width()), maxWidth));
	s.setHeight(qMin(s.height(), maxHeight));
	const int x = qMax(vp.left() + margin, vp.right() - s.width() - margin + 1);
	const int y = qMax(vp.top() + margin, vp.top() + margin);
	setGeometry(x, y, s.width(), s.height());
	raise();
}
