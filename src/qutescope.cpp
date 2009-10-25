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

#include "qutescope.h"
#include <cmath>
#include "types.h"  //necessary for the userdata struct
#include "qutecsound.h"  //necessary for the userdata struct


QuteScope::QuteScope(QWidget *parent) : QuteWidget(parent)
{
  m_zoom = 2;
  m_type = "scope";
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
  m_params = new ScopeParams(0, m_scene, static_cast<ScopeWidget *>(m_widget), &mutex, this->width(), this->height());
  m_scopeData = new ScopeData(m_params);
  m_lissajouData = new LissajouData(m_params);
  m_poincareData = new PoincareData(m_params);
  m_dataDisplay = (DataDisplay *)m_scopeData;
  m_dataDisplay->show();
//   connect(static_cast<ScopeWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteScope::~QuteScope()
{
  delete m_poincareData;
  delete m_lissajouData;
  delete m_scopeData;
  delete m_params;
}

void QuteScope::loadFromXml(QString xmlText)
{
  qDebug() << "loadFromXml not implemented for this widget yet";
}

QString QuteScope::getWidgetLine()
{
  QString line = "ioGraph {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
  line += m_type + " " + QString::number(m_zoom, 'f', 6) + " ";
  line += QString::number(m_channel, 'f', 6) + " ";
  line += m_name;
//   qDebug("QuteScope::getWidgetLine() %s", line.toStdString().c_str());
  return line;
}

QString QuteScope::getWidgetXmlText()
{
  return QString();
}

QString QuteScope::getWidgetType()
{
  return QString("scope");
}

void QuteScope::setType(QString type)
{
  m_type = type;
  updateLabel();
  m_dataDisplay->hide();
  if (m_type == "scope") {
    m_dataDisplay = (DataDisplay *)m_scopeData;
  }
  else if (m_type == "lissajou") {
    m_dataDisplay = (DataDisplay *)m_lissajouData;
  }
  else if (m_type == "poincare") {
    m_dataDisplay = (DataDisplay *)m_poincareData;
  }
  m_dataDisplay->show();
}

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
  m_params->ud = ud;
}

void QuteScope::updateLabel()
{
  QString chan = (m_channel == -1 ? tr("all") : QString::number(m_channel));
  m_label->setText(tr("Scope ch:") + chan + tr("  dec:") + QString::number(m_zoom));
}

void QuteScope::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x, y, width, height);
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
  label->setText("Type");
  layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);
  typeComboBox = new QComboBox(dialog);
  typeComboBox->addItem("Oscilloscope", QVariant(QString("scope")));
  typeComboBox->addItem("Lissajou curve", QVariant(QString("lissajou")));
  typeComboBox->addItem("Poincare map", QVariant(QString("poincare")));
//   typeComboBox->addItem("Spectrogram", QVariant(QString("fft")));
  typeComboBox->setCurrentIndex(typeComboBox->findData(QVariant(m_type)));
  layout->addWidget(typeComboBox, 6, 1, Qt::AlignLeft|Qt::AlignVCenter);
  label = new QLabel(dialog);
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
  setType(typeComboBox->itemData(typeComboBox->currentIndex()).toString());
  setChannel(channelBox->itemData(channelBox->currentIndex()).toInt());
  setValue(decimationBox->value());
  QuteWidget::applyProperties();  //Must be last to make sure the widgetsChanged signal is last
}

void QuteScope::resizeEvent(QResizeEvent * event)
{
  QuteWidget::resizeEvent(event);
  m_params->setWidth(this->width());
  m_params->setHeight(this->height());
  m_scopeData->resize();
  m_lissajouData->resize();
  m_poincareData->resize();
//   QGraphicsScene *m_scene = static_cast<ScopeWidget *>(m_widget)->scene();
//   m_scene->setSceneRect(-m_ud->zerodBFS, m_ud->zerodBFS, width() - 5, m_ud->zerodBFS *2);
//   static_cast<ScopeWidget *>(m_widget)->setSceneRect(-m_ud->zerodBFS , m_ud->zerodBFS, width() - 5, m_ud->zerodBFS *2);
}

