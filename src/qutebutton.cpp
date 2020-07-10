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

#include "qutebutton.h"

QuteButton::QuteButton(QWidget *parent) : QuteWidget(parent)
{
    m_widget = new QPushButton(this);
    m_widget->setContextMenuPolicy(Qt::NoContextMenu);
    m_currentValue = 0;
    // Necessary to pass mouse tracking to widget panel for _MouseX channels
    m_widget->setMouseTracking(true);
	setMouseTracking(true);
	canFocus(false);
	//  m_imageFilename = "/";
    connect(static_cast<QPushButton *>(m_widget), SIGNAL(pressed()),
            this, SLOT(buttonPressed()));
    connect(static_cast<QPushButton *>(m_widget), SIGNAL(released()),
            this, SLOT(buttonReleased()));

	setProperty("QCS_type", "event");
	setProperty("QCS_pressedValue", 1.0);
	setProperty("QCS_stringvalue", "");
	setProperty("QCS_text", "");
	setProperty("QCS_image", "");
	setProperty("QCS_eventLine", "");
	setProperty("QCS_latch", false);
    setProperty("QCS_latched", false);
    setProperty("QCS_fontsize", 10);
    
	QPixmap p = QPixmap(8, 8);
	p.fill(QColor(Qt::green));
	onIcon.addPixmap(p, QIcon::Normal, QIcon::On);
	p.fill(QColor(Qt::black));
	onIcon.addPixmap(p, QIcon::Normal, QIcon::Off);
}

QuteButton::~QuteButton()
{
}

