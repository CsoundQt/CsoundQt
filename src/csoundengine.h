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
#include <sndfile.hh>
#include <csPerfThread.hpp>
#include <cwindow.h> // Necessary for WINDAT struct

#include "types.h"
#include "csoundoptions.h"
#ifdef QCS_PYTHONQT
#include "pythonconsole.h"
#endif

//#include <QtCore>
#include <QTimer>
#include <QFuture>

class ConsoleWidget;
class QuteScope;
class QuteGraph;
class Curve;
class CsoundEngine;
class WidgetLayout;

// Csound 5.10 needs to be destroyed for opcodes like ficlose to flush the output
// This still necessary for 5.12
#define QCS_DESTROY_CSOUND

typedef enum {
  QCS_NO_FLAGS = 0,
  QCS_NO_COPY_BUFFER = 1,
  QCS_NO_PYTHON_CALLBACK = 2,
  QCS_NO_CONSOLE_MESSAGES = 4,
  QCS_NO_RT_EVENTS = 8
} PerfFlags;

struct CsoundUserData {
  int result; //result of csoundCompile()
  CSOUND *csound; // instance of csound
  CsoundPerformanceThread *perfThread;
  CsoundEngine *csEngine; // Pass engine
  WidgetLayout *wl; // Pass widgets
  /* performance */
  // PERF_STATUS stores performance state when run in the same thread. Should not be used when threaded.
  int PERF_STATUS; //0=stopped 1=running
  bool runDispatcher;
  QVector<double> mouseValues;
  RingBuffer audioOutputBuffer;
  bool enableWidgets; // Whether widget values are processed in the callback

  /* current configuration */
  // These should not be changed while Csound is running,
  PerfFlags flags;
  // Store some values to avoid function calls
  MYFLT zerodBFS; //0dBFS value
  int numChnls;
  int sampleRate;
  long outputBufferSize;
  bool threaded; // Whether running in a separate thread or not
  int msgRefreshTime; // In micro seconds

  // Channels are only queried at the start of run, so only channels defined in instr 0 are available
  QList<QString> inputChannelNames;
  QList<QString> outputChannelNames;
  QList<QString> outputStringChannelNames;
  QList<QVariant> previousOutputValues;
  QList<QVariant> previousStringOutputValues;


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
    void enableWidgets(bool enable);
    void setInitialDir(QString initialDir);

    void registerConsole(ConsoleWidget *c);  // Messages generated by Csound and QuteCsound are passed to the consoles registered here, and nowhere else
    QList<QPair<int, QString> > getErrorLines();
    void setConsoleBufferSize(int size);
    int popKeyPressEvent();
    int popKeyReleaseEvent();

    void processEventQueue();
    void passOutValue(QString channelName, double value);
    void passOutString(QString channelName, QString value);
    void queueMessage(QString message);
    void flushQueues();

    bool isRunning();
    bool isRecording();

    // To pass to parent document for access from python scripting
    CSOUND * getCsound();
#ifdef QCS_PYTHONQT
    void registerProcessCallback(QString func, int skipPeriods);
    void setPythonConsole(PythonConsole *pc);
#endif


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
    void setFlags(PerfFlags flags) {ud->flags = flags;}

  private:
    int runCsound();
    void stopCsound();

    void cleanupCsound();

    QFuture<void> m_msgUpdateThread;
    static void messageListDispatcher(void *data); // Function run in updater thread

    CsoundUserData *ud;

    SndfileHandle *m_outfile;
    long samplesWritten;
    bool m_recording;
    MYFLT *m_recBuffer; // for temporary copy of Csound output buffer when recording to file
    int m_recBufferSize; // size of the record buffer
    QTimer recordTimer;
    QString m_initialDir;

    CsoundOptions m_options;
    // Options which are not safe to pass while running are stored in these
    // variables to pass on next run.
    bool m_threaded;

    MYFLT *pFields; // array of pfields for score and rt events

    QVector<ConsoleWidget *> consoles;  // Consoles registered for message printing
    int m_consoleBufferSize;
    QMutex m_messageMutex; // Protection for message queue
    QStringList messageQueue;  // Messages from Csound execution
    QMutex keyMutex; // For keys pressed to pass to Csound from console and widget panel
    QStringList keyPressBuffer; // protected by keyMutex
    QStringList keyReleaseBuffer; // protected by keyMutex

    QMutex eventMutex;
    QVector<QString> eventQueue;
    int m_refreshTime; // time in milliseconds for widget value updates (both input and output)
    QVector<unsigned long> eventTimeStamps;
    int eventQueueSize;

  private slots:
    void recordBuffer();
//    void widgetLayoutDestroyed();

  signals:
    void errorLines(QList<QPair<int, QString> >);
    void passMessages(QString msg);
    void stopSignal(); // Sent when performance has stopped internally to inform others.playFromParent()
};

#endif // CSOUNDENGINE_H
