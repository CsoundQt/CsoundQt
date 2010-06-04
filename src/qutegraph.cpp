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
  m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
  m_widget->setContextMenuPolicy(Qt::NoContextMenu);
  m_label = new QLabel(this);
  QPalette palette = m_widget->palette();
  palette.setColor(QPalette::WindowText, Qt::white);
  m_label->setPalette(palette);
  m_label->setText("");
  m_label->move(105, 0);
  m_label->resize(500, 25);

  m_pageComboBox = new QComboBox(this);
  m_pageComboBox->resize(100, 25);

  m_pageComboBox->setFocusPolicy(Qt::NoFocus);
  m_label->setFocusPolicy(Qt::NoFocus);
  canFocus(false);
  connect(m_pageComboBox, SIGNAL(currentIndexChanged(int)),
          this, SLOT(indexChanged(int)));
  polygons.clear();

// Default properties
  setProperty("QCS_zoomx", 1.0);
  setProperty("QCS_zoomy", 1.0);
  setProperty("QCS_dispx", 1.0);
  setProperty("QCS_dispy", 1.0);
  setProperty("QCS_modex", "auto");
  setProperty("QCS_modey", "auto");
  setProperty("QCS_all", true);
}

QuteGraph::~QuteGraph()
{
}

QString QuteGraph::getWidgetLine()
{
  // Extension to MacCsound: type of graph (table, ftt, scope), value (which hold the index of the
  // table displayed) zoom and channel name
  // channel number is unused in QuteGraph, but selects channel for scope
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  QString line = "ioGraph {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} table ";
  line += QString::number(m_value, 'f', 6) + " ";
  line += QString::number(property("QCS_zoomx").toDouble(), 'f', 6) + " ";
  line += m_channel;
//   qDebug("QuteGraph::getWidgetLine(): %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return line;
}

QString QuteGraph::getWidgetXmlText()
{
  // Graphs are not implemented in blue
  xmlText = "";
  QXmlStreamWriter s(&xmlText);
  createXmlWriter(s);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif

  s.writeTextElement("value", QString::number((int)m_value));
  s.writeTextElement("zoomx", QString::number(property("QCS_zoomx").toDouble(), 'f', 8));
  s.writeTextElement("zoomy", QString::number(property("QCS_zoomy").toDouble(), 'f', 8));
  s.writeTextElement("dispx", QString::number(property("QCS_dispx").toDouble(), 'f', 8));
  s.writeTextElement("dispy", QString::number(property("QCS_dispy").toDouble(), 'f', 8));
  s.writeTextElement("modex", property("QCS_modex").toString());
  s.writeTextElement("modey", property("QCS_modey").toString());
  s.writeTextElement("all", property("QCS_all").toBool() ? "true" : "false");
  s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  return xmlText;
}

QString QuteGraph::getWidgetType()
{
  return QString("BSBGraph");
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

void QuteGraph::refreshWidget()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  int index = (int) m_value;
  m_valueChanged = false;
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();  // unlock
#endif
  if (index < 0) {
    for (int i = 0; i < m_pageComboBox->count(); i++) {
      QStringList parts = m_pageComboBox->itemText(i).split(QRegExp("[ :]"), QString::SkipEmptyParts);
//      qDebug() << "QuteGraph::setValue " << parts << " " << value;
      if (parts.size() > 1) {
        int num = parts.last().toInt();
        if (index == -num) {
          index = i;
          break;
        }
      }
    }
  }
  if (index >= curves.size() || curves[index]->get_caption().isEmpty()) { // Don't show if curve has no name. Is this likely?
    return;
  }
  m_pageComboBox->blockSignals(true);
  m_pageComboBox->setCurrentIndex(index);
  m_pageComboBox->blockSignals(false);
  changeCurve(index);
}

