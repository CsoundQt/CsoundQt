/*
    Copyright (C) 2008, 2009 Andres Cabrera
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

#ifndef CONFIGDIALOG_H
#define CONFIGDIALOG_H

#include "ui_configdialog.h"

class CsoundQt;
class Options;

class ConfigDialog : public QDialog, public Ui::ConfigDialog
{
  Q_OBJECT
  public:
    ConfigDialog(CsoundQt *parent = 0, Options *options = 0);

    ~ConfigDialog();
    int currentTab();
    void setCurrentTab(int index);

  public slots:
    void warnOpcodeDir(bool on);

  private:
    CsoundQt* m_parent;
    Options *m_options;
    void browseFile(QString &destination);
    void browseSaveFile(QString &destination);
    void browseDir(QString &destination);
    QList<QPair<QString, QString> > getMidiInputDevices();
    QList<QPair<QString, QString> > getMidiOutputDevices();
    QList<QPair<QString, QString> > getAudioInputDevices();
    QList<QPair<QString, QString> > getAudioOutputDevices();

  private slots:
    virtual void accept();
    void browseInputFilename();
    void browseOutputFilename();
    void browseCsdocdir();
    void browseOpcodedir();
    void browseOpcodedir64();
    void browseSadir();
    void browseSsdir();
    void browseSfdir();
    void browseIncdir();
//    void browseDefaultCsd();
    void browseFavorite();
    void browsePythonDir();
    void browseLogFile();
    void browseTerminal();
    void browseBrowser();
    void browseDot();
    void browseWaveEditor();
    void browseWavePlayer();
    void browsePdfViewer();
    void selectAudioInput();
    void selectAudioOutput();
    void selectMidiInput();
    void selectMidiOutput();
    void selectTextColor();
    void selectBgColor();

    void clearTemplate();
    void defaultTemplate();

  signals:
//    void changeFont();

};

#endif
