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

#include "qutespinbox.h"
#include <cmath>

QuteSpinBox::QuteSpinBox(QWidget* parent) : QuteText(parent)
{
  delete m_widget; //delete widget created by parent constructor
  m_widget = new QDoubleSpinBox(this);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  static_cast<QDoubleSpinBox*>(m_widget)->setAccelerated(true);
  static_cast<QDoubleSpinBox*>(m_widget)->setRange(-999999999999.0, 999999999999.0);
  connect(static_cast<QDoubleSpinBox *>(m_widget), SIGNAL(editingFinished()), this, SLOT(editingFinishedSlot()));
//   connect(static_cast<QDoubleSpinBox*>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
  m_type = "editnum";

  setProperty("QCS_value", (double) 0.0);
  setProperty("QCS_resolution", (double) 0.1);
  setProperty("QCS_minimum",(double)  -999999999999.0);
  setProperty("QCS_maximum", (double) 999999999999.0);
  setProperty("QCS_randomizable", false);
  setProperty("QCS_randomizableGroup", 0);
  setProperty("QCS_label", QVariant()); // Remove this property which is part of parent class.
  setProperty("QCS_color", QVariant()); // Remove this property which is part of parent class.
  setProperty("QCS_borderradius", QVariant()); // Remove this property which is part of parent class.
  setProperty("QCS_borderwidth", QVariant()); // Remove this property which is part of parent class.
}

QuteSpinBox::~QuteSpinBox()
{
}

void QuteSpinBox::setText(QString text)
{
  setValue(text.toDouble());
}

void QuteSpinBox::setMidiValue(int value)
{
  double max = property("QCS_maximum").toDouble();
  double min = property("QCS_minimum").toDouble();
  if (max != 999999999999.0 && min != -999999999999.0) {
    double newval = min + ((value / 127.0)* (max - min));
    setValue(newval);
    QPair<QString, double> channelValue(m_channel, newval);
    emit newValue(channelValue);
  }
  else {
    qDebug() << "QuteSpinBox::setMidiValue ranges not set.";
  }
}

//void QuteSpinBox::setResolution(double resolution)
//{
//  setProperty("QCS_resolution", resolution);
//}

QString QuteSpinBox::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ioText {" + QString::number(property("QCS_x").toInt()) + ", " + QString::number(property("QCS_y").toInt()) + "} ";
  line += "{"+ QString::number(property("QCS_width").toInt()) +", "+ QString::number(property("QCS_height").toInt()) +"} ";
  line += m_type + " ";
  line += QString::number(static_cast<QDoubleSpinBox*>(m_widget)->value(), 'f', 6) + " ";
  line += QString::number(property("QCS_resolution").toDouble(), 'f', 6) + " \"" + m_channel + "\" ";
  line += property("QCS_alignment").toString() + " ";
  line += "\"" + m_widget->property("QCS_font").toString() + "\" "
          + QString::number(m_widget->property("QCS_fontsize").toInt()) + " ";
  QColor color = m_widget->palette().color(QPalette::WindowText);
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  color = m_widget->palette().color(QPalette::Window);
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  line += m_widget->autoFillBackground()? "background ":"nobackground ";
  line += "noborder ";
  line += QString::number(static_cast<QDoubleSpinBox*>(m_widget)->value(), 'f', 6);
  // For this type of ioText widget, value and text are redundant. QuteCsound reads mthe value coming
  // in the text field, but writes to both.
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteSpinBox::getCsladspaLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ControlPort=" + m_channel + "|" + m_channel + "\n";
  line += "Range=-9999|9999";
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteSpinBox::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
//  s.writeTextElement("type", m_type);

   //These are not implemented in blue
  s.writeTextElement("alignment", property("QCS_alignment").toString());

  s.writeTextElement("font", property("QCS_font").toString());
  s.writeTextElement("fontsize", QString::number(property("QCS_fontsize").toDouble()));

  QColor color = property("QCS_color").value<QColor>();
  s.writeStartElement("color");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();
  color = property("QCS_bgcolor").value<QColor>();
  s.writeStartElement("bgcolor");
  s.writeAttribute("mode", property("QCS_bgcolormode").toBool()? "background":"nobackground");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();
  s.writeTextElement("resolution", QString::number(property("QCS_resolution").toDouble(), 'f', 8));

  s.writeTextElement("minimum", QString::number(property("QCS_minimum").toDouble()));
  s.writeTextElement("maximum", QString::number(property("QCS_maximum").toDouble()));
