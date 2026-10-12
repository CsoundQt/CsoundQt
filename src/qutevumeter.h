/*
	Copyright (C) 2026 CsoundQt contributors

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

#ifndef QUTEVUMETER_H
#define QUTEVUMETER_H

#include "qutewidget.h"
#include "selectcolorbutton.h"
#include "valuemapping.h"

#include <QLinearGradient>

// The painted meter. Output only: it never emits a value, it just displays the
// dB value it is given (from the widget's channel).
class VUMeterWidget : public QWidget
{
	Q_OBJECT
public:
	explicit VUMeterWidget(QWidget *parent = nullptr);

	enum RulerMode { RulerHide, RulerFull, RulerCompact };

	void setValue(double db) { m_value = db; update(); }
	void setRange(double minDb, double maxDb) { m_min = minDb; m_max = maxDb; update(); }
	void setRulerMode(RulerMode mode) { m_rulerMode = mode; update(); }
	void setRulerColor(QColor color) { m_rulerColor = color; update(); }
	void setExponent(double exponent) { m_exponent = ValueMapping::validExponent(exponent); update(); }
	double getExponent() const { return m_exponent; }
	void setBgColor(QColor color) { m_bgColor = color; update(); }
	void setBorderColor(QColor color) { m_borderColor = color; update(); }
	void setDrawBackground(bool show) { m_drawBackground = show; update(); }

	// Second (cursor) value, in the same dB space as the meter value.
	void setCursor(double db) { m_cursor = db; update(); }
	void setCursorColor(QColor color) { m_cursorColor = color; update(); }
	void setCursorWidth(int width) { m_cursorWidth = qMax(1, width); update(); }
	void setCursorVisible(bool visible) { m_cursorVisible = visible; update(); }

	double value() const { return m_value; }
	double minDb() const { return m_min; }
	double maxDb() const { return m_max; }

protected:
	void paintEvent(QPaintEvent *event) override;

private:
	bool isVertical() const { return height() >= width(); }
	double fractionForDb(double db) const;
	QString rulerLabelForDb(double db) const;

	double m_value = -90.0;
	double m_min = -90.0;
	double m_max = 0.0;
	double m_exponent = 0.5;   // skew of the dB scale (0.5 spreads the top)
	RulerMode m_rulerMode = RulerFull;
	QColor m_rulerColor = QColor(170, 170, 170);
	QColor m_bgColor = QColor(20, 20, 20);
	QColor m_borderColor = QColor(90, 90, 90);
	bool m_drawBackground = true;

	// Cursor (second channel): a horizontal line for a vertical meter, vertical
	// for a horizontal one, in the same dB space.
	double m_cursor = -90.0;
	bool m_cursorVisible = false;
	QColor m_cursorColor = QColor(255, 255, 255);
	int m_cursorWidth = 1;

	// Cached fill gradient: depends only on the range, exponent and the scale
	// rect, so it is rebuilt only when one of those changes (not per value).
	QLinearGradient m_gradient;
	bool m_gradientValid = false;
	double m_gradMin = 0.0;
	double m_gradMax = 0.0;
	double m_gradExp = 0.0;
	QRectF m_gradRect;
	bool m_gradVertical = false;
};

class QuteVUMeter : public QuteWidget
{
	Q_OBJECT
public:
	QuteVUMeter(QWidget *parent);
	~QuteVUMeter();

	virtual void setWidgetGeometry(int x, int y, int width, int height);
	virtual QString getWidgetLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
	virtual void refreshWidget();
	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);
	QuteWidgetType getWidgetTypeID() override;

protected:
	virtual void createPropertiesDialog();
	virtual void applyProperties();

private:
	QSpinBox *minSpinBox = nullptr;
	QSpinBox *maxSpinBox = nullptr;
	QComboBox *rulerComboBox = nullptr;
	SelectColorButton *rulerColorButton = nullptr;
	QDoubleSpinBox *exponentSpinBox = nullptr;
	SelectColorButton *cursorColorButton = nullptr;
	QSpinBox *cursorWidthSpinBox = nullptr;
	QLineEdit *cursorChannelLineEdit = nullptr;
	SelectColorButton *bgColorButton = nullptr;
	SelectColorButton *borderColorButton = nullptr;
	QCheckBox *bgColorCheckBox = nullptr;
};

#endif // QUTEVUMETER_H
