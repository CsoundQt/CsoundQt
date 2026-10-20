/***************************************************************************
 *   Copyright (C) 2026 by the CsoundQt developers                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Lesser General Public License as        *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 ***************************************************************************/

#ifndef EDITORTHEMES_H
#define EDITORTHEMES_H

#include <QColor>
#include <QHash>
#include <QString>
#include <QStringList>
#include <optional>

// User-defined editor (syntax highlighting) themes, loaded from JSON files.
//
// The built-in themes (light, dark, light classic) are compiled in and are
// never read from disk. A user theme only needs to describe what it changes:
// its default colours are required (they also decide whether the theme is
// based on the built-in light or dark theme), every other role/attribute that
// is missing or invalid falls back to that built-in base.
namespace EditorThemes {

struct FormatSpec {
    std::optional<QColor> foreground;
    std::optional<QColor> background;
    std::optional<QColor> underlineColor;
    std::optional<bool> bold;
    std::optional<bool> italic;
    std::optional<bool> underline;
    std::optional<bool> strikeout;
};

struct Theme {
    QString name;                 // also the id used in the settings
    bool dark = false;            // chosen from the required default colours
    QColor defaultForeground;
    QColor defaultBackground;
    QHash<QString, FormatSpec> formats; // only validated entries
};

// Folder scanned for *.json themes. Empty if no writable location exists.
QString userThemeDir();

// Scans userThemeDir() and replaces the list of user themes. Call once at
// startup, before reading the settings. Built-in themes are always available
// and do not need this call.
void initialize();

// Built-in theme names, in the order they are shown in the settings.
QStringList builtInNames();

// True for the compiled-in themes (including the hidden "none").
bool isBuiltIn(const QString &name);

// User theme names, sorted for display.
QStringList userThemeNames();

// Look up a loaded user theme; nullptr for built-ins or unknown names.
const Theme *find(const QString &name);

// True if name is a built-in or a loaded user theme.
bool exists(const QString &name);

} // namespace EditorThemes

#endif // EDITORTHEMES_H
