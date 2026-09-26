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

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "qutewaveform.h"
#include "selectcolorbutton.h"
#include "types.h"

#include <QMouseEvent>
#include <QPainter>
#include <QPainterPath>
#include <QScrollBar>
#include <QWheelEvent>
#include <cmath>
#include <cstring>

namespace {

// Distinct colours used when the table holds more than one interleaved channel.
const QColor channelColors[] = {
	QColor(80, 200, 255), QColor(255, 150, 0), QColor(120, 230, 120),
	QColor(255, 110, 180), QColor(230, 220, 90), QColor(150, 150, 255),
	QColor(90, 230, 220), QColor(255, 120, 120)
};
const int channelColorCount = int(sizeof(channelColors) / sizeof(channelColors[0]));

// Csound may load f-tables asynchronously (e.g. gen 1 reading an audio file),
// so a table's properties can still change right after the table number is
// assigned. Wait this long before reading them.
const int tableQueryBaseDelayMs = 50;
// If the table properties are still not available, retry with a growing delay
// (x, x*2, x*4) a limited number of times, then give up (a table may never
// expose them).
const int tableInfoQueryMaxAttempts = 3;

// Deadline (relative to the table settle timer) for the given attempt.
int tableInfoQueryDelayMs(int attempt)
{
	return tableQueryBaseDelayMs * ((1 << (attempt + 1)) - 1);
}

// Choose a "nice" step (1, 2, 5 * 10^n) for a range and a target number of ticks.
double niceStep(double range, int targetTicks)
{
	if (range <= 0.0 || targetTicks <= 0) {
		return 1.0;
	}
	const double raw = range / targetTicks;
	const double mag = std::pow(10.0, std::floor(std::log10(raw)));
	const double norm = raw / mag;
	double nice;
	if (norm <= 1.0) {
		nice = 1.0;
	} else if (norm <= 2.0) {
		nice = 2.0;
	} else if (norm <= 5.0) {
		nice = 5.0;
	} else {
		nice = 10.0;
	}
	return nice * mag;
}

} // namespace

// ---------------------------------------------------------------------------
//  WaveformView
// ---------------------------------------------------------------------------

WaveformView::WaveformView(QWidget *parent)
	: QAbstractScrollArea(parent)
{
	setFrameShape(QFrame::NoFrame);
	setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	setHorizontalScrollBarPolicy(Qt::ScrollBarAsNeeded);
	horizontalScrollBar()->setTracking(true);
	connect(horizontalScrollBar(), &QScrollBar::valueChanged, this, [this](int value) {
		m_viewStart = value;
		viewport()->update();
	});
	viewport()->setMouseTracking(true);
	m_tableTimer.start();
}

int WaveformView::frames() const
{
	if (m_tabsize <= 0) {
		return 0;
	}
	return m_tabsize / qMax(1, m_channels);
}

int WaveformView::visibleFrames() const
{
	const int f = frames();
	if (f <= 0) {
		return 1;
	}
	int vis = int(double(f) / m_zoom);
	return qBound(1, vis, f);
}

int WaveformView::dataIndex(int frame, int channel) const
{
	return frame * qMax(1, m_channels) + channel;
}

int WaveformView::waveLeft() const
{
	return m_showAxes ? 52 : 0;
}

int WaveformView::waveWidth() const
{
	return qMax(1, viewport()->width() - waveLeft() - 4);
}

double WaveformView::sampleRate() const
{
	if (m_tableSampleRate > 0.0) {
		return m_tableSampleRate;
	}
	if (m_ud != nullptr && m_ud->csound != nullptr) {
		const double sr = csoundGetSr(m_ud->csound);
		if (sr > 0.0) {
			return sr;
		}
	}
	return 0.0;
}

QColor WaveformView::channelColor(int channel) const
{
	if (m_channels <= 1) {
		return m_color;
	}
	return channelColors[channel % channelColorCount];
}

void WaveformView::updateScrollBars()
{
	const int vis = visibleFrames();
	const int maxStart = qMax(0, frames() - vis);
	m_viewStart = qBound(0, m_viewStart, maxStart);
	QScrollBar *bar = horizontalScrollBar();
	bar->blockSignals(true);
	bar->setRange(0, maxStart);
	bar->setPageStep(vis);
	bar->setSingleStep(qMax(1, vis / 20));
	bar->setValue(m_viewStart);
	bar->blockSignals(false);
}

void WaveformView::setTableNumber(int tabnum)
{
	if (tabnum <= 0) {
		return;
	}
	if (m_tabnum == tabnum) {
		return;
	}
	m_tabnum = tabnum;
	m_snapshotTabnum.store(tabnum, std::memory_order_relaxed);
	// A new table replaces the persisted copy from the previous run.
	m_data = nullptr;
	m_tabsize = 0;
	m_snapshot.clear();
	// The table may still be loading, so restart the settle delay and forget
	// any properties detected for the previous table.
	m_tableTimer.restart();
	m_tableInfoTable = -1;
	m_tableInfoAttempt = 0;
	m_tableInfoPending = false;
	m_detectedChannels.store(0);
	m_detectedSampleRate.store(0);
	m_tableInfoReadyCount.store(0);
	m_tableSampleRate = 0.0;
	m_forceRedraw = true;
	if (m_cursor >= frames()) {
		m_cursor = 0;
	}
}

