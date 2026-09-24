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

#ifndef FINDBAR_H
#define FINDBAR_H

#include <QFrame>

class QLineEdit;
class QLabel;
class QToolButton;
class QPushButton;
class QTextEdit;

// A compact, non-modal find/replace bar overlaid on a QTextEdit.
// Modelled after the help panel's in-panel find box: incremental search,
// Enter next, Shift+Enter previous, Esc close. The bar only owns the UI
// state; the search itself (matching, highlighting, replacing) is driven
// by DocumentView, which knows about the editor and the syntax checker.
class FindBar : public QFrame
{
	Q_OBJECT
public:
	explicit FindBar(QTextEdit *editor);

	QString query() const;
	void setQuery(const QString &query);
	QString replacement() const;

	void showBar();
	void hideBar() { hide(); }
	void focusFind();

	void setStatus(const QString &text);
	void setMatchCount(int current, int total);

signals:
	void queryChanged(const QString &query);
	void findNextRequested();
	void findPreviousRequested();
	void replaceRequested();
	void replaceAllRequested();
	void closed();

protected:
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	void buildUi();
	void applyPalette();
	void reposition();

	QTextEdit *m_editor = nullptr;
	QLineEdit *m_findEdit = nullptr;
	QLineEdit *m_replaceEdit = nullptr;
	QLabel *m_statusLabel = nullptr;
	QToolButton *m_prevButton = nullptr;
	QToolButton *m_nextButton = nullptr;
	QToolButton *m_closeButton = nullptr;
	QPushButton *m_replaceButton = nullptr;
	QPushButton *m_replaceAllButton = nullptr;
};

#endif // FINDBAR_H
