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
  m_jackNameSize = 16; //a small default

  rt = true;

  enableFLTK = true;
  bufferSize = 1024;
  bufferSizeActive = false;
  HwBufferSize = 2048;
  HwBufferSizeActive = false;
  dither = false;
  additionalFlags = "";
  additionalFlagsActive = false;

  fileUseOptions = false;
  fileOverrideOptions = false;
  fileAskFilename = false;
  filePlayFinished = false;
  fileFileType = 0;
  fileSampleFormat = 0;
  fileInputFilenameActive = false;
  fileInputFilename = "";
  fileOutputFilenameActive = false;
  fileOutputFilename = "";

  sampleFormat = 0;

  rtUseOptions = true;
  rtOverrideOptions = false;
  rtAudioModule = 0;
  rtInputDevice = "adc";
  rtOutputDevice = "dac";
  rtJackName = "*";
  rtMidiModule = 0;
  rtMidiInputDevice = "0";
  rtMidiOutputDevice = "0";
  simultaneousRun = true; // Allow running various instances (tabs) simultaneously.

  csdocdir = "";
  opcodedir = "";
  opcodedirActive = false;
  sadir = "";
  sadirActive = false;
  ssdir = "";
  ssdirActive = false;
  sfdir = "";
  sfdirActive = false;
  incdir = "";
  incdirActive = false;

}

QString CsoundOptions::generateCmdLineFlags()
{
  return generateCmdLineFlagsList().join(" ");
}

QStringList CsoundOptions::generateCmdLineFlagsList()
{
  QStringList list;
  if (bufferSizeActive)
    list << "-b" + QString::number(bufferSize);
  if (HwBufferSizeActive)
    list << "-B" + QString::number(HwBufferSize);
  if (additionalFlagsActive && !additionalFlags.trimmed().isEmpty()) {
    QStringList addFlags = additionalFlags.split(QRegExp("[\\s]"),QString::SkipEmptyParts);
    foreach (QString f, addFlags) {
      list << f;
    }
  }
  if (dither)
    list << " -Z";
  if (rt && rtUseOptions) {
    if (rtOverrideOptions)
      list << "-+ignore_csopts=1";
    if (_configlists.rtAudioNames[rtAudioModule] != "none") {
      list << "-+rtaudio=" + _configlists.rtAudioNames[rtAudioModule];
      if (rtInputDevice != "") {
        list << "-i" + rtInputDevice;
      }
      list << "-o" + (rtOutputDevice == "" ? "dac":rtOutputDevice);
      if (rtJackName != "" && _configlists.rtAudioNames[rtAudioModule] == "jack") {
        QString jackName = rtJackName;
        if (jackName.contains("*")) {
          jackName.replace("*",fileName1.mid(fileName1.lastIndexOf(QDir::separator()) + 1));
          jackName.replace(" ","_");
        }
        if (rtJackName.size() > m_jackNameSize) {
          rtJackName.resize(m_jackNameSize);
        }
        list << "-+jack_client=" + jackName;
      }
    }
    if (_configlists.rtMidiNames[rtMidiModule] != "none") {
      list << "-+rtmidi=" + _configlists.rtMidiNames[rtMidiModule];
      if (rtMidiInputDevice != "")
        list << "-M" + rtMidiInputDevice;
      if (rtMidiOutputDevice != "")
        list << "-Q" + rtMidiOutputDevice;
    }
  }
  else {
    list << "--format=" + _configlists.fileTypeNames[fileFileType]
        + ":" + _configlists.fileFormatFlags[fileSampleFormat];
    if (fileInputFilenameActive)
      list << "-i" + fileInputFilename + "";
    if (fileOutputFilenameActive or fileAskFilename) {
      list << "-o" + fileOutputFilename + "";
    }
  }
  if (sadirActive)
    list << "--env:SADIR='" + sadir + "'";
  if (ssdirActive)
    list << "--env:SSDIR='" + ssdir + "'";
  if (sfdirActive)
    list << "--env:SFDIR='" + sfdir + "'";
  if (incdirActive)
    list << "--env:INCDIR='" + incdir + "'";
  list << "--env:CSNOSTOP=yes";
  return list;
}

int CsoundOptions::generateCmdLine(char **argv)
{
  int index = 0;
  argv[index] = (char *) calloc(7, sizeof(char));
  strcpy(argv[index++], "csound");
  QStringList indFlags = generateCmdLineFlagsList();
  foreach (QString flag, indFlags) {
    flag = flag.simplified();
    argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
    strcpy(argv[index],flag.toStdString().c_str());
    index++;
  }
  argv[index] = (char *) calloc(fileName1.size()+1, sizeof(char));
  strcpy(argv[index++],fileName1.toLocal8Bit());
  if (fileName2 != "") {
    argv[index] = (char *) calloc(fileName2.size()+1, sizeof(char));
    strcpy(argv[index++],fileName2.toLocal8Bit());
  }
  return index;
}

void CsoundOptions::setJackNameSize(int size)
{
  m_jackNameSize = size;
}