void WaveformView::setChannels(int channels)
{
	const int prop = qBound(0, channels, 64);
	// Ignore repeated assignments of the same value once the table properties
	// are known; otherwise every outvalue would trigger a new ftchnls/ftsr
	// query.
	if (prop == m_channelsProperty && m_tableInfoTable == m_tabnum) {
		return;
	}
	m_channelsProperty = prop;
	m_tableInfoTable = -1;
	m_tableInfoAttempt = 0;
	m_tableInfoPending = false;
	m_detectedChannels.store(0);
	m_detectedSampleRate.store(0);
	m_tableInfoReadyCount.store(0);
	applyChannels(m_channelsProperty > 0 ? m_channelsProperty : 1);
}

void WaveformView::applyTableSampleRate(int sampleRate)
{
	const double rate = sampleRate > 0 ? double(sampleRate) : 0.0;
	if (rate == m_tableSampleRate) {
		return;
	}
	m_tableSampleRate = rate;
	viewport()->update();
}

void WaveformView::applyChannels(int channels)
{
	channels = qBound(1, channels, 64);
	if (channels == m_channels) {
		return;
	}
	m_channels = channels;
	if (m_cursor >= frames()) {
		m_cursor = qMax(0, frames() - 1);
	}
	updateScrollBars();
	viewport()->update();
}

void WaveformView::queryTableInfo()
{
	if (m_ud == nullptr || m_ud->perfThread == nullptr || m_ud->playMutex == nullptr) {
		return;
	}
	// Do not block the GUI thread while Csound is being torn down.
	if (!m_ud->playMutex->tryLock(1)) {
		return;
	}
	CsoundPerformanceThread *pt = m_ud->perfThread;
	if (pt != nullptr && pt->GetStatus() == 0) {
		const QByteArray channelCode =
				QStringLiteral("return(ftchnls(%1))").arg(m_tabnum).toLatin1();
		const QByteArray sampleRateCode =
				QStringLiteral("return(ftsr(%1))").arg(m_tabnum).toLatin1();
		m_tableInfoPending = true;
		pt->EvalCode(channelCode.constData(), &WaveformView::channelQueryCallback, this);
		pt->EvalCode(sampleRateCode.constData(), &WaveformView::sampleRateQueryCallback, this);
	}
	m_ud->playMutex->unlock();
}

void WaveformView::channelQueryCallback(MYFLT out, void *userdata)
{
	// Runs on the performance thread; only touch atomics here.
	auto *view = static_cast<WaveformView *>(userdata);
	if (view == nullptr) {
		return;
	}
	view->m_detectedChannels.store(int(out), std::memory_order_relaxed);
	view->m_tableInfoReadyCount.fetch_add(1, std::memory_order_release);
}

void WaveformView::sampleRateQueryCallback(MYFLT out, void *userdata)
{
	// Runs on the performance thread; only touch atomics here.
	auto *view = static_cast<WaveformView *>(userdata);
	if (view == nullptr) {
		return;
	}
	view->m_detectedSampleRate.store(int(out), std::memory_order_relaxed);
	view->m_tableInfoReadyCount.fetch_add(1, std::memory_order_release);
}

void WaveformView::setCursor(int pos)
{
	const int maxPos = frames() > 0 ? frames() - 1 : 0;
	m_cursor = qBound(0, pos, maxPos);
	// If the cursor lies outside the visible range, scroll so that it sits at
	// the left edge of the view (clamped at the end of the table).
	const int vis = visibleFrames();
	if (m_cursor < m_viewStart || m_cursor >= m_viewStart + vis) {
		setViewStart(m_cursor);
	}
	viewport()->update();
}

void WaveformView::setZoom(double zoom)
{
	m_zoom = qBound(1.0, zoom, 1.0e6);
	updateScrollBars();
	viewport()->update();
}

void WaveformView::setViewStart(int start)
{
	horizontalScrollBar()->setValue(start);
}

void WaveformView::persistTable(CSOUND *cs)
{
	// Called by the engine on the stopping thread, while the Csound instance is
	// still alive. Copy the table so the display can survive the teardown.
	const int tabnum = m_snapshotTabnum.load(std::memory_order_relaxed);
	if (cs == nullptr || tabnum <= 0) {
		return;
	}
	const int len = csoundTableLength(cs, tabnum);
	MYFLT *data = nullptr;
	if (len > 0) {
		csoundGetTable(cs, &data, tabnum);
	}
	if (len <= 0 || data == nullptr) {
		return;
	}
	m_snapshot.resize(len);
	memcpy(m_snapshot.data(), data, size_t(len) * sizeof(MYFLT));
}

void WaveformView::showSnapshot()
{
	if (m_snapshot.isEmpty()) {
		if (m_data != nullptr || m_tabsize != 0 || m_forceRedraw) {
			m_data = nullptr;
			m_tabsize = 0;
			m_forceRedraw = false;
			updateScrollBars();
			viewport()->update();
		}
		return;
	}
	if (m_data != m_snapshot.data() || m_tabsize != m_snapshot.size()) {
		m_data = m_snapshot.data();
		m_tabsize = m_snapshot.size();
		if (m_cursor >= frames()) {
			m_cursor = qMax(0, frames() - 1);
		}
		m_forceRedraw = false;
		updateScrollBars();
		viewport()->update();
	}
}

