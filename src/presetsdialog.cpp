/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Lesser General Public License for more details.
*/

#include "presetsdialog.h"

#include "widgetlayout.h"

#include <QAbstractItemView>
#include <QApplication>
#include <QDialogButtonBox>
#include <QEvent>
#include <QFormLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QIcon>
#include <QItemSelectionModel>
#include <QLabel>
#include <QLineEdit>
#include <QMenu>
#include <QModelIndex>
#include <QMouseEvent>
#include <QPainter>
#include <QPixmap>
#include <QPushButton>
#include <QShortcut>
#include <QSignalBlocker>
#include <QStackedWidget>
#include <QTableWidget>
#include <QTableWidgetItem>
#include <QTimer>
#include <QVBoxLayout>

#include <algorithm>

using namespace Qt::StringLiterals;

static QIcon plusIcon(const QWidget *widget)
{
    QPixmap pixmap(16, 16);
    pixmap.fill(Qt::transparent);
    QPainter painter(&pixmap);
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.setPen(QPen(widget->palette().color(QPalette::ButtonText), 2));
    painter.drawLine(8, 3, 8, 13);
    painter.drawLine(3, 8, 13, 8);
    return QIcon(pixmap);
}

static QString undoModifierText()
{
#ifdef Q_OS_MACOS
    return u"CMD"_s;
#else
    return u"CTRL"_s;
#endif
}

PresetNameDialog::PresetNameDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(tr("New Preset"));
    resize(500, 170);

    auto *layout = new QVBoxLayout(this);
    auto *form = new QFormLayout;
    form->setFieldGrowthPolicy(QFormLayout::AllNonFixedFieldsGrow);
    m_nameEdit = new QLineEdit(this);
    m_descriptionEdit = new QLineEdit(this);
    m_nameEdit->setFixedWidth(120);
    m_descriptionEdit->setMinimumWidth(300);
    m_nameEdit->setPlaceholderText(tr("Required"));
    m_descriptionEdit->setPlaceholderText(tr("Optional"));
    form->addRow(tr("Name:"), m_nameEdit);
    form->addRow(tr("Description:"), m_descriptionEdit);
    layout->addLayout(form);

    m_errorLabel = new QLabel(this);
    m_errorLabel->setTextFormat(Qt::PlainText);
    m_errorLabel->setStyleSheet(u"color: #c0392b;"_s);
    m_errorLabel->setWordWrap(true);
    layout->addWidget(m_errorLabel);

    auto *buttons = new QDialogButtonBox(
                QDialogButtonBox::Ok | QDialogButtonBox::Cancel, this);
    m_okButton = buttons->button(QDialogButtonBox::Ok);
    layout->addWidget(buttons);

    connect(m_nameEdit, &QLineEdit::textChanged,
            this, &PresetNameDialog::validate);
    connect(buttons, &QDialogButtonBox::accepted, this, &QDialog::accept);
    connect(buttons, &QDialogButtonBox::rejected, this, &QDialog::reject);

    m_nameEdit->setFocus();
    validate();
}

void PresetNameDialog::setExistingNames(const QStringList &names)
{
    m_existingNames.clear();
    for (const QString &name : names)
        m_existingNames.insert(name.trimmed().toLower());
    validate();
}

QString PresetNameDialog::presetName() const
{
    return m_nameEdit->text().trimmed();
}

QString PresetNameDialog::description() const
{
    return m_descriptionEdit->text().trimmed();
}

void PresetNameDialog::validate()
{
    const QString name = presetName();
    QString error;
    if (name.isEmpty()) {
        error = tr("A name is required.");
    } else if (m_existingNames.contains(name.toLower())) {
        error = tr("A preset named \"%1\" already exists.").arg(name);
    }
    m_errorLabel->setText(error);
    m_okButton->setEnabled(error.isEmpty());
}

