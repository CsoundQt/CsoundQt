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
// Qt exports such menus to the shell over D-Bus (the "dbusmenu" protocol). For
// every item it sends either an icon *name* or, when the QIcon has no name, a
// rasterized PNG of the icon (see QDBusMenuItem in the Qt sources). CsoundQt's
// icons are built from bundled resource files, so they have no name: their
// pixels - rendered with CsoundQt's own theme - are handed to the shell and
// drawn on the shell's background. If CsoundQt is set to a dark theme while the
// desktop is light (or the other way round) the two no longer match and the
// menu icons become unreadable.
//
// These helpers wrap a bundled icon in a QIconEngine that reports a freedesktop
// icon name, so Qt sends only the name and the shell resolves it in *its* icon
// theme. Inside the application the bundled pixels are painted unchanged, so
// toolbars keep CsoundQt's own artwork and follow its theme setting.
namespace ThemedIcons {

// Returns `resourcePath` (e.g. ":/themes/breeze-dark/media-play.png") as an
// icon that also carries the freedesktop name matching the file name, so the
// desktop shell can resolve it in its own theme. Returns a plain icon when
// there is no known name for the file or the resource does not exist.
QIcon forMenu(const QString &resourcePath);

// The freedesktop icon name for a CsoundQt icon file name (e.g. "media-play.png"
// -> "media-playback-start"), or an empty string if there is no equivalent.
QString freedesktopName(const QString &fileName);

} // namespace ThemedIcons

#endif // THEMEDICONS_H