void WaveformView::reset()
{
	m_running = false;
	m_tabnum = 0;
	m_tableInfoTable = -1;
	m_tableInfoAttempt = 0;
	m_tableInfoPending = false;
	m_detectedChannels.store(0);
	m_detectedSampleRate.store(0);
	m_tableInfoReadyCount.store(0);
	// Keep m_channels and m_tableSampleRate so the persisted snapshot keeps
	// rendering with the same layout and time axis.
	showSnapshot();
}

int WaveformView::frameAtX(int x) const
{
	const int vis = visibleFrames();
	return m_viewStart + int(double(x - waveLeft()) * vis / double(waveWidth()));
}

void WaveformView::refresh()
{
	if (!m_running || m_tabnum <= 0 || m_ud == nullptr || m_ud->csound == nullptr) {
		// Not running (or no live table): keep showing the persisted snapshot.
		showSnapshot();
		return;
	}
	// Give Csound time to finish (possibly asynchronous) table loading before
	// reading any property from it.
	if (!m_tableTimer.hasExpired(tableQueryBaseDelayMs)) {
		viewport()->update();
		return;
	}
	// Query ftchnls()/ftsr() until the table exposes them, retrying with a
	// growing, bounded delay (a table may never expose them).
	if (m_tableInfoTable != m_tabnum) {
		if (m_tableInfoReadyCount.load(std::memory_order_acquire) >= 2) {
			m_tableInfoReadyCount.store(0, std::memory_order_relaxed);
			m_tableInfoPending = false;
			const int detected = m_detectedChannels.load(std::memory_order_relaxed);
			const int tableSr = m_detectedSampleRate.load(std::memory_order_relaxed);
			if (detected >= 0) {
				m_tableInfoTable = m_tabnum;
				applyTableSampleRate(tableSr);
				if (m_channelsProperty == 0) {
					applyChannels(detected > 0 ? detected : 1);
				}
			} else {
				++m_tableInfoAttempt;
				if (m_tableInfoAttempt >= tableInfoQueryMaxAttempts) {
					// No channel information available; stop retrying.
					m_tableInfoTable = m_tabnum;
					applyTableSampleRate(tableSr);
					if (m_channelsProperty == 0) {
						applyChannels(1);
					}
				}
			}
		}
		if (!m_tableInfoPending && m_tableInfoAttempt < tableInfoQueryMaxAttempts
				&& m_tableTimer.elapsed() >= tableInfoQueryDelayMs(m_tableInfoAttempt)) {
			queryTableInfo();
		}
	}
	const int len = csoundTableLength(m_ud->csound, m_tabnum);
	MYFLT *data = nullptr;
	int result = 0;
	if (len > 0) {
		result = csoundGetTable(m_ud->csound, &data, m_tabnum);
	}
	if (len <= 0 || result <= 0 || data == nullptr) {
		// Live table not ready yet: keep the persisted snapshot (if any).
		showSnapshot();
		return;
	}
	// Repainting scans the whole visible table, which is expensive. Only do it
	// when the table changed or a redraw was explicitly requested; in-place
	// table changes are redrawn by sending a negative value to the table
	// channel.
	const bool dataChanged = (m_data != data) || (m_tabsize != len);
	m_data = data;
	m_tabsize = len;
	if (m_cursor >= frames()) {
		m_cursor = qMax(0, frames() - 1);
	}
	if (dataChanged || m_forceRedraw) {
		m_forceRedraw = false;
		updateScrollBars();
		viewport()->update();
	}
}

void WaveformView::forceRedraw()
{
	m_forceRedraw = true;
	viewport()->update();
}

void WaveformView::resizeEvent(QResizeEvent *event)
{
	QAbstractScrollArea::resizeEvent(event);
	updateScrollBars();
}

QRect WaveformView::channelRect(const QRect &waveRect, int channel) const
{
	if (m_channels <= 1) {
		return waveRect;
	}
	const int gap = 3;
	const int laneHeight =
			qMax(1, (waveRect.height() - gap * (m_channels - 1)) / m_channels);
	const int top = waveRect.top() + channel * (laneHeight + gap);
	return QRect(waveRect.left(), top, waveRect.width(), laneHeight);
}

void WaveformView::computeAmplitudes(QVector<double> &miny, QVector<double> &maxy) const
{
	const int n = qMax(1, m_channels);
	miny.resize(n);
	maxy.resize(n);
	if (!m_autoRange) {
		double lo = -m_range;
		double hi = m_range;
		if (hi - lo < 1.0e-9) {
			lo = -1.0;
			hi = 1.0;
		}
		miny.fill(lo);
		maxy.fill(hi);
		return;
	}
	const int vis = visibleFrames();
	const int first = m_viewStart;
	const int last = qMin(frames(), first + vis);
	for (int c = 0; c < n; ++c) {
		double lo = 1.0e30;
		double hi = -1.0e30;
		for (int f = first; f < last; ++f) {
			const double v = double(m_data[dataIndex(f, c)]);
			if (v < lo) lo = v;
			if (v > hi) hi = v;
		}
		if (lo > hi) {
			lo = -1.0;
			hi = 1.0;
		}
		if (hi - lo < 1.0e-9) {
			lo -= 0.5;
			hi += 0.5;
		}
		miny[c] = lo;
		maxy[c] = hi;
	}
}

