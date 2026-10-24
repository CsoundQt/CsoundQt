/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Lesser General Public License for more details.
*/

#include <QtTest>
#include <QFile>
#include <QFileInfo>
#include <QTemporaryDir>

#include "scanservice.h"

// A source that counts what the service asks of it and remembers the result,
// so the scheduling rules can be tested without an editor.
class FakeSource : public CodeScan::Source
{
public:
    QString text = "instr 1\nendin\n";
    QString filePath;
    QStringList includePaths;
    CodeScan::Mode mode = CodeScan::Mode::Orc;

    int textRequests = 0;
    int applied = 0;
    CodeScan::ResultPtr lastResult;

    QString scanText() override
    {
        ++textRequests;
        return text;
    }

    CodeScan::Mode scanMode() const override { return mode; }

    QString scanFilePath() const override { return filePath; }

    QStringList includeSearchPaths() override { return includePaths; }

    void applyScan(const CodeScan::ResultPtr &scan) override
    {
        ++applied;
        lastResult = scan;
    }
};

class TestScanService : public QObject
{
    Q_OBJECT

private slots:
    void testDebounceCoalescesChanges();
    void testBackgroundSourceWaits();
    void testScanNowDoesNotRescanFreshSource();
    void testScanNowPicksUpNewText();
    void testSwitchingActiveStopsPendingScan();
    void testNoneModeGivesEmptyResult();
    void testForget();
    void testDependencyChangeMarksDirty();
    void testReloadDependencies();
    void testIncludeSearchPath();
};

// Several changes in quick succession are scanned once, after the pause.
void TestScanService::testDebounceCoalescesChanges()
{
    ScanService service;
    service.setDebounceInterval(20);
    FakeSource source;

    int emitted = 0;
    connect(&service, &ScanService::scanned, this,
            [&emitted](CodeScan::Source *, const CodeScan::ResultPtr &) { ++emitted; });

    service.setActiveSource(&source);
    service.sourceChanged(&source);
    service.sourceChanged(&source);
    service.sourceChanged(&source);
    QCOMPARE(source.textRequests, 0); // still typing

    QTRY_COMPARE_WITH_TIMEOUT(source.textRequests, 1, 2000);
    QCOMPARE(source.applied, 1);
    QCOMPARE(emitted, 1);
}

// A document that is not being edited is not scanned on its text change: its
// turn comes when it is shown.
void TestScanService::testBackgroundSourceWaits()
{
    ScanService service;
    service.setDebounceInterval(20);
    FakeSource active;
    FakeSource background;

    service.setActiveSource(&active);
    service.sourceChanged(&background);
    QTest::qWait(80);

    QCOMPARE(background.textRequests, 0);
    QVERIFY(service.isDirty(&background));

    service.scanNow(&background);
    QCOMPARE(background.textRequests, 1);
    QVERIFY(!service.isDirty(&background));
}

void TestScanService::testScanNowDoesNotRescanFreshSource()
{
    ScanService service;
    FakeSource source;
    service.setActiveSource(&source);

    int emitted = 0;
    connect(&service, &ScanService::scanned, this,
            [&emitted](CodeScan::Source *, const CodeScan::ResultPtr &) { ++emitted; });

    service.scanNow(&source);
    QCOMPARE(source.textRequests, 1);

    // Asking again when nothing changed emits the result without scanning:
    // this is what showing a document does.
    service.scanNow(&source);
    QCOMPARE(source.textRequests, 1);
    QCOMPARE(source.applied, 1);
    QCOMPARE(emitted, 2);
}

void TestScanService::testScanNowPicksUpNewText()
{
    ScanService service;
    FakeSource source;
    service.setActiveSource(&source);

    service.scanNow(&source);
    QCOMPARE(source.lastResult->instruments.size(), 1);

    source.text = "instr 1\nendin\ninstr 2\nendin\n";
    service.sourceChanged(&source);
    service.scanNow(&source);

    QCOMPARE(source.textRequests, 2);
    QCOMPARE(source.lastResult->instruments.size(), 2);
}

// The pending scan of a document that was being edited belongs to that
// document, not to the one that is activated next.
void TestScanService::testSwitchingActiveStopsPendingScan()
{
    ScanService service;
    service.setDebounceInterval(20);
    FakeSource first;
    FakeSource second;

    service.setActiveSource(&first);
    service.sourceChanged(&first);
    service.setActiveSource(&second);
    QTest::qWait(80);

    QCOMPARE(first.textRequests, 0);
    QCOMPARE(second.textRequests, 0);
    QVERIFY(service.isDirty(&first));
}

