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

#include <QProcess>
#include <QFile>
#include <QFileInfo>
#include <QTemporaryFile>
#include <QTextStream>
#include <QDir>
#include <QStandardPaths>
#include <QApplication>
#include <QDebug>
#include <QRegularExpression>
#include <QVector>

#include <algorithm>

#include "csound.h"
#include "configlists.h"
using namespace Qt::StringLiterals;

typedef QPair<QString, QString> QStringPair;

static QList<AudioDeviceInfo> groupJackDevices(const QList<AudioDeviceInfo> &ports);
static QString jackAggregateKey(const QString &portName);


ConfigLists::ConfigLists()
{
    fileTypeNames      << "wav" << "aiff" << "au" << "avr"
                       << "caf" << "flac" << "htk" << "ircam"
                       << "mat4" << "mat5" << "nis" << "paf"
                       << "pvf" << "raw" << "sd2" << "sds"
                       << "svx" << "voc" << "w64" << "wavex";

    fileTypeExtensions << "*.wav" << "*.aif;*.aiff" << "*.au" << "*.avr"
                       << "*.caf" << "*.flac" << "*.htk;*.*" << "*.ircam;*.*"
                       << "*.mat4;*.*" << "*.mat5;*.*" << "*.nis;*.*" << "*.paf;*.*"
                       << "*.pvf" << "*.raw;*.*" << "*.sd2;*.*" << "*.sds;*.*"
					   << "*.svx;*.*" << "*.voc;*.*" << "*.w64;*.wav" << "*.wavex;*.wav";

    fileTypeLongNames  << "WAVE" << "AIFF" << "au" << "avr"
                       << "CAF" << "FLAC" << "htk" << "ircam"
                       << "mat4" << "mat5" << "nis" << "paf"
                       << "pvf" << "Raw (Headerless)" << "Sound Designer II" << "sds"
                       << "svx" << "voc" << "WAVE (w64)" << "WAVE (wavex)";

    // Offline render formats. The order must match the file type combo and
    // renderFileTypeNames/renderFileTypeExtensions.
    renderFileTypeNames      << "wav" << "aiff" << "flac" << "caf" << "w64";
    renderFileTypeExtensions << "*.wav" << "*.aif;*.aiff" << "*.flac" << "*.caf"
                             << "*.w64;*.wav";
    renderFileTypeLongNames  << "wave" << "aiff" << "flac" << "caf" << "wave64 (w64)";

	fileFormatFlags << "24bit" << "short" << "long" << "float";
	fileFormatNames << "pcm24" << "pcm16" << "pcm32" << "float32";

    languages << "English" << "Spanish" << "German" << "French" << "Portuguese"
              << "Italian"  << "Turkish"  << "Finnish" << "Russian" << "Korean"
              << "Persian";

    languageCodes << "en" << "es" << "de" << "fr" << "pt"
                  << "it" << "tr" << "fi" << "ru" << "kr"
                  << "fa";
}


ConfigLists::~ConfigLists()
{
}

QStringList ConfigLists::sampleFormatFlagsForFileType(const QString &fileType) const
{
    // FLAC supports only integer PCM up to 24 bit; the other render formats
    // expose the same four choices.
    if (fileType == "flac"_L1)
        return {u"short"_s, u"24bit"_s}; // pcm16, pcm24
    return {u"24bit"_s, u"short"_s, u"long"_s, u"float"_s}; // pcm24, pcm16, pcm32, float32
}

void ConfigLists::msgCallback(CSOUND *csound, int attr, const char *fmt, va_list args)
{
	Q_UNUSED(attr);
	QString *ud = (QString *) csoundGetHostData(csound);
	QString msg;
    msg = msg.vasprintf(fmt, args);
	if (msg.isEmpty()) {
		return;
	}
	ud->append(msg);
}

