/*
        Copyright (C) 2010 Andres Cabrera
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

#include <cstdlib>
#include <cmath>

#include <QSet>
#include <QThread>
#include <limits>

#include "widgetlayout.h"
#include "qutewidget.h"
#include "bundledfonts.h"
#include "notification.h"
#include "quteslider.h"
#include "qutetext.h"
#include "qutespinbox.h"
#include "qutebutton.h"
#include "quteknob.h"
#include "qutecheckbox.h"
#include "qutecombobox.h"
#include "qutemeter.h"
#include "quteconsole.h"
#include "qutegraph.h"
#include "qutescope.h"
#include "qutewaveform.h"
#include "qutevumeter.h"
#include "framewidget.h"

#include "csoundqt.h" // For passing the actions from button reserved channels


WidgetLayout::WidgetLayout(QWidget* parent) : QWidget(parent)
{
    selectionFrame = new QRubberBand(QRubberBand::Rectangle, this);
    selectionFrame->hide();
    m_trackMouse = true;
    m_editMode = false;
    m_enableEdit = true;
    m_currentPreset = -1;
    m_activeWidgets = 0;
    m_updateRate = 30;
    m_loadingWidgets = false;

    auto palette = qApp->palette();
    auto isLightTheme = palette.text().color().lightness() < palette.window().color().lightness();

    m_modified = false;
    closing = 0;
    mouseX = mouseY = mouseRelX = mouseRelY = mouseBut1 = mouseBut2 = 0;
    m_posx = m_posy =  m_w =  m_h = 0;
    xOffset = yOffset = 0;
    mouseRelX = mouseRelY = 0;
    m_contained = false;

    midiWriteCounter = 0;
    midiReadCounter = 0;
    midiQueue.resize(CSQT_MAX_MIDI_QUEUE);
    for (int i = 0; i <CSQT_MAX_MIDI_QUEUE; i++ ) {
        midiQueue[i].resize(3);
    }

    curveUpdateBuffer.resize(CSQT_CURVE_BUFFER_SIZE);
    curveUpdateBufferCount = 0;

    createSliderAct = new QAction(tr("Slider"),this);
    connect(createSliderAct, SIGNAL(triggered()), this, SLOT(createNewSlider()));
    createLabelAct = new QAction(tr("Label"),this);
    connect(createLabelAct, SIGNAL(triggered()), this, SLOT(createNewLabel()));
    createDisplayAct = new QAction(tr("Display"),this);
    connect(createDisplayAct, SIGNAL(triggered()), this, SLOT(createNewDisplay()));
    createScrollNumberAct = new QAction(tr("ScrollNumber"),this);
    connect(createScrollNumberAct, SIGNAL(triggered()),
            this, SLOT(createNewScrollNumber()));
    createLineEditAct = new QAction(tr("LineEdit"),this);

    connect(createLineEditAct, SIGNAL(triggered()), this, SLOT(createNewLineEdit()));

    createSpinBoxAct = new QAction(tr("SpinBox"),this);
    connect(createSpinBoxAct, SIGNAL(triggered()), this, SLOT(createNewSpinBox()));

    createButtonAct = new QAction(tr("Button"),this);
    connect(createButtonAct, SIGNAL(triggered()), this, SLOT(createNewButton()));

    createKnobAct = new QAction(tr("Knob"),this);
    connect(createKnobAct, SIGNAL(triggered()), this, SLOT(createNewKnob()));

    createCheckBoxAct = new QAction(tr("Checkbox"),this);
    connect(createCheckBoxAct, SIGNAL(triggered()), this, SLOT(createNewCheckBox()));

    createMenuAct = new QAction(tr("Menu"),this);
    connect(createMenuAct, SIGNAL(triggered()), this, SLOT(createNewMenu()));

    createMeterAct = new QAction(tr("Controller"),this);
    connect(createMeterAct, SIGNAL(triggered()), this, SLOT(createNewMeter()));

    createConsoleAct = new QAction(tr("Console"),this);
    connect(createConsoleAct, SIGNAL(triggered()), this, SLOT(createNewConsole()));

    createGraphAct = new QAction(tr("Graph"),this);
    connect(createGraphAct, SIGNAL(triggered()), this, SLOT(createNewGraph()));

    createScopeAct = new QAction(tr("Scope"),this);
    connect(createScopeAct, SIGNAL(triggered()), this, SLOT(createNewScope()));

    createTableDisplayAct = new QAction(tr("Table Plot"), this);
    connect(createTableDisplayAct, SIGNAL(triggered()), this, SLOT(createNewTableDisplay()));

    createWaveformAct = new QAction(tr("Waveform"), this);
    connect(createWaveformAct, SIGNAL(triggered()), this, SLOT(createNewWaveform()));

    createVUMeterAct = new QAction(tr("VU Meter"), this);
    connect(createVUMeterAct, SIGNAL(triggered()), this, SLOT(createNewVUMeter()));

    propertiesAct = new QAction(tr("Properties"),this);
    connect(propertiesAct, SIGNAL(triggered()), this, SLOT(propertiesDialog()));

    reloadWidgetsAct = new QAction(tr("Reload Widgets"), this);
    connect(reloadWidgetsAct, SIGNAL(triggered()), this, SLOT(reloadWidgets()));

    cutAct = new QAction(tr("Cut"), this);
    //  cutAct->setShortcut(tr("Ctrl+X"));
    connect(cutAct, SIGNAL(triggered()), this, SLOT(cut()));
    copyAct = new QAction(tr("Copy"), this);
    //  copyAct->setShortcut(tr("Ctrl+C"));
    connect(copyAct, SIGNAL(triggered()), this, SLOT(copy()));
    pasteAct = new QAction(tr("Paste"), this);
    //  pasteAct->setShortcut(tr("Ctrl+V"));
    connect(pasteAct, SIGNAL(triggered()), this, SLOT(paste()));
    duplicateAct = new QAction(tr("Duplicate Selected"), this);
    connect(duplicateAct, SIGNAL(triggered()), this, SLOT(duplicate()));
    clearAct = new QAction(tr("Clear all widgets"), this);
    connect(clearAct, SIGNAL(triggered()), this, SLOT(clearWidgets()));
    selectAllAct = new QAction(tr("Select all widgets"), this);
    connect(selectAllAct, SIGNAL(triggered()), this, SLOT(selectAll()));

    QString iconPrefix = isLightTheme ? ":/themes/breeze/" : ":/themes/breeze-dark/";

    alignLeftAct = new QAction(QIcon(iconPrefix + "align-horizontal-left.svg"),
                               tr("Align Left"), this);
    connect(alignLeftAct, SIGNAL(triggered()), this, SLOT(alignLeft()));

    alignRightAct = new QAction(QIcon(iconPrefix + "align-horizontal-right.svg"),
                                tr("Align Right"), this);
    connect(alignRightAct, SIGNAL(triggered()), this, SLOT(alignRight()));

    alignTopAct = new QAction(QIcon(iconPrefix + "align-vertical-top.svg"),
                              tr("Align Top"), this);
    connect(alignTopAct, SIGNAL(triggered()), this, SLOT(alignTop()));

    alignBottomAct = new QAction(QIcon(iconPrefix + "align-vertical-bottom.svg"),
                                 tr("Align Bottom"), this);
    connect(alignBottomAct, SIGNAL(triggered()), this, SLOT(alignBottom()));

    sendToBackAct = new QAction(QIcon(iconPrefix + "object-order-back.svg"),
                                tr("Send to back"), this);
    connect(sendToBackAct, SIGNAL(triggered()), this, SLOT(sendToBack()));

    sendToFrontAct = new QAction(QIcon(iconPrefix + "object-order-front.svg"),
                                 tr("Send to Front"), this);
    connect(sendToFrontAct, SIGNAL(triggered()), this, SLOT(sendToFront()));

    // Page Up / Page Down change the stacking order while editing. Kept as
    // widget-context shortcuts so they do not interfere with scrolling outside
    // edit mode.
    sendToFrontAct->setShortcut(QKeySequence(Qt::Key_PageUp));
    sendToFrontAct->setShortcutContext(Qt::WidgetWithChildrenShortcut);
    addAction(sendToFrontAct);
    sendToBackAct->setShortcut(QKeySequence(Qt::Key_PageDown));
    sendToBackAct->setShortcutContext(Qt::WidgetWithChildrenShortcut);
    addAction(sendToBackAct);

    // Ctrl+arrows move the selection to the nearest widget in that direction.
    // These override the application-level Ctrl+Left/Right (browse back/forward)
    // while the widget panel is focused.
    auto makeSelectAct = [this](const QString &text, Qt::Key key, int dx, int dy) {
        QAction *act = new QAction(text, this);
        act->setShortcut(QKeySequence(Qt::CTRL | key));
        act->setShortcutContext(Qt::WidgetWithChildrenShortcut);
        connect(act, &QAction::triggered, this, [this, dx, dy]() {
            selectInDirection(dx, dy);
        });
        addAction(act);
        return act;
    };
    selectLeftAct  = makeSelectAct(tr("Select widget to the left"),  Qt::Key_Left,  -1,  0);
    selectRightAct = makeSelectAct(tr("Select widget to the right"), Qt::Key_Right,  1,  0);
    selectUpAct    = makeSelectAct(tr("Select widget above"),       Qt::Key_Up,     0, -1);
    selectDownAct  = makeSelectAct(tr("Select widget below"),       Qt::Key_Down,   0,  1);

    // Enabled only while editing (see setEditMode()).
    sendToFrontAct->setEnabled(false);
    sendToBackAct->setEnabled(false);
    selectLeftAct->setEnabled(false);
    selectRightAct->setEnabled(false);
    selectUpAct->setEnabled(false);
    selectDownAct->setEnabled(false);

    distributeHorizontalAct = new QAction(tr("Distribute Horizontally"), this);
    connect(distributeHorizontalAct, SIGNAL(triggered()),
            this, SLOT(distributeHorizontal()));

    distributeVerticalAct = new QAction(tr("Distribute Vertically"), this);
    connect(distributeVerticalAct, SIGNAL(triggered()),
            this, SLOT(distributeVertical()));

    alignCenterHorizontalAct = new QAction(QIcon(iconPrefix + "align-horizontal-center.svg"),
                                           tr("Center Horizontally"), this);
    connect(alignCenterHorizontalAct, SIGNAL(triggered()),
            this, SLOT(alignCenterHorizontal()));

    alignCenterVerticalAct = new QAction(QIcon(iconPrefix + "align-vertical-center.svg"),
                                         tr("Center Vertically"), this);
    connect(alignCenterVerticalAct, SIGNAL(triggered()),
            this, SLOT(alignCenterVertical()));

    storePresetAct = new QAction(tr("Store Preset"), this);
    connect(storePresetAct, SIGNAL(triggered()), this, SLOT(savePreset()));
    newPresetAct = new QAction(tr("New Preset"), this);
    connect(newPresetAct, SIGNAL(triggered()), this, SLOT(newPreset()));
    recallPresetAct = new QAction(tr("Recall Preset"), this);
    connect(recallPresetAct, SIGNAL(triggered()), this, SLOT(loadPreset()));

    setFocusPolicy(Qt::StrongFocus);

    setMouseTracking(true);

    // Default values for properties
    m_objectName = "";
    m_uuid = "";
    m_visible = true;

    // We cannot set the title now since the widgetlayout is parentless. In some systems
    // this will cause a crash
    // setWindowTitle("Widgets");
    
    // Set background ON by default, since any change in the app's palette (light/dark
    // mode) will change this background and make many existing scripts/examples
    // unreadable.
    setBackground(true,  isLightTheme ? QColor(240, 240, 240) : QColor(53, 53, 53));
    m_updating = true;
    QTimer::singleShot(500, this, SLOT(updateData())); // Delay first update
    // updateData(); // Starts updateData timer

    m_widgetNameToType["BSBSpinBox"] = QuteWidgetType::SPINBOX;
    m_widgetNameToType["BSBLineEdit"] = QuteWidgetType::LINEEDIT;
    m_widgetNameToType["BSBCheckBox"] = QuteWidgetType::CHECKBOX;
    m_widgetNameToType["BSBSlider"] = QuteWidgetType::SLIDER;
    m_widgetNameToType["BSBKnob"] = QuteWidgetType::KNOB;
    m_widgetNameToType["BSBScrollNumber"] = QuteWidgetType::SCROLLNUMBER;
    m_widgetNameToType["BSBButton"] = QuteWidgetType::BUTTON;
    m_widgetNameToType["BSBDropDown"] = QuteWidgetType::DROPDOWN;
    m_widgetNameToType["BSBController"] = QuteWidgetType::CONTROLLER;
    m_widgetNameToType["BSBGraph"] = QuteWidgetType::GRAPH;
    m_widgetNameToType["BSBScope"] = QuteWidgetType::SCOPE;
    m_widgetNameToType["BSBConsole"] = QuteWidgetType::CONSOLE;
    m_widgetNameToType["BSBTableDisplay"] = QuteWidgetType::TABLEDISPLAY;
    m_widgetNameToType["BSBWaveform"] = QuteWidgetType::WAVEFORM;
    m_widgetNameToType["BSBVUMeter"] = QuteWidgetType::VUMETER;
    m_widgetNameToType["BSBDisplay"] = QuteWidgetType::DISPLAY;
    m_widgetNameToType["BSBLabel"] = QuteWidgetType::LABEL;
}

WidgetLayout::~WidgetLayout()
{
    disconnect(this, 0,0,0);
    layoutMutex.lock();
    closing = 1;
    layoutMutex.unlock();
    while (closing == 1) {
        qApp->processEvents();
        QThread::usleep(10000);
    }
    clearGraphs();  // To free memory from curves.
    pruneRetiredWidgets();
    delete m_channelSnapshot.loadRelaxed();
    m_channelSnapshot.storeRelaxed(nullptr);
}

//unsigned int WidgetLayout::widgetCount()
//{
//  widgetsMutex.lock();
//  unsigned int number = m_widgets.size();
//  widgetsMutex.unlock();
//  return number;
//}

QuteWidgetType WidgetLayout::widgetNameToType(QString widgetName) {
    if(!m_widgetNameToType.contains(widgetName))
        return QuteWidgetType::UNKNOWN;
    return m_widgetNameToType[widgetName];
}

void WidgetLayout::loadXmlWidgets(QString xmlWidgets)
{
    // Keep the previously published channel snapshot alive while the panel is
    // being rebuilt (registerWidget() will not publish a new one); a fresh
    // snapshot is published at the end and on the early-return paths below.
    struct LoadingGuard {
        bool &flag;
        explicit LoadingGuard(bool &f) : flag(f) { flag = true; }
        ~LoadingGuard() { flag = false; }
    } loadingGuard(m_loadingWidgets);

    // Capture the runtime state (current values / latched buttons) of the
    // widgets that exist now, including previously retired ones (e.g. a widget
    // that was just deleted and is being restored by undo). The state is
    // restored into any widget with the same uuid after the reload, so a
    // structural undo/redo does not turn off running instruments or reset
    // display meters.
    const QHash<QString, RuntimeState> runtimeState = captureRuntimeState();

    m_unknownWidgetFonts.clear();
    clearWidgetLayout();
    QDomDocument doc;
    if (!doc.setContent(xmlWidgets)) {
        QMessageBox::warning(this, tr("Widget Error"),
                             tr("Widgets can't be read! No widgets created."));
        qDebug() << "WidgetLayout::loadXmlWidgets Error parsing xml text! Aborting.";
        publishChannelSnapshot();
        return;
    }
    QDomNodeList panel = doc.elementsByTagName("bsbPanel");
    if (panel.size() > 1) {
        QMessageBox::warning(this, tr("More than one panel"),
                             tr("The csd file contains more than one widget panel!\n"
                                "This is not supported by the current version,\n"
                                "Additional widget panels will be lost if the file is saved!"));
    }
    QDomNode p = panel.item(0);
    if (p.isNull()) {
        qDebug() << "WidgetLayout::loadXmlWidgets no bsbPanel element! Aborting.";
        publishChannelSnapshot();
        return;
    }
    QDomNodeList c = p.childNodes();
    int version = 0;
    for (int i = 0; i < c.size(); i++) {
        // auto t0 = std::chrono::high_resolution_clock::now();
        auto item = c.item(i);
        int ret = parseXmlNode(item);
        // auto t1 = std::chrono::high_resolution_clock::now();
        // auto diff = std::chrono::duration<double, std::milli>(t1-t0).count();
        // QDEBUG << "parseXmlNode" << item.toElement().attribute("type") << diff << "ms";
        if (ret == -1) {
            qDebug() << "WidgetLayout::loadXmlWidgets Error in Xml node parsing";
            QMessageBox::warning(this, tr("Unrecognized wigdet format"),
                                 tr("There is unrecognized widget information in the file\n"
                                    "It may be saved with errors."));
        }
        if (ret > version) {
            version = ret;
        }
    }
    restoreRuntimeState(runtimeState);
    if (version > QString(CSQT_CURRENT_XML_VERSION).toInt()) {
        qDebug() << "WidgetLayout::loadXmlWidgets Newer Widget Format version";
        QMessageBox::warning(this, tr("Newer Widget Format"),
                             tr("The file was saved by a more recent version of CsoundQt.\n"
                                "Some features may not be available and will not be saved!"));
    }
    else if (version < QString(CSQT_CURRENT_XML_VERSION).toInt()) {  // Just print a silent warning
        qDebug() << "Older widget format.";
    }
    if (m_editMode) {
        setEditMode(true);
    }

    //	if (m_contained) {
    //		adjustLayoutSize();
    //	}
    //	else {
    //		this->move(m_posx, m_posy);
    //		this->resize(m_w, m_h);
    //		//    setOuterGeometry();
    //	}
    qDebug() << "Finished loading xml widgets";
    reportUnknownWidgetFonts();
    publishChannelSnapshot();
}

void WidgetLayout::reportUnknownWidgetFonts()
{
    if (m_unknownWidgetFonts.isEmpty()) {
        return;
    }
    QStringList replacements;
    for (auto it = m_unknownWidgetFonts.constBegin();
         it != m_unknownWidgetFonts.constEnd(); ++it) {
        replacements << QStringLiteral("* %1 \u2192 %2").arg(it.key(), it.value());
    }
    QString details = replacements.join(QStringLiteral("<br>"));
    if (details.size() > 300) {
        details = details.left(297) + QStringLiteral("...");
    }
    // A transient banner is enough: this is informational, not something the
    // user has to act on. The headline is bold; details are escaped.
    const QString message =
        QStringLiteral("<b>%1</b><br>%2")
            .arg(tr("Unknown fonts were replaced").toHtmlEscaped(),
                 details.toHtmlEscaped());
    Notification::showTransient(this, message, 8000, true);
    m_unknownWidgetFonts.clear();
}

void WidgetLayout::loadXmlPresets(QString xmlPresets)
{
    QDomDocument doc;
    if (!doc.setContent(xmlPresets)) {
        qDebug() << "WidgetLayout::loadXmlPresets Error parsing preset text.";
    }
    QDomElement pl = doc.firstChildElement("bsbPresets");
    QDomNodeList presetElements = pl.elementsByTagName("preset");
    QList<int> usedNumbers;
    for (int i = 0; i < presetElements.size(); i++) {
        QDomElement presetElement = presetElements.item(i).toElement();
        int newNumber = presetElement.attribute("number", "0").toInt();
        if (!usedNumbers.contains(newNumber)) {
            WidgetPreset newPreset;
            newPreset.setName(presetElement.attribute("name", ""));
            newPreset.setNumber(newNumber);
            QDomNodeList presetValues = presetElement.elementsByTagName("value");
            for (int i = 0; i < presetValues.size(); i++) {
                QDomElement valueElement = presetValues.item(i).toElement();
                QString id = valueElement.attribute("id", "");
                int mode = valueElement.attribute("mode", "0").toInt();
                if (mode & 1) {
                    double val = valueElement.text().toDouble();
                    newPreset.addValue(id, val);
                }
                if (mode & 2) {
                    double val = valueElement.text().toDouble();
                    newPreset.addValue2(id, val);
                }
                if (mode & 4) {
                    QString val = valueElement.text();
                    newPreset.addStringValue(id, val);
                }
            }
            presets.append(newPreset);
            usedNumbers.append(newNumber);
        }
        else {
            qDebug() << "WidgetLayout::loadXmlPresets duplicate number. Ignored. " << newNumber;
        }
    }
}

QString WidgetLayout::getWidgetsText()
{
    // This function must be used with care as it accesses the widgets, which
    // may cause crashing since widgets are not reentrant
    QStringList txts = {"<bsbPanel>\n"};
    layoutMutex.lock();
    txts << "<label>" << windowTitle() << "</label>\n"
         << "<objectName>" << m_objectName << "</objectName>\n"
         << "<x>" << QString::number(m_posx) << "</x>\n"
         << "<y>" << QString::number(m_posy) << "</y>\n"
         << "<width>" << QString::number(m_w) << "</width>\n"
         << "<height>" << QString::number(m_h) << "</height>\n"
         << "<visible>" << (m_visible ? QString("true"):QString("false")) << "</visible>\n"
         << "<uuid>" << m_uuid << "</uuid>\n";

    QColor bgColor = this->property("CSQT_bgcolor").value<QColor>();
    auto bg = this->property("CSQT_bg").toBool()? QString("background"):QString("nobackground");
    txts << "<bgcolor mode=\"" << bg << "\">\n";
    txts << "<r>"<<QString::number(bgColor.red())<<"</r>\n"
         << "<g>"<<QString::number(bgColor.green())<<"</g>\n"
         << "<b>"<<QString::number(bgColor.blue())<<"</b>\n";
    txts << "</bgcolor>\n";

    layoutMutex.unlock();
    widgetsMutex.lock();
    for (int i = 0; i < m_widgets.size(); i++) {
        txts << m_widgets[i]->getWidgetXmlText() << "\n";
    }
    widgetsMutex.unlock();
    txts << "</bsbPanel>";
    return txts.join("");
}

QString WidgetLayout::getPresetsText()
{
    QStringList txts = {"<bsbPresets>\n"};
    for (int i = 0; i < presets.size(); i++) {
        txts << presets[i].getXmlText();
    }
    txts << "</bsbPresets>";
    return txts.join("");
}

QString WidgetLayout::getSelectedWidgetsText()
{
    QString l;
    l += "<bsbPanel>\n";
    widgetsMutex.lock();
    for (int i = 0; i < editWidgets.size(); i++) {
        if (editWidgets[i]->isSelected()) {
            l += m_widgets[i]->getWidgetXmlText() + "\n";
        }
    }
    widgetsMutex.unlock();
    l += "</bsbPanel>";
    return l;
}

QRect WidgetLayout::getOuterGeometry()
{
    return QRect(m_posx, m_posy, m_w, m_h);
}

void WidgetLayout::setKeyRepeatMode(bool repeat)
{
    m_repeatKeys = repeat;
}


void WidgetLayout::setDisplayValue(QString channelName, double value)
{
    // ensures unlock even on exception
    QMutexLocker locker(&widgetsMutex);

    // A VU meter's second channel is a cursor; anything else matching the
    // second channel must go through setValue2().
    auto applyValue = [&](QuteWidget *w) {
        const auto wtype = w->getWidgetTypeID();
        if (wtype != QuteWidgetType::DISPLAY && wtype != QuteWidgetType::TABLEDISPLAY
                && wtype != QuteWidgetType::VUMETER) {
            return;
        }
        if (!w->isWidgetEnabled()) {
            return; // Disabled widgets ignore updates from Csound
        }
        if (!channelName.isEmpty() && w->getChannel2Name() == channelName) {
            w->setValue2(value);
        } else {
            w->setValue(value);
        }
    };

    auto it = channelNameToWidgets.find(channelName);
    
    if (it == channelNameToWidgets.end()) {
        // First time seeing this channel - discover matching widgets
        QList<QuteWidget*> matchingWidgets;
        
        for (const auto widget : m_widgets) {
            auto wtype = widget->getWidgetTypeID();
            if (wtype != QuteWidgetType::DISPLAY && wtype != QuteWidgetType::TABLEDISPLAY
                    && wtype != QuteWidgetType::VUMETER) {
                continue;
            }
            // Only widgets actually bound to this channel (directly or through
            // their second channel). Without this check the cache entry for one
            // display channel would collect every display widget, so after the
            // cache is rebuilt (e.g. after a widget is added/removed) all meters
            // would receive each other's values.
            if (widget->getChannelName() != channelName
                    && widget->getChannel2Name() != channelName) {
                continue;
            }
            applyValue(widget);
            matchingWidgets.append(widget);
            QDEBUG << "Setting unknown display channel:" << channelName 
                   << "to" << value << "UUID: " << widget->getUuid();
        }
        
        channelNameToWidgets.insert(channelName, matchingWidgets);
    } else {
        const auto& widgets = it.value();
        for (const auto& w : widgets) {
            applyValue(w);
        }
    }
}

void WidgetLayout::setOuterGeometry(QRect r)
{
    if (!r.isValid()) {
        r = this->geometry();
        m_posx = r.x();
        m_posy = r.y();
        m_w = r.width();
        m_h = r.height();
        return;
    }
    int newx = r.x();
    int newy = r.y();
    int neww = r.width();
    int newh = r.height();
    if (newx > 0 && newy > 0 ) {
        m_posx = newx >= 0 && newx < 4096? newx : m_posx;
        m_posy = newy >= 0 && newy < 4096? newy : m_posy;
        m_w = neww >= 0 && neww < 4096? neww : m_w;
        m_h = newh >= 0 && newh < 4096? newh : m_h;
    }
}


void WidgetLayout::setValue(QString channelName, double value)
{
    QMutexLocker locker(&widgetsMutex);

    auto it = channelNameToWidgets.find(channelName);
    if (it == channelNameToWidgets.end()) {
        // First time: discover all widgets bound to this channel
        QList<QuteWidget*> matches;
        matches.reserve(m_widgets.size());

        for (auto* w : m_widgets) {
            auto match = (w->getChannelName() == channelName) + (w->getChannel2Name() == channelName)*2;
            if(match > 0) {
                matches.append(w);
                if(!w->isWidgetEnabled())
                    continue;
                if(match & 1)
                    w->setValue(value);
                if(match & 2)
                    w->setValue2(value);
            }
        }

        // Insert once with the full list (fixes the overwrite bug)
        it = channelNameToWidgets.insert(channelName, matches);
    } else {
        for (auto* w : it.value()) {
            if(!w->isWidgetEnabled())
                continue;
            if (w->getChannelName() == channelName) {
                w->setValue(value);
            }
            if (w->getChannel2Name() == channelName) {
                w->setValue2(value);
            }
        }
    }
}


void WidgetLayout::setValue(QString channelName, QString value)
{
    widgetsMutex.lock();
    auto widgets = channelNameToWidgets.constFind(channelName);
    if(widgets == channelNameToWidgets.end()) {
        // First time: discover all widgets bound to this channel and cache the
        // full list. The map is normally built by setupChannels(), but that only
        // runs when Csound starts, so this path must also work without it.
        QList<QuteWidget *> matches;
        bool matchedByUuid = false;
        for (int i = 0; i < m_widgets.size(); i++) {
            auto w = m_widgets[i];
            if (w->getChannelName() == channelName) {
                if (w->isWidgetEnabled())
                    w->setValue(value);
                matches.append(w);
            } else if (!matchedByUuid && w->getUuid() == channelName) {
                // Channel name is a widget uuid: not cached by channel.
                if (w->isWidgetEnabled())
                    w->setValue(value);
                matchedByUuid = true;
            }
        }
        if (!matches.isEmpty()) {
            channelNameToWidgets.insert(channelName, matches);
        }
    } else {
        for(const auto& w: widgets.value()) {
            if(!w->isWidgetEnabled())
                continue;
            if(w->getChannelName() == channelName) {
                w->setValue(value);
            }
        }
    }
    widgetsMutex.unlock();
}

void WidgetLayout::setValue(int index, double value)
{
    // there are two values for each widget
    widgetsMutex.lock();
    if (index < m_widgets.size() * 2) {
        if (m_widgets[index/2]->isWidgetEnabled())
            m_widgets[index/2]->setValue(value);
    }
    widgetsMutex.unlock();
}

void WidgetLayout::setValue(int index, QString value)
{
    // there are two values for each widget
    widgetsMutex.lock();
    if (index < m_widgets.size() * 2) {
        if (m_widgets[index/2]->isWidgetEnabled())
            m_widgets[index/2]->setValue(value);
    }
    widgetsMutex.unlock();
}

QString WidgetLayout::getStringForChannel(QString channelName, bool *modified)
{
    (void) modified;
    // Called from the Csound performance thread: read the lock-free snapshot
    // instead of the live widget containers.
    ChannelSnapshot *snapshot = m_channelSnapshot.loadAcquire();
    if (snapshot == nullptr) {
        return QString();
    }
    auto widgets = snapshot->channelNameToWidgets.constFind(channelName);
    if(widgets == snapshot->channelNameToWidgets.constEnd()) {
        const int count = qMin(snapshot->activeWidgets, snapshot->widgets.size());
        for (int i = 0; i < count ; i++) {
            QuteWidget *w = snapshot->widgets[i];
            if (w->getChannelName() == channelName) {
                return w->getStringValue();
            }
        }
        return QString();
    } else if(widgets.value().isEmpty()) {
        return QString();
    } else {
        auto w = widgets.value().constFirst();
        return w->getChannelName() == channelName ? w->getStringValue() : QString();
    }
   
}

double WidgetLayout::getValueForChannel(QString channelName, bool *modified, double notfound)
{
    (void) modified;
    // Called from the Csound performance thread: read the lock-free snapshot
    // instead of the live widget containers.
    ChannelSnapshot *snapshot = m_channelSnapshot.loadAcquire();
    if (snapshot == nullptr) {
        return notfound;
    }
    auto widgets = snapshot->channelNameToWidgets.constFind(channelName);
    if (widgets != snapshot->channelNameToWidgets.constEnd() && !widgets.value().isEmpty()) {
        auto w = widgets.value().constFirst();
        return w->getChannelName() == channelName ? w->getValue() : w->getValue2();
    }
    // Fallback: scan the snapshot's widget list. This covers the window in
    // which the channel cache has not been rebuilt yet (e.g. right after a
    // reload), so input channels keep working.
    const int count = qMin(snapshot->activeWidgets, snapshot->widgets.size());
    for (int i = 0; i < count; i++) {
        QuteWidget *w = snapshot->widgets[i];
        if (w->getChannelName() == channelName) {
            return w->getValue();
        }
        if (w->getChannel2Name() == channelName) {
            return w->getValue2();
        }
    }
    return notfound;
    // TODO: deal with UUID as channel name
}

void WidgetLayout::getMouseValues(QVector<double> *values)
{
    // values must have size of 6 for _MouseX _MouseY _MouseRelX _MouseRelY MouseBut1 and MouseBut2
    if (this->isEnabled()) {
        mouseLock.lockForRead();
        (*values)[0] = getMouseX();
        (*values)[1] = getMouseY();
        (*values)[2] = getMouseRelX();
        (*values)[3] = getMouseRelY();
        (*values)[4] = getMouseBut1();
        (*values)[5] = getMouseBut2();
        mouseLock.unlock();
    }
}

int WidgetLayout::getMouseX()
{
    Q_ASSERT(mouseX >= 0 && mouseX < 4096);
    return mouseX;
}

int WidgetLayout::getMouseY()
{
    Q_ASSERT(mouseY >= 0 && mouseY < 4096);
    return mouseY;
}
int WidgetLayout::getMouseRelX()
{
    if (mouseRelX >= 0 && mouseRelX < 4096)
        return mouseRelX;
    else return 0;
}

int WidgetLayout::getMouseRelY()
{
    if (mouseRelY >= 0 && mouseRelY < 4096)
        return mouseRelY;
    else return 0;
}

int WidgetLayout::getMouseBut1()
{
    return mouseBut1;
}

int WidgetLayout::getMouseBut2()
{
    return mouseBut2;
}

void WidgetLayout::setWidgetProperty(QString widgetid, QString property, QVariant value)
{
    bool changed = false;
    for (int i = 0; i < m_widgets.size(); i++) {
        if ( (m_widgets[i]->getUuid() == widgetid) || (m_widgets[i]->getChannelName() == widgetid) ) {
            m_widgets[i]->setProperty(property.toLocal8Bit(), value);
            m_widgets[i]->applyInternalProperties();
            changed = true;
            
        }
    }
    if(changed) {
        widgetChanged();
    }
}

QVariant WidgetLayout::getWidgetProperty(QString widgetid, QString property)
{
    for (int i = 0; i < m_widgets.size(); i++) {
        if ( (m_widgets[i]->getUuid() == widgetid) || (m_widgets[i]->getChannelName() == widgetid) ) {
            return m_widgets[i]->property(property.toLocal8Bit());
        }
    }
    return QVariant();
}

int WidgetLayout::newXmlWidget(QDomNode mainnode, bool offset, bool newId)
{
    if (mainnode.isNull()) {
        qDebug() << "WidgetLayout::newXmlWidget null element! Aborting.";
        return -1;
    }
    //auto t0 = std::chrono::high_resolution_clock::now();

    int ret = 0;
    auto element = mainnode.toElement();
    QuteWidget *widget = nullptr;
    QDomNodeList childNodes = mainnode.childNodes();
    QString type = element.attribute("type");
    bool forceBackground = false;
    ret = element.attribute("version").toInt();
    if (type == "BSBLabel" || type == "BSBDisplay") {

        QuteText *w = new QuteText(this);
        // Displays must stay mouse-interactive so they can show tooltips; labels
        // stay transparent for mouse events (and therefore have no tooltip).
        w->setTransparentForMouse(type == "BSBLabel");
        w->setFontOffset(m_fontOffset);
        w->setFontScaling(m_fontScaling);
        w->setType(type == "BSBLabel" ? "label" : "display");
        QDomElement ebg = element.firstChildElement("bgcolor");
        if (!ebg.isNull()) {
            if (element.attribute("mode")== "background") {
                w->setProperty("CSQT_bgcolormode", true);
            }
            w->setProperty("CSQT_bgcolor", QVariant(getColorFromElement(ebg)));
        }
        widget = static_cast<QuteWidget *>(w);
    }
    // Widgets report value changes through QuteWidget::newValue(); the signals are
    // connected centrally in registerWidget() so that every creation path (XML
    // loader and programmatic) is wired the same way.
    else if (type == "BSBSpinBox") {
        widget = static_cast<QuteSpinBox *>(new QuteSpinBox(this));
    }
    else if (type == "BSBLineEdit") {
        widget = static_cast<QuteLineEdit *>(new QuteLineEdit(this));
        forceBackground = true;
    }
    else if (type == "BSBCheckBox") {
        widget = static_cast<QuteWidget *>(new QuteCheckBox(this));
    }
    else if (type == "BSBSlider" || type == "BSBHSlider" || type == "BSBVSlider") {
        widget = static_cast<QuteWidget *>( new QuteSlider(this));
    }
    else if (type == "BSBKnob") {
        widget = static_cast<QuteWidget *>(new QuteKnob(this));
    }
    else if (type == "BSBScrollNumber") {
        QuteScrollNumber *w = new QuteScrollNumber(this);
        w->setFontOffset(m_fontOffset);
        w->setFontScaling(m_fontScaling);
        widget = static_cast<QuteWidget *>(w);
    }
    else if (type == "BSBButton") {
        QuteButton *w = new QuteButton(this);
        widget = static_cast<QuteWidget *>(w);
        connect(widget, SIGNAL(queueEventSignal(QString)),
                this, SLOT(queueEvent(QString)));
        emit registerButton(w);
    }
    else if (type == "BSBDropdown") {
        widget = static_cast<QuteWidget *>(new QuteComboBox(this));
    }
    else if (type == "BSBController") {
        //auto t0 = std::chrono::high_resolution_clock::now();
        auto w = new QuteMeter(this);
        widget = static_cast<QuteWidget *>(w);
    }
    else if (type == "BSBGraph") {
        QuteGraph *w = new QuteGraph(this);
        widget = static_cast<QuteWidget *>(w);
        connect(w, SIGNAL(requestUpdateCurve(Curve*)),
                this, SLOT(processUpdateCurve(Curve*)));
        for (int i = 0; i < curves.size(); i++) {
            w->addCurve(curves[i]);
        }
        graphWidgets.append(w);
        emit requestCsoundUserData(widget);
        emit registerGraph(w);
    }
    else if (type == "BSBScope") {
        QuteScope *w = new QuteScope(this);
        widget = static_cast<QuteWidget *>(w);
        scopeWidgets.append(w);
        emit registerScope(w);
    }
    else if (type == "BSBConsole") {
        QuteConsole *w = new QuteConsole(this);
        widget = static_cast<QuteWidget *>(w);
        consoleWidgets.append(w);
    }
    else if (type == "BSBTableDisplay") {
        auto w = new QuteTable(this);
        widget = static_cast<QuteWidget *>(w);
        emit requestCsoundUserData(w);
    }
    else if (type == "BSBWaveform") {
        auto w = new QuteWaveform(this);
        widget = static_cast<QuteWidget *>(w);
        waveformWidgets.append(w);
        emit requestCsoundUserData(widget);
    }
    else if (type == "BSBVUMeter") {
        widget = static_cast<QuteWidget *>(new QuteVUMeter(this));
    }
    else {
        qDebug() << type << " not implemented";
    }
    if (widget == nullptr) {
        qDebug() << "WidgetLayout::newXmlWidget ERROR widget has not been created!";
        return -2;
    }
    if(forceBackground) {
        widget->setProperty("CSQT_bgcolormode", true);
        widget->setProperty("CSQT_bgcolor", QColor(240, 240, 240));
    }

    for (int i = 0; i < childNodes.size() ; i++) {
        QDomElement node = childNodes.item(i).toElement();
        QString nodeName = node.nodeName();
        if (nodeName == "color" || nodeName == "bgcolor"
                || nodeName == "bordercolor"
                || nodeName == "cursorcolor") {  // COLOR type
            if (node.attribute("mode") == "background") {
                widget->setProperty("CSQT_bgcolormode", true);
            }
            nodeName.prepend("CSQT_");
            widget->setProperty(nodeName.toLocal8Bit(), getColorFromElement(node));
        }
        // It's necessary to do a type conversion here rather than storing
        // the values as QVariant strings and then converting
        // because the property will be rightly typed, and that can be queried
        else if (nodeName == "value" || nodeName == "resolution"
                 || nodeName == "minimum" || nodeName == "maximum"
                 || nodeName == "pressedValue") {  // DOUBLE type
            nodeName.prepend("CSQT_");
            widget->setProperty(nodeName.toLocal8Bit(), node.firstChild().nodeValue().toDouble());
        }
        else if (nodeName == "x") {
            auto value = node.firstChild().nodeValue().toInt();
            if(offset)
                value += 20;
            widget->setProperty("CSQT_x", value);
        }
        else if (nodeName == "y") {  // INT type (with offset)
            auto value = node.firstChild().nodeValue().toInt();
            if(offset)
                value += 20;
            widget->setProperty("CSQT_y", value);
        }
        else if (nodeName == "width" || nodeName == "height"
                 || nodeName == "fontsize"
                 || nodeName == "precision"
                 || nodeName == "padding"
                 || nodeName == "borderwidth"
                 || nodeName == "borderradius"
                 || nodeName == "borderWidth"
                 || nodeName == "borderRadius"
                 || nodeName == "selectedIndex" ) {  // INT type
            QDomNode n = node.firstChild();
            nodeName.prepend("CSQT_");
            widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue().toInt());
        }
        else if (nodeName == "midichan") {
            auto value = node.firstChild().nodeValue().toInt();
            widget->setProperty("CSQT_midichan", value);
            registerWidgetChannel(widget, value);
        }
        else if (nodeName == "midicc") {
            auto value = node.firstChild().nodeValue().toInt();
            widget->setProperty("CSQT_midicc", value);
            registerWidgetController(widget, value);
        }
        else if (nodeName == "randomizable" || nodeName == "selected"
                 || nodeName == "visible"
                 || nodeName == "enabled"
                 || nodeName == "locked"
                 || nodeName == "flatStyle"
                 || nodeName == "instant" ) {  // BOOL type
            QDomNode n = node.firstChild();
            if (nodeName == "randomizable") {
                if (node.attribute("group") != "") {
                    widget->setProperty("CSQT_randomizableGroup", node.attribute("group").toInt() );
                }
            }
            nodeName.prepend("CSQT_");
            widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue() == "true");

        }
        else if (nodeName == "bsbDropdownItemList") {  // MENU ITEM type
            if (node.attribute("mode") == "value") {
                qDebug() << "bsbDropdownItem modes not implemented!";
            }
            else if (node.attribute("mode") == "string") {
                qDebug() << "bsbDropdownItem modes not implemented!";
            }
            QDomElement item = node.firstChildElement("bsbDropdownItem");
            while (!item.isNull()) {
                QDomElement ename = item.firstChildElement("name");
                QDomElement evalue = item.firstChildElement("value");
                QDomElement estringvalue = item.firstChildElement("stringvalue");
                static_cast<QuteComboBox *>(widget)->addItem(ename.firstChild().nodeValue(),
                                                             evalue.firstChild().nodeValue().toDouble(),
                                                             estringvalue.firstChild().nodeValue());
                item = item.nextSiblingElement("bsbDropdownItem");
            }
        }
        else if (nodeName == "uuid")  {  // STRING type
            QDomNode n = node.firstChild();
            QString uuid = n.nodeValue();
            if (newId || uuid.isEmpty()) {
                uuid = QUuid::createUuid().toString();
            }
            while (!uuidFree(uuid)) {
                uuid = QUuid::createUuid().toString();
            }
            widget->setProperty("CSQT_uuid", uuid);
        }
        else if (nodeName == "widgetName")  {  // STRING type (unique within file, can be empty)
            QDomNode n = node.firstChild();
            QString widgetName = n.nodeValue().trimmed();
            if (!widgetNameFree(widgetName, widget)) {
                qDebug() << "WidgetLayout::newXmlWidget duplicate widget name" << widgetName << "- clearing it.";
                widgetName = "";
            }
            widget->setProperty("CSQT_widgetName", widgetName);
        }
        else {  // STRING type (all the rest)
            QDomNode n = node.firstChild();
            nodeName.prepend("CSQT_");
            widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue());
        }
    }

    // A widget font that is neither bundled nor a known equivalent will be
    // replaced by a bundled one (see QuteWidget::applyInternalProperties()).
    // Remember it so the user can be told when the file has finished loading.
    if (widget->property("CSQT_font").isValid()) {
        const QString requested = widget->property("CSQT_font").toString().trimmed();
        if (!requested.isEmpty() && !BundledFonts::isKnownEquivalent(requested)) {
            m_unknownWidgetFonts.insert(requested, BundledFonts::resolveFamily(requested));
        }
    }

    widget->applyInternalProperties();
    registerWidget(widget);

    // auto t1 = std::chrono::high_resolution_clock::now();
    // auto diff = std::chrono::duration<double, std::milli>(t1-t0).count();
    // QDEBUG << "newXmlWidget type" << type << "took " << diff << "ms";

    return ret;
}

bool WidgetLayout::enqueueOutputValue(const char *channelName, double value)
{
	OutputValueUpdate update;
	strncpy(update.channelName, channelName, sizeof(update.channelName) - 1);
	update.channelName[sizeof(update.channelName) - 1] = '\0';
	update.value = value;
	return m_outputValueQueue.push(update);
}

bool WidgetLayout::enqueueOutputString(const char *channelName, const char *value)
{
	OutputStringUpdate update;
	strncpy(update.channelName, channelName, sizeof(update.channelName) - 1);
	update.channelName[sizeof(update.channelName) - 1] = '\0';
	strncpy(update.value, value, sizeof(update.value) - 1);
	update.value[sizeof(update.value) - 1] = '\0';
	return m_outputStringQueue.push(update);
}

void WidgetLayout::processCsoundUpdates()
{
	// Caller #1 of newValue(): runs on the GUI thread, invoked from updateData()
	// (the GUI update timer). This is where outvalue updates queued by the Csound
	// performance thread via enqueueOutputValue()/enqueueOutputString() are applied.
	OutputValueUpdate valueUpdate;
	while (m_outputValueQueue.pop(valueUpdate)) {
		newValue(QPair<QString, double>(QString::fromLocal8Bit(valueUpdate.channelName),
		                                valueUpdate.value));
	}
	OutputStringUpdate stringUpdate;
	while (m_outputStringQueue.pop(stringUpdate)) {
		newValue(QPair<QString, QString>(QString::fromLocal8Bit(stringUpdate.channelName),
		                                 QString::fromLocal8Bit(stringUpdate.value)));
	}
}

bool WidgetLayout::widgetNameFree(const QString &name, QuteWidget *exclude)
{
    if (name.isEmpty()) {
        return true;
    }
    widgetsMutex.lock();
    auto it = m_widgetNameToWidget.constFind(name);
    bool isFree = (it == m_widgetNameToWidget.constEnd()) || (it.value() == exclude);
    widgetsMutex.unlock();
    return isFree;
}

bool WidgetLayout::renameWidget(QuteWidget *widget, const QString &newName)
{
    if (widget == nullptr) {
        return false;
    }
    widgetsMutex.lock();
    auto it = m_widgetNameToWidget.constFind(newName);
    if (!newName.isEmpty() && it != m_widgetNameToWidget.constEnd() && it.value() != widget) {
        widgetsMutex.unlock();
        return false; // Name taken by another widget
    }
    QString oldName = widget->getWidgetName();
    if (!oldName.isEmpty() && m_widgetNameToWidget.value(oldName) == widget) {
        m_widgetNameToWidget.remove(oldName);
    }
    if (!newName.isEmpty()) {
        m_widgetNameToWidget.insert(newName, widget);
    }
    widgetsMutex.unlock();
    widget->setProperty("CSQT_widgetName", newName);
    widget->setWidgetName(newName);
    return true;
}

bool WidgetLayout::uuidFree(QString uuid)
{
    bool isFree = true; // TODO need to check against uuid for widget panels and widget groups
    widgetsMutex.lock();
    for (int i = 0; i < m_widgets.size(); i++) {
        if (m_widgets[i]->getUuid() == uuid) {
            isFree = false;
            break;
        }
    }
    widgetsMutex.unlock();
    return isFree;
}

void WidgetLayout::registerWidget(QuteWidget * widget)
{
    widgetsMutex.lock();
    connect(widget, SIGNAL(widgetChanged(QuteWidget *)),
            this, SLOT(widgetChanged(QuteWidget *)));
    connect(widget, SIGNAL(widgetPropertyChanged(QuteWidget *, QString)),
            this, SLOT(widgetPropertyApplied(QuteWidget *, QString)));
    connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)),
            this, SLOT(deleteWidget(QuteWidget *)));
    connect(widget, SIGNAL(propertiesAccepted()),
            this, SLOT(markHistory()));
    connect(widget, SIGNAL(showMidiLearn(QuteWidget *)),
            this, SIGNAL(showMidiLearn(QuteWidget *)));
    // Forward user facing messages from widgets to the Csound console
    connect(widget, SIGNAL(logMessage(QString,int)),
            this, SIGNAL(logMessage(QString,int)) );
    // Widgets report value changes (from GUI interaction) through these signals,
    // and newValue() distributes the value to every widget sharing the channel.
    // Connected here so all creation paths are wired identically and widget
    // synchronization works even when Csound is not running.
    connect(widget, SIGNAL(newValue(QPair<QString,double>)),
            this, SLOT(newValue(QPair<QString,double>)));
    connect(widget, SIGNAL(newValue(QPair<QString,QString>)),
            this, SLOT(newValue(QPair<QString,QString>)));
    m_widgets.append(widget);
    channelNameToWidgets.clear();
    if (!widget->getWidgetName().isEmpty()) {
        m_widgetNameToWidget.insert(widget->getWidgetName(), widget);
    }
    //  qDebug() << "WidgetLayout::registerWidget " << m_widgets.size() << widget;
    if (m_editMode) {
        createEditFrame(widget);
        editWidgets.last()->select();
    }
    setWidgetToolTip(widget, m_tooltips);
    m_activeWidgets++;
    if (!m_loadingWidgets) {
        publishChannelSnapshotLocked();
    }
    widgetsMutex.unlock();
    adjustLayoutSize();
	widget->show();
}

void WidgetLayout::publishChannelSnapshotLocked()
{
    // widgetsMutex must be held (callers inside the layout guarantee this).
    auto *snapshot = new ChannelSnapshot;
    snapshot->channelNameToWidgets = channelNameToWidgets;
    snapshot->widgets = m_widgets;
    snapshot->activeWidgets = m_activeWidgets;
    ChannelSnapshot *old = m_channelSnapshot.fetchAndStoreRelease(snapshot);
    if (old != nullptr) {
        // An in-flight realtime read may still be using it; keep it until
        // pruneRetiredWidgets() runs.
        m_retiredSnapshots.append(old);
    }
}

void WidgetLayout::publishChannelSnapshot()
{
    QMutexLocker locker(&widgetsMutex);
    publishChannelSnapshotLocked();
}

void WidgetLayout::retireWidgetLocked(QuteWidget *widget)
{
    // Do not delete the widget: the Csound performance thread may still hold a
    // pointer to it through a published snapshot. Hide it and detach it from
    // the controller registry; it is freed by pruneRetiredWidgets().
    widget->blockSignals(true);
    widget->hide();
    unregisterWidgetController(widget);
    m_retiredWidgets.append(widget);
}

void WidgetLayout::retireFrameLocked(FrameWidget *frame)
{
    frame->blockSignals(true);
    frame->hide();
    m_retiredFrames.append(frame);
}

void WidgetLayout::pruneRetiredWidgets()
{
    // Only safe when no performance is running: the Csound performance thread
    // must not be reading retired widgets or snapshots. Called when the engine
    // stops (engineStopped()) and on destruction.
    QList<ChannelSnapshot *> snapshots;
    QList<QuteWidget *> widgets;
    QList<FrameWidget *> frames;
    widgetsMutex.lock();
    snapshots.swap(m_retiredSnapshots);
    widgets.swap(m_retiredWidgets);
    frames.swap(m_retiredFrames);
    widgetsMutex.unlock();
    qDeleteAll(snapshots);
    qDeleteAll(widgets);
    qDeleteAll(frames);
}

QHash<QString, WidgetLayout::RuntimeState> WidgetLayout::captureRuntimeState()
{
    QHash<QString, RuntimeState> state;
    widgetsMutex.lock();
    auto capture = [&state](QuteWidget *w) {
        RuntimeState s;
        s.value = w->getValue();
        s.value2 = w->getValue2();
        s.stringValue = w->getStringValue();
        state.insert(w->getUuid(), s);
    };
    // Retired first, live last: if a uuid is present in both (it normally is
    // not), the live widget wins.
    for (QuteWidget *w : m_retiredWidgets) {
        capture(w);
    }
    for (QuteWidget *w : m_widgets) {
        capture(w);
    }
    widgetsMutex.unlock();
    return state;
}

void WidgetLayout::restoreRuntimeState(const QHash<QString, RuntimeState> &state)
{
    if (state.isEmpty()) {
        return;
    }
    widgetsMutex.lock();
    for (QuteWidget *w : m_widgets) {
        auto it = state.constFind(w->getUuid());
        if (it == state.constEnd()) {
            continue;
        }
        const RuntimeState &s = it.value();
        const QuteWidgetType type = w->getWidgetTypeID();
        if (type == QuteWidgetType::LABEL) {
            // Static text; its content is not runtime state.
            continue;
        }
        if (type == QuteWidgetType::DISPLAY || type == QuteWidgetType::TABLEDISPLAY) {
            // Text-based display: restore the text. Setting the numeric value
            // would reformat the text (e.g. to "0.000").
            if (!s.stringValue.isEmpty()) {
                w->setValue(s.stringValue);
            }
            continue;
        }
        if (!s.stringValue.isEmpty()) {
            w->setValue(s.stringValue);
        }
        w->setValue(s.value);
        w->setValue2(s.value2);
    }
    widgetsMutex.unlock();
}

QString WidgetLayout::getMidiControllerInstrument()
{
	// returns full Csound instrument to pass CC values to channels
	// and/or start events (if eventButton)
	if (registeredControllers.isEmpty()) {
		qDebug() << "There are no registered controllers!";
	}

	QString instrLines ;
	for (int i = 0; i < registeredControllers.size(); i++) {
		if (registeredControllers[i].cc >= 0 && registeredControllers[i].chan>0) {
			QuteWidget * widget = registeredControllers[i].widget;

			// bool isEventButton = (widget->getWidgetType()=="BSBButton"  && widget->property("CSQT_type").toString().contains("event") ); // type "event" or "pictevent"
			bool isEventButton = (widget->getWidgetTypeID() == QuteWidgetType::BUTTON  && widget->property("CSQT_type").toString().contains("event") ); // type "event" or "pictevent"
			if ( isEventButton) {
				QString eventLine = widget->property("CSQT_eventLine").toString();

				// find out if event has negative p3
                QStringList lineElements = eventLine.split(QRegularExpression("\\s"),SKIP_EMPTY_PARTS);
				if (lineElements.size() > 0 && lineElements[0] == "i") {
					// Remove first element if it is "i"
					lineElements.removeAt(0);
				}
				else if (lineElements.size() > 0 && lineElements[0][0] == 'i') {
					lineElements[0] = lineElements[0].mid(1); // Remove "i" character
				}

				QString instrNo = lineElements[0].startsWith("\"") ?
							QString("nstrnum(%1)").arg(lineElements[0]) : lineElements[0];

				bool negative_p3;
				if (lineElements.size() > 2 && lineElements[2].toDouble() < 0 ) {
					negative_p3 = true;
				} else {
					negative_p3 = false;
				}

				if (!negative_p3) {
					instrLines += QString(R"(
	if (trigger:k(ctrl7:k(%1,%2,0,1),0.9, 0) == 1) then
		scoreline {{ %3 }}, 1 ; start
	endif)")
							.arg(registeredControllers[i].chan)
							.arg(registeredControllers[i].cc)
							.arg(eventLine) + "\n";
				} else {
					if (widget->property("CSQT_latch").toBool()) {
						// toggle button -  turn off on second press
						instrLines += QString(R"(
	if (trigger:k(ctrl7:k(%1,%2,0,1),0.9, 0)==1) then
		if (active:k(%3)>0) then
			turnoff2 %3, 4, 1 ; stop
		else
			scoreline {{ %4 }}, 1 ; start
		endif
	endif)")
							.arg(registeredControllers[i].chan)
							.arg(registeredControllers[i].cc)
							.arg(lineElements[0]) // lineElements[0] holds p1 (instrument name/number)
							.arg( eventLine )	+ "\n";
					} else { // pushbutton - turn off when released
						instrLines +=
								QString(R"(
	if (trigger:k(ctrl7:k(%1,%2,0,1),0.9, 0) == 1) then
		scoreline {{ %4 }}, 1 ; start
	endif

	if (trigger:k(ctrl7:k(%1,%2,0,1),0.1, 1) == 1) then
		turnoff2 %3, 4, 1 ; stop
	endif)")
								.arg(registeredControllers[i].chan)
								.arg(registeredControllers[i].cc)
								.arg( instrNo )
								.arg( eventLine ) + "\n";
					}
				}
			} else {
				if (widget->getWidgetTypeID()==QuteWidgetType::BUTTON &&
						widget->property("CSQT_type").toString().contains("value")) {
					instrLines += QString ("\tchnset ctrl7:k(%1, %2, 0, %3), \"%4\"\n")
							.arg(registeredControllers[i].chan)
							.arg(registeredControllers[i].cc)
							.arg( widget->property("CSQT_pressedValue").toDouble() )
							.arg(widget->getChannelName() );
				} else {
				instrLines += QString ("\tchnset ctrl7:k(%1, %2, %3, %4), \"%5\"\n")
				        .arg(registeredControllers[i].chan)
				        .arg(registeredControllers[i].cc)
				        .arg( widget->property("CSQT_minimum").toDouble() )
				        .arg( widget->property("CSQT_maximum").toDouble() )
				        .arg(widget->getChannelName() );
				}
			}
		}
	}

	QString instrString = instrLines.isEmpty() ? "" :
			"alwayson \"MidiControl\"\ninstr MidiControl\n" + instrLines + "endin\n";
	return instrString;
}

void WidgetLayout::appendMessage(QString message)
{
    appendMessage(message, (int) MessageRole::Auto);
}

void WidgetLayout::appendMessage(QString message, int role)
{

    for (int i=0; i < consoleWidgets.size(); i++) {
        if (!consoleWidgets[i]->isWidgetEnabled())
            continue;
        consoleWidgets[i]->appendMessage(message, role);
        consoleWidgets[i]->scrollToEnd();
    }
}


void WidgetLayout::flush()
{
    // Called when running Csound to flush queues
    newValues.clear();
}

void WidgetLayout::engineStopped()
{
    flushGraphBuffer();
    // No performance is running now, so retired widgets and snapshots can be
    // freed safely (the realtime input callbacks are no longer invoked).
    pruneRetiredWidgets();
}

void WidgetLayout::showWidgetTooltips(bool show)
{
    m_tooltips = show;
    widgetsMutex.lock();
    for (int i=0; i < m_widgets.size(); i++) {
        setWidgetToolTip(m_widgets[i], show);
    }
    widgetsMutex.unlock();
}

void WidgetLayout::setWidgetToolTip(QuteWidget *widget, bool show)
{
    // This function must be protected/locked by the caller
    // Labels are not tooltipped: they stay transparent for mouse events, so a
    // description on them would have no effect (and is not offered).
    if(!show || widget->getWidgetTypeID() == QuteWidgetType::LABEL) {
        widget->setToolTip("");
        if (m_editMode && getEditWidget(widget) != nullptr) {
            getEditWidget(widget)->setToolTip("");
        }
        return;
    }

    QStringList lines;

    auto description = widget->getDescription();
    if(!description.isEmpty()) {
        lines << description;
        lines << " ";
    }

    auto channelName = widget->getChannelName();
    auto channel2Name = widget->getChannel2Name();
    if(!channelName.isEmpty() && channel2Name.isEmpty()) {
        lines << tr("Channel: ") + channelName;
    }
    else if(!channel2Name.isEmpty()){
        lines << tr("ChannelH: ") + channelName + ", "
                 + tr("ChannelV: ")+ channel2Name;
    }

    int midichan = widget->property("CSQT_midichan").toInt();
    if(midichan > 0) {
        int midicc = widget->property("CSQT_midicc").toInt();
        lines << QString(tr("MIDI chan: %1 CC: %2")).arg(midichan).arg(midicc);
    }

    auto tooltip = lines.join("\n");
    widget->setToolTip(tooltip);

    if (getEditWidget(widget) != nullptr) {
        getEditWidget(widget)->setToolTip(tooltip);
    }

}

void WidgetLayout::setContained(bool contained)
{
    if (m_contained == contained) {
        return;
    }
//    qDebug() << "WidgetLayout::setContained " << contained;
    m_contained = contained;
    bool bg = this->property("CSQT_bg").toBool();
    QColor bgColor = this->property("CSQT_bgcolor").value<QColor>();
    setBackground(bg, bgColor);
    if (m_contained) {
        this->setAutoFillBackground(false);
        //    qDebug() << "WidgetLayout::setContained" << this->selectionFrame;
        this->selectionFrame->setParent(this->parentWidget());
    }
    else {
        this->selectionFrame->setParent(this); // To Avoid having it destroyed by parent
    }
}

void WidgetLayout::setCurrentPosition(QPoint pos)
{
    currentPosition = pos;
}

void WidgetLayout::setFontOffset(double offset)
{
    m_fontOffset = offset;
    widgetsMutex.lock();
    for (int i=0; i < m_widgets.size(); i++) {
        if (m_widgets[i]->getWidgetTypeID() == QuteWidgetType::LABEL ||
                m_widgets[i]->getWidgetTypeID() == QuteWidgetType::SCROLLNUMBER) {
            static_cast<QuteText *>(m_widgets[i])->setFontOffset(offset);
            m_widgets[i]->applyInternalProperties();
        }
    }
    widgetsMutex.unlock();
}

void WidgetLayout::setFontScaling(double scaling)
{
    m_fontScaling = scaling;
    widgetsMutex.lock();
    for (int i=0; i < m_widgets.size(); i++) {
        if (m_widgets[i]->getWidgetTypeID() == QuteWidgetType::LABEL ||
                m_widgets[i]->getWidgetTypeID() == QuteWidgetType::SCROLLNUMBER) {
            static_cast<QuteText *>(m_widgets[i])->setFontScaling(scaling);
            m_widgets[i]->applyInternalProperties();
        }
    }
    widgetsMutex.unlock();
}

void WidgetLayout::setWidgetsLocked(bool lock)
{
    widgetsMutex.lock();
    for (int i=0; i < m_widgets.size(); i++) {
        m_widgets[i]->setLocked(lock);
    }
    widgetsMutex.unlock();
}

void WidgetLayout::appendCurve(WINDAT *windat)
{
    // Called from the Csound callback, creates a curve and queues it for processing
    // Csound itself deletes the WINDAT structures, that's why we retain a copy of
    // the data for when Csound stops
    // It would be nice if Csound used a single windat for every f-table, but it reuses them...
    //  for (int i = 0; i < curves.size(); i++) {
    //    // Check if windat is already handled by one of the existing curves
    //    if (windat == curves[i]->getOriginal()) {
    //      return;
    //    }
    //  }
    for (int i = 0; i < curves.size(); i++) {
        // Check if caption is already present to replace curve rather than create a new one.
        if (curves[i]->get_caption() == windat->caption) {
            windat->windid = (uintptr_t) curves[i];
            return;
        }
    }
    if (curves.size() > CSQT_CURVE_BUFFER_MAX) {
        qDebug() << "WidgetLayout::appendCurve curve size exceeded. Curve discarded!";
        return;
    }
    windat->caption[CAPSIZE - 1] = 0; // Just in case...
    Polarity polarity;
    switch (windat->polarity) {
    case NEGPOL:
        polarity = POLARITY_NEGPOL;
        break;
    case POSPOL:
        polarity = POLARITY_POSPOL;
        break;
    case BIPOL:
        polarity = POLARITY_BIPOL;
        break;
    default:
        polarity = POLARITY_NOPOL;
    }
    int indexInBuffer = -1;
    //This is not working... makes fft graphs ge ignored...
    //  for (int i = 0; i < newCurveBuffer.size(); i++) {
    //    if (strcmp(newCurveBuffer[i]->getOriginal()->caption,windat->caption) && strlen(newCurveBuffer[i]->getOriginal()->caption) > 0) {
    //      indexInBuffer = i;
    //      break;
    //    }
    //  }
    if (indexInBuffer < 0) {
        auto curve = new Curve(windat->fdata,
                               (size_t)windat->npts,
                               windat->caption,
                               polarity,
                               windat->max,
                               windat->min,
                               windat->absmax,
                               windat->oabsmax,
                               windat->danflag,
                               windat);  //FIXME delete these when starting a new run
        windat->windid = (uintptr_t) curve;
        newCurveBuffer.append(curve);
        // qDebug() << "WidgetLayout::appendCurve " << curve << "__--__" << windat;
    }
    else {
        qDebug() << "WidgetLayout::appendCurve reusing curve buffer " << indexInBuffer;
        newCurveBuffer[indexInBuffer]->set_data(windat->fdata);
        newCurveBuffer[indexInBuffer]->setOriginal(windat);
    }
}

void WidgetLayout::killCurve(WINDAT *windat)
{
    qDebug() << "WidgetLayout::killCurve()";
    Curve *curve = (Curve *) getCurveById(windat->windid);
    curve->setOriginal(nullptr);
}

void WidgetLayout::newCurve(Curve* curve)
{
    // qDebug() << "WidgetPanel::newCurve" << curve << curve->get_caption();
    //  FIXME check if curve is a new curve for a old ftable
    //  for (int i = 0; i < curves.size(); i++) {
    //    if (curves[i]->get_caption() == curve->get_caption()) {
    //      return;
    //    }
    //  }

    curves.append(curve);
    for (int i = 0; i < graphWidgets.size(); i++) {
        graphWidgets[i]->addCurve(curve);
    }
}

void WidgetLayout::setCurveData(Curve *curve)
{
    //  qDebug() << "WidgetPanel::setCurveData" <<curve;
    for (int i = 0; i < graphWidgets.size(); i++) {
        if (graphWidgets[i]->isWidgetEnabled())
            graphWidgets[i]->setCurveData(curve);
    }
}

//void WidgetLayout::passWidgetClipboard(QString text)
//{
//  m_clipboard = text;
//}

uintptr_t WidgetLayout::getCurveById(uintptr_t id)
{
    //  qDebug() << "WidgetLayout::getCurveById ";
    foreach (Curve *thisCurve, curves) {
        // qDebug() << "WidgetLayout::getCurveById " << (uintptr_t)thisCurve << "id" << id;
        if ((uintptr_t) thisCurve == id)
            return (uintptr_t) thisCurve;
    }
    return 0;
}

void WidgetLayout::updateCurve(WINDAT *windat)
{
    //  qDebug() << "WidgetLayout::updateCurve(WINDAT *windat) " << windat->windid;
    if (curveUpdateBufferCount+1 < CSQT_CURVE_BUFFER_SIZE) {
        curveUpdateBufferCount++;
        curveUpdateBuffer[curveUpdateBufferCount] = *windat;
    }
}

void WidgetLayout::processUpdateCurve(Curve *curve) {
    WINDAT *orig = curve->getOriginal();
    this->updateCurve(orig);
}


int WidgetLayout::killCurves(CSOUND * /*csound*/)
{
    //  qDebug() << "qutecsound::killCurves";
    // TODO this is a great idea, to copy data from the tables at the end of run,
    // but the API is not working as expected
    //  for (int i = 0; i < curves.size(); i++) {
    //    WINDAT * windat = curves[i]->getOriginal();
    //    if (windat->npts > 0 && windat->windid == (uintptr_t)curves[i]) { // Check for sanity of pointer
    //      curves[i]->set_size(windat->npts);      // number of points
    //      curves[i]->set_data(windat->fdata);
    //      curves[i]->set_caption(QString(windat->caption)); // title of curve
    //      //    curves[i]->set_polarity(windat->polarity); // polarity
    //      curves[i]->set_max(windat->max);        // curve max
    //      curves[i]->set_min(windat->min);        // curve min
    //      curves[i]->set_absmax(windat->absmax);     // abs max of above
    //      //    curves[i]->set_y_scale(windat->y_scale);    // Y axis scaling factor
    //      curves[i]->setOriginal(0);
    //    }
    //  }

    // Curves are freed not when Csound finishes, but when Csound is run again,
    // to have them available even if Csound is stopped.
    return 0;
}

