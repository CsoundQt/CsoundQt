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

#include <QtCore>
#include <csound.hpp>
#include <sndfile.hh>
#include <cwindow.h> // Necessary for WINDAT struct

#include "types.h"
#include "csoundoptions.h"
#include "qcsperfthread.h"
#ifdef QCS_PYTHONQT
#include "pythonconsole.h"
#endif

class ConsoleWidget;
class QuteScope;
class QuteGraph;
class Curve;
class CsoundEngine;
class WidgetLayout;

// Csound 5.10 needs to be destroyed for opcodes like ficlose to flush the output
// This still necessary for 5.12
#define QCS_DESTROY_CSOUND

struct CsoundUserData {
  int result; //result of csoundCompile()
  CSOUND *csound; // instance of csound
  QCsPerfThread *perfThread;
  CsoundEngine *cs; // Pass engine
  WidgetLayout *wl; // Pass widgets
  /* current configuration */
  MYFLT zerodBFS; //0dBFS value
  int numChnls;
  int sampleRate;
  long outputBufferSize;
  /* performance */
  // PERF_STATUS stores performance state when run in the same thread. Should not be used when threaded.
  int PERF_STATUS; //0=stopped 1=running
  MYFLT* outputBuffer;

  bool enableWidgets; // Whether widget values are processed in the callback
  bool threaded; // Whether running in a separate thread or not
  bool useInvalue; // To select between invalue/outvalue and chnget/chnset

  QVector<QString> channelNames;
  QVector<double> values;
  QVector<QString> stringValues;
  QVector<double> mouseValues;
  RingBuffer audioOutputBuffer;
  unsigned long ksmpscount;  // Use this or rely on the csound time counter? Is using this more efficient, since it is called so often?
#ifdef QCS_PYTHONQT
  PythonConsole *m_pythonConsole;
  QString m_pythonCallback;
  int m_pythonCallbackCounter;
  int m_pythonCallbackSkip;
#endif
};

class CsoundEngine : public QObject
{
  Q_OBJECT
  public:
    CsoundEngine();
    ~CsoundEngine();
    static void messageCallbackNoThread(CSOUND *csound,
                                         int attr,
                                         const char *fmt,
                                         va_list args);
    static void messageCallbackThread(CSOUND *csound,
                                         int attr,
                                         const char *fmt,
                                         va_list args);
//    static void outputValueCallbackThread (CSOUND *csound,
//                                    const char *channelName,
//                                    MYFLT value);
//    static void inputValueCallbackThread (CSOUND *csound,
//                                   const char *channelName,
//                                   MYFLT *value);
    static void outputValueCallback (CSOUND *csound,
                                    const char *channelName,
                                    MYFLT value);
    static void inputValueCallback (CSOUND *csound,
                                   const char *channelName,
                                   MYFLT *value);

    static void makeGraphCallback(CSOUND *csound, WINDAT *windat, const char *name);
    static void drawGraphCallback(CSOUND *csound, WINDAT *windat);
    static void killGraphCallback(CSOUND *csound, WINDAT *windat);
    static int exitGraphCallback(CSOUND *csound);
//     static void ioCallback (CSOUND *csound,
//                             const char *channelName,
//                             MYFLT *value,
//                             int channelType);
    static int keyEventCallback(void *userData,
                                void *p,
                                unsigned int type);
    static void csThread(void *data);  //Thread function (called after each performance pass by the performance thread)

    static void readWidgetValues(CsoundUserData *ud);
    static void writeWidgetValues(CsoundUserData *ud);

//    void setCsoundOptions(const CsoundOptions &options);
    // Options unsafe to change while running
    void setWidgetLayout(WidgetLayout *wl);
    void setThreaded(bool threaded);
    // Options safe to change while running
    void useInvalue(bool use);
    void enableWidgets(bool enable);
    void setInitialDir(QString initialDir);
    void freeze(); // Freeze timers before destroying to avoid access to other destroyed data (e.g. scope data, widget panel, etc.)

    void registerConsole(ConsoleWidget *c);  // Messages generated by Csound and QuteCsound are passed to the consoles registered here, and nowhere else
    void unregisterConsole(ConsoleWidget *c);
    QList<QPair<int, QString> > getErrorLines();
    void setConsoleBufferSize(int size);
    int popKeyPressEvent();
    int popKeyReleaseEvent();

    void processEventQueue();
    void passOutValue(QString channelName, double value);
    void passOutString(QString channelName, QString value);
    void queueMessage(QString message);
    void clearMessageQueue();
    void flushQueues();

    bool isRunning();
    bool isRecording();

    // To pass to parent document for access from python scripting
    CSOUND * getCsound();
#ifdef QCS_PYTHONQT
    void registerProcessCallback(QString func, int skipPeriods);
    void setPythonConsole(PythonConsole *pc);
#endif

    QMutex perfMutex;  // TODO is this still needed?
//    QTimer qTimer;  // This 4timer is started and stopped from the document page

  public slots:
    int play(CsoundOptions *options);
    void stop();
    void pause();
    int startRecording(int format, QString filename);
    void stopRecording();
    void queueEvent(QString eventLine, int delay = 0);
    void keyPressForCsound(QString key);  // For key press events from consoles and widget panel
    void keyReleaseForCsound(QString key);

    void registerScope(QuteScope *scope);
//    void unregisterScope(QuteScope *scope);
    void registerGraph(QuteGraph *scope);

  private:
    int runCsound();
    void stopCsound();

    CsoundUserData *ud;

    SndfileHandle *m_outfile;
    long samplesWritten;
    bool m_recording;
    MYFLT *recBuffer; // for temporary copy of Csound output buffer when recording to file
    int bufferSize; // size of the record buffer
    QTimer recordTimer;
    QString m_initialDir;

    CsoundOptions m_options;
    // Options which are not safe to pass while running are stored in these
    // variables to pass on next run.
    bool m_threaded;

    MYFLT *pFields; // array of pfields for score and rt events

    QVector<ConsoleWidget *> consoles;  // Consoles registered for message printing
    int m_consoleBufferSize;
    QMutex messageMutex; // Protection for message queue
    QStringList messageQueue;  // Messages from Csound execution
    QMutex keyMutex; // For keys pressed to pass to Csound from console and widget panel
    QStringList keyPressBuffer; // protected by keyMutex
    QStringList keyReleaseBuffer; // protected by keyMutex
    QMutex engineMutex; // To protect when closing

    QMutex eventMutex;
    QVector<QString> eventQueue;
    int refreshTime; // time in milliseconds for widget value updates (both input and output)
    QVector<unsigned long> eventTimeStamps;
    int eventQueueSize;

    int closing; // to notify timer this class is being destroyed

  private slots:
    void recordBuffer();
    void dispatchQueues();
//    void widgetLayoutDestroyed();

  signals:
    void errorLines(QList<QPair<int, QString> >);
    void stopSignal(); // Sent when performance has stopped internally to inform others.playFromParent()
};

#endif // CSOUNDENGINE_H
