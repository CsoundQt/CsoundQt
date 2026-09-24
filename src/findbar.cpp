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

#include "findbar.h"

#include <QApplication>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QIcon>
#include <QKeyEvent>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QStyle>
#include <QTextEdit>
#include <QToolButton>


FindBar::FindBar(QTextEdit *editor)
	: QFrame(editor), m_editor(editor)
{
	setObjectName("findBar");
	setFrameShape(QFrame::StyledPanel);
	setFrameShadow(QFrame::Raised);
	setAutoFillBackground(true);
	// The bar is a child of the (monospace) editor, from which it would inherit
	// the editor font. Use the normal UI font instead.
	setFont(QApplication::font());
	buildUi();
	applyPalette();

	if (m_editor) {
		m_editor->installEventFilter(this);
		if (m_editor->viewport())
			m_editor->viewport()->installEventFilter(this);
	}
	hide();
}

void FindBar::buildUi()
{
	auto *outer = new QVBoxLayout(this);
	outer->setContentsMargins(6, 4, 6, 4);
	outer->setSpacing(3);

	auto *findRow = new QHBoxLayout();
	findRow->setSpacing(3);
	m_findEdit = new QLineEdit(this);
	m_findEdit->setPlaceholderText(tr("Find (Enter next, Shift+Enter previous, Esc close)"));
	m_findEdit->setMinimumWidth(120);
	m_findEdit->installEventFilter(this);
	findRow->addWidget(m_findEdit, 1);

	m_prevButton = new QToolButton(this);
	m_prevButton->setIcon(style()->standardIcon(QStyle::SP_ArrowLeft));
	m_prevButton->setToolTip(tr("Find previous (Shift+Enter)"));
	m_prevButton->setAutoRaise(true);
	findRow->addWidget(m_prevButton);

	m_nextButton = new QToolButton(this);
	m_nextButton->setIcon(style()->standardIcon(QStyle::SP_ArrowRight));
	m_nextButton->setToolTip(tr("Find next (Enter)"));
	m_nextButton->setAutoRaise(true);
	findRow->addWidget(m_nextButton);

	m_statusLabel = new QLabel(this);
	m_statusLabel->setMinimumWidth(40);
	m_statusLabel->setAlignment(Qt::AlignRight | Qt::AlignVCenter);
	findRow->addWidget(m_statusLabel);

	m_closeButton = new QToolButton(this);
	m_closeButton->setIcon(style()->standardIcon(QStyle::SP_DialogCloseButton));
	m_closeButton->setToolTip(tr("Close (Esc)"));
	m_closeButton->setAutoRaise(true);
	findRow->addWidget(m_closeButton);

	outer->addLayout(findRow);

	auto *replaceRow = new QHBoxLayout();
	replaceRow->setSpacing(3);
	m_replaceEdit = new QLineEdit(this);
	m_replaceEdit->setPlaceholderText(tr("Replace with"));
	m_replaceEdit->setMinimumWidth(120);
	m_replaceEdit->installEventFilter(this);
	replaceRow->addWidget(m_replaceEdit, 1);

	m_replaceButton = new QPushButton(tr("Replace"), this);
	replaceRow->addWidget(m_replaceButton);
	m_replaceAllButton = new QPushButton(tr("Replace all"), this);
	replaceRow->addWidget(m_replaceAllButton);

	outer->addLayout(replaceRow);

	connect(m_findEdit, &QLineEdit::textChanged, this, &FindBar::queryChanged);
	connect(m_prevButton, &QToolButton::clicked, this, &FindBar::findPreviousRequested);
	connect(m_nextButton, &QToolButton::clicked, this, &FindBar::findNextRequested);
	connect(m_replaceButton, &QPushButton::clicked, this, &FindBar::replaceRequested);
	connect(m_replaceAllButton, &QPushButton::clicked, this, &FindBar::replaceAllRequested);
	connect(m_closeButton, &QToolButton::clicked, this, &FindBar::closed);
}

