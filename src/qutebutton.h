/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
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
	virtual void setValue(QString text); // String Value (internal) of button (e.g. for filenames)
	virtual double getValue(); // This value represents the state of the button
	virtual QString getStringValue(); // This value represents the filename from a _Browse channel button
	virtual QString getWidgetLine();
	virtual QString getCabbageLine();
	virtual QString getQml();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
	//    void setType(QString text);
	void setText(QString text);
	//    void setFilename(QString filename);
	//    void setEventLine(QString eventLine);
	void popUpMenu(QPoint pos);
	virtual void setMidiValue(int value);
	virtual bool acceptsMidi() {return true;}

	virtual void refreshWidget();
	virtual void applyInternalProperties();

protected:
	//    virtual void contextMenuEvent(QContextMenuEvent* event);
	virtual void applyProperties();
	virtual void createPropertiesDialog();

private:
	//    QString m_eventLine;
	//    QString m_type;  // can be event, value, pictevent, pictvalue, pict
	//    QString m_filename;
	//    QString m_imageFilename;
	double m_currentValue;

	QComboBox *typeComboBox;
	QCheckBox *latchCheckBox;
	QDoubleSpinBox *valueBox;
	QTextEdit *text;
	QLineEdit *filenameLineEdit;
	QLineEdit *line;
    QSpinBox  *fontSizeSpinBox;
	QCheckBox * useMomentaryMidiButtonCheckBox;

	QIcon icon;
    QIcon onIcon;

	bool m_isPlaying;

    void performAction();
	bool hasIndefiniteDuration();

private slots:
	void buttonPressed();
	void buttonReleased();
	void browseFile();

signals:
	void queueEventSignal(QString eventLine);
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