//  s.writeTextElement("bordermode", property("QCS_bordermode").toString());
//  s.writeTextElement("borderradius", QString::number(property("QCS_borderradius").toInt()));
//  s.writeTextElement("borderwidth", QString::number(property("QCS_borderwidth").toInt()));
  s.writeStartElement("randomizable");
  s.writeAttribute("group", QString::number(property("QCS_randomizableGroup").toInt()));
  s.writeCharacters(property("QCS_randomizable").toBool() ? "true": "false");
  s.writeEndElement();
  s.writeTextElement("value", QString::number(m_value));
  s.writeEndElement();

#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return xmlText;
}

QString QuteSpinBox::getWidgetType()
{
  return QString("BSBSpinBox");
}

void QuteSpinBox::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
//  double resolution = property("QCS_resolution").toDouble();
//  double val = resolution * (int(m_value /resolution) + 1.0); // ceil or int won't work here...
  double val = m_value;
//  qDebug()<< "QuteSpinBox::refreshWidget()" << val << m_value << resolution;
  m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
//  int cursorPos = static_cast<QLineEdit*>(m_widget)->cursorPosition();
  m_widget->blockSignals(true);
  static_cast<QDoubleSpinBox*>(m_widget)->setValue(val);
//  static_cast<QDoubleSpinBox*>(m_widget)->setCursorPosition(cursorPos);
  m_widget->blockSignals(false);
}

