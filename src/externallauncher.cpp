#include "externallauncher.h"

#include <QDebug>
#include <QDesktopServices>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QElapsedTimer>
#include <QGuiApplication>
#include <QSharedPointer>

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
bool relyOnSystemUrlHandler()
{
    if (qEnvironmentVariableIsSet("APPIMAGE") || qEnvironmentVariableIsSet("APPDIR"))
        return true;
    if (qEnvironmentVariableIsSet("FLATPAK_ID"))
        return true;
    return QFileInfo::exists(QStringLiteral("/.flatpak-info"));
}

QString systemHandlerReason(const QString &configuredBrowser)
{
    if (qEnvironmentVariableIsSet("APPIMAGE") || qEnvironmentVariableIsSet("APPDIR"))
        return QStringLiteral("appimage");
    if (qEnvironmentVariableIsSet("FLATPAK_ID")
        || QFileInfo::exists(QStringLiteral("/.flatpak-info")))
        return QStringLiteral("flatpak");
    if (configuredBrowser.isEmpty())
        return QStringLiteral("no-browser-configured");
    return QStringLiteral("configured-browser-unlaunchable");
}

QString platformName()
{
    return QGuiApplication::instance() ? QGuiApplication::platformName()
                                       : QStringLiteral("unknown");
}

void logEnvironmentContext()
{
    qDebug().noquote() << "External open context:"
                       << "appimage=" << (qEnvironmentVariableIsSet("APPIMAGE") || qEnvironmentVariableIsSet("APPDIR") ? "yes" : "no")
                       << "flatpak=" << (qEnvironmentVariableIsSet("FLATPAK_ID") || QFileInfo::exists(QStringLiteral("/.flatpak-info")) ? "yes" : "no")
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
        text.prepend(QStringLiteral("...[earlier output omitted]...\n"));
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
            safeArgs.append(QStringLiteral("…/%1").arg(QFileInfo(arg).fileName()));
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
        return QStringLiteral("file://…/%1").arg(QFileInfo(url.toLocalFile()).fileName());

    const QString scheme = url.scheme().isEmpty() ? QStringLiteral("<no-scheme>") : url.scheme();
    if (url.host().isEmpty())
        return scheme + QStringLiteral(":<no-host>");
    return scheme + QStringLiteral("://") + url.host();
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
    const QString request = feature.isEmpty() ? QStringLiteral("external") : feature;
    qDebug().noquote() << "External open attempt: feature=" << request
                       << "mechanism=direct-exec"
                       << "program=" << executable
                       << "args=" << safeArgumentsForLog(args)
                       << "workingDirectory="
                       << (process->workingDirectory().isEmpty()
                               ? QStringLiteral("<default>")
                               : QStringLiteral("…/%1").arg(QFileInfo(process->workingDirectory()).fileName()));
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
                           << "output=" << (stderrTail.isEmpty() ? QStringLiteral("<empty>") : stderrTail);
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

    const QString request = feature.isEmpty() ? QStringLiteral("external") : feature;
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
                           << "configuredBrowser=" << (configuredBrowser.isEmpty() ? QStringLiteral("<empty>") : configuredBrowser);
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
                       << "symLinkTarget=" << (browserInfo.isSymLink() ? browserInfo.symLinkTarget() : QStringLiteral("<none>"));
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
