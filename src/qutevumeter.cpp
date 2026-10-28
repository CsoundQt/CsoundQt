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

#include "qutevumeter.h"
#include "bundledfonts.h"

#include <algorithm>
#include <cmath>

#include <QPainter>
#include <QLinearGradient>
#include <QFontMetrics>
#include <QXmlStreamWriter>
#include <QGridLayout>
#include <QLabel>
#include <QDoubleSpinBox>
#include <QSpinBox>
#include <QCheckBox>
#include <QComboBox>
#include <QLineEdit>
using namespace Qt::StringLiterals;

// ------------------------------------------------------ VUMeterWidget

// dB values that DAW-style meters commonly label (finer near 0 dB). Only those
// inside the configured range are shown; min and max are always labelled.
static const double kNiceDbLabels[] = {
	-120.0, -100.0, -90.0, -80.0, -70.0, -60.0, -50.0, -40.0, -30.0,
	-24.0, -20.0, -16.0, -12.0, -9.0, -6.0, -3.0,
	0.0, 3.0, 6.0, 9.0, 12.0, 18.0, 24.0, 30.0, 36.0, 42.0, 48.0
};

VUMeterWidget::VUMeterWidget(QWidget *parent) : QWidget(parent)
{
	setFocusPolicy(Qt::NoFocus);
	setMouseTracking(false);
	setAttribute(Qt::WA_TransparentForMouseEvents, true); // output only
}

double VUMeterWidget::fractionForDb(double db) const
{
	// The dB scale is already logarithmic; this adds a further (configurable)
	// skew so the top of the scale gets more room, as on DAW meters.
	return ValueMapping{ m_min, m_max, m_exponent }.toPosition(db);
}

QString VUMeterWidget::rulerLabelForDb(double db) const
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

