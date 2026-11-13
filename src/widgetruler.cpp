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

#include "widgetruler.h"
#include "bundledfonts.h"

#include <QFontMetrics>
#include <QPainter>

#include <algorithm>
#include <cmath>

using namespace Qt::StringLiterals;

WidgetRuler::Mode WidgetRuler::modeFromString(const QString &mode)
{
	const QString m = mode.trimmed().toLower();
	if (m == "hide"_L1) {
		return Hide;
	}
	if (m == "compact"_L1) {
		return Compact;
	}
	return Full;
}

QString WidgetRuler::modeToString(Mode mode)
{
	switch (mode) {
	case Hide:
		return u"hide"_s;
	case Compact:
		return u"compact"_s;
	case Full:
	default:
		return u"full"_s;
	}
}

QFont WidgetRuler::rulerFont()
{
	QFont font;
	font.setFamily(BundledFonts::rulerFamily());
	font.setPixelSize(BundledFonts::rulerPixelSize());
	return font;
}

WidgetRuler::Geometry WidgetRuler::layout(const QRectF &full, bool vertical,
                                          Mode mode, const QString &minLabel,
                                          const QString &maxLabel,
                                          const QString &widestLabel)
{
	Geometry geometry;
	geometry.full = full;
	geometry.vertical = vertical;

	const QFontMetrics fm(rulerFont());
	const int minLabelWidth = fm.horizontalAdvance(minLabel);
	const int maxLabelWidth = fm.horizontalAdvance(maxLabel);
	const int labelLen = widestLabel.isEmpty()
			? qMax(minLabelWidth, maxLabelWidth)
			: fm.horizontalAdvance(widestLabel);
	int rulerSize = 0;
	if (mode != Hide) {
		rulerSize = vertical ? labelLen + 6 : fm.height() + 4;
	}

	// Leave half a ruler label at both ends (top+bottom for a vertical ruler,
	// left+right for a horizontal one) so the extreme labels can be centred on
	// their ticks without being clipped by the widget edge.
	QRectF meter = full;
	if (vertical) {
		const int margin = (mode != Hide) ? (fm.height() + 1) / 2 : 0;
		meter.setTop(full.top() + margin);
		meter.setHeight(full.height() - 2 * margin);
	} else {
		const int margin = (mode != Hide) ? (labelLen + 1) / 2 : 0;
		meter.setLeft(full.left() + margin);
		meter.setRight(full.right() - margin);
	}

	// Reserve ruler space only if the bar remains usable; otherwise the labels
	// would be clipped anyway and the bar would vanish.
	QRectF bar = meter;
	geometry.labels = (mode != Hide);
	if (mode != Hide) {
		if (vertical) {
			if (meter.width() - rulerSize >= 4) {
				bar.setWidth(meter.width() - rulerSize);
			} else {
				geometry.labels = false;
			}
		} else {
			if (meter.height() - rulerSize >= 4) {
				bar.setHeight(meter.height() - rulerSize);
			} else {
				geometry.labels = false;
			}
		}
	}
	if (bar.width() < 1 || bar.height() < 1) {
		return geometry;
	}

	geometry.bar = bar;
	// The scale (fill and ticks) maps onto the border rows themselves, so both
	// the minimum and maximum ticks line up with the inner edge of the bar.
	// (QRectF::bottom()/right() are one past the last pixel, hence the -1.)
	geometry.scale = bar.adjusted(0, 0, -1, -1);
	if (geometry.scale.width() < 1 || geometry.scale.height() < 1) {
		geometry.scale = bar;
	}
	geometry.valid = true;
	return geometry;
}

