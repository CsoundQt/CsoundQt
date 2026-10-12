#include "externallauncher.h"

#include <QDebug>
#include <QDesktopServices>
#include <QDir>
#include <QFileInfo>
#include <QProcess>

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

} // namespace

bool launchExecutable(const QString &executable, const QStringList &args,
                      const QString &workingDirectory, QString *errorString)
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
    if (!workingDirectory.isEmpty() && QDir(workingDirectory).exists())
        process->setWorkingDirectory(workingDirectory);

    process->start();
    if (!process->waitForStarted()) {
        const QString error = process->errorString();
        qDebug() << "Failed to start process:" << executable << args << error;
        if (errorString)
            *errorString = error;
        delete process;
        return false;
    }

    qDebug() << "Launched external program with id:" << process->processId();
    QObject::connect(process,
                     static_cast<void (QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
                     process, &QObject::deleteLater);
    return true;
}

bool openWithDefaultApplication(const QUrl &url, QString *errorString)
{
    if (url.isEmpty()) {
        if (errorString)
            *errorString = QObject::tr("Empty URL.");
        return false;
    }

    if (QDesktopServices::openUrl(url))
        return true;

    if (errorString)
        *errorString = QObject::tr("QDesktopServices::openUrl() returned false.");
    return false;
}

bool openBrowser(const QString &configuredBrowser, const QUrl &url, QString *errorString)
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
        qDebug() << "Opening URL with the system default handler";
        return openWithDefaultApplication(url, errorString);
    }

    const QFileInfo browserInfo(configuredBrowser);
    QString launchError;
    if (browserInfo.isExecutable() && !browserInfo.isDir()) {
        if (launchExecutable(configuredBrowser, QStringList(url.toString()),
                             QString(), &launchError))
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

    qDebug() << "Configured browser could not be launched, trying default system browser";
    QString fallbackError;
    if (openWithDefaultApplication(url, &fallbackError))
        return true;

    // Only report a failure if the system default browser failed as well.
    if (errorString)
        *errorString = launchError + QLatin1Char('\n') + fallbackError;
    return false;
}

} // namespace ExternalLauncher