void WidgetLayout::clearGraphs()
{
    flushGraphBuffer();
    bool updating = m_updating;
    m_updating = false;
    QMutexLocker locker(&layoutMutex);
    for (int i = 0; i < graphWidgets.size(); i++) {
        graphWidgets[i]->clearCurves();
    }
    while (curves.size() > 0) {
        Curve * c = curves.takeFirst();
        delete c;
    }
    m_updating = updating;
}

void WidgetLayout::flushGraphBuffer()
{
    bool updating = m_updating;
    m_updating = false;
    if(!layoutMutex.tryLock(200)) {
        QDEBUG << "Could not acquire lock, not flushing...";
        m_updating = updating;
        return;
    }
    while (newCurveBuffer.size() > 0) {
        Curve * c = newCurveBuffer.takeFirst();
        delete c;
    }
    curveUpdateBufferCount = 0;
    layoutMutex.unlock();
    m_updating = updating;
}

void WidgetLayout::refreshWidgets()
{
    while (midiReadCounter != midiWriteCounter) {
        // TODO it is inefficient to have this per layout (when more than one
        // layout is available)
        int index =midiReadCounter;
        int status = midiQueue[index][0];
        if (status & 176) { // MIDI control change
            int channel = (status ^ 176) + 1;
            for (int i = 0; i < registeredControllers.size(); i++) {
                if (registeredControllers[i].cc == midiQueue[index][1]) {
					if ( channel == registeredControllers[i].chan) {
                        if (registeredControllers[i].widget->isWidgetEnabled())
                            registeredControllers[i].widget->setMidiValue(midiQueue[index][2]);
                    }
                }
            }
        }
        midiReadCounter++;
        midiReadCounter = midiReadCounter%CSQT_MAX_MIDI_QUEUE;
    }
    QMutexLocker locker(&widgetsMutex);

    // Fetch mouse values once per refresh if any widget is driven by them.
    int mouseX = 0, mouseY = 0, mouseRelX = 0, mouseRelY = 0;
    int mouseBut1 = 0, mouseBut2 = 0;
    if (m_trackMouse) {
        mouseX    = getMouseX();
        mouseY    = getMouseY();
        mouseRelX = getMouseRelX();
        mouseRelY = getMouseRelY();
        mouseBut1 = getMouseBut1();
        mouseBut2 = getMouseBut2();
    }

    // the lambda should be inlined and optimized by the compiler, so it should not be a performance issue
    auto mouseValue = [&](MouseParam p) -> int {
        switch (p) {
        case MouseParam::X:    return mouseX;
        case MouseParam::Y:    return mouseY;
        case MouseParam::RelX: return mouseRelX;
        case MouseParam::RelY: return mouseRelY;
        case MouseParam::But1: return mouseBut1;
        case MouseParam::But2: return mouseBut2;
        default:               return 0;
        }
    };

    for (int i=0; i < m_widgets.size(); i++) {
        if (m_widgets[i]->isWidgetEnabled()
                && (m_widgets[i]->m_valueChanged || m_widgets[i]->m_value2Changed)) {
            m_widgets[i]->refreshWidget();
        }
        if (m_trackMouse) {
            if (m_widgets[i]->isWidgetEnabled() && m_widgets[i]->mouseParam1 != MouseParam::None) {
                m_widgets[i]->setValue(mouseValue(m_widgets[i]->mouseParam1));
            }
            if (m_widgets[i]->isWidgetEnabled() && m_widgets[i]->mouseParam2 != MouseParam::None) {
                m_widgets[i]->setValue2(mouseValue(m_widgets[i]->mouseParam2));
            }
        }
    }
}

