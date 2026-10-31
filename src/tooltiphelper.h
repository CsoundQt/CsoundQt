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

#ifndef TOOLTIPHELPER_H
#define TOOLTIPHELPER_H

#include <QFont>
#include <QFontMetrics>
#include <QList>
#include <QString>
#include <QStringList>
#include <QTextDocument> // Qt::mightBeRichText
#include <QToolTip>
#include <QWidget>

// Tooltips set with QWidget::setToolTip() are shown by a plain QLabel. Qt only
// wraps them when they would be wider than the whole screen, which leaves most
// long help texts as one very wide line. These helpers wrap them at a
// comfortable reading width instead.
namespace ToolTipHelper {

inline constexpr int MaxLineWidth = 480;

inline void appendWrappedLine(QStringList &lines, const QString &paragraph,
                              const QFontMetrics &metrics)
{
    if (paragraph.isEmpty()) {
        lines.append(QString()); // keep blank lines
        return;
    }

    QString line;
    const auto flushLine = [&lines, &line]() {
        if (!line.isEmpty()) {
            lines.append(line);
            line.clear();
        }
    };

    for (QString word : paragraph.split(QLatin1Char(' '), Qt::SkipEmptyParts)) {
        // A single long token (e.g. a file path) has to be broken as well.
        while (metrics.horizontalAdvance(word) > MaxLineWidth) {
            int cut = word.size();
            while (cut > 1
                   && metrics.horizontalAdvance(word.left(cut)) > MaxLineWidth) {
                --cut;
            }
            flushLine();
            lines.append(word.left(cut));
            word.remove(0, cut);
        }
        if (word.isEmpty())
            continue;
        const QString candidate = line.isEmpty()
                ? word : line + QLatin1Char(' ') + word;
        if (!line.isEmpty()
                && metrics.horizontalAdvance(candidate) > MaxLineWidth) {
            flushLine();
            line = word;
        } else {
            line = candidate;
        }
    }
    flushLine();
}

inline QStringList wrappedLines(const QString &text, const QFont &font)
{
    const QFontMetrics metrics(font);
    QStringList lines;
    for (const QString &paragraph : text.split(QLatin1Char('\n')))
        appendWrappedLine(lines, paragraph, metrics);
    return lines;
}

inline bool isTooWide(const QString &text, const QFont &font)
{
    const QFontMetrics metrics(font);
    for (const QString &paragraph : text.split(QLatin1Char('\n'))) {
        if (metrics.horizontalAdvance(paragraph) > MaxLineWidth)
            return true;
    }
    return false;
}

// Rewrites the plain-text tooltips of root and its children so that each line
// fits the maximum width. Rich text already controls its own layout.
inline void wrapToolTips(QWidget *root)
{
    if (root == nullptr)
        return;
    QList<QWidget *> widgets = root->findChildren<QWidget *>();
    widgets.append(root);
    for (QWidget *widget : widgets) {
        const QString text = widget->toolTip();
        if (text.isEmpty() || Qt::mightBeRichText(text)
                || !isTooWide(text, QToolTip::font())) {
            continue;
        }
        widget->setToolTip(wrappedLines(text, QToolTip::font())
                                   .join(QLatin1Char('\n')));
    }
}

} // namespace ToolTipHelper

#endif // TOOLTIPHELPER_H
