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

#ifndef SCANSERVICE_H
#define SCANSERVICE_H

#include <QHash>
#include <QObject>

#include "codescan.h"
#include "includecache.h"

class QTimer;

// The one place that decides when a document is scanned, keeps the result and
// hands it out. Nothing else starts a scan.
//
// The document the user is editing is scanned shortly after the typing stops.
// Other documents are stable as far as the editor is concerned, so they are
// scanned when they become current, not while they sit in a background tab.
//
// The service is where parsing tasks are gathered: a future scan can discover
// more work (the files pulled in by #include) and hand it back to the same
// agent instead of starting scans of its own.
class ScanService : public QObject
{
	Q_OBJECT
public:
	explicit ScanService(QObject *parent = nullptr);

	// The document the user is editing. Only this one is scanned on a text
	// change; the others wait until they become active.
	void setActiveSource(CodeScan::Source *source);

	// The text of the source changed.
	void sourceChanged(CodeScan::Source *source);

	// Bring the source up to date: scan it if its text changed since the last
	// scan, apply the result and emit scanned(). A source that is already up
	// to date is not scanned again, but its result is emitted anyway, so a
	// newly active document can be shown without extra work.
	void scanNow(CodeScan::Source *source);

	// Drop the state of a source that is going away.
	void forget(CodeScan::Source *source);

	// The file an #include directive resolves to, with the same search rules
	// as the scan (relative to the including file, then the given include
	// directories and the working directory). Empty when it cannot be found.
	QString resolveInclude(const QString &spec, const QString &includingFile,
	                       const QStringList &searchPaths) const;

	CodeScan::ResultPtr result(CodeScan::Source *source) const;
	bool isDirty(CodeScan::Source *source) const;

	// How often the files a scan depended on are checked for changes.
	void setDependencyCheckInterval(int ms);
	int dependencyCheckInterval() const;

	// Looks at the files the current scans pulled in (their modification time
	// and size) and marks the sources that depend on a changed file as dirty.
	// Returns true when something changed. The timer calls this; it is public
	// so tests and the "reload" action can force the check.
	bool checkDependencies();

	// Forgets the cached included files and rescans every known source, which
	// re-reads the whole dependency tree.
	void reloadDependencies();

	// How long after the last change the active source is scanned.
	void setDebounceInterval(int ms);
	int debounceInterval() const;

signals:
	void scanned(CodeScan::Source *source, const CodeScan::ResultPtr &scan);

private:
	struct State
	{
		CodeScan::ResultPtr result = CodeScan::empty();
		CodeScan::Mode mode = CodeScan::Mode::None;
		bool dirty = true;
		// The included files of the last scan, with the stamps they had then.
		QVector<CodeScan::Dependency> dependencies;
	};

	void scan(CodeScan::Source *source);
	void scanActive();
	void updateDependencyTimer();

	QHash<CodeScan::Source *, State> m_sources;
	IncludeCache m_includes;
	QTimer *m_debounce = nullptr;
	QTimer *m_dependencyTimer = nullptr;
	CodeScan::Source *m_active = nullptr;
};

#endif // SCANSERVICE_H
