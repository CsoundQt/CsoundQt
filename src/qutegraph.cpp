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

#include "qutegraph.h"
#include "curve.h"
#include <cmath>

QuteGraph::QuteGraph(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new StackedLayoutWidget(this);
  m_widget->show();
  m_widget->setAutoFillBackground(true);
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_widget->setFocusPolicy(Qt::NoFocus);
//   static_cast<StackedLayoutWidget *>(m_widget)->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
  m_label = new QLabel(this);
  QPalette palette = m_widget->palette();
  palette.setColor(QPalette::WindowText, Qt::white);
  m_label->setPalette(palette);
  m_label->setText("");
  m_label->move(85, 0);
  m_label->resize(500, 25);
  m_label->setFocusPolicy(Qt::NoFocus);

  m_pageComboBox = new QComboBox(this);
  m_pageComboBox->resize(80, 25);
  m_pageComboBox->setFocusPolicy(Qt::NoFocus);
  connect(m_pageComboBox, SIGNAL(activated(int)),
          this, SLOT(changeCurve(int)));
//   connect(static_cast<StackedLayoutWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteGraph::~QuteGraph()
{
}

void QuteGraph::loadFromXml(QString xmlText)
{
  qDebug() << "loadFromXml not implemented for this widget yet";
}

QString QuteGraph::getWidgetLine()
{
  // Extension to MacCsound: type of graph (table, ftt, scope), value (which hold the index of the
  // table displayed) zoom and channel name
  // channel number is unused in QuteGraph, but selects channel for scope
  QString line = "ioGraph {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} table ";
  line += QString::number(m_value, 'f', 6) + " ";
  line += QString::number(m_zoom, 'f', 6) + " ";
  line += m_name;
//   qDebug("QuteGraph::getWidgetLine(): %s", line.toStdString().c_str());
  return line;
}

QString QuteGraph::getWidgetXmlText()
{
  return QString();
}

QString QuteGraph::getWidgetType()
{
  return QString("graph");
}

void QuteGraph::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x,y,width, height);
  static_cast<StackedLayoutWidget *>(m_widget)->setWidgetGeometry(0,0,width, height);
  int index = static_cast<StackedLayoutWidget *>(m_widget)->currentIndex();
  if (index < 0)
    return;
  changeCurve(index);
}

void QuteGraph::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Graph");
  QLabel *label = new QLabel(dialog);
  label->setText("Zoom");
  layout->addWidget(label, 7, 2, Qt::AlignRight|Qt::AlignVCenter);
  zoomBox = new QDoubleSpinBox(dialog);
  zoomBox->setValue(m_zoom);
  zoomBox->setRange(1, 10.0);
  zoomBox->setDecimals(1);
  zoomBox->setSingleStep(0.5);
  layout->addWidget(zoomBox, 7, 3, Qt::AlignLeft|Qt::AlignVCenter);
//   channelLabel->hide();
//   nameLineEdit->hide();
}

void QuteGraph::applyProperties()
{
  QuteWidget::applyProperties();
  setZoom(zoomBox->value());
}

void QuteGraph::setValue(double value)
{
  if (m_value == value)
    return;
#ifdef  USE_WIDGET_MUTEX
  mutex.lock();
#endif
  qDebug("QuteGraph::setValue %i", int(value));
  if (value < 0 ) {
    for (int i = 0; i < m_pageComboBox->count(); i++) {
      QStringList parts = m_pageComboBox->itemText(i).split(QRegExp("[ :]"));
      if (parts.size() > 1) {
        if (curves[parts[1].toInt()]->get_caption().isEmpty())
          return; //don't apply value if curve is currently nameless
        if ((int) value == -parts[1].toInt()) {
          changeCurve(i);
          m_value = (int) value;
        }
      }
    }
  }
  else if (value < curves.size()) {
    changeCurve((int) value);
    m_value = (int) value;
  }
  //Dont change value if not valid
#ifdef  USE_WIDGET_MUTEX
  mutex.unlock();
#endif
}

void QuteGraph::setZoom(double zoom)
{
//   qDebug("QuteGraph::setZoom %f", zoom);
  if (zoom >=1.0 && zoom <= 10.0)
    m_zoom = zoom;
  else
    m_zoom = 1.0;
  changeCurve(-2);  // Redraw
}

