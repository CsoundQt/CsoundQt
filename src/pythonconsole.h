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

#ifndef PYTHONCONSOLE_H
#define PYTHONCONSOLE_H

#include <QtGui>

class PyQcsObject;
class PythonQtScriptingConsole;

class PythonConsole : public QDockWidget
{
  Q_OBJECT
  public:
    PythonConsole(QWidget *parent);
    ~PythonConsole();

  public slots:
//    void runCommand(QString command);
    void evaluate(QString evalCode);
    void runScript(QString fileName);

  protected:
    virtual void closeEvent(QCloseEvent * event);
//    virtual void keyPressEvent ( QKeyEvent * event );

  private:
//    void runCurrentCommand();
    PyQcsObject *m_pqcs;
    PythonQtScriptingConsole *m_console;
//    QTextEdit *m_text;
//    QString m_command;

  signals:
    void Close(bool visible);

};

#endif // PYTHONCONSOLE_H
