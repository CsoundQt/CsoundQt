/*
    Copyright (C) 2010 Andres Cabrera
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

#include "widgetlayout.h"
#include "qutewidget.h"
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
#include "qutedummy.h"
#include "framewidget.h"

#ifdef Q_OS_WIN32
#include <unistd.h> // for usleep()
#endif

#include "qutecsound.h" // For passing the actions from button reserved channels

#ifdef Q_OS_LINUX
#define LAYOUT_X_OFFSET 5
#define LAYOUT_Y_OFFSET 30
#endif
#ifdef Q_OS_SOLARIS
#define LAYOUT_X_OFFSET 0
#define LAYOUT_Y_OFFSET 25
#endif
#ifdef Q_OS_MAC
#define LAYOUT_X_OFFSET 0
#define LAYOUT_Y_OFFSET 0
#endif
#ifdef Q_OS_WIN32
#define LAYOUT_X_OFFSET 0
#define LAYOUT_Y_OFFSET 25
#endif

#define QCS_CURRENT_XML_VERSION 2

WidgetLayout::WidgetLayout(QWidget* parent) : QWidget(parent)
{
  selectionFrame = new QRubberBand(QRubberBand::Rectangle, this);
  selectionFrame->hide();

  m_trackMouse = true;
  m_editMode = false;
  m_enableEdit = true;
  m_xmlFormat = true;
  m_currentPreset = -1;

  m_modified = false;
  closing = 0;
  xOffset = yOffset = 0;
  m_contained = false;

  createSliderAct = new QAction(tr("Create Slider"),this);
  connect(createSliderAct, SIGNAL(triggered()), this, SLOT(createNewSlider()));
  createLabelAct = new QAction(tr("Create Label"),this);
  connect(createLabelAct, SIGNAL(triggered()), this, SLOT(createNewLabel()));
  createDisplayAct = new QAction(tr("Create Display"),this);
  connect(createDisplayAct, SIGNAL(triggered()), this, SLOT(createNewDisplay()));
  createScrollNumberAct = new QAction(tr("Create ScrollNumber"),this);
  connect(createScrollNumberAct, SIGNAL(triggered()),
          this, SLOT(createNewScrollNumber()));
  createLineEditAct = new QAction(tr("Create LineEdit"),this);
  connect(createLineEditAct, SIGNAL(triggered()), this, SLOT(createNewLineEdit()));
  createSpinBoxAct = new QAction(tr("Create SpinBox"),this);
  connect(createSpinBoxAct, SIGNAL(triggered()), this, SLOT(createNewSpinBox()));
  createButtonAct = new QAction(tr("Create Button"),this);
  connect(createButtonAct, SIGNAL(triggered()), this, SLOT(createNewButton()));
  createKnobAct = new QAction(tr("Create Knob"),this);
  connect(createKnobAct, SIGNAL(triggered()), this, SLOT(createNewKnob()));
  createCheckBoxAct = new QAction(tr("Create Checkbox"),this);
  connect(createCheckBoxAct, SIGNAL(triggered()), this, SLOT(createNewCheckBox()));
  createMenuAct = new QAction(tr("Create Menu"),this);
  connect(createMenuAct, SIGNAL(triggered()), this, SLOT(createNewMenu()));
  createMeterAct = new QAction(tr("Create Controller"),this);
  connect(createMeterAct, SIGNAL(triggered()), this, SLOT(createNewMeter()));
  createConsoleAct = new QAction(tr("Create Console"),this);
  connect(createConsoleAct, SIGNAL(triggered()), this, SLOT(createNewConsole()));
  createGraphAct = new QAction(tr("Create Graph"),this);
  connect(createGraphAct, SIGNAL(triggered()), this, SLOT(createNewGraph()));
  createScopeAct = new QAction(tr("Create Scope"),this);
  connect(createScopeAct, SIGNAL(triggered()), this, SLOT(createNewScope()));
  propertiesAct = new QAction(tr("Properties"),this);
  connect(propertiesAct, SIGNAL(triggered()), this, SLOT(propertiesDialog()));

  duplicateAct = new QAction(tr("Duplicate Selected"), this);
  connect(duplicateAct, SIGNAL(triggered()), this, SLOT(duplicate()));
  deleteAct = new QAction(tr("Delete Selected"), this);
  connect(deleteAct, SIGNAL(triggered()), this, SLOT(deleteSelected()));
  clearAct = new QAction(tr("Clear all widgets"), this);
  connect(clearAct, SIGNAL(triggered()), this, SLOT(clearWidgets()));
  selectAllAct = new QAction(tr("Select all widgets"), this);
  connect(selectAllAct, SIGNAL(triggered()), this, SLOT(selectAll()));

  alignLeftAct = new QAction(tr("Align Left"), this);
  connect(alignLeftAct, SIGNAL(triggered()), this, SLOT(alignLeft()));
  alignRightAct = new QAction(tr("Align Right"), this);
  connect(alignRightAct, SIGNAL(triggered()), this, SLOT(alignRight()));
  alignTopAct = new QAction(tr("Align Top"), this);
  connect(alignTopAct, SIGNAL(triggered()), this, SLOT(alignTop()));
  alignBottomAct = new QAction(tr("Align Bottom"), this);
  connect(alignBottomAct, SIGNAL(triggered()), this, SLOT(alignBottom()));
  sendToBackAct = new QAction(tr("Send to back"), this);
  connect(sendToBackAct, SIGNAL(triggered()), this, SLOT(sendToBack()));
  distributeHorizontalAct = new QAction(tr("Distribute Horizontally"), this);
  connect(distributeHorizontalAct, SIGNAL(triggered()), this, SLOT(distributeHorizontal()));
  distributeVerticalAct = new QAction(tr("Distribute Vertically"), this);
  connect(distributeVerticalAct, SIGNAL(triggered()), this, SLOT(distributeVertical()));
  alignCenterHorizontalAct = new QAction(tr("Center Vertically"), this);
  connect(alignCenterHorizontalAct, SIGNAL(triggered()), this, SLOT(alignCenterVertical()));
  alignCenterVerticalAct = new QAction(tr("Center Horizontally"), this);
  connect(alignCenterVerticalAct, SIGNAL(triggered()), this, SLOT(alignCenterHorizontal()));

  storePresetAct = new QAction(tr("Store Preset"), this);
  connect(storePresetAct, SIGNAL(triggered()), this, SLOT(savePreset()));
  newPresetAct = new QAction(tr("New Preset"), this);
  connect(newPresetAct, SIGNAL(triggered()), this, SLOT(newPreset()));
  recallPresetAct = new QAction(tr("Recall Preset"), this);
  connect(recallPresetAct, SIGNAL(triggered()), this, SLOT(loadPreset()));

  setFocusPolicy(Qt::StrongFocus);

  setMouseTracking(true);
  updateData(); // Starts updataData timer
}

WidgetLayout::~WidgetLayout()
{
  disconnect(this, 0,0,0);
  layoutMutex.lock();
  closing = 1;
  layoutMutex.unlock();
  while (closing == 1) {
    qApp->processEvents();
    usleep(10000);
  }
}

unsigned int WidgetLayout::widgetCount()
{
  widgetsMutex.lock();
  unsigned int number = m_widgets.size();
  widgetsMutex.unlock();
  return number;
}

void WidgetLayout::loadWidgets(QString widgets)
{
  if (m_xmlFormat) {
    loadXmlWidgets(widgets);
  }
  else {
    loadMacWidgets(widgets);
  }
}

void WidgetLayout::loadXmlWidgets(QString xmlWidgets)
{
  m_xmlFormat = true;
  clearWidgetLayout();
  QDomDocument doc;
  if (!doc.setContent(xmlWidgets)) {
    qDebug() << "WidgetLayout::loadXmlWidgets Error parsing xml text! Aborting.";
    return;
  }
  QDomNodeList panel = doc.elementsByTagName("bsbPanel");
  if (panel.size() > 1) {
    qDebug() << "WidgetLayout::loadXmlWidgets More than 1 panel available! Using first only";
  }
  QDomNode p = panel.item(0);
  if (p.isNull()) {
    qDebug() << "WidgetLayout::loadXmlWidgets no bsbPanel element! Aborting.";
    return;
  }
  int version = p.toElement().attribute("version", "0").toInt();
  if (version > QCS_CURRENT_XML_VERSION) {
    qDebug() << "WidgetLayout::loadXmlWidgets Newer Widget Format version";
    QMessageBox::warning(this, tr("Newer Widget Format"),
                         tr("The file was was saved by a more recent version of QuteCsound.\n"
                            "Some features may not be available and will not be saved!"));
  }
  else if (version < QCS_CURRENT_XML_VERSION) {
    qDebug() << "WidgetLayout::loadXmlWidgets Older Widget Format version";
  }

  QDomNodeList c = p.childNodes();
  for (int i = 0; i < c.size(); i++) {
    parseXmlNode(c.item(i));
  }
  if (m_editMode) {
    setEditMode(true);
  }
  adjustLayoutSize();
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
          qDebug() << "WidgetLayout::loadXmlPresets " << val;
        }
        if (mode & 2) {
          double val = valueElement.text().toDouble();
          newPreset.addValue2(id, val);
          qDebug() << "WidgetLayout::loadXmlPresets value2" << val;
        }
        if (mode & 4) {
          QString val = valueElement.text();
          newPreset.addStringValue(id, val);
          qDebug() << "WidgetLayout::loadXmlPresets string value" << val;
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

void WidgetLayout::loadMacWidgets(QString macWidgets)
{
//  m_xmlFormat = false;
  clearWidgetLayout();
  QStringList widgetLines = macWidgets.split(QRegExp("[\n\r]"), QString::SkipEmptyParts);
  foreach (QString line, widgetLines) {
//     qDebug("WidgetLine: %s", line.toStdString().c_str());
    if (line.startsWith("i")) {
      if (newMacWidget(line) < 0)
        qDebug() << "WidgetPanel::loadMacWidgets error processing line: " << line;
    }
    else {
      if (!line.contains("<MacGUI>") && !line.contains("</MacGUI>"))
      qDebug() << "WidgetPanel::loadMacWidgets error processing line: " << line;
    }
  }
  if (m_editMode) {
    setEditMode(true);
  }
  adjustLayoutSize();
}

QString WidgetLayout::getWidgetsText()
{
  // This function must be used with care as it accesses the widgets, which
  // may cause crashing since widgets are not reentrant
  QString text = "";
  QString name = "QuteCsound"; // FIXME add setting of panel name
  text = "<bsbPanel version=\"" + QString::number(QCS_CURRENT_XML_VERSION) + "\">\n";
  QString bg, red,green,blue;
  layoutMutex.lock();
  QColor bgColor = this->property("QCS_bgcolor").value<QColor>();
  bg = this->property("QCS_bg").toBool()? QString("background"):QString("nobackground");
  red = QString::number(bgColor.red());
  green =  QString::number(bgColor.green());
  blue =  QString::number(bgColor.blue());
  text += "<bgcolor mode=\"" + bg + "\">\n";
  text +=  "<r>" + red + "</r>\n" +  "<g>"  + green + "</g>\n" + "<b>" + blue + "</b>\n";
  text += "</bgcolor>\n";

  layoutMutex.unlock();
  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++) {
    text += m_widgets[i]->getWidgetXmlText() + "\n";
  }
  widgetsMutex.unlock();
  text += "</bsbPanel>";
  return text;
}

QString WidgetLayout::getPresetsText()
{
  QString text = "<bsbPresets>\n";
  for (int i = 0; i < presets.size(); i++) {
    text += presets[i].getXmlText();
  }
  text += "</bsbPresets>\n";
  return text;
}

QString WidgetLayout::getSelectedWidgetsText()
{
  qDebug() << "WidgetLayout::getSelectedWidgetsText not implemented!";
  QString l;
  widgetsMutex.lock();
  for (int i = 0; i < editWidgets.size(); i++) {
    if (editWidgets[i]->isSelected()) {
      for (int i = 0; i < m_widgets.size(); i++) {
       l += m_widgets[i]->getWidgetXmlText() + "\n";
      }
    }
  }
  widgetsMutex.unlock();
  return l;
}

QString WidgetLayout::getMacWidgetsText()
{
  // This function must be used with care as it accesses the widgets, which
  // may cause crashing since widgets are not reentrant
  QString text = "";
  text = "<MacGUI>\n";
  QString bg, color;
  layoutMutex.lock();
  QColor bgColor = this->property("QCS_bgcolor").value<QColor>();
  bg =  this->property("QCS_bg").toBool()? QString("background"):QString("nobackground");
  color = QString::number((int) (bgColor.redF()*65535.)) + ", ";
  color +=  QString::number((int) (bgColor.greenF()*65535.)) + ", ";
  color +=  QString::number((int) (bgColor.blueF()*65535.));
  layoutMutex.unlock();
  text += "ioView " + bg + " {" + color +"}\n";

  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++) {
    text += m_widgets[i]->getWidgetLine() + "\n";
//     qDebug() << m_widgets[i]->getWidgetXmlText();
  }
  widgetsMutex.unlock();
  text += "</MacGUI>";
  return text;
}

QStringList WidgetLayout::getSelectedMacWidgetsText()
{
  QStringList l;
  widgetsMutex.lock();
  for (int i = 0; i < editWidgets.size(); i++) {
    if (editWidgets[i]->isSelected()) {
      l << m_widgets[i]->getWidgetLine();
    }
  }
  widgetsMutex.unlock();
  return l;
}

void WidgetLayout::setValue(QString channelName, double value)
{
  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++) {
    if (m_widgets[i]->getChannelName() == channelName) {
      m_widgets[i]->setValue(value);
    }
    if (m_widgets[i]->getChannel2Name() == channelName) {
      m_widgets[i]->setValue2(value);
    }
  }
  widgetsMutex.unlock();
}

void WidgetLayout::setKeyRepeatMode(bool repeat)
{
  m_repeatKeys = repeat;
}

void WidgetLayout::setOuterGeometry(int newx, int newy, int neww, int newh)
{
  m_x = newx >= 0 ? newx : m_x;
  m_y = newy >= 0 ? newy : m_y;
  m_w = neww >= 0 ? neww : m_w;
  m_h = newh >= 0 ? newh : m_h;
}

QRect WidgetLayout::getOuterGeometry()
{
  return QRect(m_x, m_y, m_w, m_h);
}

void WidgetLayout::setValue(QString channelName, QString value)
{
  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++) {
    if (m_widgets[i]->getChannelName() == channelName) {
      m_widgets[i]->setValue(value);
//       qDebug() << "WidgetPanel::setValue " << value;
    }
//     if (m_widgets[i]->getChannel2Name() == channelName) {
//       m_widgets[i]->setValue2(value);
//     }
  }
  widgetsMutex.unlock();
}

void WidgetLayout::setValue(int index, double value)
{
  // there are two values for each widget
  widgetsMutex.lock();
  if (index < m_widgets.size() * 2) {
    m_widgets[index/2]->setValue(value);
  }
  widgetsMutex.unlock();
}

void WidgetLayout::setValue(int index, QString value)
{
  // there are two values for each widget
  widgetsMutex.lock();
  if (index < m_widgets.size() * 2) {
    m_widgets[index/2]->setValue(value);
  }
  widgetsMutex.unlock();
}

//void WidgetLayout::getValues(QVector<QString> *channelNames,
//                            QVector<double> *values,
//                            QVector<QString> *stringValues)
//{
//  // This function is called from the Csound thread function, so it must contain realtime compatible functions
//  if (!this->isEnabled()) {
//    return;
//  }
//  if (m_widgets.size() > (channelNames->size()/2) ) { // This allocation is not realtime, but the user can expect dropouts when creating widgets while running
//    channelNames->resize(m_widgets.size() *2);
//    values->resize(m_widgets.size() *2);
//    stringValues->resize(m_widgets.size() *2);
//  }
//  for (int i = 0; i < m_widgets.size() ; i++) {
//    (*channelNames)[i*2] = m_widgets[i]->getChannelName();
//    (*values)[i*2] = m_widgets[i]->getValue();
//    (*stringValues)[i*2] = m_widgets[i]->getStringValue();
//    (*channelNames)[i*2 + 1] = m_widgets[i]->getChannel2Name();
//    (*values)[i*2 + 1] = m_widgets[i]->getValue2();
//  }
//}

QString WidgetLayout::getStringForChannel(QString channelName)
{
//  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size() ; i++) {
    if (m_widgets[i]->getChannelName() == channelName) {
      QString value = m_widgets[i]->getStringValue();
      widgetsMutex.unlock();
      return value;
    }
  }
//  widgetsMutex.unlock();
  return QString();
}

double WidgetLayout::getValueForChannel(QString channelName)
{
//  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size() ; i++) {
//    qDebug() << "WidgetLayout::getValueForChannel " << i << "  " << m_widgets[i]->getChannelName();
    if (m_widgets[i]->getChannelName() == channelName) {
      double value = m_widgets[i]->getValue();
      widgetsMutex.unlock();
      return value;
    }
  }
//  widgetsMutex.unlock();
  return 0.0;
}

void WidgetLayout::getMouseValues(QVector<double> *values)
{
  // values must have size of 6 for _MouseX _MouseY _MouseRelX _MouseRelY MouseBut1 and MouseBut2
  if (this->isEnabled()) {
    (*values)[0] = getMouseX();
    (*values)[1] = getMouseY();
    (*values)[2] = getMouseRelX();
    (*values)[3] = getMouseRelY();
    (*values)[4] = getMouseBut1();
    (*values)[5] = getMouseBut2();
  }
}

int WidgetLayout::getMouseX()
{
  if (mouseX > 0 and mouseX < 4096)
    return mouseX;
  else return 0;
}

int WidgetLayout::getMouseY()
{
  if (mouseY > 0 and mouseY < 4096)
    return mouseY;
  else return 0;
}
int WidgetLayout::getMouseRelX()
{
  if (mouseRelX > 0 and mouseRelX < 4096)
    return mouseRelX;
  else return 0;
}

int WidgetLayout::getMouseRelY()
{
  if (mouseRelY > 0 and mouseRelY < 4096)
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

int WidgetLayout::newXmlWidget(QDomNode mainnode, bool offset, bool newId)
{
  if (mainnode.isNull()) {
    qDebug() << "WidgetLayout::newXmlWidget null element! Aborting.";
    return -1;
  }
  QuteWidget *widget = 0;
  QDomNodeList c = mainnode.childNodes();
  QString type = mainnode.toElement().attribute("type");
  int version = mainnode.toElement().attribute("version").toInt();
  if (version != 2) {
    qDebug() << "WidgetLayout::newXmlWidget WARNING: widget version != 2";
  }
  if (type == "BSBLabel") {
    QuteText *w= new QuteText(this);
    w->setType("display");
    QDomElement ebg = mainnode.toElement().firstChildElement("bgcolor");
    if (!ebg.isNull()) {
      if (mainnode.toElement().attribute("mode")== "background") {
        w->setProperty("QCS_bgcolormode", true);
      }
      w->setProperty("QCS_bgcolor", QVariant(getColorFromElement(ebg)));
    }
    widget = static_cast<QuteWidget *>(w);
  }
  else if (type == "BSBSpinBox") {
    widget = static_cast<QuteSpinBox *>(new QuteSpinBox(this));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else if (type == "BSBLineEdit") {
    widget = static_cast<QuteLineEdit *>(new QuteLineEdit(this));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
    connect(widget, SIGNAL(newValue(QPair<QString,QString>)), this, SLOT(newValue(QPair<QString,QString>)));
  }
  else if (type == "BSBCheckBox") {
    widget = static_cast<QuteWidget *>(new QuteCheckBox(this));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else if (type == "BSBSlider" || type == "BSBHSlider" || type == "BSBVSlider") {
    widget = static_cast<QuteWidget *>( new QuteSlider(this));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else if (type == "BSBKnob") {
    widget = static_cast<QuteWidget *>(new QuteKnob(this));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else if (type == "BSBScrollNumber") {
    widget = static_cast<QuteScrollNumber *>(new QuteScrollNumber(this));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else if (type == "BSBButton") {
    QuteButton *w = new QuteButton(this);
    widget = static_cast<QuteWidget *>(w);
    connect(widget, SIGNAL(queueEvent(QString)), this, SLOT(queueEvent(QString)));
    connect(widget, SIGNAL(newValue(QPair<QString,QString>)), this, SLOT(newValue(QPair<QString,QString>)));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
    emit registerButton(w);
  }
  else if (type == "BSBDropdown") {
    widget = static_cast<QuteWidget *>(new QuteComboBox(this));
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else if (type == "BSBController") {
    QuteMeter *w = new QuteMeter(this);
    widget = static_cast<QuteWidget *>(w);
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else if (type == "BSBGraph") {
    QuteGraph *w = new QuteGraph(this);
    widget = static_cast<QuteWidget *>(w);
    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
    graphWidgets.append(w);
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
//    connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  }
  else {
    qDebug() << "WidgetLayout::newXmlWidget " << type << " not implemented";
  }
  if (widget == 0) {
    qDebug() << "WidgetLayout::newXmlWidget ERROR widget has not been created!";
    return -2;
  }
  for (int i = 0; i < c.size() ; i++) {
    QDomElement node = c.item(i).toElement();
    QString nodeName = node.nodeName();
    if (nodeName == "color" || nodeName == "bgcolor") {  // COLOR type
//      qDebug() << "WidgetLayout::newXmlWidget property: " <<  nodeName.toLocal8Bit()
//        << " set to: " << getColorFromElement(node);
      if (node.attribute("mode") == "background") {
        widget->setProperty("QCS_bgcolormode", true);
      }
      QDomNode n = node.firstChild();
      nodeName.prepend("QCS_");
      widget->setProperty(nodeName.toLocal8Bit(), getColorFromElement(node));
    }
    else if (nodeName == "value" || nodeName == "resolution"
             || nodeName == "minimum" || nodeName == "maximum" ) {  // DOUBLE type
      QDomNode n = node.firstChild();
      nodeName.prepend("QCS_");
//      qDebug() << "WidgetLayout::newXmlWidget DOUBLE property:  " << nodeName.toLocal8Bit() << "--" << n.nodeValue().toDouble();
      widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue().toDouble());
    }
    else if (nodeName == "selectedIndex" ) {  // INT type
      QDomNode n = node.firstChild();
      nodeName.prepend("QCS_");
      widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue().toInt());
    }
    else if (nodeName == "x" || nodeName == "y") {  // INT type
      QDomNode n = node.firstChild();
      nodeName.prepend("QCS_");
      if (offset) {
        widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue().toInt() + 20);
      }
      else {
        widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue().toInt());
      }
    }
    else if (nodeName == "width" || nodeName == "height"
             || nodeName == "fontsize"
             || nodeName == "borderradius"
             || nodeName == "midichan"  || nodeName == "midicc"
             || nodeName == "selectedIndex" ) {  // INT type
      QDomNode n = node.firstChild();
      nodeName.prepend("QCS_");
      widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue().toInt());
    }
    else if (nodeName == "randomizable" || nodeName == "selected" ) {  // BOOL type
      QDomNode n = node.firstChild();
      nodeName.prepend("QCS_");
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
      widget->setProperty("QCS_uuid", uuid);
    }
    else {  // STRING type (all the rest)
      QDomNode n = node.firstChild();
      nodeName.prepend("QCS_");
      widget->setProperty(nodeName.toLocal8Bit(), n.nodeValue());
    }
//    qDebug() << "WidgetLayout::newXmlWidget property: " <<  nodeName.toLocal8Bit()
//        << " set to: " << widget->property(nodeName.toLocal8Bit())
//        << " from: " << QVariant(n.nodeValue());
  }
  widget->applyInternalProperties();
  registerWidget(widget);
  return 0;
}

bool WidgetLayout::uuidFree(QString uuid)
{
  bool isFree = true;
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

int WidgetLayout::newMacWidget(QString widgetLine, bool offset)
{
  // This function returns -1 on error, 0 when no widget was created and 1 if widget was created
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (parts.size()<5)
    return -1;
  if (parts[0]=="ioView") {
  // Colors in MacCsound have a range of 0-65535
    setBackground(parts[1]=="background",
                  QColor(parts[2].toInt()/256,
                         parts[3].toInt()/256,
                         parts[4].toInt()/256
                        )
                 );
    return 0;
  }
  else {
    int x,y,width,height;
    x = parts[1].toInt();
    y = parts[2].toInt();
    if (offset) {
      x += 20;
      y += 20;
    }
    width = parts[3].toInt();
    height = parts[4].toInt();
    if (parts[0]=="ioSlider") {
        return createSlider(x,y,width,height, widgetLine);
    }
    else if (parts[0]=="ioText") {
      if (parts[5]=="label" or parts[5]=="display") {
        return createText(x,y,width,height, widgetLine);
      }
      else if (parts[5]=="edit") {
        return createLineEdit(x,y,width, height, widgetLine);
      }
      else if (parts[5]=="scroll") {
        return createScrollNumber(x,y,width, height, widgetLine);
      }
      else if (parts[5]=="editnum") {
        return createSpinBox(x,y,width, height, widgetLine);
      }
    }
    else if (parts[0]=="ioButton") {
      return createButton(x,y,width,height, widgetLine);
    }
    else if (parts[0]=="ioKnob") {
      return createKnob(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioCheckbox") {
      return createCheckBox(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioMenu") {
      return createMenu(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioListing") {
      return createConsole(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioMeter") {
      return createMeter(x,y,width, height, widgetLine);
    }
    else if (parts[0]=="ioGraph") {
      if (parts.size() < 6 or parts[5]=="table")
        return createGraph(x,y,width, height, widgetLine);
      else if (parts[5]=="fft" or parts[5]=="scope" or parts[5]=="lissajou" or parts[5]=="poincare")
        return createScope(x,y,width, height, widgetLine);
    }
    else {
      // Unknown widget...
      qDebug("WidgetPanel::newMacWidget Warning: unknown widget!");
      return createDummy(x,y,width, height, widgetLine);
    }
  }
  return -1;
}

void WidgetLayout::registerWidget(QuteWidget * widget)
{
  widgetsMutex.lock();
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  setWidgetToolTip(widget, m_tooltips);
  widgetsMutex.unlock();
  adjustLayoutSize();
  widget->show();
}

void WidgetLayout::appendMessage(QString message)
{
  for (int i=0; i < consoleWidgets.size(); i++) {
    consoleWidgets[i]->appendMessage(message);
  }
}

void WidgetLayout::flush()
{
  // Called when running Csound to flush queues
  newValues.clear();
}

void WidgetLayout::engineStopped()
{
//  curveUpdateBuffer.clear();
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
  if (show) {
    if (widget->getChannel2Name() != "") {
      QString text = tr("ChannelH:") + widget->getChannelName()
          + "\n"+ tr("ChannelV:")+ widget->getChannel2Name();
      widget->setToolTip(text);
      if (getEditWidget(widget) != 0) {
        getEditWidget(widget)->setToolTip(text);
      }
    }
    else {
      QString text = tr("Channel:") + widget->getChannelName();
      widget->setToolTip(text);
      if (getEditWidget(widget) != 0) {
        getEditWidget(widget)->setToolTip(text);
      }
    }
  }
  else {
    widget->setToolTip("");
      if (m_editMode && getEditWidget(widget) != 0) {
        getEditWidget(widget)->setToolTip("");
      }
  }
}

void WidgetLayout::setContained(bool contained)
{
  if (m_contained == contained) {
    return;
  }
//  qDebug() << "WidgetLayout::setContained " << contained;
  m_contained = contained;
  bool bg = this->property("QCS_bg").toBool();
  QColor bgColor = this->property("QCS_bgcolor").value<QColor>();
  setBackground(bg, bgColor);
  if (m_contained) {
    this->setAutoFillBackground(false);
  }
}

void WidgetLayout::setCurrentPosition(QPoint pos)
{
  currentPosition = pos;
}

void WidgetLayout::appendCurve(WINDAT *windat)
{
  // Called from the Csound callback, creates a curve and queues it for processing
  // Csound itself deletes the WINDAT structures, that's why we retain a copy of the data for when Csound stops
  // It would be nice if Csound used a single windat for every f-table, but it reuses them...
//  for (int i = 0; i < curves.size(); i++) {  // Check if windat is already handled by one of the existing curves
//    if (windat == curves[i]->getOriginal()) {
//      return;
//    }
//  }
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
  Curve *curve
      = new Curve(windat->fdata,
                  windat->npts,
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
//  qDebug() << "WidgetLayout::appendCurve " << curve << "__--__" << windat;
}

void WidgetLayout::newCurve(Curve* curve)
{
  for (int i = 0; i < graphWidgets.size(); i++) {
    graphWidgets[i]->addCurve(curve);
//    qApp->processEvents(); // FIXME Kludge to allow correct resizing of graph view
    graphWidgets[i]->changeCurve(-1);
  }
  curves.append(curve);
}

void WidgetLayout::setCurveData(Curve *curve)
{
//   qDebug("WidgetPanel::setCurveData");
  for (int i = 0; i < graphWidgets.size(); i++) {
    graphWidgets[i]->setCurveData(curve);
  }
}

void WidgetLayout::passWidgetClipboard(QString text)
{
  m_clipboard = text;
}

uintptr_t WidgetLayout::getCurveById(uintptr_t id)
{
//  qDebug() << "WidgetLayout::getCurveById ";
  foreach (Curve *thisCurve, curves) {
//    qDebug() << "WidgetLayout::getCurveById " << (uintptr_t) thisCurve << " id " << id;
    if ((uintptr_t) thisCurve == id)
      return (uintptr_t) thisCurve;
  }
  return 0;
}

void WidgetLayout::updateCurve(WINDAT *windat)
{
//  qDebug() << "WidgetLayout::updateCurve(WINDAT *windat) ";
  // FIXME dont allocate new memory
  WINDAT *windat_ = (WINDAT *) malloc(sizeof(WINDAT));
  *windat_ = *windat;
  curveUpdateBuffer.append(windat_);
}


int WidgetLayout::killCurves(CSOUND */*csound*/)
{
  // FIXME free memory from curves
//  qDebug() << "qutecsound::killCurves";
  // FIXME this is a great idea, to copy data from the tables at the end of run, but the API is not working as expected
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
  return 0;
}

