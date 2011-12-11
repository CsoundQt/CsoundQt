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
#include <QProcess>


#include "appwizard.h"
#include "appdetailspage.h"
#include "additionalfilespage.h"
#include "pluginspage.h"


AppWizard::AppWizard(QWidget *parent,QString opcodeDir,
                     QString csd, QString sdkDir) :
  QWizard(parent), m_csd(csd), m_sdkDir(sdkDir)
{
  int appPage = addPage(new AppDetailsPage(this));

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


  m_dataFiles = processDataFiles();
  static_cast<AdditionalFilesPage *>(this->page(m_additionalsPage))->setFiles(m_dataFiles);
//
//  setPixmap(QWizard::BannerPixmap, QPixmap(":/images/banner.png"));
//  setPixmap(QWizard::BackgroundPixmap, QPixmap(":/images/background.png"));
  setWindowTitle(tr("Standalone Application Generator"));
}

void AppWizard::makeApp()
{
  QString appName =  field("appName").toString();
  QString targetDir =  field("targetDir").toString();
  bool forlinux =  field("linux").toBool();
  bool forosx =  field("osx").toBool();
  bool forosx_64 =  field("osx_64").toBool();
  bool forwindows =  field("windows").toBool();
  bool useDoubles = field("useDoubles").toBool();

  bool autorun =  field("autorun").toBool();
  int runMode = field("runMode").toInt();
  bool saveState = field("saveState").toBool();
  bool newParser = field("newParser").toBool();

  QString author = field("author").toString();
  QString version = field("version").toString();
  QString email = field("email").toString();
  QString website = field("website").toString();
  QString instructions = field("instructions").toString();

  bool customPaths =  field("customPaths").toBool();
  QString libDir;
  QString opcodeDir;
  if (customPaths) {
    libDir =  field("libDir").toString();
    opcodeDir =  field("opcodeDir").toString();
  }

  QStringList plugins = this->page(m_pluginsPage)->property("plugins").toStringList();
  QStringList dataFiles = this->page(m_additionalsPage)->property("dataFiles").toStringList();

  if (!QFile::exists(targetDir)) {
    QMessageBox::critical(this, tr("QuteCsound App Creator"),
                          tr("The destination directory does not exist!\n"
                             "Aborting."));
    return;
  }

  if (forlinux) {
    createLinuxApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                   libDir, opcodeDir, useDoubles);
  }
  if (forosx) {
    createMacApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                 libDir, opcodeDir, useDoubles);
  }
  if (forwindows) {
    createWinApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                 libDir, opcodeDir, useDoubles);
  }
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
          if (newDataName.indexOf(QRegExp("\\w\\:")) == 0) { // Absolute path
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
                  QStringList plugins, QString sdkDir,  QString libDir, QString opcodeDir, bool useDoubles)
{
//  QDir dir(appDir);
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
}

void AppWizard::createMacApp(QString appName, QString appDir, QStringList dataFiles,
                  QStringList plugins, QString sdkDir,  QString libDir, QString opcodeDir, bool useDoubles)
{

}

void AppWizard::createLinuxApp(QString appName, QString appDir, QStringList dataFiles,
                    QStringList plugins, QString sdkDir, QString libDir, QString opcodeDir, bool useDoubles)
{
  qDebug() << "AppWizard::createLinuxApp";
  QDir dir(appDir);
  if (dir.exists(appName + QDir::separator() + "linux")) {
    int ret = QProcess::execute("rm -fR " + dir.absolutePath() + QDir::separator() + appName + QDir::separator() + "linux");
    qDebug() << "AppWizard::createLinuxApp deleted directory";
    if (ret != 0) {
      QMessageBox::critical(this, tr("Error"), tr("Could not delete old application directory! Aborted."));
    }
  }
  if (dir.mkpath(appName + QDir::separator() + "linux")) {
    dir.cd(appName + QDir::separator() + "linux");
    // Create directories
    dir.mkdir("lib");
    dir.mkdir("data");
    // Copy csd and binaries
    if (sdkDir.isEmpty()) {
      bool ret;
      if (useDoubles) {
        ret = QFile::copy(":/res/linux/QuteApp_d", dir.absolutePath() + QDir::separator() +"lib/QuteApp");
      } else {
        ret = QFile::copy(":/res/linux/QuteApp_f", dir.absolutePath() + QDir::separator() +"lib/QuteApp");
      }
      ret = ret && QFile::copy(":/res/linux/launch.sh", dir.absolutePath() + QDir::separator() + appName + ".sh");
      if (!ret) {
        QMessageBox::critical(this, tr("Error"), tr("Could not copy Linux QuteApp executable. Aborting."));
        return;
      }
      QFile f(dir.absolutePath() + QDir::separator() +"lib/QuteApp");
      f.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
                       | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
                       | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther);
      QFile f2(dir.absolutePath() + QDir::separator() + appName + ".sh");
      f2.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
                        | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
                        | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther);
    } else {
      if (useDoubles) {
        QFile::copy(sdkDir + QDir::separator() + "linux/lib/QuteApp_d", dir.absolutePath() + QDir::separator() + "lib/QuteApp");
      } else {
        QFile::copy(sdkDir + QDir::separator() + "linux/lib/QuteApp_f", dir.absolutePath() + QDir::separator() + "lib/QuteApp");
      }
      QFile::copy(sdkDir + QDir::separator() + "linux/lib/launch.sh", appName + ".sh");
    }
    dir.cd("data");
    QFile::copy(m_csd, dir.absolutePath() + QDir::separator() + "quteapp.csd");
    QFile f(dir.absolutePath() + QDir::separator() + "quteapp.csd");
    f.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
                     | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
                     | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther);

    // Copy data files
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
    // Copy lib files and plugins
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
