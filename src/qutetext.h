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
#include "selectcolorbutton.h"

class QuteText : public QuteWidget
{
	Q_OBJECT
public:
	QuteText(QWidget *parent);

	~QuteText();

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
    void setBorderColor(QColor color);
	virtual void setText(QString text);
	virtual void refreshWidget();
	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);
	virtual QString getCabbageLine();
    virtual QString getQml();
    QuteWidgetType getWidgetTypeID() override;
	
protected:
	virtual void createPropertiesDialog();
	virtual void applyProperties();
	// Set captions on the colour buttons (if any) before their colours are
	// painted for the first time. Captioned buttons show the colour as a small
	// icon swatch; uncaptioned buttons keep the old filled-button look.
	virtual void configureColorButtons() {}

	// Render the current label text using the configured text format. Labels
	// can show GitHub-flavoured Markdown; every other text widget stays plain.
	void updateLabelText();
	Qt::TextFormat labelTextFormat() const;
	// Configure the optional rotated text layer for labels and displays.
	void updateTextOrientation();
	bool textIsVertical() const;

	QString m_type;  // can be "label", "display", "edit", "scroll". In old widget format can also be "display".
	// TODO this shouldn't be used anymore with the new format, as the type is found by querying getWidgetType()

    QTextEdit *text;
    // QPushButton *textColor;
    SelectColorButton *textColor;
   //  QPushButton *bgColor;
    SelectColorButton *bgColor;
    SelectColorButton *borderColor = nullptr; // invalid/empty = follow text color
    bool m_borderColorSet = false;
    QCheckBox *bg;
    QCheckBox *lockedCheckBox = nullptr; // labels only
    QCheckBox *boldCheckBox = nullptr;   // displays only
    // QCheckBox *border;
	QSpinBox *borderRadius;
	QSpinBox *borderWidth;
    QSpinBox *paddingSpinBox = nullptr;
    QSpinBox *precisionSpinBox;
    QLineEdit *formatLineEdit = nullptr; // Display widgets only
	QComboBox  *font;
	QSpinBox * fontSize;
	QComboBox * alignment;
    QComboBox * vertAlignmentComboBox;
    QComboBox * textFormatComboBox = nullptr; // labels only
    QComboBox * textOrientationComboBox = nullptr; // labels and displays
    QHash<QString, QLabel *>labelPtrs;
    int m_precision;
    QString m_displayFormat;
    QChar m_displayFormatConversion;
    bool m_displayFormatValid = false;
    QuteWidgetType m_typeid;

private slots:
    // void selectTextColor();
    // void selectBgColor();
};

class QuteLineEdit : public QuteText
{
	Q_OBJECT
public:
	QuteLineEdit(QWidget* parent);
	~QuteLineEdit();

	virtual void setText(QString text);
	virtual QString getWidgetXmlText();
	virtual QString getStringValue();
	virtual double getValue();
	virtual QString getWidgetType();
	virtual void dropEvent(QDropEvent *event);
	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);
	virtual QString getCabbageLine();
    QuteWidgetType getWidgetTypeID() override;

protected:
	virtual void createPropertiesDialog();
	virtual void applyProperties();
	bool eventFilter(QObject *obj, QEvent *event) override;

private:
	QCheckBox *instantCheckBox = nullptr;

private slots:
	void textEdited(QString text);
	void applyText();
	void escapePressed();
};

class QuteScrollNumber : public QuteText
{
	Q_OBJECT
public:
	QuteScrollNumber(QWidget* parent);
	~QuteScrollNumber();

    virtual void setTextAlignment(int alignment);
	virtual QString getCsladspaLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
	virtual void setValue(double value);
	virtual void setMidiValue(int value);
	virtual bool acceptsMidi() {return true;}

	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);
	virtual QString getCabbageLine();
    QuteWidgetType getWidgetTypeID() override; 


