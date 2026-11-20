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

#ifndef PRESETSDIALOG_H
#define PRESETSDIALOG_H

#include <QDialog>
#include <QSet>
#include <QStringList>
#include <QVector>

#include "widgetpreset.h"

class QLabel;
class QLineEdit;
class QPushButton;
class QStackedWidget;
class QTableWidget;
class QTableWidgetItem;
class QTimer;
class WidgetLayout;

// Asks for the name and optional description of a new preset. The name is
// required and must be unique within the current widget layout.
class PresetNameDialog : public QDialog
{
    Q_OBJECT
public:
    explicit PresetNameDialog(QWidget *parent = nullptr);

    void setExistingNames(const QStringList &names);
    QString presetName() const;
    QString description() const;

private:
    void validate();

    QLineEdit *m_nameEdit = nullptr;
    QLineEdit *m_descriptionEdit = nullptr;
    QLabel *m_errorLabel = nullptr;
    QPushButton *m_okButton = nullptr;
    QSet<QString> m_existingNames;
};

// Lists, recalls, updates and deletes the presets of one widget layout.
class PresetsDialog : public QDialog
{
    Q_OBJECT
public:
    explicit PresetsDialog(WidgetLayout *layout, QWidget *parent = nullptr);

private:
    struct DeletedPreset {
        WidgetPreset preset;
        int position = -1;
    };

    void rebuildTable();
    int selectedPresetNumber() const;
    void selectPresetNumber(int number);
    void updateButtons();
    void updateHelpText();
    void setHelpMessage(const QString &message);
    void editCell(int row, int column);
    void addPreset();
    void updateSelectedPreset();
    void recallPreset(int number);
    void deleteSelectedPreset();
    void undoDelete();
    void itemEdited(QTableWidgetItem *item);

    bool eventFilter(QObject *watched, QEvent *event) override;

    WidgetLayout *m_layout = nullptr;
    QLineEdit *m_filterEdit = nullptr;
    QTableWidget *m_table = nullptr;
    QStackedWidget *m_helpStack = nullptr;
    QLabel *m_helpPlainLabel = nullptr;
    QWidget *m_helpKeyWidget = nullptr;
    QWidget *m_helpUndoWidget = nullptr;
    QPushButton *m_updateButton = nullptr;
    QPushButton *m_addButton = nullptr;
    QPushButton *m_cancelButton = nullptr;
    QTimer *m_editTimer = nullptr;
    QVector<DeletedPreset> m_deleted;
    bool m_rebuilding = false;
    bool m_ignorePresetsChanged = false;
    bool m_showUndoHint = false;
    bool m_pressOnSelectedRow = false;
    bool m_suppressNextClick = false;
    int m_pressRow = -1;
    int m_pendingEditRow = -1;
    int m_pendingEditColumn = -1;
};

#endif // PRESETSDIALOG_H
