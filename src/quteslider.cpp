/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

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

#include "quteslider.h"

#include <QFontMetrics>
#include <QMouseEvent>
#include <QPainter>
#include <QPainterPath>

#include <algorithm>
#include <cmath>
#include <utility>

using namespace Qt::StringLiterals;

static QColor colorFromVariant(const QVariant &value)
{
	QColor color = value.value<QColor>();
	if (!color.isValid()) {
		color = QColor(value.toString());
	}
	return color;
}

// ---------------------------------------------------------------------------
//  QuteSliderControl
// ---------------------------------------------------------------------------

QuteSliderControl::QuteSliderControl(QWidget *parent) : QSlider(parent)
{
	setMouseTracking(true);
}

void QuteSliderControl::setFlatStyle(bool enable)
{
	m_flat = enable;
	update();
}

void QuteSliderControl::setBackgroundColor(const QColor &color)
{
	m_background = color;
	update();
}

void QuteSliderControl::setForegroundColor(const QColor &color)
{
	m_foreground = color;
	update();
}

void QuteSliderControl::setFillColor(const QColor &color)
{
	m_fill = color;
	update();
}

void QuteSliderControl::setBorderColor(const QColor &color)
{
	m_border = color;
	update();
}

void QuteSliderControl::setBorder(int width, int radius)
{
	m_borderWidth = qMax(0, width);
	m_borderRadius = qMax(0, radius);
	update();
}

void QuteSliderControl::setThumb(int width, int padding, int radius)
{
	// A zero width is allowed in fill mode, where it hides the thumb. In thumb
	// mode thumbLength() enforces a minimum of one pixel.
	m_thumbWidth = qMax(0, width);
	m_thumbPadding = qMax(0, padding);
	m_thumbRadius = qMax(0, radius);
	update();
}

void QuteSliderControl::setFillMode(bool fill)
{
	m_fillMode = fill;
	update();
}

void QuteSliderControl::setBackgroundMode(BackgroundMode mode)
{
	m_backgroundMode = mode;
}

void QuteSliderControl::setRuler(WidgetRuler::Mode mode, const QColor &color)
{
	m_rulerMode = mode;
	m_rulerColor = color;
	update();
}

void QuteSliderControl::setDisplayRange(double minimum, double maximum)
{
	if (maximum < minimum) {
		std::swap(minimum, maximum);
	}
	m_minimum = minimum;
	m_maximum = maximum;
	update();
}

void QuteSliderControl::setExponent(double exponent)
{
	m_exponent = ValueMapping::validExponent(exponent);
	update();
}

QString QuteSliderControl::formatValue(double value, double step) const
{
	if (!(step > 0.0)) {
		step = WidgetRuler::niceStep(m_minimum, m_maximum);
	}
	const int decimals = WidgetRuler::decimalsForStep(step);
	if (!std::isfinite(value)) {
		value = 0.0;
	}
	if (qAbs(value) < qMax(1e-12, step * 1e-9)) {
		value = 0.0;
	}
	QString text = QString::number(value, 'f', decimals);
	if (decimals > 0) {
		while (text.endsWith(QLatin1Char('0'))) {
			text.chop(1);
		}
		if (text.endsWith(QLatin1Char('.'))) {
			text.chop(1);
		}
	}
	if (text == "-0"_L1 || text.isEmpty()) {
		text = u"0"_s;
	}
	return text;
}

bool QuteSliderControl::isVertical() const
{
	return orientation() == Qt::Vertical;
}

double QuteSliderControl::majorTickStep(double axisLength) const
{
	const double span = m_maximum - m_minimum;
	if (!(span > 0.0) || axisLength <= 0.0) {
		return 0.0;
	}

	// Keep enough room between labels. Vertical labels need a font-height gap;
	// horizontal ones need the width of the widest possible number.
	const QFontMetrics metrics(WidgetRuler::rulerFont());
	const double labelSpacing = isVertical()
			? metrics.height() + 6.0
			: metrics.horizontalAdvance(u"-000.0"_s) + 12.0;
	const int targetTicks = qMax(2, static_cast<int>(axisLength
	                                                / qMax(1.0, labelSpacing)));
	return WidgetRuler::niceStep(m_minimum, m_maximum, targetTicks);
}

int QuteSliderControl::minorSubdivisions(double axisLength,
                                         double majorStep) const
{
	const double span = m_maximum - m_minimum;
	if (!(span > 0.0) || !(majorStep > 0.0) || axisLength <= 0.0) {
		return 1;
	}

	const double pixelsPerMajor = axisLength * majorStep / span;
	const double minTickSpacing = 5.0;
	const int candidates[] = {10, 5, 2};
	for (int subdivisions : candidates) {
		if (pixelsPerMajor / subdivisions >= minTickSpacing) {
			return subdivisions;
		}
	}
	return 1;
}

QString QuteSliderControl::widestRulerLabel(double majorStep) const
{
	// Intermediate labels can be wider than both ends (0.2 between 0 and 1,
	// -0.5 between -1 and 1). Measure the actual major ticks so the ruler
	// reserves enough room and the labels are not clipped to their first
	// character.
	const QFontMetrics metrics(WidgetRuler::rulerFont());
	QString widest = formatValue(m_minimum, majorStep);
	int widestWidth = metrics.horizontalAdvance(widest);
	auto consider = [&](const QString &text) {
		const int width = metrics.horizontalAdvance(text);
		if (width > widestWidth) {
			widest = text;
			widestWidth = width;
		}
	};
	consider(formatValue(m_maximum, majorStep));

	if (majorStep > 0.0) {
		const double epsilon = majorStep * 1e-9;
		double value = std::ceil((m_minimum - epsilon) / majorStep) * majorStep;
		for (int i = 0; i < 5000 && value <= m_maximum + epsilon; ++i) {
			consider(formatValue(value, majorStep));
			value += majorStep;
		}
	} else {
		for (double value : WidgetRuler::niceTicks(m_minimum, m_maximum, 6)) {
			consider(formatValue(value));
		}
	}
	return widest;
}

