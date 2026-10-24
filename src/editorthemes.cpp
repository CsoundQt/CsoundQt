
/***************************************************************************
 *   Copyright (C) 2026 by the CsoundQt developers                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Lesser General Public License as        *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 ***************************************************************************/

#include "editorthemes.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFont>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QRegularExpression>
#include <QSaveFile>
#include <QStandardPaths>

#include <algorithm>
using namespace Qt::StringLiterals;

namespace EditorThemes {

namespace {

QHash<QString, Theme> g_themes;
QStringList g_jsonNames; // shipped + user themes, sorted for display
int g_refreshGeneration = 0;

const QStringList &builtInThemeNames()
{
    static const QStringList names = {
        u"light"_s,
        u"dark"_s,
        u"light classic"_s
    };
    return names;
}

QColor saturateColor(const QColor &color, int percent)
{
    int saturation = color.saturation();
    saturation = saturation * percent / 100;
    if (saturation > 255)
        saturation = 255;
    return QColor::fromHsl(color.hue(), saturation, color.lightness());
}

// Closing XML/csd tags (</CsInstruments>, </CsOptions>, ...) are only
// structural markers. A colour halfway between the normal tag colour and the
// editor background makes them less intrusive while still visible.
QColor dimmedColor(const QColor &foreground, const QColor &background, double factor)
{
    if (!foreground.isValid() || !background.isValid())
        return foreground;
    return QColor((foreground.red()*(1-factor) + background.red()*factor),
                  (foreground.green()*(1-factor) + background.green()*factor),
                  (foreground.blue()*(1-factor) + background.blue()* factor));
}

FormatSpec makeSpec(const QColor &foreground = QColor(),
                    const QColor &background = QColor(),
                    int weight = QFont::Normal,
                    bool italic = false,
                    bool underline = false,
                    const QColor &underlineColor = QColor())
{
    FormatSpec spec;
    if (foreground.isValid())
        spec.foreground = foreground;
    if (background.isValid())
        spec.background = background;
    if (weight >= QFont::Bold)
        spec.bold = true;
    if (italic)
        spec.italic = true;
    if (underline)
        spec.underline = true;
    if (underlineColor.isValid())
        spec.underlineColor = underlineColor;
    return spec;
}

Theme makeLightTheme()
{
    Theme theme;
    theme.name = u"light"_s;
    theme.source = Source::BuiltIn;
    theme.defaultForeground = QColor(u"#030303"_s);
    theme.defaultBackground = QColor(u"#F9F9F9"_s);

    const QColor instanceColor(u"#82387B"_s);
    const QColor keywordColor(u"#D64100"_s);
    const QColor opcodeColor(u"#303F9F"_s);
    const QColor commentColor(u"#8F8F7F"_s);
    QHash<QString, FormatSpec> &f = theme.formats;
    f[u"inst"_s] = makeSpec(instanceColor, {}, QFont::Bold);
    f[u"keyword"_s] = makeSpec(keywordColor, {}, QFont::Bold);
    f[u"header"_s] = f[u"keyword"_s];
    f[u"opcode"_s] = makeSpec(opcodeColor, {}, QFont::Bold);
    f[u"deprecated"_s] = makeSpec(QColor(u"#880000"_s), {},
                                               QFont::Normal, false, true);
    f[u"singleLineComment"_s] = makeSpec(commentColor, {}, QFont::Normal, true);
    f[u"importantComment"_s] =
            makeSpec(commentColor.darker(150), QColor(u"#FFFFA0"_s));
    f[u"macroDefine"_s] = makeSpec(QColor(u"#00695C"_s), {}, QFont::Bold);
    f[u"pfield"_s] = makeSpec({}, {}, QFont::Bold);
    f[u"krate"_s] = makeSpec(QColor(u"#10796C"_s));
    f[u"irate"_s] = makeSpec(QColor(u"#546E7A"_s));
    f[u"arate"_s] = makeSpec(QColor(u"#B71C1C"_s));
    f[u"stringVar"_s] = makeSpec(QColor(Qt::darkYellow));
    f[u"fsig"_s] = makeSpec(QColor(u"#AD1457"_s), {}, QFont::Bold);
    f[u"boolean"_s] = makeSpec(QColor(u"#7B1FA2"_s));
    f[u"complex"_s] = makeSpec(QColor(u"#6D4C41"_s));
    f[u"label"_s] = makeSpec(QColor(205, 92, 92), {}, QFont::Bold, false, true);
    f[u"name"_s] = makeSpec(QColor(u"#F50057"_s), {}, QFont::Bold);
    f[u"quotation"_s] = makeSpec(QColor(u"#827717"_s));
    f[u"multiLineComment"_s] = f[u"quotation"_s];
    f[u"io"_s] = makeSpec(QColor(u"#8844BB"_s), {}, QFont::Bold);
    f[u"udo"_s] = makeSpec(opcodeColor.darker(150), {}, QFont::Bold);
    f[u"csdtag"_s] = makeSpec(instanceColor);
    f[u"csdtagClose"_s] = makeSpec(dimmedColor(instanceColor, theme.defaultBackground, 0.3));
    f[u"operator"_s] = makeSpec(instanceColor);
    f[u"scoreLetter"_s] = makeSpec(opcodeColor, {}, QFont::Bold);
    return theme;
}

Theme makeDarkTheme()
{
    Theme theme;
    theme.name = u"dark"_s;
    theme.source = Source::BuiltIn;
    theme.dark = true;
    theme.defaultForeground = QColor(u"#FBFBFB"_s);
    theme.defaultBackground = QColor(u"#1e1e1e"_s);

    const QColor instanceColor(u"#B268AB"_s);
    const QColor keywordColor(u"#FFad66"_s);
    const QColor opcodeColor(u"#4FC3F7"_s);
    const QColor commentColor(u"#a49fb0"_s);
    const QColor quotationColor(u"#c5b77d"_s);//(QStringLiteral("#91FF55"));
    const QColor nameColor(u"#D298FB"_s);
    QHash<QString, FormatSpec> &f = theme.formats;
    f[u"inst"_s] = makeSpec(instanceColor, {}, QFont::Bold);
    f[u"keyword"_s] = makeSpec(keywordColor, {}, QFont::Bold);
    f[u"header"_s] = f[u"keyword"_s];
    f[u"opcode"_s] = makeSpec(opcodeColor, {}, QFont::Bold);
    f[u"deprecated"_s] = makeSpec(saturateColor(opcodeColor, 50), {},
                                               QFont::Normal, false, true,
                                               QColor(u"#880000"_s));
    f[u"singleLineComment"_s] = makeSpec(commentColor, {}, QFont::Normal, true);
    f[u"importantComment"_s] =
            makeSpec(commentColor.lighter(175), theme.defaultBackground.lighter(140));
    f[u"macroDefine"_s] = makeSpec(QColor(u"#F06292"_s), {}, QFont::Bold);
    f[u"pfield"_s] = makeSpec({}, {}, QFont::Bold);
    f[u"krate"_s] = makeSpec(QColor(u"#87f0c8"_s));
    f[u"irate"_s] = makeSpec(QColor(u"#d0caf0"_s));
    f[u"arate"_s] = makeSpec(QColor(u"#ff6b81"_s));
    f[u"fsig"_s] = makeSpec(QColor(u"#BD2467"_s), {}, QFont::Bold);
    f[u"boolean"_s] = makeSpec(QColor(u"#D4E157"_s));
    f[u"complex"_s] = makeSpec(QColor(u"#26A69A"_s));
    f[u"label"_s] = makeSpec(instanceColor, {}, QFont::Bold, false, true);
    f[u"name"_s] = makeSpec(nameColor, {}, QFont::Bold);
    f[u"quotation"_s] = makeSpec(quotationColor);
    f[u"stringVar"_s] = makeSpec(QColor(u"#e5aIf82"_s));// f[QStringLiteral("quotation")];
    f[u"multiLineComment"_s] = f[u"singleLineComment"_s];
    f[u"io"_s] = makeSpec(QColor(u"#FFD54F"_s), {}, QFont::Bold);
    f[u"udo"_s] = makeSpec(opcodeColor);
    f[u"csdtag"_s] = makeSpec(instanceColor);
    f[u"csdtagClose"_s] = makeSpec(dimmedColor(instanceColor, theme.defaultBackground, 0.55));
    f[u"operator"_s] = makeSpec(nameColor);
    f[u"scoreLetter"_s] = makeSpec(opcodeColor, {}, QFont::Bold);
    return theme;
}

Theme makeClassicTheme()
{
    Theme theme;
    theme.name = u"light classic"_s;
    theme.source = Source::BuiltIn;
    theme.defaultForeground = QColor(Qt::black);
    theme.defaultBackground = QColor(250, 250, 250);

    const QColor brown(u"#A52A2A"_s);
    const QColor purple(u"#800080"_s);
    const QColor blue(Qt::blue);
    const QColor green(u"green"_s);
    const QColor darkCyan(u"darkCyan"_s);
    const QColor opcodeColor = blue;
    QHash<QString, FormatSpec> &f = theme.formats;
    f[u"csdtag"_s] = makeSpec(brown, {}, QFont::Bold);
    f[u"csdtagClose"_s] = f[u"csdtag"_s];
    // f[u"csdtagClose"_s].foreground = dimmedColor(brown, theme.defaultBackground);
    f[u"inst"_s] = makeSpec(purple, {}, QFont::Bold);
    f[u"keyword"_s] = makeSpec(QColor(u"#E65100"_s), {}, QFont::Bold);
    f[u"header"_s] = makeSpec(brown, {}, QFont::Bold);
    f[u"opcode"_s] = makeSpec(opcodeColor, {}, QFont::Bold);
    f[u"deprecated"_s] = f[u"opcode"_s];
    f[u"singleLineComment"_s] = makeSpec(green, {}, QFont::Normal, true);
    f[u"macroDefine"_s] = makeSpec(green, {}, QFont::Bold);
    f[u"pfield"_s] = makeSpec({}, {}, QFont::Bold);
    f[u"irate"_s] = makeSpec(darkCyan);
    f[u"krate"_s] = makeSpec(darkCyan);
    f[u"arate"_s] = makeSpec(darkCyan, {}, QFont::Bold);
    f[u"stringVar"_s] = makeSpec(QColor(Qt::darkYellow), {}, QFont::Bold);
    f[u"fsig"_s] = makeSpec(QColor(Qt::gray), {}, QFont::Bold);
    f[u"boolean"_s] = makeSpec(QColor(u"#FF8C00"_s), {}, QFont::Bold);
    f[u"complex"_s] = makeSpec(QColor(u"#008080"_s), {}, QFont::Bold);
    f[u"label"_s] = makeSpec(QColor(205, 92, 92), {}, QFont::Bold);
    f[u"name"_s] = makeSpec(QColor(u"#880E4F"_s), {}, QFont::Bold);
    f[u"quotation"_s] = makeSpec(QColor(Qt::red));
    f[u"multiLineComment"_s] = makeSpec(green);
    f[u"io"_s] = f[u"opcode"_s];
    f[u"udo"_s] = f[u"opcode"_s];
    f[u"operator"_s] = makeSpec(Qt::black, QColor(250, 250, 250));
    f[u"importantComment"_s] = f[u"singleLineComment"_s];
    f[u"scoreLetter"_s] = f[u"opcode"_s];
    return theme;
}

Theme makeNoneTheme()
{
    // Legacy, hidden: plain text without any highlighting.
    Theme theme;
    theme.name = u"none"_s;
    theme.source = Source::BuiltIn;
    theme.defaultForeground = QColor(Qt::black);
    theme.defaultBackground = QColor(250, 250, 250);
    return theme;
}

void addBuiltInThemes()
{
    for (const Theme &theme : {makeLightTheme(), makeDarkTheme(),
                               makeClassicTheme(), makeNoneTheme()}) {
        g_themes.insert(theme.name, theme);
    }
}

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
    const QString context = u"formats.%1."_s.arg(role);

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
    const QJsonValue defaultValue = root.value(u"default"_s);
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

