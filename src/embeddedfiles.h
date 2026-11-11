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

#ifndef EMBEDDEDFILES_H
#define EMBEDDEDFILES_H

#include <QByteArray>
#include <QString>
#include <QVector>

// One <CsFileB> block of a CSD file:
//
//   <CsFileB filename="name">
//   <base64 data>
//   </CsFileB>
//
// Csound extracts these blocks to the current working directory while the CSD
// is compiled. CsoundQt keeps them out of the editable text and stores them as
// text (see BaseView::m_filebText); this helper parses and serializes that
// text, and writes one entry back to disk.
struct EmbeddedFile
{
    QString name;        // filename attribute, without quotes
    QString payload;     // base64 text between the tags
    QString rawBlock;    // complete block, kept for a lossless round-trip
    qint64 decodedSize = 0; // approximate decoded size, without decoding
};

namespace EmbeddedFiles {

// Parse every <CsFileB ...> ... </CsFileB> block in text. Blocks without a
// matching end tag are ignored.
QVector<EmbeddedFile> parse(const QString &text);

// Rebuild the hidden block text from the entries. Entries that were not
// changed keep their original rawBlock byte for byte.
QString serialize(const QVector<EmbeddedFile> &files);

// Build a canonical block for a newly added or replaced embedded file. The
// payload is wrapped at 72 columns, like csb64enc.
QString makeBlock(const QString &name, const QByteArray &data);

// Decode the payload of one entry. Returns false and sets error when the data
// is not valid base64.
bool decode(const EmbeddedFile &file, QByteArray *data, QString *error = nullptr);

// Write the decoded entry to directory/name. The name must be a plain file
// name (no folders). When the target exists it is only replaced if overwrite
// is true. Returns false and sets error on failure.
bool extract(const EmbeddedFile &file, const QString &directory, bool overwrite,
             QString *error = nullptr);

// Empty when name is usable as a <CsFileB filename="..."> value, otherwise a
// translated explanation.
QString validateName(const QString &name);

// Approximate decoded size of a base64 payload, computed without decoding it.
qint64 decodedSize(const QString &base64);

} // namespace EmbeddedFiles

#endif // EMBEDDEDFILES_H
