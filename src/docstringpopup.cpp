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

#include "docstringpopup.h"

#include <QGuiApplication>
#include <QHBoxLayout>
#include <QKeyEvent>
#include <QLabel>
#include <QFrame>
#include <QScreen>
#include <QTextBrowser>
#include <QTextCursor>
#include <QTextDocument>
#include <QToolButton>
#include <QVBoxLayout>

#include <cmath>

using namespace Qt::StringLiterals;

DocstringPopup::DocstringPopup(QWidget *parent)
    : QWidget(parent, Qt::Tool | Qt::FramelessWindowHint | Qt::WindowDoesNotAcceptFocus)
{
    // 1. Prevent the window from being activated when shown
    setAttribute(Qt::WA_ShowWithoutActivating);

    // 2. Ensure the widget itself cannot receive keyboard focus
    setFocusPolicy(Qt::NoFocus);
    
    setObjectName(u"docstringPopup"_s);
    // A plain QWidget subclass paints neither the stylesheet background nor its
    // border by itself; it would only get the background through the palette
    // fill, which silently drops the border. Ask the style to draw the frame.
    setAttribute(Qt::WA_StyledBackground);

    auto *layout = new QVBoxLayout(this);
    layout->setContentsMargins(12, 10, 12, 12);
    layout->setSpacing(8);

    auto *titleRow = new QHBoxLayout;
    titleRow->setSpacing(6);

    m_title = new QLabel(this);
    QFont titleFont = m_title->font();
    titleFont.setBold(true);
    titleFont.setPointSizeF(titleFont.pointSizeF() + 1.0);
    m_title->setFont(titleFont);
    // m_title->setTextInteractionFlags(Qt::TextSelectableByMouse);

    auto *closeButton = new QToolButton(this);
    closeButton->setText(u"\u00d7"_s);
    closeButton->setAutoRaise(true);
    closeButton->setFocusPolicy(Qt::NoFocus);
    closeButton->setToolTip(tr("Close"));
    connect(closeButton, &QToolButton::clicked, this, &QWidget::hide);

    titleRow->addWidget(m_title, 1);
    titleRow->addWidget(closeButton);
    layout->addLayout(titleRow);

    m_text = new QTextBrowser(this);
    m_text->setOpenExternalLinks(false);
    m_text->setFrameShape(QFrame::NoFrame);
    m_text->setHorizontalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    m_text->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    layout->addWidget(m_text, 1);

    applyColors();
}

void DocstringPopup::setThemeColors(const QColor &foreground,
                                    const QColor &background)
{
    if (foreground == m_foreground && background == m_background)
        return;
    m_foreground = foreground;
    m_background = background;
    applyColors();
}

void DocstringPopup::applyColors()
{
    // Follow the editor's syntax theme, so the card sits in the same visual
    // world as the text it explains. Without a theme the palette is used.
    const QColor foreground = m_foreground.isValid()
            ? m_foreground : palette().color(QPalette::Text);
    const QColor background = m_background.isValid()
            ? m_background : palette().color(QPalette::Base);
    // A border between the two colours: darker than a light background, lighter
    // than a dark one, which is what palette(mid) does for the widget chrome.
    const auto blend = [](const QColor &base, const QColor &over, qreal amount) {
        QColor result;
        result.setRgbF(base.redF() * (1 - amount) + over.redF() * amount,
                       base.greenF() * (1 - amount) + over.greenF() * amount,
                       base.blueF() * (1 - amount) + over.blueF() * amount);
        return result;
    };
    const QColor border = blend(background, foreground, 0.3);
    const QColor hover = blend(background, foreground, 0.15);
    const auto isdark = background.lightness() < foreground.lightness();
    const QColor popupbg = blend(background, foreground, isdark ? 0.1 : 0.05);

    setStyleSheet(u"DocstringPopup {"
                  "  background-color: %1;"
                  "  border: 1px solid %2;"
                  "}"
                  "QLabel {"
                  "  background: transparent;"
                  "  color: %3;"
                  "}"
                  "QToolButton {"
                  "  background: transparent;"
                  "  color: %3;"
                  "  border: none;"
                  "  padding: 0 4px;"
                  "}"
                  "QToolButton:hover {"
                  "  background-color: %4;"
                  "  border-radius: 3px;"
                  "}"
                  "QTextBrowser {"
                  "  background: transparent;"
                  "  color: %3;"
                  "  border: none;"
                  "}"_s
                  .arg(popupbg.name(), border.name(),
                       foreground.name(), hover.name()));
}

void DocstringPopup::showHtml(const QString &title, const QString &html,
                              const QPoint &globalAnchor, bool passive)
{
    // A passive card must not take the focus from the editor, and must not
    // grab the mouse: the pointer has to keep tracking the name it explains.
    // The popup window type gives the explicit lookup its menu-like dismissal.
    const Qt::WindowFlags flags = (passive ? Qt::ToolTip : Qt::Popup)
            | Qt::FramelessWindowHint;
    if (windowFlags() != flags)
        setWindowFlags(flags);

    m_title->setText(title);
    m_text->setHtml(html);
    m_text->moveCursor(QTextCursor::Start);

    const QScreen *screen = QGuiApplication::screenAt(globalAnchor);
    if (screen == nullptr)
        screen = QGuiApplication::primaryScreen();
    const QRect available = screen != nullptr
            ? screen->availableGeometry()
            : QRect(0, 0, 1024, 768);

    const int margin = 16;
    const int width = qMax(280, qMin(560, available.width() - 2 * margin));
    const int textWidth = width - 24; // layout margins
    m_text->document()->setTextWidth(textWidth);

    const int chrome = m_title->sizeHint().height() + 46;
    const int documentHeight = static_cast<int>(
                std::ceil(m_text->document()->size().height()));
    const int maxHeight = qMax(180, qMin(640, available.height() - 2 * margin));
    const int height = qBound(140, documentHeight + chrome, maxHeight);

    resize(width, height);

    QPoint pos(globalAnchor.x() - 20, globalAnchor.y() + 10);
    pos.setX(qBound(available.left() + margin, pos.x(),
                    available.right() - width - margin + 1));
    pos.setY(qBound(available.top() + margin, pos.y(),
                    available.bottom() - height - margin + 1));
    move(pos);

    show();
    raise();
    if (!passive)
        m_text->setFocus();
}

void DocstringPopup::keyPressEvent(QKeyEvent *event)
{
    if (event->key() == Qt::Key_Escape) {
        hide();
        event->accept();
        return;
    }
    QWidget::keyPressEvent(event);
}