QString WidgetLayout::getCsladspaLines()
{
    QString text = "";
    int unsupported = 0;
    widgetsMutex.lock();
    foreach(QuteWidget *widget, m_widgets) {
        QString line = widget->getCsladspaLine();
        if (line != "") {
            text += line + "\n";
        }
        else {
            unsupported++;
        }
    }
    widgetsMutex.unlock();
    qDebug() << "WidgetPanel:getCsladspaLines() " << unsupported << " Unsupported widgets";
    return text;
}

QString WidgetLayout::getQml()
{
    QString qml = "import QtQuick 2.0\nimport QtQuick.Controls 2.0 // NB! Requires Qt 5.7 or later. Rewrite with QtQuick.Controls 1.X if using older Qt versions \n\n";
    //QString s2 = QString(R"()");
    qml += "Rectangle {\n";
    QColor bgcolor = this->palette().color(QWidget::backgroundRole());
    qml+=QString("\tcolor: \"%1\"\n").arg(bgcolor.name());

    // get width and hight currently from panel size, maybe not best method -
    // test how if works if some of the window is hidden
    int w = this->geometry().width() + 20;
    int h = this->geometry().height() +20;

    qml += QString("\twidth: %1\n").arg(w);
    qml += QString("\theight: %1\n").arg(h);

    qml += "\tanchors.fill: parent\n";
    qml += "\n\n\tFlickable {\n\tanchors.fill: parent\n";
    qml += QString("\tcontentWidth: %1\n").arg(w);
    qml += QString("\tcontentHeight: %1\n").arg(h);

    qml += "\n";

    qml += QString(
        R"(
            Item {
                id: scaleItem
                anchors.fill: parent
            }

            PinchArea {
                anchors.fill: parent
                pinch.maximumScale: 2.5
                pinch.minimumScale: 0.6
                pinch.target: scaleItem

               MouseArea {  // necessary for co-existense of flickable an pincharea
                   anchors.fill: parent
                   onClicked: console.log("Clicked tiny")
                   propagateComposedEvents: true
               }
           }
        )");


    int unsupported = 0;
    widgetsMutex.lock();
    foreach(QuteWidget *widget, m_widgets) {
        QString line = widget->getQml();
        if (line != "") {
            qml += line + "\n";
        }
        else {
            unsupported++;
        }
    }
    widgetsMutex.unlock();
    qDebug() << "WidgetPanel:getQml() " << unsupported << " Unsupported widgets";
    qml += "\t} // end Flickable\n";
    qml += "} // end Rectangle\n"; // end Rectangle
    //qDebug() << qml;
    return qml;
}

