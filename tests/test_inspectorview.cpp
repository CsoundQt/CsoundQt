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
#include <QTreeWidget>

#include "codescan.h"
#include "inspector.h"

using namespace Qt::StringLiterals;

// Included files served from memory.
class FakeIncludes : public CodeScan::IncludeProvider
{
public:
    QHash<QString, QString> files;

    CodeScan::IncludeFile include(const QString &spec, const QString &,
                                  bool) override
    {
        CodeScan::IncludeFile file;
        const auto it = files.constFind(spec);
        if (it == files.constEnd())
            return file;
        file.path = "/fake/" + spec;
        file.text = it.value();
        return file;
    }
};

// The inspector is a view of a CodeScan result: these tests check that the
// tree shows what the scan found, at the lines the editor has to jump to.
class TestInspectorView : public QObject
{
    Q_OBJECT

private slots:
    void init();
    void cleanup();
    void testGroups();
    void testOpcodeArgs();
    void testNewStyleOpcode();
    void testEmptyScan();
    void testIncludedSymbolsNotListed();

private:
    QTreeWidget *tree() const
    {
        return m_inspector->findChild<QTreeWidget *>();
    }

    Inspector *m_inspector = nullptr;
};

void TestInspectorView::init()
{
    m_inspector = new Inspector(nullptr);
    // The tree is only built while the dock is visible.
    m_inspector->show();
}

void TestInspectorView::cleanup()
{
    delete m_inspector;
    m_inspector = nullptr;
}

void TestInspectorView::testGroups()
{
    const QString text =
        "<CsInstruments>\n"        // 1
        "opcode Foo, a, k\n"       // 2
        "endop\n"                  // 3
        "#define RAISE #1#\n"      // 4
        "instr 1\n"                // 5
        "endin\n"                  // 6
        "ftgen 1, 0, 8192, 10, 1\n"// 7
        "</CsInstruments>\n"       // 8
        "<CsScore>\n"              // 9
        "</CsScore>\n";            // 10

    m_inspector->setScan(CodeScan::scanPtr(text, CodeScan::Mode::Csd));
    QTreeWidget *tree = this->tree();
    QVERIFY(tree != nullptr);
    QCOMPARE(tree->topLevelItemCount(), 5);

    QTreeWidgetItem *opcodes = tree->topLevelItem(0);
    QCOMPARE(opcodes->text(0), QString("Opcodes"));
    QCOMPARE(opcodes->childCount(), 1);
    QCOMPARE(opcodes->child(0)->text(0), QString("Foo, a, k"));
    QCOMPARE(static_cast<TreeItem *>(opcodes->child(0))->getLine(), 2);

    QTreeWidgetItem *macros = tree->topLevelItem(1);
    QCOMPARE(macros->text(0), QString("Macros"));
    QCOMPARE(macros->childCount(), 1);
    QCOMPARE(macros->child(0)->text(0), QString("RAISE #1#"));
    QCOMPARE(static_cast<TreeItem *>(macros->child(0))->getLine(), 4);

    QTreeWidgetItem *instruments = tree->topLevelItem(2);
    QCOMPARE(instruments->text(0), QString("Instruments"));
    QCOMPARE(instruments->childCount(), 1);
    QCOMPARE(instruments->child(0)->text(0), QString("1"));
    QCOMPARE(static_cast<TreeItem *>(instruments->child(0))->getLine(), 5);
    // The group itself jumps to the first line of the orchestra section.
    QCOMPARE(static_cast<TreeItem *>(instruments)->getLine(), 2);

    QTreeWidgetItem *ftables = tree->topLevelItem(3);
    QCOMPARE(ftables->text(0), QString("F-tables"));
    QCOMPARE(ftables->childCount(), 1);
    QCOMPARE(ftables->child(0)->text(0), QString("ftgen 1, 0, 8192, 10, 1"));

    QTreeWidgetItem *score = tree->topLevelItem(4);
    QCOMPARE(score->text(0), QString("Score"));
    QCOMPARE(static_cast<TreeItem *>(score)->getLine(), 9);
}

