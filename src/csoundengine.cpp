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

#include "csoundengine.h"
#include "widgetlayout.h"
#include "console.h"

CsoundEngine::CsoundEngine()
{
  // Initialize user data pointer passed to Csound
  ud = (CsoundUserData *)malloc(sizeof(CsoundUserData));
  ud->PERF_STATUS = 0;
  ud->cs = this;
  pFields = (MYFLT *) calloc(EVENTS_MAX_PFIELDS, sizeof(MYFLT)); // Maximum number of p-fields for events

  //FIXME set widget layout ud->wl =
  m_recording = false;
  ud->csound = NULL;
  int init = csoundInitialize(0,0,0);
  if (init < 0) {
    qDebug("CsoundEngine::CsoundEngine() Error initializing Csound!\nQutecsound will probably crash if you try to run Csound.");
  }
#ifndef QUTECSOUND_DESTROY_CSOUND
  // Create only once
  csound=csoundCreate(0);
#endif

  ud->perfThread = 0;

  eventQueue.resize(QUTECSOUND_MAX_EVENTS);
  eventTimeStamps.resize(QUTECSOUND_MAX_EVENTS);
  eventQueueSize = 0;

  ud->mouseValues.resize(6); // For _MouseX _MouseY _MouseRelX _MouseRelY _MouseBut1 and _MouseBut2 channels
}

CsoundEngine::~CsoundEngine()
{
  // FIXME make sure this runs!
  qDebug() << "CsoundEngine::~CsoundEngine() ";
  foreach (QString tempFile, tempScriptFiles) {
    QDir().remove(tempFile);
  }
#ifndef QUTECSOUND_DESTROY_CSOUND
  csoundDestroy(csound);
#endif
  free(ud);
  free(pFields);
}

void CsoundEngine::messageCallbackNoThread(CSOUND *csound,
                                          int /*attr*/,
                                          const char *fmt,
                                          va_list args)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  QString msg;
  msg = msg.vsprintf(fmt, args);
  for (int i = 0; i < ud->cs->consoles.size(); i++) {
    ud->cs->consoles[i]->appendMessage(msg);
    ud->cs->consoles[i]->scrollToEnd();
  }
}

void CsoundEngine::messageCallbackThread(CSOUND *csound,
                                          int /*attr*/,
                                          const char *fmt,
                                          va_list args)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  QString msg;
  msg = msg.vsprintf(fmt, args);
  ud->cs->queueMessage(msg);
}

void CsoundEngine::outputValueCallbackThread (CSOUND *csound,
                                     const char *channelName,
                                     MYFLT value)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  if (ud->perfThread->isRunning()) {
    QString name = QString(channelName);
    ud->cs->perfMutex.lock();
    if (name.startsWith('$')) {
      QString channelName = name;
      channelName.chop(name.size() - (int) value + 1);
      QString sValue = name;
      sValue = sValue.right(name.size() - (int) value);
      channelName.remove(0,1);
      ud->cs->queueOutString(channelName, sValue);
    }
    else {
      ud->cs->queueOutValue(name, value);
    }
    ud->cs->perfMutex.unlock();
  }
}

void CsoundEngine::inputValueCallbackThread (CSOUND *csound,
                                     const char *channelName,
                                     MYFLT *value)
{
  // from qutecsound to Csound
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  if (ud->perfThread->isRunning()) {
    QString name = QString(channelName);
    ud->cs->perfMutex.lock();
    if (name.startsWith('$')) { // channel is a string channel
      int index = ud->channelNames.indexOf(name.mid(1));
      char *string = (char *) value;
      if (index>=0) {
        strcpy(string, ud->stringValues[index].toStdString().c_str());
      }
      else {
        string[0] = '\0'; //empty c string
      }
    }
    else {  // Not a string channel
      int index = ud->channelNames.indexOf(name);
      if (index>=0)
        *value = (MYFLT) ud->values[index];
      else {
        *value = 0;
      }
      //FIXME check if mouse tracking is active
      if (name == "_MouseX") {
        *value = (MYFLT) ud->mouseValues[0];
      }
      else if (name == "_MouseY") {
        *value = (MYFLT) ud->mouseValues[1];
      }
      else if(name == "_MouseRelX") {
        *value = (MYFLT) ud->mouseValues[2];
      }
      else if(name == "_MouseRelY") {
        *value = (MYFLT) ud->mouseValues[3];
      }
      else if(name == "_MouseBut1") {
        *value = (MYFLT) ud->mouseValues[4];
      }
      else if(name == "_MouseBut2") {
        *value = (MYFLT) ud->mouseValues[5];
      }
    }
    ud->cs->perfMutex.unlock();
  }
}

