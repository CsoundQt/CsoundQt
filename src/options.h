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

#ifndef OPTIONS_H
#define OPTIONS_H

#include <QString>
#include <QColor>

#include "csoundoptions.h"

class Options: public CsoundOptions{
public:
	Options(ConfigLists *configlists);
	~Options();

	QString theme;  // Icon theme name
	QString font;
	float fontPointSize;
	bool showLineNumberArea;
	int lineEnding; // 0=Unix (LF) 1=Windows(CR+LF)
	QString consoleFont;
	float consoleFontPointSize;
	QColor consoleFontColor;
	QColor consoleBgColor;
	QColor editorBgColor;
	int tabWidth;
	bool tabIndents;
	bool colorVariables;
	bool autoPlay;
	bool autoJoin;
	bool saveChanges;
	bool rememberFile;
	bool saveWidgets;
	bool iconText;
	bool showToolbar;
    bool lockToolbar;
	bool wrapLines;
	bool autoComplete;
	bool autoParameterMode;
    bool tabShortcutActive;

	bool showWidgetsOnRun;
	bool showTooltips;
	bool terminalFLTK;
	bool oldFormat;  // Store old MacCsound widget format
	bool openProperties;  // Open properties automatically when creating a widget
	double fontScaling;
	double fontOffset;

	bool useAPI;
	bool enableWidgets;
	bool widgetsIndependent;  // Widget layouts in Separate Window (instead of Dock Widget)
	bool useInvalue; // If false use chnget
	bool keyRepeat;
	bool debugLiveEvents;
	int consoleBufferSize;
	int midiInterface;
	QString midiInterfaceName;
	int midiOutInterface;
	QString midiOutInterfaceName;
	int rtMidiApi; // "UNSPECIFIED" | "LINUX_ALSA" | "UNIX_JACK" | "MACOSX_CORE" | "WINDOWS_MM" see RtMidi.h
	// Csound engine flags
	bool noBuffer;
	bool noPython;
	bool noMessages;
	bool noEvents;

	QString csdPath; //path of active csd needed for setting -o -i paths

	int menuDepth;
	QString defaultCsd;
	bool defaultCsdActive;
	QString opcodexmldir;
	bool opcodexmldirActive;
	QString favoriteDir;
	QString pythonDir;
	QString pythonExecutable;
	QString csoundExecutable;
	QString logFile;
	QString sdkDir;
	QString templateDir;

	typedef enum {
		CS_ORC = 0x01,
		CS_SCORE = 0x02,
		PYTHON = 0x04,
		LUA = 0x08,
		QML = 0x0F
	} CodeLanguage;

	CodeLanguage evalLanguage;
	// External applications
	QString terminal;
	QString browser;
	QString dot;
	QString waveeditor;
	QString waveplayer;
	QString pdfviewer;
	int language;  // Interface language

	QString csdTemplate;

	quint16 debugPort;


	// Csound Utilities options
	QString cvInputName;
	QString cvOutputName;
	QString cvSampleRate;
	QString cvBeginTime;
	QString cvDuration;
	QString cvChannels;

	QString hetInputName;
	QString hetOutputName;
	QString hetSampleRate;
	QString hetChannel;
	QString hetBeginTime;
	QString hetDuration;
	QString hetStartFrequency;
	QString hetNumPartials;
	QString hetMaxAmplitude;
	QString hetMinAplitude;
	QString hetNumBreakPoints;
	QString hetFilterCutoff;

	QString lpInputName;
	QString lpOutputName;
	QString lpSampleRate;
	QString lpChannel;
	QString lpBeginTime;
	QString lpDuration;
	QString lpNumPoles;
	QString lpHopSize;
	QString lpLowestFreq;
	int lpVerbosity;
	bool lpAlternateStorage;

	QString pvInputName;
	QString pvOutputName;
	QString pvSampleRate;
	QString pvChannel;
	QString pvBeginTime;
	QString pvDuration;
	QString pvFrameSize;
	QString pvOverlap;
	int pvWindow;
	QString pvBeta;

	QString atsInputName;
	QString atsOutputName;
	QString atsBeginTime;
	QString atsEndTime;
	QString atsLowestFreq;
	QString atsHighestFreq;
	QString atsFreqDeviat;
	QString atsWinCycle;
	QString atsHopSize;
	QString atsLowestMag;
	QString atsTrackLen;
	QString atsMinSegLen;
	QString atsMinGapLen;
	QString atsSmrThresh;
	QString atsLastPkCon;
	QString atsSmrContr;
	int atsFileType;
	int atsWindow;
};

#endif
