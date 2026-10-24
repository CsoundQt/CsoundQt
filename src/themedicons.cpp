/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "themedicons.h"

#include <QFileInfo>
#include <QHash>
#include <QIconEngine>
#include <QPaintDevice>
#include <QPainter>
#include <QPixmap>
#include <QSet>
using namespace Qt::StringLiterals;

namespace {

// An icon engine that paints a bundled icon but reports a theme icon name.
// QIcon::name() simply forwards to QIconEngine::iconName(), and that name is
// what the dbusmenu export sends to the desktop shell instead of the pixels.
class NamedPixmapIconEngine : public QIconEngine
{
public:
	NamedPixmapIconEngine(QString themeName, const QIcon &fallback)
		: m_themeName(std::move(themeName)), m_fallback(fallback) {}

	void paint(QPainter *painter, const QRect &rect, QIcon::Mode mode,
			   QIcon::State state) override
	{
		// Same as QIconEngine's default implementation, drawn from our pixmap().
		QSize pixmapSize = rect.size();
		if (painter->device()) {
			pixmapSize *= painter->device()->devicePixelRatio();
		}
		painter->drawPixmap(rect, pixmap(pixmapSize, mode, state));
	}

	QPixmap pixmap(const QSize &size, QIcon::Mode mode, QIcon::State state) override
	{
		return m_fallback.pixmap(size, mode, state);
	}

	QSize actualSize(const QSize &size, QIcon::Mode mode, QIcon::State state) override
	{
		return m_fallback.actualSize(size, mode, state);
	}

	QList<QSize> availableSizes(QIcon::Mode mode = QIcon::Normal,
								QIcon::State state = QIcon::Off) override
	{
		return m_fallback.availableSizes(mode, state);
	}

	void addPixmap(const QPixmap &pixmap, QIcon::Mode mode, QIcon::State state) override
	{
		m_fallback.addPixmap(pixmap, mode, state);
	}

	void addFile(const QString &fileName, const QSize &size, QIcon::Mode mode,
				 QIcon::State state) override
	{
		m_fallback.addFile(fileName, size, mode, state);
	}

	QString iconName() override { return m_themeName; }
	bool isNull() override { return m_fallback.isNull(); }
	QIconEngine *clone() const override { return new NamedPixmapIconEngine(m_themeName, m_fallback); }
	QString key() const override { return m_themeName; }

private:
	QString m_themeName;
	QIcon m_fallback;
};

// CsoundQt icon file name -> freedesktop icon name. Only the icons whose
// bundled name differs from the standard one need an entry here.
const QHash<QString, QString> &iconNameMap()
{
	static const QHash<QString, QString> map = {
		{ u"edit-new"_s,      u"document-new"_s },
		{ u"folder"_s,        u"document-open"_s },
		{ u"reload"_s,        u"view-refresh"_s },
		{ u"floppy"_s,        u"document-save"_s },
		{ u"edit-close"_s,    u"window-close"_s },
		{ u"browse-prev"_s,   u"go-previous"_s },
		{ u"br_prev"_s,       u"go-previous"_s },
		{ u"browse-next"_s,   u"go-next"_s },
		{ u"br_next"_s,       u"go-next"_s },
		{ u"media-play"_s,    u"media-playback-start"_s },
		{ u"media-pause"_s,   u"media-playback-pause"_s },
		{ u"media-stop"_s,    u"media-playback-stop"_s },
		{ u"terminal"_s,      u"utilities-terminal"_s },
		{ u"render"_s,        u"document-export"_s },
		{ u"scratchpad"_s,    u"document-edit"_s },
		{ u"playfile"_s,      u"audio-x-generic"_s },
		{ u"editfile"_s,      u"document-edit"_s },
		{ u"widgets"_s,       u"view-grid"_s },
		{ u"editor"_s,        u"accessories-text-editor"_s },
		{ u"devel"_s,         u"applications-utilities"_s },
		{ u"midi-keyboard"_s, u"audio-midi"_s },
		{ u"info"_s,          u"dialog-information"_s },
		{ u"settings"_s,      u"configure"_s },
		{ u"home"_s,          u"go-home"_s },
		{ u"about"_s,         u"help-about"_s },
		{ u"note"_s,          u"audio-x-generic"_s },
		{ u"hearing"_s,       u"audio-volume-high"_s },
	};
	return map;
}

// Bundled icons that are already stored under a valid freedesktop name and can
// be passed through to the shell unchanged.
bool isStandardName(const QString &baseName)
{
	static const QSet<QString> names = {
		u"edit-undo"_s,
		u"edit-redo"_s,
		u"edit-cut"_s,
		u"edit-copy"_s,
		u"edit-paste"_s,
		u"edit-find"_s,
		u"media-record"_s,
		u"align-horizontal-left"_s,
		u"align-horizontal-right"_s,
		u"align-horizontal-center"_s,
		u"align-vertical-top"_s,
		u"align-vertical-bottom"_s,
		u"align-vertical-center"_s,
		u"object-order-front"_s,
		u"object-order-back"_s,
	};
	return names.contains(baseName);
}

} // namespace

namespace ThemedIcons {

QString freedesktopName(const QString &fileName)
{
	const QString baseName = QFileInfo(fileName).completeBaseName();
	if (baseName.isEmpty()) {
		return QString();
	}
	const auto it = iconNameMap().constFind(baseName);
	if (it != iconNameMap().constEnd()) {
		return it.value();
	}
	return isStandardName(baseName) ? baseName : QString();
}

QIcon forMenu(const QString &resourcePath)
{
	const QIcon bundled(resourcePath);
	const QString name = freedesktopName(resourcePath);
	if (name.isEmpty() || bundled.isNull()) {
		return bundled;
	}
	return QIcon(new NamedPixmapIconEngine(name, bundled));
}

} // namespace ThemedIcons
