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

#include "quteknob.h"

QVdial::~QVdial() {};


void QVdial::mousePressEvent (QMouseEvent *event) {
    if(!(event->button() & Qt::LeftButton)) {
        return;
    }
    m_mouse_press_point = event->pos();
    m_dragging = true;
    m_base_value = value();
    m_temp_scale_factor = event->modifiers() & Qt::AltModifier ? 0.25 : 1.0;
}

void QVdial::mouseReleaseEvent (QMouseEvent *event) {
    m_dragging = false;
}

void QVdial::mouseMoveEvent (QMouseEvent *event) {
    if (!m_dragging)
        return;
    int mouse_distance = m_mouse_press_point.y() - event->y();
    double delta = mouse_distance / (double)this->height() * (double)this->maximum();
    double fvalue = m_base_value + delta * m_temp_scale_factor * m_scale_factor;
    setValue((int)fvalue);
}

void QVdial::mouseDoubleClickEvent(QMouseEvent *event) {
    if(!event->modifiers())
        this->setValueDialog();
    else
        this->QDial::mouseDoubleClickEvent(event);
}

void QVdial::paintEvent(QPaintEvent *event) {
    if(!m_flat)
        return this->QDial::paintEvent(event);

    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    QPoint center = this->rect().center();
    double r = qMin(this->rect().height(), this->rect().width()) / 2.0;
    r *= 0.75;
    int const penWidth = (int)(r * 0.5);
    QPen const fgPen(m_color, penWidth, Qt::SolidLine, Qt::FlatCap);
    QPen const bgPen(m_color.darker(300),  penWidth, Qt::SolidLine, Qt::FlatCap);
    QRectF const rect(center.x() - r, center.y() - r, r * 2, r * 2);
    int const startAngle360 = 90 + (360 - m_degrees) / 2;
    int const startAngle = startAngle360 * 16;
    double relvalue = (double)this->value() / this->maximum();
    int steps = (int)(relvalue * 16 * m_degrees);
    painter.setPen(bgPen);
    painter.drawArc(rect, -startAngle, -m_degrees * 16);
    painter.setPen(fgPen);
    painter.drawArc(rect, -startAngle, -steps);
    if(m_draw_value && r >= 8) {
        double display_value = ((double)this->value()/(double)this->maximum()) *
                             (m_display_max - m_display_min) + m_display_min;
        int decimals = m_intDisplay ? 0 : m_decimals;
        QString strValue = QString::number((double)display_value, 'f', decimals);
        double numChars = (double)strValue.size();
        if(decimals > 0) {
            // do not account for decimal .
            numChars -= 0.2;
        }
        if(display_value < 0) {
            numChars -= 0.5;
        }
        numChars = numChars > 4 ? numChars : 4;
        double fontScale = 0.46 * 4/numChars;
        int fontSize = (int) (r * fontScale);
        if(fontSize >= 6.0) {
            painter.setFont({"Helvetica", fontSize});
            painter.setPen(m_textcolor);
            painter.drawText(this->rect(), Qt::AlignCenter, strValue);
        }
    }
}

void QVdial::setValueDialog() {
    double oldvalue = this->displayValue();
    double newvalue = QInputDialog::getDouble(
                this,
                tr("Enter New Value"),
                tr("Value"),
                oldvalue,
                m_display_min,
                m_display_max,
                3);
    setValueFromDisplayValue(newvalue);
}

// ------------------------------------------------------


QuteKnob::QuteKnob(QWidget *parent) : QuteWidget(parent)
{
	//TODO add resolution to config dialog and set these values accordingly
    m_widget = new QVdial(this);
    int const maximum = 10000;
    static_cast<QVdial *>(m_widget)->setMinimum(0);
    static_cast<QVdial *>(m_widget)->setMaximum(maximum);
    static_cast<QVdial *>(m_widget)->setNotchTarget(maximum / 10);
    static_cast<QVdial *>(m_widget)->setNotchesVisible(true);
    static_cast<QVdial *>(m_widget)->setDrawValue(true);

	m_widget->setPalette(QPalette(Qt::gray));
	m_widget->setContextMenuPolicy(Qt::NoContextMenu);
	m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
    setProperty("QCS_minimum", 0.0);
    setProperty("QCS_maximum", 1.0);
	setProperty("QCS_value", 0.0);
	setProperty("QCS_mode", "lin");
	setProperty("QCS_mouseControl", "continuous");
    // setProperty("QCS_mouseControlAct", "jump");
	setProperty("QCS_resolution", 0.01);
	setProperty("QCS_randomizable", false);
	setProperty("QCS_randomizableGroup", 0);

    setColor(QColor(245, 124, 0));
    setTextColor(QColor(81, 41, 0));

    setProperty("QCS_showvalue", true);
    setProperty("QCS_flatstyle", true);
    setProperty("QCS_integerMode", false);
	connect(static_cast<QDial *>(m_widget), SIGNAL(valueChanged(int)), this, SLOT(knobChanged(int)));
}

