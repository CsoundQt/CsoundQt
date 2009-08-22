/*
    Copyright (C) 2008, 2009 Andres Cabrera
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

#ifndef CONSOLE_H
#define CONSOLE_H

#include <QtGui>

class Console
{
  public:
    Console();

    virtual ~Console();

    virtual void appendMessage(QString msg);
    virtual void setDefaultFont(QFont font);
    virtual void setColors(QColor textColor, QColor bgColor);
    void clear();
    void scrollToEnd();
//     void refresh();
    QList<int> errorLines;

  protected:
    QTextEdit *text;
    bool error;
    QColor m_textColor;
    QColor m_bgColor;
    QMutex lock;
};

class DockConsole : public QDockWidget, public Console
{
  Q_OBJECT
  public:
    DockConsole(QWidget * parent): QDockWidget(parent)
    {
      setWindowTitle(tr("Csound Output Console"));
      text = new QTextEdit(parent);
      text->setReadOnly(true);
      text->setContextMenuPolicy(Qt::NoContextMenu);
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

  public slots:
    void clear()
    {
      text->clear();
    }

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {
      QMenu *menu = text->createStandardContextMenu();
      menu->addAction("Clear", this, SLOT(clear()));
      menu->exec(event->globalPos());
      delete menu;
    }
    virtual void keyPressEvent(QKeyEvent *event)
    {
      if (!event->isAutoRepeat()) {
        QString key = event->text();
        if (key != "") {
          appendMessage(key);
          emit keyPressed(key);
        }
      }
    }
    virtual void keyReleaseEvent(QKeyEvent *event)
    {
      if (!event->isAutoRepeat()) {
        QString key = event->text();
        if (key != "") {
//           appendMessage("rel:" + key);
          emit keyReleased(key);
        }
      }
    }

    virtual void closeEvent(QCloseEvent * event);
  signals:
    void Close(bool visible);
    void keyPressed(QString key);
    void keyReleased(QString key);
};


class MyQTextEdit : public QTextEdit
{
  Q_OBJECT
  public:
    MyQTextEdit(QWidget* parent) : QTextEdit(parent) {}
    ~MyQTextEdit() {}

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {
      QMenu *menu = createStandardContextMenu();
      menu->addAction("Clear", this, SLOT(clear()));
      menu->exec(event->globalPos());
      delete menu;
    }
//     virtual void contextMenuEvent(QContextMenuEvent *event)
//     {emit(popUpMenu(event->globalPos()));}
// 
//   signals:
//     void popUpMenu(QPoint pos);
};

class ConsoleWidget : public QWidget, public Console
{
  Q_OBJECT
  public:
    ConsoleWidget(QWidget * parent): QWidget(parent)
    {
      setWindowTitle(tr("Csound Output Console"));
      text = new MyQTextEdit(parent);
      text->setReadOnly(true);
      text->setFontItalic(false);
#ifdef MACOSX
      text->document()->setDefaultFont(QFont("Courier", 10));
#else
      text->document()->setDefaultFont(QFont("Courier New", 7));
#endif
//       connect(text, SIGNAL(popUpMenu(QPoint)), this, SLOT(emitPopUpMenu(QPoint)));
    }

    ~ConsoleWidget() {;};

    virtual void setWidgetGeometry(int x,int y,int width,int height);

  protected:
//   private slots:
//     void emitPopUpMenu(QPoint point) {emit(popUpMenu(point));}
  signals:
//     void popUpMenu(QPoint pos);

};

#endif
