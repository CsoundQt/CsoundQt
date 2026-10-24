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

#ifndef INCLUDECACHE_H
#define INCLUDECACHE_H

#include <QHash>
#include <QStringList>

#include "codescan.h"

// Reads the files pulled in by #include directives and remembers their text,
// so that scanning on every pause in typing does not read the same included
// files over and over.
//
// A cached text is used only while the file still has the modification time
// and size it had when it was read: the cache never serves a stale file.
class IncludeCache : public CodeScan::IncludeProvider
{
public:
	// Directories searched for an include whose name is not relative to the
	// including file. The working directory is always tried last.
	void setSearchPaths(const QStringList &paths) { m_searchPaths = paths; }
	QStringList searchPaths() const { return m_searchPaths; }

	// Splits a Csound search path list into its directories. Csound accepts
	// both ':' and ';' as separators, except that a colon in a Windows drive
	// name ("C:\...") is not a separator.
	static QStringList splitPathList(const QString &value);

	// The include directories of a <CsOptions> section: --env:INCDIR=... and
	// --env:INCDIR+=... are applied in order to basePaths (the directories
	// from the application settings). Other sources of INCDIR, such as the
	// process environment or .csound7rc, are deliberately not consulted.
	static QStringList includePathsFromOptions(const QString &optionsText,
	                                           const QStringList &basePaths);

	// The file the include resolves to, or an empty string.
	QString resolvePath(const QString &spec, const QString &includingFile,
	                    bool angled) const;
	// Same, searching the given directories instead of the cache's own list.
	QString resolvePath(const QString &spec, const QString &includingFile,
	                    bool angled, const QStringList &searchPaths) const;

	CodeScan::IncludeFile include(const QString &spec, const QString &includingFile,
	                              bool angled) override;

	// Forget every cached text: the next scan reads the files again.
	void clear() { m_cache.clear(); }
	int cachedFileCount() const { return m_cache.size(); }

private:
	struct Entry
	{
		QString text;
		qint64 lastModified = 0;
		qint64 size = 0;
	};

	QHash<QString, Entry> m_cache; // by canonical path
	QStringList m_searchPaths;
};

#endif // INCLUDECACHE_H
