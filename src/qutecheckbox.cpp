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
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  canFocus(false);

  connect(static_cast<QCheckBox *>(m_widget), SIGNAL(stateChanged(int)), this, SLOT(stateChanged(int)));
}

QuteCheckBox::~QuteCheckBox()
{
}

void QuteCheckBox::loadFromXml(QString xmlText)
{
  initFromXml(xmlText);
  QDomDocument doc;
  if (!doc.setContent(xmlText)) {
    qDebug() << "QuteCheckBox::loadFromXml: Error parsing xml";
    return;
  }
  QDomElement e = doc.firstChildElement("selected");
  if (e.isNull()) {
    qDebug() << "QuteCheckBox::loadFromXml: Expecting selected element";
    return;
  }
  else {
    static_cast<QCheckBox *>(m_widget)->setChecked(e.nodeValue() == "true");
  }
  e = doc.firstChildElement("label");
  if (e.isNull()) {
    qDebug() << "QuteCheckBox::loadFromXml: Expecting label element";
    return;
  }
  else {
    setLabel(e.nodeValue());
  }
  e = doc.firstChildElement("randomizable");
  if (e.isNull()) {
    qDebug() << "QuteCheckBox::loadFromXml: Expecting randomizable element";
    return;
  }
  else {
    qDebug() << "QuteCheckBox::loadFromXml: randomizable not implemented";
  }
}

void QuteCheckBox::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  // value is 1 is checked, 0 if not
  static_cast<QCheckBox *>(m_widget)->setChecked(value == 1);
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
  return (static_cast<QCheckBox *>(m_widget)->isChecked()? 1.0:0.0);
}

QString QuteCheckBox::getLabel()
{
  return static_cast<QCheckBox *>(m_widget)->text();
}

QString QuteCheckBox::getWidgetLine()
{
  QString line = "ioCheckbox {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += (static_cast<QCheckBox *>(m_widget)->isChecked()? QString("on "):QString("off "));
  line += m_name;
//   qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteCheckBox::getCabbageLine()
{
  QString line = "checkbox channel(\"" + m_name + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "value(" + (static_cast<QCheckBox *>(m_widget)->isChecked()? QString("1"):QString("0")) + "), ";
  line += "caption(\"" + getLabel() + "\")";
  return line;
}

QString QuteCheckBox::getWidgetType()
{
  return QString("BSBCheckBox");
}

QString QuteCheckBox::getWidgetXmlText()
{
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

  s.writeTextElement("selected",
                     static_cast<QCheckBox *>(m_widget)->isChecked()? QString("true"):QString("false"));
  s.writeTextElement("label", getLabel());
  // These come from blue, but they are not implemented here
  s.writeTextElement("randomizable", "");
  s.writeEndElement();
  return xmlText;
}

void QuteCheckBox::stateChanged(int state)
{
  if (state == Qt::Unchecked)
    emit valueChanged(0);
  else if (state == Qt::Checked)
    emit valueChanged(1);
}

void QuteCheckBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Check Box");
}