void QuteScope::updateData()
{
//   qDebug("QuteScope::updateData()");
  m_dataDisplay->updateData(m_channel, m_zoom, static_cast<ScopeWidget *>(m_widget)->freeze);
}

ScopeItem::ScopeItem(int width, int height)
{
  m_width = width;
  m_height = height;
}

void ScopeItem::paint(QPainter *p, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
  p->setPen(m_pen);
  p->drawPoints(m_polygon);
}

void ScopeItem::setPen(const QPen & pen)
{
  m_pen = pen;
}

void ScopeItem::setPolygon(const QPolygonF & polygon)
{
  m_polygon = polygon;
  update(boundingRect());
}

void ScopeItem::setSize(int width, int height)
{
  m_width = width;
  m_height = height;
  prepareGeometryChange();
}

ScopeData::ScopeData(ScopeParams *params) : DataDisplay(params)
{
  curveData.resize(m_params->width + 2);
  curve = new QGraphicsPolygonItem(/*&curveData*/);
  curve->setPen(QPen(Qt::green));
  curve->hide();
  m_params->scene->addItem(curve);
}

void ScopeData::resize()
{
  curveData.resize(m_params->width + 2);
}

void ScopeData::updateData(int channel, int zoom, bool freeze)
{
  CsoundUserData *ud = m_params->ud;
  QMutex *mutex = m_params->mutex;
  int width = m_params->width;
  int height = m_params->height;
  if (ud == 0 or ud->PERF_STATUS != 1 )
    return;
  if (freeze)
    return;
  double value;
  int numChnls = ud->numChnls;
  MYFLT newValue;
  if (channel == 0 or channel > numChnls ) {
//     qDebug() << "QuteScope::updateData() Channel out of range " << channel;
    return;
  }
  channel = (channel != -1 ? channel - 1 : -1);
#ifdef  USE_WIDGET_MUTEX
  mutex->lock();
#endif
  RingBuffer *buffer = &ud->qcs->audioOutputBuffer;
  buffer->lock();
  QList<MYFLT> list = buffer->buffer;
  buffer->unlock();
  long listSize = list.size();
  long offset = buffer->currentPos;
  for (int i = 0; i < width; i++) {
    value = 0;
    for (int j = 0; j < (int) zoom; j++) {
      if (channel == -1) {
        newValue = 0;
        for (int k = 0; k < numChnls; k++) {
          int bufferIndex = (int)((((i* zoom)+ j)*numChnls) + offset + k) % listSize;
          newValue += list[bufferIndex];
        }
        newValue /= numChnls;
        if (fabs(newValue) > fabs(value))
          value = -(double) newValue;
      }
      else {
        int bufferIndex = (int)((((i* zoom)+ j)*numChnls) + offset + channel) % listSize;
        if (fabs(list[bufferIndex]) > fabs(value))
          value = (double) -list[bufferIndex];
      }
    }
    curveData[i+1] = QPoint(i, value*height/(2/* * m_ud->zerodBFS*/));
  }
  m_params->widget->setSceneRect(0, -height/2, width, height );
  curveData.last() = QPoint(width-4, 0);
  curveData.first() = QPoint(0, 0);
  curve->setPolygon(curveData);
#ifdef  USE_WIDGET_MUTEX
  mutex->unlock();
#endif
}

void ScopeData::show()
{
  curve->show();
}

void ScopeData::hide()
{
  curve->hide();
}

LissajouData::LissajouData(ScopeParams *params) : DataDisplay(params)
{
  curveData.resize(m_params->width);
  curve = new ScopeItem(m_params->width, m_params->height);
  curve->setPen(QPen(Qt::green));
  curve->hide();
  m_params->scene->addItem(curve);
}

