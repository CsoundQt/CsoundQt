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

CsoundEngine::CsoundEngine()
{
  // Initialize user data pointer passed to Csound
  ud = (CsoundUserData *)malloc(sizeof(CsoundUserData));
  ud->PERF_STATUS = 0;
  ud->cs = this;
  pFields = (MYFLT *) calloc(EVENTS_MAX_PFIELDS, sizeof(MYFLT)); // Maximum number of p-fields for events

  ud->csound = NULL;
  int init = csoundInitialize(0,0,0);
  if (init<0) {
    qDebug("Error initializing Csound!");
    QMessageBox::warning(this, tr("QuteCsound"),
                         tr("Error initializing Csound!\nQutecsound will probably crash if you try to run Csound."));
  }
#ifndef QUTECSOUND_DESTROY_CSOUND
  // Create only once
  csound=csoundCreate(0);
#endif

  mouseValues.resize(6); // For _MouseX _MouseY _MouseRelX _MouseRelY _MouseBut1 and _MouseBut2channels
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

void CsoundEngine::messageCallback_NoThread(CSOUND *csound,
                                          int /*attr*/,
                                          const char *fmt,
                                          va_list args)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  DockConsole *console = ud->cs->m_console;
  QString msg;
  msg = msg.vsprintf(fmt, args);
  console->appendMessage(msg);
  ud->cs->widgetPanel->appendMessage(msg);
  console->scrollToEnd();
}

void CsoundEngine::messageCallback_Thread(CSOUND *csound,
                                          int /*attr*/,
                                          const char *fmt,
                                          va_list args)
{
  CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
  QString msg;
  msg = msg.vsprintf(fmt, args);
  ud->cs->queueMessage(msg);
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
      int index = ud->qcs->channelNames.indexOf(name.mid(1));
      char *string = (char *) value;
      if (index>=0) {
        strcpy(string, ud->cs->stringValues[index].toStdString().c_str());
      }
      else {
        string[0] = '\0'; //empty c string
      }
    }
    else {  // Not a string channel
      int index = ud->qcs->channelNames.indexOf(name);
      if (index>=0)
        *value = (MYFLT) ud->qcs->values[index];
      else {
        *value = 0;
      }
      //FIXME check if mouse tracking is active
      if (name == "_MouseX") {
        *value = (MYFLT) ud->qcs->mouseValues[0];
      }
      else if (name == "_MouseY") {
        *value = (MYFLT) ud->qcs->mouseValues[1];
      }
      else if(name == "_MouseRelX") {
        *value = (MYFLT) ud->qcs->mouseValues[2];
      }
      else if(name == "_MouseRelY") {
        *value = (MYFLT) ud->qcs->mouseValues[3];
      }
      else if(name == "_MouseBut1") {
        *value = (MYFLT) ud->qcs->mouseValues[4];
      }
      else if(name == "_MouseBut2") {
        *value = (MYFLT) ud->qcs->mouseValues[5];
      }
    }
    ud->qcs->perfMutex.unlock();
  }
}

