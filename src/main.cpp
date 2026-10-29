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
#include <QDir>
#include <QSettings>
#ifndef CSQT_NO_SPLASH
#include <QSplashScreen>
#endif
#include "csoundqt.h"
#include "bundledfonts.h"
#include "widgetstyle.h"
#include "debuglog.h"
#include <QLocalSocket>

#ifdef Q_OS_WIN
#include <QtQuickControls2/QQuickStyle>
#include <QtCore/qbytearray.h>
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

// Some desktop styles (e.g. Breeze) put themed icons on dialog buttons
// (Yes/No/Cancel/...). Those icons follow the desktop icon theme rather
// than the application palette, so they can end up dark-on-dark when
// CsoundQt uses a dark palette. Use text-only dialog buttons everywhere
// instead, matching the Fusion style behaviour.
// DialogButtonStyle and the widget-style helpers live in widgetstyle.h so the
// style can be re-applied when it is changed in the settings dialog.

#if defined(Q_OS_LINUX) && !defined(FLATPAK_BUILD)
// The Qt CsoundQt is built against may not ship the desktop widget styles
// (Breeze, Adwaita, Oxygen, ...). Those are provided by the distribution's Qt
// plugin packages, so also look in the usual system plugin directories. Only
// directories that actually contain style plugins are added, and only when
// CsoundQt is not running from a self-contained bundle (AppImage) whose Qt
// plugins may not match the host's.
static void addSystemStylePluginPaths()
{
    QStringList candidates;
    candidates << QStringLiteral("/usr/lib/qt6/plugins")
               << QStringLiteral("/usr/lib64/qt6/plugins")
               << QStringLiteral("/usr/local/lib/qt6/plugins");

    // Debian/Ubuntu style multiarch directories, e.g.
    // /usr/lib/x86_64-linux-gnu/qt6/plugins
    const QDir libDir(QStringLiteral("/usr/lib"));
    const QStringList arches = libDir.entryList(
                QStringList() << QStringLiteral("*-linux-gnu"),
                QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &arch : arches)
        candidates << QStringLiteral("/usr/lib/") + arch + QStringLiteral("/qt6/plugins");

    const QStringList libraryPaths = QCoreApplication::libraryPaths();
    for (const QString &path : candidates) {
        if (libraryPaths.contains(path))
            continue; // already searched
        if (QDir(path + QStringLiteral("/styles")).exists())
            QCoreApplication::addLibraryPath(path);
    }
}
#endif

// If another CsoundQt is running, give it the files to open - or, when there is
// nothing to open, ask whether a second window is really wanted - and tell the
// caller whether it should quit. --force-new skips this altogether, so a new
// instance is started even when one is already running; the files then belong
// to the new instance.
static bool handOverToRunningInstance(const QStringList &fileNames)
{
    QLocalSocket socket;
    socket.connectToServer("csoundqt");
    if (!socket.waitForConnected(200)) {
        // wait for the given ms, returns true if the server in other instance is listening
        return false;
    }
    if (!fileNames.isEmpty()) {
        qDebug() << "Opening file(s) in already running instance";
        QString message = "open ***" + fileNames.join("***"); // use a separator that is probably not in the file name
        socket.write(message.toLocal8Bit());
        socket.waitForBytesWritten(1000);
        socket.close();
        return true; // let the other instance open the file
    }
    socket.close();
    //qDebug() << "Another instance already running.";
    int answer = QMessageBox::warning(nullptr, QObject::tr("CsoundQt"),
                                      QObject::tr("Another instance is already running. "
                                                  "Are you sure you want to open a new"
                                                  " window?"),
                                      QMessageBox::Open|QMessageBox::Cancel,
                                      QMessageBox::Cancel);
    return answer == QMessageBox::Cancel;
}

