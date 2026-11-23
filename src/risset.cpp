#include "risset.h"
#include <QString>
#include <QProcess>
#include <QDebug>
#include <QCoreApplication>
#include <QSslSocket>
#include <QStandardPaths>
#include <QTextStream>
#include <QJsonDocument>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QDir>
#include <QFile>
#include <QRegularExpression>
#include <QSet>
#include <algorithm>
#include <iostream>
#include "types.h"
using namespace Qt::StringLiterals;

/**
 * @brief like unix' which, but cross-platform. Based on python shutil.which
 * @param cmd - The command to find
 * @return the absolute path, or an empty string if not found
 */
static QString which(QString cmd, QString otherwise) {
    if(QDir::isAbsolutePath(cmd))
        return cmd;

    QString PATH = QProcessEnvironment::systemEnvironment().value("PATH");
    if(PATH.isEmpty())
        return "";
#if defined(Q_OS_WIN)
    QFileInfo finfo(cmd);
    if(finfo.suffix().isEmpty()) {
        cmd = cmd + ".exe";
    }
#endif

    QStringList paths = PATH.split(QDir::listSeparator());

    QSet<QString> seen;
    foreach(auto dir, paths) {
#ifdef Q_OS_WIN
        dir = QDir::toNativeSeparators(dir.toLower());
#endif
        if(!seen.contains(dir)) {
            seen.insert(dir);
            QString name = QDir(dir).filePath(cmd);
            QDEBUG << "Inspecting " << name;
            if(QFile::exists(name)) {
                QDEBUG << "Found!" << name;
                return name;
            }
        }
    }
    return otherwise;
}


bool is_running_in_flatpak() {
    return std::getenv("FLATPAK_ID") != nullptr;
}


QString Risset::executableSuffix()
{
#ifdef Q_OS_WIN
    return u".exe"_s;
#else
    return QString();
#endif
}

QDir Risset::userDataRoot()
{
#if defined(Q_OS_LINUX)
    return QDir(QDir::home().filePath(".local/share/csoundqt"));
#elif defined(Q_OS_WIN)
    return QDir(QDir(QProcessEnvironment::systemEnvironment()
                     .value("LOCALAPPDATA")).filePath("csoundqt"));
#elif defined(Q_OS_MACOS)
    return QDir(QDir::home().filePath("Library/Application Support/csoundqt"));
#else
    return QDir(QDir::home().filePath(".csoundqt"));
#endif
}

QDir Risset::pluginRootDir()
{
    return QDir(userDataRoot().filePath("plugins"));
}

QDir Risset::pluginBinDir()
{
    return QDir(pluginRootDir().filePath("bin"));
}

QDir Risset::pluginToolDir()
{
    return QDir(pluginRootDir().filePath("tools"));
}

QDir Risset::pluginPythonDir()
{
    return QDir(pluginRootDir().filePath("python"));
}

QString Risset::localRissetExecutable()
{
    return pluginBinDir().filePath(u"risset"_s + executableSuffix());
}

QProcessEnvironment Risset::processEnvironment()
{
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.remove(u"PYTHONHOME"_s);
    environment.remove(u"PYTHONPATH"_s);

    // risset 4.1.3+ uses this instead of locating libcsound and querying it
    // through ctypes. That keeps risset working when the interpreter cannot
    // load libffi, and it makes risset use the same Csound as CsoundQt even
    // when several installations are present.
    const int version = csoundGetVersion();
    if (version >= 7000) {
        const int major = version / 1000;
        const int minor = (version % 1000) / 10;
        const int patch = version % 10;
        QString versionString =
                QString::number(major) + u"."_s + QString::number(minor);
        if (patch > 0)
            versionString += u"."_s + QString::number(patch);
        environment.insert(u"LIBCSOUND_VERSION"_s, versionString);
    }
    return environment;
}

