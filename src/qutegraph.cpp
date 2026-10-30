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

#include "qutegraph.h"
#include "curve.h"
#include "src/types.h"
#include <cmath>
#include <cstring>
#include <QPalette>
#include <QGraphicsOpacityEffect>


#include <QColorDialog>
#include <QTimer>
using namespace Qt::StringLiterals;

namespace {

// Csound may load f-tables asynchronously (e.g. gen 1 reading an audio file),
// so wait before asking the table for its sample rate. If it is not available
// yet, retry with a growing, bounded delay (see qutewaveform.cpp).
const int tableSampleRateSettleMs = 100;
const int tableSampleRatePollMs = 100;
const int tableSampleRateMaxAttempts = 4;

// Colour properties are QColor when they come from the file or the dialog, and
// an "#RRGGBB" string when they are set from Csound with outvalue.
QColor colorFromProperty(const QVariant &value)
{
    QColor color = value.value<QColor>();
    if (!color.isValid())
        color = QColor(value.toString());
    return color;
}

} // namespace


enum CsoundEngineStatus {
    Running=0,
    UserDataNotSet,
    CsoundInstanceNotSet,
    EngineNotSet,
    NotRunning
};


inline CsoundEngineStatus csoundEngineStatus(CsoundUserData *ud) {
    if(ud == nullptr) {
        return CsoundEngineStatus::UserDataNotSet;
    }
    if(ud->csound == nullptr) {
        return CsoundEngineStatus::CsoundInstanceNotSet;
    }
    if(ud->csEngine == nullptr) {
        return CsoundEngineStatus::EngineNotSet;
    }
    if(!ud->csEngine->isRunning()) {
        return CsoundEngineStatus::NotRunning;
    }
    return CsoundEngineStatus::Running;
}


// -----------------------------------------------------------------------------------------

QuteGraph::QuteGraph(QWidget *parent) : QuteWidget(parent)
{
	m_widget = new StackedLayoutWidget(this);
    //  m_widget->setAutoFillBackground(true);
    // m_widget->show();

    m_numticksY = 6;
	m_label = new QLabel(this);
	QPalette palette = m_widget->palette();
    palette.setColor(QPalette::WindowText, QColor(150, 150, 150));
	m_label->setPalette(palette);
    // m_label->setText("");
    m_label->setFont(QFont({"Helvetica", 7}));
    m_label->move(120, -4);
	m_label->resize(500, 25);
    m_label->setFocusPolicy(Qt::NoFocus);

    m_pageComboBox = new QComboBox(this);
    m_pageComboBox->setMinimumWidth(120);
    m_pageComboBox->setMaximumHeight(14);
    m_pageComboBox->setFont(QFont({"Sans", 7}));
    m_pageComboBox->setFocusPolicy(Qt::NoFocus);
    m_pageComboBox->setStyleSheet("QComboBox QAbstractItemView"
                                  "{ min-width: 150px; }");
    // m_pageComboBox->setSizeAdjustPolicy(QComboBox::AdjustToMinimumContentsLength);
    m_pageComboBox->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    m_drawGrid = true;
    m_drawTableInfo = true;
    m_showScrollbars = true;
	canFocus(false);
	connect(m_pageComboBox, SIGNAL(currentIndexChanged(int)),
			this, SLOT(indexChanged(int)));
	polygons.clear();

	QPalette Pal(this->palette());
    // set black background
    Pal.setColor(QPalette::Window, Qt::black); // old was QPalette::Background
    this->setAutoFillBackground(true);
    this->setPalette(Pal);
    this->setStyleSheet("QFrame { border: 0px; }");

	// Default properties
	setProperty("CSQT_zoomx", 1.0);
	setProperty("CSQT_zoomy", 1.0);
	setProperty("CSQT_dispx", 1.0);
	setProperty("CSQT_dispy", 1.0);
	setProperty("CSQT_modex", "auto");
	setProperty("CSQT_modey", "auto");
    setProperty("CSQT_showSelector", true);
    setProperty("CSQT_showGrid", true);
    setProperty("CSQT_showTableInfo", true);
    setProperty("CSQT_showScrollbars", true);
    setProperty("CSQT_enableTables", true);
    setProperty("CSQT_enableDisplays", true);
    // Transitory ("method-like") graph methods (see transitoryProperties()).
    // They are created here so that they can be addressed as
    // "<channel>/<method>"; the values are neither saved nor restored.
    setProperty("CSQT_findfft", "");
    setProperty("CSQT_findaudio", "");
    setProperty("CSQT_findtable", -1);
    setProperty("CSQT_freeze", 0);
    setProperty("CSQT_peakchannel", "");
    m_enableTables = true;
    m_enableDisplays = true;
	setProperty("CSQT_all", true);

    m_showPeak = false;
    m_showPeakCenterFrequency = 1000.0;
    m_showPeakRelativeBandwidth = 0.25;
    m_lastPeakFreq = 0;
    m_frozen = false;
    m_getPeakChannel = "";
    m_peakChannelPtr = nullptr;
    m_ud = nullptr;

    m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
    m_widget->setContextMenuPolicy(Qt::NoContextMenu);
    m_widget->show();

}

QuteWidgetType QuteGraph::getWidgetTypeID() { return QuteWidgetType::GRAPH; } 


QuteGraph::~QuteGraph()
{
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
	s.writeTextElement("zoomx", QString::number(property("CSQT_zoomx").toDouble(), 'f', 8));
	s.writeTextElement("zoomx", QString::number(m_zoomx, 'f', 8));
	s.writeTextElement("zoomy", QString::number(property("CSQT_zoomy").toDouble(), 'f', 8));
	s.writeTextElement("dispx", QString::number(property("CSQT_dispx").toDouble(), 'f', 8));
	s.writeTextElement("dispy", QString::number(property("CSQT_dispy").toDouble(), 'f', 8));
	s.writeTextElement("modex", property("CSQT_modex").toString());
	s.writeTextElement("modey", property("CSQT_modey").toString());
    s.writeTextElement("showSelector",
                       property("CSQT_showSelector").toBool() ? "true" : "false");
    s.writeTextElement("showGrid", property("CSQT_showGrid").toBool() ? "true" : "false");
    s.writeTextElement("showTableInfo",
                       property("CSQT_showTableInfo").toBool() ? "true" : "false");
    s.writeTextElement("showScrollbars",
                       property("CSQT_showScrollbars").toBool() ? "true" : "false");
    s.writeTextElement("enableTables",
                       property("CSQT_enableTables").toBool() ? "true" : "false");
    s.writeTextElement("enableDisplays", m_enableDisplays ? "true" : "false");
	s.writeTextElement("all", property("CSQT_all").toBool() ? "true" : "false");
	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}


QString QuteGraph::getWidgetType() {
    return QString("BSBGraph");
}

void QuteGraph::setWidgetGeometry(int x,int y,int width,int height)
{
	QuteWidget::setWidgetGeometry(x,y,width, height);
	static_cast<StackedLayoutWidget *>(m_widget)->setWidgetGeometry(0,0,width, height);
	int index = static_cast<StackedLayoutWidget *>(m_widget)->currentIndex();
    changeCurve(-2);

    if (index < 0)
		return;
    // changeCurve(index);
}

void QuteGraph::mousePressEvent(QMouseEvent *event) {
    int index = (int)m_value;
    if (index < 0 || index >= graphtypes.size())
        return;
    switch(graphtypes[index]) {
    case GraphType::GRAPH_SPECTRUM: {
        if(event->button() & Qt::LeftButton) {
            // turn on peak detection
            m_showPeakTemp = true;
            m_spectrumPeakMarkers[index]->setVisible(true);
            m_spectrumPeakTexts[index]->setVisible(true);
            m_mouseDragging = true;
            m_lastPeakFreq = 0;
            auto view = getView(index);
            auto curve = curves[index];
            const size_t curveSize = curve->get_size();
            if (curveSize == 0)
                return;
            // event->pos() is in QuteGraph coordinates, while mapToScene()
            // expects viewport coordinates. The view has a frame and the stacked
            // widget may add margins, so map through the viewport explicitly.
            const QPoint viewportPos = view->viewport()->mapFrom(this, event->position().toPoint());
            const auto peakIndex = view->mapToScene(viewportPos).x();
            const auto freq = peakIndex / curveSize * this->m_ud->sampleRate*0.5;
            m_showPeakTempFrequency = freq;
            return;
        }
        break;
    }
    default:
        break;
    }
}

void QuteGraph::mouseReleased() {
    m_mouseDragging = false;
    if(!m_showPeak ) {
        m_lastPeakFreq = 0;
        m_lastTextMarkerY = 0;
        m_lastTextMarkerX = 0;
    }
    m_showPeakTemp = false;
    int index = (int)m_value;    
    if (index < 0 || index >= m_spectrumPeakTexts.size() || index >= m_spectrumPeakMarkers.size()  )
        return;
    m_spectrumPeakTexts[index]->setVisible(m_showPeak);
    // auto scene = getView(index)->scene();
    m_spectrumPeakMarkers[index]->setVisible(m_showPeak);
}

/*
void QuteGraph::mouseMoveEvent(QMouseEvent *event) {
    int index = (int)m_value;
    switch(graphtypes[index]) {
    case GraphType::GRAPH_SPECTRUM: {
        if(!m_mouseDragging)
            return;
        auto peakIndex = getView(index)->mapToScene(event->x(), 0).x();
        auto curveSize = curves[index]->get_size();
        m_showPeakTempFrequency = peakIndex / curveSize * this->m_ud->sampleRate*0.5;
        return;
    }
    default:
        break;
    }
}
*/


void QuteGraph::keyPressEvent(QKeyEvent *event) {
    bool flag;
    int index = m_value;
    if (index < 0 || index >= graphtypes.size())
        return;
    auto graphtype = graphtypes[index];
    switch(event->key()) {
    case Qt::Key_F:
        if(graphtype != GraphType::GRAPH_SPECTRUM)
            return;
        freezeSpectrum(!m_frozen);
        event->accept();
        break;
    case Qt::Key_S:
        flag = !property("CSQT_showSelector").toBool();
        setProperty("CSQT_showSelector", flag?"true":"false");
        if(flag)
            m_pageComboBox->show();
        else
            m_pageComboBox->hide();
        event->accept();
        break;
    case Qt::Key_G:
        flag = !property("CSQT_showGrid").toBool();
        setProperty("CSQT_showGrid", flag?"true":"false");
        m_drawGrid = flag;
        event->accept();
        break;
    case Qt::Key_C:
        flag = !property("CSQT_showTableInfo").toBool();
        setProperty("CSQT_showTableInfo", flag?"true":"false");
        m_drawTableInfo = flag;
        if(flag)
            m_label->show();
        else
            m_label->hide();
        event->accept();
        break;
    case Qt::Key_Plus:
        m_zoomx = m_zoomx * 2;
        setProperty("CSQT_zoomx", m_zoomx);
        applyInternalProperties();
        event->accept();
        break;
    case Qt::Key_Minus:
        setProperty("CSQT_zoomx", qMax(1.0, property("CSQT_zoomx").toDouble()*0.5));
        applyInternalProperties();
        event->accept();
        break;
    case Qt::Key_Z:
        flag = !property("CSQT_showScrollbars").toBool();
        setProperty("CSQT_showScrollbars", flag);
        showScrollbars(flag);
        event->accept();
        break;
    case Qt::Key_H:
        QMessageBox mb;
        mb.setText(tr("<span style=\"font-size : 11pt\">"
                      "<ul>"
                      "<li><code>+</code> : zoom in"
                      "<li><code>-</code> : zoom out"
                      "<li><code>F</code> : toggle freeze (spectrum)"
                      "<li><code>S</code> : toggle Selector"
                      "<li><code>G</code> : toggle Grid"
                      "<li><code>C</code> : toggle table information"
                      "<li><code>Z</code> : toggle Scrollbars"
                      "</ul>"
                      "</span>"
                      ));
        mb.setWindowTitle("Graph Shortcuts");
        mb.exec();
        event->accept();
        break;
    }
}


