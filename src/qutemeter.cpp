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

using namespace Qt::StringLiterals;

// This class is called meter for historical reasons (MacCsound's widget was called meter)
// But it is a meter and a controller widget

QuteMeter::QuteMeter(QWidget *parent) : QuteWidget(parent)
{
    setGeometry(0,0, parent->width(), parent->height());
    m_widget = new MeterWidget(this);
    m_widget->setAutoFillBackground(true);
    //  m_widget->setWindowFlags(Qt::WindowStaysOnTopHint);
    canFocus(false);
    //   static_cast<MeterWidget *>(m_widget)->setRenderHints(QPainter::Antialiasing);
    //  connect(static_cast<MeterWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
    //  connect(static_cast<MeterWidget *>(m_widget), SIGNAL(newValues(double, double)), this, SLOT(setValuesFromWidget(double,double)));

    setProperty("CSQT_xMin", 0.0);
    setProperty("CSQT_xMax", 1.0);
    setProperty("CSQT_yMin", 0.0);
    setProperty("CSQT_yMax", 1.0);

    setProperty("CSQT_type", "fill");
    setProperty("CSQT_pointsize", 1);
    setProperty("CSQT_exponent", 1.0);

    setProperty("CSQT_color", QColor(Qt::green));
    setProperty("CSQT_bgcolor", QColor(30, 30, 30));
    setProperty("CSQT_randomizable", false);
    setProperty("CSQT_randomizableGroup", 0);
    setProperty("CSQT_randomizableMode", "both");

    setProperty("CSQT_borderColor", "#00FF00");
    setProperty("CSQT_borderWidth", 1);

    connect(static_cast<MeterWidget *>(m_widget), SIGNAL(newValue1(double)),
            this, SLOT(valueChanged(double)));
    connect(static_cast<MeterWidget *>(m_widget), SIGNAL(newValue2(double)),
            this, SLOT(value2Changed(double)));
    m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels

}

QuteMeter::~QuteMeter()
{
}

QuteWidgetType QuteMeter::getWidgetTypeID() { return QuteWidgetType::CONTROLLER; }


void QuteMeter::setMidiValue(int value)
{
    auto meter = static_cast<MeterWidget *>(m_widget);
    // MIDI maps linearly onto the GUI position; the exponent then maps the
    // position to the real value of the active axis.
    const bool vertical = !(meter->width() > meter->height());
    const ValueMapping mapping = vertical ? meter->yMapping() : meter->xMapping();
    double newval = mapping.toValue(value / 127.0);
    setValue(newval);
    QPair<QString, double> channelValue(m_channel, newval);
    emit newValue(channelValue);
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
    s.writeTextElement("xMin", QString::number(property("CSQT_xMin").toDouble(), 'f', 8));
    s.writeTextElement("xMax", QString::number(property("CSQT_xMax").toDouble(), 'f', 8));
    s.writeTextElement("yMin", QString::number(property("CSQT_yMin").toDouble(), 'f', 8));
    s.writeTextElement("yMax", QString::number(property("CSQT_yMax").toDouble(), 'f', 8));
    s.writeTextElement("xValue", QString::number(m_value, 'f', 8));
    s.writeTextElement("yValue", QString::number(m_value2, 'f', 8));

    s.writeTextElement("type", property("CSQT_type").toString());
    s.writeTextElement("pointsize", QString::number(property("CSQT_pointsize").toInt()));
    s.writeTextElement("exponent", QString::number(property("CSQT_exponent").toDouble(), 'f', 8));

    s.writeTextElement("bordermode", "border");
    s.writeTextElement("borderColor", property("CSQT_borderColor").toString());
    s.writeTextElement("borderWidth", QString::number(property("CSQT_borderWidth").toInt()));

    QColor color = property("CSQT_color").value<QColor>();
    writeColorElement(s, "color", color);
    s.writeStartElement("randomizable");
    s.writeAttribute("mode", property("CSQT_randomizableMode").toString());
    s.writeAttribute("group", QString::number(property("CSQT_randomizableGroup").toInt()));
    s.writeCharacters(property("CSQT_randomizable").toBool() ? "true":"false");
    s.writeEndElement();

    QColor bgcolor = property("CSQT_bgcolor").value<QColor>();
    writeColorElement(s, "bgcolor", bgcolor);

    s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif
    return xmlText;
}