protected:
	virtual void refreshWidget();
	virtual void createPropertiesDialog();
	virtual void applyProperties();
	virtual void configureColorButtons();

	QDoubleSpinBox* resolutionSpinBox;
	QDoubleSpinBox *minSpinBox;
	QDoubleSpinBox *maxSpinBox;
	QCheckBox *triangleCheckBox = nullptr;
	QSpinBox *prefixBaselineSpinBox = nullptr;
	QSpinBox *prefixVSizeSpinBox = nullptr;
	QSpinBox *prefixHSizeSpinBox = nullptr;
	int m_places;
	double m_min, m_max;

	// Rebuild the label style so the optional triangle prefix gets its own
	// column at the left edge, independent of the configured text alignment.
	void applyTriangleStyle();

public slots:
	void setResolution(double resolution);
	void addValue(double delta);
	void setValueFromWidget(double value);
    void setValueFromDialog();
};

// Increase this to make Alt-dragging a scroll number slower. 4.0 means
// Alt-drag changes the value at 25% of the normal speed.
constexpr double scrollNumberAltSlowFactor = 4.0;

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

	// Configure the optional triangle prefix (like a Max/MSP number box).
	// fontSize/borderWidth/padding are needed to place the triangle inside the
	// widget's text area and to keep the text clear of it. baseline is a pixel
	// offset (positive moves the triangle up), verticalSize is a percentage of
	// fontSize, and horizontalSize is a percentage of a regular triangle.
	void setTriangle(bool visible, int fontSize, int borderWidth, int padding,
	                 int baseline, int verticalSize, int horizontalSize)
	{
		m_triangleVisible = visible;
		m_triangleFontSize = qMax(1, fontSize);
		m_triangleBorder = qMax(0, borderWidth);
		m_trianglePadding = qMax(0, padding);
		m_triangleBaseline = baseline;
		m_triangleVSize = qMax(1, verticalSize);
		m_triangleHSize = qMax(1, horizontalSize);
		update();
	}

	// Horizontal space (triangle plus gap) the text has to leave free at the
	// left edge. Zero when the triangle is hidden.
	int triangleExtraWidth() const
	{
		if (!m_triangleVisible)
			return 0;
		return triangleWidth() + triangleGap();
	}

protected:
	virtual void paintEvent(QPaintEvent *event) override;
	virtual void mouseMoveEvent(QMouseEvent * event)
	{
		if (pressed) {
			double delta = (oldy - event->y()) * m_resolution;
			if (event->modifiers() & Qt::AltModifier)
				delta /= scrollNumberAltSlowFactor;
			emit addValue(delta);
			oldy = event->y();
		}
	}
	virtual void mousePressEvent(QMouseEvent * event)
	{
		if (event->button() & Qt::LeftButton) {
			oldy = event->y();
			pressed = true;
		}
	}
	virtual void mouseReleaseEvent (QMouseEvent * event)
	{
		QLabel::mouseReleaseEvent(event);
		pressed = false;
	}

    virtual void mouseDoubleClickEvent (QMouseEvent *event) {
        if(!event->modifiers())
            emit doubleClick();
        else
            QLabel::mouseDoubleClickEvent(event);
    }

private:
	double m_resolution;
//	double m_min, m_max;
	int oldy;
	bool pressed;

	bool m_triangleVisible = false;
	int m_triangleFontSize = 12;
	int m_triangleBorder = 0;
	int m_trianglePadding = 0;
	int m_triangleBaseline = 0;
	int m_triangleVSize = 80;
	int m_triangleHSize = 68;

	int triangleHeight() const
	{
		return qMax(1, qRound(m_triangleFontSize * (m_triangleVSize / 100.0)));
	}
	int triangleWidth() const
	{
		// 100% is an equilateral (regular) triangle; lower values flatten it.
		return qMax(1, qRound(triangleHeight() * 0.8660254037844386
		                       * (m_triangleHSize / 100.0)));
	}
	int triangleGap() const
	{
		return qMax(2, m_triangleFontSize / 4);
	}

signals:
	void addValue(double delta);
	void setValue(double value);
    void doubleClick();
};

#endif
