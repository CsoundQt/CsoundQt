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

#ifndef NOTIFICATION_H
#define NOTIFICATION_H

#include <QString>

class QWidget;

// Small, non-modal, self-dismissing notifications (banners) used instead of
// intrusive message boxes for purely informational messages.
namespace Notification {

// Shows a banner over the top-level window of `context` for `durationMs`
// milliseconds. Only one banner is shown at a time; a new one replaces the
// previous one. If `context` is not on screen yet (e.g. a widget layout that is
// still a hidden top-level before being added to the panel), the banner is
// anchored to the active window instead of forcing `context` visible, and is
// deferred until some suitable window is available. Does nothing if `context`
// is null. Set `richText` when `text` is HTML (e.g. to make part of it bold);
// otherwise `text` is shown literally.
void showTransient(QWidget *context, const QString &text, int durationMs = 6000,
				   bool richText = false);

} // namespace Notification

#endif // NOTIFICATION_H
