/*
    Copyright (C) 2025 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with CsoundQt; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#ifndef DEBUGLOG_H
#define DEBUGLOG_H

#include <QString>

// Mirror of CsoundQt's own qDebug()/qWarning()/... output to a log file.
//
// Qt's default message handler only writes to stderr (and, on Windows, to the
// debugger). When CsoundQt is started from a graphical launcher there is often
// no terminal receiving that output, so this module adds an optional log file
// that survives a crash and can be attached to bug reports.
//
// The handler is installed once, early in main(), and always keeps writing to
// stderr so behaviour without logging enabled is unchanged. Writing to the log
// file is toggled at runtime from Settings > Environment ("Log debug info").
namespace DebugLog {

// Installs the Qt message handler. Call once, before qDebug() is used.
void install();

// Enables or disables writing to the log file. Enabling opens the file in
// append mode and writes a session header; disabling closes it.
void setEnabled(bool enabled);

bool isEnabled();

// Full path of the log file. The location is platform dependent and the
// containing directory may not exist yet:
//   Linux:   $XDG_STATE_HOME/csoundqt/csoundqt.log (~/.local/state/...)
//   macOS:   ~/Library/Logs/CsoundQt/csoundqt.log
//   Windows: %LOCALAPPDATA%\CsoundQt\csoundqt.log
QString filePath();

} // namespace DebugLog

#endif // DEBUGLOG_H
