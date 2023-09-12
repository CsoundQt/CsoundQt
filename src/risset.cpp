#include "risset.h"
#include <QString>
#include <QProcess>
#include <QDebug>
#include <QJsonDocument>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QDir>
#include <iostream>
#include "types.h"

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

Risset::Risset(QString pythonExe)
{
    opcodeIndexDone = false;
#if defined(Q_OS_LINUX)
    csoundqtDataRoot.setPath(QDir::home().filePath(".local/share/csoundqt"));
#elif defined(Q_OS_WIN)
    csoundqtDataRoot.setPath(QDir(QProcessEnvironment::systemEnvironment().value("LOCALAPPDATA")).filePath("csoundqt"));
#elif defined(Q_OS_MACOS)
    csoundqtDataRoot.setPath(QDir::home().filePath("Library/Application Support/csoundqt"));
#else
    csoundqtDataRoot.setPath(QDir::home().filePath(".csoundqt"));
#endif
    // local path to download the html docs from github.com//csound-plugins/risset-docs
    rissetDocsRepoPath.setPath(csoundqtDataRoot.filePath("risset-docs"));
    // Try the risset script
    QString rissetScriptPath = which("risset", "risset");
    QStringList args = {"info", "--full"};
    QProcess proc;
    proc.start(rissetScriptPath, args);
    auto finishok = proc.waitForFinished();
    if (!finishok) {
        QDEBUG << "Risset script not installed" << proc.errorString();
        m_rissetPath = "";
        if(QFile::exists(pythonExe))
        m_pythonExe = pythonExe;
        else if(!pythonExe.isEmpty())
            m_pythonExe = which(pythonExe, "python3");
        else
            m_pythonExe = which("python3", "python3");

        QDEBUG << "Python binary: " << m_pythonExe;

        proc.start(m_pythonExe, {"-m", "risset", "info", "--full"});
        finishok = proc.waitForFinished();
        if (!finishok) {
            isInstalled = false;
            QDEBUG << "Risset not installed for python " << m_pythonExe << ", error: " << proc.errorString();
            return;
        }
    } else {
        m_rissetPath = rissetScriptPath;
    }

    auto procOut = proc.readAllStandardOutput();
    m_infoText = QString::fromLocal8Bit(procOut);
    QJsonDocument m_jsonInfo = QJsonDocument::fromJson(procOut);
    QJsonObject root = m_jsonInfo.object();
    rissetVersion = root.value("version").toString();
    if(rissetVersion.isEmpty()) {
        isInstalled = false;
        QDEBUG << "Risset did not execute correctly: " << proc.errorString();
        return;
    }
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
    this->opcodeNames.clear();
    QDEBUG << "Risset version: " << rissetVersion;
    auto plugins = root.value(QString("plugins")).toObject();
    for(auto pluginName: plugins.keys()) {
        auto plugindef = plugins.value(pluginName).toObject();
        bool installed = plugindef.value("installed").toBool();
        if(installed) {
            auto opcodesInPlugin = plugindef.value("opcodes").toArray();
            for(auto opcodeName: opcodesInPlugin) {
                QString opcodeNameStr = opcodeName.toString();
                opcodeNames.append(opcodeNameStr);
            }
        }
    }
    opcodeIndexDone = true;
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
        if(QFile::exists(path))
            return path;
        else {
            QDEBUG << "Dir not find html page for opcode" << opcodeName << "\n"
                   << "... Searched: " << path;
        }
    }
    else
        QDEBUG << "Risset's documentation not found. Searched:" << rissetHtmlDocs.path();
    return "";
}

RissetError Risset::generateOpcodesXml() {
    if (!isInstalled) {
        QDEBUG << "Risset is not installed";
        return RissetError::RissetNotInstalled;
    }
    QString executable;
    QStringList args;
    QString path = this->defaultOpcodesXmlPath();

    if (!m_rissetPath.isEmpty()) {
        executable = m_rissetPath;
        args = QStringList({"--debug", "dev", "--outfile", path, "opcodesxml"});
    } else if(!m_pythonExe.isEmpty()) {
        executable = m_pythonExe;
        args = QStringList({"-m", "risset", "--debug", "dev", "--outfile", path, "opcodesxml"});
    } else {
        QDEBUG << "Either the risset script should be known or the python executable "
                  "should be known...";
        return RissetError::RissetNotInstalled;
    }

    QProcess proc;
    QDEBUG << "Calling risset to generate opcodes.xml. exec: " << executable << ", args: " << args;
    proc.start(executable, args);
    proc.waitForFinished();
    if(proc.exitCode() != 0) {
        QDEBUG << "Error while generating opcodesxml";
        return RissetError::Error;
    }
    rissetOpcodesXml = path;
    return RissetError::Ok;
}



RissetError Risset::generateDocumentation(std::function<void(int)> callback) {
    if (!isInstalled) {
        QDEBUG << "Risset is not installed";
        return RissetError::RissetNotInstalled;
    }

    QString executable;
    QStringList args;

    if (!m_rissetPath.isEmpty()) {
        executable = m_rissetPath;
        args = QStringList({"makedocs"});
    } else {
        executable = m_pythonExe;
        args = QStringList({"-m", "risset", "makedocs"});
    }

    if(callback == nullptr) {
        QProcess proc;
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



