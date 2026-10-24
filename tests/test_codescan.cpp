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
#include <QTemporaryDir>

#include "codescan.h"
#include "includecache.h"

using namespace Qt::StringLiterals;

using namespace CodeScan;

class TestCodeScan : public QObject
{
    Q_OBJECT

private slots:
    void testCsd();
    void testOrc();
    void testNoOrchestra();
    void testUdoArgs();
    void testNewStyleUdo();
    void testBlockEndsWithComment();
    void testKeywordBoundaries();
    void testSpacedPreprocessorRejected();
    void testGlobalsOnlyInHeader();
    void testConditionalsSkipped();
    void testIncludeGuard();
    void testGuardedIncludeFile();
    void testDefinitions();
    void testDefinitionInCommentOrString();
    void testDeclarationsInMultilineComment();
    void testLastDefinitionWins();
    void testUdoOnFirstLine();
    void testGlobals();
    void testAnnotatedGlobals();
    void testUdoNameIsNotGlobal();
    void testInstrumentNames();
    void testInclude();
    void testGlobalInStringIsNotGlobal();
    void testIncludedDefinitions();
    void testNestedIncludes();
    void testIncludeCycle();
    void testIncludeInCommentOrString();
    void testMissingInclude();
    void testIncludeCacheReadsAndInvalidates();
    void testSplitPathList();
    void testIncludeOptions();
};

// Included files served from memory, so the scanner tests do not touch the
// file system.
class FakeIncludes : public CodeScan::IncludeProvider
{
public:
    QHash<QString, QString> files;
    int requests = 0;

    CodeScan::IncludeFile include(const QString &spec, const QString &includingFile,
                                  bool angled) override
    {
        Q_UNUSED(includingFile);
        Q_UNUSED(angled);
        ++requests;
        CodeScan::IncludeFile file;
        const auto it = files.constFind(spec);
        if (it == files.constEnd())
            return file;
        file.path = "/fake/" + spec;
        file.text = it.value();
        file.lastModified = 1000;
        file.size = file.text.size();
        return file;
    }
};

// A small .csd: the orchestra is only the part between the tags.
void TestCodeScan::testCsd()
{
    const QString text =
        "<CsoundSynthesizer>\n"          // 1
        "<CsOptions>\n"                  // 2
        "-o out.wav\n"                   // 3
        "</CsOptions>\n"                 // 4
        "<CsInstruments>\n"              // 5
        "\n"                             // 6
        "#define RAISE #1#\n"            // 7
        "gkGain = 0.5\n"                 // 8
        "opcode Foo, a, k\n"             // 9
        "kin xin\n"                      // 10
        "xout kin\n"                     // 11
        "endop\n"                        // 12
        "instr 1\n"                      // 13
        "endin\n"                        // 14
        "ftgen 1, 0, 8192, 10, 1\n"      // 15
        "</CsInstruments>\n"             // 16
        "<CsScore>\n"                    // 17
        "i1 0 1\n"                       // 18
        "</CsScore>\n"                   // 19
        "</CsoundSynthesizer>\n";        // 20

    const Result result = scan(text, Mode::Csd);

    QCOMPARE(result.orchestraLine, 6);
    QCOMPARE(result.scoreLine, 17);

    QCOMPARE(result.udos.size(), 1);
    QCOMPARE(result.udos.first().name, QString("Foo"));
    QCOMPARE(result.udos.first().line, 9);
    QCOMPARE(result.udos.first().text, QString("Foo, a, k"));
    QCOMPARE(result.udos.first().inArgs, QString("kin"));
    QCOMPARE(result.udos.first().inArgsLine, 10);
    QCOMPARE(result.udos.first().outArgs, QString("kin"));
    QCOMPARE(result.udos.first().outArgsLine, 11);

    QCOMPARE(result.instruments.size(), 1);
    QCOMPARE(result.instruments.first().line, 13);
    QCOMPARE(result.instruments.first().text, QString("1"));
    // A numbered instrument is not a name.
    QVERIFY(result.instruments.first().name.isEmpty());
    QVERIFY(result.instrumentNames.isEmpty());

    QCOMPARE(result.preprocessor.size(), 1);
    QCOMPARE(result.preprocessor.first().text, QString("RAISE #1#"));

    QCOMPARE(result.ftables.size(), 1);
    QCOMPARE(result.ftables.first().line, 15);

    QCOMPARE(result.globalVariables, QStringList() << "gkGain");
}