PresetsDialog::PresetsDialog(WidgetLayout *layout, QWidget *parent)
    : QDialog(parent), m_layout(layout)
{
    setWindowTitle(tr("Presets"));
    resize(780, 460);

    auto *layoutV = new QVBoxLayout(this);

    m_filterEdit = new QLineEdit(this);
    m_filterEdit->setPlaceholderText(tr("Filter presets by name"));
    m_filterEdit->setClearButtonEnabled(true);
    layoutV->addWidget(m_filterEdit);

    m_table = new QTableWidget(this);
    m_table->setColumnCount(3);
    m_table->setHorizontalHeaderLabels(
                {tr("Name"), tr("Index"), tr("Description")});
    m_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);
    m_table->horizontalHeader()->setSectionResizeMode(1,
                                                     QHeaderView::ResizeToContents);
    // Let the Description column absorb the remaining width so the table
    // always reaches the right edge of the dialog.
    m_table->horizontalHeader()->setStretchLastSection(true);
    m_table->setColumnWidth(0, 210);
    m_table->verticalHeader()->setVisible(false);
    m_table->setSelectionBehavior(QAbstractItemView::SelectRows);
    m_table->setSelectionMode(QAbstractItemView::SingleSelection);
    m_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_table->setAlternatingRowColors(true);
    m_table->setContextMenuPolicy(Qt::CustomContextMenu);
    m_table->setToolTip(tr("Double-click a preset to apply it.\n"
                            "Click again on a selected name or description to "
                            "edit it, or press F2."));
    layoutV->addWidget(m_table, 1);

    auto *footer = new QHBoxLayout;
    m_helpStack = new QStackedWidget(this);
    m_helpPlainLabel = new QLabel(m_helpStack);
    m_helpPlainLabel->setTextFormat(Qt::PlainText);
    m_helpPlainLabel->setWordWrap(true);
    m_helpKeyWidget = new QWidget(m_helpStack);
    auto *keyLayout = new QHBoxLayout(m_helpKeyWidget);
    keyLayout->setContentsMargins(0, 0, 0, 0);
    keyLayout->setSpacing(4);

    const QString keyStyle =
            u"QLabel { border: 2px solid %1; border-radius: 5px; "
            u"padding: 2px 2px; background-color: %2; color: %3; "
            u"font-family: monospace; }"_s
            .arg(palette().color(QPalette::Mid).name(),
                 palette().color(QPalette::Button).name(),
                 palette().color(QPalette::ButtonText).name());
    auto *enterKey = new QLabel(tr("Enter"), m_helpKeyWidget);
    enterKey->setStyleSheet(keyStyle);
    enterKey->setAlignment(Qt::AlignCenter);
    enterKey->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
    auto *delKey = new QLabel(tr("Del"), m_helpKeyWidget);
    delKey->setStyleSheet(keyStyle);
    delKey->setAlignment(Qt::AlignCenter);
    delKey->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
    keyLayout->addWidget(enterKey);
    keyLayout->addWidget(new QLabel(tr("-> Recall preset"), m_helpKeyWidget));
    keyLayout->addWidget(new QLabel(tr("|"), m_helpKeyWidget));
    keyLayout->addWidget(delKey);
    keyLayout->addWidget(new QLabel(tr("-> Delete preset"), m_helpKeyWidget));
    keyLayout->addStretch(1);

    m_helpUndoWidget = new QWidget(m_helpStack);
    auto *undoLayout = new QHBoxLayout(m_helpUndoWidget);
    undoLayout->setContentsMargins(0, 0, 0, 0);
    undoLayout->setSpacing(4);
    auto *undoKey = new QLabel(undoModifierText() + u"+Z"_s,
                               m_helpUndoWidget);
    undoKey->setStyleSheet(keyStyle);
    undoKey->setAlignment(Qt::AlignCenter);
    undoKey->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
    undoLayout->addWidget(new QLabel(tr("Press"), m_helpUndoWidget));
    undoLayout->addWidget(undoKey);
    undoLayout->addWidget(new QLabel(tr("to Undo"), m_helpUndoWidget));
    undoLayout->addStretch(1);

    m_helpStack->addWidget(m_helpPlainLabel);
    m_helpStack->addWidget(m_helpKeyWidget);
    m_helpStack->addWidget(m_helpUndoWidget);
    footer->addWidget(m_helpStack, 1);
    m_addButton = new QPushButton(this);
    QIcon addIcon = QIcon::fromTheme(u"list-add"_s);
    if (addIcon.isNull())
        addIcon = QIcon::fromTheme(u"document-new"_s);
    if (addIcon.isNull())
        addIcon = plusIcon(this);
    m_addButton->setIcon(addIcon);
    m_addButton->setAccessibleName(tr("Add preset"));
    m_addButton->setToolTip(tr("Add a preset from the current widget values"));
    m_addButton->setFixedSize(30, 30);
    footer->addWidget(m_addButton, 0, Qt::AlignRight);
    layoutV->addLayout(footer);

    auto *buttons = new QHBoxLayout;
    m_updateButton = new QPushButton(tr("Update"), this);
    m_updateButton->setToolTip(
                tr("Store the current widget values under the selected preset"));
    m_cancelButton = new QPushButton(tr("Close"), this);
    buttons->addWidget(m_updateButton);
    buttons->addStretch();
    buttons->addWidget(m_cancelButton);
    layoutV->addLayout(buttons);

    m_editTimer = new QTimer(this);
    m_editTimer->setSingleShot(true);
    connect(m_editTimer, &QTimer::timeout, this, [this]() {
        const int row = m_pendingEditRow;
        const int column = m_pendingEditColumn;
        m_pendingEditRow = -1;
        m_pendingEditColumn = -1;
        if (row >= 0 && row == m_table->currentRow())
            editCell(row, column);
    });

    auto *deleteShortcut = new QShortcut(QKeySequence::Delete, m_table);
    deleteShortcut->setContext(Qt::WidgetShortcut);
    connect(deleteShortcut, &QShortcut::activated,
            this, &PresetsDialog::deleteSelectedPreset);
    auto *undoShortcut = new QShortcut(QKeySequence::Undo, m_table);
    undoShortcut->setContext(Qt::WidgetShortcut);
    connect(undoShortcut, &QShortcut::activated,
            this, &PresetsDialog::undoDelete);
    auto *returnShortcut = new QShortcut(QKeySequence(Qt::Key_Return), m_table);
    returnShortcut->setContext(Qt::WidgetShortcut);
    connect(returnShortcut, &QShortcut::activated, this, [this]() {
        const int number = selectedPresetNumber();
        if (number >= 0)
            recallPreset(number);
    });
    auto *enterShortcut = new QShortcut(QKeySequence(Qt::Key_Enter), m_table);
    enterShortcut->setContext(Qt::WidgetShortcut);
    connect(enterShortcut, &QShortcut::activated, this, [this]() {
        const int number = selectedPresetNumber();
        if (number >= 0)
            recallPreset(number);
    });
    auto *f2Shortcut = new QShortcut(QKeySequence(Qt::Key_F2), m_table);
    f2Shortcut->setContext(Qt::WidgetShortcut);
    connect(f2Shortcut, &QShortcut::activated, this, [this]() {
        const int row = m_table->currentRow();
        if (row < 0)
            return;
        int column = m_table->currentColumn();
        if (column != 0 && column != 2)
            column = 0;
        m_editTimer->stop();
        editCell(row, column);
    });

    connect(m_filterEdit, &QLineEdit::textChanged,
            this, &PresetsDialog::rebuildTable);
    connect(m_table, &QTableWidget::itemChanged,
            this, &PresetsDialog::itemEdited);
    connect(m_table, &QTableWidget::cellClicked, this,
            [this](int row, int column) {
        m_editTimer->stop();
        m_pendingEditRow = -1;
        m_pendingEditColumn = -1;
        if (m_suppressNextClick) {
            m_suppressNextClick = false;
            return;
        }
        if (!m_pressOnSelectedRow || row != m_pressRow)
            return;
        if (column != 0 && column != 2)
            return;
        m_pendingEditRow = row;
        m_pendingEditColumn = column;
        m_editTimer->start(QApplication::doubleClickInterval());
    });
    connect(m_table, &QTableWidget::cellDoubleClicked, this,
            [this](int row, int) {
        m_editTimer->stop();
        m_pendingEditRow = -1;
        m_pendingEditColumn = -1;
        const QTableWidgetItem *item = m_table->item(row, 0);
        if (item != nullptr)
            recallPreset(item->data(Qt::UserRole).toInt());
    });
    connect(m_table, &QWidget::customContextMenuRequested,
            this, [this](const QPoint &pos) {
        m_editTimer->stop();
        m_pendingEditRow = -1;
        m_pendingEditColumn = -1;
        const QModelIndex index = m_table->indexAt(pos);
        if (!index.isValid())
            return;
        const int row = index.row();
        if (m_table->currentRow() != row)
            m_table->setCurrentCell(row, index.column());
        const int column = index.column() == 2 ? 2 : 0;
        QMenu menu(this);
        QAction *edit = menu.addAction(tr("Edit"));
        connect(edit, &QAction::triggered, this,
                [this, row, column]() { editCell(row, column); });
        menu.exec(m_table->viewport()->mapToGlobal(pos));
    });
    connect(m_table, &QTableWidget::itemSelectionChanged, this, [this]() {
        if (m_rebuilding)
            return;
        m_editTimer->stop();
        m_pendingEditRow = -1;
        m_pendingEditColumn = -1;
        m_showUndoHint = false;
        updateButtons();
        updateHelpText();
    });
    connect(m_updateButton, &QPushButton::clicked,
            this, &PresetsDialog::updateSelectedPreset);
    connect(m_addButton, &QPushButton::clicked,
            this, &PresetsDialog::addPreset);
    connect(m_cancelButton, &QPushButton::clicked, this, &QDialog::reject);
    connect(m_layout, &WidgetLayout::presetsChanged, this, [this]() {
        if (!m_ignorePresetsChanged)
            rebuildTable();
    });

    m_table->viewport()->installEventFilter(this);

    rebuildTable();
    const int current = m_layout->currentPresetNumber();
    if (current >= 0)
        selectPresetNumber(current);
}

