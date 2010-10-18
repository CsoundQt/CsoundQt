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

#ifndef BASEDOCUMENT_H
#define BASEDOCUMENT_H

#include "types.h"
#include "csoundoptions.h"

#include <QWidget>

class WidgetLayout;
class CsoundEngine;
class BaseView;
class OpEntryParser;
class QuteButton; // For registering buttons with main application

class BaseDocument : public QObject
{
  Q_OBJECT
  public:
    BaseDocument(QWidget *parent, OpEntryParser *opcodeTree);
    ~BaseDocument();

    virtual void setTextString(QString &text) = 0;
    int parseTextString(QString &text);
    virtual WidgetLayout* newWidgetLayout();
//    void setOpcodeNameList(QStringList opcodeNameList);

    WidgetLayout *getWidgetLayout();  // Needed to pass for placing in widget dock panel

  public slots:
    virtual int play(CsoundOptions *options);
    void pause();
    void stop();
    int record(int mode); // 0=16 bit int  1=32 bit int  2=float
    void stopRecording();
//    void playParent(); // Triggered from button, ask parent for options
//    void renderParent();

    virtual void registerButton(QuteButton *button);


protected:
    virtual void init(QWidget *parent, OpEntryParser *opcodeTree) = 0;
//    virtual BaseView *createView(QWidget *parent, O8pEntryParser *opcodeTree);

    QList<WidgetLayout *> m_widgetLayouts;
    OpEntryParser *m_opcodeTree;
    BaseView *m_view;
    CsoundEngine *m_csEngine;

private:

};

#endif // BASEDOCUMENT_H
