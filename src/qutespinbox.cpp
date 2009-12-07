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
  static_cast<QDoubleSpinBox*>(m_widget)->setRange(-99999.999999, 99999.999999);
  connect(static_cast<QDoubleSpinBox *>(m_widget), SIGNAL(valueChanged(double)), this, SLOT(valueChanged(double)));
//   connect(static_cast<QDoubleSpinBox*>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
  m_type = "editnum";
}

QuteSpinBox::~QuteSpinBox()
{
}

void QuteSpinBox::loadFromXml(QString xmlText)
{
  initFromXml(xmlText);
  QDomDocument doc;
  if (!doc.setContent(xmlText)) {
    qDebug() << "QuteSpinBox::loadFromXml: Error parsing xml";
    return;
  }
  QDomElement e = doc.firstChildElement("type");
  if (e.isNull()) {
    qDebug() << "QuteSpinBox::loadFromXml: Expecting minimum element";
    return;
  }
  else {
    m_type = e.nodeValue();
  }
  e = doc.firstChildElement("value");
  if (e.isNull()) {
    qDebug() << "QuteSpinBox::loadFromXml: Expecting value element";
    return;
  }
  else {
    static_cast<QDoubleSpinBox*>(m_widget)->setValue(e.nodeValue().toDouble());
  }
  e = doc.firstChildElement("resolution");
  if (e.isNull()) {
    qDebug() << "QuteSpinBox::loadFromXml: Expecting resolution element";
    return;
  }
  else {
    m_resolution = e.nodeValue().toDouble();
  }
  e = doc.firstChildElement("alignment");
  if (e.isNull()) {
    qDebug() << "QuteSpinBox::loadFromXml: Expecting alignment element";
    return;
  }
  else {
    QString alignment = e.nodeValue();
    Qt::AlignmentFlag align = Qt::AlignCenter;
    if (alignment == "left") {
      align = Qt::AlignLeft;
    }
    else if (alignment == "center") {
      align = Qt::AlignCenter;
    }
    else if (alignment == "right") {
      align = Qt::AlignRight;
    }
    static_cast<QDoubleSpinBox *>(m_widget)->setAlignment(align);
  }
  e = doc.firstChildElement("font");
  if (e.isNull()) {
    qDebug() << "QuteSpinBox::loadFromXml: Expecting font element";
    return;
  }
  else {
    m_font = e.nodeValue();
  }
  e = doc.firstChildElement("fontsize");
  if (e.isNull()) {
    qDebug() << "QuteSpinBox::loadFromXml: Expecting fontsize element";
    return;
  }
  else {
    m_fontSize = e.nodeValue().toInt();
  }
  e = doc.firstChildElement("color");
  if (e.isNull()) {
    qDebug() << "QuteMeter::loadFromXml: Expecting color element";
    return;
  }
  else {
    QDomElement e2 = e.firstChildElement("r");
//    m_color.setRed(e.nodeValue().toInt());
//    e.firstChildElement("g");
//    m_color.setGreen(e.nodeValue().toInt());
//    e.firstChildElement("b");
//    m_color.setBlue(e.nodeValue().toInt());
  }
  //TODO implement!!!
//  QColor color = m_widget->palette().color(QPalette::WindowText);
  e = doc.firstChildElement("bgcolor");
  if (e.isNull()) {
    qDebug() << "QuteMeter::loadFromXml: Expecting color element";
    return;
  }
  else {
    m_widget->setAutoFillBackground(e.attribute("mode", "nobackground") == "background");
    QDomElement e2 = e.firstChildElement("r");
//    m_color.setRed(e.nodeValue().toInt());
//    e.firstChildElement("g");
//    m_color.setGreen(e.nodeValue().toInt());
//    e.firstChildElement("b");
//    m_color.setBlue(e.nodeValue().toInt());
  }
  //TODO implement!!!
//  color = m_widget->palette().color(QPalette::Window);
  e = doc.firstChildElement("randomizable");
  if (e.isNull()) {
    qDebug() << "QuteSpinBox::loadFromXml: Expecting randomizable element";
    return;
  }
  else {
    qDebug() << "QuteSpinBox::loadFromXml: randomizable element not implemented";
  }
}

void QuteSpinBox::setAlignment(int alignment)
{
//   qDebug("QuteText::setAlignment %i", alignment);
  Qt::Alignment align;
  switch (alignment) {
    case 0:
      align = Qt::AlignLeft|Qt::AlignTop;
      break;
    case 1:
      align = Qt::AlignHCenter|Qt::AlignTop;
      break;
    case 2:
      align = Qt::AlignRight|Qt::AlignTop;
      break;
    default:
      align = Qt::AlignLeft|Qt::AlignTop;
  }
  static_cast<QDoubleSpinBox*>(m_widget)->setAlignment(align);
}

