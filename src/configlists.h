/*
	Copyright (C) 2008, 2009 Andres Cabrera
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

#ifndef CONFIGLISTS_H
#define CONFIGLISTS_H

#include <QHash>
#include <QList>
#include <QPair>
#include <QStringList>


typedef struct CSOUND_ CSOUND;

// helper function to convert char[] safely to QString
template <size_t N>
inline QString safeQString(const char (&str)[N]) {
    return QString::fromUtf8(str, strnlen(str, N));
}

// Information about one realtime audio device, as reported by Csound.
struct AudioDeviceInfo {
    QString name;        // human-readable device name
    QString id;          // value to use with -o / -i (e.g. "dac13")
    bool isOutput = false;
    int channels = -1;   // maximum channels, -1 if the backend does not report it
    int sampleRate = -1; // system/sample rate, -1 if not fixed or unknown
};

class ConfigLists
{
public:
	ConfigLists();

	~ConfigLists();

	static void msgCallback(CSOUND *csound,
							int attr,
							const char *fmt,
							va_list args);

	QStringList fileTypeNames;
	QStringList fileTypeExtensions;
	QStringList fileTypeLongNames;
	QStringList fileFormatFlags;
	QStringList fileFormatNames;
	QStringList rtAudioNames;
	QStringList rtMidiNames;
	QStringList languages;
	QStringList languageCodes;

	void refreshModules();
	// Realtime audio module names in order of preference for this platform,
	// highest priority first. Matching is by Csound module name.
	static QStringList audioModulePriorities();
	// User-facing name for a Csound realtime audio module.
	static QString audioModuleDisplayName(const QString &module);
	// Modules whose ksmps is always set from the fixed selection.
	static bool isFixedKsmpsModule(const QString &module);
	// Modules where ksmps can either be overridden or left to the orchestra.
	static bool isSelectableKsmpsModule(const QString &module);
	// Highest-priority realtime audio module available in this Csound build.
	QString defaultAudioModule() const;
    // True when the file name looks like an audio file that Csound can read
    // through GEN01 (used for drag & drop actions).
    bool isSoundFile(const QString &fileName) const;
    bool isJackRunning();
    bool isPipeWireRunning();
    // Native (graph) sample rate of the PipeWire server, or -1 if it cannot be
    // determined or PipeWire is not running.
    int pipeWireSamplerate();
    bool isFixedSamplerateBackend(const QString &module);
    int backendSamplerate(const QString &module);
    QString jackHardwarePattern(bool isOutput);
    QString resolveJackDevice(const QString &device, bool isOutput);
    // Maps a JACK device id to its aggregate display label (e.g. "dac0" ->
    // "ALC257 Analog:playback_"). Other modules are unchanged.
    QString audioDeviceDisplayName(const QString &module, bool isOutput,
                                   const QString &id);
    // Reverse mapping used when reading the device fields in the dialog.
    QString audioDeviceIdForDisplay(const QString &module, bool isOutput,
                                    const QString &text);
    // Audio devices for the settings menus. JACK ports belonging to the same
    // client/prefix family are grouped into one device (e.g. "jaaa:in_"),
    // with the channel count set to the number of ports in the group.
    QList<AudioDeviceInfo> audioDeviceGroups(const QString &module, bool isOutput);
    // Reads inputs and outputs together with one Csound instance.
    QPair<QList<AudioDeviceInfo>, QList<AudioDeviceInfo>>
    audioDeviceGroups(const QString &module);
    // Channel count for a selected device token. Returns 0 for "no device",
    // -1 when the backend cannot tell. If devices is null, the device list is
    // queried.
    int audioDeviceChannels(const QString &module, const QString &device,
                            bool isOutput,
                            const QList<AudioDeviceInfo> *devices = nullptr);
    // First device for a module: lowest adc/dac number for JACK, otherwise the
    // first entry returned by Csound.
    static QString defaultAudioDeviceId(const QString &module, bool isOutput,
                                        const QList<AudioDeviceInfo> &devices);

	QHash<QString, QString> getMidiInputDevices(QString module);
	QList<QPair<QString, QString> > getMidiOutputDevices(QString module);
	QList<QPair<QString, QString> > getAudioInputDevices(QString module);
	QList<QPair<QString, QString> > getAudioOutputDevices(QString module);
	// Audio devices of one realtime module (inputs and outputs), including the
	// system sample rate for modules where the rate is fixed by the system.
	QList<AudioDeviceInfo> audioDevices(const QString &module);
	// True when the fixed sample rate is set per device rather than once for
	// the whole module (currently CoreAudio).
	static bool isPerDeviceSamplerateBackend(const QString &module);
	// Queries the sample rate for one device token (as passed to -o / -i).
	// Returns -1 when it cannot be determined.
	int deviceSamplerate(const QString &module, const QString &device,
	                     bool isOutput);

	QStringList runCsoundInternally(QStringList flags);

private:
	QString m_messages;
	QHash<QString, int> m_backendSamplerates;
	QHash<QString, int> m_deviceSamplerates;
	int m_pipeWireSamplerate = -1;
	QList<AudioDeviceInfo> audioDevicesForDirection(const QString &module,
	                                                bool isOutput,
	                                                bool withSamplerate = true);
	QList<AudioDeviceInfo> audioDevicesFromCsound(CSOUND *cs,
	                                              const QString &module,
	                                              bool isOutput,
	                                              bool withSamplerate);
};

#endif
