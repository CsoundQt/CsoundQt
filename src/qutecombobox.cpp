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
  connect(static_cast<QComboBox *>(m_widget), SIGNAL(currentIndexChanged(int)), this, SLOT(indexChanged(int)));
  setProperty("QCS_selectedIndex", 0);
  setProperty("QCS_randomizable", false);
}

QuteComboBox::~QuteComboBox()
{
}

QString QuteComboBox::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ioMenu {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += QString::number(((QComboBox *)m_widget)->currentIndex()) + " ";
  line += "303 ";
  line += "\"" + itemList() + "\" ";
  line += property("QCS_objectName").toString();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
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
  widgetLock.lockForRead();
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
  widgetLock.unlock();
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
  widgetLock.lockForWrite();
  clearItems();
  QStringList items = text.split(",");
  int counter = 0;
  foreach (QString item, items) {
    addItem(item, counter++, "");
  }
  widgetLock.unlock();
}

void QuteComboBox::clearItems()
{
  m_widget->blockSignals(true);
  static_cast<QComboBox *>(m_widget)->clear();
  m_widget->blockSignals(false);
}

void QuteComboBox::addItem(QString text, double value, QString stringvalue)
{
  m_widget->blockSignals(true);
  static_cast<QComboBox *>(m_widget)->addItem(text, value);
  stringValues.append(stringvalue);
  m_widget->blockSignals(false);
}

void QuteComboBox::refreshWidget()
{
  widgetLock.lockForRead();
  m_widget->blockSignals(true);
  static_cast<QComboBox *>(m_widget)->setCurrentIndex((int) m_value);
  m_widget->blockSignals(false);
  widgetLock.unlock();
}

void QuteComboBox::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
//  qDebug() << "QuteComboBox::applyInternalProperties()";
  setValue(property("QCS_selectedIndex").toInt());
}

void QuteComboBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Menu");
  QLabel *label = new QLabel(dialog);

  label = new QLabel(dialog);
  label->setText("Items (separated by commas):");
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QLineEdit(dialog);
  layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);

  widgetLock.lockForRead();
  text->setText(itemList());
  widgetLock.unlock();
}

void QuteComboBox::applyProperties()
{
  setText(text->text()); // This line can't be locked, as itlocks itself internally

//  widgetLock.lockForWrite();
//  widgetLock.unlock();
//  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}


void QuteComboBox::indexChanged(int value)
{
//  qDebug() << "QuteComboBox::indexChanged" << value;

  widgetLock.lockForRead();
  m_value = value;
  QPair<QString, double> channelValue(property("QCS_objectName").toString(), m_value);
  widgetLock.unlock();

  emit newValue(channelValue);
}
