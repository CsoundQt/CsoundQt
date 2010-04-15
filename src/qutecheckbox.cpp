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
  setProperty("QCS_value", 1);  // This is called value, even though it's not handled by the usual value handlers...
  setProperty("QCS_randomizable", false);

  connect(static_cast<QCheckBox *>(m_widget), SIGNAL(stateChanged(int)), this, SLOT(stateChanged(int)));
}

QuteCheckBox::~QuteCheckBox()
{
}

void QuteCheckBox::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  // value is 1 is checked, 0 if not
  static_cast<QCheckBox *>(m_widget)->setChecked(value != 0);
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

void QuteCheckBox::setLabel(QString label)
{
  static_cast<QCheckBox *>(m_widget)->setText(label);
}

double QuteCheckBox::getValue()
{
  return (static_cast<QCheckBox *>(m_widget)->isChecked()? property("QCS_value").toDouble():0.0);
}

//QString QuteCheckBox::getLabel()
//{
//  return static_cast<QCheckBox *>(m_widget)->text();
//}

QString QuteCheckBox::getWidgetLine()
{
  QString line = "ioCheckbox {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += (static_cast<QCheckBox *>(m_widget)->isChecked()? QString("on "):QString("off "));
  line += property("QCS_objectName").toString();
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteCheckBox::getCabbageLine()
{
  QString line = "checkbox channel(\"" + property("QCS_objectName").toString() + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "value(" + (static_cast<QCheckBox *>(m_widget)->isChecked()?
                      QString::number(property("QCS_value").toDouble(), 'f', 8):QString("0")) + "), ";
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

  s.writeTextElement("selected",
                     static_cast<QCheckBox *>(m_widget)->isChecked()? QString("true"):QString("false"));
  s.writeTextElement("label", property("QCS_label").toString());
  s.writeTextElement("value", QString::number(property("QCS_value").toDouble(), 'f', 8));
  s.writeTextElement("randomizable", property("QCS_randomizable").toBool() ? "true": "false");
  s.writeEndElement();
  return xmlText;
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
  if (state == Qt::Unchecked)
    emit valueChanged(0);
  else if (state == Qt::Checked)
    emit valueChanged(property("QCS_value").toDouble());
}

void QuteCheckBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Check Box");
}
