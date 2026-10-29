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
#include "channelhighlightmode.h"

class Options: public CsoundOptions{
public:
	Options(ConfigLists *configlists);
	~Options();

    QString theme;  // Icon theme name TODO: rename to iconTheme
    QString themeMode; // application theme: "auto", "dark", "light"
    QString widgetStyle; // Qt widget style ("Fusion", "Breeze", ...); empty = default
	QString font;
	float fontPointSize;
	bool showLineNumberArea;
	// Line number contrast against the gutter background: 0 = invisible,
	// 100 = full editor foreground colour.
	int lineNumberContrast;
	QString consoleFont;
	float consoleFontPointSize;
	QColor consoleFontColor;
	QColor consoleBgColor;
	QColor editorBgColor;
	bool tabUseSpaces;  // insert spaces instead of a tab character when Tab is pressed
	int tabSpaces;      // tab size in spaces: how many spaces a tab is equivalent
	                    // to, both for insertion and for the display width of tabs
	int editorPadding;  // padding around the editor text, in pixels
	bool colorVariables;
    // Editor syntax theme chosen by the user: "auto" follows the application
    // theme, otherwise a theme id such as "light" or "dark" is forced.
    QString editorTheme;
    // Resolved editor theme actually handed to the documents (never "auto").
    QString highlightingTheme;
	bool autoJoin;
	bool midiCcToCurrentPageOnly;
	bool saveChanges;
	bool quitOnLastTabClosed; // exit instead of opening an empty document
    // Prepend the current tab's file name to the window title.
    bool includeActiveFileInTitle;
    // When a panel is toggled on, move the keyboard focus to it. Off (the
    // default) keeps the focus where it was, e.g. in the editor.
    bool focusToggledPanel;
	bool rememberFile;
	bool iconText;
	bool showToolbar;
    bool lockToolbar;
    int  toolbarIconSize;
	bool wrapLines;
	bool showScrollBar;
	bool autoComplete;
    int autoCompleteDelay;
    // Show the quick reference card when the pointer rests on an opcode, UDO or
    // instrument, without pressing Ctrl. Ctrl+hover works in either case.
    bool quickHelpOnHover;
    // Delay before that card appears, in milliseconds; 0 shows it at once.
    int quickHelpHoverDelay;
    // Width of the autocomplete menu, in characters of the entries it lists.
    int autocompleteMenuWidth;
    // Maximum number of rows visible in the autocomplete popup; the rest of
    // the list is reached by scrolling.
    int autocompleteMenuMaxLines;
	bool autoParameterMode;
    bool tabShortcutActive;
    bool tabShowCloseButton;

    bool highlightScore;

	bool showWidgetsOnRun;
	bool showTooltips;
    int graphUpdateRate;
	bool openProperties;  // Open properties automatically when creating a widget
	// Edit-mode widget frame border colours (Settings/Widgets). The unselected
	// colour may carry an alpha; the selected one is opaque and also drives the
	// resize handle colour.
	QColor widgetFrameColorUnselected;
	QColor widgetFrameColorSelected;

	bool useAPI;
	bool enableWidgets;
	bool widgetsIndependent;  // Widget layouts in Separate Window (instead of Dock Widget)
	ChannelHighlightMode channelHighlightMode = ChannelHighlightMode::CursorOnly;
	ChannelReferenceHighlightMode channelReferenceHighlightMode = ChannelReferenceHighlightMode::Always;
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
	bool noMessages;
	bool noEvents;

	QString csdPath; //path of active csd needed for setting -o -i paths

	int menuDepth;
	QString defaultCsd;
	bool defaultCsdActive;
	QString opcodexmldir;
	bool opcodexmldirActive;
    QString examplePath;
	QString csoundExecutable;
	bool logDebug;  // write CsoundQt's own debug output to a log file

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