void QuteButton::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	if (value < 0) {
		m_currentValue = -value;
		m_value = -value;
	} else {
		m_currentValue = value != 0 ? m_value : 0.0;
		if (property("QCS_latch").toBool()) {
			static_cast<QPushButton *>(m_widget)->setChecked(m_currentValue != 0);
		}
	}
	m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteButton::setValue(QString text)
{
//	qDebug() << "QuteButton::setValue" << text;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	if (m_channel.startsWith("_Browse") ||  m_channel.startsWith("_MBrowse") ) {
		m_stringValue = text;
		m_valueChanged = true;
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

double QuteButton::getValue()
{
	// Returns the value for any button type.
	double value = 0.0;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	if (m_currentValue != 0) {
		value = m_value;
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return value;
}

QString QuteButton::getStringValue()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString stringValue;
	QString name = m_channel;
	if (name.startsWith("_Browse") ||  name.startsWith("_MBrowse") ) {
		stringValue = m_stringValue;
#ifdef  USE_WIDGET_MUTEX
		widgetLock.unlock();
#endif
	}
	else {
#ifdef  USE_WIDGET_MUTEX
		widgetLock.unlock();
#endif
		stringValue =  QString::number(getValue());
	}
	return stringValue;
}

QString QuteButton::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "ioButton {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
	line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
	line +=  property("QCS_type").toString()  + " ";
	line +=  QString::number(m_value,'f', 6) + " ";
	line += "\"" + m_channel + "\" ";
	line += "\"" + static_cast<QPushButton *>(m_widget)->text().replace(QRegExp("[\n\r]"), "\u00AC") + "\" ";
	line += "\"" + property("QCS_image").toString() + "\" ";
	line += property("QCS_eventLine").toString();
	//   qDebug("QuteButton::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteButton::getCabbageLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "button channel(\"" + m_channel + "\"),  ";
	line += QString("bounds(%1,%2,%3,%4), ").arg(x()).arg(y()).arg(width()).arg(height());
	if (property("QCS_latch").toBool()) {
		line += QString("text(\"%1\", \"%2\"), ").arg(property("QCS_text").toString() + " OFF").arg(property("QCS_text").toString() + " ON"); // set different texts for ON/OFF if latced
	} 	else  {
		line += "text(\"" + property("QCS_text").toString()+ " \"), "; // otherwise just the button text
	}
	line += QString("latched(%1)").arg((int)property("QCS_latch").toBool());
	if (property("QCS_midicc").toInt() >= 0 && property("QCS_midichan").toInt()>0) { // insert only if midi channel is above 0
		line += ", midiCtrl(\"" + QString::number(property("QCS_midichan").toInt()) + ",";
		line +=  QString::number(property("QCS_midicc").toInt()) + "\")";
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	//  qDebug() << "Warning: Cabbage does not support button values different than 1, images or event buttons";
	return line;
}

QString QuteButton::getQml()
{
	QString qml = QString();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	qml = "\tButton { \n";
    //qml += QString("\t\tid: %1Button\n").arg(m_channel);
	qml += QString("\t\tx: %1 * scaleItem.scale\n").arg(x());
	qml += QString("\t\ty: %1 * scaleItem.scale\n").arg(y());
	qml += QString("\t\twidth: %1 * scaleItem.scale\n").arg(width());
	qml += QString("\t\theight: %1 * scaleItem.scale\n").arg(height());
	qml += QString("\t\ttext: \"%1\"\n").arg( property("QCS_text").toString());
	bool checkable = property("QCS_latch").toBool();
	if (checkable) {
		qml += "\t\tcheckable: true\n";
	}

	qml += QString("\t\tproperty double pressedValue: %1\n").arg(property("QCS_pressedValue").toDouble()); // to be used for pressing the button.

	QString type = property("QCS_type").toString();
	qml += QString("\t\tproperty bool isEnventButton: %1\n").arg( (type=="value" ? "false" : "true" )  );
	if (type == "value") {
		qml += QString(R"(
		onPressedChanged: {
            if (pressed) {
				csound.setControlChannel("%1", pressedValue );
			} else {
				csound.setControlChannel("%1", 0 );
			}
		}
				 )").arg(m_channel);
	}


	if (type == "event" || type == "pictevent") {
		QString eventLine = property("QCS_eventLine").toString();
        QString turnOffLine = QString();
		if (property("QCS_latch").toBool() && eventLine.size() > 0) {
			QStringList lineElements = eventLine.split(QRegExp("\\s"),QString::SkipEmptyParts);
			if (lineElements.size() > 0 && lineElements[0] == "i") {
				lineElements.removeAt(0); // Remove first element if it is "i"
			}
			else if (lineElements.size() > 0 && lineElements[0][0] == 'i') {
				lineElements[0] = lineElements[0].mid(1); // Remove "i" character
			}

			// this code is necessary to let instruments with line like "i 1 0 -1" to be switched on and off by latched button
			if (lineElements.size() > 2 && lineElements[2].toDouble() < 0) { // If duration is negative, use button to turn note on and off
                if ( lineElements[0].startsWith("\"") || lineElements[0].startsWith("\'")  ) {
                    //qDebug()<<"Stopping named instrument: " << lineElements[0];
                    lineElements[0].insert(1,"-");
                } else {
                    lineElements[0].prepend("-");
                }
                lineElements.prepend("i");

                turnOffLine = lineElements.join(" ");

				qml +=  QString("onCheckedChanged: (checked) ? csound.readScore(\'%1\') : csound.readScore(\'%2\')")
                        .arg(eventLine, turnOffLine); // if unchecked, turnOffLine should consist line to turn off the instrument
			}
		} else { // if not latched, use onClicked event
			qml += QString("\t\tonClicked: csound.readScore(\'%1\') \n").arg(eventLine);
		}
	}


	qml += "\t}\n";
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif

	return qml;

}

#define propDouble(prop, decimals) (QString::number(property(prop).toDouble(),'f', decimals))

QString QuteButton::getWidgetXmlText()
{
	// Buttons are not implemented in blue
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif

	s.writeTextElement("type", property("QCS_type").toString());
	s.writeTextElement("pressedValue", QString::number(m_value,'f', 8));
	s.writeTextElement("stringvalue", m_stringValue);
	s.writeTextElement("text", property("QCS_text").toString());
	s.writeTextElement("image", property("QCS_image").toString());
	s.writeTextElement("eventLine", property("QCS_eventLine").toString());
	s.writeTextElement("latch", property("QCS_latch").toString());
	s.writeTextElement("latched", property("QCS_latched").toString());
    s.writeTextElement("fontsize", QString::number(property("QCS_fontsize").toInt()));
	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

QString QuteButton::getWidgetType()
{
	return QString("BSBButton");
}

void QuteButton::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForWrite();
#endif
	QString eventLine = line->text();
    while (eventLine.size() > 0 && eventLine[0] == ' ') {
        // remove all spaces at the beginning. This is needed for event queue lines
        eventLine.remove(0,1);
	}
	setProperty("QCS_eventLine", eventLine);
    setProperty("QCS_text", text->toPlainText());
	setProperty("QCS_image", filenameLineEdit->text());
	setProperty("QCS_type", typeComboBox->currentText());
	setProperty("QCS_pressedValue", valueBox->value());
	setProperty("QCS_latch", latchCheckBox->isChecked());
    setProperty("QCS_fontsize", fontSizeSpinBox->value());

#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    //Must be last to make sure the widgetChanged signal is last
    QuteWidget::applyProperties();
    //  qDebug() << "QuteButton::applyProperties()" << m_value;
}


void QuteButton::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	dialog->setWindowTitle("Button");

	QLabel *label = new QLabel(dialog);
	label->setText("Type");
	layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
	typeComboBox = new QComboBox(dialog);
	typeComboBox->addItem("event");
	typeComboBox->addItem("value");
	typeComboBox->addItem("pictevent");
	typeComboBox->addItem("pictvalue");
	typeComboBox->addItem("pict");
	typeComboBox->setCurrentIndex(typeComboBox->findText(property("QCS_type").toString()));
	layout->addWidget(typeComboBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);

	latchCheckBox = new QCheckBox(dialog);
	latchCheckBox->setText(tr("Latch"));
	layout->addWidget(latchCheckBox, 5, 1, 1,2, Qt::AlignLeft|Qt::AlignVCenter);
	latchCheckBox->setChecked(property("QCS_latch").toBool());
	label = new QLabel(dialog);
	label->setText("Value");
	layout->addWidget(label, 4, 2, Qt::AlignRight|Qt::AlignVCenter);

    valueBox = new QDoubleSpinBox(dialog);
	valueBox->setDecimals(6);
	valueBox->setRange(-9999999.0, 9999999.0);
	valueBox->setValue(m_value);
	layout->addWidget(valueBox, 4, 3, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(dialog);
	label->setText("Text:");
	layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);

    text = new QTextEdit(dialog);
	text->setMinimumWidth(320);
	text->setText(property("QCS_text").toString());
    layout->addWidget(text, 6, 1, 1, 3, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(dialog);
    label->setText(tr("Font Size"));
    layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);

    fontSizeSpinBox = new QSpinBox(dialog);
    fontSizeSpinBox->setMinimum(6);
    fontSizeSpinBox->setMaximum(999);
    fontSizeSpinBox->setValue(property("QCS_fontsize").toInt());
    layout->addWidget(fontSizeSpinBox, 7, 1, Qt::AlignLeft|Qt::AlignVCenter);

	label = new QLabel(dialog);
	label->setText("Image:");
    layout->addWidget(label, 8, 0, Qt::AlignRight|Qt::AlignVCenter);
	filenameLineEdit = new QLineEdit(dialog);
	filenameLineEdit->setMinimumWidth(320);
	filenameLineEdit->setText(property("QCS_image").toString());
    layout->addWidget(filenameLineEdit, 8, 1, 1, 3, Qt::AlignLeft|Qt::AlignVCenter);

	QPushButton *browseButton = new QPushButton(dialog);
    browseButton->setText("Browse");
    layout->addWidget(browseButton, 8, 4, Qt::AlignLeft|Qt::AlignVCenter);
	connect(browseButton, SIGNAL(released()), this, SLOT(browseFile()));

	label = new QLabel(dialog);
	label->setText("Event:");
    layout->addWidget(label, 9, 0, Qt::AlignRight|Qt::AlignVCenter);
	line = new QLineEdit(dialog);
	//   text->setText(((QuteLabel *)m_widget)->toPlainText());
    layout->addWidget(line, 9,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
	line->setMinimumWidth(320);
	line->setText(property("QCS_eventLine").toString());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteButton::setText(QString text)
{
	// For old widget format conversion of line endings
	setProperty("QCS_text", text);
    static_cast<QPushButton *>(m_widget)->setText(text);
}

void QuteButton::popUpMenu(QPoint pos)
{
	QuteWidget::popUpMenu(pos);
}

void QuteButton::setMidiValue(int value)
{
	double pressedVal = property("QCS_pressedValue").toDouble();
	double newval= value == 0 ? 0 : pressedVal;
	setValue(newval);
	QString type = property("QCS_type").toString();
    // if event type, start/stop event on MIDI button press/release
    if (m_valueChanged && (type == "event" || type == "pictevent") ) {
		QString eventLine = property("QCS_eventLine").toString();
		if (newval==1) {
			emit(queueEventSignal(eventLine));
		}
		// on release check if event was with indefinite duration, then turn it off
		if (newval==0 && eventLine.size() > 0) {
			QStringList lineElements = eventLine.split(QRegExp("\\s"),QString::SkipEmptyParts);
			if (lineElements.size() > 0 && lineElements[0] == "i") {
                // Remove first element if it is "i"
                lineElements.removeAt(0);
			}
			else if (lineElements.size() > 0 && lineElements[0][0] == 'i') {
				lineElements[0] = lineElements[0].mid(1); // Remove "i" character
			}
			//bool test = property("QCS_latch").toBool();
            if (lineElements.size() > 2 &&
                    lineElements[2].toDouble() < 0 &&
                    property("QCS_latch").toBool() ) {
                // If duration is negative, turn it off. But not when it is not a latched button!
				lineElements[0].prepend("-");
				lineElements.prepend("i");
				emit(queueEventSignal(lineElements.join(" ")));
			}
		}
	} else if ((type == "value" || type == "pictvalue") && newval == pressedVal) {
        QStringList reservedChannels = QStringList() << "_Play" <<"_Stop" << "_Pause"
                                                     << "_Render" << "_Browse1"
                                                     << "_Browse2" << "_MBrowse";
        if (reservedChannels.contains(m_channel))
            buttonReleased();
	}
	QPair<QString, double> channelValue(m_channel, newval);
	emit newValue(channelValue);

}

void QuteButton::refreshWidget()
{
	// setValue sets the value the widget outputs while it is pressed
	//  static_cast<QPushButton *>(m_widget)->setChecked(m_value);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif

	//  setProperty("QCS_value", m_value);
	//  setProperty("QCS_stringvalue", m_stringValue);

	setProperty("QCS_latched", m_currentValue != 0);
	m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}


void QuteButton::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
    //qDebug() << "QuteButton::applyInternalProperties";
    m_value = property("QCS_pressedValue").toDouble();
	//  m_value2 = property("QCS_value2").toDouble();
	m_stringValue = property("QCS_stringvalue").toString();
	QString type = property("QCS_type").toString();
    auto w = static_cast<QPushButton*>(m_widget);
    w->setCheckable(property("QCS_latch").toBool());
    // Set icon here, because it can be overwritten if button is "pict"
    if (property("QCS_latch").toBool()) {
        w->setIcon(onIcon);
    } else {
        w->setIcon(QIcon());
    }

    if (type == "event" || type == "value") {
        icon = QIcon();
		static_cast<QPushButton *>(m_widget)->setIcon(icon);
        auto fontsizeProperty = property("QCS_fontsize");
        if(!fontsizeProperty.isValid()) {
            qDebug() << "Button: fontsize invalid / not present. Setting to default";
        } else {
            int fontsize = fontsizeProperty.toInt();
            if(fontsize <= 0)
                qDebug() << "Invalid font size for button, skipping";
            else {

                auto sheet = QString("QPushButton {font-size: %1pt; }").arg(fontsize);
                w->setStyleSheet(sheet);
            }
        }
        w->setText(property("QCS_text").toString());

    } else if (type == "pictevent" || type == "pictvalue" || type == "pict") {
        qDebug() << "///////////////////////////";
        w->setStyleSheet(nullptr);
        w->setText("");
		icon = QIcon(QPixmap(property("QCS_image").toString()));
		static_cast<QPushButton *>(m_widget)->setIcon(icon);
		static_cast<QPushButton *>(m_widget)->setIconSize(QSize(width(),height()));
    } else {
        qDebug() << "Warning! QuteButton::applyInternalProperties() unrecognized type:"
                 << type;
	}


    // Why is this here?
    // QString colorstr = property("QCS_color").value<QColor>().name();
    // m_widget->setStyleSheet("QPushButton { border-color:" + colorstr + "; }");
}


void QuteButton::performAction() {
    QString type = property("QCS_type").toString();
    QString eventLine = property("QCS_eventLine").toString();
    QString name = m_channel;

    if (type == "event" || type == "pictevent") {
        if (property("QCS_latch").toBool() && eventLine.size() > 0) {
            QStringList lineElements = eventLine.split(QRegExp("\\s"),QString::SkipEmptyParts);
            if (lineElements.size() > 0 && lineElements[0] == "i") {
                lineElements.removeAt(0); // Remove first element if it is "i"
            }
            else if (lineElements.size() > 0 && lineElements[0][0] == 'i') {
                lineElements[0] = lineElements[0].mid(1); // Remove "i" character
            }
            // If duration is negative, use button to turn note on and off
            if (lineElements.size() > 2 && lineElements[2].toDouble() < 0) {
                if (m_currentValue == 0) { // Button has turned off. Turn off instrument
                    if ( lineElements[0].startsWith("\"") || lineElements[0].startsWith("\'")  ) {
                        //qDebug()<<"Stopping named instrument: " << lineElements[0];
                        lineElements[0].insert(1,"-");
                    }
                    else {
                        // NB! what if string? find out instrument number
                        lineElements[0].prepend("-");
                    }
                    lineElements.prepend("i");
					setValue(0); // was 1
                    emit(queueEventSignal(lineElements.join(" ")));
                }
                else { // Button has turned on. Turn on instrument
					setValue(1); // was 0
                    emit(queueEventSignal(eventLine));
                }
            }
            else {
                emit(queueEventSignal(eventLine));
            }
        }
        else {
            emit(queueEventSignal(eventLine));
        }
    }
    else if (type == "value" || type == "pictvalue") {
        if(!name.startsWith("_")) {
            emit newValue(QPair<QString, double>(name, m_currentValue));
        }
        else if (name == "_Play") {
            if(m_value == 0)
                emit stop();
            else
                emit play();
        }
        else if (name == "_Stop")
            emit stop();
        else if (name == "_Pause")
            emit pause();
        else if (name == "_Render")
            emit render();
        else if (name.startsWith("_Browse")) {
            QString fileName = QFileDialog::getOpenFileName(this, tr("Select File"));
            if (fileName != "") {
                setProperty("QCS_stringvalue", fileName);
                emit newValue(QPair<QString, QString>(name, fileName));
            }
        }
        else if (name.startsWith("_MBrowse")) {
            // Browse multiple files
            QStringList fileNames = QFileDialog::getOpenFileNames(this, tr("Select File(s)"));
            if (!fileNames.isEmpty()) {
                QString joinedNames = fileNames.join("|");
                setProperty("QCS_stringvalue", joinedNames);
                emit newValue(QPair<QString, QString>(name, joinedNames));
            }
        }
        else {
            qDebug() << "Warning: Channel names starting with _ are reserved. This will "
                        "be an error in a next release";
            emit newValue(QPair<QString, double>(name, m_currentValue));
        }
    }
}

void QuteButton::buttonPressed()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
    // open file browser on release
    if (m_channel.startsWith("_Browse") || m_channel.startsWith("_MBrowse")) {
        return;
    }
    auto w = static_cast<QPushButton *>(m_widget);
    if (property("QCS_latch").toBool()) {
        m_currentValue = !w->isChecked() ? m_value : 0;
    } else {
		m_currentValue = m_value;
    }

#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    performAction();
}

void QuteButton::buttonReleased()
{
	// Only produce events for event types
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
    if (m_channel.startsWith("_Browse") || m_channel.startsWith("_MBrowse")) {
        performAction();
        return;
    }
    if (!property("QCS_latch").toBool()) {
        m_currentValue = 0;
    }

#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    emit newValue(QPair<QString, double>(m_channel, m_currentValue));

}

void QuteButton::browseFile()
{
    QString file =  QFileDialog::getOpenFileName(this,tr("Select File"));
	if (file!="") {
		filenameLineEdit->setText(file);
	}
}
