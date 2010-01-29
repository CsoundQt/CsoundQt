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

#include "documentpage.h"
#include "documentview.h"
#include "csoundengine.h"
#include "liveeventframe.h"
#include "eventsheet.h"
//#include "qutecsound.h"
#include "opentryparser.h"
#include "types.h"
#include "dotgenerator.h"
#include "highlighter.h"
#include "widgetlayout.h"
#include "console.h"
#include "curve.h"

#include "cwindow.h"
#include <csound.hpp>  // TODO These two are necessary for the WINDAT struct. Can they be moved?

DocumentPage::DocumentPage(QWidget *parent, OpEntryParser *opcodeTree):
    QObject(parent), m_opcodeTree(opcodeTree)
{
  fileName = "";
  companionFile = "";
//  macGUI = "";
  askForFile = true;
  readOnly = false;
  errorMarked = false;

  //FIXME this options must be set from QuteCsound configuratio!
  saveLiveEvents = true;
  saveChanges = true;

  bufferSize = 4096;
  recBuffer = (MYFLT *) calloc(bufferSize, sizeof(MYFLT));

  m_view = new DocumentView(parent);
  m_csEngine = new CsoundEngine();
  m_console = new ConsoleWidget(parent);
  //FIXME show console
  m_console->hide();
  m_widgetLayout = new WidgetLayout(parent);
  //FIXME show widgets
  m_widgetLayout->hide();

  //FIXME this is possibly not connected, but is it still necessary?
  connect(m_view, SIGNAL(contentsChanged()), this, SLOT(changed()));
//   connect(this, SIGNAL(cursorPositionChanged()), this, SLOT(moved()));

  queueTimer = new QTimer(this);
  queueTimer->setSingleShot(true);
  connect(queueTimer, SIGNAL(timeout()), this, SLOT(dispatchQueues()));
  refreshTime = QCS_QUEUETIMER_DEFAULT_TIME;  // Eventually allow this to be changed
  dispatchQueues(); //start queue dispatcher


  // FIXME connect(csEngine, SIGNAL(clearMessageQueue()), this, SLOT(clearMessageQueue()));
  // FIXME connect(layout, SIGNAL(changed()), this, SLOT(changed()));

}

DocumentPage::~DocumentPage()
{
  qDebug() << "DocumentPage::~DocumentPage()";
  //TODO is all this being deleted?
  for (int i = 0; i < m_liveFrames.size(); i++) {
    delete m_liveFrames[i];  // These widgets have the order not to delete on close
    m_liveFrames.remove(i);
  }
  delete recBuffer;
  delete m_view;
  delete m_csEngine;
}

void DocumentPage::keyPressEvent(QKeyEvent *event)
{
  qDebug() << "DocumentPage::keyPressEvent " << event->key();
  // TODO is this function necessary any more?
  if (event == QKeySequence::Cut)
  {
    emit doCut();
    return;
  }
  if (event == QKeySequence::Copy)
  {
    emit doCopy();
    return;
  }
  if (event == QKeySequence::Paste)
  {
    emit doPaste();
    return;
  }
  //FIXME is it necessary to propagate events further? Possibly
//  QTextEdit::keyPressEvent(event);
}

//void DocumentPage::closeEvent(QCloseEvent *event)
//{
//  qDebug() << "DocumentPage::closeEvent";
//  QTextEdit::closeEvent(event);
//}

