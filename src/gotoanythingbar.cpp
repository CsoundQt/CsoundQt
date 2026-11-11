/*
	Copyright (C) 2026 CsoundQt contributors

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "gotoanythingbar.h"

#include <QApplication>
#include <QKeyEvent>
#include <QLineEdit>
#include <QListWidget>
#include <QScrollBar>
#include <QTextEdit>
#include <QVBoxLayout>

#include <algorithm>

namespace {

// Ordered fuzzy match: every character of `query` must appear in `text`, in
// the same order (case-insensitively). Characters at the start of `text` or a
// word score higher, and consecutive characters score higher still, so the
// best match sorts first. Returns -1 when the query does not match.
int fuzzyScore(const QString &text, const QString &query)
{
	int score = 0;
	int from = 0;
	int previous = -2; // no previous match
	for (const QChar qc : query) {
		int found = -1;
		for (int i = from; i < text.size(); ++i) {
			if (text.at(i).toCaseFolded() == qc.toCaseFolded()) {
				found = i;
				break;
			}
		}
		if (found < 0)
			return -1;
		const QChar before = found > 0 ? text.at(found - 1) : QChar();
		const bool wordStart = found == 0 || before.isSpace()
				|| before == QLatin1Char('-') || before == QLatin1Char('/')
				|| before == QLatin1Char(':');
		if (wordStart)
			score += 16;
		if (found == previous + 1)
			score += 8;
		score += 1;
		previous = found;
		from = found + 1;
	}
	return score;
}

} // namespace


GoToAnythingBar::GoToAnythingBar(QTextEdit *editor)
	: QFrame(editor), m_editor(editor)
{
	setObjectName("goToAnythingBar");
	setFrameShape(QFrame::NoFrame);
	// One pixel more border than the default (2 px), because the background
	// matches the editor's. Keep the filter field square.
	setStyleSheet(QStringLiteral(
	        "QFrame#goToAnythingBar { border: 2px solid palette(mid); }"
	        "QFrame#goToAnythingBar QLineEdit { border-radius: 0px; }"));
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
	// Like a command palette, close when the focus moves elsewhere (clicking
	// the editor, another panel, a menu...). Moving focus inside the bar (to
	// the list) keeps it open.
	connect(qApp, &QApplication::focusChanged, this,
	        [this](QWidget *, QWidget *now) {
		if (!isVisible() || now == nullptr)
			return;
		if (now == this || isAncestorOf(now))
			return;
		hideBar();
	});
	hide();
}

void GoToAnythingBar::buildUi()
{
	auto *outer = new QVBoxLayout(this);
	outer->setContentsMargins(0, 0, 0, 0);
	outer->setSpacing(0);

	m_searchEdit = new QLineEdit(this);
	m_searchEdit->setPlaceholderText(tr("Go to opcode, instrument or <CsScore>..."));
	m_searchEdit->setClearButtonEnabled(true);
	m_searchEdit->installEventFilter(this);
	outer->addWidget(m_searchEdit);

	m_list = new QListWidget(this);
	m_list->setUniformItemSizes(true);
	m_list->setMinimumHeight(0);
	m_list->installEventFilter(this);
	outer->addWidget(m_list, 1);

	connect(m_searchEdit, &QLineEdit::textChanged, this,
	        [this](const QString &) { refilter(); });
	connect(m_list, &QListWidget::itemDoubleClicked, this,
	        [this](QListWidgetItem *) { acceptCurrent(); });
}

void GoToAnythingBar::setEntries(const QVector<Entry> &entries)
{
	m_entries = entries;
}

void GoToAnythingBar::showBar()
{
	m_searchEdit->clear();
	refilter();
	// The height is chosen from the entries present when the bar opens and is
	// kept while it is visible: narrowing the filter must not make it shrink.
	m_height = contentHeight();
	show();
	raise();
	reposition();
	m_searchEdit->setFocus(Qt::ShortcutFocusReason);
}

void GoToAnythingBar::hideBar()
{
	hide();
	if (m_editor)
		m_editor->setFocus(Qt::OtherFocusReason);
}

void GoToAnythingBar::refilter()
{
	const QString filter = m_searchEdit->text();
	const int previousRow = m_list->currentRow();

	// Ordered fuzzy matching: "opc fo" finds "opcode Foo". Keep the original
	// order when there is no filter, otherwise show the best matches first.
	QVector<QPair<int, int>> matches; // entry index, score
	matches.reserve(m_entries.size());
	for (int i = 0; i < m_entries.size(); ++i) {
		if (filter.isEmpty()) {
			matches.append({i, 0});
			continue;
		}
		const int score = fuzzyScore(m_entries.at(i).label, filter);
		if (score >= 0)
			matches.append({i, score});
	}
	if (!filter.isEmpty()) {
		std::stable_sort(matches.begin(), matches.end(),
		                 [](const QPair<int, int> &a, const QPair<int, int> &b) {
			return a.second > b.second;
		});
	}

	m_list->setUpdatesEnabled(false);
	m_list->clear();
	for (const QPair<int, int> &match : matches) {
		auto *item = new QListWidgetItem(m_entries.at(match.first).label, m_list);
		item->setData(Qt::UserRole, match.first);
	}
	const int matchCount = matches.size();
	if (matchCount == 0)
		new QListWidgetItem(tr("No matches."), m_list); // status row has no data
	// Select the first match so Enter jumps immediately; keep the current row
	// if it is still valid.
	m_list->setCurrentRow((previousRow >= 0 && previousRow < matchCount) ? previousRow : 0);
	m_list->setUpdatesEnabled(true);
}

void GoToAnythingBar::moveSelection(int delta)
{
	if (m_list->count() == 0)
		return;
	const int row = m_list->currentRow();
	m_list->setCurrentRow(qBound(0, row + delta, m_list->count() - 1));
}

void GoToAnythingBar::pageSelection(int delta)
{
	if (m_list->count() == 0)
		return;
	int rowHeight = m_list->sizeHintForRow(0);
	if (rowHeight <= 0)
		rowHeight = m_list->fontMetrics().height();
	const int page = qMax(1, m_list->viewport()->height() / rowHeight);
	moveSelection(delta * page);
}

void GoToAnythingBar::acceptCurrent()
{
	QListWidgetItem *item = m_list->currentItem();
	if (!item)
		return;
	const QVariant data = item->data(Qt::UserRole); // status rows have no data
	if (!data.isValid())
		return;
	const int index = data.toInt();
	if (index < 0 || index >= m_entries.size())
		return;
	const Entry entry = m_entries.at(index);
	hideBar();
	emit entryChosen(entry.file, entry.line, entry.column);
}

bool GoToAnythingBar::eventFilter(QObject *watched, QEvent *event)
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

void GoToAnythingBar::reposition()
{
	if (!m_editor || !m_editor->viewport())
		return;
	// The bar is a child of the editor itself (a sibling of its viewport), so
	// it does not move when the editor scrolls. It opens at the top edge and is
	// horizontally centred, with a maximum width of 600 px.
	const QRect area = m_editor->contentsRect();
	const int width = qMin(area.width(), 600);
	// The height was chosen when the bar was shown; only clamp it when the
	// panel became smaller (or when the bar is repositioned outside showBar).
	const int maxHeight = qMin(qMax(120, area.height() * 3 / 5), area.height());
	const int height = qMin(m_height > 0 ? m_height : contentHeight(), maxHeight);
	const int x = area.left() + qMax(0, (area.width() - width) / 2);
	setGeometry(x, 0, width, height);
	raise();
}

int GoToAnythingBar::contentHeight() const
{
	int rowHeight = m_list->sizeHintForRow(0);
	if (rowHeight <= 0)
		rowHeight = m_list->fontMetrics().height();
	const int rows = qMax(1, m_list->count());
	// 2 px border on each side of the bar (drawn by the stylesheet, not by
	// QFrame), plus the list's own frame.
	const int chrome = m_searchEdit->sizeHint().height()
			+ 2 * (2 + m_list->frameWidth());
	return chrome + rows * rowHeight;
}
