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

#ifndef QUTECHECKBOX_H
#define QUTECHECKBOX_H

#include "qutewidget.h"

class SelectColorButton;

// A QCheckBox that takes over its own painting in flat mode, so the square and
// the check mark look identical on every platform. When not flat it simply
// defers to QCheckBox, preserving the native look.
class QuteFlatCheckBox : public QCheckBox
{
public:
	explicit QuteFlatCheckBox(QWidget *parent = nullptr);

	void setFlatStyle(bool enable) { m_flat = enable; update(); }
	bool isFlatStyle() const { return m_flat; }
	// Invalid colours mean "inherit from the palette".
	void setBackgroundColor(const QColor &c) { m_background = c; update(); }
	void setBorderColor(const QColor &c) { m_bordercolor = c; update(); }
	void setForegroundColor(const QColor &c) { m_foreground = c; update(); }
	void setBorderWidth(int width) { m_borderwidth = width; update(); }
	void setBorderRadius(int radius) { m_borderradius = radius; update(); }
	void setPadding(int padding) { m_padding = padding; update(); }
	void setCheckStyle(const QString &style);

protected:
	void paintEvent(QPaintEvent *event) override;
	bool hitButton(const QPoint &pos) const override;

private:
	bool m_flat = false;
	QColor m_background = QColor(243, 243, 243);
	QColor m_bordercolor = QColor(173, 173, 173);
	QColor m_foreground = QColor(32, 32, 32);
	int m_borderwidth = 1;
	int m_borderradius = 3;
	int m_padding = 0;
	QString m_checkstyle; // "x" (default) or "full"
};

class QuteCheckBox : public QuteWidget
{
	Q_OBJECT
public:
	QuteCheckBox(QWidget *parent);

	~QuteCheckBox();

	virtual void setValue(double value); // Value of checkbox when pressed and state at the same time (if negative set value)
	void setLabel(QString label);
	virtual double getValue(); // This value represents the state of the button
	//    QString getLabel();
	virtual QString getCabbageLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
    virtual QString getQml();
	virtual void setMidiValue(int value);
	virtual bool acceptsMidi() {return true;}

	virtual void refreshWidget();
	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);

	//    void popUpMenu(QPoint pos);
    virtual void resizeEvent(QResizeEvent *);
    
    QuteWidgetType getWidgetTypeID() override;
	

protected:
	virtual void applyProperties();
	virtual void createPropertiesDialog();


private:
	double m_currentValue;
	QDoubleSpinBox *valueBox;

	// Flat style controls (only used when flat is selected)
	QCheckBox *flatStyleCheckBox = nullptr;
	SelectColorButton *backgroundColorButton = nullptr;
	SelectColorButton *borderColorButton = nullptr;
	SelectColorButton *foregroundColorButton = nullptr;
	QSpinBox *borderWidthSpinBox = nullptr;
	QSpinBox *borderRadiusSpinBox = nullptr;
	QSpinBox *paddingSpinBox = nullptr;
	QComboBox *checkStyleComboBox = nullptr;
	QList<QWidget *> m_flatControls; // widgets enabled only when flat is on

	QuteFlatCheckBox *checkbox() const { return static_cast<QuteFlatCheckBox *>(m_widget); }
	void updateIndicatorStyleSheet();

private slots:
	void stateChanged(int state);

};

#endif
