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
#include "options.h"
#include "configlists.h"
#include "types.h"
#include "stdlib.h"

Options::Options()
{
}


Options::~Options()
{
}

QString Options::generateCmdLineFlags(bool rt)
{
  QString cmdline = "";
  if (bufferSizeActive)
    cmdline += " -b" + QString::number(bufferSize);
  if (HwBufferSizeActive)
    cmdline += " -B" + QString::number(HwBufferSize);
  if (additionalFlagsActive)
    cmdline += " " + additionalFlags;
  if (dither)
    cmdline += " -Z";
  if (rt) {
    if (rtOverrideOptions)
      cmdline += " -+ignore_csopts=1";
    if (m_configlists.rtAudioNames[rtAudioModule] != "none") {
      cmdline += " -+rtaudio=" + m_configlists.rtAudioNames[rtAudioModule];
      cmdline += " -i" + (rtInputDevice == "" ? "adc":rtInputDevice);
      cmdline += " -o" + (rtOutputDevice == "" ? "dac":rtOutputDevice);
      if (rtJackName != "")
        cmdline += " -+jack_client=" + rtJackName;
    }
    if (m_configlists.rtMidiNames[rtMidiModule] != "none") {
      cmdline += " -+rtmidi=" + m_configlists.rtMidiNames[rtMidiModule];
      if (rtMidiInputDevice != "")
        cmdline += " -M" + rtMidiInputDevice;
      if (rtMidiOutputDevice != "")
        cmdline += " -Q" + rtMidiOutputDevice;
    }
  }
  else {
    if (fileOverrideOptions)
      cmdline += " -+ignore_csopts=1";
    cmdline += " --format=" + m_configlists.fileTypeNames[fileFileType];
    cmdline += ":" + m_configlists.fileFormatFlags[fileSampleFormat];
    if (fileInputFilenameActive)
      cmdline += " -i" + fileInputFilename;
    if (fileOutputFilenameActive or fileAskFilename)
      cmdline += " -o" + fileOutputFilename;

  }
  cmdline += " --env:CSNOSTOP=yes";

  return cmdline;
}

int Options::generateCmdLine(char **argv,
                             bool rt,
                             QString fileName,
                             QString fileName2)
{

  int index = 0;
  argv[index] = (char *) calloc(7, sizeof(char));
  strcpy(argv[index++], "csound");
  //FIXME this memory is not freed!
  argv[index] = (char *) calloc(fileName.size()+1, sizeof(char));
  strcpy(argv[index++],fileName.toStdString().c_str());
  if (fileName2 != "") {
    argv[index] = (char *) calloc(fileName2.size()+1, sizeof(char));
    strcpy(argv[index++],fileName2.toStdString().c_str());
  }
  QString flags = "";
  if ( (rt and rtUseOptions) or (!rt and fileUseOptions) ) {
    flags = generateCmdLineFlags(rt);
  }
  QStringList indFlags= flags.split(" ",QString::SkipEmptyParts);
  foreach (QString flag, indFlags) {
    argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
    strcpy(argv[index],flag.toStdString().c_str());
    index++;
  }
  return index;
}
