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
  bool useSdk = field("useSdk").toInt() == 1;
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
  QString libDir, opcodeDir, qtLibsDir;
  if (customPaths) {
    libDir =  field("libDir").toString();
    opcodeDir =  field("opcodeDir").toString();
    qtLibsDir = field("qtLibsDir").toString();
  }

  QStringList plugins = this->page(m_pluginsPage)->property("plugins").toStringList();
  QStringList dataFiles = this->page(m_additionalsPage)->property("dataFiles").toStringList();

  if (!QFile::exists(targetDir)) {
    QMessageBox::critical(this, tr("QuteCsound App Creator"),
                          tr("The destination directory does not exist!\n"
                             "Aborting."));
    return;
  }

  qDebug() << "AppWizard::makeApp() " << targetDir;
  if (useSdk) {
    createLinuxApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                   libDir, opcodeDir, qtLibsDir, useDoubles);
    // TODO create two Mac Apps (one for 32 bit plaforms to support PPC)
    createMacApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                 libDir, opcodeDir, qtLibsDir, useDoubles);
    createWinApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                 libDir, opcodeDir, qtLibsDir, useDoubles);
  } else {
    opcodeDir = static_cast<PluginsPage *>(this->page(m_pluginsPage))->getOpcodeDir();
#ifdef Q_OS_LINUX
    createLinuxApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                   libDir, opcodeDir, qtLibsDir, useDoubles);
#endif
#ifdef Q_OS_MAC
    createMacApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                 libDir, opcodeDir, qtLibsDir, useDoubles);
#endif
#ifdef Q_OS_WIN32
    createWinApp(appName, targetDir, dataFiles, plugins, m_sdkDir,
                 libDir, opcodeDir, qtLibsDir, useDoubles);
#endif
  }
  QMessageBox::information(this, tr("Done"), tr("App Creation finished!"));
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

void AppWizard::copyFolder(QString sourceFolder, QString destFolder)
{
  QDir sourceDir(sourceFolder);
  if(!sourceDir.exists()) {
    qDebug() << "AppWizard::copyFolder source dir does not exist";
    return;
  }
  QDir destDir(destFolder);
  if(!destDir.exists()) {
    destDir.mkdir(destFolder);
  }
  QStringList files = sourceDir.entryList();
  for(int i = 0; i< files.count(); i++) {
    QString srcName = sourceFolder + QDir::separator() + files[i];
    QString destName = destFolder + QDir::separator() + files[i];
    QFile::copy(srcName, destName);
  }
  files.clear();
  files = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
  for(int i = 0; i< files.count(); i++) {
    QString srcName = sourceFolder + QDir::separator() + files[i];
    QString destName = destFolder + QDir::separator() + files[i];
    copyFolder(srcName, destName);
  }
}


