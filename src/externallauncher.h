#ifndef EXTERNALLAUNCHER_H
#define EXTERNALLAUNCHER_H

#include <QString>
#include <QStringList>
#include <QUrl>

/**
 * Helpers to open URLs and files in external applications.
 *
 * This logic is factored out of CsoundQt (CsoundQt::openExternalBrowser and
 * CsoundQt::startProcess) so that it can be unit-tested on its own, without a
 * running CsoundQt instance and without actually launching a GUI application.
 *
 * The functions are intentionally free of any CsoundQt dependency and only use
 * QtCore/QtGui, so a small test executable can link them directly.
 */
namespace ExternalLauncher {

/**
 * Start \a executable with \a args and return true once it has started.
 *
 * The process is detached (this function does not wait for it to finish). If
 * \a workingDirectory is non-empty and exists, it is used as the working
 * directory. On failure, returns false and, if \a errorString is not null,
 * stores the process error there.
 */
bool launchExecutable(const QString &executable,
                      const QStringList &args = QStringList(),
                      const QString &workingDirectory = QString(),
                      QString *errorString = nullptr,
                      const QString &feature = QStringLiteral("external"));

/**
 * Open \a url in a browser.
 *
 * When running from an AppImage or a Flatpak (and whenever \a configuredBrowser
 * is empty) the URL is handed to the system URL handler via
 * QDesktopServices::openUrl(); a configured browser executable cannot be
 * launched in those packaging formats.
 *
 * Otherwise, if \a configuredBrowser is a launchable executable it is used
 * directly and the system default browser is only a fallback. A configured
 * macOS ".app" bundle (a directory, not an executable file) always falls back
 * to the system default browser.
 *
 * Returns true if the URL was handed to a browser. On failure returns false
 * and, if \a errorString is not null, stores a description of what was tried.
 */
bool openBrowser(const QString &configuredBrowser,
                  const QUrl &url,
                  QString *errorString = nullptr,
                  const QString &feature = QStringLiteral("browser"));

/**
 * Open \a url (a web URL or a local file) with the system default application
 * via QDesktopServices::openUrl().
 */
bool openWithDefaultApplication(const QUrl &url, QString *errorString = nullptr,
                                const QString &feature = QStringLiteral("external"));

/**
 * Open a directory in the system file manager.
 *
 * On Linux this prefers "gio open", which launches the default handler for
 * inode/directory directly. kde-open (used by xdg-open on KDE) can try to read
 * a directory as a file and fail with "Could not read file", so it is only
 * used as a fallback. On other platforms, and inside AppImage/Flatpak, the
 * directory URL is handed to QDesktopServices::openUrl().
 */
bool openFolder(const QString &path, QString *errorString = nullptr,
                const QString &feature = QStringLiteral("open-folder"));

/** Return a privacy-conscious target string suitable for diagnostic logs. */
QString redactUrlForLog(const QUrl &url);

} // namespace ExternalLauncher

#endif // EXTERNALLAUNCHER_H
