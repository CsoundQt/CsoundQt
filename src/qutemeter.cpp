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

#include "qutemeter.h"

#include <math.h> //for isnan

// This class is called meter for historical reasons (MacCsound's widget was called meter)
// But it is a meter and a controller widget

QuteMeter::QuteMeter(QWidget *parent) : QuteWidget(parent)
{
	setGeometry(0,0, parent->width(), parent->height());
	m_widget = new MeterWidget(this);
	m_widget->setAutoFillBackground(true);
	m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
	//  m_widget->setWindowFlags(Qt::WindowStaysOnTopHint);
	canFocus(false);
	//   static_cast<MeterWidget *>(m_widget)->setRenderHints(QPainter::Antialiasing);
	//  connect(static_cast<MeterWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
	//  connect(static_cast<MeterWidget *>(m_widget), SIGNAL(newValues(double, double)), this, SLOT(setValuesFromWidget(double,double)));
	connect(static_cast<MeterWidget *>(m_widget), SIGNAL(newValue1(double)), this, SLOT(valueChanged(double)));
	connect(static_cast<MeterWidget *>(m_widget), SIGNAL(newValue2(double)), this, SLOT(value2Changed(double)));

	setProperty("QCS_xMin", 0.0);
	setProperty("QCS_xMax", 1.0);
	setProperty("QCS_yMin", 0.0);
	setProperty("QCS_yMax", 1.0);

	setProperty("QCS_type", "fill");
	setProperty("QCS_pointsize", 1);
	setProperty("QCS_fadeSpeed", 1.0);
	setProperty("QCS_mouseControl", "jump");
	setProperty("QCS_mouseControlAct", "press");

	setProperty("QCS_color", QColor(Qt::green));
	setProperty("QCS_bgcolor", QColor(Qt::black));
	setProperty("QCS_randomizable", false);
	setProperty("QCS_randomizableGroup", 0);
	setProperty("QCS_randomizableMode", "both");

}

QuteMeter::~QuteMeter()
{
}


void QuteMeter::setMidiValue(int value)
{
	double max, min;
	bool vertical;
	if (m_widget->width() > m_widget->height()) {
		vertical = false;
	}
	else {
		vertical = true;
	}
	if (vertical) {
		max = property("QCS_yMax").toDouble();
		min = property("QCS_yMin").toDouble();
	}
	else {
		max = property("QCS_xMax").toDouble();
		min = property("QCS_xMin").toDouble();
	}
	double newval = min + ((value / 127.0)* (max - min));
	setValue(newval);
	QPair<QString, double> channelValue(m_channel, newval);
	emit newValue(channelValue);
}

QString QuteMeter::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "ioMeter {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
	line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
	QColor color = property("QCS_color").value<QColor>();
	line += "{" + QString::number(color.red() * 256)
			+ ", " + QString::number(color.green() * 256)
			+ ", " + QString::number(color.blue() * 256) + "} ";
	line += "\"" + m_channel + "\" " + QString::number(m_value, 'f', 6) + " ";
	line += "\"" + m_channel2 + "\" " + QString::number(m_value2, 'f', 6) + " ";
	line += property("QCS_type").toString() + " ";
	line += QString::number(property("QCS_pointsize").toInt()) + " ";
	line += QString::number(property("QCS_fadeSpeed").toInt()) + " ";
	line += "mouse";
	//   qDebug("QuteMeter::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteMeter::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	s.writeTextElement("objectName2", m_channel2);
	s.writeTextElement("xMin", QString::number(property("QCS_xMin").toDouble(), 'f', 8));
	s.writeTextElement("xMax", QString::number(property("QCS_xMax").toDouble(), 'f', 8));
	s.writeTextElement("yMin", QString::number(property("QCS_yMin").toDouble(), 'f', 8));
	s.writeTextElement("yMax", QString::number(property("QCS_yMax").toDouble(), 'f', 8));
	s.writeTextElement("xValue", QString::number(m_value, 'f', 8));
	s.writeTextElement("yValue", QString::number(m_value2, 'f', 8));

	s.writeTextElement("type", property("QCS_type").toString());
	s.writeTextElement("pointsize", QString::number(property("QCS_pointsize").toInt()));
	s.writeTextElement("fadeSpeed",QString::number(property("QCS_fadeSpeed").toDouble(),'f',8));
	s.writeStartElement("mouseControl");
	s.writeAttribute("act", property("QCS_mouseControlAct").toString());
	s.writeCharacters(property("QCS_mouseControl").toString());
	s.writeEndElement();

	QColor color = property("QCS_color").value<QColor>();
	s.writeStartElement("color");
	s.writeTextElement("r", QString::number(color.red()));
	s.writeTextElement("g", QString::number(color.green()));
	s.writeTextElement("b", QString::number(color.blue()));
	s.writeEndElement();
	s.writeStartElement("randomizable");
	s.writeAttribute("mode", property("QCS_randomizableMode").toString());
	s.writeAttribute("group", QString::number(property("QCS_randomizableGroup").toInt()));
	s.writeCharacters(property("QCS_randomizable").toBool() ? "true":"false");
	s.writeEndElement();

	QColor bgcolor = property("QCS_bgcolor").value<QColor>();
	s.writeStartElement("bgcolor");
	s.writeTextElement("r", QString::number(bgcolor.red()));
	s.writeTextElement("g", QString::number(bgcolor.green()));
	s.writeTextElement("b", QString::number(bgcolor.blue()));
	s.writeEndElement();

	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