void WidgetLayout::clearGraphs()
{
  for (int i = 0; i < graphWidgets.size(); i++) {
    graphWidgets[i]->clearCurves();
  }
  for (int i = 0; i < curves.size(); i++) {
    delete curves[i];
  }
  curves.clear();
  for (int i = 0; i < curveUpdateBuffer.size(); i++) {
    free(curveUpdateBuffer[i]);
  }
  curveUpdateBuffer.clear();
  for (int i = 0; i < newCurveBuffer.size(); i++) {
    delete newCurveBuffer[i];
  }
  newCurveBuffer.clear();
}

void WidgetLayout::refreshConsoles()
{
  for (int i=0; i < consoleWidgets.size(); i++) {
    consoleWidgets[i]->scrollToEnd();
  }
}

void WidgetLayout::refreshWidgets()
{
  for (int i=0; i < m_widgets.size(); i++) {
    if (m_widgets[i]->m_valueChanged) {
      m_widgets[i]->refreshWidget();
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

bool WidgetLayout::isModified()
{
  return m_modified;
}

void WidgetLayout::createContextMenu(QContextMenuEvent *event)
{
  QMenu menu;
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
  menu.addSeparator();
  menu.addAction(selectAllAct);
  menu.addAction(duplicateAct);
  menu.addAction(deleteAct);
  menu.addAction(clearAct);
  menu.addSeparator();
  menu.addAction(propertiesAct);
  menu.addSeparator();
  menu.addAction(storePresetAct);
  menu.addAction(recallPresetAct);
  menu.addAction(newPresetAct);
  menu.addSeparator();
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
  for (int i = 0; i< editWidgets.size(); i++) {
    editWidgets[i]->select();
  }
}

void WidgetLayout::widgetMoved(QPair<int, int> delta)
{
  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++) {
    if (editWidgets[i]->isSelected()) {
      int newx = m_widgets[i]->x() + delta.first;
      int newy = m_widgets[i]->y() + delta.second;
      m_widgets[i]->move(newx, newy);
      editWidgets[i]->move(newx, newy);
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
    }
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

void WidgetLayout::adjustLayoutSize()
{
  int width = 30, height = 30;
//  widgetsMutex.lock();
  for (int i = 0; i< m_widgets.size(); i++) {
    if (m_widgets[i]->x() + m_widgets[i]->width() > width) {
      width = m_widgets[i]->x() + m_widgets[i]->width();
    }
    if (m_widgets[i]->y() + m_widgets[i]->height() > height) {
      height = m_widgets[i]->y() + m_widgets[i]->height();
    }
  }
//  widgetsMutex.unlock();
  this->resize(width, height);
  emit resized();
}

void WidgetLayout::selectionChanged(QRect selection)
{
//   qDebug("WidgetLayout::selectionChanged %i %i %i %i", selection.x(), selection.y(), selection.width(), selection.height());
  if (editWidgets.isEmpty())
    return; //not in edit mode
  deselectAll();
  widgetsMutex.lock();
  for (int i = 0; i< m_widgets.size(); i++) {
    int x = m_widgets[i]->x();
    int y = m_widgets[i]->y();
    int w = m_widgets[i]->width();
    int h = m_widgets[i]->height();
    if (x > selection.x() - w && x < selection.x() + selection.width() &&
        y > selection.y() - h && y < selection.y() + selection.height() ) {
      editWidgets[i]->select();
    }
  }
  widgetsMutex.unlock();
}

void WidgetLayout::createNewSlider()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createSlider(posx, posy, 20, 100, QString("ioSlider {"+ QString::number(posx) +", "+ QString::number(posy) + "} {20, 100} 0.000000 1.000000 0.000000 slider" +QString::number(m_widgets.size())));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewLabel()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} label 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground noborder New Label";
  createText(posx, posy, 80, 25, line);
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewDisplay()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} display 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground border Display";
  createText(posx, posy, 80, 25, line);
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewScrollNumber()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} scroll 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} background border 0.000000";
  createScrollNumber(posx, posy, 80, 25, line);
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewLineEdit()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {100, 25} edit 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Type here";
  createLineEdit(posx, posy, 100, 25, line);
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewSpinBox()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} editnum 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Type here";
  createSpinBox(posx, posy, 80, 25, line);
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewButton()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioButton {"+ QString::number(posx) +", "+ QString::number(posy) +"} {100, 30} event 1.000000 \"button1\" \"New Button\" \"/\" i1 0 10";
  createButton(posx, posy, 100, 30, line);
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewKnob()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createKnob(posx, posy, 80, 80, QString("ioKnob {"+ QString::number(posx) +", "+ QString::number(posy) + "} {80, 80} 0.000000 1.000000 0.010000 0.000000 knob" +QString::number(m_widgets.size())));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewCheckBox()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createCheckBox(posx, posy, 20, 20, QString("ioCheckbox {"+ QString::number(posx) +", "+ QString::number(posy) + "} {20, 20} off checkbox" +QString::number(m_widgets.size())));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewMenu()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createMenu(posx, posy, 80, 30, QString("ioMenu {"+ QString::number(posx) +", "+ QString::number(posy) + "} {80, 25} 1 303 \"item1,item2,item3\" menu" +QString::number(m_widgets.size())));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewMeter()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createMeter(posx, posy, 30, 80, QString("ioMeter {"+ QString::number(posx) +", "+ QString::number(posy) + "} {30, 80} {0, 60000, 0} \"vert" + QString::number(m_widgets.size()) + "\" 0.000000 \"hor" + QString::number(m_widgets.size()) + "\" 0.000000 fill 1 0 mouse"));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewConsole()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createConsole(posx, posy, 320, 400, QString("ioListing {"+ QString::number(posx) +", "+ QString::number(posy) + "} {320, 400}"));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewGraph()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createGraph(posx, posy, 350, 150, QString("ioGraph {"+ QString::number(posx) +", "+ QString::number(posy) + "} {350, 150}"));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
}

