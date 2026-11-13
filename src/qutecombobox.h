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

#ifndef QUTECOMBOBOX_H
#define QUTECOMBOBOX_H

#include "qutewidget.h"

#include <QComboBox>
#include <QColor>

class SelectColorButton;

// Self-painted combo box used by the flat Menu widget. The closed box and its
// popup are drawn from explicit colours instead of the application style; the
// selected popup row uses the inverted background/foreground pair.
class FlatComboBox : public QComboBox
{
public:
	explicit FlatComboBox(QWidget *parent = nullptr);

	void setFlatProperties(bool flat, const QColor &background,
	                       const QColor &foreground, int borderWidth,
	                       int borderRadius, const QColor &borderColor);

protected:
	void paintEvent(QPaintEvent *event) override;
	void showPopup() override;

private:
	void applyPopupStyle();
	bool m_flat = false;
	QColor m_background = QColor("#eff0f1");
	QColor m_foreground = QColor("#34393a");
	QColor m_borderColor = QColor("#aebdc2");
	int m_borderWidth = 1;
	int m_borderRadius = 0;
	QPointer<QWidget> m_styledPopup;
};

class QuteComboBox : public QuteWidget
{
	Q_OBJECT
public:
	QuteComboBox(QWidget *parent);
	~QuteComboBox();

	virtual QString getCabbageLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
	virtual QString getQml();
	virtual void setMidiValue(int value);
	QuteWidgetType getWidgetTypeID() override;
	virtual bool acceptsMidi() {return true;}
	void setText(QString text);  //Text for this widget is the item list separated by commas
	void clearItems();
	void addItem(QString text, double value, QString stringvalue);
	virtual void refreshWidget();
	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);

protected:
	virtual void applyProperties();
	virtual void createPropertiesDialog();

private:
	QString itemList();
	void updateFlatStyle();
	QStringList stringValues;
	//    int m_size;
	QLineEdit *text;
	QLineEdit *line;
	QComboBox *fontComboBox = nullptr;
	QSpinBox *fontSizeSpinBox = nullptr;
	QCheckBox *flatStyleCheckBox = nullptr;
	SelectColorButton *backgroundColorButton = nullptr;
	SelectColorButton *foregroundColorButton = nullptr;
	SelectColorButton *borderColorButton = nullptr;
	QSpinBox *borderWidthSpinBox = nullptr;
	QSpinBox *borderRadiusSpinBox = nullptr;

private slots:
	void indexChanged(int value);

};

#endif
