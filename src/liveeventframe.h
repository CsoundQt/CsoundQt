/*
    Copyright (C) 2009 Andres Cabrera
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

#ifndef LIVEEVENTFRAME_H
#define LIVEEVENTFRAME_H

#include "ui_liveeventframe.h"
#include <cstdio>

class EventSheet;
class QTextEdit;

class LiveEventFrame : public QFrame, private Ui::LiveEventFrame
{
  Q_OBJECT
  Q_PROPERTY(bool visibleEnabled READ getVisibleEnabled WRITE setVisibleEnabled)
  public:
    LiveEventFrame(QString csdName, QWidget *parent = 0, Qt::WindowFlags f = 0 );
    ~LiveEventFrame();
    EventSheet * getSheet();
    void setName(QString name);
    void setFromText(QString text);
    void setVisibleEnabled(bool visible) {m_visibleEnabled = visible; }

    double getTempo();
    QString getName();
    double getLoopLength();
    QString getPlainText();
    bool getVisibleEnabled() { return m_visibleEnabled; }

    void getEvents(unsigned long ksmps, QStringList *eventText);
    bool isModified();
//    void forceDestroy();

  public slots:
    void setMode(int mode);
    void setTempo(double tempo);
    void setLoopLength(double length);
    void setModified(bool mod = true);
    void doAction(int action);
    void newFrame();
    void cloneFrame();
    void deleteFrame(bool ask = false);

    // To pass directly to live event sheet
    void markLoop(int start = -1, int end = -1);

  protected:
    void changeEvent(QEvent *e);
//    virtual void moveEvent (QMoveEvent * event);
    virtual void resizeEvent(QResizeEvent * event);
    virtual void closeEvent(QCloseEvent * event);
//    virtual void hideEvent(QHideEvent * event);
//    virtual void showEvent(QShowEvent * event);

  private:
    void renameDialog();

    int m_mode; // 0 = sheet 1 = text  2 = piano roll?
    bool m_visibleEnabled;
    QString m_name;
    QTextEdit *m_editor; //TODO add text editor
    EventSheet *m_sheet;
    QString m_csdName;
    bool m_modified;

  signals:
    void newFrameSignal(QString text);
    void deleteFrameSignal(LiveEventFrame *frame);
    void renameFrame(LiveEventFrame *frame, QString newName);
    void closed();  // To inform Live Event Control that live event panel has been closed
};

#endif // LIVEEVENTFRAME_H
