/*
	Copyright (C) 2008, 2009 Andres Cabrera
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

#ifndef KEYBOARDSHORTCUTS_H
#define KEYBOARDSHORTCUTS_H

#include <QtWidgets>

#include "ui_keyboardshortcuts.h"
#include "ui_keyselector.h"

class QAction;

class KeyboardShortcutsWidget : public QWidget, private Ui::KeyboardShortcuts
{
	Q_OBJECT

public:
	// The Shortcuts page of the configuration dialog. There is no Apply here:
	// an assignment is written to its action immediately.
	KeyboardShortcutsWidget(QWidget *parent, const QVector<QAction *> keyActions,
							const QHash<QAction *, QKeySequence> &defaultShortcuts);

	void refreshTable();
    bool needsSave() { return m_modified; }

private:
	// Write one action's shortcut right away: a change must not wait for the
	// widget to be closed (or destroyed).
	void applyShortcut(const QString &actionName, const QString &shortcut);
	// The action shown in this (sorted) row, looked up by its displayed name.
	QAction *actionForRow(int row) const;
	// Bold the shortcut and add a "Default: ..." tooltip when it differs from
	// the default; plain text otherwise.
	void formatShortcutItem(int row, QAction *action);
	// The rows whose shortcut cannot coexist with this one: the same sequence,
	// or one that is a prefix of the other.
	QList<int> conflictingRows(const QString &shortcut, int excludeRow = -1) const;

	QVector<QAction *> m_keyActions;
	// Built-in shortcuts, before the stored assignments were applied.
	QHash<QAction *, QKeySequence> m_defaultShortcuts;
    bool m_modified;

private slots:
	void restoreDefaults();
	void assignShortcut(int row, int column);
	void filterTable(const QString &filter);

signals:
	void restoreDefaultShortcuts();
};



class KeySelector : public QDialog, private Ui::KeySelectorDialog
{
	Q_OBJECT

public:
	KeySelector(QWidget *parent, const QString &command, const QString &currentShortcut,
				const QKeySequence &defaultShortcut, bool hasDefault);
	~KeySelector();
	QString newShortcut;

	void accept() override;

protected:
	// Escape closes the dialog instead of ending up in the key sequence.
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	QKeySequence m_defaultShortcut;
};

#endif