bool PresetsDialog::eventFilter(QObject *watched, QEvent *event)
{
    if (watched == m_table->viewport()) {
        if (event->type() == QEvent::MouseButtonPress) {
            auto *mouseEvent = static_cast<QMouseEvent *>(event);
            if (mouseEvent->button() == Qt::LeftButton) {
                m_suppressNextClick = false;
                const QModelIndex index =
                        m_table->indexAt(mouseEvent->position().toPoint());
                m_pressRow = index.row();
                m_pressOnSelectedRow = index.isValid()
                        && m_table->currentRow() == index.row()
                        && m_table->selectionModel()->isRowSelected(
                            index.row(), QModelIndex());
            }
        } else if (event->type() == QEvent::MouseButtonDblClick) {
            m_suppressNextClick = true;
            m_editTimer->stop();
            m_pendingEditRow = -1;
            m_pendingEditColumn = -1;
        }
    }
    return QDialog::eventFilter(watched, event);
}

void PresetsDialog::rebuildTable()
{
    m_editTimer->stop();
    m_pendingEditRow = -1;
    m_pendingEditColumn = -1;

    const int selected = selectedPresetNumber();
    m_rebuilding = true;
    QSignalBlocker blocker(m_table);
    m_table->setRowCount(0);

    QVector<WidgetPreset> presets = m_layout->getPresets();
    std::sort(presets.begin(), presets.end(),
              [](const WidgetPreset &a, const WidgetPreset &b) {
        const int cmp = QString::compare(a.getName(), b.getName(),
                                         Qt::CaseInsensitive);
        return cmp == 0 ? a.getNumber() < b.getNumber() : cmp < 0;
    });

    const QString filter = m_filterEdit->text().trimmed();
    int row = 0;
    for (const WidgetPreset &preset : presets) {
        if (!filter.isEmpty()
                && !preset.getName().contains(filter, Qt::CaseInsensitive)) {
            continue;
        }
        m_table->insertRow(row);

        auto *nameItem = new QTableWidgetItem(preset.getName());
        auto *indexItem = new QTableWidgetItem(QString::number(preset.getNumber()));
        auto *descriptionItem = new QTableWidgetItem(preset.getDescription());

        const Qt::ItemFlags editable = Qt::ItemIsSelectable
                | Qt::ItemIsEnabled | Qt::ItemIsEditable;
        const Qt::ItemFlags readOnly = Qt::ItemIsSelectable | Qt::ItemIsEnabled;
        nameItem->setFlags(editable);
        descriptionItem->setFlags(editable);
        indexItem->setFlags(readOnly);
        for (QTableWidgetItem *item : {nameItem, indexItem, descriptionItem})
            item->setData(Qt::UserRole, preset.getNumber());

        m_table->setItem(row, 0, nameItem);
        m_table->setItem(row, 1, indexItem);
        m_table->setItem(row, 2, descriptionItem);
        ++row;
    }

    m_rebuilding = false;
    blocker.unblock();
    if (selected >= 0)
        selectPresetNumber(selected);
    updateButtons();
    updateHelpText();
}

