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
#include <QApplication>
#include <QDebug>

#include "csound.h"
#include "configlists.h"

ConfigLists::ConfigLists()
{
	fileTypeNames << "wav" << "aiff" << "au" << "avr" << "caf" << "flac"
				  << "htk" << "ircam" << "mat4" << "mat5" << "nis" << "paf" << "pvf"
				  << "raw" << "sd2" << "sds" << "svx" << "voc" << "w64" << "wavex";
	fileTypeExtensions << "*.wav" << "*.aif;*.aiff" << "*.au" << "*.avr" << "*.caf"
					   << "*.flac" << "*.htk;*.*" << "*.ircam;*.*" << "*.mat4;*.*" << "*.mat5;*.*"
					   << "*.nis;*.*" << "*.paf;*.*" << "*.pvf" << "*.raw;*.*" << "*.sd2;*.*" << "*.sds;*.*"
					   << "*.svx;*.*" << "*.voc;*.*" << "*.w64;*.wav" << "*.wavex;*.wav";
	fileTypeLongNames << "WAVE" << "AIFF" << "au" << "avr" << "CAF" << "FLAC"
					  << "htk" << "ircam" << "mat4" << "mat5" << "nis" << "paf" << "pvf"
					  << "Raw (Headerless)" << "Sound Designer II" << "sds" << "svx" << "voc"
					  << "WAVE (w64)" << "WAVE (wavex)";

	fileFormatFlags << "24bit" << "short"<< "uchar"
					<< "schar"<< "float"<< "long";
	fileFormatNames << "24 Bit" << "16 Bit (short)" << "unsigned 8-bit"
					<< "signed 8-bit" << "32 bit float"<< "long (32-bit)";

	refreshModules();
	languages << "English" << "Spanish" << "German" << "French" << "Portuguese" << "Italian"  << "Turkish"  << "Finnish" << "Russian" << "Korean" << "Persian";
	languageCodes << "en" << "es" << "de" << "fr" << "pt" << "it" << "tr" << "fi" << "ru" << "kr" << "fa";
}


ConfigLists::~ConfigLists()
{
}

void ConfigLists::msgCallback(CSOUND *csound, int attr, const char *fmt, va_list args)
{
	Q_UNUSED(attr);
	QString *ud = (QString *) csoundGetHostData(csound);
	QString msg;
	msg = msg.vsprintf(fmt, args);
	if (msg.isEmpty()) {
		return;
	}
	ud->append(msg);
}

void ConfigLists::refreshModules()
{
	rtMidiNames.clear();
	rtAudioNames.clear();
#ifdef CSOUND6
	CSOUND *csound = csoundCreate(NULL);
	char *name, *type;
	int n = 0;
	while(!csoundGetModule(csound, n++, &name, &type)) {
		if (strcmp(type, "audio") == 0) {
			rtAudioNames << name;
//			printf("Module %d:  %s (%s) \n", n, name, type);
		}
	}
	rtAudioNames << "null"; // add also none (-+rtaudio=null)
	n = 0;
	while(!csoundGetModule(csound, n++, &name, &type)) {
		if (strcmp(type, "midi") == 0) {
			rtMidiNames << name;
//			printf("MIDI Module %d:  %s (%s) \n", n, name, type);
		}
	}
	if (rtAudioNames.contains("jack")) { // if jack audio is present, also jack midi can be used
		rtMidiNames <<  "jack";
	}
	rtMidiNames << "virtual" << "none";
#else
#ifdef Q_OS_LINUX
	rtAudioNames << "portaudio" << "alsa" << "jack" << "pulse" << "none";
#endif
#ifdef Q_OS_SOLARIS
	rtAudioNames << "portaudio" << "pulse" << "none";
#endif
#ifdef Q_OS_MAC
	rtAudioNames << "coreaudio" << "portaudio" << "auhal" << "jack" << "none";
#endif
#ifdef Q_OS_WIN32
	rtAudioNames << "portaudio" << "winmm" << "jack" <<  "none";
#endif
#ifdef Q_OS_HAIKU
	rtAudioNames << "haiku" << "none";
#endif
#ifdef Q_OS_LINUX
	rtMidiNames << "none" << "alsa" << "alsaseq" << "jack" << "portmidi" << "virtual";
#endif
#ifdef Q_OS_SOLARIS
	rtMidiNames << "none" << "portmidi"<< "virtual";
#endif
#ifdef Q_OS_MAC
	rtMidiNames << "none" << "coremidi" << "portmidi" << "jack" << "virtual";
#endif
#ifdef Q_OS_WIN32
	rtMidiNames << "none" << "winmm" << "portmidi" << "virtual";
#endif
#endif
    csoundDestroy(csound);
}

