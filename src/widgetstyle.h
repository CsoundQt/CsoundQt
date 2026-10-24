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
#include <QDebug>
#include <QProxyStyle>
#include <QStringList>
#include <QStyle>
#include <QStyleFactory>
using namespace Qt::StringLiterals;

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

// Name of the style currently in use. The application style is wrapped in
// DialogButtonStyle, whose own objectName is empty, so look at the base style
// it wraps.
inline QString currentWidgetStyleName()
{
    if (auto *proxy = qobject_cast<QProxyStyle *>(QApplication::style())) {
        if (proxy->baseStyle() != nullptr)
            return proxy->baseStyle()->objectName();
    }
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

#endif // WIDGETSTYLE_H
