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
	//  m_widget->setAutoFillBackground(true);
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
	s.writeTextElement("objectName2", m_channel2);
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

void QuteGraph::setValue(double value)
{
	QuteWidget::setValue(value);
	m_value2 = getTableNumForIndex((int) value);
}

void QuteGraph::refreshWidget()
{
	bool needsUpdate = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	int index = 0;
	//  qDebug() << "QuteGraph::refreshWidget()" << m_value << m_valueChanged << m_value2 << m_value2Changed;
	if (m_valueChanged) {
		index = (int) m_value;
		m_value2 = getTableNumForIndex(index);
		m_value2Changed = false;
		m_valueChanged = false;
		needsUpdate = true;
	}
	else if (m_value2Changed) {
		index = getIndexForTableNum(m_value2);
		if (index >= 0) {
			m_value = index;
			//      m_valueChanged = false;
		}
		m_value2Changed = false;
		needsUpdate = true;
	}
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();  // unlock
#endif
	if (needsUpdate) {
		if (index < 0) {
			index = getIndexForTableNum(-index);
		}
		if (index < 0 || index >= curves.size() || curves[index]->get_caption().isEmpty()) { // Don't show if curve has no name. Is this likely?
			return;
		}
		//    m_pageComboBox->blockSignals(true);
		//    m_pageComboBox->setCurrentIndex(index);
		//    m_pageComboBox->blockSignals(false);
		changeCurve(index);
	}
}

void QuteGraph::createPropertiesDialog()
{
	QuteWidget::createPropertiesDialog();
	dialog->setWindowTitle("Graph");

	channelLabel->setText("Index Channel name =");
	channelLabel->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	//  nameLineEdit->setText(getChannelName());

	QLabel *label = new QLabel(dialog);
	label = new QLabel(dialog);
	label->setText("F-table Channel name =");
	layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
	name2LineEdit = new QLineEdit(dialog);
	name2LineEdit->setText(getChannel2Name());
	name2LineEdit->setMinimumWidth(320);
	layout->addWidget(name2LineEdit, 4,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);

	label = new QLabel(dialog);
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
	setProperty("QCS_objectName2", name2LineEdit->text());
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
	if (index == -1) {// goto last curve
		index = stacked->count() - 1;
	}
	else if (index == -2) { // update curve but don't change which
		if (m_value < 0) {
			index = getIndexForTableNum(-m_value);
		}
		else {
			index = (int) m_value;
		}
	}
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
	m_pageComboBox->blockSignals(true);
	m_pageComboBox->setCurrentIndex(index);
	m_pageComboBox->blockSignals(false);
	drawCurve(curves[index], index);
	m_value = index;

	double max = - curves[index]->get_min();
	double min = - curves[index]->get_max();
	//  double span = max - min;
	//  FIXME implement dispx, dispy and modex, modey
	int size = curves[index]->get_size();
	QString caption = curves[index]->get_caption();
	//  qDebug() << "QuteGraph::changeCurve"<< curves[index]->get_caption() << index <<max<< min<< zoomx<< zoomy << size;
	//  view->setResizeAnchor(QGraphicsView::NoAnchor);
	if (caption.contains("ftable")) {
		int ftable = getTableNumForIndex(index);
		if (m_value2 != ftable) {
			m_value2 = ftable;
			m_value2Changed = true;
		}
	}
	else {
		if (caption.contains("fft")) {
			m_value2 = -1;
		}
		else { //from display opcode
			m_value2 = -1;
		}
	}
	scaleGraph(index);
	QString text = QString::number(size) + " pts Max=";
	text += QString::number(max) + " Min =" + QString::number(min);
	m_label->setText(text);
}

void QuteGraph::indexChanged(int index)
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	if (m_channel == "") {
		setInternalValue(index);
	}
	else {
		QPair<QString, double> channelValue(m_channel, index);
		emit newValue(channelValue);
	}
	if (m_channel2 == "") {
		setValue2(getTableNumForIndex(index));
	}
	else {
		QPair<QString, double> channel2Value(m_channel2, getTableNumForIndex(index));
		emit newValue(channel2Value);
	}
	//  qDebug() << "QuteGraph::indexChanged " << m_channel << m_value << m_channel2 << m_value2;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteGraph::clearCurves()
{
	//  curveLock.lock();
	m_widget->blockSignals(true);
	static_cast<StackedLayoutWidget *>(m_widget)->clearCurves();
	m_widget->blockSignals(false);
	m_pageComboBox->blockSignals(true);
	m_pageComboBox->clear();
	m_pageComboBox->blockSignals(false);
	curves.clear();
	lines.clear();
	polygons.clear();
	//  curveLock.unlock();
}

void QuteGraph::addCurve(Curve * curve)
{
	Q_ASSERT(curve != 0);
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
	//  if (curve->get_caption().contains("ftable")) {
	//    view->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	//  }
	// Add dummy polygon for all graphs when they are created
	QGraphicsPolygonItem * item = new QGraphicsPolygonItem(/*polygon*/);
	item->setPen(QPen(Qt::yellow));
	item->show();
	polygons.append(item);
	scene->addItem(item);
	view->setScene(scene);
	//   view->setObjectName(curve->get_caption());
	view->show();
	view->setResizeAnchor (QGraphicsView::NoAnchor);
	view->setFocusPolicy(Qt::NoFocus);
	m_pageComboBox->blockSignals(true);
	m_pageComboBox->addItem(curve->get_caption());
	m_pageComboBox->blockSignals(false);
	//  curveLock.lock();
	static_cast<StackedLayoutWidget *>(m_widget)->addWidget(view);
	curves.append(curve);
	//  curveLock.unlock();
	//  double max = - curves.last()->get_min();
	//  double min = - curves.last()->get_max();
	//  double zoomx = property("QCS_zoomx").toDouble();
	//  double zoomy = property("QCS_zoomy").toDouble();
	//  view->fitInView(0, min - ((max - min)*0.17/zoomy) , (double) size/zoomx, (max - min)*1.17/zoomy);
	if (m_value == curves.size() - 1) { // If new curve created corresponds to current stored value
		changeCurve(m_value);
	}
}