int DocumentPage::setTextString(QString text, bool autoCreateMacCsoundSections)
{
  if (text.contains("<MacOptions>") and text.contains("</MacOptions>")) {
    QString options = text.right(text.size()-text.indexOf("<MacOptions>"));
    options.resize(options.indexOf("</MacOptions>") + 13);
    setMacOptionsText(options);
//     qDebug("<MacOptions> present. \n%s", options.toStdString().c_str());
    if (text.indexOf("</MacOptions>") + 13 < text.size() and text[text.indexOf("</MacOptions>") + 13] == '\n')
      text.remove(text.indexOf("</MacOptions>") + 13, 1); //remove final line break
    if (text.indexOf("<MacOptions>") > 0 and text[text.indexOf("<MacOptions>") - 1] == '\n')
      text.remove(text.indexOf("<MacOptions>") - 1, 1); //remove initial line break
    text.remove(text.indexOf("<MacOptions>"), options.size());
//     qDebug("<MacOptions> present. %s", getMacOptions("WindowBounds").toStdString().c_str());
  }
  else {
    if (autoCreateMacCsoundSections) {
      QString defaultMacOptions = "<MacOptions>\nVersion: 3\nRender: Real\nAsk: Yes\nFunctions: ioObject\nListing: Window\nWindowBounds: 72 179 400 200\nCurrentView: io\nIOViewEdit: On\nOptions:\n</MacOptions>\n";
      setMacOptionsText(defaultMacOptions);
    }
    else
      setMacOptionsText("");
  }
  if (text.contains("<MacPresets>") and text.contains("</MacPresets>")) {
    macPresets = text.right(text.size()-text.indexOf("<MacPresets>"));
    macPresets.resize(macPresets.indexOf("</MacPresets>") + 12);
    if (text.indexOf("</MacPresets>") + 12 < text.size() and text[text.indexOf("</MacPresets>") + 12] == '\n')
      text.remove(text.indexOf("</MacPresets>") + 12, 1); //remove final line break
    if (text.indexOf("<MacPresets>") > 0 and text[text.indexOf("<MacPresets>") - 1] == '\n')
      text.remove(text.indexOf("<MacPresets>") - 1, 1); //remove initial line break
    text.remove(text.indexOf("<MacPresets>"), macPresets.size());
    qDebug("<MacPresets> present.");
  }
  else {
    macPresets = "";
  }
  if (text.contains("<MacGUI>") and text.contains("</MacGUI>")) {
  // FIXME put back {
//    macGUI = text.right(text.size()-text.indexOf("<MacGUI>"));
//    macGUI.resize(macGUI.indexOf("</MacGUI>") + 9);
//    if (text.indexOf("</MacGUI>") + 9 < text.size() and text[text.indexOf("</MacGUI>") + 9] == '\n')
//      text.remove(text.indexOf("</MacGUI>") + 9, 1); //remove final line break
//    if (text.indexOf("<MacGUI>") > 0 and text[text.indexOf("<MacGUI>") - 1] == '\n')
//      text.remove(text.indexOf("<MacGUI>") - 1, 1); //remove initial line break
//    text.remove(text.indexOf("<MacGUI>"), macGUI.size());
//     qDebug("<MacGUI> present.");
  }
  else {
  // FIXME put back
//    if (autoCreateMacCsoundSections) {
//      macGUI = "\n<MacGUI>\nioView nobackground {59352, 11885, 65535}\nioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1\n</MacGUI>\n";
//    }
//    else {
//      macGUI = "";
//    }
  }
  // This here is for compatibility with MacCsound
  QString optionsText = getMacOptions("Options:");
  if (optionsText.contains(" -o")) {
    QString outFile = optionsText.mid(optionsText.indexOf(" -o") + 1);
    int index = outFile.indexOf(" -");
    if (index > 0) {
      outFile = outFile.left(index);
    }
    optionsText.remove(outFile);
    setMacOption("Options:", optionsText);
    index = text.indexOf("<CsOptions>");
    int endindex = text.indexOf("</CsOptions>");
    if (index >= 0 and endindex > index) {
      text.remove(index, endindex - index);
      text.insert(index, "<CsOptions>\n" + outFile);
    }
    else {
      index = text.indexOf("<CsInstruments>");
      text.insert(index, "<CsOptions>\n" + outFile + "\n</CsOptions>\n");
    }
  }
  if (!text.contains("<CsoundSynthesizer>") &&
      !text.contains("</CsoundSynthesizer>") ) {//TODO this check is very flaky....
    view()->setFullText(text);
    //FIXME is it necessary to set modified here?
//    view()->document()->setModified(true);
    return 0;  // Don't add live event panel if not a csd file.
  }
  // Load Live Event Panels ------------------------
  while (text.contains("<EventPanel") and text.contains("</EventPanel>")) {
    QString liveEventsText = text.mid(text.indexOf("<EventPanel "),
                                      text.indexOf("</EventPanel>") - text.indexOf("<EventPanel ") + 13);
//    qDebug() << "DocumentPage::setTextString   " << liveEventsText;
    LiveEventFrame *frame = createLiveEventFrame();
    QString scoText = liveEventsText.mid(liveEventsText.indexOf(">") + 1,
                                         liveEventsText.indexOf("</EventPanel>") - liveEventsText.indexOf(">") - 1 );
    frame->getSheet()->setRowCount(1);
    frame->getSheet()->setColumnCount(6);
    frame->setFromText(scoText);
    if (liveEventsText.contains("name=\"")) {
      int index = liveEventsText.indexOf("name=\"") + 6;
      QString name = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      frame->setName(name);
    }
    if (liveEventsText.contains("tempo=\"")) {
      int index = liveEventsText.indexOf("tempo=\"") + 7;
      QString tempostr = liveEventsText.mid(index,
                                            liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      double tempo = tempostr.toDouble(&ok);
      if (ok)
        frame->setTempo(tempo);
    }
    if (liveEventsText.contains("loop=\"")) {
      int index = liveEventsText.indexOf("loop=\"") + 6;
      QString loopstr = liveEventsText.mid(index,
                                           liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      double loop = loopstr.toDouble(&ok);
      if (ok)
        frame->setLoopLength(loop);
    }
    int posx, posy, width, height;
    if (liveEventsText.contains("x=\"")) {
      int index = liveEventsText.indexOf("x=\"") + 3;
      QString xstr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      posx = xstr.toInt(&ok);
      if (!ok)
        posx = frame->x();
    }
    if (liveEventsText.contains("y=\"")) {
      int index = liveEventsText.indexOf("y=\"") + 3;
      QString ystr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      posy = ystr.toInt(&ok);
      if (!ok)
        posy = frame->y();
    }
    if (liveEventsText.contains("width=\"")) {
      int index = liveEventsText.indexOf("width=\"") + 7;
      QString wstr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      width = wstr.toInt(&ok);
      if (!ok)
        width = frame->width();
    }
    if (liveEventsText.contains("height=\"")) {
      int index = liveEventsText.indexOf("height=\"") + 8;
      QString hstr = liveEventsText.mid(index,
                                        liveEventsText.indexOf("\"", index) - index );
      bool ok = false;
      height = hstr.toInt(&ok);
      if (!ok)
        height = frame->height();
    }
    frame->move(posx, posy);
    frame->resize(width, height);
    text.remove(liveEventsText);
  }
  if (m_liveFrames.size() == 0) {
    LiveEventFrame *e = createLiveEventFrame();
    e->setFromText(QString()); // Must set blank for undo history point
  }

  view()->setFullText(text);  //FIXME is this necessary as it is above, or remove from above?
  // FIXME is it necessary to set modified here?
//  document()->setModified(true);
  return 0;
}

QString DocumentPage::getFullText()
{
  QString fullText;
  fullText = view()->getFullText();
//  if (!fullText.endsWith("\n"))
//    fullText += "\n";
  if (fileName.endsWith(".csd",Qt::CaseInsensitive) or fileName == "") {
    fullText += getMacOptionsText() + "\n" + getMacWidgetsText() + "\n";
    fullText += getMacPresetsText() + "\n";
    QString liveEventsText = "";
    if (saveLiveEvents) { // Only add live events sections if file is a csd file
      for (int i = 0; i < m_liveFrames.size(); i++) {
        QString panel = "<EventPanel name=\"";
        panel += m_liveFrames[i]->getName() + "\" tempo=\"";
        panel += QString::number(m_liveFrames[i]->getTempo(), 'f', 8) + "\" loop=\"";
        panel += QString::number(m_liveFrames[i]->getLoopLength(), 'f', 8) + "\" name=\"";
        panel += m_liveFrames[i]->getName() + "\" x=\"";
        panel += QString::number(m_liveFrames[i]->x()) + "\" y=\"";
        panel += QString::number(m_liveFrames[i]->y()) + "\" width=\"";
        panel += QString::number(m_liveFrames[i]->width()) + "\" height=\"";
        panel += QString::number(m_liveFrames[i]->height()) + "\">";
        panel += m_liveFrames[i]->getPlainText();
        panel += "</EventPanel>";
        liveEventsText += panel;
      }
      fullText += liveEventsText;
    }
  }
  return fullText;
}

QString DocumentPage::getBasicText()
{
  qDebug() << "DocumentPage::getBasicText() will crash to avoid data loss!";

//  return QString();
}

QString DocumentPage::getOptionsText()
{
  return view()->getOptionsText();
}

QString DocumentPage::getDotText()
{
  if (fileName.endsWith("sco")) {
    qDebug() << "DocumentPage::getDotText(): No dot for sco files";
    return QString();
  }
  QString orcText = getFullText();
  if (!fileName.endsWith("orc")) { //asume csd
    if (orcText.contains("<CsInstruments>") && orcText.contains("</CsInstruments>")) {
      orcText = orcText.mid(orcText.indexOf("<CsInstruments>") + 15,
                            orcText.indexOf("</CsInstruments>") - orcText.indexOf("<CsInstruments>") - 15);
    }
  }
  DotGenerator dot(fileName, orcText, m_opcodeTree);
  return dot.getDotText();
}

QString DocumentPage::getMacWidgetsText()
{
  //FIXME put back
//  return macGUI;
  return m_widgetLayout->getMacWidgetsText();
}

QString DocumentPage::getMacPresetsText()
{
  return macPresets;
}

QString DocumentPage::getMacOptionsText()
{
  return macOptions.join("\n");
}

QString DocumentPage::getMacOptions(QString option)
{
  if (!option.endsWith(":"))
    option += ":";
  if (!option.endsWith(" "))
    option += " ";
  int index = macOptions.indexOf(QRegExp(option + ".*"));
  if (index < 0) {
    qDebug("DocumentPage::getMacOptions() Option %s not found!", option.toStdString().c_str());
    return QString("");
  }
  return macOptions[index].mid(option.size());
}

QRect DocumentPage::getWidgetPanelGeometry()
{
  int index = macOptions.indexOf(QRegExp("WindowBounds: .*"));
  if (index < 0) {
//     qDebug ("DocumentPage::getWidgetPanelGeometry() no Geometry!");
    return QRect();
  }
  QString line = macOptions[index];
  QStringList values = line.split(" ");
  values.removeFirst();  //remove property name
  return QRect(values[0].toInt(),
               values[1].toInt(),
               values[2].toInt(),
               values[3].toInt());
}

QString DocumentPage::getFilePath()
{
  return fileName.left(fileName.lastIndexOf("/"));
}

QStringList DocumentPage::getScheduledEvents(unsigned long ksmps)
{
  QStringList events;
  // Called once after every Csound control pass
  for (int i = 0; i < m_liveFrames.size(); i++) {
    m_liveFrames[i]->getEvents(ksmps, &events);
  }
//  m_ksmpscount = ksmpscount;
  return events;
}

void DocumentPage::setModified(bool mod)
{
  // FIXME live frame modification should also affect here
  //FIXME is this needed? m_view->setModified(mod);
  //FIXME is this needed? m_widgetLayout->setModified(mod);
}

bool DocumentPage::isModified()
{
  if (m_view->isModified())
    return true;
  if (m_widgetLayout->isModified())
    return true;
  return false;
}

void DocumentPage::updateCsLadspaText()
{
  QString text = "<csLADSPA>\nName=";
  text += fileName.mid(fileName.lastIndexOf("/") + 1) + "\n";
  text += "Maker=QuteCsound\n";
  text += "UniqueID=69873\n";  // FIXME generate a proper id
  text += "Copyright=none\n";
  text += m_widgetLayout->getCsladspaLines();
  text += "</csLADSPA>";
  view()->setLadspaText(text);
}

void DocumentPage::copy()
{
  qDebug() << "DocumentPage::copy() not implemented!";
}

void DocumentPage::cut()
{
  qDebug() << "DocumentPage::cut() not implemented!";
}

void DocumentPage::paste()
{
  qDebug() << "DocumentPage::paste() not implemented!";
}

void DocumentPage::undo()
{
  qDebug() << "DocumentPage::undo() not implemented!";
}

void DocumentPage::redo()
{
  qDebug() << "DocumentPage::redo() not implemented!";
}

DocumentView * DocumentPage::view()
{
  return m_view;
}

void DocumentPage::setConsoleBufferSize(int size)
{
  m_csEngine->setConsoleBufferSize(size);
}

void DocumentPage::setWidgetEnabled(bool enabled)
{
  m_widgetLayout->setEnabled(enabled);
}

void DocumentPage::showLiveEventFrames(bool visible)
{
//  qDebug() << "DocumentPage::showLiveEventFrames  " << visible << (int) this;
  for (int i = 0; i < m_liveFrames.size(); i++) {
    if (visible) {
      m_liveFrames[i]->show();
    }
    else {
      m_liveFrames[i]->hide();
    }
  }
}

int DocumentPage::play()
{
  qDebug() << "DocumentPage::play() not implemented!";
  view()->unmarkErrorLines();  // Clear error lines when running
  // Determine if API should be used
  bool useAPI = true;
  // FIXME put back this check for FLTK
//  if (m_options->terminalFLTK) { // if "FLpanel" is found in csd run from terminal
//    if (view()->getBasicText().contains("FLpanel"))
//      useAPI = false;
//  }
  //Set directory of current file
  QString runFileName1, runFileName2;
  QTemporaryFile tempFile, csdFile, csdFile2; // TODO add support for orc/sco pairs
  if (fileName.startsWith(":/examples/")) { // TODO is there a proper check to see if example was modified?
    QString tmpFileName = QDir::tempPath();
    if (!tmpFileName.endsWith("/") and !tmpFileName.endsWith("\\")) {
      tmpFileName += QDir::separator();
    }
    tmpFileName += QString("QuteCsoundExample-XXXXXXXX.csd");
    tempFile.setFileTemplate(tmpFileName);
    if (!tempFile.open()) {
      qDebug() << "Error creating temporary file " << tmpFileName;
      return -2;
    }
    QString csdText = m_view->getBasicText();
    runFileName1 = tempFile.fileName();
    tempFile.write(csdText.toAscii());
    tempFile.flush();
  } /*if (fileName.startsWith(":/examples/"))*/
  else if (!saveChanges) {
    QString tmpFileName = QDir::tempPath();
    if (!tmpFileName.endsWith("/") and !tmpFileName.endsWith("\\")) {
      tmpFileName += QDir::separator();
    }
    if (fileName.endsWith(".csd",Qt::CaseInsensitive)) {
      tmpFileName += QString("csound-tmpXXXXXXXX.csd");
      csdFile.setFileTemplate(tmpFileName);
      if (!csdFile.open()) {
        qDebug() << "Error creating temporary file " << tmpFileName;
        return -2;
      }
      QString csdText = m_view->getBasicText();
      runFileName1 = csdFile.fileName();
      csdFile.write(csdText.toAscii());
      csdFile.flush();
    }
  }

  runFileName2 = companionFile;
  m_console->reset();
  m_widgetLayout->flush();
  m_widgetLayout->clearGraphs();
  m_csEngine->setFiles(runFileName1, runFileName2);

  return m_csEngine->play();
}

void DocumentPage::pause()
{
  qDebug() << "DocumentPage::pause() not implemented!";
  m_csEngine->pause();
}

void DocumentPage::stop()
{
  qDebug() << "DocumentPage::stop() not implemented!";
  m_csEngine->stop();
}

void DocumentPage::render()
{
  qDebug() << "DocumentPage::render() not implemented!";
  //  m_csEngine->runCsound(m_options->useAPI);  // render use of API depends on this preference
}

void DocumentPage::runInTerm()
{
  m_csEngine->runInTerm();
}

void DocumentPage::record(int format)
{
  if (fileName.startsWith(":/")) {
    QMessageBox::critical(static_cast<QWidget *>(parent()),
                          tr("QuteCsound"),
                          tr("You must save the examples to use Record."),
                          QMessageBox::Ok);
    //FIXME connect rec act
//    recAct->setChecked(false);
    return;
  }
  int number = 0;
  QString recName = fileName + "-000.wav";
  while (QFile::exists(recName)) {
    number++;
    recName = fileName + "-";
    if (number < 10)
      recName += "0";
    if (number < 100)
      recName += "0";
    recName += QString::number(number) + ".wav";
  }
  m_csEngine->startRecording(format, recName);

  // FIXME setup stopping of recording!
  // FIXME connect this so that the current audio file for external editor, etc is set
  emit setCurrentAudioFile(recName);
}

void DocumentPage::setMacWidgetsText(QString widgetText)
{
//   qDebug() << "DocumentPage::setMacWidgetsText: ";
  //FIXME put back
//  macGUI = widgetText;
//   document()->setModified(true);
}

void DocumentPage::setMacOptionsText(QString text)
{
  macOptions = text.split('\n');
}

void DocumentPage::setMacOption(QString option, QString newValue)
{
  if (!option.endsWith(":"))
    option += ":";
  if (!option.endsWith(" "))
    option += " ";
  int index = macOptions.indexOf(QRegExp(option + ".*"));
  if (index < 0) {
    qDebug("DocumentPage::setMacOption() Option not found!");
    return;
  }
  macOptions[index] = option + newValue;
  qDebug("DocumentPage::setMacOption() %s", macOptions[index].toStdString().c_str());
}

void DocumentPage::setWidgetPanelPosition(QPoint position)
{
  int index = macOptions.indexOf(QRegExp("WindowBounds: .*"));
  if (index < 0) {
    qDebug ("DocumentPage::getWidgetPanelGeometry() no Geometry!");
    return;
  }
  QStringList parts = macOptions[index].split(" ");
  parts.removeFirst();
  QString newline = "WindowBounds: " + QString::number(position.x()) + " ";
  newline += QString::number(position.y()) + " ";
  newline += parts[2] + " " + parts[3];
  macOptions[index] = newline;
//   qDebug("DocumentPage::setWidgetPanelPosition() %i %i", position.x(), position.y());
}

void DocumentPage::setWidgetPanelSize(QSize size)
{
  int index = macOptions.indexOf(QRegExp("WindowBounds: .*"));
  if (index < 0) {
    qDebug ("DocumentPage::getWidgetPanelGeometry() no Geometry!");
    return;
  }
  QStringList parts = macOptions[index].split(" ");
  parts.removeFirst();
  QString newline = "WindowBounds: ";
  newline += parts[0] + " " + parts[1] + " ";
  newline += QString::number(size.width()) + " ";
  newline += QString::number(size.height());
  macOptions[index] = newline;
//   qDebug("DocumentPage::setWidgetPanelSize() %i %i", size.width(), size.height());
}

void DocumentPage::newLiveEventFrame(QString text)
{
  LiveEventFrame *e = createLiveEventFrame(text);
  e->show();  //Assume that since slot was called ust be visible
}

LiveEventFrame * DocumentPage::createLiveEventFrame(QString text)
{
  qDebug() << "DocumentPage::newLiveEventFrame()";
  // TODO delete these frames, for proper cleanup
  // TODO remove from QVector when they are deleted individually
  LiveEventFrame *e = new LiveEventFrame("Live Event", 0, Qt::Window);  //FIXME is it OK to have no parent?
  e->setAttribute(Qt::WA_DeleteOnClose, false);
//  e->show();

  if (!text.isEmpty()) {
    e->setFromText(text);
  }
  m_liveFrames.append(e);
  connect(e, SIGNAL(closed()), this, SLOT(liveEventFrameClosed()));
  connect(e, SIGNAL(newFrameSignal(QString)), this, SLOT(newLiveEventFrame(QString)));
  connect(e, SIGNAL(deleteFrameSignal(LiveEventFrame *)), this, SLOT(deleteLiveEventFrame(LiveEventFrame *)));
  emit registerLiveEvent(dynamic_cast<QWidget *>(e));
  return e;
}

void DocumentPage::deleteLiveEventFrame(LiveEventFrame *frame)
{
  qDebug() << "deleteLiveEventFrame(LiveEventFrame *frame)";
  qApp->processEvents();
  int index = m_liveFrames.indexOf(frame);
  if (index >= 0) {
    frame->forceDestroy();
    m_liveFrames.remove(index);
  }
  else {
    qDebug() << "DocumentPage::deleteLiveEventFrame frame not found";
  }
}

void DocumentPage::changed()
{
  view()->unmarkErrorLines();
  emit currentTextUpdated();
}

void DocumentPage::liveEventFrameClosed()
{
//  qDebug() << "DocumentPage::liveEventFrameClosed()";
  LiveEventFrame *e = dynamic_cast<LiveEventFrame *>(QObject::sender());
//  if (e != 0) { // This shouldn't really be necessary but just in case
  bool shown = false;
  for (int i = 0; i < m_liveFrames.size(); i++) {
    if (m_liveFrames[i]->isVisible()
      && m_liveFrames[i] != e)  // frame that called has not been called yet
      shown = true;
  }
  emit liveEventsVisible(shown);
//  }
}

void DocumentPage::queueEvent(QString eventLine, int delay)
{
//   qDebug("WidgetPanel::queueEvent %s", eventLine.toStdString().c_str());
  m_csEngine->queueEvent(eventLine, delay);  //TODO  implement passing of timestamp
}
