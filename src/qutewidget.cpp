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

#include "qutewidget.h"
#include "widgetpanel.h"

#include <QSlider>


QuteWidget::QuteWidget(QWidget *parent/*, widgetType type*/):
    QWidget(parent)/*, m_type(type)*/
{
  propertiesAct = new QAction(/*QIcon(":/images/gtk-new.png"),*/ tr("&Properties"), this);
//   propertiesAct->setShortcut(tr("Alt+P"));
  this->setWindowFlags(Qt::WindowStaysOnTopHint);
//  canFocus(false);
  propertiesAct->setStatusTip(tr("Open widget properties"));
  connect(propertiesAct, SIGNAL(triggered()), this, SLOT(openProperties()));

//   deleteAct = new QAction(/*QIcon(":/images/gtk-new.png"),*/ tr("Delete"), this);
//   deleteAct->setStatusTip(tr("Delete this widget"));
//   connect(deleteAct, SIGNAL(triggered()), this, SLOT(deleteWidget()));
  m_name2 = "";
  m_value = 0.0;
  m_value2 = 0.0;

  this->setMinimumSize(10,10);

  m_uuid = QUuid::createUuid().toString();
}


QuteWidget::~QuteWidget()
{
}

void QuteWidget::initFromXml(QString xmlText)
{
  qDebug() << "QuteWidget::initFromXml" << xmlText;

  QDomDocument doc;
  if (!doc.setContent(xmlText)) {
    qDebug() << "QuteWidget::initFromXml: Error parsing xml";
    return;
  }
  QDomElement e = doc.firstChildElement("objectName");
  if (e.isNull()) {
    qDebug() << "QuteWidget::initFromXml: Expecting objectName element";
    return;
  }
  else {
    m_name = e.nodeValue();
  }
  int posx, posy, w, h;
  e = doc.firstChildElement("x");
  if (e.isNull()) {
    qDebug() << "QuteWidget::initFromXml: Expecting x element";
    return;
  }
  else {
    posx = e.nodeValue().toInt();
  }
  e = doc.firstChildElement("y");
  if (e.isNull()) {
    qDebug() << "QuteWidget::initFromXml: Expecting y element";
    return;
  }
  else {
    posy = e.nodeValue().toInt();
  }
  e = doc.firstChildElement("width");
  if (e.isNull()) {
    qDebug() << "QuteWidget::initFromXml: Expecting width element";
    return;
  }
  else {
    w = e.nodeValue().toInt();
  }
  e = doc.firstChildElement("height");
  if (e.isNull()) {
    qDebug() << "QuteWidget::initFromXml: Expecting height element";
    return;
  }
  else {
    h = e.nodeValue().toInt();
  }
  setWidgetGeometry(posx, posy, w, h);
  e = doc.firstChildElement("uuid");
  if (e.isNull()) {
    qDebug() << "QuteWidget::initFromXml: Expecting eventLine element";
    return;
  }
  else {
    m_uuid = e.nodeValue();
  }

//   s.writeStartElement("bsbObject");
//   s.writeAttribute("type", getWidgetType());
//   if (getWidgetType() == "BSBKnob" or getWidgetType() == "BSBXYController")
//     s.writeAttribute("version", "2");  // Only for compatibility with blue (absolute values)
//
}

void QuteWidget::setWidgetLine(QString line)
{
  m_line = line;
}

void QuteWidget::setChannelName(QString name)
{
  m_name = name;
  m_name.replace("\"", "'"); // Quotes are not allowed
  if (m_name.startsWith('$'))
    m_name.remove(0,1);  // $ symbol is reserved for identifying string channels
  mutex.lock();
  if (name != "")
    m_widget->setObjectName(name);
  mutex.unlock();
//   qDebug("QuteWidget::setChannelName %s", m_name.toStdString().c_str());
}

void QuteWidget::setWidgetGeometry(int x, int y, int w, int h)
{
//   qDebug("QuteWidget::setWidgetGeometry %i %i %i %i",x,y,w,h );
//   m_widget->setFixedSize(w,h);
  int yoff = 20;
  this->setGeometry(QRect(x,y+yoff,w,h));
  m_widget->setGeometry(QRect(0,0,w,h));
  this->markChanged();
}

