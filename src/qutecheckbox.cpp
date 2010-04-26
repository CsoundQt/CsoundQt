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

#include "qutecheckbox.h"

QuteCheckBox::QuteCheckBox(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QCheckBox(this);
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  canFocus(false);

  setProperty("QCS_selected", false);
  setProperty("QCS_label", "");
  setProperty("QCS_pressedValue", 1);
  setProperty("QCS_randomizable", false);

  m_currentValue = 0;

  connect(static_cast<QCheckBox *>(m_widget), SIGNAL(stateChanged(int)), this, SLOT(stateChanged(int)));
}

QuteCheckBox::~QuteCheckBox()
{
}

void QuteCheckBox::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForWrite();
#endif
  if (value >=0) {
    m_currentValue = value != 0 ? m_value : 0.0;
  }
  else {
    m_value = -value;
    m_currentValue = -value;
  }
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
}

void QuteCheckBox::setLabel(QString label)
{
  static_cast<QCheckBox *>(m_widget)->setText(label);
}

double QuteCheckBox::getValue()
{
  widgetLock.lockForRead();
  double value = m_currentValue;
  widgetLock.unlock();
  return value;
}

//QString QuteCheckBox::getLabel()
//{
//  return static_cast<QCheckBox *>(m_widget)->text();
//}

QString QuteCheckBox::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  QString line = "ioCheckbox {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += (static_cast<QCheckBox *>(m_widget)->isChecked()? QString("on "):QString("off "));
  line += property("QCS_objectName").toString();
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return line;
}

QString QuteCheckBox::getCabbageLine()
{
  QString line = "checkbox channel(\"" + property("QCS_objectName").toString() + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "value(" + (static_cast<QCheckBox *>(m_widget)->isChecked()?
                      QString::number(property("QCS_pressedValue").toDouble(), 'f', 8):QString("0")) + "), ";
  line += "caption(\"" +  property("QCS_label").toString() + "\")";
  return line;
}

QString QuteCheckBox::getWidgetType()
{
  return QString("BSBCheckBox");
}

QString QuteCheckBox::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif

  s.writeTextElement("selected",
                     static_cast<QCheckBox *>(m_widget)->isChecked()? QString("true"):QString("false"));
  s.writeTextElement("label", property("QCS_label").toString());
  s.writeTextElement("pressedValue", QString::number(property("QCS_pressedValue").toDouble()));
  s.writeTextElement("randomizable", property("QCS_randomizable").toBool() ? "true": "false");
  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return xmlText;
}

void QuteCheckBox::refreshWidget()
{
  widgetLock.lockForWrite();
  m_widget->blockSignals(true);
  static_cast<QCheckBox *>(m_widget)->setChecked(m_currentValue != 0);
  m_widget->blockSignals(false);
  setProperty("QCS_value", m_value);
  setProperty("QCS_selected", m_currentValue != 0);
  widgetLock.unlock();
}

void QuteCheckBox::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteSlider::applyInternalProperties()";
  setValue(property("QCS_selected").toBool());
  setLabel(property("QCS_label").toString());
}

void QuteCheckBox::stateChanged(int state)
{
  widgetLock.lockForRead();
  m_currentValue = state ? property("QCS_value").toDouble() : 0;
  widgetLock.unlock();
}

void QuteCheckBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  dialog->setWindowTitle("Check Box");
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
}
