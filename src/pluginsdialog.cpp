#include "pluginsdialog.h"

#include "csoundqt.h"
#include "risset.h"
#include "widgetstyle.h"

#include <QAbstractButton>
#include <QCheckBox>
#include <QCoreApplication>
#include <QDialogButtonBox>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFontDatabase>
#include <QFontMetrics>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLabel>
#include <QMessageBox>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPainter>
#include <QPlainTextEdit>
#include <QProcess>
#include <QProcessEnvironment>
#include <QProgressBar>
#include <QPushButton>
#include <QRegularExpression>
#include <QSignalBlocker>
#include <QStandardPaths>
#include <QStyle>
#include <QStyledItemDelegate>
#include <QStyleOptionViewItem>
#include <QTableWidget>
#include <QTableWidgetItem>
#include <QTimer>
#include <QVersionNumber>
#include <QVBoxLayout>
#include <QtMath>

#include <memory>
#include <utility>
using namespace Qt::StringLiterals;

namespace {

QString uvInstallerUrl()
{
#ifdef Q_OS_WIN
    return u"https://astral.sh/uv/install.ps1"_s;
#else
    return u"https://astral.sh/uv/install.sh"_s;
#endif
}

QString uvInstallerSuffix()
{
#ifdef Q_OS_WIN
    return u".ps1"_s;
#else
    return u".sh"_s;
#endif
}

QProcessEnvironment pluginEnvironment()
{
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(u"UV_UNMANAGED_INSTALL"_s,
                       Risset::pluginBinDir().absolutePath());
    environment.insert(u"UV_NO_MODIFY_PATH"_s, u"1"_s);
    environment.insert(u"UV_DISABLE_UPDATE"_s, u"1"_s);
    environment.insert(u"UV_NO_PROGRESS"_s, u"1"_s);
    environment.insert(u"UV_COLOR"_s, u"never"_s);
    environment.insert(u"UV_LINK_MODE"_s, u"copy"_s);
    return environment;
}

QJsonObject parseJsonObject(const QByteArray &data)
{
    QJsonParseError error{};
    const QJsonDocument document = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError || !document.isObject())
        return {};
    return document.object();
}

QString withoutAnsiEscapes(QString text)
{
    static const QRegularExpression ansi(u"\x1b\\[[0-9;]*[A-Za-z]"_s);
    text.remove(ansi);
    return text;
}

bool hasVersionUpgrade(const QString &available, const QString &installed)
{
    const QVersionNumber availableVersion = QVersionNumber::fromString(available);
    const QVersionNumber installedVersion = QVersionNumber::fromString(installed);
    return !availableVersion.isNull() && !installedVersion.isNull()
            && QVersionNumber::compare(availableVersion, installedVersion) > 0;
}

} // namespace

// Small indeterminate spinner for the states where CsoundQt waits for risset
// (checking whether it is installed, or querying the plugin list).
class BusySpinner : public QWidget
{
public:
    explicit BusySpinner(QWidget *parent = nullptr)
        : QWidget(parent)
    {
        setAttribute(Qt::WA_TransparentForMouseEvents, true);
        setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
        m_timer = new QTimer(this);
        m_timer->setInterval(80);
        connect(m_timer, &QTimer::timeout, this, [this]() {
            m_angle = (m_angle + 30) % 360;
            update();
        });
    }

    QSize sizeHint() const override { return QSize(44, 44); }

    void start()
    {
        show();
        m_timer->start();
    }

    void stop()
    {
        m_timer->stop();
        hide();
    }

protected:
    void paintEvent(QPaintEvent *) override
    {
        QPainter painter(this);
        painter.setRenderHint(QPainter::Antialiasing);
        const QColor color = palette().color(QPalette::Highlight);
        const QPointF center = QPointF(rect().center()) + QPointF(0.5, 0.5);
        const qreal outer = qMin(width(), height()) / 2.0 - 3.0;
        const qreal inner = outer - 5.0;
        const int segments = 12;

        for (int i = 0; i < segments; ++i) {
            QColor segment = color;
            segment.setAlphaF(0.15 + 0.85 * (i / qreal(segments)));
            QPen pen(segment, 3.0, Qt::SolidLine, Qt::RoundCap);
            painter.setPen(pen);
            const qreal angle = qDegreesToRadians(qreal(m_angle + i * 30));
            const QPointF start(center.x() + inner * qCos(angle),
                                center.y() + inner * qSin(angle));
            const QPointF end(center.x() + outer * qCos(angle),
                              center.y() + outer * qSin(angle));
            painter.drawLine(start, end);
        }
    }

private:
    QTimer *m_timer = nullptr;
    int m_angle = 0;
};

// Keep the current-cell keyboard focus indicator off passive text columns.
// Their items are intentionally non-selectable, so a focus rectangle around
// the clicked version/description cell is misleading. All other style drawing
// is delegated unchanged.
class PassiveCellDelegate : public QStyledItemDelegate
{
public:
    using QStyledItemDelegate::QStyledItemDelegate;

    void paint(QPainter *painter, const QStyleOptionViewItem &option,
               const QModelIndex &index) const override
    {
        QStyleOptionViewItem passiveOption(option);
        passiveOption.state &= ~QStyle::State_HasFocus;
        QStyledItemDelegate::paint(painter, passiveOption, index);
    }
};