QString WidgetLayout::getCabbageWidgets()
{
    QString title = windowTitle();
    QString text = "form caption(\"" + title  + "\"),";
    //text += "size(" + QString::number(m_w+20) + "," + QString::number(m_h+20) +")\n"; // m_w and m_h not returning correct results always
    int w = this->geometry().width();
    int h = this->geometry().height();
    text += QString(" size(%1,%2)\n").arg(w+20).arg(h+20);

    int unsupported = 0;
    widgetsMutex.lock();
    QString unsupportedWidgets;
    foreach(QuteWidget *widget, m_widgets) {
        QString line = widget->getCabbageLine();
        if (line != "") {
            text += line + "\n";
        }
        else {
            unsupported++;
            unsupportedWidgets += widget->getWidgetType() + " ";
        }
    }
    widgetsMutex.unlock();
    qDebug() << "WidgetPanel:getCabbageWidgets()"<<unsupported<<"Unsupported widgets";
    if (unsupported) {
        QMessageBox::warning(this, tr("CsoundQt"), tr("Could not convert %1 widget(s):\n%2")
                             .arg(unsupported).arg(unsupportedWidgets));
    }
    return text;
}

bool WidgetLayout::isModified()
{
    return m_modified;
}

void WidgetLayout::addCreateWidgetActionsToMenu(QMenu &menu) {
    menu.addAction(createSliderAct);
    menu.addAction(createLabelAct);
    menu.addAction(createDisplayAct);
    menu.addAction(createScrollNumberAct);
    menu.addAction(createLineEditAct);
    menu.addAction(createSpinBoxAct);
    menu.addAction(createButtonAct);
    menu.addAction(createKnobAct);
    menu.addAction(createCheckBoxAct);
    menu.addAction(createMenuAct);
    menu.addAction(createMeterAct);
    menu.addAction(createConsoleAct);
    menu.addAction(createGraphAct);
    menu.addAction(createScopeAct);
    menu.addAction(createTableDisplayAct);
    menu.addAction(createWaveformAct);
    menu.addAction(createVUMeterAct);
}

void WidgetLayout::createContextMenu(QContextMenuEvent *event)
{
    QMenu menu;
    QMenu newMenu(tr("New Widget", "New Widget submenu in widget layout popup"), &menu);
    this->addCreateWidgetActionsToMenu(newMenu);
    menu.addMenu(&newMenu);
    menu.addSeparator(); // ------------------------------------------------------------

    QMenu editMenu(tr("Edit", "Edit menu in widget layout right-click menu"), &menu);
    editMenu.addAction(cutAct);
    editMenu.addAction(copyAct);
    editMenu.addAction(pasteAct);
    editMenu.addAction(selectAllAct);
    // Shortcut from the duplicate action is not working from some reason...
    //  menu.addAction(duplicateAct);
    editMenu.addAction(clearAct);
    menu.addMenu(&editMenu);

    menu.addSeparator(); // ------------------------------------------------------------

    QMenu presetMenu(tr("Presets", "Preset submenu in widget layout popup"), &menu);
    presetMenu.addAction(storePresetAct);
    presetMenu.addAction(recallPresetAct);
    presetMenu.addAction(newPresetAct);
    menu.addMenu(&presetMenu);

    menu.addSeparator(); // ------------------------------------------------------------

    menu.addAction(propertiesAct);
    menu.addAction(reloadWidgetsAct);

    currentPosition = event->pos();
    //  if (m_sbActive) {
    //    currentPosition.setX(currentPosition.x() + scrollArea->horizontalScrollBar()->value());
    //    currentPosition.setY(currentPosition.y() + scrollArea->verticalScrollBar()->value() - 20);
    //  }
    menu.exec(event->globalPos());
    //  menu.exec(event->pos());
}

void WidgetLayout::deselectAll()
{
    for (int i = 0; i< editWidgets.size(); i++) {
        editWidgets[i]->deselect();
    }
}

void WidgetLayout::selectAll()
{
    // Locked widgets are not caught by "Select All" either; use an individual
    // click or Ctrl+click to select them.
    const int count = qMin(editWidgets.size(), m_widgets.size());
    for (int i = 0; i < count; i++) {
        if (m_widgets[i]->property("CSQT_locked").toBool())
            continue;
        editWidgets[i]->select();
    }
}

QList<QuteWidget *> WidgetLayout::getSelectedWidgets()
{
    // m_widgets and editWidgets are kept parallel; a widget is selected when its
    // edit frame is. Returns an empty list when not in edit mode.
    QList<QuteWidget *> selected;
    const int count = qMin(editWidgets.size(), m_widgets.size());
    for (int i = 0; i < count; i++) {
        if (editWidgets[i]->isSelected()) {
            selected.append(m_widgets[i]);
        }
    }
    return selected;
}

void WidgetLayout::widgetMoved(QPair<int, int> delta)
{
    widgetsMutex.lock();
    for (int i = 0; i < m_widgets.size(); i++) {
        if (editWidgets[i]->isSelected()) {
            // Locked widgets (labels) keep their position even in a group drag.
            if (m_widgets[i]->property("CSQT_locked").toBool())
                continue;
            int newx = m_widgets[i]->x() + delta.first;
            int newy = m_widgets[i]->y() + delta.second;
            m_widgets[i]->move(newx, newy);
            editWidgets[i]->move(newx, newy);
			// set the position to properties otherwis MidiLearn -> applyInetrnalProperties sets it to wrong (old) position
			m_widgets[i]->setProperty("CSQT_x", newx);
			m_widgets[i]->setProperty("CSQT_y", newy);

        }
    }
    widgetsMutex.unlock();
    adjustLayoutSize();
}

void WidgetLayout::widgetResized(QPair<int, int> delta)
{
    //   qDebug("WidgetPanel::widgetResized %i  %i", delta.first, delta.second);
    widgetsMutex.lock();
    for (int i = 0; i< editWidgets.size(); i++) {
        if (editWidgets[i]->isSelected()) {
            int neww = m_widgets[i]->width() + delta.first;
            int newh = m_widgets[i]->height() + delta.second;
            neww = neww > 5 ? neww : 5;
            newh = newh > 5 ? newh : 5;
            m_widgets[i]->setWidgetGeometry(m_widgets[i]->x(), m_widgets[i]->y(), neww, newh);
            editWidgets[i]->resize(neww, newh);
			// set the position to properties otherwis MidiLearn -> applyInetrnalProperties sets it to wrong (old) position
			m_widgets[i]->setProperty("CSQT_width", neww);
			m_widgets[i]->setProperty("CSQT_height", newh);
        }
    }
    widgetsMutex.unlock();
    adjustLayoutSize();
}

void WidgetLayout::widgetResizedTopLeft(QPair<int, int> delta)
{
    // Dragging the top-left corner moves the origin and resizes from the opposite
    // (right/bottom) edges, which stay fixed.
    widgetsMutex.lock();
    for (int i = 0; i < editWidgets.size(); i++) {
        if (!editWidgets[i]->isSelected())
            continue;
        int x = m_widgets[i]->x();
        int y = m_widgets[i]->y();
        int w = m_widgets[i]->width();
        int h = m_widgets[i]->height();
        // Clamp so the size stays >= 5 and the opposite edges do not move.
        int dx = qMin(delta.first, qMax(0, w - 5));
        int dy = qMin(delta.second, qMax(0, h - 5));
        int newx = x + dx;
        int newy = y + dy;
        int neww = w - dx;
        int newh = h - dy;
        m_widgets[i]->setWidgetGeometry(newx, newy, neww, newh);
        editWidgets[i]->setGeometry(newx, newy, neww, newh);
        // Keep the properties in sync (see widgetResized()).
        m_widgets[i]->setProperty("CSQT_x", newx);
        m_widgets[i]->setProperty("CSQT_y", newy);
        m_widgets[i]->setProperty("CSQT_width", neww);
        m_widgets[i]->setProperty("CSQT_height", newh);
    }
    widgetsMutex.unlock();
    adjustLayoutSize();
}

void WidgetLayout::mousePressEventParent(QMouseEvent *event)
{
    WidgetLayout::mousePressEvent(event);
}

void WidgetLayout::mouseReleaseEventParent(QMouseEvent *event)
{
    WidgetLayout::mouseReleaseEvent(event);
}

void WidgetLayout::mouseMoveEventParent(QMouseEvent *event)
{
    WidgetLayout::mouseMoveEvent(event);
}

QSize WidgetLayout::getUsedSize()
{
    int width = 30, height = 30;
    for (int i = 0; i< m_widgets.size(); i++) {
        if (m_widgets[i]->x() + m_widgets[i]->width() > width) {
            width = m_widgets[i]->x() + m_widgets[i]->width();
        }
        if (m_widgets[i]->y() + m_widgets[i]->height() > height) {
            height = m_widgets[i]->y() + m_widgets[i]->height();
        }
    }
    return QSize(width, height);
}

void WidgetLayout::adjustLayoutSize()
{
    if (m_contained) {
        QSize s = this->childrenRect().size();
        QPoint pos = this->childrenRect().topLeft();
        s.rwidth() += pos.x();
        s.rheight() += pos.y();
        if (this->size() != s) {
            this->resize(s);
        }
    }
}

void WidgetLayout::adjustWidgetSize()
{
    if (m_contained) {
        // Contained in the widget panel's scroll area: the effective size is
        // derived from the children (the containing scroll area owns the
        // geometry otherwise). adjustWidgetSize() is called when a document is
        // shown, so make it a no-op only for the standalone-window case.
        adjustLayoutSize();
    } else {
        this->resize(m_w, m_h);
        this->move(m_posx, m_posy);
    }
}

void WidgetLayout::selectionChanged(QRect selection)
{
    //   qDebug("WidgetLayout::selectionChanged %i %i %i %i", selection.x(), selection.y(), selection.width(), selection.height());
    if (editWidgets.isEmpty())
        return; //not in edit mode

    // Only toggle widgets whose selection actually changed. Selecting/clearing
    // selection repolishes the widget's stylesheet, so doing it for every widget
    // on every mouse move made rubber-band dragging very slow.
    QVector<int> toSelect;
    QVector<int> toDeselect;
    widgetsMutex.lock();
    for (int i = 0; i< m_widgets.size(); i++) {
        int x = m_widgets[i]->x();
        int y = m_widgets[i]->y();
        int w = m_widgets[i]->width();
        int h = m_widgets[i]->height();
        bool inSelection = (x > selection.x() - w && x < selection.x() + selection.width() &&
                            y > selection.y() - h && y < selection.y() + selection.height());
        // Locked widgets are not picked up by the rubber band; they can still be
        // selected individually or toggled with Ctrl+click.
        if (inSelection && !m_widgets[i]->property("CSQT_locked").toBool()
                && !editWidgets[i]->isSelected())
            toSelect.append(i);
        else if (!inSelection && editWidgets[i]->isSelected())
            toDeselect.append(i);
    }
    widgetsMutex.unlock();

    // Apply outside the lock: select()/deselect() emit signals that may call back.
    for (int i : toDeselect)
        editWidgets[i]->deselect();
    for (int i : toSelect)
        editWidgets[i]->select();
}

QString WidgetLayout::createNewSlider(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "slider" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    uuid = createSlider(posx, posy, 20, 100, channel, 0.0, 1.0, 0.0);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}


