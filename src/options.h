/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
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
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#ifndef OPTIONS_H
#define OPTIONS_H

#include <QString>
#include "configlists.h"

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
    bool autoPlay;
    bool saveChanges;

    bool useAPI;

    int bufferSize;
    bool bufferSizeActive;
    int HwBufferSize;
    bool HwBufferSizeActive;
    bool dither;
    QString additionalFlags;
    bool additionalFlagsActive;

    bool fileOverrideOptions;
    bool fileAskFilename;
    bool filePlayFinished;
    int fileFileType;
    int fileSampleFormat;
    bool fileInputFilenameActive;
    QString fileInputFilename;
    bool fileOutputFilenameActive;
    QString fileOutputFilename;

    bool rtOverrideOptions;
    int rtAudioModule;
    QString rtInputDevice;
    QString rtOutputDevice;
    QString rtJackName;

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
  private:
    ConfigLists m_configlists;

};

#endif