void QuteSpinBox::setValue(double value)
{
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  static_cast<QDoubleSpinBox*>(m_widget)->setValue(value);
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

void QuteSpinBox::setText(QString text)
{
  m_text = text;
//   int size;
//   if (m_fontSize >= QUTE_XXLARGE)
//     size = 7;
//   else if (m_fontSize >= QUTE_XLARGE)
//     size = 6;
//   else if (m_fontSize >= QUTE_LARGE)
//     size = 5;
//   else if (m_fontSize >= QUTE_MEDIUM)
//     size = 4;
//   else if (m_fontSize >= QUTE_SMALL)
//     size = 3;
//   else if (m_fontSize >= QUTE_XSMALL)
//     size = 2;
//   else
//     size = 1;
//   text.prepend("<font face=\"" + m_font + "\" size=\"" + QString::number(size) + "\">");
//   text.append("</font>");
  //TODO USE CORRECT CHARACTER for line break
//   text = text.replace("�", "\n");
  bool ok;
  double value = text.toDouble(&ok);
  if (ok)
    static_cast<QDoubleSpinBox*>(m_widget)->setValue(value);
}

void QuteSpinBox::setResolution(double resolution)
{
  m_resolution = resolution;
  int i;
  for (i = 0; i < 6; i++) {
//     Check for used decimal places.
    if ((m_resolution * pow(10, i)) == (int) (m_resolution * pow(10,i)) )
      break;
  }
  static_cast<QDoubleSpinBox*>(m_widget)->setDecimals(i);
  static_cast<QDoubleSpinBox*>(m_widget)->setSingleStep(resolution);
}

double QuteSpinBox::getValue()
{
  return static_cast<QDoubleSpinBox*>(m_widget)->value();
}

QString QuteSpinBox::getWidgetLine()
{
  QString line = "ioText {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += m_type + " ";
  line += QString::number(static_cast<QDoubleSpinBox*>(m_widget)->value(), 'f', 6) + " ";
  line += QString::number(m_resolution, 'f', 6) + " \"" + m_name + "\" ";
  QString alignment = "";
  int align = static_cast<QDoubleSpinBox *>(m_widget)->alignment();
  if (align & Qt::AlignLeft)
    alignment = "left";
  else if (align & Qt::AlignCenter)
    alignment = "center";
  else if (align & Qt::AlignRight)
    alignment = "right";
  line += alignment + " ";
  line += "\"" + m_font + "\" " + QString::number(m_fontSize) + " ";
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
  return line;
}

QString QuteSpinBox::getCsladspaLine()
{
  QString line = "ControlPort=" + m_name + "|" + m_name + "\n";
  line += "Range=-9999|9999";
  return line;
}

QString QuteSpinBox::getWidgetXmlText()
{
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);
  // Not implemented in blue

  s.writeTextElement("type", m_type);
  s.writeTextElement("value", QString::number(static_cast<QDoubleSpinBox*>(m_widget)->value()));
  s.writeTextElement("resolution", QString::number(m_resolution, 'f', 6));

  QString alignment = "";
  int align = static_cast<QDoubleSpinBox *>(m_widget)->alignment();
  if (align & Qt::AlignLeft)
    alignment = "left";
  else if (align & Qt::AlignCenter)
    alignment = "center";
  else if (align & Qt::AlignRight)
    alignment = "right";
  s.writeTextElement("alignment", alignment);

  s.writeTextElement("font", m_font);
  s.writeTextElement("fontsize", QString::number(m_fontSize));

  QColor color = m_widget->palette().color(QPalette::WindowText);
  s.writeStartElement("color");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();
  color = m_widget->palette().color(QPalette::Window);
  s.writeStartElement("bgcolor");
  s.writeAttribute("mode", m_widget->autoFillBackground()? "background":"nobackground");
  s.writeTextElement("r", QString::number(color.red()));
  s.writeTextElement("g", QString::number(color.green()));
  s.writeTextElement("b", QString::number(color.blue()));
  s.writeEndElement();

  s.writeTextElement("randomizable", "");

  return xmlText;
}

QString QuteSpinBox::getWidgetType()
{
  return QString("BSBSpinBox");
}

QString QuteSpinBox::getCabbageLine()
{
  QString line = "";
  return line;
}

QString QuteSpinBox::getStringValue()
{
  return static_cast<QDoubleSpinBox *>(m_widget)->text();
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
  resolutionSpinBox->setValue(m_resolution);
  layout->addWidget(resolutionSpinBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);

  fontSize->hide();
  font->hide();
  border->hide();
  bg->hide();
  textColor->hide();
  bgColor->hide();
  text->setText(static_cast<QDoubleSpinBox *>(m_widget)->text());

}

void QuteSpinBox::applyProperties()
{
  setResolution(resolutionSpinBox->value());
  setText(text->toPlainText());
//   m_widget->setAutoFillBackground(bg->isChecked());
  setAlignment(alignment->currentIndex());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}
