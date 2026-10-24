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

enum class Source {
    BuiltIn,   // compiled in, always present, cannot be overridden
    Shipped,   // JSON resource (:/syntax-themes/...)
    User       // JSON file in userThemeDir()
};

struct Theme {
    QString name;                 // also the id used in the settings
    Source source = Source::User;
    QString filePath;             // resource or absolute path; empty for built-ins
    bool dark = false;            // chosen from the required default colours
    QColor defaultForeground;
    QColor defaultBackground;
    // For built-ins this is the complete definition. For JSON themes it holds
    // only the overrides; the built-in light or dark theme is applied first.
    QHash<QString, FormatSpec> formats;
};

// Folder scanned for *.json themes. Empty if no writable location exists.
QString userThemeDir();

// Scans userThemeDir() and replaces the list of user themes. Call once at
// startup, before reading the settings.
void initialize();

// Reloads the theme registry from the built-in resources and userThemeDir().
// Call again when the theme folder may have changed, for example when the
// settings dialog is opened.
void refresh();

// Incremented by refresh(). Consumers that cache a theme definition can use
// this to notice that a theme with the same name may have new contents.
int refreshGeneration();

// Built-in theme names, in the order they are shown in the settings.
QStringList builtInNames();

// True for the compiled-in themes (including the hidden "none").
bool isBuiltIn(const QString &name);

// Names of all JSON themes (shipped and user), sorted for display.
QStringList jsonThemeNames();

// Look up any loaded theme (built-in, shipped or user); nullptr if unknown.
const Theme *find(const QString &name);

// True if name is a built-in, shipped or user theme.
bool exists(const QString &name);

// Write a copy of the named theme to the user theme folder under a unique
// "<name>-<number>" name. Returns the new name, or an empty string on error
// (error is set to a user-presentable message). On success the theme registry
// is reloaded, so the new theme is immediately available.
QString duplicateTheme(const QString &name, QString *error);

} // namespace EditorThemes

#endif // EDITORTHEMES_H