void WidgetLayout::createNewScope()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createScope(posx, posy, 350, 150, QString("ioGraph {"+ QString::number(posx) +", "+ QString::number(posy) + "} {350, 150} scope 2.000000 -1.000000"));
  widgetChanged();
  if (getOpenProperties()) {
    m_widgets.last()->openProperties();
  }
  markHistory();
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
  foreach (QuteWidget *widget, m_widgets) {
    delete widget;
  }
  m_widgets.clear();
  foreach (FrameWidget *widget, editWidgets) {
//     qDebug("WidgetLayout::clearWidgetLayout() removed editWidget");
    delete widget;
  }
  editWidgets.clear();
  consoleWidgets.clear();
  graphWidgets.clear();
  scopeWidgets.clear();
  widgetsMutex.unlock();
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
  bgButton->setProperty("QCS_color",QVariant(color));
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
  QColor color = bgButton->property("QCS_color").value<QColor>();
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
    bgButton->setProperty("QCS_color",QVariant(color));
    QPixmap pixmap(64,64);
    pixmap.fill(color);
    bgButton->setIcon(pixmap);
  }
}

void WidgetLayout::alignLeft()
{
  int newx = 99999;
  if (m_editMode) {
    widgetsMutex.lock();
    int size = editWidgets.size();
    for (int i = 0; i < size ; i++) { // First find leftmost
      if (editWidgets[i]->isSelected()) {
        newx =  editWidgets[i]->x() < newx ? editWidgets[i]->x(): newx;
      }
    }
    for (int i = 0; i < size ; i++) { // Then put all x values to that
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->move(newx, editWidgets[i]->y());
        m_widgets[i]->move(newx, editWidgets[i]->y());
      }
    }
    widgetsMutex.unlock();
  }
}