void WaveformView::drawAxes(QPainter &painter, const QRect &widgetRect, const QRect &waveRect,
							const QVector<double> &miny, const QVector<double> &maxy)
{
	const QFont originalFont = painter.font();
	QFont f = originalFont;
	f.setPointSizeF(qMax(7.0, f.pointSizeF() - 2.0));
	painter.setFont(f);

	QColor grid = m_color;
	grid.setAlpha(60);
	const QColor axis = m_color;
	QColor textColor = m_bgcolor.lightness() < 128 ? QColor(210, 210, 210) : QColor(50, 50, 50);
	if (!m_showBackground) {
		textColor = palette().color(QPalette::WindowText);
	}
	auto xOfFrame = [&](double frame) {
		return waveRect.left() + (frame - m_viewStart) * double(waveRect.width())
				/ double(visibleFrames());
	};

	// --- Amplitude (vertical) axes: one per stacked channel ---
	QColor ac = axis;
	ac.setAlpha(90);
	for (int c = 0; c < m_channels; ++c) {
		const QRect lane = channelRect(waveRect, c);
		const double amp = maxy[c] - miny[c];
		if (amp < 1.0e-12) {
			continue;
		}
		auto yOf = [&](double v) {
			return lane.top() + (maxy[c] - v) / amp * (lane.height() - 1);
		};
		painter.setPen(QPen(ac, 0));
		painter.drawLine(lane.topLeft(), lane.bottomLeft());
		const double astep = niceStep(amp, 4);
		for (double a = std::ceil(miny[c] / astep) * astep; a <= maxy[c] + 1e-9; a += astep) {
			const double y = yOf(a);
			if (m_showGrid) {
				painter.setPen(QPen(grid, 0));
				painter.drawLine(QPointF(lane.left(), y), QPointF(lane.right(), y));
			}
			painter.setPen(textColor);
			const QString label = QString::number(a, 'g', 3);
			painter.drawText(QRectF(0, y - 8, lane.left() - 4, 16),
							 Qt::AlignRight | Qt::AlignVCenter, label);
		}
	}

	// --- Time (horizontal) axis, shared by all channels ---
	painter.setPen(QPen(ac, 0));
	painter.drawLine(waveRect.bottomLeft(), waveRect.bottomRight());
	const double sr = sampleRate();
	const bool timeMode = sr > 0.0;
	const int vis = visibleFrames();
	const double tStart = timeMode ? double(m_viewStart) / sr : double(m_viewStart);
	const double tEnd = timeMode ? double(m_viewStart + vis) / sr : double(m_viewStart + vis);
	const double tstep = niceStep(tEnd - tStart, 6);
	int decimals = 0;
	if (timeMode) {
		decimals = tstep < 0.001 ? 4 : tstep < 0.01 ? 3 : tstep < 0.1 ? 2 : tstep < 1.0 ? 2 : 1;
	}
	for (double t = std::ceil(tStart / tstep) * tstep; t <= tEnd + 1e-9; t += tstep) {
		const double frame = timeMode ? t * sr : t;
		const double x = xOfFrame(frame);
		if (m_showGrid) {
			painter.setPen(QPen(grid, 0));
			painter.drawLine(QPointF(x, waveRect.top()), QPointF(x, waveRect.bottom()));
		}
		painter.setPen(textColor);
		const QString label = timeMode ? QString::number(t, 'f', decimals) + "s"
									   : QString::number(qRound(t));
		painter.drawText(QRectF(x - 40, waveRect.bottom() + 2, 80,
								widgetRect.bottom() - waveRect.bottom() - 1),
						 Qt::AlignHCenter | Qt::AlignTop, label);
	}
	painter.setFont(originalFont);
}

void WaveformView::drawWaveform(QPainter &painter, const QRect &waveRect,
								const QVector<double> &miny, const QVector<double> &maxy)
{
	const int vis = visibleFrames();
	const int first = m_viewStart;
	const int last = qMin(frames(), first + vis + 1);

	for (int c = 0; c < m_channels; ++c) {
		const QRect lane = channelRect(waveRect, c);
		const double amp = maxy[c] - miny[c];
		if (amp < 1.0e-12) {
			continue;
		}
		const double xscale = double(lane.width()) / double(vis);
		auto yOf = [&](double v) {
			return lane.top() + (maxy[c] - v) / amp * (lane.height() - 1);
		};
		const QColor color = channelColor(c);
		QColor stroke = color;
		QColor fill = color;
		fill.setAlpha(110);
		if (vis <= lane.width()) {
			QPainterPath path;
			for (int f = first; f < last; ++f) {
				const double x = lane.left() + (f - first) * xscale;
				const double y = yOf(double(m_data[dataIndex(f, c)]));
				if (f == first) {
					path.moveTo(x, y);
				} else {
					path.lineTo(x, y);
				}
			}
			painter.setPen(QPen(stroke, 0));
			painter.setBrush(Qt::NoBrush);
			painter.drawPath(path);
		} else {
			QPolygonF top;
			QPolygonF bottom;
			for (int px = 0; px < lane.width(); ++px) {
				int f0 = first + int(double(px) * vis / lane.width());
				int f1 = first + int(double(px + 1) * vis / lane.width());
				if (f1 <= f0) {
					f1 = f0 + 1;
				}
				if (f1 > frames()) {
					f1 = frames();
				}
				if (f0 >= frames()) {
					break;
				}
				double cmin = 1.0e30, cmax = -1.0e30;
				for (int f = f0; f < f1; ++f) {
					const double v = double(m_data[dataIndex(f, c)]);
					if (v < cmin) cmin = v;
					if (v > cmax) cmax = v;
				}
				top.append(QPointF(lane.left() + px + 0.5, yOf(cmax)));
				bottom.prepend(QPointF(lane.left() + px + 0.5, yOf(cmin)));
			}
			QPolygonF envelope = top;
			envelope += bottom;
			painter.setPen(QPen(stroke, 0));
			painter.setBrush(fill);
			painter.drawPolygon(envelope);
		}
	}
}

