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

#include <QApplication>
#include <QSplashScreen>
#include "qutecsound.h"

int main(int argc, char *argv[])
{
  QStringList fileNames;

  for (int i = 1; i < argc; i++) {
    QString arg(argv[i]);
    if (arg.endsWith(".orc") or arg.endsWith(".sco") or arg.endsWith(".csd")) {
      fileNames.append(arg);
    }
  }
  Q_INIT_RESOURCE(application);
  QApplication app(argc, argv);

  FileOpenEater *filterObj=new FileOpenEater();
  app.installEventFilter(filterObj);
  QPixmap pixmap(":/images/splashscreen.png");
  QSplashScreen *splash = new QSplashScreen(pixmap, Qt::WindowStaysOnTopHint);
  splash->show();
  splash->raise();
  splash->showMessage("Starting QuteCsound");
  app.processEvents();

  QSettings settings("csound", "qutecsound");
  settings.beginGroup("GUI");
  QString language = settings.value("language", QLocale::system().name()).toString();
  settings.endGroup();

  QTranslator translator;
  translator.load(QString(":/qutecsound_") + language);
//   translator.load(":/qutecsound_es");
  app.installTranslator(&translator);

  qutecsound * mw = new qutecsound(fileNames);
  splash->finish(mw);
  mw->show();
  filterObj->setMainWindow(mw);
  return app.exec();
}

