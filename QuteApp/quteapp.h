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

class QuteApp : public QMainWindow
{
    Q_OBJECT

  public:
    QuteApp(QWidget *parent = 0);
    ~QuteApp();

    void createMenus();

  public slots:
    void start();
    void pause();
    void stop();
    void save();
    void showConsole();

private:
    bool loadCsd();
    CsoundOptions *m_options;
    SimpleDocument *m_doc;
    ConsoleWidget *m_console;
    OpEntryParser *m_opcodeTree;
};

#endif // QTAPP_H
