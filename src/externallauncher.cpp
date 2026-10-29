
#include "externallauncher.h"

#include <QDebug>
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QElapsedTimer>
#include <QGuiApplication>
#include <QSharedPointer>

#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusUnixFileDescriptor>
#include <QVariantMap>
#endif

#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusMessage>
#endif
using namespace Qt::StringLiterals;

namespace ExternalLauncher {

namespace {

// True when CsoundQt runs from an AppImage (the type-2 runtime exports
// $APPIMAGE, linuxdeploy's AppRun exports $APPDIR) or from a Flatpak sandbox
// (which provides /.flatpak-info and $FLATPAK_ID).
//
// In both packaging formats a configured browser executable must not be
// launched directly: on AppImage the child would inherit LD_LIBRARY_PATH
// pointing at the bundled Qt/Csound libraries and silently fail, and on
// Flatpak the sandbox forbids executing a host binary altogether. URLs are
// therefore always handed to the system URL handler (which uses the
// freedesktop portal under Flatpak).
bool isFlatpakSession()
{
    return qEnvironmentVariableIsSet("FLATPAK_ID")
            || QFileInfo::exists(u"/.flatpak-info"_s);
}

bool isAppImage()
{
    return qEnvironmentVariableIsSet("APPIMAGE")
            || qEnvironmentVariableIsSet("APPDIR");
}

bool relyOnSystemUrlHandler()
{
    return isFlatpakSession() || isAppImage();
}

#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
// Ask the running file manager to show folders or select files. This goes
// through the session bus, so no child inherits our library paths. It also
// works from an AppImage, where launching a host binary directly is fragile,
// and avoids kde-open's attempt to read a directory as a file.
bool callFileManager1(const QString &method, const QStringList &uris,
                      const QString &feature)
{
    QDBusInterface manager(u"org.freedesktop.FileManager1"_s,
                           u"/org/freedesktop/FileManager1"_s,
                           u"org.freedesktop.FileManager1"_s,
                           QDBusConnection::sessionBus());
    if (!manager.isValid())
        return false;
    manager.setTimeout(5000);

    qDebug().noquote() << "External open attempt: feature=" << feature
                       << "mechanism=filemanager1" << "method=" << method
                       << "target=" << uris;
    const QDBusMessage reply = manager.call(method, uris, QString());
    const bool ok = reply.type() != QDBusMessage::ErrorMessage;
    qDebug().noquote() << "External open result: feature=" << feature
                       << "mechanism=filemanager1" << "method=" << method
                       << "result=" << ok
                       << (ok ? QString() : reply.errorMessage());
    return ok;
}

bool showFolderWithFileManager1(const QString &path, const QString &feature)
{
    const QString uri = QUrl::fromLocalFile(QDir(path).absolutePath()).toString();
    return callFileManager1(u"ShowFolders"_s, QStringList{uri}, feature);
}

bool showFileWithFileManager1(const QString &path, const QString &feature)
{
    const QString uri = QUrl::fromLocalFile(QFileInfo(path).absoluteFilePath()).toString();
    return callFileManager1(u"ShowItems"_s, QStringList{uri}, feature);
}

// Ask the desktop portal to open a local file. The portal runs outside this
// process, so it does not inherit CsoundQt's library path, and it is also the
// sanctioned way to open files from a Flatpak sandbox. The file is passed as
// a file descriptor, which works for files outside the sandbox as well.
bool openLocalFileWithPortal(const QString &path, QString *errorString,
                             const QString &feature)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        if (errorString)
            *errorString = file.errorString();
        return false;
    }

    QDBusInterface portal(u"org.freedesktop.portal.Desktop"_s,
                          u"/org/freedesktop/portal/desktop"_s,
                          u"org.freedesktop.portal.OpenURI"_s,
                          QDBusConnection::sessionBus());
    if (!portal.isValid()) {
        if (errorString)
            *errorString = portal.lastError().message();
        return false;
    }

    QVariantMap options;
    QDBusUnixFileDescriptor fd(file.handle());
    qDebug().noquote() << "External open attempt: feature=" << feature
                       << "mechanism=portal-openfile"
                       << "target=" << QUrl::fromLocalFile(path).toString();
    const QDBusMessage reply = portal.call(u"OpenFile"_s, QString(),
                                           QVariant::fromValue(fd), options);
    const bool ok = reply.type() != QDBusMessage::ErrorMessage;
    qDebug().noquote() << "External open result: feature=" << feature
                       << "mechanism=portal-openfile" << "result=" << ok
                       << (ok ? QString() : reply.errorMessage());
    if (!ok && errorString)
        *errorString = reply.errorMessage();
    return ok;
}
#endif

