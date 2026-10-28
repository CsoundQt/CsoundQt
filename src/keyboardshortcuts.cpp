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

KeyboardShortcutsWidget::KeyboardShortcutsWidget(QWidget *parent,
												 const QVector<QAction *> keyActions,
												 const QHash<QAction *, QKeySequence> &defaultShortcuts)
	: QWidget(parent), m_keyActions(keyActions), m_defaultShortcuts(defaultShortcuts)
{
    m_modified = false;
	setupUi(this);
	// The row number says nothing: the action name is the identity here.
	tableWidget->verticalHeader()->setVisible(false);
	// The .ui leaves the header texts empty, and Qt then numbers the columns.
	tableWidget->setHorizontalHeaderLabels(QStringList{
			tr("Action"), tr("Shortcut")});
	connect(restorePushButton, SIGNAL(released()), this, SLOT(restoreDefaults()));
	connect(tableWidget, SIGNAL(cellClicked(int, int)), this, SLOT(assignShortcut(int, int)));
	// Incremental filter: hide rows that match neither action nor shortcut text,
	// cf. QuteWidget::showAvailableProperties()
	connect(filterLineEdit, &QLineEdit::textChanged, this, &KeyboardShortcutsWidget::filterTable);
	refreshTable();
}

void KeyboardShortcutsWidget::refreshTable()
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
		formatShortcutItem(i, m_keyActions[i]);
	}
    tableWidget->sortItems(0);
	filterTable(filterLineEdit->text());
}

void KeyboardShortcutsWidget::filterTable(const QString &filter)
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
QList<int> KeyboardShortcutsWidget::conflictingRows(const QString &shortcut,
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
void KeyboardShortcutsWidget::applyShortcut(const QString &actionName,
									  const QString &shortcut)
{
	for (QAction *action : m_keyActions) {
		if (shortcutName(action) == actionName) {
			action->setShortcut(QKeySequence(shortcut));
			return;
		}
	}
}

// Rows are sorted by the action name, so the row index says nothing about the
// order of m_keyActions.
QAction *KeyboardShortcutsWidget::actionForRow(int row) const
{
	QTableWidgetItem *nameItem = tableWidget->item(row, 0);
	if (nameItem == nullptr)
		return nullptr;
	const QString name = nameItem->text();
	for (QAction *action : m_keyActions) {
		if (shortcutName(action) == name)
			return action;
	}
	return nullptr;
}

void KeyboardShortcutsWidget::formatShortcutItem(int row, QAction *action)
{
	QTableWidgetItem *item = tableWidget->item(row, 1);
	if (item == nullptr)
		return;
	const bool hasDefault = action != nullptr && m_defaultShortcuts.contains(action);
	const QKeySequence defaultShortcut = hasDefault
			? m_defaultShortcuts.value(action) : QKeySequence();
	// A shortcut that differs from its built-in assignment is shown in bold,
	// with the default at hand in a tooltip.
	const bool modified = hasDefault && action->shortcut() != defaultShortcut;
	QFont font = item->font();
	font.setBold(modified);
	item->setFont(font);
	item->setToolTip(modified
			? tr("Default: %1").arg(defaultShortcut.isEmpty()
									? tr("None") : defaultShortcut.toString())
			: QString());
}

void KeyboardShortcutsWidget::restoreDefaults()
{
	emit restoreDefaultShortcuts();  // To have the main application restore the default shortcuts in the m_keyActions pointer
	// Defaults are new values too, and must be stored when the dialog closes.
	m_modified = true;
	refreshTable();
}

void KeyboardShortcutsWidget::assignShortcut(int row, int /*column*/)
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
	// A shortcut that differs from its default offers the default (and a way
	// back to it) in the key selector.
	QAction *action = actionForRow(row);
	const bool hasDefault = action != nullptr && m_defaultShortcuts.contains(action);
	const QKeySequence defaultShortcut = hasDefault
			? m_defaultShortcuts.value(action) : QKeySequence();
	KeySelector dialog(this, name, key, defaultShortcut, hasDefault);
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
				formatShortcutItem(conflictRow, actionForRow(conflictRow));
			}
		}
		keyitem->setText(dialog.newShortcut);
		applyShortcut(name, dialog.newShortcut);
		formatShortcutItem(row, action);
        m_modified = true;
		//    refreshTable();
	}
}

/* ---------------------------------------------------*/

KeySelector::KeySelector(QWidget *parent, const QString &command,
						 const QString &currentShortcut,
						 const QKeySequence &defaultShortcut, bool hasDefault)
	: QDialog(parent), m_defaultShortcut(defaultShortcut)
{
	setupUi(this);
	setWindowTitle(tr("Press Key Combination"));
	commandLabel->setText(command);
	currentLabel->setText(currentShortcut != "" ? currentShortcut: tr("None"));
	// QKeySequenceEdit supports multi-chord sequences (e.g. "Ctrl+T, E").
	keySequenceEdit->setKeySequence(QKeySequence(currentShortcut));
	keySequenceEdit->setFocus();
	// Escape is used to dismiss the dialog, so it must never become part of
	// the shortcut; the editor would record it like any other key.
	keySequenceEdit->installEventFilter(this);
	// The default is only worth a line of its own when the action deviates
	// from it; restoring writes the default and closes the dialog at once.
	const bool modified = hasDefault
			&& QKeySequence(currentShortcut) != defaultShortcut;
	if (modified) {
		defaultLabel->setText(defaultShortcut.isEmpty()
							  ? tr("None") : defaultShortcut.toString());
		connect(restoreButton, &QPushButton::clicked, this, [this]() {
			keySequenceEdit->setKeySequence(m_defaultShortcut);
			accept();
		});
	} else {
		defaultCaptionLabel->hide();
		defaultLabel->hide();
		restoreButton->hide();
	}
}

KeySelector::~KeySelector()
{
}

bool KeySelector::eventFilter(QObject *watched, QEvent *event)
{
	if (watched == keySequenceEdit && event->type() == QEvent::KeyPress) {
		auto *keyEvent = static_cast<QKeyEvent *>(event);
		// Escape is a dialog key, not a shortcut key: with modifiers or in the
		// middle of a sequence it still means "close without assigning".
		if (keyEvent->key() == Qt::Key_Escape) {
			reject();
			return true;
		}
	}
	return QDialog::eventFilter(watched, event);
}

void KeySelector::accept()
{
	const QKeySequence sequence = keySequenceEdit->keySequence();
	// Belt and braces for a sequence that got in another way (set by code):
	// a shortcut containing Escape is never accepted.
	for (int i = 0; i < sequence.count(); ++i) {
		if (sequence[i].key() == Qt::Key_Escape) {
			reject();
			return;
		}
	}
	newShortcut = sequence.toString();
	QDialog::accept();
}