void QuteSpinBox::applyInternalProperties()
{

  QuteWidget::applyInternalProperties();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
//  static_cast<QDoubleSpinBox*>(m_widget)->setValue(property("QCS_value").toDouble());
//  m_value2 = property("QCS_value2").toDouble();
//  m_stringValue = property("QCS_stringValue").toString();
  static_cast<QDoubleSpinBox*>(m_widget)->setRange(property("QCS_minimum").toDouble(),property("QCS_maximum").toDouble());
  m_value = property("QCS_value").toDouble();
  double resolution = property("QCS_resolution").toDouble();
  m_valueChanged = true;
  int i;
  for (i = 0; i < 8; i++) {//     Check for used decimal places.
    double fractpart, intpart;
    fractpart = modf (resolution * pow(10, i), &intpart);
    if (fractpart < 1e-200) {
      break;
    }
  }
  static_cast<QDoubleSpinBox*>(m_widget)->setDecimals(i);
  static_cast<QDoubleSpinBox*>(m_widget)->setSingleStep(resolution);
//  static_cast<QLabel*>(m_widget)->setText(property("QCS_label").toString());
  Qt::Alignment align;
  QString alignText = property("QCS_alignment").toString();
  if (alignText == "left") {
    align = Qt::AlignLeft|Qt::AlignVCenter;
  }
  else if (alignText == "center") {
    align = Qt::AlignHCenter|Qt::AlignVCenter;
  }
  else if (alignText == "right") {
    align = Qt::AlignRight|Qt::AlignVCenter;
  }
  static_cast<QDoubleSpinBox*>(m_widget)->setAlignment(align);
  setTextColor(property("QCS_color").value<QColor>());
  QString borderStyle = (property("QCS_bordermode").toString() == "border" ? "solid": "none");

  int new_fontSize = 0;
  int totalHeight = 0;
  double fontSize = (property("QCS_fontsize").toDouble()*m_fontScaling) + m_fontOffset;

  while (totalHeight < fontSize + 1) {
    new_fontSize++;
    QFont font(property("QCS_font").toString(), new_fontSize);
    QFontMetricsF fm(font);
    totalHeight = fm.ascent() + fm.descent();
  }

  m_widget->setStyleSheet("QDoubleSpinBox { font-family:\"" + property("QCS_font").toString()
                          + "\"; font-size: " + QString::number(new_fontSize) + "pt"
                          + (property("QCS_bgcolormode").toBool() ?
                                    QString("; background-color:") + property("QCS_bgcolor").value<QColor>().name() : QString("; "))
                          + "; color:" + property("QCS_color").value<QColor>().name()
//                          + "; border-color:" + property("QCS_color").value<QColor>().name()
//                          + "; border-radius:" + QString::number(property("QCS_borderradius").toInt()) + "px"
//                          + "; border-width: :" + QString::number(property("QCS_borderwidth").toInt()) + "px"
//                          + "; border-style: " + borderStyle
                          + "; }");
//  qDebug() << "QuteSpinBox::applyInternalProperties() sylesheet" <<  m_widget->styleSheet();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteSpinBox::createPropertiesDialog()
{
//   qDebug("QuteSpinBox::createPropertiesDialog()");
  QuteText::createPropertiesDialog();
  dialog->setWindowTitle("SpinBox");
  QLabel *label = new QLabel(dialog);
  label->setText("Resolution");
  layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
  resolutionSpinBox = new QDoubleSpinBox(dialog);
  resolutionSpinBox->setDecimals(6);
  resolutionSpinBox->setRange(0,999999999999.0);
  layout->addWidget(resolutionSpinBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);

  label = new QLabel(dialog);
  label->setText("Min =");
  layout->addWidget(label, 2, 0, Qt::AlignRight|Qt::AlignVCenter);
  minSpinBox = new QDoubleSpinBox(dialog);
  minSpinBox->setDecimals(6);
  minSpinBox->setRange(-999999999999.0, 999999999999.0);
  layout->addWidget(minSpinBox, 2,1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Max =");
  layout->addWidget(label, 2, 2, Qt::AlignRight|Qt::AlignVCenter);
  maxSpinBox = new QDoubleSpinBox(dialog);
  maxSpinBox->setDecimals(6);
  maxSpinBox->setRange(-999999999999.0, 999999999999.0);
  layout->addWidget(maxSpinBox, 2,3, Qt::AlignLeft|Qt::AlignVCenter);
//  fontSize->hide();
//  font->hide();
//  border->hide();
//  bg->hide();
//  textColor->hide();
//  bgColor->hide();
//  border->hide();
  borderRadius->hide();
  borderWidth->hide();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  resolutionSpinBox->setValue(property("QCS_resolution").toDouble());
  minSpinBox->setValue(property("QCS_minimum").toDouble());
  maxSpinBox->setValue(property("QCS_maximum").toDouble());
  text->setText(static_cast<QDoubleSpinBox *>(m_widget)->text());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteSpinBox::applyProperties()
{

    switch (alignment->currentIndex()) {
    case 0:
      setProperty("QCS_alignment", "left");
      break;
    case 1:
      setProperty("QCS_alignment", "center");
      break;
    case 2:
      setProperty("QCS_alignment", "right");
      break;
    default:
      setProperty("QCS_alignment", "");
  }
  setProperty("QCS_font", font->currentFont().family());
  setProperty("QCS_fontsize", fontSize->value());
  setProperty("QCS_bgcolor", bgColor->palette().color(QPalette::Window));
  setProperty("QCS_bgcolormode", bg->isChecked());
  setProperty("QCS_color", textColor->palette().color(QPalette::Window));
  setProperty("QCS_bordermode", border->isChecked() ? "border" : "noborder");
  setProperty("QCS_resolution", resolutionSpinBox->value());
  setProperty("QCS_value", text->toPlainText().toDouble());
  setProperty("QCS_maximum", maxSpinBox->value());
  setProperty("QCS_minimum", minSpinBox->value());
//  setProperty("QCS_randomizable",false);

  QuteWidget::applyProperties();  //Must be last to make sure the widgetChanged signal is last
}

void QuteSpinBox::valueChanged(double value)
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  setInternalValue(value);
  QPair<QString, double> channelValue(m_channel, value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  emit newValue(channelValue);
}

void QuteSpinBox::editingFinishedSlot()
{
  double value = static_cast<QDoubleSpinBox*>(m_widget)->value();

#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  setInternalValue(value);
  QPair<QString, double> channelValue(m_channel, value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  emit newValue(channelValue);
}

void QuteSpinBox::setInternalValue(double value)
{
  m_value = value;
//  m_stringValue = QString::number(value);
  m_valueChanged = true;
//  setProperty("QCS_value", m_value);
}