WidgetRuler::Geometry QuteSliderControl::rulerGeometry() const
{
	// A preliminary layout gives the length available for the scale, which
	// determines how dense the tick grid can be. For a vertical ruler this
	// length does not depend on the label width, so it is exact; horizontally
	// the small end margins make it a close approximation.
	const WidgetRuler::Geometry preliminary = WidgetRuler::layout(
			rect(), isVertical(), m_rulerMode,
			formatValue(m_minimum), formatValue(m_maximum));
	const double axisLength = preliminary.valid
			? (isVertical() ? preliminary.scale.height()
			                : preliminary.scale.width())
			: 0.0;
	const double step = majorTickStep(axisLength);
	const QString minLabel = formatValue(m_minimum, step);
	const QString maxLabel = formatValue(m_maximum, step);

	WidgetRuler::Geometry geometry = WidgetRuler::layout(
			rect(), isVertical(), m_rulerMode, minLabel, maxLabel,
			widestRulerLabel(step));
	if (geometry.valid && m_borderWidth > 0) {
		// The ticks should span the inside of the border, not its outer edge.
		// Without this the maximum tick sits half a border beyond the visible
		// top (and looks one pixel too high).
		QRectF scale = geometry.bar.adjusted(m_borderWidth, m_borderWidth,
		                                     -m_borderWidth, -m_borderWidth);
		if (scale.width() >= 1 && scale.height() >= 1) {
			geometry.scale = scale;
		}
	}
	return geometry;
}

QRectF QuteSliderControl::sliderRect() const
{
	const QRectF full = rect();
	const WidgetRuler::Geometry geometry = rulerGeometry();
	return geometry.valid ? geometry.bar : full;
}

QRectF QuteSliderControl::innerRect(const QRectF &body) const
{
	// The content starts at the inside edge of the border. The pen is centred
	// on the outer path, so a border of width N covers N pixels inwards from
	// the body edge. Insetting by N (not N plus half the pen) avoids the empty
	// one-pixel band between the border and the fill/thumb.
	QRectF inner = body.adjusted(m_borderWidth, m_borderWidth,
	                              -m_borderWidth, -m_borderWidth);
	if (inner.width() < 1 || inner.height() < 1) {
		const double half = m_borderWidth / 2.0;
		inner = body.adjusted(half, half, -half, -half);
	}
	return inner;
}

int QuteSliderControl::thumbLength(const QRectF &inner) const
{
	// In fill mode a width of zero hides the thumb. In thumb mode the thumb
	// must remain visible, so its minimum length is one pixel.
	const int requested = m_fillMode ? m_thumbWidth : qMax(1, m_thumbWidth);
	if (requested <= 0) {
		return 0;
	}
	const double axis = isVertical() ? inner.height() : inner.width();
	const double available = axis - 2 * m_thumbPadding;
	if (available <= 1) {
		return 1;
	}
	return qBound(1, requested, static_cast<int>(available));
}

QRectF QuteSliderControl::thumbRect(const QRectF &inner, double position) const
{
	position = std::clamp(position, 0.0, 1.0);
	const int length = thumbLength(inner);
	const int cross = qMax(1, (isVertical() ? static_cast<int>(inner.width())
	                                       : static_cast<int>(inner.height()))
	                          - 2 * m_thumbPadding);
	const double axis = isVertical() ? inner.height() : inner.width();
	const double travel = qMax(0.0, axis - 2 * m_thumbPadding - length);

	if (isVertical()) {
		const double y = inner.bottom() - m_thumbPadding - length
				- position * travel;
		return QRectF(inner.left() + m_thumbPadding, y, cross, length);
	}
	const double x = inner.left() + m_thumbPadding + position * travel;
	return QRectF(x, inner.top() + m_thumbPadding, length, cross);
}

double QuteSliderControl::positionForPoint(const QRectF &inner,
                                           const QPointF &point) const
{
	const int length = thumbLength(inner);
	const double axis = isVertical() ? inner.height() : inner.width();
	const double travel = qMax(0.0, axis - 2 * m_thumbPadding - length);
	if (travel <= 0.0) {
		return 0.5;
	}
	double position;
	if (isVertical()) {
		position = (inner.bottom() - m_thumbPadding - length / 2.0 - point.y())
				/ travel;
	} else {
		position = (point.x() - (inner.left() + m_thumbPadding + length / 2.0))
				/ travel;
	}
	return std::clamp(position, 0.0, 1.0);
}

double QuteSliderControl::currentPosition() const
{
	const double span = maximum() - minimum();
	if (span <= 0.0) {
		return 0.0;
	}
	return std::clamp((value() - minimum()) / span, 0.0, 1.0);
}

void QuteSliderControl::setPosition(double position)
{
	position = std::clamp(position, 0.0, 1.0);
	const double span = maximum() - minimum();
	if (span <= 0.0) {
		return;
	}
	setValue(minimum() + qRound(position * span));
}

void QuteSliderControl::performBackgroundClick(const QPointF &point)
{
	const QRectF body = sliderRect();
	if (!body.contains(point)) {
		return;
	}
	const QRectF inner = innerRect(body);
	if (inner.width() < 1 || inner.height() < 1) {
		return;
	}

	const double current = currentPosition();
	const double clicked = positionForPoint(inner, point);
	if (m_backgroundMode == Jump) {
		setPosition(clicked);
		return;
	}

	// Nudge: move 10% of the value range towards the click, but never past it.
	const double span = m_maximum - m_minimum;
	if (clicked > current) {
		const double target = mapping().toPosition(
				mapping().toValue(current) + 0.1 * span);
		setPosition(qMin(target, clicked));
	} else if (clicked < current) {
		const double target = mapping().toPosition(
				mapping().toValue(current) - 0.1 * span);
		setPosition(qMax(target, clicked));
	}
}

