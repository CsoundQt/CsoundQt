/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.             *
 ***************************************************************************/
#ifndef CONFIGDIALOG_H
#define CONFIGDIALOG_H

#include "ui_configdialog.h"

class qutecsound;
class Options;
// class ConfigLists;

class ConfigDialog : public QDialog, private Ui::ConfigDialog
{
  Q_OBJECT
  public:
    ConfigDialog(qutecsound *parent = 0, Options *options = 0/*, ConfigLists *configlists = 0*/);

    ~ConfigDialog();


  private:
    qutecsound* m_parent;
    Options *m_options;
//     ConfigLists *m_configlists;
    void browseFile(QString &destination);
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
    void browseSadir();
    void browseSsdir();
    void browseSfdir();
    void browseIncdir();
    void browseDefaultCsd();
    void browseTerminal();
    void browseBrowser();
    void browseDot();
    void browseWaveEditor();
    void browseWavePlayer();
    void selectAudioInput();
    void selectAudioOutput();
    void selectMidiInput();
    void selectMidiOutput();

  signals:
    void changeFont();

};

#endif
