/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
*/

// Microbenchmark for the per-line channel lookup used by the editor's
// channel-hover highlighting. It measures the cold path: tokenizing and
// parsing a line. The widget-layout lookup and overlay work happen only when
// the resolved channel changes, so they are not part of this loop.

#include <QCoreApplication>
#include <QElapsedTimer>
#include <QString>
#include <cstdio>

#include "channeltext.h"

static volatile int resultSink = 0;

// Approximate the DocumentView cache-hit path: the first lookup fills the
// span; subsequent moves inside that span only compare the block revision and
// cursor position.
static void runCachedSpan(const char *name, const QString &line, int cursorPos,
                          int iterations)
{
    const ChannelTextResult result = findChannelLiteral(line, cursorPos);
    resultSink += result.channel.size();

    QElapsedTimer timer;
    timer.start();
    int sink = 0;
    for (int i = 0; i < iterations; ++i) {
        if (cursorPos > result.start && cursorPos < result.end)
            sink += result.channel.size();
    }
    const qint64 ns = timer.nsecsElapsed();
    resultSink += sink;

    const double perCall = double(ns) / double(iterations);
    std::printf("%-24s %8.3f us/lookup  (%d iterations)\n",
                name, perCall / 1000.0, iterations);
}

static void run(const char *name, const QString &line, int cursorPos,
                int iterations)
{
    // Warm up once so the static opcode set is initialized.
    resultSink += findChannelLiteral(line, cursorPos).channel.size();

    QElapsedTimer timer;
    timer.start();
    int sink = 0;
    for (int i = 0; i < iterations; ++i)
        sink += findChannelLiteral(line, cursorPos).channel.size();
    const qint64 ns = timer.nsecsElapsed();
    resultSink += sink;

    const double perCall = double(ns) / double(iterations);
    std::printf("%-24s %8.3f us/lookup  (%d iterations)\n",
                name, perCall / 1000.0, iterations);
}

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);

    const QString shortLine = QStringLiteral("k1 chnget \"foo\"");
    const QString longLine = QStringLiteral(
        "chnset linlin(dbamp(koutamp1), 0, 1, -irange, 0), \"vu1\"");

    // A deliberately long line with the channel at the end: this exercises
    // tokenization of a realistic, deeply nested Csound expression.
    QString veryLongLine = QStringLiteral("outvalue \"long-channel-name\", k1");
    for (int i = 0; i < 60; ++i)
        veryLongLine += QStringLiteral(" + linlin(k%1, 0, 1, 0, 0)").arg(i);

    if (findChannelLiteral(shortLine,
                           shortLine.indexOf(QStringLiteral("foo")) + 1).channel
            != QStringLiteral("foo")
            || findChannelLiteral(longLine,
                                  longLine.indexOf(QStringLiteral("vu1")) + 1).channel
            != QStringLiteral("vu1")
            || findChannelLiteral(veryLongLine,
                                  veryLongLine.indexOf(QStringLiteral("long-channel-name")) + 1).channel
            != QStringLiteral("long-channel-name")) {
        std::fprintf(stderr, "benchmark input did not resolve as expected\n");
        return 2;
    }

    run("short line", shortLine,
        shortLine.indexOf(QStringLiteral("foo")) + 1, 1000000);
    run("nested chnset line", longLine,
        longLine.indexOf(QStringLiteral("vu1")) + 1, 500000);
    run("very long line", veryLongLine,
        veryLongLine.indexOf(QStringLiteral("long-channel-name")) + 1, 100000);

    const int longPos = veryLongLine.indexOf(QStringLiteral("long-channel-name")) + 1;
    runCachedSpan("cached span (same pos)", veryLongLine, longPos, 10000000);

    std::printf("sink=%d\n", resultSink);
    return 0;
}
