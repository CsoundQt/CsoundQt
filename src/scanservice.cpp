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

#include "scanservice.h"

#include <QFileInfo>

#include <utility>
#include <QTimer>

namespace {
// A short pause after the last keystroke: long enough to coalesce typing,
// short enough that the highlighting and the inspector feel immediate.
constexpr int DEFAULT_DEBOUNCE_MS = 250;

// How often the files behind the includes are checked for changes. This only
// stats them; a scan only runs when one of them actually changed.
constexpr int DEFAULT_DEPENDENCY_CHECK_MS = 2000;
}

ScanService::ScanService(QObject *parent)
	: QObject(parent)
{
	m_debounce = new QTimer(this);
	m_debounce->setSingleShot(true);
	m_debounce->setInterval(DEFAULT_DEBOUNCE_MS);
	connect(m_debounce, &QTimer::timeout, this, &ScanService::scanActive);

	m_dependencyTimer = new QTimer(this);
	m_dependencyTimer->setInterval(DEFAULT_DEPENDENCY_CHECK_MS);
	connect(m_dependencyTimer, &QTimer::timeout, this, &ScanService::checkDependencies);
}


void ScanService::setActiveSource(CodeScan::Source *source)
{
	if (m_active == source)
		return;
	m_active = source;
	// A pending scan belongs to the document that was being edited before.
	m_debounce->stop();
}


void ScanService::sourceChanged(CodeScan::Source *source)
{
	if (source == nullptr)
		return;
	m_sources[source].dirty = true;
	// The document being edited is the one that changes at typing speed; the
	// others are rescanned when they are activated, not from here.
	if (source == m_active)
		m_debounce->start();
}


void ScanService::scanNow(CodeScan::Source *source)
{
	if (source == nullptr)
		return;
	const auto it = m_sources.constFind(source);
	if (it == m_sources.constEnd() || it->dirty) {
		scan(source);
	}
	else {
		emit scanned(source, it->result);
	}
}


void ScanService::forget(CodeScan::Source *source)
{
	m_sources.remove(source);
	if (m_active == source) {
		m_active = nullptr;
		m_debounce->stop();
	}
	updateDependencyTimer();
}


CodeScan::ResultPtr ScanService::result(CodeScan::Source *source) const
{
	const auto it = m_sources.constFind(source);
	if (it == m_sources.constEnd())
		return CodeScan::empty();
	return it->result;
}


bool ScanService::isDirty(CodeScan::Source *source) const
{
	const auto it = m_sources.constFind(source);
	if (it == m_sources.constEnd())
		return true;
	return it->dirty;
}


QString ScanService::resolveInclude(const QString &spec,
                                    const QString &includingFile,
                                    const QStringList &searchPaths) const
{
	// Both #include "file" and #include <file> use the same search path in
	// Csound, so the angled flag does not matter here.
	return m_includes.resolvePath(spec, includingFile, false, searchPaths);
}


void ScanService::setDebounceInterval(int ms)
{
	m_debounce->setInterval(ms);
}


int ScanService::debounceInterval() const
{
	return m_debounce->interval();
}


void ScanService::scanActive()
{
	if (m_active == nullptr || !isDirty(m_active))
		return;
	scan(m_active);
}


void ScanService::setDependencyCheckInterval(int ms)
{
	m_dependencyTimer->setInterval(ms);
}


int ScanService::dependencyCheckInterval() const
{
	return m_dependencyTimer->interval();
}


bool ScanService::checkDependencies()
{
	QList<CodeScan::Source *> changedSources;
	for (auto it = m_sources.begin(); it != m_sources.end(); ++it) {
		State &state = it.value();
		bool changed = false;
		for (CodeScan::Dependency &dependency : state.dependencies) {
			const QFileInfo info(dependency.path);
			// A file that disappeared has an invalid stamp: that is a change
			// too, and the scan will report the include as missing.
			const qint64 lastModified = info.lastModified().toMSecsSinceEpoch();
			const qint64 size = info.size();
			if (lastModified == dependency.lastModified && size == dependency.size)
				continue;
			dependency.lastModified = lastModified;
			dependency.size = size;
			changed = true;
		}
		if (changed)
			changedSources.append(it.key());
	}
	// Outside the iteration, so that a change is handled with the same policy
	// as a text change: the active document rescans after the debounce, a
	// background one when it is shown again.
	for (CodeScan::Source *source : std::as_const(changedSources))
		sourceChanged(source);
	return !changedSources.isEmpty();
}


void ScanService::reloadDependencies()
{
	m_includes.clear();
	const QList<CodeScan::Source *> sources = m_sources.keys();
	for (CodeScan::Source *source : sources) {
		m_sources[source].dirty = true;
		scan(source);
	}
}


void ScanService::updateDependencyTimer()
{
	bool haveDependencies = false;
	for (const State &state : std::as_const(m_sources)) {
		if (!state.dependencies.isEmpty()) {
			haveDependencies = true;
			break;
		}
	}
	if (haveDependencies && !m_dependencyTimer->isActive())
		m_dependencyTimer->start();
	else if (!haveDependencies && m_dependencyTimer->isActive())
		m_dependencyTimer->stop();
}


void ScanService::scan(CodeScan::Source *source)
{
	State &state = m_sources[source];
	state.mode = source->scanMode();
	// Included files are looked for in the document's own include paths: the
	// configured INCDIR plus its --env:INCDIR options.
	m_includes.setSearchPaths(source->includeSearchPaths());
	// Documents that are not Csound source still get a result, an empty one,
	// so the views are cleared rather than left with the previous document.
	const CodeScan::ResultPtr scan = state.mode == CodeScan::Mode::None
			? CodeScan::empty()
			: CodeScan::scanPtr(source->scanText(), state.mode, &m_includes,
			                    source->scanFilePath());
	state.result = scan;
	state.dirty = false;
	state.dependencies = scan->dependencies;
	updateDependencyTimer();

	source->applyScan(scan);
	emit scanned(source, scan);
}