void QuteGraph::changeCurve(int index)
{
//   qDebug("QuteGraph::changeCurve %i", index);
  if (index == -1) // goto last curve
    index = static_cast<StackedLayoutWidget *>(m_widget)->count() - 1;
  if (index == -2)  // update curve but don't change which
    index = static_cast<StackedLayoutWidget *>(m_widget)->currentIndex();
  if (index < 0 or curves[index]->get_caption().isEmpty())
    return;
  static_cast<StackedLayoutWidget *>(m_widget)->setCurrentIndex(index);
  QGraphicsView *view = (QGraphicsView *) static_cast<StackedLayoutWidget *>(m_widget)->currentWidget();
//   view->setFocusPolicy(Qt::NoFocus);
  double max = - curves[index]->get_min();
  double min = - curves[index]->get_max();
  int size = curves[index]->get_size();
  view->setResizeAnchor(QGraphicsView::NoAnchor);
  if (curves[index]->get_caption().contains("ftable")) {
    view->setSceneRect (0, min - ((max - min)*0.17),(double) size/m_zoom, (max - min)*1.17);
    view->fitInView(0, min - ((max - min)*0.17) , (double) size/m_zoom, (max - min)*1.17);
  }
  else {
    if (curves[index]->get_caption().contains("fft")) {
      view->setSceneRect (0, 0, size, 90.);
  //     view->fitInView(0, -30./m_zoom , (double) size/m_zoom, 100./m_zoom);
      view->fitInView(0, -30. , (double) size/m_zoom, 100.);
    }
    else { //from display opcode
      view->setSceneRect (0, -1, size, 2);
  //     view->fitInView(0, -30./m_zoom , (double) size/m_zoom, 100./m_zoom);
      view->fitInView(0, -1 , (double) size/m_zoom, 2);
    }
  }
  QString text = QString::number(size) + " pts Max=";
  text += QString::number(max, 'g', 5) + " Min =" + QString::number(min, 'g', 5);
  m_label->setText(text);
  m_pageComboBox->setCurrentIndex(index);
}

void QuteGraph::clearCurves()
{
  static_cast<StackedLayoutWidget *>(m_widget)->clearCurves();
  m_pageComboBox->clear();
  curves.clear();
  lines.clear();
  polygons.clear();
}

void QuteGraph::addCurve(Curve * curve)
{
//   qDebug("QuteGraph::addCurve()");
  QGraphicsView *view = new QGraphicsView(m_widget);
  QGraphicsScene *scene = new QGraphicsScene(view);
  view->setContextMenuPolicy(Qt::NoContextMenu);
  scene->setBackgroundBrush(QBrush(Qt::black));
  int size = curve->get_size();
  QGraphicsLineItem* line = new QGraphicsLineItem(0, 0, size, 0);
  line->setPen(QPen(QColor(Qt::white)));
  line->show();
  scene->addItem(line);
  QVector<QGraphicsLineItem *> linesVector;
  linesVector.append(line);
  lines.append(linesVector);
  if (curve->get_caption().contains("ftable")) {
//     for (int i = 0; i < size; i++) {
//       line = new QGraphicsLineItem(i, 0, i, - curve->get_data()[i]);
//       line->setPen(QPen(Qt::white));
// //       line->setPen(QPen(QColor(30 + 220.0*fabs(curve->get_data()[i])/max,
// //                   220,
// //                   255.*fabs(curve->get_data()[i])/max)));
//       scene->addItem(line);
//       line->show();
//       linesVector.append(line);
//     }
    view->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
  }
  else {
    QGraphicsPolygonItem * item = new QGraphicsPolygonItem(/*polygon*/);
    item->setPen(QPen(Qt::yellow));
    item->show();
    polygons.append(item);
    scene->addItem(item);
    //TODO add labels for frequencies
  }
  view->setScene(scene);
//   view->setObjectName(curve->get_caption());
  view->show();
  view->setResizeAnchor (QGraphicsView::NoAnchor);
  view->setFocusPolicy(Qt::NoFocus);
  m_pageComboBox->addItem(curve->get_caption());
  static_cast<StackedLayoutWidget *>(m_widget)->addWidget(view);
  curves.append(curve);
//   qDebug("QuteGraph::addCurve() %i- %i", curves.size(), curve);
}

