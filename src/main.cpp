/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
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
	QApplication app(argc, argv);
	QStringList args = app.arguments();
	args.removeAt(0); // Remove program name
	foreach (QString arg, args) {
		if (!arg.startsWith("-p")) {// avoid OS X arguments
			fileNames.append(arg);
		}
	}

	FileOpenEater filterObj;
	app.installEventFilter(&filterObj);
	QPixmap pixmap(":/images/splashscreen.png");
	QSplashScreen *splash = new QSplashScreen(pixmap);
	splash->showMessage(QString("Version %1").arg(QCS_VERSION), Qt::AlignCenter | Qt::AlignBottom, Qt::white);
	splash->show();
	splash->raise();
	app.processEvents();

	QSettings settings("csound", "qutecsound");
	settings.beginGroup("GUI");
	QString language = settings.value("language", QLocale::system().name()).toString();
	settings.endGroup();

	QTranslator translator;
	translator.load(QString(":/translations/qutecsound_") + language);
	app.installTranslator(&translator);

	CsoundQt * mw = new CsoundQt(fileNames);
	splash->finish(mw);
	delete splash;
	mw->show();
	filterObj.setMainWindow(mw);
	return app.exec();
}
