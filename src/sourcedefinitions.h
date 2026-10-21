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

#ifndef SOURCEDEFINITIONS_H
#define SOURCEDEFINITIONS_H

#include <QHash>
#include <QString>
#include <QStringList>
#include <QTextCursor>

// Index of the names that are defined in a piece of Csound source text, so
// that "Go to Source" can jump from a use of a name to the place where it is
// defined.
//
// The following definitions are recognised:
//   - user-defined opcodes:  opcode Foo, S, k
//   - named instruments:     instr Foo
//   - macros:                #define FOO #1#
//   - struct types (Csound 7): struct Foo val0:i
//
// Definitions inside comments and strings are ignored. When a name is defined
// more than once, the last definition wins, as in Csound, where the last
// definition of a name is the valid one.
class SourceDefinitions
{
public:
    enum Kind {
        Udo,          // opcode Foo, ...
        Instrument,   // instr Foo
        Macro,        // #define FOO #1#
        Struct        // struct Foo ...
    };

    struct Definition
    {
        QString name;
        int     line = 0;    // 1-based line number in the scanned text
        int     column = 0;  // 0-based column of the name within that line
        Kind    kind = Udo;
    };

    // Scans the text and replaces the index.
    void scan(const QString &text);

    // The definition of name, or nullptr when the name is not defined here.
    const Definition *find(const QString &name) const;

    // The names of the user-defined opcodes found, used for highlighting.
    QStringList udoNames() const { return m_udoNames; }

    bool isEmpty() const { return m_definitions.isEmpty(); }

private:
    QHash<QString, Definition> m_definitions;
    QStringList m_udoNames;
};

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
};

#endif // SOURCEDEFINITIONS_H
