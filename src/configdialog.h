/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#ifndef CONFIGDIALOG_H
#define CONFIGDIALOG_H

#include "ui_configdialog.h"

class Options;
class ConfigLists;

class ConfigDialog : public QDialog, private Ui::ConfigDialog
{
  Q_OBJECT
  public:
    ConfigDialog(QWidget *parent = 0, Options *options = 0, ConfigLists *m_configlist = 0);

    ~ConfigDialog();
  private:
    Options *m_options;
    void browseFile(QString &destination);
    void browseDir(QString &destination);
  private slots:
    virtual void accept();
    void browseCsdocdir();
    void browseOpcodedir();
    void browseSadir();
    void browseSsdir();
    void browseSfdir();
    void browseIncdir();
    void browseOpcodeXmlDir();
    void browseTerminal();
    void browseBrowser();
    void browseWaveEditor();
    void browseWavePlayer();

  signals:
    void changeFont();

};

#endif