PluginsDialog::PluginsDialog(CsoundQt *mainWindow, QWidget *parent)
    : QDialog(parent), m_mainWindow(mainWindow)
{
    setWindowTitle(tr("Plugins"));
    setMinimumSize(760, 480);
    resize(900, 620);

    auto *layout = new QVBoxLayout(this);

    auto *title = new QLabel(tr("<h2>Plugins</h2>"), this);
    title->setTextFormat(Qt::RichText);
    title->setSizePolicy(QSizePolicy::Preferred, QSizePolicy::Fixed);
    layout->addWidget(title);

    m_statusLabel = new QLabel(this);
    m_statusLabel->setObjectName(u"pluginsStatusLabel"_s);
    m_statusLabel->setTextFormat(Qt::RichText);
    QFont statusFont = m_statusLabel->font();
    statusFont.setBold(true);
    m_statusLabel->setFont(statusFont);
    m_statusLabel->setSizePolicy(QSizePolicy::Preferred, QSizePolicy::Fixed);
    m_statusLabel->setAlignment(Qt::AlignLeft | Qt::AlignVCenter);
    layout->addWidget(m_statusLabel);

    m_detailLabel = new QLabel(this);
    m_detailLabel->setObjectName(u"pluginsDetailLabel"_s);
    m_detailLabel->setWordWrap(true);
    m_detailLabel->setTextInteractionFlags(Qt::TextSelectableByMouse);
    m_detailLabel->setSizePolicy(QSizePolicy::Preferred, QSizePolicy::Minimum);
    m_detailLabel->setAlignment(Qt::AlignLeft | Qt::AlignTop);
    // Use the palette's muted text role so explanatory/status details read
    // like comments and stay legible in both light and dark themes.
    m_detailLabel->setForegroundRole(QPalette::PlaceholderText);
    layout->addWidget(m_detailLabel);

    m_spinner = new BusySpinner(this);
    m_spinner->hide();
    layout->addWidget(m_spinner, 1, Qt::AlignCenter);

    m_reloadButton = new QPushButton(tr("Reload plugin list"), this);
    m_reloadButton->hide();
    layout->addWidget(m_reloadButton, 0, Qt::AlignLeft);
    connect(m_reloadButton, &QPushButton::clicked,
            this, &PluginsDialog::loadPluginInfo);

    m_table = new QTableWidget(0, 7, this);
    m_table->setObjectName(u"pluginsTable"_s);
    m_table->setHorizontalHeaderLabels(
                {tr("Name"), QString(), tr("Installed"), tr("Version"),
                 tr("Short description"), tr("Info"), tr("Upgrade")});
    m_table->verticalHeader()->setVisible(false);
    m_table->verticalHeader()->setDefaultSectionSize(30);
    m_table->setSelectionMode(QAbstractItemView::NoSelection);
    // Keep each platform's table frame and header style, but remove the
    // per-cell internal grid lines.
    m_table->setShowGrid(false);
    m_table->setWordWrap(false);
    m_table->setSortingEnabled(false);
    m_table->horizontalHeader()->setSectionResizeMode(
                0, QHeaderView::Fixed);
    m_table->horizontalHeader()->setSectionResizeMode(
                1, QHeaderView::Fixed);
    m_table->horizontalHeader()->setSectionResizeMode(
                2, QHeaderView::ResizeToContents);
    m_table->horizontalHeader()->setSectionResizeMode(
                3, QHeaderView::ResizeToContents);
    m_table->horizontalHeader()->setSectionResizeMode(
                4, QHeaderView::Stretch);
    m_table->horizontalHeader()->setSectionResizeMode(
                5, QHeaderView::ResizeToContents);
    m_table->horizontalHeader()->setSectionResizeMode(
                6, QHeaderView::ResizeToContents);
    m_table->setColumnWidth(
                1, m_table->style()->pixelMetric(
                    QStyle::PM_IndicatorWidth, nullptr, m_table) + 12);
    m_table->setItemDelegateForColumn(0, new PassiveCellDelegate(m_table));
    m_table->setItemDelegateForColumn(2, new PassiveCellDelegate(m_table));
    m_table->setItemDelegateForColumn(3, new PassiveCellDelegate(m_table));
    m_table->setItemDelegateForColumn(4, new PassiveCellDelegate(m_table));

    QString styleName = installedWidgetStyleName();
    if (styleName.isEmpty())
        styleName = currentWidgetStyleName();
    const bool fusionStyle = styleName.compare(
                u"fusion"_s, Qt::CaseInsensitive) == 0;

    const QPalette appPalette = palette();
    const bool darkPalette = appPalette.color(QPalette::Window).lightness()
            < appPalette.color(QPalette::WindowText).lightness();
    if (darkPalette && fusionStyle) {
        QPalette tablePalette = m_table->palette();
        tablePalette.setColor(QPalette::Base,
                              QColor(u"#3f3f3f"_s));
        tablePalette.setColor(QPalette::AlternateBase,
                              QColor(u"#383838"_s));
        m_table->setPalette(tablePalette);
        m_table->viewport()->setPalette(tablePalette);
    }
    m_table->hide();
    layout->addWidget(m_table, 1);

    m_installButton = new QPushButton(tr("Install risset (plugin manager)"), this);
    m_installButton->setObjectName(u"installRissetButton"_s);
    m_installButton->setMinimumHeight(34);
    m_installButton->hide();
    layout->addWidget(m_installButton, 0, Qt::AlignLeft);
    connect(m_installButton, &QPushButton::clicked,
            this, &PluginsDialog::installRisset);

    m_progress = new QProgressBar(this);
    m_progress->setRange(0, 0);
    m_progress->setTextVisible(false);
    m_progress->hide();
    layout->addWidget(m_progress);

    m_logToggle = new QPushButton(tr("Show command output ▼"), this);
    m_logToggle->setAutoDefault(false);
    m_logToggle->setDefault(false);
    m_logToggle->hide();
    layout->addWidget(m_logToggle, 0, Qt::AlignLeft);
    connect(m_logToggle, &QPushButton::clicked, this, [this]() {
        setLogVisible(!m_log->isVisible());
    });

    m_log = new QPlainTextEdit(this);
    m_log->setReadOnly(true);
    m_log->setMinimumHeight(130);
    m_log->setMaximumHeight(220);
    m_log->hide();
    layout->addWidget(m_log, 1);

    // Absorbs the free space in states without a table, spinner or log (the
    // risset install page and the info-load error page), keeping those pages
    // packed below the title instead of spreading their labels vertically.
    m_bottomSpacer = new QWidget(this);
    m_bottomSpacer->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Expanding);
    m_bottomSpacer->hide();
    layout->addWidget(m_bottomSpacer, 1);

    m_updateRissetButton = new QPushButton(tr("Update"), this);
    m_updateRissetButton->setAutoDefault(false);
    m_updateRissetButton->setDefault(false);
    m_updateRissetButton->hide();
    connect(m_updateRissetButton, &QPushButton::clicked, this, [this]() {
        runRissetCommand(tr("Updating risset..."),
                         {u"update"_s}, true, true);
    });

    m_updateDocsButton = new QPushButton(tr("Update Documentation"), this);
    m_updateDocsButton->setAutoDefault(false);
    m_updateDocsButton->setDefault(false);
    m_updateDocsButton->hide();
    connect(m_updateDocsButton, &QPushButton::clicked, this, [this]() {
        runRissetCommand(tr("Updating documentation..."),
                         {u"makedocs"_s}, false, false);
    });

    m_buttons = new QDialogButtonBox(QDialogButtonBox::Close, this);
    m_buttons->setObjectName(u"pluginsButtonBox"_s);
    connect(m_buttons, &QDialogButtonBox::clicked,
            this, &PluginsDialog::buttonBoxClicked);
    auto *footer = new QHBoxLayout;
    footer->addWidget(m_updateRissetButton);
    footer->addWidget(m_updateDocsButton);
    footer->addStretch(1);
    footer->addWidget(m_buttons);
    layout->addLayout(footer);

    if (m_mainWindow != nullptr) {
        connect(m_mainWindow, &CsoundQt::rissetDetectionFinished,
                this, &PluginsDialog::refresh);
    }
    refresh();
}