void QuteGraph::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Graph");
  QLabel *label = new QLabel(dialog);
  label->setText("Zoom X");
  layout->addWidget(label, 8, 0, Qt::AlignRight|Qt::AlignVCenter);
  zoomxBox = new QDoubleSpinBox(dialog);
  zoomxBox->setRange(0.1, 10.0);
  zoomxBox->setDecimals(1);
  zoomxBox->setSingleStep(0.1);
  layout->addWidget(zoomxBox, 8, 1, Qt::AlignLeft|Qt::AlignVCenter);

  label = new QLabel(dialog);
  label->setText("Zoom Y");
  layout->addWidget(label, 8, 2, Qt::AlignRight|Qt::AlignVCenter);
  zoomyBox = new QDoubleSpinBox(dialog);
  zoomyBox->setRange(0.1, 10.0);
  zoomyBox->setDecimals(1);
  zoomyBox->setSingleStep(0.1);
  layout->addWidget(zoomyBox, 8, 3, Qt::AlignLeft|Qt::AlignVCenter);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
  zoomxBox->setValue(property("QCS_zoomx").toDouble());
  zoomyBox->setValue(property("QCS_zoomy").toDouble());
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
//   channelLabel->hide();
//   nameLineEdit->hide();
}

void QuteGraph::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForWrite();
#endif
  setProperty("QCS_zoomx", zoomxBox->value());
  setProperty("QCS_zoomy", zoomyBox->value());
  setProperty("QCS_dispx", 1);
  setProperty("QCS_dispy", 1);
  setProperty("QCS_modex", "lin");
  setProperty("QCS_modey", "lin");
  setProperty("QCS_all", true);

#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  QuteWidget::applyProperties();
}


void QuteGraph::changeCurve(int index)
{
  StackedLayoutWidget *stacked =  static_cast<StackedLayoutWidget *>(m_widget);
  if (index == -1) // goto last curve
    index = static_cast<StackedLayoutWidget *>(m_widget)->count() - 1;
  else if (index == -2)  // update curve but don't change which
    index = static_cast<StackedLayoutWidget *>(m_widget)->currentIndex();
  else if (stacked->currentIndex() == index) {
    return;
  }
  if (index < 0  || index >= curves.size()
    || curves.size() <= 0 || curves[index]->get_caption().isEmpty()) { // Invalid index
    return;
  }
  stacked->blockSignals(true);
  stacked->setCurrentIndex(index);
  stacked->blockSignals(false);
  drawCurve(curves[index], index);
  QGraphicsView *view = (QGraphicsView *) static_cast<StackedLayoutWidget *>(m_widget)->currentWidget();

  double max = - curves[index]->get_min();
  double min = - curves[index]->get_max();
  double zoomx = property("QCS_zoomx").toDouble();
  double zoomy = property("QCS_zoomy").toDouble();
//  double span = max - min;
//  FIXME implement dispx, dispy and modex, modey
  int size = curves[index]->get_size();
  qDebug() << "QuteGraph::changeCurve"<< curves[index]->get_caption()<< index <<max<< min<< zoomx<< zoomy << size;
  view->setResizeAnchor(QGraphicsView::NoAnchor);
  if (curves[index]->get_caption().contains("ftable")) {
//    view->setSceneRect (0, min - ((max - min)*0.17),(double) size/zoomx, (max - min)*1.17/zoomy);
    view->fitInView(0, min - ((max - min)*0.17/zoomy) , (double) size/zoomx, (max - min)*1.17/zoomy);
  }
  else {
    if (curves[index]->get_caption().contains("fft")) {
      view->setSceneRect (0, 0, size, 90.);
      view->fitInView(0, -30. , (double) size/zoomx, 100./zoomy);
    }
    else { //from display opcode
      view->setSceneRect (0, -1, size, 2);
      view->fitInView(0, -10./zoomy, (double) size/zoomx, 10./zoomy);
    }
  }
  QString text = QString::number(size) + " pts Max=";
  text += QString::number(max, 'g', 5) + " Min =" + QString::number(min, 'g', 5);
  m_label->setText(text);
}