int PresetsDialog::selectedPresetNumber() const
{
    const int row = m_table->currentRow();
    if (row < 0)
        return -1;
    const QTableWidgetItem *item = m_table->item(row, 0);
    return item != nullptr ? item->data(Qt::UserRole).toInt() : -1;
}

void PresetsDialog::selectPresetNumber(int number)
{
    for (int row = 0; row < m_table->rowCount(); ++row) {
        const QTableWidgetItem *item = m_table->item(row, 0);
        if (item != nullptr
                && item->data(Qt::UserRole).toInt() == number) {
            m_table->setCurrentCell(row, 0);
            m_table->scrollToItem(item);
            return;
        }
    }
}

void PresetsDialog::updateButtons()
{
    m_updateButton->setEnabled(selectedPresetNumber() >= 0);
}

void PresetsDialog::updateHelpText()
{
    if (m_showUndoHint) {
        m_helpStack->setCurrentWidget(m_helpUndoWidget);
        return;
    }
    if (selectedPresetNumber() >= 0) {
        m_helpStack->setCurrentWidget(m_helpKeyWidget);
        return;
    }
    setHelpMessage(tr("Double-click a preset to apply"));
}

void PresetsDialog::setHelpMessage(const QString &message)
{
    m_helpPlainLabel->setText(message);
    m_helpStack->setCurrentWidget(m_helpPlainLabel);
}

