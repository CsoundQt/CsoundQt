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

#include "bracketmatcher.h"
#include "highlighter.h"

#include <QVector>

namespace {

// The per-block bracket index built by the highlighter. Blocks that have not
// been highlighted yet have none; they simply contribute no brackets.
const TextBlockData *blockData(const QTextBlock &block)
{
    return static_cast<const TextBlockData *>(block.userData());
}

bool isOpening(char bracket)
{
    return bracket == '(' || bracket == '[' || bracket == '{';
}

bool isClosing(char bracket)
{
    return bracket == ')' || bracket == ']' || bracket == '}';
}

// The bracket that closes the given one, and the other way round.
char closingFor(char opening)
{
    switch (opening) {
    case '(': return ')';
    case '[': return ']';
    case '{': return '}';
    default: return 0;
    }
}

char openingFor(char closing)
{
    switch (closing) {
    case ')': return '(';
    case ']': return '[';
    case '}': return '{';
    default: return 0;
    }
}

} // namespace

void BracketMatcher::setDocument(QTextDocument *document)
{
    if (m_document == document)
        return;
    clear();
    m_document = document;
}

void BracketMatcher::updateForCursor(const QTextCursor &cursor)
{
    if (!m_document || cursor.document() != m_document) {
        clear();
        return;
    }

    const QTextBlock block = cursor.block();
    const TextBlockData *data = blockData(block);
    if (!data) {
        clear();
        return;
    }

    // The cursor sits between two characters: a bracket is "next to" it when
    // the cursor is just before an opening or just after a closing one.
    const int offset = cursor.position() - block.position();
    const QVector<BracketInfo> &infos = data->brackets();
    int bracketIndex = -1;
    bool forward = false;
    for (int i = 0; i < infos.size(); ++i) {
        if (infos.at(i).position == offset && isOpening(infos.at(i).character)) {
            bracketIndex = i;
            forward = true;
            break;
        }
        if (infos.at(i).position == offset - 1 && isClosing(infos.at(i).character)) {
            bracketIndex = i;
            forward = false;
            break;
        }
    }

    if (bracketIndex < 0) {
        clear();
        return;
    }

    const int partner = findPartner(block, bracketIndex, forward);
    if (partner < 0) {
        // An unmatched bracket is left alone: the missing mark is the signal.
        clear();
        return;
    }

    const int bracket = block.position() + infos.at(bracketIndex).position;
    if (forward)
        setPair(bracket, partner);
    else
        setPair(partner, bracket);
}

int BracketMatcher::findPartner(const QTextBlock &block, int bracketIndex, bool forward) const
{
    const TextBlockData *startData = blockData(block);
    if (!startData)
        return -1;
    const QVector<BracketInfo> &startInfos = startData->brackets();
    const char start = startInfos.at(bracketIndex).character;

    // The stack of brackets that still have to be closed (when scanning
    // forward) or opened (when scanning backward). It makes the kinds match
    // up: in "([)]" the parenthesis is not closed by the bracket that follows.
    QVector<char> expected;
    expected.append(forward ? closingFor(start) : openingFor(start));

    QTextBlock current = block;
    while (current.isValid()) {
        const TextBlockData *data = blockData(current);
        if (data) {
            const QVector<BracketInfo> &infos = data->brackets();
            // Later blocks are entered from their edge.
            const int direction = forward ? 1 : -1;
            int index = (current == block) ? bracketIndex + direction
                                           : (forward ? 0 : infos.size() - 1);
            for (; index >= 0 && index < infos.size(); index += direction) {
                const char c = infos.at(index).character;
                if (forward ? isOpening(c) : isClosing(c)) {
                    expected.append(forward ? closingFor(c) : openingFor(c));
                    continue;
                }
                // A bracket of another kind closes something else: the pair is
                // broken, so there is no partner.
                if (expected.isEmpty() || expected.last() != c)
                    return -1;
                expected.removeLast();
                if (expected.isEmpty())
                    return current.position() + infos.at(index).position;
            }
        }
        current = forward ? current.next() : current.previous();
    }
    return -1;
}

void BracketMatcher::setPair(int first, int second)
{
    m_first = first;
    m_second = second;
}

void BracketMatcher::clear()
{
    setPair(-1, -1);
}
