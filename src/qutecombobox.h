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

class QuteComboBox : public QuteWidget
{
	Q_OBJECT
public:
	QuteComboBox(QWidget *parent);
	~QuteComboBox();

	virtual QString getWidgetLine();
	virtual QString getCabbageLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
	virtual QString getQml();
	void setText(QString text);  //Text for this widget is the item list separated by commas
	void clearItems();
	void addItem(QString text, double value, QString stringvalue);
	virtual void refreshWidget();
	virtual void applyInternalProperties();

protected:
	virtual void applyProperties();
	virtual void createPropertiesDialog();

private:
	QString itemList();
	QStringList stringValues;
	//    int m_size;
	QLineEdit *text;
	QLineEdit *line;

private slots:
	void indexChanged(int value);

};

#endif
