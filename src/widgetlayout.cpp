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
#define LAYOUT_Y_OFFSET 25
#endif
#ifdef Q_OS_WIN32
#define LAYOUT_X_OFFSET 0
#define LAYOUT_Y_OFFSET 25
#endif

WidgetLayout::WidgetLayout(QWidget* parent) : QWidget(parent)
{
//       m_panel = (WidgetPanel *) parent;
  selectionFrame = new QRubberBand(QRubberBand::Rectangle, this);
  selectionFrame->hide();

  m_trackMouse = true;
  m_editMode = false;

  m_modified = false;

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
//  duplicateAct->setShortcut(tr("Ctrl+D"));
//  duplicateAct->setShortcutContext (Qt::ApplicationShortcut); // Needed because some key events are not propagation properly
  connect(duplicateAct, SIGNAL(triggered()), this, SLOT(duplicate()));
//  m_duplicateShortcut = QKeySequence("Ctrl+D");
  deleteAct = new QAction(tr("Delete Selected"), this);
//  deleteAct->setShortcut(tr("Ctrl+M"));
//   QList<QKeySequence> deleteShortcuts;
//   deleteShortcuts << QKeySequence::Delete << Qt::Key_Backspace << Qt::Key_Delete;
//   deleteAct->setShortcuts(deleteShortcuts);
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

//  setFocusPolicy(Qt::NoFocus);
  closing = 0;
  updateData(); // Starts updataData timer
}

WidgetLayout::~WidgetLayout()
{
  disconnect(this, 0,0,0);
  closing = 1;
  while (closing == 1) {
    qApp->processEvents();
    usleep(10000);
  }
}

//void WidgetLayout::setPanel(WidgetPanel* panel)
//{
//  m_panel = panel;
//}
//
//WidgetPanel * WidgetLayout::panel()
//{
//  return m_panel;
//}
//
//void WidgetLayout::setUndoHistory(QVector<QString> *history, int *index)
//{
//  m_history = history;
//  m_historyIndex = index;
//}

unsigned int WidgetLayout::widgetCount()
{
  return m_widgets.size();
}

void WidgetLayout::loadWidgets(QString macWidgets)
{
  clearWidgetLayout();
  QStringList widgetLines = macWidgets.split(QRegExp("[\n\r]"), QString::SkipEmptyParts);
  foreach (QString line, widgetLines) {
//     qDebug("WidgetLine: %s", line.toStdString().c_str());
    if (line.startsWith("i")) {
      if (newWidget(line) < 0)
        qDebug() << "WidgetPanel::loadWidgets error processing line: " << line;
    }
    else {
      if (!line.contains("<MacGUI>") && !line.contains("</MacGUI>"))
      qDebug() << "WidgetPanel::loadWidgets error processing line: " << line;
    }
  }
  if (m_editMode) {
    setEditMode(true);
  }
  adjustLayoutSize();
}

QString WidgetLayout::getMacWidgetsText()
{
  // This function must be used with care as it accesses the widgets, which
  // may cause crashing since widgets are not reentrant
  QString text = "";
  text = "<MacGUI>\n";
  text += "ioView " + (this->parentWidget()->autoFillBackground()? QString("background "):QString("nobackground "));
  text += "{" + QString::number((int) (this->parentWidget()->palette().button().color().redF()*65535.)) + ", ";
  text +=  QString::number((int) (this->parentWidget()->palette().button().color().greenF()*65535.)) + ", ";
  text +=  QString::number((int) (this->parentWidget()->palette().button().color().blueF()*65535.)) +"}\n";

  valueMutex.lock();
  for (int i = 0; i < m_widgets.size(); i++) {
    text += m_widgets[i]->getWidgetLine() + "\n";
//     qDebug() << m_widgets[i]->getWidgetXmlText();
  }
  valueMutex.unlock();
  text += "</MacGUI>";
  return text;
}

QStringList WidgetLayout::getSelectedMacWidgetsText()
{
  QStringList l;
  for (int i = 0; i < editWidgets.size(); i++) {
    if (editWidgets[i]->isSelected()) {
      l << m_widgets[i]->getWidgetLine();
    }
  }
  return l;
}

QString WidgetLayout::getWidgetsText()
{
  qDebug() << "WidgetLayout::getWidgetsText not implemented and will crash!";
}

QStringList WidgetLayout::getSelectedWidgetsText()
{
  qDebug() << "WidgetLayout::getSelectedWidgetsText not implemented and will crash!";
}

void WidgetLayout::setValue(QString channelName, double value)
{
  for (int i = 0; i < m_widgets.size(); i++) {
    if (m_widgets[i]->getChannelName() == channelName) {
      m_widgets[i]->setValue(value);
    }
    if (m_widgets[i]->getChannel2Name() == channelName) {
      m_widgets[i]->setValue2(value);
    }
  }
}

void WidgetLayout::setKeyRepeatMode(bool repeat)
{
  m_repeatKeys = repeat;
}

//void WidgetLayout::setDuplicateShortcut(QKeySequence shortcut)
//{
//  m_duplicateShortcut = shortcut;
//}

void WidgetLayout::setValue(QString channelName, QString value)
{
  for (int i = 0; i < m_widgets.size(); i++) {
    if (m_widgets[i]->getChannelName() == channelName) {
      m_widgets[i]->setValue(value);
//       qDebug() << "WidgetPanel::setValue " << value;
    }
//     if (m_widgets[i]->getChannel2Name() == channelName) {
//       m_widgets[i]->setValue2(value);
//     }
  }
}

void WidgetLayout::setValue(int index, double value)
{
  // there are two values for each widget
  if (index >= m_widgets.size() * 2)
    return;
  m_widgets[index/2]->setValue(value);
}

