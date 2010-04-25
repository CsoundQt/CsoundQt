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

#ifndef QUTECHECKBOX_H
#define QUTECHECKBOX_H

#include "qutewidget.h"

class QuteCheckBox : public QuteWidget
{
  Q_OBJECT
  public:
    QuteCheckBox(QWidget *parent);

    ~QuteCheckBox();

    virtual void setValue(double value); // Value of checkbox when pressed
    void setLabel(QString label);
    virtual double getValue(); // This value represents the state of the button
//    QString getLabel();
    virtual QString getWidgetLine();
    virtual QString getCabbageLine();
    virtual QString getWidgetXmlText();
    virtual QString getWidgetType();
    virtual void applyInternalProperties();

    void popUpMenu(QPoint pos);

  protected:
    virtual void createPropertiesDialog();

  private slots:
    void stateChanged(int state);

};

#endif