PluginsDialog::~PluginsDialog()
{
    if (!m_infoFilePath.isEmpty())
        QFile::remove(m_infoFilePath);
}

void PluginsDialog::setDependencyFilter(const QStringList &plugins)
{
    if (m_applying)
        return;
    m_dependencyFilter.clear();
    for (const QString &plugin : plugins) {
        const QString name = plugin.trimmed();
        if (name.isEmpty() || m_dependencyFilter.contains(name, Qt::CaseInsensitive))
            continue;
        m_dependencyFilter.append(name);
    }
    m_dependencyMode = !m_dependencyFilter.isEmpty();

    if (m_infoLoaded) {
        populatePluginTable(m_pluginInfo);
    } else if (m_loadingInfo) {
        showLoadingUi(tr("Loading plugins..."));
    } else {
        refresh();
    }
}

void PluginsDialog::updateDialogButtons()
{
    if (m_dependencyMode) {
        m_buttons->setStandardButtons(QDialogButtonBox::Ok
                                      | QDialogButtonBox::Cancel);
        m_updateRissetButton->show();
        m_updateDocsButton->hide();
    } else {
        m_buttons->setStandardButtons(QDialogButtonBox::Ok
                                      | QDialogButtonBox::Apply
                                      | QDialogButtonBox::Cancel);
        m_updateRissetButton->show();
        m_updateDocsButton->show();
    }
}

void PluginsDialog::refresh()
{
    if (m_mainWindow == nullptr)
        return;
    if (m_applying)
        return; // plugin operations own the UI until they finish

    if (!m_mainWindow->rissetDetectionReady()) {
        if (!m_installing) {
            showLoadingUi(tr("Checking for risset..."));
            // The dialog may have been opened before the startup probe. Start
            // it now; initRisset() is idempotent.
            m_mainWindow->initRisset();
        }
        return;
    }

    if (!m_mainWindow->rissetIsInstalled()) {
        if (m_installing) {
            fail(tr("risset was installed, but CsoundQt could not start it. "
                    "See the log above for the command output."));
            return;
        }
        showRissetInstallUi();
        return;
    }

    m_installing = false;
    m_installButton->hide();
    if (m_infoLoaded) {
        m_spinner->stop();
        m_bottomSpacer->hide();
        m_progress->hide();
        m_statusLabel->show();
        m_detailLabel->show();
        m_statusLabel->setText(
                    tr("Risset %1 is installed.").arg(m_mainWindow->rissetVersion()));
        updateDialogButtons();
        m_table->show();
        updateApplyState();
    } else if (!m_loadingInfo) {
        loadPluginInfo();
    }
}

void PluginsDialog::showLoadingUi(const QString &message)
{
    Q_UNUSED(message);
    m_statusLabel->hide();
    m_detailLabel->hide();
    m_table->hide();
    m_reloadButton->hide();
    m_installButton->hide();
    m_updateRissetButton->hide();
    m_updateDocsButton->hide();
    m_progress->hide();
    m_bottomSpacer->hide();
    m_spinner->start();
    if (m_dependencyMode)
        m_buttons->setStandardButtons(QDialogButtonBox::Ok
                                      | QDialogButtonBox::Cancel);
    else
        m_buttons->setStandardButtons(QDialogButtonBox::Close);
    m_updateRissetButton->setVisible(m_dependencyMode);
    m_updateDocsButton->hide();
}

void PluginsDialog::showRissetInstallUi()
{
    m_spinner->stop();
    m_bottomSpacer->show();
    m_statusLabel->show();
    m_detailLabel->show();
    m_statusLabel->setText(tr("Risset was not found."));
    m_detailLabel->setText(
                tr("Risset is the plugin manager CsoundQt uses to discover and "
                   "install external opcode plugins. It is a Python package. "
                   "CsoundQt can install it into your user account without "
                   "administrator rights."));
    m_detailLabel->show();
    m_table->hide();
    m_reloadButton->hide();
    m_progress->hide();
    m_installButton->show();
    m_installButton->setEnabled(true);
    m_updateRissetButton->hide();
    m_updateDocsButton->hide();
    m_buttons->setStandardButtons(QDialogButtonBox::Close);
}