// An orchestra-only document is scanned from its first line.
void TestCodeScan::testOrc()
{
    const QString text =
        "gkGain init 0\n"       // 1
        "opcode Foo, S, k\n"    // 2
        "endop\n"               // 3
        "instr MyInstr\n"       // 4
        "endin\n";              // 5

    const Result result = scan(text, Mode::Orc);

    QCOMPARE(result.orchestraLine, 1);
    QCOMPARE(result.scoreLine, -1);
    QCOMPARE(result.globalVariables, QStringList() << "gkGain");
    QCOMPARE(result.instrumentNames, QStringList() << "MyInstr");
    QVERIFY(result.find("Foo") != nullptr);
    QVERIFY(result.find("MyInstr") != nullptr);
}

// A .csd without an orchestra section has nothing to inspect.
void TestCodeScan::testNoOrchestra()
{
    const QString text =
        "<CsoundSynthesizer>\n"
        "<CsScore>\n"
        "i1 0 1\n"
        "</CsScore>\n";

    const Result result = scan(text, Mode::Csd);
    QCOMPARE(result.orchestraLine, -1);
    QCOMPARE(result.scoreLine, 2);
    QVERIFY(result.udos.isEmpty());
    QVERIFY(result.instruments.isEmpty());
    QVERIFY(result.definitions.isEmpty());
}

// The arguments of a UDO are taken from xin / xout.
void TestCodeScan::testUdoArgs()
{
    const QString text =
        "opcode Gain, a, ak\n"
        "ain, kgain xin\n"
        "xout ain * kgain\n"
        "endop\n";

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.udos.size(), 1);
    QCOMPARE(result.udos.first().inArgs, QString("ain, kgain"));
    QCOMPARE(result.udos.first().inArgsLine, 2);
    QCOMPARE(result.udos.first().outArgs, QString("ain * kgain"));
    QCOMPARE(result.udos.first().outArgsLine, 3);
}

// Csound 7 UDO signatures carry the arguments on the declaration line.
void TestCodeScan::testNewStyleUdo()
{
    const QString text =
        "opcode Lowpass2(x:a, c1:k, c2:k):a\n" // 1
        "  xout x\n"                           // 2 (new style: not scanned)
        "endop\n"                              // 3
        "opcode Empty():void\n"                // 4
        "endop\n"                              // 5
        "opcode Pair(a:i):(a, k)\n"            // 6
        "endop\n";                             // 7

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.udos.size(), 3);

    const Definition &lowpass = result.udos.at(0);
    QVERIFY(lowpass.newStyle);
    QCOMPARE(lowpass.inArgs, QString("x, c1, c2"));
    QCOMPARE(lowpass.outArgs, QString("a"));
    QCOMPARE(lowpass.inArgsLine, -1);
    QCOMPARE(lowpass.outArgsLine, -1);

    QVERIFY(result.udos.at(1).newStyle);
    QVERIFY(result.udos.at(1).inArgs.isEmpty());
    QVERIFY(result.udos.at(1).outArgs.isEmpty());

    QCOMPARE(result.udos.at(2).inArgs, QString("a"));
    QCOMPARE(result.udos.at(2).outArgs, QString("a, k"));
}

// A trailing comment does not stop endin/endop from closing the block.
void TestCodeScan::testBlockEndsWithComment()
{
    const Result instruments = scan(
        "instr 1\nendin ; done\ninstr Bells\nendin // done\n", Mode::Orc);
    QCOMPARE(instruments.instruments.size(), 2);
    QCOMPARE(instruments.instruments.at(1).name, QString("Bells"));

    const Result udos = scan(
        "opcode A, a, k\nendop ; done\nopcode B, a, k\nendop // done\n", Mode::Orc);
    QCOMPARE(udos.udos.size(), 2);
    QCOMPARE(udos.udos.at(1).name, QString("B"));
}

