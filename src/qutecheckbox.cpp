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

#include "qutecheckbox.h"
#include "selectcolorbutton.h"

#include <QPainter>
using namespace Qt::StringLiterals;

// ---------------------------------------------------------------------------
//  QuteFlatCheckBox
// ---------------------------------------------------------------------------

QuteFlatCheckBox::QuteFlatCheckBox(QWidget *parent) : QCheckBox(parent)
{
	m_checkstyle = u"x"_s;
}

void QuteFlatCheckBox::setCheckStyle(const QString &style)
{
	m_checkstyle = (style.compare(u"full"_s, Qt::CaseInsensitive) == 0)
			? u"full"_s : u"x"_s;
	update();
}

// Colour properties are stored as QColor when they come from the XML (the
// <color> element) and as "#RRGGBB" strings otherwise.
static QColor colorFromProperty(const QVariant &value)
{
	QColor color = value.value<QColor>();
	if (!color.isValid()) {
		color = QColor(value.toString());
	}
	return color;
}

// Blend two colours: `amount` is the share of `foreground` (0.1 = 10%).
static QColor blendColors(const QColor &background, const QColor &foreground,
						  double amount)
{
	amount = qBound(0.0, amount, 1.0);
	return QColor(qRound(background.red() * (1.0 - amount) + foreground.red() * amount),
				  qRound(background.green() * (1.0 - amount) + foreground.green() * amount),
				  qRound(background.blue() * (1.0 - amount) + foreground.blue() * amount),
				  qRound(background.alpha() * (1.0 - amount) + foreground.alpha() * amount));
}

// QCheckBox restricts its clickable area to the native style's
// SE_CheckBoxClickRect (roughly indicator + text). In flat mode the square and
// label are laid out differently, so make the whole widget clickable.
bool QuteFlatCheckBox::hitButton(const QPoint &pos) const
{
	if (m_flat) {
		return rect().contains(pos);
	}
	return QCheckBox::hitButton(pos);
}

void QuteFlatCheckBox::paintEvent(QPaintEvent *event)
{
	if (!m_flat) {
		QCheckBox::paintEvent(event);
		return;
	}

	QPainter painter(this);
	painter.setRenderHint(QPainter::Antialiasing, true);

	QColor bg = m_background;
	if (!bg.isValid()) {
		bg = palette().color(QPalette::Button);
	}
	QColor fg = m_foreground;
	if (!fg.isValid()) {
		fg = palette().color(QPalette::ButtonText);
	}
	QColor borderColor = m_bordercolor;

	// While the mouse is held down the background darkens slightly. The checked
	// state itself is not touched here: QAbstractButton resolves it on release.
	if (isDown()) {
		bg = blendColors(bg, fg, 0.1);
	}
	if (!isEnabled()) {
		bg = QuteWidget::disabledColor(bg);
		fg = QuteWidget::disabledColor(fg);
		borderColor = QuteWidget::disabledColor(borderColor);
	}

	// The indicator is the largest square that fits. Any remaining horizontal
	// space holds the label, matching a normal checkbox layout.
	const int side = qMin(width(), height());
	QRectF indicatorRect(0, (height() - side) / 2.0, side, side);
	const double half = m_borderwidth / 2.0;
	const QRectF square = indicatorRect.adjusted(half, half, -half, -half);

	painter.setBrush(bg);
	if (m_borderwidth > 0 && borderColor.isValid()) {
		QPen pen(borderColor, m_borderwidth);
		if (m_borderwidth == 1) {
			// Cosmetic pen so a 1px border is not thinned by scaling.
			pen.setWidth(0);
			pen.setCosmetic(true);
		}
		painter.setPen(pen);
	} else {
		painter.setPen(Qt::NoPen);
	}
	painter.drawRoundedRect(square, m_borderradius, m_borderradius);

	// Check mark. "full" fills the square, "x" draws a diagonal cross. The
	// padding keeps the mark away from the inner edge of the border.
	if (isChecked()) {
		const qreal inset = qMax(0.0, half) + qMax(0, m_padding);
		const QRectF fillArea = square.adjusted(inset, inset, -inset, -inset);
		if (fillArea.width() > 0 && fillArea.height() > 0) {
			painter.setPen(Qt::NoPen);
			painter.setBrush(fg);
			if (m_checkstyle == "full"_L1) {
				const int radius = qMax(0, m_borderradius - m_borderwidth - m_padding);
				painter.drawRoundedRect(fillArea, radius, radius);
			} else {
				QPen pen(fg, qMax(2.0, double(m_borderwidth)));
				pen.setCapStyle(Qt::RoundCap);
				painter.setPen(pen);
				painter.drawLine(fillArea.topLeft(), fillArea.bottomRight());
				painter.drawLine(fillArea.topRight(), fillArea.bottomLeft());
			}
		}
	}

	if (!text().isEmpty() && width() > side) {
		const QRectF textRect(side + 4, 0, width() - side - 4, height());
		painter.setPen(fg);
		painter.drawText(textRect, Qt::AlignVCenter | Qt::AlignLeft | Qt::TextWordWrap,
						 text());
	}
}