int QuteGraph::getCurveIndex(Curve * curve)
{
  int index = -1;
  for (int i = 0; i < curves.size(); i++) {
    if (curves[i] == curve) {
      index = i;
      break;
    }
  }
//   qDebug("QuteGraph::getCurveIndex %i - %i", index, curve);
  return index;
}

Curve* QuteGraph::getCurveById(uintptr_t id)
{
  Curve *curve = 0;
  foreach (Curve *thisCurve, curves) {
//     qDebug("QuteGraph::getCurveById curve %i id %i", thisCurve->get_id(), id);
    if (thisCurve->get_id() == id)
      return thisCurve;
  }
  return curve;
}

void QuteGraph::setUd(CsoundUserData *ud)
{
  m_ud = ud;
}

void QuteGraph::setCurveData(Curve * curve)
{
  //TODO is it necessary to free the curves created by Csound? (e.g. FFT from dispfft)
  int index = getCurveIndex(curve);
//   qDebug("QuteGraph::setCurveData %i", index);
  if (index >= curves.size() or index < 0)
    return;
  curves[index] = curve;
  double max = curve->get_max();
  StackedLayoutWidget *widget_ = static_cast<StackedLayoutWidget *>(m_widget);
  QGraphicsView *view = static_cast<QGraphicsView *>(widget_->widget(index));
  QGraphicsScene *scene = view->scene();
  // Refitting curves in view resets the scrollbar so we need the previous value
  int viewPosx = view->horizontalScrollBar()->value();
  int viewPosy = view->verticalScrollBar()->value();
  int decimate = (int) curve->get_size() / 1024;
  if (curve->get_caption().contains("ftable")) {
    if (lines[index].size() != (int) curve->get_size()) {
      foreach (QGraphicsLineItem *line, lines[index]) {
        delete line;
      }
      lines[index].clear();
      MYFLT decValue = 0;
      for (int i = 0; i < (int) curve->get_size(); i++) {
        decValue = (decValue < fabs(curve->get_data()[i]) ? curve->get_data()[i] : decValue);
        if (decimate == 0 or i%decimate == 0) {
          QGraphicsLineItem *line = new QGraphicsLineItem(i, 0, i, - decValue);
          int colorValue = (int) (220.0*fabs(decValue)/max);
          colorValue = colorValue > 220 ? 220 : colorValue;
          line->setPen(QPen(QColor(30 + colorValue,
                      220,
                      colorValue )));
          line->show();
          lines[index].append(line);
          scene->addItem(line);
          decValue = 0;
        }
      }
    }
    else {
      for (int i = 1; i < lines[index].size(); i++) { //skip first item, which is base line
        QGraphicsLineItem *line = static_cast<QGraphicsLineItem *>(lines[index][i]);
        line->setLine(i - 1, 0, i - 1, - curve->get_data()[i - 1]);
        line->setPen(QPen(QColor(30 + 220.0*fabs(curve->get_data()[i])/max,
                    220,
                    255.*fabs(curve->get_data()[i])/max)));
        line->show();
      }
    }
  }
  else {  // in case its not an ftable
    QPolygonF polygon;
    if (curve->get_caption().contains("fft")) {
      polygon.append(QPointF(0,110));
    }
    else { //from display opcode
      polygon.append(QPointF(0,0));
    }
    for (int i = 0; i < (int) curve->get_size(); i++) { //skip first item, which is base line
      double value;
      if (curve->get_caption().contains("fft")) {
        value =  20*log10(fabs(curve->get_data()[i])/m_ud->zerodBFS);
      }
      else {
        value = curve->get_data()[i]/m_ud->zerodBFS;
      }
      polygon.append(QPointF(i, -value));
    }
    if (curve->get_caption().contains("fft")) {
      polygon.append(QPointF(curve->get_size() - 1,110));
    }
    else { //from display opcode
      polygon.append(QPointF(curve->get_size() - 1,0));
    }
    polygons[index]->setPolygon(polygon);
  }
  m_pageComboBox->setItemText(index, curve->get_caption());
  if (index == m_pageComboBox->currentIndex())
    changeCurve(-2); //update curve
  view->horizontalScrollBar()->setValue(viewPosx);
  view->verticalScrollBar()->setValue(viewPosy);
}
