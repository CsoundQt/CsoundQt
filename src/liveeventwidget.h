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

#ifndef LIVEEVENTWIDGET_H
#define LIVEEVENTWIDGET_H

#include <QWidget>
#include "ui_liveeventwidget.h"

class LiveEventWidget:public QWidget
{
    Q_OBJECT

  public:
    LiveEventWidget(QWidget *parent = 0);
    ~LiveEventWidget() {;}
    void setDisplay(QWidget *w);
    void setTempo(double tempo);
    void setLoopLength(double length);
    double getTempo();
    double getLoopLength();

  private:
    Ui::LiveEventWidget ui;
};

#endif // LIVEEVENTWIDGET_H