// A keyword must be a word of its own, not the prefix of a variable name.
void TestCodeScan::testKeywordBoundaries()
{
    const Result result = scan(
        "instrnum = 1\n"
        "ftgenfoo = 2\n", Mode::Orc);
    QVERIFY(result.instruments.isEmpty());
    QVERIFY(result.ftables.isEmpty());
}

// The scanner accepts only the "#define" and "#include" spellings.
void TestCodeScan::testSpacedPreprocessorRejected()
{
    FakeIncludes includes;
    includes.files.insert(u"lib.inc"_s, "instr FromInclude\nendin\n");
    const QString text =
        "# define FOO #1#\n"
        "# include \"lib.inc\"\n"
        "#includestr \"lib.inc\"\n";

    const Result result = scan(text, Mode::Orc, &includes);
    QCOMPARE(includes.requests, 0);
    QVERIFY(result.preprocessor.isEmpty());
    QVERIFY(result.definitions.isEmpty());
    QVERIFY(result.instruments.isEmpty());
}

// Only the header defines globals; instrument and opcode bodies are not
// scanned at all (an opcode exposes only its xin/xout arguments).
void TestCodeScan::testGlobalsOnlyInHeader()
{
    const QString text =
        "gkHead init 0\n"           // 1
        "instr 1\n"                 // 2
        "gkBody init 1\n"           // 3
        "gain = 2\n"                // 4
        "#define BODY #1#\n"        // 5
        "ftgen 3, 0, 8192, 10, 1\n" // 6
        "endin\n"                   // 7
        "opcode Foo, a, k\n"        // 8
        "gkOp init 3\n"             // 9
        "xin\n"                     // 10
        "xout gaSig\n"              // 11
        "endop\n"                   // 12
        "gkTail init 4\n";          // 13

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.globalVariables, QStringList() << "gkHead" << "gkTail");
    QCOMPARE(result.udos.size(), 1);
    QVERIFY(result.udos.first().inArgs.isEmpty());
    QCOMPARE(result.udos.first().outArgs, QString("gaSig"));
    QVERIFY(result.preprocessor.isEmpty()); // #define inside the instrument
    QVERIFY(result.ftables.isEmpty());      // ftgen inside the instrument
    QVERIFY(result.find("BODY") == nullptr);
}

// Conditional compilation is not evaluated: the whole #ifdef ... #endif
// region (including #else) is skipped.
void TestCodeScan::testConditionalsSkipped()
{
    FakeIncludes includes;
    includes.files.insert(u"hidden.inc"_s, "instr FromHidden\nendin\n");
    const QString text =
        "gkHead init 0\n"
        "#ifdef DEBUG\n"
        "instr Hidden\n"
        "endin\n"
        "gkHidden init 0\n"
        "#include \"hidden.inc\"\n"
        "#else\n"
        "instr AlsoHidden\n"
        "endin\n"
        "#endif\n"
        "#ifndef NESTED\n"
        "#ifdef INNER\n"
        "opcode HiddenOp, a, k\n"
        "endop\n"
        "#end\n"
        "instr StillHidden\n"
        "endin\n"
        "#endif\n"
        "instr Visible\n"
        "endin\n"
        "gkTail init 0\n";

    const Result result = scan(text, Mode::Orc, &includes);
    QCOMPARE(includes.requests, 0);
    QCOMPARE(result.instruments.size(), 1);
    QCOMPARE(result.instruments.first().name, QString("Visible"));
    QVERIFY(result.udos.isEmpty());
    QCOMPARE(result.globalVariables, QStringList() << "gkHead" << "gkTail");
}

// #ifndef NAME immediately followed by #define NAME is an include guard: its
// body is the file's code, unlike an ordinary unsupported conditional.
void TestCodeScan::testIncludeGuard()
{
    const QString text =
        "#ifndef __GUARD__\n"
        "#define __GUARD__  ##\n"
        "gkHead init 0\n"
        "opcode Local, a, k\n"
        "endop\n"
        "instr GuardedInstr\n"
        "endin\n"
        "#ifdef NESTED\n"
        "instr Hidden\n"
        "endin\n"
        "#endif\n"
        "gkTail init 0\n"
        "#endif\n";

    const Result result = scan(text, Mode::Orc);
    QVERIFY(result.find("Local") != nullptr);
    QCOMPARE(result.instruments.size(), 1);
    QCOMPARE(result.instruments.first().name, QString("GuardedInstr"));
    QCOMPARE(result.globalVariables, QStringList() << "gkHead" << "gkTail");
}

