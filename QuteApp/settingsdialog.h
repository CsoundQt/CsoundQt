/*
    Copyright (C) 2010 Andres Cabrera
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

#ifndef SETTINGSDIALOG_H
#define SETTINGSDIALOG_H

#include <QDialog>
#include <QMultiHash>
#include "csound.hpp"

#include "csoundoptions.h"

namespace Ui {
    class SettingsDialog;
}

class SettingsDialog : public QDialog {
    Q_OBJECT
public:
    SettingsDialog(QWidget *parent, CsoundOptions *options);
    ~SettingsDialog();

    QStringList getFlags();

public slots:
    void refreshAudioIn();
    void refreshAudioOut();
    void refreshMidiIn();
    void refreshMidiOut();
    void refreshMidiControl();

    virtual void accept();

protected:
    void changeEvent(QEvent *e);

private:
    Ui::SettingsDialog *ui;
    Csound *m_csound;
    CsoundOptions *m_options;

    QString runCsound(QStringList args);
    QMultiHash<QString, QString> parsePortAudioIn(QString csOutput);
    QMultiHash<QString, QString> parsePortAudioOut(QString csOutput);
    QMultiHash<QString, QString> parsePortMidiIn(QString csOutput);
    QMultiHash<QString, QString> parsePortMidiOut(QString csOutput);
    QMultiHash<QString, QString> getAlsaMidiIn();
    QMultiHash<QString, QString> getAlsaMidiOut();
    QMultiHash<QString, QString> parseJackAudioIn(QString csOutput);
};

#endif // SETTINGSDIALOG_H
