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

#ifndef GOTOANYTHINGBAR_H
#define GOTOANYTHINGBAR_H

#include <QFrame>
#include <QString>
#include <QVector>

class QLineEdit;
class QListWidget;
class QTextEdit;

// A command-palette style overlay for jumping to a definition in the current
// document or in one of its #include files. It is a child of the editor (like
// OpcodeInsertBar), opens at the top edge of the editor and is horizontally
// centred, with a maximum width of 600 px: a filter field with a list below it.
//
// The bar is UI only. The document builds the list of entries and handles the
// chosen one, so this class knows nothing about scanning or files. Filtering
// below uses ordered fuzzy matching ("opc fo" matches "opcode Foo").
class GoToAnythingBar : public QFrame
{
	Q_OBJECT
public:
	struct Entry
	{
		QString label;      // text shown and matched by the filter
		QString file;       // empty for the current document
		int line = -1;      // 1-based
		int column = 0;     // 0-based
	};

	explicit GoToAnythingBar(QTextEdit *editor);

	void setEntries(const QVector<Entry> &entries);

	void showBar();
	void hideBar();

signals:
	void entryChosen(const QString &file, int line, int column);

protected:
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	void buildUi();
	void reposition();
	void refilter();
	void moveSelection(int delta);
	void pageSelection(int delta);
	void acceptCurrent();
	int contentHeight() const;

	QTextEdit *m_editor = nullptr;
	QLineEdit *m_searchEdit = nullptr;
	QListWidget *m_list = nullptr;
	QVector<Entry> m_entries;
	// Height chosen when the bar is shown; kept while it is visible.
	int m_height = 0;
};

#endif // GOTOANYTHINGBAR_H