// An include guard must not hide the included file from the scan: zlib.udo
// and many other UDO libraries use this pattern.
void TestCodeScan::testGuardedIncludeFile()
{
    FakeIncludes includes;
    includes.files.insert(u"zlib.udo"_s,
        "#ifndef __ZLIB__\n"
        "#define __ZLIB__  ##\n"
        "opcode zinit, 0, ii\n"
        "endop\n"
        "instr _zdecref\n"
        "endin\n"
        "#endif\n");

    const Result result = scan("#include \"zlib.udo\"\n", Mode::Orc, &includes);
    QCOMPARE(result.dependencies.size(), 1);
    QCOMPARE(result.udos.size(), 1);
    QCOMPARE(result.udos.first().name, QString("zinit"));
    QCOMPARE(result.instruments.size(), 1);
    QCOMPARE(result.instruments.first().name, QString("_zdecref"));
    QVERIFY(result.find("zinit") != nullptr);
}

void TestCodeScan::testDefinitions()
{
    const QString text =
        "<CsInstruments>\n"            // 1
        "opcode Foo, S, k\n"           // 2
        "endop\n"                      // 3
        "instr MyInstr\n"              // 4
        "endin\n"                      // 5
        "#define RAISE #1#\n"          // 6
        "struct MyType val0:i\n"       // 7
        "instr 1, 2\n";                // 8

    const Result result = scan(text, Mode::Csd);

    const Definition *udo = result.find("Foo");
    QVERIFY(udo != nullptr);
    QCOMPARE(udo->kind, Kind::Udo);
    QCOMPARE(udo->line, 2);
    QCOMPARE(udo->column, 7);

    const Definition *instrument = result.find("MyInstr");
    QVERIFY(instrument != nullptr);
    QCOMPARE(instrument->kind, Kind::Instrument);
    QCOMPARE(instrument->line, 4);
    QCOMPARE(instrument->column, 6);

    const Definition *macro = result.find("RAISE");
    QVERIFY(macro != nullptr);
    QCOMPARE(macro->kind, Kind::Macro);
    QCOMPARE(macro->line, 6);

    const Definition *type = result.find("MyType");
    QVERIFY(type != nullptr);
    QCOMPARE(type->kind, Kind::Struct);
    QCOMPARE(type->line, 7);

    QVERIFY(result.find("1") == nullptr);

    QCOMPARE(result.udos.size(), 1);
    QCOMPARE(result.udos.first().name, QString("Foo"));
}

void TestCodeScan::testDefinitionInCommentOrString()
{
    const QString text =
        "; opcode Commented, S, k\n"
        "/* opcode BlockComment, S, k */\n"
        "print \"opcode InString, S, k\"\n"
        "{{\n"
        "opcode InMultilineString, S, k\n"
        "}}\n";

    const Result result = scan(text, Mode::Orc);
    QVERIFY(result.find("Commented") == nullptr);
    QVERIFY(result.find("BlockComment") == nullptr);
    QVERIFY(result.find("InString") == nullptr);
    QVERIFY(result.find("InMultilineString") == nullptr);
    QVERIFY(result.definitions.isEmpty());
}

