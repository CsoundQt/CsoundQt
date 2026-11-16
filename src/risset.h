#ifndef RISSET_H
#define RISSET_H

#include <QString>
#include <QVector>
#include <QJsonDocument>
#include <QDir>
#include <QProcess>
#include "opentryparser.h"

enum class RissetError { Ok, Error, HtmlError, RissetNotInstalled };


class Risset
{
public:
    Risset();

    // User-writable CsoundQt data root and the managed plugin installation
    // locations used by the Plugins window.
    static QDir userDataRoot();
    static QDir pluginRootDir();
    static QDir pluginBinDir();
    static QDir pluginToolDir();
    static QDir pluginPythonDir();
    static QString localRissetExecutable();
    static QString executableSuffix();

    QString htmlManpage(QString opcodeName);
    RissetError generateDocumentation(std::function<void(int)> callback=nullptr);
    RissetError generateOpcodesXml();

    bool downloadDocumentation();
    QString findHtmlDocumentation();
    QString markdownManpage(QString opcodeName);
    void cleanupProcesses();
    void markOpcodeTree(OpEntryParser *tree);
    // One opcode in the scanned text and the 1-based line it was found on.
    struct OpcodeLocation {
        QString opcode;
        int line = 0;
    };
    // The plugin and the opcodes in the text that require it. Each opcode is
    // listed once, at its first occurrence.
    struct PluginUsage {
        QString plugin;
        QVector<OpcodeLocation> opcodes;
    };
    // Plugins whose opcodes appear in Csound source text, with where they were
    // found. Uses the opcode-to-plugin table, which comes from
    // "risset info --full" when risset is installed and from the bundled opcode
    // map otherwise. Comments and string literals are ignored, as are UDOs
    // defined in the text.
    QVector<PluginUsage> pluginUsagesInText(const QString &text) const;
    QString defaultOpcodesXmlPath() { return rissetRoot.filePath("opcodes.xml"); }

    bool isInstalled = false;
    QString rissetVersion;
    // Path of the executable that was detected (managed install or PATH).
    QString executablePath() const { return m_rissetPath; }
    // Raw JSON printed by "risset info --full".
    QString infoText() const { return m_infoText; }
    QDir rissetRoot;
    QString rissetOpcodesXml;
    QDir rissetHtmlDocs;
    QDir rissetDocsRepoPath;
    QDir rissetManpages;
    QStringList installedPlugins;
    QDir csoundqtDataRoot;
    QStringList opcodeNames;                     // list of all opcodes (not installed opcodes might be excluded)
    QHash<QString, bool> pluginInstalled;        // maps plugin to installed status
    QHash<QString, bool> pluginAvailable;         // binary supports this platform/Csound
    QHash<QString, QString> opcodeToPlugin;      // maps an opcode to its plugin
    QHash<QString, QStringList> pluginOpcodes;   // list of opcodes per plugin


private:
    QString m_infoText;
    QString m_rissetPath;
    QJsonDocument m_jsonInfo;
    bool opcodeIndexDone;
    QList<QProcess*> runningProcesses;

    void initIndex();
    // Fill opcodeToPlugin from the opcode map compiled into CsoundQt. Used
    // when risset is not installed, so missing plugins can still be detected.
    void loadBundledOpcodeMap();


};

#endif // RISSET_H