void QuteSliderControl::paintEvent(QPaintEvent *event)
{
	if (!m_flat) {
		QSlider::paintEvent(event);
		return;
	}

	QPainter painter(this);
	painter.setRenderHint(QPainter::Antialiasing, true);

	const bool enabled = isEnabled();
	const QColor background = enabled ? m_background
	                                  : QuteWidget::disabledColor(m_background);
	const QColor foreground = enabled ? m_foreground
	                                  : QuteWidget::disabledColor(m_foreground);
	QColor fill = m_fill.isValid() ? m_fill : m_foreground;
	if (!enabled) {
		fill = QuteWidget::disabledColor(fill);
	}
	const QColor border = enabled ? m_border
	                              : QuteWidget::disabledColor(m_border);

	const QRectF body = sliderRect();
	if (body.width() < 1 || body.height() < 1) {
		return;
	}

	const double half = m_borderWidth / 2.0;
	const QRectF outer = body.adjusted(half, half, -half, -half);
	const int radius = qBound(0, m_borderRadius,
	                          static_cast<int>(qMin(outer.width(), outer.height()) / 2));

	painter.setPen(Qt::NoPen);
	painter.setBrush(background);
	painter.drawRoundedRect(outer, radius, radius);

	const QRectF inner = innerRect(body);
	const QRectF thumb = thumbRect(inner, currentPosition());

	// Fill/thumb are clipped to the inside of the border so the rounded
	// corners stay clean.
	painter.save();
	QPainterPath clip;
	const int innerRadius = qBound(0, radius - m_borderWidth,
	                               static_cast<int>(qMin(inner.width(), inner.height()) / 2));
	clip.addRoundedRect(inner, innerRadius, innerRadius);
	painter.setClipPath(clip);

	if (m_fillMode) {
		QRectF fillRect = inner;
		if (isVertical()) {
			fillRect.setTop(thumb.center().y());
		} else {
			fillRect.setRight(thumb.center().x());
		}
		painter.fillRect(fillRect, fill);
	}

	// A width of zero hides the thumb in fill mode. The fill above still uses
	// the (zero-size) thumb centre, so the filled part follows the value.
	if (thumb.width() > 0 && thumb.height() > 0) {
		const int thumbRadius = qBound(0, m_thumbRadius,
		                               static_cast<int>(qMin(thumb.width(), thumb.height()) / 2));
		QPainterPath thumbPath;
		thumbPath.addRoundedRect(thumb, thumbRadius, thumbRadius);
		painter.fillPath(thumbPath, foreground);
	}
	painter.restore();

	if (m_borderWidth > 0 && m_border.isValid()) {
		QPen pen(border, m_borderWidth);
		if (m_borderWidth == 1) {
			// Cosmetic pen so a 1px border is not thinned by scaling.
			pen.setWidth(0);
			pen.setCosmetic(true);
		}
		painter.setPen(pen);
		painter.setBrush(Qt::NoBrush);
		painter.drawRoundedRect(outer, radius, radius);
	}

	if (m_rulerMode != WidgetRuler::Hide) {
		const WidgetRuler::Geometry ruler = rulerGeometry();
		if (ruler.valid) {
			const double axisLength = isVertical() ? ruler.scale.height()
			                                       : ruler.scale.width();
			const double step = majorTickStep(axisLength);
			const int subdivisions = minorSubdivisions(axisLength, step);
			WidgetRuler::draw(
					painter, ruler, m_rulerMode, m_rulerColor, mapping(),
					[this, step](double value) { return formatValue(value, step); },
					QVector<double>(), {}, {}, step, subdivisions);
		}
	}
}

void QuteSliderControl::mousePressEvent(QMouseEvent *event)
{
	if (!m_flat) {
		QSlider::mousePressEvent(event);
		return;
	}
	if (!(event->button() & Qt::LeftButton)) {
		return;
	}

	const QPointF pressPoint = event->position();
	const QRectF body = sliderRect();
	if (!body.contains(pressPoint)) {
		return;
	}
	const QRectF inner = innerRect(body);
	if (inner.width() < 1 || inner.height() < 1) {
		return;
	}

	// The value is not changed on press. A press on the thumb, or on the
	// background once the mouse moves, starts a relative drag from the current
	// value. A background press with no movement becomes a click on release.
	m_pressed = true;
	m_dragging = false;
	m_pressedOnThumb = thumbRect(inner, currentPosition()).contains(pressPoint);
	m_pressPoint = pressPoint;
	m_lastPoint = pressPoint;
	m_lastPosition = currentPosition();
	event->accept();
}

void QuteSliderControl::mouseMoveEvent(QMouseEvent *event)
{
	if (!m_flat) {
		QSlider::mouseMoveEvent(event);
		return;
	}
	if (!m_pressed) {
		return;
	}

	if (!m_dragging) {
		// A small movement threshold keeps a less steady click from turning
		// into a drag. Once crossed, the full distance from the press point is
		// used, so the thumb follows the mouse naturally.
		if ((event->position() - m_pressPoint).manhattanLength() < 3.0) {
			return;
		}
		m_dragging = true;
	}

	const QRectF inner = innerRect(sliderRect());
	const int length = thumbLength(inner);
	const double axis = isVertical() ? inner.height() : inner.width();
	const double travel = axis - 2 * m_thumbPadding - length;
	if (travel <= 0.0) {
		return;
	}

	const double scale = (event->modifiers() & Qt::AltModifier) ? 0.25 : 1.0;
	double delta;
	if (isVertical()) {
		delta = (m_lastPoint.y() - event->position().y()) / travel;
	} else {
		delta = (event->position().x() - m_lastPoint.x()) / travel;
	}
	m_lastPosition = std::clamp(m_lastPosition + delta * scale, 0.0, 1.0);
	setPosition(m_lastPosition);
	m_lastPoint = event->position();
	event->accept();
}

