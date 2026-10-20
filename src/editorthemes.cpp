/***************************************************************************
 *   Copyright (C) 2026 by the CsoundQt developers                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Lesser General Public License as        *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 ***************************************************************************/

#include "editorthemes.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QStandardPaths>

#include <algorithm>

namespace EditorThemes {

namespace {

QHash<QString, Theme> g_themes;
QStringList g_names; // sorted for display

const QStringList &builtInThemeNames()
{
    static const QStringList names = {
        QStringLiteral("light"),
        QStringLiteral("dark"),
        QStringLiteral("light classic")
    };
    return names;
}

// Read a colour attribute. Returns false when the value is present but not a
// valid colour, so the caller can log the problem.
bool readColor(const QJsonObject &object, const QString &key,
               const QString &themeName, const QString &context,
               QColor *out, bool *present)
{
    *present = false;
    const QJsonValue value = object.value(key);
    if (value.isUndefined())
        return true;
    *present = true;
    if (!value.isString()) {
        qDebug() << "CsoundQt: theme" << themeName << "-" << (context + key)
                 << "is not a string; ignored";
        *present = false;
        return false;
    }
    const QColor color(value.toString());
    if (!color.isValid()) {
        qDebug() << "CsoundQt: theme" << themeName << "-" << (context + key)
                 << "is not a valid colour:" << value.toString() << "; ignored";
        *present = false;
        return false;
    }
    *out = color;
    return true;
}

bool readBool(const QJsonObject &object, const QString &key,
              const QString &themeName, const QString &context,
              bool *out, bool *present)
{
    *present = false;
    const QJsonValue value = object.value(key);
    if (value.isUndefined())
        return true;
    if (!value.isBool()) {
        qDebug() << "CsoundQt: theme" << themeName << "-" << (context + key)
                 << "is not a boolean; ignored";
        return false;
    }
    *present = true;
    *out = value.toBool();
    return true;
}

bool parseFormat(const QJsonValue &value, const QString &themeName,
                 const QString &role, FormatSpec *spec)
{
    if (!value.isObject()) {
        qDebug() << "CsoundQt: theme" << themeName << "- format" << role
                 << "is not an object; ignored";
        return false;
    }
    const QJsonObject object = value.toObject();
    const QString context = QStringLiteral("formats.%1.").arg(role);

    QColor color;
    bool present = false;
    if (readColor(object, "foreground", themeName, context, &color, &present) && present)
        spec->foreground = color;
    if (readColor(object, "background", themeName, context, &color, &present) && present)
        spec->background = color;
    if (readColor(object, "underlineColor", themeName, context, &color, &present) && present)
        spec->underlineColor = color;

    bool flag = false;
    if (readBool(object, "bold", themeName, context, &flag, &present) && present)
        spec->bold = flag;
    if (readBool(object, "italic", themeName, context, &flag, &present) && present)
        spec->italic = flag;
    if (readBool(object, "underline", themeName, context, &flag, &present) && present)
        spec->underline = flag;
    if (readBool(object, "strikeout", themeName, context, &flag, &present) && present)
        spec->strikeout = flag;

    return true;
}

bool readDefaultColors(const QJsonObject &root, const QString &name,
                       const QString &path, QColor *foreground, QColor *background)
{
    const QJsonValue defaultValue = root.value(QStringLiteral("default"));
    if (!defaultValue.isObject()) {
        qDebug() << "CsoundQt: ignoring theme" << path
                 << "- missing \"default\" object (foreground and background are required)";
        return false;
    }
    const QJsonObject object = defaultValue.toObject();

    auto readRequired = [&](const QString &key, QColor *out) {
        const QJsonValue value = object.value(key);
        if (!value.isString()) {
            qDebug() << "CsoundQt: ignoring theme" << path << "-" << name
                     << ": default." << key << "is required and must be a colour string";
            return false;
        }
        const QColor color(value.toString());
        if (!color.isValid()) {
            qDebug() << "CsoundQt: ignoring theme" << path << "-" << name
                     << ": default." << key << "is not a valid colour:" << value.toString();
            return false;
        }
        *out = color;
        return true;
    };

    return readRequired(QStringLiteral("foreground"), foreground)
            && readRequired(QStringLiteral("background"), background);
}

void loadFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "CsoundQt: cannot read editor theme" << path << ":" << file.errorString();
        return;
    }