void QuteGraph::indexChanged(int index)
{
  setValue(index);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.lockForRead();
#endif
//  qDebug() << "QuteGraph::indexChanged " << m_channel << m_value;
  QPair<QString, double> channelValue(m_channel, m_value);
#ifdef  USE_WIDGET_MUTEX
  widgetLock.unlock();
#endif
  emit newValue(channelValue);
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
//  qDebug() << "QuteGraph::addCurve()" << curve << curve->get_caption() ;
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
  m_pageComboBox->blockSignals(true);
  m_pageComboBox->addItem(curve->get_caption());
  m_pageComboBox->blockSignals(false);
  static_cast<StackedLayoutWidget *>(m_widget)->addWidget(view);
  curves.append(curve);
  if (m_value == curves.size() - 1) { // If new curve created corresponds to current stored value
    changeCurve(m_value);
  }
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

void QuteGraph::setCurveData(Curve * curve)
{
//  qDebug("QuteGraph::setCurveData %i", index);
  int index = getCurveIndex(curve);
  if (index >= curves.size() || index < 0) {
    return;
  }
  curves[index] = curve;
  StackedLayoutWidget *widget_ = static_cast<StackedLayoutWidget *>(m_widget);
  QGraphicsView *view = static_cast<QGraphicsView *>(widget_->widget(index));
  QString modex = property("QCS_modex").toString();
  QString modey = property("QCS_modey").toString();
  // Refitting curves in view resets the scrollbar so we need the previous value
  int viewPosx = view->horizontalScrollBar()->value();
  int viewPosy = view->verticalScrollBar()->value();
  if (curve->get_caption().contains("ftable")) {
    drawCurve(curve, index);
  }
  else {  // in case its not an ftable
    QPolygonF polygon;
    if (curve->get_caption().contains("fft")) { // from dispfft opcode
      polygon.append(QPointF(0,110));
    }
    else { //from display opcode
      polygon.append(QPointF(0,0));
    }
    for (int i = 0; i < (int) curve->get_size(); i++) { //skip first item, which is base line
      double value;
      if (curve->get_caption().contains("fft")) {
        value =  20*log10(fabs(curve->get_data(i))/m_ud->zerodBFS);
      }
      else {
        value = curve->get_data(i)/m_ud->zerodBFS;
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
//  qDebug() << "QuteGraph::setCurveData " << index << m_pageComboBox->currentIndex();
  if (index == m_pageComboBox->currentIndex()) {
    changeCurve(-2); //update curve
  }
  view->horizontalScrollBar()->setValue(viewPosx);
  view->verticalScrollBar()->setValue(viewPosy);

//  changeCurve(-2);
}

void QuteGraph::setUd(CsoundUserData *ud)
{
  m_ud = ud;
}

void QuteGraph::applyInternalProperties()
{
  QuteWidget::applyInternalProperties();
  changeCurve(-2);  // Redraw
//  qDebug() << "QuteSlider::applyInternalProperties()";
}

void QuteGraph::drawCurve(Curve * curve, int index)
{
  qDebug() << "QuteGraph::drawCurve" << curve->getOriginal() << curve->get_size() << curve->getOriginal()->npts;
  bool live = curve->getOriginal() != 0;
  live = false;
  QString caption = live ? QString(curve->getOriginal()->caption) : curve->get_caption();
  if (caption.isEmpty()) {
    return;
  }
  QGraphicsScene *scene = static_cast<QGraphicsView *>(static_cast<StackedLayoutWidget *>(m_widget)->widget(index))->scene();
  double max = live ? curve->getOriginal()->max :curve->get_max();
  int size = live ? curve->getOriginal()->npts:(int) curve->get_size();
  int decimate = (int) size /1024;
  if (lines[index].size() != size) {
    foreach (QGraphicsLineItem *line, lines[index]) {
      delete line;
    }
    lines[index].clear();
    MYFLT decValue = 0.0;
    for (int i = 0; i < (int) curve->get_size(); i++) {
      float value = live ? (curve->getOriginal()->windid != 0 ? (float) curve->getOriginal()->fdata[i]: curve->get_data(i))
                    : curve->get_data(i);
      decValue = (fabs(decValue) < fabs(value) ? value : decValue);
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
      float prevvalue = live ? (float) curve->getOriginal()->fdata[i - 1] : curve->get_data(i - 1);
      float value = live ? (float) curve->getOriginal()->fdata[i] : curve->get_data(i);
      line->setLine(i - 1, 0, i - 1, - prevvalue);
      line->setPen(QPen(QColor(30 + 220.0*fabs(value)/max,
                               220,
                               255.*fabs(value)/max)));
      line->show();
    }
  }
}
