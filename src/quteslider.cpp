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

  connect(static_cast<QSlider *>(m_widget), SIGNAL(valueChanged(int)), this, SLOT(valueChanged(int)));

  setProperty("QCS_minimum", 0.0);
  setProperty("QCS_maximum", 1.0);
  setProperty("QCS_value", 0.0);
  setProperty("QCS_mode", "lin");
  setProperty("QCS_mouseControl", "continuous");
  setProperty("QCS_mouseControlAct", "jump");
  setProperty("QCS_resolution", -1.0);
  setProperty("QCS_randomizable", false);
}

QuteSlider::~QuteSlider()
{
}

double QuteSlider::getValue()
{
  return m_value;
}

void QuteSlider::valueChanged(int value)
{
  double normalized = (double) value / (double) m_len;
  double min = property("QCS_minimum").toDouble();
  double max = property("QCS_maximum").toDouble();
  m_value =  min + (normalized * (max-min));
  QuteWidget::valueChanged(m_value);
}

void QuteSlider::setValue(double value)
{
  double max = property("QCS_maximum").toDouble();
  double min = property("QCS_minimum").toDouble();
  if (value > max)
    setProperty("QCS_value", max);
  else if (value < min)
    setProperty("QCS_value", min);
  else
    setProperty("QCS_value", value);
  int val = (int) (m_len * (property("QCS_value").toDouble() - min)/(max- min));
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  static_cast<QSlider *>(m_widget)->setValue(val);
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

void QuteSlider::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteSlider::applyInternalProperties()";
  QVariant prop;

  double max = property("QCS_maximum").toDouble();
  double min = property("QCS_minimum").toDouble();
  if (max < min) {
    double temp = max;
    max = min;
    min = temp;
  }
  prop = property("QCS_value");
  if (prop.isValid()) {
    setValue(prop.toDouble());
  }
}

void QuteSlider::setWidgetGeometry(int x, int y, int w, int h)
{
  QuteWidget::setWidgetGeometry(x,y,w,h);
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
}

QString QuteSlider::getWidgetLine()
{
  QString line = "ioSlider {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(property("QCS_minimum").toDouble(), 'f', 6) + " ";
  line += QString::number(property("QCS_maximum").toDouble(), 'f', 6) + " ";
  line += QString::number(m_value, 'f', 6) + " " + property("QCS_objectName").toString();
//   qDebug("QuteSlider::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteSlider::getCabbageLine()
{
  QString line = "scrollbar chan(\"" + property("QCS_objectName").toString() + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "min("+ QString::number(property("QCS_minimum").toDouble(), 'f', 8) +"), ";
  line += "max("+ QString::number(property("QCS_maximum").toDouble(), 'f', 8) +"), ";
  line += "value(" + QString::number(m_value, 'f', 8) + "), ";
  line += "kind(\"" + (width() > height()? QString("horizontal"):QString("vertical")) +"\")";
  return line;
}

QString QuteSlider::getCsladspaLine()
{
  QString line = "ControlPort=" + property("QCS_objectName").toString() + "|" + property("QCS_objectName").toString() + "\n";
  line += "Range=" + QString::number(property("QCS_minimum").toDouble(), 'f', 8)
          + "|" + QString::number(property("QCS_maximum").toDouble(), 'f', 8);
  return line;
}

QString QuteSlider::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

  s.writeTextElement("minimum", QString::number(property("QCS_minimum").toDouble(), 'f', 8));
  s.writeTextElement("maximum", QString::number(property("QCS_maximum").toDouble(), 'f', 8));
  s.writeTextElement("value", QString::number(m_value, 'f', 8));
  s.writeTextElement("resolution", QString::number(property("QCS_resolution").toDouble(), 'f', 8));
  s.writeTextElement("randomizable", property("QCS_resolution").toBool() ? "true" : "false");

  s.writeEndElement();
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
  setProperty("QCS_value", m_value);
}

void QuteSlider::applyProperties()
{
  setProperty("QCS_maximum", maxSpinBox->value());
  setProperty("QCS_minimum", minSpinBox->value());
  QuteWidget::applyProperties();  // Must be last to make sure the widgetsChanged signal is last
}
