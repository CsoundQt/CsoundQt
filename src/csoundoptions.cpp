/*
    Copyright (C) 2010 Andres Cabrera
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

#include "csoundoptions.h"
#include "types.h" // for _configlists
#include <QDir> // for static QDir::separator()

CsoundOptions::CsoundOptions()
{
}

QString CsoundOptions::generateCmdLineFlags()
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
  if (rtOverrideOptions)
    cmdline += " -+ignore_csopts=1";
  if (rt) {
    if (_configlists.rtAudioNames[rtAudioModule] != "none") {
      cmdline += " -+rtaudio=" + _configlists.rtAudioNames[rtAudioModule];
      cmdline += " -i" + (rtInputDevice == "" ? "adc":rtInputDevice);
      cmdline += " -o" + (rtOutputDevice == "" ? "dac":rtOutputDevice);
      if (rtJackName != "" && _configlists.rtAudioNames[rtAudioModule] == "jack") {
        QString jackName = rtJackName;
        if (jackName.contains("*")) {
          jackName.replace("*",fileName1.mid(fileName1.lastIndexOf(QDir::separator()) + 1));
          jackName.replace(" ","_");
        }
        cmdline += " -+jack_client=" + jackName;
      }
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
          // FIXME is csdPath needed here for the output to be in the correct place?
//          cmdline += " -o" + csdPath + fileOutputFilename + "";
          cmdline += " -o" + fileOutputFilename + "";
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

QStringList CsoundOptions::generateCmdLineFlagsList()
{
  QStringList list;
  if (bufferSizeActive)
    list << " -b" + QString::number(bufferSize);
  if (HwBufferSizeActive)
    list << " -B" + QString::number(HwBufferSize);
  if (additionalFlagsActive && !additionalFlags.trimmed().isEmpty()) {
    QStringList addFlags = additionalFlags.split(QRegExp("[\\s]"),QString::SkipEmptyParts);
    foreach (QString f, addFlags) {
      list << f;
    }
  }
  if (dither)
    list << " -Z";
  if (rtOverrideOptions)
    list << " -+ignore_csopts=1";
  if (rt) {
    if (_configlists.rtAudioNames[rtAudioModule] != "none") {
      list << " -+rtaudio=" + _configlists.rtAudioNames[rtAudioModule];
      list << " -i" + (rtInputDevice == "" ? "adc":rtInputDevice);
      list << " -o" + (rtOutputDevice == "" ? "dac":rtOutputDevice);
      if (rtJackName != "" && _configlists.rtAudioNames[rtAudioModule] == "jack") {
        QString jackName = rtJackName;
        if (jackName.contains("*")) {
          jackName.replace("*",fileName1.mid(fileName1.lastIndexOf(QDir::separator()) + 1));
          jackName.replace(" ","_");
        }
        list << " -+jack_client=" + jackName;
      }
    }
    if (_configlists.rtMidiNames[rtMidiModule] != "none") {
      list << " -+rtmidi=" + _configlists.rtMidiNames[rtMidiModule];
      if (rtMidiInputDevice != "")
        list << " -M" + rtMidiInputDevice;
      if (rtMidiOutputDevice != "")
        list << " -Q" + rtMidiOutputDevice;
    }
  }
  else {
    list << " --format=" + _configlists.fileTypeNames[fileFileType]
        + ":" + _configlists.fileFormatFlags[fileSampleFormat];
    if (fileInputFilenameActive)
      list << " -i" + fileInputFilename + "";
    if (fileOutputFilenameActive or fileAskFilename) {
      //if (fileOutputFilename.startsWith("/"))
      if (fileOutputFilename.contains('/'))
        list << " -o" + fileOutputFilename + "";
      else {
        if (sfdirActive) {
          list << " -o" + fileOutputFilename + "";
        }
        else {
          // FIXME is csdPath needed here for the output to be in the correct place?
//          cmdline += " -o" + csdPath + fileOutputFilename + "";
          list << " -o" + fileOutputFilename + "";
        }
      }
    }
  }
  if (sadirActive)
    list << " --env:SADIR=" + sadir;
  if (ssdirActive)
    list << " --env:SSDIR=" + ssdir;
  if (sfdirActive)
    list << " --env:SFDIR=" + sfdir;
  if (ssdirActive)
    list << " --env:INCDIR=" + incdir;
  list << " --env:CSNOSTOP=yes";
  return list;
}

int CsoundOptions::generateCmdLine(char **argv)
{
  int index = 0;
  argv[index] = (char *) calloc(7, sizeof(char));
  strcpy(argv[index++], "csound");
  QStringList indFlags = generateCmdLineFlagsList();
  foreach (QString flag, indFlags) {
//    flag = "-" + flag;
    flag = flag.simplified();
    argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
    strcpy(argv[index],flag.toStdString().c_str());
    index++;
//    fprintf(stdout, "%i - %s.....", index, flag.toStdString().c_str()) ;
  }
  argv[index] = (char *) calloc(fileName1.size()+1, sizeof(char));
  strcpy(argv[index++],fileName1.toStdString().c_str());
//  fprintf(stdout, "%i - %s.....", index, fileName1.toStdString().c_str()) ;
  if (fileName2 != "") {
    argv[index] = (char *) calloc(fileName2.size()+1, sizeof(char));
    strcpy(argv[index++],fileName2.toStdString().c_str());
//    fprintf(stdout, "%i - %s.....", index, fileName2.toStdString().c_str()) ;
  }
//  fprintf(stdout, "\nCsoundOptions::generateCmdLine  index %i\n", index);
  return index;
}
