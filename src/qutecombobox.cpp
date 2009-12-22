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
  connect(static_cast<QComboBox *>(m_widget), SIGNAL(currentIndexChanged(int)), this, SLOT(valueChanged(int)));
}

QuteComboBox::~QuteComboBox()
{
}

void QuteComboBox::loadFromXml(QString xmlText)
{
  initFromXml(xmlText);
  QDomDocument doc;
  if (!doc.setContent(xmlText)) {
    qDebug() << "QuteComboBox::loadFromXml: Error parsing xml";
    return;
  }
  QDomElement e = doc.firstChildElement("bsbDropdownItemList");
  if (e.isNull()) {
    qDebug() << "QuteComboBox::loadFromXml: Expecting bsbDropdownItemList element";
    return;
  }
  else {
    QDomElement e2 = doc.firstChildElement("bsbDropdownItem");
    while (!e2.isNull()) {
      QDomElement e3 = doc.firstChildElement("name");
      QDomElement e4 = doc.firstChildElement("value");
      static_cast<QComboBox *>(m_widget)->addItem(e3.nodeValue(), QVariant(e4.nodeValue().toInt()));
      // TODO: string values for item not implemented
      e2 = e2.nextSiblingElement("bsbDropdownItem");
    }
  }
  e = doc.firstChildElement("selectedIndex");
  if (e.isNull()) {
    qDebug() << "QuteComboBox::loadFromXml: Expecting selectedIndex element";
    return;
  }
  else {
    static_cast<QComboBox *>(m_widget)->setCurrentIndex(e.nodeValue().toInt());
  }
  e = doc.firstChildElement("randomizable");
  if (e.isNull()) {
    qDebug() << "QuteComboBox::loadFromXml: Expecting randomizable element";
    return;
  }
  else {
    qDebug() << "QuteComboBox::loadFromXml: randomizable not implemented";
  }
}

void QuteComboBox::setValue(double value)
{
//   qDebug("QuteComboBox::setValue %i", (int) value);
  // setValue sets the current index of the ioMenu
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  static_cast<QComboBox *>(m_widget)->setCurrentIndex((int) value);
  m_value = static_cast<QComboBox *>(m_widget)->currentIndex();  //This confines the value to valid indices
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

double QuteComboBox::getValue()
{
  // Returns the current index
  return (float) static_cast<QComboBox *>(m_widget)->currentIndex();
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
  line += "\"" + itemList() + "\" ";
  line += m_name;
  return line;
}

QString QuteComboBox::getCabbageLine()
{
//   combobox channel("chanName"),  pos(Top, Left), size(Width, Height), value(val), items("item1", "item2", ...)
  QString line = "combobox channel(\"" + m_name + "\"),  ";
  line += "pos(" + QString::number(x()) + ", " + QString::number(y()) + "), ";
  line += "size("+ QString::number(width()) +", "+ QString::number(height()) +"), ";
  line += "value(" + QString::number(((QComboBox *)m_widget)->currentIndex()) + "), ";
  line += "items(\"" + itemList() + "\")";
  return line;
}

QString QuteComboBox::getWidgetXmlText()
{
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);

  s.writeStartElement("bsbDropdownItemList");
  for (int i = 0; i < static_cast<QComboBox *>(m_widget)->count(); i++) {
    s.writeStartElement("bsbDropdownItem");
    s.writeTextElement("name", static_cast<QComboBox *>(m_widget)->itemText(i));
    s.writeTextElement("value", QString::number(i) );  //From blue. Only partly supported. Blue supports strings here
    s.writeEndElement();
  }
  s.writeEndElement();
  s.writeTextElement("selectedIndex", QString::number(((QComboBox *)m_widget)->currentIndex()));
  // These three come from blue, but they are not implemented here
  s.writeTextElement("randomizable", "");
   //These are not implemented in blue
   //TODO: add index offset
//    s.writeTextElement("indexoffset", "");
  s.writeEndElement();
  return xmlText;
}

QString QuteComboBox::getWidgetType()
{
  return QString("BSBDropdown");
}

void QuteComboBox::applyProperties()
{
  setText(text->text());
  //TODO set size for Menu widget according to value in widgetLine?
//   setSize
  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteComboBox::contextMenuEvent(QContextMenuEvent* event)
{
  qDebug("QuteComboBox::contextMenuEvent");
  QuteWidget::contextMenuEvent(event);
}

void QuteComboBox::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Menu");
  QLabel *label = new QLabel(dialog);
  //TODO add size selection for combo box

  label = new QLabel(dialog);
  label->setText("Items (separated by commas):");
  layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);
  text = new QLineEdit(dialog);
  text->setText(itemList());
  layout->addWidget(text, 5,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);
  text->setMinimumWidth(320);
}

void QuteComboBox::setText(QString text)
{
  static_cast<QComboBox *>(m_widget)->clear();
  QStringList items = text.split(",");
  foreach (QString item, items) {
    static_cast<QComboBox *>(m_widget)->addItem(item);
  }
}

QString QuteComboBox::itemList()
{
  QString list = "";
  for (int i = 0; i < static_cast<QComboBox *>(m_widget)->count(); i++) {
    list += static_cast<QComboBox *>(m_widget)->itemText(i) + ",";
  }
  list.chop(1); //remove last comma
  return list;
}

void QuteComboBox::popUpMenu(QPoint pos)
{
  QuteWidget::popUpMenu(pos);
}
