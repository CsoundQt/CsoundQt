#ifndef PLUGINSDIALOG_H
#define PLUGINSDIALOG_H

#include <QDialog>
#include <QJsonObject>
#include <QPair>
#include <QPointer>
#include <QProcessEnvironment>
#include <QStringList>
#include <QVector>

#include <functional>

class CsoundQt;
class BusySpinner;
class QAbstractButton;
class QCheckBox;
class QDialogButtonBox;
class QLabel;
class QPlainTextEdit;
class QProgressBar;
class QPushButton;
class QNetworkAccessManager;
class QProcess;
class QTableWidget;

// Plugins window. When risset is missing it explains what risset is and
// installs it into a user-writable CsoundQt directory using uv. Once risset is
// available it lists the plugins that have a binary for this platform and
// Csound version, and installs or removes them on Apply/OK.
class PluginsDialog : public QDialog
{
    Q_OBJECT
public:
    explicit PluginsDialog(CsoundQt *mainWindow, QWidget *parent = nullptr);
    ~PluginsDialog() override;

    // Restrict the table to unmet dependencies. These plugins are preselected
    // for installation, and the footer exposes only Update, OK and Cancel.
    void setDependencyFilter(const QStringList &plugins);

    // Starts the installation without asking for confirmation. The regular
    // user path is installRisset(), which asks first. The application's
    // --self-test-risset-install mode uses this entry point so that CI
    // exercises the same code as the window.
    void startInstallation();

    // Suppress modal warnings during scripted tests. Failures are still
    // reported through the status labels and pluginApplyFinished().
    void setSilent(bool silent) { m_silent = silent; }

signals:
    // The installation commands have finished. On success CsoundQt still has
    // to re-detect risset; watch CsoundQt::rissetDetectionFinished for that.
    void installationFinished(bool success, const QString &error);
    // The plugin operations triggered by Apply or OK have finished. Emitted
    // also when the dialog closes itself after a successful OK.
    void pluginApplyFinished(bool success, const QString &error);
    // Progress text, mirroring what the log view shows.
    void message(const QString &text);

private slots:
    void refresh();
    void installRisset();
    void buttonBoxClicked(QAbstractButton *button);

private:
    void emitInstallationFinished(bool success, const QString &error);
    void setBusy(bool busy);
    void logLine(const QString &text);
    void fail(const QString &message);
    QString findUv() const;
    void downloadUvInstaller();
    void downloadUvInstallerWithExternalTools(const QString &networkError);
    void runUvInstaller();
    void installRissetWithUv(const QString &uvPath);
    void verifyRisset();
    void runProcess(const QString &program, const QStringList &arguments,
                    const QProcessEnvironment &environment,
                    const std::function<void(bool, const QString &)> &done);

    // Plugin table and risset queries
    void showLoadingUi(const QString &message);
    void showRissetInstallUi();
    QString pluginExecutable() const;
    void loadPluginInfo();
    void startInfoProcess(bool withOutfile);
    void handleInfoFinished();
    void handleInfoFailed(const QString &message);
    void populatePluginTable(const QJsonObject &info);
    void updateDialogButtons();
    void runRissetCommand(const QString &label, const QStringList &arguments,
                          bool reloadPlugins, bool regenerateOpcodes);
    void updateApplyState();
    void setLogVisible(bool visible);
    void applyPluginChanges(bool closeAfter);
    void runNextPluginOperation();
    void finishPluginApply(bool success, const QString &error);
    void setPluginUiEnabled(bool enabled);
    void showPluginInfo(const QString &name);

    CsoundQt *m_mainWindow = nullptr;
    QLabel *m_statusLabel = nullptr;
    QLabel *m_detailLabel = nullptr;
    BusySpinner *m_spinner = nullptr;
    QWidget *m_bottomSpacer = nullptr;
    QPushButton *m_installButton = nullptr;
    QPushButton *m_reloadButton = nullptr;
    QPushButton *m_updateRissetButton = nullptr;
    QPushButton *m_updateDocsButton = nullptr;
    QTableWidget *m_table = nullptr;
    QDialogButtonBox *m_buttons = nullptr;
    QProgressBar *m_progress = nullptr;
    QPushButton *m_logToggle = nullptr;
    QPlainTextEdit *m_log = nullptr;
    QNetworkAccessManager *m_network = nullptr;
    QProcess *m_process = nullptr;
    QProcess *m_infoProcess = nullptr;
    QString m_uvInstallerPath;
    QString m_uvPath;
    QString m_infoFilePath;
    QString m_infoExecutable;
    QJsonObject m_pluginInfo;
    QStringList m_dependencyFilter;
    QVector<QCheckBox *> m_installedChecks;
    QVector<QCheckBox *> m_upgradeChecks;
    enum class PluginOperationKind { Install, Remove, Upgrade };
    struct PluginOperation {
        QString name;
        PluginOperationKind kind = PluginOperationKind::Install;
    };
    QVector<PluginOperation> m_pluginOperations;
    int m_operationIndex = 0;
    int m_infoRequest = 0;
    bool m_installing = false;
    bool m_installationFinished = false;
    bool m_loadingInfo = false;
    bool m_infoLoaded = false;
    bool m_infoFallbackTried = false;
    bool m_applying = false;
    bool m_closeAfterApply = false;
    bool m_dependencyMode = false;
    bool m_upgradesAvailable = false;
    bool m_silent = false;
};

#endif // PLUGINSDIALOG_H
