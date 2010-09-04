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

#include "qutebutton.h"

QuteButton::QuteButton(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QPushButton(this);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_currentValue = 0;
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  setMouseTracking(true);
  canFocus(false);
//  m_imageFilename = "/";
  connect(static_cast<QPushButton *>(m_widget), SIGNAL(pressed()), this, SLOT(buttonPressed()));
  connect(static_cast<QPushButton *>(m_widget), SIGNAL(released()), this, SLOT(buttonReleased()));

  setProperty("QCS_type", "event");
  setProperty("QCS_pressedValue", 1.0);
  setProperty("QCS_stringvalue", "");
  setProperty("QCS_text", "");
  setProperty("QCS_image", "");
  setProperty("QCS_eventLine", "");
  setProperty("QCS_latch", false);
  setProperty("QCS_latched", false);

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
  if (value <0) {
    m_currentValue = -value;
    m_value = -value;
  }
  else {
    m_currentValue = value != 0 ? m_value : 0.0;
    if (property("QCS_latch").toBool()) {
      static_cast<QPushButton *>(m_widget)->setDown(m_currentValue != 0);
    }
  }
  m_valueChanged = true;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteButton::setValue(QString text)
{
  qDebug() << "QuteButton::setValue" << text;
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
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "OnOffCaption(\"" + m_channel + "\")"; // OffCaption is not supported in QuteCsound
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
//  qDebug() << "Warning: Cabbage does not support button values different than 1, images or event buttons";
  return line;
}

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
  while (eventLine.size() > 0 and eventLine[0] == ' ') {
    eventLine.remove(0,1); //remove all spaces at the beginning. This is needed for event queue lines
  }
  setProperty("QCS_eventLine", eventLine);
  setProperty("QCS_text", text->toPlainText());
  setProperty("QCS_image", filenameLineEdit->text());
  setProperty("QCS_type", typeComboBox->currentText());
  setProperty("QCS_pressedValue", valueBox->value());
  setProperty("QCS_latch", latchCheckBox->isChecked());
//  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
  //  setType(typeComboBox->currentText());

#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  QuteWidget::applyProperties();  //Must be last to make sure the widgetChanged signal is last
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
  layout->addWidget(text, 6,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Image:");
  layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);
  filenameLineEdit = new QLineEdit(dialog);
  filenameLineEdit->setMinimumWidth(320);
  filenameLineEdit->setText(property("QCS_image").toString());
  layout->addWidget(filenameLineEdit, 7,1,1,2, Qt::AlignLeft|Qt::AlignVCenter);
  QPushButton *browseButton = new QPushButton(dialog);
  browseButton->setText("...");
  layout->addWidget(browseButton, 7, 3, Qt::AlignCenter|Qt::AlignVCenter);
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

void QuteButton::refreshWidget()
{
  // setValue sets the value the widget outputs while it is pressed
//  static_cast<QPushButton *>(m_widget)->setChecked(m_value);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif

//  setProperty("QCS_value", m_value);
//  setProperty("QCS_stringvalue", m_stringValue);

  setProperty("QCS_latched", m_currentValue == 0);
  m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteButton::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteButton::applyInternalProperties()";
  m_value = property("QCS_pressedValue").toDouble();
//  m_value2 = property("QCS_value2").toDouble();
  m_stringValue = property("QCS_stringvalue").toString();
  QString type = property("QCS_type").toString();
  if (type == "event" or type == "value") {
    icon = QIcon();
    static_cast<QPushButton *>(m_widget)->setIcon(icon);
  }
  else if (type == "pictevent" or type == "pictvalue" or type == "pict") {
    icon = QIcon(QPixmap(property("QCS_image").toString()));
    static_cast<QPushButton *>(m_widget)->setIcon(icon);
    static_cast<QPushButton *>(m_widget)->setIconSize(QSize(width(),height()));
  }
  else {
    qDebug() << "Warning! QuteButton::applyInternalProperties() unrecognized type:" << type;
  }
  static_cast<QPushButton *>(m_widget)->setText(property("QCS_text").toString());
  static_cast<QPushButton *>(m_widget)->setCheckable(property("QCS_latch").toBool());
  if (property("QCS_latch").toBool()) {
    static_cast<QPushButton *>(m_widget)->setIcon(onIcon);
  }
  else {
    static_cast<QPushButton *>(m_widget)->setIcon(QIcon());
  }
  m_widget->setStyleSheet("QPushButton { border-color:" + property("QCS_color").value<QColor>().name()
                          + "; }");  // Why is this here?
}

void QuteButton::buttonPressed()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  if (m_channel.startsWith("_Browse") || m_channel.startsWith("_MBrowse")) {
    return;
  }
  m_currentValue = m_value;
  QPair<QString, double> channelValue(m_channel, m_currentValue);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  emit newValue(channelValue);
}

void QuteButton::buttonReleased()
{
  // Only produce events for event types
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString name = m_channel;
  QString type = property("QCS_type").toString();
  double value = m_value;
  QString eventLine = property("QCS_eventLine").toString();
  if (property("QCS_latch").toBool()) {
    if (!static_cast<QPushButton *>(m_widget)->isChecked()) {
      m_currentValue = 0;
    }
  }
  else {
    m_currentValue = 0;
  }
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  if (type == "event" or type == "pictevent")
    emit(queueEvent(eventLine));
  else if (type == "value" or type == "pictvalue") {
    if (name == "_Play" &&  value == 1)
      emit play();
    else if (name == "_Play" && value == 0)
      emit stop();
    else if (name == "_Pause")
      emit pause();
    else if (name == "_Stop")
      emit stop();
    else if (name == "_Render")
      emit render();
    else if (name.startsWith("_Browse")) {
      QString fileName = QFileDialog::getOpenFileName(this, tr("Select File"));
      if (fileName != "") {
#ifdef  USE_WIDGET_MUTEX
        widgetLock.lockForWrite();
#endif
        setProperty("QCS_stringvalue", fileName);
#ifdef  USE_WIDGET_MUTEX
        widgetLock.unlock();
#endif
        emit newValue(QPair<QString, QString>(name, fileName));
      }
    } 
    else if (name.startsWith("_MBrowse")) {
      QStringList fileNames = QFileDialog::getOpenFileNames(this, tr("Select File(s)"));
      if (!fileNames.isEmpty()) {
        QString joinedNames = fileNames.join("|");
#ifdef  USE_WIDGET_MUTEX
        widgetLock.lockForWrite();
#endif
        setProperty("QCS_stringvalue", joinedNames);
#ifdef  USE_WIDGET_MUTEX
        widgetLock.unlock();
#endif
        emit newValue(QPair<QString, QString>(name, joinedNames));
      }
    }
    else {
      emit newValue(QPair<QString, double>(name, m_currentValue));
    }
  }
}

void QuteButton::browseFile()
{
//  qDebug() << "QuteButton::browseFile()";
  QString file =  QFileDialog::getOpenFileName(this,tr("Select File"));
  if (file!="") {
    filenameLineEdit->setText(file);
  }
}