void WaveformView::paintEvent(QPaintEvent *)
{
	QPainter painter(viewport());
	const QRect r = viewport()->rect();
	if (r.isEmpty()) {
		return;
	}

	if (m_showBackground) {
		painter.fillRect(r, m_bgcolor);
	} else {
		painter.fillRect(r, palette().color(QPalette::Base));
	}

	const QColor background = m_showBackground ? m_bgcolor : palette().color(QPalette::Base);
	const QColor statusColor = background.lightness() < 128 ? QColor(220, 220, 220)
														   : QColor(40, 40, 40);
	if (m_data == nullptr || m_tabsize <= 0) {
		// A persisted snapshot is kept after stop, so only show a message when
		// there is nothing at all to draw.
		painter.setPen(statusColor);
		painter.drawText(r, Qt::AlignCenter,
						 m_running ? tr("Table not set") : tr("Stopped"));
		return;
	}

	const int bottomMargin = m_showAxes ? 20 : 0;
	const QRect waveRect(waveLeft(), 4, waveWidth(),
						 qMax(1, r.height() - 4 - bottomMargin));
	if (waveRect.width() < 4 || waveRect.height() < 4) {
		return;
	}
	painter.setRenderHint(QPainter::Antialiasing, true);

	QVector<double> miny;
	QVector<double> maxy;
	computeAmplitudes(miny, maxy);

	if (m_showAxes) {
		drawAxes(painter, r, waveRect, miny, maxy);
	}
	drawWaveform(painter, waveRect, miny, maxy);

	// Channel labels for stacked multichannel tables.
	if (m_channels > 1) {
		painter.setFont(QFont(painter.font().family(),
							  qMax(7.0, painter.font().pointSizeF() - 2.0)));
		for (int c = 0; c < m_channels; ++c) {
			const QRect lane = channelRect(waveRect, c);
			painter.setPen(channelColor(c));
			painter.drawText(QRect(lane.left() + 4, lane.top() + 2, 40, 16),
							 Qt::AlignLeft | Qt::AlignTop, QString::number(c + 1));
		}
	}

	// Cursor (in frames), spanning all channels.
	const int vis = visibleFrames();
	const double xscale = double(waveRect.width()) / double(vis);
	const double cx = waveRect.left() + double(m_cursor - m_viewStart) * xscale;
	if (cx >= waveRect.left() && cx <= waveRect.right()) {
		painter.setPen(QPen(m_cursorColor, 0));
		painter.drawLine(QPointF(cx, waveRect.top()), QPointF(cx, waveRect.bottom()));
	}
}

void WaveformView::mousePressEvent(QMouseEvent *event)
{
	if (event->button() == Qt::LeftButton) {
		if (event->modifiers() & Qt::ControlModifier) {
			// Ctrl + drag scrolls the view.
			m_panning = true;
			m_pressPos = event->pos();
			m_pressViewStart = m_viewStart;
		} else {
			// A plain click sets the cursor immediately.
			setCursor(frameAtX(event->pos().x()));
			emit cursorChanged(m_cursor);
		}
		event->accept();
		return;
	}
	QAbstractScrollArea::mousePressEvent(event);
}

void WaveformView::mouseMoveEvent(QMouseEvent *event)
{
	if (m_panning && (event->buttons() & Qt::LeftButton)) {
		const int dx = event->pos().x() - m_pressPos.x();
		const double xscale = double(visibleFrames()) / double(waveWidth());
		horizontalScrollBar()->setValue(m_pressViewStart - int(dx * xscale));
		event->accept();
		return;
	}
	QAbstractScrollArea::mouseMoveEvent(event);
}

void WaveformView::mouseReleaseEvent(QMouseEvent *event)
{
	if (event->button() == Qt::LeftButton && m_panning) {
		m_panning = false;
		event->accept();
		return;
	}
	QAbstractScrollArea::mouseReleaseEvent(event);
}

void WaveformView::wheelEvent(QWheelEvent *event)
{
	const int delta = event->angleDelta().y();
	if (delta == 0) {
		QAbstractScrollArea::wheelEvent(event);
		return;
	}
	if (event->modifiers() & Qt::ShiftModifier) {
		const int step = qMax(1, visibleFrames() / 10);
		horizontalScrollBar()->setValue(m_viewStart - (delta > 0 ? step : -step));
		event->accept();
		return;
	}
	// Zoom around the frame under the mouse.
	const int x = int(event->position().x());
	const int frameUnderMouse = frameAtX(x);
	const double factor = delta > 0 ? 1.25 : 1.0 / 1.25;
	m_zoom = qBound(1.0, m_zoom * factor, 1.0e6);
	const int vis = visibleFrames();
	const int newStart = frameUnderMouse - int(double(x - waveLeft()) * vis / double(waveWidth()));
	m_viewStart = newStart;
	updateScrollBars();
	viewport()->update();
	event->accept();
}