void VUMeterWidget::paintEvent(QPaintEvent * /*event*/)
{
	QPainter p(this);
	p.setRenderHint(QPainter::Antialiasing, false);

	const bool vertical = isVertical();
	const QRectF full = rect();

	QFont rulerFont = font();
	rulerFont.setFamily(BundledFonts::rulerFamily());
	rulerFont.setPixelSize(BundledFonts::rulerPixelSize());
	// ProggyClean is a pixel font: turn off antialiasing and hint fully so it
	// stays crisp instead of being smoothed/rescaled.
	rulerFont.setStyleStrategy(QFont::NoAntialias);
	rulerFont.setHintingPreference(QFont::PreferFullHinting);
	const QFontMetrics rulerFm(rulerFont);

	// Space taken by the ruler labels.
	int rulerSize = 0;
	if (m_rulerMode != RulerHide) {
		const int labelLen = qMax(rulerFm.horizontalAdvance(rulerLabelForDb(m_min)),
		                          rulerFm.horizontalAdvance(rulerLabelForDb(m_max)));
		rulerSize = vertical ? labelLen + 6 : rulerFm.height() + 4;
	}

	// The meter fills the widget, but leave half a ruler label at both ends
	// (top+bottom for a vertical meter, left+right for a horizontal one) so the
	// extreme labels (min and max) can be centred on their ticks without being
	// clipped by the widget edge.
	QRectF meter = full;
	if (vertical) {
		const int margin = (m_rulerMode != RulerHide) ? (rulerFm.height() + 1) / 2 : 0;
		meter.setTop(full.top() + margin);
		meter.setHeight(full.height() - 2 * margin);
	} else {
		const int margin = (m_rulerMode != RulerHide)
				? (rulerFm.horizontalAdvance(rulerLabelForDb(m_min))
				   + 1) / 2 : 0;
		meter.setLeft(full.left() + margin);
		meter.setRight(full.right() - margin);
	}

	// Reserve ruler space only if the bar remains usable; otherwise the labels
	// would be clipped anyway and the bar would vanish.
	QRectF bar = meter;
	bool drawRulerLabels = (m_rulerMode != RulerHide);
	if (m_rulerMode != RulerHide) {
		if (vertical) {
			if (meter.width() - rulerSize >= 4) {
				bar.setWidth(meter.width() - rulerSize);
			} else {
				drawRulerLabels = false;
			}
		} else {
			if (meter.height() - rulerSize >= 4) {
				bar.setHeight(meter.height() - rulerSize);
			} else {
				drawRulerLabels = false;
			}
		}
	}
	if (bar.width() < 1 || bar.height() < 1) {
		return;
	}

	// The scale (fill and ticks) maps onto the border rows themselves, so both
	// the minimum and maximum ticks line up with the inner edge of the meter.
	// (QRectF::bottom()/right() are one past the last pixel, hence the -1.)
	QRectF scale = bar.adjusted(0, 0, -1, -1);
	if (scale.width() < 1 || scale.height() < 1) {
		scale = bar;
	}

	// Meter background.
	if (m_drawBackground) {
		p.fillRect(bar, m_bgColor);
	}

	// Disabled: grey only the meter bar (not the ruler area) and show no value.
	const bool enabled = isEnabled();
	if (!enabled) {
		QuteWidget::paintDisabledOverlay(p, bar.toRect());
	}

	// Filled portion. The gradient depends only on the range/exponent and the
	// scale rect (not on the value), so it is cached and rebuilt only when one
	// of those changes.
	if (enabled) {
		const double frac = fractionForDb(m_value);
		QRectF fillRect = scale;
		if (vertical) {
			fillRect.setTop(scale.bottom() - scale.height() * frac);
		} else {
			fillRect.setWidth(scale.width() * frac);
		}
		if (!m_gradientValid || m_gradMin != m_min || m_gradMax != m_max
		        || m_gradExp != m_exponent || m_gradRect != scale
		        || m_gradVertical != vertical) {
			QLinearGradient grad;
			if (vertical) {
				grad = QLinearGradient(scale.left(), scale.bottom(), scale.left(), scale.top());
			} else {
				grad = QLinearGradient(scale.left(), scale.top(), scale.right(), scale.top());
			}
			// Colour stops are anchored to dB values (not to fractions of the bar),
			// so a colour always corresponds to the same dB regardless of the skew:
			// green up to -18 dB, yellow around -6 dB, red at/above 0 dB.
			QVector<QPair<double, QColor>> stops;
			// Adds an interior stop only when the dB value lies inside the range
			// (the endpoints are added explicitly below).
			auto addStop = [&](double db, const QColor &color) {
				if (db > m_min && db <= m_max) {
					stops << qMakePair(db, color);
				}
			};
			stops << qMakePair(m_min, QColor(40, 50, 56));
			addStop(-90.0, QColor(40, 50, 56));
			addStop(-60.0, QColor(55, 71, 79));
			addStop(-48.0, QColor(23, 107, 80));
			addStop(-36.0, QColor(32, 164, 100));
			addStop(-24.0, QColor(101, 200, 74));
			addStop(-18.0, QColor(185, 217, 43));
			addStop(-12.0, QColor(240, 210, 47));
			addStop(-6.0,  QColor(245, 165, 35));
			addStop(-2.0,  QColor(230, 60, 53));
			addStop(0.0,   QColor(255, 23, 68));
			addStop(+12.1, QColor(255, 0, 170));
			stops << qMakePair(m_max, QColor(255, 0, 170));
			std::sort(stops.begin(), stops.end(),
			          [](const QPair<double, QColor> &a, const QPair<double, QColor> &b) {
			              return a.first < b.first;
			          });
			for (const auto &stop : stops) {
				grad.setColorAt(std::clamp(fractionForDb(stop.first), 0.0, 1.0), stop.second);
			}
			m_gradient = grad;
			m_gradMin = m_min;
			m_gradMax = m_max;
			m_gradExp = m_exponent;
			m_gradRect = scale;
			m_gradVertical = vertical;
			m_gradientValid = true;
		}
		p.fillRect(fillRect, m_gradient);
	}

	// Border.
	p.setPen(m_borderColor);
	p.setBrush(Qt::NoBrush);
	p.drawRect(bar.adjusted(0, 0, -1, -1));

	// Ruler: labelled dB ticks (the values DAW meters usually show) plus, in
	// full mode, minor ticks between them. Min, max and 0 dB are always
	// labelled.
	if (m_rulerMode != RulerHide) {
		p.setFont(rulerFont);
		p.setPen(m_rulerColor);

		auto tickPos = [&](double db) -> double {
			const double f = fractionForDb(db);
			return vertical ? scale.bottom() - f * scale.height()
			                : scale.left() + f * scale.width();
		};
		auto drawTickAt = [&](double t, int len) {
			const int ti = qRound(t);
			if (vertical) {
				p.drawLine(QPointF(bar.right(), ti), QPointF(bar.right() + len, ti));
			} else {
				p.drawLine(QPointF(ti, bar.bottom()), QPointF(ti, bar.bottom() + len));
			}
		};

		// Major (candidate) tick positions: the nice dB values inside the
		// range, plus min and max.
		QVector<double> majors;
		for (double db : kNiceDbLabels) {
			if (db >= m_min - 1e-6 && db <= m_max + 1e-6) {
				majors << db;
			}
		}
		if (majors.isEmpty() || qAbs(majors.first() - m_min) > 1e-6) {
			majors.prepend(m_min);
		}
		if (qAbs(majors.last() - m_max) > 1e-6) {
			majors.append(m_max);
		}
		std::sort(majors.begin(), majors.end());

		// Decide which ticks are labelled (and therefore long). Min and max are
		// always labelled; the rest are dropped if they would overlap.
		QVector<double> labelled;
		QVector<double> labelledPos;
		// Minimum spacing between labels along the scale axis.
		const double labelSpacing = vertical ? rulerFm.height()
		                                     : rulerFm.horizontalAdvance(u"-000"_s);
		auto tryLabel = [&](double db) {
			const double t = tickPos(db);
			for (double p : labelledPos) {
				if (qAbs(t - p) < labelSpacing) {
					return;
				}
			}
			labelled << db;
			labelledPos << t;
		};
		tryLabel(m_max);
		tryLabel(m_min);
		// 0 dB is important enough to always be shown when it is in range.
		if (m_min <= 0.0 && m_max >= 0.0) {
			const double t0 = tickPos(0.0);
			bool present = false;
			for (double p : labelledPos) {
				if (qAbs(t0 - p) < 1e-6) {
					present = true;
					break;
				}
			}
			if (!present) {
				labelled << 0.0;
				labelledPos << t0;
			}
		}
		for (double db : majors) {
			if (qAbs(db - m_min) < 1e-6 || qAbs(db - m_max) < 1e-6) {
				continue;
			}
			tryLabel(db);
		}
		std::sort(labelled.begin(), labelled.end());

		// Minor ticks (full ruler only): between two labelled ticks, place them
		// at regular integer dB steps, but only if they stay reasonably apart
		// (>= 8 px). Otherwise a coarser integer step (or none) is used, so the
		// compressed low end of the skewed scale does not fill with ticks.
		if (m_rulerMode == RulerFull) {
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
					for (double db = a + step; db < b - 1e-6; db += step) {
						drawTickAt(tickPos(db), 2);
					}
				}
			}
		}

		// Labelled ticks (long) on top.
		for (double db : labelled) {
			drawTickAt(tickPos(db), 4);
		}

		// Labels, with the tick at the exact centre of the number.
		if (drawRulerLabels) {
			for (double db : labelled) {
				const QString text = rulerLabelForDb(db);
				const double t = tickPos(db);
				const QRectF br = rulerFm.boundingRect(text);
				if (vertical) {
					double baseline = t - br.center().y();
					baseline = qBound(full.top() - br.top(),
					                  baseline,
					                  full.bottom() - br.bottom());
					p.drawText(QPointF(qRound(bar.right() + 6), qRound(baseline)), text);
				} else {
					const double adv = rulerFm.horizontalAdvance(text);
					double x = t - adv / 2.0;
					x = qBound(full.left(), x, full.right() - adv);
					const double baseline = bar.bottom() + 6 + rulerFm.ascent();
					p.drawText(QPointF(qRound(x), qRound(baseline)), text);
				}
			}
		}
	}

	// Cursor (second channel): a line across the meter at the cursor's dB value
	// (horizontal for a vertical meter, vertical otherwise). Drawn on top.
	// Not shown while disabled.
	if (enabled && m_cursorVisible && m_cursor >= m_min && m_cursor <= m_max) {
		const double f = fractionForDb(m_cursor);
		p.setPen(QPen(m_cursorColor, m_cursorWidth));
		if (vertical) {
			const int y = qRound(scale.bottom() - f * scale.height());
			p.drawLine(QPointF(scale.left(), y), QPointF(scale.right(), y));
		} else {
			const int x = qRound(scale.left() + f * scale.width());
			p.drawLine(QPointF(x, scale.top()), QPointF(x, scale.bottom()));
		}
	}
}

