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
  m_widget = new QDial(this);
  m_max = 1.0;
  m_min = 0.0;
  static_cast<QDial *>(m_widget)->setNotchesVisible(true);
  //TODO add resolution to config dialog and set these values accordingly
  m_resolution = 0.01;
  static_cast<QDial *>(m_widget)->setMinimum(0);
  static_cast<QDial *>(m_widget)->setMaximum(99);
  m_widget->setPalette(QPalette(Qt::gray));
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);

  connect((QDial *)m_widget, SIGNAL(valueChanged(int)), this, SLOT(valueChanged(int)));
}

QuteKnob::~QuteKnob()
{
}

double QuteKnob::getValue()
{
  QDial *knob = static_cast<QDial *>(m_widget);
  double normalized = (double) (knob->value() - knob->minimum())
        / (double) (knob->maximum() - knob->minimum());
  m_value = m_min + (normalized * (m_max-m_min));
  return m_value;
}

void QuteKnob::setRange(double min, double max)
{
  // TODO when knob is resized, its internal range should be adjusted...
  if (max < min) {
    double temp = max;
    max = min;
    min = temp;
  }
  m_min = min;
  m_max = max;
  if (m_value > m_max)
    m_value = m_max;
  else if (m_value > m_min)
    m_value = m_min;
}

void QuteKnob::setValue(double value)
{
  if (value > m_max)
    m_value = m_max;
  else if (value < m_min)
    m_value = m_min;
  else
    m_value = value;
  int val = (int) (static_cast<QDial *>(m_widget)->maximum() * (m_value - m_min)/(m_max-m_min));
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  ((QDial *)m_widget)->setValue(val);
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

void QuteKnob::setResolution(double resolution)
{
  m_resolution = resolution;
}

void QuteKnob::setWidgetLine(QString line)
{
  m_line = line;
}

void QuteKnob::setWidgetGeometry(int x, int y, int width, int height)
{
  QuteWidget::setWidgetGeometry(x,y,width,height);
  m_widget->move(5,5);
  m_widget->setFixedSize(width-10, height-10);
}

QString QuteKnob::getWidgetLine()
{
  QString line = "ioKnob {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(m_min, 'f', 6) + " " + QString::number(m_max, 'f', 6) + " ";
  line += QString::number(m_resolution, 'f', 6) + " ";
  line += QString::number(m_value, 'f', 6) + " " + m_name;
//   qDebug("QuteKnob::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteKnob::getCsladspaLine()
{
  QString line = "ControlPort=" + m_name + "|" + m_name + "\n";
  line += "Range=" + QString::number(m_min, 'f', 6) + "|" + QString::number(m_max, 'f', 6);
  return line;
}

QString QuteKnob::getCabbageLine()
{
  QString line = "";
  return line;
}

void QuteKnob::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Knob");
  QLabel *label = new QLabel(dialog);
  label->setText("Min =");
  layout->addWidget(label, 2, 0, Qt::AlignRight|Qt::AlignVCenter);
  minSpinBox = new QDoubleSpinBox(dialog);
  minSpinBox->setDecimals(6);
  minSpinBox->setRange(-99999.0, 99999.0);
  minSpinBox->setValue(m_min);
  layout->addWidget(minSpinBox, 2,1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Max =");
  layout->addWidget(label, 2, 2, Qt::AlignRight|Qt::AlignVCenter);
  maxSpinBox = new QDoubleSpinBox(dialog);
  maxSpinBox->setDecimals(6);
  maxSpinBox->setRange(-99999.0, 99999.0);
  maxSpinBox->setValue(m_max);
  layout->addWidget(maxSpinBox, 2,3, Qt::AlignLeft|Qt::AlignVCenter);
  label->setText("Resolution");
  layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
//   resolutionSpinBox = new QDoubleSpinBox(dialog);
//   resolutionSpinBox->setDecimals(6);
//   resolutionSpinBox->setValue(getResolution());
//   layout->addWidget(resolutionSpinBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);
}

void QuteKnob::applyProperties()
{
  m_max = maxSpinBox->value();
  m_min = minSpinBox->value();
//   m_resolution = resolutionSpinBox->value();
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}
