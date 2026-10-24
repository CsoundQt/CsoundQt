/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the Free
    Software Foundation; either version 2.1 of the License, or (at your option)
    any later version.

    CsoundQt is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for
    more details.
*/

#include <QtTest>
#include <QGuiApplication>
#include <QScrollArea>
#include <QTextBlock>
#include <QTextCursor>
#include <QTextDocument>

#include "sourcecursor.h"
#include "texteditor.h"

// A document with the text under test, so that a cursor can be placed in it.
class TextFixture
{
public:
    explicit TextFixture(const QString &text) : m_document(text) {}

    // The cursor at the given line (1-based) and column (0-based).
    QTextCursor cursorAt(int line, int column) const
    {
        QTextBlock block = m_document.findBlockByLineNumber(line - 1);
        QTextCursor cursor(block);
        cursor.setPosition(block.position() + column);
        return cursor;
    }

private:
    QTextDocument m_document;
};

class TestGoToSource : public QObject
{
    Q_OBJECT

private slots:
    void testIdentifierAtCursor();
    void testScheduleArgument();
    void testNotScheduleArgument();
    void testIncludePathAtCursor();
    void testContextMenuPosition();
};

void TestGoToSource::testIdentifierAtCursor()
{
    // The cursor is on the name, inside it and just after it.
    {
        TextFixture fixture("asig = foo(a, b)");
        QCOMPARE(SourceCursor::identifierAt(fixture.cursorAt(1, 7)), QString("foo"));
        QCOMPARE(SourceCursor::identifierAt(fixture.cursorAt(1, 9)), QString("foo"));
        QCOMPARE(SourceCursor::identifierAt(fixture.cursorAt(1, 10)), QString("foo"));
    }
    // A quoted name is returned without the quotes.
    {
        TextFixture fixture("schedule \"MyInstr\", 0, 1");
        QCOMPARE(SourceCursor::identifierAt(fixture.cursorAt(1, 11)), QString("MyInstr"));
    }
    // Not on a name: between the '=' and the call.
    {
        TextFixture fixture("asig = foo(a, b)");
        QCOMPARE(SourceCursor::identifierAt(fixture.cursorAt(1, 6)), QString());
        QCOMPARE(SourceCursor::identifierAt(fixture.cursorAt(1, 5)), QString());
    }
    // A number is not a name.
    {
        TextFixture fixture("schedule 1.5, 0");
        QCOMPARE(SourceCursor::identifierAt(fixture.cursorAt(1, 9)), QString());
    }
}

void TestGoToSource::testScheduleArgument()
{
    // The usual syntax.
    {
        TextFixture fixture("schedule(MyInstr, 0, 1)");
        QTextCursor cursor = fixture.cursorAt(1, 9);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(SourceCursor::isScheduleArgument(cursor));
    }
    {
        TextFixture fixture("schedulek(MyInstr, 0, 1)");
        QTextCursor cursor = fixture.cursorAt(1, 10);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(SourceCursor::isScheduleArgument(cursor));
    }
    // The legacy syntax, with and without a quoted name.
    {
        TextFixture fixture("schedule MyInstr, 0, 1");
        QTextCursor cursor = fixture.cursorAt(1, 9);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(SourceCursor::isScheduleArgument(cursor));
    }
    {
        TextFixture fixture("schedule \"MyInstr\", 0, 1");
        QTextCursor cursor = fixture.cursorAt(1, 11);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(SourceCursor::isScheduleArgument(cursor));
    }
    // A space before the parenthesis is allowed.
    {
        TextFixture fixture("schedule (MyInstr, 0, 1)");
        QTextCursor cursor = fixture.cursorAt(1, 10);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(SourceCursor::isScheduleArgument(cursor));
    }
    // A variable as the first argument is a name as far as the test is
    // concerned; whether it names an instrument is decided by the caller.
    {
        TextFixture fixture("schedule Sinstr");
        QTextCursor cursor = fixture.cursorAt(1, 9);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("Sinstr"));
        QVERIFY(SourceCursor::isScheduleArgument(cursor));
    }
}