QString PluginsDialog::pluginExecutable() const
{
    if (m_mainWindow != nullptr && m_mainWindow->risset != nullptr)
        return m_mainWindow->risset->executablePath();
    return m_infoExecutable;
}

void PluginsDialog::loadPluginInfo()
{
    if (m_mainWindow == nullptr || !m_mainWindow->rissetIsInstalled())
        return;
    if (m_infoProcess != nullptr)
        return;

    m_infoExecutable = pluginExecutable();
    if (m_infoExecutable.isEmpty()) {
        handleInfoFailed(tr("CsoundQt does not know where risset is installed."));
        return;
    }

    m_loadingInfo = true;
    m_infoLoaded = false;
    m_infoFallbackTried = false;
    showLoadingUi(tr("Loading plugins..."));

    m_infoFilePath = QDir(QStandardPaths::writableLocation(
                              QStandardPaths::TempLocation))
            .filePath(u"csoundqt-risset-info-%1-%2.json"_s
                      .arg(QCoreApplication::applicationPid())
                      .arg(++m_infoRequest));
    QFile::remove(m_infoFilePath);
    startInfoProcess(true);
}

void PluginsDialog::startInfoProcess(bool withOutfile)
{
    if (m_infoProcess == nullptr) {
        m_infoProcess = new QProcess(this);
        m_infoProcess->setProcessChannelMode(QProcess::SeparateChannels);
        connect(m_infoProcess, &QProcess::finished, this,
                [this](int, QProcess::ExitStatus) { handleInfoFinished(); });
        connect(m_infoProcess, &QProcess::errorOccurred, this,
                [this](QProcess::ProcessError error) {
            if (error != QProcess::FailedToStart || m_infoProcess == nullptr)
                return;
            const QString message = m_infoProcess->errorString();
            m_infoProcess->deleteLater();
            m_infoProcess = nullptr;
            handleInfoFailed(message);
        });
    }

    QStringList arguments = {u"info"_s, u"--full"_s};
    if (withOutfile)
        arguments << u"--outfile"_s << m_infoFilePath;
    m_infoProcess->start(m_infoExecutable, arguments);
}

void PluginsDialog::handleInfoFinished()
{
    if (m_infoProcess == nullptr)
        return;

    const QProcess::ExitStatus status = m_infoProcess->exitStatus();
    const int exitCode = m_infoProcess->exitCode();

    QByteArray payload;
    if (!m_infoFilePath.isEmpty()) {
        QFile file(m_infoFilePath);
        if (file.exists() && file.open(QIODevice::ReadOnly))
            payload = file.readAll();
    }
    const QByteArray standardOutput = m_infoProcess->readAllStandardOutput();
    const QByteArray standardError = m_infoProcess->readAllStandardError();

    QJsonObject info = parseJsonObject(payload);
    if (info.isEmpty())
        info = parseJsonObject(standardOutput);

    if (info.isEmpty() && !m_infoFallbackTried) {
        // Older risset versions do not support --outfile for info. Try the
        // plain stdout form before giving up.
        m_infoFallbackTried = true;
        QFile::remove(m_infoFilePath);
        startInfoProcess(false);
        return;
    }

    m_infoProcess->deleteLater();
    m_infoProcess = nullptr;
    QFile::remove(m_infoFilePath);
    m_infoFilePath.clear();
    m_loadingInfo = false;
    m_progress->hide();

    if (info.isEmpty()) {
        QString reason = status == QProcess::CrashExit
                ? tr("risset crashed.")
                : tr("risset exited with code %1.").arg(exitCode);
        const QString errorText = QString::fromLocal8Bit(standardError).trimmed();
        if (!errorText.isEmpty())
            reason += '\n'_L1 + errorText;
        handleInfoFailed(reason);
        return;
    }

    m_infoLoaded = true;
    populatePluginTable(info);
}

void PluginsDialog::handleInfoFailed(const QString &message)
{
    if (m_infoProcess != nullptr) {
        m_infoProcess->deleteLater();
        m_infoProcess = nullptr;
    }
    if (!m_infoFilePath.isEmpty()) {
        QFile::remove(m_infoFilePath);
        m_infoFilePath.clear();
    }
    m_loadingInfo = false;
    m_infoLoaded = false;
    m_upgradesAvailable = false;
    m_spinner->stop();
    m_bottomSpacer->show();
    m_progress->hide();
    m_table->hide();
    m_installButton->hide();
    m_reloadButton->show();
    updateDialogButtons();
    m_statusLabel->show();
    m_detailLabel->show();
    if (m_mainWindow != nullptr && m_mainWindow->rissetIsInstalled()) {
        m_statusLabel->setText(
                    tr("Risset %1 is installed.").arg(m_mainWindow->rissetVersion()));
    }
    m_detailLabel->setText(
                tr("Could not read the plugin list:\n%1").arg(message));
    m_detailLabel->show();
    if (auto *apply = m_buttons->button(QDialogButtonBox::Apply))
        apply->setEnabled(false);
}