void QuteSliderControl::mouseReleaseEvent(QMouseEvent *event)
{
	if (!m_flat) {
		QSlider::mouseReleaseEvent(event);
		return;
	}
	if (!m_pressed) {
		return;
	}

	if (!m_dragging && !m_pressedOnThumb) {
		performBackgroundClick(event->position());
	}
	m_pressed = false;
	m_dragging = false;
	m_pressedOnThumb = false;
	event->accept();
}

void QuteSliderControl::mouseDoubleClickEvent(QMouseEvent *event)
{
	if (!m_flat) {
		QSlider::mouseDoubleClickEvent(event);
		return;
	}
	event->accept();
}

// ---------------------------------------------------------------------------
//  QuteSlider
// ---------------------------------------------------------------------------

QuteSlider::QuteSlider(QWidget *parent) : QuteWidget(parent)
{
	m_widget = new QuteSliderControl(this);

	m_widget->setContextMenuPolicy(Qt::NoContextMenu);
	m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
	canFocus(false);
	if (width() > height())    {
		control()->setOrientation(Qt::Horizontal);
	} else {
		control()->setOrientation(Qt::Vertical);
	}

	connect(control(), SIGNAL(valueChanged(int)), this, SLOT(sliderChanged(int)));

	setProperty("CSQT_minimum", 0.0);
	setProperty("CSQT_maximum", 1.0);
	setProperty("CSQT_value", 0.0);
	setProperty("CSQT_mode", "lin");
	setProperty("CSQT_mouseControl", "continuous");
	setProperty("CSQT_mouseControlAct", "jump");
	setProperty("CSQT_resolution", -1.0);
	setProperty("CSQT_randomizable", false);
	setProperty("CSQT_randomizableGroup", 0);
	setProperty("CSQT_exponent", 1.0);

	// Flat style. Disabled by default, so existing sliders keep the native
	// look. The defaults follow the panel background (light/dark), as the flat
	// button does.
	setProperty("CSQT_flatStyle", false);
	const bool darkPanel = isDarkTheme();
	auto shade = [darkPanel](int r, int g, int b) {
		return darkPanel ? QColor(255 - r, 255 - g, 255 - b) : QColor(r, g, b);
	};
	setProperty("CSQT_bgcolor", shade(0xf3, 0xf3, 0xf3));
	setProperty("CSQT_foreground", shade(0x20, 0x20, 0x20));
	setProperty("CSQT_fillcolor", QString()); // empty = use foreground
	setProperty("CSQT_bordercolor", shade(0xad, 0xad, 0xad));
	setProperty("CSQT_borderWidth", 1);
	setProperty("CSQT_borderRadius", 3);
	setProperty("CSQT_thumbWidth", 12);
	setProperty("CSQT_thumbPadding", 2);
	setProperty("CSQT_thumbRadius", 0);
	setProperty("CSQT_fillMode", "fill");
	setProperty("CSQT_backgroundMode", "jump");
	setProperty("CSQT_rulermode", "hide");
	setProperty("CSQT_rulercolor", shade(0x6d, 0x6d, 0x6d));
}

QuteSlider::~QuteSlider()
{
}

QuteWidgetType QuteSlider::getWidgetTypeID() { return QuteWidgetType::SLIDER; }

void QuteSlider::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	setInternalValue(value);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteSlider::setMidiValue(int value)
{
	auto w = control();
	// MIDI maps linearly onto the GUI position, then the exponent curve maps
	// that position to the real value.
	double newval = w->mapping().toValue(value / 127.0);
	setValue(newval);
	QPair<QString, double> channelValue(m_channel, newval);
	emit newValue(channelValue);
}

void QuteSlider::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	auto w = control();
	const double position = w->mapping().toPosition(m_value);
	const int val = qRound(position * w->maximum());
	m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	w->blockSignals(true);
	w->setValue(val);
	w->blockSignals(false);
}

