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
#include "qutegraph.h"
#include "curve.h"
#include <cmath>

QuteGraph::QuteGraph(QWidget *parent) : QuteWidget(parent)
{
  m_widget = new StackedLayoutWidget(this);
  m_widget->show();
  m_widget->setAutoFillBackground(true);
  m_label = new QLabel(this);
  QPalette palette = m_widget->palette();
  palette.setColor(QPalette::WindowText, Qt::white);
  m_label->setPalette(palette);
  m_label->setText("");
  m_label->move(85, 0);
  m_label->resize(500, 25);

  m_pageComboBox = new QComboBox(this);
  m_pageComboBox->resize(80, 25);
  connect(m_pageComboBox, SIGNAL(activated(int)),
          this, SLOT(changeCurve(int)));
  connect(dynamic_cast<StackedLayoutWidget *>(m_widget), SIGNAL(popUpMenu(QPoint)), this, SLOT(popUpMenu(QPoint)));
}

QuteGraph::~QuteGraph()
{
}

QString QuteGraph::getWidgetLine()
{
  QString line = "ioGraph {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
  line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"}";
  return line;
}

void QuteGraph::setWidgetGeometry(int x,int y,int width,int height)
{
  QuteWidget::setWidgetGeometry(x,y,width, height);
  dynamic_cast<StackedLayoutWidget *>(m_widget)->setWidgetGeometry(0,0,width, height);
  int index = dynamic_cast<StackedLayoutWidget *>(m_widget)->currentIndex();
  if (index < 0)
    return;
  changeCurve(index);
}

void QuteGraph::createPropertiesDialog()
{
  QuteWidget::createPropertiesDialog();
  dialog->setWindowTitle("Graph");
  channelLabel->hide();
  nameLineEdit->hide();
}

void QuteGraph::changeCurve(int index)
{
  if (index == -1)
    index = dynamic_cast<StackedLayoutWidget *>(m_widget)->count() - 1;
  dynamic_cast<StackedLayoutWidget *>(m_widget)->setCurrentIndex(index);
  QGraphicsView *view = (QGraphicsView *) dynamic_cast<StackedLayoutWidget *>(m_widget)->currentWidget();
  double max = curves[index]->get_max();
  double min = curves[index]->get_min();
  int size = curves[index]->get_size();
  view->setResizeAnchor(QGraphicsView::NoAnchor);
  view->setSceneRect (0, min - ((max - min)*0.1), size, (max - min)*1.1);
  view->fitInView(0, min - ((max - min)*0.1) , size, (max - min)*1.1 );
  QString text = QString::number(size) + " pts Max=";
  text += QString::number(max, 'g', 5) + " Min =" + QString::number(min, 'g', 5);
  m_label->setText(text);
  m_pageComboBox->setCurrentIndex(index);
}

void QuteGraph::clearCurves()
{
  dynamic_cast<StackedLayoutWidget *>(m_widget)->clearCurves();
  m_pageComboBox->clear();
  curves.clear();
}

void QuteGraph::addCurve(Curve * curve)
{
  qDebug("QuteGraph::addCurve()");
  QGraphicsView *view = new QGraphicsView(m_widget);
  QGraphicsScene *scene = new QGraphicsScene(view);
  scene->setBackgroundBrush(QBrush(Qt::black));
  double max = curve->get_max();
//   double min = curve->get_min();
//   double absmax = curve->get_absmax();
  int size = curve->get_size();
  QGraphicsLineItem* line = new QGraphicsLineItem(0, 0, size, 0);
  line->setPen(QPen(QColor(Qt::white)));
  scene->addItem(line);
  line->show();
  for (int i = 0; i < size; i++) {
    line = new QGraphicsLineItem(i, 0, i, curve->get_data()[i]);
    line->setPen(QPen(QColor(30 + 220.0*fabs(curve->get_data()[i])/max,
                 220,
                 255.*fabs(curve->get_data()[i])/max)));
    scene->addItem(line);
    line->show();
  }
  view->setScene(scene);
  view->setObjectName(curve->get_caption());
  view->show();
  view->setResizeAnchor (QGraphicsView::NoAnchor);
  m_pageComboBox->addItem(curve->get_caption());
  dynamic_cast<StackedLayoutWidget *>(m_widget)->addWidget(view);
  curves.append(curve);
}
