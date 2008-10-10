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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/


#include <QApplication>
#include "qutecsound.h"

int main(int argc, char *argv[])
{
  QString fileName;

  if (argc > 1)
    fileName = QString(argv[1]);
#ifdef MACOSX
  if (fileName.startsWith("-psn_"))
	fileName = "";
#endif
  qDebug("Opening %s", fileName.toStdString().c_str());
  Q_INIT_RESOURCE(application);
  QApplication app(argc, argv);
  qutecsound * mw = new qutecsound(fileName);
  mw->show();
  return app.exec();
}