// ---------------------------------------------------------------------------
//  QuteWaveform
// ---------------------------------------------------------------------------

QuteWaveform::QuteWaveform(QWidget *parent) : QuteWidget(parent)
{
	auto *view = new WaveformView(this);
	m_widget = view;
	m_widget->setContextMenuPolicy(Qt::NoContextMenu);
	connect(view, &WaveformView::cursorChanged, this, &QuteWaveform::cursorMoved);

	m_value = 0.0;   // table number
	m_value2 = 0.0;  // cursor position (frames)

	setProperty("CSQT_color", QColor(80, 200, 255));
	setProperty("CSQT_bgcolor", QColor(24, 24, 24));
	setProperty("CSQT_bgcolormode", true);
	setProperty("CSQT_cursorcolor", QColor(255, 150, 0));
	setProperty("CSQT_showGrid", false);
	setProperty("CSQT_showAxes", true);
	setProperty("CSQT_autoRange", true);
	setProperty("CSQT_channels", 0);
	setProperty("CSQT_range", 1.0);
	setProperty("CSQT_zoom", 1.0);
	setProperty("CSQT_offset", 0);
	setProperty("CSQT_value", 0.0);
	setProperty("CSQT_cursor", 0.0);
	setProperty("CSQT_randomizable", false);
}

QuteWaveform::~QuteWaveform()
{
	if (m_registeredEngine) {
		m_registeredEngine->removeBeforeCleanupCallback(m_widget);
	}
}

void QuteWaveform::setCsoundUserData(CsoundUserData *ud)
{
	if (ud == nullptr) {
		qDebug() << "CsoundUserData is null";
		return;
	}
	m_csoundUserData = ud;
	auto *view = static_cast<WaveformView *>(m_widget);
	view->setUserData(ud);
	if (ud->csEngine) {
		connect(ud->csEngine, SIGNAL(stopSignal()), this, SLOT(onStop()), Qt::UniqueConnection);
		// Copy the table out of Csound just before the instance is destroyed so
		// the waveform survives the stop.
		if (m_registeredEngine != ud->csEngine) {
			if (m_registeredEngine) {
				m_registeredEngine->removeBeforeCleanupCallback(m_widget);
			}
			m_registeredEngine = ud->csEngine;
			ud->csEngine->addBeforeCleanupCallback(m_widget, [view](CSOUND *cs) {
				view->persistTable(cs);
			});
		}
	}
}

void QuteWaveform::setValue(double value)
{
	// Mirrors QuteTable: >0 sets the table, <0 forces a redraw, 0 is a no-op.
	if (value == 0.0) {
		m_value = m_tabnum;
		return;
	}
	if (value < 0.0) {
		m_forceRefresh = true;
		return;
	}
	const int tab = int(value);
	m_value = value;
	if (tab != m_tabnum) {
		m_tabnum = tab;
		m_valueChanged = true;
	}
}

void QuteWaveform::setValue2(double value)
{
	m_value2 = value;
	m_value2Changed = true;
}

void QuteWaveform::setValue(QString s)
{
	const auto parts = QStringView(s).split(' ', SKIP_EMPTY_PARTS);
	if (parts.isEmpty()) {
		return;
	}
	if (parts[0] == QLatin1String("@set") && parts.size() == 2) {
		setValue(parts[1].toDouble());
	} else if (parts[0] == QLatin1String("@cursor") && parts.size() == 2) {
		setValue2(parts[1].toDouble());
	} else if (parts[0] == QLatin1String("@zoom") && parts.size() == 2) {
		setProperty("CSQT_zoom", parts[1].toDouble());
		applyProperty("CSQT_zoom");
	} else if (parts[0] == QLatin1String("@update")) {
		setValue(-1.0);
	} else {
		qWarning() << "Waveform: message not understood:" << s;
	}
}

void QuteWaveform::cursorMoved(int pos)
{
	m_value2 = pos;
	emit newValue(QPair<QString, double>(m_channel2, double(pos)));
}

void QuteWaveform::onStop()
{
	auto *view = static_cast<WaveformView *>(m_widget);
	view->reset();
}

void QuteWaveform::refreshWidget()
{
	auto *view = static_cast<WaveformView *>(m_widget);
	const bool running = m_csoundUserData && m_csoundUserData->csound
			&& m_csoundUserData->csEngine && m_csoundUserData->csEngine->isRunning();
	view->setRunning(running);
	if (m_valueChanged) {
		m_valueChanged = false;
		const int tab = int(m_value);
		if (tab > 0) {
			view->setTableNumber(tab);
		}
	}
	if (m_value2Changed) {
		m_value2Changed = false;
		view->setCursor(int(m_value2));
	}
	// Make sure the table is applied even if only the cursor changed (or the
	// table was retained from a previous run).
	if (running && m_tabnum > 0 && view->tableNumber() != m_tabnum) {
		view->setTableNumber(m_tabnum);
	}
	if (m_forceRefresh) {
		m_forceRefresh = false;
		view->forceRedraw();
	}
	view->refresh();
}