    return readRequired(u"foreground"_s, foreground)
            && readRequired(u"background"_s, background);
}

void loadFile(const QString &path, Source source)
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

    const QJsonValue nameValue = root.value(u"name"_s);
    if (!nameValue.isString() || nameValue.toString().trimmed().isEmpty()) {
        qDebug() << "CsoundQt: ignoring editor theme" << path
                 << "- missing required \"name\"";
        return;
    }
    const QString name = nameValue.toString().trimmed();
    if (name == "auto"_L1) {
        qDebug() << "CsoundQt: ignoring editor theme" << path
                 << "- \"auto\" is reserved for the application theme";
        return;
    }

    auto existing = g_themes.find(name);
    if (existing != g_themes.end()) {
        if (existing->source == Source::BuiltIn) {
            qDebug() << "CsoundQt: ignoring editor theme" << path
                     << "- the name" << name << "is reserved for a built-in theme";
            return;
        }
        if (existing->source == Source::Shipped && source == Source::User) {
            // Let a user theme customise a shipped one without changing its id.
            qDebug() << "CsoundQt: user editor theme" << name
                     << "overrides the shipped theme";
            g_themes.erase(existing);
        }
        else {
            qDebug() << "CsoundQt: ignoring editor theme" << path
                     << "- a theme named" << name << "was already loaded";
            return;
        }
    }

