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

#ifndef OPTIONS_H
#define OPTIONS_H

#include <QString>
#include <QColor>

#include "csoundoptions.h"

class Options: public CsoundOptions{
  public:
    Options();
    ~Options();

    QString font;
    float fontPointSize;
    QString consoleFont;
    float consoleFontPointSize;
    QColor consoleFontColor;
    QColor consoleBgColor;
    int tabWidth;
    bool colorVariables;
    bool autoPlay;
    bool saveChanges;
    bool rememberFile;
    bool saveWidgets;
    bool iconText;
    bool showToolbar;
    bool wrapLines;
    bool autoComplete;

    bool showWidgetsOnRun;
    bool showTooltips;
    bool terminalFLTK;
    bool oldFormat;  // Store old MacCsound widget format

    bool useAPI;
    bool enableWidgets;
    bool useInvalue; // If false use chnget
    bool thread;
    bool keyRepeat;
    bool debugLiveEvents;
    int consoleBufferSize;

    QString csdPath; //path of active csd needed for setting -o -i paths

    QString defaultCsd;
    bool defaultCsdActive;
    QString opcodexmldir;
    bool opcodexmldirActive;
    QString favoriteDir;
    QString pythonDir;
    QString logFile;

    // External applications
    QString terminal;
    QString browser;
    QString dot;
    QString waveeditor;
    QString waveplayer;
    QString pdfviewer;
    int language;  // Interface language
    
};

#endif
