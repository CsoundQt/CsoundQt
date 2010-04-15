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
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  setMouseTracking(true);
  canFocus(false);
//  m_imageFilename = "/";
  connect(static_cast<QPushButton *>(m_widget), SIGNAL(released()), this, SLOT(buttonReleased()));

  setProperty("QCS_type", "event");
  setProperty("QCS_value", 1.0);
  setProperty("QCS_stringvalue", "");
  setProperty("QCS_text", "");
  setProperty("QCS_image", "");
  setProperty("QCS_eventLine", "");
  setProperty("QCS_latch", false);


}

QuteButton::~QuteButton()
{
}

void QuteButton::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  // setValue sets the value the widget outputs while it is pressed
  static_cast<QPushButton *>(m_widget)->setChecked(value != 0);
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

double QuteButton::getValue()
{
  // Returns the value for any button type.
  if ( static_cast<QPushButton *>(m_widget)->isDown() )
    return property("QCS_value").toDouble();
  else
    return 0.0;
}

QString QuteButton::getStringValue()
{
  QString name = property("QCS_objectName").toString();
  if (name.startsWith("_Browse")) {
    return property("QCS_stringvalue").toString();
  }
  else {
    return QString::number(getValue());
  }
}

QString QuteButton::getWidgetLine()
{
  QString line = "ioButton {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line +=  property("QCS_type").toString()  + " ";
  line +=  QString::number(property("QCS_value").toDouble(),'f', 6) + " ";
  line += "\"" + property("QCS_objectName").toString() + "\" ";
  line += "\"" + static_cast<QPushButton *>(m_widget)->text().replace(QRegExp("[\n\r]"), "\u00AC") + "\" ";
  line += "\"" + property("QCS_image").toString() + "\" ";
  line += property("QCS_eventLine").toString();
//   qDebug("QuteButton::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteButton::getCabbageLine()
{
  QString line = "button channel(\"" + property("QCS_objectName").toString() + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "OnOffCaption(\"" + property("QCS_objectName").toString() + "\")"; // OffCaption is not supported in QuteCsound
  qDebug() << "Warning: Cabbage does not support button values different than 1, images or event buttons";
  return line;
}

QString QuteButton::getWidgetXmlText()
{
// Buttons are not implemented in blue
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

  s.writeTextElement("type", property("QCS_type").toString());
  s.writeTextElement("value", QString::number(property("QCS_value").toDouble(),'f', 8));
  s.writeTextElement("stringvalue", property("QCS_stringvalue").toString());
  s.writeTextElement("text", property("QCS_text").toString());
  s.writeTextElement("image", property("QCS_image").toString());
  s.writeTextElement("eventLine", property("QCS_eventLine").toString());

  s.writeEndElement();
  return xmlText;
}

QString QuteButton::getWidgetType()
{
  return QString("BSBButton");
}

void QuteButton::applyProperties()
{
  QString eventLine = line->text();
  while (eventLine.size() > 0 and eventLine[0] == ' ') {
    eventLine.remove(0,1); //remove all spaces at the beginning. This is needed for event queue lines
  }
  setProperty("QCS_eventLine", eventLine);
  setProperty("QCS_value", valueBox->value());
  setProperty("QCS_text", text->toPlainText());
  setProperty("QCS_image", filenameLineEdit->text());
  setProperty("QCS_type", typeComboBox->currentText());
//  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
//  setType(typeComboBox->currentText());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteButton::contextMenuEvent(QContextMenuEvent* event)
{
  QuteWidget::contextMenuEvent(event);
}

void QuteButton::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
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

  label = new QLabel(dialog);
  label->setText("Value");
  layout->addWidget(label, 4, 2, Qt::AlignRight|Qt::AlignVCenter);
  valueBox = new QDoubleSpinBox(dialog);
  valueBox->setDecimals(6);
  valueBox->setRange(-9999999.0, 9999999.0);
  valueBox->setValue(property("QCS_value").toDouble());
  layout->addWidget(valueBox, 4, 3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Text:");
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QTextEdit(dialog);
  text->setText(property("QCS_text").toString());
  layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
  label = new QLabel(dialog);
  label->setText("Image:");
  layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
  filenameLineEdit = new QLineEdit(dialog);
  filenameLineEdit->setText(property("QCS_image").toString());
  filenameLineEdit->setMinimumWidth(320);
  layout->addWidget(filenameLineEdit, 6,1,1,2, Qt::AlignLeft|Qt::AlignVCenter);
  QPushButton *browseButton = new QPushButton(dialog);
  browseButton->setText("...");
  layout->addWidget(browseButton, 6, 3, Qt::AlignCenter|Qt::AlignVCenter);
  connect(browseButton, SIGNAL(released()), this, SLOT(browseFile()));

  label = new QLabel(dialog);
  label->setText("Event:");
  layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);
  line = new QLineEdit(dialog);
//   text->setText(((QuteLabel *)m_widget)->toPlainText());
  line->setText(property("QCS_eventLine").toString());
  layout->addWidget(line, 7,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  line->setMinimumWidth(320);
}

void QuteButton::setText(QString text)
{
  // For old widget format conversion of line endings
  setProperty("QCS_text", text);
  static_cast<QPushButton *>(m_widget)->setText(text);
}

//void QuteButton::setFilename(QString filename)
//{
//  m_imageFilename = filename;
//}

//void QuteButton::setEventLine(QString eventLine)
//{
//  while (eventLine.size() > 0 and eventLine[0] == ' ') {
//    eventLine.remove(0,1); //remove all spaces at the beginning. This is needed for event queue lines
//  }
//  m_eventLine = eventLine;
//}

void QuteButton::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}

void QuteButton::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteButton::applyInternalProperties()";

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
  static_cast<QPushButton *>(m_widget)->setCheckable( property("QCS_latch").toBool());
}

void QuteButton::buttonReleased()
{
  // Only produce events for event types
  QString name = property("QCS_objectName").toString();
  QString type = property("QCS_type").toString();
  if (type == "event" or type == "pictevent")
    emit(queueEvent(property("QCS_eventLine").toString()));
  else if (type == "value" or type == "pictvalue") {
    if (name == "_Play" && property("QCS_value").toDouble() == 1)
      emit play();
    else if (name == "_Play" && property("QCS_value").toDouble() == 0)
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
        setProperty("QCS_stringvalue", fileName);
        emit newValue(QPair<QString, QString>(name, fileName));
      }
    }
  }
}

void QuteButton::browseFile()
{
  qDebug("QuteButton::browseFile()");
  QString file =  QFileDialog::getOpenFileName(this,tr("Select File"));
  if (file!="") {
    filenameLineEdit->setText(file);
  }
}
