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

private slots:
    void refresh();
    void installRisset();

private:
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
};

#endif // PLUGINSDIALOG_H
