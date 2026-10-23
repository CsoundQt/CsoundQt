/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#ifndef BRACKETMATCHER_H
#define BRACKETMATCHER_H

#include <QTextBlock>
#include <QTextCursor>
#include <QTextDocument>

// Finds the bracket that pairs with the one next to the cursor. DocumentView
// reads first()/second() and applies the background extra selections.
//
// The matcher owns the document its positions belong to, so a pair found in one
// document can never be marked in another one. The kinds (), [] and {} are
// matched; a bracket of a different kind
// closing a bracket breaks the pair. Brackets inside comments and strings are
// not part of the index, so they never match.
class BracketMatcher
{
public:
    BracketMatcher() = default;

    // The document whose blocks are searched. A null document disables matching.
    void setDocument(QTextDocument *document);
    QTextDocument *document() const { return m_document; }

    // Recomputes the pair for the given cursor and updates the mark. A cursor
    // from another document just clears the mark.
    void updateForCursor(const QTextCursor &cursor);

    // Removes the mark, e.g. before the document is replaced.
    void clear();

    // Positions of the marked pair in document(); -1 when nothing is marked.
    int first() const { return m_first; }
    int second() const { return m_second; }

private:
    // Finds the partner of the bracket at bracketIndex in block, scanning one
    // block at a time in the given direction. Returns its document position or
    // -1. Iterative, so an unmatched bracket in a long file cannot turn the
    // number of blocks into stack depth.
    int findPartner(const QTextBlock &block, int bracketIndex, bool forward) const;
    void setPair(int first, int second);

    QTextDocument *m_document = nullptr;
    int m_first = -1;
    int m_second = -1;
};

#endif // BRACKETMATCHER_H
