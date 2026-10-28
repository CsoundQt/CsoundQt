/*
    Copyright (C) 2026 CsoundQt contributors

    This file is part of CsoundQt.

    CsoundQt is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation; either version 2.1 of the License, or
    (at your option) any later version.

    CsoundQt is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Lesser General Public License for more details.
*/

#ifndef MARKDOWN_H
#define MARKDOWN_H

#include <QString>

// A small, deliberately limited Markdown renderer for UDO docstrings. The
// source text is treated as literal text: HTML tags in it are escaped and
// never passed through. Supported:
//
//   # headings (levels 1 to 6)
//   * unordered lists (also - and +), including nested lists
//   **bold**, *italic*, _italic_
//   `inline code`
//   ``` fenced code blocks ```
//
// A single newline inside a paragraph is kept as a line break, so docstrings
// written as indented plain text keep their layout.
namespace Markdown {

// headingOffset shifts every heading level, so a docstring embedded in a page
// whose title is already an h1 starts with h2. Levels are clamped to h6.
QString toHtml(const QString &markdown, int headingOffset = 0);

} // namespace Markdown

#endif // MARKDOWN_H