void AppWizard::createWinApp(QString appName, QString appDir, QStringList dataFiles,
                             QStringList plugins, QString sdkDir,  QString libDir,
                             QString opcodeDir, QString qtLibsDir, bool useDoubles)
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
                             QStringList plugins, QString sdkDir,  QString libDir,
                             QString opcodeDir, QString qtLibsDir, bool useDoubles)
{
  qDebug() << "AppWizard::createMacApp";
  QDir dir(appDir);
  QList<QPair<QString, QString> > copyList;
  if (dir.exists(appName + QDir::separator() + "osx")) {
    int ret = QProcess::execute("rm -fR " + dir.absolutePath() + QDir::separator() + appName + QDir::separator() + "osx");
    qDebug() << "AppWizard::createMacApp deleted directory";
    if (ret != 0) {
      QMessageBox::critical(this, tr("Error"), tr("Could not delete old application directory! Aborted."));
    }
  }
  if (dir.mkpath(appName + QDir::separator() + "osx")) {
    dir.cd(appName + QDir::separator() + "osx");
    // Copy csd and binaries
    if (sdkDir.isEmpty()) {
      if (useDoubles) {
        copyList << QPair<QString, QString>(QCoreApplication::applicationDirPath() + QDir::separator() + "../Resources/QuteApp_d.app",
                                            dir.absolutePath() + QDir::separator() + appName + ".app");
      } else {
        copyList << QPair<QString, QString>(QCoreApplication::applicationDirPath() + QDir::separator() + "../Resources/QuteApp_f.app",
                                            dir.absolutePath() + QDir::separator() + appName + ".app");
      }
    } else {
      if (useDoubles) {
        copyList << QPair<QString, QString>(sdkDir + QDir::separator() + "osx/QuteApp_d.app",
                                            dir.absolutePath() + QDir::separator() + appName + ".app");
      } else {
        copyList << QPair<QString, QString>(sdkDir + QDir::separator() + "osx/QuteApp_f.app",
                                            dir.absolutePath() + QDir::separator() + appName + ".app");
      }
    }
    // Data files
    copyList << QPair<QString, QString>
        (m_csd,
         dir.absolutePath() + QDir::separator() + appName + ".app" + QDir::separator() + "Contents/Resources" + QDir::separator() + "quteapp.csd");

    foreach(QString file, dataFiles) {
      QString destName = dir.absolutePath() + QDir::separator() + appName + ".app" +  QDir::separator() + "Contents/Resources" + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
      if (file.startsWith("/")) { // Absolute path
        copyList << QPair<QString, QString>(file, destName);
      }
      else { // Relative path
        copyList <<  QPair<QString, QString>(m_csd.left(m_csd.lastIndexOf("/")), destName);
      }
    }
    // No need to copy Qt libraries as they should already be deplyed in the QuteApp
    // Copy lib files and plugins only if libDir is not given
    if (!libDir.isEmpty()) {
      QStringList libFiles;
      if (useDoubles) {
        libFiles << "LibCsound64.framework";
      } else {
        libFiles << "LibCsound.framework";
      }
      libFiles << "libportaudio.so" << "libportmidi.so";
      QStringList defaultLibDirs;
      defaultLibDirs << "/usr/lib" << "/usr/local/lib";
      QStringList libSearchDirs;
      libSearchDirs << libDir << defaultLibDirs;
      //FIXME this is not really working yet... You need to use the frameworks and libs inside the QuteApp template bundle.
      qDebug() << "AppWizard::createMacApp Error! libDir not implemented!";
      dir.cd("../Frameworks");
      foreach(QString file, libFiles) {
        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
        for (int i = 0 ; i < libSearchDirs.size(); i++) {
          QString libName = libSearchDirs[i] + QDir::separator() + file;
          if (QFile::exists(libName)) {
            copyList << QPair<QString, QString>(libName,destName);
            break;
          }
        }
      }
    }
    if (!opcodeDir.isEmpty()) {
      foreach(QString file, plugins) {
        QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
        copyList << QPair<QString, QString>(opcodeDir + QDir::separator() + file, destName);
      }
    }
    QList<QPair<QString,QString> >::const_iterator i;
    for (i = copyList.constBegin(); i != copyList.constEnd(); ++i) {
      QFileInfo finfo((*i).first);
      if (finfo.isDir()) {
        copyFolder((*i).first, (*i).second);
        qDebug() << "createMacApp dir copied:" << (*i).first;
      } else {
        if (QFile::copy((*i).first, (*i).second)) {
          qDebug() << "createMacApp copied:" << (*i).first;
        } else {
          qDebug() << "createMacApp error copying: " << (*i).first << (*i).second;
        }
      }
    }
    dir.cdUp();
    QFile f3(dir.absolutePath() + QDir::separator() + "quteapp.csd");
    f3.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
                     | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
                     | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther);
  }
  else {
    QMessageBox::critical(this, tr("QuteCsound App Creator"),
                          tr("Error creating app directory."));
  }
}