// Declarations inside a multi-line /* ... */ comment are not code: they must
// not reach the inspector lists or the names used for completion.
void TestCodeScan::testDeclarationsInMultilineComment()
{
    const QString text =
        "gkReal init 0\n"               // 1
        "instr Real\n"                  // 2
        "endin\n"                       // 3
        "/*\n"                          // 4
        "instr Commented\n"             // 5
        "gkCommented init 0\n"          // 6
        "endin\n"                       // 7
        "opcode CommentedOp, a, k\n"    // 8
        "xin\n"                         // 9
        "endop\n"                       // 10
        "#define COMMENTED #1#\n"       // 11
        "ftgen 5, 0, 8192, 10, 1\n"     // 12
        "*/\n"                          // 13
        "/* instr InlineCommented */\n" // 14
        "{{\n"                          // 15
        "instr InMultilineString\n"     // 16
        "}}\n"                          // 17
        "instr After\n"                 // 18
        "endin\n";                      // 19

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.instruments.size(), 2);
    QCOMPARE(result.instruments.at(0).name, QString("Real"));
    QCOMPARE(result.instruments.at(1).name, QString("After"));
    QVERIFY(result.udos.isEmpty());
    QVERIFY(result.ftables.isEmpty());
    QVERIFY(result.preprocessor.isEmpty());
    QVERIFY(result.find("Commented") == nullptr);
    QVERIFY(result.find("CommentedOp") == nullptr);
    QCOMPARE(result.globalVariables, QStringList() << "gkReal");
}

void TestCodeScan::testLastDefinitionWins()
{
    const QString text =
        "opcode Foo, S, k\n"      // 1
        "endop\n"                 // 2
        "opcode Foo, S, k, i\n"   // 3
        "endop\n";                // 4

    const Result result = scan(text, Mode::Orc);
    const Definition *udo = result.find("Foo");
    QVERIFY(udo != nullptr);
    QCOMPARE(udo->line, 3);
}

void TestCodeScan::testUdoOnFirstLine()
{
    const Result result = scan("opcode First, S, k\nendop\ninstr Second\nendin\n",
                               Mode::Orc);

    const Definition *udo = result.find("First");
    QVERIFY(udo != nullptr);
    QCOMPARE(udo->line, 1);

    const Definition *instrument = result.find("Second");
    QVERIFY(instrument != nullptr);
    QCOMPARE(instrument->line, 3);
}

void TestCodeScan::testGlobals()
{
    const QString text =
        "gkLevel init 0\n"
        "gaSig init 0\n"
        "gSName init \"\"\n"
        "kLocal init 0\n";

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.globalVariables,
             QStringList() << "gaSig" << "gkLevel" << "gSName");
    QCOMPARE(result.globalStringVariables, QStringList() << "gSName");
}

void TestCodeScan::testAnnotatedGlobals()
{
    const QString text =
        "gain@global:a = 0\n"
        "level:k = 0\n"
        "gkfoo:a = 0\n"; // an explicit local type wins over the g prefix

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.globalVariables, QStringList() << "gain");
}

void TestCodeScan::testUdoNameIsNotGlobal()
{
    const QString text =
        "opcode gfoo, S, k\n"
        "endop\n"
        "gfoo \"x\"\n";

    const Result result = scan(text, Mode::Orc);
    QVERIFY(result.globalVariables.isEmpty());
    QVERIFY(result.find("gfoo") != nullptr);
}

void TestCodeScan::testInstrumentNames()
{
    const QString text =
        "instr 1\n"
        "endin\n"
        "instr Bells\n"
        "endin\n"
        "instr \"Quoted Name\"\n"
        "endin\n";

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.instrumentNames, QStringList() << "Bells" << "Quoted Name");
    QCOMPARE(result.instruments.size(), 3);
    QCOMPARE(result.instruments.at(2).text, QString("\"Quoted Name\""));
}

void TestCodeScan::testInclude()
{
    const QString text =
        "#include \"udo.inc\"\n"
        "instr 1\n"
        "endin\n";

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.preprocessor.size(), 1);
    QCOMPARE(result.preprocessor.first().kind, Kind::Include);
    QCOMPARE(result.preprocessor.first().line, 1);
    // An include is not a definition of a name.
    QVERIFY(result.definitions.isEmpty());
}

// A global name inside a string is not a variable, but one before a block
// comment on the same line is.
void TestCodeScan::testGlobalInStringIsNotGlobal()
{
    const QString text =
        "print \"gkInString\"\n"
        "gkReal = 0 /* gkInComment */\n";

    const Result result = scan(text, Mode::Orc);
    QCOMPARE(result.globalVariables, QStringList() << "gkReal");
}