void QuteGraph::setValue(double value)
{
    QuteWidget::setValue(value);
    // m_value2 = this->getTableNumForIndex(value);
    /*
    if(value < 0) {
        int tabnum = -((int)value);
        int index = this->getIndexForTableNum(tabnum);
        QuteWidget::setValue(index);
    } else {
        QuteWidget::setValue(value);
    }
    */

}

void QuteGraph::refreshWidget()
{
    bool needsUpdate = false;
#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	int index = 0;
	if (m_valueChanged) {
        index = static_cast<int>(m_value);
        if(index < 0) {
            m_value2 = -index;
        } else {
            m_value2 = getTableNumForIndex(index);
        }
        m_value2Changed = false;
		m_valueChanged = false;
		needsUpdate = true;
	}
	else if (m_value2Changed) {
        index = getIndexForTableNum((int)m_value2);
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
        if (index < 0 ||
            index >= curves.size() ||
            curves[index]->get_caption().isEmpty()) {
            // Don't show if curve has no name. Is this likely?
			return;
		}
		//    m_pageComboBox->blockSignals(true);
		//    m_pageComboBox->setCurrentIndex(index);
		//    m_pageComboBox->blockSignals(false);
		changeCurve(index);

	}
    // QComboBox *cb = this->m_pageComboBox;
    // cb->move(this->width() - cb->width(),  this->height()-cb->height());
}

