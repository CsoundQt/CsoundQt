#include "pluginsdialog.h"

#include "csoundqt.h"
#include "risset.h"

#include <QCoreApplication>
#include <QDialogButtonBox>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QLabel>
#include <QMessageBox>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPlainTextEdit>
#include <QProcess>
#include <QProcessEnvironment>
#include <QProgressBar>
#include <QPushButton>
#include <QStandardPaths>
#include <QVBoxLayout>

#include <memory>

namespace {

QString uvInstallerUrl()
{
#ifdef Q_OS_WIN
    return QStringLiteral("https://astral.sh/uv/install.ps1");
#else
    return QStringLiteral("https://astral.sh/uv/install.sh");
#endif
}

QString uvInstallerSuffix()
{
#ifdef Q_OS_WIN
    return QStringLiteral(".ps1");
#else
    return QStringLiteral(".sh");
#endif
}

QProcessEnvironment pluginEnvironment()
{
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("UV_UNMANAGED_INSTALL"),
                       Risset::pluginBinDir().absolutePath());
    environment.insert(QStringLiteral("UV_NO_MODIFY_PATH"), QStringLiteral("1"));
    environment.insert(QStringLiteral("UV_DISABLE_UPDATE"), QStringLiteral("1"));
    environment.insert(QStringLiteral("UV_NO_PROGRESS"), QStringLiteral("1"));
    environment.insert(QStringLiteral("UV_COLOR"), QStringLiteral("never"));
    environment.insert(QStringLiteral("UV_LINK_MODE"), QStringLiteral("copy"));
    return environment;
}

} // namespace

PluginsDialog::PluginsDialog(CsoundQt *mainWindow, QWidget *parent)
    : QDialog(parent), m_mainWindow(mainWindow)
{
    setWindowTitle(tr("Plugins"));
    setMinimumSize(600, 380);
    resize(660, 460);

    auto *layout = new QVBoxLayout(this);

    auto *title = new QLabel(tr("<h2>Plugins</h2>"), this);
    title->setTextFormat(Qt::RichText);
    layout->addWidget(title);

    m_statusLabel = new QLabel(this);
    m_statusLabel->setTextFormat(Qt::RichText);
    QFont statusFont = m_statusLabel->font();
    statusFont.setBold(true);
    m_statusLabel->setFont(statusFont);
    layout->addWidget(m_statusLabel);

    m_detailLabel = new QLabel(this);
    m_detailLabel->setWordWrap(true);
    m_detailLabel->setTextInteractionFlags(Qt::TextSelectableByMouse);
    layout->addWidget(m_detailLabel);

    m_installButton = new QPushButton(tr("Install risset (plugin manager)"), this);
    m_installButton->setMinimumHeight(34);
    layout->addWidget(m_installButton, 0, Qt::AlignLeft);
    connect(m_installButton, &QPushButton::clicked,
            this, &PluginsDialog::installRisset);

    m_progress = new QProgressBar(this);
    m_progress->setRange(0, 0);
    m_progress->setTextVisible(false);
    m_progress->hide();
    layout->addWidget(m_progress);

    m_log = new QPlainTextEdit(this);
    m_log->setReadOnly(true);
    m_log->setMinimumHeight(130);
    m_log->hide();
    layout->addWidget(m_log, 1);

    auto *buttons = new QDialogButtonBox(QDialogButtonBox::Close, this);
    connect(buttons, &QDialogButtonBox::rejected, this, &QDialog::close);
    layout->addWidget(buttons);

    if (m_mainWindow != nullptr) {
        connect(m_mainWindow, &CsoundQt::rissetDetectionFinished,
                this, &PluginsDialog::refresh);
    }
    refresh();
}

void PluginsDialog::refresh()
{
    if (m_mainWindow == nullptr)
        return;

    if (!m_mainWindow->rissetDetectionReady()) {
        if (!m_installing) {
            m_statusLabel->setText(tr("Looking for risset..."));
            m_detailLabel->setText(
                        tr("CsoundQt is checking whether the risset plugin "
                           "manager is available."));
            m_installButton->hide();
            m_progress->setRange(0, 0);
            m_progress->show();
        }
        return;
    }

    if (m_mainWindow->rissetIsInstalled()) {
        m_installing = false;
        m_progress->hide();
        m_installButton->hide();
        m_statusLabel->setText(
                    tr("Risset %1 is installed.").arg(m_mainWindow->rissetVersion()));
        m_detailLabel->setText(
                    tr("Plugin browsing and plugin installation will appear "
                       "here in a later version."));
        return;
    }

    if (m_installing) {
        fail(tr("risset was installed, but CsoundQt could not start it. "
                "See the log above for the command output."));
        return;
    }

    m_statusLabel->setText(tr("Risset was not found."));
    m_detailLabel->setText(
                tr("Risset is the plugin manager CsoundQt uses to discover and "
                   "install external opcode plugins. It is a Python package. "
                   "CsoundQt can install it into your user account without "
                   "administrator rights."));
    m_progress->hide();
    m_installButton->show();
    m_installButton->setEnabled(true);
}

