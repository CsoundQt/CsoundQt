/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
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
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/
#ifndef QUTESPINBOX_H
#define QUTESPINBOX_H

#include "qutetext.h"

class QuteSpinBox : public QuteText
{
  Q_OBJECT
  public:
    QuteSpinBox(QWidget* parent);
    ~QuteSpinBox();

    virtual void setAlignment(int alignment);
    virtual void setValue(double value);
    virtual void setText(QString text);
    virtual void setResolution(double resolution);
    virtual double getValue();
    virtual QString getWidgetLine();
    virtual QString getStringValue();

  protected:
    virtual void createPropertiesDialog();
    virtual void applyProperties();

    QDoubleSpinBox* resolutionSpinBox;
};


class SpinBoxWidget : public QDoubleSpinBox
{
  Q_OBJECT
  public:
    SpinBoxWidget(QWidget* parent) : QDoubleSpinBox(parent) {}
    ~SpinBoxWidget() {}

  protected:
    virtual void contextMenuEvent(QContextMenuEvent *event)
    {emit(popUpMenu(event->globalPos()));}

  signals:
    void popUpMenu(QPoint pos);
};

#endif
