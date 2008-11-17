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
#ifndef QUTECHECKBOX_H
#define QUTECHECKBOX_H

#include "qutewidget.h"

class QuteCheckBox : public QuteWidget
{
  Q_OBJECT
  public:
    QuteCheckBox(QWidget *parent);

    ~QuteCheckBox();

    virtual void setValue(double value); // Value of button when pressed
    virtual double getValue(); // This value represents the state of the button
    virtual QString getWidgetLine();
    void popUpMenu(QPoint pos);

//   protected:
//     virtual void contextMenuEvent(QContextMenuEvent* event);


};

#endif