void QuteGraph::createPropertiesDialog()
{
    QLabel *label;
	QuteWidget::createPropertiesDialog();
	dialog->setWindowTitle("Graph");

	channelLabel->setText("Index Channel name =");
	channelLabel->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
	//  nameLineEdit->setText(getChannelName());

    label = new QLabel("F-table Channel name =", dialog);
    layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);
	name2LineEdit = new QLineEdit(dialog);
	name2LineEdit->setText(getChannel2Name());
	name2LineEdit->setMinimumWidth(320);
	layout->addWidget(name2LineEdit, 4,1,1,3, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel("Zoom X", dialog);
    layout->addWidget(label, 8, 0, Qt::AlignRight|Qt::AlignVCenter);
	zoomxBox = new QDoubleSpinBox(dialog);
	zoomxBox->setRange(0.1, 10.0);
	zoomxBox->setDecimals(1);
	zoomxBox->setSingleStep(0.1);
	layout->addWidget(zoomxBox, 8, 1, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel("Zoom Y", dialog);
    layout->addWidget(label, 8, 2, Qt::AlignRight|Qt::AlignVCenter);
	zoomyBox = new QDoubleSpinBox(dialog);
	zoomyBox->setRange(0.1, 10.0);
	zoomyBox->setDecimals(1);
	zoomyBox->setSingleStep(0.1);
	layout->addWidget(zoomyBox, 8, 3, Qt::AlignLeft|Qt::AlignVCenter);

    acceptTablesCheckBox = new QCheckBox(dialog);
    acceptTablesCheckBox->setText("Enable tables");
    acceptTablesCheckBox->setToolTip("Enable the display of tables. Each time a table is "
                                     "creted it will be made available to be selected.\n"
                                     "NB: modifications to a table will not be shown in the "
                                     "graph, use a TablePlot widget for that.\n"
                                     "NB2: If you plan to use the Graph widget to display"
                                     "spectra or signals, uncheck this option");
    acceptTablesCheckBox->setChecked(property("CSQT_enableTables").toBool());
    layout->addWidget(acceptTablesCheckBox, 9, 0, Qt::AlignLeft|Qt::AlignVCenter);

    acceptDisplaysCheckBox = new QCheckBox(dialog);
    acceptDisplaysCheckBox->setText("Enable Displays");
    acceptDisplaysCheckBox->setToolTip("Enable displaying audio signals/spectra. Check this"
                                       "if you plan to use the graph widget to display audio"
                                       "signals and spectra using the opcodes display/dispfft");
    acceptDisplaysCheckBox->setChecked(property("CSQT_enableDisplays").toBool());
    layout->addWidget(acceptDisplaysCheckBox, 9, 1, Qt::AlignLeft|Qt::AlignVCenter);

    showSelectorCheckBox = new QCheckBox("Show Selector", dialog);
    showSelectorCheckBox->setChecked(property("CSQT_showSelector").toBool());
    layout->addWidget(showSelectorCheckBox, 10, 0, Qt::AlignLeft|Qt::AlignVCenter);

    showGridCheckBox = new QCheckBox("Show Grid", dialog);
    showGridCheckBox->setChecked(property("CSQT_showGrid").toBool());
    showGridCheckBox->setToolTip("Show the grid. Has effect only for spectral graphs");
    layout->addWidget(showGridCheckBox, 10, 1, Qt::AlignLeft|Qt::AlignVCenter);

    showTableInfoCheckBox = new QCheckBox("Show Table Information", dialog);
    showTableInfoCheckBox->setCheckState(
                property("CSQT_showTableInfo").toBool()?Qt::Checked:Qt::Unchecked);
    showTableInfoCheckBox->setToolTip("Show the grid. Has effect only for spectral graphs");
    layout->addWidget(showTableInfoCheckBox, 11, 0, Qt::AlignLeft|Qt::AlignVCenter);

    showScrollbarsCheckBox = new QCheckBox("Show Scrollbars", dialog);
    showScrollbarsCheckBox->setChecked(property("CSQT_showScrollbars").toBool());
    layout->addWidget(showScrollbarsCheckBox, 11, 1, Qt::AlignLeft|Qt::AlignVCenter);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	zoomxBox->setValue(property("CSQT_zoomx").toDouble());
	zoomyBox->setValue(property("CSQT_zoomy").toDouble());
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
	setProperty("CSQT_objectName2", name2LineEdit->text());
	setProperty("CSQT_zoomx", zoomxBox->value());
	setProperty("CSQT_zoomy", zoomyBox->value());
    setProperty("CSQT_dispx", 1);
	setProperty("CSQT_dispy", 1);
	setProperty("CSQT_modex", "lin");
	setProperty("CSQT_modey", "lin");
	setProperty("CSQT_all", true);
    setProperty("CSQT_showSelector", showSelectorCheckBox->checkState());
    setProperty("CSQT_showGrid", showGridCheckBox->checkState());
    setProperty("CSQT_showScrollbars", showScrollbarsCheckBox->isChecked());
    setProperty("CSQT_enableTables", acceptTablesCheckBox->isChecked());
    setProperty("CSQT_enableDisplays", acceptDisplaysCheckBox->isChecked());

    m_enableTables = acceptTablesCheckBox->isChecked();
    m_enableDisplays = acceptDisplaysCheckBox->isChecked();

    showTableInfo(showTableInfoCheckBox->checkState());

#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	QuteWidget::applyProperties();
}


int QuteGraph::findCurve(CurveType type, QStringView text) {
    // returns the index or -1 if not found
    for (int i = 0; i < curves.size(); i++) {
        if(curves[i]->get_type() != type)
            continue;
        QString caption = curves[i]->get_caption();
        if (caption.contains(text)) {
            return i;
        }
    }
    return -1;
}

void QuteGraph::findFft(const QString &text)
{
    // Switch the graph to the spectrum curve whose caption contains text
    // (the "findfft" method).
    if (text.isEmpty())
        return;
    const int index = findCurve(CURVE_SPECTRUM, QStringView(text));
    if (index >= 0 && index < curves.size())
        setValue(index);
    else
        qDebug() << "findfft: no spectrum curve matching" << text;
}

void QuteGraph::findAudio(const QString &text)
{
    // Switch the graph to the audio-signal curve whose caption contains text
    // (the waveform display, cf. Csound's "display" opcode; the "findaudio"
    // method).
    if (text.isEmpty())
        return;
    const int index = findCurve(CURVE_AUDIOSIGNAL, QStringView(text));
    if (index >= 0 && index < curves.size())
        setValue(index);
    else
        qDebug() << "findaudio: no audio signal curve matching" << text;
}

void QuteGraph::findTable(int tabnum)
{
    // Switch the graph to the f-table curve with the given table number
    // (the "findtable" method).
    const int index = getIndexForTableNum(tabnum);
    if (index >= 0 && index < curves.size())
        setValue(index);
    else
        qDebug() << "findtable: no curve for table" << tabnum;
}

void QuteGraph::freezeGraph(int status)
{
    // Freeze (status != 0) or unfreeze (status == 0) a spectrum display
    // (the "freeze" method).
    const int index = (int)m_value;
    if (index < 0 || index >= graphtypes.size()
            || graphtypes[index] != GraphType::GRAPH_SPECTRUM) {
        return;
    }
    if (status != 0 && status != 1) {
        qDebug() << "freeze: expected status 0 (unfreeze) or 1 (freeze), got" << status;
        return;
    }
    freezeSpectrum(status == 1);
}

void QuteGraph::setPeakChannel(const QString &channel)
{
    // Name of the control channel the detected peak frequency is written to
    // (the "peakchannel" method).
    if (channel.isEmpty())
        return;
    m_getPeakChannel = channel;
    qDebug() << "peak channel: " << m_getPeakChannel;
    if (m_ud == nullptr || m_ud->csound == nullptr) {
        // Not connected to Csound yet (e.g. while loading a file); the channel
        // pointer is acquired on the next message once Csound is available.
        m_peakChannelPtr = nullptr;
        return;
    }
    cs_float *ptr = nullptr;
    csoundGetChannelPtr(m_ud->csound, (void **) &ptr,
                        m_getPeakChannel.toLocal8Bit().constData(),
                        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL);
    m_peakChannelPtr = ptr;
}

void QuteGraph::changeCurve(int index)
{
    if(curves.size() <= 0)
        return;

    int origRequest = index;
    StackedLayoutWidget *stacked =  static_cast<StackedLayoutWidget *>(m_widget);
    if (index == -1) { // goto last curve
        index = stacked->count() - 1;
	}
	else if (index == -2) { // update curve but don't change which
        if (m_value < 0)
			index = getIndexForTableNum(-m_value);
        else
			index = (int) m_value;
    } else if (index >= stacked->count()) {
        qDebug() << "changeCurve: index out of range. Num indices:"<<stacked->size();
        return;
    }
    else if (stacked->currentIndex() == index) {
        return;
    } else {
        // change curve
        auto view = stacked->currentWidget();
        view->hide();
        stacked->blockSignals(true);
        stacked->setCurrentIndex(index);
        stacked->blockSignals(false);
        m_pageComboBox->blockSignals(true);
        m_pageComboBox->setCurrentIndex(index);
        m_pageComboBox->blockSignals(false);
    }

    if (index < 0  || index >= curves.size()) { // Invalid index
        QDEBUG << "Invalid index" << index;
        return;
    }
    m_value = index;
    switch(graphtypes[index]) {
    case GraphType::GRAPH_FTABLE: {
        int ftable = getTableNumForIndex(index);
        if (m_value2 != ftable) {
            m_value2 = ftable;
            m_value2Changed = true;
        }
        if(m_drawTableInfo) {
            auto curve = curves[index];
            auto text = QString("%1 pts (%2, %3)")
                    .arg(curve->get_size())
                    .arg(curve->get_max(), 0, 'f', 3)
                    .arg(curve->get_min(), 0, 'f', 3);
            m_label->setText(text);
            m_label->show();
        }
        if(origRequest != -2) {
            drawGraph(curves[index], index);
        }
        break;
    }
    case GraphType::GRAPH_SPECTRUM:
        m_value2 = -1;
        m_label->hide();
        break;
    case GraphType::GRAPH_AUDIOSIGNAL:
        m_value2 = -1;
        m_label->hide();
        break;
    }
    scaleGraph(index);

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
    graphtypes.clear();
	polygons.clear();
    m_pathItems.clear();
    m_axisItems.clear();
	m_gridlines.clear();
    m_gridTextsX.clear();
    m_gridTextsY.clear();
    m_gridCache.clear();
    m_spectrumPeakTexts.clear();
    m_spectrumPeakMarkers.clear();
    m_showPeak = false;
    m_showPeakTemp = false;
    m_showPeakCenterFrequency = 1000;
    //  curveLock.unlock();
}

void QuteGraph::addCurve(Curve * curve)
{
    QMutexLocker locker(&curveLock);
    Q_ASSERT(curve != nullptr);
    GraphType graphType;
    QGraphicsView *view;
    CurveType type = curve->get_type();
    if(type == CURVE_SPECTRUM) {
        if(!m_enableDisplays)
            return;
        graphType = GraphType::GRAPH_SPECTRUM;
        auto spectralView = new SpectralView(m_widget);
        view = static_cast<QGraphicsView*>(spectralView);
        connect(spectralView, SIGNAL(mouseReleased()), this, SLOT(mouseReleased()));
        view->setRenderHint(QPainter::Antialiasing);
    } else if(type == CURVE_FTABLE) {
        if(!m_enableTables)
            return;
        graphType = GraphType::GRAPH_FTABLE;
        view = new QGraphicsView(m_widget);
        view->setRenderHint(QPainter::Antialiasing);
    } else {
        if(!m_enableDisplays)
            return;
        graphType = GraphType::GRAPH_AUDIOSIGNAL;
        view = new QGraphicsView(m_widget);
    }
    QGraphicsScene *scene = new QGraphicsScene(view);
	view->setContextMenuPolicy(Qt::NoContextMenu);
    view->setScene(scene);
    view->setObjectName(curve->get_caption());
    auto scrollbarPolicy = property("CSQT_showScrollbars").toBool() ? Qt::ScrollBarAsNeeded
                                                                   : Qt::ScrollBarAlwaysOff;
    view->setHorizontalScrollBarPolicy(scrollbarPolicy);
    view->show();
    scene->setBackgroundBrush(QBrush(Qt::black));
    QVector<QGraphicsLineItem *> gridLinesVector;
    QVector<QGraphicsTextItem *> gridTextVectorX;
    QVector<QGraphicsTextItem *> gridTextVectorY;
    qreal freqStep = 1000.0;
    // Max. samplerate. We generate a grid for this and can make lines/labels visible or
    // not depending on the actual sample rate
    qreal sr = 96000;
    int numTicksX = (int)(sr*0.5 / freqStep);
    int numTicksY = m_numticksY;
    auto gridpen = QPen(QColor(90, 90, 90));
    auto gridpen2 = QPen(QColor(60, 60, 60));
    gridpen.setCosmetic(true);
    gridpen2.setCosmetic(true);

    auto marker = new QGraphicsRectItem();
    marker->setVisible(false);
    auto markerpen = QPen(QColor(250, 250, 250));
    markerpen.setCosmetic(true);
    marker->setPen(markerpen);
    marker->setBrush(QBrush(QColor(255, 255, 255, 100)));
    m_spectrumPeakMarkers.append(marker);
    scene->addItem(marker);
    auto markerText = new QGraphicsTextItem();
    markerText->setDefaultTextColor(markerpen.color());
    markerText->setVisible(false);
    markerText->setFlags(QGraphicsItem::ItemIgnoresTransformations);
    markerText->setFont(QFont("Sans", 8));
    scene->addItem(markerText);
    m_spectrumPeakTexts.append(markerText);
    m_dbRange = 100;
    auto gridTextFont = QFont("Sans", 6);

    if(graphType == GraphType::GRAPH_SPECTRUM) {
        for (int i = 0 ; i < numTicksY; i++) {
            // 0 - 0db, 5 -> 100 dB (6:120
            QGraphicsLineItem *gridLine = new QGraphicsLineItem();
            gridLine->setPen(gridpen);
            scene->addItem(gridLine);
            gridLinesVector.append(gridLine);
            QGraphicsTextItem *gridText = new QGraphicsTextItem();
            gridText->setDefaultTextColor(Qt::gray);
            gridText->setFlags(QGraphicsItem::ItemIgnoresTransformations);
            int dbs = round(float(i)/numTicksY * 120.0);
            gridText->setHtml(QString("<div style=\"background:#000000;\">-%1 </p>"
                                      ).arg(dbs));
            gridText->setFont(gridTextFont);
            gridText->setVisible(false);
            scene->addItem(gridText);
            gridTextVectorY.append(gridText);

        }

        for (int i = 0; i < numTicksX; i++) {
            QGraphicsLineItem *gridLine = new QGraphicsLineItem();
            gridLine->setPen(i%2 == 0 ? gridpen : gridpen2);
            scene->addItem(gridLine);
            gridLinesVector.append(gridLine);
            QGraphicsTextItem *gridText = new QGraphicsTextItem();
            gridText->setDefaultTextColor(Qt::gray);
            gridText->setFlags(QGraphicsItem::ItemIgnoresTransformations);
            if (i > 0 && i%2==0) {
                // double kHz = i*((numTicksX-1.0)/numTicksX) * 2.0;
                double kHz = i * freqStep / 1000.0 ;
                if(i%10==0)
                    gridText->setHtml(
                                QString("<div style=\"background:#000000;\">%1k</p>")
                                .arg(kHz, 2, 'f', 1));
                else
                    gridText->setHtml(
                                QString("<div style=\"background:#000000;\">%1</p>")
                                .arg(kHz, 2, 'f', 1));

            }
            gridText->setFont(gridTextFont);
            gridText->setVisible(false);
            scene->addItem(gridText);
            gridTextVectorX.append(gridText);
        }
    }

    m_gridlines.append(gridLinesVector);
    m_gridTextsX.append(gridTextVectorX);
    m_gridTextsY.append(gridTextVectorY);
    m_gridCache.append(GridCache());

    graphtypes.append(graphType);

    QGraphicsPolygonItem * item = new QGraphicsPolygonItem();
    auto graphPen = QPen(Qt::yellow);
    graphPen.setCosmetic(true);
    item->setPen(graphPen);
    item->show();
    polygons.append(item);
    scene->addItem(item);

    // Persistent path items for signal/ftable curves (see header). The axis is
    // added first so the data path is drawn on top.
    auto axisItem = new QGraphicsPathItem();
    axisItem->setPen(QPen(QColor(40, 40, 40), 0));
    scene->addItem(axisItem);
    m_axisItems.append(axisItem);

    auto pathItem = new QGraphicsPathItem();
    auto pathPen = QPen(QColor(255, 193, 7), 0);
    pathPen.setCosmetic(true);
    pathItem->setPen(pathPen);
    scene->addItem(pathItem);
    m_pathItems.append(pathItem);

    view->setResizeAnchor (QGraphicsView::NoAnchor);
    // view->setFocusPolicy(Qt::NoFocus);
	m_pageComboBox->blockSignals(true);
    QString curveTitle = curve->get_caption().trimmed();
    if(curveTitle.endsWith(":"))
        curveTitle = curveTitle.mid(0, curveTitle.size()-1);
    m_pageComboBox->addItem(curveTitle);
    // m_pageComboBox->addItem(curve->get_title());
	m_pageComboBox->blockSignals(false);
	//  curveLock.lock();
	static_cast<StackedLayoutWidget *>(m_widget)->addWidget(view);
    curves.append(curve);
    if (m_value == curves.size() - 1) {
        // If new curve created corresponds to current stored value
		changeCurve(m_value);
	}
}

int QuteGraph::getCurveIndex(Curve * curve)
{
    Q_ASSERT(curve != nullptr);
	int index = -1;
	for (int i = 0; i < curves.size(); i++) {
		if (curves[i] == curve) {
			index = i;
			break;
		}
	}
    return index;
}

QGraphicsView * QuteGraph::getView(int index) {
    StackedLayoutWidget *widget_ = static_cast<StackedLayoutWidget *>(m_widget);
    QGraphicsView *view = static_cast<QGraphicsView *>(widget_->widget(index));
    return view;
}

void QuteGraph::drawGraph(Curve *curve, int index) {
    switch(curve->get_type()) {
    // case GraphType::GRAPH_FTABLE:
    case CurveType::CURVE_FTABLE:
        drawFtablePath(curve, index);
        scaleGraph(index);
        break;
    // case GraphType::GRAPH_SPECTRUM:
    case CurveType::CURVE_SPECTRUM:
        // view->setRenderHint(QPainter::Antialiasing);
        drawSpectrum(curve, index);
        // drawSpectrumPath(curve, index);
        changeCurve(-2); //update curve
        break;
    case CurveType::CURVE_AUDIOSIGNAL:
    // case GraphType::GRAPH_AUDIOSIGNAL:
        // drawSignal(curve, index);
        drawSignalPath(curve, index);
        changeCurve(-2); //update curve
        break;
    }
}

void QuteGraph::setCurveData(Curve * curve)
{
    Q_ASSERT(curve != nullptr);
	int index = getCurveIndex(curve);

    if (index >= curves.size() ||
        index < 0 ||
        index != m_value) {
        return;
	}

    /*
    if(!m_enableTables && graphtypes[index] == GraphType::GRAPH_FTABLE)
        return;
    */

    auto view = getView(index);

    // Refitting curves in view resets the scrollbar so we need the previous value
    int viewPosx = view->horizontalScrollBar()->value();
	int viewPosy = view->verticalScrollBar()->value();

    drawGraph(curve, index);
    view->horizontalScrollBar()->setValue(viewPosx);
    view->verticalScrollBar()->setValue(viewPosy);
}

QStringList QuteGraph::transitoryProperties() const
{
	// Graph "methods": addressed as "<channel>/<method>", applied immediately
	// and never written to or read from the file.
	return { "findfft", "findaudio", "findtable", "freeze", "peakchannel" };
}

bool QuteGraph::applyProperty(const QString &name)
{
	if (name == "CSQT_showGrid") {
		m_drawGrid = property("CSQT_showGrid").toBool();
		update();
		return true;
	}
	if (name == "CSQT_showTableInfo") {
		m_drawTableInfo = property("CSQT_showTableInfo").toBool();
		update();
		return true;
	}
	if (name == "CSQT_showSelector") {
		if (property("CSQT_showSelector").toBool())
			m_pageComboBox->show();
		else
			m_pageComboBox->hide();
		return true;
	}
	if (name == "CSQT_findfft") {
		findFft(property("CSQT_findfft").toString());
		return true;
	}
	if (name == "CSQT_findaudio") {
		findAudio(property("CSQT_findaudio").toString());
		return true;
	}
	if (name == "CSQT_findtable") {
		findTable(property("CSQT_findtable").toInt());
		return true;
	}
	if (name == "CSQT_freeze") {
		freezeGraph(property("CSQT_freeze").toInt());
		return true;
	}
	if (name == "CSQT_peakchannel") {
		setPeakChannel(property("CSQT_peakchannel").toString());
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteGraph::setWidgetEnabled(bool enabled)
{
	QuteWidget::setWidgetEnabled(enabled);
	// The graph is made of child graphics views, so a paint overlay on the
	// container would be painted underneath them. A (cheap, only while disabled)
	// opacity effect greys the whole subtree instead.
	if (enabled) {
		if (m_widget->graphicsEffect()) {
			m_widget->setGraphicsEffect(nullptr);
		}
	} else if (!m_widget->graphicsEffect()) {
		auto *effect = new QGraphicsOpacityEffect(m_widget);
		effect->setOpacity(0.35);
		m_widget->setGraphicsEffect(effect);
	}
}

void QuteGraph::applyInternalProperties()
{
	QuteWidget::applyInternalProperties();
    if(property("CSQT_showSelector").toBool()) {
        m_pageComboBox->show();
    } else {
        m_pageComboBox->hide();
    }
	changeCurve(-2);  // Redraw
    m_drawGrid = property("CSQT_showGrid").toBool();
    m_drawTableInfo = property("CSQT_showTableInfo").toBool();
    m_zoomx = property("CSQT_zoomx").toDouble();
    m_zoomy = property("CSQT_zoomy").toDouble();
    showScrollbars(property("CSQT_showScrollbars").toBool());
}

void QuteGraph::drawFtablePath(Curve *curve, int index) {
    Q_ASSERT(index >= 0);
    int curveSize = curve->get_size();

    auto rect = this->rect();
    int width = rect.width();
    int step = curveSize / width;
    if(step == 0)
        step = 1;

    QPainterPath path;
    for (int i = 0; i < curveSize; i+=step) {
        double value = curve->get_data(i);
        path.lineTo(QPointF(i, -value));
    }
    auto pen = QPen(QColor(255, 255, 50), 0);
    if(step > 1) {
        pen.setWidth(0);
    }
    m_pathItems[index]->setPath(path);
    m_pathItems[index]->setPen(pen);
}


size_t QuteGraph::spectrumGetPeak(Curve *curve, double freq, double bandwidth) {
    qreal sr = this->getSr(44100.);
    qreal nyquist = sr * 0.5;
    size_t curveSize = curve->get_size();
    qreal minfreq = freq - bandwidth*0.5;
    qreal maxfreq = freq + bandwidth*0.5;
    minfreq = qMax(1.0, minfreq);
    maxfreq = qMax(minfreq, maxfreq);
    size_t index0 = (size_t)(minfreq / nyquist * curveSize);
    index0 = index0 < curveSize - 1 ? index0 : curveSize - 1;
    size_t index1 = (size_t)(maxfreq / nyquist * curveSize);
    index1 = index1 < curveSize - 1 ? index1 : curveSize - 1;
    qreal maxvalue = 0;
    size_t maxindex = 0;
    if(!m_frozen) {
        for(auto i=index0; i<index1; i++) {
            auto data = curve->get_data(i);
            if (data > maxvalue) {
                maxvalue = data;
                maxindex = i;
            }
        }
    }
    else {
        for(auto i=index0; i<index1; i++) {
            auto data = frozenCurve[i];
            if (data > maxvalue) {
                maxvalue = data;
                maxindex = i;
            }
        }
    }
    if(maxindex > curveSize - 1) {
        qDebug() << "spectrum peak: wrong index " << maxindex;
        return 0;
    }
    return maxindex;
}

size_t QuteGraph::spectrumGetNearestPeak(Curve *curve, double freq, double windowHz, int step) {
    const qreal nyquist = this->getSr(44100.) * 0.5;
    const int curveSize = int(curve->get_size());
    if (curveSize < 3 || nyquist <= 0.0)
        return 0;

    step = qMax(1, step);
    const double clickBin = qBound(0.0, freq / nyquist * curveSize, double(curveSize - 1));
    const double halfWindowHz = qMax(windowHz * 0.5, nyquist / curveSize);
    const double halfWindowBins = halfWindowHz / nyquist * curveSize;

    const int firstBin = qMax(1, int(std::floor(clickBin - halfWindowBins)));
    const int lastBin = qMin(curveSize - 2, int(std::ceil(clickBin + halfWindowBins)));
    if (firstBin > lastBin)
        return size_t(qBound(0.0, std::round(clickBin), double(curveSize - 1)));

    auto ampAt = [&](int i) -> double {
        if (m_frozen && i >= 0 && i < frozenCurve.size())
            return double(frozenCurve[i]);
        return double(curve->get_data(i));
    };

    // Use the same per-pixel envelope as drawSpectrum(): when several FFT bins
    // are drawn into one pixel, only the loudest bin of that column can be a
    // peak. This keeps invisible noise wiggles from being selected.
    struct Column {
        int colStart;
        int bin;
        double amp;
    };
    QVector<Column> columns;
    auto addColumn = [&](int colStart) {
        const int colEnd = qMin(colStart + step, curveSize);
        int bestBin = colStart;
        double bestAmp = ampAt(colStart);
        for (int i = colStart + 1; i < colEnd; ++i) {
            const double amp = ampAt(i);
            if (amp > bestAmp) {
                bestAmp = amp;
                bestBin = i;
            }
        }
        columns.append(Column{colStart, bestBin, bestAmp});
    };

    const int firstColumnStart = (firstBin / step) * step;
    const int lastColumnStart = (lastBin / step) * step;
    // Include one column on each side so a column at the window edge is only a
    // local maximum if it is also one in the full displayed envelope.
    const int scanStart = qMax(0, firstColumnStart - step);
    const int scanEnd = qMin(curveSize - 1, lastColumnStart + step);
    for (int colStart = scanStart; colStart <= scanEnd; colStart += step)
        addColumn(colStart);
    if (columns.isEmpty())
        return size_t(qBound(0.0, std::round(clickBin), double(curveSize - 1)));

    const int candidateFirst = (firstColumnStart - scanStart) / step;
    const int candidateLast = (lastColumnStart - scanStart) / step;

    // Weight a peak by its distance to the click: 1 at the click, 0 at the
    // window edge. The amplitude is linear, like the values in Curve.
    auto scoreOf = [&](const Column &column, double &distanceFactor) -> double {
        const double binFreq = double(column.bin) / curveSize * nyquist;
        const double t = qBound(0.0, qAbs(binFreq - freq) / halfWindowHz, 1.0);
        distanceFactor = 1.0 - t;
        return column.amp * distanceFactor;
    };

    const double epsilon = 1e-12;
    double bestScore = -1.0;
    double bestDistanceFactor = 2.0;
    double bestAmp = -1.0;
    int bestBin = -1;

    auto consider = [&](const Column &column) {
        double distanceFactor = 0.0;
        const double score = scoreOf(column, distanceFactor);
        if (score > bestScore + epsilon
            || (qAbs(score - bestScore) <= epsilon && distanceFactor > bestDistanceFactor + epsilon)
            || (qAbs(score - bestScore) <= epsilon
                && qAbs(distanceFactor - bestDistanceFactor) <= epsilon
                && column.amp > bestAmp)) {
            bestScore = score;
            bestDistanceFactor = distanceFactor;
            bestAmp = column.amp;
            bestBin = column.bin;
        }
    };

    // Prefer local maxima of the displayed envelope. Only columns inside the
    // search window are candidates; the extra columns only serve as neighbours.
    int localMaxima = 0;
    const int columnCount = int(columns.size());
    for (int i = candidateFirst; i <= candidateLast; ++i) {
        const bool leftOk = i == 0 || columns[i].amp >= columns[i - 1].amp;
        const bool rightOk = i == columnCount - 1 || columns[i].amp > columns[i + 1].amp;
        if (leftOk && rightOk) {
            consider(columns[i]);
            ++localMaxima;
        }
    }

    // Clicking on a slope (or a window narrower than three columns) has no
    // local maximum: fall back to the best-scoring column in the window.
    if (localMaxima == 0) {
        for (int i = candidateFirst; i <= candidateLast; ++i)
            consider(columns[i]);
    }

    // All candidates were at the window edge (weight 0): use the nearest one.
    if (bestBin < 0 || bestScore <= 0.0) {
        int nearest = -1;
        double nearestDistance = 0.0;
        for (int i = candidateFirst; i <= candidateLast; ++i) {
            const double binFreq = double(columns[i].bin) / curveSize * nyquist;
            const double distance = qAbs(binFreq - freq);
            if (nearest < 0 || distance < nearestDistance - epsilon
                || (qAbs(distance - nearestDistance) <= epsilon
                    && columns[i].amp > columns[nearest].amp)) {
                nearest = i;
                nearestDistance = distance;
            }
        }
        if (nearest >= 0)
            bestBin = columns[nearest].bin;
    }

    if (bestBin < 0)
        bestBin = int(qBound(0.0, std::round(clickBin), double(curveSize - 1)));
    return size_t(bestBin);
}

QString mton(double midinote) {
    //                                C  C# D D#  E  F  F# G G# A Bb B
    static const int _pc2idx[] = {2, 2, 3, 3, 4, 5, 5, 6, 6, 0, 1, 1};
    static const int _pc2alt[] = {0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 2, 0};
    static const char _alts[] = " #b";

    QString dst = "";
    double m = midinote;

    int octave = (int) (m / 12 - 1);
    int pc = (int)m % 12;
    int cents = round((m - floor(m)) * 100.0);
    int sign;

    if (cents == 0) {
        sign = 0;
    } else if (cents <= 50) {
        sign = 1;
    } else {
        cents = 100 - cents;
        sign = -1;
        pc += 1;
        if (pc == 12) {
            pc = 0;
            octave += 1;
        }
    }
    if(octave >= 0) {
        dst.append(QChar('0' + octave)); // Qt6 CHECK! this might be wrong!
    } else {
        dst.append('-');
        dst.append(QChar('0' - octave));
    }
    dst.append(QChar('A' + _pc2idx[pc]));
    int32_t alt = _pc2alt[pc];
    if(alt > 0) {
        dst.append(_alts[alt]);
    }
    if(sign == 1) {
        dst.append('+');
        if(cents != 50) {
            dst += QString::number(cents);
        }
    } else if(sign == -1) {
        dst.append('-');
        if(cents != 50) {
            dst += QString::number(cents);
        }
    }
    return dst;
}


QPoint quantizePoint(int x, int y, int resx, int resy) {
    x = static_cast<int>(round((double)x / resx) * resx);
    y = static_cast<int>(round((double)y / resy) * resy);
    return QPoint(x, y);
}

void QuteGraph::freezeSpectrum(bool status) {
    int index = m_value;
    auto curve = curves[index];
    if(status) {
        m_frozen = true;
        frozenCurve.resize(curve->get_size());
        for(size_t i=0; i < curve->get_size(); i++) {
            frozenCurve[i] = curve->get_data(i);
        }
    } else {
        m_frozen = false;
    }
}

void QuteGraph::drawSpectrum(Curve *curve, int index) {
    if(!curveLock.tryLock())
        return;
    int curveSize = curve->get_size();
    if(curveSize != frozenCurve.size() && graphtypes[index] == GraphType::GRAPH_SPECTRUM)
        freezeSpectrum(false);
    // auto view = getView(index);
    // QGraphicsScene *scene = static_cast<QGraphicsView *>(static_cast<StackedLayoutWidget *>(m_widget)->widget(index))->scene();
    QGraphicsView *view = getView(index);
    double dbRange = m_dbRange;
    double db0 = m_ud->zerodBFS;

    // Draw at most about one polygon point per screen pixel. When the curve has
    // more bins than the view has pixels, keep the loudest bin per pixel column:
    // this cuts both the log() work and the rasterized polygon size with no
    // visible loss at the current zoom (when zoomed in, step is 1 and nothing is
    // dropped). view->transform().m11() is scene units (bins) per pixel.
    const double scenePerPixel = view->transform().m11();
    const int step = scenePerPixel > 0.0 ? qMax(1, int(1.0 / scenePerPixel)) : 1;
    const int outCount = (curveSize + step - 1) / step;

    QVector<QPointF> polygonPoints;
    polygonPoints.resize(outCount + 2);
    polygonPoints[0] = QPointF(0, dbRange);

    int out = 1;
    for (int i = 0; i < (int) curveSize; i += step) {
        int end = qMin(i + step, (int) curveSize);
        double best = m_frozen ? frozenCurve[i] : curve->get_data(i);
        int bestIndex = i;
        for (int j = i + 1; j < end; j++) {
            double data = m_frozen ? frozenCurve[j] : curve->get_data(j);
            if (data > best) {
                best = data;
                bestIndex = j;
            }
        }
        double db = best > 0.000001 ? 20.0*log10(best/db0) : -dbRange;
        polygonPoints[out++] = QPointF(bestIndex, -db); //skip first item, which is base line
    }

    polygonPoints.back() = QPointF(curveSize - 1, dbRange);
    polygons[index]->setPolygon(QPolygonF(polygonPoints));

    // m_pageComboBox->setItemText(index, curve->get_caption());
    // draw Grid
    int numTicksY = m_numticksY;
    const auto& gridlinesvec = m_gridlines[index];
    const auto& gridtextvecx = m_gridTextsX[index];
    const auto& gridtextvecy = m_gridTextsY[index];
    qreal sr = this->getSr(44100.0);
    qreal nyquist = sr * 0.5;
    qreal freqStep = 1000.0;  // TODO: allow to configure this
    int numTicksX = (int)(nyquist / freqStep);
    // TODO: fix y axis
    // The grid items only depend on these parameters, so touch them only when
    // one of them actually changed instead of on every update.
    GridCache &gridCache = m_gridCache[index];
    const bool gridNeedsUpdate = !gridCache.valid
            || gridCache.drawn != m_drawGrid
            || gridCache.curveSize != curveSize
            || gridCache.dbRange != dbRange
            || gridCache.numTicksY != numTicksY
            || gridCache.numTicksX != numTicksX;
    if(gridNeedsUpdate) {
        if(m_drawGrid) {
            gridtextvecy[0]->setVisible(true);
            for (int i = 1; i < numTicksY; i++) {
                int y = float(i)/(numTicksY) * dbRange;
                gridlinesvec[i]->setLine(0, y, curveSize, y);
                gridlinesvec[i]->setVisible(true);
                gridtextvecy[i]->setPos(0, y);
                gridtextvecy[i]->setVisible(true);
            }

            for (int i = 1; i < numTicksX; i++) {
                // qreal x = i * qreal(curveSize)/numTicksX;
                qreal freq = i * freqStep;
                qreal x = freq/nyquist * curveSize;
                int idx = i + m_numticksY;
                gridlinesvec[idx]->setLine(x, 0, x, dbRange);
                gridlinesvec[idx]->setVisible(true);
                gridtextvecx[i]->setPos(x, 0);
                gridtextvecx[i]->setVisible(true);
            }
        } else {
            for(int i=0; i < numTicksY; i++) {
                gridlinesvec[i]->setVisible(false);
                gridtextvecy[i]->setVisible(false);
            }
            for (int i = 0; i < numTicksX; i++) {
                gridlinesvec[i+m_numticksY]->setVisible(false);
                gridtextvecx[i]->setVisible(false);
            }
        }
        gridCache.valid = true;
        gridCache.drawn = m_drawGrid;
        gridCache.curveSize = curveSize;
        gridCache.dbRange = dbRange;
        gridCache.numTicksY = numTicksY;
        gridCache.numTicksX = numTicksX;
    }

    if(m_showPeak || m_showPeakTemp) {
        auto freq = m_showPeakTemp ? m_showPeakTempFrequency : m_showPeakCenterFrequency;
        size_t peakIndex;
        if(m_showPeakTemp) {
            // Search a fraction of the visible width, clamped to 8..48 pixels
            // (total width). Candidates are weighted by their distance to the
            // click, so a loud peak at the window edge no longer beats a
            // quieter peak under the cursor.
            const int viewportWidth = view->viewport()->width();
            const double sceneLeft = view->mapToScene(0, 0).x();
            const double sceneRight = view->mapToScene(viewportWidth, 0).x();
            const double visibleSceneWidth = qAbs(sceneRight - sceneLeft);
            const double windowPx = qBound(8.0, double(viewportWidth) / 10.0, 48.0);
            double windowHz;
            if(viewportWidth > 0 && visibleSceneWidth > 0.0 && curveSize > 0)
                windowHz = windowPx * (visibleSceneWidth / viewportWidth) * nyquist / curveSize;
            else
                windowHz = nyquist / m_zoomx / 8.0;
            peakIndex = this->spectrumGetNearestPeak(curve, freq, windowHz, step);
        }
        else {
            double bandwidth = freq * m_showPeakRelativeBandwidth;
            peakIndex = this->spectrumGetPeak(curve, freq, bandwidth);
        }
        auto data = m_frozen ? frozenCurve[peakIndex] : curve->get_data(peakIndex);
        double db = data > 0.000001 ? 20.0*log10(data/db0) : -dbRange;
        auto marker = m_spectrumPeakMarkers[index];
        auto vcenter = view->mapFromScene(QPointF(peakIndex, -db));
        auto markerLeftTop = view->mapToScene(QPoint(vcenter.x() - 4, vcenter.y()-4));
        auto markerRightBottom = view->mapToScene(vcenter.x() + 4, vcenter.y()+4);
        marker->setRect(markerLeftTop.x(), markerLeftTop.y(),
                        markerRightBottom.x()-markerLeftTop.x(),
                        markerRightBottom.y() - markerLeftTop.y());
        auto markerText = m_spectrumPeakTexts[index];
        auto textPos = view->mapToScene(vcenter.x() + 10, vcenter.y() - 12);
        auto markerY = m_lastTextMarkerY <= 0 ? textPos.y() :
                                                textPos.y() * 0.2 + m_lastTextMarkerY * 0.8;
        auto markerX = m_lastTextMarkerX <= 0 ? textPos.x() :
                                                textPos.x() * 0.3 + m_lastTextMarkerX * 0.7;
        m_lastTextMarkerY = markerY;
        m_lastTextMarkerX = markerX;
        markerText->setPos(markerX, markerY);
        double factor = nyquist / curveSize;
        double peakFreq;
        if(peakIndex <= 1 || peakIndex >= static_cast<size_t>(curveSize - 2) ) {
            peakFreq = factor * peakIndex;
        }
        else {
            double freq0 = qreal(peakIndex-1)*factor;
            double freq1 = qreal(peakIndex)*factor;
            double freq2 = qreal(peakIndex+1)*factor;
            double amp1 = data;
            double amp0, amp2;
            if(!m_frozen) {
                amp0 = curve->get_data(peakIndex-1);
                amp2 = curve->get_data(peakIndex+1);
            } else {
                amp0 = frozenCurve[peakIndex-1];
                amp2 = frozenCurve[peakIndex+1];
            }
            amp1 *= amp1;
            amp0 *= amp0;
            amp2 *= amp2;
            peakFreq = (freq0*amp0 + freq1*amp1 + freq2*amp2) / (amp0+amp1+amp2);
        }
        peakFreq = m_lastPeakFreq <= 0 ? peakFreq : peakFreq * 0.2 + m_lastPeakFreq * 0.8;
        m_lastPeakFreq = peakFreq;
        cs_float a4 = csoundGetA4(this->m_ud->csound);
        double midinote;
        QString notename;
        if(peakFreq > 10) {
            midinote = 12.0 * log2(peakFreq / a4) + 69.0;
            notename = mton(midinote);
        }
        else {
            // midinote = 0;
            notename = "LOW";
        }
        // Rebuilding the text document every update is not cheap, so only set
        // it when the displayed value actually changed.
        const QString markerString = QString("%1 Hz (%2)").arg((int)(peakFreq+0.5)).arg(notename);
        if(markerText->toPlainText() != markerString) {
            markerText->setPlainText(markerString);
        }
        marker->setVisible(true);
        markerText->setVisible(true);
        if(m_peakChannelPtr != nullptr) {
            *m_peakChannelPtr = peakFreq;
        }
    }
    else {
        if(m_getPeakChannel != nullptr) {
            *m_peakChannelPtr = 0;
        }
    }
    curveLock.unlock();
}

void QuteGraph::drawSignalPath(Curve *curve, int index) {
    int curveSize = curve->get_size();
    auto zerodbfs = m_ud->zerodBFS;

    // Keep at most about one point per screen pixel. Unlike the spectrum (a
    // filled magnitude envelope), an audio waveform needs both its positive and
    // negative envelope, so emit the min and max of every pixel column.
    const double scenePerPixel = getView(index)->transform().m11();
    const int step = scenePerPixel > 0.0 ? qMax(1, int(1.0 / scenePerPixel)) : 1;

    QPainterPath path;
    bool started = false;
    for (int i = 0; i < curveSize; i += step) {
        int end = qMin(i + step, curveSize);
        double vmax = curve->get_data(i) / zerodbfs;
        double vmin = vmax;
        for (int j = i + 1; j < end; j++) {
            double value = curve->get_data(j) / zerodbfs;
            if (value > vmax) vmax = value;
            if (value < vmin) vmin = value;
        }
        if (!started) {
            path.moveTo(i, vmax);
            started = true;
        } else {
            path.lineTo(i, vmax);
        }
        if (vmin != vmax)
            path.lineTo(i, vmin);
    }

    QPainterPath axis;
    axis.moveTo(0, 0);
    axis.lineTo(curveSize, 0);

    m_axisItems[index]->setPath(axis);
    m_pathItems[index]->setPath(path);
    m_pathItems[index]->setPen(QPen(QColor(255, 193, 7), 0));
}

void QuteGraph::scaleGraph(int index)
{
    auto curve = curves[index];

    double max = curves[index]->get_max();
    double min = curves[index]->get_min();
    double zoomx = m_zoomx;
    double zoomy = m_zoomy;
	// double zoomx = property("CSQT_zoomx").toDouble();
	// double zoomy = property("CSQT_zoomy").toDouble();
	//  double span = max - min;
    //  FIXME implement dispx, dispy and modex, modey
    int size = curve->get_size();
    double sizef = (double)size;
    auto view = getView(index);
    //  view->setResizeAnchor(QGraphicsView::NoAnchor);
    auto graphType = graphtypes[index];
    if(graphType == GraphType::GRAPH_FTABLE && max != min) {
        double yrange = max - min;
        double factor = 1.17;
        view->setSceneRect(0, -max*factor - 0.05, sizef, yrange*factor);
        view->fitInView(0, -max*factor/zoomy, sizef/zoomx, yrange*factor/zoomy);
    } else if(graphType == GraphType::GRAPH_SPECTRUM) {
        double dbRange = m_dbRange;
        view->setSceneRect (0, -3, size, dbRange);
        view->fitInView(0, -3/zoomy, sizef/zoomx, dbRange/zoomy);
    } else { //from display opcode
        view->setSceneRect (0, -1, size, 2);
        // view->fitInView(0, -10./zoomy, (double) size/zoomx, 10./zoomy);
        view->fitInView(0, -2./zoomy, sizef/zoomx, 2./zoomy);
	}

}

int QuteGraph::getTableNumForIndex(int index) {
    if (index < 0 || index >= curves.size() || curves.size() <= 0) {
        // Invalid index
		return -1;
	}
	int ftable = -1;
    if(graphtypes[index] == GraphType::GRAPH_FTABLE) {
        QString caption = curves[index]->get_caption();
		ftable= caption.mid(caption.indexOf(" ") + 1,
							caption.indexOf(":") - caption.indexOf(" ") - 1).toInt();
	}
    return ftable;
}

int QuteGraph::getIndexForTableNum(int ftable)
{
	int index = -1;
	for (int i = 0; i < curves.size(); i++) {
		QString text = curves[i]->get_caption();
		if (text.contains("ftable")) {
            QStringList parts = text.split(QRegularExpression(uR"([ :])"_s), Qt::SkipEmptyParts);
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

void QuteGraph::showScrollbars(bool show) {
    auto policy = show ? Qt::ScrollBarAsNeeded : Qt::ScrollBarAlwaysOff;
    for(int i=0; i < this->curves.size(); i++) {
        auto view = getView(i);
        view->setHorizontalScrollBarPolicy(policy);
    }
    m_showScrollbars = show;
}

// ----------------------
QuteTableWidget::~QuteTableWidget() {
}




void QuteTableWidget::reset() {
    // This needs to be called with the lock
    m_tabnum = 0;
    m_running = false;
    // Forget the table number so a later run cannot persist an unrelated table
    // (possibly from a fresh Csound instance) into the snapshot.
    m_snapshotTabnum.store(0, std::memory_order_relaxed);
    // A later run gets a fresh Csound instance, so its tables must be queried
    // again. Keep m_tableSampleRate so the snapshot keeps its time axis.
    m_sampleRateTable = -1;
    m_sampleRateQueryActive = false;
    m_sampleRateQueryAttempt = 0;
    // Keep the table copy (if any) so the last plot survives the stop.
    showSnapshot();
}

void QuteTableWidget::startSampleRateQuery()
{
    // Only the auto mode (sample rate == 0) needs the table's sample rate, and
    // only while a table is being performed.
    if (m_sampleRate > 0.0 || m_sampleRateQueryActive)
        return;
    if (!m_running || m_tabnum <= 0)
        return;
    if (m_sampleRateTable == m_tabnum)
        return; // already resolved for this table
    m_sampleRateQueryActive = true;
    m_sampleRateQueryAttempt = 0;
    QTimer::singleShot(tableSampleRateSettleMs, this,
                       &QuteTableWidget::querySampleRate);
}

void QuteTableWidget::querySampleRate()
{
    if (!m_sampleRateQueryActive || m_sampleRate > 0.0
            || !m_running || m_tabnum <= 0) {
        m_sampleRateQueryActive = false;
        return;
    }
    CsoundUserData *ud = m_ud;
    bool issued = false;
    if (ud != nullptr && ud->perfThread != nullptr && ud->playMutex != nullptr
            && ud->playMutex->tryLock(1)) {
        // Do not query while Csound is being torn down or is not performing.
        if (ud->perfThread->GetStatus() == 0) {
            m_detectedSampleRate.store(0, std::memory_order_relaxed);
            m_sampleRateReady.store(0, std::memory_order_relaxed);
            const QByteArray code =
                    u"return(ftsr(%1))"_s.arg(m_tabnum).toLatin1();
            ud->perfThread->EvalCode(code.constData(),
                                     &QuteTableWidget::sampleRateQueryCallback,
                                     this);
            issued = true;
        }
        ud->playMutex->unlock();
    }
    if (issued) {
        QTimer::singleShot(tableSampleRatePollMs, this,
                           &QuteTableWidget::finishSampleRateQuery);
    } else {
        retrySampleRateQuery();
    }
}

void QuteTableWidget::finishSampleRateQuery()
{
    if (!m_sampleRateQueryActive)
        return;
    if (m_sampleRateReady.load(std::memory_order_acquire) > 0) {
        const int sampleRate =
                m_detectedSampleRate.load(std::memory_order_relaxed);
        m_sampleRateQueryActive = false;
        m_sampleRateTable = m_tabnum;
        const double rate = sampleRate > 0 ? double(sampleRate) : 0.0;
        if (rate != m_tableSampleRate) {
            m_tableSampleRate = rate;
            update();
        }
        return;
    }
    retrySampleRateQuery();
}

void QuteTableWidget::retrySampleRateQuery()
{
    if (!m_sampleRateQueryActive
            || ++m_sampleRateQueryAttempt >= tableSampleRateMaxAttempts) {
        // Give up: the table may not define a sample rate, in which case the
        // auto mode falls back to 1.
        m_sampleRateQueryActive = false;
        m_sampleRateTable = m_tabnum;
        update();
        return;
    }
    QTimer::singleShot(tableSampleRateSettleMs * (1 << m_sampleRateQueryAttempt),
                       this, &QuteTableWidget::querySampleRate);
}

void QuteTableWidget::sampleRateQueryCallback(cs_float out, void *userdata)
{
    // Runs on the performance thread; only touch atomics here.
    auto *widget = static_cast<QuteTableWidget *>(userdata);
    if (widget == nullptr)
        return;
    widget->m_detectedSampleRate.store(int(out), std::memory_order_relaxed);
    widget->m_sampleRateReady.store(1, std::memory_order_release);
}

void QuteTableWidget::persistTable(CSOUND *cs) {
    // Called by the engine on the stopping thread, while the Csound instance is
    // still alive. Copy the table so the display can survive the teardown.
    const int tabnum = m_snapshotTabnum.load(std::memory_order_relaxed);
    if (cs == nullptr || tabnum <= 0) {
        return;
    }
    const int len = csoundTableLength(cs, tabnum);
    cs_float *data = nullptr;
    if (len > 0) {
        csoundGetTable(cs, &data, tabnum);
    }
    if (len <= 0 || data == nullptr) {
        return;
    }
    m_snapshot.resize(len);
    memcpy(m_snapshot.data(), data, size_t(len) * sizeof(cs_float));
    m_hasSnapshot.store(true, std::memory_order_release);
}

void QuteTableWidget::showSnapshot() {
    const bool hasSnapshot = !m_snapshot.isEmpty();
    m_hasSnapshot.store(hasSnapshot, std::memory_order_release);
    if (!hasSnapshot) {
        m_data = nullptr;
        m_tabsize = 0;
        m_path.clear();
        update();
        return;
    }
    m_data = m_snapshot.data();
    buildPath(m_snapshot.constData(), m_snapshot.size());
    update();
}


QRectF QuteTableWidget::plotRect() const
{
    const QRect r = rect();
    constexpr int tickLength = 6;
    constexpr int textGap = 3;
    // Top margin holds the table size, the bottom one the x tick labels.
    const int topMargin = gridFontMetrics.height() + 3;
    const int rightMargin = m_margin;
    const int bottomMargin = gridFontMetrics.height() + tickLength + textGap + 1;

    const int usableHeight = qMax(1, r.height() - topMargin - bottomMargin);
    const int targetTicks = qBound(2, usableHeight / 34, 10);
    const double step = niceTickStep(m_maxy - m_miny, targetTicks);

    // The left margin has to fit the widest tick label.
    const int labelWidth = qMax(
                gridFontMetrics.horizontalAdvance(formatTickValue(m_maxy, step)),
                gridFontMetrics.horizontalAdvance(formatTickValue(m_miny, step)));
    constexpr int labelGap = 5;
    int leftMargin = labelWidth + tickLength + labelGap;
    // Never let the labels eat more than a third of the widget.
    leftMargin = qBound(m_margin, leftMargin, qMax(m_margin, r.width() / 3));

    return QRectF(r.left() + leftMargin,
                  r.top() + topMargin,
                  qMax(0, r.width() - leftMargin - rightMargin),
                  qMax(0, r.height() - topMargin - bottomMargin));
}

double QuteTableWidget::valueToY(double value, const QRectF &plot) const
{
    const double range = m_maxy - m_miny;
    if (!(range > 0.0))
        return plot.center().y();
    return plot.bottom() - (value - m_miny) / range * plot.height();
}

double QuteTableWidget::niceTickStep(double range, int targetTicks)
{
    if (!(range > 0.0) || !std::isfinite(range) || targetTicks <= 0)
        return 1.0;
    const double raw = range / targetTicks;
    if (!(raw > 0.0) || !std::isfinite(raw))
        return 1.0;
    const double magnitude = std::pow(10.0, std::floor(std::log10(raw)));
    const double fraction = raw / magnitude;
    double nice = 10.0;
    if (fraction <= 1.0)
        nice = 1.0;
    else if (fraction <= 2.0)
        nice = 2.0;
    else if (fraction <= 5.0)
        nice = 5.0;
    return nice * magnitude;
}

QString QuteTableWidget::formatTickValue(double value, double step) const
{
    // Avoid displaying "-0".
    if (qFuzzyIsNull(value) || (step > 0.0 && std::abs(value) < step * 1e-6))
        value = 0.0;
    if (!(step > 0.0) || !std::isfinite(step))
        return QString::number(value, 'g', 4);
    if (step < 1e-6)
        return QString::number(value, 'g', 4);
    if (step >= 1.0)
        return QString::number(qRound64(value));
    int decimals = int(std::ceil(-std::log10(step)));
    decimals = qBound(0, decimals, 6);
    return QString::number(value, 'f', decimals);
}

void QuteTableWidget::paintGrid(QPainter *painter) {
    const QRectF plot = plotRect();
    if (plot.width() < 4.0 || plot.height() < 4.0)
        return;

    painter->save();
    painter->setRenderHint(QPainter::Antialiasing, false);
    painter->setFont(gridFont);
    painter->setBrush(Qt::NoBrush);

    constexpr int tickLength = 6;
    constexpr int minorTickLength = 3;
    constexpr int textGap = 3;

    // On a light background the axis and the labels have to turn dark.
    const bool lightBackground = m_background.lightness() > 128;
    const QColor axisColor = lightBackground ? QColor(90, 90, 90)
                                             : QColor(150, 150, 150);
    const QColor textColor = lightBackground ? QColor(40, 40, 40)
                                             : QColor(200, 200, 200);
    const int fontHeight = gridFontMetrics.height();

    // Frame; all four sides stay inside the widget.
    painter->setPen(QPen(axisColor, 0));
    painter->drawRect(plot);

    // ------------------------- y axis -------------------------
    const int targetTicks = qBound(2, int(plot.height() / 34.0), 10);
    const double step = niceTickStep(m_maxy - m_miny, targetTicks);
    const bool zeroVisible = m_miny < 0.0 && m_maxy > 0.0;
    bool zeroIsTick = false;

    if (step > 0.0) {
        const long long first = (long long)std::ceil((m_miny - step * 1e-9) / step);
        const long long last = (long long)std::floor((m_maxy + step * 1e-9) / step);
        if (last >= first && last - first < 1000) {
            for (long long i = first; i <= last; ++i) {
                const double value = double(i) * step;
                const double y = valueToY(value, plot);
                const bool isZero = zeroVisible && std::abs(value) < step * 1e-6;
                if (isZero)
                    zeroIsTick = true;
                // Major gridline. The zero line uses the same colour.
                painter->setPen(QPen(m_gridColor, 0));
                painter->drawLine(QPointF(plot.left(), y),
                                  QPointF(plot.right(), y));
                // Major tick mark.
                painter->setPen(QPen(axisColor, 0));
                painter->drawLine(QPointF(plot.left() - tickLength, y),
                                  QPointF(plot.left(), y));
                // Tick label, right-aligned in the left margin.
                const QRectF labelRect(0.0, y - fontHeight / 2.0,
                                       plot.left() - tickLength - textGap,
                                       fontHeight);
                painter->setPen(textColor);
                painter->drawText(labelRect, Qt::AlignRight | Qt::AlignVCenter,
                                  formatTickValue(value, step));
            }
        }

        // Minor ticks: five sub-intervals per major tick, no text.
        const int minorDivisions = 5;
        const double minorStep = step / minorDivisions;
        const long long firstMinor =
                (long long)std::ceil((m_miny - minorStep * 1e-9) / minorStep);
        const long long lastMinor =
                (long long)std::floor((m_maxy + minorStep * 1e-9) / minorStep);
        if (lastMinor >= firstMinor && lastMinor - firstMinor < 5000) {
            painter->setPen(QPen(axisColor, 0));
            for (long long i = firstMinor; i <= lastMinor; ++i) {
                if (i % minorDivisions == 0)
                    continue; // already drawn as a major tick
                const double y = valueToY(double(i) * minorStep, plot);
                painter->drawLine(QPointF(plot.left() - minorTickLength, y),
                                  QPointF(plot.left(), y));
            }
        }
    }

    // Always mark zero when it lies inside the range, even if the tick
    // selection would not put a major tick there. It is drawn in the same
    // colour as every other gridline.
    if (zeroVisible && !zeroIsTick) {
        const double y = valueToY(0.0, plot);
        painter->setPen(QPen(m_gridColor, 0));
        painter->drawLine(QPointF(plot.left(), y), QPointF(plot.right(), y));
        const QRectF labelRect(0.0, y - fontHeight / 2.0,
                               plot.left() - tickLength - textGap, fontHeight);
        painter->setPen(textColor);
        painter->drawText(labelRect, Qt::AlignRight | Qt::AlignVCenter,
                          QStringLiteral("0"));
    }

    // ------------------------- x axis -------------------------
    const double xMax = double(m_tabsize) * xFactor();
    if (xMax > 0.0 && std::isfinite(xMax)) {
        const int xTargetTicks = qBound(2, int(plot.width() / 80.0), 10);
        const double xStep = niceTickStep(xMax, xTargetTicks);
        if (xStep > 0.0) {
            const long long last =
                    (long long)std::floor((xMax + xStep * 1e-9) / xStep);
            const int widgetWidth = rect().width();
            for (long long i = 0; i <= last && i < 1000; ++i) {
                const double value = double(i) * xStep;
                const double x = plot.left() + value / xMax * plot.width();
                // Major gridline.
                painter->setPen(QPen(m_gridColor, 0));
                painter->drawLine(QPointF(x, plot.top()),
                                  QPointF(x, plot.bottom()));
                // Major tick mark.
                painter->setPen(QPen(axisColor, 0));
                painter->drawLine(QPointF(x, plot.bottom()),
                                  QPointF(x, plot.bottom() + tickLength));
                // Label, centred under the tick and kept inside the widget.
                const QString text = formatTickValue(value, xStep);
                const int textWidth = gridFontMetrics.horizontalAdvance(text);
                const double labelLeft = qBound(0.0, x - textWidth / 2.0,
                                                double(widgetWidth - textWidth));
                const QRectF labelRect(labelLeft, plot.bottom() + tickLength + textGap,
                                       textWidth, fontHeight);
                painter->setPen(textColor);
                painter->drawText(labelRect, Qt::AlignHCenter | Qt::AlignTop,
                                  text);
            }

            // Minor ticks on the x axis, no text.
            const int minorDivisions = 5;
            const double minorStep = xStep / minorDivisions;
            const long long lastMinor =
                    (long long)std::floor((xMax + minorStep * 1e-9) / minorStep);
            if (lastMinor < 5000) {
                painter->setPen(QPen(axisColor, 0));
                for (long long i = 0; i <= lastMinor; ++i) {
                    if (i % minorDivisions == 0)
                        continue; // already drawn as a major tick
                    const double x = plot.left()
                            + double(i) * minorStep / xMax * plot.width();
                    painter->drawLine(QPointF(x, plot.bottom()),
                                      QPointF(x, plot.bottom() + minorTickLength));
                }
            }
        }
    }

    // Number of table points, in the free space above the plot.
    painter->setPen(textColor);
    const QRectF sizeRect(plot.left(), 0.0, plot.width(), plot.top());
    painter->drawText(sizeRect, Qt::AlignRight | Qt::AlignBottom,
                      QString::number(m_tabsize));

    painter->restore();
}


void QuteTableWidget::paintEvent(QPaintEvent *event) {
    Q_UNUSED(event);
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setPen(Qt::NoPen);
    const bool hasSnapshot = m_hasSnapshot.load(std::memory_order_acquire);
    if(!m_running && !hasSnapshot) {
        painter.setBrush(QColor(176, 0, 32));
        painter.drawRect(this->rect());
        painter.setPen(Qt::white);
        painter.drawText(this->rect(), Qt::AlignCenter, "Stopped");
        if (!isEnabled())
            QuteWidget::paintDisabledOverlay(painter, this->rect());
        return;
    }
    if(m_running && m_tabnum <= 0 && !hasSnapshot) {
        // table not set
        painter.setBrush(QColor(0, 176, 32));
        painter.drawRect(this->rect());
        painter.setPen(Qt::white);
        painter.drawText(this->rect(), Qt::AlignCenter, "Table not set");
        if (!isEnabled())
            QuteWidget::paintDisabledOverlay(painter, this->rect());
        return;
    }
    // running OK (or showing the persisted table after stop)
    painter.setBrush(m_background);
    painter.drawRect(this->rect());
    painter.setBrush(Qt::NoBrush);
    // blockSignals(true);
    mutex.lock();
    if(m_showGrid) {
        this->paintGrid(&painter);
    }
    // Keep the curve inside the plotting area so it cannot run over the tick
    // labels or outside the widget.
    painter.save();
    painter.setClipRect(plotRect());
    painter.setPen(QPen(m_color, 0));
    painter.drawPath(m_path);
    painter.restore();
    mutex.unlock();
    if (!isEnabled())
        QuteWidget::paintDisabledOverlay(painter, this->rect());
    // blockSignals(false);
}

void QuteTableWidget::resizeEvent(QResizeEvent *event) {
    QWidget::resizeEvent(event);
    if (!m_running && m_hasSnapshot.load(std::memory_order_acquire)
            && !m_snapshot.isEmpty()) {
        QMutexLocker locker(&mutex);
        buildPath(m_snapshot.constData(), m_snapshot.size());
    }
}

void QuteTableWidget::setRange(double maxy) {
    if(maxy == 0.0) {
        m_autorange = true;
    } else {
        m_autorange = false;
        m_maxy = maxy;
        m_miny = -maxy;
    }
}

void QuteTableWidget::setMaxRange(double maxy) {
    // Fixed upper bound; keep the lower bound non-positive so the zero line
    // remains visible.
    m_autorange = false;
    m_maxy = maxy;
    m_miny = qMin(m_miny, 0.0);
    if (m_running)
        updatePath();
    else
        showSnapshot();
    update();
}

void QuteTableWidget::setMinRange(double miny) {
    // Fixed lower bound; keep the upper bound at least 1 so the plot cannot
    // collapse to a negative range.
    m_autorange = false;
    m_miny = miny;
    m_maxy = qMax(m_maxy, 1.0);
    if (m_running)
        updatePath();
    else
        showSnapshot();
    update();
}

void QuteTableWidget::updatePath() {
    if(!m_running || m_tabnum <= 0) {
        QDEBUG << "Not running or table number not set";
        return;
    }

    //CS7 changes
    int tabsize = csoundTableLength(m_ud->csound, m_tabnum);
    if(tabsize <= 0) {
        QDEBUG << "Table not found: " << m_tabnum;
        return;
    }

    // data = new double[tabsize]();  // <--- no need to allocate memory, we get a pointer to the table
    // old: csoundTableCopyOut(m_ud->csound, m_tabnum, data, 0);
    cs_float *data = nullptr;
    int result = csoundGetTable(m_ud->csound, &data, m_tabnum);
    if (result <= 0 || data == nullptr) {
        QDEBUG << "Table could not be read: " << m_tabnum;
        return;
    }

    m_data = data;
    buildPath(data, tabsize);
}

void QuteTableWidget::buildPath(const cs_float *data, int tabsize) {
    if (data == nullptr || tabsize <= 0) {
        m_tabsize = 0;
        m_path.clear();
        return;
    }

    m_tabsize = tabsize;

    double maxy = m_maxy;
    double miny = m_miny;

    if(m_autorange) {
        double newmaxy = m_maxy;
        double newminy = m_miny;
        // A rough sampling step; the exact one is computed once the plot area
        // (and therefore the label width) is known.
        int scanStep = int(tabsize / qMax(1, rect().width()));
        if (scanStep < 1)
            scanStep = 1;
        for(int i=0; i < tabsize; i+=scanStep) {
            double y = data[i];
            if(y > newmaxy)
                newmaxy = y;
            else if (y < newminy)
                newminy = y;
        }
        maxy = m_maxy = ceil(newmaxy);
        miny = m_miny = floor(newminy);
    }

    if (maxy - miny < 1.0e-12) {
        maxy += 0.5;
        miny -= 0.5;
    }

    // Keep the curve inside the same area used by the grid and labels.
    const QRectF plot = plotRect();
    if (plot.width() <= 0.0 || plot.height() <= 0.0) {
        m_path.clear();
        return;
    }

    double xscale = plot.width() / (double)tabsize;
    double x0 = plot.left();

    int step = int(tabsize / qMax(1.0, plot.width()));
    if(step == 0)
        step = 1;

    m_path.clear();
    QPolygonF poly;
    size_t numpoints = tabsize / step;
    poly.reserve(numpoints+1);
    double yscale = -plot.height() / (maxy-miny);
    double ydata = data[0];
    poly.append(QPointF(x0, (ydata-miny)*yscale + plot.bottom()));
    double ytop = plot.bottom();
    for(int i=1; i < tabsize; i+=step) {
        ydata = data[i];
        double x2 = i*xscale + x0;
        double y2 = (ydata - miny) * yscale + ytop;
        poly.append(QPointF(x2, y2));
    }
    m_path.addPolygon(poly);
    // delete[] data;
}

void QuteTableWidget::updateData(int tabnum) {
    QMutexLocker locker(&mutex);
    if(!m_running) {
        QDEBUG << "Not running, cannot update";
        return;
    }
    if(tabnum >= 0 && tabnum != m_tabnum) {
        QDEBUG << "Changing/Setting table number to new/first value";
        // A new table replaces the persisted copy from the previous run.
        m_snapshot.clear();
        m_hasSnapshot.store(false, std::memory_order_release);
        if(m_autorange) {
            m_maxy = 1.0;
            m_miny = 0;
        }
        m_tabnum = tabnum;
        // The new table may define a different sample rate (or none at all).
        m_sampleRateTable = -1;
        m_sampleRateQueryActive = false;
        m_sampleRateQueryAttempt = 0;
    }
    if (m_tabnum > 0) {
        m_snapshotTabnum.store(m_tabnum, std::memory_order_relaxed);
    }
    this->updatePath();
    if (m_sampleRate == 0.0)
        this->startSampleRateQuery();
    this->update();
}


// -------------------------

QuteTable::~QuteTable() {
    if (m_registeredEngine) {
        m_registeredEngine->removeBeforeCleanupCallback(m_widget);
    }
}

// void QuteTable::mousePressEvent(QMouseEvent *event) {};
// void QuteTable::mouseReleaseEvent(QMouseEvent *event) {};

QuteTable::QuteTable(QWidget *parent) : QuteWidget(parent) {
    m_widget = new QuteTableWidget(this);
    m_value = 0;
    m_tabnum = 0;
    // auto w = static_cast<QuteTableWidget*>(m_widget);
    setProperty("CSQT_randomizable", false);
    m_widget->setContextMenuPolicy(Qt::NoContextMenu);
    m_widget->setMouseTracking(true);
    setProperty("CSQT_range", 0.0);
    setProperty("CSQT_foreground", QColor(255, 193, 3));
    setProperty("CSQT_background", QColor(24, 24, 24));
    setProperty("CSQT_gridcolor", QColor(160, 160, 160, 72));
    setProperty("CSQT_samplerate", 1.0);
    setProperty("CSQT_showGrid", true);
    // Transitory ("method-like") table methods (see transitoryProperties()).
    // They are created here so that they can be addressed as
    // "<channel>/<method>"; the values are neither saved nor restored.
    setProperty("CSQT_update", 0);
    setProperty("CSQT_setmaxrange", 0.0);
    setProperty("CSQT_setminrange", 0.0);
}


QuteWidgetType QuteTable::getWidgetTypeID() { return QuteWidgetType::TABLEDISPLAY; }


void QuteTable::setColor(QColor color) {
    setProperty("CSQT_foreground", color);
    static_cast<QuteTableWidget*>(m_widget)->setColor(color);
}

QStringList QuteTable::transitoryProperties() const
{
    // Table "methods": addressed as "<channel>/<method>", applied immediately
    // and never written to or read from the file.
    return { "update", "setmaxrange", "setminrange" };
}

QHash<QString, QString> QuteTable::propertyDescriptions() const
{
    return {
        { u"update"_s,
          tr("Method: update the current table plot when the value is non-zero") },
        { u"setmaxrange"_s,
          tr("Method: disable auto-range and set the maximum amplitude; the "
             "minimum stays at or below zero") },
        { u"setminrange"_s,
          tr("Method: disable auto-range and set the minimum amplitude; the "
             "maximum stays at or above 1") },
        { u"range"_s,
          tr("Zero enables auto-range, otherwise a fixed symmetric +/- range") },
        { u"foreground"_s, tr("Colour of the plotted curve") },
        { u"background"_s, tr("Background colour of the plot") },
        { u"gridcolor"_s, tr("Colour of the grid and of the zero line") },
        { u"samplerate"_s,
          tr("Sample rate used for the x axis (index / sample rate gives "
             "seconds). Zero selects auto mode: the table's sample rate when "
             "it defines one, otherwise 1") },
        { u"showGrid"_s, tr("Show the value grid") }
    };
}

bool QuteTable::applyProperty(const QString &name)
{
	auto w = static_cast<QuteTableWidget*>(m_widget);
	if (name == "CSQT_foreground") {
		w->setColor(colorFromProperty(property("CSQT_foreground")));
		return true;
	}
	if (name == "CSQT_background") {
		w->setBackgroundColor(colorFromProperty(property("CSQT_background")));
		return true;
	}
	if (name == "CSQT_gridcolor") {
		w->setGridColor(colorFromProperty(property("CSQT_gridcolor")));
		return true;
	}
	if (name == "CSQT_samplerate") {
		w->setSampleRate(property("CSQT_samplerate").toDouble());
		return true;
	}
	if (name == "CSQT_range") {
		w->setRange(property("CSQT_range").toDouble());
		return true;
	}
	if (name == "CSQT_showGrid") {
		w->showGrid(property("CSQT_showGrid").toBool());
		return true;
	}
	if (name == "CSQT_update") {
		// A non-zero value requests an update of the current table, exactly like
		// sending -1 to the widget channel.
		if (property("CSQT_update").toInt() != 0 && m_tabnum > 0)
			m_valueChanged = true;
		return true;
	}
	if (name == "CSQT_setmaxrange") {
		w->setMaxRange(property("CSQT_setmaxrange").toDouble());
		return true;
	}
	if (name == "CSQT_setminrange") {
		w->setMinRange(property("CSQT_setminrange").toDouble());
		return true;
	}
	return QuteWidget::applyProperty(name);
}

void QuteTable::applyInternalProperties() {
    QuteWidget::applyInternalProperties();
    auto w = static_cast<QuteTableWidget*>(m_widget);
    w->setColor(colorFromProperty(property("CSQT_foreground")));
    w->setBackgroundColor(colorFromProperty(property("CSQT_background")));
    w->setGridColor(colorFromProperty(property("CSQT_gridcolor")));
    w->setSampleRate(property("CSQT_samplerate").toDouble());
    w->setRange(property("CSQT_range").toDouble());
    w->showGrid(property("CSQT_showGrid").toBool());
}

void QuteTable::createPropertiesDialog() {
    QuteWidget::createPropertiesDialog();
    dialog->setWindowTitle("Table Plot");
    auto label = new QLabel(tr("Foreground"), dialog);
    layout->addWidget(label, 4, 0, Qt::AlignRight|Qt::AlignVCenter);

    colorButton = new SelectColorButton(dialog);
    colorButton->setColor(colorFromProperty(property("CSQT_foreground")));
    layout->addWidget(colorButton, 4, 1, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(tr("Background"), dialog);
    layout->addWidget(label, 5, 0, Qt::AlignRight|Qt::AlignVCenter);

    backgroundColorButton = new SelectColorButton(dialog);
    backgroundColorButton->setColor(colorFromProperty(property("CSQT_background")));
    layout->addWidget(backgroundColorButton, 5, 1, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(tr("Grid color"), dialog);
    layout->addWidget(label, 6, 0, Qt::AlignRight|Qt::AlignVCenter);

    gridColorButton = new SelectColorButton(dialog);
    gridColorButton->setColor(colorFromProperty(property("CSQT_gridcolor")));
    layout->addWidget(gridColorButton, 6, 1, Qt::AlignLeft|Qt::AlignVCenter);

    label = new QLabel(tr("Sample rate"), dialog);
    label->setToolTip(tr("Sample rate used to convert the table index to time on "
                         "the x axis. Zero selects automatic mode: the table's "
                         "sample rate when it defines one, otherwise 1."));
    layout->addWidget(label, 7, 0, Qt::AlignRight|Qt::AlignVCenter);

    sampleRateSpinBox = new QDoubleSpinBox(dialog);
    sampleRateSpinBox->setDecimals(3);
    sampleRateSpinBox->setRange(0.0, 1000000.0);
    sampleRateSpinBox->setSingleStep(100.0);
    sampleRateSpinBox->setToolTip(label->toolTip());
    sampleRateSpinBox->setValue(property("CSQT_samplerate").toDouble());
    layout->addWidget(sampleRateSpinBox, 7, 1, Qt::AlignLeft|Qt::AlignVCenter);

    double range = property("CSQT_range").toDouble();
    rangeCheckBox = new QCheckBox("Fixed Range", dialog);
    rangeCheckBox->setToolTip("If checked the range is fixed to the value set on the right."
                              "If the table has values outside this range these will not be"
                              "displayed");
    rangeCheckBox->setChecked(range > 0.0);
    layout->addWidget(rangeCheckBox, 8, 1, Qt::AlignRight|Qt::AlignVCenter);

    rangeSpinBox = new QDoubleSpinBox(dialog);
    rangeSpinBox->setRange(0.1, 999999.0);
    rangeSpinBox->setSingleStep(0.1);
    rangeSpinBox->setToolTip("Sets the max. range to plot. Disable this to use autorange"
                             "With a fixed range, values outside the range will not be "
                             "visible");
    rangeSpinBox->setValue(range > 0 ? range : 1.0);
    layout->addWidget(rangeSpinBox, 8, 2, Qt::AlignLeft|Qt::AlignVCenter);
    connect(rangeCheckBox, SIGNAL(toggled(bool)), rangeSpinBox, SLOT(setEnabled(bool)));

    gridCheckBox = new QCheckBox("Show Grid", dialog);
    gridCheckBox->setChecked(property("CSQT_showGrid").toBool());
    layout->addWidget(gridCheckBox, 9, 1, Qt::AlignLeft|Qt::AlignVCenter);

}

void QuteTable::applyProperties() {
#ifdef  USE_WIDGET_MUTEX
    widgetLock.lockForWrite();
#endif
    setProperty("CSQT_foreground", colorButton->getColor());
    setProperty("CSQT_background", backgroundColorButton->getColor());
    setProperty("CSQT_gridcolor", gridColorButton->getColor());
    setProperty("CSQT_samplerate", sampleRateSpinBox->value());
    bool fixedrange = rangeCheckBox->isChecked();
    double range = rangeSpinBox->value();
    if(fixedrange) {
        Q_ASSERT(range > 0.0);
        setProperty("CSQT_range", range);
    } else {
        setProperty("CSQT_range", 0.0);
    }
    setProperty("CSQT_showGrid", gridCheckBox->isChecked());

#ifdef  USE_WIDGET_MUTEX
    widgetLock.unlock();
#endif
    QuteWidget::applyProperties();
}

void QuteTable::refreshWidget() {
    Q_ASSERT(m_valueChanged);
    QMutexLocker locker(&mutex);
    m_valueChanged = false;
    auto status = csoundEngineStatus(m_csoundUserData);
    m_csoundRunning = status == CsoundEngineStatus::Running;
    auto w = static_cast<QuteTableWidget*>(m_widget);
    w->setRunningStatus(m_csoundRunning);
    if(status != CsoundEngineStatus::Running) {
        return;
    }
    w->updateData(m_tabnum);
}

QString QuteTable::getWidgetXmlText() {
    xmlText = "";
    QXmlStreamWriter s(&xmlText);
    createXmlWriter(s);        // --------- start

    // The curve colour used to be stored as <color>; it is now <foreground>
    // (the old name is still read back by WidgetLayout).
    writeColorElement(s, "foreground",
                      colorFromProperty(property("CSQT_foreground")));
    writeColorElement(s, "background",
                      colorFromProperty(property("CSQT_background")));
    // Keep the alpha channel of the default (translucent) grid colour.
    s.writeTextElement("gridcolor",
                       colorFromProperty(property("CSQT_gridcolor"))
                       .name(QColor::HexArgb));

    s.writeTextElement("samplerate",
                       QString::number(property("CSQT_samplerate").toDouble(), 'g', 12));
    auto range = property("CSQT_range").toDouble();
    s.writeTextElement("range", QString::number(range, 'f', 2));

    s.writeEndElement();      // --------- end
    return xmlText;
}

void QuteTable::onStop() {
    // this->blockSignals(true);
    mutex.lock();
    m_tabnum = 0;
    m_value = 0;
    m_valueChanged = true;

    static_cast<QuteTableWidget*>(m_widget)->stop(m_csoundUserData);
    mutex.unlock();
    // this->applyInternalProperties();
    // this->blockSignals(false);
}

void QuteTable::setCsoundUserData(CsoundUserData *ud) {
    if(ud == nullptr) {
        qDebug()<<"CsoundUserData is null";
        return;
    }
    m_csoundUserData = ud;
    auto w = static_cast<QuteTableWidget*>(m_widget);
    if(w == nullptr) {
        qDebug() << "widget is null";
        return;
    }
    w->setUserData(ud);
    if (ud->csEngine) {
        connect(ud->csEngine, SIGNAL(stopSignal()), this, SLOT(onStop()), Qt::UniqueConnection);
        // Copy the table out of Csound just before the instance is destroyed so
        // the plot survives the stop.
        if (m_registeredEngine != ud->csEngine) {
            if (m_registeredEngine) {
                m_registeredEngine->removeBeforeCleanupCallback(m_widget);
            }
            m_registeredEngine = ud->csEngine;
            ud->csEngine->addBeforeCleanupCallback(m_widget, [w](CSOUND *cs) {
                w->persistTable(cs);
            });
        }
    }
}

/*
void QuteTable::setWidgetGeometry(int x, int y, int width, int height) {

    if(csoundEngineStatus(m_csoundUserData)==CsoundEngineStatus::Running) {
        return;
    }
    QuteWidget::setWidgetGeometry(x,y,width, height);
}
*/

void QuteTable::setTableNumber(int tabnum) {
    if(tabnum <= 0) {
        qWarning() << "Table number must be greater than 0";
        return;
    }
    if(tabnum == m_tabnum)
        return;
    m_valueChanged = true;
    m_value = tabnum;
    m_tabnum = tabnum;
    auto w = static_cast<QuteTableWidget*>(m_widget);
    w->updateData(m_tabnum);
}

void QuteTable::setValue(double value) {
    if(value == 0) {
        m_value = m_tabnum;
        return;
    }
    else if(value < 0.) {
        if(m_tabnum <= 0) {
            QDEBUG << "Table number not set, can't update";
            return;
        }
        // update data, don't change table number
        m_valueChanged = true;
        // auto w = static_cast<QuteTableWidget*>(m_widget);
        // w->updateData(m_tabnum);
    }
    else if(value > 0 && value != m_tabnum) {
        setTableNumber(static_cast<int>(value));
    }
};

void QuteTable::setValue(QString s) {
    auto parts = QStringView(s).split(' ', SKIP_EMPTY_PARTS); // was splitRef
    if(parts.size() == 0) {
        qWarning() << "TablePLot: Message not understood, expected @set <tabnum> "
                    "or @update";
        return;
    }
    if(parts[0] == QLatin1String("@set")) {
        if(parts.size() != 2) {
            qWarning() << "@set message expects a table number (example: @set 103)";
            return;
        }
        int tabnum = parts[1].toInt();
        setTableNumber(tabnum);
    } else if (parts[0] == QLatin1String("@update") && m_tabnum > 0) {
        setValue(-1);
    } else
        qWarning() << "Message not supported:" << s;
}

SpectralView::~SpectralView() {};

void SpectralView::mouseReleaseEvent(QMouseEvent *ev) {
    emit mouseReleased();
    QGraphicsView::mouseReleaseEvent(ev);
}