double WidgetRuler::niceStep(double minimum, double maximum, int targetTicks)
{
	const double span = maximum - minimum;
	if (!std::isfinite(span) || span <= 0.0) {
		return 0.0;
	}
	targetTicks = qMax(2, targetTicks);
	const double raw = span / targetTicks;
	const double magnitude = std::pow(10.0, std::floor(std::log10(raw)));
	const double normalized = raw / magnitude;
	double nice = 10.0;
	if (normalized <= 1.0) {
		nice = 1.0;
	} else if (normalized <= 2.0) {
		nice = 2.0;
	} else if (normalized <= 2.5) {
		nice = 2.5;
	} else if (normalized <= 5.0) {
		nice = 5.0;
	}
	return nice * magnitude;
}

QVector<double> WidgetRuler::niceTicks(double minimum, double maximum,
                                       int targetTicks)
{
	QVector<double> values;
	const double step = niceStep(minimum, maximum, targetTicks);
	if (step <= 0.0) {
		values << minimum;
		return values;
	}

	const double epsilon = step * 1e-9;
	double value = std::ceil((minimum - epsilon) / step) * step;
	// Guard against a huge number of ticks if the range/step combination is
	// degenerate (e.g. extremely small step with an extreme range).
	const int maxTicks = qMax(2, targetTicks) * 20;
	for (int i = 0; i < maxTicks && value <= maximum + epsilon; ++i) {
		if (value >= minimum - epsilon) {
			values << value;
		}
		value += step;
	}
	return values;
}

int WidgetRuler::decimalsForStep(double step)
{
	if (!std::isfinite(step) || step <= 0.0) {
		return 0;
	}
	for (int decimals = 0; decimals <= 9; ++decimals) {
		const double scaled = step * std::pow(10.0, decimals);
		if (std::abs(scaled - std::round(scaled)) < 1e-6) {
			return decimals;
		}
	}
	return 9;
}

QVector<double> WidgetRuler::dbMajorTicks()
{
	return { -120.0, -100.0, -90.0, -80.0, -70.0, -60.0, -50.0, -40.0,
	         -30.0, -24.0, -20.0, -16.0, -12.0, -9.0, -6.0, -3.0,
	         0.0, 3.0, 6.0, 9.0, 12.0, 18.0, 24.0, 30.0, 36.0, 42.0, 48.0 };
}

QString WidgetRuler::dbLabel(double db)
{
	// Ruler labels drop the minus sign and mark positive values with '+'.
	const double a = qAbs(db);
	const QString magnitude = (a == qRound(a)) ? QString::number(qRound(a))
	                                            : QString::number(a, 'f', 1);
	if (db > 0.0) {
		return u"+"_s + magnitude;
	}
	return magnitude; // negative sign dropped, zero stays "0"
}

