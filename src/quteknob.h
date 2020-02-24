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

#ifndef QUTEKNOB_H
#define QUTEKNOB_H

#include "qutewidget.h"

/* QVdial: A knob with vertical dragging instead of circular
 *
 */
class QVdial: public QDial {
public:
    QVdial (QWidget *parent = nullptr)
    : QDial(parent)
    , m_dragging(false)
    , m_scale_factor(1.0)
    , m_temp_scale_factor(1.0)
    , m_draw_value(true)
    , m_decimals(2)
    , m_display_min(0.0)
    , m_display_max(1.0)
    , m_color(QColor(245, 124, 0))
    , m_flat(true)
    , m_degrees(300)
    , m_intDisplay(true)
    {}
    virtual ~QVdial() override;
    void setScaleFactor(double factor) { m_scale_factor = factor; }
    void setDecimals(int decimals) { m_decimals = decimals; }
    void setDisplayRange(double min, double max) {
        m_display_min = min;
        m_display_max = max;
        max = qAbs(max);
        if(max < 100)
            m_decimals = 2;
        else if(max < 1000)
            m_decimals = 1;
        else
            m_decimals = 0;
    }
    void setDrawValue(bool enable) { m_draw_value = enable; }
    void setColor(QColor color) { m_color = color; }
    void setTextColor(QColor color) { m_textcolor = color; }

    void setFlatStyle(bool enable) { m_flat = enable; }
    void setValueDialog();
    void setIntegerMode(bool enable) { m_intDisplay = enable; }

    void setValueFromDisplayValue(double display_value) {
        double delta = (display_value - m_display_min) / (m_display_max-m_display_min);
        double minval = (double)this->minimum();
        double flvalue = delta * (this->maximum() - minval) + minval;
        setValue((int)flvalue);
    }

    double displayValue() {
        return ((double)this->value()/(double)this->maximum()) *
                (m_display_max - m_display_min) + m_display_min;
    }

protected:
    virtual void mousePressEvent (QMouseEvent *event) override;
    virtual void mouseReleaseEvent (QMouseEvent *event) override;
    virtual void mouseMoveEvent (QMouseEvent *event) override;
    virtual void mouseDoubleClickEvent (QMouseEvent *event) override;
    virtual void paintEvent(QPaintEvent *event) override;

private:
    bool   m_dragging;
    QPoint m_mouse_press_point;
    int    m_base_value;
    double m_scale_factor;
    double m_temp_scale_factor;
    bool   m_draw_value;
    int    m_decimals;
    double m_display_min;
    double m_display_max;
    QColor m_color;
    QColor m_textcolor;
    bool   m_flat;
    int    m_degrees;
    bool   m_intDisplay;
};

class QuteKnob : public QuteWidget
{
	Q_OBJECT
public:
	QuteKnob(QWidget *parent);
	~QuteKnob();

	virtual void setWidgetGeometry(int x, int y, int width, int height);
	virtual QString getWidgetLine();
	virtual QString getCsladspaLine();
	virtual QString getCabbageLine();
    virtual QString getQml();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
    //    virtual void setResolution(double resolution);
	void setRange(double min, double max);
	virtual void setMidiValue(int value);
	virtual bool acceptsMidi() {return true;}

	virtual void refreshWidget();
	virtual void applyInternalProperties();

private slots:
    void selectKnobColor();
    void selectKnobTextColor();

protected:
	virtual void createPropertiesDialog();
	virtual void applyProperties();

protected slots:
	void knobChanged(int value);

private:
	void setInternalValue(double value);
	QDoubleSpinBox *minSpinBox;
	QDoubleSpinBox *maxSpinBox;
	QDoubleSpinBox *resolutionSpinBox;
    QCheckBox      *displayValueCheckBox;
    QCheckBox      *flatStyleCheckBox;
    QPushButton    *knobColorButton;
    QPushButton    *knobTextColorButton;
    QCheckBox      *intModeCheckBox;

};

#endif
