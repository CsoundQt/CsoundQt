#ifndef RISSET_H
#define RISSET_H

#include <QString>
#include <QJsonDocument>
#include <QDir>


class Risset
{
public:
    Risset(QString pythonExe);

    QString htmlManpage(QString opcodeName);
    QString generateDocumentation();
    bool downloadDocumentation();
    QString findHtmlDocumentation();

    bool isInstalled;
    QString rissetVersion;
    QDir rissetRoot;
    QString rissetOpcodesXml;
    QDir rissetHtmlDocs;
    QDir rissetDocsRepoPath;
    QStringList installedPlugins;
    QDir csoundqtDataRoot;
    QStringList opcodeNames;

private:
    QString m_infoText;
    QString m_pythonExe;
    QJsonDocument m_jsonInfo;
    bool opcodeIndexDone;

    void initIndex();

};

#endif // RISSET_H