void ConfigLists::refreshModules()
{
    rtMidiNames.clear();
	rtAudioNames.clear();
    CSOUND *csound = csoundCreate(nullptr, nullptr);
	char *name, *type;
	int n = 0;

	while(!csoundGetModule(csound, n++, &name, &type)) {
		if (strcmp(type, "audio") == 0) {
			// PulseAudio is no longer supported, and the blocking PortAudio
			// variant is never a useful choice.
			if (strcmp(name, "pulse") != 0 && strcmp(name, "pa_bl") != 0)
				rtAudioNames << name;
		}
	}

	rtAudioNames << "null"; // add also none (-+rtaudio=null)
	// Present the modules in the platform's order of preference. Modules
	// without a priority keep their API order after the known ones, and
	// "null" always comes last.
	const QStringList priorities = audioModulePriorities();
	auto rank = [&priorities](const QString &module) -> int {
		const int priority = priorities.indexOf(module);
		if (priority >= 0)
			return priority;
		const int afterKnown = int(priorities.size());
		if (module == "null"_L1)
			return afterKnown + 1;
		return afterKnown;
	};
	std::stable_sort(rtAudioNames.begin(), rtAudioNames.end(),
	                 [&rank](const QString &a, const QString &b) {
		return rank(a) < rank(b);
	});
	n = 0;

	while(!csoundGetModule(csound, n++, &name, &type)) {
		if (strcmp(type, "midi") == 0) {
			rtMidiNames << name;
		}
	}

    if (rtAudioNames.contains("jack")) {
        rtMidiNames <<  "jack";
	}
    rtMidiNames << "none";
    rtMidiNames.removeAll("virtual"_L1); // not supported by CsoundQt
    csoundDestroy(csound);
    //test:
    qDebug() << Q_FUNC_INFO << rtAudioNames;

}

QStringList ConfigLists::audioModulePriorities()
{
#ifdef Q_OS_LINUX
    // Csound's PipeWire backend is listed as "rtpw" by the module API;
    // "pipewire" and "pw" are accepted aliases at run time.
    return {u"jack"_s, u"rtpw"_s, u"pipewire"_s, u"pw"_s, u"alsa"_s, u"pa_cb"_s};
#elif defined(Q_OS_MACOS)
    return {u"auhal"_s, u"jack"_s, u"pa_cb"_s, u"portaudio"_s};
#elif defined(Q_OS_WIN32)
    return {u"portaudio"_s, u"pa_cb"_s};
#else
    return {u"pa_cb"_s};
#endif
}

QString ConfigLists::audioModuleDisplayName(const QString &module)
{
    if (module == "rtpw"_L1 || module == "pipewire"_L1 || module == "pw"_L1)
        return u"pipewire"_s;
    if (module == "pa_cb"_L1)
        return u"portaudio"_s;
    if (module == "null"_L1)
        return u"Disabled"_s;
    if (module == "alsa"_L1)
        return u"ALSA"_s;
    if (module == "auhal"_L1)
        return u"coreaudio"_s;
    return module;
}

bool ConfigLists::isFixedKsmpsModule(const QString &module)
{
    return module == "auhal"_L1
            || module == "coreaudio"_L1
            || module == "jack"_L1
            || module == "rtpw"_L1
            || module == "pipewire"_L1
            || module == "pw"_L1;
}

bool ConfigLists::isSelectableKsmpsModule(const QString &module)
{
    return module == "alsa"_L1
            || module == "pa_cb"_L1
            || module == "pa_bl"_L1
            || module == "portaudio"_L1
            || module == "null"_L1;
}

QString ConfigLists::defaultAudioModule() const
{
    for (const QString &module : rtAudioNames) {
        if (module != "null"_L1)
            return module;
    }
    return u"null"_s;
}

QHash<QString,QString> ConfigLists::getMidiInputDevices(QString module)
{
	// based on code by Steven Yi
    QHash<QString,QString> deviceList;

    CSOUND *cs = csoundCreate(nullptr, nullptr);
	if (module=="jack") {
        csoundSetOption(cs, "-+rtaudio=jack");
        csoundSetOption(cs, "-+rtmidi=jack");
	}

    csoundSetMIDIModule(cs, module.toLatin1().data());
    int i,newn, n = csoundGetMIDIDevList(cs, nullptr, 0);
	CS_MIDIDEVICE *devs = (CS_MIDIDEVICE *) malloc(n*sizeof(CS_MIDIDEVICE));
	newn = csoundGetMIDIDevList(cs,devs,0);
	if (newn != n) {
		qDebug()  << "Device number changed";
		return deviceList;
	}
	for (i = 0; i < n; i++) {
		qDebug() << "Device "<<i << devs[i].device_name;
		QString displayName, id;
		if (module=="jack") {
            displayName = safeQString(devs[i].device_name);
            id = displayName;
		} else {
            displayName = QString("%1 (%2)")
            .arg(safeQString(devs[i].device_name))
                .arg(safeQString(devs[i].interface_name));
            id = safeQString(devs[i].device_id);
		}
		deviceList.insert(displayName, id);
	}
	free(devs);
    csoundDestroy(cs);

	qDebug()<<"Devices found: "<<deviceList;
	return deviceList;
}

