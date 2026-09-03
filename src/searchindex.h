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

#ifndef SEARCHINDEX_H
#define SEARCHINDEX_H

#include <QString>
#include <QStringList>
#include <QHash>
#include <QList>
#include <QVector>

// One searchable result across any root.
struct SearchResult
{
    int     rootIndex = -1;
    QString title;     // title of the matching index entry (may be a section)
    QString pageTitle; // title of the page the match comes from
    QString location;  // relative to the root; may contain "#fragment"
    QString snippet;
    double  score = 0.0;
};

// Loads MkDocs-style search_index.json files (one per manual root), builds a
// small inverted index per root, and searches across all roots in parallel.
// Roots are parsed lazily on the first search and cached for the session.
class SearchIndexManager
{
public:
    struct Root
    {
        QString root;      // absolute path to the site root
        QString label;     // display name in results
        QString indexFile; // root + "/search/search_index.json"
        struct Doc
        {
            QString title;
            QString location;
            QString plain; // tag-stripped text, for snippets
        };
        QVector<Doc> docs;
        QHash<QString, QList<int>> titlePostings; // term -> doc indices
        QHash<QString, QList<int>> textPostings;
        bool loaded = false;
    };

    void addRoot(const QString &rootPath, const QString &label);
    const QList<Root> &roots() const { return m_roots; }

    // Parses/indexes any not-yet-loaded roots (once). Returns false if all
    // roots failed to load.
    bool ensureLoaded();

    // Searches every (loaded) root and merges results by score. When
    // includePrefix is true, partial-word matches ("perli" -> "perlin") are
    // added with a reduced weight; otherwise only exact term matches count.
    QList<SearchResult> search(const QString &query, bool includePrefix = false) const;

    // Absolute file path for a result (fragment kept for scrolling).
    QString resolvePath(const SearchResult &r) const;

private:
    void loadRoot(Root &r);
    void tokenize(const QString &s, QStringList &out) const;

    QList<Root> m_roots;
};

#endif // SEARCHINDEX_H
