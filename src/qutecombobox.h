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
#ifndef QUTECOMBOBOX_H
#define QUTECOMBOBOX_H

#include "qutewidget.h"

class QuteComboBox : public QuteWidget
{
  Q_OBJECT
  public:
    QuteComboBox(QWidget *parent);

    ~QuteComboBox();

    virtual void setValue(double value); // Current item select index
    virtual double getValue();
    virtual QString getWidgetLine();
    void setSize(int size);
    void setText(QString text);  //Text for this widget is the item list separated by commas
    void popUpMenu(QPoint pos);
    QString itemList();

  protected:
    virtual void contextMenuEvent(QContextMenuEvent* event);
    virtual void applyProperties();
    virtual void createPropertiesDialog();

  private:
    int m_size;
    QLineEdit *text;
    QLineEdit *line;

};

#endif
