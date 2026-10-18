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
		{ QStringLiteral("edit-new"),      QStringLiteral("document-new") },
		{ QStringLiteral("folder"),        QStringLiteral("document-open") },
		{ QStringLiteral("reload"),        QStringLiteral("view-refresh") },
		{ QStringLiteral("floppy"),        QStringLiteral("document-save") },
		{ QStringLiteral("edit-close"),    QStringLiteral("window-close") },
		{ QStringLiteral("browse-prev"),   QStringLiteral("go-previous") },
		{ QStringLiteral("br_prev"),       QStringLiteral("go-previous") },
		{ QStringLiteral("browse-next"),   QStringLiteral("go-next") },
		{ QStringLiteral("br_next"),       QStringLiteral("go-next") },
		{ QStringLiteral("media-play"),    QStringLiteral("media-playback-start") },
		{ QStringLiteral("media-pause"),   QStringLiteral("media-playback-pause") },
		{ QStringLiteral("media-stop"),    QStringLiteral("media-playback-stop") },
		{ QStringLiteral("terminal"),      QStringLiteral("utilities-terminal") },
		{ QStringLiteral("render"),        QStringLiteral("document-export") },
		{ QStringLiteral("scratchpad"),    QStringLiteral("document-edit") },
		{ QStringLiteral("playfile"),      QStringLiteral("audio-x-generic") },
		{ QStringLiteral("editfile"),      QStringLiteral("document-edit") },
		{ QStringLiteral("widgets"),       QStringLiteral("view-grid") },
		{ QStringLiteral("editor"),        QStringLiteral("accessories-text-editor") },
		{ QStringLiteral("devel"),         QStringLiteral("applications-utilities") },
		{ QStringLiteral("midi-keyboard"), QStringLiteral("input-keyboard") },
		{ QStringLiteral("info"),          QStringLiteral("dialog-information") },
		{ QStringLiteral("settings"),      QStringLiteral("configure") },
		{ QStringLiteral("home"),          QStringLiteral("go-home") },
		{ QStringLiteral("about"),         QStringLiteral("help-about") },
		{ QStringLiteral("note"),          QStringLiteral("audio-x-generic") },
		{ QStringLiteral("hearing"),       QStringLiteral("audio-volume-high") },
	};
	return map;
}

// Bundled icons that are already stored under a valid freedesktop name and can
// be passed through to the shell unchanged.
bool isStandardName(const QString &baseName)
{
	static const QSet<QString> names = {
		QStringLiteral("edit-undo"),
		QStringLiteral("edit-redo"),
		QStringLiteral("edit-cut"),
		QStringLiteral("edit-copy"),
		QStringLiteral("edit-paste"),
		QStringLiteral("edit-find"),
		QStringLiteral("media-record"),
		QStringLiteral("align-horizontal-left"),
		QStringLiteral("align-horizontal-right"),
		QStringLiteral("align-horizontal-center"),
		QStringLiteral("align-vertical-top"),
		QStringLiteral("align-vertical-bottom"),
		QStringLiteral("align-vertical-center"),
		QStringLiteral("object-order-front"),
		QStringLiteral("object-order-back"),
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