// An include is expanded where it appears: its opcodes, instruments, macros
// and globals are part of the document, and its definitions carry their file.
void TestCodeScan::testIncludedDefinitions()
{
    FakeIncludes includes;
    includes.files.insert(u"lib.inc"_s,
        "opcode FromInclude, a, k\n"
        "endop\n"
        "#define INC_MACRO #1#\n"
        "instr IncludedInstr\n"
        "endin\n"
        "gkFromInclude init 0\n"
        "ftgen 2, 0, 8192, 10, 1\n");

    const QString text =
        "<CsInstruments>\n"        // 1
        "#include \"lib.inc\"\n"  // 2
        "opcode Local, a, k\n"     // 3
        "endop\n"                  // 4
        "</CsInstruments>\n";      // 5

    // The document has a path of its own; that path must not end up in the
    // file of its own definitions: only included files carry one.
    const Result result = scan(text, Mode::Csd, &includes, u"/fake/main.csd"_s);
    QCOMPARE(includes.requests, 1);

    // The included definition is known, with the file it lives in.
    const Definition *external = result.find("FromInclude");
    QVERIFY(external != nullptr);
    QCOMPARE(external->file, QString("/fake/lib.inc"));
    QCOMPARE(external->line, 1);

    // A definition of the document itself keeps its empty file.
    const Definition *local = result.find("Local");
    QVERIFY(local != nullptr);
    QVERIFY(local->file.isEmpty());

    // Highlighting and completion see the included names.
    QCOMPARE(result.udos.size(), 2);
    QCOMPARE(result.udos.first().name, QString("FromInclude"));
    QCOMPARE(result.udos.first().file, QString("/fake/lib.inc"));
    QCOMPARE(result.instrumentNames, QStringList() << "IncludedInstr");
    QCOMPARE(result.globalVariables, QStringList() << "gkFromInclude");

    // The include directive is listed in the tree, in the document's file.
    QCOMPARE(result.preprocessor.size(), 2);
    QCOMPARE(result.preprocessor.at(0).kind, Kind::Include);
    QVERIFY(result.preprocessor.at(0).file.isEmpty());
    QCOMPARE(result.preprocessor.at(1).kind, Kind::Macro);
    QCOMPARE(result.preprocessor.at(1).file, QString("/fake/lib.inc"));

    // The included ftable is listed too.
    QCOMPARE(result.ftables.size(), 1);
    QCOMPARE(result.ftables.first().file, QString("/fake/lib.inc"));

    // The dependency is recorded with its stamp.
    QCOMPARE(result.dependencies.size(), 1);
    QCOMPARE(result.dependencies.first().path, QString("/fake/lib.inc"));
    QCOMPARE(result.dependencies.first().lastModified, qint64(1000));
    QCOMPARE(result.dependencies.first().size, qint64(includes.files.value("lib.inc").size()));
}

void TestCodeScan::testNestedIncludes()
{
    FakeIncludes includes;
    includes.files.insert(u"a.inc"_s, "#include \"b.inc\"\n");
    includes.files.insert(u"b.inc"_s,
        "#include \"c.inc\"\n"
        "instr FromB\n"
        "endin\n");
    includes.files.insert(u"c.inc"_s,
        "opcode FromC, a, k\n"
        "endop\n");

    const Result result = scan("#include \"a.inc\"\n", Mode::Orc, &includes);

    QVERIFY(result.find("FromC") != nullptr);
    QCOMPARE(result.find("FromC")->file, QString("/fake/c.inc"));
    QVERIFY(result.find("FromB") != nullptr);
    QCOMPARE(result.instrumentNames, QStringList() << "FromB");
    QCOMPARE(result.dependencies.size(), 3);
}

void TestCodeScan::testIncludeCycle()
{
    FakeIncludes includes;
    includes.files.insert(u"a.inc"_s,
        "#include \"b.inc\"\n"
        "instr FromA\n"
        "endin\n");
    includes.files.insert(u"b.inc"_s,
        "#include \"a.inc\"\n"
        "instr FromB\n"
        "endin\n");

    const Result result = scan("#include \"a.inc\"\n", Mode::Orc, &includes);
    QCOMPARE(result.instruments.size(), 2);
    QCOMPARE(result.dependencies.size(), 2);
}

