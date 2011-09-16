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

namespace Ui {
    class LiveEventFrame;
}

class LiveEventFrame : public QWidget
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
	double getLoopStart();
	double getLoopEnd();
    QString getPlainText();
    bool getVisibleEnabled() { return m_visibleEnabled; }

    void getEvents(unsigned long ksmps, QStringList *eventText);
    bool isModified();
//    void forceDestroy();

  public slots:
    void setMode(int mode);
    void setTempo(double tempo);
    void setLoopLength(double length);
    void setLoopRange(double start, double end);
	void setLoopEnabled(bool enabled);
    void setModified(bool mod = true);
    void doAction(int action);
    void newFrame();
    void cloneFrame();
    void deleteFrame(bool ask = false);

    // To pass directly to live event sheet
    void markLoop(double start = -1, double end = -1);
	void loopPanel(bool loop);

  protected:
//    void changeEvent(QEvent *e);
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
    double m_loopStart, m_loopEnd; // TODO move looping to this class

    Ui::LiveEventFrame *m_ui;

  signals:
    void newFrameSignal(QString text);
    void deleteFrameSignal(LiveEventFrame *frame);
    void renamePanel(LiveEventFrame *frame, QString newName);
    void setLoopRangeFromPanel(LiveEventFrame *frame, double start, double end);
    void setLoopLengthFromPanel(LiveEventFrame *frame, double length);
    void setTempoFromPanel(LiveEventFrame *frame, double tempo);
	void setLoopEnabledFromPanel(LiveEventFrame *frame, bool enabled);
	void closed(bool visible);  // To inform Live Event Control that live event panel has been closed
};

#endif // LIVEEVENTFRAME_H
