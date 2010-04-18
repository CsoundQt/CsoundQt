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

namespace Ui {
    class LiveEventControl;
}

class LiveEventControl : public QWidget {
    Q_OBJECT
  public:
    LiveEventControl(QWidget *parent = 0);
    ~LiveEventControl();

    void renamePanel(int index, QString newName);

  public slots:
    void removePanel(int index);
    void appendPanel(bool visible, bool play, bool loop, int sync,
                     QString name, double loopLength, QString loopRange, double tempo);
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
    void setPanelName(int index, QString name);
    void setPanelTempo(int index, double tempo);
    void setPanelLoopLength(int index, double tempo);
};

#endif // LIVEEVENTCONTROL_H