void TestScanService::testNoneModeGivesEmptyResult()
{
    ScanService service;
    FakeSource source;
    source.mode = CodeScan::Mode::None;
    service.setActiveSource(&source);

    service.scanNow(&source);
    QCOMPARE(source.textRequests, 0); // nothing to scan
    QCOMPARE(source.applied, 1);
    QVERIFY(source.lastResult == CodeScan::empty());
    QVERIFY(service.result(&source) == CodeScan::empty());
}

void TestScanService::testForget()
{
    ScanService service;
    FakeSource source;
    service.setActiveSource(&source);
    service.scanNow(&source);
    QVERIFY(!service.isDirty(&source));

    service.forget(&source);
    QVERIFY(service.isDirty(&source));
    QVERIFY(service.result(&source) == CodeScan::empty());
}

// Writes a file, replacing whatever was there.
static void writeFile(const QString &path, const QString &text)
{
    QFile file(path);
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Truncate));
    file.write(text.toUtf8());
}

// A change in an included file is noticed without scanning: only the file
// stamps are compared. The source is marked dirty, nothing more.
void TestScanService::testDependencyChangeMarksDirty()
{
    QTemporaryDir directory;
    QVERIFY(directory.isValid());
    const QString includePath = directory.filePath("lib.inc");
    writeFile(includePath, "instr First\nendin\n");

    ScanService service;
    FakeSource source;
    source.filePath = directory.filePath("doc.csd");
    source.text = "#include \"lib.inc\"\n";
    service.setActiveSource(&source);

    service.scanNow(&source);
    QCOMPARE(source.lastResult->instruments.size(), 1);
    QVERIFY(!service.checkDependencies());

    writeFile(includePath, "instr First\nendin\ninstr Second\nendin\n");
    QVERIFY(service.checkDependencies());
    QVERIFY(service.isDirty(&source));
    QCOMPARE(source.textRequests, 1); // not scanned yet

    // Bringing it up to date picks up the new content.
    service.scanNow(&source);
    QCOMPARE(source.textRequests, 2);
    QCOMPARE(source.lastResult->instruments.size(), 2);
    QVERIFY(!service.checkDependencies());
}

// The reload action drops the cache and rescans every known source.
void TestScanService::testReloadDependencies()
{
    QTemporaryDir directory;
    QVERIFY(directory.isValid());
    const QString includePath = directory.filePath("lib.inc");
    writeFile(includePath, "opcode First, a, k\nendop\n");

    ScanService service;
    FakeSource active;
    active.filePath = directory.filePath("doc.csd");
    active.text = "#include \"lib.inc\"\n";
    FakeSource background;
    background.filePath = directory.filePath("other.csd");
    background.text = "#include \"lib.inc\"\n";
    service.setActiveSource(&active);
    service.scanNow(&active);
    service.scanNow(&background);
    QCOMPARE(active.lastResult->udos.size(), 1);
    QCOMPARE(background.lastResult->udos.size(), 1);

    writeFile(includePath, "opcode First, a, k\nendop\nopcode Second, a, k\nendop\n");
    service.reloadDependencies();

    QCOMPARE(active.textRequests, 2);
    QCOMPARE(background.textRequests, 2);
    QCOMPARE(active.lastResult->udos.size(), 2);
    QCOMPARE(background.lastResult->udos.size(), 2);
}

// Includes are also looked for in the search paths the source provides (the
// configured INCDIR plus its --env:INCDIR options), not only next to the
// document.
void TestScanService::testIncludeSearchPath()
{
    QTemporaryDir documentDir;
    QTemporaryDir includeDir;
    QVERIFY(documentDir.isValid());
    QVERIFY(includeDir.isValid());
    writeFile(includeDir.filePath("lib.inc"), "instr FromInclude\nendin\n");

    FakeSource source;
    source.filePath = documentDir.filePath("doc.csd");
    source.text = "#include \"lib.inc\"\n";
    source.includePaths = QStringList() << includeDir.path();

    ScanService service;
    service.setActiveSource(&source);
    service.scanNow(&source);

    QCOMPARE(source.lastResult->instruments.size(), 1);
    QCOMPARE(source.lastResult->dependencies.size(), 1);
    QCOMPARE(service.resolveInclude("lib.inc", source.filePath, source.includePaths),
             QFileInfo(includeDir.filePath("lib.inc")).canonicalFilePath());

    // Without the search path the name does not resolve.
    QCOMPARE(service.resolveInclude("lib.inc", source.filePath, QStringList()),
             QString());
}

QTEST_GUILESS_MAIN(TestScanService)
#include "test_scanservice.moc"
