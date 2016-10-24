/*
	Copyright (C) 2010 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "csoundoptions.h"
#include "configlists.h"
#include <QDir> // for static QDir::separator()
#include <cstdlib> // for calloc

CsoundOptions::CsoundOptions(ConfigLists *configlists) :
	m_configlists(configlists)
{
	m_jackNameSize = 16; //a small default

	rt = true;

	enableFLTK = true;
	bufferSize = 1024;
	bufferSizeActive = false;
	HwBufferSize = 2048;
	HwBufferSizeActive = false;
	dither = false;
	newParser = false;
	multicore = false;
	numThreads = 1;
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
	rtAudioModule = "";
	rtInputDevice = "adc";
	rtOutputDevice = "dac";
	rtJackName = "*";
	rtMidiModule = "";
	rtMidiInputDevice = "0";
	rtMidiOutputDevice = "0";
	useCsoundMidi = false;
	simultaneousRun = true; // Allow running various instances (tabs) simultaneously.

	csdocdir = "";
	opcodedir = "";
	opcodedirActive = false;
	opcodedir64 = "";
	opcodedir64Active = false;
	opcode6dir64 = "";
	opcode6dir64Active = false;
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
	if (dither) {
		list << " -Z";
	}
#ifndef CSOUND6
    if (newParser == 1) {
		list << "--new-parser";
#endif
		if (multicore) {
			list << "-j" + QString::number(numThreads);
		}
#ifndef CSOUND6
    } else if (newParser == 0) {
        list << "--old-parser";
	}
#endif
	if (rt && rtUseOptions) {
		if (rtOverrideOptions)
			list << "-+ignore_csopts=1";
		if (m_configlists->rtAudioNames.indexOf(rtAudioModule) >= 0
				&& rtAudioModule != "none") {
			list << "-+rtaudio=" + rtAudioModule;
			if (rtInputDevice != "") {
				list << "-i" + rtInputDevice;
			}
			list << "-o" + (rtOutputDevice == "" ? "dac":rtOutputDevice);
			if (rtJackName != "" && rtAudioModule == "jack") {
				QString jackName = rtJackName;
				if (jackName.contains("*")) {
					jackName.replace("*",fileName1.mid(fileName1.lastIndexOf(QDir::separator()) + 1));
					jackName.replace(" ","_");
				}
				if (jackName.size() > m_jackNameSize) {
					jackName = jackName.left(m_jackNameSize);
				}
				list << "-+jack_client=" + jackName;
			}
		}
		if (useCsoundMidi &&
				m_configlists->rtMidiNames.indexOf(rtMidiModule) >= 0 &&
				rtMidiModule != "none") {
			list << "-+rtmidi=" + rtMidiModule;
			if (rtMidiInputDevice != "")
				list << "-M" + rtMidiInputDevice;
			if (rtMidiOutputDevice != "")
				list << "-Q" + rtMidiOutputDevice;
		}
	}
	else {
		list << "--format=" + m_configlists->fileTypeNames[fileFileType]
				+ ":" + m_configlists->fileFormatFlags[fileSampleFormat];
		if (fileInputFilenameActive)
			list << "-i" + fileInputFilename + "";
        if (fileOutputFilenameActive || fileAskFilename) {
			list << "-o" + fileOutputFilename + "";
		}
	}
	// These lines break setting of variables. Are they actually needed here for some reason?
	//  if (sadirActive)
	//    list << "--env:SADIR='" + sadir + "'";
	//  if (ssdirActive)
	//    list << "--env:SSDIR='" + ssdir + "'";
	//  if (sfdirActive)
	//    list << "--env:SFDIR='" + sfdir + "'";
	//  if (incdirActive)
	//    list << "--env:INCDIR='" + incdir + "'";
	list << "--env:CSNOSTOP=yes";
	return list;
}

int CsoundOptions::generateCmdLine(char **argv)
{
	int index = 0;
	argv[index] = (char *) calloc(7, sizeof(char));
	strcpy((char *)argv[index++], "csound");
	QStringList indFlags = generateCmdLineFlagsList();
	foreach (QString flag, indFlags) {
		flag = flag.simplified();
		argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
		strcpy(argv[index], flag.toLocal8Bit());
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