QList<QPair<QString, QString> > ConfigLists::getMidiOutputDevices(QString module)
{
	QList<QPair<QString, QString> > deviceList;

    CSOUND *cs = csoundCreate(nullptr, nullptr);
	if (module=="jack") {
        csoundSetOption(cs, "-+rtaudio=jack");
        csoundSetOption(cs, "-+rtmidi=jack");
	}

    csoundSetMIDIModule(cs, module.toLatin1().data());
    int i,newn, n = csoundGetMIDIDevList(cs, nullptr, 1);
	CS_MIDIDEVICE *devs = (CS_MIDIDEVICE *) malloc(n*sizeof(CS_MIDIDEVICE));
	newn = csoundGetMIDIDevList(cs,devs,1);
	if (newn != n) {
		qDebug()  << "Device number changed";
		return deviceList;
	}
	for (i = 0; i < n; i++) {
        // qDebug() << devs[i].device_name;
		QString displayName, id;
		if (module=="jack") {
            displayName = safeQString(devs[i].device_name);
            id = safeQString(devs[i].device_name);
		} else {
            displayName = QString("%1 (%2)")
                              .arg(safeQString( devs[i].device_name) )
                    .arg(safeQString(devs[i].interface_name));
            id = safeQString(devs[i].device_id);
		}

        deviceList.append(QStringPair(displayName, id));
	}
	free(devs);
    csoundDestroy(cs);

	return deviceList;
}

QList<QPair<QString, QString> > ConfigLists::getAudioInputDevices(QString module)
{
    QList<QStringPair> deviceList;
    CSOUND *cs = csoundCreate(nullptr, nullptr);

    csoundSetRTAudioModule(cs, module.toLatin1().data());
    int i,newn, n = csoundGetAudioDevList(cs, nullptr, 0);
	CS_AUDIODEVICE *devs = (CS_AUDIODEVICE *) malloc(n*sizeof(CS_AUDIODEVICE));
	newn = csoundGetAudioDevList(cs,devs,0);
	if (newn != n) {
		qDebug()  << "Device number changed";
		return deviceList;
	}
	for (i = 0; i < n; i++) {
        // qDebug() << "devs[i].device_name;
        // this caused sometimes carbage on MacOS: deviceList.append(QStringPair(devs[i].device_name, devs[i].device_id));
        deviceList.append(QStringPair(safeQString( devs[i].device_name),
                                      safeQString( devs[i].device_id)));

	}
	free(devs);
    csoundDestroy(cs);
	return deviceList;
}


QList<QPair<QString, QString> > ConfigLists::getAudioOutputDevices(QString module)
{
    QList<QPair<QString, QString> > deviceList;

    CSOUND *cs = csoundCreate(nullptr, nullptr);

    csoundSetRTAudioModule(cs, module.toLatin1().data());
    int i,newn, n = csoundGetAudioDevList(cs, nullptr, 1);
	CS_AUDIODEVICE *devs = (CS_AUDIODEVICE *) malloc(n*sizeof(CS_AUDIODEVICE));
	newn = csoundGetAudioDevList(cs,devs,1);
	if (newn != n) {
		qDebug()  << "OutputDevices Device number changed";
		return deviceList;
	}
	for (i = 0; i < n; i++) {
        // qDebug()  << devs[i].device_name;
        //deviceList.append(QStringPair(devs[i].device_name, devs[i].device_id));
        deviceList.append(QStringPair(safeQString( devs[i].device_name),
                                      safeQString( devs[i].device_id)));
	}
	free(devs);
    csoundDestroy(cs);

	return deviceList;
}

QList<AudioDeviceInfo> ConfigLists::audioDevices(const QString &module)
{
    QList<AudioDeviceInfo> devices;
    devices += audioDevicesForDirection(module, true);
    devices += audioDevicesForDirection(module, false);
    return devices;
}

QList<AudioDeviceInfo> ConfigLists::audioDevicesForDirection(const QString &module,
                                                            bool isOutput,
                                                            bool withSamplerate)
{
    CSOUND *cs = csoundCreate(&m_messages, nullptr);
    csoundSetMessageCallback(cs, msgCallback);
    csoundSetRTAudioModule(cs, module.toLocal8Bit().constData());
    const QList<AudioDeviceInfo> devices =
            audioDevicesFromCsound(cs, module, isOutput, withSamplerate);
    csoundDestroy(cs);
    return devices;
}

