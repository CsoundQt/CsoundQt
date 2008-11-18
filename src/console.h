/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.             *
 ***************************************************************************/
#ifndef CONSOLE_H
#define CONSOLE_H

#include <QDockWidget>
#include <QTextEdit>

class Console
{
  public:
    Console();

    ~Console();

    void appendMessage(QString msg);
    void clear();
    void setDefaultFont(QFont font) {text->document()->setDefaultFont(font);}
  protected:
    QTextEdit *text;
};

class DockConsole : public QDockWidget, public Console
{
  Q_OBJECT
  public:
    DockConsole(QWidget * parent): QDockWidget(parent)
    {
      setWindowTitle("Csound Output Console");
      setWidget(text);
    }

    ~DockConsole() {;};
  private:
    virtual void closeEvent(QCloseEvent * event);
  signals:
    void Close(bool visible);
};

class ConsoleWidget : public QWidget, public Console
{
  Q_OBJECT
  public:
    ConsoleWidget(QWidget * parent): QWidget(parent)
    {
      setWindowTitle("Csound Output Console");
    }

    ~ConsoleWidget() {;};
  private:
    virtual void closeEvent(QCloseEvent * event);
  signals:
    void Close(bool visible);
};

#endif