// ---------------------------------------------------------------------------
//  QuteCheckBox
// ---------------------------------------------------------------------------

QuteCheckBox::QuteCheckBox(QWidget *parent) : QuteWidget(parent)
{
	m_widget = new QuteFlatCheckBox(this);
	auto w = checkbox();
    // w->setStyleSheet("QCheckBox::indicator { width:50px; height: 50px; }");

    // Necessary to pass mouse tracking to widget panel for _MouseX channels
    m_widget->setMouseTracking(true);
	m_widget->setContextMenuPolicy(Qt::NoContextMenu);
	canFocus(false);

	setProperty("CSQT_selected", false);
    setProperty("CSQT_label", "");
	setProperty("CSQT_pressedValue", 1.0);
	setProperty("CSQT_randomizable", false);
	setProperty("CSQT_randomizableGroup", 0);

	// Flat style. Disabled by default, so existing checkboxes keep the native
	// look. The colours follow the same light/dark convention as flat buttons.
	setProperty("CSQT_flatStyle", false);
	const bool darkPanel = isDarkTheme();
	auto shade = [darkPanel](int r, int g, int b) {
		return darkPanel ? QColor(255 - r, 255 - g, 255 - b) : QColor(r, g, b);
	};
	setProperty("CSQT_color", shade(0xf3, 0xf3, 0xf3));            // background
	setProperty("CSQT_borderColor", shade(0xad, 0xad, 0xad).name());
	setProperty("CSQT_textColor", shade(0x20, 0x20, 0x20).name()); // foreground
	setProperty("CSQT_borderWidth", 1);
	setProperty("CSQT_borderRadius", 3);
	setProperty("CSQT_padding", 0);
	setProperty("CSQT_checkstyle", "x");

	m_currentValue = 0;

	updateIndicatorStyleSheet();

    connect(w, SIGNAL(stateChanged(int)), this, SLOT(stateChanged(int)));
}

QuteCheckBox::~QuteCheckBox()
{
}

QuteWidgetType QuteCheckBox::getWidgetTypeID() { return QuteWidgetType::CHECKBOX; }


void QuteCheckBox::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	if (value >=0) {
		m_currentValue = value != 0 ? m_value : 0.0;
	}
	else {
		m_value = -value;
		m_currentValue = -value;
	}
	m_valueChanged = true;
	//  qDebug( ) << "QuteCheckBox::setValue " << value << "---" << m_currentValue;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteCheckBox::setLabel(QString label)
{
	static_cast<QCheckBox *>(m_widget)->setText(label);
}

double QuteCheckBox::getValue()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	double value = m_currentValue;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return value;
}

//QString QuteCheckBox::getLabel()
//{
//  return static_cast<QCheckBox *>(m_widget)->text();
//}