QHash<QString,QString> ConfigLists::getMidiInputDevices(QString module)
{
	// based on code by Steven Yi
	QHash<QString,QString> deviceList;
#ifdef CSOUND6
	CSOUND *cs = csoundCreate(NULL);
	if (module=="jack") {
		csoundSetOption(cs,"-+rtaudio=jack");
		csoundSetOption(cs,"-+rtmidi=jack");
	}
	csoundSetMIDIModule(cs, module.toLatin1().data());
	int i,newn, n = csoundGetMIDIDevList(cs,NULL,0);
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
			displayName = devs[i].device_name;
			id = devs[i].device_name;
		} else {
			displayName = QString("%1 (%2)").arg(devs[i].device_name).arg(devs[i].interface_name);
			id = QString(devs[i].device_id);
		}
		deviceList.insert(displayName, id);
	}
	free(devs);
    csoundDestroy(cs);
#else
	if (module == "none") {
		return deviceList;
	}
	if (module == "alsa") {
		QProcess amidi;
		amidi.start("amidi", QStringList() << "-l");
		if (!amidi.waitForFinished())
			return deviceList;

		QByteArray result = amidi.readAllStandardOutput();
		QString values = QString(result);
		QStringList st = values.split("\n");
		st.takeFirst(); // Remove first column lines
		for (int i = 0; i < st.size(); i++){
			QStringList parts = st[i].split(" ", QString::SkipEmptyParts);
			if (parts.size() > 0 && parts[0].contains("I")) {
				QString devname = parts[1]; // Devce name
				parts.takeFirst(); // Remove IO flags
				QString fullname = parts.join(" ") ; // Full name with description
				deviceList.insert(fullname, devname);
			}
		}
		deviceList.insert("All available devices ", "a");
	}
	else if (module == "virtual") {
		QString name = qApp->translate("Enabled", "Virtual MIDI keyboard Enabled");
		deviceList.insert(name, "0");
	}
	else { // if not alsa (i.e. winmm or portmidi)
		QFile file(":/test.csd");
		if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
			return deviceList;
		QString jackCSD = QString(file.readAll());
		QString tempText = jackCSD;
		tempText.replace("$SR", "441000");
		QTemporaryFile tempFile(QDir::tempPath() + QDir::separator() + "testcsdCsoundQtXXXXXX.csd");
		tempFile.open();
		QTextStream out(&tempFile);
		out << tempText;
		tempFile.close();
		tempFile.open();

		QStringList flags;
		QString rtMidiFlag = "-+rtmidi=" + module;
		flags << "-+msg_color=false" << rtMidiFlag << "-otest"  << "-n"  << "-M999" << tempFile.fileName();
		QStringList messages = runCsoundInternally(flags);

		QString startText, endText;
		if (module == "portmidi") {
			startText = "The available MIDI";
			endText = "*** PortMIDI";
		}
		else if (module == "winmm") {
			startText = "The available MIDI";
			endText = "rtmidi: input device number is out of range";
		}
		else if (module == "coremidi") {
			int index = messages.indexOf(QRegExp("[0-9]{1,1} MIDI sources in system\\s*"));
            if (index >= 0) {
                for (int i = 0; i < messages[index].split(" ")[0].toInt(); i++) {
                    deviceList.insert(QString::number(i), QString::number(i));
                }
            }
		}
		else if (module == "alsaseq") {
			//FIXME parse alsaseq devices
		}
		if (startText == "" && endText == "") {
			return deviceList;
		}
		bool collect = false;
		foreach (QString line, messages) {
			if (collect) {
				if (endText.length() > 0 && line.indexOf(endText) >= 0) {
					collect = false;
				}
				else {
					if (line.indexOf(":") >= 0) {
//						qDebug()  << line;
						QString fullname = line.mid(line.indexOf(":") + 1).trimmed();
						QString devname = line.mid(0,line.indexOf(":")).trimmed();
						deviceList.insert(fullname, devname);
					}
				}
			}
			else if (line.indexOf(startText) >= 0) {
				collect = true;
			}
		}
	}
