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

#include "searchindex.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QRegularExpression>
#include <QSet>
#include <QDebug>
#include <algorithm>

static QString stripHtml(const QString &html)
{
    QString out;
    out.reserve(html.size());
    bool inTag = false;
    const int n = html.size();
    const QChar *d = html.constData();
    for (int i = 0; i < n; ++i)
    {
        QChar c = d[i];
        if (c == '<')
        {
            inTag = true;
            continue;
        }
        if (c == '>')
        {
            inTag = false;
            continue;
        }
        if (!inTag)
            out.append(c);
    }
    out.replace(QStringLiteral("&amp;"), "&").replace(QStringLiteral("&lt;"), "<")
        .replace(QStringLiteral("&gt;"), ">").replace(QStringLiteral("&nbsp;"), " ")
        .replace(QStringLiteral("&#39;"), "'").replace(QStringLiteral("&quot;"), "\"");
    return out;
}

void SearchIndexManager::tokenize(const QString &s, QStringList &out) const
{
    QString tok;
    const int n = s.size();
    const QChar *d = s.constData();
    for (int i = 0; i <= n; ++i)
    {
        QChar c = (i < n) ? d[i].toLower() : QChar();
        if (c.isLetterOrNumber())
            tok.append(c);
        else
        {
            if (tok.size() >= 2)
                out.append(tok);
            tok.clear();
        }
    }
}

void SearchIndexManager::addRoot(const QString &rootPath, const QString &label)
{
    Root r;
    r.root = rootPath;
    r.label = label;
    r.indexFile = rootPath + "/search/search_index.json";
    m_roots.append(r);
}

void SearchIndexManager::loadRoot(Root &r)
{
    if (r.loaded)
        return;
    QFile f(r.indexFile);
    if (!f.open(QIODevice::ReadOnly))
    {
        qWarning() << "cannot open index:" << r.indexFile;
        return;
    }
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll(), &err);
    if (err.error != QJsonParseError::NoError)
    {
        qWarning() << "index parse error:" << err.errorString();
        return;
    }
    QJsonArray arr = doc.object().value("docs").toArray();
    r.docs.reserve(arr.size());
    for (int i = 0; i < arr.size(); ++i)
    {
        QJsonObject o = arr.at(i).toObject();
        QString title = o.value("title").toString();
        QString loc   = o.value("location").toString();
        QString plain = stripHtml(o.value("text").toString());
        r.docs.append({title, loc, plain});

        QStringList tt;
        tokenize(title, tt);
        QStringList xt;
        tokenize(plain, xt);
        QHash<QString, bool> seen;
        for (const QString &t : tt)
        {
            if (seen.contains(t))
                continue;
            seen.insert(t, true);
            r.titlePostings[t].append(i);
        }
        for (const QString &t : xt)
        {
            if (seen.contains(t))
                continue;
            seen.insert(t, true);
            r.textPostings[t].append(i);
        }
    }
    r.loaded = true;
    qDebug() << "loaded index" << r.label << "docs:" << r.docs.size()
             << "terms:" << r.titlePostings.size() << "/" << r.textPostings.size();
}

bool SearchIndexManager::ensureLoaded()
{
    bool any = false;
    for (Root &r : m_roots)
    {
        if (!r.loaded)
            loadRoot(r);
        if (r.loaded)
            any = true;
    }
    return any;
}

static bool isStopWord(const QString &t)
{
    static const QSet<QString> stops = {
        "the", "and", "for", "are", "was", "has", "had", "with", "that", "this",
        "from", "your", "you", "will", "its", "also", "can", "any", "all", "not",
        "but", "into", "than", "then", "them", "they", "their", "there", "these",
        "those", "which", "when", "where", "what", "how", "why", "who", "whom",
        "about", "more", "most", "some", "such", "other", "over", "under", "only",
        "one", "two", "first", "last", "using", "used", "use", "used", "via", "etc"
    };
    return stops.contains(t);
}