void LissajouData::resize()
{
  // We take 8 times the display width points for each pass
  // to have a smooth animation
  curveData.resize(m_params->width * 8);
  curve->setSize(m_params->width, m_params->height);
}

void LissajouData::updateData(int channel, int zoom, bool freeze)
{
  // The decimation factor (zoom) is not used here
  CsoundUserData *ud = m_params->ud;
  QMutex *mutex = m_params->mutex;
  int width = m_params->width;
  int height = m_params->height;
  if (ud == 0 or ud->PERF_STATUS != 1 )
    return;
  if (freeze)
    return;
  double x, y;
  int numChnls = ud->numChnls;
  // We take two consecutives channels, the first one for abscissas and
  // the second one for ordinates
  if (channel == 0 or channel >= numChnls or numChnls < 2) {
//     qDebug() << "QuteScope::updateData() Channel out of range " << channel;
    return;
  }
  channel = (channel != -1 ? channel - 1 : 0);
#ifdef  USE_WIDGET_MUTEX
  mutex->lock();
#endif
  RingBuffer *buffer = &ud->qcs->audioOutputBuffer;
  buffer->lock();
  QList<MYFLT> list = buffer->buffer;
  buffer->unlock();
  long listSize = list.size();
  long offset = buffer->currentPos;
  for (int i = 0; i < curveData.size(); i++) {
    int bufferIndex = (int)((i*numChnls) + offset + channel) % listSize;
    x = (double)list[bufferIndex];
    bufferIndex = (bufferIndex + 1) % listSize;
    y = (double) -list[bufferIndex];
    curveData[i] = QPoint(x*width/2, y*height/2);
  }
  m_params->widget->setSceneRect(-width/2, -height/2, width, height );
  curve->setPolygon(curveData);
#ifdef  USE_WIDGET_MUTEX
  mutex->unlock();
#endif
}

void LissajouData::show()
{
  curve->show();
}

void LissajouData::hide()
{
  curve->hide();
}

PoincareData::PoincareData(ScopeParams *params) : DataDisplay(params)
{
  curveData.resize(m_params->width);
  curve = new ScopeItem(m_params->width, m_params->height);
  curve->setPen(QPen(Qt::green));
  curve->hide();
  lastValue = 0.0;
  m_params->scene->addItem(curve);
}

void PoincareData::resize()
{
  // We take 8 times the display width points for each pass
  // to have a smooth animation
  curveData.resize(m_params->width * 8);
  curve->setSize(m_params->width, m_params->height);
}

void PoincareData::updateData(int channel, int zoom, bool freeze)
{
  CsoundUserData *ud = m_params->ud;
  QMutex *mutex = m_params->mutex;
  int width = m_params->width;
  int height = m_params->height;
  if (ud == 0 or ud->PERF_STATUS != 1 )
    return;
  if (freeze)
    return;
  double value;
  int numChnls = ud->numChnls;
  if (channel == 0 or channel > numChnls) {
//     qDebug() << "QuteScope::updateData() Channel out of range " << channel;
    return;
  }
  channel = (channel != -1 ? channel - 1 : 0);
#ifdef  USE_WIDGET_MUTEX
  mutex->lock();
#endif
  RingBuffer *buffer = &ud->qcs->audioOutputBuffer;
  buffer->lock();
  QList<MYFLT> list = buffer->buffer;
  buffer->unlock();
  long listSize = list.size();
  long offset = buffer->currentPos;
  for (int i = 0; i < curveData.size(); i++) {
    int bufferIndex = (int)((i*zoom*numChnls) + offset + channel) % listSize;
    value = (double)list[bufferIndex];
    curveData[i] = QPoint(lastValue*width/2, -value*height/2);
    lastValue = value;
  }
  m_params->widget->setSceneRect(-width/2, -height/2, width, height );
  curve->setPolygon(curveData);
#ifdef  USE_WIDGET_MUTEX
  mutex->unlock();
#endif
}

void PoincareData::show()
{
  curve->show();
}

void PoincareData::hide()
{
  curve->hide();
}

