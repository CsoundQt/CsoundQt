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
#include <QGraphicsBlurEffect>
#include <QGraphicsOpacityEffect>
#include <QGraphicsPixmapItem>
#include <QGraphicsScene>
#include <QKeyEvent>
#include <QLabel>
#include <QMouseEvent>
#include <QPainter>
#include <QPainterPath>
#include <QPixmap>
#include <QPointer>
#include <QPropertyAnimation>
#include <QTimer>
#include <QWidget>

namespace {

// Blurs an image with QGraphicsBlurEffect (there is no public QImage blur API).
static QImage blurredImage(const QImage &source, int radius)
{
	if (source.isNull() || radius <= 0)
		return source;
	QGraphicsScene scene;
	scene.setSceneRect(0, 0, source.width(), source.height());
	QGraphicsPixmapItem item(QPixmap::fromImage(source));
	QGraphicsBlurEffect blur;
	blur.setBlurRadius(radius);
	item.setGraphicsEffect(&blur);
	scene.addItem(&item);
	QImage result(source.size(), QImage::Format_ARGB32_Premultiplied);
	result.fill(Qt::transparent);
	QPainter painter(&result);
	scene.render(&painter, QRectF(0, 0, source.width(), source.height()),
				 QRectF(0, 0, source.width(), source.height()));
	return result;
}

// The banner itself: paints a frosted (blurred, tinted) rounded background
// behind the rich text provided by the QLabel base class.
class BannerLabel : public QLabel
{
public:
	explicit BannerLabel(QWidget *parent = nullptr) : QLabel(parent) {}

	void setBlurredBackground(const QPixmap &background)
	{
		m_background = background;
		update();
	}

protected:
	void paintEvent(QPaintEvent *event) override
	{
		if (!m_background.isNull()) {
			QPainter painter(this);
			painter.setRenderHint(QPainter::Antialiasing);
			QPainterPath path;
			path.addRoundedRect(rect(), 8, 8);
			painter.setClipPath(path);
			painter.drawPixmap(rect(), m_background);
			painter.fillRect(rect(), QColor(30, 30, 30, 165));
			painter.setClipping(false);
			painter.setPen(QColor(255, 255, 255, 70));
			painter.setBrush(Qt::NoBrush);
			painter.drawRoundedRect(rect().adjusted(0, 0, -1, -1), 8, 8);
		}
		QLabel::paintEvent(event);
	}

private:
	QPixmap m_background;
};

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

