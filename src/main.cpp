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
#include <QCheckBox>
#include <QDialogButtonBox>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFrame>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLabel>
#include <QPointer>
#include <QPushButton>
#include <QSettings>
#include <QStandardPaths>
#include <QTableWidget>
#include <QTemporaryDir>
#include <QTextStream>
#include <QTimer>
#ifndef CSQT_NO_SPLASH
#include <QSplashScreen>
#endif
#include "csoundqt.h"
#include "csoundengine.h"
#include "documentpage.h"
#include "pluginsdialog.h"
#include "risset.h"
#include "bundledfonts.h"
#include "widgetstyle.h"
#include "debuglog.h"
#include <QLocalSocket>

#include <cstdio>
#include <cstdlib>
#include <utility>

using namespace Qt::StringLiterals;


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
    candidates << u"/usr/lib/qt6/plugins"_s
               << u"/usr/lib64/qt6/plugins"_s
               << u"/usr/local/lib/qt6/plugins"_s;

    // Debian/Ubuntu style multiarch directories, e.g.
    // /usr/lib/x86_64-linux-gnu/qt6/plugins
    const QDir libDir(u"/usr/lib"_s);
    const QStringList arches = libDir.entryList(
                QStringList() << u"*-linux-gnu"_s,
                QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &arch : arches)
        candidates << u"/usr/lib/"_s + arch + u"/qt6/plugins"_s;

    const QStringList libraryPaths = QCoreApplication::libraryPaths();
    for (const QString &path : candidates) {
        if (libraryPaths.contains(path))
            continue; // already searched
        if (QDir(path + u"/styles"_s).exists())
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
                    .filePath(u"csoundqt-risset-self-test.json"_s);
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
    report.insert(u"success"_s, success);
    report.insert(u"dataRoot"_s,
                  Risset::userDataRoot().absolutePath());
    report.insert(u"pluginRoot"_s,
                  Risset::pluginRootDir().absolutePath());
    report.insert(u"managedExecutable"_s,
                  Risset::localRissetExecutable());

    if (m_application->risset != nullptr) {
        const Risset *risset = m_application->risset;
        report.insert(u"installed"_s, risset->isInstalled);
        report.insert(u"version"_s, risset->rissetVersion);
        report.insert(u"executable"_s, risset->executablePath());
        report.insert(u"opcodesXml"_s, risset->rissetOpcodesXml);
        const QJsonDocument info =
                QJsonDocument::fromJson(risset->infoText().toUtf8());
        if (info.isObject())
            report.insert(u"info"_s, info.object());
        else
            report.insert(u"infoRaw"_s, risset->infoText());
    } else {
        report.insert(u"installed"_s, false);
    }

    if (!error.isEmpty())
        report.insert(u"error"_s, error);
    return report;
}

// End-to-end test of the plugin dependency workflow. It starts with risset
// uninstalled, opens a CSD that uses plugin opcodes without declaring them in
// <CsMeta>, follows the banner to install risset and the detected plugins
// through the real windows, and finally runs the CSD. Used by the opt-in
// networked CI job.
class RissetDependencySelfTest : public QObject
{
    Q_OBJECT
public:
    RissetDependencySelfTest(CsoundQt *application, QString csdPath,
                             QString reportPath, QObject *parent = nullptr)
        : QObject(parent), m_application(application),
          m_sourceCsd(std::move(csdPath)), m_reportPath(std::move(reportPath))
    {
        if (m_reportPath.isEmpty()) {
            m_reportPath = QDir(QStandardPaths::writableLocation(
                                    QStandardPaths::TempLocation))
                    .filePath(u"csoundqt-risset-dependency-self-test.json"_s);
        }
    }

    void start();

signals:
    void finished(bool success);

private:
    enum class Stage {
        InitialDetection,
        RissetInstallation,
        RissetDetection,
        PluginInstallation,
        PluginDetection,
        Performance,
        Done
    };

