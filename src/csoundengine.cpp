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


#ifdef USE_QT5
#include <QtConcurrent/QtConcurrent>
#endif

#ifdef Q_OS_WIN
#include <ole2.h> // for OleInitialize() FLTK bug workaround
#include <unistd.h> // for usleep()
#endif

#ifdef CSOUND6
#include "csound_standard_types.h"
#endif

#include "csoundengine.h"
#include "widgetlayout.h"
#include "console.h"
#include "qutescope.h"  // Needed for passing the ud to the scope for display data
#include "qutegraph.h"  // Needed for passing the ud to the graph for display data

CsoundEngine::CsoundEngine(ConfigLists *configlists) :
	m_options(configlists)
{
	QMutexLocker locker(&m_playMutex);
	ud = new CsoundUserData();
	ud->csEngine = this;
	ud->csound = 0;
	ud->perfThread = 0;
	ud->flags = QCS_NO_FLAGS;
	ud->mouseValues.resize(6); // For _MouseX _MouseY _MouseRelX _MouseRelY _MouseBut1 and _MouseBut2 channels
	ud->wl = NULL;
#ifdef QCS_PYTHONQT
	ud->m_pythonCallback = "";
#endif

	m_recording = false;
	m_consoleBufferSize = 0;
	m_recBufferSize = 4096;
	m_recBuffer = (MYFLT *) calloc(m_recBufferSize, sizeof(MYFLT));

#ifndef QCS_DESTROY_CSOUND
	// Create only once
	ud->csound=csoundCreate(0);
	ud->perfThread = new CsoundPerformanceThread(ud->csound);
	ud->perfThread->SetProcessCallback(CsoundEngine::csThread, (void*)ud);
#endif

	eventQueue.resize(QCS_MAX_EVENTS);
	eventTimeStamps.resize(QCS_MAX_EVENTS);
	eventQueueSize = 0;

	m_refreshTime = QCS_QUEUETIMER_DEFAULT_TIME;  // TODO Eventually allow this to be changed
	ud->msgRefreshTime = m_refreshTime*1000;

	ud->runDispatcher = true;
	m_msgUpdateThread = QtConcurrent::run(messageListDispatcher, (void *) ud);

}

CsoundEngine::~CsoundEngine()
{
	disconnect(SIGNAL(passMessages(QString)),0,0);

	disconnect(this, 0,0,0);
	ud->runDispatcher = false;
	m_msgUpdateThread.waitForFinished(); // Join the message thread
	stop();
#ifndef QCS_DESTROY_CSOUND
	csoundDestroy(ud->csound);
#endif
	delete ud;
	free(m_recBuffer);
}

#ifndef CSOUND6
//void CsoundEngine::messageCallbackNoThread(CSOUND *csound,
//										   int /*attr*/,
//										   const char *fmt,
//										   va_list args)
//{
//	CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
//	QString msg;
//	msg = msg.vsprintf(fmt, args);
//	if (msg.isEmpty()) {
//		return;
//	}
//	for (int i = 0; i < ud->csEngine->consoles.size(); i++) {
//		ud->csEngine->consoles[i]->appendMessage(msg);
//	}
//}

void CsoundEngine::messageCallbackThread(CSOUND *csound,
										 int /*attr*/,
										 const char *fmt,
										 va_list args)
{

	CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
	if (!(ud->flags & QCS_NO_CONSOLE_MESSAGES)) {
		QString msg;
		msg = msg.vsprintf(fmt, args);
		if (msg.isEmpty()) {
			return;
		}
		ud->csEngine->queueMessage(msg);
	}
}
#endif

#ifndef CSOUND6
void CsoundEngine::outputValueCallback (CSOUND *csound,
										const char *channelName,
										MYFLT value)
{
	// Called by the csound running engine when 'outvalue' opcode is used
	// To pass data from Csound to CsoundQt
	CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
	QString name = QString(channelName);
	if (name.startsWith('$')) {
		QString channelName = name;
		channelName.chop(name.size() - (int) value + 1);
		QString sValue = name;
		sValue = sValue.right(name.size() - (int) value);
		channelName.remove(0,1);
		ud->csEngine->passOutString(channelName, sValue);
	}
	else {
		ud->csEngine->passOutValue(name, value);
	}
}