void WidgetLayout::alignRight()
{
  int newx = -99999;
  if (m_editMode) {
    widgetsMutex.lock();
    int size = editWidgets.size();
    for (int i = 0; i < size ; i++) { // First find leftmost
      if (editWidgets[i]->isSelected()) {
        newx =  editWidgets[i]->x() > newx ? editWidgets[i]->x(): newx;
      }
    }
    for (int i = 0; i < size ; i++) { // Then put all x values to that
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->move(newx, editWidgets[i]->y());
        m_widgets[i]->move(newx, editWidgets[i]->y());
      }
    }
    widgetsMutex.unlock();
  }
}

void WidgetLayout::alignTop()
{
  int newy = 99999;
  if (m_editMode) {
    widgetsMutex.lock();
    int size = editWidgets.size();
    for (int i = 0; i < size ; i++) { // First find uppermost
      if (editWidgets[i]->isSelected()) {
        newy =  editWidgets[i]->y() < newy ? editWidgets[i]->y(): newy;
      }
    }
    for (int i = 0; i < size ; i++) { // Then put all y values to that
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->move(editWidgets[i]->x(), newy);
        m_widgets[i]->move(editWidgets[i]->x(), newy);
      }
    }
    widgetsMutex.unlock();
  }
}

void WidgetLayout::alignBottom()
{
  int newy = -99999;
  if (m_editMode) {
    widgetsMutex.lock();
    int size = editWidgets.size();
    for (int i = 0; i < size ; i++) { // First find uppermost
      if (editWidgets[i]->isSelected()) {
        newy =  editWidgets[i]->y() > newy ? editWidgets[i]->y(): newy;
      }
    }
    for (int i = 0; i < size ; i++) { // Then put all y values to that
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->move(editWidgets[i]->x(), newy);
        m_widgets[i]->move(editWidgets[i]->x(), newy);
      }
    }
    widgetsMutex.unlock();
  }
}

void WidgetLayout::sendToBack()
{
  if (m_editMode) {
    widgetsMutex.lock();
    for (int i = 0; i < editWidgets.size() ; i++) { // First invert selection
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->deselect();
      }
      else {
        editWidgets[i]->select();
      }
    }
    widgetsMutex.unlock();
    cut();
    paste();
    widgetsMutex.lock();
    for (int i = 0; i < editWidgets.size() ; i++) { // Now invert selection again
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->deselect();
      }
      else {
        editWidgets[i]->select();
      }
    }
    widgetsMutex.unlock();
  }
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
//    qDebug() << "WidgetLayout::distributeHorizontal " << emptySpace <<  "---" << order;
    int accum = min;
    for (int i = 1; i < order.size() - 1 ; i++) { // Don't touch first and last
      spacing = emptySpace / (num- i);
      emptySpace -= spacing;
      accum += spacing + editWidgets[order[i-1]]->width();
//      qDebug() << "WidgetLayout::distributeHorizontal --" << i;
      editWidgets[order[i]]->move(accum, editWidgets[order[i]]->y());
      m_widgets[order[i]]->move(accum, editWidgets[order[i]]->y());
    }
    widgetsMutex.unlock();
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
//      qDebug() << "WidgetLayout::distributeHorizontal --" << i;
      editWidgets[order[i]]->move(editWidgets[order[i]]->x(), accum);
      m_widgets[order[i]]->move(editWidgets[order[i]]->x(), accum);
    }
    widgetsMutex.unlock();
  }
}

