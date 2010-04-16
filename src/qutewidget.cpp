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
#include "widgetlayout.h"


QuteWidget::QuteWidget(QWidget *parent):
    QWidget(parent)
{
  propertiesAct = new QAction(tr("&Properties"), this);
  propertiesAct->setStatusTip(tr("Open widget properties"));
  connect(propertiesAct, SIGNAL(triggered()), this, SLOT(openProperties()));

  m_value = 0.0;
  m_value2 = 0.0;

  this->setMinimumSize(2,2);
  this->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels

  setProperty("QCS_uuid", QUuid::createUuid().toString());
}


QuteWidget::~QuteWidget()
{
}

void QuteWidget::setWidgetLine(QString line)
{
  m_line = line;
}

void QuteWidget::setChannelName(QString name)
{
  name.replace("\"", "'"); // Quotes are not allowed
  if (name.startsWith('$')) {
    name.remove(0,1);  // $ symbol is reserved for identifying string channels
  }
  if (name != "") {
    mutex.lock();
    m_widget->setObjectName(name);
    mutex.unlock();
  }
//   qDebug("QuteWidget::setChannelName %s", m_name.toStdString().c_str());
}

void QuteWidget::setWidgetGeometry(int x, int y, int w, int h)
{
//  qDebug("QuteWidget::setWidgetGeometry %i %i %i %i",x,y,w,h );
  this->setGeometry(QRect(x,y,w,h));
  m_widget->setGeometry(QRect(0,0,w,h));
  this->markChanged();
}

//void QuteWidget::setRange(int /*min*/, int /*max*/)
//{
//  qDebug("QuteWidget::setRange not implemented for widget type");
//}
//
//void QuteWidget::setChecked(bool /*checked*/)
//{
//  qDebug("QuteWidget::setChecked not implemented for widget type");
//}

QString QuteWidget::getChannelName()
{
  return property("QCS_objectName").toString();
}

QString QuteWidget::getChannel2Name()
{
  return property("QCS_objectName2").toString();
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

  s.writeAttribute("version", "2");  // Only for compatibility with blue (absolute values)

  s.writeTextElement("objectName", property("QCS_objectName").toString());
  s.writeTextElement("x", QString::number(x()));
  s.writeTextElement("y", QString::number(y()));
  s.writeTextElement("width", QString::number(width()));
  s.writeTextElement("height", QString::number(height()));
  s.writeTextElement("uuid", property("QCS_uuid").toString());
}

double QuteWidget::getValue()
{
  return 0.0;
}

double QuteWidget::getValue2()
{
  return 0.0;
}

QString QuteWidget::getStringValue()
{
  return QString("");
}

QString QuteWidget::getCsladspaLine()
{
  //Widgets return empty strings when not supported
  return QString("");
}

QString QuteWidget::getUuid()
{
  if (property("QCS_uuid").isValid())
    return property("QCS_uuid").toString();
  else
    return QString();
}