void CsoundEngine::inputValueCallback(CSOUND *csound,
									  const char *channelName,
									  MYFLT *value)
{
	// Called by the csound running engine when 'invalue' opcode is used
	// To pass data from qutecsound to Csound
	CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
	QString name = QString(channelName);
	if (name.startsWith('$')) { // channel is a string channel
        char *string = (char *) value;
        QString newValue = ud->wl->getStringForChannel(name.mid(1));
        int maxlen = csoundGetStrVarMaxLen(csound);
        strncpy(string, newValue.toLocal8Bit(), maxlen);
	}
	else {  // Not a string channel
		//FIXME check if mouse tracking is active, and move this from here
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
		else {
			*value = (MYFLT) ud->wl->getValueForChannel(name);
		}
	}
}
#else
void CsoundEngine::outputValueCallback (CSOUND *csound,
								 const char *channelName,
								 void *channelValuePtr,
								 const void *channelType)
{
	// Called by the csound running engine when 'outvalue' opcode is used
	// To pass data from Csound to CsoundQt
	CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
	if (channelType == &CS_VAR_TYPE_S) {
		ud->csEngine->passOutString(channelName, (const char *) channelValuePtr);
	}
	else if (channelType == &CS_VAR_TYPE_K){
		ud->csEngine->passOutValue(channelName, *((MYFLT *)channelValuePtr));
	} else {
		qDebug() << "outputValueCallback: Unsupported type";
	}
}

void CsoundEngine::inputValueCallback (CSOUND *csound,
								const char *channelName,
								void *channelValuePtr,
								const void *channelType)
{
	// Called by the csound running engine when 'invalue' opcode is used
	// To pass data from qutecsound to Csound
	CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
	if (channelType == &CS_VAR_TYPE_S) { // channel is a string channel
		char *string = (char *) channelValuePtr;
		QString newValue = ud->wl->getStringForChannel(channelName);
		int maxlen = csoundGetChannelDatasize(csound, channelName);
		strncpy(string, newValue.toLocal8Bit(), maxlen);
	}
	else if (channelType == &CS_VAR_TYPE_K) {  // Not a string channel
		//FIXME check if mouse tracking is active, and move this from here
		QString name(channelName);
		MYFLT *value = (MYFLT *) channelValuePtr;
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
		else {
			*value = (MYFLT) ud->wl->getValueForChannel(name);
		}
	} else {
		qDebug() << "inputValueCallback: Unsupported type";
	}
}

#endif

void CsoundEngine::makeGraphCallback(CSOUND *csound, WINDAT *windat, const char * /*name*/)
{
	CsoundUserData *ud = (CsoundUserData *) csoundGetHostData(csound);
	// Csound reuses windat, so it is not guaranteed to be unique
	// name seems not to be used.
	//  qDebug() << "CsoundEngine::makeGraph() " << windat << "  " << name<< windat->windid;
	ud->wl->appendCurve(windat);
}

void CsoundEngine::drawGraphCallback(CSOUND *csound, WINDAT *windat)
{
	CsoundUserData *udata = (CsoundUserData *) csoundGetHostData(csound);
	// This callback paints data on curves
	//  qDebug("CsoundEngine::drawGraph()");
	udata->wl->updateCurve(windat);
}

void CsoundEngine::killGraphCallback(CSOUND *csound, WINDAT *windat)
{
	// When is this callback called??
	qDebug() << "CsoundEngine::killGraphCallback";
	CsoundUserData *udata = (CsoundUserData *) csoundGetHostData(csound);
	udata->wl->killCurve(windat);
}

int CsoundEngine::exitGraphCallback(CSOUND *csound)
{
	//  qDebug("CsoundEngine::exitGraphCallback()");
	CsoundUserData *udata = (CsoundUserData *) csoundGetHostData(csound);
	return udata->wl->killCurves(csound);
}

int CsoundEngine::keyEventCallback(void *userData,
								   void *p,
								   unsigned int type)
{
//	if (type != CSOUND_CALLBACK_KBD_EVENT)
//		return 1;
	CsoundUserData *ud = (CsoundUserData *) userData;
	//  WidgetLayout *wl = (WidgetLayout *) ud->wl;
	int *value = (int *) p;
	int key = ud->csEngine->popKeyPressEvent();
	if (key >= 0) {
		*value = key;
		//    qDebug() << "Pressed: " << key;
	}
	else {
		key = ud->csEngine->popKeyReleaseEvent();
		if (key >= 0) {
			*value = key;
			//       qDebug() << "Released: " << key;
		}
	}
	return 0;
}

void CsoundEngine::csThread(void *data)
{
	CsoundUserData* udata = (CsoundUserData*)data;
	if (!(udata->flags & QCS_NO_COPY_BUFFER)) {
		MYFLT *outputBuffer = csoundGetSpout(udata->csound);
		for (int i = 0; i < udata->outputBufferSize*udata->numChnls; i++) {
			udata->audioOutputBuffer.put(outputBuffer[i]/ udata->zerodBFS);
		}
	}
	//  udata->wl->getValues(&udata->channelNames,
	//                       &udata->values,
	//                       &udata->stringValues);
	if (udata->enableWidgets) {
		//        csoundDeleteChannelList(udata->csound, *channelList);
		writeWidgetValues(udata);
		readWidgetValues(udata);
	}
	if (!(udata->flags & QCS_NO_RT_EVENTS)) {
		udata->csEngine->processEventQueue();
	}
#ifdef QCS_PYTHONQT
	if (!(udata->flags & QCS_NO_PYTHON_CALLBACK)) {
		if (!udata->m_pythonCallback.isEmpty()) {
			if (udata->m_pythonCallbackCounter >= udata->m_pythonCallbackSkip) {
				udata->m_pythonConsole->evaluate(udata->m_pythonCallback, false);
				udata->m_pythonCallbackCounter = 0;
			}
			else {
				udata->m_pythonCallbackCounter++;
			}
		}
	}
#endif
}