QList<AudioDeviceInfo> ConfigLists::audioDevicesFromCsound(CSOUND *cs,
                                                          const QString &module,
                                                          bool isOutput,
                                                          bool withSamplerate)
{
    QList<AudioDeviceInfo> devices;
    const qsizetype count = csoundGetAudioDevList(cs, nullptr, isOutput ? 1 : 0);
    if (count <= 0)
        return devices;
    QVector<CS_AUDIODEVICE> raw(count);
    const qsizetype filled = csoundGetAudioDevList(cs, raw.data(), isOutput ? 1 : 0);
    if (filled <= 0)
        return devices;

    const bool probeRate = withSamplerate && isFixedSamplerateBackend(module);
    // CoreAudio reports a rate per device; the other fixed backends use a
    // single system-wide rate.
    const bool perDeviceRate = isPerDeviceSamplerateBackend(module);
    int moduleRate = -1;
    if (probeRate && !perDeviceRate)
        moduleRate = backendSamplerate(module);

    for (qsizetype i = 0; i < qMin(count, filled); ++i) {
        AudioDeviceInfo info;
        info.name = safeQString(raw[i].device_name);
        info.id = safeQString(raw[i].device_id);
        info.isOutput = raw[i].isOutput != 0;
        info.channels = raw[i].max_nchnls;
        if (probeRate) {
            info.sampleRate = perDeviceRate
                    ? deviceSamplerate(module, info.id, isOutput)
                    : moduleRate;
        }
        devices.append(info);
    }
    if (module == "jack"_L1)
        return groupJackDevices(devices);
    return devices;
}

QList<AudioDeviceInfo> ConfigLists::audioDeviceGroups(const QString &module,
                                                      bool isOutput)
{
    const auto groups = audioDeviceGroups(module);
    return isOutput ? groups.second : groups.first;
}

QPair<QList<AudioDeviceInfo>, QList<AudioDeviceInfo>>
ConfigLists::audioDeviceGroups(const QString &module)
{
    const auto cached = m_audioDeviceGroupCache.constFind(module);
    if (cached != m_audioDeviceGroupCache.constEnd())
        return cached.value();

    CSOUND *cs = csoundCreate(&m_messages, nullptr);
    csoundSetMessageCallback(cs, msgCallback);
    csoundSetRTAudioModule(cs, module.toLocal8Bit().constData());
    const QList<AudioDeviceInfo> inputs =
            audioDevicesFromCsound(cs, module, false, false);
    const QList<AudioDeviceInfo> outputs =
            audioDevicesFromCsound(cs, module, true, false);
    csoundDestroy(cs);
    const auto groups = qMakePair(inputs, outputs);
    m_audioDeviceGroupCache.insert(module, groups);
    return groups;
}

void ConfigLists::clearAudioDeviceCache()
{
    m_audioDeviceGroupCache.clear();
    // Device presence, backend system rate, per-device rates and the PipeWire
    // native rate can all change while CsoundQt is running. A Settings refresh
    // must invalidate all of them, not just the device lists.
    m_backendSamplerates.clear();
    m_deviceSamplerates.clear();
    m_pipeWireSamplerate = -1;
}

int ConfigLists::audioDeviceChannels(const QString &module, const QString &device,
                                     bool isOutput,
                                     const QList<AudioDeviceInfo> *devices)
{
    if (device.isEmpty())
        return 0; // No Input / No Output

    QList<AudioDeviceInfo> loaded;
    const QList<AudioDeviceInfo> *list = devices;
    if (list == nullptr) {
        loaded = audioDeviceGroups(module, isOutput);
        list = &loaded;
    }

    for (const AudioDeviceInfo &group : *list) {
        if (group.id == device || group.name == device)
            return group.channels;
    }

    const QString defaultToken = isOutput ? u"dac"_s : u"adc"_s;
    if (device == defaultToken) {
        if (module == "jack"_L1) {
            const QString wanted = isOutput ? u"system:playback_"_s
                                            : u"system:capture_"_s;
            for (const AudioDeviceInfo &group : *list) {
                if (group.name == wanted)
                    return group.channels;
            }
        }
        // The backend's "default" device is not necessarily the first entry,
        // so its channel count is not reliable here.
        return -1;
    }

    if (module == "jack"_L1) {
        QString wanted;
        if (device == "dac:system:playback_"_L1)
            wanted = u"system:playback_"_s;
        else if (device == "adc:system:capture_"_L1)
            wanted = u"system:capture_"_s;
        if (!wanted.isEmpty()) {
            for (const AudioDeviceInfo &group : *list) {
                if (group.name == wanted)
                    return group.channels;
            }
        }
        // Regex device selection, e.g. "adc:.*:capture_.*": count the matching
        // ports. Each JACK port is one channel.
        QString pattern = device;
        if (pattern.startsWith("adc:"_L1) || pattern.startsWith("dac:"_L1))
            pattern = pattern.section(QLatin1Char(':'), 1);
        if (pattern != "null"_L1) {
            const QList<QStringPair> ports = isOutput
                    ? getAudioOutputDevices(u"jack"_s)
                    : getAudioInputDevices(u"jack"_s);
            const QRegularExpression regex(pattern);
            if (regex.isValid()) {
                int count = 0;
                for (const QStringPair &port : ports) {
                    if (regex.match(port.first).hasMatch())
                        ++count;
                }
                if (count > 0)
                    return count;
            }
        }
    }

    return -1;
}