// ------------------------------------------------------ QuteVUMeter

static VUMeterWidget::RulerMode rulerModeFromString(const QString &mode)
{
	const QString m = mode.trimmed().toLower();
	if (m == "hide"_L1) {
		return VUMeterWidget::RulerHide;
	}
	if (m == "compact"_L1) {
		return VUMeterWidget::RulerCompact;
	}
	return VUMeterWidget::RulerFull;
}

QuteVUMeter::QuteVUMeter(QWidget *parent) : QuteWidget(parent)
{
	auto w = new VUMeterWidget(this);
	m_widget = w;

	setProperty("CSQT_minimum", -90.0);
	setProperty("CSQT_maximum", 0.0);
	setProperty("CSQT_rulermode", "full");
	setProperty("CSQT_rulercolor", QColor(170, 170, 170).name());
	setProperty("CSQT_exponent", 0.5);
	setProperty("CSQT_cursorcolor", QColor(255, 255, 255).name());
	setProperty("CSQT_cursorwidth", 1);
	setProperty("CSQT_bgcolor", QColor(20, 20, 20));
	setProperty("CSQT_bgcolormode", true);
	setProperty("CSQT_bordercolor", QColor(90, 90, 90));
	// Start empty (at the minimum) until the channel drives a value.
	setValue(property("CSQT_minimum").toDouble());
}