    Theme theme;
    theme.name = name;
    theme.source = source;
    theme.filePath = path;
    if (!readDefaultColors(root, name, path,
                           &theme.defaultForeground, &theme.defaultBackground)) {
        return;
    }
    theme.dark = theme.defaultForeground.lightness() > theme.defaultBackground.lightness();

    const QJsonValue formatsValue = root.value(u"formats"_s);
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

void scanResources()
{
    const QDir dir(u":/syntax-themes"_s);
    const QStringList files = dir.entryList(QStringList() << u"*.json"_s,
                                            QDir::Files, QDir::Name);
    for (const QString &fileName : files)
        loadFile(dir.absoluteFilePath(fileName), Source::Shipped);
}

void scanUserThemes(const QString &dirPath)
{
    const QDir dir(dirPath);
    const QStringList files = dir.entryList(QStringList() << u"*.json"_s,
                                            QDir::Files, QDir::Name);
    for (const QString &fileName : files)
        loadFile(dir.absoluteFilePath(fileName), Source::User);
}

QString colorToString(const QColor &color)
{
    return color.alpha() == 255 ? color.name(QColor::HexRgb)
                                : color.name(QColor::HexArgb);
}

QJsonObject formatToJson(const FormatSpec &spec)
{
    QJsonObject object;
    if (spec.foreground)
        object.insert(u"foreground"_s, colorToString(*spec.foreground));
    if (spec.background)
        object.insert(u"background"_s, colorToString(*spec.background));
    if (spec.underlineColor)
        object.insert(u"underlineColor"_s, colorToString(*spec.underlineColor));
    if (spec.bold)
        object.insert(u"bold"_s, *spec.bold);
    if (spec.italic)
        object.insert(u"italic"_s, *spec.italic);
    if (spec.underline)
        object.insert(u"underline"_s, *spec.underline);
    if (spec.strikeout)
        object.insert(u"strikeout"_s, *spec.strikeout);
    return object;
}

QString sanitizedFileBase(const QString &name)
{
    QString base = name;
    base.replace(QRegularExpression(uR"([^A-Za-z0-9._-]+)"_s),
                 u"-"_s);
    base.remove(QRegularExpression(uR"(^-+|-+$)"_s));
    if (base.isEmpty())
        base = u"theme"_s;
    return base;
}

} // namespace