QString ConfigLists::defaultAudioDeviceId(const QString &module, bool isOutput,
                                          const QList<AudioDeviceInfo> &devices)
{
    if (devices.isEmpty())
        return QString();
    if (module != "jack"_L1)
        return devices.first().id;

    const QString prefix = isOutput ? u"dac"_s : u"adc"_s;
    int bestNumber = -1;
    QString bestId;
    for (const AudioDeviceInfo &device : devices) {
        if (!device.id.startsWith(prefix))
            continue;
        bool ok = false;
        const int number = device.id.mid(prefix.size()).toInt(&ok);
        if (ok && (bestNumber < 0 || number < bestNumber)) {
            bestNumber = number;
            bestId = device.id;
        }
    }
    return bestId.isEmpty() ? devices.first().id : bestId;
}

QStringList ConfigLists::runCsoundInternally(QStringList flags)
{
//#if CS_APIVERSION>=4 // CS_APIVERSION is not any more in Csound 7 source
	const char *argv[33];
//#else
//	char *argv[33];
//#endif
    int index = 1;
    Q_ASSERT(flags.size() < 32);
	argv[0]  = (char *) calloc(7, sizeof(char));
	strncpy((char *) argv[0], "csound", 6);

	foreach (QString flag, flags) {
		argv[index] = (char *) calloc(flag.size()+1, sizeof(char));
		strncpy((char *) argv[index], flag.toLatin1(), flag.size());
		index++;
	}
    int argc = flags.size() + 1;
#ifdef MACOSX_PRE_SNOW
	//Remember menu bar to set it after FLTK grabs it
	menuBarHandle = GetMenuBar();
#endif
    m_messages.clear();
    CSOUND *csoundD = csoundCreate(&m_messages, nullptr);

	csoundSetMessageCallback(csoundD, msgCallback);
    int result = csoundCompile(csoundD, argc, argv);

	if(!result) {
        //CS7
        //csoundPerform(csoundD);
        while( csoundPerformKsmps(csoundD)==0);
    } else {
        qDebug() << "Error compiling.";
        qDebug() << m_messages;
    }

    // FIXME This crashes on Linux for portmidi! And messes up devices on OS X
    //csoundDestroy(csoundD);
    csoundReset(csoundD); // CS7

#ifdef MACOSX_PRE_SNOW
	// Put menu bar back
	SetMenuBar(menuBarHandle);
#endif
	return m_messages.split("\n");
}


bool ConfigLists::isSoundFile(const QString &fileName) const
{
    const QString suffix = QFileInfo(fileName).suffix().toLower();
    if (suffix.isEmpty()) {
        return false;
    }
    // fileTypeNames holds the formats this Csound build can record; they are
    // also readable through GEN01.
    if (fileTypeNames.contains(suffix)) {
        return true;
    }
    // Formats that are commonly read but not offered for recording.
    static const QStringList extraSoundExtensions = {
        u"aif"_s, u"aifc"_s, u"snd"_s,
        u"wave"_s, u"ogg"_s, u"oga"_s,
        u"mp3"_s
    };
    return extraSoundExtensions.contains(suffix);
}

bool ConfigLists::isJackRunning() {
    CSOUND *cs = csoundCreate(nullptr, nullptr);
    csoundSetRTAudioModule(cs, "jack");
    int n = csoundGetAudioDevList(cs, nullptr, 1);
    csoundDestroy(cs);
    return n > 0;
}

