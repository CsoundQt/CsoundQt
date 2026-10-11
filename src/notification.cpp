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

#include "notification.h"

#include <QApplication>
#include <QGraphicsOpacityEffect>
#include <QLabel>
#include <QPointer>
#include <QPropertyAnimation>
#include <QTimer>
#include <QWidget>

namespace {

// Shows one transient banner at a time. If the context widget is not on screen
// yet (e.g. a widget layout that is still a hidden top-level before it is added
// to the panel), it waits until its window is visible and only then shows the
// banner, so the notification is not lost.
class BannerManager : public QObject
{
public:
	static BannerManager &instance()
	{
		static BannerManager manager;
		return manager;
	}

	void show(QWidget *context, const QString &text, int durationMs, bool richText)
	{
		m_context = context;
		m_text = text;
		m_duration = durationMs;
		m_richText = richText;
		m_waited = 0;
		m_pending = true;
		m_poll.start();
		tryShow();
	}

private:
	BannerManager()
	{
		m_poll.setInterval(150);
		connect(&m_poll, &QTimer::timeout, this, &BannerManager::tryShow);
	}

	void tryShow()
	{
		if (!m_pending) {
			m_poll.stop();
			return;
		}
		if (m_context.isNull()) {
			m_pending = false;
			m_poll.stop();
			return;
		}

		QWidget *context = m_context.data();
		QWidget *top = context->window();

		// Prefer the context's own top-level window (once it has been added to
		// the panel it is the main window). If that is not visible yet, do NOT
		// force it open; anchor the banner to an already visible window instead
		// so a file loaded into a background tab still notifies the user.
		QWidget *anchor = nullptr;
		if (top != nullptr && top->isVisible()) {
			anchor = top;
		} else {
			QWidget *active = QApplication::activeWindow();
			if (active != nullptr && active->isVisible() && active->isWindow()) {
				anchor = active;
			}
		}

		if (anchor != nullptr) {
			m_pending = false;
			m_poll.stop();
			showBanner(anchor, m_text, m_duration);
			return;
		}

		// Do not wait forever: after a while show it anyway (may be off-screen
		// until the document becomes current, but better than dropping it).
		const int maxWaitMs = 30000;
		if (m_waited >= maxWaitMs) {
			m_pending = false;
			m_poll.stop();
			showBanner(top != nullptr ? top : context, m_text, m_duration);
			return;
		}
		m_waited += m_poll.interval();
	}

	void showBanner(QWidget *top, const QString &text, int durationMs)
	{
		if (top == nullptr) {
			return;
		}
		if (m_banner != nullptr) {
			m_banner->close(); // deletes it (WA_DeleteOnClose)
			m_banner = nullptr;
		}

		auto *banner = new QLabel(top);
		m_banner = banner;
		banner->setWordWrap(true);
		banner->setAlignment(Qt::AlignLeft);
		banner->setTextFormat(Qt::RichText);
		// QSS has no line-height, so use rich text for a roomier line spacing.
		QString html = m_richText ? text : text.toHtmlEscaped();
		html.replace(QLatin1Char('\n'), QStringLiteral("<br>"));
		banner->setText(QStringLiteral("<div style=\"line-height:150%;\">%1</div>").arg(html));
		banner->setTextInteractionFlags(Qt::NoTextInteraction);
		// Do not swallow clicks: the banner is purely informational.
		banner->setAttribute(Qt::WA_TransparentForMouseEvents);
		banner->setAttribute(Qt::WA_DeleteOnClose);
		banner->setStyleSheet(QStringLiteral(
			"QLabel {"
			" background-color: rgba(40, 40, 40, 235);"
			" color: #f2f2f2;"
			" border: 1px solid rgba(255, 255, 255, 60);"
			" border-radius: 8px;"
			" padding: 10px 18px;"
			" font-size: 13px;"
			"}"));
		const int margin = 16;
		const int available = qMax(200, top->width() - 2 * margin);
		banner->setMinimumWidth(qMin(360, available));
		banner->setMaximumWidth(qMin(640, available));
		banner->adjustSize();
		const int x = top->width() - banner->width() - margin;
		banner->move(qMax(margin, x), margin);
		banner->show();
		banner->raise();

		QObject::connect(banner, &QObject::destroyed, this, [this]() {
			m_banner = nullptr;
		});

		// Fade out just before closing.
		QTimer::singleShot(qMax(0, durationMs - 400), banner, [banner]() {
			auto *effect = new QGraphicsOpacityEffect; // banner takes ownership
			banner->setGraphicsEffect(effect);
			auto *animation = new QPropertyAnimation(effect, "opacity", banner);
			animation->setDuration(400);
			animation->setStartValue(1.0);
			animation->setEndValue(0.0);
			QObject::connect(animation, &QPropertyAnimation::finished,
							 banner, &QWidget::close);
			animation->start();
		});
	}

	QPointer<QWidget> m_context;
	QPointer<QLabel> m_banner;
	QString m_text;
	int m_duration = 6000;
	int m_waited = 0;
	bool m_pending = false;
	bool m_richText = false;
	QTimer m_poll;
};

} // namespace

namespace Notification {

void showTransient(QWidget *context, const QString &text, int durationMs, bool richText)
{
	if (context == nullptr) {
		return;
	}
	BannerManager::instance().show(context, text, durationMs, richText);
}

} // namespace Notification