QString QuteCheckBox::getCabbageLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "checkbox channel(\"" + m_channel + "\"),  ";
	line += QString("bounds(%1,%2,%3,%4), ").arg(x()).arg(y()).arg(width()).arg(height());
	line += "value(" + (static_cast<QCheckBox *>(m_widget)->isChecked()?
							QString("1"):QString("0")) + ")";
	//line += QString(", caption(%1)").arg(m_channel);
	if (property("CSQT_midicc").toInt() >= 0 && property("CSQT_midichan").toInt()>0) { // insert only if midi channel is above 0
		line += ", midiCtrl(\"" + QString::number(property("CSQT_midichan").toInt()) + ",";
		line +=  QString::number(property("CSQT_midicc").toInt()) + "\")";
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteCheckBox::getWidgetType()
{
    return QString("BSBCheckBox");
}

QString QuteCheckBox::getQml()
{
    QString qml = QString();
#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForWrite();
#endif

	qml = "\n\tCheckBox {\n";
    qml += QString("\t\tx: %1 * scaleItem.scale\n").arg(x());
    qml += QString("\t\ty: %1  * scaleItem.scale\n").arg(y());
    qml += QString("\t\twidth: %1  * scaleItem.scale\n").arg(width());
    qml += QString("\t\theight: %1  * scaleItem.scale\n").arg(height());
    qml += QString("\t\tchecked: %1\n").arg(getValue()==0 ? "false" : "true" );
    qml += QString("\t\tonCheckedChanged: csound.setControlChannel(\"%1\", checked ? %2 : 0)\n").arg(m_channel).arg(property("CSQT_pressedValue").toDouble());
    //color, font and other outlook properties ignored by now
    qml += "\t}";
#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif
    return qml;

}

void QuteCheckBox::setMidiValue(int value)
{
	double pressedVal = property("CSQT_pressedValue").toDouble();
	double newval= value == 0 ? 0 : pressedVal;
	setValue(newval);
	QPair<QString, double> channelValue(m_channel, newval);
	emit newValue(channelValue);
}

QString QuteCheckBox::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif

	s.writeTextElement("selected",
					   m_currentValue != 0 ? QString("true"):QString("false"));
	s.writeTextElement("label", property("CSQT_label").toString());
    s.writeTextElement("pressedValue",
                       QString::number(property("CSQT_pressedValue").toDouble()));
	s.writeStartElement("randomizable");
	s.writeAttribute("group", QString::number(property("CSQT_randomizableGroup").toInt()));
	s.writeCharacters(property("CSQT_randomizable").toBool() ? "true": "false");
	s.writeEndElement();
	s.writeTextElement("flatStyle", property("CSQT_flatStyle").toBool() ? "true" : "false");
	writeColorElement(s, "color", colorFromProperty(property("CSQT_color")));
	s.writeTextElement("borderColor", property("CSQT_borderColor").toString());
	s.writeTextElement("textColor", property("CSQT_textColor").toString());
	s.writeTextElement("borderWidth", QString::number(property("CSQT_borderWidth").toInt()));
	s.writeTextElement("borderRadius", QString::number(property("CSQT_borderRadius").toInt()));
	s.writeTextElement("padding", QString::number(property("CSQT_padding").toInt()));
	s.writeTextElement("checkstyle", property("CSQT_checkstyle").toString());
	s.writeEndElement();

#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

void QuteCheckBox::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	//  qDebug() << "QuteCheckBox::refreshWidget " << "--" << m_currentValue;
	m_widget->blockSignals(true);
	static_cast<QCheckBox *>(m_widget)->setChecked(m_currentValue != 0);
	m_widget->blockSignals(false);
	//  setProperty("CSQT_pressedValue", m_value);
	setProperty("CSQT_selected", m_currentValue != 0);

	m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteCheckBox::resizeEvent(QResizeEvent *event) {
    updateIndicatorStyleSheet();
    QuteWidget::resizeEvent(event);
}

void QuteCheckBox::updateIndicatorStyleSheet()
{
    // The indicator size only matters for the native checkbox. In flat mode we
    // paint the square ourselves (see QuteFlatCheckBox::paintEvent).
    if (checkbox()->isFlatStyle()) {
        checkbox()->setStyleSheet(QString());
    } else {
        const int size = qMin(this->height(), this->width());
        checkbox()->setStyleSheet(QString("QCheckBox::indicator { "
                                          "width:%1px; "
                                          "height: %1px; }").arg(size));
    }
}


bool QuteCheckBox::applyProperty(const QString &name)
{
	if (name == "CSQT_pressedValue") {
		m_value = property("CSQT_pressedValue").toDouble();
		return true;
	}
	if (name == "CSQT_selected") {
		setValue(property("CSQT_selected").toBool() ? 1 : 0);
		return true;
	}
	if (name == "CSQT_label") {
		setLabel(property("CSQT_label").toString());
		return true;
	}
	if (name == "CSQT_flatStyle") {
		checkbox()->setFlatStyle(property("CSQT_flatStyle").toBool());
		updateIndicatorStyleSheet();
		return true;
	}
	if (name == "CSQT_color") {
		checkbox()->setBackgroundColor(colorFromProperty(property("CSQT_color")));
		return true;
	}
	if (name == "CSQT_borderColor") {
		checkbox()->setBorderColor(colorFromProperty(property("CSQT_borderColor")));
		return true;
	}
	if (name == "CSQT_textColor") {
		checkbox()->setForegroundColor(colorFromProperty(property("CSQT_textColor")));
		return true;
	}
	if (name == "CSQT_borderWidth") {
		checkbox()->setBorderWidth(property("CSQT_borderWidth").toInt());
		return true;
	}
	if (name == "CSQT_borderRadius") {
		checkbox()->setBorderRadius(property("CSQT_borderRadius").toInt());
		return true;
	}
	if (name == "CSQT_padding") {
		checkbox()->setPadding(property("CSQT_padding").toInt());
		return true;
	}
	if (name == "CSQT_checkstyle") {
		checkbox()->setCheckStyle(property("CSQT_checkstyle").toString());
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteCheckBox::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
	//  qDebug() << "QuteSlider::applyInternalProperties()";
    // Pressed value must go before selected to make sure it has the right value...
    m_value = property("CSQT_pressedValue").toDouble();
	setValue(property("CSQT_selected").toBool() ? 1:0);
    setLabel(property("CSQT_label").toString());

	QuteFlatCheckBox *w = checkbox();
	w->setBackgroundColor(colorFromProperty(property("CSQT_color")));
	w->setBorderColor(colorFromProperty(property("CSQT_borderColor")));
	w->setForegroundColor(colorFromProperty(property("CSQT_textColor")));
	w->setBorderWidth(property("CSQT_borderWidth").toInt());
	w->setBorderRadius(property("CSQT_borderRadius").toInt());
	w->setPadding(property("CSQT_padding").toInt());
	w->setCheckStyle(property("CSQT_checkstyle").toString());
	w->setFlatStyle(property("CSQT_flatStyle").toBool());
	updateIndicatorStyleSheet();
}

void QuteCheckBox::stateChanged(int state)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	m_currentValue = (state != Qt::Unchecked ? property("CSQT_pressedValue").toDouble() : 0);
	QPair<QString, double> channelValue(m_channel, m_currentValue);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    emit newValue(channelValue);
}

void QuteCheckBox::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	setProperty("CSQT_pressedValue", valueBox->value());
	setProperty("CSQT_flatStyle", flatStyleCheckBox->isChecked());
	QColor flatBg = backgroundColorButton->getColor();
	if (!flatBg.isValid()) {
		flatBg = m_widget->palette().color(QPalette::Button);
	}
	setProperty("CSQT_color", flatBg);
	QColor flatBorder = borderColorButton->getColor();
	setProperty("CSQT_borderColor", flatBorder.isValid() ? flatBorder.name() : QString());
	QColor flatFg = foregroundColorButton->getColor();
	if (!flatFg.isValid()) {
		flatFg = m_widget->palette().color(QPalette::ButtonText);
	}
	setProperty("CSQT_textColor", flatFg.name());
	setProperty("CSQT_borderWidth", borderWidthSpinBox->value());
	setProperty("CSQT_borderRadius", borderRadiusSpinBox->value());
	setProperty("CSQT_padding", paddingSpinBox->value());
	setProperty("CSQT_checkstyle", checkStyleComboBox->currentText());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    //Must be last to make sure the widgetChanged signal is last
    QuteWidget::applyProperties();
}

