/*
    Copyright (C) 2009 Andres Cabrera
    mantaraya36@gmail.com

    This file is part of QuteCsound.

    QuteCsound is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    QuteCsound is distributed in the hope that it will be useful,
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

KeyboardShortcuts::KeyboardShortcuts(QWidget *parent, const QVector<QAction *> keyActions)
  : QDialog(parent), m_keyActions(keyActions)
{
  setupUi(this);
  setWindowTitle(tr("Keyboard Shortcuts"));
  for (int i = 0; i < m_keyActions.size(); i++) {
    registerAction(m_keyActions[i]);
  }
  tableWidget->setColumnWidth(0, 320);
  tableWidget->setColumnWidth(1, 170);
//   QDialog::setSizePolicy(QSizePolicy(QSizePolicy::Fixed,QSizePolicy::Fixed));
  connect(restorePushButton, SIGNAL(released()), this, SLOT(restoreDefaults()));
  connect(tableWidget, SIGNAL(cellClicked(int, int)), this, SLOT(assignShortcut(int, int)));
}

KeyboardShortcuts::~KeyboardShortcuts()
{
}

void KeyboardShortcuts::registerAction(QAction *action)
{
  int newRow = tableWidget->rowCount();
  tableWidget->insertRow(newRow);
  QTableWidgetItem *name = new QTableWidgetItem(action->text().remove("&"));
  name->setFlags(Qt::ItemIsEnabled);
  tableWidget->setItem(newRow, 0, name);
  QTableWidgetItem *key = new QTableWidgetItem(action->shortcut().toString());
  key->setFlags(Qt::ItemIsEnabled);
  tableWidget->setItem(newRow, 1, key);
}

void KeyboardShortcuts::refreshTable()
{
  for (int i = 0; i < m_keyActions.size(); i++) {
    QTableWidgetItem *name = tableWidget->item(i, 0);
    QTableWidgetItem *key = tableWidget->item(i, 1);
    name->setText(m_keyActions[i]->text().remove("&"));
    key->setText(m_keyActions[i]->shortcut().toString());
  }
}

bool KeyboardShortcuts::shortcutTaken(QString shortcut)
{
  for (int i = 0; i < m_keyActions.size(); i++) {
    if (m_keyActions[i]->shortcut().toString() == shortcut)
      return true;
  }
  return false;
}

void KeyboardShortcuts::restoreDefaults()
{
  emit restoreDefaultShortcuts();
  QDialog::reject();
}

void KeyboardShortcuts::assignShortcut(int row, int /*column*/)
{
  QAction *action = m_keyActions[row];
  KeySelector dialog(this, action->text().remove("&"),action->shortcut());
  if (dialog.exec() == QDialog::Accepted) {
    if (dialog.newShortcut == "")
      return;
    if (shortcutTaken(dialog.newShortcut)) {
      QMessageBox::warning(this, tr("Invalid shortcut"),
                            tr("Shortcut cannot be assigned.\nIt is already used."),
                                QMessageBox::Ok,
                                QMessageBox::Ok);
      return;
    }
    m_keyActions[row]->setShortcut(dialog.newShortcut);
    refreshTable();
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
  newLabel->setText("");
}

KeySelector::~KeySelector()
{
}

void KeySelector::keyPressEvent(QKeyEvent *event)
{
  int key = event->key();
  int modifiers = event->modifiers();
//   qDebug() << key << "         " << modifiers;
  if (key == 16777248 || key == 16777249 || key == 16777249 || key == 16777250 || key == 16777251)
    return; // Only a modifier was pressed
  QString keyName;
  if (modifiers != 0)
    keyName += QKeySequence(modifiers).toString();
  keyName += QKeySequence(key).toString();
  newLabel->setText(keyName);
  newShortcut = keyName;
}