int main(int argc, char *argv[])
{
    int result = 0;

    // Set a global template for ALL qDebug messages.
	qSetMessagePattern("[%{if-debug}D%{endif}%{if-info}I%{endif}%{if-warning}W%{endif}%{if-critical}C%{endif}%{if-fatal}F%{endif}][%{file}:%{line} %{function}] %{message}");

    // Route CsoundQt's own debug output through our handler so it can also be
    // written to a log file (Settings > Environment > "Log debug info").
    DebugLog::install();

    // in Qt6 not needed, High-DPI always enabled
    //QApplication::setAttribute(Qt::AA_EnableHighDpiScaling); // TO test if this solved hight DPI problems
    //QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QStringList fileNames;
    QApplication qapp(argc, argv);

    // Start logging as early as possible (before the main window is built) so
    // that startup problems are captured too. The setting is re-applied in
    // CsoundQt::applySettings() when it is changed at runtime.
    {
        QSettings settings("csoundqt", "csoundqt");
        DebugLog::setEnabled(settings.value("Environment/logDebug", false).toBool());
    }

    // Make the bundled widget fonts available (used only by the widget panel).
    BundledFonts::registerFonts();

#ifdef Q_OS_OSX
       if (csoundGetVersion()<6090) { // this build does not work with older Csound on OSX
           qDebug()<<"Csound version too old: "<< VERSION;
           QMessageBox::warning(NULL, QObject::tr("Csound version mismatch"), QObject::tr("This version of CsoundQt requires Csound 6.09 or newer. Please download it from <br>") +"<a href=http://csound.github.io/download>http://csound.github.io/download</a>" );
           return(0);
       }
#endif

#ifdef Q_OS_WIN
    // To force qml elemtns follow colour theme
    QQuickStyle::setStyle(QStringLiteral("Fusion"));
    qDebug() << "QQC2 style requested:" << QQuickStyle::name();
#endif

#if defined(Q_OS_LINUX) && !defined(FLATPAK_BUILD)
    // Make the distribution's widget styles (Breeze, Adwaita, ...) available.
    if (!qEnvironmentVariableIsSet("APPIMAGE") && !qEnvironmentVariableIsSet("APPDIR"))
        addSystemStylePluginPaths();
#endif

    // Qt widget style. The default is Fusion on Linux (so CsoundQt looks the
    // same everywhere) and Qt's native style on macOS and Windows; the user can
    // pick another available style in Settings > General > Theme. The style is
    // wrapped in DialogButtonStyle (see widgetstyle.h) so dialog buttons stay
    // text-only; this also applies to the message boxes shown below and to
    // every dialog in the application.
    QString widgetStyle;
    {
        QSettings styleSettings("csoundqt", "csoundqt");
        widgetStyle = styleSettings.value("GUI/widgetStyle",
                                          defaultWidgetStyleName()).toString();
    }
    if (QStyle *widgetStyleBase = createWidgetStyle(resolveWidgetStyleName(widgetStyle))) {
        qApp->setStyle(new DialogButtonStyle(widgetStyleBase));
    } else {
        // No explicit style (macOS/Windows default): keep Qt's style, just
        // strip themed dialog button icons.
        qApp->setStyle(new DialogButtonStyle(qApp->style()));
    }

    bool autoplay = false;
    bool autorender = false;
    bool noRecentFiles = false;
    bool forceNew = false;
    QStringList args = qapp.arguments();
    args.removeAt(0); // Remove program name
    for(int i=0; i < args.size(); i++) {
        auto arg = args[i];
        if(arg == "--help") {
            QTextStream out(stdout);
            out << "\n\n";
            out << "Options:" << Qt::endl;
            out << "   --play        Autoplay the last file passed via command line" << Qt::endl;
            out << "   --render      Render the last file passed via command line" << Qt::endl;
            out << "   --no-recent-files  Do not reopen files from the last session" << Qt::endl;
            out << "   --force-new   Start a new instance even if one is already running" << Qt::endl;
            out << "   --help        This message" << Qt::endl;
            out << Qt::endl;
            exit(0);
        }
        if(arg == "--play") {
            autoplay = true;
        }
        if(arg == "--render") {
            autorender = true;
        }
        if(arg == "--no-recent-files") {
            noRecentFiles = true;
        }
        if(arg == "--force-new") {
            forceNew = true;
        }
    }

    foreach (QString arg, args) {
        if (!arg.startsWith("-")) {// avoid OS X arguments
            fileNames.append(arg);
        }
    }
    // If another instance is already running, hand it the files (or ask before
    // opening a second window) and quit. --force-new skips all that and always
    // starts a new instance.
    if (!forceNew && handOverToRunningInstance(fileNames)) {
        return 0;
    }
    // forming filenames was here before. now before localSocket
    FileOpenEater filterObj;
    qapp.installEventFilter(&filterObj);

#ifndef CSQT_NO_SPLASH
    QPixmap pixmap(":/images/splashscreen.png");

    QSplashScreen *splash = new QSplashScreen(pixmap);
    splash->showMessage(QString("Version %1").arg(CSQT_VERSION),
                        Qt::AlignCenter | Qt::AlignBottom, Qt::white);
    splash->show();
    splash->raise();
    qapp.processEvents();
#endif
    QSettings qsettings("csoundqt", "csoundqt");
    qsettings.beginGroup("GUI");
    QString language = qsettings.value("language", QLocale::system().name()).toString();
    qsettings.endGroup();
    QTranslator translator;
    bool loaded = translator.load(QString(":/translations/csoundqt_") + language);
    if (loaded) {
        qapp.installTranslator(&translator);
    } else {
        QDEBUG << "Could load translator";
    }

    CsoundQt *csoundQt = new CsoundQt(fileNames, noRecentFiles);
    if (!csoundQt->startServer())
        qDebug()<<"Could not start local server.";
#ifndef CSQT_NO_SPLASH
    // splash->finish(csoundQt);
    splash->hide();
    delete splash;
    splash = nullptr;
#endif

    // enable widget updates after show
    csoundQt->show();
    
    
    if(autoplay && !fileNames.isEmpty())
        csoundQt->play();
    if(autorender && !fileNames.isEmpty())
        csoundQt->render();

    
    filterObj.setMainWindow(csoundQt);
    // QDEBUG << "Starting qapp exec";
    
    result = qapp.exec();
    return result;
}