void PluginsDialog::installRisset()
{
    if (m_installing || m_mainWindow == nullptr)
        return;

    const auto answer = QMessageBox::question(
                this, tr("Install risset"),
                tr("CsoundQt will download the uv Python runner and install "
                   "risset into:\n\n%1\n\n"
                   "This needs an internet connection and does not require "
                   "administrator rights. Continue?")
                .arg(Risset::pluginRootDir().absolutePath()),
                QMessageBox::Yes | QMessageBox::Cancel,
                QMessageBox::Yes);
    if (answer != QMessageBox::Yes)
        return;

    const QString binDir = Risset::pluginBinDir().absolutePath();
    const QString toolDir = Risset::pluginToolDir().absolutePath();
    const QString pythonDir = Risset::pluginPythonDir().absolutePath();
    if (!QDir().mkpath(binDir) || !QDir().mkpath(toolDir)
            || !QDir().mkpath(pythonDir)) {
        fail(tr("Could not create the plugin directory:\n%1")
             .arg(Risset::pluginRootDir().absolutePath()));
        return;
    }

    m_log->clear();
    m_log->show();
    m_progress->setRange(0, 0);
    m_progress->show();
    m_installButton->hide();
    setBusy(true);

    m_uvPath = findUv();
    if (!m_uvPath.isEmpty()) {
        logLine(tr("Using uv at %1").arg(m_uvPath));
        installRissetWithUv(m_uvPath);
        return;
    }

    downloadUvInstaller();
}

void PluginsDialog::downloadUvInstaller()
{
    m_statusLabel->setText(tr("Installing risset..."));
    m_detailLabel->setText(tr("Downloading the uv installer..."));
    logLine(tr("Downloading %1").arg(uvInstallerUrl()));

    m_uvInstallerPath = QDir(QStandardPaths::writableLocation(
                                 QStandardPaths::TempLocation))
            .filePath(QStringLiteral("csoundqt-uv-install-%1%2")
                      .arg(QCoreApplication::applicationPid())
                      .arg(uvInstallerSuffix()));

    if (m_network == nullptr)
        m_network = new QNetworkAccessManager(this);

    QNetworkRequest request{QUrl(uvInstallerUrl())};
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                         QNetworkRequest::NoLessSafeRedirectPolicy);
    QNetworkReply *reply = m_network->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            fail(tr("Could not download the uv installer:\n%1")
                 .arg(reply->errorString()));
            return;
        }
        QFile file(m_uvInstallerPath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            fail(tr("Could not write the uv installer to:\n%1")
                 .arg(m_uvInstallerPath));
            return;
        }
        file.write(reply->readAll());
        file.close();
        logLine(tr("Downloaded the uv installer."));
        runUvInstaller();
    });
}

void PluginsDialog::runUvInstaller()
{
    m_detailLabel->setText(tr("Installing uv..."));
    logLine(tr("Running the uv installer."));

    QProcessEnvironment environment = pluginEnvironment();
    QString program;
    QStringList arguments;
#ifdef Q_OS_WIN
    program = QStringLiteral("powershell.exe");
    arguments = {QStringLiteral("-NoProfile"),
                 QStringLiteral("-ExecutionPolicy"),
                 QStringLiteral("Bypass"),
                 QStringLiteral("-File"),
                 m_uvInstallerPath};
#else
    program = QStringLiteral("/bin/sh");
    arguments = {m_uvInstallerPath};
#endif

    runProcess(program, arguments, environment,
               [this](bool success, const QString &error) {
        QFile::remove(m_uvInstallerPath);
        if (!success) {
            fail(tr("Could not install uv:\n%1").arg(error));
            return;
        }
        m_uvPath = findUv();
        if (m_uvPath.isEmpty()) {
            fail(tr("The uv installer finished, but uv could not be found."));
            return;
        }
        logLine(tr("uv installed at %1").arg(m_uvPath));
        installRissetWithUv(m_uvPath);
    });
}

