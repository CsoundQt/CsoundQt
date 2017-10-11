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
#include <QLocalSocket>
#ifdef QCS_HTML5
#include "include/cef_base.h"
#ifdef WIN32
#include "include/cef_sandbox_win.h"
#endif
#include "cefclient.h"
#include "client_app.h"
#include "client_handler.h"
#include "csoundhtmlview.h"
#include <cstdlib>
#include <exception>
#include <QWaitCondition>

QMutex mutex;
QWaitCondition wait_for_browsers_to_close;
#endif

#ifdef WIN32
#include <tchar.h>
#include <windows.h>

namespace {

typedef BOOL (WINAPI *LPFN_ISWOW64PROCESS) (HANDLE, PBOOL);
LPFN_ISWOW64PROCESS fnIsWow64Process;

}  // namespace

#ifdef QCS_HTML5

class shutdown_exception : public std::exception
{
  virtual const char* what() const throw()
  {
    return "Forcing shutdown.";
  }
} shutdown_exception_;

#endif

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
    try {
#endif
        QStringList fileNames;
        QApplication qapp(argc, argv);
#ifdef Q_OS_OSX
       if (csoundGetVersion()<6090) { // this build does not work with older Csound on OSX
           qDebug()<<"Csound version too old: "<< VERSION;
           QMessageBox::warning(NULL, QObject::tr("Csound version mismatch"), QObject::tr("This version of CsoundQt requires Csound 6.09 or newer. Please download it from <br>") +"<a href=http://csound.github.io/download>http://csound.github.io/download</a>" );
           return(0);
       }
#endif
        QStringList args = qapp.arguments();
        args.removeAt(0); // Remove program name
        foreach (QString arg, args) {
            if (!arg.startsWith("-p")) {// avoid OS X arguments
                fileNames.append(arg);
            }
        }
        // check if another instance is already running. If yes, ask it to open the file in new tab and quit
        QLocalSocket * socket = new QLocalSocket();
        socket->connectToServer("csoundqt");
        if (socket->waitForConnected(500)) { // wait for max 0.5 seconds, returns true if the server in other instance is listening
            if (!fileNames.isEmpty()) {
                qDebug()<<"Opening file(s) in already running instance";
                QString message = "open ***" + fileNames.join("***"); // use a separator that is probably not in the file name
                socket->write(message.toLocal8Bit());
                socket->waitForBytesWritten(1000);
                socket->close();
                return 0; // exit and leave the other instance open the file
            } else {
                socket->close();
                //qDebug()<<"Another instance already running.";
                int answer = QMessageBox::warning(NULL, QObject::tr("CsoundQt"), QObject::tr("Another instance is already running. Are you sure you want to open a new window?"),  QMessageBox::Open|QMessageBox::Cancel, QMessageBox::Cancel);
                if (answer==QMessageBox::Cancel) {
                    return 0;
                }
            }
        }
#ifdef QCS_HTML5
        void* sandbox_info = 0;
#ifdef WIN32
#if defined(CEF_USE_SANDBOX)
        // Manage the life span of the sandbox information object. This is necessary
        // for sandbox support on Windows. See cef_sandbox_win.h for complete details.
        CefScopedSandboxInfo scoped_sandbox;
        sandbox_info = scoped_sandbox.sandbox_info();
#endif
        HINSTANCE moduleHandle = (HINSTANCE) GetModuleHandle(NULL);
        CefMainArgs main_args(moduleHandle);
#else
        CefMainArgs main_args(argc, argv);
#endif
        CefRefPtr<ClientApp> app(new ClientApp);
        result = CefExecuteProcess(main_args, app.get(), sandbox_info);
        if (result >= 0) {
            return result;
        }
        CefSettings settings;
#if !defined(CEF_USE_SANDBOX)
        settings.no_sandbox = true;
#endif
#if defined(WIN32)
        settings.multi_threaded_message_loop = true;
#endif
        // Currently we run in a single process, otherwise Csound is not
        // available to the ClientApp class. This may have to be changed.
        settings.single_process = true;
        CefString(&settings.cache_path).FromASCII(QDir::tempPath().toLocal8Bit());
        CefInitialize(main_args, settings, app.get(), sandbox_info);
        // Load flash system plug-in on Windows.
#ifdef WIN32_XXX
        CefLoadPlugins(IsWow64());
#endif
#endif
        // forming filenames was here before. now before localSocket
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
        if (!csoundQt->startServer())
            qDebug()<<"Could not start local server.";
        splash->finish(csoundQt);
        delete splash;
#ifdef QCS_HTML5
        app->setMainWindow(csoundQt);
#endif
        csoundQt->show();
		filterObj.setMainWindow(csoundQt);
        result = qapp.exec();
#ifdef QCS_HTML5
        CefShutdown();
        CefQuit();
        qDebug() << "CsoundQt main will now return:" << result;
        // At this point, I have done all I can to shut down cleanly, and the
        // sequence of CEF closing steps appears to be correct. But the only
        // way to avoid a crash is still to force an exit, and even that doesn't
        // always work.
        //throw shutdown_exception_;
        std::abort();
    } catch (std::exception &e) {
        qDebug() << e.what();
        std::abort();
    }
#endif
    return result;
}