#endif
	qDebug()<<"Devices found: "<<deviceList;
	return deviceList;
}

QList<QPair<QString, QString> > ConfigLists::getMidiOutputDevices(QString module)
{
	QList<QPair<QString, QString> > deviceList;
#ifdef CSOUND6
	CSOUND *cs = csoundCreate(NULL);
	if (module=="jack") {
		csoundSetOption(cs,"-+rtaudio=jack");
		csoundSetOption(cs,"-+rtmidi=jack");
	}
	csoundSetMIDIModule(cs, module.toLatin1().data());
	int i,newn, n = csoundGetMIDIDevList(cs,NULL,1);
	CS_MIDIDEVICE *devs = (CS_MIDIDEVICE *) malloc(n*sizeof(CS_MIDIDEVICE));
	newn = csoundGetMIDIDevList(cs,devs,1);
	if (newn != n) {
		qDebug()  << "Device number changed";
		return deviceList;
	}
	for (i = 0; i < n; i++) {
//		qDebug() << devs[i].device_name;
		QString displayName, id;
		if (module=="jack") {
			displayName = devs[i].device_name;
			id = devs[i].device_name;
		} else {
			displayName = QString("%1 (%2)").arg(devs[i].device_name).arg(devs[i].interface_name);
			id = QString(devs[i].device_id);
		}

		deviceList.append(QPair<QString,QString>(displayName, id));
	}
	free(devs);
    csoundDestroy(cs);
#else
	if (module == "none") {
		return deviceList;
	}
	if (module == "alsa") {
		QProcess amidi;
		amidi.start("amidi", QStringList() << "-l");
		if (!amidi.waitForFinished())
			return deviceList;

		QByteArray result = amidi.readAllStandardOutput();
		QString values = QString(result);
		QStringList st = values.split("\n");
		st.takeFirst(); // Remove first column lines
		for (int i = 0; i < st.size(); i++){
			QStringList parts = st[i].split(" ", QString::SkipEmptyParts);
			if (parts.size() > 0 && parts[0].contains("O")) {
				QPair<QString, QString> device;
				device.second = parts[1]; // Devce name
				parts.takeFirst(); // Remove IO flags
				device.first = parts.join(" ") ; // Full name with description
				deviceList.append(device);
			}
		}
	}
	else if (module == "virtual") {
		// do nothing
	}
	else { // if not alsa (i.e. winmm or portmidi)
		QFile file(":/test.csd");
		if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
			return deviceList;
		QString jackCSD = QString(file.readAll());
		QString tempText = jackCSD;
		tempText.replace("$SR", "441000");
		QTemporaryFile tempFile(QDir::tempPath() + QDir::separator() + "testcsdCsoundQtXXXXXX.csd");
		tempFile.open();
		QTextStream out(&tempFile);
		out << tempText;
		tempFile.close();
		tempFile.open();

		QStringList flags;
		flags << "-+msg_color=false" << "-otest"  << "-n"   << "-Q999" << tempFile.fileName();
		QStringList messages = runCsoundInternally(flags);

		QString startText, endText;
		if (module == "portmidi") {
			startText = "The available MIDI";
			endText = "*** PortMIDI";
		}
		else if (module == "winmm") {
			startText = "The available MIDI";
			endText = "rtmidi: output device number is out of range";
		}
		if (startText == "" && endText == "") {
			return deviceList;
		}
		bool collect = false;
		foreach (QString line, messages) {
			if (collect) {
				if (endText.length() > 0 && line.indexOf(endText) >= 0) {
					collect = false;
				}
				else {
					if (line.indexOf(":") >= 0) {
						qDebug("%s", line.toLocal8Bit().constData());
						QPair<QString, QString> device;
						device.first = line.mid(line.indexOf(":") + 1).trimmed();
						device.second = line.mid(0,line.indexOf(":")).trimmed();
						deviceList.append(device);
					}
				}
			}
			else if (line.indexOf(startText) >= 0) {
				collect = true;
			}
		}
	}
#endif
	return deviceList;
}

