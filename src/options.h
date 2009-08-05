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
#include "types.h"

class Options{
  public:
    Options();

    ~Options();

    QString generateCmdLineFlags(bool rt = false);
    int generateCmdLine(char **argv,
                        bool rt,
                        QString fileName,
                        QString fileName2);


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
    bool wrapLines;

    bool enableWidgets;
    bool useInvalue; // If false use chnget
    bool showWidgetsOnRun;
    bool showTooltips;
    bool enableFLTK;

    bool useAPI;
    bool thread;

    int bufferSize;
    bool bufferSizeActive;
    int HwBufferSize;
    bool HwBufferSizeActive;
    bool dither;
    QString additionalFlags;
    bool additionalFlagsActive;

    bool fileUseOptions;
    bool fileOverrideOptions;
    bool fileAskFilename;
    bool filePlayFinished;
    int fileFileType;
    int fileSampleFormat;
    bool fileInputFilenameActive;
    QString fileInputFilename;
    bool fileOutputFilenameActive;
    QString fileOutputFilename;
    QString csdPath; //path of active csd needed for setting -o -i paths

    int sampleFormat;

    bool rtUseOptions;
    bool rtOverrideOptions;
    int rtAudioModule;
    QString rtInputDevice;
    QString rtOutputDevice;
    QString rtJackName;
    int rtMidiModule;
    QString rtMidiInputDevice;
    QString rtMidiOutputDevice;

    QString csdocdir;
    QString opcodedir;
    bool opcodedirActive;
    QString sadir;
    bool sadirActive;
    QString ssdir;
    bool ssdirActive;
    QString sfdir;
    bool sfdirActive;
    QString incdir;
    bool incdirActive;
    QString defaultCsd;
    bool defaultCsdActive;
    QString opcodexmldir;
    bool opcodexmldirActive;

    QString terminal;
    QString browser;
    QString dot;
    QString waveeditor;
    QString waveplayer;
    int language;
//   private:
//     ConfigLists m_configlists;

};

#endif
