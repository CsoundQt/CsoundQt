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

#include "includecache.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>

using namespace Qt::StringLiterals;

QStringList IncludeCache::splitPathList(const QString &value)
{
	QStringList paths;
	qsizetype start = 0;
	for (qsizetype i = 0; i <= value.size(); ++i) {
		const bool atEnd = i == value.size();
		if (!atEnd) {
			const QChar c = value.at(i);
			if (c != QLatin1Char(':') && c != QLatin1Char(';'))
				continue;
			// A drive letter colon belongs to the path: C:\foo.
			if (c == QLatin1Char(':') && i == start + 1
			        && value.at(start).isLetter())
				continue;
		}
		const QString path = value.mid(start, i - start).trimmed();
		if (!path.isEmpty())
			paths.append(path);
		start = i + 1;
	}
	return paths;
}


QStringList IncludeCache::includePathsFromOptions(const QString &optionsText,
                                                  const QStringList &basePaths)
{
	// --env:INCDIR=<value> replaces the configured value, --env:INCDIR+=<value>
	// appends to it. The value may be quoted and may be a path list itself.
	static const QRegularExpression optionRx(
	        uR"RX(--env:INCDIR(\+)?=(?:"([^"]*)"|'([^']*)'|(\S+)))RX"_s);

	QStringList paths = basePaths;
	for (const QString &line : optionsText.split(QLatin1Char('\n'))) {
		const QString trimmed = line.trimmed();
		if (trimmed.startsWith(QLatin1Char(';')) || trimmed.startsWith("//"_L1))
			continue; // a commented-out option is not in effect
		for (auto it = optionRx.globalMatch(line); it.hasNext(); ) {
			const QRegularExpressionMatch match = it.next();
			QString value;
			if (match.capturedStart(2) >= 0)
				value = match.captured(2);
			else if (match.capturedStart(3) >= 0)
				value = match.captured(3);
			else
				value = match.captured(4);
			const QStringList directories = splitPathList(value);
			if (match.captured(1) == "+"_L1)
				paths.append(directories);
			else
				paths = directories;
		}
	}
	paths.removeDuplicates();
	return paths;
}


QString IncludeCache::resolvePath(const QString &spec, const QString &includingFile,
                                  bool angled) const
{
	return resolvePath(spec, includingFile, angled, m_searchPaths);
}


QString IncludeCache::resolvePath(const QString &spec, const QString &includingFile,
                                  bool angled, const QStringList &searchPaths) const
{
	if (spec.isEmpty())
		return QString();

	// An absolute name is used as it is.
	const QFileInfo specInfo(spec);
	if (specInfo.isAbsolute())
		return (specInfo.isFile() ? specInfo.canonicalFilePath() : QString());

	// Csound looks next to the file it is reading. The search paths are the
	// directories the application offers (the Csound include path), and the
	// working directory is what Csound itself falls back to. The two flavours
	// of #include are looked up the same way: Csound's preprocessor has one
	// include path list.
	QStringList candidates;
	if (!includingFile.isEmpty())
		candidates.append(QFileInfo(includingFile).absolutePath() + QLatin1Char('/') + spec);
	for (const QString &directory : searchPaths)
		candidates.append(QDir(directory).filePath(spec));
	candidates.append(QDir::current().filePath(spec));

	Q_UNUSED(angled);
	for (const QString &candidate : candidates) {
		const QFileInfo info(candidate);
		if (!info.isFile())
			continue;
		const QString canonical = info.canonicalFilePath();
		if (!canonical.isEmpty())
			return canonical;
	}
	return QString();
}


CodeScan::IncludeFile IncludeCache::include(const QString &spec,
                                            const QString &includingFile,
                                            bool angled)
{
	CodeScan::IncludeFile file;
	const QString path = resolvePath(spec, includingFile, angled);
	if (path.isEmpty())
		return file;

	const QFileInfo info(path);
	const qint64 lastModified = info.lastModified().toMSecsSinceEpoch();
	const qint64 size = info.size();

	const auto cached = m_cache.constFind(path);
	if (cached != m_cache.constEnd()
	        && cached->lastModified == lastModified && cached->size == size) {
		file.path = path;
		file.text = cached->text;
		file.lastModified = lastModified;
		file.size = size;
		return file;
	}

	QFile source(path);
	if (!source.open(QIODevice::ReadOnly))
		return file;
	const QString text = QString::fromUtf8(source.readAll());
	m_cache.insert(path, Entry{text, lastModified, size});

	file.path = path;
	file.text = text;
	file.lastModified = lastModified;
	file.size = size;
	return file;
}
