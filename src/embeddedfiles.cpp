/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
*/

#include "embeddedfiles.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QSaveFile>

using namespace Qt::StringLiterals;

namespace {

constexpr int kCloseTagLength = 10; // "</CsFileB>"
constexpr int kBase64LineWidth = 72;

QString translated(const char *text)
{
    return QCoreApplication::translate("EmbeddedFiles", text);
}

QString parseName(const QString &header)
{
    const int equals = header.indexOf(u"filename="_s);
    if (equals < 0)
        return QString();

    int pos = equals + 9; // strlen("filename=")
    while (pos < header.size() && header.at(pos).isSpace())
        ++pos;
    if (pos >= header.size())
        return QString();

    if (header.at(pos) == QLatin1Char('"')) {
        const int close = header.indexOf(QLatin1Char('"'), pos + 1);
        if (close < 0)
            return QString();
        return header.mid(pos + 1, close - pos - 1);
    }

    const int close = header.indexOf(QLatin1Char('>'), pos);
    if (close < 0)
        return header.mid(pos).trimmed();
    return header.mid(pos, close - pos).trimmed();
}

QByteArray cleanBase64(const QString &payload)
{
    QByteArray base64;
    base64.reserve(payload.size());
    for (const QChar c : payload) {
        if (!c.isSpace())
            base64.append(c.toLatin1());
    }
    return base64;
}

} // namespace

namespace EmbeddedFiles {

QVector<EmbeddedFile> parse(const QString &text)
{
    QVector<EmbeddedFile> files;
    int from = 0;

    while (from < text.size()) {
        const int start = text.indexOf(u"<CsFileB "_s, from);
        if (start < 0)
            break;

        const int headerEnd = text.indexOf(QLatin1Char('>'), start);
        if (headerEnd < 0)
            break;

        const int close = text.indexOf(u"</CsFileB>"_s, headerEnd + 1);
        if (close < 0)
            break; // malformed: no end tag

        int blockEnd = close + kCloseTagLength;
        // Keep the line break that follows the block, so concatenating the
        // original raw blocks reproduces the source text exactly.
        if (blockEnd < text.size() && text.at(blockEnd) == QLatin1Char('\r'))
            ++blockEnd;
        if (blockEnd < text.size() && text.at(blockEnd) == QLatin1Char('\n'))
            ++blockEnd;

        EmbeddedFile file;
        file.name = parseName(text.mid(start, headerEnd - start + 1));
        file.payload = text.mid(headerEnd + 1, close - headerEnd - 1);
        file.rawBlock = text.mid(start, blockEnd - start);
        file.decodedSize = decodedSize(file.payload);
        files.append(file);

        from = blockEnd;
    }

    return files;
}

QString serialize(const QVector<EmbeddedFile> &files)
{
    QString text;
    for (const EmbeddedFile &file : files) {
        text += file.rawBlock;
        if (!text.endsWith(QLatin1Char('\n')))
            text += QLatin1Char('\n');
    }
    return text;
}

QString makeBlock(const QString &name, const QByteArray &data)
{
    QString block = u"<CsFileB filename=\"%1\">\n"_s.arg(name);
    const QByteArray base64 = data.toBase64();
    for (int i = 0; i < base64.size(); i += kBase64LineWidth) {
        block += QString::fromLatin1(base64.mid(i, kBase64LineWidth));
        block += QLatin1Char('\n');
    }
    block += u"</CsFileB>\n"_s;
    return block;
}

bool decode(const EmbeddedFile &file, QByteArray *data, QString *error)
{
    QByteArray base64 = cleanBase64(file.payload);
    // Csound's decoder accepts unpadded data; make the length acceptable to
    // Qt before asking it to validate the alphabet.
    while (base64.size() % 4 != 0)
        base64.append('=');

    const QByteArray::FromBase64Result result =
            QByteArray::fromBase64Encoding(
                base64, QByteArray::AbortOnBase64DecodingErrors);
    if (!result) {
        if (error)
            *error = translated("The embedded data is not valid base64.");
        return false;
    }
    if (data)
        *data = result.decoded;
    return true;
}

bool extract(const EmbeddedFile &file, const QString &directory, bool overwrite,
             QString *error)
{
    const QString nameError = validateName(file.name);
    if (!nameError.isEmpty()) {
        if (error)
            *error = nameError;
        return false;
    }

    const QDir dir(directory);
    if (!dir.exists()) {
        if (error)
            *error = translated("The target directory does not exist.");
        return false;
    }

    const QString target = dir.filePath(file.name);
    if (QFileInfo::exists(target) && !overwrite) {
        if (error)
            *error = translated("The file already exists.");
        return false;
    }

    QByteArray data;
    QString decodeError;
    if (!decode(file, &data, &decodeError)) {
        if (error)
            *error = decodeError;
        return false;
    }

    QSaveFile out(target);
    if (!out.open(QIODevice::WriteOnly)) {
        if (error)
            *error = out.errorString();
        return false;
    }
    if (out.write(data) != data.size()) {
        if (error)
            *error = out.errorString();
        return false;
    }
    if (!out.commit()) {
        if (error)
            *error = out.errorString();
        return false;
    }
    return true;
}

QString validateName(const QString &name)
{
    if (name.isEmpty())
        return translated("The file name cannot be empty.");
    if (name != name.trimmed())
        return translated("The file name cannot start or end with whitespace.");

    // The name is a plain file name: no folders and no characters that would
    // break the <CsFileB filename="..."> tag or the extraction path.
    static const QString forbidden = u"\"<>/\\:|?*"_s;
    for (const QChar c : name) {
        if (c.unicode() < 0x20 || c.unicode() == 0x7f)
            return translated("The file name contains an invalid character.");
        if (forbidden.contains(c)) {
            return translated("The file name cannot contain the character '%1'.")
                    .arg(c);
        }
    }
    return QString();
}

qint64 decodedSize(const QString &base64)
{
    qint64 characters = 0;
    for (const QChar c : base64) {
        if (!c.isSpace())
            ++characters;
    }
    if (characters <= 0)
        return 0;

    int padding = 0;
    for (int i = base64.size() - 1; i >= 0; --i) {
        const QChar c = base64.at(i);
        if (c.isSpace())
            continue;
        if (c == QLatin1Char('='))
            ++padding;
        else
            break;
    }

    if (padding > 0) {
        const qint64 size = (characters / 4) * 3 - padding;
        return size > 0 ? size : 0;
    }
    // Some CSD writers omit the padding; Csound still decodes the bits.
    return (characters * 3) / 4;
}

} // namespace EmbeddedFiles
