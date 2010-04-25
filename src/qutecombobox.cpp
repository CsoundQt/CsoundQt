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

#include "qutecombobox.h"

QuteComboBox::QuteComboBox(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new QComboBox(this);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
//  canFocus(false);
//   connect((QComboBox *)m_widget, SIGNAL(released()), this, SLOT(buttonReleased()));
//  connect(static_cast<QComboBox *>(m_widget), SIGNAL(currentIndexChanged(int)), this, SLOT(indexChanged(int)));
  setProperty("QCS_selectedIndex", 0);
  setProperty("QCS_randomizable", false);
}

QuteComboBox::~QuteComboBox()
{
}

void QuteComboBox::setValue(double value)
{
//   qDebug("QuteComboBox::setValue %i", (int) value);
  // setValue sets the current index of the ioMenu
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForWrite();
#endif
  static_cast<QComboBox *>(m_widget)->setCurrentIndex((int) value);
//  m_value = static_cast<QComboBox *>(m_widget)->currentIndex();  //This confines the value to valid indices
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
}

double QuteComboBox::getValue()
{
  // Returns the user data for the current index
  QComboBox *menu = static_cast<QComboBox *>(m_widget);
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  double value = menu->itemData(menu->currentIndex(), Qt::UserRole).toDouble();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return  value;
}

//void QuteComboBox::setSize(int size)
//{
//  m_size = size;
//}

QString QuteComboBox::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  QString line = "ioMenu {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(((QComboBox *)m_widget)->currentIndex()) + " ";
  line += "303 ";
  line += "\"" + itemList() + "\" ";
  line += property("QCS_objectName").toString();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return line;
}

QString QuteComboBox::getCabbageLine()
{
//   combobox channel("chanName"),  pos(Top, Left), size(Width, Height), value(val), items("item1", "item2", ...)
  QString line = "combobox channel(\"" + property("QCS_objectName").toString() + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "value(" + QString::number(((QComboBox *)m_widget)->currentIndex()) + "), ";
  line += "items(\"" + itemList() + "\")";
  return line;
}

QString QuteComboBox::getWidgetXmlText()
{
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif

  s.writeStartElement("bsbDropdownItemList");
  for (int i = 0; i < static_cast<QComboBox *>(m_widget)->count(); i++) {
    s.writeStartElement("bsbDropdownItem");
    s.writeTextElement("name", static_cast<QComboBox *>(m_widget)->itemText(i));
    s.writeTextElement("value", QString::number(static_cast<QComboBox *>(m_widget)->itemData(i).toInt()) );
    s.writeTextElement("stringvalue", stringValues[i]);
    s.writeEndElement();
  }
  s.writeEndElement();
  s.writeTextElement("selectedIndex", QString::number(((QComboBox *)m_widget)->currentIndex()));
  s.writeTextElement("randomizable",  property("QCS_randomizable").toBool() ? "true" : "false");
  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
  return xmlText;
}

QString QuteComboBox::getWidgetType()
{
  return QString("BSBDropdown");
}

QString QuteComboBox::itemList()
{
  // For old format
  QString list = "";
  for (int i = 0; i < static_cast<QComboBox *>(m_widget)->count(); i++) {
    list += static_cast<QComboBox *>(m_widget)->itemText(i) + ",";
  }
  list.chop(1); //remove last comma
  return list;
}

void QuteComboBox::setText(QString text)
{
  // For old format
  clearItems();
  QStringList items = text.split(",");
  int counter = 0;
  foreach (QString item, items) {
    addItem(item, counter++, "");
  }
}

void QuteComboBox::clearItems()
{
  static_cast<QComboBox *>(m_widget)->clear();
}

void QuteComboBox::addItem(QString text, double value, QString stringvalue)
{
  static_cast<QComboBox *>(m_widget)->addItem(text, value);
  stringValues.append(stringvalue);
}

void QuteComboBox::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}

void QuteComboBox::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteComboBox::applyInternalProperties()";
  static_cast<QComboBox *>(m_widget)->setCurrentIndex(property("QCS_selectedIndex").toInt());
}

//void QuteComboBox::contextMenuEvent(QContextMenuEvent* event)
//{
//  qDebug("QuteComboBox::contextMenuEvent");
//  QuteWidget::contextMenuEvent(event);
//}

void QuteComboBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForRead();
#endif
  dialog->setWindowTitle("Menu");
  QLabel *label = new QLabel(dialog);

  label = new QLabel(dialog);
  label->setText("Items (separated by commas):");
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QLineEdit(dialog);
  text->setText(itemList());
  layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
}

void QuteComboBox::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.lockForWrite();
#endif
  setText(text->text());
#ifdef  USE_WIDGET_MUTEX
  widgetMutex.unlock();
#endif
//  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}


//void QuteComboBox::indexChanged(int value)
//{
//  QuteWidget::valueChanged((double) value);
//}
