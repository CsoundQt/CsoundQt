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

#include <QtGui>
#include "ui_keyboardshortcuts.h"
#include "ui_keyselector.h"

class QAction;

class KeyboardShortcuts : public QDialog, private Ui::KeyboardShortcuts
{
	Q_OBJECT

public:
	KeyboardShortcuts(QWidget *parent, const QVector<QAction *> keyActions);
	~KeyboardShortcuts();

	void refreshTable();
	bool shortcutTaken(QString shortcut);

private:
	QVector<QAction *> m_keyActions;

private slots:
	void restoreDefaults();
	void assignShortcut(int row, int column);
	QString getShortcut(QString action);

signals:
	void restoreDefaultShortcuts();
};



class KeySelector : public QDialog, private Ui::KeySelectorDialog
{
	Q_OBJECT

public:
	KeySelector(QWidget *parent, QString command, QString currentShortcut);
	~KeySelector();
	QString newShortcut;

protected:
	virtual void keyPressEvent(QKeyEvent *event);
};

#endif
