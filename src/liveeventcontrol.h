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

#ifndef LIVEEVENTCONTROL_H
#define LIVEEVENTCONTROL_H

#include <QtGui>
#include "liveeventframe.h"

namespace Ui {
    class LiveEventControl;
}

class LiveEventControl : public QWidget {
    Q_OBJECT
  public:
    LiveEventControl(QWidget *parent = 0);
    ~LiveEventControl();

    void renamePanel(int index, QString newName);
    void setPanelLoopRange(int index, double start, double end);
    void setPanelLoopLength(int index, double length);
	void setPanelLoopEnabled(int index, bool enabled);
    void setPanelTempo(int index, double tempo);

  public slots:
    void removePanel(int index);
	void appendPanel(LiveEventFrame *e);
    void setPanelProperty(int index, QString property, QVariant value);

  protected:
    void closeEvent(QCloseEvent * event);
    void changeEvent(QEvent *e);

  private:
    QTableWidgetItem * getItem(int row, int column);
    void openLoopRangeDialog(int row);
    Ui::LiveEventControl *m_ui;

  private slots:
	void newButtonReleased();
	void frameClosed(LiveEventFrame *e);
    void cellChangedSlot(int row, int column);
    void cellClickedSlot(int row, int column);

  signals:
    void closed();  // To inform DocumentPage that live event panel has been closed
//    void hidePanels(bool show);
    void stopAll();
    void newPanel();
    void playPanel(int index);
    void loopPanel(int index, bool loop);
    void stopPanel(int index);
    void setPanelVisible(int index, bool visible);
    void setPanelSync(int index, int mode);
    void setPanelNameSignal(int index, QString name);
    void setPanelTempoSignal(int index, double tempo);
    void setPanelLoopLengthSignal(int index, double length);
    void setPanelLoopRangeSignal(int index, double start, double end);
};

#endif // LIVEEVENTCONTROL_H