void TestGoToSource::testNotScheduleArgument()
{
    // Not the first argument.
    {
        TextFixture fixture("schedule(0, MyInstr)");
        QTextCursor cursor = fixture.cursorAt(1, 12);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(!SourceCursor::isScheduleArgument(cursor));
    }
    // Another opcode.
    {
        TextFixture fixture("foo(MyInstr)");
        QTextCursor cursor = fixture.cursorAt(1, 4);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(!SourceCursor::isScheduleArgument(cursor));
    }
    // An opcode whose name ends in "schedule".
    {
        TextFixture fixture("xschedule(MyInstr)");
        QTextCursor cursor = fixture.cursorAt(1, 10);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(!SourceCursor::isScheduleArgument(cursor));
    }
    // Not a call at all.
    {
        TextFixture fixture("asig = MyInstr");
        QTextCursor cursor = fixture.cursorAt(1, 8);
        QCOMPARE(SourceCursor::identifierAt(cursor), QString("MyInstr"));
        QVERIFY(!SourceCursor::isScheduleArgument(cursor));
    }
}

// Inside the file name of an #include directive the cursor points at the
// included file, so "Go to Source" can open it.
void TestGoToSource::testIncludePathAtCursor()
{
    // "#include \"/path/to/myinclude.udo\"": the path is at columns 10..31.
    {
        TextFixture fixture("#include \"/path/to/myinclude.udo\"");
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 10)),
                 QString("/path/to/myinclude.udo"));
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 20)),
                 QString("/path/to/myinclude.udo"));
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 32)),
                 QString("/path/to/myinclude.udo"));
        // Before the opening quote and after the closing one.
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 9)), QString());
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 33)), QString());
    }
    // The angled form, with leading whitespace.
    {
        TextFixture fixture("  #include <lib.inc>");
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 12)),
                 QString("lib.inc"));
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 15)),
                 QString("lib.inc"));
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 19)),
                 QString("lib.inc"));
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 20)), QString());
    }
    // Strings that are not an include path.
    {
        TextFixture fixture("Sfile = \"/path/to/myinclude.udo\"");
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 15)), QString());
    }
    {
        TextFixture fixture("; #include \"lib.inc\"");
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 15)), QString());
    }
    {
        TextFixture fixture("#includes \"lib.inc\"");
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 15)), QString());
    }
    // An include whose path is not closed yet is not a usable target.
    {
        TextFixture fixture("#include \"lib.inc");
        QCOMPARE(SourceCursor::includePathAt(fixture.cursorAt(1, 15)), QString());
    }
}

// The position of a context menu request has to be turned into the cursor
// of the character that was clicked. The editor has a line number area, which
// is a viewport margin, so a position in viewport coordinates must not be
// converted again.
void TestGoToSource::testContextMenuPosition()
{
    // The editor sits in a scroll area and shows line numbers, as in the
    // application.
    QScrollArea area;
    TextEditLineNumbers edit;
    edit.setPlainText("schedule MyInstr, 0, 1\n");
    edit.setLineAreaVisible(true);
    area.setWidget(&edit);
    area.resize(500, 200);
    area.show();
    qApp->processEvents();

    // "MyInstr" is at the document positions 9 to 15.
    QTextCursor word(edit.document());
    word.setPosition(9);
    word.setPosition(16, QTextCursor::KeepAnchor);
    QCOMPARE(word.selectedText(), QString("MyInstr"));

    // The position of a character in the middle of the word, in the
    // coordinates of the editor's viewport, which is what a context menu
    // request gives.
    QTextCursor inside(edit.document());
    inside.setPosition(12);
    const QPoint pos = edit.cursorRect(inside).center();

    QTextCursor clicked = edit.cursorAt(pos);
    clicked.select(QTextCursor::WordUnderCursor);
    QCOMPARE(clicked.selectedText(), QString("MyInstr"));
    QCOMPARE(clicked.selectionStart(), 9);
}

QTEST_MAIN(TestGoToSource)
#include "test_gotosource.moc"
