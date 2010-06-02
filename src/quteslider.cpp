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

#include "quteslider.h"

QuteSlider::QuteSlider(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QSlider(this);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  canFocus(false);
  if (width() > height())
    static_cast<QSlider *>(m_widget)->setOrientation(Qt::Horizontal);
  else
    static_cast<QSlider *>(m_widget)->setOrientation(Qt::Vertical);

  connect(static_cast<QSlider *>(m_widget), SIGNAL(valueChanged(int)), this, SLOT(sliderChanged(int)));

  setProperty("QCS_minimum", 0.0);
  setProperty("QCS_maximum", 1.0);
  setProperty("QCS_value", 0.0);
  setProperty("QCS_mode", "lin");
  setProperty("QCS_mouseControl", "continuous");
  setProperty("QCS_mouseControlAct", "jump");
  setProperty("QCS_resolution", -1.0);
  setProperty("QCS_randomizable", false);
  setProperty("QCS_randomizableGroup", 0);
}

QuteSlider::~QuteSlider()
{
}

//void QuteSlider::sliderMoved(int value)
//{
//  QuteWidget::valueChanged(m_value);
//}

void QuteSlider::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  setInternalValue(value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteSlider::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
//  qDebug() << "QuteSlider::refreshWidget " << m_value;
  double min = property("QCS_minimum").toDouble();
  double max = property("QCS_maximum").toDouble();
  int val = (int) (m_len * (m_value - min)/(max- min));
  m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  m_widget->blockSignals(true);
  static_cast<QSlider *>(m_widget)->setValue(val);
  m_widget->blockSignals(false);
}

void QuteSlider::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteSlider::applyInternalProperties()";

  m_value = property("QCS_value").toDouble();
//  m_value2 = property("QCS_value2").toDouble();
//  m_stringValue = property("QCS_stringValue").toString();
  double max = property("QCS_maximum").toDouble();
  double min = property("QCS_minimum").toDouble();
  if (max < min) {
    double temp = max;
    max = min;
    min = temp;
  }
}

void QuteSlider::setWidgetGeometry(int x, int y, int w, int h)
{
  QuteWidget::setWidgetGeometry(x,y,w,h);
  m_widget->blockSignals(true);
  if (width() > height()) {
    static_cast<QSlider *>(m_widget)->setOrientation(Qt::Horizontal);
    static_cast<QSlider *>(m_widget)->setMaximum(w);
    m_len = w;
  }
  else {
    static_cast<QSlider *>(m_widget)->setOrientation(Qt::Vertical);
    static_cast<QSlider *>(m_widget)->setMaximum(h);
    m_len = h;
  }
  m_widget->blockSignals(false);
}

QString QuteSlider::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ioSlider {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(property("QCS_minimum").toDouble(), 'f', 6) + " ";
  line += QString::number(property("QCS_maximum").toDouble(), 'f', 6) + " ";
  line += QString::number(m_value, 'f', 6) + " " + m_channel;
//   qDebug("QuteSlider::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteSlider::getCabbageLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  QString line = "scrollbar chan(\"" + m_channel + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "min("+ QString::number(property("QCS_minimum").toDouble(), 'f', 8) +"), ";
  line += "max("+ QString::number(property("QCS_maximum").toDouble(), 'f', 8) +"), ";
  line += "value(" + QString::number(m_value, 'f', 8) + "), ";
  line += "kind(\"" + (width() > height()? QString("horizontal"):QString("vertical")) +"\")";
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteSlider::getCsladspaLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ControlPort=" + m_channel + "|" + m_channel + "\n";
  line += "Range=" + QString::number(property("QCS_minimum").toDouble(), 'f', 8)
          + "|" + QString::number(property("QCS_maximum").toDouble(), 'f', 8);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteSlider::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
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

  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return xmlText;
}

QString QuteSlider::getWidgetType()
{
  return (width() > height()? QString("BSBHSlider"):QString("BSBVSlider"));
}

void QuteSlider::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Slider");
  QLabel *label = new QLabel(dialog);
  label->setText("Min =");
  layout->addWidget(label, 2, 0, Qt::AlignRight|Qt::AlignVCenter);
  minSpinBox = new QDoubleSpinBox(dialog);
  minSpinBox->setDecimals(6);
  minSpinBox->setRange(-99999.0, 99999.0);
  layout->addWidget(minSpinBox, 2,1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Max =");
  layout->addWidget(label, 2, 2, Qt::AlignRight|Qt::AlignVCenter);
  maxSpinBox = new QDoubleSpinBox(dialog);
  maxSpinBox->setDecimals(6);
  maxSpinBox->setRange(-99999.0, 99999.0);
  layout->addWidget(maxSpinBox, 2,3, Qt::AlignLeft|Qt::AlignVCenter);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  minSpinBox->setValue(property("QCS_minimum").toDouble());
  maxSpinBox->setValue(property("QCS_maximum").toDouble());
//  setProperty("QCS_value", m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
}

void QuteSlider::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  setProperty("QCS_maximum", maxSpinBox->value());
  setProperty("QCS_minimum", minSpinBox->value());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  QuteWidget::applyProperties();  // Must be last to make sure the widgetsChanged signal is last
}

void QuteSlider::sliderChanged(int value)
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  double normalized = (double) value / (double) m_len;
  double min = property("QCS_minimum").toDouble();
  double max = property("QCS_maximum").toDouble();
  double scaledValue =  min + (normalized * (max-min));
  setInternalValue(scaledValue);
  QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  emit newValue(channelValue);
}

void QuteSlider::setInternalValue(double value)
{
  double max = property("QCS_maximum").toDouble();
  double min = property("QCS_minimum").toDouble();
  if (value > max)
    m_value = max;
  else if (value < min)
    m_value = min;
  else
    m_value = value;
  m_valueChanged = true;
//  setProperty("QCS_value", m_value);
}
