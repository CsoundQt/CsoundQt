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

#include "keyboardshortcuts.h"
#include <QAction>

namespace {
// Qt fires the shorter shortcut immediately when one sequence is a prefix of
// the other, so such bindings cannot coexist.
bool sequencesConflict(const QKeySequence &a, const QKeySequence &b)
{
	if (a.isEmpty() || b.isEmpty()) {
		return false;
	}
	const int chords = qMin(a.count(), b.count());
	for (int i = 0; i < chords; i++) {
		if (a[i] != b[i]) {
			return false;
		}
	}
	return true;
}

// Name shown in this dialog. Actions whose menu text is terse (e.g. the
// checkable panel entries "Editor", "Widgets", ...) can carry a clearer
// "shortcutName" property without changing the View menu.
QString shortcutName(QAction *action)
{
	const QVariant custom = action->property("shortcutName");
	return custom.isValid() ? custom.toString() : action->text().remove("&");
}
}

KeyboardShortcuts::KeyboardShortcuts(QWidget *parent, const QVector<QAction *> keyActions)
	: QDialog(parent), m_keyActions(keyActions)
{
    m_modified = false;
	setupUi(this);
	setWindowTitle(tr("Keyboard Shortcuts"));
	//   QDialog::setSizePolicy(QSizePolicy(QSizePolicy::Fixed,QSizePolicy::Fixed));
	connect(restorePushButton, SIGNAL(released()), this, SLOT(restoreDefaults()));
	connect(tableWidget, SIGNAL(cellClicked(int, int)), this, SLOT(assignShortcut(int, int)));
	// Incremental filter: hide rows that match neither action nor shortcut text,
	// cf. QuteWidget::showAvailableProperties()
	connect(filterLineEdit, &QLineEdit::textChanged, this, &KeyboardShortcuts::filterTable);
	refreshTable();
}

KeyboardShortcuts::~KeyboardShortcuts()
{
	for (int i = 0; i < m_keyActions.size(); i++) {
		m_keyActions[i]->setShortcut(getShortcut(shortcutName(m_keyActions[i])));
	}
}

void KeyboardShortcuts::refreshTable()
{
	tableWidget->setColumnWidth(0, 320);
	tableWidget->setColumnWidth(1, 170);
	tableWidget->setRowCount(m_keyActions.size());
	for (int i = 0; i < m_keyActions.size(); i++) {
		QTableWidgetItem *name = tableWidget->item(i, 0);
		QTableWidgetItem *key = tableWidget->item(i, 1);
		if (name == 0) {
			name = new QTableWidgetItem();
			tableWidget->setItem(i,0, name);
		}
		if (key == 0) {
			key = new QTableWidgetItem();
			tableWidget->setItem(i,1, key);
		}
		name->setText(shortcutName(m_keyActions[i]));
		key->setText(m_keyActions[i]->shortcut().toString());
	}
    tableWidget->sortItems(0);
	filterTable(filterLineEdit->text());
}

void KeyboardShortcuts::filterTable(const QString &filter)
{
	for (int row = 0; row < tableWidget->rowCount(); row++) {
		QTableWidgetItem *name = tableWidget->item(row, 0);
		QTableWidgetItem *key = tableWidget->item(row, 1);
		const QString nameText = name != nullptr ? name->text() : QString();
		const QString keyText = key != nullptr ? key->text() : QString();
		const bool match = nameText.contains(filter, Qt::CaseInsensitive)
			|| keyText.contains(filter, Qt::CaseInsensitive);
		tableWidget->setRowHidden(row, !match);
	}
}

bool KeyboardShortcuts::shortcutTaken(QString shortcut, int excludeRow)
{
	const QKeySequence candidate(shortcut);
	if (candidate.isEmpty()) {
		return false; // An empty shortcut clears the assignment
	}
	int rows = tableWidget->rowCount();
	for (int i = 0; i < rows; i++) {
		if (i == excludeRow) {
			continue;
		}
		QTableWidgetItem *key = tableWidget->item(i, 1);
		if (key != 0 && !key->text().isEmpty()
				&& sequencesConflict(candidate, QKeySequence(key->text()))) {
			return true;
		}
	}
	return false;
}

QString KeyboardShortcuts::getShortcut(QString action)
{
	int rows = tableWidget->rowCount();
	for (int i = 0; i < rows; i++) {
		QTableWidgetItem *name = tableWidget->item(i, 0);
		QTableWidgetItem *key = tableWidget->item(i, 1);
		if (name != 0 && name->text() == action) {
			if (key != 0) {
				return key->text();
			}
			break;
		}
	}
	return QString();
}

void KeyboardShortcuts::restoreDefaults()
{
	emit restoreDefaultShortcuts();  // To have the main application restore the default shortcuts in the m_keyActions pointer
	refreshTable();
}

void KeyboardShortcuts::assignShortcut(int row, int /*column*/)
{
	Q_ASSERT(m_keyActions.size() > row);
	Q_ASSERT(tableWidget->rowCount() > row);
	QTableWidgetItem *nameItem = tableWidget->item(row, 0);
	QTableWidgetItem *keyitem = tableWidget->item(row, 1);
	if (nameItem == 0) {
		nameItem = new QTableWidgetItem();
		tableWidget->setItem(row,0, nameItem);
	}
	if (keyitem == 0) {
		keyitem = new QTableWidgetItem();
		tableWidget->setItem(row,1, keyitem);
	}
	QString name = nameItem->text();
	QString key = keyitem->text();
	KeySelector dialog(this, name, key);
	if (dialog.exec() == QDialog::Accepted) {
		if (shortcutTaken(dialog.newShortcut, row)) {
			QMessageBox::warning(this, tr("Invalid shortcut"),
								 tr("Shortcut cannot be assigned.\nIt is already used or is a prefix of another shortcut."),
								 QMessageBox::Ok,
								 QMessageBox::Ok);
			return;
		}
		keyitem->setText(dialog.newShortcut);
        m_modified = true;
		//    refreshTable();
	}
}

/* ---------------------------------------------------*/

KeySelector::KeySelector(QWidget *parent, QString command, QString currentShortcut)
	: QDialog(parent)
{
	setupUi(this);
	setWindowTitle(tr("Press Key Combination"));
	commandLabel->setText(command);
	currentLabel->setText(currentShortcut != "" ? currentShortcut: tr("None"));
	// QKeySequenceEdit supports multi-chord sequences (e.g. "Ctrl+T, E").
	keySequenceEdit->setKeySequence(QKeySequence(currentShortcut));
	keySequenceEdit->setFocus();
}

KeySelector::~KeySelector()
{
}

void KeySelector::accept()
{
	newShortcut = keySequenceEdit->keySequence().toString();
	QDialog::accept();
}