void PluginsDialog::populatePluginTable(const QJsonObject &info)
{
    m_pluginInfo = info;
    const QJsonObject plugins = info.value(u"plugins"_s).toObject();
    QStringList names = plugins.keys();
    names.sort(Qt::CaseInsensitive);
    QFont boldNameFont = m_table->font();
    boldNameFont.setBold(true);
    const QFontMetrics boldNameMetrics(boldNameFont);
    int nameColumnWidth = boldNameMetrics.horizontalAdvance(
                m_table->horizontalHeaderItem(0)->text()) + 24;

    m_spinner->stop();
    m_bottomSpacer->hide();
    m_progress->hide();
    m_statusLabel->show();
    m_detailLabel->show();
    m_installedChecks.clear();
    m_upgradeChecks.clear();
    m_upgradesAvailable = false;
    const QSignalBlocker blocker(m_table);
    m_table->setRowCount(0);

    for (const QString &name : names) {
        const QJsonObject plugin = plugins.value(name).toObject();
        const bool installed = plugin.value(u"installed"_s).toBool();
        // risset's info command already filters by the current platform and
        // Csound version; keep the guard for completeness.
        const bool available = plugin.value(u"available"_s).toBool(true);
        if (!installed && !available)
            continue;
        if (m_dependencyMode
                && !m_dependencyFilter.contains(name, Qt::CaseInsensitive))
            continue;

        const QString version = plugin.value(u"version"_s).toString();
        const QString installedVersion =
                plugin.value(u"installed-version"_s).toString();
        const bool upgradeAvailable = installed && available
                && !m_dependencyMode
                && hasVersionUpgrade(version, installedVersion);
        m_upgradesAvailable = m_upgradesAvailable || upgradeAvailable;

        nameColumnWidth = qMax(nameColumnWidth,
                               boldNameMetrics.horizontalAdvance(name) + 24);

        const int row = m_table->rowCount();
        m_table->insertRow(row);

        auto *nameItem = new QTableWidgetItem(name);
        nameItem->setFlags(Qt::ItemIsEnabled);
        nameItem->setToolTip(name);
        nameItem->setData(Qt::UserRole, name);
        nameItem->setData(Qt::UserRole + 1, nameItem->font().bold());
        m_table->setItem(row, 0, nameItem);

        auto *installedItem = new QTableWidgetItem;
        // The cell item itself is inert; only the checkbox in the cell widget
        // below should be interactive.
        installedItem->setFlags(Qt::NoItemFlags);
        m_table->setItem(row, 1, installedItem);

        auto *checkBox = new QCheckBox(m_table);
        checkBox->setChecked(installed || m_dependencyMode);
        checkBox->setProperty("csqtInitialInstalled", installed);
        checkBox->setToolTip(tr("Check to install, uncheck to remove"));
        checkBox->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
        // Keep the widget square around the indicator. The default size hint
        // includes space for the (empty) label, which would make the empty
        // part of the cell clickable. Use the style's preferred height so a
        // native style's indicator border is not clipped.
        // const int indicator = qMax(
        //             checkBox->style()->pixelMetric(
        //                 QStyle::PM_IndicatorWidth, nullptr, checkBox),
        //             checkBox->style()->pixelMetric(
        //                 QStyle::PM_IndicatorHeight, nullptr, checkBox));
        // const int side = qMax(indicator, checkBox->sizeHint().height());
        // checkBox->setFixedSize(side, side);
        auto *checkContainer = new QWidget(m_table);
        auto *checkLayout = new QHBoxLayout(checkContainer);
        checkLayout->setContentsMargins(0, 0, 0, 0);
        checkLayout->setSpacing(0);
        checkLayout->addStretch(1);
        checkLayout->addWidget(checkBox, 0, Qt::AlignCenter);
        checkLayout->addStretch(1);
        m_table->setCellWidget(row, 1, checkContainer);
        m_installedChecks.append(checkBox);
        connect(checkBox, &QCheckBox::toggled,
                this, &PluginsDialog::updateApplyState);

        const QString installedVersionText = installed
                && !installedVersion.isEmpty()
                ? installedVersion : u"—"_s;
        auto *installedVersionItem = new QTableWidgetItem(installedVersionText);
        installedVersionItem->setFlags(Qt::ItemIsEnabled);
        installedVersionItem->setToolTip(installedVersionText);
        m_table->setItem(row, 2, installedVersionItem);

        auto *versionItem = new QTableWidgetItem(version);
        versionItem->setFlags(Qt::ItemIsEnabled);
        versionItem->setToolTip(version);
        m_table->setItem(row, 3, versionItem);

        const QString description =
                plugin.value(u"short_description"_s).toString();
        auto *descriptionItem = new QTableWidgetItem(description);
        descriptionItem->setFlags(Qt::ItemIsEnabled);
        descriptionItem->setToolTip(description);
        m_table->setItem(row, 4, descriptionItem);

        auto *infoButton = new QPushButton(tr("Info"), m_table);
        infoButton->setAutoDefault(false);
        infoButton->setDefault(false);
        infoButton->setFocusPolicy(Qt::NoFocus);
        infoButton->setMinimumWidth(56);
        connect(infoButton, &QPushButton::clicked, this,
                [this, name]() { showPluginInfo(name); });
        m_table->setCellWidget(row, 5, infoButton);

        auto *upgradeItem = new QTableWidgetItem;
        upgradeItem->setFlags(Qt::NoItemFlags);
        m_table->setItem(row, 6, upgradeItem);
        if (upgradeAvailable) {
            auto *upgradeCheck = new QCheckBox(m_table);
            upgradeCheck->setToolTip(tr("Select to upgrade this plugin"));
            auto *upgradeContainer = new QWidget(m_table);
            auto *upgradeLayout = new QHBoxLayout(upgradeContainer);
            upgradeLayout->setContentsMargins(0, 0, 0, 0);
            upgradeLayout->setSpacing(0);
            upgradeLayout->addStretch(1);
            upgradeLayout->addWidget(upgradeCheck, 0, Qt::AlignCenter);
            upgradeLayout->addStretch(1);
            m_table->setCellWidget(row, 6, upgradeContainer);
            m_upgradeChecks.append(upgradeCheck);
            connect(upgradeCheck, &QCheckBox::toggled,
                    this, &PluginsDialog::updateApplyState);
        } else {
            // Keep the vectors row-aligned with the install checkboxes.
            m_upgradeChecks.append(nullptr);
        }
    }

    m_table->setColumnHidden(6, !m_upgradesAvailable);
    if (m_upgradesAvailable) {
        // Ad-hoc row: empty except for an "All" button in the Upgrade column,
        // which selects every available upgrade.
        const int row = m_table->rowCount();
        m_table->insertRow(row);
        for (int column = 0; column < 6; ++column) {
            auto *item = new QTableWidgetItem;
            item->setFlags(Qt::NoItemFlags);
            m_table->setItem(row, column, item);
        }
        auto *allButton = new QPushButton(tr("All"), m_table);
        allButton->setAutoDefault(false);
        allButton->setDefault(false);
        allButton->setFocusPolicy(Qt::NoFocus);
        allButton->setToolTip(tr("Select all available upgrades"));
        connect(allButton, &QPushButton::clicked, this, [this]() {
            for (QCheckBox *upgrade : std::as_const(m_upgradeChecks)) {
                if (upgrade == nullptr || !upgrade->isEnabled())
                    continue;
                const QSignalBlocker blocker(upgrade);
                upgrade->setChecked(true);
            }
            updateApplyState();
        });
        m_table->setCellWidget(row, 6, allButton);
    }

    m_table->resizeColumnsToContents();
    // The name section is fixed so bolding a pending change cannot resize it
    // and shift the other columns. Its width is measured using bold text above.
    m_table->setColumnWidth(0, nameColumnWidth);
    m_table->setColumnWidth(
                1, m_table->style()->pixelMetric(
                    QStyle::PM_IndicatorWidth, nullptr, m_table) + 12);
    m_table->horizontalHeader()->setSectionResizeMode(4, QHeaderView::Stretch);
    m_table->show();
    m_updateRissetButton->show();
    m_updateDocsButton->setVisible(!m_dependencyMode);
    m_statusLabel->setText(
                tr("Risset %1 is installed.").arg(m_mainWindow->rissetVersion()));
    updateDialogButtons();

    if (m_table->rowCount() == 0) {
        m_detailLabel->setText(
                    tr("No plugins available"));
        m_reloadButton->show();
    } else if (m_dependencyMode) {
        m_detailLabel->setText(
                    tr("Required plugins are selected for installation. "
                       "Press OK to install them."));
        m_reloadButton->hide();
    } else {
        m_detailLabel->setText(
                    tr("%1 plugins available. "
                       "Check a plugin to install, uncheck to "
                       "remove. Then press Apply or OK.")
                    .arg(m_installedChecks.size()));
        m_reloadButton->hide();
    }
    m_detailLabel->show();
    updateApplyState();
}