void WidgetLayout::setValue(int index, QString value)
{
  // there are two values for each widget
  if (index >= m_widgets.size() * 2)
    return;
  m_widgets[index/2]->setValue(value);
}

void WidgetLayout::getValues(QVector<QString> *channelNames,
                            QVector<double> *values,
                            QVector<QString> *stringValues)
{
  // This function is called from the Csound thread function, so it must not contain realtime compatible functions
  if (!this->isEnabled()) {
    return;
  }
  if (m_widgets.size() > (channelNames->size()/2) ) { // This allocation is not realtime, but the user can expect dropouts when creating widgets while running
    channelNames->resize(m_widgets.size() *2);
    values->resize(m_widgets.size() *2);
    stringValues->resize(m_widgets.size() *2);
  }
  for (int i = 0; i < channelNames->size()/2 ; i++) {
    (*channelNames)[i*2] = m_widgets[i]->getChannelName();
    (*values)[i*2] = m_widgets[i]->getValue();
    (*stringValues)[i*2] = m_widgets[i]->getStringValue();
    (*channelNames)[i*2 + 1] = m_widgets[i]->getChannel2Name();
    (*values)[i*2 + 1] = m_widgets[i]->getValue2();
  }
}

void WidgetLayout::getMouseValues(QVector<double> *values)
{
  // values must have size of 4 for _MouseX _MouseY _MouseRelX and _MouseRelY
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

int WidgetLayout::newWidget(QString widgetLine, bool offset)
{
  //FIXME is it still necessary to pass an offeset?
  // This function returns -1 on error, 0 when no widget was created and 1 if widget was created
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"'); //Remove this line whe not needed
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
      qDebug("WidgetPanel::newWidget Warning: unknown widget!");
      return createDummy(x,y,width, height, widgetLine);
    }
  }
  return -1;
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

void WidgetLayout::showWidgetTooltips(bool show)
{
  m_tooltips = show;
  for (int i=0; i < m_widgets.size(); i++) {
    setWidgetToolTip(m_widgets[i], show);
  }
}

void WidgetLayout::setWidgetToolTip(QuteWidget *widget, bool show)
{
  if (show) {
    if (widget->getChannel2Name() != "") {
      widget->setToolTip(tr("ChannelV:") + widget->getChannelName()
          + tr("\nChannelH:")+ widget->getChannel2Name());
    }
    else {
      widget->setToolTip(tr("Channel:") + widget->getChannelName());
    }
  }
  else
    widget->setToolTip("");
}

void WidgetLayout::appendCurve(WINDAT *windat)
{
//  qDebug() << "WidgetLayout::appendCurve " << curve;
  windat->caption[CAPSIZE - 1] = 0; // Just in case...
  Polarity polarity;
    // translate polarities and hope the definition in Csound doesn't change.
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
                  windat->danflag);  //FIXME delete these, but where?
  windat->windid = (uintptr_t) curve;
  curve->set_id((uintptr_t) curve);
  newCurveBuffer.append(curve);
}

void WidgetLayout::newCurve(Curve* curve)
{
  for (int i = 0; i < graphWidgets.size(); i++) {
    graphWidgets[i]->addCurve(curve);
    curves.append(curve);
    qApp->processEvents(); // FIXME Kludge to allow correct resizing of graph view
    graphWidgets[i]->changeCurve(-1);
  }
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

Curve * WidgetLayout::getCurveById(uintptr_t id)
{
  foreach (Curve *thisCurve, curves) {
//     qDebug() << "WidgetLayout::getCurveById " << thisCurve->get_id() << " id " << id;
    if (thisCurve->get_id() == id)
      return thisCurve;
  }
  return 0;
}

void WidgetLayout::updateCurve(WINDAT *windat)
{
//  qDebug() << "WidgetLayout::updateCurve(WINDAT *windat) ";
  // FIXME dont allocate new memory
  WINDAT *windat_ = (WINDAT *) malloc(sizeof(WINDAT));
  *windat_ = *windat;
  curveBuffer.append(windat_);
}


int WidgetLayout::killCurves(CSOUND *csound)
{
  // FIXME free memory from curves
//  clearGraphs();
  qDebug() << "qutecsound::killCurves. Implement!";
  return 0;
}

void WidgetLayout::clearGraphs()
{
  for (int i = 0; i < graphWidgets.size(); i++) {
    graphWidgets[i]->clearCurves();
  }
  curves.clear();
  curveBuffer.clear();
  newCurveBuffer.clear();

}

void WidgetLayout::refreshConsoles()
{
  // Necessary
  for (int i=0; i < consoleWidgets.size(); i++) {
    consoleWidgets[i]->scrollToEnd();
  }
}

QString WidgetLayout::getCsladspaLines()
{
  QString text = "";
  int unsupported = 0;
  foreach(QuteWidget *widget, m_widgets) {
    QString line = widget->getCsladspaLine();
    if (line != "") {
      text += line + "\n";
    }
    else {
      unsupported++;
    }
  }
  qDebug() << "WidgetPanel:getCsladspaLines() " << unsupported << " Unsupported widgets";
  return text;
}

bool WidgetLayout::isModified()
{
  return m_modified;
}

//void WidgetLayout::setEditAct(QAction *_editAct)
//{
//  editAct = _editAct;
//  connect(editAct, SIGNAL(triggered(bool)), this, SLOT(setEditMode(bool)));
//}

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
  // FIXME put actions back in menu
//  menu.addAction(editAct);
//  menu.addSeparator();
//  menu.addAction(cutAct);
//  menu.addAction(copyAct);
//  menu.addAction(pasteAct);
  menu.addAction(selectAllAct);
  menu.addAction(duplicateAct);
  menu.addAction(deleteAct);
  menu.addAction(clearAct);
  menu.addSeparator();
  menu.addAction(propertiesAct);
  currentPosition = event->pos();
//  if (m_sbActive) {
//    currentPosition.setX(currentPosition.x() + scrollArea->horizontalScrollBar()->value());
//    currentPosition.setY(currentPosition.y() + scrollArea->verticalScrollBar()->value() - 20);
//  }
  menu.exec(event->globalPos());
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
  for (int i = 0; i < m_widgets.size(); i++) {
    if (editWidgets[i]->isSelected()) {
      int newx = m_widgets[i]->x() + delta.first;
      int newy = m_widgets[i]->y() + delta.second;
      m_widgets[i]->move(newx, newy);
      editWidgets[i]->move(newx, newy);
    }
  }
  adjustLayoutSize();
}