QString FindBar::query() const
{
	return m_findEdit->text();
}

void FindBar::setQuery(const QString &query)
{
	if (m_findEdit->text() == query)
		return;
	m_findEdit->setText(query); // emits textChanged -> queryChanged
}

QString FindBar::replacement() const
{
	return m_replaceEdit->text();
}

void FindBar::showBar()
{
	applyPalette();
	show();
	raise();
	reposition();
	focusFind();
}

void FindBar::focusFind()
{
	m_findEdit->setFocus(Qt::ShortcutFocusReason);
	m_findEdit->selectAll();
}

void FindBar::setStatus(const QString &text)
{
	m_statusLabel->setText(text);
}

void FindBar::setMatchCount(int current, int total)
{
	if (total <= 0)
		m_statusLabel->clear();
	else
		m_statusLabel->setText(QString("%1/%2").arg(current).arg(total));
}

bool FindBar::eventFilter(QObject *watched, QEvent *event)
{
	const bool fromEditor = m_editor
			&& (watched == m_editor || watched == m_editor->viewport());

	if (fromEditor && event->type() == QEvent::PaletteChange) {
		// The editor background/text follow the highlighting theme while the
		// placeholder colour comes from the application palette, which can
		// leave dark-on-dark text. Re-derive it from the editor palette.
		applyPalette();
		return false;
	}
	if (fromEditor && event->type() == QEvent::Resize) {
		if (isVisible())
			reposition();
		return false;
	}

	if (event->type() == QEvent::KeyPress) {
		auto *ke = static_cast<QKeyEvent *>(event);
		if (watched == m_findEdit || watched == m_replaceEdit) {
			if (ke->key() == Qt::Key_Escape) {
				emit closed();
				return true;
			}
			if (ke->key() == Qt::Key_Return || ke->key() == Qt::Key_Enter) {
				if (watched == m_replaceEdit)
					emit replaceRequested();
				else if (ke->modifiers() & Qt::ShiftModifier)
					emit findPreviousRequested();
				else
					emit findNextRequested();
				return true;
			}
			if (watched == m_findEdit) {
				if (ke->key() == Qt::Key_Up) {
					emit findPreviousRequested();
					return true;
				}
				if (ke->key() == Qt::Key_Down) {
					emit findNextRequested();
					return true;
				}
			}
		}
	}
	return QFrame::eventFilter(watched, event);
}

void FindBar::applyPalette()
{
	if (!m_editor)
		return;
	// Take the editor palette (so the fields match the editor's theme) but
	// make sure the placeholder text contrasts with the field background.
	QPalette p = m_editor->palette();
	QColor placeholder = p.color(QPalette::Text);
	placeholder.setAlpha(150);
	p.setColor(QPalette::PlaceholderText, placeholder);
	setPalette(p);

	// The QStyle standard icons are drawn with a fixed (dark) colour and are
	// hard to see on a dark theme. Use the themed arrow/close icons instead.
	const bool dark = p.color(QPalette::Button).lightness() < 128;
	const QString theme = dark ? "breeze-dark" : "breeze";
	m_prevButton->setIcon(QIcon(QString(":/themes/%1/browse-prev.png").arg(theme)));
	m_nextButton->setIcon(QIcon(QString(":/themes/%1/browse-next.png").arg(theme)));
	m_closeButton->setIcon(QIcon(QString(":/themes/%1/edit-close.png").arg(theme)));
}

void FindBar::reposition()
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
	const int preferredWidth = 480; // wide enough for find + replace
	QSize s = size();
	s.setWidth(qMin(qMax(preferredWidth, s.width()), maxWidth));
	int x = vp.right() - s.width() - margin + 1;
	int y = vp.top() + margin;
	x = qMax(vp.left() + margin, x);
	y = qMax(vp.top() + margin, y);
	setGeometry(x, y, s.width(), s.height());
	raise();
}
