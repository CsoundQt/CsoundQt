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
                     QString csd, QString targetDir) :
    QWizard(parent), m_csd(csd)
{
  int appPage = addPage(new AppDetailsPage(this));
  QString fullPath = m_csd;
  QString appName = fullPath.mid(fullPath.lastIndexOf(QDir::separator()) + 1);
  appName = appName.remove(".csd");
  setField("appName", appName);
  setField("targetDir", targetDir);
  setField("opcodeDir", opcodeDir);
  m_pluginsPage = addPage(new PluginsPage(this, field("opcodeDir").toString()));
  m_additionalsPage = addPage(new AdditionalFilesPage(this));
//  static_cast<PluginsPage *>(this->page(m_pluginsPage))->
  connect(static_cast<AppDetailsPage *>(this->page(appPage)), SIGNAL(opcodeDirChangedSignal()),
          static_cast<PluginsPage *>(this->page(m_pluginsPage)), SLOT(updateOpcodeDir()));
  connect(static_cast<AppDetailsPage *>(this->page(appPage)), SIGNAL(platformChangedSignal()),
          static_cast<PluginsPage *>(this->page(m_pluginsPage)), SLOT(updateOpcodeDir()));
  connect(static_cast<AppDetailsPage *>(this->page(appPage)), SIGNAL(libDirChangedSignal()),
          static_cast<PluginsPage *>(this->page(m_pluginsPage)), SLOT(updateOpcodeDir()));
  QString libDir;
#ifdef Q_OS_LINUX
  setField("platform", 0);
  setField("libDir", "/usr/local/lib");
  if (opcodeDir.isEmpty()) {
    setField("opcodeDir", "/usr/local/lib/csound/plugins");
  }
#endif
#ifdef Q_OS_SOLARIS
  setField("libDir", "/usr/lib");
  if (opcodeDir.isEmpty()) {
    setField("opcodeDir", "/usr/local/lib/csound/plugins");
  }
#endif
#ifdef Q_OS_WIN32
  setField("platform", 2);
  setField("libDir", "");
  if (opcodeDir.isEmpty()) {
    setField("opcodeDir", "");
  }
#endif
#ifdef Q_OS_MAC
  setField("platform", 1);
  setField("libDir", "/Library/Frameworks");
#endif
  m_dataFiles = processDataFiles();
  static_cast<AdditionalFilesPage *>(this->page(m_additionalsPage))->setFiles(m_dataFiles);
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
  int platform =  field("platform").toInt();
  bool useDoubles = field("useDoubles").toBool();
  QString libDir =  field("libDir").toString();
  QString opcodeDir =  field("opcodeDir").toString();
  QStringList plugins = this->page(m_pluginsPage)->property("plugins").toStringList();
  QStringList dataFiles = this->page(m_additionalsPage)->property("dataFiles").toStringList();
  switch (platform) {
  case 0:
    createLinuxApp(appName, targetDir, dataFiles, plugins, libDir, opcodeDir, useDoubles);
    break;
  case 1:
    createMacApp(appName, targetDir, dataFiles, plugins, libDir, useDoubles);
    break;
  case 2:
    createWinApp(appName, targetDir, dataFiles, plugins, libDir, opcodeDir, useDoubles);

  }

  QDialog::accept();
}

QStringList AppWizard::processDataFiles()
{
  QFile csdFile(m_csd);
  if (!csdFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
    return QStringList();
  }
  QStringList list;
  QTextStream in(&csdFile);
  while (!in.atEnd()) {
    QString line = in.readLine();
    if (line.count("\"") == 2) {
      int startIndex = line.indexOf("\"");
      if ((line.contains(";") && (line.indexOf(";") > startIndex)) ||
          !line.contains(";")) { // Quotes are not part of a comment
        if (!line.contains("outvalue") && !line.contains("invalue") &&
            !line.contains("if") && !line.contains("=") &&
            !line.contains("elseif") && !line.contains("=") ) { // exclude opcodes which use strings which are not filenames
          int endIndex = line.lastIndexOf("\"");
          QString dataName = line.mid(startIndex + 1, endIndex-startIndex - 1);
          QString newDataName = dataName;
#ifdef Q_OS_WIN32
          if (newDataName.startsWith(QRegExp("\w\:"))) { // Absolute path
#else
          if (newDataName.startsWith("/")) { // Absolute path
#endif
            newDataName = "data/" + newDataName.right(newDataName.lastIndexOf("/") + 1);
          }
          else {
            newDataName += "data/";
          }
          list << dataName;
          line.replace(dataName,newDataName);
        }
      }
    }
    m_fullText += line + "\n";
    if (line.trimmed().startsWith("</CsoundSynthesizer>")) {
      break;
    }
  }
  return list;
}

void AppWizard::createWinApp(QString appName, QString appDir, QStringList dataFiles,
                  QStringList plugins, QString libDir, QString opcodeDir, bool useDoubles)
{
//  QDir dir(appDir);
//  if (dir.exists()) {
//    if (QDir(appDir + QDir::separator() + appName).exists()) {
//      QMessageBox::critical(this, tr("QuteCsound App Creator"),
//                            tr("Destination directory exists. Please delete."));
//      return;
//    }
//    if (dir.mkdir(appName)) {
//      dir.cd(appName);
//      dir.mkdir("lib");
//      dir.mkdir("data");
//      dir.cd("data");
//      QMessageBox::critical(this, tr("QuteCsound App Creator"),
//                            tr("Plugins:") + dataFiles.join("\n"));
//      foreach(QString file, dataFiles) {
//        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
//        QFile::copy(file, destName);
//        qDebug() << "createWinApp " << destName;
//      }
//      dir.cd("../lib");
//      foreach(QString file, plugins) {
//        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
//        QFile::copy(file, destName);
//        qDebug() << "createWinApp " << destName;
//      }
//    }
//    else {
//      QMessageBox::critical(this, tr("QuteCsound App Creator"),
//                            tr("Error creating app directory."));
//    }
//  }
//  else {
//    QMessageBox::critical(this, tr("QuteCsound App Creator"),
//                          tr("The destination directory does not exist!\n"
//                             "Aborting."));
//  }
}

void AppWizard::createMacApp(QString appName, QString appDir, QStringList dataFiles,
                  QStringList plugins, QString libDir, bool useDoubles)
{

}

void AppWizard::createLinuxApp(QString appName, QString appDir, QStringList dataFiles,
                    QStringList plugins, QString libDir, QString opcodeDir, bool useDoubles)
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
        if (file.startsWith("/")) { // Absolute path
          QFile::copy(file, destName);
        }
        else { // Relative path
          QFile::copy(m_csd.left(m_csd.lastIndexOf("/")), destName);
        }
        qDebug() << "createLinuxApp data:" << destName;
      }
      dir.cd("../lib");
      QStringList libFiles;
//      libFiles << "libportaudio.so" << "libportmidi.so";
      libFiles << "libcsound.so" << "libcsound.so.5.2";
      foreach(QString file, libFiles) {
        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
        QFile::copy(libDir + QDir::separator() + file, destName);
        qDebug() << "createLinuxApp " << destName << libDir + QDir::separator() + file;
      }
      foreach(QString file, plugins) {
        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
        QFile::copy(opcodeDir + QDir::separator() + file, destName);
        qDebug() << "createLinuxApp " << destName << opcodeDir + QDir::separator() + file ;
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
