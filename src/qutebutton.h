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
#ifndef QUTEBUTTON_H
#define QUTEBUTTON_H

#include "qutewidget.h"

class QuteButton : public QuteWidget
{
  Q_OBJECT
  public:
    QuteButton(QWidget *parent);

    ~QuteButton();

    virtual void setValue(double value); // Value of button when pressed
    virtual double getValue(); // This value represents the state of the button
    virtual QString getWidgetLine();
    void setType(QString text);
    void setText(QString text);
    void setFilename(QString filename);
    void setEventLine(QString eventLine);
    void popUpMenu(QPoint pos);

  protected:
    virtual void contextMenuEvent(QContextMenuEvent* event);
    virtual void applyProperties();
    virtual void createPropertiesDialog();

  private:
    QString m_eventLine;
    QString m_type;  // can be event, value, pictevent, pictvalue, pict
    QString m_filename;

    QComboBox *typeComboBox;
    QDoubleSpinBox *valueBox;
    QLineEdit *text;
    QLineEdit *filenameLineEdit;
    QLineEdit *line;

    QIcon icon;

  private slots:
    void buttonReleased();
    void browseFile();

  signals:
    void queueEvent(QString eventLine);
    void play();
    void stop();
//     void selectMidiInDevices(QPoint pos);
//     void selectMidiOutDevices(QPoint pos);
//     void selectAudioInDevices(QPoint pos);
//     void selectAudioOutDevices(QPoint pos);
};

#endif