void CsoundEngine::outputValueCallback (CSOUND *csound,
                                     const char *channelName,
                                     MYFLT value)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  if (ud->PERF_STATUS == 1) {
    QString name = QString(channelName);
    ud->cs->perfMutex.lock();
    if (name.startsWith('$')) {
      QString channelName = name;
      channelName.chop(name.size() - (int) value + 1);
      QString sValue = name;
      sValue = sValue.right(name.size() - (int) value);
      channelName.remove(0,1);
      ud->cs->queueOutString(channelName, sValue);
    }
    else {
      ud->cs->queueOutValue(name, value);
    }
    ud->cs->perfMutex.unlock();
  }
}

void CsoundEngine::inputValueCallback (CSOUND *csound,
                                     const char *channelName,
                                     MYFLT *value)
{
  // from qutecsound to Csound
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  if (ud->PERF_STATUS == 1) {
    QString name = QString(channelName);
    ud->cs->perfMutex.lock();
    if (name.startsWith('$')) { // channel is a string channel
      int index = ud->channelNames.indexOf(name.mid(1));
      char *string = (char *) value;
      if (index>=0) {
        strcpy(string, ud->stringValues[index].toStdString().c_str());
      }
      else {
        string[0] = '\0'; //empty c string
      }
    }
    else {  // Not a string channel
      int index = ud->channelNames.indexOf(name);
      if (index>=0)
        *value = (MYFLT) ud->values[index];
      else {
        *value = 0;
      }
      //FIXME check if mouse tracking is active
      if (name == "_MouseX") {
        *value = (MYFLT) ud->mouseValues[0];
      }
      else if (name == "_MouseY") {
        *value = (MYFLT) ud->mouseValues[1];
      }
      else if(name == "_MouseRelX") {
        *value = (MYFLT) ud->mouseValues[2];
      }
      else if(name == "_MouseRelY") {
        *value = (MYFLT) ud->mouseValues[3];
      }
      else if(name == "_MouseBut1") {
        *value = (MYFLT) ud->mouseValues[4];
      }
      else if(name == "_MouseBut2") {
        *value = (MYFLT) ud->mouseValues[5];
      }
    }
    ud->cs->perfMutex.unlock();
  }
}

void CsoundEngine::makeGraphCallback(CSOUND *csound, WINDAT *windat, const char *name)
{
//   qDebug("qutecsound::makeGraph()");
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
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
                  windat->danflag);
  curve->set_id((uintptr_t) curve);
  ud->wl->newCurve(curve);
  windat->windid = (uintptr_t) curve;
//   qDebug("qutecsound::makeGraphCallback %i", windat->windid);
}

void CsoundEngine::drawGraphCallback(CSOUND *csound, WINDAT *windat)
{
  CsoundUserData *udata = (CsoundUserData *) csoundGetHostData(csound);
  // FIXME what is this callback for????
//   qDebug("qutecsound::drawGraph()");
//  udata->qcs->updateCurve(windat);
}

void CsoundEngine::killGraphCallback(CSOUND *csound, WINDAT *windat)
{
//   udata->qcs->killCurve(windat);
  qDebug("qutecsound::killGraph()");
}

int CsoundEngine::exitGraphCallback(CSOUND *csound)
{
//  qDebug("qutecsound::exitGraphCallback()");
  CsoundUserData *udata = (CsoundUserData *) csoundGetHostData(csound);
  return udata->wl->killCurves(csound);
}

int CsoundEngine::keyEventCallback(void *userData,
                                 void *p,
                                 unsigned int type)
{
  if (type != CSOUND_CALLBACK_KBD_EVENT)
    return 1;
  CsoundUserData *ud = (CsoundUserData *) userData;
  WidgetLayout *wl = (WidgetLayout *) ud->wl;
  int *value = (int *) p;
  int key = wl->popKeyPressEvent();
  if (key >= 0) {
    *value = key;
//     qDebug() << "Pressed: " << key;
  }
  else {
    key = ud->cs->popKeyReleaseEvent();
    if (key >= 0) {
      *value = key;
//       qDebug() << "Released: " << key;
    }
  }
  return 0;
}

