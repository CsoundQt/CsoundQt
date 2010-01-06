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

#include "configlists.h"

ConfigLists::ConfigLists()
{
  fileTypeNames << "wav" << "aiff" << "au" << "avr" << "caf" << "flac"
      << "htk" << "ircam" << "mat4" << "mat5" << "nis" << "paf" << "pvf"
      << "raw" << "sd2" << "sds" << "svx" << "voc" << "w64" << "wavex";
  fileTypeExtensions << "*.wav" << "*.aif;*.aiff" << "*.au" << "*.avr" << "*.caf"
      << "*.flac" << "*.htk;*.*" << "*.ircam;*.*" << "*.mat4;*.*" << "*.mat5;*.*"
      << "*.nis;*.*" << "*.paf;*.*" << "*.pvf" << "*.raw;*.*" << "*.sd2;*.*" << "*.sds;*.*"
      << "*.svx;*.*" << "*.voc;*.*" << "*.w64;*.wav" << "*.wavex;*.wav";
  fileTypeLongNames << "WAVE" << "AIFF" << "au" << "avr" << "CAF" << "FLAC"
      << "htk" << "ircam" << "mat4" << "mat5" << "nis" << "paf" << "pvf"
      << "Raw (Headerless)" << "Sound Designer II" << "sds" << "svx" << "voc"
      << "WAVE (w64)" << "WAVE (wavex)";

  fileFormatFlags << "24bit" << "short"<< "uchar"
      << "schar"<< "float"<< "long";
  fileFormatNames << "24 Bit" << "16 Bit (short)" << "unsigned 8-bit"
      << "signed 8-bit" << "32 bit float"<< "long (32-bit)";
#ifdef LINUX
  rtAudioNames << "alsa" << "jack" << "portaudio" << "pulse" << "none";
#endif
#ifdef SOLARIS
  rtAudioNames << "portaudio" << "pulse" << "none";
#endif
#ifdef MACOSX
  rtAudioNames << "portaudio" << "coreaudio" << "none";
#endif
#ifdef WIN32
  rtAudioNames << "portaudio" << "winmm" << "jack" <<  "none";
#endif
#ifdef LINUX
  rtMidiNames << "none" << "alsa"  << "portmidi"<< "virtual";
#endif
#ifdef SOLARIS
  rtMidiNames << "none" << "portmidi"<< "virtual";
#endif
#ifdef MACOSX
  rtMidiNames << "none" << "portmidi" << "virtual";
#endif
#ifdef WIN32
  rtMidiNames << "none" << "winmm" << "portmidi" << "virtual";
#endif
  languages << "English" << "Spanish" << "German" << "French" << "Portuguese" << "Italian" << "Turkish";
  languageCodes << "en" << "es" << "de" << "fr" << "pt" << "it" << "tr";
}


ConfigLists::~ConfigLists()
{
}