bool QuteSlider::applyProperty(const QString &name)
{
	auto w = control();
	if (name == "CSQT_value") {
		m_value = property("CSQT_value").toDouble();
		m_valueChanged = true;
		return true;
	}
	if (name == "CSQT_minimum" || name == "CSQT_maximum") {
		double min = property("CSQT_minimum").toDouble();
		double max = property("CSQT_maximum").toDouble();
		if (max < min) {
			std::swap(min, max);
		}
		m_min = min;
		m_max = max;
		w->setDisplayRange(m_min, m_max);
		setInternalValue(m_value);
		return true;
	}
	if (name == "CSQT_exponent") {
		w->setExponent(property("CSQT_exponent").toDouble());
		m_valueChanged = true;
		return true;
	}
	if (name == "CSQT_flatStyle") {
		w->setFlatStyle(property("CSQT_flatStyle").toBool());
		return true;
	}
	if (name == "CSQT_bgcolor") {
		w->setBackgroundColor(colorFromVariant(property("CSQT_bgcolor")));
		return true;
	}
	if (name == "CSQT_foreground") {
		w->setForegroundColor(colorFromVariant(property("CSQT_foreground")));
		return true;
	}
	if (name == "CSQT_fillcolor") {
		w->setFillColor(colorFromVariant(property("CSQT_fillcolor")));
		return true;
	}
	if (name == "CSQT_bordercolor") {
		w->setBorderColor(colorFromVariant(property("CSQT_bordercolor")));
		return true;
	}
	if (name == "CSQT_borderWidth" || name == "CSQT_borderRadius") {
		w->setBorder(property("CSQT_borderWidth").toInt(),
		             property("CSQT_borderRadius").toInt());
		return true;
	}
	if (name == "CSQT_thumbWidth" || name == "CSQT_thumbPadding"
	        || name == "CSQT_thumbRadius") {
		const bool fill = property("CSQT_fillMode").toString().trimmed().toLower()
				!= "thumb"_L1;
		int thumbWidth = property("CSQT_thumbWidth").toInt();
		if (!fill && thumbWidth < 1) {
			// A hidden thumb is only meaningful in fill mode.
			thumbWidth = 1;
			setProperty("CSQT_thumbWidth", thumbWidth);
		}
		w->setThumb(thumbWidth,
		            property("CSQT_thumbPadding").toInt(),
		            property("CSQT_thumbRadius").toInt());
		return true;
	}
	if (name == "CSQT_fillMode") {
		const bool fill = property("CSQT_fillMode").toString().trimmed().toLower()
				!= "thumb"_L1;
		int thumbWidth = property("CSQT_thumbWidth").toInt();
		if (!fill && thumbWidth < 1) {
			thumbWidth = 1;
			setProperty("CSQT_thumbWidth", thumbWidth);
		}
		w->setFillMode(fill);
		w->setThumb(thumbWidth,
		            property("CSQT_thumbPadding").toInt(),
		            property("CSQT_thumbRadius").toInt());
		return true;
	}
	if (name == "CSQT_backgroundMode") {
		const QString mode = property("CSQT_backgroundMode").toString().trimmed().toLower();
		w->setBackgroundMode(mode == "nudge"_L1
		                     ? QuteSliderControl::Nudge
		                     : QuteSliderControl::Jump);
		return true;
	}
	if (name == "CSQT_rulermode") {
		w->setRuler(WidgetRuler::modeFromString(property("CSQT_rulermode").toString()),
		            colorFromVariant(property("CSQT_rulercolor")));
		return true;
	}
	if (name == "CSQT_rulercolor") {
		w->setRuler(WidgetRuler::modeFromString(property("CSQT_rulermode").toString()),
		            colorFromVariant(property("CSQT_rulercolor")));
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteSlider::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();

	double min = property("CSQT_minimum").toDouble();
	double max = property("CSQT_maximum").toDouble();
	if (max < min) {
		std::swap(min, max);
	}
	m_min = min;
	m_max = max;

	auto w = control();
	w->setDisplayRange(m_min, m_max);
	w->setExponent(property("CSQT_exponent").toDouble());
	w->setFlatStyle(property("CSQT_flatStyle").toBool());
	w->setBackgroundColor(colorFromVariant(property("CSQT_bgcolor")));
	w->setForegroundColor(colorFromVariant(property("CSQT_foreground")));
	w->setFillColor(colorFromVariant(property("CSQT_fillcolor")));
	w->setBorderColor(colorFromVariant(property("CSQT_bordercolor")));
	w->setBorder(property("CSQT_borderWidth").toInt(),
	             property("CSQT_borderRadius").toInt());
	const bool fillMode = property("CSQT_fillMode").toString().trimmed().toLower()
			!= "thumb"_L1;
	int thumbWidth = property("CSQT_thumbWidth").toInt();
	if (!fillMode && thumbWidth < 1) {
		thumbWidth = 1;
		setProperty("CSQT_thumbWidth", thumbWidth);
	}
	w->setFillMode(fillMode);
	w->setThumb(thumbWidth,
	            property("CSQT_thumbPadding").toInt(),
	            property("CSQT_thumbRadius").toInt());
	w->setBackgroundMode(property("CSQT_backgroundMode").toString().trimmed().toLower()
	                     == "nudge"_L1
	                     ? QuteSliderControl::Nudge
	                     : QuteSliderControl::Jump);
	w->setRuler(WidgetRuler::modeFromString(property("CSQT_rulermode").toString()),
	            colorFromVariant(property("CSQT_rulercolor")));

	setInternalValue(property("CSQT_value").toDouble());
	// Sync the QSlider position immediately so the first click after loading or
	// after a property change starts from the value that is actually shown.
	refreshWidget();
	m_valueChanged = true;
}

void QuteSlider::setWidgetGeometry(int x, int y, int w, int h)
{
	QuteWidget::setWidgetGeometry(x,y,w,h);
	auto slider = control();
	slider->blockSignals(true);
	if (width() > height()) {
		slider->setOrientation(Qt::Horizontal);
		slider->setMaximum(w);
		m_len = w;
	} else {
		slider->setOrientation(Qt::Vertical);
		slider->setMaximum(h);
		m_len = h;
	}
	slider->blockSignals(false);
	slider->update();
}

QString QuteSlider::getCabbageLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	QString line = "";
	if (m_widget->width() > m_widget->height()) {
		line += "hslider ";
	}
	else {
		line += "vslider ";
	}
	line += "channel(\"" + m_channel + "\"),  ";
	line += QString("bounds(%1,%2,%3,%4), ").arg(x()).arg(y()).arg(width()).arg(height());
	line += QString("range(%1,%2,%3) " ).arg(property("CSQT_minimum").toDouble()).arg(property("CSQT_maximum").toDouble()).arg(m_value);
	//line += QString(", text(%1), ").arg(m_channel); // Is it good idea to put channel as name - not really since geometry probably does not allow it
	if (property("CSQT_midicc").toInt() >= 0 && property("CSQT_midichan").toInt()>0) { // insert only if midi channel is above 0
		line += ", midiCtrl(\"" + QString::number(property("CSQT_midichan").toInt()) + ",";
		line +=  QString::number(property("CSQT_midicc").toInt()) + "\")";
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}


QString QuteSlider::getQml()
{
	QString qml = QString();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	qml = "\n\tSlider {\n";
	//qml += QString("\t\t\id: %1Slider\n").arg(m_channel);
	qml += QString("\t\tx: %1 * scaleItem.scale\n").arg(x());
	qml += QString("\t\ty: %1  * scaleItem.scale\n").arg(y());
	qml += QString("\t\twidth: %1 * scaleItem.scale\n").arg(width());
	qml += QString("\t\theight: %1 * scaleItem.scale\n").arg(height());
	qml += QString("\t\tfrom: %1\n").arg(property("CSQT_minimum").toString());
	qml += QString("\t\tto: %1\n").arg(property("CSQT_maximum").toString());
	qml += QString("\t\tvalue: %1\n").arg(getValue());
	if ( width() > height() ) {
		qml += "\t\torientation: Qt.Horizontal\n";
	} else {
		qml += "\t\torientation: Qt.Vertical\n";
	}
	qml += QString("\t\tonPositionChanged: csound.setControlChannel(\"%1\", valueAt(position))\n").arg(m_channel); // NB! this is for QtQuick.Controls 2! since onValueChanged works onlu on drag end

	qml += "\t}";
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif

	return qml;
}

QString QuteSlider::getCsladspaLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "ControlPort=" + m_channel + "|" + m_channel + "\n";
	line += "Range=" + QString::number(property("CSQT_minimum").toDouble(), 'f', 8)
			+ "|" + QString::number(property("CSQT_maximum").toDouble(), 'f', 8);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteSlider::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	s.writeTextElement("minimum", QString::number(property("CSQT_minimum").toDouble(), 'f', 8));
	s.writeTextElement("maximum", QString::number(property("CSQT_maximum").toDouble(), 'f', 8));
	s.writeTextElement("exponent", QString::number(property("CSQT_exponent").toDouble(), 'f', 8));
	s.writeTextElement("value", QString::number(m_value, 'f', 8));
	s.writeTextElement("mode", property("CSQT_mode").toString());

	s.writeStartElement("mouseControl");
	s.writeAttribute("act", property("CSQT_mouseControlAct").toString());
	s.writeCharacters(property("CSQT_mouseControl").toString());
	s.writeEndElement();
	s.writeTextElement("resolution", QString::number(property("CSQT_resolution").toDouble(), 'f', 8));
	s.writeStartElement("randomizable");
	s.writeAttribute("group", QString::number(property("CSQT_randomizableGroup").toInt()));
	s.writeCharacters(property("CSQT_randomizable").toBool() ? "true": "false");
	s.writeEndElement();

	s.writeTextElement("flatStyle",
	                   property("CSQT_flatStyle").toBool() ? "true" : "false");
	writeColorElement(s, "bgcolor", colorFromVariant(property("CSQT_bgcolor")));
	writeColorElement(s, "foreground", colorFromVariant(property("CSQT_foreground")));
	const QColor fillColor = colorFromVariant(property("CSQT_fillcolor"));
	if (fillColor.isValid()) {
		writeColorElement(s, "fillcolor", fillColor);
	} else {
		s.writeTextElement("fillcolor", QString());
	}
	writeColorElement(s, "bordercolor", colorFromVariant(property("CSQT_bordercolor")));
	s.writeTextElement("borderWidth", QString::number(property("CSQT_borderWidth").toInt()));
	s.writeTextElement("borderRadius", QString::number(property("CSQT_borderRadius").toInt()));
	s.writeTextElement("thumbWidth", QString::number(property("CSQT_thumbWidth").toInt()));
	s.writeTextElement("thumbPadding", QString::number(property("CSQT_thumbPadding").toInt()));
	s.writeTextElement("thumbRadius", QString::number(property("CSQT_thumbRadius").toInt()));
	s.writeTextElement("fillMode", property("CSQT_fillMode").toString());
	s.writeTextElement("backgroundMode", property("CSQT_backgroundMode").toString());
	s.writeTextElement("rulermode", property("CSQT_rulermode").toString());
	writeColorElement(s, "rulercolor", colorFromVariant(property("CSQT_rulercolor")));

	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}


