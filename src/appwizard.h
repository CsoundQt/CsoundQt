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

#ifndef APPWIZARD_H
#define APPWIZARD_H

#include <QWizard>

class QCheckBox;
class QGroupBox;
class QLabel;
class QLineEdit;
class QRadioButton;
class QListWidget;

class AppWizard : public QWizard
{
	Q_OBJECT
public:
	explicit AppWizard(QWidget *parent, QString opcodeDir,
					   QString csd, QString sdkDir);

	void makeApp();
	//    void setOpcodeDir(QString opcodeDir) {m_opcodeDir = opcodeDir;}

signals:

public slots:
	//    virtual void accept();
private:
	//    QString m_opcodeDir;
	QString m_csd;
	QString m_sdkDir;
	QString m_fullText;
	int m_pluginsPage;
	int m_additionalsPage;
	QStringList m_dataFiles;

	QStringList processDataFiles();
	void copyFolder(QString sourceFolder, QString destFolder);


	void createWinApp(QString appName, QString appDir, QStringList dataFiles,
					  QStringList plugins, QString sdkDir, QString libDir,
					  QString opcodeDir,  QString qtLibsDir);
	void createMacApp(QString appName, QString appDir, QStringList dataFiles,
					  QStringList plugins, QString sdkDir,  QString libDir,
					  QString opcodeDir, QString qtLibsDir);
	void createLinuxApp(QString appName, QString appDir, QStringList dataFiles,
						QStringList plugins, QString sdkDir,  QString libDir,
						QString opcodeDir, QString qtLibsDir);

	void getLinuxLibDeps(QString libname);
};


#endif // APPWIZARD_H
