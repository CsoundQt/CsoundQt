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
    virtual QString getStringValue(); // This value represents the filename from a _Browse channel button
    virtual QString getWidgetLine();
    virtual QString getCabbageLine();
    virtual QString getWidgetXmlText();
    virtual QString getWidgetType();
//    void setType(QString text);
    void setText(QString text);
//    void setFilename(QString filename);
//    void setEventLine(QString eventLine);
    void popUpMenu(QPoint pos);

    virtual void applyInternalProperties();

  protected:
    virtual void contextMenuEvent(QContextMenuEvent* event);
    virtual void applyProperties();
    virtual void createPropertiesDialog();

  private:
//    QString m_eventLine;
//    QString m_type;  // can be event, value, pictevent, pictvalue, pict
//    QString m_filename;
//    QString m_imageFilename;

    QComboBox *typeComboBox;
    QDoubleSpinBox *valueBox;
    QTextEdit *text;
    QLineEdit *filenameLineEdit;
    QLineEdit *line;

    QIcon icon;

  private slots:
    void buttonReleased();
    void browseFile();

  signals:
    void queueEvent(QString eventLine);
    void play();
    void pause();
    void stop();
    void render();
//     void selectMidiInDevices(QPoint pos);
//     void selectMidiOutDevices(QPoint pos);
//     void selectAudioInDevices(QPoint pos);
//     void selectAudioOutDevices(QPoint pos);
};

#endif
