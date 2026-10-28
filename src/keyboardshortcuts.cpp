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
	// The .ui leaves the header texts empty, and Qt then numbers the columns.
	tableWidget->setHorizontalHeaderLabels(QStringList{
			tr("Action"), tr("Shortcut")});
	//   QDialog::setSizePolicy(QSizePolicy(QSizePolicy::Fixed,QSizePolicy::Fixed));
	connect(restorePushButton, SIGNAL(released()), this, SLOT(restoreDefaults()));
	connect(tableWidget, SIGNAL(cellClicked(int, int)), this, SLOT(assignShortcut(int, int)));
	// Incremental filter: hide rows that match neither action nor shortcut text,
	// cf. QuteWidget::showAvailableProperties()
	connect(filterLineEdit, &QLineEdit::textChanged, this, &KeyboardShortcuts::filterTable);
	refreshTable();
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

// The rows whose shortcut cannot coexist with this one: the same sequence, or
// one that is a prefix of the other (Qt would fire the shorter one at once).
QList<int> KeyboardShortcuts::conflictingRows(const QString &shortcut,
											  int excludeRow) const
{
	QList<int> rows;
	const QKeySequence candidate(shortcut);
	if (candidate.isEmpty()) {
		return rows; // An empty shortcut clears the assignment
	}
	for (int i = 0; i < tableWidget->rowCount(); i++) {
		if (i == excludeRow) {
			continue;
		}
		QTableWidgetItem *key = tableWidget->item(i, 1);
		if (key != 0 && !key->text().isEmpty()
				&& sequencesConflict(candidate, QKeySequence(key->text()))) {
			rows.append(i);
		}
	}
	return rows;
}

// The dialog only has a Close button, so every change is written to the action
// at the moment it is made instead of being collected and applied when the
// window goes away.
void KeyboardShortcuts::applyShortcut(const QString &actionName,
									  const QString &shortcut)
{
	for (QAction *action : m_keyActions) {
		if (shortcutName(action) == actionName) {
			action->setShortcut(QKeySequence(shortcut));
			return;
		}
	}
}

void KeyboardShortcuts::restoreDefaults()
{
	emit restoreDefaultShortcuts();  // To have the main application restore the default shortcuts in the m_keyActions pointer
	// Defaults are new values too, and must be stored when the dialog closes.
	m_modified = true;
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
		// A shortcut belongs to one action. Rather than refuse the assignment,
		// name the actions that hold it and let the user take it over.
		const QList<int> conflicts = conflictingRows(dialog.newShortcut, row);
		if (!conflicts.isEmpty()) {
			QStringList usedBy;
			for (int conflictRow : conflicts) {
				QTableWidgetItem *conflictName = tableWidget->item(conflictRow, 0);
				usedBy.append(QStringLiteral("\"%1\"").arg(
						conflictName != nullptr
						? conflictName->text().toHtmlEscaped() : QString()));
			}
			const QString shortcut = QKeySequence(dialog.newShortcut).toString()
					.toHtmlEscaped();
			QMessageBox box(this);
			box.setIcon(QMessageBox::Warning);
			box.setWindowTitle(tr("Shortcut Already Used"));
			if (usedBy.size() == 1) {
				box.setText(tr("The shortcut <b>%1</b> is already used by<br>%2.")
							.arg(shortcut, usedBy.first()));
			} else {
				box.setText(tr("The shortcut <b>%1</b> is already used by:<br>%2")
							.arg(shortcut, usedBy.join(QStringLiteral("<br>"))));
			}
			box.setInformativeText(tr("Overwrite it and assign the shortcut to \"%1\"?")
								   .arg(name.toHtmlEscaped()));
			QPushButton *overwrite = box.addButton(tr("Overwrite"),
												   QMessageBox::AcceptRole);
			QPushButton *cancel = box.addButton(QMessageBox::Cancel);
			box.setDefaultButton(cancel);
			box.exec();
			if (box.clickedButton() != overwrite) {
				return;
			}
			// Take the sequence over: the other actions lose their shortcut
			// right away, exactly as their cleared rows show.
			for (int conflictRow : conflicts) {
				QTableWidgetItem *conflictName = tableWidget->item(conflictRow, 0);
				if (QTableWidgetItem *conflictKey = tableWidget->item(conflictRow, 1)) {
					conflictKey->setText(QString());
				}
				applyShortcut(conflictName != nullptr
							  ? conflictName->text() : QString(), QString());
			}
		}
		keyitem->setText(dialog.newShortcut);
		applyShortcut(name, dialog.newShortcut);
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