bool ConfigLists::isPipeWireRunning() {
#ifdef Q_OS_LINUX
    QString dir = qEnvironmentVariable("PIPEWIRE_RUNTIME_DIR");
    if (dir.isEmpty())
        dir = QStandardPaths::writableLocation(QStandardPaths::RuntimeLocation);
    if (dir.isEmpty())
        dir = qEnvironmentVariable("XDG_RUNTIME_DIR");
    if (dir.isEmpty())
        return false;
    QString remote = qEnvironmentVariable("PIPEWIRE_REMOTE",
                                          u"pipewire-0"_s);
    return QFile::exists(dir + QLatin1Char('/') + remote);
#else
    return false;
#endif
}

int ConfigLists::pipeWireSamplerate()
{
    if (m_pipeWireSamplerate > 0)
        return m_pipeWireSamplerate;
    if (!isPipeWireRunning())
        return -1;

    int sampleRate = -1;

    // pw-metadata reports the graph clock rate.
    QProcess metadata;
    metadata.start(u"pw-metadata"_s, {u"-n"_s, u"settings"_s});
    if (metadata.waitForFinished(1000)) {
        const QString output = QString::fromLocal8Bit(metadata.readAllStandardOutput());
        static const QRegularExpression rateRx(
                    uR"(key:'clock\.rate'\s+value:'(\d+)')"_s);
        const QRegularExpressionMatch match = rateRx.match(output);
        if (match.hasMatch())
            sampleRate = match.captured(1).toInt();
    }

    // Fall back to PipeWire's PulseAudio compatibility layer.
    if (sampleRate <= 0) {
        QProcess pactl;
        pactl.start(u"pactl"_s, {u"info"_s});
        if (pactl.waitForFinished(1000)) {
            const QString output = QString::fromLocal8Bit(pactl.readAllStandardOutput());
            static const QRegularExpression specRx(
                        uR"(Default Sample Specification:.*?(\d+)Hz)"_s);
            const QRegularExpressionMatch match = specRx.match(output);
            if (match.hasMatch())
                sampleRate = match.captured(1).toInt();
        }
    }

    // Last resort: ask Csound's PipeWire module.
    if (sampleRate <= 0) {
        for (const QString &module : {u"rtpw"_s, u"pipewire"_s, u"pw"_s}) {
            if (!rtAudioNames.contains(module))
                continue;
            const int rate = backendSamplerate(module);
            if (rate > 0) {
                sampleRate = rate;
                break;
            }
        }
    }

    if (sampleRate > 0)
        m_pipeWireSamplerate = sampleRate;
    return sampleRate;
}

bool ConfigLists::isFixedSamplerateBackend(const QString &module)
{
    return module == "jack"_L1
            || module == "rtpw"_L1
            || module == "pipewire"_L1
            || module == "pw"_L1
            || module == "auhal"_L1
            || module == "coreaudio"_L1;
}

int ConfigLists::backendSamplerate(const QString &module)
{
    if (!isFixedSamplerateBackend(module))
        return -1;
    if (m_backendSamplerates.contains(module))
        return m_backendSamplerates.value(module);
    int sampleRate = -1;
    QTemporaryFile csd(QDir::tempPath() + QDir::separator() + "csoundqt-srprobe-XXXXXX.csd");
    if (csd.open()) {
        csd.write("<CsoundSynthesizer>\n<CsInstruments>\n"
                  "sr=48000\nksmps=64\nnchnls=2\n</CsInstruments>\n"
                  "<CsScore>\n</CsScore>\n</CsoundSynthesizer>\n");
        csd.flush();
        CSOUND *cs = csoundCreate(&m_messages, nullptr);
        csoundSetMessageCallback(cs, msgCallback);
        const QByteArray rtAudio = ("-+rtaudio=" + module).toLocal8Bit();
        const QByteArray orchestra = csd.fileName().toLocal8Bit();
        const QByteArray output = module == "jack"_L1
                ? QByteArray("-odac:null") : QByteArray("-odac");
        const char *argv[] = {"csound", "--get-system-sr", rtAudio.constData(),
                              output.constData(), orchestra.constData()};
        csoundCompile(cs, 5, argv);
        const double sr = double(csoundSystemSr(cs, 0));
        csoundDestroy(cs);
        if (sr > 0)
            sampleRate = int(sr + 0.5);
    }
    if (sampleRate > 0)
        m_backendSamplerates.insert(module, sampleRate);
    return sampleRate;
}

