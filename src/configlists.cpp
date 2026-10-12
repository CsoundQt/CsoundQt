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
#include <QTemporaryFile>
#include <QTextStream>
#include <QDir>
#include <QStandardPaths>
#include <QApplication>
#include <QDebug>

#include <algorithm>

#include "csound.h"
#include "configlists.h"

typedef QPair<QString, QString> QStringPair;


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

	fileFormatFlags << "24bit" << "short"<< "uchar"
					<< "schar"<< "float"<< "long";
	fileFormatNames << "24 Bit" << "16 Bit (short)" << "unsigned 8-bit"
					<< "signed 8-bit" << "32 bit float"<< "long (32-bit)";

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
			rtAudioNames << name;
		}
	}

	rtAudioNames << "null"; // add also none (-+rtaudio=null)
	n = 0;

	while(!csoundGetModule(csound, n++, &name, &type)) {
		if (strcmp(type, "midi") == 0) {
			rtMidiNames << name;
		}
	}

    if (rtAudioNames.contains("jack")) {
        rtMidiNames <<  "jack";
	}
    rtMidiNames << "virtual" << "none";
    csoundDestroy(csound);
    //test:
    qDebug() << Q_FUNC_INFO << rtAudioNames;

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
                                          QStringLiteral("pipewire-0"));
    return QFile::exists(dir + QLatin1Char('/') + remote);
#else
    return false;
#endif
}

bool ConfigLists::isFixedSamplerateBackend(const QString &module)
{
    return module == QLatin1String("jack")
            || module == QLatin1String("auhal")
            || module == QLatin1String("coreaudio")
            || module == QLatin1String("pipewire")
            || module == QLatin1String("pw");
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
        const QByteArray output = module == QLatin1String("jack")
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

static QString jackEscapeRegex(const QString &text)
{
    static const QString special = QStringLiteral("\\^$.|?*+()[]{}");
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
    const QString prefix = isOutput ? QStringLiteral("dac") : QStringLiteral("adc");
    if (isPipeWireRunning()) {
        return prefix + (isOutput ? QStringLiteral(":.*:playback_.*")
                                  : QStringLiteral(":.*:capture_.*"));
    }
    return prefix + (isOutput ? QStringLiteral(":system:playback_")
                              : QStringLiteral(":system:capture_"));
}

QString ConfigLists::resolveJackDevice(const QString &device, bool isOutput,
                                       bool connectSuccessive)
{
    const QString prefix = isOutput ? QStringLiteral("dac") : QStringLiteral("adc");
    if (device.contains(QLatin1Char(':')))
        return device;
    if (device.isEmpty())
        return isOutput ? jackHardwarePattern(true) : QString();
    if (device == prefix)
        return jackHardwarePattern(isOutput);
    int index = -1;
    if (!jackDeviceIndex(device, prefix, &index))
        return device;
    const QList<QStringPair> ports = isOutput ? getAudioOutputDevices(QStringLiteral("jack"))
                                              : getAudioInputDevices(QStringLiteral("jack"));
    if (index < 0 || index >= int(ports.size()))
        return device;
    const QString selected = ports.at(index).first;
    if (!connectSuccessive)
        return prefix + QLatin1Char(':') + jackEscapeRegex(selected);
    const QString client = selected.section(QLatin1Char(':'), 0, 0);
    const QString family = jackPortFamily(selected);
    QStringList siblings;
    for (const QStringPair &port : ports) {
        if (port.first.section(QLatin1Char(':'), 0, 0) == client
                && jackPortFamily(port.first) == family) {
            siblings.append(port.first);
        }
    }
    std::sort(siblings.begin(), siblings.end(), jackNaturalLessThan);
    const int selectedIndex = siblings.indexOf(selected);
    if (selectedIndex < 0)
        return device;
    QStringList escaped;
    for (int i = selectedIndex; i < int(siblings.size()); ++i)
        escaped.append(jackEscapeRegex(siblings.at(i)));
    return prefix + QLatin1Char(':') + escaped.join(QLatin1Char('|'));
}