void WidgetLayout::alignCenterVertical()
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
  }
}

void WidgetLayout::alignCenterHorizontal()
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
  }
}

void WidgetLayout::keyPressEvent(QKeyEvent *event)
{
//  qDebug() << "WidgetLayout::keyPressEvent --- " << event->key() << "___" << event->modifiers() << " control = " <<  Qt::ControlModifier;
  if (!event->isAutoRepeat() or m_repeatKeys) {
    QString key = event->text();
    if (event->key() == Qt::Key_D && (event->modifiers() & Qt::ControlModifier )) {
      this->duplicate();
      event->accept();
      return;
    }
    // Why are these not working here?????
    if (event->key() == Qt::Key_X && (event->modifiers() & Qt::ControlModifier )) {
      this->cut();
      event->accept();
      return;
    }
    else if (event->key() == Qt::Key_C && (event->modifiers() & Qt::ControlModifier )) {
      this->copy();
      event->accept();
      return;
    }
    else if (event->key() == Qt::Key_V && (event->modifiers() & Qt::ControlModifier )) {
      this->paste();
      event->accept();
      return;
    }
    else if (event->matches(QKeySequence::Delete)) {
      this->deleteSelected();
    }
    else if (event->matches(QKeySequence::Undo)) {
      this->undo();
    }
    else if (event->matches(QKeySequence::Redo)) {
      this->redo();
    }
    else if (key != "") {
//           appendMessage(key);
      emit keyPressed(key);
      QWidget::keyPressEvent(event); // Propagate event if not used
    }
  }
  // FIXME something here might be causing the beeping on OS X because the keyboard event is not being accepted
  // http://sourceforge.net/tracker/index.php?func=detail&aid=2991838&group_id=227265&atid=1070588
}

void WidgetLayout::keyReleaseEvent(QKeyEvent *event)
{
  if (!event->isAutoRepeat() or m_repeatKeys) {
    QString key = event->text();
    if (key != "") {
//           appendMessage("rel:" + key);
      emit keyReleased(key);
    }
  }
  QWidget::keyReleaseEvent(event); // Propagate event
}

void WidgetLayout::widgetChanged(QuteWidget* widget)
{
  if (widget != 0) {
//    widgetsMutex.lock();
    int index = m_widgets.indexOf(widget);
    if (index >= 0 and editWidgets.size() > index) {
      int newx = widget->x();
      int newy = widget->y();
      int neww = widget->width();
      int newh = widget->height();
      editWidgets[index]->move(newx, newy);
      editWidgets[index]->resize(neww, newh);
    }
    setWidgetToolTip(widget, m_tooltips);
//    widgetsMutex.unlock();
    emit changed();
  }
  adjustLayoutSize();
}

void WidgetLayout::mousePressEvent(QMouseEvent *event)
{
  if (m_editMode && (event->button() & Qt::LeftButton)) {
    this->setFocus(Qt::MouseFocusReason);
    selectionFrame->show();
    startx = event->x() - LAYOUT_X_OFFSET + xOffset;
    starty = event->y() - LAYOUT_Y_OFFSET + yOffset;
    selectionFrame->setGeometry(startx, starty, 0,0);
    if (event->button() & Qt::LeftButton) {
      deselectAll();
    }
  }
//  else if (m_editMode && (event->button() & Qt::RightButton)) {
//
//  }
//  qDebug() << "WidgetPanel::mouseMoveEvent " << event->x();
  if (event->button() == Qt::LeftButton)
    mouseBut1 = 1;
  else if (event->button() == Qt::RightButton)
    mouseBut2 = 1;
  QWidget::mousePressEvent(event);
}

void WidgetLayout::mouseMoveEvent(QMouseEvent *event)
{
  QWidget::mouseMoveEvent(event);
  int x = startx;
  int y = starty;
  int width = abs(event->x() - startx - LAYOUT_X_OFFSET + xOffset);
  int height = abs(event->y() - starty - LAYOUT_Y_OFFSET + yOffset);
  if (event->buttons() & Qt::LeftButton) {  // Currently dragging selection
    if (event->x() < startx) {
      x = event->x() + xOffset;
      //         width = event->x() - startx;
    }
    if (event->y() < starty) {
      y = event->y() + yOffset;
      //         height = event->y() - starty;
    }
    selectionFrame->setGeometry(x, y, width, height);
    selectionChanged(QRect(x,y,width,height));
  }
//  qDebug() << "WidgetPanel::mouseMoveEvent " << event->x();
  mouseX = event->globalX();
  mouseY = event->globalY();
  mouseRelX = event->x() + xOffset;
  mouseRelY = event->y() + xOffset;
}

void WidgetLayout::mouseReleaseEvent(QMouseEvent *event)
{
  if (event->button() & Qt::LeftButton) {
    selectionFrame->hide();
  }
//  qDebug() << "WidgetPanel::mouseMoveEvent " << event->x();
  if (event->button() == Qt::LeftButton)
    mouseBut1 = 0;
  else if (event->button() == Qt::RightButton) {
    emit deselectAll();
    mouseBut2 = 0;
  }
  markHistory();
  QWidget::mouseReleaseEvent(event);
}

void WidgetLayout::contextMenuEvent(QContextMenuEvent *event)
{
  if (m_enableEdit) {
    createContextMenu(event);
    event->accept();
  }
}

bool WidgetLayout::parseXmlNode(QDomNode node)
{
  QString name = node.nodeName();
  if (name == "objectName") {
    this->setProperty("QCS_objectName", node.firstChild().nodeValue());
  }
  else if (name == "x") {
    m_x = node.firstChild().nodeValue().toInt();
  }
  else if (name == "y") {
    m_y = node.firstChild().nodeValue().toInt();
  }
  else if (name == "width") {
    m_w = node.firstChild().nodeValue().toInt();
  }
  else if (name == "height") {
    m_h = node.firstChild().nodeValue().toInt();
  }
  else if (name == "visible") {
    qDebug()<< "WidgetLayout::parseXmlNode visible element not implemented.";
  }
  else if (name == "uuid") {
    qDebug()<< "WidgetLayout::parseXmlNode uuid element not implemented.";
  }
  else if (name == "bgcolor") {
    bool bg = false;
    if (node.toElement().attribute("mode")== "background") {
      bg = true;
    }
    QDomElement er = node.toElement().firstChildElement("r");
    QDomElement eg = node.toElement().firstChildElement("g");
    QDomElement eb = node.toElement().firstChildElement("b");

    setBackground(bg, QColor(er.firstChild().nodeValue().toInt(),
                             eg.firstChild().nodeValue().toInt(),
                             eb.firstChild().nodeValue().toInt()) );
  }
  else if (name == "bsbObject") {
    newXmlWidget(node);
  }
  else if (name == "bsbGroup") {
    qDebug() << "WidgetLayout::parseXmlNode bsbGroup not implemented";
  }
  else {
    qDebug() << "WidgetLayout::parseXmlNode unknown node name: "<< name;
    return false;
  }
  return true;
}

