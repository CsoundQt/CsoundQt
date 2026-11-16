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

#ifndef THEMEDICONS_H
#define THEMEDICONS_H

#include <QIcon>
#include <QString>

// Icons for actions that may end up in the desktop's global menu (KDE Plasma's
// "Global Menu" widget in a panel, for instance).
//
// Qt exports global menus to the shell over D-Bus (the "dbusmenu" protocol).
// The shell resolves an icon name in its own icon theme, which follows the
// desktop palette; an icon without a name is instead sent as rasterized pixels
// rendered with CsoundQt's palette. That can make menu icons unreadable when
// the application's theme differs from the desktop's.
//
// forMenu() therefore returns an icon whose engine reports the matching
// freedesktop name to global-menu exporters, while continuing to paint the
// bundled application-themed pixels in CsoundQt's own menus and toolbars.
namespace ThemedIcons {

// Resolve a bundled theme icon path to the SVG file that should be loaded. The
// icon set is vector-only; a path like ".../media-play.png" is mapped to
// ".../media-play.svg" (a path without an extension gets ".svg" appended).
// Returns `resourcePath` unchanged when the SVG does not exist.
QString resolvePath(const QString &resourcePath);

// QIcon for a bundled theme icon, loaded from resolvePath().
QIcon icon(const QString &resourcePath);

// Returns `resourcePath` (e.g. ":/themes/breeze-dark/media-play.svg") as an
// icon that also carries the freedesktop name matching the file name, so the
// desktop shell can resolve it in its own theme. Returns a plain icon when
// there is no known name for the file or the resource does not exist.
QIcon forMenu(const QString &resourcePath);

// The freedesktop icon name for a CsoundQt icon file name (e.g. "media-play.svg"
// -> "media-playback-start"), or an empty string if there is no equivalent.
QString freedesktopName(const QString &fileName);

} // namespace ThemedIcons

#endif // THEMEDICONS_H
