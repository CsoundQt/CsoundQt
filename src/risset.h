#ifndef RISSET_H
#define RISSET_H

#include <QString>
#include <QJsonDocument>
#include <QDir>
#include <QProcess>


class Risset
{
public:
    Risset(QString pythonExe);

    QString htmlManpage(QString opcodeName);
    int generateDocumentation(std::function<void(int)> callback=nullptr);
    bool downloadDocumentation();
    QString findHtmlDocumentation();
    QString markdownManpage(QString opcodeName);
    void cleanupProcesses();

    bool isInstalled;
    QString rissetVersion;
    QDir rissetRoot;
    QString rissetOpcodesXml;
    QDir rissetHtmlDocs;
    QDir rissetDocsRepoPath;
    QDir rissetManpages;
    QStringList installedPlugins;
    QDir csoundqtDataRoot;
    QStringList opcodeNames;

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