    void checkInitialBanner();
    void startRissetInstallation();
    void checkPluginBanner();
    void openFilteredPluginDialog();
    void pollForPluginTable();
    void checkFilteredPluginDialog();
    void checkInstalledPlugin();
    void startPerformance();
    void onDetectionFinished();
    void onPerformanceStopped();
    void evaluatePerformance();
    void appendMessage(const QString &message);
    void appendErrorLines(const QList<QPair<int, QString>> &lines);
    void finish(bool success, const QString &error = QString());
    bool pluginInstalled(const QString &name) const;
    QString bannerText() const;
    QString installButtonText() const;
    QPushButton *installButton() const;
    PluginsDialog *pluginsDialog() const;
    QJsonObject buildReport(bool success, const QString &error) const;

    CsoundQt *m_application = nullptr;
    QString m_sourceCsd;
    QString m_reportPath;
    QTemporaryDir m_tempDir;
    QPointer<PluginsDialog> m_pluginsDialog;
    DocumentPage *m_page = nullptr;
    CsoundEngine *m_engine = nullptr;
    QTimer *m_timeout = nullptr;
    QTimer *m_pollTimer = nullptr;
    Stage m_stage = Stage::InitialDetection;
    QString m_tempCsd;
    QStringList m_bannerTexts;
    QString m_initialAction;
    QString m_installAction;
    QStringList m_installList;
    QStringList m_messages;
    QStringList m_errorLines;
    bool m_runEvaluated = false;
    bool m_done = false;
    int m_pollTries = 0;
};

void RissetDependencySelfTest::start()
{
    // Defer to the event loop so this runs after CsoundQt is shown and
    // QApplication::exec() has started.
    QTimer::singleShot(0, this, [this]() {
        qInfo().noquote() << "Risset dependency self test: loading"
                          << m_sourceCsd;
        if (!QFileInfo::exists(m_sourceCsd)) {
            finish(false, u"CSD not found: "_s + m_sourceCsd);
            return;
        }
        if (!m_tempDir.isValid()) {
            finish(false, u"Could not create a temporary directory."_s);
            return;
        }
        // Work on a copy: playing a document may save it, and the CI checkout
        // should stay untouched.
        m_tempCsd = m_tempDir.filePath(u"dict_get.csd"_s);
        if (!QFile::copy(m_sourceCsd, m_tempCsd)) {
            finish(false, u"Could not copy the CSD to "_s + m_tempCsd);
            return;
        }

        m_timeout = new QTimer(this);
        m_timeout->setSingleShot(true);
        connect(m_timeout, &QTimer::timeout, this, [this]() {
            finish(false, u"Timed out while installing risset, installing "
                          "plugins or running the CSD."_s);
        });
        m_timeout->start(45 * 60 * 1000);

        connect(m_application, &CsoundQt::rissetDetectionFinished,
                this, &RissetDependencySelfTest::onDetectionFinished);

        if (m_application->loadFile(m_tempCsd, false, true) < 0) {
            finish(false, u"Could not load "_s + m_tempCsd);
            return;
        }
        m_page = m_application->currentDocumentPage();
        if (m_page == nullptr) {
            finish(false, u"The test CSD has no document page."_s);
            return;
        }

        if (m_application->rissetDetectionReady())
            QTimer::singleShot(0, this,
                               &RissetDependencySelfTest::checkInitialBanner);
        else
            m_application->initRisset();
    });
}

void RissetDependencySelfTest::onDetectionFinished()
{
    switch (m_stage) {
    case Stage::InitialDetection:
        checkInitialBanner();
        break;
    case Stage::RissetDetection:
        checkPluginBanner();
        break;
    case Stage::PluginDetection:
        checkInstalledPlugin();
        break;
    default:
        break;
    }
}

QString RissetDependencySelfTest::bannerText() const
{
    auto *label = m_application->findChild<QLabel*>(
                u"pluginDependencyLabel"_s);
    return label != nullptr ? label->text() : QString();
}

QString RissetDependencySelfTest::installButtonText() const
{
    QPushButton *button = installButton();
    return button != nullptr ? button->text() : QString();
}