QuteVUMeter::~QuteVUMeter() {}

QuteWidgetType QuteVUMeter::getWidgetTypeID() { return QuteWidgetType::VUMETER; }

void QuteVUMeter::setWidgetGeometry(int x, int y, int width, int height)
{
	QuteWidget::setWidgetGeometry(x, y, width, height);
	m_widget->blockSignals(true);
	m_widget->setGeometry(0, 0, width, height);
	m_widget->blockSignals(false);
	m_widget->update();
}

void QuteVUMeter::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	m_valueChanged = false;
	m_value2Changed = false;
	const double value = m_value;
	const double cursor = m_value2;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	auto w = static_cast<VUMeterWidget *>(m_widget);
	w->setValue(value);
	w->setCursor(cursor);
}

void QuteVUMeter::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
	auto w = static_cast<VUMeterWidget *>(m_widget);
	w->setRange(property("CSQT_minimum").toDouble(), property("CSQT_maximum").toDouble());
	QString rulerMode = property("CSQT_rulermode").toString().trimmed();
	if (rulerMode.isEmpty() && property("CSQT_showruler").isValid()) {
		// Legacy boolean property.
		rulerMode = property("CSQT_showruler").toBool() ? "full" : "hide";
	}
	w->setRulerMode(rulerModeFromString(rulerMode));
	w->setRulerColor(QColor(property("CSQT_rulercolor").toString()));
	w->setExponent(property("CSQT_exponent").toDouble());
	w->setCursorColor(QColor(property("CSQT_cursorcolor").toString()));
	w->setCursorWidth(property("CSQT_cursorwidth").toInt());
	w->setCursorVisible(!m_channel2.isEmpty());
	w->setCursor(m_value2);
	w->setBgColor(property("CSQT_bgcolor").value<QColor>());
	w->setDrawBackground(property("CSQT_bgcolormode").toBool());
	w->setBorderColor(property("CSQT_bordercolor").value<QColor>());
	w->setValue(m_value);
}