void PluginsDialog::runRissetCommand(const QString &label,
                                    const QStringList &arguments,
                                    bool reloadPlugins,
                                    bool regenerateOpcodes)
{
    if (m_applying)
        return;

    const QString executable = pluginExecutable();
    if (executable.isEmpty()) {
        QMessageBox::warning(this, tr("Plugins"),
                             tr("CsoundQt does not know where risset is installed."));
        return;
    }

    m_applying = true;
    m_spinner->stop();
    m_bottomSpacer->hide();
    m_statusLabel->show();
    m_detailLabel->show();
    m_statusLabel->setText(label);
    m_detailLabel->setText(tr("Risset command output:"));
    m_log->clear();
    setLogVisible(false);
    m_progress->setRange(0, 0);
    m_progress->show();
    setPluginUiEnabled(false);

    QStringList loggedCommand{u"risset"_s};
    loggedCommand.append(arguments);
    logLine(u"$ %1"_s.arg(loggedCommand.join(' '_L1)));

    runProcess(executable, arguments, QProcessEnvironment::systemEnvironment(),
               [this, reloadPlugins, regenerateOpcodes](bool success,
                                                        const QString &error) {
        m_applying = false;
        m_progress->hide();
        setPluginUiEnabled(true);

        if (!success) {
            m_statusLabel->setText(tr("Risset command failed."));
            m_detailLabel->setText(error);
            logLine(error);
            setLogVisible(true);
            return;
        }

        m_statusLabel->setText(tr("Risset command completed."));
        m_detailLabel->setText(tr("The command completed successfully."));
        logLine(tr("Command completed successfully."));
        setLogVisible(true);

        if (reloadPlugins) {
            m_infoLoaded = false;
            loadPluginInfo();
        }
        if (regenerateOpcodes && m_mainWindow != nullptr)
            m_mainWindow->recheckRisset(true);
    });
}

void PluginsDialog::buttonBoxClicked(QAbstractButton *button)
{
    if (button == nullptr || m_buttons == nullptr || m_applying)
        return;
    switch (m_buttons->buttonRole(button)) {
    case QDialogButtonBox::ApplyRole:
        applyPluginChanges(false);
        break;
    case QDialogButtonBox::AcceptRole:
        applyPluginChanges(true);
        break;
    case QDialogButtonBox::RejectRole:
        reject();
        break;
    default:
        break;
    }
}

