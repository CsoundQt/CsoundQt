
/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
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
#include "csoundqt.h"  //necessary for the userdata struct


QuteScope::QuteScope(QWidget *parent) : QuteWidget(parent)
{
	QGraphicsScene *m_scene = new QGraphicsScene(this);
    // m_scene->setBackgroundBrush(QBrush(Qt::black));
    m_scene->setBackgroundBrush(QBrush(QColor("#161616")));
	m_widget = new ScopeWidget(this);
	m_widget->show();
	m_widget->setAutoFillBackground(true);
	m_widget->setContextMenuPolicy(Qt::NoContextMenu);
    // Necessary to pass mouse tracking to widget panel for _MouseX channels
    m_widget->setMouseTracking(true);
	//  m_widget->setWindowFlags(Qt::WindowStaysOnTopHint);
	canFocus(false);
	static_cast<ScopeWidget *>(m_widget)->setScene(m_scene);
	static_cast<ScopeWidget *>(m_widget)->setResizeAnchor(QGraphicsView::AnchorViewCenter);
    // static_cast<ScopeWidget *>(m_widget)->setRenderHints(QPainter::Antialiasing);
    m_label = new QLabel(this);
	QPalette palette = m_widget->palette();
    palette.setColor(QPalette::WindowText, QColor(196, 196, 196));
	m_label->setPalette(palette);
    auto font = m_label->font();
    font.setPixelSize(11);
    m_label->setFont(font);
	m_label->setText("Scope");
    m_label->move(10, 0);
	m_label->resize(500, 25);

    m_params = new ScopeParams(nullptr,
                               m_scene,
                               static_cast<ScopeWidget *>(m_widget),
                               &scopeLock,
                               this->width(),
                               this->height());
    m_params->triggerMode = TriggerMode::NoTrigger;

    m_scopeData    = new ScopeData(m_params);
	m_lissajouData = new LissajouData(m_params);
	m_poincareData = new PoincareData(m_params);

    m_dataDisplay = (DataDisplay *)m_scopeData;
	m_dataDisplay->show();

	// Default properties
	setProperty("CSQT_type", "scope");
	setZoomx(1.0);
	setZoomy(1.0);
	setProperty("CSQT_dispx", 1.0);
	setProperty("CSQT_dispy", 1.0);
	setProperty("CSQT_mode", "lin");
    setProperty("CSQT_triggermode", "NoTrigger");
	// Optional audio channel to monitor instead of the audio output. The value
	// is the name of a Csound audio channel (created from the orchestra with
	// e.g. "chnset asignal, \"name\""). "channel2" is a friendlier alias of the
	// canonical "objectName2", so it can be set from Csound via
	// outvalue "<scope channel>/channel2", "myaudio".
	setProperty("CSQT_objectName2", QString());
	setProperty("CSQT_channel2", QString());

	// Release the monitored audio channel when the widget is deleted at
	// runtime (the engine is still alive here; only teardown skips this).
	connect(this, &QuteWidget::deleteThisWidget, this, [this](QuteWidget *) {
		if (m_monitor != nullptr && m_params != nullptr && m_params->ud != nullptr
		        && m_params->ud->csEngine != nullptr) {
			m_params->ud->csEngine->releaseAudioMonitor(m_monitor);
			m_monitor = nullptr;
		}
	});
}

QuteScope::~QuteScope()
{
	// Note: the monitor is not released here. During document teardown the
	// engine is destroyed before its widgets, so touching m_params->ud would be
	// a use-after-free; the engine frees all monitors in its own destructor.
	delete m_poincareData;
	delete m_lissajouData;
	delete m_scopeData;
	delete m_params;
}

QuteWidgetType QuteScope::getWidgetTypeID() { return QuteWidgetType::SCOPE; } 


TriggerMode triggerNameToMode(QString s) {
    if(s == "NoTrigger")
        return TriggerMode::NoTrigger;
    else if(s =="TriggerUp")
        return TriggerMode::TriggerUp;
    else
        return TriggerMode::NoTrigger;
}

QString triggerModeToName(TriggerMode t) {
    if(t == TriggerMode::NoTrigger)
        return "NoTrigger";
    else if(t == TriggerMode::TriggerUp)
        return "TriggerUp";
    else
        return QString();
}


