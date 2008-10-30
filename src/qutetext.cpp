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

// Font point sizes equivalent for html
// This seems necessary since qt rich text
// only takes these values for font size
#define QUTE_XXSMALL 4
#define QUTE_XSMALL 6
#define QUTE_SMALL 8
#define QUTE_MEDIUM 10
#define QUTE_LARGE 14
#define QUTE_XLARGE 20
#define QUTE_XXLARGE 24

QuteText::QuteText(QWidget *parent) : QuteWidget(parent)
{
  m_value = 0.0;
  m_widget = new QuteLabel(this);
  ((QuteLabel *)m_widget)->setWordWrap (true);
  ((QuteLabel *)m_widget)->setMargin (5);
  ((QuteLabel *)m_widget)->setTextFormat(Qt::RichText);
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
//   qDebug("QuteText::setAlignment %i", alignment);
  Qt::Alignment align;
  switch (alignment) {
    case 0:
      align = Qt::AlignLeft;
      break;
    case 1:
      align = Qt::AlignCenter;
      break;
    case 2:
      align = Qt::AlignRight;
      break;
    default:
      align = Qt::AlignLeft;
  }
   ((QLabel *)m_widget)->setAlignment(align);
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
  m_text = text;
  int size;
  if (m_fontSize >= QUTE_XXLARGE)
    size = 7;
  else if (m_fontSize >= QUTE_XLARGE)
    size = 6;
  else if (m_fontSize >= QUTE_LARGE)
    size = 5;
  else if (m_fontSize >= QUTE_MEDIUM)
    size = 4;
  else if (m_fontSize >= QUTE_SMALL)
    size = 3;
  else if (m_fontSize >= QUTE_XSMALL)
    size = 2;
  else
    size = 1;
  text.prepend("<font face=\"" + m_font + "\" size=\"" + QString::number(size) + "\">");
  text.append("</font>");
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
  switch (((QuteLabel *)m_widget)->alignment()) {
    case Qt::AlignLeft:
      alignment = "left";
      break;
    case Qt::AlignCenter:
      alignment = "center";
      break;
    case Qt::AlignRight:
      alignment = "right";
      break;
      //Another possibility is Qt::AlignJustify
    default:
      alignment = "left";
  }
  line += alignment + " ";
  line += "\"" + m_font + "\" " + QString::number(m_fontSize) + " ";
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
  line += m_text;
  qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
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
  text->setText(m_text);
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
  label = new QLabel(dialog);
  label->setText("Font");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
  font = new QFontComboBox(dialog);
  font->setCurrentFont(QFont(m_font));
  layout->addWidget(font, 6, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Font Size");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);
  fontSize = new QComboBox(dialog);
  fontSize->addItem("XX-Small", QVariant((int) QUTE_XXSMALL));
  fontSize->addItem("X-Small", QVariant((int) QUTE_XSMALL));
  fontSize->addItem("Small", QVariant((int) QUTE_SMALL));
  fontSize->addItem("Medium", QVariant((int) QUTE_MEDIUM));
  fontSize->addItem("Large", QVariant((int) QUTE_LARGE));
  fontSize->addItem("X-Large", QVariant((int) QUTE_XLARGE));
  fontSize->addItem("XX-Large", QVariant((int) QUTE_XXLARGE));
  int i = m_fontSize;
  int index = -1;
  while (i > 0 and index == -1) {
    index = fontSize->findData(i);
    i--;
  }
  if (index == -1)
    index = 0;
  fontSize->setCurrentIndex(index);
  layout->addWidget(fontSize,7, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Alignment");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 7, 2, Qt::AlignRight|Qt::AlignVCenter);
  alignment = new QComboBox(dialog);
  alignment->addItem("Left");
  alignment->addItem("Center");
  alignment->addItem("Right");
  int align;
  switch (((QLabel *)m_widget)->alignment()) {
    case Qt::AlignLeft:
      align = 0;
      break;
    case Qt::AlignCenter:
      align = 1;
      break;
    case Qt::AlignRight:
      align = 2;
      break;
    default:
      align = 0;
  }
  alignment->setCurrentIndex(align);
  layout->addWidget(alignment,7, 3, Qt::AlignLeft|Qt::AlignVCenter);
  connect(bgColor, SIGNAL(released()), this, SLOT(selectBgColor()));
}

void QuteText::applyProperties()
{
  m_font = font->currentFont().family();
  m_fontSize = fontSize->itemData(fontSize->currentIndex()).toInt();
//   ((QuteLabel *)m_widget)->setText(text->text());
  setText(text->text());
  ((QuteLabel *)m_widget)->setAutoFillBackground(bg->isChecked());
  ((QuteLabel *)m_widget)->setFrameShape(border->isChecked()?  QFrame::Box : QFrame::NoFrame);
  setAlignment(alignment->currentIndex());
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

