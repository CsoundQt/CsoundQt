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
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/


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

  QPixmap pixmap(":/qtcs.png");
  QSplashScreen splash(pixmap, Qt::WindowStaysOnTopHint);
  splash.show();
  splash.showMessage("Starting QuteCsound");
  app.processEvents();
  qutecsound * mw = new qutecsound(fileNames);
  splash.finish(mw);
  mw->show();
  return app.exec();
}

