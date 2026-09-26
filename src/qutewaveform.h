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

#ifndef QUTEWAVEFORM_H
#define QUTEWAVEFORM_H

#include "qutewidget.h"

#include <QElapsedTimer>
#include <QPointer>
#include <QVector>
#include <atomic>

class SelectColorButton;

// The actual drawing/zooming/scrolling widget. It lives inside a QuteWaveform
// (m_widget) and reads the samples of a Csound f-table directly.
//
// A Csound table is a flat array of MYFLT, but soundfile tables (gen 1) are
// interleaved. The number of interleaved channels is either set explicitly
// with setChannels(> 0) or auto-detected with the ftchnls opcode when
// setChannels(0) is used; channels > 1 are drawn stacked in distinct colours,
// sharing the time axis but each with its own amplitude axis.
// The cursor and the horizontal axis are in frames (samples per channel).
class WaveformView : public QAbstractScrollArea
{
	Q_OBJECT
public:
	explicit WaveformView(QWidget *parent = nullptr);

	void setUserData(CsoundUserData *ud) { m_ud = ud; }
	void setRunning(bool running) { m_running = running; }

	void setTableNumber(int tabnum);
	int tableNumber() const { return m_tabnum; }

	// channels == 0 requests auto-detection via ftchnls(), otherwise the given
	// number of interleaved channels is used.
	void setChannels(int channels);
	int channels() const { return m_channels; }

	void setCursor(int pos);
	int cursor() const { return m_cursor; }

	void setColor(const QColor &c) { m_color = c; viewport()->update(); }
	void setBgColor(const QColor &c) { m_bgcolor = c; viewport()->update(); }
	void setCursorColor(const QColor &c) { m_cursorColor = c; viewport()->update(); }
	void setShowBackground(bool show) { m_showBackground = show; viewport()->update(); }
	void setShowGrid(bool show) { m_showGrid = show; viewport()->update(); }
	void setShowAxes(bool show) { m_showAxes = show; viewport()->update(); }
	void setAutoRange(bool on) { m_autoRange = on; viewport()->update(); }
	void setRange(double range) { m_range = range; viewport()->update(); }

	void setZoom(double zoom);
	double zoom() const { return m_zoom; }
	void setViewStart(int start);
	int viewStart() const { return m_viewStart; }

	// Re-read the table pointer/length from Csound and repaint.
	void refresh();
	// Force a repaint on the next refresh (used for in-place table changes).
	void forceRedraw();
	// Called by the engine just before the Csound instance is destroyed, while
	// the table is still valid, to copy it so the waveform can persist after
	// the performance stops.
	void persistTable(CSOUND *cs);
	// Stop displaying live data, falling back to the persisted snapshot.
	void reset();

	int frameAtX(int x) const;

signals:
	void cursorChanged(int pos);

protected:
	void paintEvent(QPaintEvent *event) override;
	void resizeEvent(QResizeEvent *event) override;
	void mousePressEvent(QMouseEvent *event) override;
	void mouseMoveEvent(QMouseEvent *event) override;
	void mouseReleaseEvent(QMouseEvent *event) override;
	void wheelEvent(QWheelEvent *event) override;

private:
	int frames() const;
	int visibleFrames() const;
	int waveLeft() const;
	int waveWidth() const;
	int dataIndex(int frame, int channel) const;
	QColor channelColor(int channel) const;
	double sampleRate() const;
	void updateScrollBars();
	void applyChannels(int channels);
	void applyTableSampleRate(int sampleRate);
	void showSnapshot();
	void queryTableInfo();
	static void channelQueryCallback(MYFLT out, void *userdata);
	static void sampleRateQueryCallback(MYFLT out, void *userdata);
	// Vertical lane occupied by the given channel when channels are stacked.
	QRect channelRect(const QRect &waveRect, int channel) const;
	void computeAmplitudes(QVector<double> &miny, QVector<double> &maxy) const;
	void drawAxes(QPainter &painter, const QRect &widgetRect, const QRect &waveRect,
				  const QVector<double> &miny, const QVector<double> &maxy);
	void drawWaveform(QPainter &painter, const QRect &waveRect,
					  const QVector<double> &miny, const QVector<double> &maxy);

	CsoundUserData *m_ud = nullptr;
	bool m_running = false;
	int m_tabnum = 0;
	MYFLT *m_data = nullptr;
	int m_tabsize = 0;    // raw number of MYFLT values
	int m_channelsProperty = 0; // requested channels, 0 = auto-detect
	int m_channels = 1;   // effective interleaved channels used for drawing
	int m_tableInfoTable = -1; // table whose properties have been resolved
	int m_tableInfoAttempt = 0;
	bool m_tableInfoPending = false;
	std::atomic<int> m_detectedChannels{0};
	std::atomic<int> m_detectedSampleRate{0};
	std::atomic<int> m_tableInfoReadyCount{0};
	double m_tableSampleRate = 0.0;
	bool m_forceRedraw = true;
	QVector<MYFLT> m_snapshot;          // table copy kept after stop
	std::atomic<int> m_snapshotTabnum{0};
	QElapsedTimer m_tableTimer;
	int m_cursor = 0;     // frame
	double m_zoom = 1.0;
	int m_viewStart = 0;  // frame

	QColor m_color = QColor(80, 200, 255);
	QColor m_bgcolor = QColor(24, 24, 24);
	QColor m_cursorColor = QColor(255, 150, 0);
	bool m_showBackground = true;
	bool m_showGrid = false;
	bool m_showAxes = true;
	bool m_autoRange = true;
	double m_range = 1.0;

	bool m_panning = false;    // Ctrl + drag to scroll
	QPoint m_pressPos;
	int m_pressViewStart = 0;
};

// The panel widget wrapper. Channel (objectName) sets the table number,
// channel2 (objectName2) sets/reads the cursor position (in frames).
class QuteWaveform : public QuteWidget
{
	Q_OBJECT
public:
	QuteWaveform(QWidget *parent);
	~QuteWaveform() override;

	QString getWidgetLine() override { return QString(); }
	QString getWidgetXmlText() override;
	QString getWidgetType() override { return QString("BSBWaveform"); }
	QuteWidgetType getWidgetTypeID() override { return QuteWidgetType::WAVEFORM; }

	void setCsoundUserData(CsoundUserData *ud) override;
	void setValue(double value) override;   // table number
	void setValue2(double value) override;  // cursor position (frames)
	void setValue(QString s) override;
	void refreshWidget() override;
	void applyInternalProperties() override;
	bool applyProperty(const QString &name) override;

public slots:
	void onStop();
	void updateData();       // periodic refresh while running
	void cursorMoved(int pos);

private:
	int m_tabnum = 0;
	bool m_forceRefresh = false;  // negative value requests a redraw
	QPointer<CsoundEngine> m_registeredEngine;  // engine the snapshot callback is registered with
	QLineEdit *name2LineEdit = nullptr;
	SelectColorButton *colorButton = nullptr;
	SelectColorButton *bgColorButton = nullptr;
	SelectColorButton *cursorColorButton = nullptr;
	QCheckBox *bgColorCheckBox = nullptr;
	QCheckBox *showGridCheckBox = nullptr;
	QCheckBox *showAxesCheckBox = nullptr;
	QCheckBox *autoRangeCheckBox = nullptr;
	QSpinBox *tableSpinBox = nullptr;
	QSpinBox *channelsSpinBox = nullptr;
	QDoubleSpinBox *rangeSpinBox = nullptr;

protected:
	void createPropertiesDialog() override;
	void applyProperties() override;
};

#endif // QUTEWAVEFORM_H
