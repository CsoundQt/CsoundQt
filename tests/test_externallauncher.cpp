/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
*/

// Tests for ExternalLauncher (src/externallauncher.cpp), the code that opens
// links and files in a configured browser or the system default application.
//
// The tests do not launch a real GUI browser. Instead they:
//   * use this test executable itself as a "fake browser" (it detects the
//     CSOUNDQT_FAKE_BROWSER environment variable and records its arguments),
//     which works on every platform without relying on scripts / .bat files;
//   * use QDesktopServices::setUrlHandler() to intercept the
//     default-application fallback.
// This makes it possible to verify the logic on headless CI runners
// (macOS/Windows/Linux) with QT_QPA_PLATFORM=offscreen.

#include <QtTest/QtTest>

#include <QCoreApplication>
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QTemporaryDir>
#include <QUrl>

#include "externallauncher.h"

namespace {

// Receives URLs from QDesktopServices::openUrl() when registered as handler.
class UrlCatcher : public QObject
{
    Q_OBJECT
public:
    QUrl lastUrl;
    int count = 0;

public slots:
    void handleUrl(const QUrl &url)
    {
        lastUrl = url;
        ++count;
    }
};

QString readFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return QString();
    return QString::fromUtf8(file.readAll());
}

} // namespace

class TestExternalLauncher : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();

    void launchExecutableStartsProgram();
    void openBrowserUsesConfiguredBrowser();
    void openBrowserUsesConfiguredBrowserForLocalHtml();
    void openBrowserFallsBackWhenBrowserIsAppBundle();
    void openBrowserFallsBackWhenBrowserMissing();
    void openBrowserUsesDefaultWhenNoneConfigured();
    void openBrowserUsesSystemHandlerInAppImage();
    void openWithDefaultApplicationUsesHandler();
    void openBrowserReportsFailureWhenEverythingFails();

private:
    // Creates an executable that appends each received argument to markerFile.
    QString createFakeBrowser(const QString &markerFile);
    QString markerPath(const QString &name) const;

    QTemporaryDir m_dir;
};

void TestExternalLauncher::initTestCase()
{
    QVERIFY2(m_dir.isValid(), "Could not create temporary directory");
}

void TestExternalLauncher::init()
{
    // Keep the AppImage/Flatpak detection in openBrowser() from leaking
    // between tests.
    qunsetenv("APPIMAGE");
    qunsetenv("APPDIR");
    qunsetenv("FLATPAK_ID");
}

QString TestExternalLauncher::markerPath(const QString &name) const
{
    return m_dir.filePath(name);
}

QString TestExternalLauncher::createFakeBrowser(const QString &markerFile)
{
    // The test executable doubles as the fake browser: when the
    // CSOUNDQT_FAKE_BROWSER environment variable is set (inherited by child
    // processes) it appends its first argument to the marker file. This avoids
    // relying on shell scripts or .bat files, which QProcess cannot launch
    // directly on Windows.
    qputenv("CSOUNDQT_FAKE_BROWSER", QByteArrayLiteral("1"));
    qputenv("CSOUNDQT_FAKE_BROWSER_MARKER", markerFile.toUtf8());
    return QCoreApplication::applicationFilePath();
}

void TestExternalLauncher::launchExecutableStartsProgram()
{
    const QString marker = markerPath("marker-launch.txt");
    const QString browser = createFakeBrowser(marker);
    QVERIFY(!browser.isEmpty());

    QVERIFY(ExternalLauncher::launchExecutable(browser, {QStringLiteral("https://example.com/launch")}));
    QTRY_VERIFY_WITH_TIMEOUT(readFile(marker).contains(QStringLiteral("https://example.com/launch")), 15000);
}

void TestExternalLauncher::openBrowserUsesConfiguredBrowser()
{
    const QString marker = markerPath("marker-browser.txt");
    const QString browser = createFakeBrowser(marker);
    QVERIFY(!browser.isEmpty());
    const QUrl url(QStringLiteral("https://example.com/page"));

    QString error;
    QVERIFY2(ExternalLauncher::openBrowser(browser, url, &error), qPrintable(error));
    QVERIFY(error.isEmpty());
    QTRY_VERIFY_WITH_TIMEOUT(readFile(marker).contains(url.toString()), 15000);
}

void TestExternalLauncher::openBrowserUsesConfiguredBrowserForLocalHtml()
{
    const QString html = m_dir.filePath("help.html");
    {
        QFile file(html);
        QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
        file.write("<html><body>hi</body></html>\n");
    }

    const QString marker = markerPath("marker-html.txt");
    const QString browser = createFakeBrowser(marker);
    QVERIFY(!browser.isEmpty());
    const QUrl url = QUrl::fromLocalFile(html);

    QString error;
    QVERIFY2(ExternalLauncher::openBrowser(browser, url, &error), qPrintable(error));
    QTRY_VERIFY_WITH_TIMEOUT(readFile(marker).contains(url.toString()), 15000);
}