void QuteWidget::setRange(int /*min*/, int /*max*/)
{
  qDebug("QuteWidget::setRange not implemented for widget type");
}

void QuteWidget::setValue(double /*value*/)
{
//   mutex.lock();
//   mutex.unlock();
}

void QuteWidget::setValue2(double /*value*/)
{
}

void QuteWidget::setValue(QString /*value*/)
{
}

void QuteWidget::setResolution(double resolution)
{
  m_resolution = resolution;
}

void QuteWidget::setChecked(bool /*checked*/)
{
  qDebug("QuteWidget::setChecked not implemented for widget type");
}

QString QuteWidget::getChannelName()
{
  return m_name;
}

QString QuteWidget::getChannel2Name()
{
  return m_name2;
}

QString QuteWidget::getWidgetLine()
{
  return m_line;
}

QString QuteWidget::getCabbageLine()
{
  //Widgets return empty strings when not supported
  return QString("");
}

void QuteWidget::createXmlWriter(QXmlStreamWriter &s)
{
  s.writeStartElement("bsbObject");
  s.writeAttribute("type", getWidgetType());
  if (getWidgetType() == "BSBKnob" or getWidgetType() == "BSBXYController")
    s.writeAttribute("version", "2");  // Only for compatibility with blue (absolute values)

  s.writeTextElement("objectName", m_name);
  s.writeTextElement("x", QString::number(x()));
  s.writeTextElement("y", QString::number(y()));
  s.writeTextElement("width", QString::number(width()));
  s.writeTextElement("height", QString::number(height()));
  s.writeTextElement("uuid", m_uuid);
}

// QString QuteWidget::getWidgetXmlText()
// {
//   createXmlWriter();
//   return xmlText;
// }

double QuteWidget::getValue()
{
  return 0.0;
}

double QuteWidget::getValue2()
{
#ifdef DEBUG
  qDebug("QuteWidget::getValue2 not implemented for widget type");
#endif
  return 0.0;
}

double QuteWidget::getResolution()
{
  return m_resolution;
}

QString QuteWidget::getStringValue()
{
#ifdef DEBUG
  qDebug("QuteWidget::getValue for QString not implemented for widget type");
#endif
  return QString("");
}

QString QuteWidget::getCsladspaLine()
{
  //Widgets return empty strings when not supported
  return QString("");
}

void QuteWidget::markChanged()
{
  emit widgetChanged(this);
}

void QuteWidget::canFocus(bool can)
{
  if (can) {
    this->setFocusPolicy(Qt::StrongFocus);
    m_widget->setFocusPolicy(Qt::StrongFocus);
  }
  else {
    this->setFocusPolicy(Qt::NoFocus);
    m_widget->setFocusPolicy(Qt::NoFocus);
  }
}

void QuteWidget::contextMenuEvent(QContextMenuEvent *event)
{
  popUpMenu(event->globalPos());
}

void QuteWidget::mousePressEvent(QMouseEvent *event)
{
//   qDebug("QuteWidget::mousePressEvent");
  QWidget::mousePressEvent(event);
}

void QuteWidget::popUpMenu(QPoint pos)
{
  QMenu menu(this);
  menu.addAction(propertiesAct);
  menu.addSeparator();

  QList<QAction *> actionList = getParentActionList();

  for (int i = 0; i < actionList.size(); i++) {
    menu.addAction(actionList[i]);
  }

//   menu.addSeparator();
//   menu.addAction(deleteAct);

  menu.exec(pos);
}

void QuteWidget::openProperties()
{
  createPropertiesDialog();

  connect(acceptButton, SIGNAL(released()), dialog, SLOT(accept()));
  connect(dialog, SIGNAL(accepted()), this, SLOT(apply()));
  connect(applyButton, SIGNAL(released()), this, SLOT(apply()));
  connect(cancelButton, SIGNAL(released()), dialog, SLOT(close()));
  dialog->exec();
}

void QuteWidget::deleteWidget()
{
//   qDebug("QuteWidget::deleteWidget()");
  emit(deleteThisWidget(this));
}

