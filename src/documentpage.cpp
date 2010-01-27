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

DocumentPage::DocumentPage(QWidget *parent, OpEntryParser *opcodeTree):
    QObject(parent), m_opcodeTree(opcodeTree)
{
  fileName = "";
  companionFile = "";
//  macGUI = "";
  askForFile = true;
  readOnly = false;
  errorMarked = false;
  saveLiveEvents = true;

  bufferSize = 4096;
  recBuffer = (MYFLT *) calloc(bufferSize, sizeof(MYFLT));

  m_view = new DocumentView();
  m_csEngine = new CsoundEngine();

  connect(document(), SIGNAL(contentsChanged()), this, SLOT(changed()));
//   connect(this, SIGNAL(cursorPositionChanged()), this, SLOT(moved()));

  queueTimer = new QTimer(this);
  queueTimer->setSingleShot(true);
  connect(queueTimer, SIGNAL(timeout()), this, SLOT(dispatchQueues()));
  refreshTime = QCS_QUEUETIMER_DEFAULT_TIME;  // Eventually allow this to be changed
  dispatchQueues(); //start queue dispatcher

  connect(m_console, SIGNAL(keyPressed(QString)),
          this, SLOT(keyPressForCsound(QString)));
  connect(m_console, SIGNAL(keyReleased(QString)),
          this, SLOT(keyReleaseForCsound(QString)));

  // FIXME connect(csEngine, SIGNAL(clearMessageQueue()), this, SLOT(clearMessageQueue()));
  // FIXME connect(layout, SIGNAL(changed()), this, SLOT(changed()));

}

DocumentPage::~DocumentPage()
{
  qDebug() << "DocumentPage::~DocumentPage()";
  //TODO is this being deleted?
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
  return QTextEdit::keyPressEvent(event);
}

void DocumentPage::contextMenuEvent(QContextMenuEvent *event)
{
  QMenu *menu = createStandardContextMenu();
  menu->addSeparator();
  QMenu *opcodeMenu = menu->addMenu("Opcodes");
  QMenu *mainMenu = 0;
  QMenu *subMenu;
  QString currentMain = "";
  for (int i = 0; i < m_opcodeTree->getCategoryCount(); i++) {
    QString category = m_opcodeTree->getCategory(i);
    QStringList categorySplit = category.split(":");
    if (!categorySplit.isEmpty() && categorySplit[0] != currentMain) {
      mainMenu = opcodeMenu->addMenu(categorySplit[0]);
      currentMain = categorySplit[0];
    }
    if (categorySplit.size() < 2) {
      subMenu = mainMenu;
    }
    else {
      subMenu = mainMenu->addMenu(categorySplit[1]);
    }
    foreach(Opcode opcode, m_opcodeTree->getOpcodeList(i)) {
      QAction *action = subMenu->addAction(opcode.opcodeName, this, SLOT(opcodeFromMenu()));
      action->setData(opcode.outArgs + opcode.opcodeName + opcode.inArgs);
    }
  }
  menu->exec(event->globalPos());
  delete menu;
}

void DocumentPage::closeEvent(QCloseEvent *event)
{
  qDebug() << "DocumentPage::closeEvent";
  for (int i = 0; i < m_liveFrames.size(); i++) {
    delete m_liveFrames[i];  // These widgets have the order not to delete on close
    m_liveFrames.remove(i);
  }
  QTextEdit::closeEvent(event);
}

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
  if (!text.contains("<CsoundSynthesizer>")) {//TODO this check is very flaky....
    setPlainText(text);
    document()->setModified(true);
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
  setPlainText(text);
  document()->setModified(true);
  return 0;
}

QString DocumentPage::getFullText()
{
  QString fullText;
  fullText = document()->toPlainText();
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
  qDebug() << "DocumentPage::getBasicText() will crash to avoid data loss!"

//  return QString();
}