QPushButton *RissetDependencySelfTest::installButton() const
{
    return m_application->findChild<QPushButton*>(
                u"pluginDependencyInstallButton"_s);
}

PluginsDialog *RissetDependencySelfTest::pluginsDialog() const
{
    return m_application->findChild<PluginsDialog*>();
}

bool RissetDependencySelfTest::pluginInstalled(const QString &name) const
{
    if (m_application->risset == nullptr)
        return false;
    const auto &installed = m_application->risset->pluginInstalled;
    for (auto it = installed.cbegin(); it != installed.cend(); ++it) {
        if (it.key().compare(name, Qt::CaseInsensitive) == 0)
            return it.value();
    }
    return false;
}

void RissetDependencySelfTest::checkInitialBanner()
{
    if (m_stage != Stage::InitialDetection
            || !m_application->rissetDetectionReady()) {
        return;
    }
    if (m_application->rissetIsInstalled()) {
        finish(false, u"risset was already installed before the test: "_s
               + m_application->rissetVersion());
        return;
    }

    auto *banner = m_application->findChild<QFrame*>(
                u"pluginDependencyBanner"_s);
    QPushButton *button = installButton();
    if (banner == nullptr || button == nullptr) {
        finish(false, u"The plugin dependency banner was not created."_s);
        return;
    }
    if (!banner->isVisible()) {
        finish(false, u"The plugin dependency banner is not visible."_s);
        return;
    }
    const QString text = bannerText();
    if (!text.contains(u"klib"_s, Qt::CaseInsensitive)
            || !text.contains(u"line "_s, Qt::CaseInsensitive)) {
        finish(false, u"The banner does not report the detected klib "
                      "opcodes: "_s + text);
        return;
    }
    if (button->text().compare(u"Manage Plugins"_s,
                               Qt::CaseInsensitive) != 0) {
        finish(false, u"Expected the banner to offer Manage Plugins, got: "_s
               + button->text());
        return;
    }
    m_bannerTexts.append(text);
    m_initialAction = button->text();

    // Follow the same path as the user: click the banner button, then check
    // that the Plugins window shows the risset installation page.
    button->click();
    m_pluginsDialog = pluginsDialog();
    if (m_pluginsDialog == nullptr) {
        finish(false, u"The Plugins window did not open."_s);
        return;
    }
    m_pluginsDialog->setSilent(true);

    auto *install = m_pluginsDialog->findChild<QPushButton*>(
                u"installRissetButton"_s);
    if (install == nullptr || !install->isVisible()) {
        finish(false, u"The risset installation prompt is not visible."_s);
        return;
    }

    m_stage = Stage::RissetInstallation;
    startRissetInstallation();
}

void RissetDependencySelfTest::startRissetInstallation()
{
    connect(m_pluginsDialog, &PluginsDialog::installationFinished,
            this, [this](bool success, const QString &error) {
        if (!success) {
            finish(false, u"Installing risset failed: "_s + error);
            return;
        }
        m_stage = Stage::RissetDetection;
        qInfo().noquote() << "Risset dependency self test: risset installed; "
                             "waiting for detection";
    });
    m_pluginsDialog->startInstallation();
}