void WidgetLayout::widgetResized(QPair<int, int> delta)
{
//   qDebug("WidgetPanel::widgetResized %i  %i", delta.first, delta.second);
  for (int i = 0; i< editWidgets.size(); i++) {
    if (editWidgets[i]->isSelected()) {
      int neww = m_widgets[i]->width() + delta.first;
      int newh = m_widgets[i]->height() + delta.second;
      m_widgets[i]->setWidgetGeometry(m_widgets[i]->x(), m_widgets[i]->y(), neww, newh);
      editWidgets[i]->resize(neww, newh);
    }
  }
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
//  int woff = 20, hoff = 45; // hack to avoid scrollbars...
  for (int i = 0; i< m_widgets.size(); i++) {
    if (m_widgets[i]->x() + m_widgets[i]->width() > width) {
      width = m_widgets[i]->x() + m_widgets[i]->width();
    }
    if (m_widgets[i]->y() + m_widgets[i]->height() > height) {
      height = m_widgets[i]->y() + m_widgets[i]->height();
    }
  }
//  if (this->width() - woff > width) {
//    width = this->width() - woff;
//  }
//  if  (this->height() - hoff > height) {
//    height = this->height() - hoff;
//  }
  this->resize(width, height);
  emit resized();
}

void WidgetLayout::selectionChanged(QRect selection)
{
//   qDebug("WidgetLayout::selectionChanged %i %i %i %i", selection.x(), selection.y(), selection.width(), selection.height());
  if (editWidgets.isEmpty())
    return; //not in edit mode
  deselectAll();
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
}

void WidgetLayout::createNewSlider()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createSlider(posx, posy, 20, 100, QString("ioSlider {"+ QString::number(posx) +", "+ QString::number(posy) + "} {20, 100} 0.000000 1.000000 0.000000 slider" +QString::number(m_widgets.size())));
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewLabel()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} label 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground noborder New Label";
  createText(posx, posy, 80, 25, line);
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewDisplay()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} display 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground border Display";
  createText(posx, posy, 80, 25, line);
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewScrollNumber()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} scroll 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} background border 0.000000";
  createScrollNumber(posx, posy, 80, 25, line);
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewLineEdit()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {100, 25} edit 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Type here";
  createLineEdit(posx, posy, 100, 25, line);
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewSpinBox()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioText {"+ QString::number(posx) +", "+ QString::number(posy) +"} {80, 25} editnum 0.000000 0.001000 \"\" left \"Lucida Grande\" 8 {0, 0, 0} {65535, 65535, 65535} nobackground noborder Type here";
  createSpinBox(posx, posy, 80, 25, line);
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewButton()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  QString line = "ioButton {"+ QString::number(posx) +", "+ QString::number(posy) +"} {100, 30} event 1.000000 \"button1\" \"New Button\" \"/\" i1 0 10";
  createButton(posx, posy, 100, 30, line);
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewKnob()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createKnob(posx, posy, 80, 80, QString("ioKnob {"+ QString::number(posx) +", "+ QString::number(posy) + "} {80, 80} 0.000000 1.000000 0.010000 0.000000 knob" +QString::number(m_widgets.size())));
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewCheckBox()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createCheckBox(posx, posy, 20, 20, QString("ioCheckbox {"+ QString::number(posx) +", "+ QString::number(posy) + "} {20, 20} off checkbox" +QString::number(m_widgets.size())));
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewMenu()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createMenu(posx, posy, 80, 30, QString("ioMenu {"+ QString::number(posx) +", "+ QString::number(posy) + "} {80, 25} 1 303 \"item1,item2,item3\" menu" +QString::number(m_widgets.size())));
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewMeter()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createMeter(posx, posy, 30, 80, QString("ioMeter {"+ QString::number(posx) +", "+ QString::number(posy) + "} {30, 80} {0, 60000, 0} \"vert" + QString::number(m_widgets.size()) + "\" 0.000000 \"hor" + QString::number(m_widgets.size()) + "\" 0.000000 fill 1 0 mouse"));
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewConsole()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createConsole(posx, posy, 320, 400, QString("ioListing {"+ QString::number(posx) +", "+ QString::number(posy) + "} {320, 400}"));
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewGraph()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createGraph(posx, posy, 350, 150, QString("ioGraph {"+ QString::number(posx) +", "+ QString::number(posy) + "} {350, 150}"));
  widgetChanged();
  markHistory();
}