	void show(QWidget *context, const QString &text, const QString &title, int durationMs,
			  bool richText, Notification::Horizontal horizontal, Notification::Vertical vertical)
	{
		m_context = context;
		m_text = text;
		m_title = title;
		m_duration = durationMs;
		m_richText = richText;
		m_horizontal = horizontal;
		m_vertical = vertical;
		m_waited = 0;
		m_pending = true;
		m_dismissing = false;
		m_poll.start();
		tryShow();
	}

protected:
	bool eventFilter(QObject *obj, QEvent *event) override
	{
		if (obj == m_banner.data() && event->type() == QEvent::MouseButtonRelease) {
			dismiss();
			return true;
		}
		if (event->type() == QEvent::KeyPress) {
			auto *keyEvent = static_cast<QKeyEvent *>(event);
			if (keyEvent->key() == Qt::Key_Escape
					&& !m_banner.isNull() && m_banner->isVisible()) {
				dismiss();
				return true;
			}
		}
		return QObject::eventFilter(obj, event);
	}

private:
	BannerManager()
	{
		m_poll.setInterval(150);
		connect(&m_poll, &QTimer::timeout, this, &BannerManager::tryShow);
		qApp->installEventFilter(this);
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

		auto *banner = new BannerLabel(top);
		m_banner = banner;
		m_dismissing = false;
		banner->setWordWrap(true);
		banner->setAlignment(Qt::AlignLeft);
		banner->setTextFormat(Qt::RichText);
		// QSS has no line-height, so use rich text for a roomier line spacing.
		QString html;
		if (!m_title.isEmpty()) {
			QString title = m_title.toHtmlEscaped();
			title.replace(QLatin1Char('\n'), QStringLiteral("<br>"));
			html += QStringLiteral("<div style=\"font-size:16px; font-weight:bold; "
								   "line-height:140%;\">%1</div>").arg(title);
		}
		QString body = m_richText ? text : text.toHtmlEscaped();
		body.replace(QLatin1Char('\n'), QStringLiteral("<br>"));
		html += QStringLiteral("<div style=\"line-height:150%;%1\">%2</div>")
				.arg(m_title.isEmpty() ? QString() : QStringLiteral("margin-top:4px;"), body);
		banner->setText(html);
		banner->setTextInteractionFlags(Qt::NoTextInteraction);
		banner->setCursor(Qt::PointingHandCursor);
		banner->setAttribute(Qt::WA_DeleteOnClose);
		banner->installEventFilter(this);
		banner->setStyleSheet(QStringLiteral(
			"QLabel {"
			" color: #f2f2f2;"
			" padding: 14px 18px;"
			" font-size: 13px;"
			"}"));
		const int margin = 16;
		const int MINWIDTH = 200;
		const int MAXWIDTH = 480;
		const int available = qMax(MINWIDTH, top->width() - 2 * margin);
		const int cap = qMin(MAXWIDTH, available);
		// Single-line bubble when there is no explicit line break and the
		// content fits: measure unconstrained (includes stylesheet padding)
		// and shrink the bubble to the text. Otherwise fix the width and
		// wrap by words.
		bool hasNewline = m_text.contains(QLatin1Char('\n'))
			|| m_title.contains(QLatin1Char('\n'));
		if (m_richText && !hasNewline) {
			const QString lower = m_text.toLower() + m_title.toLower();
			hasNewline = lower.contains(QStringLiteral("<br"))
				|| lower.contains(QStringLiteral("<p"))
				|| lower.contains(QStringLiteral("<div"));
		}
		banner->setWordWrap(false);
		banner->setMinimumWidth(0);
		banner->setMaximumWidth(QWIDGETSIZE_MAX);
		banner->adjustSize();
		const int singleWidth = banner->width();
		if (!hasNewline && singleWidth <= cap) {
			const int w = qBound(MINWIDTH, singleWidth, cap);
			banner->setWordWrap(false);
			banner->setMinimumWidth(w);
			banner->setMaximumWidth(w);
			banner->resize(w, banner->height());
		} else {
			banner->setWordWrap(true);
			banner->setMinimumWidth(cap);
			banner->setMaximumWidth(cap);
			banner->adjustSize();
		}
		int x;
		switch (m_horizontal) {
		case Notification::Horizontal::Left:
			x = margin;
			break;
		case Notification::Horizontal::Center:
			x = (top->width() - banner->width()) / 2;
			break;
		case Notification::Horizontal::Right:
		default:
			x = top->width() - banner->width() - margin;
			break;
		}
		int y;
		switch (m_vertical) {
		case Notification::Vertical::Top:
			y = margin;
			break;
		case Notification::Vertical::Center:
			y = (top->height() - banner->height()) / 2;
			break;
		case Notification::Vertical::Bottom:
		default:
			y = top->height() - banner->height() - margin;
			break;
		}
		const int posX = qMax(margin, x);
		const int posY = qMax(margin, y);
		banner->move(posX, posY);
		// Frosted background: snapshot the window region the banner will cover,
		// blur it, and paint it behind the text. Grabbing before show() ensures
		// the banner itself is not part of the snapshot.
		const QPixmap snapshot = top->grab(QRect(posX, posY, banner->width(), banner->height()));
		if (!snapshot.isNull()) {
			QPixmap background = QPixmap::fromImage(blurredImage(snapshot.toImage(), 14));
			background.setDevicePixelRatio(snapshot.devicePixelRatio());
			banner->setBlurredBackground(background);
		}
		banner->show();
		banner->raise();

		QObject::connect(banner, &QObject::destroyed, this, [this]() {
			m_banner = nullptr;
		});

		QTimer::singleShot(qMax(0, durationMs - 400), banner, [this]() {
			dismiss();
		});
	}

	// Starts the fade-out animation. Called on timeout, click or Escape.
	void dismiss()
	{
		BannerLabel *banner = m_banner.data();
		if (banner == nullptr || m_dismissing) {
			return;
		}
		m_dismissing = true;
		auto *effect = new QGraphicsOpacityEffect; // banner takes ownership
		banner->setGraphicsEffect(effect);
		auto *animation = new QPropertyAnimation(effect, "opacity", banner);
		animation->setDuration(400);
		animation->setStartValue(1.0);
		animation->setEndValue(0.0);
		QObject::connect(animation, &QPropertyAnimation::finished,
						 banner, &QWidget::close);
		animation->start();
	}

	QPointer<QWidget> m_context;
	QPointer<BannerLabel> m_banner;
	QString m_text;
	QString m_title;
	int m_duration = 6000;
	int m_waited = 0;
	bool m_pending = false;
	bool m_richText = false;
	bool m_dismissing = false;
	Notification::Horizontal m_horizontal = Notification::Horizontal::Right;
	Notification::Vertical m_vertical = Notification::Vertical::Top;
	QTimer m_poll;
};

} // namespace

namespace Notification {

void showTransient(QWidget *context, const QString &text, int durationMs, bool richText,
				   Horizontal horizontal, Vertical vertical)
{
	if (context == nullptr) {
		return;
	}
	BannerManager::instance().show(context, text, QString(), durationMs, richText,
								   horizontal, vertical);
}

void showTransient(QWidget *context, const QString &text, const QString &title,
				   int durationMs, bool richText, Horizontal horizontal, Vertical vertical)
{
	if (context == nullptr) {
		return;
	}
	BannerManager::instance().show(context, text, title, durationMs, richText,
								   horizontal, vertical);
}

} // namespace Notification
