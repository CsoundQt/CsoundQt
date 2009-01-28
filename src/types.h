/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/

#ifndef TYPES_H
#define TYPES_H

#include <QMutex>
// #include <QStringList>
#include "configlists.h"

// Time in milliseconds for widget and console messages updates
#define QCS_QUEUETIMER_TIME 50

#ifdef LINUX
#define DEFAULT_HTML_DIR "/usr/local/share/doc/csound/html"
#define DEFAULT_TERM_EXECUTABLE "/usr/bin/xterm"
#define DEFAULT_BROWSER_EXECUTABLE "/usr/bin/firefox"
#define DEFAULT_WAVEEDITOR_EXECUTABLE "/usr/bin/audacity"
#define DEFAULT_WAVEPLAYER_EXECUTABLE "/usr/bin/aplay"
#define DEFAULT_DOT_EXECUTABLE "dot"
#endif
#ifdef SOLARIS
#define DEFAULT_HTML_DIR "/usr/local/share/doc/csound/html"
#define DEFAULT_TERM_EXECUTABLE "/usr/openwin/bin/xterm"
#define DEFAULT_BROWSER_EXECUTABLE "/usr/bin/firefox"
#define DEFAULT_WAVEEDITOR_EXECUTABLE "/usr/local/bin/audacity"
#define DEFAULT_WAVEPLAYER_EXECUTABLE "/usr/bin/jmplay"
#define DEFAULT_DOT_EXECUTABLE "dot"
#endif
#ifdef MACOSX
#define DEFAULT_HTML_DIR "/Library/Frameworks/CsoundLib.framework/Versions/5.1/Resources/Manual"
#define DEFAULT_TERM_EXECUTABLE "/Applications/Utilities/Terminal.app"
#define DEFAULT_BROWSER_EXECUTABLE "/Applications/Firefox.app"
#define DEFAULT_WAVEEDITOR_EXECUTABLE "/Applications/Audacity.app"
#define DEFAULT_WAVEPLAYER_EXECUTABLE "/Applications/QuickTime Player.app"
#define DEFAULT_DOT_EXECUTABLE "/Applications/Graphviz.app/Contents/MacOS/dot"
#endif
#ifdef WIN32
#define DEFAULT_HTML_DIR "C:/Program Files/Csound/doc/manual"
#define DEFAULT_TERM_EXECUTABLE "cmd.exe"
#define DEFAULT_BROWSER_EXECUTABLE "firefox.exe"
#define DEFAULT_WAVEEDITOR_EXECUTABLE "audacity.exe"
#define DEFAULT_WAVEPLAYER_EXECUTABLE "wmplayer.exe"
#define DEFAULT_DOT_EXECUTABLE "dot.exe"
#endif

#include <csound.h>

enum viewMode {
  VIEW_CSD,
  VIEW_ORC_SCO
};

class Opcode
{
  public:
    QString outArgs;
    QString opcodeName;
    QString inArgs;
};

class qutecsound;

struct CsoundUserData{
  int result; //result of csoundCompile()
  CSOUND *csound; // instance of csound
  /*performance status*/
  bool PERF_STATUS; //0= stopped 1=running
  qutecsound *qcs; //pass main application to check widgets
  MYFLT zerodBFS; //0dBFS value
  long outputBufferSize;
  MYFLT* outputBuffer;
  int numChnls;
  int sampleRate;
};

static ConfigLists _configlists;

class RingBuffer
{
  public:
    RingBuffer() {
      size = 8192*4;
      resize(size);
      currentPos = 0;
      currentReadPos = 0;
//       lock = false;
    }
    ~RingBuffer() {}
//     bool lock;
    QList<MYFLT> buffer;
    long currentPos;
    long currentReadPos;
    int size;
    QMutex mutex;

    void put(MYFLT value) {
	  //qDebug() << "RingBuffer::put";
      mutex.lock();
	  //qDebug() << "RingBuffer::put lock";
      //lock = true;
      buffer[currentPos] = value;
      currentPos++;
      if (currentPos == currentReadPos) {
//         qDebug("RingBuffer: Buffer overflow!");
      }
      if (currentPos >= buffer.size())
        currentPos = 0;
      mutex.unlock();
    }

    bool copyAvailableBuffer(MYFLT *data, int saveSize) {
	  //qDebug() << "RingBuffer::copyAvailableBuffer";
      mutex.lock();
	  //qDebug() << "RingBuffer::copyAvailableBuffer lock";
      currentReadPos = currentReadPos%size;
      int available = (currentReadPos <= currentPos ?
          currentPos - currentReadPos :  currentPos - currentReadPos + size);
//       qDebug("RingBuffer: Available: %i", available);
      if (available <= saveSize) { //not enough data in buffer
	    mutex.unlock();
        return false;
      }
      for (int i = 0; i < saveSize; i++) {
//         qDebug("RingBuffer: currentPos %li currentReadPos %li value %f", currentPos, currentReadPos, buffer[currentReadPos%size]);
        data[i] = buffer[currentReadPos%size];
        currentReadPos++;
      }
      mutex.unlock();
      return true;
    }

    void resize(int size) {
      buffer.clear();
      for (int i = 0; i< size; i++) {
        buffer.append(0.0);
      }
      currentPos = 0;
    }

    void  allZero() {
      for (int i = 0; i< buffer.size(); i++) {
        buffer[i] = 0;
      }
      currentPos = 0;
    }
};

#endif