int CsoundEngine::keyEventCallback(void *userData,
                                 void *p,
                                 unsigned int type)
{
  if (type != CSOUND_CALLBACK_KBD_EVENT)
    return 1;
  CsoundUserData *ud = (CsoundUserData *) userData;
  qutecsound *qcs = (qutecsound *) ud->qcs;
  int *value = (int *) p;
  int key = qcs->popKeyPressEvent();
  if (key >= 0) {
    *value = key;
//     qDebug() << "Pressed: " << key;
  }
  else {
    key = qcs->popKeyReleaseEvent();
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
  ud->qcs->newCurve(curve);
  windat->windid = (uintptr_t) curve;
//   qDebug("qutecsound::makeGraphCallback %i", windat->windid);
}

void CsoundEngine::drawGraphCallback(CSOUND *csound, WINDAT *windat)
{
  CsoundUserData *udata = (CsoundUserData *) csoundGetHostData(csound);
//   qDebug("qutecsound::drawGraph()");
  udata->qcs->updateCurve(windat);
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
  return udata->qcs->killCurves(csound);
}

void CsoundEngine::runCsound(bool realtime)
{
  if (ud->PERF_STATUS == -1) { //Currently stopping, do nothing
    return;
  }
  else if (ud->PERF_STATUS == 1) { //If running, stop
    stop();
    return;
  }
  // Determine if API should be used
  bool useAPI = true;
  if (QObject::sender() == renderAct) {
    useAPI = m_options->useAPI;
  }
  else if (QObject::sender() == runTermAct) {
    useAPI = false;
  }
  if (m_options->terminalFLTK) { // if "FLpanel" is found in csd run from terminal
    if (documentPages[curPage]->document()->toPlainText().contains("FLpanel"))
      useAPI = false;
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
    //   outValueQueue.clear();
    inValueQueue.clear();
    outStringQueue.clear();
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

void qutecsound::stopCsound()
{
  qDebug("qutecsound::stopCsound()");
  if (m_options->thread) {
//    perfThread->ScoreEvent(0, 'e', 0, 0);
    if (ud->PERF_STATUS == 1) {
      ud->PERF_STATUS = -1;
      perfThread->Stop();
      perfThread->Join();
      delete perfThread;
      ud->PERF_STATUS = 0;
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

void qutecsound::readWidgetValues(CsoundUserData *ud)
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

  for (int i = 0; i < ud->qcs->channelNames.size(); i++) {
    if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->values[i];
    }
    if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
       CSOUND_INPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
      char *string = (char *) pvalue;
      strcpy(string, ud->qcs->stringValues[i].toStdString().c_str());
    }
  }
  //FIXME check if mouse tracking is active
  if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseX",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->mouseValues[0];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseY",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->mouseValues[1];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseRelX",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->mouseValues[2];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseRelY",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->mouseValues[3];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseBut1",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->mouseValues[4];
  }
  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseBut2",
        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
      *pvalue = (MYFLT) ud->qcs->mouseValues[5];
  }
}

void qutecsound::writeWidgetValues(CsoundUserData *ud)
{
//   qDebug("qutecsound::writeWidgetValues");
//   MYFLT* pvalue;
//   for (int i = 0; i < ud->qcs->channelNames.size(); i++) {
//     if (ud->qcs->channelNames[i] != "") {
//       if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
//          CSOUND_OUTPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
//            ud->qcs->widgetPanel->setValue(i,*pvalue);
//       }
//       else if(csoundGetChannelPtr(ud->csound, &pvalue, ud->qcs->channelNames[i].toStdString().c_str(),
//         CSOUND_OUTPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
//         ud->qcs->widgetPanel->setValue(i,QString((char *)pvalue));
//       }
//     }
//   }
}

void qutecsound::processEventQueue(CsoundUserData *ud)
{
  // This function should only be called when Csound is running
  while (ud->qcs->widgetPanel->layoutWidget->eventQueueSize > 0) {
    ud->qcs->widgetPanel->layoutWidget->eventQueueSize--;
    ud->qcs->widgetPanel->layoutWidget->eventQueue[ud->qcs->widgetPanel->layoutWidget->eventQueueSize];
    char type = ud->qcs->widgetPanel->layoutWidget->eventQueue[ud->qcs->widgetPanel->layoutWidget->eventQueueSize][0].unicode();
    QStringList eventElements =
        ud->qcs->widgetPanel->layoutWidget->eventQueue[ud->qcs->widgetPanel->layoutWidget->eventQueueSize].remove(0,1).split(" ",QString::SkipEmptyParts);
    qDebug("type %c line: %s", type, ud->qcs->widgetPanel->layoutWidget->eventQueue[ud->qcs->widgetPanel->layoutWidget->eventQueueSize].toStdString().c_str());
    // eventElements.size() should never be larger than EVENTS_MAX_PFIELDS
    for (int j = 0; j < eventElements.size(); j++) {
      ud->qcs->pFields[j] = (MYFLT) eventElements[j].toDouble();
    }
    if (ud->qcs->m_options->thread) {
      //ScoreEvent is not working
      ud->qcs->perfThread->ScoreEvent(0, type, eventElements.size(), ud->qcs->pFields);
//       ud->qcs->perfThread->InputMessage(ud->qcs->widgetPanel->eventQueue[ud->qcs->widgetPanel->eventQueueSize].remove(0,1).data());
//       perfThread->lock();
//       csoundScoreEvent(ud->csound,type ,ud->qcs->pFields, eventElements.size());
//       perfThread->unlock();
    }
    else {
      csoundScoreEvent(ud->csound,type ,ud->qcs->pFields, eventElements.size());
    }
  }
}

void qutecsound::queueOutValue(QString channelName, double value)
{
  widgetPanel->newValue(QPair<QString, double>(channelName, value));
}

// void qutecsound::queueInValue(QString channelName, double value)
// {
//   inValueQueue.insert(channelName, value);
// }

void qutecsound::queueOutString(QString channelName, QString value)
{
//   qDebug() << "qutecsound::queueOutString";
  widgetPanel->newValue(QPair<QString, QString>(channelName, value));
}

void qutecsound::csThread(void *data)
{
  CsoundUserData* udata = (CsoundUserData*)data;
  udata->outputBuffer = csoundGetSpout(udata->csound);
  for (int i = 0; i < udata->outputBufferSize*udata->numChnls; i++) {
    udata->qcs->audioOutputBuffer.put(udata->outputBuffer[i]/ udata->zerodBFS);
  }
  if (udata->qcs->m_options->enableWidgets) {
    udata->qcs->widgetPanel->getValues(&udata->qcs->channelNames,
                                       &udata->qcs->values,
                                       &udata->qcs->stringValues);
    udata->qcs->widgetPanel->getMouseValues(&udata->qcs->mouseValues);
    if (!udata->qcs->m_options->useInvalue) {
      writeWidgetValues(udata);
      readWidgetValues(udata);
    }
  }
//  QStringList events = udata->qcs->widgetPanel->getScheduledEvents(udata->ksmpscount);
  QStringList events = udata->qcs->documentPages[udata->qcs->curPage]
      ->getScheduledEvents(udata->ksmpscount * udata->outputBufferSize);
  for (int i = 0; i < events.size(); i++) {
    char type = udata->qcs->widgetPanel->layoutWidget->eventQueue[udata->qcs->widgetPanel->layoutWidget->eventQueueSize][0].unicode();
    QStringList eventElements = events[i].remove(0,1).split(QRegExp("\\s"),QString::SkipEmptyParts);
    // eventElements.size() should never be larger than EVENTS_MAX_PFIELDS
    for (int j = 0; j < eventElements.size(); j++) {
      udata->qcs->pFields[j] = (MYFLT) eventElements[j].toDouble();
    }
    if (udata->qcs->m_options->thread) {
      //ScoreEvent is not working
      udata->qcs->perfThread->ScoreEvent(0, type, eventElements.size(), udata->qcs->pFields);
      //       ud->qcs->perfThread->InputMessage(ud->qcs->widgetPanel->eventQueue[ud->qcs->widgetPanel->eventQueueSize].remove(0,1).data());
      //       perfThread->lock();
      //       csoundScoreEvent(ud->csound,type ,ud->qcs->pFields, eventElements.size());
      //       perfThread->unlock();
    }
    else {
      csoundScoreEvent(udata->csound,type ,udata->qcs->pFields, eventElements.size());
    }
  }
  (udata->ksmpscount)++;
}