QuteKnob::~QuteKnob() {}

void QuteKnob::setRange(double min, double max)
{
	// TODO when knob is resized, its internal range should be adjusted...
	if (max < min) {
		double temp = max;
		max = min;
		min = temp;
	}
	if (m_value > max)
		m_value =  max;
	else if (m_value > min)
		m_value = min;
    setProperty("QCS_maximum", max);
	setProperty("QCS_minimum", min);
	m_valueChanged = true;
    static_cast<QVdial *>(m_widget)->setDisplayRange(min, max);

}

void QuteKnob::setMidiValue(int value)
{
	double max = property("QCS_maximum").toDouble();
	double min = property("QCS_minimum").toDouble();
	double newval= min + ((value / 127.0)* (max - min));
	setValue(newval);
	QPair<QString, double> channelValue(m_channel, newval);
	emit newValue(channelValue);
}

void QuteKnob::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
    auto w = static_cast<QVdial *>(m_widget);
	double max = property("QCS_maximum").toDouble();
	double min = property("QCS_minimum").toDouble();

    int val = (int)(w->maximum() * (m_value - min)/(max-min));
	m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    w->blockSignals(true);
    w->setValue(val);
    w->blockSignals(false);
}

void QuteKnob::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
    setValue(property("QCS_value").toDouble());
    auto w = static_cast<QVdial*>(m_widget);

    w->setColor(property("QCS_color").value<QColor>());
    w->setTextColor(QColor(property("QCS_textcolor").toString()));
    w->setDrawValue(property("QCS_showvalue").toBool());
    w->setFlatStyle(property("QCS_flatstyle").toBool());
    w->setIntegerMode(property("QCS_integerMode").toBool());
    w->setDisplayRange(property("QCS_minimum").toDouble(),
                       property("QCS_maximum").toDouble());
}

void QuteKnob::setWidgetGeometry(int x, int y, int width, int height)
{
	QuteWidget::setWidgetGeometry(x,y,width,height);
	m_widget->blockSignals(true);
	m_widget->setFixedSize(width, height);
	m_widget->blockSignals(false);
}

QString QuteKnob::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "ioKnob {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
	line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
	line += QString::number(property("QCS_maximum").toDouble(), 'f', 6) + " ";
	line += QString::number(property("QCS_minimum").toDouble(), 'f', 6) + " ";
	line += QString::number(property("QCS_resolution").toDouble(), 'f', 6) + " ";
	line += QString::number(m_value, 'f', 6) + " " + m_channel;
	//   qDebug("QuteKnob::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteKnob::getCsladspaLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "ControlPort=" + m_channel + "|" + m_channel + "\n";
	line += "Range=" + QString::number(property("QCS_minimum").toDouble(), 'f', 8);
	line += "|" + QString::number(property("QCS_maximum").toDouble(), 'f', 8);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}


QString QuteKnob::getCabbageLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	QString line = "rslider ";
	line += "channel(\"" + m_channel + "\"),  ";
	line += QString("bounds(%1,%2,%3,%4), ").arg(x()).arg(y()).arg(width()).arg(height());
	line += QString("range(%1,%2,%3), ").arg(property("QCS_minimum").toDouble()).arg(property("QCS_maximum").toDouble()).arg(m_value);
    // insert only if midi channel is above 0
    if (property("QCS_midicc").toInt() >= 0 && property("QCS_midichan").toInt() > 0) {
		line += ", midiCtrl(\"" + QString::number(property("QCS_midichan").toInt()) + ",";
		line +=  QString::number(property("QCS_midicc").toInt()) + "\")";
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    return line;
}

QString QuteKnob::getQml()
{
    QString qml = QString();
#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForWrite();
#endif
    qml = "\n\tDial {\n";
    //qml += QString("\t\tid: %1Dial\n").arg(m_channel);
	qml += QString("\t\tx: %1 * scaleItem.scale\n").arg(x());
	qml += QString("\t\ty: %1  * scaleItem.scale\n").arg(y());
	qml += QString("\t\twidth: %1 * scaleItem.scale\n").arg(width());
	qml += QString("\t\theight: %1 * scaleItem.scale\n").arg(height());
    qml += QString("\t\tfrom: %1\n").arg(property("QCS_minimum").toString());
    qml += QString("\t\tto: %1\n").arg(property("QCS_maximum").toString());
    qml += QString("\t\tvalue: %1\n").arg(getValue());
    qml += QString("\t\tonPositionChanged: csound.setControlChannel(\"%1\", from + position*(to-from))\n").arg(m_channel); // NB! this is for QtQuick.Controls 2! since onValueChanged works onlu on drag end

    qml += "\t}";
#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif

    return qml;

}