void QuteWidget::applyInternalProperties()
{
//  qDebug() << "QuteWidget::applyInternalProperties()";
  int x,y,width, height;
  x = property("QCS_x").toInt();
  y = property("QCS_y").toInt();
  width = property("QCS_width").toInt();
  height = property("QCS_height").toInt();
  setWidgetGeometry(x,y,width, height);
  setChannelName(property("QCS_objectName").toString());
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

//void QuteWidget::mousePressEvent(QMouseEvent *event)
//{
////   qDebug("QuteWidget::mousePressEvent");
//  emit mouseReleased();
//  QWidget::mouseReleaseEvent(event);
//}

//void QuteWidget::mouseReleaseEvent(QMouseEvent *event)
//{
////   qDebug("QuteWidget::mousePressEvent");
//  emit mouseReleased();
//  QWidget::mouseReleaseEvent(event);
//}

void QuteWidget::popUpMenu(QPoint pos)
{
  qDebug() << "QuteWidget::popUpMenu";
  QMenu menu(this);
  menu.addAction(propertiesAct);
  menu.addSeparator();

  QList<QAction *> actionList = getParentActionList();

  for (int i = 0; i < actionList.size(); i++) {
    menu.addAction(actionList[i]);
  }
  WidgetLayout *layout = static_cast<WidgetLayout *>(this->parentWidget());
  layout->setCurrentPosition(layout->mapFromGlobal(pos));

  menu.addSeparator();
  QMenu createMenu(tr("Create New", "Menu name in widget right-click menu"),&menu);
  createMenu.addAction(layout->createSliderAct);
  createMenu.addAction(layout->createLabelAct);
  createMenu.addAction(layout->createDisplayAct);
  createMenu.addAction(layout->createScrollNumberAct);
  createMenu.addAction(layout->createLineEditAct);
  createMenu.addAction(layout->createSpinBoxAct);
  createMenu.addAction(layout->createButtonAct);
  createMenu.addAction(layout->createKnobAct);
  createMenu.addAction(layout->createCheckBoxAct);
  createMenu.addAction(layout->createMenuAct);
  createMenu.addAction(layout->createMeterAct);
  createMenu.addAction(layout->createConsoleAct);
  createMenu.addAction(layout->createGraphAct);
  createMenu.addAction(layout->createScopeAct);

  menu.addMenu(&createMenu);

  menu.addSeparator();
  menu.addAction(layout->storePresetAct);
  menu.addAction(layout->newPresetAct);
  menu.addAction(layout->recallPresetAct);
  menu.addSeparator();

  QMenu presetMenu(tr("Presets"),&menu);

  QList<int> list = layout->getPresetNums();
  for (int i = 0; i < list.size(); i++) {
    QAction *act = new QAction(layout->getPresetName(list[i]), &menu);
    act->setData(i);
    connect(act, SIGNAL(triggered()), layout, SLOT(loadPresetFromAction()));
    presetMenu.addAction(act);
  }
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
  if (dialog->result() != QDialog::Accepted) {
    qDebug() << "QuteWidget::openProperties() dialog not accepted";
  }
//  dialog->deleteLater();
  parentWidget()->setFocus(Qt::OtherFocusReason); // For some reason focus is grabbed away from the layout, but this doesn't solve the problem...
}

void QuteWidget::deleteWidget()
{
//   qDebug("QuteWidget::deleteWidget()");
  emit(deleteThisWidget(this));
}

void QuteWidget::valueChanged(double value)
{
  QPair<QString, double> channelValue;
  channelValue = QPair<QString, double>(property("QCS_objectName").toString(), value);
  emit newValue(channelValue);
}

void QuteWidget::value2Changed(double value)
{
  QPair<QString, double> channelValue;
  channelValue = QPair<QString, double>(property("QCS_objectName2").toString(), value);
  emit newValue(channelValue);
}

void QuteWidget::createPropertiesDialog()
{
  qDebug() << "QuteWidget::createPropertiesDialog()---Dynamic Properties:\n" << dynamicPropertyNames ();
  dialog = new QDialog(this);
  dialog->resize(300, 300);
//  dialog->setModal(true);
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
  layout->addWidget(acceptButton, 15, 3, Qt::AlignCenter|Qt::AlignVCenter);
  applyButton = new QPushButton(tr("Apply"));
  layout->addWidget(applyButton, 15, 1, Qt::AlignCenter|Qt::AlignVCenter);
  cancelButton = new QPushButton(tr("Cancel"));
  layout->addWidget(cancelButton, 15, 2, Qt::AlignCenter|Qt::AlignVCenter);
}

void QuteWidget::applyProperties()
{
  qDebug() << "QuteWidget::applyProperties()";
  setProperty("QCS_objectName", nameLineEdit->text());
  setProperty("QCS_x", xSpinBox->value());
  setProperty("QCS_y",ySpinBox->value());
  setProperty("QCS_width", wSpinBox->value());
  setProperty("QCS_height", hSpinBox->value());
  applyInternalProperties();
//  setChannelName(nameLineEdit->text());
//  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());

//  this->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  emit(widgetChanged(this));
  emit propertiesAccepted();
  parentWidget()->setFocus(Qt::PopupFocusReason); // For some reason focus is grabbed away from the layout
}

QList<QAction *> QuteWidget::getParentActionList()
{
  QList<QAction *> actionList;
  // A bit of a kludge... Must get the Widget Panel, which is the parent to the widget which
  // holds the actual QuteWidgets
  WidgetLayout *layout = static_cast<WidgetLayout *>(this->parentWidget());
  // FIXME put cut/copy/paste actions in menu
//  actionList.append(layout->copyAct);
//  actionList.append(layout->pasteAct);
//  actionList.append(layout->cutAct);
  actionList.append(layout->deleteAct);
  actionList.append(layout->duplicateAct);
  actionList.append(layout->alignLeftAct);
  actionList.append(layout->alignRightAct);
  actionList.append(layout->alignTopAct);
  actionList.append(layout->alignBottomAct);
  actionList.append(layout->sendToBackAct);
  actionList.append(layout->distributeHorizontalAct);
  actionList.append(layout->distributeVerticalAct);
  // FIXME put edit action in menu
//  actionList.append(layout->editAct);
  return actionList;
}

//QList<QAction *> QuteWidget::getPresetActionList()
//{
//}

void QuteWidget::apply()
{
  applyProperties();
}