// void CsoundEngine::ioCallback (CSOUND *csound,
//                              const char *channelName,
//                              MYFLT *value,
//                              int channelType
//                             )
// {
//   qDebug() << "qutecsound::ioCallback";
//   if (channelType & CSOUND_INPUT_CHANNEL) { // is Input Channel
//     if (channelType & CSOUND_CONTROL_CHANNEL) {
//       inputValueCallback(csound, channelName, value);
//     }
//     else if (channelType & CSOUND_AUDIO_CHANNEL) {
//     }
//     else if (channelType & CSOUND_STRING_CHANNEL) {
//     }
//   }
//   else if (channelType & CSOUND_OUTPUT_CHANNEL) { // Is output channel
//     if (channelType & CSOUND_CONTROL_CHANNEL) {
//       outputValueCallback(csound, channelName, *value);
//     }
//     else if (channelType & CSOUND_AUDIO_CHANNEL) {
//     }
//     else if (channelType & CSOUND_STRING_CHANNEL) {
//     }
//   }
// }

void CsoundEngine::csThread(void *data)
{
  CsoundUserData* udata = (CsoundUserData*)data;
  udata->outputBuffer = csoundGetSpout(udata->csound);
  for (int i = 0; i < udata->outputBufferSize*udata->numChnls; i++) {
    udata->audioOutputBuffer.put(udata->outputBuffer[i]/ udata->zerodBFS);
  }
  udata->wl->getValues(&udata->channelNames,
                       &udata->values,
                       &udata->stringValues);
  udata->wl->getMouseValues(&udata->mouseValues);
  //FIXME put back usage of invalue/outvalue
//  if (!udata->qcs->m_options->useInvalue) {
//    writeWidgetValues(udata);
//    readWidgetValues(udata);
//  }
  (udata->ksmpscount)++;
}

