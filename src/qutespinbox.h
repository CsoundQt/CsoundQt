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

#ifndef QUTESPINBOX_H
#define QUTESPINBOX_H

#include "qutetext.h"

class QuteSpinBox : public QuteText
{
	Q_OBJECT
public:
	QuteSpinBox(QWidget* parent);
	~QuteSpinBox();

	virtual void setText(QString text);
	virtual void setMidiValue(int value);
	//    virtual void setResolution(double resolution);
	virtual QString getWidgetLine();
	virtual QString getCsladspaLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();

	virtual void refreshWidget();
	virtual void applyInternalProperties();

protected:
	virtual void createPropertiesDialog();
	virtual void applyProperties();

protected slots:
	void valueChanged(double value);
	void setInternalValue(double value);
	void editingFinishedSlot();

private:
	QDoubleSpinBox *minSpinBox;
	QDoubleSpinBox *maxSpinBox;
	QDoubleSpinBox* resolutionSpinBox;
};

#endif
