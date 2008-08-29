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
#include "configlists.h"

ConfigLists::ConfigLists()
{
  fileTypeNames << "wav" << "aiff" << "au" << "avr" << "caf" << "flac"
      << "htk" << "ircam" << "mat4" << "mat5" << "nis" << "paf" << "pvf"
      << "raw" << "sd2" << "sds" << "svx" << "voc" << "w64" << "wavex";
  fileTypeExtensions << "*.wav" << "*.aif;*.aiff" << "*.au" << "*.avr" << "*.caf"
      << "*.flac" << "*.htk;*.*" << "*.ircam;*.*" << "*.mat4;*.*" << "*.mat5;*.*"
      << "*.nis;*.*" << "*.paf;*.*" << "*.pvf" << "*.raw;*.*" << "*.sd2;*.*" << "*.sds;*.*"
      << "*.svx;*.*" << "*.voc;*.*" << "*.w64;*.wav" << "*.wav;*.wavex";
  fileTypeLongNames << "WAVE" << "AIFF" << "au" << "avr" << "CAF" << "FLAC"
      << "htk" << "ircam" << "mat4" << "mat5" << "nis" << "paf" << "pvf"
      << "Raw (Headerless)" << "Sound Designer II" << "sds" << "svx" << "voc"
      << "WAVE (w64)" << "WAVE (wavex)";

  fileFormatFlags << "24bit" << "short"<< "uchar"
      << "schar"<< "float"<< "long";
  fileFormatNames << "24 Bit" << "16 Bit (short)" << "unsigned 8-bit"
      << "signed 8-bit" << "32 bit float"<< "long (32-bit)";
#ifdef LINUX
  rtAudioNames << "alsa" << "jack" << "portaudio" << "none";
#endif
#ifdef MACOSX
  rtAudioNames << "coreaudio" << "portaudio" << "none";
#endif
#ifdef WIN32
  rtAudioNames << "winmm" << "portaudio" << "none";
#endif
#ifdef LINUX
  rtMidiNames << "none" << "portmidi" << "alsa" << "virtual";
#endif
#ifdef MACOSX
  rtMidiNames << "none" << "portmidi" << "virtual";
#endif
#ifdef WIN32
  rtMidiNames << "none" << "winmm" << "portmidi" << "virtual";
#endif
}


ConfigLists::~ConfigLists()
{
}