bool QuteVUMeter::applyProperty(const QString &name)
{
	auto w = static_cast<VUMeterWidget *>(m_widget);
	if (name == "CSQT_minimum" || name == "CSQT_maximum") {
		w->setRange(property("CSQT_minimum").toDouble(), property("CSQT_maximum").toDouble());
		return true;
	}
	if (name == "CSQT_rulermode") {
		w->setRulerMode(rulerModeFromString(property("CSQT_rulermode").toString()));
		return true;
	}
	if (name == "CSQT_showruler") {
		w->setRulerMode(property("CSQT_showruler").toBool() ? VUMeterWidget::RulerFull
		                                                    : VUMeterWidget::RulerHide);
		return true;
	}
	if (name == "CSQT_rulercolor") {
		w->setRulerColor(QColor(property("CSQT_rulercolor").toString()));
		return true;
	}
	if (name == "CSQT_exponent") {
		w->setExponent(property("CSQT_exponent").toDouble());
		return true;
	}
	if (name == "CSQT_cursorcolor") {
		w->setCursorColor(QColor(property("CSQT_cursorcolor").toString()));
		return true;
	}
	if (name == "CSQT_cursorwidth") {
		w->setCursorWidth(property("CSQT_cursorwidth").toInt());
		return true;
	}
	if (name == "CSQT_bgcolor") {
		w->setBgColor(property("CSQT_bgcolor").value<QColor>());
		return true;
	}
	if (name == "CSQT_bgcolormode") {
		w->setDrawBackground(property("CSQT_bgcolormode").toBool());
		return true;
	}
	if (name == "CSQT_bordercolor") {
		w->setBorderColor(property("CSQT_bordercolor").value<QColor>());
		return true;
	}
	return QuteWidget::applyProperty(name);
}

QString QuteVUMeter::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	s.writeTextElement("minimum", QString::number(property("CSQT_minimum").toDouble(), 'f', 8));
	s.writeTextElement("maximum", QString::number(property("CSQT_maximum").toDouble(), 'f', 8));
	s.writeTextElement("objectName2", m_channel2);
	s.writeTextElement("rulermode", property("CSQT_rulermode").toString());
	s.writeTextElement("rulercolor", property("CSQT_rulercolor").toString());
	s.writeTextElement("exponent", QString::number(property("CSQT_exponent").toDouble(), 'f', 8));
	s.writeTextElement("cursorcolor", property("CSQT_cursorcolor").toString());
	s.writeTextElement("cursorwidth", QString::number(property("CSQT_cursorwidth").toInt()));

	writeColorElement(s, "bgcolor", property("CSQT_bgcolor").value<QColor>());
	s.writeTextElement("bgcolormode", property("CSQT_bgcolormode").toBool() ? "true" : "false");

	writeColorElement(s, "bordercolor", property("CSQT_bordercolor").value<QColor>());

	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

QString QuteVUMeter::getWidgetType()
{
	return QString("BSBVUMeter");
}

void QuteVUMeter::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();

