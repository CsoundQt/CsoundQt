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

#include "quteknob.h"

QuteKnob::QuteKnob(QWidget *parent) : QuteWidget(parent)
{
  //TODO add resolution to config dialog and set these values accordingly
  m_widget = new QDial(this);
  static_cast<QDial *>(m_widget)->setMinimum(0);
  static_cast<QDial *>(m_widget)->setMaximum(99);
  static_cast<QDial *>(m_widget)->setNotchesVisible(true);
  m_widget->setPalette(QPalette(Qt::gray));
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels

  setProperty("QCS_resolution", 0.01);
  setProperty("QCS_minimum", 0.0);
  setProperty("QCS_maximum", 99.0);
  connect(static_cast<QDial *>(m_widget), SIGNAL(valueChanged(int)), this, SLOT(knobChanged(int)));
}

QuteKnob::~QuteKnob()
{
}

double QuteKnob::getValue()
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  double value = m_value;
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return value;
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
  setProperty("QCS_maximum", max);
  setProperty("QCS_minimum", min);
}

void QuteKnob::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteSlider::applyInternalProperties()";
//  QVariant prop;
  setValue(property("QCS_value").toDouble());
}

void QuteKnob::setValue(double value)
{
//  qDebug() << "QuteKnob::setValue " << value;
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForWrite();
#endif
  double max = property("QCS_maximum").toDouble();
  double min = property("QCS_minimum").toDouble();
  setInternalValue(value);
  int val = (int) (static_cast<QDial *>(m_widget)->maximum() * (m_value - min)/(max-min));
  static_cast<QSlider *>(m_widget)->blockSignals(true);
  static_cast<QDial *>(m_widget)->setValue(val);
  static_cast<QSlider *>(m_widget)->blockSignals(false);
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
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
//  m_widget->move(5,5);
  m_widget->setFixedSize(width, height);
}

QString QuteKnob::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  QString line = "ioKnob {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(property("QCS_maximum").toDouble(), 'f', 6) + " ";
  line += QString::number(property("QCS_minimum").toDouble(), 'f', 6) + " ";
  line += QString::number(property("QCS_resolution").toDouble(), 'f', 6) + " ";
  line += QString::number(m_value, 'f', 6) + " " + property("QCS_objectName").toString();
//   qDebug("QuteKnob::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return line;
}

QString QuteKnob::getCabbageLine()
{
  QString line = "";
  return line;
}

QString QuteKnob::getCsladspaLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  QString line = "ControlPort=" + property("QCS_objectName").toString() + "|" + property("QCS_objectName").toString() + "\n";
  line += "Range=" + QString::number(property("QCS_minimum").toDouble(), 'f', 8);
  line += "|" + QString::number(property("QCS_maximum").toDouble(), 'f', 8);
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return line;
}

QString QuteKnob::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif

  s.writeTextElement("minimum", QString::number(property("QCS_minimum").toDouble(), 'f', 8));
  s.writeTextElement("maximum", QString::number(property("QCS_maximum").toDouble(), 'f', 8));
  s.writeTextElement("value", QString::number(m_value, 'f', 8));
  s.writeTextElement("randomizable", "");
  s.writeTextElement("resolution", QString::number(property("QCS_resolution").toDouble(), 'f', 8));

  // Thesecome from blue, but they are not implemented here
  //s.writeTextElement("knobWidth", "");
  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
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
  widgetMutex.lockForRead();
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
  setProperty("QCS_value", m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
}

void QuteKnob::applyProperties()
{
//  m_max = maxSpinBox->value();
//  m_min = minSpinBox->value();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  setProperty("QCS_maximum", maxSpinBox->value());
  setProperty("QCS_minimum", minSpinBox->value());
//   m_resolution = resolutionSpinBox->value();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteKnob::knobChanged(int value)
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForWrite();
#endif
  double min = property("QCS_minimum").toDouble();
  double max = property("QCS_maximum").toDouble();
  QDial *knob = static_cast<QDial *>(m_widget);
  double normalized = (double) (value - knob->minimum())
        / (double) (knob->maximum() - knob->minimum());
  double scaledValue =  min + (normalized * (max-min));
  setInternalValue(scaledValue);
  QPair<QString, double> channelValue(property("QCS_objectName").toString(), m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  emit newValue(channelValue);
}

void QuteKnob::setInternalValue(double value)
{
  double max = property("QCS_maximum").toDouble();
  double min = property("QCS_minimum").toDouble();
  if (value > max)
    m_value = max;
  else if (value < min)
    m_value = min;
  else
    m_value = value;
  setProperty("QCS_value", m_value);
}