QString WidgetLayout::createNewLabel(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "label" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    QColor fgColor = qApp->palette().color(QPalette::WindowText);
    QColor bgColor = qApp->palette().color(QPalette::Window);
    uuid = createText(posx, posy, 80, 25, "label", QString(),
                      "left", "Arial", 10, fgColor, bgColor,
                      false, "noborder", channel);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewDisplay(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "display" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    QColor fgColor = qApp->palette().color(QPalette::WindowText);
    QColor bgColor = qApp->palette().color(QPalette::Window);
    uuid = createText(posx, posy, 80, 25, "display", channel,
                      "left", "Arial", 10, fgColor, bgColor,
                      false, "border", "Display");
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewScrollNumber(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "scroll" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    QColor fgColor = qApp->palette().color(QPalette::WindowText);
    QColor bgColor = qApp->palette().color(QPalette::Window);
    uuid = createScrollNumber(posx, posy, 80, 25, channel,
                              "left", "Arial", 10, fgColor, bgColor,
                              true, "border", 0.001, 0.0);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewLineEdit(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "line" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    QColor fgColor = qApp->palette().color(QPalette::WindowText);
    QColor bgColor = qApp->palette().color(QPalette::Window);
    uuid = createLineEdit(posx, posy, 100, 25, channel,
                          "left", "Arial", 10, fgColor, bgColor,
                          true, "border", "Type here");
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewSpinBox(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "spinbox" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    QColor fgColor = qApp->palette().color(QPalette::WindowText);
    QColor bgColor = qApp->palette().color(QPalette::Window);
    uuid = createSpinBox(posx, posy, 80, 25, channel,
                         "left", "Arial", 10, fgColor, bgColor,
                         false, "noborder", 0.001, 0.0);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewButton(int x, int y, QString channel)
{
    qDebug() << "WidgetLayout::createNewButton";
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "button" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    //IS IT OK if the channel name is alsoset as the text of the button?
    uuid = createButton(posx, posy, 100, 30, channel, "event", 1.0, channel, "/", "i1 0 10");
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewKnob(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "knob" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    uuid = createKnob(posx, posy, 80, 80, channel, 0.0, 1.0, 0.01, 0.0);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewCheckBox(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "checkbox" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    uuid = createCheckBox(posx, posy, 20, 20, channel, false);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewMenu(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "menu" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    uuid = createMenu(posx, posy, 80, 30, channel, "item1,item2,item3", 1);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewMeter(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "meter" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    QString channel2 = "hor" + QString::number(m_widgets.size());
    // Legacy default meter color {0, 60000, 0} in 0-65535 range
    uuid = createMeter(posx, posy, 30, 80, channel, channel2,
                       QColor(0, 234, 0), "fill", 0.0, 0.0, 1, 0);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}


QString WidgetLayout::createNewConsole(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "console" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    uuid = createConsole(posx, posy, 320, 400);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewGraph(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "graph" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    uuid = createGraph(posx, posy, 350, 150);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewTableDisplay(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "graph" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    uuid = createTableDisplay(posx, posy, 350, 150);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewWaveform(int x, int y, QString channel)
{
    Q_UNUSED(channel);
    const int posx = x >= 0 ? x : currentPosition.x();
    const int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    QString uuid = createWaveform(posx, posy, 500, 160);
    widgetChanged();
    if (getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewVUMeter(int x, int y, QString channel)
{
    Q_UNUSED(channel);
    const int posx = x >= 0 ? x : currentPosition.x();
    const int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    // Default: vertical meter with a 20x100 bar, plus room for the ruler
    // labels (to the right) and the value (below), so nothing is cropped.
    QFontMetrics fm(font());
    const int width = 20 + fm.horizontalAdvance(QStringLiteral("-000")) + 10;
    const int height = 100 + fm.height() + 2;
    QString uuid = createVUMeter(posx, posy, width, height);
    widgetChanged();
    if (getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

QString WidgetLayout::createNewScope(int x, int y, QString channel)
{
    QString uuid;
    bool dialog;
    int posx = x >= 0 ? x : currentPosition.x();
    int posy = y >= 0 ? y : currentPosition.y();
    deselectAll();
    if (channel.isEmpty()) {
        channel = "scope" + QString::number(m_widgets.size());
        dialog = true;
    } else {
        dialog = false;
    }
    // -255 selects all channels (see QuteScope channel box)
    uuid = createScope(posx, posy, 350, 150, "scope", 2.0, -255);
    widgetChanged();
    if (dialog && getOpenProperties()) {
        m_widgets.last()->openProperties();
    }
    markHistory();
    return uuid;
}

void WidgetLayout::clearWidgets()
{
    clearWidgetLayout();
    widgetChanged();
}

void WidgetLayout::clearWidgetLayout()
{
    //   qDebug("WidgetLayout::clearWidgetLayout()");
    widgetsMutex.lock();
    m_activeWidgets = 0;
    // Retire the widgets instead of deleting them: the Csound performance
    // thread may still be reading them through the published channel snapshot.
    // They are actually freed by pruneRetiredWidgets() when no performance is
    // running (see engineStopped()).
    foreach (QuteWidget *widget, m_widgets) {
        retireWidgetLocked(widget);
    }
    m_widgets.clear();
    channelNameToWidgets.clear();
    m_widgetNameToWidget.clear();
    foreach (FrameWidget *frame, editWidgets) {
        //     qDebug("WidgetLayout::clearWidgetLayout() removed editWidget");
        retireFrameLocked(frame);
    }
    editWidgets.clear();
    consoleWidgets.clear();
    graphWidgets.clear();
    scopeWidgets.clear();
    waveformWidgets.clear();
    if (!m_loadingWidgets) {
        publishChannelSnapshotLocked();
    }
    widgetsMutex.unlock();
}


QStringList WidgetLayout::getUuids()
{   QStringList uuids = QStringList();
    for (int i=0; i<m_widgets.size(); i++) {
        uuids.append( m_widgets[i]->getUuid() );
    }
    return uuids;
}

QStringList WidgetLayout::listProperties(QString widgetid)
{

    QStringList prop_names = QStringList();
    for (int i = 0; i < m_widgets.size(); i++) {
        if ( (m_widgets[i]->getUuid() == widgetid) || (m_widgets[i]->getChannelName() == widgetid) ) {
            QList<QByteArray> props= m_widgets[i]->dynamicPropertyNames();

            foreach (QByteArray prop, props) {
                prop_names << QString(prop);
            }
            return prop_names;

        }
    }
    return QStringList();

}


bool WidgetLayout::destroyWidget(QString widgetid)
{
    for (int i = 0; i < m_widgets.size(); i++) {
        if ( (m_widgets[i]->getUuid() == widgetid) || (m_widgets[i]->getChannelName() == widgetid) ) {
            // is it necessary to use widgetsMutex.lock(); / unlock?
            deleteWidget(m_widgets[i]);
            markHistory();  // is it necessary here? probably yes, possible to undo
            return true;
        }
    }

    return false;
}

void WidgetLayout::propertiesDialog()
{
    QDialog *dialog = new QDialog(this);
    dialog->resize(300, 120);
    dialog->setModal(true);
    dialog->setWindowTitle("Widget Panel");
    QGridLayout *layout = new QGridLayout(dialog);
    bgCheckBox = new QCheckBox(dialog);
    bgCheckBox->setText("Enable Background");
    if (m_contained) {
        bgCheckBox->setChecked(parentWidget()->autoFillBackground());
    }
    else {
        bgCheckBox->setChecked(this->autoFillBackground());
    }
    layout->addWidget(bgCheckBox, 0, 0, Qt::AlignRight|Qt::AlignVCenter);
    QLabel *label = new QLabel(dialog);
    label->setText("Color");
    label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
    layout->addWidget(label, 1, 0, Qt::AlignRight|Qt::AlignVCenter);
    bgButton = new QPushButton(dialog);
    QPixmap pixmap = QPixmap(64,64);
    QColor color;
    if (m_contained) {
        color = parentWidget()->palette().button().color();
    }
    else {
        color = this->palette().button().color();
    }
    bgButton->setProperty("CSQT_color",QVariant(color));
    pixmap.fill(color);
    bgButton->setIcon(pixmap);
    layout->addWidget(bgButton, 1, 1, Qt::AlignLeft|Qt::AlignVCenter);
    QPushButton *applyButton = new QPushButton(tr("Apply"));
    layout->addWidget(applyButton, 9, 1, Qt::AlignCenter|Qt::AlignVCenter);
    QPushButton *cancelButton = new QPushButton(tr("Cancel"));
    layout->addWidget(cancelButton, 9, 2, Qt::AlignCenter|Qt::AlignVCenter);
    QPushButton *acceptButton = new QPushButton(tr("Ok"));
    layout->addWidget(acceptButton, 9, 3, Qt::AlignCenter|Qt::AlignVCenter);
    connect(acceptButton, SIGNAL(released()), dialog, SLOT(accept()));
    connect(dialog, SIGNAL(accepted()), this, SLOT(applyProperties()));
    connect(applyButton, SIGNAL(released()), this, SLOT(applyProperties()));
    connect(cancelButton, SIGNAL(released()), dialog, SLOT(close()));
    connect(bgButton, SIGNAL(released()), this, SLOT(selectBgColor()));
    dialog->exec();
}

void WidgetLayout::applyProperties()
{
    QColor color = bgButton->property("CSQT_color").value<QColor>();
    setBackground(bgCheckBox->isChecked(), color);
    widgetChanged();
    mouseBut2 = 0;  // Button un clicked is not propagated after opening the edit dialog. Do it artificially here
}

void WidgetLayout::selectBgColor()
{
    QColor color;
    if (m_contained) {
        color = QColorDialog::getColor(parentWidget()->palette().button().color(), this);
    }
    else {
        color = QColorDialog::getColor(this->palette().button().color(), this);
    }
    if (color.isValid()) {
        bgButton->setProperty("CSQT_color",QVariant(color));
        QPixmap pixmap(64,64);
        pixmap.fill(color);
        bgButton->setIcon(pixmap);
    }
}

void WidgetLayout::alignLeft()
{
    int leftmost = 99999;
    if (m_editMode) {
        widgetsMutex.lock();
        int size = editWidgets.size();
        for (int i = 0; i < size ; i++) { // First find leftmost
            if (editWidgets[i]->isSelected())
                leftmost =  qMin(leftmost, editWidgets[i]->x());
        }
        if(leftmost == 99999) {
            // no widgets selected
            widgetsMutex.unlock();
            return;
        }
        for (int i = 0; i < size ; i++) { // Then put all x values to that
            if (editWidgets[i]->isSelected()) {
                editWidgets[i]->move(leftmost, editWidgets[i]->y());
                m_widgets[i]->move(leftmost, editWidgets[i]->y());
            }
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::alignRight()
{
    int rightmost = -1;
    if (m_editMode) {
        widgetsMutex.lock();
        int size = editWidgets.size();
        for (int i = 0; i < size ; i++) { // First find leftmost
            if (editWidgets[i]->isSelected())
                rightmost = qMax(rightmost, editWidgets[i]->x() + editWidgets[i]->width());
        }
        if(rightmost < 0) {
            // no widgets selected
            widgetsMutex.unlock();
            return;
        }
        for (int i = 0; i < size ; i++) { // Then put all x values to that
            if (editWidgets[i]->isSelected()) {
                int x = rightmost - editWidgets[i]->width();
                editWidgets[i]->move(x, editWidgets[i]->y());
                m_widgets[i]->move(x, editWidgets[i]->y());
            }
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::alignTop()
{
    int top = 99999;
    if (m_editMode) {
        widgetsMutex.lock();
        int size = editWidgets.size();
        for (int i = 0; i < size ; i++) { // First find uppermost
            if (editWidgets[i]->isSelected())
                top = editWidgets[i]->y() < top ? editWidgets[i]->y(): top;
        }
        if(top == 99999) {
            // no widgets selected
            widgetsMutex.unlock();
            return;
        }
        for (int i = 0; i < size ; i++) { // Then put all y values to that
            if (editWidgets[i]->isSelected()) {
                editWidgets[i]->move(editWidgets[i]->x(), top);
                m_widgets[i]->move(editWidgets[i]->x(), top);
            }
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::alignBottom()
{
    int bottom = -1;
    if (m_editMode) {
        widgetsMutex.lock();
        int size = editWidgets.size();
        for (int i = 0; i < size ; i++) {
            if (editWidgets[i]->isSelected())
                bottom = qMax(bottom, editWidgets[i]->y()+editWidgets[i]->height());
        }
        if(bottom < 0) {
            // no widgets selected
            widgetsMutex.unlock();
            return;
        }
        for (int i = 0; i < size ; i++) {
            if (editWidgets[i]->isSelected()) {
                int y = bottom - editWidgets[i]->height();
                editWidgets[i]->move(editWidgets[i]->x(), y);
                m_widgets[i]->move(editWidgets[i]->x(), y);
            }
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::sendToBack()
{
    if (!m_editMode)
        return;

    QVector<QuteWidget *> selWidgets;
    QVector<FrameWidget *> selFrames;
    widgetsMutex.lock();
    for (int i = 0; i < qMin(m_widgets.size(), editWidgets.size()); ++i) {
        if (editWidgets[i]->isSelected()) {
            selWidgets.append(m_widgets[i]);
            selFrames.append(editWidgets[i]);
        }
    }
    if (selWidgets.isEmpty()) {
        widgetsMutex.unlock();
        return;
    }
    for (int i = m_widgets.size() - 1; i >= 0; --i) {
        if (editWidgets[i]->isSelected()) {
            m_widgets.removeAt(i);
            editWidgets.removeAt(i);
        }
    }
    // Put the selection at the bottom (front of the bottom->top list).
    for (int k = selWidgets.size() - 1; k >= 0; --k) {
        m_widgets.prepend(selWidgets[k]);
        editWidgets.prepend(selFrames[k]);
    }
    // Restack bottom -> top; frames are raised last so they stay above widgets.
    for (QuteWidget *w : m_widgets) w->raise();
    for (FrameWidget *f : editWidgets) f->raise();
    widgetsMutex.unlock();

    markHistory();
    setModified(true);
}

void WidgetLayout::sendToFront()
{
    if (!m_editMode)
        return;

    QVector<QuteWidget *> selWidgets;
    QVector<FrameWidget *> selFrames;
    widgetsMutex.lock();
    for (int i = 0; i < qMin(m_widgets.size(), editWidgets.size()); ++i) {
        if (editWidgets[i]->isSelected()) {
            selWidgets.append(m_widgets[i]);
            selFrames.append(editWidgets[i]);
        }
    }
    if (selWidgets.isEmpty()) {
        widgetsMutex.unlock();
        return;
    }
    for (int i = m_widgets.size() - 1; i >= 0; --i) {
        if (editWidgets[i]->isSelected()) {
            m_widgets.removeAt(i);
            editWidgets.removeAt(i);
        }
    }
    // Put the selection on top (end of the bottom->top list).
    for (QuteWidget *w : selWidgets) m_widgets.append(w);
    for (FrameWidget *f : selFrames) editWidgets.append(f);
    // Restack bottom -> top; frames are raised last so they stay above widgets.
    for (QuteWidget *w : m_widgets) w->raise();
    for (FrameWidget *f : editWidgets) f->raise();
    widgetsMutex.unlock();

    markHistory();
    setModified(true);
}


void WidgetLayout::distributeHorizontal()
{
    if (m_editMode) {
        int spacing, emptySpace, max = -9999, min = 9999, widgetWidth = 0;
        int num = 0;
        QVector<int> order;
        widgetsMutex.lock();
        for (int i = 0; i < editWidgets.size() ; i++) { // First check free space
            if (editWidgets[i]->isSelected()) {
                widgetWidth += editWidgets[i]->width();
                num++;
                if (min > editWidgets[i]->x()) { // Left most widget
                    min = editWidgets[i]->x();
                    order.prepend(i);
                }
                if (max < editWidgets[i]->x() + editWidgets[i]->width()) { // Right most widget
                    max = editWidgets[i]->x() + editWidgets[i]->width();
                    if (!order.contains(i))
                        order.append(i);
                }
                if (!order.contains(i)) {
                    int j = 0;
                    while (j < order.size()) {
                        if (editWidgets[order[j]]->x() > editWidgets[i]->x()) {
                            break;
                        }
                        j++;
                    }
                    order.insert(j++, i);
                }
            }
        }
        if (num < 3)
            return;  // do nothing for less than three selected
        emptySpace = max - min - widgetWidth;
        int accum = min;
        for (int i = 1; i < order.size() - 1 ; i++) { // Don't touch first and last
            spacing = emptySpace / (num- i);
            emptySpace -= spacing;
            accum += spacing + editWidgets[order[i-1]]->width();
            editWidgets[order[i]]->move(accum, editWidgets[order[i]]->y());
            m_widgets[order[i]]->move(accum, editWidgets[order[i]]->y());
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::distributeVertical()
{
    if (m_editMode) {
        int spacing, emptySpace, max = -9999, min = 9999, widgetHeight = 0;
        int num = 0;
        QVector<int> order;
        widgetsMutex.lock();
        for (int i = 0; i < editWidgets.size() ; i++) { // First check free space
            if (editWidgets[i]->isSelected()) {
                num++;
                widgetHeight += editWidgets[i]->height();
                if (min > editWidgets[i]->y()) { // Bottom widget
                    min = editWidgets[i]->y();
                    order.prepend(i);
                }
                if (max < editWidgets[i]->y() + editWidgets[i]->height()) { // Topmost widget
                    max = editWidgets[i]->y() + editWidgets[i]->height();
                    if (!order.contains(i))
                        order.append(i);
                }
                if (!order.contains(i)) {
                    int j = 0;
                    while (j < order.size()) {
                        if (editWidgets[order[j]]->y() > editWidgets[i]->y()) {
                            break;
                        }
                        j++;
                    }
                    order.insert(j++, i);
                }
            }
        }
        if (num < 3)
            return;  // do nothing for less than three selected
        emptySpace = max - min - widgetHeight;
        //    qDebug() << "WidgetLayout::distributeHorizontal " << emptySpace <<  "---" << order;
        int accum = min;
        for (int i = 1; i < order.size() - 1 ; i++) { // Don't touch first and last
            spacing = emptySpace / (num - i);
            emptySpace -= spacing;
            accum += spacing + editWidgets[order[i-1]]->height();
            editWidgets[order[i]]->move(editWidgets[order[i]]->x(), accum);
            m_widgets[order[i]]->move(editWidgets[order[i]]->x(), accum);
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::alignCenterHorizontal()
{
    if (m_editMode) {
        int center = 0, min = 9999;
        widgetsMutex.lock();
        for (int i = 0; i < editWidgets.size() ; i++) { // First find center
            if (editWidgets[i]->isSelected()) {
                if (min > editWidgets[i]->y()) { // Upper widget
                    min = editWidgets[i]->y();
                    center = editWidgets[i]->x() + (editWidgets[i]->width()/2);
                }
            }
        }
        for (int i = 0; i < editWidgets.size() ; i++) {
            if (editWidgets[i]->isSelected()) {
                int newx = center -  (editWidgets[i]->width()/2);
                editWidgets[i]->move(newx, editWidgets[i]->y());
                m_widgets[i]->move(newx, m_widgets[i]->y());
            }
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::alignCenterVertical()
{
    if (m_editMode) {
        int center = 0, min = 9999;
        widgetsMutex.lock();
        for (int i = 0; i < editWidgets.size() ; i++) { // First find center
            if (editWidgets[i]->isSelected()) {
                if (min > editWidgets[i]->x()) { // Leftmost widget
                    min = editWidgets[i]->x();
                    center = editWidgets[i]->y() + (editWidgets[i]->height()/2);
                }
            }
        }
        for (int i = 0; i < editWidgets.size() ; i++) {
            if (editWidgets[i]->isSelected()) {
                int newy = center -  (editWidgets[i]->height()/2);
                editWidgets[i]->move(editWidgets[i]->x(), newy);
                m_widgets[i]->move(m_widgets[i]->x(), newy);
            }
        }
        widgetsMutex.unlock();
        markHistory();
        setModified(true);
    }
}

void WidgetLayout::keyPressEvent(QKeyEvent *event)
{
    int key = event->key();
    if(m_editMode) {
        int quant = (event->modifiers() & Qt::AltModifier) ? 1 : 5;
        switch(key) {
        case Qt::Key_Escape:
            // Escape clears the selection while editing the panel.
            this->deselectAll();
            event->accept();
            return;
        case Qt::Key_Return:
        case Qt::Key_Enter: {
            // With exactly one widget selected, Enter opens its properties dialog.
            const QList<QuteWidget *> selected = getSelectedWidgets();
            if (selected.size() == 1) {
                selected.first()->openProperties();
                event->accept();
                return;
            }
            break;
        }
        case Qt::Key_Left:
            this->moveSelected(-quant, 0, quant);
            event->accept();
            return;
        case Qt::Key_Right:
            this->moveSelected(quant, 0, quant);
            event->accept();
            return;
        case Qt::Key_Up:
            this->moveSelected(0, -quant, quant);
            event->accept();
            return;
        case Qt::Key_Down:
            this->moveSelected(0, quant, quant);
            event->accept();
            return;
        case Qt::Key_S:
            this->createNewSlider();
            event->accept();
            return;
        case Qt::Key_K:
            this->createNewKnob();
            event->accept();
            return;
        case Qt::Key_B:
            this->createNewButton();
            event->accept();
            return;
        case Qt::Key_A:
            if(event->modifiers() & Qt::ControlModifier) {
                this->selectAll();
                event->accept();
                return;
            }
        }

    }

    if (!event->isAutoRepeat() || m_repeatKeys) {
        QString keyText = event->text();
        if (key == Qt::Key_D && (event->modifiers() & Qt::ControlModifier )) {
            // TODO why is this necessary? The shortcut from the duplicate
            // action in the main app is not working!
            this->duplicate();
            event->accept();
            return;
        }

        //    if (event->key() == Qt::Key_X && (event->modifiers() & Qt::ControlModifier )) {
        //      this->cut();
        //      event->accept();
        //      return;
        //    }
        //    else if (event->key() == Qt::Key_C && (event->modifiers() & Qt::ControlModifier )) {
        //      this->copy();
        //      event->accept();
        //      return;
        //    }
        //    else if (event->key() == Qt::Key_V && (event->modifiers() & Qt::ControlModifier )) {
        //      this->paste();
        //      event->accept();
        //      return;
        //    }
        if (key == Qt::Key_Delete || key == Qt::Key_Backspace) {
            this->deleteSelected();
            event->accept();
            return;
        }
        //    else if (event->matches(QKeySequence::Undo)) {
        //      this->undo();
        //      event->accept();
        //    }
        //    else if (event->matches(QKeySequence::Redo)) {
        //      this->redo();
        //      event->accept();
        //    }
        else { //else if (key != "") {
            //      qDebug() << "WidgetLayout::keyPressEvent" <convolve< key;
            //           appendMessage(key);
            QWidget::keyPressEvent(event); // Propagate event if not used
            if (!keyText.isEmpty()) {
                int key = static_cast<int>( keyText[0].toLatin1() ); // if simple character send ASCII code
                emit keyPressed(key);
            } else {
                emit keyPressed(event->key()); // else send keycode and let CsoundEngine process it
            }
            //      event->accept();
        }
    }
}

void WidgetLayout::keyReleaseEvent(QKeyEvent *event)
{
    if (!event->isAutoRepeat() || m_repeatKeys) {
        QString keyText = event->text();
        int key = -1;
        if (!keyText.isEmpty()) {
            key = (int) keyText[0].toLatin1(); // if simple character send ASCII code
        } else {
            key = event->key();
        }
        emit keyReleased(key);
    }
    QWidget::keyReleaseEvent(event); // Propagate event
}

void WidgetLayout::widgetChanged(QuteWidget* widget)
{
    if (widget != nullptr && !m_widgets.contains(widget)) {
        // The widget has been removed from the panel. Do not re-register it as
        // a controller/channel owner; just refresh the layout.
        adjustLayoutSize();
        return;
    }
    if (widget != nullptr) {
        //    widgetsMutex.lock();
        // check if this is an unknown channel
        
        int index = m_widgets.indexOf(widget);
        if (index >= 0 && editWidgets.size() > index) {
            int newx = widget->x();
            int newy = widget->y();
            int neww = widget->width();
            int newh = widget->height();
            editWidgets[index]->move(newx, newy);
            editWidgets[index]->resize(neww, newh);
        }
        setWidgetToolTip(widget, m_tooltips);
        //    widgetsMutex.unlock();
        int cc = widget->property("CSQT_midicc").toInt();  // Is it safe to query these here?
        int chan = widget->property("CSQT_midichan").toInt();
        registerWidgetController(widget, cc);
        registerWidgetChannel(widget, chan);
        setModified(true);
    }
    adjustLayoutSize();
}

void WidgetLayout::widgetPropertyApplied(QuteWidget* widget, const QString &property)
{
    // Focused counterpart of widgetChanged() for runtime "<channel>/<property>"
    // messages. Only the things the changed property can actually affect are
    // updated, and the document is deliberately NOT marked modified: these are
    // transient runtime changes (e.g. driven by outvalue), not edits to the file.
    int index = m_widgets.indexOf(widget);
    if (index < 0) {
        return;
    }
    if (property == "CSQT_x" || property == "CSQT_y"
            || property == "CSQT_width" || property == "CSQT_height") {
        if (editWidgets.size() > index) {
            editWidgets[index]->move(widget->x(), widget->y());
            editWidgets[index]->resize(widget->width(), widget->height());
        }
        adjustLayoutSize();
    }
    else if (property == "CSQT_objectName" || property == "CSQT_objectName2"
             || property == "CSQT_description") {
        setWidgetToolTip(widget, m_tooltips);
    }
    else if (property == "CSQT_midicc") {
        registerWidgetController(widget, widget->property("CSQT_midicc").toInt());
    }
    else if (property == "CSQT_midichan") {
        registerWidgetChannel(widget, widget->property("CSQT_midichan").toInt());
    }
    else if (property == "CSQT_locked") {
        // Locked widgets get a dashed frame while unselected.
        if (editWidgets.size() > index) {
            editWidgets[index]->refreshFrameAppearance();
        }
    }
}

void WidgetLayout::mousePressEvent(QMouseEvent *event)
{
    auto evbutton = event->button();
    if (m_editMode && (evbutton & Qt::LeftButton)) {
        beginSelection(event->globalPosition().toPoint());
    }
    mouseLock.lockForWrite();
    if (evbutton == Qt::LeftButton)
        mouseBut1 = 1;
    else if (evbutton == Qt::RightButton)
        mouseBut2 = 1;
    mouseLock.unlock();
    // Accept so the layout takes the mouse grab and receives the move/release
    // events that drive the rubber-band selection started here.
    event->accept();
    //  QWidget::mousePressEvent(event);
}

void WidgetLayout::beginSelection(QPoint globalPos)
{
    if (!m_editMode) {
        return;
    }
    this->setFocus(Qt::MouseFocusReason);
    selectionFrame->show();
    selectionFrame->raise();
    const QPoint pos = mapFromGlobal(globalPos);
    startx = pos.x() + xOffset;
    starty = pos.y() + yOffset;
    selectionFrame->setGeometry(startx, starty, 0, 0);
    deselectAll();
}

void WidgetLayout::continueSelection(QPoint globalPos)
{
    const QPoint pos = mapFromGlobal(globalPos);
    const int relx = pos.x();
    const int rely = pos.y();
    int x = startx;
    int y = starty;
    int width  = abs(relx - startx + xOffset);
    int height = abs(rely - starty + yOffset);
    if (relx < (startx - xOffset)) {
        x = relx + xOffset;
    }
    if (rely < (starty - yOffset)) {
        y = rely + yOffset;
    }
    selectionFrame->setGeometry(x, y, width, height);
    selectionChanged(QRect(x - xOffset, y - yOffset, width, height));
}

void WidgetLayout::endSelection()
{
    selectionFrame->hide();
    markHistory();
}

bool WidgetLayout::focusNextPrevChild(bool next)
{
    // In edit mode Tab / Shift+Tab walk the widget selection instead of moving
    // keyboard focus.
    if (m_editMode && !m_widgets.isEmpty()) {
        selectNextWidget(next);
        return true;
    }
    return QWidget::focusNextPrevChild(next);
}

void WidgetLayout::selectNextWidget(bool forward)
{
    const int count = qMin(editWidgets.size(), m_widgets.size());
    if (count == 0) {
        return;
    }
    int current = -1;
    if (forward) {
        // Next widget after the last selected one.
        for (int i = 0; i < count; ++i) {
            if (editWidgets[i]->isSelected()) {
                current = i;
            }
        }
    } else {
        // Previous widget before the first selected one.
        for (int i = count - 1; i >= 0; --i) {
            if (editWidgets[i]->isSelected()) {
                current = i;
            }
        }
    }
    int next;
    if (current < 0) {
        next = forward ? 0 : count - 1;
    } else {
        next = (current + (forward ? 1 : -1) + count) % count;
    }
    deselectAll();
    editWidgets[next]->select();
}

// Distance from a rectangle to a point; 0 when the point is inside.
static double pointToRectDistance(const QRect &r, const QPoint &p)
{
    const int dx = qMax(qMax(r.left() - p.x(), p.x() - r.right()), 0);
    const int dy = qMax(qMax(r.top() - p.y(), p.y() - r.bottom()), 0);
    return std::sqrt(double(dx) * dx + double(dy) * dy);
}

// Smallest distance from rectangle a to any of rectangle b's four vertices.
static double rectToRectVerticesDistance(const QRect &a, const QRect &b)
{
    double d = pointToRectDistance(a, b.topLeft());
    d = qMin(d, pointToRectDistance(a, b.topRight()));
    d = qMin(d, pointToRectDistance(a, b.bottomLeft()));
    d = qMin(d, pointToRectDistance(a, b.bottomRight()));
    return d;
}

void WidgetLayout::selectInDirection(int dx, int dy)
{
    const int count = qMin(editWidgets.size(), m_widgets.size());
    if (count == 0) {
        return;
    }
    QRect current;
    bool any = false;
    for (int i = 0; i < count; ++i) {
        if (editWidgets[i]->isSelected()) {
            current = any ? current.united(m_widgets[i]->geometry())
                          : m_widgets[i]->geometry();
            any = true;
        }
    }
    const bool skipContainingWidgets = any;
    if (!any) {
        // With no selection, use the cursor as the navigation origin when it
        // is over the widget panel. Otherwise start at the panel edge facing
        // the requested direction, with the perpendicular span covering the
        // visible panel (an infinite selection band into the panel).
        QRect panelRect = rect();
        QWidget *panelViewport = nullptr;
        for (QWidget *ancestor = parentWidget(); ancestor != nullptr;
             ancestor = ancestor->parentWidget()) {
            if (auto *scrollArea = qobject_cast<QScrollArea *>(ancestor)) {
                panelViewport = scrollArea->viewport();
                break;
            }
        }
        if (panelViewport) {
            const QRect viewportGlobal(panelViewport->mapToGlobal(panelViewport->rect().topLeft()),
                                      panelViewport->mapToGlobal(panelViewport->rect().bottomRight()));
            const QPoint cursorGlobal = QCursor::pos();
            if (viewportGlobal.contains(cursorGlobal)) {
                const QPoint cursor = mapFromGlobal(cursorGlobal);
                current = QRect(cursor, QSize(1, 1));
            } else {
                const QPoint topLeft = mapFromGlobal(viewportGlobal.topLeft());
                const QPoint bottomRight = mapFromGlobal(viewportGlobal.bottomRight());
                panelRect = QRect(topLeft, bottomRight).normalized();
            }
        } else {
            const QPoint cursorGlobal = QCursor::pos();
            const QRect layoutGlobal(mapToGlobal(rect().topLeft()),
                                     mapToGlobal(rect().bottomRight()));
            if (layoutGlobal.contains(cursorGlobal)) {
                current = QRect(mapFromGlobal(cursorGlobal), QSize(1, 1));
            }
        }

        if (current.isNull()) {
            if (dx > 0) {
                current = QRect(panelRect.left(), panelRect.top(), 1, panelRect.height());
            } else if (dx < 0) {
                current = QRect(panelRect.right(), panelRect.top(), 1, panelRect.height());
            } else if (dy > 0) {
                current = QRect(panelRect.left(), panelRect.top(), panelRect.width(), 1);
            } else {
                current = QRect(panelRect.left(), panelRect.bottom(), panelRect.width(), 1);
            }
        }
    }

    int bestIntersect = -1;
    long bestGap = std::numeric_limits<long>::max();
    int bestFallback = -1;
    double bestFallbackDist = std::numeric_limits<double>::max();

    for (int i = 0; i < count; ++i) {
        if (editWidgets[i]->isSelected()) {
            continue;
        }
        const QRect c = m_widgets[i]->geometry();

        // Skip a widget that contains the current one: otherwise a large widget
        // sitting on top of a label (or any container) would always be picked
        // when navigating away from it.
        if (skipContainingWidgets && c.contains(current)) {
            continue;
        }

        // First rule: the current geometry, extended endlessly in the requested
        // direction, is a rectangle; the closest widget intersecting it wins.
        bool intersects = false;
        long gap = 0;
        if (dx != 0) {
            const bool perpendicularOverlap = qMax(current.top(), c.top())
                                              <= qMin(current.bottom(), c.bottom());
            if (perpendicularOverlap) {
                if (dx > 0 && c.right() >= current.right()) {
                    intersects = true;
                    gap = qMax(0, c.left() - current.right());
                } else if (dx < 0 && c.left() <= current.left()) {
                    intersects = true;
                    gap = qMax(0, current.left() - c.right());
                }
            }
        } else if (dy != 0) {
            const bool perpendicularOverlap = qMax(current.left(), c.left())
                                              <= qMin(current.right(), c.right());
            if (perpendicularOverlap) {
                if (dy > 0 && c.bottom() >= current.bottom()) {
                    intersects = true;
                    gap = qMax(0, c.top() - current.bottom());
                } else if (dy < 0 && c.top() <= current.top()) {
                    intersects = true;
                    gap = qMax(0, current.top() - c.bottom());
                }
            }
        }
        if (intersects && (bestIntersect < 0 || gap < bestGap)) {
            bestGap = gap;
            bestIntersect = i;
        }

        // Fallback candidate: any widget lying in the requested direction.
        const QPoint cc = c.center();
        const QPoint rc = current.center();
        const bool inDirection = (dx > 0 && cc.x() > rc.x())
                              || (dx < 0 && cc.x() < rc.x())
                              || (dy > 0 && cc.y() > rc.y())
                              || (dy < 0 && cc.y() < rc.y());
        if (inDirection) {
            const double dist = rectToRectVerticesDistance(current, c);
            if (dist < bestFallbackDist) {
                bestFallbackDist = dist;
                bestFallback = i;
            }
        }
    }

    const int best = (bestIntersect >= 0) ? bestIntersect : bestFallback;
    if (best >= 0) {
        deselectAll();
        editWidgets[best]->select();
    }
}

void WidgetLayout::selectThroughWidgets(QPoint globalPos)
{
    if (!m_editMode) {
        return;
    }
    const QPoint pos = mapFromGlobal(globalPos);
    // Widgets under the point, front-most first (later widgets are on top).
    QVector<int> stack;
    const int count = qMin(editWidgets.size(), m_widgets.size());
    for (int i = count - 1; i >= 0; --i) {
        const QRect r(m_widgets[i]->x(), m_widgets[i]->y(),
                      m_widgets[i]->width(), m_widgets[i]->height());
        if (r.contains(pos)) {
            stack.append(i);
        }
    }
    if (stack.isEmpty()) {
        return;
    }
    int current = -1;
    for (int k = 0; k < stack.size(); ++k) {
        if (editWidgets[stack[k]]->isSelected()) {
            current = k;
            break;
        }
    }
    // First Alt+click goes one level below the front-most widget; further clicks
    // go deeper, wrapping around at the bottom.
    int next;
    if (current < 0) {
        next = (stack.size() > 1) ? 1 : 0;
    } else {
        next = (current + 1) % stack.size();
    }
    deselectAll();
    editWidgets[stack[next]]->select();
}

void WidgetLayout::mouseMoveEvent(QMouseEvent *event)
{
    //  QWidget::mouseMoveEvent(event);
    auto relpos = event->position();
    auto relx = relpos.x();
    auto rely = relpos.y();

    if (event->buttons() & Qt::LeftButton) {
        continueSelection(event->globalPosition().toPoint());
    }
    mouseLock.lockForWrite();
    auto globalpos = event->globalPosition();
    mouseX = globalpos.x();
    mouseY = globalpos.y();
    mouseRelX = relx + xOffset;
    mouseRelY = rely + yOffset;
    mouseLock.unlock();
}

void WidgetLayout::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() & Qt::LeftButton) {
        endSelection(); // Hides the frame and records history.
    }
    mouseLock.lockForWrite();
    if (event->button() == Qt::LeftButton)
        mouseBut1 = 0;
    else if (event->button() == Qt::RightButton) {
        emit deselectAll();
        mouseBut2 = 0;
    }
    mouseLock.unlock();
    if (!(event->button() & Qt::LeftButton)) {
        markHistory();
    }
    //  QWidget::mouseReleaseEvent(event);
}

void WidgetLayout::contextMenuEvent(QContextMenuEvent *event)
{
    if (m_enableEdit) {
        createContextMenu(event);
        event->accept();
    }
}

void WidgetLayout::closeEvent(QCloseEvent *event) {
    Q_UNUSED(event);
    emit this->windowStatus(false);
}

int WidgetLayout::parseXmlNode(QDomNode node)
{
    int ret = 0;
    QString name = node.nodeName();
    if (name == "objectName") {
        m_objectName = node.firstChild().nodeValue();
        //    this->setProperty("CSQT_objectName", node.firstChild().nodeValue());
    }
    else if (name == "label") {
        auto child = node.firstChild();
        if(!child.isNull()) {
            this->setWindowTitle(child.nodeValue());
        }
    }
    else if (name == "x") {
        int newx = node.firstChild().nodeValue().toInt();
        m_posx = newx >= 0 && newx < 4096? newx : m_posx;
    }
    else if (name == "y") {
        int newy = node.firstChild().nodeValue().toInt();
        m_posy = newy >= 0 && newy < 4096? newy : m_posy;
    }
    else if (name == "width") {
        int neww = node.firstChild().nodeValue().toInt();
        m_w = neww >= 0 && neww < 4096? neww : m_w;
    }
    else if (name == "height") {
        int newh = node.firstChild().nodeValue().toInt();
        m_h = newh >= 0 && newh < 4096? newh : m_h;
    }
    else if (name == "visible") {
        m_visible = node.firstChild().nodeValue() == "true";
    }
    else if (name == "uuid") {
        m_uuid = node.firstChild().nodeValue();
    }
    else if (name == "bgcolor") {
        bool bg = false;
        auto nodeElement = node.toElement();

        if (nodeElement.attribute("mode")== "background") {
            //qDebug() << "background true";
            bg = true;
        }
        QDomElement er = nodeElement.firstChildElement("r");
        QDomElement eg = nodeElement.firstChildElement("g");
        QDomElement eb = nodeElement.firstChildElement("b");
        auto bgcolor = QColor(er.firstChild().nodeValue().toInt(),
                              eg.firstChild().nodeValue().toInt(),
                              eb.firstChild().nodeValue().toInt());
        // auto parent = node.parentNode().nodeName();
        //qDebug() << "setting background" << parent << bgcolor << node.toElement().text();
        setBackground(bg, bgcolor);
    }
    else if (name == "bsbObject") {
        ret = newXmlWidget(node);
    }
    else if (name == "bsbGroup") {
        qDebug() << "bsbGroup not implemented";
    }
    else {
        qDebug() << "WidgetLayout::parseXmlNode unknown node name: "<< name;
        return -1;
    }
    return ret;
}

QString WidgetLayout::createSlider(int x, int y, int width, int height,
                                   const QString &channel,
                                   double minimum, double maximum, double value)
{
    QuteSlider *widget = new QuteSlider(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_minimum", minimum);
    widget->setProperty("CSQT_maximum", maximum);
    widget->setProperty("CSQT_value", value);
    widget->setProperty("CSQT_objectName", channel);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createText(int x, int y, int width, int height,
                                 const QString &textType,
                                 const QString &channel,
                                 const QString &alignment,
                                 const QString &font,
                                 int fontSize,
                                 const QColor &fgColor,
                                 const QColor &bgColor,
                                 bool bgMode,
                                 const QString &borderMode,
                                 const QString &labelText)
{
    QuteText *widget = new QuteText(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setType(textType);
    widget->setProperty("CSQT_objectName", channel);
    widget->setProperty("CSQT_alignment", alignment);
    widget->setProperty("CSQT_font", font);
    widget->setProperty("CSQT_fontsize", fontSize);
    widget->setProperty("CSQT_color", fgColor);
    widget->setProperty("CSQT_bgcolor", bgColor);
    widget->setProperty("CSQT_bgcolormode", bgMode);
    widget->setProperty("CSQT_bordermode", borderMode);
    widget->setProperty("CSQT_precision", 3);
    if (textType == "label") {
        widget->setTransparentForMouse(true);
    }
    widget->setProperty("CSQT_label", labelText);
    widget->setFontOffset(m_fontOffset);
    widget->setFontScaling(m_fontScaling);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createScrollNumber(int x, int y, int width, int height,
                                                 const QString &channel,
                                                 const QString &alignment,
                                                 const QString &font,
                                                 int fontSize,
                                                 const QColor &fgColor,
                                                 const QColor &bgColor,
                                                 bool bgMode,
                                                 const QString &borderMode,
                                                 double resolution,
                                                 double value)
{
    QuteScrollNumber *widget = new QuteScrollNumber(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setType("scroll");
    widget->setProperty("CSQT_resolution", resolution);
    widget->setProperty("CSQT_objectName", channel);
    widget->setProperty("CSQT_alignment", alignment);
    widget->setProperty("CSQT_font", font);
    widget->setProperty("CSQT_fontsize", fontSize);
    widget->setProperty("CSQT_color", fgColor);
    widget->setProperty("CSQT_bgcolor", bgColor);
    widget->setProperty("CSQT_bgcolormode", bgMode);
    widget->setProperty("CSQT_bordermode", borderMode);
    widget->setProperty("CSQT_value", value);
    widget->setFontOffset(m_fontOffset);
    widget->setFontScaling(m_fontScaling);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createLineEdit(int x, int y, int width, int height,
                                             const QString &channel,
                                             const QString &alignment,
                                             const QString &font,
                                             int fontSize,
                                             const QColor &fgColor,
                                             const QColor &bgColor,
                                             bool bgMode,
                                             const QString &borderMode,
                                             const QString &labelText)
{
    QuteLineEdit *widget = new QuteLineEdit(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setType("edit");
    widget->setProperty("CSQT_objectName", channel);
    widget->setProperty("CSQT_alignment", alignment);
    widget->setProperty("CSQT_font", font);
    widget->setProperty("CSQT_fontsize", fontSize);
    widget->setProperty("CSQT_color", fgColor);
    widget->setProperty("CSQT_bgcolor", bgColor);
    widget->setProperty("CSQT_bgcolormode", bgMode);
    widget->setProperty("CSQT_bordermode", borderMode);
    widget->setProperty("CSQT_label", labelText);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createSpinBox(int x, int y, int width, int height,
                                           const QString &channel,
                                           const QString &alignment,
                                           const QString &font,
                                           int fontSize,
                                           const QColor &fgColor,
                                           const QColor &bgColor,
                                           bool bgMode,
                                           const QString &borderMode,
                                           double resolution,
                                           double value)
{
    QuteSpinBox *widget = new QuteSpinBox(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setType("editnum");
    widget->setProperty("CSQT_resolution", resolution);
    widget->setProperty("CSQT_objectName", channel);
    widget->setProperty("CSQT_alignment", alignment);
    widget->setProperty("CSQT_font", font);
    widget->setProperty("CSQT_fontsize", fontSize);
    widget->setProperty("CSQT_color", fgColor);
    widget->setProperty("CSQT_bgcolor", bgColor);
    widget->setProperty("CSQT_bgcolormode", bgMode);
    widget->setProperty("CSQT_bordermode", borderMode);
    widget->setProperty("CSQT_value", value);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createButton(int x, int y, int width, int height,
                                   const QString &channel,
                                   const QString &buttonType,
                                   double pressedValue,
                                   const QString &text,
                                   const QString &image,
                                   const QString &eventLine)
{
    qDebug("WidgetPanel::createButton");
    QuteButton *widget = new QuteButton(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_objectName", channel);
    widget->setProperty("CSQT_type", buttonType);
    widget->setProperty("CSQT_pressedValue", pressedValue);
    widget->setText(text);
    widget->setProperty("CSQT_image", image);
    widget->setProperty("CSQT_eventLine", eventLine);
    connect(widget, SIGNAL(queueEventSignal(QString)), this, SLOT(queueEvent(QString)));
    emit registerButton(widget);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createKnob(int x, int y, int width, int height,
                                 const QString &channel,
                                 double minimum, double maximum,
                                 double resolution, double value)
{
    QuteKnob *widget = new QuteKnob(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_minimum", minimum);
    widget->setProperty("CSQT_maximum", maximum);
    widget->setProperty("CSQT_resolution", resolution);
    widget->setProperty("CSQT_value", value);
    widget->setProperty("CSQT_objectName", channel);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createCheckBox(int x, int y, int width, int height,
                                         const QString &channel, bool checked)
{
    QuteCheckBox *widget = new QuteCheckBox(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setValue(checked);
    widget->setProperty("CSQT_objectName", channel);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createMenu(int x, int y, int width, int height,
                                 const QString &channel,
                                 const QString &items, int selectedIndex)
{
    QuteComboBox *widget = new QuteComboBox(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_objectName", channel);
    widget->setProperty("CSQT_selectedIndex", selectedIndex);
    widget->setText(items);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createMeter(int x, int y, int width, int height,
                                  const QString &channel,
                                  const QString &channel2,
                                  const QColor &color,
                                  const QString &meterType,
                                  double xValue, double yValue,
                                  int pointSize, int fadeSpeed)
{
    QuteMeter *widget = new QuteMeter(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_color", color);
    widget->setProperty("CSQT_type", meterType);
    widget->setProperty("CSQT_objectName2", channel2);
    widget->setProperty("CSQT_yValue", yValue);
    widget->setProperty("CSQT_xValue", xValue);
    widget->setProperty("CSQT_objectName", channel);
    widget->setProperty("CSQT_pointsize", pointSize);
    widget->setProperty("CSQT_fadeSpeed", fadeSpeed);
    widget->setProperty("CSQT_xMin", 0.0);
    widget->setProperty("CSQT_xMax", 1.0);
    widget->setProperty("CSQT_yMin", 0.0);
    widget->setProperty("CSQT_yMax", 1.0);
    widget->applyInternalProperties();
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createConsole(int x, int y, int width, int height)
{
    QuteConsole *widget = new QuteConsole(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->applyInternalProperties();
    consoleWidgets.append(widget);
    registerWidget(widget);
    return widget->getUuid();
}

QString WidgetLayout::createGraph(int x, int y, int width, int height)
{
    QuteGraph *widget = new QuteGraph(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_zoomx", 1.0);
    for (int i = 0; i < curves.size(); i++) {
        widget->addCurve(curves[i]);
    }
    graphWidgets.append(widget);
    emit requestCsoundUserData(widget);
    emit registerGraph(widget);
    registerWidget(widget);
    widget->applyInternalProperties();
    return widget->getUuid();
}

QString WidgetLayout::createScope(int x, int y, int width, int height,
                                  const QString &scopeType, double zoom, int channels)
{
    QuteScope *widget = new QuteScope(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_type", scopeType);
    widget->setProperty("CSQT_zoomx", zoom);
    widget->setProperty("CSQT_value", channels);
    emit registerScope(widget);
    scopeWidgets.append(widget);
    registerWidget(widget);
    widget->applyInternalProperties();
    return widget->getUuid();
}

QString WidgetLayout::createTableDisplay(int x, int y, int width, int height)
{
    QuteTable *widget = new QuteTable(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    widget->setProperty("CSQT_tableNumber", 0);

    emit requestCsoundUserData(widget);
    registerWidget(widget);
    widget->applyInternalProperties();
    return widget->getUuid();
}

QString WidgetLayout::createWaveform(int x, int y, int width, int height)
{
    auto *widget = new QuteWaveform(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    const QString base = "wave" + QString::number(m_widgets.size());
    widget->setProperty("CSQT_objectName", base + "Table");
    widget->setProperty("CSQT_objectName2", base + "Cursor");
    emit requestCsoundUserData(widget);
    registerWidget(widget);
    waveformWidgets.append(widget);
    widget->applyInternalProperties();
    return widget->getUuid();
}

QString WidgetLayout::createVUMeter(int x, int y, int width, int height)
{
    auto *widget = new QuteVUMeter(this);
    widget->setProperty("CSQT_x", x);
    widget->setProperty("CSQT_y", y);
    widget->setProperty("CSQT_width", width);
    widget->setProperty("CSQT_height", height);
    registerWidget(widget);
    widget->applyInternalProperties();
    return widget->getUuid();
}

void WidgetLayout::setBackground(bool bg, QColor bgColor)
{
    QWidget *w;
    layoutMutex.lock();
    w = m_contained ?  this->parentWidget() : this;  // If contained, set background of parent widget

    if (bg) // to get rid of pink backgrounds
        w->setPalette(QPalette(bgColor));
    else
        w->setPalette(QPalette());
    w->setBackgroundRole(QPalette::Window);
    w->setAutoFillBackground(bg);
    layoutMutex.unlock();
    this->setProperty("CSQT_bg", QVariant(bg));
    this->setProperty("CSQT_bgcolor", QVariant(bgColor));
}

FrameWidget *WidgetLayout::getEditWidget(QuteWidget *widget)
{
    // This function is only called from setWidgetTooltip, so it should not be locked,
    // because it already is
    FrameWidget *out = 0;
    for (int i  = 0 ; i < m_widgets.size(); i++) {
        if (m_widgets[i] == widget) {
            if (editWidgets.size() > i) {
                return editWidgets[i];
            }
        }
    }
    return out;
}

void WidgetLayout::registerWidgetController(QuteWidget *widget, int cc)
{
    for (int i = 0; i < registeredControllers.size(); i++) {
        if (registeredControllers[i].widget == widget) {
            registeredControllers[i].cc = cc;
            return;
        }
    }
    // right order of parameters: RegisteredController(QuteWidget * _widget, int _chan, int _cc)
    registeredControllers << RegisteredController(widget, 0, cc);
}

void WidgetLayout::registerWidgetChannel(QuteWidget *widget, int chan)
{
    if (chan < 0) { // No control
        return;
    }
    for (int i = 0; i < registeredControllers.size(); i++) {
        if (registeredControllers[i].widget == widget) {
            registeredControllers[i].chan = chan;
            return;
        }
    }
    // RegisteredController(QuteWidget * _widget, int _chan,int  _cc)
    registeredControllers << RegisteredController(widget, chan, 1);
}

void WidgetLayout::unregisterWidgetController(QuteWidget *widget)
{
    for (int i = 0; i < registeredControllers.size(); i++) {
        if (registeredControllers[i].widget == widget) {
            registeredControllers.removeAt(i);
            return;
        }
    }
}

void WidgetLayout::clearWidgetControllers()
{
    registeredControllers.clear();
}

void WidgetLayout::setModified(bool mod)
{
    m_modified = mod;
    if (mod) {
        emit changed();
    }
}

void WidgetLayout::setMouseOffset(int x, int y)
{
    xOffset = -x;
    yOffset = -y;
}

void WidgetLayout::clearHistory()
{
    m_history.clear();
    m_history.append(HistoryEntry());
    m_historyIndex = 0;
}

int WidgetLayout::getPresetIndex(int number)
{
    for (int i = 0; i < presets.size(); i++) {
        if (presets[i].getNumber() == number) {
            return i;
        }
    }
    return -1;
}

void WidgetLayout::loadPreset()
{
    QDialog d(this);
    QVBoxLayout *l = new QVBoxLayout(&d);
    QPushButton *okButton = new QPushButton(tr("Close"),&d);
    QPushButton *newButton = new QPushButton(tr("New Preset"),&d);

    QTreeWidget *treeWidget = new QTreeWidget(&d);

    treeWidget->setHeaderLabel(tr("Double-click Preset to Load"));
    l->addWidget(treeWidget);
    l->addWidget(okButton);
    l->addWidget(newButton);

    connect(okButton, SIGNAL(released()), &d, SLOT(accept()));
    connect(newButton, SIGNAL(released()), this, SLOT(newPreset()));
    connect(newButton, SIGNAL(released()), &d, SLOT(reject()));  // For now just close the load preset window (instead of refreshing...

    treeWidget->setColumnCount(1);
    QList<QTreeWidgetItem *> items;
    for (int i = 0; i < presets.size(); i++) {
        QString itemText = QString::number(presets[i].getNumber()) + "  " + presets[i].getName();
        QTreeWidgetItem *item = new QTreeWidgetItem((QTreeWidget*)0, QStringList(itemText));
        item->setData(0,Qt::UserRole,presets[i].getNumber());
        items.append(item);
    }
    QList<QTreeWidgetItem *> sortedItems;
    for (int i = 0; i < items.size(); i++) {
        int j = 0;
        for (j = 0; j < sortedItems.size(); j++) {
            if (items[i]->data(0,Qt::UserRole).toInt() < sortedItems[j]->data(0,Qt::UserRole).toInt()) {
                break;
            }
        }
        sortedItems.insert(j, items[i]);
    }
    treeWidget->insertTopLevelItems(0, sortedItems);
    connect(treeWidget,SIGNAL(itemDoubleClicked (QTreeWidgetItem * , int)),
            this, SLOT(loadPresetFromItem(QTreeWidgetItem * , int)) );

    d.setModal(false);
    d.exec();
}

void WidgetLayout::loadPresetFromAction()
{
    QAction *s = static_cast<QAction *>(sender());
    loadPreset(s->data().toInt());
}

void WidgetLayout::loadPresetFromItem(QTreeWidgetItem * item, int column)
{
    loadPreset(item->data(column,Qt::UserRole).toInt());
}

void WidgetLayout::loadPreset(int num)
{
    int index = getPresetIndex(num);
    loadPresetFromIndex(index);
}

void WidgetLayout::loadPresetFromIndex(int index)
{
    if (index < 0 || index >= presets.size()) {
        qDebug() << "WidgetLayout::loadPreset num invalid.";
        return;
    }
    m_currentPreset = index;
    WidgetPreset p = presets[index];
    QStringList ids = p.getWidgetIds();
    widgetsMutex.lock();
    for (int i = 0; i < ids.size(); i++) {
        QString savedId = ids[i];
        for (int j = 0; j < m_widgets.size(); j++) {
            QString id = m_widgets[j]->getUuid();
            if (savedId != id)
                continue;
            int mode = p.getMode(i);
            if (mode & 1) {
                m_widgets[j]->setValue(p.getValue(i));
                QString channel = m_widgets[j]->getChannelName();
                // Store the value in the changes buffer to read from chnget
                if (!channel.isEmpty()) {
                    valueMutex.lock();
                    if(newValues.contains(channel))
                        newValues[channel] = p.getValue(i);
                    else
                        newValues.insert(channel, p.getValue(i));
                    valueMutex.unlock();
                }
            }
            if (mode & 2) {
                m_widgets[j]->setValue2(p.getValue2(i));
                QString channel = m_widgets[j]->getChannelName();
                // store the value in the changes buffer to read from chnget
                if (!channel.isEmpty()) {
                    valueMutex.lock();
                    if(newValues.contains(channel))
                        newValues[channel] = p.getValue2(i);
                    else
                        newValues.insert(channel, p.getValue2(i));
                    valueMutex.unlock();
                }
            }
            if (mode & 4) {
                m_widgets[j]->setValue(p.getStringValue(i));
                QString channel = m_widgets[j]->getChannelName();
                // Store the value in the changes buffer to read from chnget
                if (!channel.isEmpty()) {
                    stringValueMutex.lock();
                    if(newStringValues.contains(channel))
                        newStringValues[channel] = p.getStringValue(i);
                    else
                        newStringValues.insert(channel, p.getStringValue(i));
                    stringValueMutex.unlock();
                }
            }
        }
    }
    widgetsMutex.unlock();
    QPair<QString, QString> channelValue;
    channelValue.first = "_GetPresetName";
    channelValue.second = p.getName();
    newValue(channelValue);
    QPair<QString, double> channelValue2;
    channelValue2.first = "_GetPresetNumber";
    channelValue2.second = p.getNumber();
    newValue(channelValue2);
}

void WidgetLayout::newPreset()
{
    QDialog d(this);
    QGridLayout *l = new QGridLayout(&d);
    QLabel *nameLabel = new QLabel(tr("New Preset Name:"), &d);
    QLineEdit *nameLineEdit = new QLineEdit(&d);
    QLabel *numberLabel = new QLabel(tr("Number:"), &d);
    QSpinBox *numberSpinBox = new QSpinBox(&d);
    numberSpinBox->unsetLocale();
    QPushButton *okButton = new QPushButton(tr("Ok"),&d);
    QPushButton *cancelButton = new QPushButton(tr("Cancel"),&d);
    l->addWidget(nameLabel, 0,0, Qt::AlignRight);
    l->addWidget(nameLineEdit, 0,1, Qt::AlignLeft);
    l->addWidget(numberLabel, 1,0, Qt::AlignRight);
    l->addWidget(numberSpinBox, 1,1, Qt::AlignLeft);
    l->addWidget(cancelButton, 2,0, Qt::AlignCenter);
    l->addWidget(okButton, 2,1, Qt::AlignCenter);
    connect(okButton, SIGNAL(released()), &d, SLOT(accept()));
    connect(cancelButton, SIGNAL(released()), &d, SLOT(reject()));

    int ret = d.exec();
    if (ret == QDialog::Accepted) {
        if (presetExists(numberSpinBox->value())) {
            int ret = QMessageBox::question(this, tr("Preset Already Exists"),
                                            tr("Preset %i already exists. Overwrite?").arg(numberSpinBox->value()),
                                            QMessageBox::Yes|QMessageBox::No, QMessageBox::No);
            if (ret == QMessageBox::Yes) {
                savePreset(numberSpinBox->value(), nameLineEdit->text() );
            }
        }
        else {
            savePreset(numberSpinBox->value(), nameLineEdit->text() );
        }
    }
}


void WidgetLayout::savePreset()
{
    QDialog d(this);
    QVBoxLayout *l = new QVBoxLayout(&d);
    QLabel *lab= new QLabel(&d);
    QComboBox *box = new QComboBox(&d);
    QPushButton *okButton = new QPushButton(tr("Ok"),&d);
    QPushButton *cancelButton = new QPushButton(tr("Cancel"),&d);
    QPushButton *newButton = new QPushButton(tr("New Preset"),&d);

    lab->setText(tr("Select Preset to save"));
    l->addWidget(lab);
    l->addWidget(box);
    l->addWidget(cancelButton);
    l->addWidget(newButton);
    l->addWidget(okButton);
    connect(okButton, SIGNAL(released()), &d, SLOT(accept()));
    connect(cancelButton, SIGNAL(released()), &d, SLOT(reject()));
    connect(newButton, SIGNAL(released()), this, SLOT(newPreset()));
    connect(newButton, SIGNAL(released()), &d, SLOT(reject()));  // For now just close the load preset window (instead of refreshing...
    for (int i = 0; i < presets.size(); i++) {
        QString itemText = QString::number(presets[i].getNumber()) + "  " + presets[i].getName();
        box->addItem(itemText, presets[i].getNumber() );
    }
    box->setCurrentIndex(m_currentPreset);

    int ret = d.exec();
    if (ret == QDialog::Accepted) {
        if (box->currentIndex() < 0) {
            newPreset();
        }
        else {
            savePreset(presets[box->currentIndex()].getNumber(), presets[box->currentIndex()].getName());
        }
    }
}

void WidgetLayout::savePreset(int num, QString name)
{
    int index = getPresetIndex(num);
    WidgetPreset p;
    p.setName(name);
    p.setNumber(num);
    if (index == -1) {
        qDebug() << "WidgetLayout::savePreset new preset";
        presets.append(p);
        index = presets.size() - 1;
    }
    widgetsMutex.lock();
    for (int i = 0; i < m_widgets.size(); i++) {
        auto w = m_widgets[i];
        QString id = w->getUuid();
        auto mtype = w->getWidgetTypeID();
        if (mtype != QuteWidgetType::LABEL
                && mtype != QuteWidgetType::LINEEDIT
                && mtype != QuteWidgetType::BUTTON
                && mtype != QuteWidgetType::CONSOLE) {
            p.addValue(id, w->getValue());
        }
        if (mtype == QuteWidgetType::BUTTON) {
            if (static_cast<QuteButton *>(m_widgets[i])->property("CSQT_latch").toBool()) {
                p.addValue(id, m_widgets[i]->getValue());
            }
        }
        if (mtype == QuteWidgetType::CONTROLLER) {
            p.addValue2(id, m_widgets[i]->getValue2());
        }
        if (mtype == QuteWidgetType::BUTTON
                || mtype == QuteWidgetType::LINEEDIT
                || mtype == QuteWidgetType::DISPLAY) {
            p.addStringValue(id, m_widgets[i]->getStringValue());
        }
        // Note that BSBLabel is left out from presets
    }
    widgetsMutex.unlock();
    presets[index] = p;
    m_currentPreset = index;
}

void WidgetLayout::setPresetName(int num, QString name)
{
    if (num >= 0 && num < presets.size()) {
        int index = getPresetIndex(num);
        if (index >= 0) {
            presets[getPresetIndex(num)].setName(name);
        }
        else {
            qDebug() << "WidgetLayout::setPresetName invalid number.";
        }
    }
}

QList<int> WidgetLayout::getPresetNums()
{
    QList<int> list;
    for (int i = 0; i < presets.size(); i++) {
        list.append(presets[i].getNumber());
    }
    return list;
}

QString WidgetLayout::getPresetName(int num)
{
    int index = getPresetIndex(num);
    if (index >= 0) {
        return presets[getPresetIndex(num)].getName();
    }
    else {
        return QString();
        qDebug() << "WidgetLayout::getPresetName invalid number.";
    }
}

bool WidgetLayout::presetExists(int num)
{
    return getPresetNums().contains(num);
}

QColor WidgetLayout::getColorFromElement(QDomElement elem)
{
    QDomElement er = elem.firstChildElement("r");
    QDomElement eg = elem.firstChildElement("g");
    QDomElement eb = elem.firstChildElement("b");
    return QColor(er.firstChild().nodeValue().toInt(),
                  eg.firstChild().nodeValue().toInt(),
                  eb.firstChild().nodeValue().toInt());
}

void WidgetLayout::copy()
{
    qDebug() << "WidgetLayout::copy()";
    QString text;
    if (m_editMode) {
        widgetsMutex.lock();
        for (int i = 0; i < editWidgets.size() ; i++) {
            if (editWidgets[i]->isSelected()) {
                text += m_widgets[i]->getWidgetXmlText()+ "\n";
            }
        }
        widgetsMutex.unlock();
        QClipboard *clipboard = qApp->clipboard();
        clipboard->setText(text);
    }
}

void WidgetLayout::cut()
{
    qDebug() << "WidgetLayout::cut()";
    if (m_editMode) {
        WidgetLayout::copy();
        widgetsMutex.lock();
        for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
            if (editWidgets[i]->isSelected()) {
                widgetsMutex.unlock();
                deleteWidget(m_widgets[i]);
                widgetsMutex.lock();
            }
        }
        widgetsMutex.unlock();
        markHistory();
    }
}

void WidgetLayout::paste()
{
    qDebug() << "WidgetLayout::paste()";
    if (m_editMode) {
        deselectAll();
        QClipboard *clipboard = qApp->clipboard();
        QString clipboardText = clipboard->text();
        QDomDocument doc;
        QString errorText;
        int lineNumber, column;
        if (!doc.setContent("<doc>" + clipboardText + "</doc>",
                            &errorText, &lineNumber, &column)) {
            qDebug() <<"WidgetLayout::paste Parsing Error: " << errorText <<  lineNumber
                   << column << clipboardText;
        }
        QDomElement docElement = doc.firstChildElement("doc");
        QDomElement pl = docElement.firstChildElement("bsbObject");
        while (!pl.isNull()) {
            newXmlWidget(pl);
            editWidgets.last()->select();
            pl = pl.nextSiblingElement("bsbObject");
        }
    }
    markHistory();
}

void WidgetLayout::setEditEnabled(bool enabled)
{
    setEditMode(enabled);
    m_enableEdit = enabled;
}

void WidgetLayout::setEditMode(bool active)
{
    if (!m_enableEdit) {
        return;
    }
    if (active) {
        widgetsMutex.lock();
        foreach (FrameWidget *frame, editWidgets) {
            retireFrameLocked(frame);
        }
        editWidgets.clear();
        foreach (QuteWidget * widget, m_widgets) {
            createEditFrame(widget);
            setWidgetToolTip(widget,m_tooltips);
        }
        widgetsMutex.unlock();
    }
    else {
        widgetsMutex.lock();
        foreach (FrameWidget *frame, editWidgets) {
            retireFrameLocked(frame);
        }
        editWidgets.clear();
        widgetsMutex.unlock();
    }
    m_editMode = active;
    // These shortcuts are only meaningful while editing; disabling them outside
    // edit mode keeps Page Up/Down free for scrolling the panel.
    sendToFrontAct->setEnabled(active);
    sendToBackAct->setEnabled(active);
    selectLeftAct->setEnabled(active);
    selectRightAct->setEnabled(active);
    selectUpAct->setEnabled(active);
    selectDownAct->setEnabled(active);
}

void WidgetLayout::setFrameColors(const QColor &unselected, const QColor &selected)
{
    FrameWidget::setFrameColors(unselected, selected);
    for (FrameWidget *frame : editWidgets) {
        frame->refreshFrameAppearance();
    }
}

void WidgetLayout::createEditFrame(QuteWidget* widget)
{
    // This function should be locked from outside always
    FrameWidget * frame = new FrameWidget(this);
    QPalette palette = QPalette(QColor(Qt::red),QColor(Qt::red));
    palette.setColor(QPalette::WindowText, QColor(Qt::red));
    frame->setWidget(widget);
    // The constructor runs before the widget is bound, so apply the frame style
    // now that the locked flag is known (dotted frame for locked widgets).
    frame->refreshFrameAppearance();
    frame->setPalette(palette);
    frame->setFocusProxy(this);
    frame->setGeometry(widget->x(), widget->y(), widget->width(), widget->height());
    frame->setFrameShape(QFrame::Box);
    //       frame->setMouseTracking(false);  //Only track mouse when buttons are pressed
    frame->show();
    editWidgets.append(frame);
    connect(frame, SIGNAL(popUpMenu(QPoint)), widget, SLOT(popUpMenu(QPoint)));
    connect(frame, SIGNAL(deselectAllSignal()), this, SLOT(deselectAll()));
    connect(frame, SIGNAL(moved( QPair<int, int> )),
            this, SLOT(widgetMoved( QPair<int, int> )));
    connect(frame, SIGNAL(resized( QPair<int, int> )),
            this, SLOT(widgetResized( QPair<int, int> )));
    connect(frame, SIGNAL(resizedTopLeft( QPair<int, int> )),
            this, SLOT(widgetResizedTopLeft( QPair<int, int> )));
    connect(frame, SIGNAL(mouseReleased()), this, SLOT(markHistoryGeometry()));
    connect(frame, SIGNAL(selectionStarted(QPoint)), this, SLOT(beginSelection(QPoint)));
    connect(frame, SIGNAL(selectionMoved(QPoint)), this, SLOT(continueSelection(QPoint)));
    connect(frame, SIGNAL(selectionFinished()), this, SLOT(endSelection()));
    connect(frame, SIGNAL(selectThrough(QPoint)), this, SLOT(selectThroughWidgets(QPoint)));
    connect(frame, SIGNAL(editWidget()), widget, SLOT(openProperties()));
    connect(frame, SIGNAL(widgetSelected(QuteWidget*)),
            this, SLOT(widgetSelected(QuteWidget*)));
    connect(frame, SIGNAL(widgetUnselected(QuteWidget*)),
            this, SLOT(widgetUnselected(QuteWidget*)));

}

void WidgetLayout::markHistory()
{
    markHistoryInternal(false);
}

void WidgetLayout::markHistoryGeometry()
{
    markHistoryInternal(true);
}

void WidgetLayout::markHistoryInternal(bool geometryOnly)
{
    const QString text = getWidgetsText();
    const QHash<QString, QRect> geometry = currentWidgetGeometry();
    if (m_history.isEmpty()) {
        m_history.append(HistoryEntry());
        m_historyIndex = 0;
    }
    const QString currentXml = m_history[m_historyIndex].xml;
    if (currentXml == text) {
        return;  // nothing changed
    }
    if (!currentXml.isEmpty()) {
        m_historyIndex++;
    }
    if (m_historyIndex >= CSQT_MAX_UNDO) {
        m_history.pop_front();
        m_historyIndex--;
    }
    if (m_history.size() != m_historyIndex + 1) {
        m_history.resize(m_historyIndex + 1);
    }
    HistoryEntry entry;
    entry.xml = text;
    entry.geometryOnly = geometryOnly;
    entry.geometry = geometry;
    m_history[m_historyIndex] = entry;
}

QHash<QString, QRect> WidgetLayout::currentWidgetGeometry()
{
    QHash<QString, QRect> geometry;
    widgetsMutex.lock();
    geometry.reserve(m_widgets.size());
    for (QuteWidget *widget : m_widgets) {
        geometry.insert(widget->getUuid(), QRect(widget->x(), widget->y(),
                                                 widget->width(), widget->height()));
    }
    widgetsMutex.unlock();
    return geometry;
}

void WidgetLayout::applyHistoryGeometry(const QHash<QString, QRect> &geometry)
{
    // Restore geometry in place (no widget is destroyed or created). Used to
    // undo/redo move and resize actions without reloading the whole panel.
    widgetsMutex.lock();
    for (int i = 0; i < m_widgets.size(); i++) {
        QuteWidget *widget = m_widgets[i];
        auto it = geometry.constFind(widget->getUuid());
        if (it == geometry.constEnd()) {
            continue;
        }
        const QRect r = it.value();
        if (r.width() <= 0 || r.height() <= 0) {
            continue;
        }
        widget->setProperty("CSQT_x", r.x());
        widget->setProperty("CSQT_y", r.y());
        widget->setProperty("CSQT_width", r.width());
        widget->setProperty("CSQT_height", r.height());
        widget->setWidgetGeometry(r.x(), r.y(), r.width(), r.height());
        if (i < editWidgets.size()) {
            editWidgets[i]->setGeometry(r);
        }
    }
    widgetsMutex.unlock();
    adjustLayoutSize();
    widgetChanged();
    setModified(true);
}

void WidgetLayout::deleteWidget(QuteWidget *widget)
{
    widgetsMutex.lock();
    int index = m_widgets.indexOf(widget);
    if (index < 0) {
        // Already removed (e.g. during a reload); nothing to do.
        widgetsMutex.unlock();
        return;
    }
    m_activeWidgets = index;  // Allow all widgets before this one to be active
    m_widgets.remove(index);
    // Remove only this widget from the channel cache. Clearing the whole cache
    // would make every other channel briefly fall back to discovery, which has
    // side effects on widgets that are not being removed.
    for (auto it = channelNameToWidgets.begin(); it != channelNameToWidgets.end(); ) {
        it.value().removeAll(widget);
        if (it.value().isEmpty()) {
            it = channelNameToWidgets.erase(it);
        } else {
            ++it;
        }
    }
    if (!widget->getWidgetName().isEmpty()
            && m_widgetNameToWidget.value(widget->getWidgetName()) == widget) {
        m_widgetNameToWidget.remove(widget->getWidgetName());
    }
    if (!editWidgets.isEmpty()) {
        retireFrameLocked(editWidgets[index]);
        editWidgets.remove(index);
    }
    index = consoleWidgets.indexOf(dynamic_cast<QuteConsole *>(widget));
    if (index >= 0) {
        consoleWidgets.remove(index);
    }
    index = graphWidgets.indexOf(dynamic_cast<QuteGraph *>(widget));
    if (index >= 0)
        graphWidgets.remove(index);
    index = scopeWidgets.indexOf(dynamic_cast<QuteScope *>(widget));
    if (index >= 0)
        scopeWidgets.remove(index);
    index = waveformWidgets.indexOf(dynamic_cast<QuteWaveform *>(widget));
    if (index >= 0)
        waveformWidgets.remove(index);
    m_activeWidgets = m_widgets.size();  // Allow all widgets again
    retireWidgetLocked(widget);
    publishChannelSnapshotLocked();
    widgetsMutex.unlock();
    widgetChanged(widget);
}

void WidgetLayout::newValue(QPair<QString, double> channelValue)
{
    // THREADING CONTRACT: this slot must only be called on the GUI thread.
    // See the QString overload of newValue() for the full explanation: the Csound
    // performance thread only enqueues raw values (enqueueOutputValue()), which are
    // applied later via processCsoundUpdates() on the GUI thread, and widget signals
    // are emitted during GUI interaction.
    if (QThread::currentThread() != QCoreApplication::instance()->thread()) {
        qWarning() << Q_FUNC_INFO << "called from a non-GUI thread!"
                   << "This should never happen. Dropping update for channel"
                   << channelValue.first;
        return;
    }

    auto channelName = channelValue.first;
    if(channelName.isEmpty())
        return;
        
    if(channelName[0] == '_') {
        if (channelName == "_SetPreset") {
            loadPreset((int)channelValue.second);
            return;
        }
        else if (channelName == "_SetPresetIndex") {
            loadPresetFromIndex((int)channelValue.second);
            return;
        }    
    }
        
    QString path;
    auto idx = channelName.indexOf("/");
    if (idx >= 0) {
        path = channelName.mid(idx+1);
        channelName = channelName.left(idx);
    }

    // Mirror the string overload of newValue(): when a path is given, e.g.
    // outvalue "b1/CSQT_x", 10, the value addresses a property of the widget(s)
    // bound to the channel, not the widget's value.
    bool sentAsMessage = false;
    if (!path.isEmpty() && !channelName.isEmpty()) {
        if (!widgetsMutex.tryLock(1)) {
            QDEBUG << "Could not acquire widgets lock";
            return;
        }
        for (int i = 0; i < m_widgets.size(); i++) {
            // Properties can be addressed through either the widget's channel
            // or its second channel (e.g. a controller's x/y channels).
            if (m_widgets[i]->getChannelName() != channelName
                    && m_widgets[i]->getChannel2Name() != channelName)
                continue;
            m_widgets[i]->widgetMessage(path, channelValue.second);
            sentAsMessage = true;
        }
        widgetsMutex.unlock();
    }

    if (sentAsMessage) {
        // A message to the widget, not a value change: do not set the value and
        // do not feed it back to Csound (mirrors the string overload).
        return;
    }

    setValue(channelName, channelValue.second);

    // Now store the value in the changes buffer to read from chnget
    valueMutex.lock();
    if(newValues.contains(channelName))
        newValues[channelName] = channelValue.second;
    else
        newValues.insert(channelName, channelValue.second);
    valueMutex.unlock();
}

void WidgetLayout::newValue(QPair<QString, QString> channelValue)
{
    // THREADING CONTRACT: this slot must only be called on the GUI thread.
    // There are exactly two kinds of callers, both on the GUI thread:
    //   1. processCsoundUpdates(), which drains the outvalue queue from updateData()
    //      (the GUI update timer). The Csound performance thread only enqueues raw
    //      values (enqueueOutputString()); it never calls this directly.
    //   2. Signal connections from the widgets themselves (e.g. QuteLineEdit,
    //      QuteButton, see registerWidget()), which are emitted during GUI
    //      interaction and therefore also arrive on the GUI thread.
    // Touching widgets from any other thread is undefined behaviour, so fail loudly
    // instead of silently corrupting state.
    if (QThread::currentThread() != QCoreApplication::instance()->thread()) {
        qWarning() << Q_FUNC_INFO << "called from a non-GUI thread!"
                   << "This should never happen. Dropping update for channel"
                   << channelValue.first;
        return;
    }

    QString channelName = channelValue.first;
    if (channelName.contains("/")) {
        channelName = channelValue.first.left(channelValue.first.indexOf("/"));
    }
    QString path = channelValue.first.mid(channelValue.first.indexOf("/") + 1);
    // Send value to a widget if channel matches
    if(!widgetsMutex.tryLock(1)) {
        QDEBUG << "Could not acquire widgets lock";
        return;
    }
    bool updateValue = true;
    if (!channelName.isEmpty()) {
        for (int i = 0; i < m_widgets.size(); i++){
            // Match either the primary or the second channel (see the numeric
            // overload of newValue()).
            if (m_widgets[i]->getChannelName() != channelName
                    && m_widgets[i]->getChannel2Name() != channelName)
                continue;
            if (path == channelName)
                m_widgets[i]->setValue(channelValue.second);
            else {
                // A "channel/path" message (e.g. "b1/CSQT_color") modifies the
                // widget via widgetMessage() -> applyInternalProperties(). Safe
                // here because of the GUI-thread guard above.
                m_widgets[i]->widgetMessage(path, channelValue.second);
                // This is a message to the widget, not a value change, so it must
                // not be stored in the channel changes buffer below.
                updateValue = false;
            }
        }
    }
    widgetsMutex.unlock();
    // Now store the value in the changes buffer to read from chnget
    if (updateValue && !channelName.isEmpty()) {
        if (!stringValueMutex.tryLock(1)) {
            QDEBUG << "Could not acquire string value mutex";
            return;
        }
        if(newStringValues.contains(channelValue.first))
            newStringValues[channelValue.first] = channelValue.second;
        else
            newStringValues.insert(channelValue.first, channelValue.second);
        stringValueMutex.unlock();
    }
}


void WidgetLayout::queueEvent(QString eventLine)
{
    emit queueEventSignal(eventLine);
}

void WidgetLayout::duplicate()
{
    if(!m_editMode)
        return;
    widgetsMutex.lock();
    QList<int> selectedWidgets;
    for (int i = 0; i < editWidgets.size() ; i++) {
        if (editWidgets[i]->isSelected()) {
            selectedWidgets << i;
        }
    }
    for (int i = 0; i < selectedWidgets.size() ; i++) {
        int index = selectedWidgets[i];
        editWidgets[index]->deselect();
        QDomDocument doc;
        doc.setContent(m_widgets[index]->getWidgetXmlText());
        widgetsMutex.unlock();
        newXmlWidget(doc.firstChildElement("bsbObject"), true, true);
        widgetsMutex.lock();
        // editWidgets.last()->select();
    }
    widgetsMutex.unlock();
    markHistory();
    setModified(true);
}

void WidgetLayout::deleteSelected()
{
    widgetsMutex.lock();
    for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
        if (!editWidgets[i]->isSelected())
            continue;
        widgetsMutex.unlock();
        deleteWidget(m_widgets[i]);
        widgetsMutex.lock();
    }
    widgetsMutex.unlock();
    markHistory();
    setModified(true);
}

void WidgetLayout::moveSelected(int horiz, int vert, int grid) {
    widgetsMutex.lock();

    // Determine a single movement delta for the whole selection by snapping the
    // bounding-box top-left to the grid. Snapping each widget on its own would
    // change the relative positions within a multi-widget selection.
    int minx = 0;
    int miny = 0;
    bool anySelected = false;
    for (int i = 0; i < editWidgets.size(); i++) {
        if (!editWidgets[i]->isSelected())
            continue;
        QPoint pos = m_widgets[i]->pos();
        if (!anySelected) {
            minx = pos.x();
            miny = pos.y();
            anySelected = true;
        } else {
            minx = qMin(minx, pos.x());
            miny = qMin(miny, pos.y());
        }
    }
    if (!anySelected) {
        widgetsMutex.unlock();
        return;
    }

    int dx = horiz;
    int dy = vert;
    if (grid > 1) {
        dx = int(round((minx + horiz) / (double)grid)) * grid - minx;
        dy = int(round((miny + vert) / (double)grid)) * grid - miny;
    }

    for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
        if(!editWidgets[i]->isSelected())
            continue;
        widgetsMutex.unlock();
        QPoint pos = m_widgets[i]->pos();
        int x = pos.x() + dx;
        int y = pos.y() + dy;
        m_widgets[i]->move(x, y);
        editWidgets[i]->move(x, y);
        widgetsMutex.lock();
    }
    widgetsMutex.unlock();
    markHistoryGeometry();
    setModified(true);
}

void WidgetLayout::undo()
{
    if(m_historyIndex <= 0)
        return;
    // If the change being undone only moved/resized widgets, restore the
    // geometry in place instead of reloading (and destroying) the whole panel.
    const bool geometryOnly = m_history[m_historyIndex].geometryOnly;
    m_historyIndex--;
    applyHistoryEntry(m_historyIndex, geometryOnly);
}

void WidgetLayout::reloadWidgets() {
    if(m_historyIndex <= 0 || m_historyIndex >= m_history.size())
        return;
    loadXmlWidgets(m_history[m_historyIndex].xml);
}

void WidgetLayout::redo()
{
    if (m_historyIndex >= m_history.size() - 1)
        return;
    m_historyIndex++;
    applyHistoryEntry(m_historyIndex, m_history[m_historyIndex].geometryOnly);
}

void WidgetLayout::applyHistoryEntry(int targetIndex, bool geometryOnly)
{
    if (geometryOnly) {
        applyHistoryGeometry(m_history[targetIndex].geometry);
        return;
    }
    // If only widgets were added or removed, apply the change incrementally so
    // that the widgets that stay are neither destroyed nor recreated (undoing a
    // removal must not disturb the widgets that are still there).
    if (tryApplyStructuralChange(targetIndex)) {
        return;
    }
    loadXmlWidgets(m_history[targetIndex].xml);
}

bool WidgetLayout::tryApplyStructuralChange(int targetIndex)
{
    if (targetIndex < 0 || targetIndex >= m_history.size()) {
        return false;
    }
    const HistoryEntry &target = m_history[targetIndex];
    if (target.geometry.isEmpty()) {
        return false;  // no state information; use the full reload
    }

    QSet<QString> targetUuids;
    for (auto it = target.geometry.constBegin(); it != target.geometry.constEnd(); ++it) {
        targetUuids.insert(it.key());
    }
    QSet<QString> currentUuids;
    widgetsMutex.lock();
    for (QuteWidget *w : m_widgets) {
        currentUuids.insert(w->getUuid());
    }
    widgetsMutex.unlock();

    if (currentUuids == targetUuids) {
        // Same set of widgets: this was not a structural change (e.g. a
        // property edit); let the caller do a full reload.
        return false;
    }

    const QHash<QString, RuntimeState> runtime = captureRuntimeState();

    // Remove widgets that do not exist in the target state.
    const QVector<QuteWidget *> live = m_widgets;
    for (QuteWidget *w : live) {
        if (!targetUuids.contains(w->getUuid())) {
            deleteWidget(w);
        }
    }

    // Re-create widgets that exist in the target state but are missing now.
    QSet<QString> liveUuids;
    widgetsMutex.lock();
    for (QuteWidget *w : m_widgets) {
        liveUuids.insert(w->getUuid());
    }
    widgetsMutex.unlock();
    const QSet<QString> missing = targetUuids - liveUuids;
    if (!missing.isEmpty()) {
        QDomDocument doc;
        if (!doc.setContent(target.xml)) {
            return false;
        }
        QDomNodeList panel = doc.elementsByTagName("bsbPanel");
        QDomNode p = panel.item(0);
        if (p.isNull()) {
            return false;
        }
        const QDomNodeList children = p.childNodes();
        for (int i = 0; i < children.size(); ++i) {
            QDomElement element = children.item(i).toElement();
            if (element.isNull() || element.tagName() != "bsbObject") {
                continue;
            }
            QString uuid;
            for (QDomNode n = element.firstChild(); !n.isNull(); n = n.nextSibling()) {
                if (n.toElement().tagName() == "uuid") {
                    uuid = n.toElement().text();
                    break;
                }
            }
            if (missing.contains(uuid)) {
                newXmlWidget(element);
            }
        }
    }

    restoreRuntimeState(runtime);
    return true;
}


void WidgetLayout::updateData()
{
    if (closing == 1) {
        closing = 0;
        return;
    }

    if(!m_updating)
        return;

    processCsoundUpdates(); // Apply outvalue updates queued by the performance thread
    refreshWidgets();
    
    int const refresh_rate = m_updateRate;
    int const msec = 1000 / refresh_rate;
    
    if (!layoutMutex.tryLock(1)) {
        updateTimer.singleShot(msec, this, SLOT(updateData()));
        return;
    }
    while (!newCurveBuffer.isEmpty()) {
        Curve * curve = newCurveBuffer.takeFirst();
        newCurve(curve);  // Register new curve
    }
    // Check for graph updates after creating new curves.
    // Csound calls the draw callback once per display update and reuses the
    // data buffer, so every queued WINDAT for a curve points at the same latest
    // data. The buffer is a stack drained newest-first, so keep only the first
    // (newest) entry per curve instead of redrawing once per queued update.
    QSet<uintptr_t> updatedCurves;
    while (curveUpdateBufferCount > 0) {
        WINDAT * curveData = &curveUpdateBuffer[curveUpdateBufferCount--];
        if (updatedCurves.contains(curveData->windid)) {
            continue;
        }
        updatedCurves.insert(curveData->windid);
        Curve *curve = (Curve *) getCurveById(curveData->windid);
        if (curve != nullptr) {
            curve->set_size(curveData->npts);    // number of points
            curve->set_data(curveData->fdata);
            curve->set_caption(curveData->caption);
            curve->set_max(curveData->max);
            curve->set_min(curveData->min);
            curve->set_absmax(curveData->absmax);
            // Y axis scaling factor
            // curve->set_y_scale(windat->y_scale);
            setCurveData(curve);
        }
        // delete curveData; //FIXME don't do this deleting here...
    }
    for (int i = 0; i < scopeWidgets.size(); i++) {
        if (scopeWidgets[i]->isWidgetEnabled())
            scopeWidgets[i]->updateData();
    }
    for (int i = 0; i < waveformWidgets.size(); i++) {
        if (waveformWidgets[i]->isWidgetEnabled())
            waveformWidgets[i]->updateData();
    }
    layoutMutex.unlock();
    closing = 0;
    updateTimer.singleShot(msec, this, SLOT(updateData()));
}

void WidgetLayout::widgetSelected(QuteWidget *widget)
{
    emit widgetSelectedSignal(widget);
}

void WidgetLayout::widgetUnselected(QuteWidget *widget)
{
    emit widgetUnselectedSignal(widget);
}
