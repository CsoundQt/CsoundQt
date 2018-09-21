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

#ifndef QUTETEXT_H
#define QUTETEXT_H

#include "qutewidget.h"

class QuteText : public QuteWidget
{
	Q_OBJECT
public:
	QuteText(QWidget *parent);

	~QuteText();

	virtual QString getWidgetLine();
	virtual QString getWidgetXmlText();

	virtual QString getWidgetType();
	virtual void setValue(double value);
	virtual void setValue(QString value);

	void setType(QString type);
    virtual void setAlignment(QString alignment);
	void setFont(QString font);
	void setFontSize(int fontSize);
	void setTextColor(QColor textColor);
	void setBgColor(QColor bgColor);
	void setBg(bool bg);
	void setBorder(bool border);
	virtual void setText(QString text);
	virtual void refreshWidget();
	virtual void applyInternalProperties();
	virtual QString getCabbageLine();
    virtual QString getQml();

	// Configuraion (Not saved)
	void setFontScaling(double scaling);
	void setFontOffset(double offset);

protected:
	virtual void createPropertiesDialog();
	virtual void applyProperties();

	QString m_type;  // can be "label", "display", "edit", "scroll". In old widget format can also be "display".
	// TODO this shouldn't be used anymore with the new format, as the type is found by querying getWidgetType()

	//Configuration options
	double m_fontScaling, m_fontOffset;

	QTextEdit *text;
	QPushButton *textColor;
	QPushButton *bgColor;
	QCheckBox *bg;
	QCheckBox *border;
	QSpinBox *borderRadius;
	QSpinBox *borderWidth;
	QFontComboBox  *font;
	QSpinBox * fontSize;
	QComboBox * alignment;

private slots:
	void selectTextColor();
	void selectBgColor();
};

class QuteLineEdit : public QuteText
{
	Q_OBJECT
public:
	QuteLineEdit(QWidget* parent);
	~QuteLineEdit();

	virtual void setText(QString text);
	virtual QString getWidgetLine();
	virtual QString getWidgetXmlText();
	virtual QString getStringValue();
	virtual double getValue();
	virtual QString getWidgetType();
	virtual void dropEvent(QDropEvent *event);
	virtual void applyInternalProperties();
	virtual QString getCabbageLine();

protected:
	virtual void createPropertiesDialog();
	//    virtual void applyProperties();

protected slots:
	void textEdited(QString text);
};

class QuteScrollNumber : public QuteText
{
	Q_OBJECT
public:
	QuteScrollNumber(QWidget* parent);
	~QuteScrollNumber();

    virtual void setTextAlignment(int alignment);
	virtual QString getWidgetLine();
	virtual QString getCsladspaLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
	virtual void setValue(double value);
	virtual void setMidiValue(int value);

	virtual void applyInternalProperties();
	virtual QString getCabbageLine();

protected:
	virtual void refreshWidget();
	virtual void createPropertiesDialog();
	virtual void applyProperties();

	QDoubleSpinBox* resolutionSpinBox;
	QDoubleSpinBox *minSpinBox;
	QDoubleSpinBox *maxSpinBox;
	int m_places;
	double m_min, m_max;

public slots:
	void setResolution(double resolution);
	void addValue(double delta);
	void setValueFromWidget(double value);
};

class ScrollNumberWidget : public QLabel
{
	Q_OBJECT
public:
	ScrollNumberWidget(QWidget* parent) : QLabel(parent)
	{
		setContextMenuPolicy(Qt::NoContextMenu);
		pressed = false;
	}
	~ScrollNumberWidget() {}

	void setResolution(double resolution)
	{
		m_resolution = resolution;
	}

protected:
	virtual void mouseMoveEvent(QMouseEvent * event)
	{
		if (pressed) {
			double delta = (oldy - event->y()) * m_resolution;
			emit addValue(delta);
			oldy = event->y();
		}
	}
	virtual void mousePressEvent(QMouseEvent * event)
	{
		if (event->button() & Qt::LeftButton) {
			if (event->modifiers() & Qt::AltModifier) {
				emit setValue(0);
			}
			oldy = event->y();
			pressed = true;
		}
	}
	virtual void mouseReleaseEvent (QMouseEvent * event)
	{
		QLabel::mouseReleaseEvent(event);
		pressed = false;
	}

private:
	double m_resolution;
//	double m_min, m_max;
	int oldy;
	bool pressed;

signals:
	void addValue(double delta);
	void setValue(double value);
};

#endif
