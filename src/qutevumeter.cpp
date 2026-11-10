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
#include "widgetruler.h"

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

static WidgetRuler::Mode toWidgetRulerMode(VUMeterWidget::RulerMode mode)
{
	switch (mode) {
	case VUMeterWidget::RulerHide:
		return WidgetRuler::Hide;
	case VUMeterWidget::RulerCompact:
		return WidgetRuler::Compact;
	case VUMeterWidget::RulerFull:
	default:
		return WidgetRuler::Full;
	}
}

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

	QVector<double> dbCandidates;
	for (double db : kNiceDbLabels) {
		dbCandidates << db;
	}

	// Reserve space for the widest candidate label, not only the two ends.
	const QFontMetrics labelMetrics(WidgetRuler::rulerFont());
	QString widestLabel = rulerLabelForDb(m_min);
	int widestWidth = labelMetrics.horizontalAdvance(widestLabel);
	auto considerLabel = [&](const QString &text) {
		const int width = labelMetrics.horizontalAdvance(text);
		if (width > widestWidth) {
			widestLabel = text;
			widestWidth = width;
		}
	};
	considerLabel(rulerLabelForDb(m_max));
	for (double db : dbCandidates) {
		if (db >= m_min && db <= m_max) {
			considerLabel(rulerLabelForDb(db));
		}
	}

	const WidgetRuler::Geometry rulerGeometry = WidgetRuler::layout(
			full, vertical, toWidgetRulerMode(m_rulerMode),
			rulerLabelForDb(m_min), rulerLabelForDb(m_max), widestLabel);
	if (!rulerGeometry.valid) {
		return;
	}
	const QRectF bar = rulerGeometry.bar;
	const QRectF scale = rulerGeometry.scale;

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
	// labelled. The drawing itself is shared with the flat slider.
	if (m_rulerMode != RulerHide) {
		auto minorDbTicks = [](double a, double b) {
			QVector<double> ticks;
			const int gapDb = qRound(b - a);
			if (gapDb <= 1 || qAbs((b - a) - gapDb) > 1e-6) {
				return ticks;
			}
			for (int i = 1; i < gapDb; ++i) {
				ticks << a + i;
			}
			return ticks;
		};
		WidgetRuler::draw(p, rulerGeometry, toWidgetRulerMode(m_rulerMode),
		                  m_rulerColor, ValueMapping{m_min, m_max, m_exponent},
		                  [this](double db) { return rulerLabelForDb(db); },
		                  dbCandidates, {0.0}, minorDbTicks);
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

	int row = 2;

	QLabel *label = new QLabel("Min (dB) =", dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight | Qt::AlignVCenter);

	minSpinBox = new QSpinBox(dialog);
	minSpinBox->setRange(-200, 200);
	minSpinBox->setValue(qRound(property("CSQT_minimum").toDouble()));
	layout->addWidget(minSpinBox, row, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Max (dB) =", dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight | Qt::AlignVCenter);

	maxSpinBox = new QSpinBox(dialog);
	maxSpinBox->setRange(-200, 200);
	maxSpinBox->setValue(qRound(property("CSQT_maximum").toDouble()));
	layout->addWidget(maxSpinBox, row, 3, Qt::AlignLeft | Qt::AlignVCenter);
	++row;

	// Row 3 is the common channel row.
	row = 4;

	label = new QLabel(tr("Ruler ="), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight | Qt::AlignVCenter);

	rulerComboBox = new QComboBox(dialog);
	rulerComboBox->addItem(tr("Hide"), u"hide"_s);
	rulerComboBox->addItem(tr("Full"), u"full"_s);
	rulerComboBox->addItem(tr("Compact"), u"compact"_s);
	{
		const int modeIndex = rulerComboBox->findData(property("CSQT_rulermode").toString());
		rulerComboBox->setCurrentIndex(modeIndex >= 0 ? modeIndex : 1);
	}
	layout->addWidget(rulerComboBox, row, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Scale exponent =", dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight | Qt::AlignVCenter);

	exponentSpinBox = new QDoubleSpinBox(dialog);
	exponentSpinBox->setDecimals(2);
	exponentSpinBox->setRange(0.10, 4.00);
	exponentSpinBox->setSingleStep(0.05);
	exponentSpinBox->setValue(property("CSQT_exponent").toDouble());
	exponentSpinBox->setToolTip("Skew of the dB scale: 1 is linear in dB, "
	                            "0.5 gives the top of the scale more room");
	layout->addWidget(exponentSpinBox, row, 3, Qt::AlignLeft | Qt::AlignVCenter);
	++row;

	label = new QLabel("Ruler color", dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight | Qt::AlignVCenter);

	rulerColorButton = new SelectColorButton(dialog);
	rulerColorButton->setColor(QColor(property("CSQT_rulercolor").toString()));
	layout->addWidget(rulerColorButton, row, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Background", dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight | Qt::AlignVCenter);

	bgColorButton = new SelectColorButton(dialog);
	bgColorButton->setColor(property("CSQT_bgcolor").value<QColor>());
	layout->addWidget(bgColorButton, row, 3, Qt::AlignLeft | Qt::AlignVCenter);
	++row;

	bgColorCheckBox = new QCheckBox(tr("On"), dialog);
	bgColorCheckBox->setChecked(property("CSQT_bgcolormode").toBool());
	layout->addWidget(bgColorCheckBox, row, 1, Qt::AlignLeft | Qt::AlignVCenter);
	connect(bgColorCheckBox, SIGNAL(toggled(bool)), bgColorButton, SLOT(setEnabled(bool)));
	bgColorButton->setEnabled(bgColorCheckBox->isChecked());

	label = new QLabel("Border color", dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight | Qt::AlignVCenter);

	borderColorButton = new SelectColorButton(dialog);
	borderColorButton->setColor(property("CSQT_bordercolor").value<QColor>());
	layout->addWidget(borderColorButton, row, 3, Qt::AlignLeft | Qt::AlignVCenter);
	++row;

	label = new QLabel("Cursor channel =", dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight | Qt::AlignVCenter);

	cursorChannelLineEdit = new QLineEdit(dialog);
	cursorChannelLineEdit->setText(m_channel2);
	cursorChannelLineEdit->setToolTip("Optional second channel (same dB range) shown as a "
	                                  "cursor line: horizontal for a vertical meter, "
	                                  "vertical otherwise");
	layout->addWidget(cursorChannelLineEdit, row, 1, 1, 3, Qt::AlignLeft | Qt::AlignVCenter);
	++row;

	label = new QLabel("Cursor color", dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight | Qt::AlignVCenter);

	cursorColorButton = new SelectColorButton(dialog);
	cursorColorButton->setColor(QColor(property("CSQT_cursorcolor").toString()));
	layout->addWidget(cursorColorButton, row, 1, Qt::AlignLeft | Qt::AlignVCenter);

	label = new QLabel("Cursor width =", dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight | Qt::AlignVCenter);

	cursorWidthSpinBox = new QSpinBox(dialog);
	cursorWidthSpinBox->unsetLocale();
	cursorWidthSpinBox->setRange(1, 20);
	cursorWidthSpinBox->setValue(property("CSQT_cursorwidth").toInt());
	layout->addWidget(cursorWidthSpinBox, row, 3, Qt::AlignLeft | Qt::AlignVCenter);
	++row;

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