QString QuteSlider::getWidgetType()
{
	return (width() > height()? QString("BSBHSlider"):QString("BSBVSlider"));
}

QHash<QString, QString> QuteSlider::propertyDescriptions() const
{
	return {
		{u"flatStyle"_s, u"Draw the slider with a flat, platform-independent style"_s},
		{u"bgcolor"_s, u"Background colour of the slider body"_s},
		{u"foreground"_s, u"Thumb colour"_s},
		{u"fillcolor"_s, u"Fill colour up to the thumb (defaults to the foreground)"_s},
		{u"bordercolor"_s, u"Border colour"_s},
		{u"borderWidth"_s, u"Border width in pixels (0 = no border)"_s},
		{u"borderRadius"_s, u"Corner radius in pixels (0 = square)"_s},
		{u"thumbWidth"_s, u"Thumb length along the track in pixels"_s},
		{u"thumbPadding"_s, u"Gap in pixels between the thumb and the slider edges"_s},
		{u"thumbRadius"_s, u"Thumb corner radius in pixels"_s},
		{u"fillMode"_s, u"Slider mode: \"thumb\" or \"fill\""_s},
		{u"backgroundMode"_s, u"Background click mode: \"nudge\" or \"jump\""_s},
		{u"exponent"_s, u"Skew of the value curve (1 = linear)"_s},
		{u"rulermode"_s, u"Value ruler: hide, full or compact"_s},
		{u"rulercolor"_s, u"Ruler tick and label colour"_s}
	};
}

