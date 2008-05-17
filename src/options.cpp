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
#include "options.h"
#include "configlists.h"
#include "types.h"

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
    cmdline += " -+rtaudio=" + m_configlists.rtaudioNames[rtAudioModule];
    if (rtInputDevice != "")
      cmdline += " -i" + rtInputDevice;
    if (rtOutputDevice != "")
      cmdline += " -o" + rtOutputDevice;
    if (rtJackName != "")
      cmdline += " -+jack_client=" + rtJackName;
  }
  else {
    if (fileOverrideOptions)
      cmdline += " -+ignore_csopts=1";
    cmdline += " --format=" + m_configlists.fileTypeNames[fileFileType];
    cmdline += ":" + m_configlists.fileFormatFlags[fileSampleFormat];
    if (fileInputFilenameActive)
      cmdline += " -i" + fileInputFilename;
    if (fileOutputFilenameActive)
      cmdline += " -o" + fileOutputFilename;

  }

  return cmdline;
}
