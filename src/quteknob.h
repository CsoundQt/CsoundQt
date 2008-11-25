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
#ifndef QUTEKNOB_H
#define QUTEKNOB_H

#include "qutewidget.h"

class QuteKnob : public QuteWidget
{
  Q_OBJECT
  public:
    QuteKnob(QWidget *parent);

    ~QuteKnob();

    double getValue();
    void setRange(double min, double max);
    void setValue(double value);
    virtual void setWidgetLine(QString line);
    virtual void setWidgetGeometry(int x, int y, int width, int height);
    QString getWidgetLine();
    virtual void createPropertiesDialog();
    virtual void applyProperties();

  private:
    QDoubleSpinBox *minSpinBox;
    QDoubleSpinBox *maxSpinBox;
};

#endif