int WidgetLayout::createSlider(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioSlider x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteSlider *widget= new QuteSlider(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setProperty("QCS_minimum",parts[5].toDouble());
  widget->setProperty("QCS_maximum",parts[6].toDouble());
  widget->setProperty("QCS_value",parts[7].toDouble());

  if (parts.size()>8) {
    int i=8;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setProperty("QCS_objectName", channelName);
  }
  widget->applyInternalProperties();
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createText(int x, int y, int width, int height, QString widgetLine)
{
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (parts.size()<20 or quoteParts.size()<5)
    return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (lastParts.size() < 9)
    return -1;
  QuteText *widget= new QuteText(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setType(parts[5]);
  widget->setProperty("QCS_objectName",quoteParts[1]);
  widget->setProperty("QCS_alignment",quoteParts[2].simplified());
  widget->setProperty("QCS_font",quoteParts[3].simplified());

  //#define QCS_XXSMALL 8
  //#define QCS_XSMALL 10
  //#define QCS_SMALL 12
  //#define QCS_MEDIUM 16
  //#define QCS_LARGE 20
  //#define QCS_XLARGE 24
  //#define QCS_XXLARGE 28
  widget->setProperty("QCS_fontsize",lastParts[0].toInt());
  widget->setProperty("QCS_color", QColor(lastParts[1].toDouble()/256.0,
                                          lastParts[2].toDouble()/256.0,
                                          lastParts[3].toDouble()/256.0));
  widget->setProperty("QCS_bgcolor", QColor(lastParts[4].toDouble()/256.0,
                                          lastParts[5].toDouble()/256.0,
                                          lastParts[6].toDouble()/256.0));
  widget->setProperty("QCS_bgcolormode", lastParts[7] == "background");
  widget->setProperty("QCS_bordermode", lastParts[8]);
  QString labelText = "";
  labelText = widgetLine.mid(widgetLine.indexOf("border") + 7);
  if (parts[5] == "display" || parts[5] == "label") {
    widget->setProperty("QCS_precision", 3);
  }
  else {
    widget->setProperty("QCS_resolution", parts[7].toDouble());
  }
  widget->setProperty("QCS_label", labelText.replace("\u00AC", "\n"));
  widget->applyInternalProperties();
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createScrollNumber(int x, int y, int width, int height, QString widgetLine)
{
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (parts.size()<20 or quoteParts.size()<5)
    return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (lastParts.size() < 9)
    return -1;
  QuteScrollNumber *widget= new QuteScrollNumber(this);

  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setType(parts[5]);
  widget->setProperty("QCS_resolution", parts[7].toDouble());
  widget->setProperty("QCS_objectName",quoteParts[1]);
  widget->setProperty("QCS_alignment",quoteParts[2].simplified());
  widget->setProperty("QCS_font",quoteParts[3].simplified());
  widget->setProperty("QCS_fontsize",lastParts[0].toInt());
  widget->setProperty("QCS_color", QColor(lastParts[1].toDouble()/256.0,
                                          lastParts[2].toDouble()/256.0,
                                          lastParts[3].toDouble()/256.0));
  widget->setProperty("QCS_bgcolor", QColor(lastParts[4].toDouble()/256.0,
                                          lastParts[5].toDouble()/256.0,
                                          lastParts[6].toDouble()/256.0));
  widget->setProperty("QCS_bgcolormode", lastParts[7] == "background");
  widget->setProperty("QCS_bordermode", lastParts[8]);

  QString labelText = "";
  int i = 9;
  while (lastParts.size() > i) {
    labelText += lastParts[i] + " ";
    i++;
  }
  labelText.chop(1);
  widget->setProperty("QCS_value", labelText.toDouble());
//  widget->setValue(labelText.toDouble());
  widget->applyInternalProperties();
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createLineEdit(int x, int y, int width, int height, QString widgetLine)
{
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (parts.size()<20 or quoteParts.size()<5)
    return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (lastParts.size() < 9)
    return -1;
  QuteLineEdit *widget= new QuteLineEdit(this);

  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setType(parts[5]);
  widget->setProperty("QCS_objectName",quoteParts[1]);
  widget->setProperty("QCS_alignment",quoteParts[2].simplified());
  widget->setProperty("QCS_font",quoteParts[3].simplified());
  widget->setProperty("QCS_fontsize",lastParts[0].toInt());
  widget->setProperty("QCS_color", QColor(lastParts[1].toDouble()/256.0,
                                          lastParts[2].toDouble()/256.0,
                                          lastParts[3].toDouble()/256.0));
  widget->setProperty("QCS_bgcolor", QColor(lastParts[4].toDouble()/256.0,
                                          lastParts[5].toDouble()/256.0,
                                          lastParts[6].toDouble()/256.0));
  widget->setProperty("QCS_bgcolormode", lastParts[7] == "background");
  widget->setProperty("QCS_bordermode", lastParts[8]);
  QString labelText = "";
  labelText = widgetLine.mid(widgetLine.indexOf("border") + 7);
//  widget->setProperty("QCS_resolution", parts[7].toDouble());
  widget->setProperty("QCS_label", labelText);
  widget->applyInternalProperties();

  registerWidget(widget);
  return 1;
}

int WidgetLayout::createSpinBox(int x, int y, int width, int height, QString widgetLine)
{
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (parts.size()<20 or quoteParts.size()<5)
    return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (lastParts.size() < 9)
    return -1;
  QuteSpinBox *widget= new QuteSpinBox(this);

  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setType(parts[5]);
  widget->setProperty("QCS_resolution",parts[7].toDouble());
  widget->setProperty("QCS_objectName",quoteParts[1]);
  widget->setProperty("QCS_alignment",quoteParts[2].simplified());
  widget->setProperty("QCS_font",quoteParts[3].simplified());
  widget->setProperty("QCS_fontsize",lastParts[0].toInt());
  widget->setProperty("QCS_color", QColor(lastParts[1].toDouble()/256.0,
                                          lastParts[2].toDouble()/256.0,
                                          lastParts[3].toDouble()/256.0));
  widget->setProperty("QCS_bgcolor", QColor(lastParts[4].toDouble()/256.0,
                                          lastParts[5].toDouble()/256.0,
                                          lastParts[6].toDouble()/256.0));
  widget->setProperty("QCS_bgcolormode", lastParts[7] == "background");
  widget->setProperty("QCS_bordermode", lastParts[8]);

  QString labelText = "";
  int i = 9;
  while (lastParts.size() > i) {
    labelText += lastParts[i] + " ";
    i++;
  }
  labelText.chop(1);
  widget->setValue(labelText.toDouble());
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  widget->applyInternalProperties();
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createButton(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("WidgetPanel::createButton");
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
//   if (parts.size()<20 or quoteParts.size()>5)
//     return -1;
  QStringList lastParts = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
//   if (lastParts.size() < 9)
//     return -1;
  QuteButton *widget= new QuteButton(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setProperty("QCS_objectName",quoteParts[1]);
  widget->setProperty("QCS_type",parts[5]);
  widget->setProperty("QCS_value",parts[6].toDouble()); //value produced by button when pushed
//  widget->setProperty("QCS_stringvalue",parts[7].toDouble()); // Not available in old format
  widget->setText(quoteParts[3]);
  widget->setProperty("QCS_image",quoteParts[5]);
  if (quoteParts.size()>6) {
    quoteParts[6].remove(0,1); //remove initial space
    widget->setProperty("QCS_eventLine", quoteParts[6]);
  }
  connect(widget, SIGNAL(queueEvent(QString)), this, SLOT(queueEvent(QString)));
  connect(widget, SIGNAL(newValue(QPair<QString,QString>)), this, SLOT(newValue(QPair<QString,QString>)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  emit registerButton(widget);
  widget->applyInternalProperties();
  registerWidget(widget);

  return 1;
}

int WidgetLayout::createKnob(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioKnob x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteKnob *widget= new QuteKnob(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setProperty("QCS_minimum",parts[5].toDouble());
  widget->setProperty("QCS_maximum",parts[6].toDouble());
  widget->setProperty("QCS_resolution",parts[7].toDouble());
  widget->setProperty("QCS_value",parts[8].toDouble());
  if (parts.size()>9) {
    int i=9;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setProperty("QCS_objectName", channelName);
  }
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  widget->applyInternalProperties();
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createCheckBox(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioCheckBox x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteCheckBox *widget= new QuteCheckBox(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setValue(parts[5]=="on");
  if (parts.size()>6) {
    int i=6;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setProperty("QCS_objectName", channelName);
  }
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  widget->applyInternalProperties();
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createMenu(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioMenu x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  QuteComboBox *widget= new QuteComboBox(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  if (quoteParts.size() > 2) {
    widget->setProperty("QCS_objectName", quoteParts[2].remove(0,1)); //remove initial space from channel name
  }
  widget->setProperty("QCS_selectedIndex", parts[5].toInt());

  widget->setText(quoteParts[1]);
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  widget->applyInternalProperties();
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createMeter(int x, int y, int width, int height, QString widgetLine)
{
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  if (quoteParts.size() < 5) {
    qDebug("WidgetPanel::createMeter ERROR parsing widget line!");
    return 0;
  }
  QStringList parts2 = quoteParts[4].split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (parts2.size() < 5) {
    qDebug("WidgetPanel::createMeter ERROR parsing widget line!");
    return 0;
  }
  QuteMeter *widget= new QuteMeter(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  widget->setProperty("QCS_color" ,QColor(parts[5].toDouble()/256.0,
                                          parts[6].toDouble()/256.0,
                                          parts[7].toDouble()/256.0));
  widget->setProperty("QCS_type", parts2[1]);
  widget->setProperty("QCS_objectName2", quoteParts[1]);
  widget->setProperty("QCS_yValue", quoteParts[2].toDouble());
  widget->setProperty("QCS_xValue", parts2[0].toDouble());
  widget->setProperty("QCS_objectName", quoteParts[3]);
  widget->setProperty("QCS_pointsize", parts2[2].toInt());
  widget->setProperty("QCS_fadeSpeed", parts2[3].toInt());
  widget->setProperty("QCS_xMin", 0.0);
  widget->setProperty("QCS_xMax", 1.0);
  widget->setProperty("QCS_yMin", 0.0);
  widget->setProperty("QCS_yMax", 1.0);
//  widget->setBehavior(parts2[4]);

  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  widget->applyInternalProperties();
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createConsole(int x, int y, int width, int height, QString widgetLine)
{
//    qDebug("ioListing x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteConsole *widget= new QuteConsole(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);

  widget->applyInternalProperties();
  consoleWidgets.append(widget);
  registerWidget(widget);
  return 1;
}

int WidgetLayout::createGraph(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioGraph x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteGraph *widget= new QuteGraph(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  //Graph widget is always of type "graph" part 5 is discarded
  if (parts.size() > 6)
    widget->setValue(parts[6].toDouble());
  if (parts.size() > 7) {
    widget->setProperty("QCS_zoomx",parts[7].toDouble());
  }
  else
    widget->setProperty("QCS_zoomx", 1.0);
  if (parts.size()>8) {
    int i = 8;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setProperty("QCS_objectName", channelName);
  }
  graphWidgets.append(widget);
  emit registerGraph(widget);
  registerWidget(widget);
  widget->applyInternalProperties();
  return 1;
}

int WidgetLayout::createScope(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("WidgetPanel::createScope ioGraph x=%i y=%i w=%i h=%i", x,y, width, height);
//   qDebug("%s",widgetLine.toStdString().c_str() );
  QuteScope *widget= new QuteScope(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (parts.size() > 5) {
    widget->setProperty("QCS_type",parts[5]);
  }
  if (parts.size() > 6) {
    widget->setProperty("QCS_zoomx",parts[6].toDouble());
  }
  if (parts.size() > 7) {
    int chans = (int) parts[7].toDouble();
    if (chans < 0) {
      chans = -255; // Force all 8 channels when loading old format
    }
    widget->setProperty("QCS_value", chans);
  }
  if (parts.size() > 8) {
    int i=8;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setProperty("QCS_objectName", channelName);
  }
  emit registerScope(widget);
  scopeWidgets.append(widget);
  registerWidget(widget);
  widget->applyInternalProperties();
  return 1;
}

int WidgetLayout::createDummy(int x, int y, int width, int height, QString widgetLine)
{
  QuteWidget *widget= new QuteDummy(this);
  widget->setProperty("QCS_x",x);
  widget->setProperty("QCS_y",y);
  widget->setProperty("QCS_width",width);
  widget->setProperty("QCS_height",height);
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  widget->show();
  widgetsMutex.lock();
  m_widgets.append(widget);
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  setWidgetToolTip(widget, m_tooltips);
  widgetsMutex.unlock();
  adjustLayoutSize();
  return 1;
}

void WidgetLayout::setBackground(bool bg, QColor bgColor)
{
//  qDebug() << "WidgetLayout::setBackground " << bg << "--" << bgColor;
  QWidget *w;
  layoutMutex.lock();
  w = m_contained ?  this->parentWidget() : this;  // If contained, set background of parent widget
  w->setPalette(QPalette(bgColor));
  w->setBackgroundRole(QPalette::Window);
  w->setAutoFillBackground(bg);
  layoutMutex.unlock();
  this->setProperty("QCS_bg", QVariant(bg));
  this->setProperty("QCS_bgcolor", QVariant(bgColor));
}

FrameWidget *WidgetLayout::getEditWidget(QuteWidget *widget)
{
  // This function is only called from setWidgetTooltip, so it should not be locked, because it already is
  FrameWidget *out = 0;
//  qDebug() << "WidgetLayout::getEditWidget";
  for (int i  = 0 ; i < m_widgets.size(); i++) {
    if (m_widgets[i] == widget) {
      if (editWidgets.size() > i) {
//        qDebug() << "WidgetLayout::getEditWidget " << editWidgets[i];
        return editWidgets[i];
      }
    }
  }
  return out;
}

void WidgetLayout::setModified(bool mod)
{
//  qDebug() << "WidgetLayout::setModified";
  m_modified = mod;
  emit changed();
}

void WidgetLayout::setMouseOffset(int x, int y)
{
  xOffset = x;
  yOffset = y;
}

void WidgetLayout::clearHistory()
{
  m_history.clear();
  m_history << "";
  m_historyIndex = 0;
}

int WidgetLayout::getPresetIndex(int number)
{
  int index = -1;
  for (int i = 0; i < presets.size(); i++) {
    if (presets[i].getNumber() == number) {
      index = i;
      break;
    }
  }
  return index;
}

void WidgetLayout::loadPreset()
{
  QDialog d(this);
  QVBoxLayout *l = new QVBoxLayout(&d);
  QLabel *lab= new QLabel(&d);
  QComboBox *box = new QComboBox(&d);
  QPushButton *okButton = new QPushButton(tr("Ok"),&d);
  QPushButton *cancelButton = new QPushButton(tr("Cancel"),&d);
  lab->setText(tr("Select Preset to Load"));
  l->addWidget(lab);
  l->addWidget(box);
  l->addWidget(cancelButton);
  l->addWidget(okButton);
  connect(okButton, SIGNAL(released()), &d, SLOT(accept()));
  connect(cancelButton, SIGNAL(released()), &d, SLOT(reject()));

  for (int i = 0; i < presets.size(); i++) {
    QString itemText = QString::number(presets[i].getNumber()) + "  " + presets[i].getName();
    box->addItem(itemText, presets[i].getNumber() );
  }

  int ret = d.exec();
  if (ret == QDialog::Accepted) {
    loadPreset(presets[box->currentIndex()].getNumber());
  }
}

void WidgetLayout::loadPresetFromAction()
{
  QAction *s = static_cast<QAction *>(sender());
  loadPreset(s->data().toInt());
}

void WidgetLayout::loadPreset(int num)
{
  int index = getPresetIndex(num);
  qDebug() << "WidgetLayout::loadPreset " << num << "  " << index;
  if (index < 0) {
    qDebug() << "WidgetLayout::loadPreset num invalid.";
    return;
  }
  WidgetPreset p = presets[index];
  QStringList ids = p.getWidgetIds();
  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++) {
    QString id = m_widgets[i]->getUuid();
    qDebug() << "WidgetPreset::idIndex " << p.idIndex(id);
    if (p.idIndex(id) > -1) {
      int mode = p.getMode(id);
      if (mode & 1) {
        m_widgets[i]->setValue(p.getValue(id));
      }
      if (mode & 2) {
        m_widgets[i]->setValue2(p.getValue2(id));
      }
      if (mode & 4) {
        m_widgets[i]->setValue(p.getStringValue(id));
      }
    }
  }
  widgetsMutex.unlock();
}

void WidgetLayout::newPreset()
{
  QDialog d(this);
  QGridLayout *l = new QGridLayout(&d);
  QLabel *nameLabel = new QLabel(tr("New Preset Name:"), &d);
  QLineEdit *nameLineEdit = new QLineEdit(&d);
  QLabel *numberLabel = new QLabel(tr("Number:"), &d);
  QSpinBox *numberSpinBox = new QSpinBox(&d);
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
    savePreset(numberSpinBox->value(), nameLineEdit->text() );
//    qDebug() << "WidgetLayout::newPreset() " << numberSpinBox->value() << "  " << nameLineEdit->text();
  }
}

//void WidgetLayout::newPreset(int number, QString name)
//{
//  presets.resize(presets.size() + 1);
//  savePreset(number, name);
//}

void WidgetLayout::savePreset()
{
  QDialog d(this);
  QVBoxLayout *l = new QVBoxLayout(&d);
  QLabel *lab= new QLabel(&d);
  QComboBox *box = new QComboBox(&d);
  QPushButton *okButton = new QPushButton(tr("Ok"),&d);
  QPushButton *cancelButton = new QPushButton(tr("Cancel"),&d);
  lab->setText(tr("Select Preset to save"));
  l->addWidget(lab);
  l->addWidget(box);
  l->addWidget(cancelButton);
  l->addWidget(okButton);
  connect(okButton, SIGNAL(released()), &d, SLOT(accept()));
  connect(cancelButton, SIGNAL(released()), &d, SLOT(reject()));

  for (int i = 0; i < presets.size(); i++) {
    QString itemText = QString::number(presets[i].getNumber()) + "  " + presets[i].getName();
    box->addItem(itemText, presets[i].getNumber() );
  }
  box->setCurrentIndex(m_currentPreset);

  int ret = d.exec();
  if (ret == QDialog::Accepted) {
    savePreset(box->currentIndex(), presets[box->currentIndex()].getName());
    m_currentPreset = box->currentIndex();
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
    QString id = m_widgets[i]->getUuid();
    if (!(m_widgets[i]->getWidgetType() == "BSBLabel")
        && !(m_widgets[i]->getWidgetType() == "BSBTextEdit")
        && !(m_widgets[i]->getWidgetType() == "BSBButton")
        && !(m_widgets[i]->getWidgetType() == "BSBConsole")) {
      p.addValue(id, m_widgets[i]->getValue());
    }
    if (m_widgets[i]->getWidgetType() == "BSBController"
        || m_widgets[i]->getWidgetType() == "BSBXYController") {
      p.addValue2(id, m_widgets[i]->getValue2());
    }
    if (m_widgets[i]->getWidgetType() == "BSBLabel"
        || m_widgets[i]->getWidgetType() == "BSBButton"
        || m_widgets[i]->getWidgetType() == "BSBTextEdit") {
      p.addStringValue(id, m_widgets[i]->getStringValue());
    }
  }
  widgetsMutex.unlock();
  presets[index] = p;
}

void WidgetLayout::setPresetName(int num, QString name)
{
  if (num >= 0 && num < presets.size()) {
    int index = getPresetIndex(num);
    if (index >= 0) {
      presets[getPresetIndex(num)].setName(name);
    }
    else {
      qDebug() << "WidgetLayout::setPresetName invalud number.";
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
    qDebug() << "WidgetLayout::getPresetName invalud number.";
  }
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
    if (m_xmlFormat) {
      for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
        if (editWidgets[i]->isSelected()) {
          text += m_widgets[i]->getWidgetXmlText()+ "\n";
        }
      }
    }
    else {
      for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
        if (editWidgets[i]->isSelected()) {
          text += m_widgets[i]->getWidgetLine() + "\n";
        }
      }
    }
    m_clipboard = text;
    widgetsMutex.unlock();
    emit setWidgetClipboardSignal(m_clipboard);
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
    if (m_xmlFormat) {
      QDomDocument doc;
      QString errorText;
      int lineNumber, column;
      if (!doc.setContent("<doc>" + m_clipboard + "</doc>", &errorText, &lineNumber, &column)) {
        qDebug() << "WidgetLayout::paste Parsing Error: " << errorText <<  lineNumber << column << m_clipboard;
      }
      QDomElement docElement = doc.firstChildElement("doc");
      QDomElement pl = docElement.firstChildElement("bsbObject");
      qDebug() << "WidgetLayout::paste() " << doc.toString();
      while (!pl.isNull()) {
        qDebug() << "WidgetLayout::paste() " << pl.text();
        newXmlWidget(pl);
        editWidgets.last()->select();
        pl = pl.nextSiblingElement("bsbObject");
      }
    }
    else {
      QStringList lines = m_clipboard.split("\n");
      foreach (QString line, lines) {
        newMacWidget(line);
        editWidgets.last()->select();
      }
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
    foreach (FrameWidget *widget, editWidgets) {
      delete widget;
    }
    editWidgets.clear();
    foreach (QuteWidget * widget, m_widgets) {
      createEditFrame(widget);
      setWidgetToolTip(widget,m_tooltips);
    }
    widgetsMutex.unlock();
  }
  else {
    foreach (QFrame* frame, editWidgets) {
      delete(frame);
    }
    editWidgets.clear();
  }
  m_editMode = active;
}

void WidgetLayout::createEditFrame(QuteWidget* widget)
{
  // This function should be locked from outside always
  FrameWidget * frame = new FrameWidget(this);
  QPalette palette(QColor(Qt::red),QColor(Qt::red));
  palette.setColor(QPalette::WindowText, QColor(Qt::red));
  frame->setWidget(widget);
  frame->setPalette(palette);
  frame->setFocusProxy(this);
  frame->setGeometry(widget->x(), widget->y(), widget->width(), widget->height());
  frame->setFrameShape(QFrame::Box);
//       frame->setMouseTracking(false);  //Only track mouse when buttons are pressed
  frame->show();
  editWidgets.append(frame);
  connect(frame, SIGNAL(popUpMenu(QPoint)), widget, SLOT(popUpMenu(QPoint)));
  connect(frame, SIGNAL(deselectAllSignal()), this, SLOT(deselectAll()));
  connect(frame, SIGNAL(moved( QPair<int, int> )), this, SLOT(widgetMoved( QPair<int, int> )));
  connect(frame, SIGNAL(resized( QPair<int, int> )), this, SLOT(widgetResized( QPair<int, int> )));
  connect(frame, SIGNAL(mouseReleased()), this, SLOT(markHistory()));
  connect(frame, SIGNAL(editWidget()), widget, SLOT(openProperties()));
}

void WidgetLayout::markHistory()
{
  QString text;
  if (m_xmlFormat) {
    text = getWidgetsText();
  }
  else {
    text = getMacWidgetsText();
  }
  if (m_history.isEmpty()) {
    m_history << "";
    m_historyIndex = 0;
  }
  if (m_history[m_historyIndex] != text) {
    if (! m_history[m_historyIndex].isEmpty())
      m_historyIndex++;
    if (m_historyIndex >= QCS_MAX_UNDO) {
      m_history.pop_front();
      (m_historyIndex)--;
    }
    if (m_history.size() != m_historyIndex + 1)
      m_history.resize(m_historyIndex + 1);
    m_history[m_historyIndex] = text;
    //    qDebug() << "WidgetLayout::markHistory "<< *m_historyIndex << " ....."  << text;
  }
}

void WidgetLayout::deleteWidget(QuteWidget *widget)
{
  widgetsMutex.lock();
  int index = m_widgets.indexOf(widget);
//   qDebug("WidgetPanel::deleteWidget %i", number);
  widget->close();
  m_widgets.remove(index);
  if (!editWidgets.isEmpty()) {
    delete(editWidgets[index]);
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
  widgetsMutex.unlock();
  widgetChanged(widget);
}

void WidgetLayout::newValue(QPair<QString, double> channelValue)
{
//  qDebug() << "WidgetLayout::newValue " << channelValue.first << "--" << channelValue.second;
  widgetsMutex.lock();
  if (!channelValue.first.isEmpty()) {
    for (int i = 0; i < m_widgets.size(); i++){
      if (m_widgets[i]->getChannelName() == channelValue.first) {
//        qDebug() << "WidgetLayout::newValue " << channelValue.first << "--" << m_widgets[i]->getChannelName();
        m_widgets[i]->setValue(channelValue.second);
      }
      if (m_widgets[i]->getChannel2Name() == channelValue.first) {
        m_widgets[i]->setValue2(channelValue.second);
      }
    }
  }
  widgetsMutex.unlock();
}

void WidgetLayout::newValue(QPair<QString, QString> channelValue)
{
  widgetsMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++){
    if (m_widgets[i]->getChannelName() == channelValue.first) {
      m_widgets[i]->setValue(channelValue.second);
    }
  }
  widgetsMutex.unlock();
//  if (!channelValue.first.isEmpty()) {
//    stringValueMutex.lock();
//    if(newStringValues.contains(channelValue.first)) {
//      newStringValues[channelValue.first] = channelValue.second;
//    }
//    else {
//      newStringValues.insert(channelValue.first, channelValue.second);
//    }
//    stringValueMutex.unlock();
//  }
}

void WidgetLayout::processNewValues()
{
  // Apply values received
//   qDebug("WidgetPanel::processNewValues");

  //FIXME clean this processes
  if (closing != 0)
    return;
  QList<QString> channelNames;
//  valueMutex.lock();
//  channelNames = newValues.keys();
//  valueMutex.unlock();
//  widgetsMutex.lock();
//  foreach(QString name, channelNames) {
//    for (int i = 0; i < m_widgets.size(); i++){
//      if (m_widgets[i]->getChannelName() == name) {
//        m_widgets[i]->setValue(newValues.value(name));
//      }
//      if (m_widgets[i]->getChannel2Name() == name) {
//        m_widgets[i]->setValue2(newValues.value(name));
//      }
//      if (m_trackMouse) {
//        QString ch1name = m_widgets[i]->getChannelName();
//        if (ch1name == "_MouseX") {
//          m_widgets[i]->setValue(getMouseX());
//        }
//        else if (ch1name == "_MouseY") {
//          m_widgets[i]->setValue(getMouseY());
//        }
//        else if (ch1name == "_MouseRelX") {
//          m_widgets[i]->setValue(getMouseRelX());
//        }
//        else if (ch1name == "_MouseRelY") {
//          m_widgets[i]->setValue(getMouseRelY());
//        }
//        else if (ch1name == "_MouseBut1") {
//          m_widgets[i]->setValue(getMouseBut1());
//        }
//        else if (ch1name == "_MouseBut2") {
//          m_widgets[i]->setValue(getMouseBut2());
//        }
//        QString ch2name = m_widgets[i]->getChannel2Name();
//        if (ch2name == "_MouseX") {
//          m_widgets[i]->setValue2(getMouseX());
//        }
//        else if (ch2name == "_MouseY") {
//          m_widgets[i]->setValue2(getMouseY());
//        }
//        else if (ch2name == "_MouseRelX") {
//          m_widgets[i]->setValue2(getMouseRelX());
//        }
//        else if (ch2name == "_MouseRelY") {
//          m_widgets[i]->setValue2(getMouseRelY());
//        }
//        else if (ch2name == "_MouseBut1") {
//          m_widgets[i]->setValue2(getMouseBut1());
//        }
//        else if (ch2name == "_MouseBut2") {
//          m_widgets[i]->setValue2(getMouseBut2());
//        }
//      }
//    }
//  }
//  widgetsMutex.unlock();
//  valueMutex.lock();
//  newValues.clear();
//  valueMutex.unlock();
//  stringValueMutex.lock();
//  channelNames = newStringValues.keys();
//  // Now set string values
//  stringValueMutex.unlock();
//  widgetsMutex.lock();
//  foreach(QString name, channelNames) {
//    for (int i = 0; i < m_widgets.size(); i++){
//      if (m_widgets[i]->getChannelName() == name) {
//        m_widgets[i]->setValue(newStringValues.value(name));
//      }
//    }
//  }
//  widgetsMutex.unlock();
//  stringValueMutex.lock();
//  newStringValues.clear();
//  stringValueMutex.unlock();
}

void WidgetLayout::queueEvent(QString eventLine)
{
  // FIXME connect this!!
  emit queueEventSignal(eventLine);
}

//void WidgetLayout::paste(QPoint /*pos*/)
//{
//}

void WidgetLayout::duplicate()
{
   qDebug("WidgetLayout::duplicate()");
  if (m_editMode) {
    widgetsMutex.lock();
    int size = editWidgets.size();
    for (int i = 0; i < size ; i++) {
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->deselect();
        if (m_xmlFormat) {
          QDomDocument doc;
          doc.setContent(m_widgets[i]->getWidgetXmlText());
          widgetsMutex.unlock();
          newXmlWidget(doc.firstChildElement("bsbObject"), true, true);
          widgetsMutex.lock();
//          qDebug() << "WidgetLayout::duplicate() " << m_widgets[i]->getWidgetXmlText();
        }
        else {
          widgetsMutex.unlock();
          newMacWidget(m_widgets[i]->getWidgetLine(), true);
          widgetsMutex.lock();
        }
        editWidgets.last()->select();
      }
    }
    widgetsMutex.unlock();
  }
  markHistory();
}

void WidgetLayout::deleteSelected()
{
//   qDebug("WidgetLayout::deleteSelected()");
  widgetsMutex.lock();
  for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
    if (editWidgets[i]->isSelected()) {
      deleteWidget(m_widgets[i]);
    }
  }
  widgetsMutex.unlock();
  markHistory();
}

void WidgetLayout::undo()
{
//  qDebug() << "WidgetLayout::undo()";
  if (m_historyIndex > 0) {
    (m_historyIndex)--;
    if (m_xmlFormat) {
      loadXmlWidgets(m_history[m_historyIndex]);
    }
    else {
//      qDebug() << "WidgetLayout::undo() " << m_historyIndex << "...." << m_history[m_historyIndex];
      loadMacWidgets(m_history[m_historyIndex]);
    }
  }
}

void WidgetLayout::redo()
{
//  qDebug() << "WidgetLayout::redo()";
  if (m_historyIndex < m_history.size() - 1) {
    m_historyIndex++;
    if (m_xmlFormat) {
      loadXmlWidgets(m_history[m_historyIndex]);
    }
    else {
      loadMacWidgets(m_history[m_historyIndex]);
    }
  }
}

void WidgetLayout::killCurve(WINDAT *windat)
{
  qDebug() << "WidgetLayout::killCurve()";
  Curve *curve = (Curve *) getCurveById(windat->windid);
  curve->setOriginal(0);
}

void WidgetLayout::updateData()
{
  if (closing == 1) {
    closing = 0;
    return;
  }
  if (!layoutMutex.tryLock(30)) {
    QTimer::singleShot(30, this, SLOT(updateData()));
    return;
  }
  while (!newCurveBuffer.isEmpty()) {
    Curve * curve = newCurveBuffer.takeFirst();
    newCurve(curve); // Register new curve
//    qDebug() << "WidgetLayout::updateData() new curve " << curve;
  }
  // Check for graph updates after creating new curves
  for (int i = 0; i < curveUpdateBuffer.size(); i++) {
    Curve *curve = (Curve *) getCurveById(curveUpdateBuffer[i]->windid);
//    qDebug() << "WidgetLayout::updateData() " << i << " of " << curveUpdateBuffer.size() <<  " ---" << curveUpdateBuffer[i] << "  " << curve;
    if (curve == 0) {
      break;
    }
    WINDAT * windat = curve->getOriginal();
    windat = curveUpdateBuffer[i];
    if (windat != 0) {
//      qDebug() << "WidgetLayout::updateData() " << windat->caption << "-" <<  curve->get_caption();
      curve->set_size(windat->npts);      // number of points
      curve->set_data(windat->fdata);
      curve->set_caption(QString(windat->caption)); // title of curve
      //      curve->set_polarity(windat->polarity); // polarity
      curve->set_max(windat->max);        // curve max
      curve->set_min(windat->min);        // curve min
      curve->set_absmax(windat->absmax);     // abs max of above
      //      curve->set_y_scale(windat->y_scale);    // Y axis scaling factor
      setCurveData(curve);
      curveUpdateBuffer.remove(i);
      i--;
    }
  }
//  curveBuffer.clear();
  for (int i = 0; i < scopeWidgets.size(); i++) {
    scopeWidgets[i]->updateData();
  }
  layoutMutex.unlock();
  closing = 0;
  QTimer::singleShot(30, this, SLOT(updateData()));
}