QList<QPair<QString, QString> > ConfigLists::getAudioInputDevices(QString module)
{
	//  qDebug()  ;
	QList<QPair<QString, QString> > deviceList;
#ifdef CSOUND6
	CSOUND *cs = csoundCreate(NULL);
	csoundSetRTAudioModule(cs, module.toLatin1().data());
	int i,newn, n = csoundGetAudioDevList(cs,NULL,0);
	CS_AUDIODEVICE *devs = (CS_AUDIODEVICE *) malloc(n*sizeof(CS_AUDIODEVICE));
	newn = csoundGetAudioDevList(cs,devs,0);
	if (newn != n) {
		qDebug()  << "Device number changed";
		return deviceList;
	}
	for (i = 0; i < n; i++) {
//		qDebug()  << "evs[i].device_name;
		deviceList.append(QPair<QString,QString>(devs[i].device_name,  QString(devs[i].device_id)));
	}
	free(devs);
    csoundDestroy(cs);
#else
	if (module == "none") {
		return deviceList;
	}
	if (module == "alsa") {
		QFile f("/proc/asound/pcm");
		f.open(QIODevice::ReadOnly | QIODevice::Text);
		QString values = QString(f.readAll());
		QStringList st = values.split("\n");
		foreach (QString line, st) {
			if (line.indexOf("capture") >= 0) {
				QStringList parts = line.split(":");

				QStringList cardId = parts[0].split("-");
				QString buffer = "";
				buffer.append(parts[1]).append(" : ").append(parts[2]);

				QPair<QString, QString> device;
				device.first = buffer;
				device.second = "adc:hw:" + QString::number(cardId[0].toInt()) + "," + QString::number(cardId[1].toInt());
				deviceList.append(device);
			}
		}
	}
	else if (module == "jack") {
		QFile file(":/test.csd");
		if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
			return deviceList;
		QString jackCSD = QString(file.readAll());
		QString tempText = jackCSD;
		tempText.replace("$SR", "1000");
		QTemporaryFile tempFile(QDir::tempPath() + QDir::separator() + "testcsdCsoundQtXXXXXX.csd");
		tempFile.open();
		QTextStream out(&tempFile);
		out << tempText;
		tempFile.close();
		tempFile.open();

		QStringList flags;
		QString previousLine = "";
		// -odac is needed otherwise csound segfaults
		flags << "-+msg_color=false" << "-+rtaudio=jack" << "-iadc:xxx" << "-odac:xxx" << "-B2048" <<  tempFile.fileName();
		QStringList messages = runCsoundInternally(flags);

		QString sr = "";
		foreach (QString line, messages) { // Need to run again if sample rate does not match...
			if (line.indexOf("does not match JACK sample rate") >= 0) {
				sr = line.mid(line.lastIndexOf(" ") + 1);
			}
			if (line.endsWith("channel)\n") || line.endsWith("channels)\n")) {
				QStringList parts = previousLine.split("\"");
				QPair<QString, QString> device;
				device.first = parts[1];
				device.second = "adc:" + parts[1];
				deviceList.append(device);
			}
			previousLine = line;
		}
		if (sr == "") {
			return deviceList;
		}

		tempText = jackCSD;
		tempText.replace("$SR", sr);
		out << tempText;
		tempFile.close();
		tempFile.open();

		messages = runCsoundInternally(flags); // run with same flags as before

		foreach (QString line, messages) {
			if (line.endsWith("channel)\n") || line.endsWith("channels)\n")) {
				QStringList parts = previousLine.split("\"");
				QPair<QString, QString> device;
				device.first = parts[1];
				device.second = "adc:" + parts[1];
				deviceList.append(device);
			}
			previousLine = line;
		}
	}  //ends if (module=="jack")
	else { // if not alsa or jack (i.e. coreaudio or portaudio)
		QFile file(":/test.csd");
		if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
			return deviceList;
		QString jackCSD = QString(file.readAll());
		QString tempText = jackCSD;
		tempText.replace("$SR", "1000");
		QTemporaryFile tempFile(QDir::tempPath() + QDir::separator() + "testcsdCsoundQtXXXXXX.csd");
		tempFile.open();
		QTextStream out(&tempFile);
		out << tempText;
		tempFile.close();
		tempFile.open();

		QStringList flags;
		QString rtAudioFlag = "-+rtaudio=" + module + " ";
		flags << "-+msg_color=false" << rtAudioFlag << "-iadc999" << "-odac999" << "-d" << tempFile.fileName();
		QStringList messages = runCsoundInternally(flags);

		QString startText, endText;
		if (module=="portaudio") {
			startText = "PortAudio: available";
			endText = "error:";
		}
		else if (module=="winmm" || module=="mme") {
			startText = "The available input devices are:";
			endText = "device number is out of range";
		}
		else if (module=="coreaudio") {
			startText = "CoreAudio Module: found";
			endText = "";
		}
		if (startText == "" && endText == "") {
			return deviceList;
		}
		bool collect = false;
		foreach (QString line, messages) {
			if (collect) {
				if (endText.length() > 0 && line.indexOf(endText) >= 0) {
					collect = false;
				}
				else {
					if (module == "coreaudio") {
						QString coreAudioMatch = "=> CoreAudio device";

						if (line.indexOf(coreAudioMatch) >= 0) {
							line = line.mid(coreAudioMatch.length()).trimmed();

							QPair<QString, QString> device;
							device.first = line.mid(line.indexOf(":")).trimmed();
							device.second = "adc" + line.left(line.indexOf(":"));
							deviceList.append(device);
						}
					} // if not coreaudio, i.e. portaudio
					else if (line.indexOf(":") >= 0) {
						QPair<QString, QString> device;
						device.first = line.mid(line.indexOf(":") + 1).trimmed();
						device.second = "adc" + line.left(line.indexOf(":")).trimmed();
						deviceList.append(device);
					}
				}
			}
			else if (line.indexOf(startText) >= 0) {
				collect = true;
			}
		}
	}
#endif
	return deviceList;
}