void TestInspectorView::testOpcodeArgs()
{
    const QString text =
        "opcode Gain, a, ak\n"      // 1
        "ain, kgain xin\n"          // 2
        "xout ain * kgain\n"        // 3
        "endop\n";                  // 4

    m_inspector->setScan(CodeScan::scanPtr(text, CodeScan::Mode::Orc));
    QTreeWidget *tree = this->tree();
    QTreeWidgetItem *opcode = tree->topLevelItem(0)->child(0);
    QVERIFY(opcode != nullptr);
    QCOMPARE(opcode->text(0), QString("Gain, a, ak"));
    QCOMPARE(opcode->childCount(), 2);
    QCOMPARE(opcode->child(0)->text(0), QString("ain, kgain xin"));
    QCOMPARE(static_cast<TreeItem *>(opcode->child(0))->getLine(), 2);
    QCOMPARE(opcode->child(1)->text(0), QString("xout ain * kgain"));
    QCOMPARE(static_cast<TreeItem *>(opcode->child(1))->getLine(), 3);
}

// A Csound 7 signature carries the arguments in the declaration line, so the
// tree does not add the xin/xout rows used by the classic form.
void TestInspectorView::testNewStyleOpcode()
{
    const QString text =
        "opcode Gain(x:a, g:k):a\n"
        "  xout x * g\n"
        "endop\n";

    m_inspector->setScan(CodeScan::scanPtr(text, CodeScan::Mode::Orc));
    QTreeWidgetItem *opcode = tree()->topLevelItem(0)->child(0);
    QVERIFY(opcode != nullptr);
    QCOMPARE(opcode->text(0), QString("Gain(x:a, g:k):a"));
    QCOMPARE(opcode->childCount(), 0);
}

void TestInspectorView::testEmptyScan()
{
    m_inspector->setScan(CodeScan::empty());
    QTreeWidget *tree = this->tree();
    QCOMPARE(tree->topLevelItemCount(), 5);
    for (int i = 0; i < tree->topLevelItemCount(); ++i)
        QCOMPARE(tree->topLevelItem(i)->childCount(), 0);
}

// The tree describes the document the user is editing. Symbols that an
// #include pulls in are part of the scan (completion, highlighting, Go to
// Source) but belong to a subsidiary file, so they are not listed here.
void TestInspectorView::testIncludedSymbolsNotListed()
{
    FakeIncludes includes;
    includes.files.insert(u"lib.inc"_s,
        "opcode FromInclude, a, k\n"
        "endop\n"
        "#define FROM_INCLUDE #1#\n"
        "instr IncludedInstr\n"
        "endin\n"
        "ftgen 2, 0, 8192, 10, 1\n");

    const QString text =
        "#include \"lib.inc\"\n"  // 1
        "opcode Local, a, k\n"    // 2
        "endop\n";                // 3

    m_inspector->setScan(CodeScan::scanPtr(text, CodeScan::Mode::Orc, &includes));
    QTreeWidget *tree = this->tree();

    // The included opcode is not listed, and the group still jumps to the
    // first opcode of the document, not to one from the included file.
    QTreeWidgetItem *opcodes = tree->topLevelItem(0);
    QCOMPARE(opcodes->childCount(), 1);
    QCOMPARE(opcodes->child(0)->text(0), QString("Local, a, k"));
    QCOMPARE(static_cast<TreeItem *>(opcodes)->getLine(), 2);

    // The #include directive itself is part of the document. The macro that
    // the included file defines is not.
    QTreeWidgetItem *macros = tree->topLevelItem(1);
    QCOMPARE(macros->childCount(), 1);
    QCOMPARE(macros->child(0)->text(0), QString("#include \"lib.inc\""));
    QCOMPARE(static_cast<TreeItem *>(macros)->getLine(), 1);

    QCOMPARE(tree->topLevelItem(2)->childCount(), 0); // instruments
    QCOMPARE(tree->topLevelItem(3)->childCount(), 0); // f-tables

    // A document whose symbols all come from an include shows empty groups,
    // and the empty groups do not navigate anywhere.
    m_inspector->setScan(CodeScan::scanPtr(u"#include \"lib.inc\"\n"_s,
                                          CodeScan::Mode::Orc, &includes));
    opcodes = tree->topLevelItem(0);
    QCOMPARE(opcodes->childCount(), 0);
    QCOMPARE(static_cast<TreeItem *>(opcodes)->getLine(), -1);
    QCOMPARE(static_cast<TreeItem *>(tree->topLevelItem(3))->getLine(), -1);
}

QTEST_MAIN(TestInspectorView)
#include "test_inspectorview.moc"