void CsoundEngine::readWidgetValues(CsoundUserData *ud)
{
  MYFLT* pvalue;
//   CsoundChannelListEntry **lst;
//   CsoundChannelListEntry *chan;
//   int num = csoundListChannels(ud->csound, lst);
//   for (int i = 0; i < num; i++) {
//     chan = lst[i];
//     if (chan) {  //Not sure why this check is needed here....
//       if (chan->type & (CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL)) {
//         if(csoundGetChannelPtr(ud->csound, &pvalue, chan->name, 0) == 0) {
//           *pvalue = (MYFLT) ud->qcs->values[i];
//         }
//       }
//       else if (chan->type & (CSOUND_INPUT_CHANNEL | CSOUND_STRING_CHANNEL)) {
//         if(csoundGetChannelPtr(ud->csound, &pvalue, chan->name, 0) == 0) {
//           char *string = (char *) pvalue;
//           strcpy(string, ud->qcs->stringValues[i].toStdString().c_str());
//         }
//       }
//     }
//   }
//   csoundDeleteChannelList(ud->csound, *lst);

  for (int i = 0; i < ud->channelNames.size(); i++) {
    if(csoundGetChannelPtr(ud->csound, &pvalue, ud->channelNames[i].toStdString().c_str(),
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->values[i];
    }
    if(csoundGetChannelPtr(ud->csound, &pvalue, ud->channelNames[i].toStdString().c_str(),
       CSOUND_INPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
      char *string = (char *) pvalue;
      strcpy(string, ud->stringValues[i].toStdString().c_str());
    }
  }
  //FIXME check if mouse tracking is active
  if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseX",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->mouseValues[0];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseY",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->mouseValues[1];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseRelX",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->mouseValues[2];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseRelY",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->mouseValues[3];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseBut1",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->mouseValues[4];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseBut2",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->mouseValues[5];
  }
}

void CsoundEngine::writeWidgetValues(CsoundUserData *ud)
{
//   qDebug("qutecsound::writeWidgetValues");
   MYFLT* pvalue;
   for (int i = 0; i < ud->channelNames.size(); i++) {
     if (ud->channelNames[i] != "") {
       if(csoundGetChannelPtr(ud->csound, &pvalue, ud->channelNames[i].toStdString().c_str(),
          CSOUND_OUTPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
            ud->wl->setValue(i,*pvalue);
       }
       else if(csoundGetChannelPtr(ud->csound, &pvalue, ud->channelNames[i].toStdString().c_str(),
         CSOUND_OUTPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
         ud->wl->setValue(i,QString((char *)pvalue));
       }
     }
   }
}



void CsoundEngine::registerConsole(ConsoleWidget *c)
{
  //FIXME register consoles as they are created
  consoles.append(c);

  connect(c, SIGNAL(keyPressed(QString)),
          this, SLOT(keyPressForCsound(QString)));
  connect(c, SIGNAL(keyReleased(QString)),
          this, SLOT(keyReleaseForCsound(QString)));
}

void CsoundEngine::unregisterConsole(ConsoleWidget *c)
{
  //FIXME unregister consoles as they are destroyed
  int index = consoles.indexOf(c);
  if (index >= 0 )
    consoles.remove(index);
}

void CsoundEngine::setConsoleBufferSize(int size)
{
  m_consoleBufferSize = size;
}

void CsoundEngine::keyPressForCsound(QString key)
{
//   qDebug() << "keyPressForCsound " << key;
  keyMutex.lock(); // Is this lock necessary?
  keyPressBuffer << key;
  keyMutex.unlock();
}

void CsoundEngine::keyReleaseForCsound(QString key)
{
//   qDebug() << "keyReleaseForCsound " << key;
  keyMutex.lock(); // Is this lock necessary?
  keyReleaseBuffer << key;
  keyMutex.unlock();
}

int CsoundEngine::popKeyPressEvent()
{
  keyMutex.lock();
  int value = -1;
  if (!keyPressBuffer.isEmpty()) {
    value = (int) keyPressBuffer.takeFirst()[0].toAscii();
  }
  keyMutex.unlock();
  return value;
}

int CsoundEngine::popKeyReleaseEvent()
{
  keyMutex.lock();
  int value = -1;
  if (!keyReleaseBuffer.isEmpty()) {
    value = (int) keyReleaseBuffer.takeFirst()[0].toAscii() + 0x10000;
  }
  keyMutex.unlock();
  return value;
}

void CsoundEngine::processEventQueue()
{
  // This function should only be called when Csound is running
  while (eventQueueSize > 0) {
    eventQueueSize--;
    eventQueue[eventQueueSize];
    char type = eventQueue[eventQueueSize][0].unicode();
    // FIXME this should process both events from the widget panel and the live event panels!
    QStringList eventElements = eventQueue[eventQueueSize].remove(0,1).split(" ",QString::SkipEmptyParts);
    qDebug("type %c line: %s", type, eventQueue[eventQueueSize].toStdString().c_str());
    // eventElements.size() should never be larger than EVENTS_MAX_PFIELDS
    for (int j = 0; j < eventElements.size(); j++) {
      pFields[j] = (MYFLT) eventElements[j].toDouble();
    }
    if (ud->perfThread != 0) {
      //ScoreEvent is not working
      ud->perfThread->ScoreEvent(0, type, eventElements.size(), pFields);
//       ud->qcs->perfThread->InputMessage(ud->qcs->widgetPanel->eventQueue[ud->qcs->widgetPanel->eventQueueSize].remove(0,1).data());
//       perfThread->lock();
//       csoundScoreEvent(ud->csound,type ,ud->qcs->pFields, eventElements.size());
//       perfThread->unlock();
    }
    else {
      csoundScoreEvent(ud->csound, type, pFields, eventElements.size());
    }
  }
}

void CsoundEngine::queueOutValue(QString channelName, double value)
{
  ud->wl->newValue(QPair<QString, double>(channelName, value));
}

// void qutecsound::queueInValue(QString channelName, double value)
// {
//   inValueQueue.insert(channelName, value);
// }

void CsoundEngine::queueOutString(QString channelName, QString value)
{
//   qDebug() << "qutecsound::queueOutString";
  ud->wl->newValue(QPair<QString, QString>(channelName, value));
}


void CsoundEngine::play()
{
  if (!ud->perfThread->isRunning()) {
    runCsound(true);
  }
  else {
    ud->perfThread->Play();
  }
}

void CsoundEngine::stop()
{
  stopCsound();
}

void CsoundEngine::pause()
{
  if (ud->perfThread->isRunning())
   ud->perfThread->Pause();
}

void CsoundEngine::runInTerm()
{
  runCsound(false);
}

void CsoundEngine::startRecording(int sampleformat, QString fileName)
{
  if (isRunning()) {
    //FIXME run act must be checked according to the status of the current document when it changes
//    runAct->setChecked(true);
    play();
  }
  const int channels=ud->numChnls;
  const int sampleRate=ud->sampleRate;
  int format = SF_FORMAT_WAV;
  switch (sampleformat) {
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
  qDebug("start recording: %s", fileName.toStdString().c_str());
  outfile = new SndfileHandle(fileName.toStdString().c_str(), SFM_WRITE, format, channels, sampleRate);
  // clip instead of wrap when converting floats to ints
  outfile->command(SFC_SET_CLIPPING, NULL, SF_TRUE);
  samplesWritten = 0;
  m_recording = true;

  QTimer::singleShot(20, this, SLOT(recordBuffer()));
}

void CsoundEngine::stopRecording()
{
  m_recording = false;  // Will be processed on next record buffer
}

void CsoundEngine::queueEvent(QString eventLine, int delay)
{
//   qDebug("CsoundEngine::queueEvent %s", eventLine.toStdString().c_str());
  if (eventQueueSize < QUTECSOUND_MAX_EVENTS) {
    eventMutex.lock();
    eventQueue[eventQueueSize] = eventLine;
    eventQueueSize++;
    eventMutex.unlock();
  }
  else
    qDebug("Warning: event queue full, event not processed");
}

void CsoundEngine::runCsound(bool useAPI)
{
  if ((m_options->thread && ud->perfThread->isRunning() ) ||
           (!m_options->thread && ud->PERF_STATUS == 1)) { //If running, stop
    stop();
    return;
  }
  if (documentPages[curPage]->fileName.isEmpty()) {
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("This file has not been saved\nPlease select name and location."));
    if (!saveAs()) {
      runAct->setChecked(false);
      return;
    }
  }
  else if (documentPages[curPage]->document()->isModified()) {
    if (m_options->saveChanges)
      if (!save()) {
        runAct->setChecked(false);
        return;
      }
  }
  //Set directory of current file
  m_options->csdPath = "";
  if (documentPages[curPage]->fileName.contains('/')) {
    m_options->csdPath =
        documentPages[curPage]->fileName.left(documentPages[curPage]->fileName.lastIndexOf('/'));
    QDir::setCurrent(m_options->csdPath);
  }
  QString fileName, fileName2;
  fileName = documentPages[curPage]->fileName;
  if (!fileName.endsWith(".csd",Qt::CaseInsensitive)) {
    if (documentPages[curPage]->askForFile)
      getCompanionFileName();
    if (fileName.endsWith(".sco",Qt::CaseInsensitive)) {
      //Must switch filename order when open file is a sco file
      fileName2 = fileName;
      fileName = documentPages[curPage]->companionFile;
    }
    else
      fileName2 = documentPages[curPage]->companionFile;
  }

  if (useAPI) {
#ifdef MACOSX_PRE_SNOW
//Remember menu bar to set it after FLTK grabs it
    menuBarHandle = GetMenuBar();
#endif
    m_console->clear();
    widgetPanel->flush();
    widgetPanel->clearGraphs();
    eventQueueSize = 0; //Flush events gathered while idle
    //   outValueQueue.clear();
//    inValueQueue.clear();
//    outStringQueue.clear();
    emit clearMessageQueueSignal();
    audioOutputBuffer.allZero();
    QTemporaryFile tempFile;
    if (fileName.startsWith(":/examples/")) {
      QString tmpFileName = QDir::tempPath();
      if (!tmpFileName.endsWith("/") and !tmpFileName.endsWith("\\")) {
        tmpFileName += QDir::separator();
      }
      tmpFileName += QString("QuteCsoundExample-XXXXXXXX.csd");
      tempFile.setFileTemplate(tmpFileName);
      if (!tempFile.open()) {
        QMessageBox::critical(this,
                              tr("QuteCsound"),
                                tr("Error creating temporary file."),
                                    QMessageBox::Ok);
        runAct->setChecked(false);
        return;
      }
      QString csdText = textEdit->document()->toPlainText();
      fileName = tempFile.fileName();
      tempFile.write(csdText.toAscii());
      tempFile.flush();
    }
    QTemporaryFile csdFile, csdFile2; // TODO add support for orc/sco pairs
    if (!m_options->saveChanges) {
      QString tmpFileName = QDir::tempPath();
      if (!tmpFileName.endsWith("/") and !tmpFileName.endsWith("\\")) {
        tmpFileName += QDir::separator();
      }
      if (documentPages[curPage]->fileName.endsWith(".csd",Qt::CaseInsensitive)) {
        tmpFileName += QString("csound-tmpXXXXXXXX.csd");
        csdFile.setFileTemplate(tmpFileName);
        if (!csdFile.open()) {
          QMessageBox::critical(this,
                                tr("QuteCsound"),
                                tr("Error creating temporary file."),
                                QMessageBox::Ok);
          runAct->setChecked(false);
          return;
        }
        QString csdText = textEdit->document()->toPlainText();
        fileName = csdFile.fileName();
        csdFile.write(csdText.toAscii());
        csdFile.flush();
      }
    }
    char **argv;
    argv = (char **) calloc(33, sizeof(char*));
    // TODO use: PUBLIC int csoundSetGlobalEnv(const char *name, const char *value);
    int argc = m_options->generateCmdLine(argv, realtime, fileName, fileName2);
#ifdef QUTECSOUND_DESTROY_CSOUND
    csound=csoundCreate(0);
#endif

    // Message Callbacks must be set before compile, otherwise some information is missed
    if (m_options->thread) {
      csoundSetMessageCallback(csound, &qutecsound::messageCallback_Thread);
    }
    else {
      csoundSetMessageCallback(csound, &qutecsound::messageCallback_NoThread);
    }
//    QString oldOpcodeDir = "";
    if (m_options->opcodedirActive) {
      // csoundGetEnv must be called after Compile or Precompile,
      // But I need to set OPCODEDIR before compile....
//      char *name = 0;
//      csoundGetEnv(csound,name);
//      oldOpcodeDir = QString(name);
//      qDebug() << oldOpcodeDir;
      csoundSetGlobalEnv("OPCODEDIR", m_options->opcodedir.toLocal8Bit());
    }
    csoundReset(csound);
    csoundSetHostData(csound, (void *) ud);
    csoundPreCompile(csound);  //Need to run PreCompile to create the FLTK_Flags global variable

    int variable = csoundCreateGlobalVariable(csound, "FLTK_Flags", sizeof(int));
    if (m_options->enableFLTK) {
      // disable FLTK graphs, but allow FLTK widgets
      *((int*) csoundQueryGlobalVariable(csound, "FLTK_Flags")) = 4;
    }
    else {
//       qDebug("play() FLTK Disabled");
      *((int*) csoundQueryGlobalVariable(csound, "FLTK_Flags")) = 3;
    }
//    qDebug("Command Line args:");
//    for (int index=0; index< argc; index++) {
//      qDebug() << argv[index];
//    }

    csoundSetIsGraphable(csound, true);
    csoundSetMakeGraphCallback(csound, &qutecsound::makeGraphCallback);
    csoundSetDrawGraphCallback(csound, &qutecsound::drawGraphCallback);
    csoundSetKillGraphCallback(csound, &qutecsound::killGraphCallback);
    csoundSetExitGraphCallback(csound, &qutecsound::exitGraphCallback);

    if (m_options->enableWidgets) {
      if (m_options->useInvalue) {
        csoundSetInputValueCallback(csound, &qutecsound::inputValueCallback);
        csoundSetOutputValueCallback(csound, &qutecsound::outputValueCallback);
      }
      else {
        // Not really sure that this is worth the trouble, as it
        // is used only with chnsend and chnrecv which are deprecated
//         qDebug() << "csoundSetChannelIOCallback";
//         csoundSetChannelIOCallback(csound, &qutecsound::ioCallback);
      }
    }
    else {
      csoundSetInputValueCallback(csound, NULL);
      csoundSetOutputValueCallback(csound, NULL);
    }
    csoundSetCallback(csound,
                      &keyEventCallback,
                      (void *) ud, CSOUND_CALLBACK_KBD_EVENT);

    ud->result=csoundCompile(csound,argc,argv);
    ud->csound = csound;
//    qDebug("Csound compiled %i", ud->result);
    if (ud->result!=CSOUND_SUCCESS or variable != CSOUND_SUCCESS) {
      qDebug("Csound compile failed!");
      stop();
      free(argv);
      // FIXME mark error lines: documentPages[curPage]->markErrorLines(m_console->errorLines);
      return;
    }
    if (m_options->enableWidgets and m_options->showWidgetsOnRun) {
      showWidgetsAct->setChecked(true);
      if (!textEdit->document()->toPlainText().contains("FLpanel")) // Don't bring up widget panel if there's an FLTK panel
        widgetPanel->setVisible(true);
    }
    ud->PERF_STATUS = 1;
    ud->zerodBFS = csoundGet0dBFS(csound);
    ud->sampleRate = csoundGetSr(csound);
    ud->numChnls = csoundGetNchnls(csound);
    ud->outputBufferSize = csoundGetKsmps(ud->csound);
    ud->ksmpscount = 0;

    //TODO is something here necessary to work with doubles?
//     PUBLIC int csoundGetSampleFormat(CSOUND *);
//     PUBLIC int csoundGetSampleSize(CSOUND *);
    unsigned int numWidgets = widgetPanel->widgetCount();
      // TODO: When this is working, simplify pointers
    ud->qcs->channelNames.resize(numWidgets*2);
    ud->qcs->values.resize(numWidgets*2);
    ud->qcs->stringValues.resize(numWidgets*2);
    if(m_options->thread) {
      // First update values from widgets
      if (ud->qcs->m_options->enableWidgets) {
        ud->qcs->widgetPanel->getValues(&ud->qcs->channelNames,
                                        &ud->qcs->values,
                                        &ud->qcs->stringValues);
      }
      perfThread = new CsoundPerformanceThread(csound);
      perfThread->SetProcessCallback(qutecsound::csThread, (void*)ud);
//      qDebug() << "qutecsound::runCsound perfThread->Play";
      perfThread->Play();
    }
    else { // Run in the same thread
      while(ud->PERF_STATUS == 1 && csoundPerformKsmps(csound)==0) {
        processEventQueue(ud);
        qutecsound::csThread(ud);
        qApp->processEvents(); // Must process events last to avoid stopping and calling csThread invalidly
      }
      stop();  // To flush pending queues
#ifdef MACOSX_PRE_SNOW
// Put menu bar back
      SetMenuBar(menuBarHandle);
#endif
    }
    for (int i = 0; i < 33; i++) {
      if (argv[i] != 0)
        free(argv[i]);
    }
    free(argv);
//    if (oldOpcodeDir != "") {
//      csoundSetGlobalEnv("OPCODEDIR", oldOpcodeDir.toLocal8Bit());
//    }
  }
  else {  // Run in external shell
    QFile tempFile("QuteCsoundExample.csd");
    if (fileName.startsWith(":/examples/")) {
      QString tmpFileName = QDir::tempPath();
      if (!tmpFileName.endsWith("/") and !tmpFileName.endsWith("\\")) {
        tmpFileName += QDir::separator();
      }
//       tmpFileName += QString("QuteCsoundExample.csd");
//       tempFile.setFileTemplate(tmpFileName);
      if (!tempFile.open(QIODevice::ReadWrite | QIODevice::Text)) {
        QMessageBox::critical(this,
                              tr("QuteCsound"),
                                 tr("Error creating temporary file."),
                                    QMessageBox::Ok);
        runAct->setChecked(false);
        return;
      }
      QString csdText = textEdit->document()->toPlainText();
      fileName = tempFile.fileName();
      tempFile.write(csdText.toAscii());
      tempFile.flush();
      if (!tempScriptFiles.contains(fileName))
        tempScriptFiles << fileName;
    }
    QString script = generateScript(realtime, fileName);
    QString scriptFileName = QDir::tempPath();
    if (!scriptFileName.endsWith("/"))
      scriptFileName += "/";
    scriptFileName += SCRIPT_NAME;
    QFile file(scriptFileName);
    if (!file.open(QIODevice::ReadWrite | QIODevice::Text)) {
      qDebug() << "qutecsound::runCsound() : Error creating temp file";
      return;
    }
    QTextStream out(&file);
    out << script;
//     file.flush();
    file.close();
    file.setPermissions (QFile::ExeOwner| QFile::WriteOwner| QFile::ReadOwner);

    QString options;
#ifdef LINUX
    options = "-e " + scriptFileName;
#endif
#ifdef SOLARIS
    options = "-e " + scriptFileName;
#endif
#ifdef MACOSX
    options = scriptFileName;
#endif
#ifdef WIN32
    options = scriptFileName;
    qDebug() << "m_options->terminal == " << m_options->terminal;
#endif
    execute(m_options->terminal, options);
    runAct->setChecked(false);
    recAct->setChecked(false);
    if (!tempScriptFiles.contains(scriptFileName))
      tempScriptFiles << scriptFileName;
  }
  if (QObject::sender() == renderAct) {
    if (QDir::isRelativePath(m_options->fileOutputFilename)) {
      currentAudioFile = m_options->csdPath + "/" + m_options->fileOutputFilename;
    }
    else {
      currentAudioFile = m_options->fileOutputFilename;
    }
  }
}


void CsoundEngine::stopCsound()
{
  qDebug("qutecsound::stopCsound()");
  if (m_options->thread) {
//    perfThread->ScoreEvent(0, 'e', 0, 0);
    if (perfThread->isRunning()) {
      perfThread->Stop();
      perfThread->Join();
      delete perfThread;
      perfThread = 0;
    }
  }
  else {
    csoundStop(csound);
    ud->PERF_STATUS = 0;
    csoundCleanup(csound);
    m_console->scrollToEnd();
  }
#ifdef MACOSX_PRE_SNOW
// Put menu bar back
  SetMenuBar(menuBarHandle);
#endif
#ifdef QUTECSOUND_DESTROY_CSOUND
  csoundDestroy(csound);
#endif
}

void DocumentPage::dispatchQueues()
{
//   qDebug("qutecsound::dispatchQueues()");
  int counter = 0;
  ud->wl->processNewValues();
  if (isRunning()) {
    while ((m_consoleBufferSize <= 0 || counter++ < m_consoleBufferSize) && m_csEngine->isRunning()) {
      messageMutex.lock();
      if (messageQueue.isEmpty()) {
        messageMutex.unlock();
        break;
      }
      QString msg = messageQueue.takeFirst();
      messageMutex.unlock();
      m_console->appendMessage(msg);
      m_widgetLayout->appendMessage(msg);
      qApp->processEvents(); //FIXME Is this needed here to avoid display problems in the console?
      m_console->scrollToEnd();
      m_widgetLayout->refreshConsoles();  // Scroll to end of text all console widgets
    }
    messageMutex.lock();
    if (!messageQueue.isEmpty() && m_consoleBufferSize > 0 && counter >= m_consoleBufferSize) {
      messageQueue.clear();
      messageQueue << "\nQUTECSOUND: Message buffer overflow. Messages discarded!\n";
    }
    messageMutex.unlock();
    //   QList<QString> channels = outValueQueue.keys();
    //   foreach (QString channel, channels) {
    //     widgetPanel->setValue(channel, outValueQueue[channel]);
    //   }
    //   outValueQueue.clear();

//    stringValueMutex.lock();
//    QStringList channels = outStringQueue.keys();
//    for  (int i = 0; i < channels.size(); i++) {
//      m_widgetLayout->setValue(channels[i], outStringQueue[channels[i]]);
//    }
//    outStringQueue.clear();
//    stringValueMutex.unlock();
    m_csEngine->processEventQueue();
    while (!newCurveBuffer.isEmpty()) {
      Curve * curve = newCurveBuffer.pop();
  // //     qDebug("qutecsound::dispatchQueues() %i-%s", index, curve->get_caption().toStdString().c_str());
        m_widgetLayout->newCurve(curve);
    }
    if (curveBuffer.size() > 32) {
      qDebug("qutecsound::dispatchQueues() WARNING: curve update buffer too large!");
      curveBuffer.resize(32);
    }
    foreach (WINDAT * windat, curveBuffer){
      Curve *curve = m_widgetLayout->getCurveById(windat->windid);
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
        m_widgetLayout->setCurveData(curve);
      }
      curveBuffer.remove(curveBuffer.indexOf(windat));
    }
    qApp->processEvents();
//    if (m_options->thread) {
      // FIXME it's necessary to check this, otherwise even though performance has ended, no one will find out
//      if (m_csEngine->GetStatus() != 0) {
//        stop();
//      }
//    }
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

void CsoundEngine::recordBuffer()
{
  if (m_recording == 1) {
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
}

bool CsoundEngine::isRunning()
{
  if (m_options->thread) {
    return perfThread->isRunning();
  }
  else {
    return ud->PERF_STATUS;
  }
}

