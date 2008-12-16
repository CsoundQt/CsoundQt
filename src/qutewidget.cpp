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
#include "qutewidget.h"
#include "widgetpanel.h"

#include <QSlider>

QuteWidget::QuteWidget(QWidget *parent/*, widgetType type*/):
    QWidget(parent)/*, m_type(type)*/
{
  propertiesAct = new QAction(/*QIcon(":/images/gtk-new.png"),*/ tr("&Properties"), this);
  propertiesAct->setShortcut(tr("Alt+P"));
  propertiesAct->setStatusTip(tr("Open widget properties"));
  connect(propertiesAct, SIGNAL(triggered()), this, SLOT(openProperties()));

  deleteAct = new QAction(/*QIcon(":/images/gtk-new.png"),*/ tr("Delete"), this);
  deleteAct->setStatusTip(tr("Delete this widget"));
  connect(deleteAct, SIGNAL(triggered()), this, SLOT(deleteWidget()));
  m_name2 = "";

  this->setMinimumSize(10,10);
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
  m_name = name;
  if (m_name.startsWith('$'))
    m_name.remove(0,1);  // $ symbol is reserved for identifying string channels
  if (name != "")
    m_widget->setObjectName(name);
//   qDebug("QuteWidget::setChannelName %s", m_name.toStdString().c_str());
}

void QuteWidget::setWidgetGeometry(int x, int y, int w, int h)
{
//   qDebug("QuteWidget::setWidgetGeometry %i %i %i %i",x,y,w,h );
//   m_widget->setFixedSize(w,h);
  this->setGeometry(QRect(x,y,w,h));
  m_widget->setGeometry(QRect(0,0,w,h));
}

void QuteWidget::setRange(int /*min*/, int /*max*/)
{
  qDebug("QuteWidget::setRange not implemented for widget type");
}

void QuteWidget::setValue(double /*value*/)
{
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

QString QuteWidget::getStringValue()
{
#ifdef DEBUG
  qDebug("QuteWidget::getValue for QString not implemented for widget type");
#endif
  return QString("");
}

void QuteWidget::markChanged()
{
  emit widgetChanged(this);
}

void QuteWidget::contextMenuEvent(QContextMenuEvent *event)
{
  popUpMenu(event->globalPos());
}

void QuteWidget::popUpMenu(QPoint pos)
{
  QMenu menu(this);
  menu.addAction(propertiesAct);
  menu.addSeparator();

  QList<QAction *> actionList = getParentActionList();

//   foreach (QAction *action, actionList) {
//     menu.addAction(action);
//   }

  menu.addSeparator();
  menu.addAction(deleteAct);

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
  double doubleValue = getValue();
  QHash<QString, double> channelValue;
  channelValue.insert(m_name, doubleValue);
  emit newValue(channelValue);
}

void QuteWidget::createPropertiesDialog()
{
  dialog = new QDialog(this);
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
  label->setText("Width =");
  layout->addWidget(label, 1, 0, Qt::AlignRight|Qt::AlignVCenter);
  wSpinBox = new QSpinBox(dialog);
  wSpinBox->setMaximum(9999);
  wSpinBox->setValue(this->width());
  layout->addWidget(wSpinBox, 1, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Height =");
  layout->addWidget(label, 1, 2, Qt::AlignRight|Qt::AlignVCenter);
  hSpinBox = new QSpinBox(dialog);
  hSpinBox->setMaximum(9999);
  hSpinBox->setValue(this->height());
  layout->addWidget(hSpinBox, 1, 3, Qt::AlignLeft|Qt::AlignVCenter);
  channelLabel = new QLabel(dialog);
  channelLabel->setText("Channel name =");
  channelLabel->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(channelLabel, 3, 0, Qt::AlignLeft|Qt::AlignVCenter);
  nameLineEdit = new QLineEdit(getChannelName(), dialog);
  nameLineEdit->setFocus(Qt::OtherFocusReason);
  nameLineEdit->selectAll();
  layout->addWidget(nameLineEdit, 3, 1, Qt::AlignLeft|Qt::AlignVCenter);
  applyButton = new QPushButton(tr("Apply"));
  layout->addWidget(applyButton, 9, 1, Qt::AlignCenter|Qt::AlignVCenter);
  cancelButton = new QPushButton(tr("Cancel"));
  layout->addWidget(cancelButton, 9, 2, Qt::AlignCenter|Qt::AlignVCenter);
  acceptButton = new QPushButton(tr("Ok"));
  layout->addWidget(acceptButton, 9, 3, Qt::AlignCenter|Qt::AlignVCenter);
}

void QuteWidget::applyProperties()
{
  setChannelName(nameLineEdit->text());
  setWidgetGeometry(xSpinBox->value(), ySpinBox->value(), wSpinBox->value(), hSpinBox->value());
//   qDebug("QuteWidget::applyProperties() Not fully implemented yet.");
  emit(widgetChanged(this));
}

QList<QAction *> QuteWidget::getParentActionList()
{
  QList<QAction *> actionList;
  actionList.append(static_cast<WidgetPanel *>(parent())->copyAct);
  actionList.append(static_cast<WidgetPanel *>(parent())->pasteAct);
  actionList.append(static_cast<WidgetPanel *>(parent())->cutAct);
  return actionList;
}

void QuteWidget::apply()
{
  applyProperties();
}