void WidgetLayout::createNewScope()
{
  int posx = currentPosition.x();
  int posy = currentPosition.y();
  createScope(posx, posy, 350, 150, QString("ioGraph {"+ QString::number(posx) +", "+ QString::number(posy) + "} {350, 150} scope 2.000000 -1.000000"));
  widgetChanged();
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
  bgCheckBox->setChecked(parentWidget()->autoFillBackground());
  layout->addWidget(bgCheckBox, 0, 0, Qt::AlignRight|Qt::AlignVCenter);
  QLabel *label = new QLabel(dialog);
//   label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  label->setText("Color");
  label->setAlignment(Qt::AlignRight|Qt::AlignVCenter);
  layout->addWidget(label, 1, 0, Qt::AlignRight|Qt::AlignVCenter);
  bgButton = new QPushButton(dialog);
  QPixmap pixmap = QPixmap(64,64);
  pixmap.fill(this->palette().button().color());
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
  setBackground(bgCheckBox->isChecked(), this->palette().button().color());
  widgetChanged();
}

void WidgetLayout::selectBgColor()
{
  QColor color = QColorDialog::getColor(this->palette().button().color(), this);
  if (color.isValid()) {
    this->setPalette(QPalette(color));
    QPixmap pixmap(64,64);
    pixmap.fill(this->palette().button().color());
    bgButton->setIcon(pixmap);
  }
}

void WidgetLayout::alignLeft()
{
  int newx = 99999;
  if (m_editMode) {
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
  }
}

void WidgetLayout::alignRight()
{
  int newx = -99999;
  if (m_editMode) {
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
  }
}

void WidgetLayout::alignTop()
{
  int newy = 99999;
  if (m_editMode) {
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
  }
}

void WidgetLayout::alignBottom()
{
  int newy = -99999;
  if (m_editMode) {
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
  }
}

void WidgetLayout::sendToBack()
{
  if (m_editMode) {
    for (int i = 0; i < editWidgets.size() ; i++) { // First invert selection
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->deselect();
      }
      else {
        editWidgets[i]->select();
      }
    }
    cut();
    paste();
    for (int i = 0; i < editWidgets.size() ; i++) { // Now invert selection again
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->deselect();
      }
      else {
        editWidgets[i]->select();
      }
    }
  }
}

