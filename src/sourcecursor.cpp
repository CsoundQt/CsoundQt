/*
	Copyright (C) 2026 CsoundQt contributors
	This file is part of CsoundQt.
	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.
*/

#include "sourcecursor.h"

#include <QTextBlock>

namespace {

// A Csound name: a letter or an underscore followed by letters, digits or
// underscores.
bool isNameChar(QChar c)
{
    return c.isLetterOrNumber() || c == QLatin1Char('_');
}

bool isNameStart(QChar c)
{
    return c.isLetter() || c == QLatin1Char('_');
}

// The word that ends just before the given position, skipping the spaces in
// between. When wordStart is given, it receives the position of its first
// character.
QString wordEndingBefore(const QString &line, int position, int *wordStart = nullptr)
{
    int i = position;
    while (i >= 0 && line.at(i).isSpace())
        --i;
    const int end = i + 1;
    while (i >= 0 && isNameChar(line.at(i)))
        --i;
    if (wordStart)
        *wordStart = i + 1;
    return line.mid(i + 1, end - (i + 1));
}

// The bounds of the identifier at the given position in the line.
bool identifierBounds(const QString &line, int position, int *start, int *end)
{
    int first = position;
    int last = position;
    while (first > 0 && isNameChar(line.at(first - 1)))
        --first;
    while (last < line.size() && isNameChar(line.at(last)))
        ++last;
    if (last <= first)
        return false;
    // A name does not start with a digit: "schedule 1.5" names no instrument.
    if (!isNameStart(line.at(first)))
        return false;
    if (start)
        *start = first;
    if (end)
        *end = last;
    return true;
}

bool isScheduleOpcode(const QString &name)
{
    return name == QLatin1String("schedule") || name == QLatin1String("schedulek");
}

} // namespace

QString SourceCursor::identifierAt(const QTextCursor &cursor)
{
    if (cursor.isNull())
        return QString();
    const QString line = cursor.block().text();
    int start = 0;
    int end = 0;
    if (!identifierBounds(line, cursor.positionInBlock(), &start, &end))
        return QString();
    return line.mid(start, end - start);
}

QString SourceCursor::includePathAt(const QTextCursor &cursor)
{
    if (cursor.isNull())
        return QString();
    const QString line = cursor.block().text();

    // The directive has to start the line, after optional whitespace.
    int pos = 0;
    while (pos < line.size() && line.at(pos).isSpace())
        ++pos;
    if (pos >= line.size() || line.at(pos) != QLatin1Char('#'))
        return QString();
    ++pos;
    while (pos < line.size() && line.at(pos).isSpace())
        ++pos;
    if (line.mid(pos, 7) != QLatin1String("include"))
        return QString();
    pos += 7;
    // "#includes" or "#include_x" is not the directive.
    if (pos < line.size() && isNameChar(line.at(pos)))
        return QString();
    while (pos < line.size() && line.at(pos).isSpace())
        ++pos;
    if (pos >= line.size())
        return QString();

    QChar close;
    if (line.at(pos) == QLatin1Char('"'))
        close = QLatin1Char('"');
    else if (line.at(pos) == QLatin1Char('<'))
        close = QLatin1Char('>');
    else
        return QString();

    const int start = pos + 1;
    const int end = line.indexOf(close, start);
    if (end < 0)
        return QString();
    // Anywhere inside the delimiters, from just after the opening one to just
    // before the closing one.
    const int position = cursor.positionInBlock();
    if (position < start || position > end)
        return QString();
    return line.mid(start, end - start);
}

bool SourceCursor::isScheduleArgument(const QTextCursor &cursor)
{
    if (cursor.isNull())
        return false;
    const QString line = cursor.block().text();
    int start = 0;
    int end = 0;
    if (!identifierBounds(line, cursor.positionInBlock(), &start, &end))
        return false;

    // Look at what comes before the name: either the name of the opcode
    // (legacy "schedule MyInstr" syntax) or an opening parenthesis
    // ("schedule(MyInstr, ...)").
    int i = start - 1;
    while (i >= 0 && line.at(i).isSpace())
        --i;
    // A quoted name: schedule "MyInstr"
    if (i >= 0 && line.at(i) == QLatin1Char('"'))
        --i;
    while (i >= 0 && line.at(i).isSpace())
        --i;
    if (i < 0)
        return false;

    int argsStart = 0;
    if (line.at(i) == QLatin1Char('(')) {
        // The name of the opcode is the word before the parenthesis.
        if (!isScheduleOpcode(wordEndingBefore(line, i - 1)))
            return false;
        argsStart = i + 1;
    }
    else {
        // The legacy syntax: schedule MyInstr, ...
        int wordStart = 0;
        const QString opcode = wordEndingBefore(line, i, &wordStart);
        if (!isScheduleOpcode(opcode))
            return false;
        argsStart = wordStart + opcode.length();
    }

    // The name has to be the first argument: no comma may separate it from
    // the start of the argument list.
    int depth = 0;
    bool inString = false;
    for (int k = argsStart; k < start; ++k) {
        const QChar c = line.at(k);
        if (inString) {
            if (c == QLatin1Char('"'))
                inString = false;
            continue;
        }
        switch (c.unicode()) {
        case '"':
            inString = true;
            break;
        case '(':
        case '[':
        case '{':
            ++depth;
            break;
        case ')':
        case ']':
        case '}':
            --depth;
            break;
        case ',':
            if (depth == 0)
                return false; // not the first argument
            break;
        default:
            break;
        }
    }
    return true;
}
