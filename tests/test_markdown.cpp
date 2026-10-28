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

#include "markdown.h"

using namespace Qt::StringLiterals;

class TestMarkdown : public QObject
{
    Q_OBJECT

private slots:
    void testParagraphsAndInline();
    void testHeadings();
    void testHeadingOffset();
    void testLists();
    void testFencedCode();
    void testHtmlIsEscaped();
};

void TestMarkdown::testParagraphsAndInline()
{
    const QString markdown =
        "A **nice** filter with *emphasis* and _underscore_.\n"
        "\n"
        "Args:\n"
        "  sig: `input` signal\n";

    QCOMPARE(Markdown::toHtml(markdown),
             u"<p>A <strong>nice</strong> filter with <em>emphasis</em> "
             "and <em>underscore</em>.</p>\n"
             "<p>Args:<br>\n"
             "&nbsp;&nbsp;sig: <code>input</code> signal</p>\n"_s);
}

void TestMarkdown::testHeadings()
{
    QCOMPARE(Markdown::toHtml(u"# Title\n## Sub *title*\n"_s),
             u"<h1>Title</h1>\n<h2>Sub <em>title</em></h2>\n"_s);
}

void TestMarkdown::testHeadingOffset()
{
    // Docstrings are embedded below a page title, so their headings start at
    // h2 and are clamped to h6.
    QCOMPARE(Markdown::toHtml(u"# One\n## Two\n###### Six\n"_s, 1),
             u"<h2>One</h2>\n<h3>Two</h3>\n<h6>Six</h6>\n"_s);
}

void TestMarkdown::testLists()
{
    QCOMPARE(Markdown::toHtml(u"* one\n* two\n"_s),
             u"<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n"_s);

    const QString nested = Markdown::toHtml(
        u"* one\n  * nested\n* two\n"_s);
    QVERIFY(nested.startsWith(u"<ul>\n<li>one<ul>\n<li>nested</li>\n</ul>\n</li>\n"_s));
    QVERIFY(nested.endsWith(u"<li>two</li>\n</ul>\n"_s));
}

void TestMarkdown::testFencedCode()
{
    QCOMPARE(Markdown::toHtml(u"```\nx = 1 < 2\n```\n"_s),
             u"<pre><code>x = 1 &lt; 2</code></pre>\n"_s);
}

void TestMarkdown::testHtmlIsEscaped()
{
    QCOMPARE(Markdown::toHtml(u"<b>not bold</b>\n"_s),
             u"<p>&lt;b&gt;not bold&lt;/b&gt;</p>\n"_s);
}

QTEST_APPLESS_MAIN(TestMarkdown)

#include "test_markdown.moc"
