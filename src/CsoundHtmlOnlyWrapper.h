/*
	Copyright (C) 2008-2016 Andres Cabrera
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

#ifndef CsoundHtmlOnlyWrapper_H
#define CsoundHtmlOnlyWrapper_H

#include <QObject>
#include <QDebug>
#include <csound_threaded.hpp>

class CsoundHtmlOnlyWrapper : public QObject
{
    Q_OBJECT
public:
	explicit CsoundHtmlOnlyWrapper(QObject *parent = 0);
    virtual ~CsoundHtmlOnlyWrapper();
	Q_INVOKABLE int compileCsd(const QString &filename);
	Q_INVOKABLE int compileCsdText(const QString &text);
	Q_INVOKABLE int compileOrc(const QString &text);
	Q_INVOKABLE double evalCode(const QString &text);
	Q_INVOKABLE double get0dBFS();
	Q_INVOKABLE int getApiVersion();
	Q_INVOKABLE double getControlChannel(const QString &name);
	Q_INVOKABLE qint64 getCurrentTimeSamples();
	Q_INVOKABLE QString getEnv(const QString &name);
	Q_INVOKABLE int getKsmps();
	Q_INVOKABLE int getNchnls();
	Q_INVOKABLE int getNchnlsInput();
	Q_INVOKABLE QString getOutputName();
	Q_INVOKABLE double getScoreOffsetSeconds();
	Q_INVOKABLE double getScoreTime();
	Q_INVOKABLE int getSr();
	Q_INVOKABLE QString getStringChannel(const QString &name);
	Q_INVOKABLE int getVersion();
	Q_INVOKABLE bool isPlaying();
	Q_INVOKABLE int isScorePending();
	Q_INVOKABLE void message(const QString &text);
    Q_INVOKABLE int perform();
    Q_INVOKABLE int readScore(const QString &text);
    Q_INVOKABLE void reset();
    Q_INVOKABLE void rewindScore();
	Q_INVOKABLE int runUtility(const QString &command, int argc, char **argv);
	Q_INVOKABLE int scoreEvent(char type, const double *pFields, long numFields);
	Q_INVOKABLE void setControlChannel(const QString &name, double value);
	Q_INVOKABLE int setGlobalEnv(const QString &name, const QString &value);
	Q_INVOKABLE void setInput(const QString &name);
    // Dummy for now.
    Q_INVOKABLE void setMessageCallback(QObject *callback);
    Q_INVOKABLE int setOption(const QString &name);
	Q_INVOKABLE void setOutput(const QString &name, const QString &type, const QString &format);
	Q_INVOKABLE void setScoreOffsetSeconds(double value);
	Q_INVOKABLE void setScorePending(bool value);
	Q_INVOKABLE void setStringChannel(const QString &name, const QString &value);
    Q_INVOKABLE int start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE double tableGet(int table_number, int index);
	Q_INVOKABLE int tableLength(int table_number);
	Q_INVOKABLE void tableSet(int table_number, int index, double value);
private:
    QObject *message_callback;
    CsoundThreaded csound;
};

#endif // CsoundHtmlWrapper_H
