/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of QuteCsound.

	QuteCsound is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	QuteCsound is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "qutecheckbox.h"

QuteCheckBox::QuteCheckBox(QWidget *parent) : QuteWidget(parent)
{
	m_widget = new QCheckBox(this);
	m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
	m_widget->setContextMenuPolicy(Qt::NoContextMenu);
	canFocus(false);

	setProperty("QCS_selected", false);
	setProperty("QCS_label", "");
	setProperty("QCS_pressedValue", 1.0);
	setProperty("QCS_randomizable", false);
	setProperty("QCS_randomizableGroup", 0);

	m_currentValue = 0;

	connect(static_cast<QCheckBox *>(m_widget), SIGNAL(stateChanged(int)), this, SLOT(stateChanged(int)));
}

QuteCheckBox::~QuteCheckBox()
{
}

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

QString QuteCheckBox::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "ioCheckbox {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
	line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
	line += (static_cast<QCheckBox *>(m_widget)->isChecked()? QString("on "):QString("off "));
	line += m_channel;
	//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteCheckBox::getCabbageLine()
{
	QString line = "checkbox channel(\"" + m_channel + "\"),  ";
	line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
	line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
	line += "value(" + (static_cast<QCheckBox *>(m_widget)->isChecked()?
							QString("1!"):QString("0")) + "), ";
	line += "caption(\"" +  property("QCS_label").toString() + "\")";
	return line;
}

QString QuteCheckBox::getWidgetType()
{
	return QString("BSBCheckBox");
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
	s.writeTextElement("label", property("QCS_label").toString());
	s.writeTextElement("pressedValue", QString::number(property("QCS_pressedValue").toDouble()));
	s.writeStartElement("randomizable");
	s.writeAttribute("group", QString::number(property("QCS_randomizableGroup").toInt()));
	s.writeCharacters(property("QCS_randomizable").toBool() ? "true": "false");
	s.writeEndElement();
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
	//  setProperty("QCS_pressedValue", m_value);
	setProperty("QCS_selected", m_currentValue != 0);
	m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteCheckBox::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
	//  qDebug() << "QuteSlider::applyInternalProperties()";
	m_value = property("QCS_pressedValue").toDouble(); // Pressed value must go before selected to make sure it has the right value...
	setValue(property("QCS_selected").toBool() ? 1:0);
	setLabel(property("QCS_label").toString());
}

void QuteCheckBox::stateChanged(int state)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	m_currentValue = (state != Qt::Unchecked ? property("QCS_pressedValue").toDouble() : 0);
	QPair<QString, double> channelValue(m_channel, m_currentValue);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	//  qDebug() << "QuteCheckBox::stateChanged" << state << property("QCS_pressedValue").toDouble() << m_currentValue;
	emit newValue(channelValue);
}

void QuteCheckBox::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	setProperty("QCS_pressedValue", valueBox->value());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	QuteWidget::applyProperties();  //Must be last to make sure the widgetChanged signal is last
}

void QuteCheckBox::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
	dialog->setWindowTitle("Check Box");
	QLabel * label = new QLabel(dialog);
	label->setText("Pressed Value");
	layout->addWidget(label, 4, 2, Qt::AlignRight|Qt::AlignVCenter);
	valueBox = new QDoubleSpinBox(dialog);
	valueBox->setDecimals(6);
	valueBox->setRange(-9999999.0, 9999999.0);
	layout->addWidget(valueBox, 4, 3, Qt::AlignLeft|Qt::AlignVCenter);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	valueBox->setValue(property("QCS_pressedValue").toDouble());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}