void QuteWidget::valueChanged(int /*value*/)
{
  double doubleValue = getValue(); // int value is not always the real value
  QPair<QString, double> channelValue;
  channelValue = QPair<QString, double>(m_name, doubleValue);
  emit newValue(channelValue);
}

void QuteWidget::valueChanged(double value)
{
//   double doubleValue = getValue();
  QPair<QString, double> channelValue;
  channelValue = QPair<QString, double>(m_name, value);
  emit newValue(channelValue);
}

void QuteWidget::value2Changed(double value)
{
  QPair<QString, double> channelValue;
  channelValue = QPair<QString, double>(m_name2, value);
  emit newValue(channelValue);
}

void QuteWidget::createPropertiesDialog()
{
#ifdef MACOSX
  dialog = new QDialog(static_cast<QWidget *>(this->parent()), Qt::WindowStaysOnTopHint);  // On OS X the widget panel may com in front of properties
#else
  dialog = new QDialog(static_cast<QWidget *>(this->parent()));
#endif
  dialog->resize(300, 300);
  dialog->setModal(true);
  layout = new QGridLayout(dialog);
  QLabel *label = new QLabel(dialog);
  label->setText("X =");
  layout->addWidget(label, 0, 0, Qt::AlignRight|Qt::AlignVCenter);
  xSpinBox = new QSpinBox(dialog);
  xSpinBox->setMaximum(9999);
  xSpinBox->setValue(this->x());
  layout->addWidget(xSpinBox, 0, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Y =");
  layout->addWidget(label, 0, 2, Qt::AlignRight|Qt::AlignVCenter);
  ySpinBox = new QSpinBox(dialog);
  ySpinBox->setMaximum(9999);
  ySpinBox->setValue(this->y());
  layout->addWidget(ySpinBox, 0, 3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText(tr("Width ="));
  layout->addWidget(label, 1, 0, Qt::AlignRight|Qt::AlignVCenter);
  wSpinBox = new QSpinBox(dialog);
  wSpinBox->setMaximum(9999);
  wSpinBox->setValue(this->width());
  layout->addWidget(wSpinBox, 1, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText(tr("Height ="));
  layout->addWidget(label, 1, 2, Qt::AlignRight|Qt::AlignVCenter);
  hSpinBox = new QSpinBox(dialog);
  hSpinBox->setMaximum(9999);
  hSpinBox->setValue(this->height());
  layout->addWidget(hSpinBox, 1, 3, Qt::AlignLeft|Qt::AlignVCenter);
  channelLabel = new QLabel(dialog);
  channelLabel->setText(tr("Channel name ="));
  channelLabel->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(channelLabel, 3, 0, Qt::AlignLeft|Qt::AlignVCenter);
  nameLineEdit = new QLineEdit(getChannelName(), dialog);
  nameLineEdit->setFocus(Qt::OtherFocusReason);
  nameLineEdit->selectAll();
  layout->addWidget(nameLineEdit, 3, 1, Qt::AlignLeft|Qt::AlignVCenter);
  acceptButton = new QPushButton(tr("Ok"));
  layout->addWidget(acceptButton, 9, 3, Qt::AlignCenter|Qt::AlignVCenter);
  applyButton = new QPushButton(tr("Apply"));
  layout->addWidget(applyButton, 9, 1, Qt::AlignCenter|Qt::AlignVCenter);
  cancelButton = new QPushButton(tr("Cancel"));
  layout->addWidget(cancelButton, 9, 2, Qt::AlignCenter|Qt::AlignVCenter);
}

void QuteWidget::applyProperties()
{
  setChannelName(nameLineEdit->text());
  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
  emit(widgetChanged(this));
}

QList<QAction *> QuteWidget::getParentActionList()
{
  QList<QAction *> actionList;
  // A bit of a kludge... Must get the Widget Panel, which is the parent to the widget which
  // holds the actual QuteWidgets
//   qDebug() << parent() << parent()->parent();
  WidgetPanel *panel = static_cast<LayoutWidget *>(parent())->panel();
  actionList.append(panel->copyAct);
  actionList.append(panel->pasteAct);
  actionList.append(panel->cutAct);
  actionList.append(panel->duplicateAct);
  actionList.append(panel->deleteAct);
  return actionList;
}

void QuteWidget::apply()
{
  applyProperties();
}