void RissetDependencySelfTest::checkPluginBanner()
{
    if (m_stage != Stage::RissetDetection
            || !m_application->rissetDetectionReady()) {
        return;
    }
    if (!m_application->rissetIsInstalled()) {
        finish(false, u"CsoundQt did not detect risset after installation."_s);
        return;
    }

    auto *banner = m_application->findChild<QFrame*>(
                u"pluginDependencyBanner"_s);
    QPushButton *button = installButton();
    if (banner == nullptr || button == nullptr || !banner->isVisible()) {
        finish(false, u"The plugin dependency banner did not return after "
                      "installing risset."_s);
        return;
    }
    const QString text = bannerText();
    if (!text.contains(u"klib"_s, Qt::CaseInsensitive)) {
        finish(false, u"The banner does not mention klib after risset was "
                      "installed: "_s + text);
        return;
    }
    if (button->text().compare(u"Install Plugins"_s,
                               Qt::CaseInsensitive) != 0) {
        finish(false, u"Expected the banner to offer Install Plugins, got: "_s
               + button->text());
        return;
    }
    m_bannerTexts.append(text);
    m_installAction = button->text();

    // Open the filtered Plugins window from the banner.
    button->click();
    m_pluginsDialog = pluginsDialog();
    if (m_pluginsDialog == nullptr) {
        finish(false, u"The filtered Plugins window did not open."_s);
        return;
    }
    m_pluginsDialog->setSilent(true);

    m_stage = Stage::PluginInstallation;
    m_pollTries = 0;
    m_pollTimer = new QTimer(this);
    connect(m_pollTimer, &QTimer::timeout,
            this, &RissetDependencySelfTest::pollForPluginTable);
    m_pollTimer->start(200);
    QTimer::singleShot(0, this,
                       &RissetDependencySelfTest::pollForPluginTable);
}

void RissetDependencySelfTest::pollForPluginTable()
{
    if (m_stage != Stage::PluginInstallation)
        return;
    if (m_pluginsDialog == nullptr) {
        finish(false, u"The filtered Plugins window was closed unexpectedly."_s);
        return;
    }
    auto *table = m_pluginsDialog->findChild<QTableWidget*>(
                u"pluginsTable"_s);
    if (table != nullptr && table->isVisible() && table->rowCount() > 0) {
        if (m_pollTimer != nullptr)
            m_pollTimer->stop();
        checkFilteredPluginDialog();
        return;
    }
    if (++m_pollTries > 900) { // about three minutes
        finish(false, u"Timed out waiting for the filtered plugin list."_s);
    }
}

void RissetDependencySelfTest::checkFilteredPluginDialog()
{
    auto *table = m_pluginsDialog->findChild<QTableWidget*>(
                u"pluginsTable"_s);
    int klibRow = -1;
    for (int row = 0; row < table->rowCount(); ++row) {
        const QTableWidgetItem *item = table->item(row, 0);
        if (item != nullptr
                && item->text().compare(u"klib"_s,
                                        Qt::CaseInsensitive) == 0) {
            klibRow = row;
            break;
        }
    }
    if (klibRow < 0) {
        finish(false, u"The filtered Plugins window does not list klib."_s);
        return;
    }

    auto *checkContainer = table->cellWidget(klibRow, 1);
    auto *check = checkContainer != nullptr
            ? checkContainer->findChild<QCheckBox*>() : nullptr;
    if (check == nullptr || !check->isChecked()) {
        finish(false, u"klib is not preselected for installation."_s);
        return;
    }

    auto *buttons = m_pluginsDialog->findChild<QDialogButtonBox*>(
                u"pluginsButtonBox"_s);
    if (buttons == nullptr) {
        finish(false, u"The filtered Plugins window has no button box."_s);
        return;
    }
    if (buttons->button(QDialogButtonBox::Apply) != nullptr) {
        finish(false, u"The dependency Plugins window shows an Apply "
                      "button."_s);
        return;
    }
    auto *ok = buttons->button(QDialogButtonBox::Ok);
    if (ok == nullptr || buttons->button(QDialogButtonBox::Cancel) == nullptr) {
        finish(false, u"The dependency Plugins window does not offer only "
                      "OK and Cancel."_s);
        return;
    }

    m_installList.append(u"klib"_s);
    connect(m_pluginsDialog, &PluginsDialog::pluginApplyFinished,
            this, [this](bool success, const QString &error) {
        if (!success) {
            finish(false, u"Installing klib failed: "_s + error);
            return;
        }
        m_stage = Stage::PluginDetection;
        qInfo().noquote() << "Risset dependency self test: plugins installed; "
                             "waiting for detection";
    });
    ok->click();
}

