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

#include <QStringList>
#include <QPair>

typedef struct CSOUND_ CSOUND;

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

	QList<QPair<QString, QString> > getMidiInputDevices(int moduleIndex);
	QList<QPair<QString, QString> > getMidiOutputDevices(int moduleIndex);
	QList<QPair<QString, QString> > getAudioInputDevices(int moduleIndex);
	QList<QPair<QString, QString> > getAudioOutputDevices(int moduleIndex);

	QStringList runCsoundInternally(QStringList flags);

private:
	QString m_messages;
};

#endif
