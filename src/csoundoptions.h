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

#ifndef CSOUNDOPTIONS_H
#define CSOUNDOPTIONS_H

#include <QString>

class ConfigLists;

class CsoundOptions
{
public:
	CsoundOptions(ConfigLists *configlists);

	QString generateCmdLineFlags();
	QStringList generateCmdLineFlagsList();
	int generateCmdLine(char **argv);

	// True if the csd sets 0dbfs itself: either an assignment in the orchestra
	// header ("0dbfs = ...") or "--0dbfs=..." in the <CsOptions> tag.
	static bool textSetsDbfs(const QString &basicText, const QString &optionsText);

	void setJackNameSize(int size);

	bool hasFixedSamplerateBackend() const;
	int backendSamplerate() const;

    // this is used to identify a document indenpendently of its filename (which might
    // be a temporary name)
    QString docName;
	QString fileName1;
	QString fileName2;
	bool rt; //FIXME make sure this is set!

	int bufferSize;
	bool bufferSizeActive;
	int HwBufferSize;
	bool HwBufferSizeActive;
	// Fallback 0dBFS: when true, pass --0dbfs=1 unless the csd sets 0dbfs
	// itself (see csdSetsDbfs).
	bool fallbackDbfs;
	// Per-run value set by the caller: the csd sets 0dbfs itself, either with
	// an orchestra header assignment ("0dbfs = ...") or with "--0dbfs=..." in
	// the <CsOptions> tag. Not persisted.
	bool csdSetsDbfs;
	bool dither;
    bool sampleAccurateFlag;
    bool realtimeFlag;
	bool newParser;
	bool multicore;
	int numThreads;
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
	// Offline rendering only: pass --nodisplays to Csound. This controls
	// Csound's own display opcodes, independently of whether CsoundQt draws
	// its widgets during a render.
	bool disableDisplaysOnRender;

	int sampleFormat;

	bool rtUseOptions;
	bool rtOverrideOptions;
	QString rtAudioModule;
	QString rtInputDevice;
	QString rtOutputDevice;
	bool connectSuccessiveJackPorts;
	QString rtJackName;
	QString rtMidiModule;
	QString rtMidiInputDevice;
	QString rtMidiOutputDevice;
    bool useSystemSamplerate;
    bool checkSyntaxOnly;
    bool checkSyntaxBeforeRun;
    int samplerate;
    bool overrideNumChannels;
    int numChannels;
    int numInputChannels;

    bool useLimiter;
    double limitValue;

	bool useCsoundMidi;
	bool simultaneousRun; // Allow running various instances (tabs) simultaneously.

	QString csdocdir;
    QString opcode7dir64;
	bool opcode7dir64Active;
	QString sadir;
	bool sadirActive;
	QString ssdir;
	bool ssdirActive;
	QString sfdir;
	bool sfdirActive;
	QString incdir;
	bool incdirActive;
	QString rawWave;
	bool rawWaveActive;

private:
	int m_jackNameSize;
	ConfigLists *m_configlists;
};

#endif // CSOUNDOPTIONS_H
