/*
	Copyright (C) 2010 Andres Cabrera
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

#ifndef ABOUT_H
#define ABOUT_H

#include <QDialog>
#include <QTextBrowser>

namespace Ui {
class About;
}

class About : public QDialog {
	Q_OBJECT
public:
	About(QWidget *parent = 0);
	~About();

	void setHtmlText(QString text);
	QTextBrowser *getTextEdit();

protected:
	void changeEvent(QEvent *e);

private:
	Ui::About *ui;
};

#endif // ABOUT_H