void QuteWaveform::updateData()
{
	auto *view = static_cast<WaveformView *>(m_widget);
	const bool running = m_csoundUserData && m_csoundUserData->csound
			&& m_csoundUserData->csEngine && m_csoundUserData->csEngine->isRunning();
	view->setRunning(running);
	// On a (re)start the channel value may be unchanged from the previous run,
	// so no value-change event reaches the widget and the view (reset when the
	// performance stopped) would stay empty. Re-apply the last table number.
	if (running && m_tabnum > 0 && view->tableNumber() != m_tabnum) {
		view->setTableNumber(m_tabnum);
	}
	if (m_forceRefresh) {
		m_forceRefresh = false;
		view->forceRedraw();
	}
	view->refresh();
}

bool QuteWaveform::applyProperty(const QString &name)
{
	auto *view = static_cast<WaveformView *>(m_widget);
	const QByteArray key = name.toLatin1();
	if (name == "CSQT_color") {
		view->setColor(property(key.constData()).value<QColor>());
		return true;
	}
	if (name == "CSQT_bgcolor") {
		view->setBgColor(property(key.constData()).value<QColor>());
		return true;
	}
	if (name == "CSQT_bgcolormode") {
		view->setShowBackground(property(key.constData()).toBool());
		return true;
	}
	if (name == "CSQT_cursorcolor") {
		view->setCursorColor(property(key.constData()).value<QColor>());
		return true;
	}
	if (name == "CSQT_showGrid") {
		view->setShowGrid(property(key.constData()).toBool());
		return true;
	}
	if (name == "CSQT_showAxes") {
		view->setShowAxes(property(key.constData()).toBool());
		return true;
	}
	if (name == "CSQT_autoRange") {
		view->setAutoRange(property(key.constData()).toBool());
		return true;
	}
	if (name == "CSQT_channels") {
		view->setChannels(property(key.constData()).toInt());
		return true;
	}
	if (name == "CSQT_range") {
		view->setRange(property(key.constData()).toDouble());
		return true;
	}
	if (name == "CSQT_zoom") {
		view->setZoom(property(key.constData()).toDouble());
		return true;
	}
	if (name == "CSQT_offset") {
		view->setViewStart(property(key.constData()).toInt());
		return true;
	}
	if (name == "CSQT_value") {
		setValue(property(key.constData()).toDouble());
		return true;
	}
	if (name == "CSQT_cursor") {
		setValue2(property(key.constData()).toDouble());
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteWaveform::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
	auto *view = static_cast<WaveformView *>(m_widget);

	const double table = property("CSQT_value").toDouble();
	if (table > 0.0) {
		m_value = table;
		m_tabnum = int(table);
	}
	m_value2 = property("CSQT_cursor").toDouble();

	view->setColor(property("CSQT_color").value<QColor>());
	view->setBgColor(property("CSQT_bgcolor").value<QColor>());
	view->setShowBackground(property("CSQT_bgcolormode").toBool());
	view->setCursorColor(property("CSQT_cursorcolor").value<QColor>());
	view->setShowGrid(property("CSQT_showGrid").toBool());
	view->setShowAxes(property("CSQT_showAxes").toBool());
	view->setAutoRange(property("CSQT_autoRange").toBool());
	view->setChannels(property("CSQT_channels").toInt());
	view->setRange(property("CSQT_range").toDouble());
	view->setZoom(property("CSQT_zoom").toDouble());
	view->setViewStart(property("CSQT_offset").toInt());
	view->setTableNumber(int(m_value));
	view->setCursor(int(m_value2));
}

static void writeColorElement(QXmlStreamWriter &s, const QString &name, const QColor &color)
{
	s.writeStartElement(name);
	s.writeTextElement("r", QString::number(color.red()));
	s.writeTextElement("g", QString::number(color.green()));
	s.writeTextElement("b", QString::number(color.blue()));
	s.writeEndElement();
}

QString QuteWaveform::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

	s.writeTextElement("value", QString::number(m_value, 'f', 0));
	s.writeTextElement("objectName2", m_channel2);
	s.writeTextElement("cursor", QString::number(m_value2, 'f', 0));
	writeColorElement(s, "color", property("CSQT_color").value<QColor>());
	writeColorElement(s, "bgcolor", property("CSQT_bgcolor").value<QColor>());
	s.writeTextElement("bgcolormode", property("CSQT_bgcolormode").toBool() ? "true" : "false");
	writeColorElement(s, "cursorcolor", property("CSQT_cursorcolor").value<QColor>());
	s.writeTextElement("showGrid", property("CSQT_showGrid").toBool() ? "true" : "false");
	s.writeTextElement("showAxes", property("CSQT_showAxes").toBool() ? "true" : "false");
	s.writeTextElement("autoRange", property("CSQT_autoRange").toBool() ? "true" : "false");
	s.writeTextElement("channels", QString::number(property("CSQT_channels").toInt()));
	s.writeTextElement("range", QString::number(property("CSQT_range").toDouble(), 'f', 6));
	s.writeTextElement("zoom", QString::number(property("CSQT_zoom").toDouble(), 'f', 6));
	s.writeTextElement("offset", QString::number(property("CSQT_offset").toInt()));

	s.writeEndElement();
	return xmlText;
}

