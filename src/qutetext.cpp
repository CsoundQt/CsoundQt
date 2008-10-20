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
#include "qutetext.h"

QuteText::QuteText(QWidget *parent) : QuteWidget(parent)
{
  m_value = 0.0;
  m_widget = new QuteLabel(this);
  ((QuteLabel *)m_widget)->setWordWrap (true);
  ((QuteLabel *)m_widget)->setMargin (5);
//   ((QuteTextEdit *)m_widget)->setReadOnly(true);
//   ((QuteTextEdit *)m_widget)->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
  connect(((QuteLabel *)m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
//   m_alignment = Qt::AlignLeft;
}

QuteText::~QuteText()
{
}

double QuteText::getValue()
{
  return m_value;
}

void QuteText::setResolution(double resolution)
{
  m_resolution = resolution;
}

void QuteText::setAlignment(int alignment)
{
//   ((QLabel *)m_widget)->setAlignment(alignment);
}

void QuteText::setFont(QString font)
{
  m_font = font;
}

void QuteText::setFontSize(int fontSize)
{
  m_fontSize = fontSize;
}

void QuteText::setTextColor(QColor textColor)
{
  QPalette palette = ((QuteLabel *) m_widget)->palette();
  palette.setColor(QPalette::WindowText, textColor);
  ((QuteLabel *) m_widget)->setPalette(palette);
}

void QuteText::setBgColor(QColor bgColor)
{
  QPalette palette = ((QuteLabel *) m_widget)->palette();
  palette.setColor(QPalette::Window, bgColor);
  ((QuteLabel *) m_widget)->setPalette(palette);
}

void QuteText::setBg(bool bg)
{
  ((QuteLabel *)m_widget)->setAutoFillBackground(bg);
}

void QuteText::setBorder(bool border)
{
  if (border)
    ((QuteLabel *)m_widget)->setFrameShape(QFrame::Box);
  else
    ((QuteLabel *)m_widget)->setFrameShape(QFrame::NoFrame);
//   m_border = border;
}

void QuteText::setText(QString text)
{
  ((QuteLabel *)m_widget)->setText(text);
}

QString QuteText::getWidgetLine()
{
  //TODO finish implementig all properties for label
  QString line = "ioText {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += "label ";
  line += QString::number(m_value, 'f', 6) + " 0.00100 \"" + m_name + "\" ";
  QString alignment = "";
//   switch (((QLabel *)m_widget)->alignment()) {
//     case Qt:AlignLeft:
//       alignment = "left";
//       break;
//     case Qt:AlignRight:
//       alignment = "right";
//       break;
//     case Qt:AlignCenter:
//       alignment = "center";
//       break;
//       //Another possibility is Qt::AlignJustify
//     default:
//       alignment = "left";
//   }
  line += "left \"Lucida Grande\" 10 ";
  QColor color = ((QuteLabel *) m_widget)->palette().color(QPalette::WindowText);
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  color = ((QuteLabel *) m_widget)->palette().color(QPalette::Window);
  line += "{" + QString::number(color.red() * 256)
      + ", " + QString::number(color.green() * 256)
      + ", " + QString::number(color.blue() * 256) + "} ";
  line += ((QuteLabel *)m_widget)->autoFillBackground()? "background ":"nobackground ";
  line += ((QuteLabel *)m_widget)->frameShape()==QFrame::NoFrame ? "noborder ": "border ";
//   line += ((QuteLabel *)m_widget)->toPlainText();
  line += ((QuteLabel *)m_widget)->text();
  qDebug("QuteSlider::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

void QuteText::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  QLabel *label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Text:");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QLineEdit(dialog);
//   text->setText(((QuteLabel *)m_widget)->toPlainText());
  text->setText(((QuteLabel *)m_widget)->text());
  layout->addWidget(text, 4,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
  label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Text Color");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  textColor = new QPushButton(dialog);
  QPalette palette(((QuteLabel *) m_widget)->palette().color(QPalette::WindowText));
  textColor->setPalette(palette);
//   palette.color(QPalette::Window);
  layout->addWidget(textColor, 5,1, Qt::AlignLeft|Qt::AlignVCenter);
  connect(textColor, SIGNAL(released()), this, SLOT(selectTextColor()));
  label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Background Color");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 5, 2, Qt::AlignRight|Qt::AlignVCenter);
  bgColor = new QPushButton(dialog);
  palette = QPalette(((QuteLabel *) m_widget)->palette().color(QPalette::Window));
  bgColor->setPalette(palette);
//   palette.color(QPalette::Window);
  layout->addWidget(bgColor, 5,3, Qt::AlignLeft|Qt::AlignVCenter);
  bg = new QCheckBox("Background", dialog);
  bg->setChecked(((QuteLabel *)m_widget)->autoFillBackground());
  layout->addWidget(bg, 6,3, Qt::AlignLeft|Qt::AlignVCenter);
  border = new QCheckBox("Border", dialog);
  border->setChecked(((QuteLabel *)m_widget)->frameShape() != QFrame::NoFrame);
  layout->addWidget(border, 6,2, Qt::AlignLeft|Qt::AlignVCenter);
  connect(bgColor, SIGNAL(released()), this, SLOT(selectBgColor()));

}

void QuteText::applyProperties()
{
  ((QuteLabel *)m_widget)->setText(text->text());
  ((QuteLabel *)m_widget)->setAutoFillBackground(bg->isChecked());
  ((QuteLabel *)m_widget)->setFrameShape(border->isChecked()?  QFrame::Box : QFrame::NoFrame);
//   ((QuteLabel *)m_widget)->setPlainText(text->text());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteText::selectTextColor()
{
  QColor color = QColorDialog::getColor(((QuteLabel *) m_widget)->palette().color(QPalette::WindowText), this);
  if (color.isValid()) {
    setTextColor(color);
    textColor->setPalette(QPalette(((QuteLabel *) m_widget)->palette().color(QPalette::WindowText)));
//     colorLabel->setAutoFillBackground(true);
  }
}

void QuteText::selectBgColor()
{
  QColor color = QColorDialog::getColor(((QuteLabel *) m_widget)->palette().color(QPalette::Window), this);
  if (color.isValid()) {
    setBgColor(color);
    bgColor->setPalette(QPalette(((QuteLabel *) m_widget)->palette().color(QPalette::Window)));
//     colorLabel->setAutoFillBackground(true);
  }
}