#ifdef USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	dialog->setWindowTitle("VU Meter");

	QLabel *label = new QLabel("Min (dB) =", dialog);
	layout->addWidget(label, 2, 0, Qt::AlignRight | Qt::AlignVCenter);

	minSpinBox = new QSpinBox(dialog);
	minSpinBox->setRange(-200, 200);
	minSpinBox->setValue(qRound(property("CSQT_minimum").toDouble()));
	layout->addWidget(minSpinBox, 2, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Max (dB) =", dialog);
	layout->addWidget(label, 2, 2, Qt::AlignRight | Qt::AlignVCenter);

	maxSpinBox = new QSpinBox(dialog);
	maxSpinBox->setRange(-200, 200);
	maxSpinBox->setValue(qRound(property("CSQT_maximum").toDouble()));
	layout->addWidget(maxSpinBox, 2, 3, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel(tr("Ruler ="), dialog);
	layout->addWidget(label, 4, 0, Qt::AlignRight | Qt::AlignVCenter);

	rulerComboBox = new QComboBox(dialog);
	rulerComboBox->addItem(tr("Hide"), u"hide"_s);
	rulerComboBox->addItem(tr("Full"), u"full"_s);
	rulerComboBox->addItem(tr("Compact"), u"compact"_s);
	{
		const int modeIndex = rulerComboBox->findData(property("CSQT_rulermode").toString());
		rulerComboBox->setCurrentIndex(modeIndex >= 0 ? modeIndex : 1);
	}
	layout->addWidget(rulerComboBox, 4, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Scale exponent =", dialog);
	layout->addWidget(label, 4, 2, Qt::AlignRight | Qt::AlignVCenter);

	exponentSpinBox = new QDoubleSpinBox(dialog);
	exponentSpinBox->setDecimals(2);
	exponentSpinBox->setRange(0.10, 4.00);
	exponentSpinBox->setSingleStep(0.05);
	exponentSpinBox->setValue(property("CSQT_exponent").toDouble());
	exponentSpinBox->setToolTip("Skew of the dB scale: 1 is linear in dB, "
	                            "0.5 gives the top of the scale more room");
	layout->addWidget(exponentSpinBox, 4, 3, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Ruler color", dialog);
	layout->addWidget(label, 5, 0, Qt::AlignRight | Qt::AlignVCenter);

	rulerColorButton = new SelectColorButton(dialog);
	rulerColorButton->setColor(QColor(property("CSQT_rulercolor").toString()));
	layout->addWidget(rulerColorButton, 5, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Background", dialog);
	layout->addWidget(label, 5, 2, Qt::AlignRight | Qt::AlignVCenter);

	bgColorButton = new SelectColorButton(dialog);
	bgColorButton->setColor(property("CSQT_bgcolor").value<QColor>());
	layout->addWidget(bgColorButton, 5, 3, Qt::AlignLeft | Qt::AlignVCenter);

	bgColorCheckBox = new QCheckBox(tr("On"), dialog);
	bgColorCheckBox->setChecked(property("CSQT_bgcolormode").toBool());
	layout->addWidget(bgColorCheckBox, 6, 1, Qt::AlignLeft | Qt::AlignVCenter);
	connect(bgColorCheckBox, SIGNAL(toggled(bool)), bgColorButton, SLOT(setEnabled(bool)));
	bgColorButton->setEnabled(bgColorCheckBox->isChecked());

	label = new QLabel("Border color", dialog);
	layout->addWidget(label, 6, 2, Qt::AlignRight | Qt::AlignVCenter);

	borderColorButton = new SelectColorButton(dialog);
	borderColorButton->setColor(property("CSQT_bordercolor").value<QColor>());
	layout->addWidget(borderColorButton, 6, 3, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Cursor channel =", dialog);
	layout->addWidget(label, 7, 0, Qt::AlignRight | Qt::AlignVCenter);

	cursorChannelLineEdit = new QLineEdit(dialog);
	cursorChannelLineEdit->setText(m_channel2);
	cursorChannelLineEdit->setToolTip("Optional second channel (same dB range) shown as a "
	                                  "cursor line: horizontal for a vertical meter, "
	                                  "vertical otherwise");
	layout->addWidget(cursorChannelLineEdit, 7, 1, 1, 3, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Cursor color", dialog);
	layout->addWidget(label, 8, 0, Qt::AlignRight | Qt::AlignVCenter);

	cursorColorButton = new SelectColorButton(dialog);
	cursorColorButton->setColor(QColor(property("CSQT_cursorcolor").toString()));
	layout->addWidget(cursorColorButton, 8, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Cursor width =", dialog);
	layout->addWidget(label, 8, 2, Qt::AlignRight | Qt::AlignVCenter);

	cursorWidthSpinBox = new QSpinBox(dialog);
	cursorWidthSpinBox->unsetLocale();
	cursorWidthSpinBox->setRange(1, 20);
	cursorWidthSpinBox->setValue(property("CSQT_cursorwidth").toInt());
	layout->addWidget(cursorWidthSpinBox, 8, 3, Qt::AlignLeft | Qt::AlignVCenter);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteVUMeter::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	setProperty("CSQT_minimum", minSpinBox->value());
	setProperty("CSQT_maximum", maxSpinBox->value());
	setProperty("CSQT_rulermode", rulerComboBox->currentData().toString());
	setProperty("CSQT_rulercolor", rulerColorButton->getColor().name());
	setProperty("CSQT_exponent", exponentSpinBox->value());
	setProperty("CSQT_objectName2", cursorChannelLineEdit->text());
	setProperty("CSQT_cursorcolor", cursorColorButton->getColor().name());
	setProperty("CSQT_cursorwidth", cursorWidthSpinBox->value());
	setProperty("CSQT_bgcolor", bgColorButton->getColor());
	setProperty("CSQT_bgcolormode", bgColorCheckBox->isChecked());
	setProperty("CSQT_bordercolor", borderColorButton->getColor());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	QuteWidget::applyProperties(); // Must be last
}
