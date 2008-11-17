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
#include "qutecheckbox.h"

QuteCheckBox::QuteCheckBox(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QCheckBox(this);
//   m_filename = "/";
//   m_type = "event";
//   ((QPushButton *)m_widget)->setIcon(icon);
//   connect((QPushButton *)m_widget, SIGNAL(released()), this, SLOT(buttonReleased()));
}

QuteCheckBox::~QuteCheckBox()
{
}

void QuteCheckBox::setValue(double value)
{
  // value is 1 is checked, 0 if not
  ((QCheckBox *)m_widget)->setChecked(value == 1);
}

double QuteCheckBox::getValue()
{
  return (((QCheckBox *)m_widget)->isChecked()? 1.0:0.0);
}

QString QuteCheckBox::getWidgetLine()
{
  QString line = "ioCheckbox {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += (((QCheckBox *)m_widget)->isChecked()? QString("on"):QString("off") + " ");
  line += m_name;
  qDebug("QuteText::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

// void QuteCheckBox::applyProperties()
// {
//   setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
//   setType(typeComboBox->currentText());
//   QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
// }

// void QuteCheckBox::contextMenuEvent(QContextMenuEvent* event)
// {
//   QuteWidget::contextMenuEvent(event);
// }
//
// void QuteCheckBox::createPropertiesDialog()
// {
//   QuteWidget::createPropertiesDialog();
//
//   QLabel *label = new QLabel(dialog);
//   label->setText("Type");
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
//
//   label = new QLabel(dialog);
//   label->setText("Value");
//   label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
//   layout->addWidget(label, 4, 2, Qt::AlignRight|Qt::AlignVCenter);
// //   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
//   valueBox = new QDoubleSpinBox(dialog);
//   valueBox->setDecimals(6);
//   valueBox->setRange(-99999.0, 99999.0);
//   valueBox->setValue(m_value);
//   layout->addWidget(valueBox, 4, 3, Qt::AlignLeft|Qt::AlignVCenter);
//   label = new QLabel(dialog);
//   label->setText("Text:");
//   label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
//   layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
//   text = new QLineEdit(dialog);
// //   text->setText(((QuteLabel *)m_widget)->toPlainText());
//   text->setText(((QPushButton *)m_widget)->text());
//   layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
//   text->setMinimumWidth(320);
//   label = new QLabel(dialog);
//   label->setText("Image:");
//   label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
//   layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
//   filenameLineEdit = new QLineEdit(dialog);
// //   text->setText(((QuteLabel *)m_widget)->toPlainText());
//   filenameLineEdit->setText(m_filename);
//   filenameLineEdit->setMinimumWidth(320);
//   layout->addWidget(filenameLineEdit, 6,1,1,2, Qt::AlignLeft|Qt::AlignVCenter);
//   QPushButton *browseButton = new QPushButton(dialog);
//   browseButton->setText("...");
//   layout->addWidget(browseButton, 6, 3, Qt::AlignCenter|Qt::AlignVCenter);
//   connect(browseButton, SIGNAL(released()), this, SLOT(browseFile()));
//
//   label = new QLabel(dialog);
// //   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
//   label->setText("Event:");
//   label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
//   layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);
//   line = new QLineEdit(dialog);
// //   text->setText(((QuteLabel *)m_widget)->toPlainText());
//   line->setText(m_eventLine);
//   layout->addWidget(line, 7,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
//   line->setMinimumWidth(320);
// }

// void QuteCheckBox::setWidgetLine(QString line)
// {
//   QuteWidget::setWidgetLine(line);
// }

// void QuteCheckBox::setType(QString type)
// {
// //   if (m_type == type)
// //     return;
//   m_type = type;
//   if (m_type == "event" or m_type == "value") {
//     icon = QIcon();
//     ((QPushButton *)m_widget)->setIcon(icon);
//   }
//   else if (m_type == "pictevent" or m_type == "pictvalue" or m_type == "pict") {
//     icon = QIcon(QPixmap(m_filename));
//     ((QPushButton *)m_widget)->setIcon(icon);
//     ((QPushButton *)m_widget)->setIconSize(QSize(width(),height()));
//   }
//   else {
//     qDebug("Warning! QuteCheckBox::setType() unrecognized type");
//   }
// }
//
// void QuteCheckBox::setText(QString text)
// {
//   //TODO use proper character symbol
// //   text = text.replace("Â", "\n");
//   ((QPushButton *)m_widget)->setText(text);
// }
//
// void QuteCheckBox::setFilename(QString filename)
// {
//   m_filename = filename;
// }
//
// void QuteCheckBox::setEventLine(QString eventLine)
// {
//   while (eventLine.size() > 0 and eventLine[0] == ' ') {
//     qDebug("remove");
//     eventLine.remove(0,1); //remove all spaces at the beginning. This is needed for event queue lines
//   }
//   m_eventLine = eventLine;
// }

// void QuteCheckBox::popUpMenu(QPoint pos)
// {
//   QuteWidget::popUpMenu(pos);
// }
//
// void QuteCheckBox::buttonReleased()
// {
//   // Only produce events for event types
//   if (m_type == "event" or m_type == "pictevent")
//     emit(queueEvent(m_eventLine));
// }
//
// void QuteCheckBox::browseFile()
// {
//   qDebug("QuteCheckBox::browseFile()");
//   QString file =  QFileDialog::getOpenFileName(this,tr("Select File"));
//   if (file!="") {
//     filenameLineEdit->setText(file);
//   }
// }
