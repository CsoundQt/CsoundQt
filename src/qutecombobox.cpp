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
#include "qutecombobox.h"

QuteComboBox::QuteComboBox(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QComboBox(this);
//   ((QComboBox *)m_widget)->setIcon(icon);
//   connect((QComboBox *)m_widget, SIGNAL(released()), this, SLOT(buttonReleased()));
}

QuteComboBox::~QuteComboBox()
{
}

void QuteComboBox::setValue(double value)
{
  // setValue sets the current index of the ioMenu
  m_value = value;
}

double QuteComboBox::getValue()
{
  // Returns the current index
  if ( ((QComboBox *)m_widget)->currentIndex() )
    return m_value;
  else
    return 0.0;
}

void QuteComboBox::setSize(int size)
{
  m_size = size;
}

QString QuteComboBox::getWidgetLine()
{
  QString line = "ioMenu {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(((QComboBox *)m_widget)->currentIndex()) + " ";
  line += QString::number(m_size) + " ";
  line += "\"" + itemList() + "\"";
  return line;
}

void QuteComboBox::applyProperties()
{
  setText(text->text());
  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteComboBox::contextMenuEvent(QContextMenuEvent* event)
{
  QuteWidget::contextMenuEvent(event);
}

void QuteComboBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();

  QLabel *label = new QLabel(dialog);
//   label->setText("Size");
//   label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
//   layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
// //   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
//   typeComboBox = new QComboBox(dialog);
//   typeComboBox->addItem("event");
//   typeComboBox->addItem("value");
//   typeComboBox->addItem("pictevent");
//   typeComboBox->addItem("pictvalue");
//   typeComboBox->addItem("pict");
//   typeComboBox->setCurrentIndex(typeComboBox->findText(m_type));
//   layout->addWidget(typeComboBox, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);

  label = new QLabel(dialog);
  label->setText("Text:");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QLineEdit(dialog);
  text->setText(itemList());
  layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
}

void QuteComboBox::setText(QString text)
{

}

QString QuteComboBox::itemList()
{
  QString list = "";
  return list;
}

void QuteComboBox::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}
