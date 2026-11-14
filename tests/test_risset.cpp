#include <QtTest>

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTemporaryDir>

#include <cstdio>

#include "risset.h"

using namespace Qt::StringLiterals;

class TestRisset : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void pluginPaths();
    void missingRissetDoesNotInvokePython();
    void detectsRissetScript();
    void prefersManagedRisset();
    void generatesOpcodesXml();

private:
    QString installFakeExecutable(const QString &directory,
                                  const QString &name,
                                  const QString &version,
                                  const QString &opcodesPath);
    QTemporaryDir m_home;
    QTemporaryDir m_emptyBin;
};

void TestRisset::initTestCase()
{
    QVERIFY(m_home.isValid());
    QVERIFY(m_emptyBin.isValid());

    // Risset's plugin installation lives under the user's CsoundQt data root.
    // Redirect that root to the temporary directory, and keep PATH free of a
    // real risset installation.
    qputenv("HOME", m_home.path().toUtf8());
    qputenv("LOCALAPPDATA", m_home.path().toUtf8());
    qputenv("PATH", m_emptyBin.path().toUtf8());

    // Remove a fake managed risset left behind by an interrupted earlier run.
    QDir managed(Risset::pluginBinDir().absolutePath());
    managed.remove(u"risset"_s + Risset::executableSuffix());
    managed.remove(u"risset-json.txt"_s);
    managed.remove(u"opcodes.xml"_s);
}

