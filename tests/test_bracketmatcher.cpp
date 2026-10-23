/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#include <QtTest>
#include <QGuiApplication>
#include <QTextCursor>
#include <QTextDocument>
#include <QTextLayout>

#include "bracketmatcher.h"
#include "editorthemes.h"
#include "highlighter.h"

// The ranges of a scan as a readable string, e.g. "0-5;10-20".
static QString formatRanges(const QVector<QPair<int, int>> &ranges)
{
    QStringList parts;
    for (const QPair<int, int> &range : ranges)
        parts << QString("%1-%2").arg(range.first).arg(range.second);
    return parts.join(';');
}

// The colour the block is painted with at the given position: the last format
// range covering it wins, as it does when the block is drawn.
static QColor colourAt(const QTextDocument &document, int position)
{
    const QTextBlock block = document.findBlock(position);
    const QTextLayout *layout = block.layout();
    if (!layout)
        return QColor();
    const int offset = position - block.position();
    QColor colour;
    const QVector<QTextLayout::FormatRange> formats = layout->formats();
    for (const QTextLayout::FormatRange &range : formats) {
        if (range.start <= offset && offset < range.start + range.length)
            colour = range.format.foreground().color();
    }
    return colour;
}

class TestBracketMatcher : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        EditorThemes::initialize();
    }

    void matchesPair_data()
    {
        QTest::addColumn<QString>("text");
        QTest::addColumn<int>("cursorPosition");
        QTest::addColumn<int>("expectedFirst");
        QTest::addColumn<int>("expectedSecond");

        // The cursor is between two characters: it matches when it is just
        // before an opening or just after a closing bracket.
        QTest::newRow("forward") << "(a+b)*c" << 0 << 0 << 4;
        QTest::newRow("backward") << "(a+b)*c" << 5 << 0 << 4;
        QTest::newRow("nested outer") << "((a))" << 0 << 0 << 4;
        QTest::newRow("nested inner") << "((a))" << 1 << 1 << 3;
        QTest::newRow("empty pair") << "()" << 0 << 0 << 1;
        QTest::newRow("not next to a bracket") << "(a+b)" << 2 << -1 << -1;
        QTest::newRow("unmatched opening") << "(a+b" << 0 << -1 << -1;
        QTest::newRow("unmatched closing") << "a+b)" << 4 << -1 << -1;
        QTest::newRow("across blocks") << "(a\n+b)" << 0 << 0 << 5;
        QTest::newRow("across blocks backward") << "(a\n+b)" << 6 << 0 << 5;
        QTest::newRow("triple nested middle") << "(((x)))" << 6 << 1 << 5;
        QTest::newRow("triple nested outer") << "(((x)))" << 7 << 0 << 6;
    }

    void matchesPair()
    {
        QFETCH(QString, text);
        QFETCH(int, cursorPosition);
        QFETCH(int, expectedFirst);
        QFETCH(int, expectedSecond);

        const QPair<int, int> pair = match(text, cursorPosition);
        QCOMPARE(pair.first, expectedFirst);
        QCOMPARE(pair.second, expectedSecond);
    }

    // The other kinds of brackets are matched as well.
    void matchesOtherBracketKinds_data()
    {
        QTest::addColumn<QString>("text");
        QTest::addColumn<int>("cursorPosition");
        QTest::addColumn<int>("expectedFirst");
        QTest::addColumn<int>("expectedSecond");

        QTest::newRow("square") << "iArr[10] = 1" << 4 << 4 << 7;
        QTest::newRow("square backward") << "iArr[10] = 1" << 8 << 4 << 7;
        QTest::newRow("curly") << "x = {y}" << 4 << 4 << 6;
        QTest::newRow("nested kinds") << "([{}])" << 0 << 0 << 5;
        QTest::newRow("nested kinds inner") << "([{}])" << 1 << 1 << 4;
        // A bracket of another kind does not close the one before it.
        QTest::newRow("mismatched kinds") << "([)]" << 0 << -1 << -1;
    }

    void matchesOtherBracketKinds()
    {
        QFETCH(QString, text);
        QFETCH(int, cursorPosition);
        QFETCH(int, expectedFirst);
        QFETCH(int, expectedSecond);

        const QPair<int, int> pair = match(text, cursorPosition);
        QCOMPARE(pair.first, expectedFirst);
        QCOMPARE(pair.second, expectedSecond);
    }

    // Brackets in comments and strings are not code, so they never match.
    void ignoresBracketsOutsideCode_data()
    {
        QTest::addColumn<QString>("text");
        QTest::addColumn<int>("cursorPosition");

        QTest::newRow("in a string") << "print \"a (b) c\"" << 9;
        QTest::newRow("in a line comment") << "a = 1 ; (b)" << 8;
        QTest::newRow("in a line comment, // ") << "a = 1 // (b)" << 8;
        QTest::newRow("in a multiline string") << "{{ a ( b }}" << 4;
        QTest::newRow("in a multiline comment") << "/* x\n ( y )\n*/ z" << 6;
    }

    void ignoresBracketsOutsideCode()
    {
        QFETCH(QString, text);
        QFETCH(int, cursorPosition);

        const QPair<int, int> pair = match(text, cursorPosition);
        QCOMPARE(pair.first, -1);
        QCOMPARE(pair.second, -1);
    }

    // A bracket in code still matches when a string or a comment follows it.
    void matchesBracketsInCode()
    {
        const QPair<int, int> pair = match("a = (1) ; a string \"(x)\"", 4);
        QCOMPARE(pair.first, 4);
        QCOMPARE(pair.second, 6);
    }

    // The same in a piece of a Csound file: the comment and the string are
    // not code, the nested brackets are.
    void ignoresBracketsOutsideCodeInAFile()
    {
        const QString text = QStringLiteral(
            "<CsInstruments>\n"
            "instr 1\n"
            "  ; a comment ( in comment\n"
            "  Smsg = \"a string ( in string\"\n"
            "  kfreq = (440 + (55 * 2))\n"
            "endin\n");

        const int commentBracket = text.indexOf("( in comment");
        const int stringBracket = text.indexOf("( in string");
        const int codeBracket = text.indexOf("(440");

        QCOMPARE(match(text, commentBracket).first, -1);
        QCOMPARE(match(text, stringBracket).first, -1);

        const QPair<int, int> pair = match(text, codeBracket);
        QCOMPARE(pair.first, codeBracket);
        QCOMPARE(pair.second, text.indexOf("))") + 1);
    }

    // The bracket index must exist even when highlighting is switched off, so
    // matching is a navigation aid rather than decoration.
    void matchesUnderNoneTheme()
    {
        QTextDocument document;
        document.setPlainText(QStringLiteral("(a+b)"));
        Highlighter highlighter(&document);
        highlighter.setTheme(QStringLiteral("none"));

        BracketMatcher matcher;
        matcher.setDocument(&document);

        QTextCursor cursor(&document);
        cursor.setPosition(0);
        matcher.updateForCursor(cursor);

        QCOMPARE(matcher.first(), 0);
        QCOMPARE(matcher.second(), 4);
    }

    // A cursor from another document must not mark anything: the positions
    // belong to the matcher's document only.
    void cursorFromAnotherDocumentClearsTheMark()
    {
        QTextDocument document;
        document.setPlainText(QStringLiteral("(a+b)"));
        Highlighter highlighter(&document);
        highlighter.setTheme(QStringLiteral("light"));

        BracketMatcher matcher;
        matcher.setDocument(&document);

        QTextCursor cursor(&document);
        cursor.setPosition(0);
        matcher.updateForCursor(cursor);
        QCOMPARE(matcher.first(), 0);
        QCOMPARE(matcher.second(), 4);

        QTextDocument otherDocument;
        otherDocument.setPlainText(QStringLiteral("(x)"));
        QTextCursor otherCursor(&otherDocument);
        otherCursor.setPosition(0);
        matcher.updateForCursor(otherCursor);

        QCOMPARE(matcher.first(), -1);
        QCOMPARE(matcher.second(), -1);
    }

    // The lexical scan: which parts of a line are comments and which are
    // strings.
    void scan_data()
    {
        QTest::addColumn<QString>("line");
        QTest::addColumn<int>("startState");
        QTest::addColumn<QString>("expectedComments");
        QTest::addColumn<QString>("expectedStrings");
        QTest::addColumn<QString>("expectedMultilineStrings");
        QTest::addColumn<int>("expectedEndState");

        QTest::newRow("plain") << "a = 1" << 0 << "" << "" << "" << 0;
        QTest::newRow("line comment") << "a = 1 ; note" << 0 << "6-12" << "" << "" << 0;
        QTest::newRow("slash comment") << "a = 1 // note" << 0 << "6-13" << "" << "" << 0;
        QTest::newRow("string before comment") << "a = \"x\" ; note" << 0 << "8-14" << "4-7" << "" << 0;
        QTest::newRow("semicolon inside string") << "a = \"x;y\"" << 0 << "" << "4-9" << "" << 0;
        QTest::newRow("string") << "a = \"x (y)\"" << 0 << "" << "4-11" << "" << 0;
        QTest::newRow("unterminated string") << "a = \"xy" << 0 << "" << "4-7" << "" << 0;
        QTest::newRow("multiline comment") << "/* a (b)" << 0 << "0-8" << "" << "" << 1;
        QTest::newRow("multiline comment closed") << "/* a */ b" << 0 << "0-7" << "" << "" << 0;
        QTest::newRow("stray comment end") << "x */ a = 1" << 0 << "" << "" << "" << 0;
        QTest::newRow("multiline string") << "{{ a (b)" << 0 << "" << "" << "0-8" << 2;
        QTest::newRow("multiline string closed") << "{{ a }} b" << 0 << "" << "" << "0-7" << 0;
        QTest::newRow("stray string end") << "x }} a = 1" << 0 << "" << "" << "" << 0;
        QTest::newRow("continuing a comment") << " (a) more" << 1 << "0-9" << "" << "" << 1;
        QTest::newRow("continuing a string") << " (a) more" << 2 << "" << "" << "0-9" << 2;
    }

    void scan()
    {
        QFETCH(QString, line);
        QFETCH(int, startState);
        QFETCH(QString, expectedComments);
        QFETCH(QString, expectedStrings);
        QFETCH(QString, expectedMultilineStrings);
        QFETCH(int, expectedEndState);

        const CsoundLex::Line info = CsoundLex::scan(line, startState);
        QCOMPARE(formatRanges(info.comments), expectedComments);
        QCOMPARE(formatRanges(info.strings), expectedStrings);
        QCOMPARE(formatRanges(info.multilineStrings), expectedMultilineStrings);
        QCOMPARE(info.endState, expectedEndState);
    }

    // The contents of a {{ ... }} string are not code: they keep the colour of
    // a string and are not highlighted as an instrument, an opcode or a
    // variable.
    void doesNotHighlightInsideMultilineStrings()
    {
        const QString text = QStringLiteral(
            "<CsInstruments>\n"
            "instr ShowOld\n"
            "mess:S = {{Before Csound 7 we had to start a variable name\n"
            "This is a typical example:\n"
            "\n"
            "instr Old\n"
            "\n"
            "  iFreq = p4\n"
            "endin}}\n"
            "  chnset(mess,\"display-output\")\n"
            "endin\n");

        QTextDocument document;
        document.setPlainText(text);
        Highlighter highlighter(&document);
        highlighter.setTheme(QStringLiteral("light"));

        const QColor stringColour = colourAt(document, text.indexOf("typical example"));
        QVERIFY2(stringColour.isValid(), "the string should be painted");

        // Inside the string: everything is a string.
        QCOMPARE(colourAt(document, text.indexOf("instr Old")), stringColour);
        QCOMPARE(colourAt(document, text.indexOf("iFreq")), stringColour);
        QCOMPARE(colourAt(document, text.indexOf("typical example")), stringColour);
        // The line that ends the string is a string as well.
        QCOMPARE(colourAt(document, text.indexOf("endin}}")), stringColour);

        // Outside the string the code is highlighted as usual.
        const QColor instColour = colourAt(document, text.indexOf("instr ShowOld"));
        QVERIFY2(instColour.isValid() && instColour != stringColour,
                 "the instrument outside the string should have its own colour");
    }

private:
    // Runs the matcher over a piece of text and returns the marked pair.
    static QPair<int, int> match(const QString &text, int cursorPosition)
    {
        QTextDocument document;
        document.setPlainText(text);

        Highlighter highlighter(&document);
        highlighter.setTheme(QStringLiteral("light"));

        BracketMatcher matcher;
        matcher.setDocument(&document);

        QTextCursor cursor(&document);
        cursor.setPosition(cursorPosition);
        matcher.updateForCursor(cursor);

        return { matcher.first(), matcher.second() };
    }
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    TestBracketMatcher test;
    return QTest::qExec(&test, argc, argv);
}

#include "test_bracketmatcher.moc"
