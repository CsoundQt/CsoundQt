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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#include "qutewidget.h"

#include <QSlider>

QuteWidget::QuteWidget(QWidget *parent, widgetType type):
    QWidget(parent), m_type(type)
{
  this->setGeometry(QRect(5, 5, 20, 200));
  m_widget = new QSlider(this);

  propertiesAct = new QAction(/*QIcon(":/images/gtk-new.png"),*/ tr("&Properties"), this);
  propertiesAct->setShortcut(tr("Alt+P"));
  propertiesAct->setStatusTip(tr("Open widget properties"));
  connect(propertiesAct, SIGNAL(triggered()), this, SLOT(openProperties()));
}


QuteWidget::~QuteWidget()
{
}

void QuteWidget::setChannelName(QString name)
{
  m_name = name;
  m_widget->setObjectName(name);
}

void QuteWidget::setWidgetGeometry(QRect rect)
{
  this->setGeometry(rect);
  m_widget->setMinimumSize(rect.width(), rect.height());
}


void QuteWidget::setRange(int min, int max)
{
  ((QSlider *)m_widget)->setRange(min,max);
}

QString QuteWidget::getChannelName()
{
  return m_name;
}

double QuteWidget::getValue()
{
  if (m_type == QUTE_SLIDER)
    return ((QSlider *)m_widget)->value();

}


void QuteWidget::contextMenuEvent(QContextMenuEvent *event)
{
  QMenu menu(this);
  menu.addAction(propertiesAct);
//   menu.addAction(copyAct);
//   menu.addAction(pasteAct);
  menu.exec(event->globalPos());
//   qDebug("menu");
}

void QuteWidget::openProperties()
{
  QDialog dialog(this);
  dialog.resize(300, 300);
  dialog.setModal(true);
  QGridLayout *layout = new QGridLayout(&dialog);
  QLabel *label = new QLabel(&dialog);
  label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("X =");
  label->setAlignment(Qt::AlignRight);
  layout->addWidget(label, 0, 0, Qt::AlignCenter);
  label = new QLabel(&dialog);
  label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Y =");
  label->setAlignment(Qt::AlignRight);
  layout->addWidget(label, 0, 2, Qt::AlignCenter);
  label = new QLabel(&dialog);
  label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Width =");
  label->setAlignment(Qt::AlignRight);
  layout->addWidget(label, 1, 0, Qt::AlignCenter);
  label = new QLabel(&dialog);
  label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Height =");
  label->setAlignment(Qt::AlignRight);
  layout->addWidget(label, 1, 2, Qt::AlignCenter);
  QPushButton *button = new QPushButton(tr("Ok"));
  layout->addWidget(button, 3, 3, Qt::AlignCenter);

  connect(button, SIGNAL(released()), &dialog, SLOT(accept()));
  dialog.exec();
}