bool ConfigLists::isPerDeviceSamplerateBackend(const QString &module)
{
    return module == "auhal"_L1 || module == "coreaudio"_L1;
}

int ConfigLists::deviceSamplerate(const QString &module, const QString &device,
                                  bool isOutput)
{
    const QString cacheKey = module + QLatin1Char('|') + device
            + (isOutput ? u"|out"_s : u"|in"_s);
    if (m_deviceSamplerates.contains(cacheKey))
        return m_deviceSamplerates.value(cacheKey);

    int sampleRate = -1;
    QTemporaryFile csd(QDir::tempPath() + QDir::separator() + "csoundqt-devsrprobe-XXXXXX.csd");
    if (csd.open()) {
        csd.write("<CsoundSynthesizer>\n<CsInstruments>\n"
                  "sr=48000\nksmps=64\nnchnls=1\n</CsInstruments>\n"
                  "<CsScore>\n</CsScore>\n</CsoundSynthesizer>\n");
        csd.flush();
        CSOUND *cs = csoundCreate(&m_messages, nullptr);
        csoundSetMessageCallback(cs, msgCallback);
        const QByteArray rtAudio = ("-+rtaudio=" + module).toLocal8Bit();
        const QByteArray orchestra = csd.fileName().toLocal8Bit();
        const QByteArray deviceFlag = ((isOutput ? "-o" : "-i") + device).toLocal8Bit();
        const char *argv[] = {"csound", "--get-system-sr", rtAudio.constData(),
                              deviceFlag.constData(), orchestra.constData()};
        csoundCompile(cs, 5, argv);
        const double sr = double(csoundSystemSr(cs, 0));
        csoundDestroy(cs);
        if (sr > 0)
            sampleRate = int(sr + 0.5);
    }
    if (sampleRate > 0)
        m_deviceSamplerates.insert(cacheKey, sampleRate);
    return sampleRate;
}

static int jackNaturalCompare(const QString &left, const QString &right)
{
    const QChar *l = left.constData();
    const QChar *r = right.constData();
    const QChar *lEnd = l + left.size();
    const QChar *rEnd = r + right.size();
    enum { STRING, NUMBER } mode = STRING;
    while (l < lEnd && r < rEnd) {
        if (mode == STRING) {
            while (l < lEnd && r < rEnd) {
                const bool lDigit = l->isDigit();
                const bool rDigit = r->isDigit();
                if (lDigit && rDigit) {
                    mode = NUMBER;
                    break;
                }
                if (lDigit)
                    return -1;
                if (rDigit)
                    return 1;
                const int diff = int(l->toUpper().unicode()) - int(r->toUpper().unicode());
                if (diff != 0)
                    return diff;
                ++l;
                ++r;
            }
        } else {
            unsigned long lInt = 0;
            unsigned long rInt = 0;
            while (l < lEnd && l->isDigit()) {
                lInt = lInt * 10 + unsigned(l->unicode() - '0');
                ++l;
            }
            while (r < rEnd && r->isDigit()) {
                rInt = rInt * 10 + unsigned(r->unicode() - '0');
                ++r;
            }
            if (lInt != rInt)
                return lInt < rInt ? -1 : 1;
            mode = STRING;
        }
    }
    if (r < rEnd)
        return -1;
    if (l < lEnd)
        return 1;
    return 0;
}

static bool jackNaturalLessThan(const QString &a, const QString &b)
{
    return jackNaturalCompare(a, b) < 0;
}

// Common prefix of a numbered JACK port family, e.g. "jaaa:in_1" -> "jaaa:in_".
static QString jackAggregateKey(const QString &portName)
{
    const int colon = portName.indexOf(QLatin1Char(':'));
    if (colon < 0)
        return portName;
    const QString shortName = portName.mid(colon + 1);
    const int underscore = shortName.lastIndexOf(QLatin1Char('_'));
    if (underscore < 0)
        return portName;
    return portName.left(colon + 1) + shortName.left(underscore + 1);
}

