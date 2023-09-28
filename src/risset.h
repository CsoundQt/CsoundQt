#ifndef RISSET_H
#define RISSET_H

#include <QString>
#include <QJsonDocument>
#include <QDir>
#include <QProcess>
#include "opentryparser.h"

enum class RissetError { Ok, Error, HtmlError, RissetNotInstalled };


class Risset
{
public:
    Risset(QString pythonExe);

    QString htmlManpage(QString opcodeName);
    RissetError generateDocumentation(std::function<void(int)> callback=nullptr);
    RissetError generateOpcodesXml();

    bool downloadDocumentation();
    QString findHtmlDocumentation();
    QString markdownManpage(QString opcodeName);
    void cleanupProcesses();
    void markOpcodeTree(OpEntryParser *tree);
    QString defaultOpcodesXmlPath() { return rissetRoot.filePath("opcodes.xml"); }

    bool isInstalled;
    QString rissetVersion;
    QDir rissetRoot;
    QString rissetOpcodesXml;
    QDir rissetHtmlDocs;
    QDir rissetDocsRepoPath;
    QDir rissetManpages;
    QStringList installedPlugins;
    QDir csoundqtDataRoot;
    QStringList opcodeNames;                     // list of all opcodes (not installed opcodes might be excluded)
    QHash<QString, bool> pluginInstalled;        // maps plugin to installed status
    QHash<QString, QString> opcodeToPlugin;      // maps an opcode to its plugin
    QHash<QString, QStringList> pluginOpcodes;   // list of opcodes per plugin


private:
    QString m_infoText;
    QString m_pythonExe;
    QString m_rissetPath;
    QJsonDocument m_jsonInfo;
    bool opcodeIndexDone;
    QList<QProcess*> runningProcesses;

    void initIndex();


};

#endif // RISSET_H