QString systemHandlerReason(const QString &configuredBrowser)
{
    if (qEnvironmentVariableIsSet("APPIMAGE") || qEnvironmentVariableIsSet("APPDIR"))
        return u"appimage"_s;
    if (qEnvironmentVariableIsSet("FLATPAK_ID")
        || QFileInfo::exists(u"/.flatpak-info"_s))
        return u"flatpak"_s;
    if (configuredBrowser.isEmpty())
        return u"no-browser-configured"_s;
    return u"configured-browser-unlaunchable"_s;
}

QString platformName()
{
    return QGuiApplication::instance() ? QGuiApplication::platformName()
                                       : u"unknown"_s;
}

void logEnvironmentContext()
{
    qDebug().noquote() << "External open context:"
                       << "appimage=" << (qEnvironmentVariableIsSet("APPIMAGE") || qEnvironmentVariableIsSet("APPDIR") ? "yes" : "no")
                       << "flatpak=" << (qEnvironmentVariableIsSet("FLATPAK_ID") || QFileInfo::exists(u"/.flatpak-info"_s) ? "yes" : "no")
                       << "qtPlatform=" << platformName()
                       << "desktop=" << qEnvironmentVariable("XDG_CURRENT_DESKTOP")
                       << "session=" << qEnvironmentVariable("XDG_SESSION_TYPE")
                       << "LD_LIBRARY_PATH=" << (qEnvironmentVariableIsSet("LD_LIBRARY_PATH") ? "set" : "unset")
                       << "QT_QPA_PLATFORM=" << qEnvironmentVariable("QT_QPA_PLATFORM");
}

QString boundedOutput(const QByteArray &output)
{
    constexpr qsizetype maxBytes = 1024;
    const QByteArray tail = output.right(maxBytes);
    QString text = QString::fromLocal8Bit(tail).trimmed();
    if (output.size() > maxBytes)
        text.prepend(u"...[earlier output omitted]...\n"_s);
    return text;
}

QStringList safeArgumentsForLog(const QStringList &args)
{
    QStringList safeArgs;
    safeArgs.reserve(args.size());
    for (const QString &arg : args) {
        const QUrl url(arg);
        if (url.isValid() && !url.scheme().isEmpty()) {
            safeArgs.append(redactUrlForLog(url));
        } else if (QFileInfo(arg).isAbsolute()) {
            safeArgs.append(u"…/%1"_s.arg(QFileInfo(arg).fileName()));
        } else {
            safeArgs.append(arg);
        }
    }
    return safeArgs;
}

} // namespace

QString redactUrlForLog(const QUrl &url)
{
    if (url.isLocalFile())
        return u"file://…/%1"_s.arg(QFileInfo(url.toLocalFile()).fileName());

    const QString scheme = url.scheme().isEmpty() ? u"<no-scheme>"_s : url.scheme();
    if (url.host().isEmpty())
        return scheme + u":<no-host>"_s;
    return scheme + u"://"_s + url.host();
}