QString Risset::networkDiagnostics()
{
    const auto valueOr = [](const QString &value, const QString &fallback) {
        return value.isEmpty() ? fallback : value;
    };

    QStringList availableBackends = QSslSocket::availableBackends();
    availableBackends.removeDuplicates();

    QString text;
    QTextStream out(&text);
    out << "Qt TLS: supportsSsl="
        << (QSslSocket::supportsSsl() ? "true" : "false") << "\n";
    out << "  active backend: "
        << valueOr(QSslSocket::activeBackend(), u"(none)"_s) << "\n";
    out << "  available backends: "
        << valueOr(availableBackends.join(u", "_s), u"(none)"_s) << "\n";
    out << "  build SSL: "
        << valueOr(QSslSocket::sslLibraryBuildVersionString(),
                   u"(unknown)"_s) << "\n";
    out << "  runtime SSL: "
        << valueOr(QSslSocket::sslLibraryVersionString(),
                   u"(unknown)"_s) << "\n";
    out << "  library paths: "
        << QCoreApplication::libraryPaths().join(u", "_s) << "\n";

    QStringList tlsPlugins;
    for (const QString &path : QCoreApplication::libraryPaths()) {
        const QDir tlsDir(QDir(path).filePath(u"tls"_s));
        if (!tlsDir.exists())
            continue;
        const QStringList entries = tlsDir.entryList(QDir::Files, QDir::Name);
        for (const QString &entry : entries)
            tlsPlugins.append(tlsDir.filePath(entry));
    }
    tlsPlugins.removeDuplicates();
    out << "  TLS plugins: "
        << valueOr(tlsPlugins.join(u", "_s), u"(none found)"_s) << "\n";

    const QString curl = QStandardPaths::findExecutable(u"curl"_s);
    const QString wget = QStandardPaths::findExecutable(u"wget"_s);
    out << "  curl: " << valueOr(curl, u"(not found)"_s) << "\n";
    out << "  wget: " << valueOr(wget, u"(not found)"_s) << "\n";
    return text;
}

Risset::Risset()
{
    opcodeIndexDone = false;
    csoundqtDataRoot = userDataRoot();
    // local path to download the html docs from github.com//csound-plugins/risset-docs
    rissetDocsRepoPath.setPath(csoundqtDataRoot.filePath("risset-docs"));
    // Prefer the copy installed by the Plugins window. The process PATH of a
    // GUI application may not include the shell's local bin directory.
    QString rissetScriptPath = localRissetExecutable();
    if (!QFile::exists(rissetScriptPath))
        rissetScriptPath = which("risset", QString());
    if (rissetScriptPath.isEmpty() || !QFile::exists(rissetScriptPath)) {
        isInstalled = false;
        loadBundledOpcodeMap();
        QDEBUG << "Risset script not found in the path or at"
               << localRissetExecutable();
        return;
    }

    QStringList args = {"info", "--full"};
    QProcess proc;
    proc.setProcessEnvironment(processEnvironment());
    proc.start(rissetScriptPath, args);
    auto finishok = proc.waitForFinished();
    if (!finishok) {
        isInstalled = false;
        loadBundledOpcodeMap();
        QDEBUG << "Risset script not runnable" << rissetScriptPath
               << proc.errorString();
        return;
    }
    m_rissetPath = rissetScriptPath;

    auto procOut = proc.readAllStandardOutput();
    m_infoText = QString::fromLocal8Bit(procOut);
    QJsonDocument m_jsonInfo = QJsonDocument::fromJson(procOut);
    QJsonObject root = m_jsonInfo.object();          
    rissetVersion = root.value("version").toString();
    if(rissetVersion.isEmpty()) {
        isInstalled = false;
        loadBundledOpcodeMap();
        QDEBUG << "Risset did not execute correctly: " << proc.errorString();
        return;
    }
    isInstalled = true;
    m_rissetPath = rissetScriptPath;
    rissetRoot.setPath(root.value("rissetroot").toString());
    rissetHtmlDocs.setPath(root.value("htmldocs").toString());
    rissetOpcodesXml = root.value("opcodesxml").toString();
    if(!QFile::exists(rissetOpcodesXml)) {
        QDEBUG << "Did not find opcodes.xml, path = " << rissetOpcodesXml;
        this->generateOpcodesXml();
    }

    rissetManpages.setPath(root.value("manpages").toString());
    QDEBUG << "Risset opcodes.xml: " << rissetOpcodesXml;
    QDEBUG << "Risset version: " << rissetVersion;
    QDEBUG << "Risset manual: " << rissetHtmlDocs.absolutePath();
    this->opcodeNames.clear();
    auto plugins = root.value(QString("plugins")).toObject();
    for(auto& pluginName: plugins.keys()) {
        QDEBUG << "Risset - parsing plugin" << pluginName;
        auto plugindef = plugins.value(pluginName).toObject();
        bool installed = plugindef.value("installed").toBool();
        pluginAvailable[pluginName] =
                plugindef.value("available").toBool(installed);
        auto opcodesInPlugin = plugindef.value("opcodes").toArray();
        QStringList opcodesList;
        for(auto opcodeName: opcodesInPlugin) {
            QString opcodeNameStr = opcodeName.toString();
            opcodeNames.append(opcodeNameStr);
            opcodeToPlugin[opcodeNameStr] = pluginName;
            opcodesList.append(opcodeNameStr);
        }
        pluginInstalled[pluginName] = installed;
        this->pluginOpcodes[pluginName] = opcodesList;
        if(installed) {
            this->installedPlugins.append(pluginName);
        }

    }
    // QDEBUG << "Risset opcodes: " << opcodeNames;
    opcodeIndexDone = true;
}