void QuteCheckBox::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
	dialog->setWindowTitle("Check Box");
	int row = 4;

	QLabel * label = new QLabel(dialog);
	label->setText("Pressed Value");
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);

    valueBox = new QDoubleSpinBox(dialog);
	valueBox->setDecimals(6);
	valueBox->setRange(-9999999.0, 9999999.0);
	layout->addWidget(valueBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	valueBox->setValue(property("CSQT_pressedValue").toDouble());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	++row;

	// --- Flat style ---
	m_flatControls.clear();
	flatStyleCheckBox = new QCheckBox(tr("Flat"), dialog);
	flatStyleCheckBox->setToolTip(tr("Draw the checkbox with a flat, platform-independent "
									 "appearance instead of the native style."));
	flatStyleCheckBox->setChecked(property("CSQT_flatStyle").toBool());
	layout->addWidget(flatStyleCheckBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	++row;

	QColor flatBg = colorFromProperty(property("CSQT_color"));
	if (!flatBg.isValid()) {
		flatBg = m_widget->palette().color(QPalette::Button);
	}
	QColor flatBorder = colorFromProperty(property("CSQT_borderColor"));
	if (!flatBorder.isValid()) {
		flatBorder = m_widget->palette().color(QPalette::Mid);
	}
	QColor flatFg = colorFromProperty(property("CSQT_textColor"));
	if (!flatFg.isValid()) {
		flatFg = m_widget->palette().color(QPalette::ButtonText);
	}

	label = new QLabel("Background", dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	backgroundColorButton = new SelectColorButton(dialog);
	backgroundColorButton->setColor(flatBg);
	layout->addWidget(backgroundColorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << backgroundColorButton;

	label = new QLabel("Border", dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	borderColorButton = new SelectColorButton(dialog);
	borderColorButton->setColor(flatBorder);
	layout->addWidget(borderColorButton, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << borderColorButton;
	++row;

	label = new QLabel("Foreground", dialog);
	label->setToolTip(tr("Colour of the check mark and of the label text."));
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	foregroundColorButton = new SelectColorButton(dialog);
	foregroundColorButton->setColor(flatFg);
	layout->addWidget(foregroundColorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << foregroundColorButton;

	label = new QLabel("Width", dialog);
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	borderWidthSpinBox = new QSpinBox(dialog);
	borderWidthSpinBox->unsetLocale();
	borderWidthSpinBox->setRange(0, 64);
	borderWidthSpinBox->setValue(property("CSQT_borderWidth").toInt());
	layout->addWidget(borderWidthSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << borderWidthSpinBox;
	++row;

	label = new QLabel("Radius", dialog);
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	borderRadiusSpinBox = new QSpinBox(dialog);
	borderRadiusSpinBox->unsetLocale();
	borderRadiusSpinBox->setRange(0, 1000);
	borderRadiusSpinBox->setValue(property("CSQT_borderRadius").toInt());
	layout->addWidget(borderRadiusSpinBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << borderRadiusSpinBox;

	label = new QLabel("Check style", dialog);
	label->setToolTip(tr("How the checked state is drawn: \"x\" is a diagonal cross, "
						 "\"full\" fills the square with the foreground colour."));
	layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	checkStyleComboBox = new QComboBox(dialog);
	checkStyleComboBox->addItem("x");
	checkStyleComboBox->addItem("full");
	if (checkStyleComboBox->findText(property("CSQT_checkstyle").toString()) < 0) {
		checkStyleComboBox->setCurrentIndex(0);
	} else {
		checkStyleComboBox->setCurrentText(property("CSQT_checkstyle").toString());
	}
	layout->addWidget(checkStyleComboBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << checkStyleComboBox;
	++row;

	label = new QLabel("Padding", dialog);
	label->setToolTip(tr("Space in pixels between the check mark and the border."));
	layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_flatControls << label;
	paddingSpinBox = new QSpinBox(dialog);
	paddingSpinBox->unsetLocale();
	paddingSpinBox->setRange(0, 1000);
	paddingSpinBox->setValue(property("CSQT_padding").toInt());
	layout->addWidget(paddingSpinBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
	m_flatControls << paddingSpinBox;
	++row;


	auto refreshFlatControls = [this]() {
		const bool flat = flatStyleCheckBox->isChecked();
		for (QWidget *w : m_flatControls) {
			w->setEnabled(flat);
		}
	};
	connect(flatStyleCheckBox, &QCheckBox::toggled, this, refreshFlatControls);
	refreshFlatControls();
}
