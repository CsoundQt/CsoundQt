/*
    Copyright (C) 2025 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with CsoundQt; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#ifndef WIDGETSTYLE_H
#define WIDGETSTYLE_H

#include <QApplication>
#include <QColor>
#include <QDebug>
#include <QFontMetrics>
#include <QProxyStyle>
#include <QScrollArea>
#include <QScrollBar>
#include <QStringList>
#include <QStyle>
#include <QStyleFactory>
#include <QStyleOptionDockWidget>
using namespace Qt::StringLiterals;

// How much smaller dock-panel titles are drawn than the widget's normal font.
constexpr qreal DOCK_TITLE_FONT_DELTA = 0.9;

// Some desktop styles (e.g. Breeze) put themed icons on dialog buttons
// (Yes/No/Cancel/...). Those icons follow the desktop icon theme rather than
// the application palette, so they can end up dark-on-dark when CsoundQt uses
// a dark palette. Use text-only dialog buttons everywhere instead, matching the
// Fusion style behaviour. The proxy wraps whatever style is active, so it must
// be re-applied whenever the widget style changes.
class DialogButtonStyle : public QProxyStyle
{
public:
    using QProxyStyle::QProxyStyle;

    inline static int s_toolTipWakeUpDelay = 500;

    static void setToolTipWakeUpDelay(int milliseconds)
    {
        s_toolTipWakeUpDelay = qMax(0, milliseconds);
    }

    int styleHint(StyleHint hint, const QStyleOption *option = nullptr,
                  const QWidget *widget = nullptr,
                  QStyleHintReturn *returnData = nullptr) const override
    {
        if (hint == SH_ToolTip_WakeUpDelay)
            return s_toolTipWakeUpDelay;
        return QProxyStyle::styleHint(hint, option, widget, returnData);
    }

    void drawControl(ControlElement element, const QStyleOption *option,
                     QPainter *painter, const QWidget *widget = nullptr) const override
    {
        // Dock panel title bars are a little too prominent at the normal UI
        // font size; draw just the title with a slightly smaller font.
        if (element == CE_DockWidgetTitle && option != nullptr) {
            QStyleOptionDockWidget dockOption(
                        *static_cast<const QStyleOptionDockWidget *>(option));
            QFont font = widget != nullptr ? widget->font() : QApplication::font();
            if (font.pointSizeF() > 0.0) {
                font.setPointSizeF(qMax(1.0, font.pointSizeF() - DOCK_TITLE_FONT_DELTA));
            } else if (font.pixelSize() > 0) {
                font.setPixelSize(qMax(1, font.pixelSize() - qRound(DOCK_TITLE_FONT_DELTA)));
            }
            dockOption.fontMetrics = QFontMetrics(font);
            QProxyStyle::drawControl(element, &dockOption, painter, widget);
            return;
        }
        QProxyStyle::drawControl(element, option, painter, widget);
    }

    QIcon standardIcon(StandardPixmap standardIcon,
                       const QStyleOption *option = nullptr,
                       const QWidget *widget = nullptr) const override
    {
        switch (standardIcon) {
        case SP_DialogOkButton:
        case SP_DialogCancelButton:
        case SP_DialogCloseButton:
        case SP_DialogApplyButton:
        case SP_DialogResetButton:
        case SP_DialogHelpButton:
        case SP_DialogSaveButton:
        case SP_DialogSaveAllButton:
        case SP_DialogOpenButton:
        case SP_DialogYesButton:
        case SP_DialogYesToAllButton:
        case SP_DialogNoButton:
        case SP_DialogNoToAllButton:
        case SP_DialogAbortButton:
        case SP_DialogRetryButton:
        case SP_DialogIgnoreButton:
        case SP_DialogDiscardButton:
            return QIcon();
        default:
            return QProxyStyle::standardIcon(standardIcon, option, widget);
        }
    }
};

// The widget style CsoundQt uses when none has been chosen explicitly.
// On Linux that is Fusion, so the application looks the same on every
// distribution. On macOS and Windows it is empty, meaning Qt's own platform
// default (the native macOS style, windows11/windowsvista on Windows).
inline QString defaultWidgetStyleName()
{
#ifdef Q_OS_LINUX
    return u"Fusion"_s;
#else
    return QString();
#endif
}

// Name of the style CsoundQt installed last (see installWidgetStyle below).
// Qt replaces the application style with an internal QStyleSheetStyle as soon
// as any stylesheet is set - the code editor styles its scrollbars, and dialogs
// such as About have their own stylesheets - and that wrapper hides the real
// style from currentWidgetStyleName().
inline QString &installedWidgetStyleName()
{
    static QString name;
    return name;
}

// Whether the code editor uses the flat (thin, arrow-less) scrollbars. Set from
// the "Flat scrollbars" setting and only ever honoured for the Fusion style
// (see TextEditLineNumbers::updateScrollBarStyle).
inline bool &flatScrollBarsEnabled()
{
    static bool enabled = true;
    return enabled;
}

// Flat scrollbar look used when the Fusion style is active and the "Flat
// scrollbars" setting is on: thin, arrow-less bars with a rounded handle. The
// track is filled with `background` (the surface behind the bars) so it blends
// into the surrounding area; clicking the track still pages.
inline QString flatScrollBarStyleSheet(const QColor &background)
{
    return uR"(
QScrollBar:vertical {
    width: 6px;
    background: %1;
    margin: 0;
}
QScrollBar::handle:vertical {
    background: palette(mid);
    border-radius: 3px;
    min-height: 24px;
}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0;
    background: none;
}
QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical {
    background: none;
}
QScrollBar:horizontal {
    height: 6px;
    background: %1;
    margin: 0;
}
QScrollBar::handle:horizontal {
    background: palette(mid);
    border-radius: 3px;
    min-width: 24px;
}
QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
    width: 0;
    background: none;
}
QScrollBar::add-page:horizontal, QScrollBar::sub-page:horizontal {
    background: none;
}
)"_s.arg(background.name());
}

// Name of the style currently in use. The application style is wrapped in
// DialogButtonStyle, whose own objectName is empty, so look at the base style
// it wraps.
inline QString currentWidgetStyleName()
{
    if (auto *proxy = qobject_cast<QProxyStyle *>(QApplication::style())) {
        if (proxy->baseStyle() != nullptr && !proxy->baseStyle()->objectName().isEmpty())
            return proxy->baseStyle()->objectName();
    }
    // A stylesheet is active: Qt hid the real style (see above), so fall back
    // to the name recorded when it was installed.
    if (!installedWidgetStyleName().isEmpty())
        return installedWidgetStyleName();
    if (QApplication::style() != nullptr)
        return QApplication::style()->objectName();
    return QString();
}

// The classic Qt "Windows" style is a legacy fallback that looks out of place
// on every platform - it is not the native Windows style, which is
// "windows11"/"windowsvista". Hide it from the chooser and never select it.
inline bool isHiddenWidgetStyle(const QString &name)
{
    return name.compare(u"Windows"_s, Qt::CaseInsensitive) == 0;
}

// Widget styles offered to the user: Qt's own keys in Qt's order, minus the
// hidden ones above.
inline QStringList availableWidgetStyleNames()
{
    QStringList keys = QStyleFactory::keys();
    keys.removeIf([](const QString &key) { return isHiddenWidgetStyle(key); });
    return keys;
}

// Resolve a configured style name to an available Qt style key. An empty
// config means "use the platform default". When the requested style is not
// available (e.g. its plugin was removed, or it is a hidden style) this falls
// back to the platform default, which itself may be empty (keep Qt's current
// style).
inline QString resolveWidgetStyleName(const QString &requested)
{
    const QString wanted = requested.isEmpty() ? defaultWidgetStyleName() : requested;
    if (!wanted.isEmpty()) {
        const QStringList keys = availableWidgetStyleNames();
        for (const QString &key : keys) {
            if (key.compare(wanted, Qt::CaseInsensitive) == 0)
                return key; // canonical key as Qt knows it
        }
        qWarning() << "Widget style not available:" << wanted
                   << "- using" << defaultWidgetStyleName();
    }
    return defaultWidgetStyleName();
}

// Create a style for a resolved name; returns nullptr when Qt's current style
// should be kept (empty name or style unavailable).
inline QStyle *createWidgetStyle(const QString &name)
{
    if (name.isEmpty())
        return nullptr;
    if (QStyle *style = QStyleFactory::create(name)) {
        style->setObjectName(name);
        return style;
    }
    return nullptr;
}

// Install an application style (nullptr keeps Qt's current style), wrapped in
// DialogButtonStyle so dialog buttons stay text-only. Also records which style
// is active, so widgets that adapt to the style (e.g. the editor scrollbars)
// can still tell which one it is once a stylesheet hides it (see above).
inline void installWidgetStyle(QStyle *style, const QString &name)
{
    if (style == nullptr)
        style = QApplication::style();
    if (style == nullptr)
        return;
    const QString installedName = name.isEmpty() ? style->objectName() : name;
    qApp->setStyle(new DialogButtonStyle(style));
    installedWidgetStyleName() = installedName.isEmpty()
            ? currentWidgetStyleName() : installedName;
}

// Apply or remove the flat scrollbar look on a widget panel's scroll area.
// Only Fusion gets it, and only when the "Flat scrollbars" option is on, so
// every other style keeps its native scrollbars.
inline void updateFlatScrollBarStyle(QScrollArea *area)
{
    if (area == nullptr)
        return;
    const bool flat =
            currentWidgetStyleName().compare(u"Fusion"_s, Qt::CaseInsensitive) == 0
            && flatScrollBarsEnabled();
    QWidget *viewport = area->viewport();
    const QColor background = viewport != nullptr
            ? viewport->palette().color(QPalette::Window)
            : area->palette().color(QPalette::Window);
    const QString sheet = flat ? flatScrollBarStyleSheet(background) : QString();
    for (QScrollBar *bar : {area->verticalScrollBar(), area->horizontalScrollBar()}) {
        if (bar->styleSheet() != sheet)
            bar->setStyleSheet(sheet);
    }
}

#endif // WIDGETSTYLE_H