bool launchExecutable(const QString &executable, const QStringList &args,
                      const QString &workingDirectory, QString *errorString,
                      const QString &feature)
{
    if (executable.isEmpty()) {
        if (errorString)
            *errorString = QObject::tr("No executable given.");
        return false;
    }

    // Not parented and not deleted here: an external application (e.g. a
    // browser) may outlive this call, so the QProcess is only destroyed once
    // the process has finished.
    auto *process = new QProcess();
    process->setProgram(executable);
    process->setArguments(args);
    process->setProcessChannelMode(QProcess::MergedChannels);
    if (!workingDirectory.isEmpty() && QDir(workingDirectory).exists())
        process->setWorkingDirectory(workingDirectory);

    auto output = QSharedPointer<QByteArray>::create();
    auto timer = QSharedPointer<QElapsedTimer>::create();
    auto childPid = QSharedPointer<qint64>::create(0);
    timer->start();
    const QString request = feature.isEmpty() ? u"external"_s : feature;
    qDebug().noquote() << "External open attempt: feature=" << request
                       << "mechanism=direct-exec"
                       << "program=" << executable
                       << "args=" << safeArgumentsForLog(args)
                       << "workingDirectory="
                       << (process->workingDirectory().isEmpty()
                               ? u"<default>"_s
                               : u"…/%1"_s.arg(QFileInfo(process->workingDirectory()).fileName()));
    logEnvironmentContext();

    QObject::connect(process, &QProcess::readyReadStandardOutput, process,
                     [process, output]() {
        *output += process->readAllStandardOutput();
        constexpr qsizetype maxBytes = 4096;
        if (output->size() > maxBytes)
            output->remove(0, output->size() - maxBytes);
    });
    QObject::connect(process, &QProcess::errorOccurred, process,
                     [request, executable](QProcess::ProcessError error) {
        qDebug().noquote() << "External open process error: feature=" << request
                           << "mechanism=direct-exec" << "program=" << executable
                           << "error=" << static_cast<int>(error);
    });
    QObject::connect(process, &QProcess::started, process, [process, childPid]() {
        *childPid = process->processId();
    });
    QObject::connect(process,
                     static_cast<void (QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
                     process,
                     [process, output, timer, childPid, request, executable](int exitCode, QProcess::ExitStatus status) {
        *output += process->readAllStandardOutput();
        const QString stderrTail = boundedOutput(*output);
        qDebug().noquote() << "External open process finished: feature=" << request
                           << "mechanism=direct-exec" << "program=" << executable
                           << "pid=" << *childPid << "exitCode=" << exitCode
                           << "exitStatus=" << (status == QProcess::NormalExit ? "normal" : "crash")
                           << "elapsedMs=" << timer->elapsed()
                           << "output=" << (stderrTail.isEmpty() ? u"<empty>"_s : stderrTail);
        process->deleteLater();
    });

    process->start();
    if (!process->waitForStarted()) {
        const QString error = process->errorString();
        qDebug().noquote() << "External open start failed: feature=" << request
                           << "mechanism=direct-exec" << "program=" << executable
                           << "error=" << error;
        if (errorString)
            *errorString = error;
        delete process;
        return false;
    }

    qDebug().noquote() << "External open started: feature=" << request
                       << "mechanism=direct-exec" << "program=" << executable
                       << "pid=" << process->processId();
    *childPid = process->processId();
    return true;
}

bool openWithDefaultApplication(const QUrl &url, QString *errorString, const QString &feature)
{
    if (url.isEmpty()) {
        if (errorString)
            *errorString = QObject::tr("Empty URL.");
        return false;
    }

    const QString request = feature.isEmpty() ? u"external"_s : feature;

#if defined(Q_OS_LINUX) && defined(QT_DBUS_LIB)
    // Prefer the desktop portal for local files. It opens the file in the
    // user's session rather than spawning a handler as a child of CsoundQt,
    // so it is unaffected by CsoundQt's environment and works inside Flatpak.
    if (url.isLocalFile()) {
        const QFileInfo info(url.toLocalFile());
        if (!info.isDir() && info.exists()) {
            QString portalError;
            if (openLocalFileWithPortal(info.absoluteFilePath(), &portalError,
                                        request))
                return true;
            qDebug().noquote() << "External open fallback: feature=" << request
                               << "mechanism=QDesktopServices::openUrl"
                               << "reason=portal-openfile-failed"
                               << "error=" << portalError;
        }
    }
#endif

    qDebug().noquote() << "External open attempt: feature=" << request
                       << "mechanism=QDesktopServices::openUrl"
                       << "target=" << redactUrlForLog(url);
    logEnvironmentContext();

    const bool opened = QDesktopServices::openUrl(url);

    qDebug().noquote() << "External open result: feature=" << request
                       << "mechanism=QDesktopServices::openUrl"
                       << "target=" << redactUrlForLog(url) << "result=" << opened;
    if (opened)
        return true;

    if (errorString)
        *errorString = QObject::tr("QDesktopServices::openUrl() returned false.");
    return false;
}

bool openFolder(const QString &path, QString *errorString, const QString &feature)
{
    const QFileInfo info(path);
    if (!info.exists() || !info.isDir()) {
        if (errorString)
            *errorString = QObject::tr("Not a directory: %1").arg(path);
        return false;
    }

    const QString request = feature.isEmpty() ? u"open-folder"_s : feature;

#if defined(Q_OS_LINUX)
    // A Flatpak sandbox must use the portal through QDesktopServices. Outside
    // Flatpak, ask the running file manager over the session bus: no child
    // inherits our LD_LIBRARY_PATH, and kde-open (which would try to read the
    // directory as a file) is not involved.
    if (!isFlatpakSession()) {
#if defined(QT_DBUS_LIB)
        if (showFolderWithFileManager1(info.absoluteFilePath(), request))
            return true;
#endif
    }
#endif

    QString folder = info.absoluteFilePath();
    if (!folder.endsWith(QLatin1Char('/')))
        folder += QLatin1Char('/');
    return openWithDefaultApplication(QUrl::fromLocalFile(folder), errorString, request);
}

bool revealFile(const QString &path, QString *errorString, const QString &feature)
{
    const QFileInfo info(path);
    const QString request = feature.isEmpty() ? u"reveal-file"_s : feature;

    // A render history entry can outlive the file it points to. Selecting it
    // is impossible then, but the containing folder is still useful.
    if (!info.exists())
        return openFolder(info.absolutePath(), errorString, request);

#if defined(Q_OS_LINUX)
    // A Flatpak sandbox must use the portal through QDesktopServices; the
    // FileManager1 interface is not generally available there.
    if (!isFlatpakSession()) {
#if defined(QT_DBUS_LIB)
        if (showFileWithFileManager1(info.absoluteFilePath(), request))
            return true;
#endif
    }
#endif

    // Fall back to showing the containing folder when the file manager does
    // not implement selection or the platform has no desktop-service API for
    // revealing a file.
    return openFolder(info.absolutePath(), errorString, request);
}

bool openBrowser(const QString &configuredBrowser, const QUrl &url, QString *errorString,
                 const QString &feature)
{
    if (url.isEmpty()) {
        if (errorString)
            *errorString = QObject::tr("Empty URL.");
        return false;
    }

    // AppImage and Flatpak delegate entirely to the system URL handler: a
    // configured browser executable cannot be launched there (see
    // relyOnSystemUrlHandler()). An empty setting also means "use the system
    // default".
    if (relyOnSystemUrlHandler() || configuredBrowser.isEmpty()) {
        const QString reason = systemHandlerReason(configuredBrowser);
        qDebug().noquote() << "External browser request: feature=browser"
                           << "mechanism=QDesktopServices::openUrl" << "reason=" << reason
                           << "target=" << redactUrlForLog(url)
                           << "configuredBrowser=" << (configuredBrowser.isEmpty() ? u"<empty>"_s : configuredBrowser);
        if (!configuredBrowser.isEmpty()) {
            const QFileInfo configuredInfo(configuredBrowser);
            qDebug().noquote() << "External browser configured path facts: exists=" << configuredInfo.exists()
                               << "isFile=" << configuredInfo.isFile() << "isDir=" << configuredInfo.isDir()
                               << "isExecutable=" << configuredInfo.isExecutable();
        }
        return openWithDefaultApplication(url, errorString, feature);
    }

    const QFileInfo browserInfo(configuredBrowser);
    QString launchError;
    qDebug().noquote() << "External browser request: feature=" << feature
                       << "mechanism=direct-exec" << "reason=configured-browser"
                       << "target=" << redactUrlForLog(url)
                       << "program=" << configuredBrowser;
    logEnvironmentContext();
    qDebug().noquote() << "External browser configured path facts: exists=" << browserInfo.exists()
                       << "isFile=" << browserInfo.isFile() << "isDir=" << browserInfo.isDir()
                       << "isExecutable=" << browserInfo.isExecutable()
                       << "isSymLink=" << browserInfo.isSymLink()
                       << "symLinkTarget=" << (browserInfo.isSymLink() ? browserInfo.symLinkTarget() : u"<none>"_s);
    if (browserInfo.isExecutable() && !browserInfo.isDir()) {
        if (launchExecutable(configuredBrowser, QStringList(url.toString()),
                             QString(), &launchError, feature))
            return true;
    } else {
        // On macOS the default is an .app bundle, which is a directory and
        // cannot be executed directly by QProcess.
        launchError = QObject::tr("\"%1\" is not an executable file "
                                  "(exists=%2, isFile=%3, isDir=%4, isExecutable=%5)")
                          .arg(configuredBrowser)
                          .arg(browserInfo.exists())
                          .arg(browserInfo.isFile())
                          .arg(browserInfo.isDir())
                          .arg(browserInfo.isExecutable());
    }

    qDebug().noquote() << "External browser fallback: feature=" << feature
                       << "mechanism=QDesktopServices::openUrl"
                       << "reason=configured-browser-unlaunchable"
                       << "program=" << configuredBrowser
                       << "target=" << redactUrlForLog(url);
    QString fallbackError;
    if (openWithDefaultApplication(url, &fallbackError, feature))
        return true;

    // Only report a failure if the system default browser failed as well.
    if (errorString)
        *errorString = launchError + QLatin1Char('\n') + fallbackError;
    return false;
}

} // namespace ExternalLauncher
