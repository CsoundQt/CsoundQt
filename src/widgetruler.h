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

#ifndef WIDGETRULER_H
#define WIDGETRULER_H

#include "valuemapping.h"

#include <QColor>
#include <QFont>
#include <QRectF>
#include <QString>
#include <QVector>

#include <functional>

class QPainter;

// A value ruler shared by widgets that draw a scale (the VU meter and the flat
// slider). It reserves space for the labels beside a bar, then draws labelled
// major ticks and, in Full mode, minor ticks.
class WidgetRuler
{
public:
	enum Mode { Hide, Full, Compact };

	using ValueFormatter = std::function<QString(double)>;
	// Returns intermediate tick values strictly between a and b.
	using MinorGenerator = std::function<QVector<double>(double a, double b)>;

	struct Geometry {
		QRectF full;
		QRectF bar;      // area left for the bar, after reserving ruler space
		QRectF scale;    // bar minus its last row/column (tick anchor area)
		bool vertical = true;
		bool labels = false; // labels fit beside the bar
		bool valid = false;
	};

	static Mode modeFromString(const QString &mode);
	static QString modeToString(Mode mode);

	// The pixel font used for ruler labels.
	static QFont rulerFont();

	// Split `full` into the bar and the ruler area. `widestLabel` is used to
	// reserve enough room for the labels; when empty, the wider of `minLabel`
	// and `maxLabel` is used. Intermediate labels can be longer than both ends
	// (e.g. "0.2" between "0" and "1"), so callers with such a scale should
	// pass the actual widest label.
	static Geometry layout(const QRectF &full, bool vertical, Mode mode,
	                       const QString &minLabel, const QString &maxLabel,
	                       const QString &widestLabel = QString());

	// A "nice" step (1, 2, 2.5 or 5 times a power of ten) for a scale.
	static double niceStep(double minimum, double maximum, int targetTicks = 6);
	// Candidate major tick values at nice steps inside the range.
	static QVector<double> niceTicks(double minimum, double maximum,
	                                 int targetTicks = 6);
	// Number of decimals needed to print values spaced by `step`.
	static int decimalsForStep(double step);

	// Draw the ruler ticks and labels. `candidates` are the possible major tick
	// values; the minimum and maximum are added automatically. Values listed in
	// `alwaysLabel` are labelled even if they are close to another label. The
	// optional `minorGenerator` supplies the minor ticks of Full mode.
	// When `majorStep` is positive the ticks form a regular grid at that value
	// interval (the minimum and maximum are added as well). Minor ticks then
	// subdivide each interval into `minorSubdivisions` equal parts; an interval
	// whose minor ticks would be closer than 5 pixels is left without them.
	// When `majorStep` is zero the caller's candidate values are used instead
	// (the VU meter's dB scale).
	static void draw(QPainter &painter, const Geometry &geometry, Mode mode,
	                 const QColor &color, const ValueMapping &mapping,
	                 const ValueFormatter &formatter,
	                 const QVector<double> &candidates,
	                 const QVector<double> &alwaysLabel = {},
	                 const MinorGenerator &minorGenerator = {},
	                 double majorStep = 0.0, int minorSubdivisions = 0);
};

#endif // WIDGETRULER_H