void PresetsDialog::editCell(int row, int column)
{
    if (row < 0 || row >= m_table->rowCount())
        return;
    if (column != 0 && column != 2)
        column = 0;
    QTableWidgetItem *item = m_table->item(row, column);
    if (item == nullptr || !(item->flags() & Qt::ItemIsEditable))
        return;
    m_table->setFocus(Qt::OtherFocusReason);
    m_table->setCurrentCell(row, column);
    m_table->editItem(item);
}

void PresetsDialog::addPreset()
{
    QStringList names;
    for (const WidgetPreset &preset : m_layout->getPresets())
        names << preset.getName();

    PresetNameDialog dialog(this);
    dialog.setExistingNames(names);
    if (dialog.exec() != QDialog::Accepted)
        return;

    const int number = m_layout->addPreset(dialog.presetName(),
                                           dialog.description());
    if (number < 0)
        return;
    m_showUndoHint = false;
    rebuildTable();
    selectPresetNumber(number);
    m_table->setFocus(Qt::OtherFocusReason);
    updateHelpText();
}

void PresetsDialog::updateSelectedPreset()
{
    const int number = selectedPresetNumber();
    if (number < 0)
        return;
    m_showUndoHint = false;
    if (m_layout->updatePreset(number)) {
        rebuildTable();
        selectPresetNumber(number);
        m_table->setFocus(Qt::OtherFocusReason);
        updateHelpText();
    }
}