void QuteWaveform::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
	dialog->setWindowTitle("Waveform");
	channelLabel->setText("Table Channel name =");

	QLabel *label = new QLabel("Cursor Channel name =", dialog);
	layout->addWidget(label, 4, 0, Qt::AlignRight | Qt::AlignVCenter);
	name2LineEdit = new QLineEdit(dialog);
	name2LineEdit->setText(getChannel2Name());
	name2LineEdit->setMinimumWidth(320);
	layout->addWidget(name2LineEdit, 4, 1, 1, 3, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Table number", dialog);
	layout->addWidget(label, 5, 0, Qt::AlignRight | Qt::AlignVCenter);
	tableSpinBox = new QSpinBox(dialog);
	tableSpinBox->unsetLocale();
	tableSpinBox->setRange(0, 1000000);
	tableSpinBox->setValue(int(m_value));
	layout->addWidget(tableSpinBox, 5, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Channels", dialog);
	layout->addWidget(label, 5, 2, Qt::AlignRight | Qt::AlignVCenter);
	channelsSpinBox = new QSpinBox(dialog);
	channelsSpinBox->unsetLocale();
	channelsSpinBox->setRange(0, 64);
	channelsSpinBox->setSpecialValueText(tr("Auto"));
	channelsSpinBox->setToolTip(tr("Number of interleaved channels in the table.\n"
								   "Soundfile tables (gen 1) are interleaved; 0 auto-detects\n"
								   "the count with ftchnls()."));
	channelsSpinBox->setValue(qMax(0, property("CSQT_channels").toInt()));
	layout->addWidget(channelsSpinBox, 5, 3, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Waveform color", dialog);
	layout->addWidget(label, 6, 0, Qt::AlignRight | Qt::AlignVCenter);
	colorButton = new SelectColorButton(dialog);
	colorButton->setColor(property("CSQT_color").value<QColor>());
	layout->addWidget(colorButton, 6, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Cursor color", dialog);
	layout->addWidget(label, 7, 0, Qt::AlignRight | Qt::AlignVCenter);
	cursorColorButton = new SelectColorButton(dialog);
	cursorColorButton->setColor(property("CSQT_cursorcolor").value<QColor>());
	layout->addWidget(cursorColorButton, 7, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Background color", dialog);
	layout->addWidget(label, 8, 0, Qt::AlignRight | Qt::AlignVCenter);
	bgColorButton = new SelectColorButton(dialog);
	bgColorButton->setColor(property("CSQT_bgcolor").value<QColor>());
	layout->addWidget(bgColorButton, 8, 1, Qt::AlignLeft | Qt::AlignVCenter);

	bgColorCheckBox = new QCheckBox("Use background color", dialog);
	bgColorCheckBox->setChecked(property("CSQT_bgcolormode").toBool());
	layout->addWidget(bgColorCheckBox, 8, 2, Qt::AlignLeft | Qt::AlignVCenter);

	showGridCheckBox = new QCheckBox("Show grid", dialog);
	showGridCheckBox->setChecked(property("CSQT_showGrid").toBool());
	layout->addWidget(showGridCheckBox, 9, 1, Qt::AlignLeft | Qt::AlignVCenter);

	showAxesCheckBox = new QCheckBox("Show axes", dialog);
	showAxesCheckBox->setChecked(property("CSQT_showAxes").toBool());
	layout->addWidget(showAxesCheckBox, 9, 2, Qt::AlignLeft | Qt::AlignVCenter);

	autoRangeCheckBox = new QCheckBox("Auto amplitude range", dialog);
	autoRangeCheckBox->setChecked(property("CSQT_autoRange").toBool());
	layout->addWidget(autoRangeCheckBox, 10, 1, Qt::AlignLeft | Qt::AlignVCenter);

	rangeSpinBox = new QDoubleSpinBox(dialog);
	rangeSpinBox->unsetLocale();
	rangeSpinBox->setRange(0.000001, 1000000.0);
	rangeSpinBox->setDecimals(6);
	rangeSpinBox->setValue(property("CSQT_range").toDouble() > 0.0
						   ? property("CSQT_range").toDouble() : 1.0);
	rangeSpinBox->setEnabled(!autoRangeCheckBox->isChecked());
	layout->addWidget(rangeSpinBox, 10, 2, Qt::AlignLeft | Qt::AlignVCenter);
	connect(autoRangeCheckBox, &QCheckBox::toggled, rangeSpinBox, [this](bool on) {
		rangeSpinBox->setEnabled(!on);
	});
}

void QuteWaveform::applyProperties()
{
	setProperty("CSQT_objectName2", name2LineEdit->text());
	setProperty("CSQT_value", double(tableSpinBox->value()));
	setProperty("CSQT_channels", channelsSpinBox->value());
	setProperty("CSQT_color", colorButton->getColor());
	setProperty("CSQT_cursorcolor", cursorColorButton->getColor());
	setProperty("CSQT_bgcolor", bgColorButton->getColor());
	setProperty("CSQT_bgcolormode", bgColorCheckBox->isChecked());
	setProperty("CSQT_showGrid", showGridCheckBox->isChecked());
	setProperty("CSQT_showAxes", showAxesCheckBox->isChecked());
	setProperty("CSQT_autoRange", autoRangeCheckBox->isChecked());
	setProperty("CSQT_range", rangeSpinBox->value());

	m_value = double(tableSpinBox->value());
	m_tabnum = tableSpinBox->value();

	QuteWidget::applyProperties();
}
