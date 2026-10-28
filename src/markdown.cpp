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

#include "markdown.h"

#include <QStringList>
#include <QVector>

using namespace Qt::StringLiterals;

namespace Markdown {

namespace {

// Inline formatting. The input is escaped while it is copied to the output, so
// the result is safe to use as HTML. Code spans are not formatted further;
// emphasis may contain other inline formatting.
QString inlineHtml(const QString &text)
{
    QString out;
    qsizetype i = 0;
    qsizetype plainStart = 0;

    const auto flushPlain = [&](qsizetype end) {
        if (end > plainStart)
            out += text.mid(plainStart, end - plainStart).toHtmlEscaped();
    };

    while (i < text.size()) {
        const QChar c = text.at(i);

        if (c == QLatin1Char('`')) {
            const qsizetype close = text.indexOf(QLatin1Char('`'), i + 1);
            if (close > i + 1) {
                flushPlain(i);
                out += u"<code>"_s
                        + text.mid(i + 1, close - i - 1).toHtmlEscaped()
                        + u"</code>"_s;
                i = close + 1;
                plainStart = i;
                continue;
            }
        }
        else if (c == QLatin1Char('*')) {
            if (text.mid(i, 2) == u"**"_s) {
                const qsizetype close = text.indexOf(u"**"_s, i + 2);
                if (close > i + 2) {
                    flushPlain(i);
                    out += u"<strong>"_s
                            + inlineHtml(text.mid(i + 2, close - i - 2))
                            + u"</strong>"_s;
                    i = close + 2;
                    plainStart = i;
                    continue;
                }
            }
            else {
                const qsizetype close = text.indexOf(QLatin1Char('*'), i + 1);
                if (close > i + 1) {
                    flushPlain(i);
                    out += u"<em>"_s
                            + inlineHtml(text.mid(i + 1, close - i - 1))
                            + u"</em>"_s;
                    i = close + 1;
                    plainStart = i;
                    continue;
                }
            }
        }
        else if (c == QLatin1Char('_')) {
            const bool leftBoundary = i == 0 || !text.at(i - 1).isLetterOrNumber();
            const qsizetype close = text.indexOf(QLatin1Char('_'), i + 1);
            if (leftBoundary && close > i + 1) {
                const bool rightBoundary = close + 1 >= text.size()
                        || !text.at(close + 1).isLetterOrNumber();
                if (rightBoundary) {
                    flushPlain(i);
                    out += u"<em>"_s
                            + inlineHtml(text.mid(i + 1, close - i - 1))
                            + u"</em>"_s;
                    i = close + 1;
                    plainStart = i;
                    continue;
                }
            }
        }

        ++i;
    }

    flushPlain(text.size());
    return out;
}

bool isFence(const QString &trimmed)
{
    return trimmed.startsWith(u"```"_s);
}

// The heading level of a trimmed line, or 0 when the line is not a heading.
int headingLevel(const QString &trimmed)
{
    int level = 0;
    while (level < 6 && level < trimmed.size()
           && trimmed.at(level) == QLatin1Char('#'))
        ++level;
    if (level == 0 || level >= trimmed.size() || !trimmed.at(level).isSpace())
        return 0;
    return level;
}

bool isListMarker(const QString &trimmed, QString *text = nullptr)
{
    if (trimmed.size() < 2)
        return false;
    const QChar marker = trimmed.at(0);
    if (marker != QLatin1Char('*') && marker != QLatin1Char('-')
            && marker != QLatin1Char('+'))
        return false;
    if (!trimmed.at(1).isSpace())
        return false;
    if (text != nullptr)
        *text = trimmed.mid(2).trimmed();
    return true;
}

int indentationWidth(const QString &line)
{
    int width = 0;
    for (const QChar c : line) {
        if (c == QLatin1Char(' '))
            ++width;
        else if (c == QLatin1Char('\t'))
            width += 4;
        else
            break;
    }
    return width;
}

// One paragraph line: leading whitespace is made visible with non-breaking
// spaces, because HTML would otherwise collapse the indentation.
QString paragraphLine(const QString &line)
{
    qsizetype indent = 0;
    QString prefix;
    while (indent < line.size()) {
        const QChar c = line.at(indent);
        if (c == QLatin1Char(' '))
            prefix += u"&nbsp;"_s;
        else if (c == QLatin1Char('\t'))
            prefix += u"&nbsp;&nbsp;&nbsp;&nbsp;"_s;
        else
            break;
        ++indent;
    }
    return prefix + inlineHtml(line.mid(indent));
}

QString renderParagraph(const QStringList &lines)
{
    QStringList rendered;
    rendered.reserve(lines.size());
    for (const QString &line : lines)
        rendered.append(paragraphLine(line));
    return u"<p>"_s + rendered.join(u"<br>\n"_s) + u"</p>\n"_s;
}

// Renders the list that starts at line i and returns the first line after it.
int renderList(const QStringList &lines, int i, QString &html)
{
    QVector<int> levels;

    while (i < lines.size()) {
        const QString &line = lines.at(i);
        const QString trimmed = line.trimmed();
        if (trimmed.isEmpty())
            break;

        QString item;
        if (isListMarker(trimmed, &item)) {
            const int indent = indentationWidth(line);
            if (levels.isEmpty()) {
                html += u"<ul>\n"_s;
                levels.append(indent);
            }
            else if (indent > levels.last()) {
                html += u"<ul>\n"_s;
                levels.append(indent);
            }
            else {
                while (levels.size() > 1 && indent < levels.last()) {
                    html += u"</li>\n</ul>\n"_s;
                    levels.removeLast();
                }
                if (indent > levels.last()) {
                    html += u"<ul>\n"_s;
                    levels.append(indent);
                }
                else {
                    html += u"</li>\n"_s;
                }
            }
            html += u"<li>"_s + inlineHtml(item);
        }
        else {
            // A continuation of the current item: it has to be indented past
            // the item's marker. Anything else ends the list.
            if (levels.isEmpty() || indentationWidth(line) <= levels.last())
                break;
            html += u"<br>"_s + paragraphLine(line);
        }
        ++i;
    }

    while (!levels.isEmpty()) {
        html += u"</li>\n</ul>\n"_s;
        levels.removeLast();
    }
    return i;
}

} // namespace

QString toHtml(const QString &markdown, int headingOffset)
{
    QStringList lines = markdown.split(QLatin1Char('\n'));
    // Tolerate CRLF input; the scanner normally already works on LF.
    for (QString &line : lines) {
        if (line.endsWith(QLatin1Char('\r')))
            line.chop(1);
    }

    QString html;
    int i = 0;
    while (i < lines.size()) {
        const QString &line = lines.at(i);
        const QString trimmed = line.trimmed();

        if (trimmed.isEmpty()) {
            ++i;
            continue;
        }

        if (isFence(trimmed)) {
            ++i;
            QString code;
            bool first = true;
            while (i < lines.size() && !isFence(lines.at(i).trimmed())) {
                if (!first)
                    code += QLatin1Char('\n');
                code += lines.at(i);
                first = false;
                ++i;
            }
            if (i < lines.size())
                ++i; // the closing fence
            html += u"<pre><code>"_s + code.toHtmlEscaped()
                    + u"</code></pre>\n"_s;
            continue;
        }

        if (const int level = headingLevel(trimmed); level > 0) {
            const int outputLevel = qBound(1, level + headingOffset, 6);
            html += u"<h%1>%2</h%1>\n"_s
                    .arg(outputLevel)
                    .arg(inlineHtml(trimmed.mid(level).trimmed()));
            ++i;
            continue;
        }

        if (isListMarker(trimmed)) {
            i = renderList(lines, i, html);
            continue;
        }

        QStringList paragraph;
        while (i < lines.size()) {
            const QString &candidate = lines.at(i);
            const QString candidateTrimmed = candidate.trimmed();
            if (candidateTrimmed.isEmpty()
                    || isFence(candidateTrimmed)
                    || headingLevel(candidateTrimmed) > 0
                    || isListMarker(candidateTrimmed))
                break;
            paragraph.append(candidate);
            ++i;
        }
        html += renderParagraph(paragraph);
    }

    return html;
}

} // namespace Markdown
