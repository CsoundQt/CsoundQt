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
#include "qutebutton.h"

QuteButton::QuteButton(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QPushButton(this);
  m_file = "/";
  connect((QPushButton *)m_widget, SIGNAL(released()), this, SLOT(buttonReleased()));
}


QuteButton::~QuteButton()
{
}

void QuteButton::setValue(double value)
{
  m_value = value;
}

double QuteButton::getValue()
{
  if ( ((QPushButton *)m_widget)->isDown() )
    return m_value;
  else
    return 0.0;
}

QString QuteButton::getWidgetLine()
{
  //TODO implement other types of buttons
  QString line = "ioButton {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += "event ";
  line +=  QString::number(m_value,'f', 6) + " ";
  line += "\"" + m_name + "\" ";
  line += "\"" + ((QPushButton *)m_widget)->text() + "\" ";
  line += "\"" + m_file + "\" ";
  line += m_eventLine;
  qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

void QuteButton::applyProperties()
{
  setEventLine(line->text());
  setText(text->text());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteButton::contextMenuEvent(QContextMenuEvent* event)
{
  QuteWidget::contextMenuEvent(event);
}

void QuteButton::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  QLabel *label = new QLabel(dialog);
  label->setText("Value");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 3, 2, Qt::AlignRight|Qt::AlignVCenter);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  valueBox = new QDoubleSpinBox(dialog);
  valueBox->setDecimals(6);
  valueBox->setRange(-99999.0, 99999.0);
  valueBox->setValue(m_value);
  layout->addWidget(valueBox, 3, 3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Text:");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QLineEdit(dialog);
//   text->setText(((QuteLabel *)m_widget)->toPlainText());
  text->setText(((QPushButton *)m_widget)->text());
  layout->addWidget(text, 4,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
  label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Event:");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  line = new QLineEdit(dialog);
//   text->setText(((QuteLabel *)m_widget)->toPlainText());
  line->setText(m_eventLine);
  layout->addWidget(line, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  line->setMinimumWidth(320);
}

// void QuteButton::setWidgetLine(QString line)
// {
//   QuteWidget::setWidgetLine(line);
// }

void QuteButton::setText(QString text)
{
  ((QPushButton *)m_widget)->setText(text);
}

void QuteButton::setEventLine(QString eventLine)
{
  while (eventLine.size() > 0 and eventLine[0] == ' ') {
    qDebug("reomve");
    eventLine.remove(0,1); //remove all spaces at the beginning. This is needed for event queue lines
  }
  m_eventLine = eventLine;
}

void QuteButton::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}

void QuteButton::buttonReleased()
{
  emit(queueEvent(m_eventLine));
}