QString QuteScope::getWidgetLine()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	QString line = "ioGraph {" + QString::number(x()) + ", " + QString::number(y()) + "} ";
	line += "{"+ QString::number(width()) +", "+ QString::number(height()) +"} ";
	line += property("CSQT_type").toString() + " " + QString::number(zoomx(), 'f', 6) + " ";
	line += QString::number((int) m_value) + " ";
	line += m_channel;
	//   qDebug("QuteScope::getWidgetLine() %s", line.toStdString().c_str());
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return line;
}

QString QuteScope::getWidgetXmlText()
{
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif

	s.writeTextElement("objectName2", m_channel2);
	s.writeTextElement("value", QString::number(m_value, 'f', 8));
	s.writeTextElement("type", property("CSQT_type").toString());
	s.writeTextElement("zoomx", QString::number(zoomx(), 'f', 8));
	s.writeTextElement("zoomy", QString::number(zoomy(), 'f', 8));
	s.writeTextElement("dispx", QString::number(property("CSQT_dispx").toDouble(), 'f', 8));
	s.writeTextElement("dispy", QString::number(property("CSQT_dispy").toDouble(), 'f', 8));
    s.writeTextElement("mode",  QString::number(property("CSQT_mode").toDouble(), 'f', 8));
    s.writeTextElement("triggermode", property("CSQT_triggermode").toString());
	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

QString QuteScope::getWidgetType()
{
	return QString("BSBScope");
}

void QuteScope::setType(QString type)
{
	updateLabel();
	m_dataDisplay->hide();
	if (type == "scope") {
		m_dataDisplay = (DataDisplay *)m_scopeData;
	}
	else if (type == "lissajou") {
		m_dataDisplay = (DataDisplay *)m_lissajouData;
	}
	else if (type == "poincare") {
		m_dataDisplay = (DataDisplay *)m_poincareData;
	}
	m_dataDisplay->show();
}

void QuteScope::setValue(double value)
{
	QuteWidget::setValue(value);
	updateLabel();
}

void QuteScope::setUd(CsoundUserData *ud)
{
	m_params->ud = ud;
}

void QuteScope::updateLabel()
{
	QString chan;
	if (!m_channel2.isEmpty()) {
		// Monitoring a named audio channel instead of the output.
		chan = m_channel2;
	}
	else if ((int) m_value < 0) {
        chan = tr("all", "meaning 'all' channels in scope, 4 letter max");
	}
	else if ((int) m_value <= 0) {
        chan = tr("None", "meaning 'no' channels in scope, 4 letter max");
	}
	else {
		chan =  QString::number((int) m_value );
	}
	m_label->setText(tr("Scope ch:") + chan);
}


bool QuteScope::applyProperty(const QString &name)
{
	if (name == "CSQT_value") {
		setValue(property("CSQT_value").toDouble());
		return true;
	}
	if (name == "CSQT_type") {
		setType(property("CSQT_type").toString());
		return true;
	}
	if (name == "CSQT_objectName2" || name == "CSQT_channel2") {
		const QByteArray key = name.toLatin1();
		const QString name2 = property(key.constData()).toString();
		setProperty("CSQT_objectName2", name2);
		setProperty("CSQT_channel2", name2);
		m_channel2 = name2;
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteScope::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
	// Keep the "channel2" alias in sync with the canonical objectName2.
	setProperty("CSQT_channel2", m_channel2);
	setType(property("CSQT_type").toString());
	setValue(property("CSQT_value").toDouble());
    m_params->triggerMode = triggerNameToMode(property("CSQT_triggermode").toString());
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
	layout->addWidget(typeComboBox, 6, 1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Channel");
	layout->addWidget(label, 6, 2, Qt::AlignRight|Qt::AlignVCenter);
	channelBox = new QComboBox(dialog);
	channelBox->addItem("all", QVariant((int) -255));
    int maxChannels = 16;
    if(m_params->ud != nullptr && m_params->ud->csEngine->isRunning()) {
        maxChannels = m_params->ud->numChnls;
    }
    for(int i=1; i <= maxChannels; i++) {
        channelBox->addItem(QString::number(i), QVariant((int) i));
    }
    channelBox->addItem("none", QVariant((int) 0));
	layout->addWidget(channelBox, 6, 3, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(tr("Audio Channel"));
	label->setToolTip(tr("Name of a Csound audio channel (created with e.g. "
	                     "chnset asignal, \"name\") to monitor instead of the "
	                     "audio output. Leave empty to scope the output."));
	layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);
	name2LineEdit = new QLineEdit(dialog);
	name2LineEdit->setToolTip(label->toolTip());
	layout->addWidget(name2LineEdit, 7, 1, 1, 3, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Zoom X");
	layout->addWidget(label, 8, 0, Qt::AlignRight|Qt::AlignVCenter);
	zoomxBox = new QDoubleSpinBox(dialog);
	zoomxBox->setRange(1, 20);
	layout->addWidget(zoomxBox, 8, 1, Qt::AlignLeft|Qt::AlignVCenter);
	label = new QLabel(dialog);
	label->setText("Zoom Y");
	layout->addWidget(label, 8, 2, Qt::AlignRight|Qt::AlignVCenter);
	zoomyBox = new QDoubleSpinBox(dialog);
	zoomyBox->setRange(1, 20);
	layout->addWidget(zoomyBox, 8, 3, Qt::AlignLeft|Qt::AlignVCenter);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	typeComboBox->setCurrentIndex(typeComboBox->findData(QVariant(property("CSQT_type").toString())));
	channelBox->setCurrentIndex(channelBox->findData(QVariant((int) m_value)));
	name2LineEdit->setText(getChannel2Name());
	zoomxBox->setValue(zoomx());
	zoomyBox->setValue(zoomy());

    label = new QLabel("Trigger");
    layout->addWidget(label, 9, 0, Qt::AlignRight|Qt::AlignVCenter);
    triggerBox = new QComboBox(dialog);
    triggerBox->addItem("No Trigger", "NoTrigger");
    triggerBox->addItem("Trigger Up", "TriggerUp");
    triggerBox->setCurrentIndex(triggerBox->findData(property("CSQT_triggermode").toString()));
    layout->addWidget(triggerBox, 9, 1, Qt::AlignLeft|Qt::AlignVCenter);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
}

void QuteScope::applyProperties()
{
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	setProperty("CSQT_type", typeComboBox->itemData(typeComboBox->currentIndex()).toString());
	setZoomx(zoomxBox->value());
	setZoomy(zoomyBox->value());
	setProperty("CSQT_value", channelBox->itemData(channelBox->currentIndex()).toInt());
	const QString monitorChannel = name2LineEdit != nullptr ? name2LineEdit->text().trimmed() : QString();
	setProperty("CSQT_objectName2", monitorChannel);
	setProperty("CSQT_channel2", monitorChannel);
    auto triggerModeStr = triggerBox->currentData().toString();
    setProperty("CSQT_triggermode", triggerModeStr);
    m_params->triggerMode = triggerNameToMode(triggerModeStr);
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
    //Must be last to make sure the widgetChanged signal is last
    QuteWidget::applyProperties();
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

void QuteScope::updateMonitor()
{
    CsoundUserData *ud = m_params->ud;
    if (ud == nullptr || ud->csEngine == nullptr) {
        return;
    }
    if (m_channel2 == m_activeMonitorName) {
        return;
    }
    if (m_monitor != nullptr) {
        ud->csEngine->releaseAudioMonitor(m_monitor);
        m_monitor = nullptr;
    }
    m_activeMonitorName = m_channel2;
    if (!m_activeMonitorName.isEmpty()) {
        m_monitor = ud->csEngine->acquireAudioMonitor(m_activeMonitorName);
    }
    updateLabel();
}

void QuteScope::updateData()
{
    CsoundUserData *ud = m_params->ud;
    if (ud == nullptr) {
        return;
    }
    updateMonitor();
    RingBuffer *buffer = &ud->audioOutputBuffer;
    int numChnls = ud->numChnls;
    int channel = (int) m_value;
    if (m_monitor != nullptr) {
        // Display the monitored mono audio channel instead of the output.
        buffer = &m_monitor->buffer;
        numChnls = 1;
        channel = 1;
    }
    m_dataDisplay->updateData(buffer, numChnls, channel,
                              zoomx(),
                              zoomy(),
                              static_cast<ScopeWidget *>(m_widget)->freeze);
}

ScopeItem::ScopeItem(int width, int height)
{
	m_width = width;
	m_height = height;
}

void ScopeItem::paint(QPainter *p,
                      const QStyleOptionGraphicsItem */*option*/,
                      QWidget */*widget*/)
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
    curve->setPen(QPen(Qt::green, 0));
    curve->setPen(QPen(QColor(64, 255, 64), 0));   // "#40FF40"

	curve->hide();
	m_params->scene->addItem(curve);
}

void ScopeData::resize()
{
	curveData.resize(m_params->width + 2);
}

void ScopeData::updateData(RingBuffer *buffer, int numChnls, int channel,
                           double zoomx, double zoomy, bool freeze)
{
	CsoundUserData *ud = m_params->ud;
	int width = m_params->width;
	int height = m_params->height;
    if (ud == 0 || !ud->csEngine->isRunning() )
		return;
	if (freeze)
		return;
	double value;
	MYFLT newValue;
    if (channel == 0 || channel > numChnls ) {
        return;
	}
	channel = (channel < 0 ? -1: channel - 1);
#ifdef  USE_WIDGET_MUTEX
    //FIXME is this locking needed, or should a separate locking mechanism be implemented?
    QReadWriteLock *mutex = m_params->mutex;
	mutex->lockForWrite();
#endif
    // FIXME how to make sure the buffer is read before it is flushed when recorded?
    // Have another buffer?
	buffer->lock();
	QList<MYFLT> list = buffer->buffer;
	buffer->unlock();
	long listSize = list.size();
	double factor = numChnls * zoomx;
	const long span = (long)(width * factor);
	auto wrapIndex = [listSize](long v) {
		v %= listSize;
		if (v < 0) {
			v += listSize;
		}
		return v;
	};
	// Anchor the window at the newest samples. currentPos points just past the
	// most recent sample, so starting there would display the oldest data in the
	// ring (adding a delay of the whole buffer).
	long offset = wrapIndex(buffer->currentPos - span);
    long maxFrames = width;

    if(m_params->triggerMode == TriggerMode::TriggerUp) {
		// Look for the most recent rising edge in the window one span before the
		// newest samples, so the triggered window still contains a full span of
		// already-written samples (no wrap-around discontinuity at its end).
		const long searchStart = wrapIndex(buffer->currentPos - 2 * span);
		long trigIndex = -1;
		double lastValue = 1.0;
		if(channel >= 0) {
			for(int i=0; i < maxFrames; i++) {
				int idx = (int)((searchStart + (long)(i*numChnls*zoomx) + channel) % listSize);
				double value = list[idx];
				if(value >= 0 && lastValue < 0) {
					trigIndex = (long)idx - channel;
					break;
				}
				lastValue = value;
			}
		}
		else {
			for(int i=0; i < maxFrames; i++) {
				int baseidx = (int)((searchStart + (long)(i*numChnls*zoomx)) % listSize);
				double value = 0;
				for(int chan = 0; chan < numChnls; chan++) {
					double newValue = list[(baseidx+chan) % listSize];
					if(fabs(newValue) > fabs(value))
						value = newValue;
				}
				if(value >= 0 && lastValue < 0) {
					trigIndex = baseidx;
					break;
				}
				lastValue = value;
			}

		}
		if (trigIndex >= 0) {
			offset = wrapIndex(trigIndex);
		}
    }
    int halfheight = height/2;
    if(channel >= 0) {
        for(int i = 0; i < maxFrames; i++) {
            int idx = (int)((offset+channel+ (int)(i*factor)) % listSize);
            value = (double) list[idx];
            curveData[i+1] = QPoint(i, -zoomy*value*halfheight);
        }
    } else {
        for(int i = 0; i < maxFrames; i++) {
            value = 0;
            for(int chan = 0; chan < numChnls; chan++) {
                int idx = (int)((offset+chan+ (int)(i*factor)) % listSize);
                newValue = (double) list[idx];
                if(fabs(newValue) > fabs(value))
                    value = newValue;
            }
            curveData[i+1] = QPoint(i, -zoomy*value*halfheight);
        }

    }


    /*
    for (int i = 0; i < width; i++) {
		value = 0;
        for (int j = 0; j < (int) zoomx; j++) {
			if (channel == -1) {
                // all channels
				newValue = 0;
				for (int k = 0; k < numChnls; k++) {
                    int bufIdx = (int)((((i*zoomx)+j)*numChnls) + offset + k) % listSize;
                    newValue += list[bufIdx];
				}
				newValue /= numChnls;
				if (fabs(newValue) > fabs(value))
					value = -(double) newValue;
			}
			else {
                int bufIdx = (int)((((i*zoomx)+j)*numChnls) + offset + channel) % listSize;
                if (fabs(list[bufIdx]) > fabs(value))
                    value = (double) -list[bufIdx];
			}
		}
        curveData[i+1] = QPoint(i, zoomy*value*height/2);
	}
    */
    // buffer->currentReadPos += width;
    buffer->currentReadPos = (offset + span) % buffer->size;
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
    auto pen = QPen(Qt::green);
    pen.setCosmetic(true);
    curve->setPen(pen);
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

void LissajouData::updateData(RingBuffer *buffer, int numChnls, int channel,
                              double zoomx, double zoomy, bool freeze)
{
	// The decimation factor (zoom) is not used here
	CsoundUserData *ud = m_params->ud;
	int width = m_params->width;
	int height = m_params->height;
    if (ud == nullptr || !ud->csEngine->isRunning())
		return;
	if (freeze)
		return;
	double x, y;
	// We take two consecutives channels, the first one for abscissas and
	// the second one for ordinates
    if (channel == 0 || channel >= numChnls || numChnls < 2) {
        return;
	}
	channel = (channel < 0 ? 0 : channel - 1);
#ifdef  USE_WIDGET_MUTEX
	QReadWriteLock *mutex = m_params->mutex;
	mutex->lockForWrite();
#endif
	buffer->lock();
	QList<MYFLT> list = buffer->buffer;
	buffer->unlock();
	long listSize = list.size();
	// Anchor at the newest samples (see ScopeData::updateData).
	long offset = buffer->currentPos - (long)((long)curveData.size() * numChnls);
	offset %= listSize;
	if (offset < 0) {
		offset += listSize;
	}
	for (int i = 0; i < curveData.size(); i++) {
		int bufferIndex = (int)((i*numChnls) + offset + channel) % listSize;
		x = (double)list[bufferIndex];
        bufferIndex = (bufferIndex + 1) % listSize;
        y = (double) -list[bufferIndex];
		curveData[i] = QPoint(x*width*zoomx/4, y*height*zoomy/4);
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
    curve->setPen(QPen(Qt::green, 0));
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

void PoincareData::updateData(RingBuffer *buffer, int numChnls, int channel,
                              double zoomx, double zoomy, bool freeze)
{
	CsoundUserData *ud = m_params->ud;
	int width = m_params->width;
	int height = m_params->height;
    if (ud == 0 || !ud->csEngine->isRunning() )
		return;
	if (freeze)
		return;
	double value;
    if (channel == 0 || channel > numChnls) {
        return;
	}
	channel = (channel < 0 ? 0 :  channel - 1);
#ifdef  USE_WIDGET_MUTEX
	QReadWriteLock *mutex = m_params->mutex;
	mutex->lockForWrite();
#endif
	buffer->lock();
	QList<MYFLT> list = buffer->buffer;
	buffer->unlock();
	long listSize = list.size();
	// Anchor at the newest samples (see ScopeData::updateData).
	long offset = buffer->currentPos - (long)((long)curveData.size() * zoomx * numChnls);
	offset %= listSize;
	if (offset < 0) {
		offset += listSize;
	}
	for (int i = 0; i < curveData.size(); i++) {
		int bufferIndex = (int)((i*zoomx*numChnls) + offset + channel) % listSize;
		value = (double)list[bufferIndex];
		curveData[i] = QPoint(lastValue*width*zoomx/2, -value*height*zoomy/2);
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