void PluginsDialog::updateApplyState()
{
    if (m_buttons == nullptr)
        return;
    auto *apply = m_buttons->button(QDialogButtonBox::Apply);
    if (apply == nullptr)
        return;

    bool changed = false;
    for (int row = 0; row < m_installedChecks.size(); ++row) {
        QCheckBox *check = m_installedChecks.at(row);
        QCheckBox *upgrade = row < m_upgradeChecks.size()
                ? m_upgradeChecks.at(row) : nullptr;
        QTableWidgetItem *nameItem = m_table->item(row, 0);
        if (check == nullptr || nameItem == nullptr)
            continue;
        const bool installed = check->property("csqtInitialInstalled").toBool();
        if (upgrade != nullptr) {
            const bool canUpgrade = installed && check->isChecked()
                    && !m_dependencyMode;
            if (!canUpgrade && upgrade->isChecked()) {
                const QSignalBlocker blocker(upgrade);
                upgrade->setChecked(false);
            }
            upgrade->setEnabled(canUpgrade);
        }
        const bool willChange =
                installed != check->isChecked()
                || (upgrade != nullptr && upgrade->isChecked());
        QFont nameFont = nameItem->font();
        nameFont.setBold(nameItem->data(Qt::UserRole + 1).toBool()
                         || willChange);
        nameItem->setFont(nameFont);
        if (willChange) {
            changed = true;
        }
    }
    apply->setEnabled(changed && !m_applying && !m_loadingInfo
                      && m_table->isVisible());
}

void PluginsDialog::setLogVisible(bool visible)
{
    if (m_log == nullptr || m_logToggle == nullptr)
        return;
    const bool hasOutput = !m_log->toPlainText().isEmpty();
    m_logToggle->setVisible(hasOutput);
    m_logToggle->setText(visible ? tr("Hide command output ▴")
                                 : tr("Show command output ▾"));
    m_log->setVisible(visible && hasOutput);
}

void PluginsDialog::applyPluginChanges(bool closeAfter)
{
    if (m_applying)
        return;
    if (m_loadingInfo) {
        if (closeAfter)
            accept();
        return;
    }

    QVector<PluginOperation> operations;
    for (int row = 0; row < m_installedChecks.size(); ++row) {
        const QCheckBox *checkItem = m_installedChecks.at(row);
        const QCheckBox *upgradeCheck = row < m_upgradeChecks.size()
                ? m_upgradeChecks.at(row) : nullptr;
        auto *nameItem = m_table->item(row, 0);
        if (checkItem == nullptr || nameItem == nullptr)
            continue;
        const bool before =
                checkItem->property("csqtInitialInstalled").toBool();
        const bool now = checkItem->isChecked();
        const QString name = nameItem->data(Qt::UserRole).toString();
        if (before != now) {
            operations.append({name, now ? PluginOperationKind::Install
                                         : PluginOperationKind::Remove});
        } else if (upgradeCheck != nullptr && upgradeCheck->isEnabled()
                   && upgradeCheck->isChecked()) {
            operations.append({name, PluginOperationKind::Upgrade});
        }
    }
    if (operations.isEmpty()) {
        if (closeAfter)
            accept();
        return;
    }

    if (pluginExecutable().isEmpty()) {
        if (!m_silent) {
            QMessageBox::warning(this, tr("Plugins"),
                                 tr("CsoundQt does not know where risset is installed."));
        }
        return;
    }

    m_pluginOperations = operations;
    m_operationIndex = 0;
    m_applying = true;
    m_closeAfterApply = closeAfter;
    m_spinner->stop();
    m_bottomSpacer->hide();
    m_statusLabel->show();
    m_detailLabel->show();
    m_statusLabel->setText(tr("Updating plugins..."));
    m_detailLabel->setText(
                tr("Installing and removing plugins. This can take a few minutes."));
    m_detailLabel->show();
    m_log->clear();
    setLogVisible(false);
    m_progress->setRange(0, 0);
    m_progress->show();
    setPluginUiEnabled(false);
    runNextPluginOperation();
}

void PluginsDialog::runNextPluginOperation()
{
    if (m_operationIndex >= m_pluginOperations.size()) {
        finishPluginApply(true, QString());
        return;
    }

    const PluginOperation operation = m_pluginOperations.at(m_operationIndex);
    const QString name = operation.name;
    const QString executable = pluginExecutable();
    if (executable.isEmpty()) {
        finishPluginApply(false,
                          tr("CsoundQt does not know where risset is installed."));
        return;
    }

    QStringList arguments;
    QString operationLabel;
    switch (operation.kind) {
    case PluginOperationKind::Install:
        operationLabel = tr("Installing %1...").arg(name);
        arguments = {u"install"_s, name};
        break;
    case PluginOperationKind::Remove:
        operationLabel = tr("Removing %1...").arg(name);
        arguments = {u"remove"_s, name};
        break;
    case PluginOperationKind::Upgrade:
        operationLabel = tr("Upgrading %1...").arg(name);
        arguments = {u"install"_s, u"--force"_s, name};
        break;
    }
    logLine(operationLabel);
    runProcess(executable,
               arguments,
               QProcessEnvironment::systemEnvironment(),
               [this, name, kind = operation.kind](bool success,
                                                   const QString &error) {
        if (!success) {
            QString action;
            switch (kind) {
            case PluginOperationKind::Install: action = tr("install"); break;
            case PluginOperationKind::Remove: action = tr("remove"); break;
            case PluginOperationKind::Upgrade: action = tr("upgrade"); break;
            }
            finishPluginApply(false, tr("Could not %1 %2:\n%3")
                              .arg(action, name, error));
            return;
        }
        ++m_operationIndex;
        QTimer::singleShot(0, this, &PluginsDialog::runNextPluginOperation);
    });
}

void PluginsDialog::finishPluginApply(bool success, const QString &error)
{
    m_applying = false;
    m_progress->hide();
    setPluginUiEnabled(true);
    const bool anyCompleted = m_operationIndex > 0;

    if (!success) {
        m_closeAfterApply = false;
        m_statusLabel->setText(tr("Could not update the plugins."));
        m_detailLabel->setText(error);
        m_detailLabel->show();
        logLine(error);
        setLogVisible(true);
        if (!m_silent)
            QMessageBox::warning(this, tr("Plugins"), error);
    } else {
        m_statusLabel->setText(tr("Plugins updated."));
        m_detailLabel->setText(tr("The plugin changes were applied."));
        m_detailLabel->show();
        setLogVisible(false);
    }

    if (!success || !m_closeAfterApply) {
        m_infoLoaded = false;
        loadPluginInfo();
    }
    if (m_mainWindow != nullptr && (success || anyCompleted))
        m_mainWindow->recheckRisset(true);

    emit pluginApplyFinished(success, error);

    if (success && m_closeAfterApply)
        accept();
}