void TestCodeScan::testIncludeInCommentOrString()
{
    FakeIncludes includes;
    includes.files.insert(u"lib.inc"_s, "instr Hidden\nendin\n");

    const QString text =
        "; #include \"lib.inc\"\n"
        "print \"#include \\\"lib.inc\\\"\"\n";

    const Result result = scan(text, Mode::Orc, &includes);
    QCOMPARE(includes.requests, 0);
    QVERIFY(result.instruments.isEmpty());
}

void TestCodeScan::testMissingInclude()
{
    FakeIncludes includes;

    const Result result = scan("#include \"nope.inc\"\n", Mode::Orc, &includes);
    QCOMPARE(includes.requests, 1);
    QVERIFY(result.dependencies.isEmpty());
    // The directive itself is still listed in the tree.
    QCOMPARE(result.preprocessor.size(), 1);
    QCOMPARE(result.preprocessor.first().kind, Kind::Include);
}

// The cache only answers with a text while the file has the stamp it had when
// it was read.
void TestCodeScan::testIncludeCacheReadsAndInvalidates()
{
    QTemporaryDir directory;
    QVERIFY(directory.isValid());
    const QString includePath = directory.filePath("lib.inc");
    {
        QFile file(includePath);
        QVERIFY(file.open(QIODevice::WriteOnly));
        file.write("instr First\nendin\n");
    }
    const QString documentPath = directory.filePath("doc.csd");

    IncludeCache cache;
    const CodeScan::IncludeFile first = cache.include("lib.inc", documentPath, false);
    QCOMPARE(first.path, QFileInfo(includePath).canonicalFilePath());
    QVERIFY(first.text.contains("First"));
    QCOMPARE(cache.cachedFileCount(), 1);

    // The same file again: the cached text is used.
    const CodeScan::IncludeFile again = cache.include("lib.inc", documentPath, false);
    QCOMPARE(again.text, first.text);

    // A changed file is read again, not served from the cache.
    {
        QFile file(includePath);
        QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Truncate));
        file.write("instr Second\nendin\n");
    }
    const CodeScan::IncludeFile changed = cache.include("lib.inc", documentPath, false);
    QVERIFY(changed.text.contains("Second"));

    // A missing include resolves to nothing.
    QVERIFY(cache.include("missing.inc", documentPath, false).path.isEmpty());

    // Relative includes are resolved against the including file.
    QCOMPARE(cache.resolvePath("lib.inc", documentPath, false),
             QFileInfo(includePath).canonicalFilePath());
}

// A Csound search path can use ':' or ';' as a separator; a Windows drive
// colon belongs to the path.
void TestCodeScan::testSplitPathList()
{
    QCOMPARE(IncludeCache::splitPathList(u"/a:/b;/c"_s),
             QStringList() << "/a" << "/b" << "/c");
    QCOMPARE(IncludeCache::splitPathList(u"C:\\one;D:\\two"_s),
             QStringList() << "C:\\one" << "D:\\two");
    QCOMPARE(IncludeCache::splitPathList(":/a::/b:"_L1),
             QStringList() << "/a" << "/b");
    QCOMPARE(IncludeCache::splitPathList(QString()), QStringList());
}

// Only the --env:INCDIR options of the document count; each one replaces or
// appends in the order it appears.
void TestCodeScan::testIncludeOptions()
{
    const QStringList base = QStringList() << "/from/settings";
    const QString options =
        "; --env:INCDIR=/commented-out\n"
        "// --env:INCDIR=/also/commented\n"
        "--env:INCDIR=/one:/two\n"
        "--env:INCDIR+=/three\n"
        "--env:INCDIR=\"/four:/with space\"\n"
        "--env:INCDIR+='/six;/seven'\n";
    QCOMPARE(IncludeCache::includePathsFromOptions(options, base),
             QStringList() << "/four" << "/with space" << "/six" << "/seven");

    // Without options the configured path is used unchanged.
    QCOMPARE(IncludeCache::includePathsFromOptions(QString(), base), base);

    // The setting is the starting point of an append.
    QCOMPARE(IncludeCache::includePathsFromOptions(
                 u"--env:INCDIR+=/more\n"_s, base),
             QStringList() << "/from/settings" << "/more");
}

QTEST_MAIN(TestCodeScan)
#include "test_codescan.moc"