void AppWizard::createLinuxApp(QString appName, QString appDir, QStringList dataFiles,
                               QStringList plugins, QString sdkDir, QString libDir,
                               QString opcodeDir, QString qtLibsDir, bool useDoubles)
{
  qDebug() << "AppWizard::createLinuxApp";
  QDir dir(appDir);
  QList<QPair<QString, QString> > copyList;
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
      if (useDoubles) {
        copyList << QPair<QString, QString>(":/res/linux/QuteApp_d",
                                            dir.absolutePath() + QDir::separator() +"lib/QuteApp");
      } else {
        copyList << QPair<QString, QString>(":/res/linux/QuteApp_f",
                                            dir.absolutePath() + QDir::separator() +"lib/QuteApp");
      }
      copyList << QPair<QString, QString>(":/res/linux/launch.sh",
                                          dir.absolutePath() + QDir::separator() + appName + ".sh");
    } else {
      if (useDoubles) {
        copyList << QPair<QString, QString>(sdkDir + QDir::separator() + "linux/lib/QuteApp_d",
                                            dir.absolutePath() + QDir::separator() +"lib/QuteApp");
      } else {
        copyList << QPair<QString, QString>(sdkDir + QDir::separator() + "linux/lib/QuteApp_f",
                                            dir.absolutePath() + QDir::separator() +"lib/QuteApp");
      }
      copyList << QPair<QString, QString>(sdkDir + QDir::separator() + "linux/lib/launch.sh",
                                          dir.absolutePath() + QDir::separator() + appName + ".sh");
    }
    // Data files
    dir.cd("data");
    copyList << QPair<QString, QString>(m_csd,
                                        dir.absolutePath() + QDir::separator() + "quteapp.csd");

    foreach(QString file, dataFiles) {
      QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
      if (file.startsWith("/")) { // Absolute path
        copyList << QPair<QString, QString>(file, destName);
      }
      else { // Relative path
        copyList <<  QPair<QString, QString>(m_csd.left(m_csd.lastIndexOf("/")), destName);
      }
    }
    // Copy lib files and plugins
    QStringList libFiles;
    if (useDoubles) {
        libFiles << "libcsound64.so" << "libcsound64.so.5.2";
    } else {
        libFiles << "libcsound.so" << "libcsound.so.5.2";
    }
    libFiles << "libportaudio.so" << "libportmidi.so";
    QStringList defaultLibDirs;
    defaultLibDirs << "/usr/lib" << "/usr/local/lib";
    QStringList libSearchDirs;
    if (libDir.isEmpty()) {
      libSearchDirs << defaultLibDirs;
    } else {
      libSearchDirs << libDir;
    }

    dir.cd("../lib");
    foreach(QString file, libFiles) {
      QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
      for (int i = 0 ; i < libSearchDirs.size(); i++) {
          QString libName = libSearchDirs[i] + QDir::separator() + file;
          if (QFile::exists(libName)) {
              copyList << QPair<QString, QString>(libName,destName);
              break;
          }
      }
    }
    // Qt Libs
    QStringList qtLibFiles;
    qtLibFiles << "libQtCore.4.so" << "libQtGui.4.so" << "libQtXml.4.so";
    QStringList defaultQtLibDirs;
    defaultQtLibDirs<< "/usr/lib" << "/usr/local/lib";
    QStringList qtLibSearchDirs;
    if (qtLibsDir.isEmpty()) {
      qtLibSearchDirs << defaultQtLibDirs;
    } else {
      qtLibSearchDirs << qtLibsDir;
    }
    foreach(QString file, qtLibFiles) {
      QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
      for (int i = 0 ; i < qtLibSearchDirs.size(); i++) {
          QString libName = qtLibSearchDirs[i] + QDir::separator() + file;
          if (QFile::exists(libName)) {
              copyList << QPair<QString, QString>(libName,destName);
              break;
          }
      }
    }
    foreach(QString file, plugins) {
      QString destName = dir.absolutePath() + QDir::separator() + file.mid(file.lastIndexOf(QDir::separator()) + 1);
      copyList << QPair<QString, QString>(opcodeDir + QDir::separator() + file, destName);
    }
    QList<QPair<QString,QString> >::const_iterator i;
    for (i = copyList.constBegin(); i != copyList.constEnd(); ++i) {
      if (QFile::copy((*i).first, (*i).second)) {
        qDebug() << "createLinuxApp copied:" << (*i).first;
      } else {
        qDebug() << "createLinuxApp error copying: " << (*i).first << (*i).second;
      }
    }
    dir.cdUp();
    QFile f(dir.absolutePath() + QDir::separator() +"lib/QuteApp");
    f.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
                     | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
                     | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther);
    QFile f2(dir.absolutePath() + QDir::separator() + appName + ".sh");
    f2.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
                      | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
                      | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther);
    QFile f3(dir.absolutePath() + QDir::separator() + "quteapp.csd");
    f3.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
                     | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
                     | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther);
  }
  else {
    QMessageBox::critical(this, tr("QuteCsound App Creator"),
                          tr("Error creating app directory."));
  }
}

void AppWizard::getLinuxLibDeps(QString libname)
{
    QProcess ldd;
//    ldd.start("ldd", QStringList() << "-c");
//    if (!ldd.waitForStarted())
//        return false;

//    ldd.write("Qt rocks!");
//    ldd.closeWriteChannel();

//    if (!ldd.waitForFinished())
//        return false;

//    QByteArray result = ldd.readAll();
}
