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

#ifndef DOCSTRINGPOPUP_H
#define DOCSTRINGPOPUP_H

#include <QColor>
#include <QWidget>

class QLabel;
class QTextBrowser;

// A small floating card that shows an ad-hoc help page: the docstring of a
// user-defined opcode or instrument, or a quick reference for an opcode. It can
// be a pop-up (clicking outside it or pressing Escape dismisses it), or, for
// the ctrl+hover lookup, a passive tooltip that leaves the focus in the editor.
// The text is scrollable, so long argument lists remain readable.
class DocstringPopup : public QWidget
{
    Q_OBJECT

public:
    explicit DocstringPopup(QWidget *parent = nullptr);

    // The editor's syntax theme decides the card's colours, so it reads as part
    // of the text it explains rather than as a stray panel. Invalid colours keep
    // the widget palette.
    void setThemeColors(const QColor &foreground, const QColor &background);

    // Shows the card near globalAnchor. title is plain text, html is the
    // already-rendered docstring. A passive card (the ctrl+hover lookup) is a
    // tooltip-like window: it never takes the keyboard focus or grabs the
    // mouse, so the user keeps working in the editor and Escape still reaches
    // it. The default card is a popup that Escape or a click outside dismisses.
    void showHtml(const QString &title, const QString &html,
                  const QPoint &globalAnchor, bool passive = true);

protected:
    void keyPressEvent(QKeyEvent *event) override;

private:
    // The stylesheet, rebuilt when the theme colours change.
    void applyColors();

    QLabel *m_title = nullptr;
    QTextBrowser *m_text = nullptr;
    QColor m_foreground;
    QColor m_background;
};

#endif // DOCSTRINGPOPUP_H
