/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/
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
