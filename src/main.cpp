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
#ifdef QCS_HTML5
#include "include/cef_base.h"
#include "cefclient.h"
#include "client_app.h"
#include "client_handler.h"
#endif

#ifdef WIN32
#include <tchar.h>
#include <windows.h>

namespace {

typedef BOOL (WINAPI *LPFN_ISWOW64PROCESS) (HANDLE, PBOOL);
LPFN_ISWOW64PROCESS fnIsWow64Process;

}  // namespace

// Detect whether the operating system is a 64-bit.
// http://msdn.microsoft.com/en-us/library/windows/desktop/ms684139%28v=vs.85%29.aspx
BOOL IsWow64() {
  BOOL bIsWow64 = FALSE;
  fnIsWow64Process = (LPFN_ISWOW64PROCESS) GetProcAddress(
      GetModuleHandle(TEXT("kernel32")),
      "IsWow64Process");
  if (NULL != fnIsWow64Process) {
    if (!fnIsWow64Process(GetCurrentProcess(), &bIsWow64)) {
      // handle error
    }
  }
  return bIsWow64;
}
#endif

int main(int argc, char *argv[])
{
    int result = 0;
#ifdef QCS_HTML5
#ifdef WIN32
    HINSTANCE moduleHandle = (HINSTANCE) GetModuleHandle(NULL);
    CefMainArgs main_args(moduleHandle);
#else
    CefMainArgs main_args(argc, argv);
#endif
    CefRefPtr<ClientApp> app(new ClientApp);
    result = CefExecuteProcess(main_args, app.get(), 0);
    if (result >= 0) {
        return result;
    }
    CefSettings settings;
    settings.multi_threaded_message_loop = true;
    // Currently we run in a single process, otherwise Csound is not
    // available to the ClientApp class. This may have to be changed.
    settings.single_process = true;
    CefString(&settings.cache_path).FromASCII(QDir::tempPath().toLocal8Bit());
    CefInitialize(main_args, settings, app.get(), 0);
    CefRefPtr<ClientHandler> g_handler(new ClientHandler());
    // Load flash system plug-in on Windows.
#ifdef WIN32
    CefLoadPlugins(IsWow64());
#endif
#endif
    QStringList fileNames;
    QApplication qapp(argc, argv);
    QStringList args = qapp.arguments();
	args.removeAt(0); // Remove program name
	foreach (QString arg, args) {
		if (!arg.startsWith("-p")) {// avoid OS X arguments
			fileNames.append(arg);
		}
	}
	FileOpenEater filterObj;
    qapp.installEventFilter(&filterObj);
	QPixmap pixmap(":/images/splashscreen.png");
	QSplashScreen *splash = new QSplashScreen(pixmap);
	splash->showMessage(QString("Version %1").arg(QCS_VERSION), Qt::AlignCenter | Qt::AlignBottom, Qt::white);
	splash->show();
	splash->raise();
    qapp.processEvents();
    QSettings qsettings("csound", "qutecsound");
    qsettings.beginGroup("GUI");
    QString language = qsettings.value("language", QLocale::system().name()).toString();
    qsettings.endGroup();
	QTranslator translator;
	translator.load(QString(":/translations/qutecsound_") + language);
    qapp.installTranslator(&translator);
    CsoundQt *csoundQt = new CsoundQt(fileNames);
    splash->finish(csoundQt);
	delete splash;
#ifdef QCS_HTML5
    app->setMainWindow(csoundQt);
#endif
    csoundQt->show();
    filterObj.setMainWindow(csoundQt);
    result = qapp.exec();
#ifdef QCS_HTML5
    CefQuit();
#endif
    return result;
}