QString userThemeDir()
{
    const QString dataLocation =
            QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    if (dataLocation.isEmpty())
        return QString();
    return QDir(dataLocation).filePath(u"csoundqt/themes"_s);
}

void refresh()
{
    g_themes.clear();
    g_jsonNames.clear();
    ++g_refreshGeneration;

    // Compiled-in themes first: they are reserved and always available.
    addBuiltInThemes();

    scanResources();

    const QString dirPath = userThemeDir();
    if (dirPath.isEmpty()) {
        qDebug() << "CsoundQt: no writable data location for editor themes";
    }
    else if (!QDir().mkpath(dirPath)) {
        qDebug() << "CsoundQt: cannot create editor theme directory" << dirPath;
    }
    else {
        qDebug() << "CsoundQt: loading editor themes from" << dirPath;
        scanUserThemes(dirPath);
    }

    for (auto it = g_themes.constBegin(); it != g_themes.constEnd(); ++it) {
        if (it->source != Source::BuiltIn)
            g_jsonNames << it.key();
    }
    std::sort(g_jsonNames.begin(), g_jsonNames.end(),
              [](const QString &a, const QString &b) {
        return QString::localeAwareCompare(a, b) < 0;
    });
}

void initialize()
{
    refresh();
}

int refreshGeneration()
{
    return g_refreshGeneration;
}

