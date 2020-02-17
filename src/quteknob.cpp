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
    m_mouse_press_point = event->pos();
    m_dragging = true;
    m_base_value = value();
    m_temp_scale_factor = event->modifiers() & Qt::AltModifier ? 0.25f : 1.0f;
}


void QVdial::mouseReleaseEvent (QMouseEvent *event) {
    m_dragging = false;
}

void QVdial::mouseMoveEvent (QMouseEvent *event) {
    if (!m_dragging)
        return;
    float delta = (m_mouse_press_point.y() - event->y()) / (float)this->height() * (float)this->maximum();
    float fvalue = m_base_value + delta * m_temp_scale_factor * m_scale_factor;
    setValue((int)fvalue);
}

QuteKnob::QuteKnob(QWidget *parent) : QuteWidget(parent)
{
	//TODO add resolution to config dialog and set these values accordingly
    m_widget = new QVdial(this);
    static_cast<QVdial *>(m_widget)->setMinimum(0);
    static_cast<QVdial *>(m_widget)->setMaximum(10000);
    static_cast<QVdial *>(m_widget)->setNotchTarget(100);
    static_cast<QVdial *>(m_widget)->setNotchesVisible(true);


	m_widget->setPalette(QPalette(Qt::gray));
	m_widget->setContextMenuPolicy(Qt::NoContextMenu);
	m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
    setProperty("QCS_minimum", 0.0);
    setProperty("QCS_maximum", 99.0);
	setProperty("QCS_value", 0.0);
	setProperty("QCS_mode", "lin");
	setProperty("QCS_mouseControl", "continuous");
    // setProperty("QCS_mouseControlAct", "jump");
	setProperty("QCS_resolution", 0.01);
	setProperty("QCS_randomizable", false);
	setProperty("QCS_randomizableGroup", 0);
	connect(static_cast<QDial *>(m_widget), SIGNAL(valueChanged(int)), this, SLOT(knobChanged(int)));
}

QuteKnob::~QuteKnob()
{
}

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
    qDebug() << "QCS_maximum: " << max << "\n";
	setProperty("QCS_maximum", max);
	setProperty("QCS_minimum", min);
	m_valueChanged = true;
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
	double max = property("QCS_maximum").toDouble();
	double min = property("QCS_minimum").toDouble();
	int val = (int) (static_cast<QDial *>(m_widget)->maximum() * (m_value - min)/(max-min));
	m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	m_widget->blockSignals(true);
	static_cast<QDial *>(m_widget)->setValue(val);
	m_widget->blockSignals(false);
}

void QuteKnob::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
	//  qDebug() << "QuteSlider::applyInternalProperties()";
	//  QVariant prop;
	//  m_value = property("QCS_value").toDouble();
	//  m_value2 = property("QCS_value2").toDouble();
	//  m_stringValue = property("QCS_stringValue").toString();
	setValue(property("QCS_value").toDouble());
}

//void QuteKnob::setResolution(double resolution)
//{
//  setProperty("QCS_resolution", resolution);
//}

//void QuteKnob::setWidgetLine(QString line)
//{
//  m_line = line;
//}

void QuteKnob::setWidgetGeometry(int x, int y, int width, int height)
{
	//  qDebug() << "QuteKnob::setWidgetGeometry " << width << "," << height;
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
	if (property("QCS_midicc").toInt() >= 0 && property("QCS_midichan").toInt()>0) { // insert only if midi channel is above 0
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
	s.writeTextElement("resolution", QString::number(property("QCS_resolution").toDouble(), 'f', 8));
	s.writeStartElement("randomizable");
	s.writeAttribute("group", QString::number(property("QCS_randomizableGroup").toInt()));
	s.writeCharacters(property("QCS_randomizable").toBool() ? "true": "false");
	s.writeEndElement();

	// Thesecome from blue, but they are not implemented here
	//s.writeTextElement("knobWidth", "");
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
	minSpinBox->setDecimals(6);
	minSpinBox->setRange(-99999.0, 99999.0);
	minSpinBox->setValue(property("QCS_minimum").toDouble());
	layout->addWidget(minSpinBox, 2,1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Max =");
	layout->addWidget(label, 2, 2, Qt::AlignRight|Qt::AlignVCenter);
	maxSpinBox = new QDoubleSpinBox(dialog);
	maxSpinBox->setDecimals(6);
	maxSpinBox->setRange(-99999.0, 99999.0);
	maxSpinBox->setValue(property("QCS_maximum").toDouble());
	layout->addWidget(maxSpinBox, 2,3, Qt::AlignLeft|Qt::AlignVCenter);
	label->setText("Resolution");
	layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
	//   resolutionSpinBox = new QDoubleSpinBox(dialog);
	//   resolutionSpinBox->setDecimals(6);
	//   resolutionSpinBox->setValue(getResolution());
	//   layout->addWidget(resolutionSpinBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);
	//  setProperty("QCS_value", m_value);
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
	//   m_resolution = resolutionSpinBox->value();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	QuteWidget::applyProperties();  //Must be last to make sure the widgetChanged signal is last
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
	//  setInternalValue(scaledValue);
	m_valueChanged = true;
	QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	emit newValue(channelValue);
}