void QuteSlider::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
	dialog->setWindowTitle("Slider");
	int row = 2;
	QLabel *label = new QLabel(dialog);
	label->setText("Min =");
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	minSpinBox = new QDoubleSpinBox(dialog);
	minSpinBox->setDecimals(6);
	minSpinBox->setRange(-99999.0, 99999.0);
	layout->addWidget(minSpinBox, row,1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Max =");
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	maxSpinBox = new QDoubleSpinBox(dialog);
	maxSpinBox->setDecimals(6);
	maxSpinBox->setRange(-99999.0, 99999.0);
	layout->addWidget(maxSpinBox, row,3, Qt::AlignLeft|Qt::AlignVCenter);
	++row;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	minSpinBox->setValue(property("CSQT_minimum").toDouble());
	maxSpinBox->setValue(property("CSQT_maximum").toDouble());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif

	// Row 3 is the common channel row; the flat-style rows start below it.
	row = 4;
	m_flatControls.clear();

	flatStyleCheckBox = new QCheckBox(tr("Flat style"), dialog);
	flatStyleCheckBox->setToolTip(tr("Draw the slider with a flat, platform-independent "
	                                 "appearance instead of the native style."));
	flatStyleCheckBox->setChecked(property("CSQT_flatStyle").toBool());
	layout->addWidget(flatStyleCheckBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	++row;

	QColor backgroundColor = colorFromVariant(property("CSQT_bgcolor"));
	if (!backgroundColor.isValid()) {
		backgroundColor = m_widget->palette().color(QPalette::Button);
	}
	QColor foregroundColor = colorFromVariant(property("CSQT_foreground"));
	if (!foregroundColor.isValid()) {
		foregroundColor = m_widget->palette().color(QPalette::ButtonText);
	}
	QColor borderColor = colorFromVariant(property("CSQT_bordercolor"));
	if (!borderColor.isValid()) {
		borderColor = m_widget->palette().color(QPalette::Mid);
	}
	QColor fillColor = colorFromVariant(property("CSQT_fillcolor"));
	m_fillColorSet = fillColor.isValid();

	label = new QLabel(tr("Background"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	backgroundColorButton = new SelectColorButton(dialog);
	backgroundColorButton->setColor(backgroundColor);
	layout->addWidget(backgroundColorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << backgroundColorButton;

	label = new QLabel(tr("Foreground"), dialog);
	label->setToolTip(tr("Colour of the thumb."));
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	foregroundColorButton = new SelectColorButton(dialog);
	foregroundColorButton->setColor(foregroundColor);
	layout->addWidget(foregroundColorButton, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << foregroundColorButton;
	++row;

	label = new QLabel(tr("Fill"), dialog);
	label->setToolTip(tr("Colour of the filled part. Defaults to the foreground colour."));
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	fillColorButton = new SelectColorButton(dialog);
	fillColorButton->setColor(m_fillColorSet ? fillColor : foregroundColor);
	layout->addWidget(fillColorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << fillColorButton;

	label = new QLabel(tr("Border"), dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	borderColorButton = new SelectColorButton(dialog);
	borderColorButton->setColor(borderColor);
	layout->addWidget(borderColorButton, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << borderColorButton;
	++row;

	label = new QLabel(tr("Border width"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	borderWidthSpinBox = new QSpinBox(dialog);
	borderWidthSpinBox->unsetLocale();
	borderWidthSpinBox->setRange(0, 64);
	borderWidthSpinBox->setValue(property("CSQT_borderWidth").toInt());
	layout->addWidget(borderWidthSpinBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << borderWidthSpinBox;

	label = new QLabel(tr("Border radius"), dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	borderRadiusSpinBox = new QSpinBox(dialog);
	borderRadiusSpinBox->unsetLocale();
	borderRadiusSpinBox->setRange(0, 1000);
	borderRadiusSpinBox->setValue(property("CSQT_borderRadius").toInt());
	layout->addWidget(borderRadiusSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << borderRadiusSpinBox;
	++row;

	label = new QLabel(tr("Thumb width"), dialog);
	label->setToolTip(tr("Length of the thumb along the slider track."));
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	thumbWidthSpinBox = new QSpinBox(dialog);
	thumbWidthSpinBox->unsetLocale();
	thumbWidthSpinBox->setRange(0, 1000); // 0 hides the thumb in fill mode
	thumbWidthSpinBox->setValue(property("CSQT_thumbWidth").toInt());
	layout->addWidget(thumbWidthSpinBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << thumbWidthSpinBox;

	label = new QLabel(tr("Thumb padding"), dialog);
	label->setToolTip(tr("Gap in pixels between the thumb and the slider edges."));
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	thumbPaddingSpinBox = new QSpinBox(dialog);
	thumbPaddingSpinBox->unsetLocale();
	thumbPaddingSpinBox->setRange(0, 1000);
	thumbPaddingSpinBox->setValue(property("CSQT_thumbPadding").toInt());
	layout->addWidget(thumbPaddingSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << thumbPaddingSpinBox;
	++row;

	label = new QLabel(tr("Thumb roundness"), dialog);
	label->setToolTip(tr("Corner radius of the thumb in pixels."));
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	thumbRadiusSpinBox = new QSpinBox(dialog);
	thumbRadiusSpinBox->unsetLocale();
	thumbRadiusSpinBox->setRange(0, 1000);
	thumbRadiusSpinBox->setValue(property("CSQT_thumbRadius").toInt());
	layout->addWidget(thumbRadiusSpinBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << thumbRadiusSpinBox;

	label = new QLabel(tr("Exponent ="), dialog);
	label->setToolTip(tr("Skew of the value curve: 1 is linear, values > 1 give "
	                     "finer control near the minimum, values < 1 finer "
	                     "control near the maximum."));
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	exponentSpinBox = new QDoubleSpinBox(dialog);
	exponentSpinBox->setDecimals(4);
	exponentSpinBox->setRange(0.001, 100.0);
	exponentSpinBox->setSingleStep(0.1);
	exponentSpinBox->setValue(property("CSQT_exponent").toDouble());
	exponentSpinBox->setToolTip(label->toolTip());
	layout->addWidget(exponentSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	++row;

	label = new QLabel(tr("Mode"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	fillModeComboBox = new QComboBox(dialog);
	fillModeComboBox->addItem(tr("Thumb"), u"thumb"_s);
	fillModeComboBox->addItem(tr("Fill"), u"fill"_s);
	{
		const int index = fillModeComboBox->findData(property("CSQT_fillMode").toString());
		fillModeComboBox->setCurrentIndex(index >= 0 ? index : 1);
	}
	layout->addWidget(fillModeComboBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << fillModeComboBox;

	// A zero thumb width is only useful in fill mode, where it hides the thumb.
	auto updateThumbWidthRange = [this]() {
		const bool fill = fillModeComboBox->currentData().toString() != "thumb"_L1;
		thumbWidthSpinBox->setMinimum(fill ? 0 : 1);
		if (!fill && thumbWidthSpinBox->value() == 0) {
			thumbWidthSpinBox->setValue(1);
		}
	};
	connect(fillModeComboBox, &QComboBox::currentIndexChanged,
	        this, updateThumbWidthRange);
	updateThumbWidthRange();

	label = new QLabel(tr("Background click"), dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	backgroundModeComboBox = new QComboBox(dialog);
	backgroundModeComboBox->addItem(tr("Nudge"), u"nudge"_s);
	backgroundModeComboBox->addItem(tr("Jump"), u"jump"_s);
	{
		const int index = backgroundModeComboBox->findData(
				property("CSQT_backgroundMode").toString());
		backgroundModeComboBox->setCurrentIndex(index >= 0 ? index : 1);
	}
	layout->addWidget(backgroundModeComboBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << backgroundModeComboBox;
	++row;

	label = new QLabel(tr("Ruler"), dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	rulerComboBox = new QComboBox(dialog);
	rulerComboBox->addItem(tr("Hide"), u"hide"_s);
	rulerComboBox->addItem(tr("Full"), u"full"_s);
	rulerComboBox->addItem(tr("Compact"), u"compact"_s);
	{
		const int index = rulerComboBox->findData(property("CSQT_rulermode").toString());
		rulerComboBox->setCurrentIndex(index >= 0 ? index : 0);
	}
	layout->addWidget(rulerComboBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << rulerComboBox;

	label = new QLabel(tr("Ruler colour"), dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	rulerColorButton = new SelectColorButton(dialog);
	rulerColorButton->setColor(colorFromVariant(property("CSQT_rulercolor")));
	layout->addWidget(rulerColorButton, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << rulerColorButton;
	++row;

	auto refreshFlatControls = [this]() {
		const bool flat = flatStyleCheckBox->isChecked();
		for (QWidget *widget : m_flatControls) {
			widget->setEnabled(flat);
		}
	};
	connect(flatStyleCheckBox, &QCheckBox::toggled, this, refreshFlatControls);
	refreshFlatControls();

	// While the fill colour is unset it follows the foreground.
	connect(foregroundColorButton, &SelectColorButton::clicked, this, [this]() {
		if (!m_fillColorSet) {
			fillColorButton->setColor(foregroundColorButton->getColor());
		}
	});
	connect(fillColorButton, &SelectColorButton::clicked, this, [this]() {
		m_fillColorSet = true;
	});
}

void QuteSlider::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	setProperty("CSQT_maximum", maxSpinBox->value());
	setProperty("CSQT_minimum", minSpinBox->value());
	setProperty("CSQT_exponent", exponentSpinBox->value());

	setProperty("CSQT_flatStyle", flatStyleCheckBox->isChecked());

	QColor backgroundColor = backgroundColorButton->getColor();
	if (!backgroundColor.isValid()) {
		backgroundColor = m_widget->palette().color(QPalette::Button);
	}
	setProperty("CSQT_bgcolor", backgroundColor);

	QColor foregroundColor = foregroundColorButton->getColor();
	if (!foregroundColor.isValid()) {
		foregroundColor = m_widget->palette().color(QPalette::ButtonText);
	}
	setProperty("CSQT_foreground", foregroundColor);

	const QColor fillColor = fillColorButton->getColor();
	if (m_fillColorSet && fillColor.isValid()) {
		setProperty("CSQT_fillcolor", fillColor.name());
	} else {
		setProperty("CSQT_fillcolor", QString());
	}

	QColor borderColor = borderColorButton->getColor();
	if (!borderColor.isValid()) {
		borderColor = m_widget->palette().color(QPalette::Mid);
	}
	setProperty("CSQT_bordercolor", borderColor);

	setProperty("CSQT_borderWidth", borderWidthSpinBox->value());
	setProperty("CSQT_borderRadius", borderRadiusSpinBox->value());
	setProperty("CSQT_thumbWidth", thumbWidthSpinBox->value());
	setProperty("CSQT_thumbPadding", thumbPaddingSpinBox->value());
	setProperty("CSQT_thumbRadius", thumbRadiusSpinBox->value());
	setProperty("CSQT_fillMode", fillModeComboBox->currentData().toString());
	setProperty("CSQT_backgroundMode", backgroundModeComboBox->currentData().toString());
	setProperty("CSQT_rulermode", rulerComboBox->currentData().toString());
	setProperty("CSQT_rulercolor", rulerColorButton->getColor());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	QuteWidget::applyProperties();  // Must be last to make sure the widgetChanged signal is last
}

void QuteSlider::sliderChanged(int value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	auto w = control();
	const double span = w->maximum() - w->minimum();
	const double normalized = span > 0.0
			? (value - w->minimum()) / span : 0.0;
	const double scaledValue = w->mapping().toValue(normalized);
	setInternalValue(scaledValue);
	QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	emit newValue(channelValue);
}

void QuteSlider::setInternalValue(double value)
{
	double max = rangeMax();
	double min = rangeMin();
	if (value > max)
		m_value = max;
	else if (value < min)
		m_value = min;
	else
		m_value = value;
	m_valueChanged = true;
	//  setProperty("CSQT_value", m_value);
}