void Risset::loadBundledOpcodeMap()
{
    QFile file(u":/risset-opcodemap.json"_s);
    if (!file.open(QIODevice::ReadOnly)) {
        QDEBUG << "Could not open the bundled risset opcode map";
        return;
    }
    QJsonParseError error{};
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);
    if (error.error != QJsonParseError::NoError || !document.isObject()) {
        QDEBUG << "Could not parse the bundled risset opcode map:"
               << error.errorString();
        return;
    }

    const QJsonObject plugins = document.object()
            .value(u"plugins"_s).toObject();
    for (auto it = plugins.constBegin(); it != plugins.constEnd(); ++it) {
        const QString pluginName = it.key();
        const QJsonArray opcodes = it.value().toObject()
                .value(u"opcodes"_s).toArray();
        QStringList opcodeList;
        for (const QJsonValue &value : opcodes) {
            const QString opcode = value.toString();
            if (opcode.isEmpty())
                continue;
            opcodeToPlugin.insert(opcode, pluginName);
            opcodeNames.append(opcode);
            opcodeList.append(opcode);
        }
        pluginOpcodes.insert(pluginName, opcodeList);
    }
    opcodeIndexDone = !opcodeToPlugin.isEmpty();
    QDEBUG << "Loaded bundled risset opcode map:" << plugins.size()
           << "plugins," << opcodeToPlugin.size() << "opcodes";
}

namespace {

// A copy of the text with comments and strings blanked out, keeping newlines
// so offsets and line numbers still match the original. This makes variable
// and opcode recognition less error-prone.
QString cleanCsoundText(const QString &source)
{
    QString cleaned = source;
    const int length = source.size();
    const auto blank = [&cleaned](int start, int end) {
        end = qMin(end, int(cleaned.size()));
        for (int i = start; i < end; ++i) {
            if (cleaned.at(i) != '\n'_L1 && cleaned.at(i) != '\r'_L1)
                cleaned[i] = ' ';
        }
    };

    int i = 0;
    while (i < length) {
        const QChar c = source.at(i);
        if (c == ';'_L1
                || (c == '/'_L1 && i + 1 < length
                    && source.at(i + 1) == '/'_L1)) {
            int end = int(source.indexOf('\n'_L1, i + 1));
            if (end < 0)
                end = length;
            blank(i, end);
            i = end;
            continue;
        }
        if (c == '/'_L1 && i + 1 < length && source.at(i + 1) == '*'_L1) {
            int end = int(source.indexOf(u"*/"_s, i + 2));
            end = end < 0 ? length : end + 2;
            blank(i, end);
            i = end;
            continue;
        }
        if (c == '{'_L1 && i + 1 < length && source.at(i + 1) == '{'_L1) {
            int end = int(source.indexOf(u"}}"_s, i + 2));
            end = end < 0 ? length : end + 2;
            blank(i, end);
            i = end;
            continue;
        }
        if (c == '"'_L1 || c == '\''_L1) {
            const QChar quote = c;
            int end = i + 1;
            while (end < length) {
                const QChar d = source.at(end++);
                if (d == '\\'_L1) {
                    if (end < length)
                        ++end;
                    continue;
                }
                if (d == quote)
                    break;
            }
            blank(i, end);
            i = end;
            continue;
        }
        ++i;
    }
    return cleaned;
}

void collectNames(const QRegularExpression &expression, const QString &text,
                  QSet<QString> &names)
{
    auto matches = expression.globalMatch(text);
    while (matches.hasNext())
        names.insert(matches.next().captured(1));
}

} // namespace