static QList<AudioDeviceInfo> groupJackDevices(const QList<AudioDeviceInfo> &ports)
{
    QHash<QString, QList<AudioDeviceInfo>> groups;
    QStringList keys;
    for (const AudioDeviceInfo &port : ports) {
        const QString key = jackAggregateKey(port.name);
        if (!groups.contains(key))
            keys.append(key);
        groups[key].append(port);
    }

    QList<AudioDeviceInfo> devices;
    for (const QString &key : keys) {
        QList<AudioDeviceInfo> members = groups.value(key);
        std::sort(members.begin(), members.end(),
                  [](const AudioDeviceInfo &a, const AudioDeviceInfo &b) {
            return jackNaturalLessThan(a.name, b.name);
        });
        AudioDeviceInfo device = members.first();
        device.name = key;
        device.channels = members.size();
        devices.append(device);
    }
    std::sort(devices.begin(), devices.end(),
              [](const AudioDeviceInfo &a, const AudioDeviceInfo &b) {
        return a.name < b.name;
    });
    return devices;
}

static QString jackEscapeRegex(const QString &text)
{
    static const QString special = u"\\^$.|?*+()[]{}"_s;
    QString escaped;
    escaped.reserve(text.size() * 2);
    for (const QChar c : text) {
        if (special.contains(c))
            escaped += QLatin1Char('\\');
        escaped += c;
    }
    return escaped;
}

static QString jackPortFamily(const QString &portName)
{
    const QString shortName = portName.section(QLatin1Char(':'), 1);
    const int underscore = shortName.lastIndexOf(QLatin1Char('_'));
    return underscore > 0 ? shortName.left(underscore) : shortName;
}

static bool jackDeviceIndex(const QString &device, const QString &prefix, int *index)
{
    if (!device.startsWith(prefix))
        return false;
    const QString number = device.mid(prefix.size());
    if (number.isEmpty())
        return false;
    bool ok = false;
    const uint value = number.toUInt(&ok);
    if (!ok)
        return false;
    if (index != nullptr)
        *index = int(value);
    return true;
}

QString ConfigLists::jackHardwarePattern(bool isOutput)
{
    const QString prefix = isOutput ? u"dac"_s : u"adc"_s;
    if (isPipeWireRunning()) {
        return prefix + (isOutput ? u":.*:playback_.*"_s
                                  : u":.*:capture_.*"_s);
    }
    return prefix + (isOutput ? u":system:playback_"_s
                              : u":system:capture_"_s);
}

QString ConfigLists::resolveJackDevice(const QString &device, bool isOutput)
{
    const QString prefix = isOutput ? u"dac"_s : u"adc"_s;
    if (device.contains(QLatin1Char(':')))
        return device;
    if (device.isEmpty())
        return isOutput ? jackHardwarePattern(true) : QString();
    if (device == prefix)
        return jackHardwarePattern(isOutput);
    int index = -1;
    if (!jackDeviceIndex(device, prefix, &index))
        return device;
    const QList<QStringPair> ports = isOutput ? getAudioOutputDevices(u"jack"_s)
                                              : getAudioInputDevices(u"jack"_s);
    if (index < 0 || index >= int(ports.size()))
        return device;
    const QString selected = ports.at(index).first;
    const QString client = selected.section(QLatin1Char(':'), 0, 0);
    const QString family = jackPortFamily(selected);
    QStringList siblings;
    for (const QStringPair &port : ports) {
        if (port.first.section(QLatin1Char(':'), 0, 0) == client
                && jackPortFamily(port.first) == family) {
            siblings.append(port.first);
        }
    }
    if (siblings.isEmpty())
        return device;
    std::sort(siblings.begin(), siblings.end(), jackNaturalLessThan);
    // A numeric device id refers to the aggregate device, so connect from the
    // first port of the family. Csound limits the connection to its own
    // channel count.
    QStringList escaped;
    for (const QString &port : siblings)
        escaped.append(jackEscapeRegex(port));
    return prefix + QLatin1Char(':') + escaped.join(QLatin1Char('|'));
}

QString ConfigLists::audioDeviceDisplayName(const QString &module, bool isOutput,
                                            const QString &id)
{
    if (id.isEmpty())
        return id;
    const QList<AudioDeviceInfo> devices = audioDeviceGroups(module, isOutput);
    for (const AudioDeviceInfo &device : devices) {
        if (device.id == id || device.name == id)
            return device.name;
    }
    // Default tokens ("dac", "adc", "dac:null", regexes, ...) stay as they are.
    return id;
}

QString ConfigLists::audioDeviceIdForDisplay(const QString &module, bool isOutput,
                                             const QString &text)
{
    if (text.isEmpty())
        return text;
    const QList<AudioDeviceInfo> devices = audioDeviceGroups(module, isOutput);
    for (const AudioDeviceInfo &device : devices) {
        if (device.name == text || device.id == text)
            return device.id;
    }
    return text;
}