QString QuteMeter::getWidgetType()
{
    // QString type = static_cast<MeterWidget *>(m_widget)->getType();
    auto type = static_cast<MeterWidget*>(m_widget)->getMeterType();
    if (type == MeterWidgetType::Fill ||
            type == MeterWidgetType::Line ||
            type == MeterWidgetType::Llif) {
        return QString("BSBController");
    }
    //  else if (type == "crosshair" or type == "point") {
    //  }
    return QString("BSBController");
}

QString QuteMeter::getQml()
{
    QString qml = QString();
    QString type = property("CSQT_type").toString();
    if ( type != "fill") {
        qDebug() << "Currently exporting only meter controllers (type \"fill\") is supported";
        return qml;
    }
#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForWrite();
#endif
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
        max = property("CSQT_yMax").toDouble();
        min = property("CSQT_yMin").toDouble();
        channel = m_channel2;
        value = m_value2;
    }
    else {
        max = property("CSQT_xMax").toDouble();
        min = property("CSQT_xMin").toDouble();
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
                    border.width: 1
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
            arg(channel).arg(property("CSQT_color").toString());


#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif

    return qml;

}

void QuteMeter::createPropertiesDialog()
{
    QuteWidget::createPropertiesDialog();

#ifdef USE_WIDGET_MUTEX
    widgetLock.lockForRead();
#endif
    dialog->setWindowTitle("Controller");

    int row = 4;
    channelLabel->setText(tr("Horizontal Channel"));
    channelLabel->setAlignment(Qt::AlignRight|Qt::AlignVCenter);

    QLabel *label = nullptr;
    // Put the second channel in the shared Widget group, between the primary
    // channel and the description.
    if (widgetGroup != nullptr) {
        auto *groupLayout = qobject_cast<QGridLayout *>(widgetGroup->layout());
        if (groupLayout != nullptr) {
            groupLayout->removeWidget(descriptionLabel);
            groupLayout->removeWidget(descriptionLineEdit);
            groupLayout->removeWidget(enabledCheckBox);

            label = new QLabel(tr("Vertical Channel"), widgetGroup);
            groupLayout->addWidget(label, 1, 0, Qt::AlignRight|Qt::AlignVCenter);

            name2LineEdit = new QLineEdit(widgetGroup);
            name2LineEdit->setText(getChannel2Name());
            name2LineEdit->setFixedWidth(160);
            groupLayout->addWidget(name2LineEdit, 1, 1, 1, 4,
                                   Qt::AlignLeft|Qt::AlignVCenter);

            groupLayout->addWidget(descriptionLabel, 2, 0,
                                   Qt::AlignRight|Qt::AlignVCenter);
            groupLayout->addWidget(descriptionLineEdit, 2, 1, 1, 4,
                                   Qt::AlignVCenter);
            groupLayout->addWidget(enabledCheckBox, 3, 1, 1, 4,
                                   Qt::AlignLeft|Qt::AlignVCenter);
        }
    }
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
    auto w = static_cast<MeterWidget *>(m_widget);
    label = new QLabel("Color", dialog);
    label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
    layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);

    colorButton = new SelectColorButton(dialog);
    colorButton->setColor(static_cast<MeterWidget *>(m_widget)->getColor());
    layout->addWidget(colorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel("Background", dialog);
    layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);

    bgColorButton = new SelectColorButton(dialog);
    bgColorButton->setColor(static_cast<MeterWidget *>(m_widget)->getBgColor());
    layout->addWidget(bgColorButton, row, 3, Qt::AlignLeft|Qt::AlignVCenter);
    row++;

    label = new QLabel(tr("Border"), dialog);
    layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);
    borderColorLabel = label;

    borderColorButton = new SelectColorButton(dialog);
    borderColorButton->setColor(QColor(property("CSQT_borderColor").toString()));
    layout->addWidget(borderColorButton, row, 1, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(tr("Border Width"), dialog);
    layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);

    borderWidthSpinBox = new QSpinBox(dialog);
    borderWidthSpinBox->unsetLocale();
    borderWidthSpinBox->setRange(0, 64);
    borderWidthSpinBox->setValue(property("CSQT_borderWidth").toInt());
    borderWidthSpinBox->setToolTip(tr("Border width in pixels. Set to 0 to hide the border."));
    layout->addWidget(borderWidthSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);

    auto updateBorderColorState = [this](int width) {
        const bool enabled = width > 0;
        borderColorButton->setEnabled(enabled);
        if (borderColorLabel != nullptr)
            borderColorLabel->setEnabled(enabled);
    };
    connect(borderWidthSpinBox, QOverload<int>::of(&QSpinBox::valueChanged),
            this, updateBorderColorState);
    updateBorderColorState(borderWidthSpinBox->value());
    
    row++;
    
    label = new QLabel(dialog);
    label->setText("Type");
    label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
    layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);

    typeComboBox = new QComboBox(dialog);
    typeComboBox->addItem("fill");
    typeComboBox->addItem("llif");
    typeComboBox->addItem("line");
    typeComboBox->addItem("crosshair");
    typeComboBox->addItem("point");
    typeComboBox->setCurrentIndex(typeComboBox->findText(w->getType()));
    layout->addWidget(typeComboBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(dialog);
    label->setText("Size");
    label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
    layout->addWidget(label, row, 2, Qt::AlignRight|Qt::AlignVCenter);

    pointSizeSpinBox = new QSpinBox(dialog);
    pointSizeSpinBox->unsetLocale();
    pointSizeSpinBox->setValue(w->getPointSize());
    pointSizeSpinBox->setToolTip("Size of the point / line if applicable");
    layout->addWidget(pointSizeSpinBox, row, 3, Qt::AlignLeft|Qt::AlignVCenter);

    if(w->getMeterType() != MeterWidgetType::Point &&
            w->getMeterType() != MeterWidgetType::Line) {
        // label->setEnabled(false);
        pointSizeSpinBox->setEnabled(false);
    }

    connect(typeComboBox, SIGNAL(currentIndexChanged(int)),
            this, SLOT(checkTypeComboBox()));
    ++row;

    label = new QLabel(dialog);
    label->setText(tr("X Range"));
    layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);

    m_xMinBox = new QDoubleSpinBox(dialog);
    m_xMinBox->setDecimals(4);
    m_xMinBox->setRange(-999999999.0, 999999999.0);
    m_xMinBox->setMaximumWidth(100);
    m_xMinBox->setValue(property("CSQT_xMin").toDouble());
    m_xMinBox->setToolTip(tr("Minimum X value"));

    m_xMaxBox = new QDoubleSpinBox(dialog);
    m_xMaxBox->setDecimals(4);
    m_xMaxBox->setRange(-999999999.0, 999999999.0);
    m_xMaxBox->setMaximumWidth(100);
    m_xMaxBox->setValue(property("CSQT_xMax").toDouble());
    m_xMaxBox->setToolTip(tr("Maximum X value"));

    auto *xRangeRow = new QHBoxLayout;
    xRangeRow->setContentsMargins(0, 0, 0, 0);
    xRangeRow->setSpacing(6);
    xRangeRow->addWidget(m_xMinBox);
    xRangeRow->addWidget(new QLabel(u"–"_s, dialog));
    xRangeRow->addWidget(m_xMaxBox);
    xRangeRow->addStretch();
    layout->addLayout(xRangeRow, row, 1, 1, 3,
                      Qt::AlignLeft|Qt::AlignVCenter);
    ++row;

    label = new QLabel(dialog);
    label->setText(tr("Y Range"));
    layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);

    m_yMinBox = new QDoubleSpinBox(dialog);
    m_yMinBox->setDecimals(4);
    m_yMinBox->setRange(-999999999.0, 999999999.0);
    m_yMinBox->setMaximumWidth(100);
    m_yMinBox->setValue(property("CSQT_yMin").toDouble());
    m_yMinBox->setToolTip(tr("Minimum Y value"));

    m_yMaxBox = new QDoubleSpinBox(dialog);
    m_yMaxBox->setDecimals(4);
    m_yMaxBox->setRange(-999999999.0, 999999999.0);
    m_yMaxBox->setMaximumWidth(100);
    m_yMaxBox->setValue(property("CSQT_yMax").toDouble());
    m_yMaxBox->setToolTip(tr("Maximum Y value"));

    auto *yRangeRow = new QHBoxLayout;
    yRangeRow->setContentsMargins(0, 0, 0, 0);
    yRangeRow->setSpacing(6);
    yRangeRow->addWidget(m_yMinBox);
    yRangeRow->addWidget(new QLabel(u"–"_s, dialog));
    yRangeRow->addWidget(m_yMaxBox);
    yRangeRow->addStretch();
    layout->addLayout(yRangeRow, row, 1, 1, 3,
                      Qt::AlignLeft|Qt::AlignVCenter);
    ++row;

    label = new QLabel("Exponent =", dialog);
    layout->addWidget(label, row, 0, Qt::AlignRight|Qt::AlignVCenter);

    exponentSpinBox = new QDoubleSpinBox(dialog);
    exponentSpinBox->setDecimals(3);
    exponentSpinBox->setRange(0.001, 100.0);
    exponentSpinBox->setSingleStep(0.1);
    exponentSpinBox->setValue(property("CSQT_exponent").toDouble());
    exponentSpinBox->setToolTip("Skew of the value curve for the active axis: 1 is linear, "
                                "values > 1 give finer control near the minimum, "
                                "values < 1 finer control near the maximum. "
                                "Applies only to slider-like controllers (fill, llif, line)");
    layout->addWidget(exponentSpinBox, row, 1, Qt::AlignLeft|Qt::AlignVCenter);
    ++row;
    // The exponent only applies to slider-like types (a single active axis).
    exponentSpinBox->setEnabled(w->isSlider());
    label->setEnabled(w->isSlider());

    setProperty("CSQT_xValue", m_value);
    setProperty("CSQT_yValue", m_value2);
