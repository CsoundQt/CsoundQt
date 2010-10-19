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

#include "options.h"
// #include "configlists.h"
#include "types.h"
#include "stdlib.h"

Options::Options()
{
  font = "Courier";
  fontPointSize = 10;
  lineEnding = 0; // 0=Unix (LF) 1=Windows(CR+LF)
  consoleFont = "Courier";
  consoleFontPointSize = 10;
  consoleFontColor = Qt::black;
  consoleBgColor = Qt::white;
  tabWidth = 8;
  colorVariables = true;
  autoPlay = true;
  autoJoin = false;
  saveChanges = true;
  rememberFile = true;
  saveWidgets = true;
  iconText = true;
  showToolbar = true;
  wrapLines = true;
  autoComplete = true;

  showWidgetsOnRun = true;
  showTooltips = false;
  terminalFLTK = false;
  oldFormat = false;  // Store old MacCsound widget format
  openProperties = true;  // Open properties automatically when creating a widget
  fontScaling = 1.0;
  fontOffset = 0.0;

  useAPI = true;
  enableWidgets = true;
  widgetsIndependent = true;  // Widget layouts in Separate Window (instead of Dock Widget)
  useInvalue = true; // If false use chnget
  thread = true;
  keyRepeat = true;
  debugLiveEvents = false;
  consoleBufferSize = 1024;
  midiInterface = 0; // For internal QuteCsound MIDI control

  csdPath = "./"; //path of active csd needed for setting -o -i paths

  defaultCsd = "";
  defaultCsdActive = false;
  opcodexmldir = "";
  opcodexmldirActive = false;
  favoriteDir = "";
  pythonDir = "";
  pythonExecutable = "python";
  logFile = "log.txt";

  // External applications
  terminal = "";
  browser = "";
  dot = "";
  waveeditor = "";
  waveplayer = "";
  pdfviewer = "";
  language = 0;  // Interface language

  csdTemplate = "";
}


Options::~Options()
{
}