void WidgetRuler::draw(QPainter &painter, const Geometry &geometry, Mode mode,
                       const QColor &color, const ValueMapping &mapping,
                       const ValueFormatter &formatter,
                       const QVector<double> &candidates,
                       const QVector<double> &alwaysLabel,
                       const MinorGenerator &minorGenerator,
                       double majorStep, int minorSubdivisions,
                       bool discreteMinorTicks)
{
	if (!geometry.valid || mode == Hide) {
		return;
	}

	// Rulers are drawn at pixel coordinates and must stay crisp. The slider
	// paints with antialiasing for its rounded body, while the VU meter turns
	// it off globally; disable it here so both widgets render identical ticks
	// and labels regardless of their caller's painter state.
	painter.save();
	painter.setRenderHint(QPainter::Antialiasing, false);

	const bool vertical = geometry.vertical;
	const QRectF &full = geometry.full;
	const QRectF &bar = geometry.bar;
	const QRectF &scale = geometry.scale;

	QFont font = rulerFont();
	painter.setFont(font);
	painter.setPen(color);
	const QFontMetrics fm(font);

	auto tickPos = [&](double value) -> double {
		const double f = mapping.toPosition(value);
		return vertical ? scale.bottom() - f * scale.height()
		                : scale.left() + f * scale.width();
	};
	auto drawTickAt = [&](double t, int len) {
		const int ti = qRound(t);
		if (vertical) {
			painter.drawLine(QPointF(bar.right(), ti), QPointF(bar.right() + len, ti));
		} else {
			painter.drawLine(QPointF(ti, bar.bottom()), QPointF(ti, bar.bottom() + len));
		}
	};

	const double epsilon = 1e-9 * qMax(1.0, qAbs(mapping.maximum - mapping.minimum));
	const bool regularGrid = majorStep > 0.0 && std::isfinite(majorStep);

	// Major tick positions: either a regular grid at `majorStep`, or the
	// caller's candidate values. The minimum and maximum are always included.
	QVector<double> majors;
	auto addMajor = [&](double value) {
		if (value < mapping.minimum - epsilon || value > mapping.maximum + epsilon) {
			return;
		}
		for (double existing : majors) {
			if (qAbs(existing - value) < epsilon) {
				return;
			}
		}
		majors << value;
	};
	if (regularGrid) {
		double value = std::ceil((mapping.minimum - epsilon) / majorStep) * majorStep;
		const int maxTicks = 5000;
		for (int i = 0; i < maxTicks && value <= mapping.maximum + epsilon; ++i) {
			addMajor(value);
			value += majorStep;
		}
	} else {
		for (double value : candidates) {
			addMajor(value);
		}
	}
	addMajor(mapping.minimum);
	addMajor(mapping.maximum);
	std::sort(majors.begin(), majors.end());

	// Decide which ticks are labelled. Min and max are always labelled; the
	// rest are dropped if they would overlap.
	QVector<double> labelled;
	QVector<double> labelledPos;
	const double labelSpacing = vertical ? fm.height()
	                                     : fm.horizontalAdvance(u"-000"_s);
	auto positionAlreadyLabelled = [&](double t) {
		for (double p : labelledPos) {
			if (qAbs(t - p) < 1e-6) {
				return true;
			}
		}
		return false;
	};
	auto tryLabel = [&](double value) {
		const double t = tickPos(value);
		for (double p : labelledPos) {
			if (qAbs(t - p) < labelSpacing) {
				return;
			}
		}
		labelled << value;
		labelledPos << t;
	};
	tryLabel(mapping.maximum);
	tryLabel(mapping.minimum);
	// Values that must always be shown when they are in range.
	for (double value : alwaysLabel) {
		if (value < mapping.minimum - epsilon || value > mapping.maximum + epsilon) {
			continue;
		}
		const double t = tickPos(value);
		if (!positionAlreadyLabelled(t)) {
			labelled << value;
			labelledPos << t;
		}
	}
	for (double value : majors) {
		if (qAbs(value - mapping.minimum) < epsilon
		        || qAbs(value - mapping.maximum) < epsilon) {
			continue;
		}
		tryLabel(value);
	}
	std::sort(labelled.begin(), labelled.end());

	if (regularGrid) {
		// Minor ticks are a regular subdivision of each major interval. On a
		// skewed scale some intervals are much shorter than others, so decide
		// per interval how many subdivisions actually fit with at least 5
		// pixels between ticks. On a linear scale use the same count for every
		// interval, so floating-point rounding cannot make the ruler alternate
		// between "has minor ticks" and "has none".
		if (mode == Full && minorSubdivisions > 1) {
			const double minMinorSpacing = 5.0;
			const bool linearScale = qAbs(mapping.exponent - 1.0) < 1e-9;
			for (int i = 0; i + 1 < majors.size(); ++i) {
				const double a = majors[i];
				const double b = majors[i + 1];
				if (b <= a + epsilon) {
					continue;
				}
				const double pixelGap = qAbs(tickPos(b) - tickPos(a));
				int subdivisions = minorSubdivisions;
				if (!linearScale) {
					// Fit as many equal parts as possible, up to the global
					// maximum. A narrow interval may fit only one minor tick.
					subdivisions = qMin(minorSubdivisions,
					                    static_cast<int>((pixelGap + 1e-6)
					                                     / minMinorSpacing));
					while (subdivisions >= 2
					       && pixelGap / subdivisions < minMinorSpacing - 1e-6) {
						--subdivisions;
					}
				}
				if (subdivisions < 2) {
					continue;
				}
				for (int j = 1; j < subdivisions; ++j) {
					const double value = a + (b - a) * j / subdivisions;
					drawTickAt(tickPos(value), 2);
				}
			}
		}
		// Every major tick is drawn long, even when a label had to be dropped
		// to avoid overlap.
		for (double value : majors) {
			drawTickAt(tickPos(value), 4);
		}
	} else {
		// Candidate-based behaviour (used by the VU meter's dB scale).
		if (mode == Full && labelled.size() > 1) {
			if (discreteMinorTicks) {
				// Legacy dB/VU ruler: use regular integer dB steps between two
				// labelled values, choosing the finest divisor that keeps the
				// ticks at least 8 pixels apart. This must stay separate from
				// the adaptive, equal-pixel subdivisions used by the slider.
				const double minTickSpacing = 8.0;
				for (int i = 0; i + 1 < labelled.size(); ++i) {
					const double a = labelled[i];
					const double b = labelled[i + 1];
					const int gapDb = qRound(b - a);
					if (gapDb <= 1 || qAbs((b - a) - gapDb) > 1e-6) {
						continue;
					}
					int step = 0;
					for (int s = 1; s < gapDb; ++s) {
						if (gapDb % s != 0) {
							continue;
						}
						if (qAbs(tickPos(a + s) - tickPos(a)) >= minTickSpacing) {
							step = s;
							break;
						}
					}
					if (step > 0) {
						for (double value = a + step; value < b - 1e-6;
						     value += step) {
							drawTickAt(tickPos(value), 2);
						}
					}
				}
			} else {
				QVector<double> minor;
				for (int i = 0; i + 1 < labelled.size(); ++i) {
					const double a = labelled[i];
					const double b = labelled[i + 1];
					if (minorGenerator) {
						minor += minorGenerator(a, b);
					} else {
						for (int j = 1; j < 5; ++j) {
							minor << a + (b - a) * j / 5.0;
						}
					}
				}
				std::sort(minor.begin(), minor.end());

				const double minTickSpacing = 8.0;
				double lastTick = -1e9;
				for (double value : minor) {
					if (value <= mapping.minimum + epsilon
					        || value >= mapping.maximum - epsilon) {
						continue;
					}
					const double t = tickPos(value);
					bool nearLabel = false;
					for (double p : labelledPos) {
						if (qAbs(t - p) < 1.0) {
							nearLabel = true;
							break;
						}
					}
					if (nearLabel || qAbs(t - lastTick) < minTickSpacing) {
						continue;
					}
					drawTickAt(t, 2);
					lastTick = t;
				}
			}
		}

		// Candidate-based rulers only draw long ticks for labelled values.
		for (double value : labelled) {
			drawTickAt(tickPos(value), 4);
		}
	}

	// Labels, with the tick at the exact centre of the number.
	if (geometry.labels) {
		for (double value : labelled) {
			const QString text = formatter ? formatter(value)
			                               : QString::number(value);
			const double t = tickPos(value);
			const QRectF br = fm.boundingRect(text);
			if (vertical) {
				double baseline = t - br.center().y();
				baseline = qBound(full.top() - br.top(),
				                  baseline,
				                  full.bottom() - br.bottom());
				painter.drawText(QPointF(qRound(bar.right() + 6), qRound(baseline)), text);
			} else {
				const double adv = fm.horizontalAdvance(text);
				double x = t - adv / 2.0;
				x = qBound(full.left(), x, full.right() - adv);
				const double baseline = bar.bottom() + 6 + fm.ascent();
				painter.drawText(QPointF(qRound(x), qRound(baseline)), text);
			}
		}
	}

	painter.restore();
}
