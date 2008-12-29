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
#ifndef OPTIONS_H
#define OPTIONS_H

#include <QString>
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
    int tabWidth;
    bool colorVariables;
    bool autoPlay;
    bool saveChanges;
    bool rememberFile;
    bool saveWidgets;
    bool iconText;

    bool enableWidgets;
    bool invalueEnabled;
    bool chngetEnabled;
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
    QString opcodexmldir;
    bool opcodexmldirActive;

    QString terminal;
    QString browser;
    QString waveeditor;
    QString waveplayer;
//   private:
//     ConfigLists m_configlists;

};

#endif