    QJsonParseError error;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);
    if (error.error != QJsonParseError::NoError) {
        qDebug() << "CsoundQt: ignoring editor theme" << path << "- invalid JSON:"
                 << error.errorString() << "at offset" << error.offset;
        return;
    }
    if (!document.isObject()) {
        qDebug() << "CsoundQt: ignoring editor theme" << path << "- top level is not an object";
        return;
    }
    const QJsonObject root = document.object();

    const QJsonValue nameValue = root.value(QStringLiteral("name"));
    if (!nameValue.isString() || nameValue.toString().trimmed().isEmpty()) {
        qDebug() << "CsoundQt: ignoring editor theme" << path
                 << "- missing required \"name\"";
        return;
    }
    const QString name = nameValue.toString().trimmed();
    if (name == QLatin1String("auto")) {
        qDebug() << "CsoundQt: ignoring editor theme" << path
                 << "- \"auto\" is reserved for the application theme";
        return;
    }
    if (isBuiltIn(name)) {
        qDebug() << "CsoundQt: ignoring editor theme" << path
                 << "- the name" << name << "is reserved for a built-in theme";
        return;
    }
    if (g_themes.contains(name)) {
        qDebug() << "CsoundQt: ignoring editor theme" << path
                 << "- a theme named" << name << "was already loaded";
        return;
    }

    Theme theme;
    theme.name = name;
    if (!readDefaultColors(root, name, path,
                           &theme.defaultForeground, &theme.defaultBackground)) {
        return;
    }
    theme.dark = theme.defaultForeground.lightness() > theme.defaultBackground.lightness();

    const QJsonValue formatsValue = root.value(QStringLiteral("formats"));
    if (!formatsValue.isUndefined()) {
        if (!formatsValue.isObject()) {
            qDebug() << "CsoundQt: theme" << name
                     << "- \"formats\" is not an object; using the built-in values";
        }
        else {
            const QJsonObject formats = formatsValue.toObject();
            for (auto it = formats.constBegin(); it != formats.constEnd(); ++it) {
                FormatSpec spec;
                if (parseFormat(it.value(), name, it.key(), &spec))
                    theme.formats.insert(it.key(), spec);
            }
        }
    }

    qDebug() << "CsoundQt: loaded editor theme" << name << "from" << path
             << "-" << (theme.dark ? "dark" : "light") << "base";
    g_themes.insert(name, theme);
}

} // namespace

QString userThemeDir()
{
    const QString dataLocation =
            QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    if (dataLocation.isEmpty())
        return QString();
    return QDir(dataLocation).filePath(QStringLiteral("csoundqt/themes"));
}

void initialize()
{
    g_themes.clear();
    g_names.clear();

    const QString dirPath = userThemeDir();
    if (dirPath.isEmpty()) {
        qDebug() << "CsoundQt: no writable data location for editor themes";
        return;
    }
    if (!QDir().mkpath(dirPath)) {
        qDebug() << "CsoundQt: cannot create editor theme directory" << dirPath;
        return;
    }
    qDebug() << "CsoundQt: loading editor themes from" << dirPath;

    const QDir dir(dirPath);
    const QStringList files = dir.entryList(QStringList() << QStringLiteral("*.json"),
                                            QDir::Files, QDir::Name);
    for (const QString &fileName : files)
        loadFile(dir.absoluteFilePath(fileName));

    g_names = g_themes.keys();
    std::sort(g_names.begin(), g_names.end(), [](const QString &a, const QString &b) {
        return QString::localeAwareCompare(a, b) < 0;
    });
}

QStringList builtInNames()
{
    return builtInThemeNames();
}

bool isBuiltIn(const QString &name)
{
    if (name == QLatin1String("none")) // legacy, always hidden
        return true;
    return builtInThemeNames().contains(name);
}

QStringList userThemeNames()
{
    return g_names;
}

const Theme *find(const QString &name)
{
    auto it = g_themes.constFind(name);
    if (it == g_themes.constEnd())
        return nullptr;
    return &it.value();
}

bool exists(const QString &name)
{
    return isBuiltIn(name) || g_themes.contains(name);
}

} // namespace EditorThemes