QList<QPair<QString, QString> > ConfigLists::getAudioOutputDevices(QString module)
{
	//  qDebug() ;
	QList<QPair<QString, QString> > deviceList;
#ifdef CSOUND6
	CSOUND *cs = csoundCreate(NULL);
	csoundSetRTAudioModule(cs, module.toLatin1().data());
	int i,newn, n = csoundGetAudioDevList(cs,NULL,1);
	CS_AUDIODEVICE *devs = (CS_AUDIODEVICE *) malloc(n*sizeof(CS_AUDIODEVICE));
	newn = csoundGetAudioDevList(cs,devs,1);
	if (newn != n) {
		qDebug()  << "OutputDevices Device number changed";
		return deviceList;
	}
	for (i = 0; i < n; i++) {
		//		qDebug()  << devs[i].device_name;
		deviceList.append(QPair<QString,QString>(devs[i].device_name,  QString(devs[i].device_id)));
	}
	free(devs);
    csoundDestroy(cs);
#else
	if (module == "none") {
		return deviceList;
	}
	if (module == "alsa") {
		QFile f("/proc/asound/pcm");
		f.open(QIODevice::ReadOnly | QIODevice::Text);
		QString values = QString(f.readAll());
		QStringList st = values.split("\n");
		foreach (QString line, st) {
			if (line.indexOf("playback") >= 0) {
				QStringList parts = line.split(":");

				QStringList cardId = parts[0].split("-");
				QString buffer = "";
				buffer.append(parts[1]).append(" : ").append(parts[2]);

				QPair<QString, QString> device;
				device.first = buffer;
				device.second = "dac:hw:" + QString::number(cardId[0].toInt()) + "," + QString::number(cardId[1].toInt());
				deviceList.append(device);
			}
		}
	}
	else if (module=="jack") {
		QFile file(":/test.csd");
		if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
			return deviceList;
		QString jackCSD = QString(file.readAll());
		QString tempText = jackCSD;
		tempText.replace("$SR", "1000");
		QTemporaryFile tempFile(QDir::tempPath() + QDir::separator() + "testcsdCsoundQtXXXXXX.csd");
		tempFile.open();
		QTextStream out(&tempFile);
		out << tempText;
		tempFile.close();
		tempFile.open();

		QStringList flags;
		QString previousLine = "";
		flags << "-+msg_color=false" << "-+rtaudio=jack" << "-odac:xxx" << "-B2048" <<  tempFile.fileName();
		QStringList messages = runCsoundInternally(flags);

		QString sr = "";
		foreach (QString line, messages) {
			if (line.indexOf("does not match JACK sample rate") >= 0) {
				sr = line.mid(line.lastIndexOf(" ") + 1);
			}
			if (line.endsWith("channel)\n") || line.endsWith("channels)\n")) {
				QStringList parts = previousLine.split("\"");
				QPair<QString, QString> device;
				device.first = parts[1];
				device.second = "dac:" + parts[1];
				deviceList.append(device);
			}
			previousLine = line;
		}
		if (sr == "") {
			return deviceList;
		}

		tempText = jackCSD;
		tempText.replace("$SR", sr);
		out << tempText;
		tempFile.close();
		tempFile.open();

		messages = runCsoundInternally(flags); // run with same flags as before

		foreach (QString line, messages) {
			if (line.endsWith("channel)\n") || line.endsWith("channels)\n")) {
				QStringList parts = previousLine.split("\"");
				QPair<QString, QString> device;
				device.first = parts[1];
				device.second = "dac:" + parts[1];
				deviceList.append(device);
			}
			previousLine = line;
		}
	}  //ends if (module=="jack")
	else { // if not alsa or jack (i.e. coreaudio or portaudio)
		QFile file(":/test.csd");
		if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
			return deviceList;
		QString jackCSD = QString(file.readAll());
		QString tempText = jackCSD;
		tempText.replace("$SR", "1000");
		QTemporaryFile tempFile(QDir::tempPath() + QDir::separator() + "testcsdCsoundQtXXXXXX.csd");
		tempFile.open();
		QTextStream out(&tempFile);
		out << tempText;
		tempFile.close();
		tempFile.open();

		QStringList flags;
		QString rtAudioFlag = "-+rtaudio=" + module + " ";
		flags << "-+msg_color=false" << rtAudioFlag << "-odac999" << tempFile.fileName();
		QStringList messages = runCsoundInternally(flags);

		QString startText, endText;
		if (module=="portaudio") {
			startText = "PortAudio: available";
			endText = "error:";
		}
		else if (module=="winmm" || module=="mme") {
			startText = "The available output devices are:";
			endText = "device number is out of range";
		}
		else if (module=="coreaudio") {
			startText = "CoreAudio Module: found";
			endText = "";
		}
		if (startText == "" && endText == "") {
			return deviceList;
		}
		bool collect = false;
		foreach (QString line, messages) {
			if (collect) {
				if (endText.length() > 0 && line.indexOf(endText) >= 0) {
					collect = false;
				}
				else {
					if (module == "coreaudio") {
						QString coreAudioMatch = "=> CoreAudio device";

						if (line.indexOf(coreAudioMatch) >= 0) {
							line = line.mid(coreAudioMatch.length()).trimmed();

							QPair<QString, QString> device;
							device.first = line.mid(line.indexOf(":")).trimmed();
							device.second = "dac" + line.left(line.indexOf(":"));
							deviceList.append(device);
						}
					} // if not coreaudio, i.e. portaudio
					else if (line.indexOf(":") >= 0) {
						QPair<QString, QString> device;
						device.first = line.mid(line.indexOf(":") + 1).trimmed();
						device.second = "dac" + line.left(line.indexOf(":")).trimmed();
						deviceList.append(device);
					}
				}
			}
			else if (line.indexOf(startText) >= 0) {
				collect = true;
			}
		}
	}
#endif
	return deviceList;
}

QStringList ConfigLists::runCsoundInternally(QStringList flags)
{
#if CS_APIVERSION>=4
	const char *argv[33];
#else
	char *argv[33];
#endif
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
	CSOUND *csoundD;
	m_messages.clear();
	csoundD=csoundCreate(&m_messages);

	csoundSetMessageCallback(csoundD, msgCallback);
	int result = csoundCompile(csoundD,argc,argv);

	if(!result) {
		csoundPerform(csoundD);
    } else {
        qDebug()  << "Error compiling.";
        qDebug() << m_messages;
    }

    // FIXME This crashes on Linux for portmidi! And messes up devices on OS X
    csoundDestroy(csoundD);

#ifdef MACOSX_PRE_SNOW
	// Put menu bar back
	SetMenuBar(menuBarHandle);
#endif
	return m_messages.split("\n");
}
