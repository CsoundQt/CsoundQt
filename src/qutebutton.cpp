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
  m_widget->setFocusPolicy(Qt::NoFocus);
  m_imageFilename = "/";
  m_type = "event";
  connect(static_cast<QPushButton *>(m_widget), SIGNAL(released()), this, SLOT(buttonReleased()));
}

QuteButton::~QuteButton()
{
}

void QuteButton::loadFromXml(QString xmlText)
{
  qDebug() << "loadFromXml not implemented for this widget yet";
}

void QuteButton::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  // setValue sets the value the widget outputs while it is pressed
  m_value = value;
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

double QuteButton::getValue()
{
  // Returns the value for any button type.
  if ( ((QPushButton *)m_widget)->isDown() )
    return m_value;
  else
    return 0.0;
}

QString QuteButton::getStringValue()
{
  if (m_name.startsWith("_Browse")) {
    return m_filename;
  }
  else {
    return QString::number(m_value);
  }
}

QString QuteButton::getWidgetLine()
{
  QString line = "ioButton {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += m_type + " ";
  line +=  QString::number(m_value,'f', 6) + " ";
  line += "\"" + m_name + "\" ";
  line += "\"" + static_cast<QPushButton *>(m_widget)->text().replace(QRegExp("[\n\r]"), "\u00AC") + "\" ";
  line += "\"" + m_imageFilename + "\" ";
  line += m_eventLine;
//   qDebug("QuteButton::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteButton::getCabbageLine()
{
  QString line = "button channel(\"" + m_name + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "OnOffCaption(\"" + m_name + "\")"; // OffCaption is not supported in QuteCsound
  qDebug() << "Warning: Cabbage does not support button values different than 1, images or event buttons";
  return line;
}

QString QuteButton::getWidgetXmlText()
{
  return QString();
}

QString QuteButton::getWidgetType()
{
  return QString("button");
}

void QuteButton::applyProperties()
{
  setEventLine(line->text());
  setValue(valueBox->value());
  setText(text->toPlainText());
  setFilename(filenameLineEdit->text());
  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
  setType(typeComboBox->currentText());
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
  typeComboBox->setCurrentIndex(typeComboBox->findText(m_type));
  layout->addWidget(typeComboBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);

  label = new QLabel(dialog);
  label->setText("Value");
  layout->addWidget(label, 4, 2, Qt::AlignRight|Qt::AlignVCenter);
  valueBox = new QDoubleSpinBox(dialog);
  valueBox->setDecimals(6);
  valueBox->setRange(-99999.0, 99999.0);
  valueBox->setValue(m_value);
  layout->addWidget(valueBox, 4, 3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Text:");
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QTextEdit(dialog);
  text->setText(((QPushButton *)m_widget)->text());
  layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
  label = new QLabel(dialog);
  label->setText("Image:");
  layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
  filenameLineEdit = new QLineEdit(dialog);
  filenameLineEdit->setText(m_imageFilename);
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
  line->setText(m_eventLine);
  layout->addWidget(line, 7,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  line->setMinimumWidth(320);
}

void QuteButton::setType(QString type)
{
//   if (m_type == type)
//     return;
  m_type = type;
  if (m_type == "event" or m_type == "value") {
    icon = QIcon();
    static_cast<QPushButton *>(m_widget)->setIcon(icon);
  }
  else if (m_type == "pictevent" or m_type == "pictvalue" or m_type == "pict") {
    icon = QIcon(QPixmap(m_imageFilename));
    static_cast<QPushButton *>(m_widget)->setIcon(icon);
    static_cast<QPushButton *>(m_widget)->setIconSize(QSize(width(),height()));
  }
  else {
    qDebug("Warning! QuteButton::setType() unrecognized type");
  }
}

void QuteButton::setText(QString text)
{
  text.replace("\u00AC", "\n");
  static_cast<QPushButton *>(m_widget)->setText(text);
}

void QuteButton::setFilename(QString filename)
{
  m_imageFilename = filename;
}

void QuteButton::setEventLine(QString eventLine)
{
  while (eventLine.size() > 0 and eventLine[0] == ' ') {
    qDebug("remove");
    eventLine.remove(0,1); //remove all spaces at the beginning. This is needed for event queue lines
  }
  m_eventLine = eventLine;
}

void QuteButton::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}

void QuteButton::buttonReleased()
{
  // Only produce events for event types
  if (m_type == "event" or m_type == "pictevent")
    emit(queueEvent(m_eventLine));
  else if (m_type == "value" or m_type == "pictvalue") {
    if (m_name == "_Play" && m_value == 1)
      emit play();
    else if (m_name == "_Play" && m_value == 0)
      emit stop();
    else if (m_name == "_Stop")
      emit stop();
    else if (m_name == "_Render")
      emit render();
    else if (m_name.startsWith("_Browse")) {
      QString fileName = QFileDialog::getOpenFileName(this, tr("Select File"));
      if (fileName != "") {
        m_filename = fileName;
        emit newValue(QPair<QString, QString>(m_name, fileName));
      }
    }
//     else if (m_name == "_Midiindevices") {
//       QPoint pos(x(), y());
//       emit selectMidiInDevices(pos);
//     }
//     else if (m_name == "_Midioutdevices") {
//       QPoint pos(x(), y());
//       emit selectMidiOutDevices(pos);
//     }
//     else if (m_name == "_Audioindevices") {
//       QPoint pos(x(), y());
//       emit selectAudioInDevices(pos);
//     }
//     else if (m_name == "_Audioindevices") {
//       QPoint pos(x(), y());
//       emit selectAudioOutDevices(pos);
//     }
  }
}

void QuteButton::browseFile()
{
  qDebug("QuteButton::browseFile()");
  QString file =  QFileDialog::getOpenFileName(this,tr("Select File"));
  if (file!="") {
    filenameLineEdit->setText(file);
    m_imageFilename = file;
  }
}
