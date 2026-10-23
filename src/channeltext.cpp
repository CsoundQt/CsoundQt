/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
*/

#include "channeltext.h"

#include <QSet>
#include <climits>

// A small tokenizer for one line of Csound code. It only needs to distinguish
// the pieces that matter for finding a literal channel argument: identifiers,
// string constants, commas and parentheses. Comments end the line.
struct CsoundLineToken
{
    enum Kind { Identifier, String, Comma, LeftParen, RightParen, Other };
    Kind kind = Other;
    QString text;
    int start = 0;
    int end = 0;
    bool closed = false; // true for a properly terminated string
};

static QList<CsoundLineToken> tokenizeCsoundLine(const QString &line,
                                                  int *commentStart = nullptr)
{
    QList<CsoundLineToken> tokens;
    if (commentStart)
        *commentStart = -1;
    int i = 0;
    while (i < line.size()) {
        const QChar c = line.at(i);
        if (c.isSpace()) {
            ++i;
            continue;
        }
        if (c == QLatin1Char(';')
                || (c == QLatin1Char('/') && i + 1 < line.size()
                    && line.at(i + 1) == QLatin1Char('/'))) {
            if (commentStart)
                *commentStart = i;
            break;
        }
        if (c == QLatin1Char('"')) {
            const int start = i++;
            QString text;
            bool escaped = false;
            bool closed = false;
            while (i < line.size()) {
                const QChar ch = line.at(i);
                if (escaped) {
                    text += ch;
                    escaped = false;
                    ++i;
                    continue;
                }
                if (ch == QLatin1Char('\\')) {
                    escaped = true;
                    ++i;
                    continue;
                }
                if (ch == QLatin1Char('"')) {
                    closed = true;
                    ++i;
                    break;
                }
                text += ch;
                ++i;
            }
            tokens.append({CsoundLineToken::String, text, start, i, closed});
            continue;
        }
        if (c.isLetter() || c == QLatin1Char('_')) {
            const int start = i;
            while (i < line.size()
                   && (line.at(i).isLetterOrNumber()
                       || line.at(i) == QLatin1Char('_')))
                ++i;
            tokens.append({CsoundLineToken::Identifier,
                           line.mid(start, i - start), start, i, false});
            continue;
        }
        CsoundLineToken::Kind kind = CsoundLineToken::Other;
        if (c == QLatin1Char(','))
            kind = CsoundLineToken::Comma;
        else if (c == QLatin1Char('('))
            kind = CsoundLineToken::LeftParen;
        else if (c == QLatin1Char(')'))
            kind = CsoundLineToken::RightParen;
        tokens.append({kind, QString(c), i, i + 1, false});
        ++i;
    }
    return tokens;
}

ChannelTextResult findChannelLiteral(const QString &line, int cursorPos,
                                     bool requireInsideString)
{
    int commentStart = -1;
    const QList<CsoundLineToken> tokens = tokenizeCsoundLine(line, &commentStart);

    static const QSet<QString> channelOpcodes = {
        QStringLiteral("chnget"), QStringLiteral("chnset"),
        QStringLiteral("invalue"), QStringLiteral("outvalue")
    };

    int opcodeIndex = -1;
    int bestDistance = INT_MAX;
    bool hasChannelReference = false;
    for (int i = 0; i < tokens.size(); ++i) {
        const CsoundLineToken &token = tokens.at(i);
        if (token.kind != CsoundLineToken::Identifier
                || !channelOpcodes.contains(token.text))
            continue;
        hasChannelReference = true;
        int distance = 0;
        if (cursorPos < token.start)
            distance = token.start - cursorPos;
        else if (cursorPos > token.end)
            distance = cursorPos - token.end;
        if (distance < bestDistance) {
            bestDistance = distance;
            opcodeIndex = i;
        }
    }
    if (commentStart >= 0 && cursorPos >= commentStart)
        return ChannelTextResult(hasChannelReference);
    if (opcodeIndex < 0)
        return ChannelTextResult();

    const QString &opcode = tokens.at(opcodeIndex).text;
    const int channelIndex = (opcode == QLatin1String("chnset")) ? 1 : 0;
    int i = opcodeIndex + 1;
    // Optional Csound 7 type annotation, e.g. chnget:k "channel".
    if (i + 1 < tokens.size()
            && tokens.at(i).kind == CsoundLineToken::Other
            && tokens.at(i).text == QLatin1String(":")
            && tokens.at(i + 1).kind == CsoundLineToken::Identifier) {
        i += 2;
    }

    QList<QList<CsoundLineToken>> arguments;
    QList<CsoundLineToken> current;
    const bool functional = (i < tokens.size()
                             && tokens.at(i).kind == CsoundLineToken::LeftParen);
    int depth = 1;
    if (functional)
        ++i;
    // Legacy syntax can have nested calls in the value argument, e.g.
    // chnset linlin(dbamp(kout), 0, 1, -range, 0), "vu1". Split only on
    // commas outside those nested parentheses.
    int legacyDepth = 0;
    for (; i < tokens.size(); ++i) {
        const CsoundLineToken &token = tokens.at(i);
        if (functional) {
            if (token.kind == CsoundLineToken::LeftParen) {
                ++depth;
                current.append(token);
            } else if (token.kind == CsoundLineToken::RightParen) {
                --depth;
                if (depth == 0) {
                    if (!current.isEmpty())
                        arguments.append(current);
                    break;
                }
                current.append(token);
            } else if (depth == 1 && token.kind == CsoundLineToken::Comma) {
                arguments.append(current);
                current.clear();
            } else {
                current.append(token);
            }
            continue;
        }

        if (token.kind == CsoundLineToken::LeftParen) {
            ++legacyDepth;
            current.append(token);
        } else if (token.kind == CsoundLineToken::RightParen) {
            if (legacyDepth > 0)
                --legacyDepth;
            current.append(token);
        } else if (legacyDepth == 0
                   && token.kind == CsoundLineToken::Comma) {
            arguments.append(current);
            current.clear();
        } else if (legacyDepth == 0
                   && token.kind == CsoundLineToken::Identifier
                   && channelOpcodes.contains(token.text)) {
            // Stop at a second opcode on the same line, so two calls such as
            // `chnget "a" + chnget "b"` do not merge their argument lists.
            break;
        } else if (legacyDepth == 0 && token.kind == CsoundLineToken::Other
                   && !current.isEmpty()
                   && current.constLast().kind == CsoundLineToken::String
                   && arguments.size() == channelIndex) {
            // A channel argument is a single literal. Stop before trailing
            // expression tokens when the caller wrote e.g. chnget "a" + x.
            break;
        } else {
            current.append(token);
        }
    }
    if (!current.isEmpty())
        arguments.append(current);

    if (channelIndex >= arguments.size())
        return ChannelTextResult(true);
    const QList<CsoundLineToken> &channelArg = arguments.at(channelIndex);
    if (channelArg.size() != 1)
        return ChannelTextResult(true);
    const CsoundLineToken &channel = channelArg.first();
    if (channel.kind != CsoundLineToken::String || !channel.closed)
        return ChannelTextResult(true);
    if (requireInsideString
            && (cursorPos <= channel.start || cursorPos >= channel.end))
        return ChannelTextResult(true);
    ChannelTextResult result(true);
    result.channel = channel.text;
    result.start = channel.start;
    result.end = channel.end;
    return result;
}
