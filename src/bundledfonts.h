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

#ifndef BUNDLEDFONTS_H
#define BUNDLEDFONTS_H

#include <QString>
#include <QStringList>

// Fonts bundled with CsoundQt (SIL OFL 1.1), used for the widget panel only.
// The editor/console keep using whatever the user configured from the system.
//
// Widget text is always plain (no bold/italic/rich text), so only the Regular
// face of each family is bundled. Restricting the widget font picker to these
// families and resolving anything else to a bundled family makes a widget GUI
// look the same regardless of the platform and installed fonts.
namespace BundledFonts {

// Registers all bundled fonts with QFontDatabase. Call once, after
// QApplication has been constructed. Returns the number registered.
int registerFonts();

// Bundled families, grouped by category.
QStringList sansFamilies();
QStringList serifFamilies();
QStringList monoFamilies();
QStringList allFamilies();

// Family assigned to anything that is not bundled (Liberation Sans).
QString defaultFamily();

// Family used for dense numeric rulers (VU meter etc.). This is a pixel-style
// monospaced font used at a fixed pixel size rather than for widget text, so it
// is registered but not offered in the widget font picker.
QString rulerFamily();
int rulerPixelSize();

// True if the family is one of the bundled families (case-insensitive).
bool isBundled(const QString &family);

// True if the family is bundled or a known equivalent (e.g. Arial, Times New
// Roman): those are replaced silently. Anything else is "unknown" and the user
// is warned when a file using it is opened.
bool isKnownEquivalent(const QString &family);

// Maps a requested family to a bundled one. Bundled families are returned
// unchanged; known equivalents are aliased; anything else maps to
// defaultFamily().
QString resolveFamily(const QString &family);

} // namespace BundledFonts

#endif // BUNDLEDFONTS_H
