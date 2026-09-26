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

class SelectColorButton;

// A QPushButton that takes over its own painting when in flat mode, so the
// appearance (rounded rectangle, colors, border) is identical on every
// platform instead of depending on the native style. When not flat it simply
// defers to QPushButton, preserving the native look.
class QutePushButton : public QPushButton
{
public:
	explicit QutePushButton(QWidget *parent = nullptr) : QPushButton(parent) {}

	void setFlatStyle(bool enable) { m_flat = enable; update(); }
	// Invalid colors mean "inherit": pressed falls back to the background,
	// pressed text falls back to the text color.
	void setBackgroundColor(const QColor &c) { m_background = c; update(); }
	void setPressedColor(const QColor &c) { m_pressed = c; update(); }
	void setBorderColor(const QColor &c) { m_bordercolor = c; update(); }
	void setTextColor(const QColor &c) { m_textcolor = c; update(); }
	void setPressedTextColor(const QColor &c) { m_pressedtextcolor = c; update(); }
	void setBorderWidth(int width) { m_borderwidth = width; update(); }
	void setBorderRadius(int radius) { m_borderradius = radius; update(); }

protected:
	void paintEvent(QPaintEvent *event) override;

private:
	bool m_flat = false;
	QColor m_background = QColor(224, 224, 224);
	QColor m_pressed;              // invalid = use background
	QColor m_bordercolor = QColor(128, 128, 128);
	QColor m_textcolor = QColor(0, 0, 0);
	QColor m_pressedtextcolor;     // invalid = use text color
	int m_borderwidth = 0;
	int m_borderradius = 3;
};

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
	virtual bool applyProperty(const QString &name);
	QuteWidgetType getWidgetTypeID() override;
	

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

	// Flat style controls (only used when flat is selected)
	QCheckBox *flatStyleCheckBox = nullptr;
	SelectColorButton *backgroundColorButton = nullptr;
	SelectColorButton *pressedColorButton = nullptr;
	SelectColorButton *borderColorButton = nullptr;
	SelectColorButton *textColorButton = nullptr;
	SelectColorButton *pressedTextColorButton = nullptr;
	QSpinBox *borderWidthSpinBox = nullptr;
	QSpinBox *borderRadiusSpinBox = nullptr;
	QList<QWidget *> m_flatControls; // widgets enabled only when flat is on
	bool m_pressedColorSet = false;
	bool m_pressedTextColorSet = false;

	QIcon icon;
    QIcon onIcon;

	bool m_isPlaying;
	bool m_latched;

    void performAction();
	bool hasIndefiniteDuration();
	QutePushButton *button() const { return static_cast<QutePushButton *>(m_widget); }

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
