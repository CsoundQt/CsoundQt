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

//Based on the csPerfThread.cpp by Istvan Varga

#ifndef QCSPERFTHREAD_H
#define QCSPERFTHREAD_H


#include <QMutex>
#include <csound.hpp>

class CsoundPerformanceThreadMessage;
class CsPerfThread_PerformScore;

class QCsPerfThread {
  public:
    QCsPerfThread(Csound *);
    QCsPerfThread(CSOUND *);
    ~QCsPerfThread();
    void csPerfThread_constructor(CSOUND *csound);

    int isRunning() { return running;}

   void *GetProcessCallback() { return (void *)processcallback; }
   void SetProcessCallback(void (*Callback)(void *), void *cbdata){
    processcallback = Callback;
    cdata = cbdata;
   }

    CSOUND *GetCsound() { return csound; }

    int GetStatus() { return status; }
    void Play();
    void Pause();
    void TogglePause();
    void Stop();

    /**
     * Sends a score event of type 'opcod' (e.g. 'i' for a note event), with
     * 'pcnt' p-fields in array 'p' (p[0] is p1). If absp2mode is non-zero,
     * the start time of the event is measured from the beginning of
     * performance, instead of the default of relative to the current time.
     */
    void ScoreEvent(int absp2mode, char opcod, int pcnt, const MYFLT *p);
    /**
     * Sends a score event as a string, similarly to line events (-L).
     */
    void InputMessage(const char *s);
    /**
     * Sets the playback time pointer to the specified value (in seconds).
     */
    void SetScoreOffsetSeconds(double timeVal);
    /**
     * Waits until the performance is finished or fails, and returns a
     * positive value if the end of score was reached or Stop() was called,
     * and a negative value if an error occured. Also releases any resources
     * associated with the performance thread object.
     */
    int Join();
    /**
     * Waits until all pending messages (pause, send score event, etc.)
     * are actually received by the performance thread.
     */
    void FlushMessageQueue();
    friend class CsoundPerformanceThreadMessage;
    friend class CsPerfThread_PerformScore;
  private:
     volatile CsoundPerformanceThreadMessage *firstMessage;
     CsoundPerformanceThreadMessage *lastMessage;
     CSOUND  *csound;
     void * queueLock;         // this is actually a mutex
     void * pauseLock;
     void * flushLock;
     void    *perfThread;
     int     paused;
     int     status;
     void *    cdata;
     int  running;
     // --------
     int  Perform();
     void QueueMessage(CsoundPerformanceThreadMessage *);
     void (*processcallback)(void *cdata);
};


#endif // QCSPERFTHREAD_H