QVector<Risset::PluginUsage> Risset::pluginUsagesInText(const QString &text) const
{
    QVector<PluginUsage> usages;
    if (opcodeToPlugin.isEmpty() || text.isEmpty())
        return usages;

    // Only the orchestra can call opcodes; ignore widgets and score text.
    QString source = text;
    int contentStart = 0;
    static const QRegularExpression instruments(
                uR"(<CsInstruments\b[^>]*>([\s\S]*?)</CsInstruments\s*>)"_s,
                QRegularExpression::CaseInsensitiveOption);
    const QRegularExpressionMatch instrumentsMatch = instruments.match(text);
    if (instrumentsMatch.hasMatch()) {
        contentStart = int(instrumentsMatch.capturedStart(1));
        source = instrumentsMatch.captured(1);
    }

    const QString cleaned = cleanCsoundText(source);

    // Lines are reported as they appear in the whole document, not in the
    // extracted orchestra section.
    int line = 1 + int(text.left(contentStart).count('\n'_L1));

    // Names that cannot be opcodes. A UDO defined here shadows a plugin opcode
    // with the same name. Variables are recognised by typed declarations/uses
    // ("accum:k"), assignment targets ("accum = ...") and array subscripts
    // ("accum[0]"); once a name appears in one of these positions it is a
    // variable everywhere in the document.
    QSet<QString> excluded;
    static const QRegularExpression udo(uR"(\bopcode\s+([A-Za-z_]\w*))"_s);
    static const QRegularExpression typedVariable(
                uR"(\b([A-Za-z_]\w*)\s*:\s*(?:\[|[A-Za-z_]\w*))"_s);
    static const QRegularExpression assignment(
                uR"(\b([A-Za-z_]\w*)\s*=(?!=))"_s);
    static const QRegularExpression subscript(
                uR"(\b([A-Za-z_]\w*)\s*\[)"_s);
    collectNames(udo, cleaned, excluded);
    collectNames(typedVariable, cleaned, excluded);
    collectNames(assignment, cleaned, excluded);
    collectNames(subscript, cleaned, excluded);

    const auto addUse = [&usages](const QString &plugin, const QString &opcode,
                                  int lineNumber) {
        for (PluginUsage &usage : usages) {
            if (usage.plugin != plugin)
                continue;
            for (const OpcodeLocation &location : usage.opcodes) {
                if (location.opcode == opcode)
                    return; // keep the first occurrence
            }
            usage.opcodes.append(OpcodeLocation{opcode, lineNumber});
            return;
        }
        PluginUsage usage;
        usage.plugin = plugin;
        usage.opcodes.append(OpcodeLocation{opcode, lineNumber});
        usages.append(usage);
    };

    const int length = cleaned.size();
    int i = 0;
    while (i < length) {
        const QChar c = cleaned.at(i);
        if (c == '\n'_L1) {
            ++line;
            ++i;
            continue;
        }
        if (c.isLetter() || c == '_'_L1) {
            const int start = i;
            while (i < length
                   && (cleaned.at(i).isLetterOrNumber()
                       || cleaned.at(i) == '_'_L1))
                ++i;
            const QString token = cleaned.mid(start, i - start);
            if (excluded.contains(token))
                continue;
            int previous = start - 1;
            while (previous >= 0
                   && (cleaned.at(previous) == ' ' || cleaned.at(previous) == '\t'))
                --previous;
            if (previous >= 0
                    && (cleaned.at(previous) == '.'_L1
                        || cleaned.at(previous) == ':'_L1))
                continue; // struct member or type name
            const auto plugin = opcodeToPlugin.constFind(token);
            if (plugin != opcodeToPlugin.constEnd())
                addUse(plugin.value(), token, line);
            continue;
        }
        ++i;
    }

    std::sort(usages.begin(), usages.end(),
              [](const PluginUsage &left, const PluginUsage &right) {
        return left.plugin.compare(right.plugin, Qt::CaseInsensitive) < 0;
    });
    return usages;
}

void Risset::markOpcodeTree(OpEntryParser *tree) {
    // Mark the opcodes which are not installed. This information can be used, for example
    // for more nuanced highlighting
    for(auto& opcode : tree->opcodeList) {
        auto pluginName = this->opcodeToPlugin.value(opcode.opcodeName);
        if(!pluginName.isEmpty()) {
            opcode.isInstalled = this->pluginInstalled[pluginName];
        }
    }
}


QString Risset::markdownManpage(QString opcodeName) {
    if(!rissetManpages.exists()) {
        QDEBUG << "Risset markdown root not set";
        return "";
    }
    QString path = rissetManpages.filePath(opcodeName + ".md");
    if(QFile::exists(path))
        return path;
    else {
        QDEBUG << "Did not find markdown manpage for opcode" << opcodeName;
        QDEBUG << "... Searched: " << path;
        return "";
    }

}


QString Risset::htmlManpage(QString opcodeName) {
    // TODO!
    if(rissetHtmlDocs.exists()) {
        QString path = rissetHtmlDocs.filePath("opcodes/" + opcodeName + ".html");
        if(QFile::exists(path)) {
            QDEBUG << "Risset: found html man page for opcode" << opcodeName << ": " << path;
            return path;
        }
        else {
            QDEBUG << "Risset: did not find html page for opcode" << opcodeName << "\n"
                   << "... Searched: " << path;
        }
    }
    else
        QDEBUG << "Risset's documentation not found. Searched:" << rissetHtmlDocs.path();
    return "";
}