void RissetDependencySelfTest::checkInstalledPlugin()
{
    if (m_stage != Stage::PluginDetection
            || !m_application->rissetDetectionReady()) {
        return;
    }
    if (!pluginInstalled(u"klib"_s)) {
        finish(false, u"CsoundQt did not detect the installed klib plugin."_s);
        return;
    }
    auto *banner = m_application->findChild<QFrame*>(
                u"pluginDependencyBanner"_s);
    if (banner != nullptr && banner->isVisible()) {
        finish(false, u"The dependency banner is still visible after klib was "
                      "installed: "_s + bannerText());
        return;
    }
    startPerformance();
}

void RissetDependencySelfTest::startPerformance()
{
    m_page = m_application->currentDocumentPage();
    if (m_page == nullptr) {
        finish(false, u"The test document disappeared."_s);
        return;
    }
    m_engine = m_page->getEngine();
    if (m_engine == nullptr) {
        finish(false, u"The test document has no Csound engine."_s);
        return;
    }
    connect(m_page, &DocumentPage::stopSignal,
            this, &RissetDependencySelfTest::onPerformanceStopped);
    connect(m_engine, &CsoundEngine::passMessages,
            this, &RissetDependencySelfTest::appendMessage);
    connect(m_engine, &CsoundEngine::errorLines,
            this, &RissetDependencySelfTest::appendErrorLines);

    m_stage = Stage::Performance;
    qInfo().noquote() << "Risset dependency self test: running the CSD with "
                         "the installed klib plugin";
    m_application->play(false);
}

void RissetDependencySelfTest::onPerformanceStopped()
{
    if (m_stage != Stage::Performance)
        return;
    // Let play() return before compiling again for the final check.
    QTimer::singleShot(0, this,
                       &RissetDependencySelfTest::evaluatePerformance);
}

void RissetDependencySelfTest::appendMessage(const QString &message)
{
    m_messages.append(message);
    if (m_messages.size() > 200)
        m_messages.removeFirst();
}

void RissetDependencySelfTest::appendErrorLines(
        const QList<QPair<int, QString>> &lines)
{
    for (const auto &line : lines) {
        const QString text = line.second.trimmed();
        if (!text.isEmpty())
            m_errorLines.append(text);
    }
}

void RissetDependencySelfTest::evaluatePerformance()
{
    if (m_done || m_runEvaluated || m_engine == nullptr)
        return;
    m_runEvaluated = true;

    // The run itself is the check. A compilation failure reports error lines
    // and the message buffer contains the Csound diagnostics; do not compile
    // a second time here because CsoundQt may already have removed its session
    // copy of the CSD.
    QStringList problems = m_errorLines;
    for (const QString &message : std::as_const(m_messages)) {
        if (message.contains(u"error"_s, Qt::CaseInsensitive)
                || message.contains(u"unknown opcode"_s, Qt::CaseInsensitive)
                || message.contains(u"not found"_s, Qt::CaseInsensitive)) {
            problems.append(message.trimmed());
        }
    }
    if (!problems.isEmpty()) {
        finish(false, u"The CSD did not run cleanly:\n"_s
               + problems.join(u"\n"_s));
        return;
    }
    finish(true);
}

void RissetDependencySelfTest::finish(bool success, const QString &error)
{
    if (m_done)
        return;
    m_done = true;
    m_stage = Stage::Done;
    if (m_timeout != nullptr)
        m_timeout->stop();
    if (m_pollTimer != nullptr)
        m_pollTimer->stop();

    const QJsonObject report = buildReport(success, error);
    const QByteArray json = QJsonDocument(report).toJson(QJsonDocument::Indented);

    QFile file(m_reportPath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write(json);
        file.close();
        qInfo().noquote() << "Risset dependency self test report:"
                          << m_reportPath;
    } else {
        qWarning().noquote() << "Risset dependency self test: could not write "
                                "the report to" << m_reportPath;
    }

    QTextStream out(stdout);
    out << QString::fromUtf8(json) << Qt::endl;

    qInfo().noquote() << (success ? "RISSET DEPENDENCY SELF TEST PASSED"
                                  : "RISSET DEPENDENCY SELF TEST FAILED")
                      << (error.isEmpty() ? QString() : error);

    if (m_pluginsDialog != nullptr) {
        m_pluginsDialog->close();
        m_pluginsDialog->deleteLater();
        m_pluginsDialog = nullptr;
    }

    emit finished(success);
    deleteLater();
}