void WidgetLayout::distributeHorizontal()
{
  if (m_editMode) {
    int size = editWidgets.size();
    if (size < 3)
      return;  // do nothing for less than three selected
    int spacing, emptySpace, max = -9999, min = 9999, widgetWidth = 0;
    int num = 0;
    QVector<int> order;
    for (int i = 0; i < size ; i++) { // First check free space
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
  }
}

void WidgetLayout::distributeVertical()
{
  if (m_editMode) {
    int size = editWidgets.size();
    if (size < 3)
      return;  // do nothing for less than three selected
    int spacing, emptySpace, max = -9999, min = 9999, widgetHeight = 0;
    int num = 0;
    QVector<int> order;
    for (int i = 0; i < size ; i++) { // First check free space
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
  }
}

void WidgetLayout::keyPressEvent(QKeyEvent *event)
{
  qDebug() << "WidgetLayout::keyPressEvent --- " << event->key();
//  if (!event->isAutoRepeat() or m_repeatKeys) {
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
//  }
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

//void WidgetLayout::resizeEvent(QResizeEvent * event)
//{
//  qDebug() << "WidgetLayout::resizeEvent " << event->size() << event->oldSize();
//}

void WidgetLayout::widgetChanged(QuteWidget* widget)
{
  if (widget != 0) {
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
  }
  adjustLayoutSize();
}

// void WidgetPanel::updateWidgetText()
// {
//   emit widgetsChanged(widgetsText());
// }

void WidgetLayout::mousePressEvent(QMouseEvent *event)
{
  if (m_editMode && (event->button() & Qt::LeftButton)) {
    this->setFocus(Qt::MouseFocusReason);
    selectionFrame->show();
    startx = event->x() - LAYOUT_X_OFFSET;
    starty = event->y() - LAYOUT_Y_OFFSET;
    selectionFrame->setGeometry(startx, starty, 0,0);
    if (event->button() & Qt::LeftButton) {
      deselectAll();
    }
  }
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
  int width = abs(event->x() - startx - LAYOUT_X_OFFSET);
  int height = abs(event->y() - starty - LAYOUT_Y_OFFSET);
  if (event->buttons() & Qt::LeftButton) {  // Currently dragging selection
    if (event->x() < startx) {
      x = event->x();
      //         width = event->x() - startx;
    }
    if (event->y() < starty) {
      y = event->y();
      //         height = event->y() - starty;
    }
    selectionFrame->setGeometry(x, y, width, height);
    selectionChanged(QRect(x,y,width,height));
  }
//  qDebug() << "WidgetPanel::mouseMoveEvent " << event->x();
  //FIXME these are duplicated now!
  mouseX = event->globalX();
  mouseY = event->globalY();
  mouseRelX = event->x();
  mouseRelY = event->y();
}

void WidgetLayout::mouseReleaseEvent(QMouseEvent *event)
{
  if (event->button() & Qt::LeftButton) {
    selectionFrame->hide();
  }
//  qDebug() << "WidgetPanel::mouseMoveEvent " << event->x();
  if (event->button() == Qt::LeftButton)
    mouseBut1 = 0;
  else if (event->button() == Qt::RightButton)
    mouseBut2 = 0;
  //       if (event->button() & Qt::LeftButton) {
  //         emit deselectAll();
  //       }
  markHistory();
  QWidget::mouseReleaseEvent(event);
}

void WidgetLayout::contextMenuEvent(QContextMenuEvent *event)
{
  createContextMenu(event);
  event->accept();
}

int WidgetLayout::createSlider(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioSlider x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteSlider *widget= new QuteSlider(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setRange(parts[5].toDouble(), parts[6].toDouble());
  widget->setValue(parts[7].toDouble());
  if (parts.size()>8) {
    int i=8;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setChannelName(channelName);
  }
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
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
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setType(parts[5]);
  widget->setResolution(parts[7].toDouble());
  widget->setChannelName(quoteParts[1]);
  if (quoteParts[2] == " left ")
    widget->setAlignment(0);
  else if (quoteParts[2] == " center ")
    widget->setAlignment(1);
  else if (quoteParts[2] == " right ")
    widget->setAlignment(2);
  widget->setFont(quoteParts[3]);
  widget->setFontSize(lastParts[0].toInt());
  widget->setTextColor(QColor(lastParts[1].toDouble()/256.0,
                       lastParts[2].toDouble()/256.0,
                                             lastParts[3].toDouble()/256.0));
  widget->setBgColor(QColor(lastParts[4].toDouble()/256.0,
                     lastParts[5].toDouble()/256.0,
                                           lastParts[6].toDouble()/256.0));
  widget->setBg(lastParts[7] == "background");
  widget->setBorder(lastParts[8] == "border");
  QString labelText = "";
//   int i = 9;
//   while (lastParts.size() > i) {
//     labelText += lastParts[i] + " ";
//     i++;
//   }
//   labelText.chop(1);
  labelText = widgetLine.mid(widgetLine.indexOf("border") + 7);
  widget->setText(labelText);
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
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
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setType(parts[5]);
  widget->setResolution(parts[7].toDouble());
  widget->setChannelName(quoteParts[1]);
  if (quoteParts[2] == " left ")
    widget->setAlignment(0);
  else if (quoteParts[2] == " center ")
    widget->setAlignment(1);
  else if (quoteParts[2] == " right ")
    widget->setAlignment(2);
  widget->setFont(quoteParts[3]);
  widget->setFontSize(lastParts[0].toInt());
  widget->setTextColor(QColor(lastParts[1].toDouble()/256.0,
                       lastParts[2].toDouble()/256.0,
                                             lastParts[3].toDouble()/256.0));
  widget->setBgColor(QColor(lastParts[4].toDouble()/256.0,
                     lastParts[5].toDouble()/256.0,
                                           lastParts[6].toDouble()/256.0));
  widget->setBg(lastParts[7] == "background");
  widget->setBorder(lastParts[8] == "border");
  QString labelText = "";
  int i = 9;
  while (lastParts.size() > i) {
    labelText += lastParts[i] + " ";
    i++;
  }
  labelText.chop(1);
  bool ok;
  widget->setValue(labelText.toDouble(&ok));
  if (!ok)
    widget->setText(labelText);
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
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
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setType(parts[5]);
  widget->setResolution(parts[7].toDouble());
  widget->setChannelName(quoteParts[1]);
  if (quoteParts[2] == " left ")
    widget->setAlignment(0);
  else if (quoteParts[2] == " center ")
    widget->setAlignment(1);
  else if (quoteParts[2] == " right ")
    widget->setAlignment(2);
  widget->setFont(quoteParts[3]);
  widget->setFontSize(lastParts[0].toInt());
  widget->setTextColor(QColor(lastParts[1].toDouble()/256.0,
                       lastParts[2].toDouble()/256.0,
                                             lastParts[3].toDouble()/256.0));
  widget->setBgColor(QColor(lastParts[4].toDouble()/256.0,
                     lastParts[5].toDouble()/256.0,
                                           lastParts[6].toDouble()/256.0));
  widget->setBg(lastParts[7] == "background");
//   widget->setBorder(lastParts[8] == "border");
  QString labelText = "";
  int i = 9;
  while (lastParts.size() > i) {
    labelText += lastParts[i] + " ";
    i++;
  }
  labelText.chop(1);
  widget->setText(labelText);
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
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
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setType(parts[5]);
  widget->setResolution(parts[7].toDouble());
  widget->setChannelName(quoteParts[1]);
  if (quoteParts[2] == " left ")
    widget->setAlignment(0);
  else if (quoteParts[2] == " center ")
    widget->setAlignment(1);
  else if (quoteParts[2] == " right ")
    widget->setAlignment(2);
  widget->setFont(quoteParts[3]);
  widget->setFontSize(lastParts[0].toInt());
  widget->setTextColor(QColor(lastParts[1].toDouble()/256.0,
                       lastParts[2].toDouble()/256.0,
                                             lastParts[3].toDouble()/256.0));
  widget->setBgColor(QColor(lastParts[4].toDouble()/256.0,
                     lastParts[5].toDouble()/256.0,
                                           lastParts[6].toDouble()/256.0));
  widget->setBg(lastParts[7] == "background");
//   widget->setBorder(lastParts[8] == "border");
  QString labelText = "";
  int i = 9;
  while (lastParts.size() > i) {
    labelText += lastParts[i] + " ";
    i++;
  }
  labelText.chop(1);
  widget->setText(labelText);
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
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
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->show();
  m_widgets.append(widget);
  widget->setValue(parts[6].toDouble());  //value produced by button
  widget->setChannelName(quoteParts[1]);
  widget->setText(quoteParts[3]);
  widget->setFilename(quoteParts[5]);
  widget->setType(parts[5]); // setType must come after setFilename so image is loaded
  if (quoteParts.size()>6) {
    quoteParts[6].remove(0,1); //remove initial space
    widget->setEventLine(quoteParts[6]);
  }
  connect(widget, SIGNAL(queueEvent(QString)), this, SLOT(queueEvent(QString)));
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));

  // Play and render require the options from the main application, so must call play from it
  connect(widget, SIGNAL(play()), static_cast<qutecsound *>(parent()), SLOT(play()));
  connect(widget, SIGNAL(render()), static_cast<qutecsound *>(parent()), SLOT(render()));
  connect(widget, SIGNAL(pause()), static_cast<qutecsound *>(parent()), SLOT(pause()));
  connect(widget, SIGNAL(stop()), static_cast<qutecsound *>(parent()), SLOT(stop()));
  connect(widget, SIGNAL(newValue(QPair<QString,QString>)), this, SLOT(newValue(QPair<QString,QString>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));

  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  return 1;
}

int WidgetLayout::createKnob(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioKnob x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteKnob *widget= new QuteKnob(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setRange(parts[5].toDouble(), parts[6].toDouble());
  //TODO set resolution of knob
  widget->setValue(parts[8].toDouble());
  if (parts.size()>9) {
    int i=9;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setChannelName(channelName);
  }
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  return 1;
}

int WidgetLayout::createCheckBox(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioCheckBox x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteCheckBox *widget= new QuteCheckBox(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setValue(parts[5]=="on");
  if (parts.size()>6) {
    int i=6;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setChannelName(channelName);
  }
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  return 1;
}

int WidgetLayout::createMenu(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioMenu x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QStringList quoteParts = widgetLine.split('"');
  QuteComboBox *widget= new QuteComboBox(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setSize(parts[6].toInt());
  widget->setText(quoteParts[1]);
  widget->setValue(parts[5].toDouble()); //setValue must be after setText otherwise ComboBox is empty
  if (quoteParts.size() > 2)
    widget->setChannelName(quoteParts[2].remove(0,1)); //remove initial space from channel name
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  return 1;
}

int WidgetLayout::createMeter(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioMenu x=%i y=%i w=%i h=%i", x,y, width, height);
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
  //TODO is setWidgetLine actually necessary?
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  widget->setColor(QColor(parts[5].toDouble()/256.0,
                       parts[6].toDouble()/256.0,
                                         parts[7].toDouble()/256.0));
  widget->setType(parts2[1]); // Important to set type before setting values since values are inverted for crosshair and point
  widget->setChannelName(quoteParts[1]);
  widget->setValue(quoteParts[2].toDouble());
  widget->setChannel2Name(quoteParts[3]);
  widget->setValue2(parts2[0].toDouble());
  widget->setPointSize(parts2[2].toInt());
  widget->setFadeSpeed(parts2[3].toInt());
  widget->setBehavior(parts2[4]);
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(newValue(QPair<QString,double>)), this, SLOT(newValue(QPair<QString,double>)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  return 1;
}

int WidgetLayout::createConsole(int x, int y, int width, int height, QString widgetLine)
{
//    qDebug("ioListing x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteConsole *widget= new QuteConsole(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  consoleWidgets.append(widget);
  return 1;
}

int WidgetLayout::createGraph(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("ioGraph x=%i y=%i w=%i h=%i", x,y, width, height);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  QuteGraph *widget= new QuteGraph(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  emit registerGraph(widget);
  //Graph widget is always of type "graph" part 5 is discarded
  if (parts.size() > 6)
    widget->setValue(parts[6].toDouble());
  if (parts.size() > 7)
    widget->setZoom(parts[7].toDouble());
  else
    widget->setZoom(1.0);
  if (parts.size()>8) {
    int i = 8;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setChannelName(channelName);
  }
  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  graphWidgets.append(widget);
  return 1;
}

int WidgetLayout::createScope(int x, int y, int width, int height, QString widgetLine)
{
//   qDebug("WidgetPanel::createScope ioGraph x=%i y=%i w=%i h=%i", x,y, width, height);
//   qDebug("%s",widgetLine.toStdString().c_str() );
  QuteScope *widget= new QuteScope(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  emit registerScope(widget);
  QStringList parts = widgetLine.split(QRegExp("[\\{\\}, ]"), QString::SkipEmptyParts);
  if (parts.size() > 5)
    widget->setType(parts[5]);
  if (parts.size() > 6)
    widget->setValue(parts[6].toDouble()); //Value here indicates zoom level
  if (parts.size() > 7) {
    widget->setChannel((int) parts[7].toDouble()); // Channel number to display
  }
  if (parts.size() > 8) {
    int i=8;
    QString channelName = "";
    while (parts.size()>i) {
      channelName += parts[i] + " ";
      i++;
    }
    channelName.chop(1);  //remove last space
    widget->setChannelName(channelName);
  }

  connect(widget, SIGNAL(widgetChanged(QuteWidget *)), this, SLOT(widgetChanged(QuteWidget *)));
  connect(widget, SIGNAL(deleteThisWidget(QuteWidget *)), this, SLOT(deleteWidget(QuteWidget *)));
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  m_widgets.append(widget);
  widget->show();
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  scopeWidgets.append(widget);
  return 1;
}

int WidgetLayout::createDummy(int x, int y, int width, int height, QString widgetLine)
{
  QuteWidget *widget= new QuteDummy(this);
  widget->setWidgetLine(widgetLine);
  widget->setWidgetGeometry(x,y,width, height);
  connect(widget, SIGNAL(propertiesAccepted()), this, SLOT(markHistory()));
  widget->show();
  m_widgets.append(widget);
  if (m_editMode) {
    createEditFrame(widget);
    editWidgets.last()->select();
  }
  adjustLayoutSize();
  setWidgetToolTip(widget, m_tooltips);
  return 1;
}

void WidgetLayout::setBackground(bool bg, QColor bgColor)
{
  if (bg) {
    this->setPalette(QPalette(bgColor));
    this->setBackgroundRole(QPalette::Window);
    this->setAutoFillBackground(true);
  }
  else { // =="nobackground"
    this->setPalette(QPalette());
    this->setAutoFillBackground(false);
  }
}

void WidgetLayout::setModified(bool mod)
{
  qDebug() << "WidgetLayout::setModified";
  m_modified = mod;
  emit changed();
}

void WidgetLayout::clearHistory()
{
  m_history.clear();
  m_history << "";
  m_historyIndex = 0;
}

void WidgetLayout::loadPreset(int num)
{
  WidgetPreset p = presets[num];
  if (num >= 0 && num < presets.size()) {
    for (int i = 0; i < m_widgets.size(); i++) {
      QString id = m_widgets[i]->getUuid();
      if (p.idIndex(id) > -1) {
        m_widgets[i]->setValue(p.getValue(id));
        m_widgets[i]->setValue2(p.getValue2(id));
        m_widgets[i]->setValue(p.getStringValue(id));
      }
    }
  }
  else {
    qDebug() << "WidgetPanel::loadPreset invalid preset number";
  }
}

void WidgetLayout::savePreset(int num, QString name)
{
  if (num >= 0 && num < presets.size()) {
    presets[num].clear();
  }
  else if (num < 0) {
    WidgetPreset p;
    presets.append(p);
    num = presets.size() - 1;
  }
  else {
    qDebug() << "WidgetPanel::savePreset invalid preset number";
    return;
  }
  for (int i = 0; i < m_widgets.size(); i++) {
    QString id = m_widgets[i]->getUuid();
    WidgetPreset p;
    p.setName(name);
    p.setValue(id, m_widgets[i]->getValue());
    p.setValue2(id, m_widgets[i]->getValue2());
    p.setStringValue(id, m_widgets[i]->getStringValue());
    presets.append(p);
  }
}

void WidgetLayout::setPresetName(int num, QString name)
{
  if (num >= 0 && num < presets.size()) {
    presets[num].setName(name);
  }
}

QString WidgetLayout::getPresetsXmlText()
{
  qDebug() << "WidgetPanel::getPresetsXmlText() not implemented yet";
  return QString();
}

void WidgetLayout::copy()
{
  qDebug() << "WidgetLayout::copy()";
  QString text;
  if (m_editMode) {
    for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
      if (editWidgets[i]->isSelected()) {
        text += m_widgets[i]->getWidgetLine() + "\n";
      }
    }
    m_clipboard = text;
    emit setWidgetClipboardSignal(m_clipboard);
  }
}

void WidgetLayout::cut()
{
  qDebug() << "WidgetLayout::cut()";
  if (m_editMode) {
    WidgetLayout::copy();
    for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
      if (editWidgets[i]->isSelected()) {
        deleteWidget(m_widgets[i]);
      }
    }
    markHistory();
  }
}

void WidgetLayout::paste()
{
  qDebug() << "WidgetLayout::paste()";
  if (m_editMode) {
    deselectAll();
    QStringList lines = m_clipboard.split("\n");
    foreach (QString line, lines) {
      newWidget(line);
      editWidgets.last()->select();
    }
  }
  markHistory();
}

void WidgetLayout::setEditMode(bool active)
{
  if (active) {
    foreach (FrameWidget *widget, editWidgets) {
      delete widget;
    }
    editWidgets.clear();
    foreach (QuteWidget * widget, m_widgets) {
      createEditFrame(widget);
    }
  }
  else {
    foreach (QFrame* frame, editWidgets) {
      delete(frame);
    }
    editWidgets.clear();
  }
  m_editMode = active;
}

//void WidgetLayout::toggleEditMode()
//{
//  m_editMode = !m_editMode;
//  if (m_editMode) {
//    foreach (FrameWidget *widget, editWidgets) {
//      delete widget;
//    }
//    editWidgets.clear();
//    foreach (QuteWidget * widget, m_widgets) {
//      createEditFrame(widget);
//    }
//  }
//  else {
//    foreach (QFrame* frame, editWidgets) {
//      delete(frame);
//    }
//    editWidgets.clear();
//  }
//}

void WidgetLayout::createEditFrame(QuteWidget* widget)
{
  FrameWidget * frame = new FrameWidget(this);
  QPalette palette(QColor(Qt::red),QColor(Qt::red));
  palette.setColor(QPalette::WindowText, QColor(Qt::red));
  frame->setWidget(widget);
  frame->setPalette(palette);
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
  QString text = getMacWidgetsText();
  if (m_history.isEmpty()) {
    m_history << "";
    m_historyIndex = 0;
  }
  if (m_history[m_historyIndex] != text) {
    if (! m_history[m_historyIndex].isEmpty())
      m_historyIndex++;
    if (m_historyIndex >= QUTE_MAX_UNDO) {
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
  widgetChanged(widget);
}

void WidgetLayout::newValue(QPair<QString, double> channelValue)
{
//   qDebug("WidgetPanel::newValue");
  if (!channelValue.first.isEmpty()) {
    valueMutex.lock();
    if(newValues.contains(channelValue.first)) {
      newValues[channelValue.first] = channelValue.second;
    }
    else {
      newValues.insert(channelValue.first, channelValue.second);
    }
    valueMutex.unlock();
  }
//   widgetChanged();
}

void WidgetLayout::newValue(QPair<QString, QString> channelValue)
{
  if (!channelValue.first.isEmpty()) {
    stringValueMutex.lock();
    if(newStringValues.contains(channelValue.first)) {
      newStringValues[channelValue.first] = channelValue.second;
    }
    else {
      newStringValues.insert(channelValue.first, channelValue.second);
    }
    stringValueMutex.unlock();
  }
}

void WidgetLayout::processNewValues()
{
  // Apply values received
//   qDebug("WidgetPanel::processNewValues");
  QList<QString> channelNames;
  valueMutex.lock();
  channelNames = newValues.keys();
  valueMutex.unlock();
  foreach(QString name, channelNames) {
    for (int i = 0; i < m_widgets.size(); i++){
      if (m_widgets[i]->getChannelName() == name) {
        m_widgets[i]->setValue(newValues.value(name));
      }
      if (m_widgets[i]->getChannel2Name() == name) {
        m_widgets[i]->setValue2(newValues.value(name));
      }
      if (m_trackMouse) {
        QString ch1name = m_widgets[i]->getChannelName();
        if (ch1name == "_MouseX") {
          m_widgets[i]->setValue(getMouseX());
        }
        else if (ch1name == "_MouseY") {
          m_widgets[i]->setValue(getMouseY());
        }
        else if (ch1name == "_MouseRelX") {
          m_widgets[i]->setValue(getMouseRelX());
        }
        else if (ch1name == "_MouseRelY") {
          m_widgets[i]->setValue(getMouseRelY());
        }
        else if (ch1name == "_MouseBut1") {
          m_widgets[i]->setValue(getMouseBut1());
        }
        else if (ch1name == "_MouseBut2") {
          m_widgets[i]->setValue(getMouseBut2());
        }
        QString ch2name = m_widgets[i]->getChannel2Name();
        if (ch2name == "_MouseX") {
          m_widgets[i]->setValue2(getMouseX());
        }
        else if (ch2name == "_MouseY") {
          m_widgets[i]->setValue2(getMouseY());
        }
        else if (ch2name == "_MouseRelX") {
          m_widgets[i]->setValue2(getMouseRelX());
        }
        else if (ch2name == "_MouseRelY") {
          m_widgets[i]->setValue2(getMouseRelY());
        }
        else if (ch2name == "_MouseBut1") {
          m_widgets[i]->setValue2(getMouseBut1());
        }
        else if (ch2name == "_MouseBut2") {
          m_widgets[i]->setValue2(getMouseBut2());
        }
      }
    }
  }
  valueMutex.lock();
  newValues.clear();
  valueMutex.unlock();
  stringValueMutex.lock();
  channelNames = newStringValues.keys();
  // Now set string values
  stringValueMutex.unlock();
  foreach(QString name, channelNames) {
    for (int i = 0; i < m_widgets.size(); i++){
      if (m_widgets[i]->getChannelName() == name) {
        m_widgets[i]->setValue(newStringValues.value(name));
      }
    }
  }
  stringValueMutex.lock();
  newStringValues.clear();
  stringValueMutex.unlock();
}

void WidgetLayout::queueEvent(QString eventLine)
{
  // FIXME connect this!!
  emit queueEventSignal(eventLine);
}

void WidgetLayout::paste(QPoint /*pos*/)
{
}

void WidgetLayout::duplicate()
{
   qDebug("WidgetLayout::duplicate()");
  if (m_editMode) {
    int size = editWidgets.size();
    for (int i = 0; i < size ; i++) {
      if (editWidgets[i]->isSelected()) {
        editWidgets[i]->deselect();
        newWidget(m_widgets[i]->getWidgetLine(), true);
        editWidgets.last()->select();
      }
    }
  }
  markHistory();
}

void WidgetLayout::deleteSelected()
{
//   qDebug("WidgetLayout::deleteSelected()");
  for (int i = editWidgets.size() - 1; i >= 0 ; i--) {
    if (editWidgets[i]->isSelected()) {
      deleteWidget(m_widgets[i]);
    }
  }
  markHistory();
}

void WidgetLayout::undo()
{
  qDebug("WidgetLayout::undo()");
  if (m_historyIndex > 0) {
    (m_historyIndex)--;
    qDebug() << "WidgetLayout::undo() " << m_historyIndex << "...." << m_history[m_historyIndex];
    loadWidgets(m_history[m_historyIndex]);
  }
}

void WidgetLayout::redo()
{
  qDebug("WidgetLayout::redo()");
  if (m_historyIndex < m_history.size() - 1) {
    m_historyIndex++;
    loadWidgets(m_history[m_historyIndex]);
  }
}

void WidgetLayout::killCurve(WINDAT *windat)
{
  qDebug() << "WidgetLayout::killCurve()";
  Curve *curve = getCurveById(windat->windid);
  // FIXME free memory for this graph
}

void WidgetLayout::updateData()
{
  if (closing == 1) {
    closing = 0;
    return;
  }
  while (!newCurveBuffer.isEmpty() && curveBuffer.size() < 32) {
    Curve * curve = newCurveBuffer.pop();
//    qDebug() << "WidgetLayout::updateData() curve " << curve->get_caption();
    newCurve(curve);
  }
//  if (curveBuffer.size() > 32) {
//    qDebug("qutecsound::dispatchQueues() WARNING: curve update buffer too large!");
//    curveBuffer.resize(32);
//  }
  for (int i = 0; i < curveBuffer.size(); i++) {
    WINDAT * windat = curveBuffer[i];
    Curve *curve = getCurveById((uintptr_t) windat->windid);
    if (curve != 0) {
//      qDebug() << "qutecsound::updateData() " <<windat->caption << "-" <<  curve->get_caption();
      curve->set_size(windat->npts);      // number of points
      curve->set_data(windat->fdata);
      curve->set_caption(QString(windat->caption)); // title of curve
      //     curve->set_polarity(windat->polarity); // polarity
      curve->set_max(windat->max);        // curve max
      curve->set_min(windat->min);        // curve min
      curve->set_absmax(windat->absmax);     // abs max of above
      //     curve->set_y_scale(windat->y_scale);    // Y axis scaling factor
      setCurveData(curve);
    }
    curveBuffer.remove(curveBuffer.indexOf(windat));
  }
  for (int i = 0; i < scopeWidgets.size(); i++) {
    scopeWidgets[i]->updateData();
  }
  QTimer::singleShot(30, this, SLOT(updateData()));
}
