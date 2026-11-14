#ifndef PLUGINSDIALOG_H
#define PLUGINSDIALOG_H

#include <QDialog>
#include <QPointer>
#include <QProcessEnvironment>
#include <QStringList>

#include <functional>

class CsoundQt;
class QLabel;
class QPlainTextEdit;
class QProgressBar;
class QPushButton;
class QNetworkAccessManager;
class QProcess;

// Plugins window. The first version focuses on the "risset is not installed"
// case: it explains what risset is and installs it into a user-writable
// CsoundQt directory using uv. Plugin browsing and installation will be added
// once risset is detected.
class PluginsDialog : public QDialog
{
    Q_OBJECT
public:
    explicit PluginsDialog(CsoundQt *mainWindow, QWidget *parent = nullptr);

    // Starts the installation without asking for confirmation. The regular
    // user path is installRisset(), which asks first. The application's
    // --self-test-risset-install mode uses this entry point so that CI
    // exercises the same code as the window.
    void startInstallation();

signals:
    // The installation commands have finished. On success CsoundQt still has
    // to re-detect risset; watch CsoundQt::rissetDetectionFinished for that.
    void installationFinished(bool success, const QString &error);
    // Progress text, mirroring what the log view shows.
    void message(const QString &text);

private slots:
    void refresh();
    void installRisset();

private:
    void emitInstallationFinished(bool success, const QString &error);
    void setBusy(bool busy);
    void logLine(const QString &text);
    void fail(const QString &message);
    QString findUv() const;
    void downloadUvInstaller();
    void runUvInstaller();
    void installRissetWithUv(const QString &uvPath);
    void verifyRisset();
    void runProcess(const QString &program, const QStringList &arguments,
                    const QProcessEnvironment &environment,
                    const std::function<void(bool, const QString &)> &done);

    CsoundQt *m_mainWindow = nullptr;
    QLabel *m_statusLabel = nullptr;
    QLabel *m_detailLabel = nullptr;
    QPushButton *m_installButton = nullptr;
    QProgressBar *m_progress = nullptr;
    QPlainTextEdit *m_log = nullptr;
    QNetworkAccessManager *m_network = nullptr;
    QProcess *m_process = nullptr;
    QString m_uvInstallerPath;
    QString m_uvPath;
    bool m_installing = false;
    bool m_installationFinished = false;
};

#endif // PLUGINSDIALOG_H