#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif

}

void QuteMeter::checkTypeComboBox() {
    qDebug() << "checkTypeComboBox";
    QString metertype = typeComboBox->currentText();
    if(metertype == "line" || metertype == "point" )
        pointSizeSpinBox->setEnabled(true);
    else {
        pointSizeSpinBox->setEnabled(false);
    }
    // The exponent is only meaningful for slider-like (single axis) types.
    if(exponentSpinBox != nullptr) {
        exponentSpinBox->setEnabled(metertype == "fill" || metertype == "llif"
                                    || metertype == "line");
    }
}

void QuteMeter::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForRead();
#endif
    double val1 = m_value;
    double val2 = m_value2;
    if (val1 < xMin()) { // Must check this in case number is -inf
        val1 =  xMin();
    }
    if (val2 < yMin()) {
        val2 =  yMin();
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
    //  setProperty("CSQT_objectName", nameLineEdit->text());
#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForRead();
#endif
    // Only properties should be changed here as applyInternalProperties takes care of the rest
    setProperty("CSQT_objectName2", name2LineEdit->text());
    // setProperty("CSQT_color", colorButton->palette().color(QPalette::Window));
    setProperty("CSQT_color", colorButton->getColor());
    // setProperty("CSQT_bgcolor", bgColorButton->palette().color(QPalette::Window));
    setProperty("CSQT_bgcolor", bgColorButton->getColor());
    setProperty("CSQT_type", typeComboBox->currentText());
    setProperty("CSQT_pointsize", pointSizeSpinBox->value());
    setProperty("CSQT_exponent", exponentSpinBox->value());
    setProperty("CSQT_xMin", m_xMinBox->value());
    setProperty("CSQT_xMax", m_xMaxBox->value());
    setProperty("CSQT_yMin", m_yMinBox->value());
    setProperty("CSQT_yMax", m_yMaxBox->value());
    setProperty("CSQT_borderColor", borderColorButton->getColor().name());
    setProperty("CSQT_borderWidth", borderWidthSpinBox->value());
#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif
    QuteWidget::applyProperties();  //Must be last to make sure the widgetChanged signal is last
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

bool QuteMeter::applyProperty(const QString &name)
{
	auto meter = static_cast<MeterWidget *>(m_widget);
	if (name == "CSQT_color") {
		meter->setColor(property("CSQT_color").value<QColor>());
		return true;
	}
	if (name == "CSQT_bgcolor") {
		meter->setBgColor(property("CSQT_bgcolor").value<QColor>());
		return true;
	}
	if (name == "CSQT_xValue") {
		m_value = property("CSQT_xValue").toDouble();
		setValue(m_value);
		return true;
	}
	if (name == "CSQT_yValue") {
		m_value2 = property("CSQT_yValue").toDouble();
		setValue2(m_value2);
		return true;
	}
	if (name == "CSQT_exponent") {
		meter->setExponent(property("CSQT_exponent").toDouble());
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteMeter::applyInternalProperties()
{
    QuteWidget::applyInternalProperties();
    auto meter = static_cast<MeterWidget *>(m_widget);
    meter->setColor(property("CSQT_color").value<QColor>());
    meter->setBgColor(property("CSQT_bgcolor").value<QColor>());
    meter->showBackground(true);
    meter->setType(property("CSQT_type").toString());
    meter->setPointSize(property("CSQT_pointsize").toInt());
    meter->setRanges(property("CSQT_xMin").toDouble(),
                     property("CSQT_xMax").toDouble(),
                     property("CSQT_yMin").toDouble(),
                     property("CSQT_yMax").toDouble());
    meter->setExponent(property("CSQT_exponent").toDouble());
    meter->setBorderColor(QColor(property("CSQT_borderColor").toString()));
    meter->setBorderWidth(property("CSQT_borderWidth").toInt());

    m_value = property("CSQT_xValue").toDouble();
    m_value2 = property("CSQT_yValue").toDouble();
    //  if (m_value2 == m_value) {
    //    qDebug() << "Warning! Controller Widget can't have the same name for both channels!";
    //    m_value2 = "";
    //  }
    setValue(m_value);
    setValue2(m_value2);
}


void QuteMeter::valueChanged(double value1)
{
    //  QString type = property("CSQT_type").toString();
    //  qDebug() << "QuteMeter::valueChanged " << value1;

#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForRead();
#endif
    m_value = value1;
    m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif
    QPair<QString, double> channelValue(m_channel, m_value);
    emit newValue(channelValue);
}

void QuteMeter::value2Changed(double value2)
{
    //  QString type = property("CSQT_type").toString();
    //  qDebug() << "QuteMeter::value2Changed "<< value2;

#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForRead();
#endif
    m_value2 = value2;
    m_value2Changed = true;
#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif
    QPair<QString, double> channelValue(m_channel2, m_value2);
    emit newValue(channelValue);
}

/* Meter Widget ----------------------------------------*/

MeterWidget::MeterWidget(QWidget *parent) : QGraphicsView(parent)
{
    //auto t0 = std::chrono::high_resolution_clock::now();
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setAlignment(Qt::AlignLeft | Qt::AlignTop);
    setTransformationAnchor(QGraphicsView::NoAnchor);
    setInteractive (true);
    // m_scene = new QGraphicsScene(5,5, 20, 20, this);
    m_scene = new QGraphicsScene(0, 0, 20, 20, this);
    m_scene->setBackgroundBrush(Qt::black);
    m_scene->setSceneRect(0, 0, 20, 20);
    m_showBackground = true;
    m_bgcolor = Qt::black;
    setFrameStyle(QFrame::NoFrame);

    setScene(m_scene);
    m_mouseDown = false;
    // Defaults, so updateGeometry() is safe before setType()/setRanges() run.
    m_value = 0.0;
    m_value2 = 0.0;
    m_xmin = 0.0;
    m_xmax = 1.0;
    m_ymin = 0.0;
    m_ymax = 1.0;
    m_metertype = MeterWidgetType::Fill;
    m_type = "fill";
    m_pointSize = 1;
    m_vertical = false;
    m_exponent = 1.0;
    auto borderPen = QPen(QColor(Qt::green).darker(150), 1);
    auto blockPen = Qt::NoPen;
    m_block = m_scene->addRect(0, 0, 0, 0, blockPen, QBrush(Qt::green));
    m_point = m_scene->addEllipse(0, 0, 0, 0, QPen(Qt::green) , QBrush(Qt::green));
    m_vline = m_scene->addLine(0, 0, 0, 0, QPen(Qt::green));
    m_hline = m_scene->addLine(0, 0, 0, 0, QPen(Qt::green));
    m_border = m_scene->addRect(m_scene->sceneRect(), borderPen, Qt::NoBrush);
    m_border->hide();
    // auto t1 = std::chrono::high_resolution_clock::now();
    // QDEBUG << "... MeterWidget constructor " << std::chrono::duration<double, std::milli>(t1-t0).count() << "ms";

}

MeterWidget::~MeterWidget()
{
}

QColor MeterWidget::getColor()
{
    return m_block->brush().color();
}

QColor MeterWidget::getBgColor()
{
    return m_scene->backgroundBrush().color();
}

QColor MeterWidget::getBorderColor()
{
    return m_border->pen().color();
}



template <MeterWidget::Axis axis>
void MeterWidget::updateGeometry()
{
    const double portionx = xMapping().toPosition(m_value);
    const double portiony = yMapping().toPosition(m_value2);
    const double w = width();
    const double h = height();
    const double px = portionx * w;
    const double py = (1.0 - portiony) * h;

    switch (m_metertype) {
    case MeterWidgetType::Fill:
        if (!m_vertical)
            m_block->setRect(0, 0, px, h);
        else
            m_block->setRect(0, py, w, h - py);
        break;
    case MeterWidgetType::Llif:
        if (!m_vertical)
            m_block->setRect(px, 0, w - px, h);
        else
            m_block->setRect(0, 0, w, py);
        break;
    case MeterWidgetType::Line:
        if (!m_vertical)
            m_vline->setLine(px, 0, px, h);
        else
            m_hline->setLine(0, py, w, py);
        break;
    case MeterWidgetType::Crosshair:
    case MeterWidgetType::Point:
    default:
        m_vline->setLine(px, 0, px, h);
        m_hline->setLine(0, py, w, py);
        m_point->setRect(px - m_pointSize / 2.0,
                         py - m_pointSize / 2.0,
                         m_pointSize,
                         m_pointSize);
    }
}


void MeterWidget::setValue(double value)
{
    QMutexLocker locker(&mutex);
    if (m_value == value) return;
    m_value = value;
    updateGeometry<Axis::X>();
}

void MeterWidget::setValue2(double value)
{
    QMutexLocker locker(&mutex);
    if (m_value2 == value) return;
    m_value2 = value;
    updateGeometry<Axis::Y>();
}

void MeterWidget::setValues(double value1, double value2)
{
    QMutexLocker locker(&mutex);
    if (m_value == value1 && m_value2 == value2) return;
    m_value = value1;
    m_value2 = value2;
    updateGeometry<Axis::Both>();
}


void MeterWidget::setType(QString type)
{
    m_type = type;

    // For "line", which primitive is visible depends on m_vertical.
    const bool vertical = m_vertical;

    struct Layout { bool block, point, vline, hline; };
    Layout layout;
    MeterWidgetType meterType;

    if (type == "fill") {
        meterType = MeterWidgetType::Fill;
        layout = { true,  false, false, false };
        setRenderHint(QPainter::Antialiasing, false);
    }
    else if (type == "llif") {
        meterType = MeterWidgetType::Llif;
        layout = { true,  false, false, false };
    }
    else if (type == "line") {
        meterType = MeterWidgetType::Line;
        layout = { false, false, !vertical, vertical };
    }
    else if (type == "crosshair") {
        meterType = MeterWidgetType::Crosshair;
        layout = { false, false, true, true };
    }
    else if (type == "point") {
        meterType = MeterWidgetType::Point;
        layout = { false, true,  false, false };
        setRenderHints(QPainter::Antialiasing);
    }
    else {
        QDEBUG << "MeterWidget::setType: Unknown type" << type;
        return;   // unknown type — leave state untouched (matches original)
    }

    m_metertype = meterType;
    m_block ->setVisible(layout.block);
    m_point ->setVisible(layout.point);
    m_vline ->setVisible(layout.vline);
    m_hline ->setVisible(layout.hline);
}

void MeterWidget::setRanges(double xmin, double xmax, double ymin, double ymax)
{
    m_xmin = xmin;
    m_xmax = xmax;
    m_ymin = ymin;
    m_ymax = ymax;
}

bool MeterWidget::isSlider() const
{
    return m_metertype == MeterWidgetType::Fill
        || m_metertype == MeterWidgetType::Llif
        || m_metertype == MeterWidgetType::Line;
}

// The exponent applies to the active axis, and only while the widget behaves
// like a slider (fill/llif/line). For the 2D crosshair/point types the mapping
// stays linear.
ValueMapping MeterWidget::xMapping() const
{
    return ValueMapping{ m_xmin, m_xmax, isSlider() ? m_exponent : 1.0 };
}

ValueMapping MeterWidget::yMapping() const
{
    return ValueMapping{ m_ymin, m_ymax, isSlider() ? m_exponent : 1.0 };
}

void MeterWidget::setExponent(double exponent)
{
    m_exponent = ValueMapping::validExponent(exponent);
    updateGeometry<Axis::Both>();
}

void MeterWidget::setPointSize(int size)
{
    m_pointSize = size;
    m_point->setRect(m_value2*width()- (m_pointSize/2.0),
                     (1-m_value)*height()- (m_pointSize/2.0),
                     m_pointSize,
                     m_pointSize);
    auto pen = m_hline->pen();
    pen.setWidth(size);
    m_hline->setPen(pen);
    m_vline->setPen(pen);
}

void MeterWidget::setColor(QColor color)
{
    m_block->setBrush(QBrush(color));
    // auto pen = m_border->pen();
    // pen.setColor(color);
    // m_border->setPen(pen);
    m_point->setPen(QPen(Qt::NoPen));
    m_point->setBrush(QBrush(color));
    m_vline->setPen(QPen(color));
    m_hline->setPen(QPen(color));
}

void MeterWidget::setBgColor(QColor color) {
    m_scene->setBackgroundBrush(color);
    m_bgcolor = color;
}

void MeterWidget::setBorderColor(QColor color) {
    auto pen = m_border->pen();
    pen.setColor(color);
    m_border->setPen(pen);
}

void MeterWidget::setBorderWidth(int width)
{
    m_borderWidth = width;
    auto pen = m_border->pen();
    pen.setWidth(width);
    m_border->setPen(pen);
    updateBorderRect();
    if (width > 0)
        m_border->show();
    else
        m_border->hide();
}

void MeterWidget::updateBorderRect()
{
    const qreal inset = m_borderWidth / 2.0;
    m_border->setRect(m_scene->sceneRect().adjusted(inset, inset, -inset, -inset));
}

void MeterWidget::showBackground(bool show) {
    if(!show) {
        m_scene->setBackgroundBrush(Qt::NoBrush);
        this->setStyleSheet("background: transparent");
    } else {
        // m_scene->setBackgroundBrush(m_bgcolor);
        this->setStyleSheet("background: " + m_bgcolor.name());
    }
    m_showBackground = show;
}

void MeterWidget::setWidgetGeometry(int x,int y,int width,int height)
{
    m_scene->setSceneRect(0,0, width, height);
    // m_border->setRect(0, 0, width-1, height-1);
    updateBorderRect();
    setSceneRect(0,0, width, height);
    setGeometry(x,y,width, height);
    setMaximumSize(width, height);
    m_vertical = width <= height;
    setType(m_type);  // update widgets which depend on verticality
}


void MeterWidget::handlePointerEvent(const QPointF& pos, bool clamp)
{
    const double w = width();
    const double h = height();

    double newhor  = xMapping().toValue(pos.x() / w);
    double newvert = yMapping().toValue(1.0 - pos.y() / h);

    if (clamp) {
        newhor  = qBound(m_xmin, newhor,  m_xmax);
        newvert = qBound(m_ymin, newvert, m_ymax);
    }

    switch (m_metertype) {
    case MeterWidgetType::Fill:
    case MeterWidgetType::Line:
    case MeterWidgetType::Llif:
        if (m_vertical) emit newValue2(newvert);
        else            emit newValue1(newhor);
        break;

    case MeterWidgetType::Crosshair:
    case MeterWidgetType::Point:
        emit newValue1(newhor);
        emit newValue2(newvert);
        break;

    default:
        break;
    }
}

void MeterWidget::mousePressEvent(QMouseEvent* event)
{
    if (event->button() == Qt::LeftButton)
        handlePointerEvent(event->position(), false);
}

void MeterWidget::paintEvent(QPaintEvent *event)
{
    QGraphicsView::paintEvent(event);
    if (!isEnabled()) {
        QPainter painter(viewport());
        QuteWidget::paintDisabledOverlay(painter, viewport()->rect());
    }
}

void MeterWidget::mouseMoveEvent(QMouseEvent* event)
{
    if (event->buttons() & Qt::LeftButton)
        handlePointerEvent(event->position(), true);
}


