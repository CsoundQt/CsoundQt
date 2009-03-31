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
#include "qutescope.h"
#include <cmath>
#include "types.h"  //necessary for the userdata struct
#include "qutecsound.h"  //necessary for the userdata struct


QuteScope::QuteScope(QWidget *parent) : QuteWidget(parent)
{
  m_ud = 0;
  m_zoom = 2;
//   m_type = "scope";
  m_channel = -1;
  QGraphicsScene *m_scene = new QGraphicsScene(this);
  m_scene->setBackgroundBrush(QBrush(Qt::black));
  m_widget = new ScopeWidget(this);
  m_widget->show();
  m_widget->setAutoFillBackground(true);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  static_cast<ScopeWidget *>(m_widget)->setScene(m_scene);
  static_cast<ScopeWidget *>(m_widget)->setResizeAnchor(QGraphicsView::AnchorViewCenter);
//   static_cast<ScopeWidget *>(m_widget)->setRenderHints(QPainter::Antialiasing);
  m_label = new QLabel(this);
  QPalette palette = m_widget->palette();
  palette.setColor(QPalette::WindowText, Qt::white);
  m_label->setPalette(palette);
  m_label->setText("Scope");
  m_label->move(85, 0);
  m_label->resize(500, 25);
  curveData.resize(this->width());
  curve = new QGraphicsPolygonItem(/*&curveData*/);
  curve->setPen(QPen(Qt::green));
  curve->show();
  m_scene->addItem(curve);

//   connect(static_cast<ScopeWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteScope::~QuteScope()
{
}

QString QuteScope::getWidgetLine()
{
  QString line = "ioGraph {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += "scope " + QString::number(m_zoom, 'f', 6) + " ";
  line += QString::number(m_channel, 'f', 6) + " ";
  line += m_name;
//   qDebug("QuteScope::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

// void QuteScope::setType(QString type)
// {
//   m_type = type;
//   updateLabel();
// }

void QuteScope::setValue(double value)
{
  m_zoom = (int) value;
  updateLabel();
}

void QuteScope::setChannel(int channel)
{
//   qDebug("QuteScope::setChannel %i", channel);
  m_channel = channel;
  updateLabel();
}

void QuteScope::setUd(CsoundUserData *ud)
{
  m_ud = ud;
}

void QuteScope::updateLabel()
{
  QString chan = (m_channel == -1 ? tr("all") : QString::number(m_channel));
  m_label->setText(tr("Scope ch:") + chan + tr("  dec:") + QString::number(m_zoom));
}

void QuteScope::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x,y,width, height);
//   static_cast<ScopeWidget *>(m_widget)->setWidgetGeometry(0,0,width, height);
//   if (index < 0)
//     return;
}

void QuteScope::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Scope");
//   channelLabel->hide();
//   nameLineEdit->hide();
  QLabel *label = new QLabel(dialog);
//   label->setText("Type");
//   layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
//   typeComboBox = new QComboBox(dialog);
//   typeComboBox->addItem("Osciloscope", QVariant(QString("scope")));
//   typeComboBox->addItem("Spectrogram", QVariant(QString("fft")));
//   typeComboBox->setCurrentIndex(typeComboBox->findData(QVariant(m_type)));
//   layout->addWidget(typeComboBox, 6, 1, Qt::AlignLeft|Qt::AlignVCenter);
//   label = new QLabel(dialog);
  label->setText("Channel");
  layout->addWidget(label, 6, 2, Qt::AlignRight|Qt::AlignVCenter);
  channelBox = new QComboBox(dialog);
  channelBox->addItem("all", QVariant((int) -1));
  channelBox->addItem("Ch.1",QVariant((int) 1));
  channelBox->addItem("Ch.2",QVariant((int) 2));
  channelBox->addItem("Ch.3",QVariant((int) 3));
  channelBox->addItem("Ch.4",QVariant((int) 4));
  channelBox->addItem("Ch.5",QVariant((int) 5));
  channelBox->addItem("Ch.6",QVariant((int) 6));
  channelBox->addItem("Ch.7",QVariant((int) 7));
  channelBox->addItem("Ch.8",QVariant((int) 8));
  channelBox->addItem("none", QVariant((int) 0));
  channelBox->setCurrentIndex(channelBox->findData(QVariant((int)m_channel)));
  layout->addWidget(channelBox, 6, 3, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
  label->setText("Decimation");
  layout->addWidget(label, 7, 2, Qt::AlignRight|Qt::AlignVCenter);
  decimationBox = new QSpinBox(dialog);
  decimationBox->setValue(m_zoom);
  decimationBox->setRange(1, 20);
  layout->addWidget(decimationBox, 7, 3, Qt::AlignLeft|Qt::AlignVCenter);
}

void QuteScope::applyProperties()
{
//   setType(typeComboBox->itemData(typeComboBox->currentIndex()).toString());
  setChannel(channelBox->itemData(channelBox->currentIndex()).toInt());
  setValue(decimationBox->value());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteScope::resizeEvent(QResizeEvent * event)
{
  QuteWidget::resizeEvent(event);
  curveData.resize(this->width() + 2);
//   QGraphicsScene *m_scene = static_cast<ScopeWidget *>(m_widget)->scene();
//   m_scene->setSceneRect(-m_ud->zerodBFS, m_ud->zerodBFS, width() - 5, m_ud->zerodBFS *2);
//   static_cast<ScopeWidget *>(m_widget)->setSceneRect(-m_ud->zerodBFS , m_ud->zerodBFS, width() - 5, m_ud->zerodBFS *2);
}

void QuteScope::updateData()
{
//   qDebug("QuteScope::updateData()");
  if (m_ud == 0 or m_ud->PERF_STATUS == 0 )
    return;
  if (static_cast<ScopeWidget *>(m_widget)->freeze)
    return;
  double value;
  int numChnls = m_ud->numChnls;
  int channel = m_channel;
  MYFLT newValue;
  if (channel == 0 or channel > numChnls ) {
//     qDebug() << "QuteScope::updateData() Channel out of range " << channel;
    return;
  }
  channel = (channel != -1 ? channel - 1 : -1);
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  RingBuffer *buffer = &m_ud->qcs->audioOutputBuffer;
  buffer->lock();
  QList<MYFLT> list = buffer->buffer;
  buffer->unlock();
  long listSize = list.size();
  long offset = buffer->currentPos;
  for (int i = 0; i < this->width(); i++) {
    value = 0;
    for (int j = 0; j < (int) m_zoom; j++) {
      if (channel == -1) {
        newValue = 0;
        for (int k = 0; k < numChnls; k++) {
          int bufferIndex = (int)((((i* m_zoom)+ j)*numChnls) + offset + k) % listSize;
          newValue += list[bufferIndex];
        }
        newValue /= numChnls;
        if (fabs(newValue) > fabs(value))
          value = -(double) newValue;
      }
      else {
        int bufferIndex = (int)((((i* m_zoom)+ j)*numChnls) + offset + channel) % listSize;
        if (fabs(list[bufferIndex]) > fabs(value))
          value = (double) -list[bufferIndex];
      }
    }
    curveData[i+1] = QPoint(i,value*height()/(2/* * m_ud->zerodBFS*/));
  }
  static_cast<ScopeWidget *>(m_widget)->setSceneRect(0, -height()/2, width(), height() );
  curveData.last() = QPoint(width()-4, 0);
  curveData.first() = QPoint(0, 0);
  curve->setPolygon(curveData);
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}