RissetError Risset::generateOpcodesXml() {
    if (!isInstalled || m_rissetPath.isEmpty()) {
        QDEBUG << "Risset is not installed";
        return RissetError::RissetNotInstalled;
    }
    QString path = this->defaultOpcodesXmlPath();

    // risset 4 takes --outfile after the "dev opcodesxml" subcommand. Older
    // versions accepted it on "dev" itself, so try both before giving up.
    const QList<QStringList> argumentVariants = {
        {"--debug", "dev", "opcodesxml", "--outfile", path},
        {"--debug", "dev", "--outfile", path, "opcodesxml"}
    };

    QString lastError;
    for (const QStringList &args : argumentVariants) {
        QProcess proc;
        QDEBUG << "Calling risset to generate opcodes.xml. exec: " << m_rissetPath
               << ", args: " << args;
        proc.setProcessEnvironment(processEnvironment());
        proc.start(m_rissetPath, args);
        proc.waitForFinished();
        const QString standardError =
                QString::fromLocal8Bit(proc.readAllStandardError()).trimmed();
        if (proc.exitCode() == 0 && QFile::exists(path)) {
            rissetOpcodesXml = path;
            return RissetError::Ok;
        }
        if (!standardError.isEmpty())
            lastError = standardError;
    }

    QDEBUG << "Error while generating opcodesxml:" << lastError;
    return RissetError::Error;
}



RissetError Risset::generateDocumentation(std::function<void(int)> callback) {
    if (!isInstalled || m_rissetPath.isEmpty()) {
        QDEBUG << "Risset is not installed";
        return RissetError::RissetNotInstalled;
    }

    QStringList args = {"makedocs"};
    const QString executable = m_rissetPath;

    if(callback == nullptr) {
        QProcess proc;
        proc.setProcessEnvironment(processEnvironment());
        proc.start(executable, args);
        proc.waitForFinished();
        if(proc.exitCode() != 0) {
            QDEBUG << "Error while making documentation. Risset args: " << args;
            return RissetError::Error;
        } else  {
            if(!QFile::exists(rissetHtmlDocs.filePath("index.html"))) {
                QDEBUG << "Risset::generateDocumentation failed to genererate HTML docs, path: "
                         << rissetHtmlDocs.path();
                return RissetError::HtmlError;
            }
            QDEBUG << "Risset makedocs OK!";
            return RissetError::Ok;
        }
    }
    else {
        QProcess *proc = new QProcess();
        proc->setProcessEnvironment(processEnvironment());
        proc->start(executable, args);
        runningProcesses.append(proc);
        QObject::connect(proc, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
            [this, callback](int exitCode, QProcess::ExitStatus exitStatus) {
            if(exitStatus == QProcess::CrashExit)
                exitCode = -1;
            callback(exitCode);
            this->cleanupProcesses();
        });
        return RissetError::Ok;
    }
}


static bool updateGitRepo(QString path) {
    QProcess proc;
    QStringList args = {"-C", path, "update"};
    proc.start("git", args);
    proc.waitForFinished();
    return true;
}


static bool cloneGitRepo(QString url, QString path) {
    QProcess proc;
    proc.start("git", {"clone", "--depth", "1", url, path});
    proc.waitForFinished();
    return true;
}


bool Risset::downloadDocumentation() {
    // TODO
    if(rissetDocsRepoPath.exists()) {
        return updateGitRepo(rissetDocsRepoPath.path());
    }
    else {
        return cloneGitRepo("https://github.com/csound-plugins/risset-docs.git", rissetDocsRepoPath.path());
    }
}

QString Risset::findHtmlDocumentation() {
    if(QFile::exists(rissetHtmlDocs.filePath("index.html"))) {
        return rissetHtmlDocs.path();
    }
    else if(QFile::exists(rissetDocsRepoPath.filePath("site/index.html"))) {
        return rissetDocsRepoPath.filePath("site");
    }
    else
        return "";
}


void Risset::initIndex() {
}

void Risset::cleanupProcesses()
{
    QMutableListIterator<QProcess*> it(runningProcesses);
    while (it.hasNext()) {
        auto proc = it.next();
        if(proc->processId() == 0) {
            delete proc;
            it.remove();
        }
    }
    QDEBUG << "Running processes: " << runningProcesses.size();
}