void TestExternalLauncher::openBrowserFallsBackWhenBrowserIsAppBundle()
{
    // On macOS the configured browser is an .app bundle: a directory that
    // cannot be executed directly. The default application must be used.
    const QString bundle = m_dir.filePath("Safari.app");
    QVERIFY(QDir().mkpath(bundle));

    UrlCatcher catcher;
    QDesktopServices::setUrlHandler(QStringLiteral("csoundqt-test"), &catcher, "handleUrl");
    const QUrl url(QStringLiteral("csoundqt-test://open/link"));

    QString error;
    QVERIFY2(ExternalLauncher::openBrowser(bundle, url, &error), qPrintable(error));
    QVERIFY2(error.isEmpty(), qPrintable(error));
    QCOMPARE(catcher.count, 1);
    QCOMPARE(catcher.lastUrl, url);
    QDesktopServices::unsetUrlHandler(QStringLiteral("csoundqt-test"));
}

void TestExternalLauncher::openBrowserFallsBackWhenBrowserMissing()
{
    const QString missing = m_dir.filePath("does-not-exist-browser");

    UrlCatcher catcher;
    QDesktopServices::setUrlHandler(QStringLiteral("csoundqt-test"), &catcher, "handleUrl");
    const QUrl url(QStringLiteral("csoundqt-test://missing"));

    QString error;
    QVERIFY2(ExternalLauncher::openBrowser(missing, url, &error), qPrintable(error));
    QCOMPARE(catcher.count, 1);
    QDesktopServices::unsetUrlHandler(QStringLiteral("csoundqt-test"));
}

void TestExternalLauncher::openBrowserUsesDefaultWhenNoneConfigured()
{
    UrlCatcher catcher;
    QDesktopServices::setUrlHandler(QStringLiteral("csoundqt-test"), &catcher, "handleUrl");
    const QUrl url(QStringLiteral("csoundqt-test://default"));

    QString error;
    QVERIFY2(ExternalLauncher::openBrowser(QString(), url, &error), qPrintable(error));
    QCOMPARE(catcher.count, 1);
    QCOMPARE(catcher.lastUrl, url);
    QDesktopServices::unsetUrlHandler(QStringLiteral("csoundqt-test"));
}

void TestExternalLauncher::openBrowserUsesSystemHandlerInAppImage()
{
    // Inside an AppImage a configured browser executable must be ignored: the
    // launched child would inherit the bundled LD_LIBRARY_PATH and fail
    // silently. The system URL handler is used instead.
    const QString marker = markerPath("marker-appimage.txt");
    const QString browser = createFakeBrowser(marker);
    QVERIFY(!browser.isEmpty());

    UrlCatcher catcher;
    QDesktopServices::setUrlHandler(QStringLiteral("csoundqt-test"), &catcher, "handleUrl");
    const QUrl url(QStringLiteral("csoundqt-test://appimage"));

    qputenv("APPIMAGE", QByteArrayLiteral("/tmp/CsoundQt-x86_64.AppImage"));
    QString error;
    QVERIFY2(ExternalLauncher::openBrowser(browser, url, &error), qPrintable(error));

    QCOMPARE(catcher.count, 1);
    QCOMPARE(catcher.lastUrl, url);
    QVERIFY2(!QFile::exists(marker),
             "the configured browser must not be launched from an AppImage");
    QDesktopServices::unsetUrlHandler(QStringLiteral("csoundqt-test"));
}

void TestExternalLauncher::openWithDefaultApplicationUsesHandler()
{
    UrlCatcher catcher;
    QDesktopServices::setUrlHandler(QStringLiteral("csoundqt-test"), &catcher, "handleUrl");
    const QUrl url(QStringLiteral("csoundqt-test://direct"));

    QString error;
    QVERIFY2(ExternalLauncher::openWithDefaultApplication(url, &error), qPrintable(error));
    QCOMPARE(catcher.count, 1);
    QDesktopServices::unsetUrlHandler(QStringLiteral("csoundqt-test"));
}

void TestExternalLauncher::openBrowserReportsFailureWhenEverythingFails()
{
    // An invalid URL makes QDesktopServices::openUrl() return false on every
    // platform, so the failure path can be tested deterministically.
    const QUrl invalid(QStringLiteral("http://[invalid"));
    QVERIFY2(!invalid.isValid(), "test URL is unexpectedly valid");

    const QString missing = m_dir.filePath("still-does-not-exist");

    QString error;
    QVERIFY(!ExternalLauncher::openBrowser(missing, invalid, &error));
    QVERIFY2(!error.isEmpty(), "expected a non-empty error description");
}

// Custom main: when launched as the fake browser (see createFakeBrowser()),
// record the URL argument and exit. Otherwise run the test suite.
int main(int argc, char *argv[])
{
    if (qEnvironmentVariableIsSet("CSOUNDQT_FAKE_BROWSER")) {
        const QByteArray marker = qgetenv("CSOUNDQT_FAKE_BROWSER_MARKER");
        QFile file(QString::fromLocal8Bit(marker));
        if (file.open(QIODevice::Append | QIODevice::Text)) {
            for (int i = 1; i < argc; ++i)
                file.write(QByteArray(argv[i]) + '\n');
        }
        return 0;
    }

    QGuiApplication app(argc, argv);
    TestExternalLauncher test;
    return QTest::qExec(&test, argc, argv);
}

#include "test_externallauncher.moc"
