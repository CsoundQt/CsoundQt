/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "bundledfonts.h"

#include <QDebug>
#include <QFontDatabase>
#include <QHash>

namespace {

struct BundledFont {
	const char *family;
	const char *resource;
};

const BundledFont sansFonts[] = {
	{"Liberation Sans", ":/fonts/Sans/LiberationSans/LiberationSans-Regular.ttf"},
	{"Noto Sans",       ":/fonts/Sans/NotoSans/NotoSans[wdth,wght].ttf"},
	{"Inter",           ":/fonts/Sans/Inter/Inter[opsz,wght].ttf"},
	{"Source Sans 3",   ":/fonts/Sans/SourceSans3/SourceSans3[wght].ttf"},
	{"IBM Plex Sans",   ":/fonts/Sans/IBMPlexSans/IBMPlexSans[wdth,wght].ttf"},
};

const BundledFont serifFonts[] = {
	{"Liberation Serif", ":/fonts/Serif/LiberationSerif/LiberationSerif-Regular.ttf"},
	{"IBM Plex Serif",   ":/fonts/Serif/IBMPlexSerif/IBMPlexSerif-Regular.ttf"},
	{"Source Serif 4",   ":/fonts/Serif/SourceSerif4/SourceSerif4[opsz,wght].ttf"},
};

const BundledFont monoFonts[] = {
	{"Liberation Mono", ":/fonts/Mono/LiberationMono/LiberationMono-Regular.ttf"},
	{"IBM Plex Mono",   ":/fonts/Mono/IBMPlexMono/IBMPlexMono-Regular.ttf"},
	{"JetBrains Mono",  ":/fonts/Mono/JetBrainsMono/JetBrainsMono[wght].ttf"},
};

bool isBundledFamily(const QString &family)
{
	const auto test = [&family](const BundledFont *table, size_t count) {
		for (size_t i = 0; i < count; ++i) {
			if (family.compare(QString::fromLatin1(table[i].family), Qt::CaseInsensitive) == 0) {
				return true;
			}
		}
		return false;
	};
	return test(sansFonts, sizeof(sansFonts) / sizeof(sansFonts[0]))
			|| test(serifFonts, sizeof(serifFonts) / sizeof(serifFonts[0]))
			|| test(monoFonts, sizeof(monoFonts) / sizeof(monoFonts[0]));
}

// Known equivalents (silently replaced). Keys are lower-case.
const QHash<QString, QString> &aliasTable()
{
	static const QHash<QString, QString> aliases = {
		{"arial", "Liberation Sans"},
		{"arial black", "Liberation Sans"},
		{"helvetica", "Liberation Sans"},
		{"helvetica neue", "Liberation Sans"},
		{"sans", "Liberation Sans"},
		{"sans serif", "Liberation Sans"},
		{"sans-serif", "Liberation Sans"},
		{"ms shell dlg", "Liberation Sans"},
		{"ms shell dlg 2", "Liberation Sans"},
		{"tahoma", "Liberation Sans"},
		{"times", "Liberation Serif"},
		{"times new roman", "Liberation Serif"},
		{"serif", "Liberation Serif"},
		{"freeserif", "Liberation Serif"},
		{"courier", "Liberation Mono"},
		{"courier new", "Liberation Mono"},
		{"courier 10 pitch", "Liberation Mono"},
		{"monospace", "Liberation Mono"},
		{"monospaced", "Liberation Mono"},
	};
	return aliases;
}

} // namespace

namespace BundledFonts {

int registerFonts()
{
	const BundledFont *tables[] = {sansFonts, serifFonts, monoFonts};
	const size_t counts[] = {
		sizeof(sansFonts) / sizeof(sansFonts[0]),
		sizeof(serifFonts) / sizeof(serifFonts[0]),
		sizeof(monoFonts) / sizeof(monoFonts[0]),
	};
	int registered = 0;
	for (int t = 0; t < 3; ++t) {
		for (size_t i = 0; i < counts[t]; ++i) {
			const int id = QFontDatabase::addApplicationFont(QString::fromLatin1(tables[t][i].resource));
			if (id == -1) {
				qWarning() << "BundledFonts: could not load" << tables[t][i].resource;
			} else {
				++registered;
			}
		}
	}
	return registered;
}

QStringList sansFamilies()
{
	QStringList families;
	for (const BundledFont &font : sansFonts) {
		families << QString::fromLatin1(font.family);
	}
	return families;
}

QStringList serifFamilies()
{
	QStringList families;
	for (const BundledFont &font : serifFonts) {
		families << QString::fromLatin1(font.family);
	}
	return families;
}

QStringList monoFamilies()
{
	QStringList families;
	for (const BundledFont &font : monoFonts) {
		families << QString::fromLatin1(font.family);
	}
	return families;
}

QStringList allFamilies()
{
	return sansFamilies() + serifFamilies() + monoFamilies();
}

QString defaultFamily()
{
	return QStringLiteral("Liberation Sans");
}

bool isBundled(const QString &family)
{
	return isBundledFamily(family);
}

bool isKnownEquivalent(const QString &family)
{
	if (isBundledFamily(family)) {
		return true;
	}
	return aliasTable().contains(family.trimmed().toLower());
}

QString resolveFamily(const QString &family)
{
	if (isBundledFamily(family)) {
		// Return the canonical spelling for the bundled family.
		for (const QString &bundled : allFamilies()) {
			if (family.compare(bundled, Qt::CaseInsensitive) == 0) {
				return bundled;
			}
		}
		return family;
	}
	const auto it = aliasTable().constFind(family.trimmed().toLower());
	if (it != aliasTable().constEnd()) {
		return it.value();
	}
	return defaultFamily();
}

} // namespace BundledFonts