QString QuteKnob::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif

	s.writeTextElement("minimum", QString::number(property("QCS_minimum").toDouble(), 'f', 8));
	s.writeTextElement("maximum", QString::number(property("QCS_maximum").toDouble(), 'f', 8));
	s.writeTextElement("value", QString::number(m_value, 'f', 8));
	s.writeTextElement("mode", property("QCS_mode").toString());
	s.writeStartElement("mouseControl");
	s.writeAttribute("act", property("QCS_mouseControlAct").toString());
	s.writeCharacters(property("QCS_mouseControl").toString());
	s.writeEndElement();
    s.writeTextElement("resolution",
                       QString::number(property("QCS_resolution").toDouble(), 'f', 8));
	s.writeStartElement("randomizable");
	s.writeAttribute("group", QString::number(property("QCS_randomizableGroup").toInt()));
	s.writeCharacters(property("QCS_randomizable").toBool() ? "true": "false");
	s.writeEndElement();

    QColor color = property("QCS_color").value<QColor>();
    s.writeStartElement("color");
    s.writeTextElement("r", QString::number(color.red()));
    s.writeTextElement("g", QString::number(color.green()));
    s.writeTextElement("b", QString::number(color.blue()));
    s.writeEndElement();

    // we save textcolor as a hex value (QColor::name() returns the hex
    // representation, which can be used to create a QColor also
    QColor textcolor = static_cast<QVdial*>(m_widget)->getTextColor();
    s.writeTextElement("textcolor", textcolor.name());
    s.writeTextElement("showvalue",
                       property("QCS_showvalue").toBool() ? "true" : "false");
    s.writeTextElement("flatstyle",
                       property("QCS_flatstyle").toBool() ? "true" : "false");
    s.writeTextElement("integerMode",
                       property("QCS_integerMode").toBool() ? "true" : "false");
	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

QString QuteKnob::getWidgetType()
{
	return QString("BSBKnob");
}

void buttonSetColorIcon(QPushButton *button, QColor color, int size) {
    QPixmap pixmap(size, size);
    pixmap.fill(color);
    button->setPalette(QPalette(color));
    button->setIcon(pixmap);
}

void QuteKnob::selectKnobColor() {
    auto currentColor = m_widget->palette().color(QPalette::WindowText);
    QColor color = QColorDialog::getColor(currentColor, this);
    setColor(color);
    if(knobColorButton != nullptr) {
        buttonSetColorIcon(knobColorButton, color, 64);
    }
}

void QuteKnob::selectKnobTextColor() {
    auto currentColor = m_widget->palette().color(QPalette::WindowText);
    QColor c = QColorDialog::getColor(currentColor, this);
    setTextColor(c);
    if(knobColorButton != nullptr)
        buttonSetColorIcon(knobTextColorButton, c, 64);
}

