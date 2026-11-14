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
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QStandardPaths>
#include <QTextStream>
#include <QTimer>
#ifndef CSQT_NO_SPLASH
#include <QSplashScreen>
#endif
#include "csoundqt.h"
#include "pluginsdialog.h"
#include "risset.h"
#include "bundledfonts.h"
#include "widgetstyle.h"
#include "debuglog.h"
#include <QLocalSocket>

#include <cstdio>
#include <cstdlib>
#include <utility>

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
static bool handOverToRunningInstance(const QStringList &fileNames,
                                      bool readOnly, bool noEditor)
{
    QLocalSocket socket;
    socket.connectToServer("csoundqt");
    if (!socket.waitForConnected(200)) {
        // wait for the given ms, returns true if the server in other instance is listening
        return false;
    }
    if (!fileNames.isEmpty()) {
        qDebug() << "Opening file(s) in already running instance";
        QString header = "open";
        if (readOnly)
            header += " --readonly";
        if (noEditor)
            header += " --noeditor";
        QString message = header + " ***" + fileNames.join("***"); // use a separator that is probably not in the file name
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

namespace {

// Headless end-to-end test of the risset installation: it drives the real
// Plugins window code, waits for CsoundQt's own detection to pick up the
// result and writes a JSON report. Started by --self-test-risset-install, as
// used by the opt-in networked CI job.
class RissetSelfTest : public QObject
{
    Q_OBJECT
public:
    RissetSelfTest(CsoundQt *application, QString reportPath,
                   QObject *parent = nullptr)
        : QObject(parent), m_application(application),
          m_reportPath(std::move(reportPath))
    {
        if (m_reportPath.isEmpty()) {
            m_reportPath = QDir(QStandardPaths::writableLocation(
                                    QStandardPaths::TempLocation))
                    .filePath(QStringLiteral("csoundqt-risset-self-test.json"));
        }
    }

    void start();

signals:
    void finished(bool success);

private:
    void onDetectionFinished();
    void startInstallation();
    void verifyDetection();
    void finish(bool success, const QString &error = QString());
    QJsonObject buildReport(bool success, const QString &error) const;

    CsoundQt *m_application = nullptr;
    QString m_reportPath;
    PluginsDialog *m_dialog = nullptr;
    QTimer *m_timeout = nullptr;
    bool m_installStarted = false;
    bool m_done = false;
};

void RissetSelfTest::start()
{
    // Defer to the event loop, so QApplication::exit() below is never called
    // before exec() has started.
    QTimer::singleShot(0, this, [this]() {
        qInfo().noquote() << "Risset self test: waiting for the initial detection";

        m_timeout = new QTimer(this);
        m_timeout->setSingleShot(true);
        connect(m_timeout, &QTimer::timeout, this, [this]() {
            finish(false, QStringLiteral(
                       "Timed out while installing or detecting risset."));
        });
        m_timeout->start(20 * 60 * 1000);

        connect(m_application, &CsoundQt::rissetDetectionFinished,
                this, &RissetSelfTest::onDetectionFinished);

        if (m_application->rissetDetectionReady())
            QTimer::singleShot(0, this, &RissetSelfTest::onDetectionFinished);
        else
            m_application->initRisset();
    });
}

void RissetSelfTest::onDetectionFinished()
{
    if (m_done)
        return;

    if (!m_installStarted) {
        if (m_application->rissetIsInstalled()) {
            finish(false, QStringLiteral(
                       "risset was already installed before the test: %1")
                   .arg(m_application->rissetVersion()));
            return;
        }
        qInfo().noquote() << "Risset self test: risset is not installed; "
                             "starting the Plugins window installer";
        startInstallation();
        return;
    }

    verifyDetection();
}

void RissetSelfTest::startInstallation()
{
    m_installStarted = true;
    m_dialog = new PluginsDialog(m_application, m_application);
    connect(m_dialog, &PluginsDialog::message, this, [](const QString &text) {
        qInfo().noquote() << "risset:" << text;
    });
    connect(m_dialog, &PluginsDialog::installationFinished, this,
            [this](bool success, const QString &error) {
        if (!success) {
            finish(false, error);
            return;
        }
        qInfo().noquote() << "Risset self test: installation finished; "
                             "waiting for CsoundQt to detect it";
    });
    m_dialog->startInstallation();
}

void RissetSelfTest::verifyDetection()
{
    if (!m_application->rissetIsInstalled()) {
        finish(false, QStringLiteral(
                   "CsoundQt did not detect risset after the installation."));
        return;
    }

    const QString version = m_application->rissetVersion();
    if (version.isEmpty()) {
        finish(false, QStringLiteral(
                   "CsoundQt detected risset but reported no version."));
        return;
    }

    // Detection must prefer the executable that the Plugins window installed,
    // not an unrelated risset that happens to be on PATH.
    const QString detected = m_application->risset->executablePath();
    const QString managed = Risset::localRissetExecutable();
    if (QFileInfo(detected) != QFileInfo(managed)) {
        finish(false, QStringLiteral(
                   "CsoundQt detected %1 instead of the managed %2.")
               .arg(detected, managed));
        return;
    }

    const QString opcodesXml = m_application->risset->rissetOpcodesXml;
    if (!opcodesXml.isEmpty() && !QFile::exists(opcodesXml)) {
        finish(false, QStringLiteral(
                   "CsoundQt did not find risset's opcodes.xml at %1.")
               .arg(opcodesXml));
        return;
    }

    qInfo().noquote() << "Risset self test: CsoundQt detected risset" << version;
    finish(true);
}

void RissetSelfTest::finish(bool success, const QString &error)
{
    if (m_done)
        return;
    m_done = true;
    if (m_timeout != nullptr)
        m_timeout->stop();

    const QJsonObject report = buildReport(success, error);
    const QByteArray json = QJsonDocument(report).toJson(QJsonDocument::Indented);

    QFile file(m_reportPath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write(json);
        file.close();
        qInfo().noquote() << "Risset self test report:" << m_reportPath;
    } else {
        qWarning().noquote() << "Risset self test: could not write the report to"
                             << m_reportPath;
    }

    QTextStream out(stdout);
    out << QString::fromUtf8(json) << Qt::endl;

    qInfo().noquote() << (success ? "RISSET SELF TEST PASSED"
                                  : "RISSET SELF TEST FAILED")
                      << (error.isEmpty() ? QString() : error);

    if (m_dialog != nullptr) {
        m_dialog->close();
        m_dialog->deleteLater();
        m_dialog = nullptr;
    }

    emit finished(success);
    deleteLater();
}

QJsonObject RissetSelfTest::buildReport(bool success, const QString &error) const
{
    QJsonObject report;
    report.insert(QStringLiteral("success"), success);
    report.insert(QStringLiteral("dataRoot"),
                  Risset::userDataRoot().absolutePath());
    report.insert(QStringLiteral("pluginRoot"),
                  Risset::pluginRootDir().absolutePath());
    report.insert(QStringLiteral("managedExecutable"),
                  Risset::localRissetExecutable());

    if (m_application->risset != nullptr) {
        const Risset *risset = m_application->risset;
        report.insert(QStringLiteral("installed"), risset->isInstalled);
        report.insert(QStringLiteral("version"), risset->rissetVersion);
        report.insert(QStringLiteral("executable"), risset->executablePath());
        report.insert(QStringLiteral("opcodesXml"), risset->rissetOpcodesXml);
        const QJsonDocument info =
                QJsonDocument::fromJson(risset->infoText().toUtf8());
        if (info.isObject())
            report.insert(QStringLiteral("info"), info.object());
        else
            report.insert(QStringLiteral("infoRaw"), risset->infoText());
    } else {
        report.insert(QStringLiteral("installed"), false);
    }

    if (!error.isEmpty())
        report.insert(QStringLiteral("error"), error);
    return report;
}

} // namespace

int main(int argc, char *argv[])
{
    int result = 0;

    // Set a global template for ALL qDebug messages. qcs.pro defines
    // QT_MESSAGELOGCONTEXT, so file/line/function are present in release
    // builds too; otherwise Qt compiles the context out and the prefix shows
    // "unknown:0 unknown".
	qSetMessagePattern("[%{if-debug}D%{endif}%{if-info}I%{endif}%{if-warning}W%{endif}%{if-critical}C%{endif}%{if-fatal}F%{endif}][%{file}:%{line} %{function}] %{message}");

    // Route CsoundQt's own debug output through our handler so it can also be
    // written to a log file (Settings > Environment > "Log debug info").
    DebugLog::install();

    // in Qt6 not needed, High-DPI always enabled
    //QApplication::setAttribute(Qt::AA_EnableHighDpiScaling); // TO test if this solved hight DPI problems
    //QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QStringList fileNames;
    QApplication qapp(argc, argv);

#if defined(Q_OS_LINUX)
    // Qt Quick's GPU backend on Wayland slows down the raster QWidget windows
    // dramatically: as soon as a QQuickWidget is shown, the main window's
    // repaints are throttled and stay slow even after the QML window is closed.
    // The QML panels here are simple, so use the software scene graph on
    // Wayland and keep normal QWidget painting unaffected.
    if (QGuiApplication::platformName().startsWith(QStringLiteral("wayland"))
            && !qEnvironmentVariableIsSet("QT_QUICK_BACKEND")) {
        qputenv("QT_QUICK_BACKEND", "software");
    }
#endif

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
        DialogButtonStyle::setToolTipWakeUpDelay(
                    styleSettings.value("GUI/tooltipWakeUpDelay", 500).toInt());
    }
    const QString resolvedStyle = resolveWidgetStyleName(widgetStyle);
    if (QStyle *widgetStyleBase = createWidgetStyle(resolvedStyle)) {
        installWidgetStyle(widgetStyleBase, resolvedStyle);
    } else {
        // No explicit style (macOS/Windows default): keep Qt's style, just
        // strip themed dialog button icons.
        installWidgetStyle(qApp->style(), resolvedStyle);
    }

    bool autoplay = false;
    bool autorender = false;
    bool noRecentFiles = false;
    bool forceNew = false;
    bool readOnly = false;
    bool noEditor = false;
    bool rissetSelfTest = false;
    QString rissetSelfTestReport;
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
            out << "   --readonly    Open command-line files in read-only mode" << Qt::endl;
            out << "   --noeditor    Open command-line files without an editor, in a widget window" << Qt::endl;
            out << "   --force-new   Start a new instance even if one is already running" << Qt::endl;
            out << "   --self-test-risset-install  Install risset through the Plugins window and verify detection (network test)" << Qt::endl;
            out << "   --self-test-risset-report FILE  Write the self-test JSON report to FILE" << Qt::endl;
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
        if(arg == "--readonly") {
            readOnly = true;
        }
        if(arg == "--noeditor") {
            noEditor = true;
        }
        if(arg == "--self-test-risset-install") {
            rissetSelfTest = true;
        }
        if(arg == "--self-test-risset-report" && i + 1 < args.size()) {
            rissetSelfTestReport = args[++i];
        }
        else if(arg.startsWith("--self-test-risset-report=")) {
            rissetSelfTestReport = arg.section('=', 1);
        }
    }

    if (rissetSelfTest)
        forceNew = true; // a running instance must not swallow the test

    if (!rissetSelfTest) {
        foreach (QString arg, args) {
            if (!arg.startsWith("-")) {// avoid OS X arguments
                fileNames.append(arg);
            }
        }
    }
    // If another instance is already running, hand it the files (or ask before
    // opening a second window) and quit. --force-new skips all that and always
    // starts a new instance.
    if (!forceNew && handOverToRunningInstance(fileNames, readOnly, noEditor)) {
        return 0;
    }
    // forming filenames was here before. now before localSocket
    FileOpenEater filterObj;
    qapp.installEventFilter(&filterObj);

#ifndef CSQT_NO_SPLASH
    QSplashScreen *splash = nullptr;
    if (!rissetSelfTest) {
        QPixmap pixmap(":/images/splashscreen.png");

        splash = new QSplashScreen(pixmap);
        splash->showMessage(QString("Version %1").arg(CSQT_VERSION),
                            Qt::AlignCenter | Qt::AlignBottom, Qt::white);
        splash->show();
        splash->raise();
        qapp.processEvents();
    }
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

    CsoundQt *csoundQt = new CsoundQt(fileNames, noRecentFiles, readOnly, noEditor);
    if (!csoundQt->startServer())
        qDebug()<<"Could not start local server.";
#ifndef CSQT_NO_SPLASH
    // splash->finish(csoundQt);
    if (splash != nullptr) {
        splash->hide();
        delete splash;
        splash = nullptr;
    }
#endif

    // enable widget updates after show
    csoundQt->show();

    if (rissetSelfTest) {
        auto *selfTest = new RissetSelfTest(csoundQt, rissetSelfTestReport);
        QObject::connect(selfTest, &RissetSelfTest::finished, &qapp,
                         [&qapp](bool success) {
            qInfo() << "Risset self test: asking the application to exit with"
                    << (success ? 0 : 1);
            qapp.exit(success ? 0 : 1);
        });
        selfTest->start();
    }

    if(autoplay && !fileNames.isEmpty()) {
        if (noEditor)
            csoundQt->playWidgetWindows();
        else
            csoundQt->play();
    }
    if(autorender && !fileNames.isEmpty())
        csoundQt->render();

    
    filterObj.setMainWindow(csoundQt);
    // QDEBUG << "Starting qapp exec";
    
    result = qapp.exec();
    if (rissetSelfTest) {
        qInfo() << "Risset self test: event loop returned" << result;
        // The self test must not hang in Csound/Qt teardown on CI. Everything
        // that matters has been written to the report at this point.
        std::fflush(nullptr);
        std::_Exit(result);
    }
    return result;
}

#include "main.moc"