QString QuteMeter::getWidgetType()
{
	QString type = static_cast<MeterWidget *>(m_widget)->getType();
    if (type == "fill" || type == "line" || type == "llif") {
		return QString("BSBController");
	}
	//  else if (type == "crosshair" or type == "point") {
	//  }
	return QString("BSBController");
}

QString QuteMeter::getCabbageLine()
{
	QString type = static_cast<MeterWidget *>(m_widget)->getType();
    if (!(type == "crosshair" || type == "point")) {
		qDebug()<<"Meter can be converted to XYpad only if the type is crosshair or point";
		return QString();
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	QString line = "xypad ";
	line += QString("bounds(%1,%2,%3,%4), ").arg(x()).arg(y()).arg(width()).arg(height());
	line += QString("channel(\"%1\",\"%2\"), ").arg(m_channel).arg(m_channel2);
	line += QString("rangex(%1, %2, %3), ").arg(property("QCS_xMin").toDouble()).arg(property("QCS_xMax").toDouble()).arg(m_value);
	line += QString("rangey(%1, %2, %3)").arg(property("QCS_yMin").toDouble()).arg(property("QCS_yMax").toDouble()).arg(m_value2);

	//NB! meter does not have midi2 yet!
	if (property("QCS_midicc").toInt() >= 0 && property("QCS_midichan").toInt()>0) { // insert only if midi channel is above 0
		line += ", midiCtrl(\"" + QString::number(property("QCS_midichan").toInt()) + ",";
		line +=  QString::number(property("QCS_midicc").toInt()) + "\")";
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    return line;
}

QString QuteMeter::getQml()
{
    QString qml = QString();
	QString type = property("QCS_type").toString();
	if ( type != "fill") {
		qDebug() << "Currently exporting only meter controllers (type \"fill\") is supported";
		return qml;
	}
#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForWrite();
#endif
	//if ( m_widget->m_type!= "fill" ) // why error?
    // todo: only if fill - horizontal vüi vertical
    // todo: crosshair jm

	bool vertical;
	if (m_widget->width() > m_widget->height()) {
		vertical = false;
	} else {
		vertical = true;
	}
	double max, min, value;
	QString channel;
	if (vertical) {
		max = property("QCS_yMax").toDouble();
		min = property("QCS_yMin").toDouble();
		channel = m_channel2;
		value = m_value2;
	}
	else {
		max = property("QCS_xMax").toDouble();
		min = property("QCS_xMin").toDouble();
		channel = m_channel;
		value = m_value;
	}

	qml=QString(R"(
				Rectangle {
					x: %1 * scaleItem.scale
					y: %2 * scaleItem.scale
					width: %3 * scaleItem.scale
					height: %4 * scaleItem.scale
					color: "black"
					border.color: "black"
					border.width: 2
					property double min: %5
					property double max: %6
					property double value: %7
					property string channel: "%8"
					property bool isVertical: height>width

					MouseArea {
						anchors.fill: parent

						function setValue() { // value from min..max
							var value;
							if (parent.isVertical) {
								value = parent.min +  (1 - (mouseY/parent.height)) * (parent.max-parent.min);
							} else {
								value = parent.min +  (mouseX/parent.width) * (parent.max-parent.min);
							}

							if (value>parent.max) value=parent.max;
							if (value<parent.min) value=parent.min;
							if (typeof(csound) !== 'undefined' ) csound.setControlChannel(parent.channel, value);

							parent.value = value;
						}

						onClicked: setValue();
						onMouseYChanged: setValue();
					}

					Rectangle {
						property double relativeValue: (parent.value-parent.min)/(parent.max-parent.min)
						width: parent.isVertical ? parent.width - 2*parent.border.width :
												  (parent.width-2*parent.border.width) *relativeValue
						height: parent.isVertical ? (parent.height-2*parent.border.width) *relativeValue :
													parent.height - 2*parent.border.width

						anchors.margins: parent.border.width
						anchors.bottom: parent.bottom
						anchors.left: parent.left
						color: "%9"
					}
				}
				)").arg(x()).arg(y()).arg(width()).arg(height()).arg(min).arg(max).arg(value).
			arg(channel).arg(property("QCS_color").toString());


#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif

    return qml;

}

void QuteMeter::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	dialog->setWindowTitle("Controller");
	channelLabel->setText("Horizontal Channel name =");
	channelLabel->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	//  nameLineEdit->setText(getChannelName());

	QLabel *label = new QLabel(dialog);
	label = new QLabel(dialog);
	label->setText("Vertical Channel name =");
	layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
	name2LineEdit = new QLineEdit(dialog);
	name2LineEdit->setText(getChannel2Name());
	name2LineEdit->setMinimumWidth(320);
	layout->addWidget(name2LineEdit, 4,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
	//  if (static_cast<MeterWidget *>(m_widget)->getType() != "point" and ((MeterWidget *)m_widget)->getType() != "crosshair") {
	//    if (((MeterWidget *)m_widget)->m_vertical) {
	//      channelLabel->setEnabled(false);
	//      nameLineEdit->setEnabled(false);
	//    }
	//    else {
	//      label->setEnabled(false);
	//      name2LineEdit->setEnabled(false);
	//    }
	//  }

	label = new QLabel(dialog);
	label->setText("Color");
	label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
	colorButton = new QPushButton(dialog);
	QPixmap pixmap(64,64);
	pixmap.fill(static_cast<MeterWidget *>(m_widget)->getColor());
	colorButton->setIcon(pixmap);
	QPalette palette(static_cast<MeterWidget *>(m_widget)->getColor());
	palette.color(QPalette::Window);
	colorButton->setPalette(palette);
	layout->addWidget(colorButton, 5,1, Qt::AlignLeft|Qt::AlignVCenter);
	connect(colorButton, SIGNAL(released()), this, SLOT(selectTextColor()));

	label->setText("Type");
	label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
	typeComboBox = new QComboBox(dialog);
	typeComboBox->addItem("fill");
	typeComboBox->addItem("llif");
	typeComboBox->addItem("line");
	typeComboBox->addItem("crosshair");
	typeComboBox->addItem("point");
	typeComboBox->setCurrentIndex(typeComboBox->findText(static_cast<MeterWidget *>(m_widget)->getType()));
	layout->addWidget(typeComboBox, 6, 1, Qt::AlignLeft|Qt::AlignVCenter);

	label = new QLabel(dialog);
	label->setText("Point size:");
	label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);
	pointSizeSpinBox = new QSpinBox(dialog);
	pointSizeSpinBox->setValue(((MeterWidget *)m_widget)->getPointSize());
	layout->addWidget(pointSizeSpinBox, 7,1, Qt::AlignLeft|Qt::AlignVCenter);
	if (static_cast<MeterWidget *>(m_widget)->getType() != "point") {
		label->setEnabled(false);
		pointSizeSpinBox->setEnabled(false);

	}

	label = new QLabel(dialog);
	label->setText("Fade speed:");
	label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	layout->addWidget(label, 7, 2, Qt::AlignRight|Qt::AlignVCenter);
	fadeSpeedSpinBox = new QSpinBox(dialog);
	fadeSpeedSpinBox->setValue(property("QCS_fadeSpeed").toDouble());
	fadeSpeedSpinBox->setRange(0, 1000);
	layout->addWidget(fadeSpeedSpinBox, 7,3, Qt::AlignLeft|Qt::AlignVCenter);
	label->setEnabled(false);
	fadeSpeedSpinBox->setEnabled(false);

	label = new QLabel(dialog);
	label->setText("Behavior");
	label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	layout->addWidget(label, 8, 0, Qt::AlignRight|Qt::AlignVCenter);
	behaviorComboBox = new QComboBox(dialog);
	behaviorComboBox->addItem("jump");
	behaviorComboBox->addItem("relative");
	behaviorComboBox->addItem("none");
	behaviorComboBox->setCurrentIndex(behaviorComboBox->findText(property("QCS_mouseControl").toString()));
	layout->addWidget(behaviorComboBox,8, 1, Qt::AlignLeft|Qt::AlignVCenter);
	label->setEnabled(false);
	behaviorComboBox->setEnabled(false);
	label = new QLabel(dialog);
	label->setText("Min X value =");
	layout->addWidget(label,9, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_xMinBox = new QDoubleSpinBox(dialog);
	m_xMinBox->setRange(-999999999.0, 999999999.0);
	m_xMinBox->setValue(property("QCS_xMin").toDouble());
	layout->addWidget(m_xMinBox, 9,1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Max X value =");
	layout->addWidget(label, 9, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_xMaxBox = new QDoubleSpinBox(dialog);
	m_xMaxBox->setRange(-999999999.0, 999999999.0);
	m_xMaxBox->setValue(property("QCS_xMax").toDouble());
	layout->addWidget(m_xMaxBox, 9,3, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Min Y value =");
	layout->addWidget(label, 10, 0, Qt::AlignRight|Qt::AlignVCenter);
	m_yMinBox = new QDoubleSpinBox(dialog);
	m_yMinBox->setRange(-999999999.0, 999999999.0);
	m_yMinBox->setValue(property("QCS_yMin").toDouble());
	layout->addWidget(m_yMinBox, 10, 1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Max Y value =");
	layout->addWidget(label, 10, 2, Qt::AlignRight|Qt::AlignVCenter);
	m_yMaxBox = new QDoubleSpinBox(dialog);
	m_yMaxBox->setRange(-999999999.0, 999999999.0);
	m_yMaxBox->setValue(property("QCS_yMax").toDouble());
	layout->addWidget(m_yMaxBox, 10,3, Qt::AlignLeft|Qt::AlignVCenter);
	setProperty("QCS_xValue", m_value);
	setProperty("QCS_yValue", m_value2);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif

}

void QuteMeter::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	double val1 = m_value;
	double val2 = m_value2;
	if (val1 < property("QCS_xMin").toDouble()) { // Must check this in case number is -inf
		val1 =  property("QCS_xMin").toDouble();
	}
	if (val2 < property("QCS_yMin").toDouble()) {
		val2 =  property("QCS_yMin").toDouble();
	}
	m_widget->blockSignals(true);
	static_cast<MeterWidget *>(m_widget)->setValues(val1, val2);
	m_widget->blockSignals(false);
	m_valueChanged = false;
	m_value2Changed = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteMeter::applyProperties()
{
	//  setProperty("QCS_objectName", nameLineEdit->text());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	// Only properties should be changed here as applyInternalProperties takes care of the rest
	setProperty("QCS_objectName2", name2LineEdit->text());
	setProperty("QCS_color", colorButton->palette().color(QPalette::Window));
	setProperty("QCS_type", typeComboBox->currentText());
	setProperty("QCS_pointsize", pointSizeSpinBox->value());
	setProperty("QCS_fadeSpeed", fadeSpeedSpinBox->value());
	setProperty("QCS_mouseControl", behaviorComboBox->currentText());
	setProperty("QCS_xMin", m_xMinBox->value());
	setProperty("QCS_xMax", m_xMaxBox->value());
	setProperty("QCS_yMin", m_yMinBox->value());
	setProperty("QCS_yMax", m_yMaxBox->value());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	QuteWidget::applyProperties();  //Must be last to make sure the widgetChanged signal is last
//	qDebug("QuteMeter::applyProperties()");
}

void QuteMeter::setWidgetGeometry(int x,int y,int width,int height)
{
	QuteWidget::setWidgetGeometry(x,y,width, height);
	/* In MacCsound, meter widgets have an offset of about five pixels in every border
	 This has proven problematic in Qt, as the graphicsScene*/
	m_widget->blockSignals(true);
	static_cast<MeterWidget *>(m_widget)->setWidgetGeometry(0,0,width, height);
	m_widget->blockSignals(false);
}

void QuteMeter::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
	static_cast<MeterWidget *>(m_widget)->setColor(property("QCS_color").value<QColor>());
	static_cast<MeterWidget *>(m_widget)->setType(property("QCS_type").toString());
	static_cast<MeterWidget *>(m_widget)->setPointSize(property("QCS_pointsize").toInt());
	static_cast<MeterWidget *>(m_widget)->setRanges(property("QCS_xMin").toDouble(),
													property("QCS_xMax").toDouble(),
													property("QCS_yMin").toDouble(),
													property("QCS_yMax").toDouble());
	m_value = property("QCS_xValue").toDouble();
	m_value2 = property("QCS_yValue").toDouble();
	//  if (m_value2 == m_value) {
	//    qDebug() << "Warning! Controller Widget can't have the same name for both channels!";
	//    m_value2 = "";
	//  }
	setValue(m_value);
	setValue2(m_value2);
}


void QuteMeter::selectTextColor()
{
	QColor color = QColorDialog::getColor(property("QCS_color").value<QColor>(), this);
	if (color.isValid()) {
		QPixmap pixmap(64,64);
		pixmap.fill(color);
		colorButton->setIcon(pixmap);
		QPalette palette(color);
		palette.color(QPalette::Window);
		colorButton->setPalette(palette);
	}
}

void QuteMeter::valueChanged(double value1)
{
	//  QString type = property("QCS_type").toString();
	//  qDebug() << "QuteMeter::valueChanged " << value1;

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	m_value = value1;
	QPair<QString, double> channelValue;
	channelValue = QPair<QString, double>(m_channel, m_value);
	m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	emit newValue(channelValue);
}

void QuteMeter::value2Changed(double value2)
{
	//  QString type = property("QCS_type").toString();
	//  qDebug() << "QuteMeter::value2Changed "<< value2;

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	m_value2 = value2;
	QPair<QString, double> channelValue;
	channelValue = QPair<QString, double>(m_channel2, m_value2);
	m_value2Changed = true;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	emit newValue(channelValue);
}

/* Meter Widget ----------------------------------------*/

MeterWidget::MeterWidget(QWidget *parent) : QGraphicsView(parent)
{
	setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	setAlignment(Qt::AlignLeft | Qt::AlignTop);
	setTransformationAnchor(QGraphicsView::NoAnchor);
	setInteractive (true);
	m_scene = new QGraphicsScene(5,5, 20, 20, this);
	m_scene->setBackgroundBrush(Qt::black);
	m_scene->setSceneRect(0,0, 20, 20);
	setScene(m_scene);
	m_mouseDown = false;
	m_block = m_scene->addRect(0, 0, 0, 0, QPen() , QBrush(Qt::green));
	m_point = m_scene->addEllipse(0, 0, 0, 0, QPen(Qt::green) , QBrush(Qt::green));
	m_vline = m_scene->addLine(0, 0, 0, 0, QPen(Qt::green));
	m_hline = m_scene->addLine(0, 0, 0, 0, QPen(Qt::green));
}

MeterWidget::~MeterWidget()
{
}

QColor MeterWidget::getColor()
{
	return m_block->brush().color();
}

void MeterWidget::setValue(double value)
{
	//  qDebug() << "MeterWidget::setValue " <<value;
	//  if (isnan(value) != 0)
	//    return;
	//  if (value > m_xmax) {
	//    value = m_xmax;
	//  }
	//  if (value < m_xmin) {
	//    value = m_xmin;
	//  }
	if (m_value == value) {
		return;
	}
	mutex.lock();
	m_value = value;

	double portionx = (m_value -  m_xmin) / (m_xmax - m_xmin);
	double portiony = (m_value2 -  m_ymin) / (m_ymax - m_ymin);
    if (m_type == "fill" && !m_vertical) {
		m_block->setRect(0, 0, portionx*width(), height());
	}
    else if (m_type == "llif" && !m_vertical) {
		m_block->setRect(portionx*width(),0, width(), height());
	}
    else if (m_type == "line" && !m_vertical) {
		m_vline->setLine(portionx*width(), 0 ,portionx*width(), height());
	}
	else {
		m_vline->setLine(portionx*width(), 0 ,portionx*width(), height());
		m_point->setRect(portionx*width()- (m_pointSize/2.0), (1-portiony)*height()- (m_pointSize/2.0), m_pointSize, m_pointSize);
	}
	mutex.unlock();
	//  emit valueChanged(m_value);
}

void MeterWidget::setValue2(double value)
{
	//  qDebug() << "MeterWidget::setValue2 " << value;
	//  if (value > m_ymax) {
	//    value = m_ymax;
	//  }
	//  if (value < m_ymin) {
	//    value = m_ymin;
	//  }
	if (m_value2 == value) {
		return;
	}
	mutex.lock();
	m_value2 = value;
	double portionx = (m_value -  m_xmin) / (m_xmax - m_xmin);
	double portiony = (m_value2 -  m_ymin) / (m_ymax - m_ymin);
    if (m_type == "fill" && m_vertical) {
		m_block->setRect(0, (1-portiony)*height(), width(), height());
	}
    else if (m_type == "llif" && m_vertical) {
		m_block->setRect(0, 0, width(), (1-portiony)*height());
	}
    else if (m_type == "line" && m_vertical) {
		m_hline->setLine(0, (1-portiony)*height(), width(), (1-portiony)*height());
		//    m_hline->setLine(portiony*width(), 0 ,portiony*width(), height());
	}
	else {
		m_hline->setLine(0, (1-portiony)*height(), width(), (1-portiony)*height());
		m_point->setRect(portionx*width()- (m_pointSize/2.0), (1-portiony)*height()- (m_pointSize/2.0), m_pointSize, m_pointSize);
	}
	mutex.unlock();
	//  emit value2Changed(m_value2);
}

void MeterWidget::setValues(double value1, double value2)
{
	if (m_value2 == value2 && m_value == value1) {
		return;
	}
	mutex.lock();
	m_value = value1;
	m_value2 = value2;
	double portionx = (m_value -  m_xmin) / (m_xmax - m_xmin);
	double portiony = (m_value2 -  m_ymin) / (m_ymax - m_ymin);
	if (m_type == "fill") {
		if (!m_vertical) {
			m_block->setRect(0, 0, portionx*width(), height());
		}
		else {
			m_block->setRect(0, (1-portiony)*height(), width(), portiony * height());
		}
	}
	else if (m_type == "llif") {
		if (!m_vertical) {
			m_block->setRect(portionx*width(),0, width(), height());
		}
		else {
			m_block->setRect(0, 0, width(), (1-portiony)*height());
		}
	}
	else if (m_type == "line") {
		if (!m_vertical) {
			m_vline->setLine(portionx*width(), 0 ,portionx*width(), height());
		}
		else {
			m_hline->setLine(0, (1-portiony)*height(), width(), (1-portiony)*height());
		}
	}
	else {
		m_vline->setLine(portionx*width(), 0 ,portionx*width(), height());
		m_hline->setLine(0, (1-portiony)*height(), width(), (1-portiony)*height());
		m_point->setRect(portionx*width()- (m_pointSize/2.0), (1-portiony)*height()- (m_pointSize/2.0), m_pointSize, m_pointSize);
	}
	mutex.unlock();

}

void MeterWidget::setType(QString type)
{
	//   qDebug() << "MeterWidget::setType " << type << m_vertical;
	if (type == "fill") {
		m_type = type;
		m_block->show();
		m_point->hide();
		m_vline->hide();
		m_hline->hide();
	}
	else if (type == "llif") {
		m_type = type;
		m_block->show();
		m_point->hide();
		m_vline->hide();
		m_hline->hide();
	}
	else if (type == "line") {
		m_type = type;
		m_block->hide();
		m_point->hide();
		if (m_vertical) {
			m_vline->hide();
			m_hline->show();
		}
		else {
			m_vline->show();
			m_hline->hide();
		}
	}
	else if (type == "crosshair") {
		m_type = type;
		m_block->hide();
		m_point->hide();
		m_vline->show();
		m_hline->show();
	}
	else if (type == "point") {
		m_type = type;
		m_block->hide();
		m_point->show();
		m_vline->hide();
		m_hline->hide();
	}
}

void MeterWidget::setRanges(double xmin, double xmax, double ymin, double ymax)
{
	m_xmin = xmin;
	m_xmax = xmax;
	m_ymin = ymin;
	m_ymax = ymax;
}

void MeterWidget::setPointSize(int size)
{
	m_pointSize = size;
	m_point->setRect(m_value2*width()- (m_pointSize/2.0), (1-m_value)*height()- (m_pointSize/2.0), m_pointSize, m_pointSize);
}

void MeterWidget::setColor(QColor color)
{
	//   qDebug("MeterWidget::setColor()");
	m_block->setBrush(QBrush(color));
	m_point->setPen(QPen(Qt::NoPen));
	m_point->setBrush(QBrush(color));
	m_vline->setPen(QPen(color));
	m_hline->setPen(QPen(color));
}

void MeterWidget::setWidgetGeometry(int x,int y,int width,int height)
{
	m_scene->setSceneRect(0,0, width, height);
	setSceneRect(0,0, width, height);
	setGeometry(x,y,width, height);
	setMaximumSize(width, height);
	if (width > height)
		m_vertical = false;
	else
		m_vertical = true;
	setType(m_type);  // update widgets which depend on verticality
}

void MeterWidget::mouseMoveEvent(QMouseEvent* event)
{
	if (event->buttons() & Qt::LeftButton) {
		//     if (event->x() > 0 and event->x()< width() and
		//         event->y() > 0 and event->y()< height())
		double newhor = m_xmin + ((m_xmax - m_xmin ) * (double)event->x()/ width() );
		double newvert = m_ymin + ((m_ymax - m_ymin ) * (1 - ((double)event->y()/ height())));
		if (newhor > m_xmax) {
			newhor = m_xmax;
		}
		else if (newhor < m_xmin) {
			newhor = m_xmin;
		}
		if (newvert > m_ymax) {
			newvert = m_ymax;
		}
		else if (newvert < m_ymin) {
			newvert = m_ymin;
		}
		if ( m_type == "line" || m_type == "llif" || m_type == "fill" ) {
			if (m_vertical) {
				emit newValue2(newvert);
			}
			else {
				emit newValue1(newhor);
			}
		}
		else if (m_type == "crosshair" || m_type == "point") {
			emit newValue1(newhor);
			emit newValue2(newvert);
		}
	}
}

void MeterWidget::mousePressEvent(QMouseEvent* event)
{
	if (event->buttons() & Qt::LeftButton) {
		//     if (event->x() > 0 and event->x()< width() and
		//         event->y() > 0 and event->y()< height())
		double newhor =  m_xmin + ((m_xmax - m_xmin ) * (double)event->x()/ width());
		double newvert = m_ymin + ((m_ymax - m_ymin ) * (1 - ((double)event->y()/ height())));
		if ( (m_type == "line" || m_type == "llif" || m_type == "fill")) {
			if (m_vertical) {
				emit newValue2(newvert);
			}
			else {
				emit newValue1(newhor);
			}
		}
		else if (m_type == "crosshair" || m_type == "point") {
			emit newValue1(newhor);
			emit newValue2(newvert);
		}
	}
}