QJsonObject RissetDependencySelfTest::buildReport(
        bool success, const QString &error) const
{
    QJsonObject report;
    report.insert(u"success"_s, success);
    report.insert(u"csd"_s, m_sourceCsd);
    report.insert(u"temporaryCsd"_s, m_tempCsd);
    report.insert(u"dataRoot"_s, Risset::userDataRoot().absolutePath());
    report.insert(u"pluginRoot"_s, Risset::pluginRootDir().absolutePath());
    report.insert(u"rissetInstalled"_s, m_application->rissetIsInstalled());
    report.insert(u"rissetVersion"_s, m_application->rissetVersion());
    report.insert(u"klibInstalled"_s, pluginInstalled(u"klib"_s));

    QJsonArray bannerTexts;
    for (const QString &text : m_bannerTexts)
        bannerTexts.append(text);
    report.insert(u"banners"_s, bannerTexts);
    report.insert(u"initialAction"_s, m_initialAction);
    report.insert(u"installAction"_s, m_installAction);
    report.insert(u"installList"_s, QJsonArray::fromStringList(m_installList));

    QJsonArray messages;
    for (const QString &message : m_messages)
        messages.append(message);
    report.insert(u"messages"_s, messages);
    report.insert(u"errorLines"_s, QJsonArray::fromStringList(m_errorLines));

    if (!error.isEmpty())
        report.insert(u"error"_s, error);
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
    if (QGuiApplication::platformName().startsWith(u"wayland"_s)
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
    QQuickStyle::setStyle(u"Fusion"_s);
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
    bool rissetDependencySelfTest = false;
    QString rissetDependencyCsd;
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
            out << "   --self-test-risset-dependencies FILE  Install risset and detected plugins through CsoundQt, then run FILE (network test)" << Qt::endl;
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
        if(arg == "--self-test-risset-dependencies" && i + 1 < args.size()) {
            rissetDependencySelfTest = true;
            rissetDependencyCsd = args[++i];
        }
        else if(arg.startsWith("--self-test-risset-dependencies=")) {
            rissetDependencySelfTest = true;
            rissetDependencyCsd = arg.section('=', 1);
        }
        if(arg == "--self-test-risset-report" && i + 1 < args.size()) {
            rissetSelfTestReport = args[++i];
        }
        else if(arg.startsWith("--self-test-risset-report=")) {
            rissetSelfTestReport = arg.section('=', 1);
        }
    }

    if (rissetDependencySelfTest && rissetDependencyCsd.isEmpty()) {
        qWarning() << "--self-test-risset-dependencies needs a CSD path";
        return 1;
    }
    const bool anyRissetSelfTest = rissetSelfTest || rissetDependencySelfTest;

    if (anyRissetSelfTest)
        forceNew = true; // a running instance must not swallow the test

    if (!anyRissetSelfTest) {
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
    if (!anyRissetSelfTest) {
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
    } else if (rissetDependencySelfTest) {
        auto *selfTest = new RissetDependencySelfTest(
                    csoundQt, rissetDependencyCsd, rissetSelfTestReport);
        QObject::connect(selfTest, &RissetDependencySelfTest::finished, &qapp,
                         [&qapp](bool success) {
            qInfo() << "Risset dependency self test: asking the application "
                       "to exit with" << (success ? 0 : 1);
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
    if (anyRissetSelfTest) {
        qInfo() << "Risset self test: event loop returned" << result;
        // The self test must not hang in Csound/Qt teardown on CI. Everything
        // that matters has been written to the report at this point.
        std::fflush(nullptr);
        std::_Exit(result);
    }
    return result;
}

#include "main.moc"