void QuteKnob::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	dialog->setWindowTitle("Knob");
	QLabel *label = new QLabel(dialog);

	label->setText("Min =");
	layout->addWidget(label, 2, 0, Qt::AlignRight|Qt::AlignVCenter);
	minSpinBox = new QDoubleSpinBox(dialog);
    minSpinBox->setDecimals(4);
	minSpinBox->setRange(-99999.0, 99999.0);
	minSpinBox->setValue(property("QCS_minimum").toDouble());
	layout->addWidget(minSpinBox, 2,1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Max =");
	layout->addWidget(label, 2, 2, Qt::AlignRight|Qt::AlignVCenter);
	maxSpinBox = new QDoubleSpinBox(dialog);
    maxSpinBox->setDecimals(4);
	maxSpinBox->setRange(-99999.0, 99999.0);
	maxSpinBox->setValue(property("QCS_maximum").toDouble());
    layout->addWidget(maxSpinBox, 2, 3, Qt::AlignLeft|Qt::AlignVCenter);

    // label->setText("Resolution");
    // layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);

    flatStyleCheckBox = new QCheckBox(dialog);
    flatStyleCheckBox->setText("Flat style");
    flatStyleCheckBox->setToolTip("If checked, knob is drawn in a flat style. "
                                  "Otherwise, the native Qt look is used");
    flatStyleCheckBox->setCheckState(
                property("QCS_flatstyle").toBool()?Qt::Checked:Qt::Unchecked);
    layout->addWidget(flatStyleCheckBox, 5, 1, Qt::AlignLeft|Qt::AlignVCenter);

    displayValueCheckBox = new QCheckBox(dialog);
    displayValueCheckBox->setText("Display value");
    displayValueCheckBox->setToolTip("Show value as text inside the knob");
    displayValueCheckBox->setCheckState(
                property("QCS_showvalue").toBool()?Qt::Checked:Qt::Unchecked);
    layout->addWidget(displayValueCheckBox, 6, 1, Qt::AlignLeft|Qt::AlignVCenter);

    intModeCheckBox = new QCheckBox(dialog);
    intModeCheckBox->setText("Integer");
    intModeCheckBox->setToolTip("Constrain displayed value to nearest integer");
    intModeCheckBox->setCheckState(
                property("QCS_integerMode").toBool()?Qt::Checked:Qt::Unchecked);
    layout->addWidget(intModeCheckBox, 6, 2, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(dialog);
    label->setText("Color");
    layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);

    knobColorButton = new QPushButton(dialog);
    QColor color = property("QCS_color").value<QColor>();
    buttonSetColorIcon(knobColorButton, color, 64);
    layout->addWidget(knobColorButton, 7, 1, Qt::AlignLeft | Qt::AlignVCenter);
    connect(knobColorButton, SIGNAL(released()), this, SLOT(selectKnobColor()));

    label = new QLabel(dialog);
    label->setText("Text Color");
    layout->addWidget(label, 7, 2, Qt::AlignRight|Qt::AlignVCenter);

    knobTextColorButton = new QPushButton(dialog);
    QColor textcolor = QColor(property("QCS_textcolor").toString());
    buttonSetColorIcon(knobTextColorButton, textcolor, 64);
    layout->addWidget(knobTextColorButton, 7, 3, Qt::AlignLeft | Qt::AlignVCenter);
    connect(knobTextColorButton, SIGNAL(released()), this, SLOT(selectKnobTextColor()));

    connect(flatStyleCheckBox, SIGNAL(toggled(bool)),
            displayValueCheckBox, SLOT(setEnabled(bool)));
    connect(flatStyleCheckBox, SIGNAL(toggled(bool)),
            knobColorButton, SLOT(setEnabled(bool)));
    connect(flatStyleCheckBox, SIGNAL(toggled(bool)),
            knobColorButton, SLOT(setEnabled(bool)));
    connect(flatStyleCheckBox, SIGNAL(toggled(bool)),
            knobTextColorButton, SLOT(setEnabled(bool)));
    connect(flatStyleCheckBox, SIGNAL(toggled(bool)),
            label, SLOT(setEnabled(bool)));
    connect(flatStyleCheckBox, SIGNAL(toggled(bool)),
            intModeCheckBox, SLOT(setEnabled(bool)));


#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteKnob::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif

    setProperty("QCS_maximum", maxSpinBox->value());
	setProperty("QCS_minimum", minSpinBox->value());

    // QColor color = knobColorButton->palette().color(QPalette::Window);
    QColor color = static_cast<QVdial*>(m_widget)->getColor();

    setProperty("QCS_color", color);
    // QColor textcolor = knobTextColorButton->palette().color(QPalette::Window);
    QColor textcolor = static_cast<QVdial*>(m_widget)->getTextColor();
    setProperty("QCS_textcolor", textcolor.name());

    auto w = static_cast<QVdial*>(m_widget);
    w->setDisplayRange(minSpinBox->value(), maxSpinBox->value());

    bool showvalue = displayValueCheckBox->checkState();
    setProperty("QCS_showvalue", showvalue);
    w->setDrawValue(showvalue);

    bool flatstyle = flatStyleCheckBox->checkState();
    setProperty("QCS_flatstyle", flatstyle);
    w->setFlatStyle(flatstyle);

    bool intmode = intModeCheckBox->checkState();
    setProperty("QCS_integerMode", intmode);
    w->setIntegerMode(intmode);

#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif
    //Must be last to make sure the widgetChanged signal is last
    QuteWidget::applyProperties();
}

void QuteKnob::knobChanged(int value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	double min = property("QCS_minimum").toDouble();
	double max = property("QCS_maximum").toDouble();
	QDial *knob = static_cast<QDial *>(m_widget);
	double normalized = (double) (value - knob->minimum())
			/ (double) (knob->maximum() - knob->minimum());
	m_value =  min + (normalized * (max-min));
    // setInternalValue(scaledValue);
	m_valueChanged = true;
	QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	emit newValue(channelValue);
}

void QuteKnob::setColor(QColor c) {
    setProperty("QCS_color", c);
    static_cast<QVdial*>(m_widget)->setColor(c);
}

void QuteKnob::setTextColor(QColor c) {
    setProperty("QCS_textcolor", c.name());
    static_cast<QVdial*>(m_widget)->setTextColor(c);
}