void PluginsDialog::setPluginUiEnabled(bool enabled)
{
    m_table->setEnabled(enabled);
    m_buttons->setEnabled(enabled);
    m_updateRissetButton->setEnabled(enabled);
    m_updateDocsButton->setEnabled(enabled);
    if (enabled)
        updateApplyState();
}

void PluginsDialog::showPluginInfo(const QString &name)
{
    const QString executable = pluginExecutable();
    if (executable.isEmpty()) {
        QMessageBox::warning(this, tr("Plugin info"),
                             tr("CsoundQt does not know where risset is installed."));
        return;
    }

    QDialog dialog(this);
    dialog.setWindowTitle(tr("Plugin: %1").arg(name));
    dialog.resize(680, 560);
    auto *layout = new QVBoxLayout(&dialog);
    auto *text = new QPlainTextEdit(&dialog);
    text->setReadOnly(true);
    text->setLineWrapMode(QPlainTextEdit::NoWrap);
    text->setFont(QFontDatabase::systemFont(QFontDatabase::FixedFont));
    text->setPlainText(tr("Loading %1...").arg(name));
    layout->addWidget(text, 1);
    auto *buttons = new QDialogButtonBox(QDialogButtonBox::Close, &dialog);
    connect(buttons, &QDialogButtonBox::rejected, &dialog, &QDialog::reject);
    layout->addWidget(buttons);

    auto *process = new QProcess(&dialog);
    process->setProcessChannelMode(QProcess::SeparateChannels);
    connect(process, &QProcess::finished, &dialog,
            [process, text](int, QProcess::ExitStatus status) {
        QString output = QString::fromLocal8Bit(process->readAllStandardOutput());
        const QString error =
                QString::fromLocal8Bit(process->readAllStandardError()).trimmed();
        output = withoutAnsiEscapes(output).trimmed();
        if (output.isEmpty())
            output = withoutAnsiEscapes(error).trimmed();
        if (output.isEmpty())
            output = tr("No information is available for this plugin.");
        if (status == QProcess::CrashExit)
            output = tr("risset show crashed.\n\n") + output;
        text->setPlainText(output);
    });
    connect(process, &QProcess::errorOccurred, &dialog,
            [process, text](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart) {
            text->setPlainText(
                        tr("Could not run risset show:\n%1")
                        .arg(process->errorString()));
        }
    });
    process->start(executable, {u"show"_s, name});
    dialog.exec();
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

    startInstallation();
}

void PluginsDialog::startInstallation()
{
    if (m_installing)
        return;

    m_installationFinished = false;

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
    setLogVisible(false);
    m_progress->setRange(0, 0);
    m_progress->show();
    m_spinner->stop();
    m_bottomSpacer->hide();
    m_statusLabel->show();
    m_detailLabel->show();
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
            .filePath(u"csoundqt-uv-install-%1%2"_s
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
    program = u"powershell.exe"_s;
    arguments = {u"-NoProfile"_s,
                 u"-ExecutionPolicy"_s,
                 u"Bypass"_s,
                 u"-File"_s,
                 m_uvInstallerPath};
#else
    program = u"/bin/sh"_s;
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
    environment.insert(u"UV_TOOL_BIN_DIR"_s,
                       Risset::pluginBinDir().absolutePath());
    environment.insert(u"UV_TOOL_DIR"_s,
                       Risset::pluginToolDir().absolutePath());
    environment.insert(u"UV_PYTHON_INSTALL_DIR"_s,
                       Risset::pluginPythonDir().absolutePath());

    runProcess(uvPath,
               {u"tool"_s, u"install"_s,
                u"--force"_s, u"risset"_s},
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
               {u"info"_s, u"--full"_s},
               QProcessEnvironment::systemEnvironment(),
               [this](bool success, const QString &error) {
        if (!success) {
            fail(tr("risset was installed but could not be started:\n%1")
                 .arg(error));
            return;
        }
        emitInstallationFinished(true, QString());
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
        Risset::pluginBinDir().filePath(u"uv"_s + suffix),
        QDir::home().filePath(u".local/bin/uv"_s + suffix),
        QDir::home().filePath(u".cargo/bin/uv"_s + suffix)
    };
    for (const QString &candidate : candidates) {
        if (QFileInfo::exists(candidate))
            return candidate;
    }
    return QStandardPaths::findExecutable(u"uv"_s);
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
    // The plugin root exists after CsoundQt installed risset. If risset was
    // found on PATH instead, it may not exist yet; a non-existent working
    // directory makes QProcess fail to start.
    const QDir pluginRoot(Risset::pluginRootDir().absolutePath());
    if (pluginRoot.exists())
        process->setWorkingDirectory(pluginRoot.absolutePath());

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
    m_log->appendPlainText(trimmed);
    setLogVisible(true);
    emit message(trimmed);
}

void PluginsDialog::emitInstallationFinished(bool success, const QString &error)
{
    if (m_installationFinished)
        return;
    m_installationFinished = true;
    emit installationFinished(success, error);
}

void PluginsDialog::fail(const QString &message)
{
    m_installing = false;
    m_spinner->stop();
    m_bottomSpacer->hide();
    m_progress->hide();
    m_statusLabel->show();
    m_detailLabel->show();
    m_installButton->show();
    m_installButton->setEnabled(true);
    m_statusLabel->setText(tr("Installation failed."));
    m_detailLabel->setText(message);
    logLine(message);
    emitInstallationFinished(false, message);
}