QString TestRisset::installFakeExecutable(const QString &directory,
                                          const QString &name,
                                          const QString &version,
                                          const QString &opcodesPath)
{
    QDir().mkpath(directory);
    const QString target = QDir(directory).filePath(name + Risset::executableSuffix());
    QFile::remove(target);
    if (!QFile::copy(QCoreApplication::applicationFilePath(), target))
        return {};
    QFile::setPermissions(target, QFile::ReadOwner | QFile::WriteOwner
                          | QFile::ExeOwner | QFile::ReadGroup
                          | QFile::ExeGroup | QFile::ReadOther
                          | QFile::ExeOther);

    // The fake executable reads this file when invoked as "risset info --full".
    // Each directory has its own copy, which lets the managed/path preference
    // test distinguish the two installations.
    const QString payload = QStringLiteral(
                "{\"version\":\"%1\",\"rissetroot\":\"%2\","
                "\"htmldocs\":\"%2\",\"opcodesxml\":\"%3\","
                "\"plugins\":{}}")
            .arg(version, directory, opcodesPath);
    QFile json(QDir(directory).filePath(u"risset-json.txt"_s));
    if (!json.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return {};
    json.write(payload.toUtf8());
    json.close();
    return target;
}

void TestRisset::pluginPaths()
{
    const QString dataRoot = QDir::cleanPath(Risset::userDataRoot().absolutePath());
    QCOMPARE(QDir::cleanPath(Risset::pluginRootDir().absolutePath()),
             QDir::cleanPath(QDir(dataRoot).filePath("plugins")));
    QCOMPARE(QDir::cleanPath(Risset::pluginBinDir().absolutePath()),
             QDir::cleanPath(QDir(dataRoot).filePath("plugins/bin")));
    QCOMPARE(QDir::cleanPath(Risset::pluginToolDir().absolutePath()),
             QDir::cleanPath(QDir(dataRoot).filePath("plugins/tools")));
    QCOMPARE(QDir::cleanPath(Risset::pluginPythonDir().absolutePath()),
             QDir::cleanPath(QDir(dataRoot).filePath("plugins/python")));

    const QString expected = QDir(Risset::pluginBinDir().absolutePath())
            .filePath(u"risset"_s + Risset::executableSuffix());
    QCOMPARE(QDir::cleanPath(Risset::localRissetExecutable()),
             QDir::cleanPath(expected));
}

void TestRisset::missingRissetDoesNotInvokePython()
{
    QTemporaryDir bin;
    QVERIFY(bin.isValid());
    const QString opcodes = bin.filePath(u"opcodes.xml"_s);
    QFile opcodesFile(opcodes);
    QVERIFY(opcodesFile.open(QIODevice::WriteOnly));
    opcodesFile.write("<opcodes/>");
    opcodesFile.close();

    // Copy the test binary as a fake python3. If Risset falls back to
    // `python3 -m risset`, the fake executable writes the marker.
    QVERIFY(!installFakeExecutable(bin.path(), u"python3"_s,
                                   u"9.9.9"_s, opcodes).isEmpty());
    qputenv("PATH", bin.path().toUtf8());
    qputenv("CSQT_FAKE_PYTHON", "1");

    Risset risset;
    qunsetenv("CSQT_FAKE_PYTHON");
    QVERIFY(!risset.isInstalled);
    QVERIFY(!QFile::exists(bin.filePath(u"python-called"_s)));
}

void TestRisset::detectsRissetScript()
{
    QTemporaryDir bin;
    QVERIFY(bin.isValid());
    const QString opcodes = bin.filePath(u"opcodes.xml"_s);
    QFile opcodesFile(opcodes);
    QVERIFY(opcodesFile.open(QIODevice::WriteOnly));
    opcodesFile.write("<opcodes/>");
    opcodesFile.close();

    QVERIFY(!installFakeExecutable(bin.path(), u"risset"_s,
                                   u"9.9.9"_s, opcodes).isEmpty());
    qputenv("PATH", bin.path().toUtf8());

    Risset risset;
    QVERIFY(risset.isInstalled);
    QCOMPARE(risset.rissetVersion, u"9.9.9"_s);
}

void TestRisset::prefersManagedRisset()
{
    const QString managedDir = Risset::pluginBinDir().absolutePath();
    QVERIFY(QDir().mkpath(managedDir));
    const QString managedOpcodes = QDir(managedDir).filePath(u"opcodes.xml"_s);
    QFile opcodesFile(managedOpcodes);
    QVERIFY(opcodesFile.open(QIODevice::WriteOnly));
    opcodesFile.write("<opcodes/>");
    opcodesFile.close();

    const QString managed = installFakeExecutable(
                managedDir, u"risset"_s, u"8.8.8"_s, managedOpcodes);
    QVERIFY(!managed.isEmpty());

    QTemporaryDir pathBin;
    QVERIFY(pathBin.isValid());
    QVERIFY(!installFakeExecutable(pathBin.path(), u"risset"_s,
                                   u"9.9.9"_s, managedOpcodes).isEmpty());
    qputenv("PATH", pathBin.path().toUtf8());

    Risset risset;
    QVERIFY(risset.isInstalled);
    QCOMPARE(risset.rissetVersion, u"8.8.8"_s);

    QFile::remove(managed);
    QFile::remove(managedOpcodes);
    QFile::remove(QDir(managedDir).filePath(u"risset-json.txt"_s));
}

void TestRisset::generatesOpcodesXml()
{
    QTemporaryDir bin;
    QVERIFY(bin.isValid());
    const QString opcodes = bin.filePath(u"opcodes.xml"_s);
    QVERIFY(!QFile::exists(opcodes));

    QVERIFY(!installFakeExecutable(bin.path(), u"risset"_s,
                                   u"7.7.7"_s, opcodes).isEmpty());
    qputenv("PATH", bin.path().toUtf8());

    Risset risset;
    QVERIFY(risset.isInstalled);
    QCOMPARE(risset.rissetVersion, u"7.7.7"_s);
    QVERIFY(QFile::exists(opcodes));
    QCOMPARE(risset.rissetOpcodesXml, opcodes);

    // risset 4 expects "dev opcodesxml --outfile PATH". The old argument order
    // is only a fallback for older risset installations.
    QFile argsFile(bin.filePath(u"risset-args.txt"_s));
    QVERIFY(argsFile.open(QIODevice::ReadOnly));
    const QStringList args = QString::fromLocal8Bit(argsFile.readAll())
            .split(u"\n"_s, Qt::SkipEmptyParts);
    QVERIFY2(args.size() >= 5, qPrintable(args.join(u" "_s)));
    QCOMPARE(args.at(0), u"--debug"_s);
    QCOMPARE(args.at(1), u"dev"_s);
    QCOMPARE(args.at(2), u"opcodesxml"_s);
    QCOMPARE(args.at(3), u"--outfile"_s);
    QCOMPARE(args.at(4), opcodes);
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    // The test binary doubles as the fake risset/python executable when it is
    // copied into a temporary bin directory. It reads risset-json.txt from its
    // own directory, so each fake installation can report a different version.
    const QFileInfo self(QCoreApplication::applicationFilePath());
    const bool asPython = qEnvironmentVariableIsSet("CSQT_FAKE_PYTHON");
    bool infoCommand = false;
    bool opcodesXmlCommand = false;
    QString outfile;
    for (int i = 1; i < argc; ++i) {
        if (qstrcmp(argv[i], "info") == 0)
            infoCommand = true;
        if (qstrcmp(argv[i], "opcodesxml") == 0)
            opcodesXmlCommand = true;
        if (qstrcmp(argv[i], "--outfile") == 0 && i + 1 < argc)
            outfile = QString::fromLocal8Bit(argv[i + 1]);
    }

    // Generating opcodes.xml: write the requested file and remember the
    // argument order, so the test can check that the current risset 4 syntax
    // is used before the legacy fallback.
    if (opcodesXmlCommand) {
        QFile argsFile(QDir(self.absolutePath()).filePath(u"risset-args.txt"_s));
        if (argsFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            for (int i = 1; i < argc; ++i) {
                argsFile.write(argv[i]);
                argsFile.write("\n");
            }
        }
        if (!outfile.isEmpty()) {
            QFile out(outfile);
            if (out.open(QIODevice::WriteOnly | QIODevice::Truncate))
                out.write("<opcodes/>");
        }
        return 0;
    }

    if (asPython) {
        QFile marker(QDir(self.absolutePath()).filePath(u"python-called"_s));
        if (marker.open(QIODevice::WriteOnly | QIODevice::Truncate))
            marker.write("called");
    }
    if (infoCommand || asPython) {
        QFile json(QDir(self.absolutePath()).filePath(u"risset-json.txt"_s));
        if (json.open(QIODevice::ReadOnly)) {
            const QByteArray payload = json.readAll();
            fwrite(payload.constData(), 1, size_t(payload.size()), stdout);
            fflush(stdout);
        }
        return 0;
    }

    TestRisset test;
    return QTest::qExec(&test, argc, argv);
}

#include "test_risset.moc"
