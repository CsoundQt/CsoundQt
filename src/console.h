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

#include <QtGui>

class Console
{
  public:
    Console();

    virtual ~Console();

    virtual void appendMessage(QString msg);
    void clear();
    void setDefaultFont(QFont font) {text->document()->setDefaultFont(font);}
    QList<int> errorLines;

  protected:
    QTextEdit *text;
    bool error;
};

class DockConsole : public QDockWidget, public Console
{
  Q_OBJECT
  public:
    DockConsole(QWidget * parent): QDockWidget(parent)
    {
      setWindowTitle("Csound Output Console");
      text = new QTextEdit(parent);
      text->setReadOnly(true);
      text->document()->setDefaultFont(QFont("Courier", 10));
      setWidget(text);
    }

    ~DockConsole() {;};

    void copy()
    {
      text->copy();
    }

    bool widgetHasFocus()
    {
      return text->hasFocus();
    }
  private:
    virtual void closeEvent(QCloseEvent * event);
  signals:
    void Close(bool visible);
};


class MyQTextEdit : public QTextEdit
{
  Q_OBJECT
  public:
    MyQTextEdit(QWidget* parent) : QTextEdit(parent) {}
    ~MyQTextEdit() {}

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {emit(popUpMenu(event->globalPos()));}

  signals:
    void popUpMenu(QPoint pos);
};

class ConsoleWidget : public QWidget, public Console
{
  Q_OBJECT
  public:
    ConsoleWidget(QWidget * parent): QWidget(parent)
    {
      setWindowTitle("Csound Output Console");
      text = new MyQTextEdit(parent);
      text->setReadOnly(true);
      text->setFontItalic(false);
#ifdef MACOSX
      text->document()->setDefaultFont(QFont("Courier", 10));
#else
      text->document()->setDefaultFont(QFont("Courier New", 7));
#endif
      connect(text, SIGNAL(popUpMenu(QPoint)), this, SLOT(emitPopUpMenu(QPoint)));
    }

    ~ConsoleWidget() {;};

    virtual void setWidgetGeometry(int x,int y,int width,int height);
  //protected:
    //virtual void contextMenuEvent(QContextMenuEvent *event)
    //{emit(popUpMenu(event->globalPos()));}
  private slots:
    void emitPopUpMenu(QPoint point) {emit(popUpMenu(point));}
  signals:
    void popUpMenu(QPoint pos);
};

#endif
