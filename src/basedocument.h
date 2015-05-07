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

#ifndef BASEDOCUMENT_H
#define BASEDOCUMENT_H

#include "types.h"
#include "csoundoptions.h"
#include <QWidget>

class WidgetLayout;
class CsoundEngine;
class DocumentView;
class OpEntryParser;
class ConsoleWidget;
class QuteButton; // For registering buttons with main application
class AppProperties;

class BaseDocument : public QObject
{
	Q_OBJECT
public:
	BaseDocument(QWidget *parent, OpEntryParser *opcodeTree, ConfigLists *configlists);
	~BaseDocument();
	virtual int setTextString(QString &text) = 0;
	virtual void loadTextString(QString &text);
	virtual void setFileName(QString name);
	int parseAndRemoveWidgetText(QString &text);
	virtual WidgetLayout* newWidgetLayout();
	void widgetsVisible(bool visible);
	void setFlags(int flags);
	void setAppProperties(AppProperties properties);
	virtual QString getFullText();
	QString getBasicText();
	QString getOrc();
	QString getSco();
	QString getOptionsText();
	QString getWidgetsText();
	QString getPresetsText();
	AppProperties getAppProperties();
	//    void setOpcodeNameList(QStringList opcodeNameList);
	// Get internal components
	WidgetLayout *getWidgetLayout();  // Needed to pass for placing in widget dock panel
	ConsoleWidget *getConsole();  // Needed to pass for placing in console dock panel
	CsoundEngine *getEngine(); // Needed to pass to python interpreter
public slots:
	virtual int play(CsoundOptions *options);
	void pause();
	void stop();
	int record(int mode); // 0=16 bit int  1=32 bit int  2=float
	void stopRecording();
	//    void playParent(); // Triggered from button, ask parent for options
	//    void renderParent();
	void queueEvent(QString line, int delay = 0);
	virtual void registerButton(QuteButton *button) = 0;
protected:
	virtual void init(QWidget *parent, OpEntryParser *opcodeTree) = 0;
	//    virtual BaseView *createView(QWidget *parent, O8pEntryParser *opcodeTree);
	QString fileName;
	QList<WidgetLayout *> m_widgetLayouts;
	OpEntryParser *m_opcodeTree;
	DocumentView *m_view;
	ConsoleWidget *m_console;
	CsoundEngine *m_csEngine;
};

#endif // BASEDOCUMENT_H
