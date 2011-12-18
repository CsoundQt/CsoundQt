/*
    Copyright (C) 2010 Andres Cabrera
    mantaraya36@gmail.com

    This file is part of QuteCsound.

    QuteCsound is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    QuteCsound is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#ifndef QUTEAPP_H
#define QUTEAPP_H

#include <QtGui/QMainWindow>

class SimpleDocument;
class CsoundOptions;
class OpEntryParser;
class ConsoleWidget;
class AboutWidget;

class QuteApp : public QMainWindow
{
    Q_OBJECT

  public:
    QuteApp(QWidget *parent = 0);
    ~QuteApp();

    void createMenus();

    typedef enum {
      RUN_RT_ONLY,
      RENDER_ONLY,
      RUN_OR_RENDER
    } RunMode;

  public slots:
    void start();
    void pause();
    void stop();
    void save();
    void showConsole();
	void configure();
    void info();

private:
    bool loadCsd();
    void setAboutTexts();

    CsoundOptions *m_options;
    SimpleDocument *m_doc;
    ConsoleWidget *m_console;
    OpEntryParser *m_opcodeTree;
    AboutWidget *m_aboutWidget;

    // Local Preferences
    QString m_appName;
    QString m_author;
    QString m_email;
    QString m_website;
    QString m_date;
    QString m_version;
    bool m_autorun;
    bool m_showRunOptions;
    bool m_saveOnClose;
    bool m_newParser;
    RunMode m_runMode;
    bool m_saveState;
    QString m_instructions;

};

#endif // QTAPP_H