QList<SearchResult> SearchIndexManager::search(const QString &query, bool includePrefix) const
{
    QList<SearchResult> results;
    QStringList terms;
    tokenize(query, terms);
    if (terms.isEmpty())
        return results;

    for (int ri = 0; ri < m_roots.size(); ++ri)
    {
        const Root &r = m_roots.at(ri);
        if (!r.loaded || r.docs.isEmpty())
            continue;

        QHash<int, double> scores;
        const QString      needle = query.trimmed().toLower();
        for (const QString &term : terms)
        {
            if (isStopWord(term))
                continue;
            auto it = r.titlePostings.find(term);
            if (it != r.titlePostings.end())
                for (int doc : it.value())
                    scores[doc] += 1000.0;
            it = r.textPostings.find(term);
            if (it != r.textPostings.end())
                for (int doc : it.value())
                    scores[doc] += 1.0;

            if (includePrefix)
            {
                // Partial-word matches at reduced weight, e.g. "perli" -> "perlin".
                for (auto pit = r.titlePostings.constBegin(); pit != r.titlePostings.constEnd(); ++pit)
                {
                    const QString &k = pit.key();
                    if (k != term && k.startsWith(term))
                        for (int doc : pit.value())
                            scores[doc] += 300.0;
                }
                for (auto pit = r.textPostings.constBegin(); pit != r.textPostings.constEnd(); ++pit)
                {
                    const QString &k = pit.key();
                    if (k != term && k.startsWith(term))
                        for (int doc : pit.value())
                            scores[doc] += 0.3;
                }
            }
        }
        // Pages whose whole title matches the search string rank highest.
        if (!needle.isEmpty())
            for (int doc = 0; doc < r.docs.size(); ++doc)
                if (r.docs.at(doc).title.toLower() == needle)
                    scores[doc] += 10000.0;
        if (scores.isEmpty())
            continue;

        QVector<int> docIds;
        docIds.reserve(scores.size());
        for (auto it = scores.constBegin(); it != scores.constEnd(); ++it)
            docIds.append(it.key());
        std::sort(docIds.begin(), docIds.end(), [&](int a, int b) {
            return scores.value(a) > scores.value(b);
        });

        int shown = 0;
        QSet<QString> seenPages; // one match per page: keep the best-ranked entry
        for (int doc : docIds)
        {
            if (shown >= 20)
                break;
            const QString pageKey = r.docs.at(doc).location.section('#', 0, 0);
            if (seenPages.contains(pageKey))
                continue;
            seenPages.insert(pageKey);
            SearchResult res;
            res.rootIndex = ri;
            res.title     = r.docs.at(doc).title;
            res.location  = r.docs.at(doc).location;
            res.score     = scores.value(doc);
            // Find the page-level entry (location without fragment) to show
            // where the match comes from; fall back to the entry title.
            res.pageTitle = res.title;
            if (res.location.contains('#'))
                for (const auto &d : r.docs)
                    if (d.location == pageKey)
                    {
                        res.pageTitle = d.title;
                        break;
                    }
            // snippet around first query-term occurrence
            const QString &plain = r.docs.at(doc).plain;
            int pos = -1;
            for (const QString &term : terms)
            {
                pos = plain.indexOf(term, 0, Qt::CaseInsensitive);
                if (pos >= 0)
                    break;
            }
            if (pos >= 0)
            {
                int start = qMax(0, pos - 60);
                int len   = qMin(plain.size() - start, 140);
                res.snippet = (start > 0 ? "…" : "") + plain.mid(start, len).simplified() + "…";
            }
            results.append(res);
            shown++;
        }
    }

    std::sort(results.begin(), results.end(),
              [](const SearchResult &a, const SearchResult &b) { return a.score > b.score; });
    if (results.size() > 30)
        results.resize(30);
    return results;
}

QString SearchIndexManager::resolvePath(const SearchResult &r) const
{
    if (r.rootIndex < 0 || r.rootIndex >= m_roots.size())
        return QString();
    return m_roots.at(r.rootIndex).root + "/" + r.location;
}
