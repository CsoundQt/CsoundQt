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
            qDebug() << "Inspecting " << name;
            if(QFile::exists(name)) {
                qDebug() << "Found!" << name;
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

    // first we check if risset is installed
    QProcess proc;
    QStringList args = {"-c",
                        "import importlib, sys; "
                        "sys.exit(0 if importlib.util.find_spec('risset') is not None else 0)"};
    if(!pythonExe.isEmpty()) {
        if(QDir(pythonExe).isAbsolute()) {
            if(QFile::exists(pythonExe))
                m_pythonExe = pythonExe;
            else {
                qWarning() << "Python binary was set to" << pythonExe << "but it does not exist!";
                m_pythonExe = which("python3", "python3");
            }
        }
        else {
            m_pythonExe = which(pythonExe, pythonExe);
        }
    }
    else {
        m_pythonExe = which("python3", "python3");
    }
    qDebug() << "Using python binary:" << m_pythonExe;
    proc.start(m_pythonExe, args);
    proc.waitForFinished();
    isInstalled = proc.exitCode() == 0;
    if(!isInstalled) {
        qDebug() << "Risset not installed: " << proc.errorString();
    }
    else {
        qDebug() << "Risset installed!";
        args.clear();
        args << "-m" << "risset" << "info" << "--full";
        proc.start(m_pythonExe, args);
        proc.waitForFinished();
        auto procOut = proc.readAllStandardOutput();
        m_infoText = QString::fromLocal8Bit(procOut);
        QJsonDocument m_jsonInfo = QJsonDocument::fromJson(procOut);
        QJsonObject root = m_jsonInfo.object();
        rissetVersion = root.value("version").toString();
        rissetRoot.setPath(root.value("rissetroot").toString());
        rissetHtmlDocs.setPath(root.value("htmldocs").toString());
        rissetOpcodesXml = root.value("opcodesxml").toString();
        rissetManpages.setPath(root.value("manpages").toString());
        qDebug() << "Risset opcodes.xml: " << rissetOpcodesXml;

        this->opcodeNames.clear();
        qDebug() << "Risset version: " << rissetVersion;
        auto plugins = root.value(QString("plugins")).toObject();
        foreach(auto pluginName, plugins.keys()) {
            qDebug() << "initIndex: inspecting plugin" << pluginName;
            auto plugindef = plugins.value(pluginName).toObject();
            bool installed = plugindef.value("installed").toBool();
            if(installed) {
                auto opcodesInPlugin = plugindef.value("opcodes").toArray();
                foreach(auto opcodeName, opcodesInPlugin) {
                    QString opcodeNameStr = opcodeName.toString();
                    // qDebug() << "Registering opcode:" << opcodeNameStr;
                    opcodeNames.append(opcodeNameStr);
                }
            }
        }
    }
    opcodeIndexDone = true;
}


QString Risset::markdownManpage(QString opcodeName) {
    if(!rissetManpages.exists()) {
        qDebug() << "Risset markdown root not set";
        return "";
    }
    QString path = rissetManpages.filePath(opcodeName + ".md");
    if(QFile::exists(path))
        return path;
    else {
        qDebug() << "Did not find markdown manpage for opcode" << opcodeName;
        qDebug() << "... Searched: " << path;
        return "";
    }

}


QString Risset::htmlManpage(QString opcodeName) {
    // TODO!
    if(rissetHtmlDocs.exists()) {
        QString path = rissetHtmlDocs.filePath("opcodes/" + opcodeName + ".html");
        if(QFile::exists(path)) {
            return path;
        }
        else {
            qDebug() << "Dir not find html page for opcode" << opcodeName;
            qDebug() << "... Searched: " << path;
        }
    }
    else {
        qDebug() << "Risset's documentation not found. Searched:" << rissetHtmlDocs.path();
    }
    return "";
}


QString Risset::generateDocumentation() {
    QProcess proc;
    QStringList args = {"-m", "risset", "makedocs"};
    proc.start(m_pythonExe, args);
    proc.waitForFinished();
    if(proc.exitCode() != 0) {
        qDebug() << "Error while making documentation. Risset args: << args";
        return "Error while calling 'risset makedocs'";
    } else  {
        if(!QFile::exists(rissetHtmlDocs.filePath("index.html"))) {
            qDebug() << "Risset::geerateDocumentation failed to genererate HTML docs, path: "
                     << rissetHtmlDocs.path();
            return "Failed to generate docs";
        }
        qDebug() << "Risset makedocs OK!";
        return "";
    }
}


static bool isGitFolder(QString path) {
    // out = subprocess.check_output(["git", "-C", path, "rev-parse", "--is-inside-work-tree"]).decode("utf-8").strip()
    QProcess proc;
    QStringList args = {"-C", path, "rev-parse", "--is-inside-work-tree"};
    proc.start("git", args);
    proc.waitForFinished();
    if(proc.exitCode() != 0)
        return false;
    auto out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
    return out == "true";
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
    QStringList args = {"clone", "--depth", "1", url, path};
    proc.start("git", args);
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