int QuteGraph::getCurveIndex(Curve * curve)
{
	Q_ASSERT(curve != 0);
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
	Q_ASSERT(curve != 0);
	int index = getCurveIndex(curve);
	//  qDebug() << "QuteGraph::setCurveData " << index << curve;
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
				value =  20.0*log10(fabs(curve->get_data(i))/m_ud->zerodBFS);
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
	//  view->horizontalScrollBar()->setValue(viewPosx);
	//  view->verticalScrollBar()->setValue(viewPosy);

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
	//  bool live = curve->getOriginal() != 0;
	Q_ASSERT(index >= 0);
	QString caption = curve->get_caption();
	//  qDebug() << "QuteGraph::drawCurve" << caption << curve->getOriginal() << curve->get_size() << curve->getOriginal()->npts << curve->get_max() << curve->get_min();
	if (caption.isEmpty()) {
		return;
	}
	QGraphicsScene *scene = static_cast<QGraphicsView *>(static_cast<StackedLayoutWidget *>(m_widget)->widget(index))->scene();
	double max = curve->get_max();
	max = max == 0 ? 1: max;
	int size = (int) curve->get_size();
	int decimate = (int) size /1024;
	if (lines[index].size() != size) {
		foreach (QGraphicsLineItem *line, lines[index]) {
			delete line;
		}
		lines[index].clear();
		MYFLT decValue = 0.0;
		for (int i = 0; i < (int) curve->get_size(); i++) {
			//      float value = live ? (curve->getOriginal()->windid != 0 ? (float) curve->getOriginal()->fdata[i]: curve->get_data(i))
			//                    : curve->get_data(i);
			float value = curve->get_data(i);
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
			//      float prevvalue = live ? (float) curve->getOriginal()->fdata[i - 1] : curve->get_data(i - 1);
			float prevvalue = curve->get_data(i - 1);
			//      float value = live ? (float) curve->getOriginal()->fdata[i] : curve->get_data(i);
			float value = curve->get_data(i);
			line->setLine(i - 1, 0, i - 1, - prevvalue);
			int colorValue = (int) (220.0*fabs(value)/max);
			colorValue = colorValue > 220 ? 220 : colorValue;
			line->setPen(QPen(QColor(30 + colorValue,
									 220,
									 colorValue)));
			line->show();
		}
	}
	scaleGraph(index);
}

void QuteGraph::scaleGraph(int index)
{
	double max = - curves[index]->get_min();
	double min = - curves[index]->get_max();
	double zoomx = property("QCS_zoomx").toDouble();
	double zoomy = property("QCS_zoomy").toDouble();
	//  double span = max - min;
	//  FIXME implement dispx, dispy and modex, modey
	int size = curves[index]->get_size();
	QString caption = curves[index]->get_caption();
	QGraphicsView *view = (QGraphicsView *) static_cast<StackedLayoutWidget *>(m_widget)->currentWidget();
	qDebug() << "QuteGraph::scaleGraph"<< curves[index]->get_caption() << index <<max<< min<< zoomx<< zoomy << size;
	//  view->setResizeAnchor(QGraphicsView::NoAnchor);
	if (caption.contains("ftable")) {
		view->setSceneRect (0, min - (max - min)*0.17, (double) size, (max - min)*1.17);
		qDebug() << view->sceneRect();
		view->fitInView(0, min, (double) size/zoomx, (max - min)*1.17/zoomy);
	}
	else {
		if (caption.contains("fft")) {
			view->setSceneRect (0, 0, size, 90.);
			view->fitInView(0, -30. , (double) size/zoomx, 100./zoomy);
		}
		else { //from display opcode
			view->setSceneRect (0, -1, size, 2);
			view->fitInView(0, -10./zoomy, (double) size/zoomx, 10./zoomy);
		}
	}
}

int QuteGraph::getTableNumForIndex(int index)
{
	if (index < 0  || index >= curves.size()
			|| curves.size() <= 0) { // Invalid index
		return -1;
	}
	QString caption = curves[index]->get_caption();
	int ftable = -1;
	if (caption.contains("ftable")) {
		ftable= caption.mid(caption.indexOf(" ") + 1,
							caption.indexOf(":") - caption.indexOf(" ") - 1).toInt();
	}
	//  qDebug() << "QuteGraph::getTableNumForIndex ftable" << ftable << index;
	return ftable;
}

int QuteGraph::getIndexForTableNum(int ftable)
{
	int index = -1;
	for (int i = 0; i < curves.size(); i++) {
		QString text = curves[i]->get_caption();
		if (text.contains("ftable")) {
			QStringList parts = text.split(QRegExp("[ :]"), QString::SkipEmptyParts);
			//      qDebug() << "QuteGraph::setValue " << parts << " " << value;
			if (parts.size() > 1) {
				int num = parts.last().toInt();
				if (ftable == num) {
					index = i;
					break;
				}
			}
		}
	}
	return index;
}

void QuteGraph::setInternalValue(double value)
{
	m_value = value;
	m_valueChanged = true;
}
