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

#ifndef UTILITIESDIALOG_H
#define UTILITIESDIALOG_H

#include "ui_utilitiesdialog.h"

class Options;
class ConfigLists;

class UtilitiesDialog : public QDialog, private Ui::UtilitiesDialog
{
	Q_OBJECT
public:
	UtilitiesDialog(QWidget *parent, Options *options/*, ConfigLists *m_configlist*/);

private:
	Options *m_options;
	QString m_helpDir; // Html help directory

	void browseFile(QString &destination, QString extension ="");
	void browseDir(QString &destination);
	void changeHelp(QString filename);
	virtual void closeEvent(QCloseEvent * event);

private slots:
	void changeTab(int tab);
	void runAtsa();
	void resetAtsa();
	void setAtsaOutput(QString name);
	void runPvanal();
	void resetPvanal();
	void setPvanalOutput(QString name);
	void runHetro();
	void resetHetro();
	void setHetroOutput(QString name);
	void runLpanal();
	void resetLpanal();
	void setLpanalOutput(QString name);
	void runCvanal();
	void resetCvanal();
	void setCvanalOutput(QString name);
	void browseAtsaInput();
	void browseAtsaOutput();
	void browsePvInput();
	void browsePvOutput();
	void browseHetInput();
	void browseHetOutput();
	void browseLpInput();
	void browseLpOutput();
	void browseCvInput();
	void browseCvOutput();


signals:
	void runUtility(QString flags);
	void Close(bool visible);
};

#endif
