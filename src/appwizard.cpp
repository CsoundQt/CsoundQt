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

#include <QCheckBox>
#include <QGroupBox>
#include <QLabel>
#include <QLineEdit>
#include <QRadioButton>
#include <QVBoxLayout>
#include <QGridLayout>
#include <QListWidget>
#include <QDir>
#include <QFile>
#include <QMessageBox>
#include <QDebug>


#include "appwizard.h"
#include "appdetailspage.h"
#include "additionalfilespage.h"
#include "pluginspage.h"


AppWizard::AppWizard(QWidget *parent,QString opcodeDir,
                     QString appName, QString targetDir) :
    QWizard(parent)
{
  addPage(new AppDetailsPage);
  addPage(new PluginsPage(this, opcodeDir));
  addPage(new AdditionalFilesPage(this));
  setField("appName", appName);
  setField("targetDir", targetDir);
//
//  setPixmap(QWizard::BannerPixmap, QPixmap(":/images/banner.png"));
//  setPixmap(QWizard::BackgroundPixmap, QPixmap(":/images/background.png"));

  setWindowTitle(tr("Standalone Application Generator"));
}

void AppWizard::accept()
{
  QString appName =  field("appName").toString();
  QString targetDir =  field("targetDir").toString();
  bool autorun =  field("autorun").toBool();
  int platform =  field("platform").toBool();
  bool useDoubles = field("useDoubles").toBool();
  QStringList plugins = field("plugins").toStringList();
  QStringList dataFiles = field("dataFiles").toStringList();
  QString sdkDir;
  switch (platform) {
  case 0:
    sdkDir =  field("linuxSdkDir").toString();
    createLinuxApp(appName, targetDir, dataFiles, plugins, sdkDir, useDoubles);
    break;
  case 1:
    sdkDir =  field("macSdkDir").toString();
    createMacApp(appName, targetDir, dataFiles, plugins, sdkDir, useDoubles);
    break;
  case 2:
    sdkDir =  field("winSdkDir").toString();
    createWinApp(appName, targetDir, dataFiles, plugins, sdkDir, useDoubles);

  }

  QDialog::accept();
}


void AppWizard::createWinApp(QString appName, QString appDir, QStringList dataFiles,
                  QStringList plugins, QString sdkDir, bool useDoubles)
{
  QDir dir(appDir);
  if (dir.exists()) {
    if (QDir(appDir + QDir::separator() + appName).exists()) {
      QMessageBox::critical(this, tr("QuteCsound App Creator"),
                            tr("Destination directory exists. Please delete."));
      return;
    }
    if (dir.mkdir(appName)) {
      dir.cd(appName);
      dir.mkdir("lib");
      dir.mkdir("data");
      dir.cd("data");
      foreach(QString file, dataFiles) {
        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
        QFile::copy(file, destName);
        qDebug() << "createWinApp " << destName;
      }
    }
    else {
      QMessageBox::critical(this, tr("QuteCsound App Creator"),
                            tr("Error creating app directory."));
    }
  }
  else {
    QMessageBox::critical(this, tr("QuteCsound App Creator"),
                          tr("The destination directory does not exist!\n"
                             "Aborting."));
  }
}

void AppWizard::createMacApp(QString appName, QString appDir, QStringList dataFiles,
                  QStringList plugins, QString sdkDir, bool useDoubles)
{

}
void AppWizard::createLinuxApp(QString appName, QString appDir, QStringList dataFiles,
                    QStringList plugins, QString sdkDir, bool useDoubles)
{
  qDebug() << "AppWizard::createLinuxApp";
  QDir dir(appDir);
  if (dir.exists()) {
    if (QDir(appDir + QDir::separator() + appName).exists()) {
      QMessageBox::critical(this, tr("QuteCsound App Creator"),
                            tr("Destination directory exists. Please remove."));
      return;
    }
    if (dir.mkdir(appName)) {
      dir.cd(appName);
      dir.mkdir("lib");
      dir.mkdir("data");
      dir.cd("data");
      foreach(QString file, dataFiles) {
        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
        QFile::copy(file, destName);
        qDebug() << "createLinuxApp " << destName;
      }
      dir.cd("../lib");
      QStringList libFiles;
//      libFiles << "libportaudio.so" << "libportmidi.so";
      libFiles << "libcsound.so" << "libcsound.so.5.2";
      foreach(QString file, dataFiles) {
        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
        QFile::copy(file, destName);
        qDebug() << "createLinuxApp " << destName;
      }
    }
    else {
      QMessageBox::critical(this, tr("QuteCsound App Creator"),
                            tr("Error creating app directory."));
    }
  }
  else {
    QMessageBox::critical(this, tr("QuteCsound App Creator"),
                          tr("The destination directory does not exist!\n"
                             "Aborting."));
  }

}