void PresetsDialog::recallPreset(int number)
{
    if (!m_layout->presetExists(number))
        return;
    m_editTimer->stop();
    m_pendingEditRow = -1;
    m_pendingEditColumn = -1;
    m_showUndoHint = false;
    selectPresetNumber(number);
    m_layout->loadPreset(number);
    m_table->setFocus(Qt::OtherFocusReason);
    updateHelpText();
}

void PresetsDialog::deleteSelectedPreset()
{
    const int number = selectedPresetNumber();
    if (number < 0)
        return;

    const QVector<WidgetPreset> presets = m_layout->getPresets();
    int position = -1;
    WidgetPreset preset;
    for (int i = 0; i < presets.size(); ++i) {
        if (presets[i].getNumber() == number) {
            position = i;
            preset = presets[i];
            break;
        }
    }
    if (position < 0)
        return;

    const int removedPosition = m_layout->removePreset(number);
    if (removedPosition < 0)
        return;

    DeletedPreset deleted;
    deleted.preset = preset;
    deleted.position = removedPosition;
    m_deleted.append(deleted);

    rebuildTable();
    m_showUndoHint = true;
    m_table->setFocus(Qt::OtherFocusReason);
    updateHelpText();
}

void PresetsDialog::undoDelete()
{
    if (m_deleted.isEmpty())
        return;

    const DeletedPreset deleted = m_deleted.takeLast();
    const int number = m_layout->restorePreset(deleted.position, deleted.preset);
    if (number < 0)
        return;

    m_showUndoHint = false;
    rebuildTable();
    selectPresetNumber(number);
    m_table->setFocus(Qt::OtherFocusReason);
    updateHelpText();
}

void PresetsDialog::itemEdited(QTableWidgetItem *item)
{
    if (m_rebuilding || item == nullptr)
        return;

    const int number = item->data(Qt::UserRole).toInt();
    if (number < 0)
        return;

    if (item->column() == 0) {
        const QString oldName = m_layout->getPresetName(number);
        const QString newName = item->text().trimmed();
        if (newName == oldName) {
            if (item->text() != newName) {
                QSignalBlocker blocker(m_table);
                item->setText(newName);
            }
            return;
        }

        m_ignorePresetsChanged = true;
        const bool accepted = m_layout->setPresetName(number, newName);
        m_ignorePresetsChanged = false;

        {
            QSignalBlocker blocker(m_table);
            if (accepted)
                item->setText(newName);
            else
                item->setText(oldName);
        }
        if (accepted) {
            // The table is ordered by name; re-sort after the editor has
            // closed instead of rebuilding the rows from inside itemChanged().
            QTimer::singleShot(0, this, &PresetsDialog::rebuildTable);
        } else {
            setHelpMessage(newName.isEmpty()
                           ? tr("A name is required.")
                           : tr("A preset named \"%1\" already exists.")
                             .arg(newName));
        }
    } else if (item->column() == 2) {
        const QString oldDescription = m_layout->getPresetDescription(number);
        const QString newDescription = item->text().trimmed();
        if (newDescription == oldDescription) {
            if (item->text() != newDescription) {
                QSignalBlocker blocker(m_table);
                item->setText(newDescription);
            }
            return;
        }

        m_ignorePresetsChanged = true;
        m_layout->setPresetDescription(number, newDescription);
        m_ignorePresetsChanged = false;

        QSignalBlocker blocker(m_table);
        item->setText(newDescription);
    }
}