QString DocumentPage::getOptionsText()
{
  QString text = document()->toPlainText();
  int index = text.indexOf("<CsOptions>") + 11;
  int end = text.indexOf("</CsOptions>") - 1 ;
  if (index < 0 or end < 0)
    return QString();
  text = text.mid(index, end-index);
  return text;
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
  return layoutWidget->getMacWidgetsText();
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

void DocumentPage::markErrorLines(QList<int> lines)
{
  QTextCharFormat errorFormat;
  errorFormat.setBackground(QBrush(QColor(255, 182, 193)));
  QTextCursor cur = textCursor();
  cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
  int lineCount = 1;
  foreach(int line, lines) {
    // Csound reports the line numbers incorrectly... but only on my machine apparently...
    while (lineCount < line) {
      lineCount++;
//       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
      cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
    }
    cur.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
    cur.mergeCharFormat(errorFormat);
    setTextCursor(cur);
    cur.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
  }
  setTextCursor(cur);
  errorMarked = true;
}

void DocumentPage::unmarkErrorLines()
{
  if (!errorMarked)
    return;
  int position = verticalScrollBar()->value();
  QTextCursor currentCursor = textCursor();
  errorMarked = false;
//   qDebug("DocumentPage::unmarkErrorLines()");
  selectAll();
  QTextCursor cur = textCursor();
  QTextCharFormat format = cur.blockCharFormat();
  format.clearBackground();
  cur.setCharFormat(format);
  setTextCursor(cur);  //sets format
  setTextCursor(currentCursor); //returns cursor to initial position
  verticalScrollBar()->setValue(position); //return document display to initial position
}

void DocumentPage::updateCsladspaText(QString text)
{
  QTextCursor cursor = textCursor();
  QTextDocument *doc = document();
  moveCursor(QTextCursor::Start);
  if (find("<csLADSPA>") and find("</csLADSPA>")) {
    QString curText = doc->toPlainText();
    int index = curText.indexOf("<csLADSPA>");
    curText.remove(index, curText.indexOf("</csLADSPA>") + 11 - index);
    curText.insert(index, text);
    doc->setPlainText(curText);
  }
  else { //csLADSPA section not present, or incomplete
    find("<CsoundSynthesizer>"); //cursor moves there
    moveCursor(QTextCursor::EndOfLine);
    insertPlainText(QString("\n") + text + QString("\n"));
  }
  moveCursor(QTextCursor::Start);
}

QString DocumentPage::getFilePath()
{
  return fileName.left(fileName.lastIndexOf("/"));
}

int DocumentPage::currentLine()
{
  QTextCursor cursor = textCursor();
//   cursor.clearSelection();
//   cursor.setPosition(0,QTextCursor::KeepAnchor);
//   QString section = cursor.selectedText();
//   qDebug() << section;
//   return section.count('\n');
  return cursor.blockNumber() + 1;
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
  m_view->setModified(mod);
  m_widgetLayout->setModified(mod);
}

bool DocumentPage::isModified()
{
  if (m_view->isModified())
    return true;
  if (m_widgetLayout->isModified())
    return true;
  return false;
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

void DocumentPage::keyPressForCsound(QString key)
{
//   qDebug() << "keyPressForCsound " << key;
  keyMutex.lock(); // Is this lock necessary?
  keyPressBuffer << key;
  keyMutex.unlock();
}

void DocumentPage::keyReleaseForCsound(QString key)
{
//   qDebug() << "keyReleaseForCsound " << key;
  keyMutex.lock(); // Is this lock necessary?
  keyReleaseBuffer << key;
  keyMutex.unlock();
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

void DocumentPage::play()
{
  qDebug() << "DocumentPage::play() not implemented!";
  unmarkErrorLines();  // Clear error lines when running
}

void DocumentPage::pause()
{
    qDebug() << "DocumentPage::pause() not implemented!";
}

void DocumentPage::stop()
{
    qDebug() << "DocumentPage::stop() not implemented!";
}

void DocumentPage::render()
{
    qDebug() << "DocumentPage::render() not implemented!";
}

void DocumentPage::record()
{
  if (fileName.startsWith(":/")) {
    QMessageBox::critical(this,
                          tr("QuteCsound"),
                          tr("You must save the examples to use Record."),
                          QMessageBox::Ok);
    //FIXME connect rec act
//    recAct->setChecked(false);
    return;
  }
  if (!runAct->isChecked()) {
    //FIXME run act must be checked according to the status of the current document when it changes
//    runAct->setChecked(true);
    play();
  }
  if (recAct->isChecked()) {
#ifdef USE_LIBSNDFILE
    int format=SF_FORMAT_WAV;
    switch (m_options->sampleFormat) {
      case 0:
        format |= SF_FORMAT_PCM_16;
        break;
      case 1:
        format |= SF_FORMAT_PCM_24;
        break;
      case 2:
        format |= SF_FORMAT_FLOAT;
        break;
    }
 //  const int format=SF_FORMAT_WAV | SF_FORMAT_FLOAT;
    const int channels=ud->numChnls;
    const int sampleRate=ud->sampleRate;
    int number = 0;
    QString fileName = documentPages[curPage]->fileName + "-000.wav";
    while (QFile::exists(fileName)) {
      number++;
      fileName = documentPages[curPage]->fileName + "-";
      if (number < 10)
        fileName += "0";
      if (number < 100)
        fileName += "0";
      fileName += QString::number(number) + ".wav";
    }
    currentAudioFile = fileName;
    qDebug("start recording: %s", fileName.toStdString().c_str());
    outfile = new SndfileHandle(fileName.toStdString().c_str(), SFM_WRITE, format, channels, sampleRate);
    // clip instead of wrap when converting floats to ints
    outfile->command(SFC_SET_CLIPPING, NULL, SF_TRUE);
    samplesWritten = 0;

    QTimer::singleShot(20, this, SLOT(recordBuffer()));
#else
  QMessageBox::warning(this, tr("QuteCsound"),
                       tr("This version of QuteCsound has been compiled\nwithout Record support!"),
                       QMessageBox::Ok);
#endif
  }
}

void DocumentPage::recordBuffer()
{
#ifdef USE_LIBSNDFILE
  if (recAct->isChecked()) {
    if (audioOutputBuffer.copyAvailableBuffer(recBuffer, bufferSize)) {
      int samps = outfile->write(recBuffer, bufferSize);
      samplesWritten += samps;
    }
    else {
//       qDebug("qutecsound::recordBuffer() : Empty Buffer!");
    }
    QTimer::singleShot(20, this, SLOT(recordBuffer()));
  }
  else { //Stop recording
    delete outfile;
    qDebug("closed file: %s\nWritten %li samples", currentAudioFile.toStdString().c_str(), samplesWritten);
  }
#endif
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

void DocumentPage::jumpToLine(int line)
{
  int lineCount = 1;
  QTextCursor cur = textCursor();
  cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
  while (lineCount < line) {
    lineCount++;
    //       cur.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor);
    cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor);
  }
  moveCursor(QTextCursor::End); // go to end to make sure line is put at the top of text
  setTextCursor(cur);
}

void DocumentPage::opcodeFromMenu()
{
  QAction *action = (QAction *) QObject::sender();
  QTextCursor cursor = textCursor();
  QString text = action->data().toString();
  cursor.insertText(text);
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
  LiveEventFrame *e = new LiveEventFrame("Live Event", this, Qt::Window);
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
  unmarkErrorLines();
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

void DocumentPage::dispatchQueues()
{
//   qDebug("qutecsound::dispatchQueues()");
  int counter = 0;
  widgetPanel->processNewValues();
  if (ud && ud->PERF_STATUS == 1) {
    while ((m_options->consoleBufferSize <= 0 || counter++ < m_options->consoleBufferSize) && ud->PERF_STATUS == 1) {
      messageMutex.lock();
      if (messageQueue.isEmpty()) {
        messageMutex.unlock();
        break;
      }
      QString msg = messageQueue.takeFirst();
      messageMutex.unlock();
      m_console->appendMessage(msg);
      widgetPanel->appendMessage(msg);
      qApp->processEvents(); //FIXME Is this needed here to avoid display problems in the console?
      m_console->scrollToEnd();
      widgetPanel->refreshConsoles();  // Scroll to end of text all console widgets
    }
    messageMutex.lock();
    if (!messageQueue.isEmpty() && m_options->consoleBufferSize > 0 && counter >= m_options->consoleBufferSize) {
      messageQueue.clear();
      messageQueue << "\nQUTECSOUND: Message buffer overflow. Messages discarded!\n";
    }
    messageMutex.unlock();
    //   QList<QString> channels = outValueQueue.keys();
    //   foreach (QString channel, channels) {
    //     widgetPanel->setValue(channel, outValueQueue[channel]);
    //   }
    //   outValueQueue.clear();

    stringValueMutex.lock();
    QStringList channels = outStringQueue.keys();
    for  (int i = 0; i < channels.size(); i++) {
      widgetPanel->setValue(channels[i], outStringQueue[channels[i]]);
    }
    outStringQueue.clear();
    stringValueMutex.unlock();
    processEventQueue(ud);
    while (!newCurveBuffer.isEmpty()) {
      Curve * curve = newCurveBuffer.pop();
  // //     qDebug("qutecsound::dispatchQueues() %i-%s", index, curve->get_caption().toStdString().c_str());
        widgetPanel->newCurve(curve);
    }
    if (curveBuffer.size() > 32) {
      qDebug("qutecsound::dispatchQueues() WARNING: curve update buffer too large!");
      curveBuffer.resize(32);
    }
    foreach (WINDAT * windat, curveBuffer){
      Curve *curve = widgetPanel->getCurveById(windat->windid);
      if (curve != 0) {
  //       qDebug("qutecsound::dispatchQueues() %s -- %s",windat->caption, curve->get_caption().toStdString().c_str());
        curve->set_size(windat->npts);      // number of points
        curve->set_data(windat->fdata);
        curve->set_caption(QString(windat->caption)); // title of curve
    //     curve->set_polarity(windat->polarity); // polarity
        curve->set_max(windat->max);        // curve max
        curve->set_min(windat->min);        // curve min
        curve->set_absmax(windat->absmax);     // abs max of above
    //     curve->set_y_scale(windat->y_scale);    // Y axis scaling factor
        widgetPanel->setCurveData(curve);
      }
      curveBuffer.remove(curveBuffer.indexOf(windat));
    }
    qApp->processEvents();
    if (m_options->thread) {
      if (perfThread->GetStatus() != 0) {
        stop();
      }
    }
  }
  queueTimer->start(refreshTime); //will launch this function again later
}

void DocumentPage::queueMessage(QString message)
{
  messageMutex.lock();
  messageQueue << message;
  messageMutex.unlock();
}

void DocumentPage::clearMessageQueue()
{
  messageMutex.lock();
  messageQueue.clear();
  messageMutex.unlock();
}
