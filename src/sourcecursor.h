/*
	Copyright (C) 2026 CsoundQt contributors
	This file is part of CsoundQt.
	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.
*/

#ifndef SOURCECURSOR_H
#define SOURCECURSOR_H

#include <QHash>
#include <QString>
#include <QStringList>
#include <QTextCursor>

// What the cursor is pointing at, for the "Go to Source" action.
//
// Only the Csound identifier under the cursor is of interest: the action
// jumps to the definition of the name the cursor is on, not of the selection.
class SourceCursor
{
public:
    // The Csound identifier at the cursor, or an empty string when the cursor
    // is not on one. A quoted name is returned without the quotes, so that
    // schedule "MyInstr" gives MyInstr.
    static QString identifierAt(const QTextCursor &cursor);

    // True when the cursor is on the first argument of a schedule() or
    // schedulek() call, in either the usual syntax (schedule(MyInstr, ...)) or
    // the legacy one (schedule MyInstr, ...). A variable as the first
    // argument (schedule Sinstr) is a name as far as this test is concerned;
    // whether it names an instrument is decided by the caller.
    static bool isScheduleArgument(const QTextCursor &cursor);

    // The file name of an #include directive when the cursor is anywhere
    // between its delimiters, #include "file" or #include <file>. Empty when
    // the cursor is not inside an include path. The result is the text as
    // written (without the delimiters), not a resolved path.
    static QString includePathAt(const QTextCursor &cursor);
};

#endif // SOURCECURSOR_H
