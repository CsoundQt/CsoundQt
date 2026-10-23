/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
*/

#ifndef CHANNELTEXT_H
#define CHANNELTEXT_H

#include <QString>

// Result of looking for a literal channel argument on one source line.
struct ChannelTextResult
{
    QString channel;
    int start = -1; // position of the opening quote in the line
    int end = -1;   // position just after the closing quote
    // True when the line contains a channel opcode at all, even if the cursor
    // is not inside the channel argument. Used to skip unchanged lines that
    // cannot possibly produce a highlight.
    bool hasChannelReference = false;

    ChannelTextResult() = default;
    explicit ChannelTextResult(bool hasReference)
        : hasChannelReference(hasReference) {}
};

// Return the literal channel of the chnget/chnset/invalue/outvalue nearest to
// cursorPos. Variables and expressions are rejected; only one complete double
// quoted string counts. When requireInsideString is true, the result is empty
// unless cursorPos lies strictly inside that string.
ChannelTextResult findChannelLiteral(const QString &line, int cursorPos,
                                     bool requireInsideString = false);

#endif // CHANNELTEXT_H