void PluginsDialog::installRissetWithUv(const QString &uvPath)
{
    m_detailLabel->setText(
                tr("Installing risset... This can take a few minutes."));
    logLine(tr("Installing risset with uv."));

    QProcessEnvironment environment = pluginEnvironment();
    environment.insert(QStringLiteral("UV_TOOL_BIN_DIR"),
                       Risset::pluginBinDir().absolutePath());
    environment.insert(QStringLiteral("UV_TOOL_DIR"),
                       Risset::pluginToolDir().absolutePath());
    environment.insert(QStringLiteral("UV_PYTHON_INSTALL_DIR"),
                       Risset::pluginPythonDir().absolutePath());

    runProcess(uvPath,
               {QStringLiteral("tool"), QStringLiteral("install"),
                QStringLiteral("--force"), QStringLiteral("risset")},
               environment,
               [this](bool success, const QString &error) {
        if (!success) {
            fail(tr("Could not install risset:\n%1").arg(error));
            return;
        }
        if (!QFile::exists(Risset::localRissetExecutable())) {
            fail(tr("uv finished, but the risset executable was not found at:\n%1")
                 .arg(Risset::localRissetExecutable()));
            return;
        }
        logLine(tr("risset installed at %1")
                .arg(Risset::localRissetExecutable()));
        verifyRisset();
    });
}

void PluginsDialog::verifyRisset()
{
    m_detailLabel->setText(tr("Checking the risset installation..."));
    runProcess(Risset::localRissetExecutable(),
               {QStringLiteral("info"), QStringLiteral("--full")},
               QProcessEnvironment::systemEnvironment(),
               [this](bool success, const QString &error) {
        if (!success) {
            fail(tr("risset was installed but could not be started:\n%1")
                 .arg(error));
            return;
        }
        if (m_mainWindow != nullptr) {
            m_statusLabel->setText(tr("Risset installed. Detecting..."));
            m_detailLabel->setText(
                        tr("CsoundQt is looking for the risset installation."));
            m_mainWindow->recheckRisset();
        }
    });
}

QString PluginsDialog::findUv() const
{
    const QString suffix = Risset::executableSuffix();
    const QStringList candidates = {
        Risset::pluginBinDir().filePath(QStringLiteral("uv") + suffix),
        QDir::home().filePath(QStringLiteral(".local/bin/uv") + suffix),
        QDir::home().filePath(QStringLiteral(".cargo/bin/uv") + suffix)
    };
    for (const QString &candidate : candidates) {
        if (QFileInfo::exists(candidate))
            return candidate;
    }
    return QStandardPaths::findExecutable(QStringLiteral("uv"));
}

void PluginsDialog::runProcess(
        const QString &program, const QStringList &arguments,
        const QProcessEnvironment &environment,
        const std::function<void(bool, const QString &)> &done)
{
    auto *process = new QProcess(this);
    m_process = process;
    process->setProcessChannelMode(QProcess::MergedChannels);
    process->setProcessEnvironment(environment);
    process->setWorkingDirectory(Risset::pluginRootDir().absolutePath());

    auto finished = std::make_shared<bool>(false);
    auto finish = [this, process, done, finished](bool success,
                                                  const QString &error) {
        if (*finished)
            return;
        *finished = true;
        if (m_process == process)
            m_process = nullptr;
        process->deleteLater();
        done(success, error);
    };

    connect(process, &QProcess::readyReadStandardOutput, this,
            [this, process]() {
        logLine(QString::fromLocal8Bit(process->readAllStandardOutput()));
    });
    connect(process, &QProcess::finished, this,
            [process, finish](int exitCode, QProcess::ExitStatus status) {
        const bool success = status == QProcess::NormalExit && exitCode == 0;
        finish(success,
               success ? QString()
                       : tr("Process exited with code %1.").arg(exitCode));
    });
    connect(process, &QProcess::errorOccurred, this,
            [process, finish](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart) {
            finish(false, tr("Could not start %1:\n%2")
                   .arg(process->program(), process->errorString()));
        }
    });

    process->start(program, arguments);
    if (!process->waitForStarted(3000))
        finish(false, tr("Could not start %1:\n%2")
               .arg(program, process->errorString()));
}

void PluginsDialog::setBusy(bool busy)
{
    m_installing = busy;
    m_installButton->setEnabled(!busy);
    if (busy)
        m_installButton->hide();
    else
        m_installButton->show();
    m_progress->setVisible(busy);
    if (busy)
        m_progress->setRange(0, 0);
}

void PluginsDialog::logLine(const QString &text)
{
    const QString trimmed = text.trimmed();
    if (trimmed.isEmpty())
        return;
    m_log->show();
    m_log->appendPlainText(trimmed);
}

void PluginsDialog::fail(const QString &message)
{
    m_installing = false;
    m_progress->hide();
    m_installButton->show();
    m_installButton->setEnabled(true);
    m_statusLabel->setText(tr("Installation failed."));
    m_detailLabel->setText(message);
    logLine(message);
}