void CsoundEngine::readWidgetValues(CsoundUserData *ud)
{
	MYFLT* pvalue;

	if (ud->wl->valueMutex.tryLock()) {
		QHash<QString, double>::const_iterator i;
		QHash<QString, double>::const_iterator end = ud->wl->newValues.constEnd();
		for (i = ud->wl->newValues.constBegin(); i != end; ++i) {
			if(csoundGetChannelPtr(ud->csound, &pvalue, i.key().toLocal8Bit().constData(),
								   CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
				*pvalue = (MYFLT) i.value();
			}
		}
		ud->wl->newValues.clear();
		ud->wl->valueMutex.unlock();
	}
	if (ud->wl->stringValueMutex.tryLock()) {
		QHash<QString, QString>::const_iterator i;
		QHash<QString, QString>::const_iterator end = ud->wl->newStringValues.constEnd();
		for (i = ud->wl->newStringValues.constBegin(); i != end; ++i) {
			if(csoundGetChannelPtr(ud->csound, &pvalue, i.key().toLocal8Bit().constData(),
								   CSOUND_INPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
				char *string = (char *) pvalue;
				strcpy(string, i.value().toLocal8Bit().constData());
			}
		}
		ud->wl->newStringValues.clear();
		ud->wl->stringValueMutex.unlock();
	}
	//  for (int i = 0; i < ud->inputChannelNames.size(); i++) {
	//    if(csoundGetChannelPtr(ud->csound, &pvalue, ud->inputChannelNames[i].toLocal8Bit().constData(),
	//        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
	//      double value = ud->wl->getValueForChannel(ud->inputChannelNames[i]);
	//      *pvalue = (MYFLT) value;
	////      *pvalue = (MYFLT) (ud->inputValues[i].toDouble());
	//    }
	//    else if(csoundGetChannelPtr(ud->csound, &pvalue, ud->inputChannelNames[i].toLocal8Bit().constData(),
	//       CSOUND_INPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
	//      bool modified = false;
	//      char *string = (char *) pvalue;
	//      QString value = ud->wl->getStringForChannel(ud->inputChannelNames[i]);
	//      if (modified) {
	//        strcpy(string, value.toLocal8Bit().constData());
	//      }
	//    }
	//    else {
	//      qDebug() << "CsoundEngine::readWidgetValues invalid input channel: " << ud->inputChannelNames[i];
	//    }
	//  }
	//FIXME check if mouse tracking is active
	//  if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseX",
	//        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
	//      *pvalue = (MYFLT) ud->mouseValues[0];
	//  }
	//  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseY",
	//        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
	//      *pvalue = (MYFLT) ud->mouseValues[1];
	//  }
	//  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseRelX",
	//        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
	//      *pvalue = (MYFLT) ud->mouseValues[2];
	//  }
	//  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseRelY",
	//        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
	//      *pvalue = (MYFLT) ud->mouseValues[3];
	//  }
	//  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseBut1",
	//        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
	//      *pvalue = (MYFLT) ud->mouseValues[4];
	//  }
	//  else if(csoundGetChannelPtr(ud->csound, &pvalue, "_MouseBut2",
	//        CSOUND_INPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
	//      *pvalue = (MYFLT) ud->mouseValues[5];
	//  }
}

void CsoundEngine::writeWidgetValues(CsoundUserData *ud)
{
	//   qDebug("qutecsound::writeWidgetValues");
	MYFLT* pvalue;
	for (int i = 0; i < ud->outputChannelNames.size(); i++) {
		if (ud->outputChannelNames[i] != ""
				&& csoundGetChannelPtr(ud->csound, &pvalue,
									   ud->outputChannelNames[i].toLocal8Bit().constData(),
									   CSOUND_OUTPUT_CHANNEL | CSOUND_CONTROL_CHANNEL) == 0) {
			if(ud->previousOutputValues[i] != *pvalue) {
				ud->wl->setValue(ud->outputChannelNames[i],*pvalue);
				ud->previousOutputValues[i] = *pvalue;
			}
		}
	}
	for (int i = 0; i < ud->outputStringChannelNames.size(); i++) {
		if (ud->outputStringChannelNames[i] != ""
				&& csoundGetChannelPtr(ud->csound, &pvalue,
									   ud->outputStringChannelNames[i].toLocal8Bit().constData(),
									   CSOUND_OUTPUT_CHANNEL | CSOUND_STRING_CHANNEL) == 0) {
			QString value = QString((char *)pvalue);
			if(ud->previousStringOutputValues[i] != value) {
				ud->wl->setValue(ud->outputStringChannelNames[i],value);
				ud->previousStringOutputValues[i] = value;
			}
		}
	}
}

void CsoundEngine::setWidgetLayout(WidgetLayout *wl)
{
	ud->wl = wl;
	//  connect(wl, SIGNAL(destroyed()), this, SLOT(widgetLayoutDestroyed()));
	// Key presses on widget layout and console are passed to the engine
	connect(wl, SIGNAL(keyPressed(QString)),
			this, SLOT(keyPressForCsound(QString)));
	connect(wl, SIGNAL(keyReleased(QString)),
			this, SLOT(keyReleaseForCsound(QString)));

	// Register scopes and graphs to pass them the engine's user data
	connect(wl, SIGNAL(registerScope(QuteScope*)),
			this,SLOT(registerScope(QuteScope*)));
	connect(wl, SIGNAL(registerGraph(QuteGraph*)),
			this,SLOT(registerGraph(QuteGraph*)));
	connect(this, SIGNAL(passMessages(QString)), wl, SLOT(appendMessage(QString)));
}

void CsoundEngine::enableWidgets(bool enable)
{
	ud->enableWidgets = enable;
}

void CsoundEngine::setInitialDir(QString initialDir)
{
	m_initialDir = initialDir;
}

void CsoundEngine::registerConsole(ConsoleWidget *c)
{
	consoles.append(c);
	connect(this,SIGNAL(passMessages(QString)), c, SLOT(appendMessage(QString)));
}

QList<QPair<int, QString> > CsoundEngine::getErrorLines()
{
	QList<QPair<int, QString> > list;
	if (consoles.size() > 0) {
		QList<int> lines = consoles[0]->errorLines;
		QStringList texts = consoles[0]->errorTexts;
		for (int i = 0; i < lines.size(); i++) {
			list.append(QPair<int, QString>(lines[i], texts[i]));
		}
	}
	return list;
}

void CsoundEngine::setConsoleBufferSize(int size)
{
	//  qDebug() << "CsoundEngine::setConsoleBufferSize " << size;
	m_consoleBufferSize = size;
}

void CsoundEngine::keyPressForCsound(QString key)
{
	//  qDebug() << "CsoundEngine::keyPressForCsound " << key;
	keyMutex.lock();
	keyPressBuffer << key;
	keyMutex.unlock();
}

void CsoundEngine::keyReleaseForCsound(QString key)
{
	//   qDebug() << "keyReleaseForCsound " << key;
	keyMutex.lock();
	keyReleaseBuffer << key;
	keyMutex.unlock();
}

void CsoundEngine::registerScope(QuteScope *scope)
{
	scope->setUd(ud);
}

void CsoundEngine::registerGraph(QuteGraph *graph)
{
	graph->setUd(ud);
}

void CsoundEngine::evaluate(QString code)
{
#ifdef CSOUND6
	CSOUND *csound = getCsound();
	if (csound) {
		csoundCompileOrc(csound, code.toLatin1());
	} else {
		queueMessage(tr("Csound is not running. Code not evaluated."));
	}
#else
	Q_UNUSED(code);
	qDebug() << "CsoundEngine::evaluate only available in Csound6";
#endif
}

//void CsoundEngine::unregisterScope(QuteScope *scope)
//{
//  // TODO is it necessary to unregiter scopes?
//  qDebug() << "CsoundEngine::unregisterScope not implemented";
//}

int CsoundEngine::popKeyPressEvent()
{
	keyMutex.lock();
	int value = -1;
	if (!keyPressBuffer.isEmpty()) {
		value = (int) keyPressBuffer.takeFirst()[0].toLatin1();
	}
	keyMutex.unlock();
	return value;
}

int CsoundEngine::popKeyReleaseEvent()
{
	keyMutex.lock();
	int value = -1;
	if (!keyReleaseBuffer.isEmpty()) {
		value = (int) keyReleaseBuffer.takeFirst()[0].toLatin1() + 0x10000;
	}
	keyMutex.unlock();
	return value;
}

void CsoundEngine::processEventQueue()
{
	// This function should only be called when Csound is running
	eventMutex.lock();
	while (eventQueueSize > 0) {
		eventQueueSize--;
#ifdef QCS_DESTROY_CSOUND
		if (ud->perfThread != 0) {
			//ScoreEvent is not working
			//      ud->perfThread->ScoreEvent(0, type, eventElements.size(), pFields);
			//      qDebug() << "CsoundEngine::processEventQueue()" << eventQueue[eventQueueSize];
			ud->perfThread
					->InputMessage(eventQueue[eventQueueSize].toLatin1());
		}
		else {
			qDebug() << "WARNING: ud->perfThread is NULL";
		}
#else
		ud->perfThread
				->InputMessage(eventQueue[eventQueueSize].toLatin1());
#endif
	}
	eventMutex.unlock();
}

void CsoundEngine::passOutValue(QString channelName, double value)
{
	ud->wl->newValue(QPair<QString, double>(channelName, value));
}

void CsoundEngine::passOutString(QString channelName, QString value)
{
	//   qDebug() << "qutecsound::queueOutString";
	ud->wl->newValue(QPair<QString, QString>(channelName, value));
}

int CsoundEngine::play(CsoundOptions *options)
{
	//  qDebug() << "CsoundEngine::play";
	if (!isRunning()) {
		m_options = *options;
		return runCsound();
	}
	else {
		ud->perfThread->TogglePause();
		return 0;
	}
}

void CsoundEngine::stop()
{
	stopRecording();
	stopCsound();
}

void CsoundEngine::pause()
{
	if (isRunning() && ud->perfThread->GetStatus() == 0) {
		//ud->perfThread->Pause();
		ud->perfThread->TogglePause();
	}
}

int CsoundEngine::startRecording(int sampleformat, QString fileName)
{
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
	qDebug("start recording: %s", fileName.toLocal8Bit().constData());
	m_outfile = new SndfileHandle(fileName.toLocal8Bit(), SFM_WRITE, format, channels, sampleRate);
	// clip instead of wrap when converting floats to ints
	m_outfile->command(SFC_SET_CLIPPING, NULL, SF_TRUE);
	samplesWritten = 0;
	m_recording = true;

	recordTimer.singleShot(20, this, SLOT(recordBuffer()));
	return 0;
}

void CsoundEngine::stopRecording()
{
	m_recording = false;  // Will be processed on next record buffer
}

void CsoundEngine::queueEvent(QString eventLine, int delay)
{
	// TODO: implement delayed events
	//   qDebug("CsoundEngine::queueEvent %s", eventLine.toStdString().c_str());
	if (!isRunning()) {
		QMutexLocker lock(&m_messageMutex);
		messageQueue << tr("Csound is not running! Event ignored.\n");
		return;
	}
	if (eventQueueSize < QCS_MAX_EVENTS) {
		eventMutex.lock();
		eventQueue[eventQueueSize] = eventLine;
		eventQueueSize++;
		eventMutex.unlock();
	}
	else {
		qDebug("Warning: event queue full, event not processed");
	}
}

int CsoundEngine::runCsound()
{
	QMutexLocker locker(&m_playMutex);
#ifdef MACOSX_PRE_SNOW
	//Remember menu bar to set it after FLTK grabs it
	menuBarHandle = GetMenuBar();
#endif
#ifdef Q_OS_WIN
	// Call OleInitialize twice to keep the FLTK opcodes from reducing the COM
	// reference count to zero.
	OleInitialize(NULL);
	OleInitialize(NULL);
#endif
	eventQueueSize = 0; //Flush events gathered while idle
	ud->audioOutputBuffer.allZero();

	QDir::setCurrent(m_options.fileName1);
	for (int i = 0; i < consoles.size(); i++) {
		consoles[0]->reset();
	}

#ifdef QCS_DESTROY_CSOUND
	ud->csound=csoundCreate(0);
#endif

	setupEnvironment(); // Environment variables must be set before csoundCompile

	ud->msgRefreshTime = m_refreshTime*1000;
#ifdef CSOUND6
	csoundCreateMessageBuffer(ud->csound, 0);
#endif
	csoundSetHostData(ud->csound, (void *) ud);

#ifndef CSOUND6
	// Message Callbacks must be set before compile, otherwise some information is missed
	csoundSetMessageCallback(ud->csound, &CsoundEngine::messageCallbackThread);
	csoundPreCompile(ud->csound);  //Need to run PreCompile to create the FLTK_Flags global variable
#endif

	if (m_options.enableFLTK) {
		// disable FLTK graphs, but allow FLTK widgets
		int *var = (int*) csoundQueryGlobalVariable(ud->csound, "FLTK_Flags");
		if (var) {
			*var = 4;
		} else {
			if (csoundCreateGlobalVariable(ud->csound, "FLTK_Flags", sizeof(int)) != CSOUND_SUCCESS) {
				qDebug() << "Error creating the FTLK_Flags variable";
			}  else {
				int *var = (int*) csoundQueryGlobalVariable(ud->csound, "FLTK_Flags");
				if (var) {
					*var = 4;
				} else {
					qDebug() << "Error reading the FTLK_Flags variable";
				}
			}
		}
	}
	else {
		//       qDebug("play() FLTK Disabled");
		csoundSetGlobalEnv("CS_OMIT_LIBS", "fluidOpcodes,virtual,widgets");
		int *var = (int*) csoundQueryGlobalVariable(ud->csound, "FLTK_Flags");
		if (var) {
			*var = 3;
		} else {
			qDebug() << "Error reading the FTLK_Flags variable";
		}
	}

#ifdef CSOUND6
	csoundRegisterKeyboardCallback(ud->csound,
								   &CsoundEngine::keyEventCallback,
								   (void *) ud, CSOUND_CALLBACK_KBD_EVENT | CSOUND_CALLBACK_KBD_TEXT);
#else
	csoundSetCallback(ud->csound,
					  &CsoundEngine::keyEventCallback,
					  (void *) ud, CSOUND_CALLBACK_KBD_EVENT | CSOUND_CALLBACK_KBD_TEXT);
	csoundSetIsGraphable(ud->csound, true);
	csoundSetMakeGraphCallback(ud->csound, &CsoundEngine::makeGraphCallback);
	csoundSetDrawGraphCallback(ud->csound, &CsoundEngine::drawGraphCallback);
	csoundSetKillGraphCallback(ud->csound, &CsoundEngine::killGraphCallback);
	csoundSetExitGraphCallback(ud->csound, &CsoundEngine::exitGraphCallback);
#endif


	char **argv;
	argv = (char **) calloc(33, sizeof(char*));
	int argc = m_options.generateCmdLine(argv);
	ud->result=csoundCompile(ud->csound,argc,argv);
	for (int i = 0; i < argc; i++) {
		qDebug() << argv[i];
		free(argv[i]);
	}
	free(argv);
	if (ud->result!=CSOUND_SUCCESS) {
		qDebug() << "Csound compile failed! "  << ud->result;
		stop();
		emit (errorLines(getErrorLines()));
		return -3;
	}
#ifdef CSOUND6
	csoundSetIsGraphable(ud->csound, true);
	csoundSetMakeGraphCallback(ud->csound, &CsoundEngine::makeGraphCallback);
	csoundSetDrawGraphCallback(ud->csound, &CsoundEngine::drawGraphCallback);
	csoundSetKillGraphCallback(ud->csound, &CsoundEngine::killGraphCallback);
	csoundSetExitGraphCallback(ud->csound, &CsoundEngine::exitGraphCallback);
#endif
	ud->zerodBFS = csoundGet0dBFS(ud->csound);
	ud->sampleRate = csoundGetSr(ud->csound);
	ud->numChnls = csoundGetNchnls(ud->csound);
	ud->outputBufferSize = csoundGetKsmps(ud->csound);

	if (ud->enableWidgets) {
		setupChannels();
	}

	ud->perfThread = new CsoundPerformanceThread(ud->csound);
	ud->perfThread->SetProcessCallback(CsoundEngine::csThread, (void*)ud);
	ud->perfThread->Play();
	return 0;
}

void CsoundEngine::stopCsound()
{
	//  qDebug() << "CsoundEngine::stopCsound()";
	//    perfThread->ScoreEvent(0, 'e', 0, 0);
	QMutexLocker locker(&m_playMutex);
	if (ud->perfThread != 0) {
		CsoundPerformanceThread *pt = ud->perfThread;
		ud->perfThread = NULL;
		pt->Stop();
		//      qDebug() << "CsoundEngine::stopCsound() stopped";
//		pt->FlushMessageQueue();
		pt->Join();
		qDebug() << "CsoundEngine::stopCsound() joined";
		delete pt;
		cleanupCsound();
	}
#ifdef MACOSX_PRE_SNOW
	// Put menu bar back
	SetMenuBar(menuBarHandle);
#endif
	emit stopSignal();
}

void CsoundEngine::cleanupCsound()
{
	if (ud->csound) {

		csoundSetIsGraphable(ud->csound, 0);
		csoundSetMakeGraphCallback(ud->csound, NULL);
		csoundSetDrawGraphCallback(ud->csound, NULL);
		csoundSetKillGraphCallback(ud->csound, NULL);
		csoundSetExitGraphCallback(ud->csound, NULL);
#ifdef CSOUND6
		csoundRemoveKeyboardCallback(ud->csound,
									 &CsoundEngine::keyEventCallback);
#else
		csoundRemoveCallback(ud->csound,
							 &CsoundEngine::keyEventCallback);
#endif
		csoundCleanup(ud->csound);
		flushQueues();
#ifndef CSOUND6
		csoundSetMessageCallback(ud->csound, 0);
#else
		csoundDestroyMessageBuffer(ud->csound);
#endif
#ifdef QCS_DESTROY_CSOUND
		csoundDestroy(ud->csound);
#else
		csoundReset(ud->csound);
#endif
		ud->csound = NULL;
	}
}

void CsoundEngine::setupChannels()
{
	ud->inputChannelNames.clear();
	ud->outputChannelNames.clear();
	ud->outputStringChannelNames.clear();
	ud->previousOutputValues.clear();
	ud->previousStringOutputValues.clear();
#ifndef CSOUND6
	// For invalue/outvalue
	csoundSetInputValueCallback(ud->csound, &CsoundEngine::inputValueCallback);
	csoundSetOutputValueCallback(ud->csound, &CsoundEngine::outputValueCallback);
#else
	csoundSetInputChannelCallback(ud->csound, &CsoundEngine::inputValueCallback);
	csoundSetOutputChannelCallback(ud->csound, &CsoundEngine::outputValueCallback);
#endif
	// For chnget/chnset
#ifndef CSOUND6
	CsoundChannelListEntry *channelList;
	int numChannels = csoundListChannels(ud->csound, &channelList);
	CsoundChannelListEntry *entry = channelList;
#else
	controlChannelInfo_t *channelList;
	int numChannels = csoundListChannels(ud->csound, &channelList);
	controlChannelInfo_t *entry = channelList;
#endif
	MYFLT *pvalue;
	for (int i = 0; i < numChannels; i++) {
		int chanType = csoundGetChannelPtr(ud->csound, &pvalue, entry->name,
										   0);
		QVector<QuteWidget *> widgets = ud->wl->getWidgets();
		if (chanType & CSOUND_INPUT_CHANNEL) {
//			ud->inputChannelNames << QString(entry->name);
			if (chanType & CSOUND_CONTROL_CHANNEL) {
				ud->wl->valueMutex.lock();
				foreach (QuteWidget *w, widgets) {
					if (!w->getChannelName().isEmpty()) {
						ud->wl->newValues.insert(w->getChannelName(), w->getValue());
					}
					if (!w->getChannel2Name().isEmpty()) {
						ud->wl->newValues.insert(w->getChannel2Name(), w->getValue2());
					}
				}
				ud->wl->valueMutex.unlock();
			} else if (chanType & CSOUND_STRING_CHANNEL) {
				ud->wl->stringValueMutex.lock();
				foreach (QuteWidget *w, widgets) {
					if (!w->getChannelName().isEmpty()) {
						ud->wl->newStringValues.insert(w->getChannelName(), w->getStringValue());
					}
				}
				ud->wl->stringValueMutex.unlock();
			}
		}
		if (chanType & CSOUND_OUTPUT_CHANNEL) { // Channels can be input and output at the same time
			if (chanType & CSOUND_CONTROL_CHANNEL) {
				ud->outputChannelNames << QString(entry->name);
				ud->previousOutputValues << 0;
				foreach (QuteWidget *w, widgets) {
					if (w->getChannelName() == QString(entry->name)) {
						ud->previousOutputValues.last() = w->getValue();
						continue;
					}
					if (w->getChannel2Name() == QString(entry->name)) {
						ud->previousOutputValues.last() = w->getValue2();
						continue;
					}
				}
			} else if (chanType & CSOUND_STRING_CHANNEL) {
				ud->outputStringChannelNames << QString(entry->name);
				ud->previousStringOutputValues << "";
				foreach (QuteWidget *w, widgets) {
					if (w->getChannelName() == QString(entry->name)) {
						ud->previousStringOutputValues.last() = w->getStringValue();
						continue;
					}
				}
			}
		}
		entry++;
	}
	csoundDeleteChannelList(ud->csound, channelList);
}

void CsoundEngine::setupEnvironment()
{
	if (m_options.sadirActive){
		int ret = csoundSetGlobalEnv("SADIR", m_options.sadir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting SADIR";
		}
	}
	else {
		csoundSetGlobalEnv("SADIR", "");
	}
	if (m_options.ssdirActive){
		int ret = csoundSetGlobalEnv("SSDIR", m_options.ssdir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting SSDIR";
		}
	}
	else {
		csoundSetGlobalEnv("SSDIR", "");
	}
	if (m_options.sfdirActive){
		int ret = csoundSetGlobalEnv("SFDIR", m_options.sfdir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting SFDIR";
		}
	}
	else {
		csoundSetGlobalEnv("SFDIR", "");
	}
	if (m_options.incdirActive){
		int ret = csoundSetGlobalEnv("INCDIR", m_options.incdir.toLocal8Bit().constData());
		if (ret != 0) {
			qDebug() << "CsoundEngine::runCsound() Error setting INCDIR";
		}
	}
	else {
		csoundSetGlobalEnv("INCDIR", "");
	}
	// csoundGetEnv must be called after Compile or Precompile,
	// But I need to set OPCODEDIR before compile.... So I can't know keep the old OPCODEDIR
	if (m_options.opcodedirActive) {
		csoundSetGlobalEnv("OPCODEDIR", m_options.opcodedir.toLatin1().constData());
	}
	if (m_options.opcodedir64Active) {
		csoundSetGlobalEnv("OPCODEDIR64", m_options.opcodedir64.toLatin1().constData());
	}
	if (m_options.opcode6dir64Active) {
		csoundSetGlobalEnv("OPCODE6DIR64", m_options.opcode6dir64.toLatin1().constData());
	}
#ifdef Q_OS_MAC
	else { // Set opcode dir for bundled Csound if present
#ifdef USE_DOUBLE
		QString opcodedir = m_initialDir + "/CsoundQt.app/Contents/Frameworks/CsoundLib64.framework/Resources/Opcodes";
#else
		QString opcodedir = m_initialDir + "/CsoundQt.app/Contents/Frameworks/CsoundLib.framework/Resources/Opcodes";
#endif
		if (QFile::exists(opcodedir)) {
#ifdef USE_DOUBLE
			csoundSetGlobalEnv("OPCODEDIR64", opcodedir.toLocal8Bit().constData());
#else
			csoundSetGlobalEnv("OPCODEDIR", opcodedir.toLocal8Bit().constData());
#endif
		}
	}
#endif
}

void CsoundEngine::messageListDispatcher(void *data)
{
	qDebug("CsoundEngine::messageListDispatcher()");
	CsoundUserData *ud_local = (CsoundUserData *) data;

	while (ud_local->runDispatcher) {
		if (ud_local->perfThread) {
			if (ud_local->perfThread->GetStatus() != 0) { // In case score has ended
				ud_local->csEngine->stop();
			}
		}
		CSOUND *csound = ud_local->csEngine->getCsound();

		if (csound) {
			if (ud_local->wl) {
				ud_local->wl->getMouseValues(&ud_local->mouseValues);
			}
#ifdef CSOUND6
			int count = csoundGetMessageCnt(csound);

			ud_local->csEngine->m_messageMutex.lock();
			for (int i = 0; i< count; i++) {
				ud_local->csEngine->messageQueue << csoundGetFirstMessage(csound);
				// FIXME: Is this thread safe?
				csoundPopFirstMessage(csound);
			}
			ud_local->csEngine->m_messageMutex.unlock();
#endif
		}

		int counter = 0;
		ud_local->csEngine->m_messageMutex.lock();
		while ((ud_local->csEngine->m_consoleBufferSize <= 0 || counter++ < ud_local->csEngine->m_consoleBufferSize)) {
			if (ud_local->csEngine->messageQueue.isEmpty()) {
				break;
			}
			QString msg = ud_local->csEngine->messageQueue.takeFirst();
			emit ud_local->csEngine->passMessages(msg); //Must use signals to make things thread safe
		}
		if (!ud_local->csEngine->messageQueue.isEmpty()
				&& ud_local->csEngine->m_consoleBufferSize > 0
				&& counter >= ud_local->csEngine->m_consoleBufferSize) {
			ud_local->csEngine->messageQueue.clear();
			ud_local->csEngine->messageQueue << "\nCsoundQt: Message buffer overflow. Messages discarded!\n";
		}
		ud_local->csEngine->m_messageMutex.unlock();

		usleep(ud_local->msgRefreshTime);
	}
	qDebug() << "messageListDispatcher quit";
}

void CsoundEngine::flushQueues()
{
	m_messageMutex.lock();
#ifdef CSOUND6
	int count = csoundGetMessageCnt(ud->csound);
	for (int i = 0; i < count; i++) {
		messageQueue << csoundGetFirstMessage(ud->csound);
		// FIXME: Is this thread safe?
		csoundPopFirstMessage(ud->csound);
	}
#endif
	while (!messageQueue.isEmpty()) {
		QString msg = messageQueue.takeFirst();
		for (int i = 0; i < ud->csEngine->consoles.size(); i++) {
			ud->csEngine->consoles[i]->appendMessage(msg);
		}
		ud->wl->appendMessage(msg);
    }
    m_messageMutex.unlock();
	ud->wl->flushGraphBuffer();
//	qApp->processEvents();
}

void CsoundEngine::queueMessage(QString message)
{
	m_messageMutex.lock();
	messageQueue << message;
	m_messageMutex.unlock();
}

void CsoundEngine::recordBuffer()
{
	if (m_recording) {
		if (ud->audioOutputBuffer.copyAvailableBuffer(m_recBuffer, m_recBufferSize)) {
			int samps = m_outfile->write(m_recBuffer, m_recBufferSize);
			samplesWritten += samps;
		}
		else {
			//       qDebug("CsoundQt::recordBuffer() : Empty Buffer!");
		}
		recordTimer.singleShot(20, this, SLOT(recordBuffer()));
	}
	else { //Stop recording
		delete m_outfile;
		qDebug("Recording stopped. Written %li samples", samplesWritten);
	}
}

bool CsoundEngine::isRunning()
{
	QMutexLocker locker(&m_playMutex);
	return (ud->perfThread && (ud->perfThread->GetStatus() == 0));
}

bool CsoundEngine::isRecording()
{
	return m_recording;
}

CSOUND *CsoundEngine::getCsound()
{
	return ud->csound;
}

#ifdef QCS_PYTHONQT
void CsoundEngine::registerProcessCallback(QString func, int skipPeriods)
{
	ud->m_pythonCallback = func;
	ud->m_pythonCallbackSkip = skipPeriods;
}

void CsoundEngine::setPythonConsole(PythonConsole *pc)
{
	ud->m_pythonConsole = pc;
}

#endif
