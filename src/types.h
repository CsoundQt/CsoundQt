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

#ifndef TYPES_H
#define TYPES_H

#include <QMutex>
#include <QtGlobal>
#include <QDebug>
#include <csound.h>

#define QCS_VERSION "0.9.3"

// Time in milliseconds for widget and console messages updates
#define QCS_QUEUETIMER_DEFAULT_TIME 50
// Maximum number of files in recent files menu
#define QCS_MAX_RECENT_FILES 20
// Maximum undo history depth for widget panel and event sheet
#define QCS_MAX_UNDO 256

// Maximum MIDI message queue size for internal control
#define QCS_MAX_MIDI_QUEUE 128

#ifdef Q_OS_LINUX
#define DEFAULT_HTML_DIR "/usr/share/doc/csound-doc/html"
#define DEFAULT_TERM_EXECUTABLE "/usr/bin/xterm"
#define DEFAULT_BROWSER_EXECUTABLE "/usr/bin/firefox"
#define DEFAULT_WAVEEDITOR_EXECUTABLE "/usr/bin/audacity"
#define DEFAULT_WAVEPLAYER_EXECUTABLE "/usr/bin/aplay"
#define DEFAULT_PDFVIEWER_EXECUTABLE "/usr/bin/evince"
#define DEFAULT_DOT_EXECUTABLE "dot"
#define DEFAULT_LOG_FILE ""
#define DEFAULT_SCRIPT_DIR "../../csoundqt/src/Scripts"
#endif
#ifdef Q_OS_SOLARIS
#define DEFAULT_HTML_DIR "/usr/local/share/doc/csound/html"
#define DEFAULT_TERM_EXECUTABLE "/usr/openwin/bin/xterm"
#define DEFAULT_BROWSER_EXECUTABLE "/usr/bin/firefox"
#define DEFAULT_WAVEEDITOR_EXECUTABLE "/usr/local/bin/audacity"
#define DEFAULT_WAVEPLAYER_EXECUTABLE "/usr/bin/jmplay"
#define DEFAULT_PDFVIEWER_EXECUTABLE "/usr/bin/evince"
#define DEFAULT_DOT_EXECUTABLE "dot"
#define DEFAULT_LOG_FILE ""
#define DEFAULT_SCRIPT_DIR "../../csoundqt/src/Scripts"
#endif
#ifdef Q_OS_MAC
#define DEFAULT_HTML_DIR "/Library/Frameworks/CsoundLib64.framework/Resources/Manual"
#define DEFAULT_TERM_EXECUTABLE "/Applications/Utilities/Terminal.app"
#define DEFAULT_BROWSER_EXECUTABLE "/Applications/Firefox.app"
#define DEFAULT_WAVEEDITOR_EXECUTABLE "/Applications/Audacity.app"
#define DEFAULT_WAVEPLAYER_EXECUTABLE "/Applications/QuickTime Player.app"
#define DEFAULT_PDFVIEWER_EXECUTABLE "/Applications/Preview.app"
#define DEFAULT_DOT_EXECUTABLE "/usr/local/bin/dot"
#define DEFAULT_LOG_FILE ""
#define DEFAULT_SCRIPT_DIR qApp->applicationDirPath() + "/../Resources/Scripts"
#endif
#ifdef Q_OS_WIN32
#define DEFAULT_HTML_DIR "C:/Program Files/Csound/doc/manual"
#define DEFAULT_TERM_EXECUTABLE "cmd.exe"
#define DEFAULT_BROWSER_EXECUTABLE ""
#define DEFAULT_WAVEEDITOR_EXECUTABLE ""
#define DEFAULT_WAVEPLAYER_EXECUTABLE ""
#define DEFAULT_PDFVIEWER_EXECUTABLE ""
#define DEFAULT_DOT_EXECUTABLE ""
#define DEFAULT_LOG_FILE ""
#define DEFAULT_SCRIPT_DIR qApp->applicationDirPath() + "/Scripts"
#endif
#ifdef Q_OS_HAIKU
#define DEFAULT_HTML_DIR "/boot/common/share/doc/csound-doc/html"
#define DEFAULT_TERM_EXECUTABLE "Terminal"
#define DEFAULT_BROWSER_EXECUTABLE "/boot/apps/WebPositive/WebPositive"
#define DEFAULT_WAVEEDITOR_EXECUTABLE ""
#define DEFAULT_WAVEPLAYER_EXECUTABLE "/boot/system/apps/MediaPlayer"
#define DEFAULT_PDFVIEWER_EXECUTABLE "/boot/apps/BePDF/BePDF"
#define DEFAULT_DOT_EXECUTABLE "dot"
#define DEFAULT_LOG_FILE ""
#endif

#define QCS_DEFAULT_TEMPLATE "<CsoundSynthesizer>\n<CsOptions>\n</CsOptions>\n<CsInstruments>\n\nsr = 44100\nksmps = 128\nnchnls = 2\n0dbfs = 1.0\n\n\n</CsInstruments>\n<CsScore>\n\n</CsScore>\n</CsoundSynthesizer>"


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
	QString desc;
};

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

	void lock() {
		mutex.lock();
	}

	void unlock() {
		mutex.unlock();
	}

	void put(MYFLT value) {
		//qDebug() << "RingBuffer::put";
		mutex.lock();
		//qDebug() << "RingBuffer::put lock";
		//lock = true;
		//	  qDebug() << "RingBuffer::put currentPos " << currentPos << " value " << value;
		buffer[currentPos] = value;
		currentPos++;
		//       if (currentPos == currentReadPos) {
		//         qDebug("RingBuffer: Buffer overflow!");
		//       }
		if (currentPos >= size)
			currentPos = 0;
		mutex.unlock();
	}

	bool copyAvailableBuffer(MYFLT *data, int saveSize) {
		//		qDebug() << "RingBuffer::copyAvailableBuffer saveSize " << saveSize << " currentPos " << currentPos << " currentReadPos " << currentReadPos ;
		mutex.lock();
		//qDebug() << "RingBuffer::copyAvailableBuffer lock";
		int available = (currentReadPos <= currentPos ?
							 currentPos - currentReadPos :  currentPos - currentReadPos + size);
		//       qDebug("RingBuffer: Available: %i", available);
		if (available <= saveSize) { //not enough data in buffer
			mutex.unlock();
			return false;
		}
		for (int i = 0; i < saveSize; i++) {
			//         qDebug("RingBuffer: currentPos %li currentReadPos %li value %f", currentPos, currentReadPos, buffer[currentReadPos%size]);
			data[i] = buffer[currentReadPos];
			currentReadPos++;
			if (currentReadPos == size) {
				currentReadPos = 0;
			}
		}
		mutex.unlock();
		return true;
	}

	void resize(int size) {
		mutex.lock();
		buffer.clear();
		for (int i = 0; i< size; i++) {
			buffer.append(0.0);
		}
		currentPos = 0;
		mutex.unlock();
	}

	void  allZero() {
		mutex.lock();
		for (int i = 0; i< buffer.size(); i++) {
			buffer[i] = 0;
		}
		currentReadPos = 0;
		currentPos = 0;
		mutex.unlock();
	}
};

#endif
