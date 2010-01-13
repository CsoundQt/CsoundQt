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

#include "LiveEventWidgetidget.h"
#include "liveeventframe.h"

LiveEventWidget::LiveEventWidget(QWidget *parent)
    : QWidget(parent)
{
  ui.setupUi(this);
  connect(ui.actionComboBox,SIGNAL(activated(int)),
          static_cast<LiveEventFrame *>(parentWidget()), SLOT(doAction(int)));
  connect(ui.tempoSpinBox,SIGNAL(valueChanged(double)),
          static_cast<LiveEventFrame *>(parentWidget()), SLOT(setTempo(double)));
  connect(ui.loopLengthSpinBox,SIGNAL(valueChanged(double)),
          static_cast<LiveEventFrame *>(parentWidget()), SLOT(setLoopLength(double)));
  //  m_frame->actionComboBox->setCurrentIndex(0);
}


void LiveEventWidget::setDisplay(QWidget *w)
{
  ui.scrollArea->setWidget(w);
}

void LiveEventWidget::setTempo(double tempo)
{
  ui.tempoSpinBox->setValue(tempo);
}

void LiveEventWidget::setLoopLength(double length)
{
  ui.loopLengthSpinBox->setValue(length);
}

double LiveEventWidget::getTempo()
{
  return ui.tempoSpinBox->value();
}

double LiveEventWidget::getLoopLength()
{
  return ui.loopLengthSpinBox->value();
}

