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

#ifndef CSOUNDENGINE_H
#define CSOUNDENGINE_H

#include <csound.hpp>
#include <csPerfThread.hpp>
#include "types.h"

// Csound 5.10 needs to be destroyed for opcodes like ficlose to flush the output

#define QUTECSOUND_DESTROY_CSOUND

class CsoundEngine;

struct CsoundUserData{
  int result; //result of csoundCompile()
  CSOUND *csound; // instance of csound
  CsoundPerformanceThread *perfThread;
  CsoundEngine *cs; //pass engine
  /* current configuration */
  MYFLT zerodBFS; //0dBFS value
  int numChnls;
  int sampleRate;
  long outputBufferSize;
  /* performance */
  int PERF_STATUS; //0= stopped 1=running -1=stopping
  MYFLT* outputBuffer;

  QVector<QString> channelNames;
  QVector<double> values;
  QVector<QString> stringValues;
  QVector<double> mouseValues;
  RingBuffer audioOutputBuffer;
  unsigned long ksmpscount;
};

class CsoundEngine
{
  public:
    CsoundEngine();
    ~CsoundEngine();
    static void messageCallback_NoThread(CSOUND *csound,
                                         int attr,
                                         const char *fmt,
                                         va_list args);
    static void messageCallback_Thread(CSOUND *csound,
                                         int attr,
                                         const char *fmt,
                                         va_list args);

    //callbacks for graph drawing based on J. Ramsdell's flcsound
    static void makeGraphCallback(CSOUND *csound, WINDAT *windat, const char *name);
    static void drawGraphCallback(CSOUND *csound, WINDAT *windat);
    static void killGraphCallback(CSOUND *csound, WINDAT *windat);
    static int exitGraphCallback(CSOUND *csound);
    static void outputValueCallback (CSOUND *csound,
                                    const char *channelName,
                                    MYFLT value);
    static void inputValueCallback (CSOUND *csound,
                                   const char *channelName,
                                   MYFLT *value);
//     static void ioCallback (CSOUND *csound,
//                             const char *channelName,
//                             MYFLT *value,
//                             int channelType);
    static int keyEventCallback(void *userData,
                                void *p,
                                unsigned int type);

    static void  csThread(void *data);  //Thread function
    QMutex perfMutex;
    static void readWidgetValues(CsoundUserData *ud);
    static void writeWidgetValues(CsoundUserData *ud);
    static void processEventQueue(CsoundUserData *ud);
    void queueOutValue(QString channelName, double value);
    void queueOutString(QString channelName, QString value);
    void queueMessage(QString message);

    void runCsound(bool realtime);
    void stopCsound();
  private:
    CsoundUserData *ud;
    MYFLT *pFields; // array of pfields for score and rt events

    QStringList tempScriptFiles; //Remember temp files to delete them later

  signals:
    void clearMessageQueueSignal();
};

#endif // CSOUNDENGINE_H
