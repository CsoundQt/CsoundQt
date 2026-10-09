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

#ifndef OPCODEINSERTBAR_H
#define OPCODEINSERTBAR_H

#include <QFrame>

class QLineEdit;
class QListWidget;
class QTextEdit;

// A compact, non-modal opcode search bar overlaid on a QTextEdit.
// Modelled after the help panel's global search: a search field filters a
// list of entries, but here the entries are all known opcodes and matching
// is by substring rather than by prefix (unlike autocomplete). Enter or Tab
// inserts the selected opcode name, Esc dismisses the bar, Up/Down and
// PgUp/PgDown move over the list. The bar only owns the UI state;
// DocumentView performs the actual insertion at the cursor.
class OpcodeInsertBar : public QFrame
{
	Q_OBJECT
public:
	explicit OpcodeInsertBar(QTextEdit *editor);

	void setOpcodes(const QStringList &opcodes);

	void showBar();
	void hideBar();

signals:
	void opcodeChosen(const QString &opcode);
	void closed();

protected:
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	void buildUi();
	void reposition();
	void refilter();
	void moveSelection(int delta);
	void pageSelection(int delta);
	void acceptCurrent();

	QTextEdit *m_editor = nullptr;
	QLineEdit *m_searchEdit = nullptr;
	QListWidget *m_list = nullptr;
	QStringList m_opcodes;
};

#endif // OPCODEINSERTBAR_H