QStringList builtInNames()
{
    return builtInThemeNames();
}

bool isBuiltIn(const QString &name)
{
    if (name == "none"_L1) // legacy, always hidden
        return true;
    return builtInThemeNames().contains(name);
}

QStringList jsonThemeNames()
{
    return g_jsonNames;
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
    return g_themes.contains(name);
}

QString duplicateTheme(const QString &name, QString *error)
{
    const Theme *theme = find(name);
    if (!theme) {
        if (error)
            *error = QCoreApplication::translate("EditorThemes", "The selected theme does not exist.");
        return QString();
    }
    const QString dirPath = userThemeDir();
    if (dirPath.isEmpty() || !QDir().mkpath(dirPath)) {
        if (error)
            *error = QCoreApplication::translate("EditorThemes", "Could not create the theme folder.");
        return QString();
    }

    // "<name>-2", "<name>-3", ...
    QString newName;
    for (int number = 2; ; ++number) {
        newName = u"%1-%2"_s.arg(name).arg(number);
        if (!exists(newName))
            break;
    }

    QJsonObject root;
    root.insert(u"name"_s, newName);
    QJsonObject defaultObject;
    defaultObject.insert(u"foreground"_s, colorToString(theme->defaultForeground));
    defaultObject.insert(u"background"_s, colorToString(theme->defaultBackground));
    root.insert(u"default"_s, defaultObject);

    QJsonObject formats;
    for (auto it = theme->formats.constBegin(); it != theme->formats.constEnd(); ++it) {
        const QJsonObject object = formatToJson(it.value());
        if (!object.isEmpty())
            formats.insert(it.key(), object);
    }
    if (!formats.isEmpty())
        root.insert(u"formats"_s, formats);

    const QString base = sanitizedFileBase(newName);
    QString path = QDir(dirPath).filePath(base + u".json"_s);
    for (int number = 2; QFileInfo::exists(path); ++number)
        path = QDir(dirPath).filePath(u"%1-%2.json"_s.arg(base).arg(number));

    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        if (error)
            *error = QCoreApplication::translate("EditorThemes", "Could not write %1: %2").arg(path, file.errorString());
        return QString();
    }
    file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    if (!file.commit()) {
        if (error)
            *error = QCoreApplication::translate("EditorThemes", "Could not write %1: %2").arg(path, file.errorString());
        return QString();
    }

    initialize();
    if (!exists(newName)) {
        if (error)
            *error = QCoreApplication::translate("EditorThemes", "The copied theme could not be loaded from %1.").arg(path);
        return QString();
    }
    qDebug() << "CsoundQt: duplicated editor theme" << name << "as" << newName
             << "in" << path;
    return newName;
}

} // namespace EditorThemes
