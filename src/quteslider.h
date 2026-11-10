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

#ifndef QUTESLIDER_H
#define QUTESLIDER_H

#include "qutewidget.h"
#include "selectcolorbutton.h"
#include "valuemapping.h"
#include "widgetruler.h"

// The slider's self-painted (flat) style. When flat is off it simply defers to
// QSlider, so the native look is preserved. When flat is on it takes over both
// painting and mouse handling.
class QuteSliderControl : public QSlider
{
public:
	explicit QuteSliderControl(QWidget *parent = nullptr);

	enum BackgroundMode { Nudge, Jump };

	void setFlatStyle(bool enable);
	void setBackgroundColor(const QColor &color);
	void setForegroundColor(const QColor &color);
	void setFillColor(const QColor &color);   // invalid = use foreground
	void setBorderColor(const QColor &color);
	void setBorder(int width, int radius);
	void setThumb(int width, int padding, int radius);
	void setFillMode(bool fill);
	void setBackgroundMode(BackgroundMode mode);
	void setRuler(WidgetRuler::Mode mode, const QColor &color);
	void setDisplayRange(double minimum, double maximum);
	void setExponent(double exponent);

	ValueMapping mapping() const
	{
		return ValueMapping{m_minimum, m_maximum, m_exponent};
	}

protected:
	void paintEvent(QPaintEvent *event) override;
	void mousePressEvent(QMouseEvent *event) override;
	void mouseMoveEvent(QMouseEvent *event) override;
	void mouseReleaseEvent(QMouseEvent *event) override;
	void mouseDoubleClickEvent(QMouseEvent *event) override;

private:
	bool isVertical() const;
	double majorTickStep(double axisLength) const;
	int minorSubdivisions(double axisLength, double majorStep) const;
	QString widestRulerLabel(double majorStep) const;
	WidgetRuler::Geometry rulerGeometry() const;
	QRectF sliderRect() const;
	QRectF innerRect(const QRectF &body) const;
	int thumbLength(const QRectF &inner) const;
	QRectF thumbRect(const QRectF &inner, double position) const;
	double positionForPoint(const QRectF &inner, const QPointF &point) const;
	double currentPosition() const;
	void setPosition(double position);
	void performBackgroundClick(const QPointF &point);
	QString formatValue(double value, double step = 0.0) const;

	bool m_flat = false;
	QColor m_background = QColor(243, 243, 243);
	QColor m_foreground = QColor(32, 32, 32);
	QColor m_fill; // invalid = use foreground
	QColor m_border = QColor(173, 173, 173);
	int m_borderWidth = 1;
	int m_borderRadius = 3;
	int m_thumbWidth = 12;
	int m_thumbPadding = 2;
	int m_thumbRadius = 0;
	bool m_fillMode = true;
	BackgroundMode m_backgroundMode = Jump;
	WidgetRuler::Mode m_rulerMode = WidgetRuler::Hide;
	QColor m_rulerColor = QColor(109, 109, 109);

	double m_minimum = 0.0;
	double m_maximum = 1.0;
	double m_exponent = 1.0;

	bool m_pressed = false;
	bool m_pressedOnThumb = false;
	bool m_dragging = false;
	QPointF m_pressPoint;
	QPointF m_lastPoint;
	double m_lastPosition = 0.0;
};

class QuteSlider : public QuteWidget
{
	Q_OBJECT
	Q_PROPERTY(double CSQT_minimum READ rangeMin WRITE setRangeMin)
	Q_PROPERTY(double CSQT_maximum READ rangeMax WRITE setRangeMax)
public:
	QuteSlider(QWidget *parent);

	~QuteSlider();

	double rangeMin() const { return m_min; }
	double rangeMax() const { return m_max; }
	void setRangeMin(double v) { m_min = v; }
	void setRangeMax(double v) { m_max = v; }

	virtual void setWidgetGeometry(int x, int y, int w, int h);
	virtual QString getCabbageLine();
	virtual QString getCsladspaLine();
	virtual QString getWidgetXmlText();
	virtual QString getQml();

	virtual QString getWidgetType();
	//    void setInternalValue(double value);
	virtual void setValue(double value);
	virtual void setMidiValue(int value);
	virtual bool acceptsMidi() {return true;}

	virtual void refreshWidget();
	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);
	QuteWidgetType getWidgetTypeID() override;


protected:
	virtual void createPropertiesDialog();
	virtual void applyProperties();
	virtual QHash<QString, QString> propertyDescriptions() const override;

private:
	QuteSliderControl *control() const
	{
		return static_cast<QuteSliderControl *>(m_widget);
	}

	QDoubleSpinBox *minSpinBox;
	QDoubleSpinBox *maxSpinBox;
	int m_len = 0; //length of the slider
	double m_min = 0.0;
	double m_max = 1.0;

	// Flat style controls (only used when flat is selected)
	QCheckBox *flatStyleCheckBox = nullptr;
	SelectColorButton *backgroundColorButton = nullptr;
	SelectColorButton *foregroundColorButton = nullptr;
	SelectColorButton *fillColorButton = nullptr;
	SelectColorButton *borderColorButton = nullptr;
	QSpinBox *borderWidthSpinBox = nullptr;
	QSpinBox *borderRadiusSpinBox = nullptr;
	QSpinBox *thumbWidthSpinBox = nullptr;
	QSpinBox *thumbPaddingSpinBox = nullptr;
	QSpinBox *thumbRadiusSpinBox = nullptr;
	QComboBox *fillModeComboBox = nullptr;
	QComboBox *backgroundModeComboBox = nullptr;
	QComboBox *rulerComboBox = nullptr;
	SelectColorButton *rulerColorButton = nullptr;
	QDoubleSpinBox *exponentSpinBox = nullptr;
	QList<QWidget *> m_flatControls;
	bool m_fillColorSet = false;

private slots:
	void sliderChanged(int value);
	void setInternalValue(double value);   // This function must be protected using the widget mutex by the caller
};

#endif
