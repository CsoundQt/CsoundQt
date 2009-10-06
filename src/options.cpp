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
  if (additionalFlagsActive && !additionalFlags.trimmed().isEmpty())
    cmdline += " " + additionalFlags;
  if (dither)
    cmdline += " -Z";
  if (rt) {
    if (rtOverrideOptions)
      cmdline += " -+ignore_csopts=1";
    if (_configlists.rtAudioNames[rtAudioModule] != "none") {
      cmdline += " -+rtaudio=" + _configlists.rtAudioNames[rtAudioModule];
      cmdline += " -i" + (rtInputDevice == "" ? "adc":rtInputDevice);
      cmdline += " -o" + (rtOutputDevice == "" ? "dac":rtOutputDevice);
      if (rtJackName != "")
        cmdline += " -+jack_client=" + rtJackName;
    }
    if (_configlists.rtMidiNames[rtMidiModule] != "none") {
      cmdline += " -+rtmidi=" + _configlists.rtMidiNames[rtMidiModule];
      if (rtMidiInputDevice != "")
        cmdline += " -M" + rtMidiInputDevice;
      if (rtMidiOutputDevice != "")
        cmdline += " -Q" + rtMidiOutputDevice;
    }
  }
  else {
    if (fileOverrideOptions)
      cmdline += " -+ignore_csopts=1";
    cmdline += " --format=" + _configlists.fileTypeNames[fileFileType];
    cmdline += ":" + _configlists.fileFormatFlags[fileSampleFormat];
    if (fileInputFilenameActive)
      cmdline += " -i" + fileInputFilename + "";
    if (fileOutputFilenameActive or fileAskFilename) {
      //if (fileOutputFilename.startsWith("/"))
      if (fileOutputFilename.contains('/'))
        cmdline += " -o" + fileOutputFilename + "";
      else {
        if (sfdirActive) {
          cmdline += " -o" + fileOutputFilename + "";
        }
        else {
          cmdline += " -o" + csdPath + fileOutputFilename + "";
        }
      }
    }
  }
  if (sadirActive)
    cmdline += " --env:SADIR=" + sadir;
  if (ssdirActive)
    cmdline += " --env:SSDIR=" + ssdir;
  if (sfdirActive)
    cmdline += " --env:SFDIR=" + sfdir;
  if (ssdirActive)
    cmdline += " --env:INCDIR=" + incdir;
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
  QStringList indFlags= flags.split(" -",QString::SkipEmptyParts);
  foreach (QString flag, indFlags) {
    flag = "-" + flag;
//     printf("%s", flag.toStdString().c_str()) ;
    argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
    strcpy(argv[index],flag.toStdString().c_str());
    index++;
  }
  return index;
}
