
/*
	Copyright (C) 2010 Andres Cabrera
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

#include "about.h"
#include "ui_about.h"
#include "widgetstyle.h"

#include <QScrollBar>

About::About(QWidget *parent) :
	QDialog(parent),
	ui(new Ui::About)
{
	ui->setupUi(this);
	updateScrollBarStyle();
}

void About::updateScrollBarStyle()
{
	// Flat scrollbars are a Fusion-only extra (see widgetstyle.h): every other
	// widget style keeps its native scrollbars.
	const bool flat =
			currentWidgetStyleName().compare(u"Fusion"_s, Qt::CaseInsensitive) == 0
			&& flatScrollBarsEnabled();
	const QString sheet = flat
			? flatScrollBarStyleSheet(ui->infoText->palette().color(QPalette::Base))
			: QString();
	for (QScrollBar *bar : {ui->infoText->verticalScrollBar(),
							ui->infoText->horizontalScrollBar()}) {
		if (bar->styleSheet() != sheet)
			bar->setStyleSheet(sheet);
	}
}

About::~About()
{
	delete ui;
}

void About::setHtmlText(QString text)
{
	ui->infoText->setHtml(text);
}

QTextBrowser *About::getTextEdit()
{
	return ui->infoText;
}

void About::changeEvent(QEvent *e)
{
	QDialog::changeEvent(e);
	switch (e->type()) {
	case QEvent::LanguageChange:
		ui->retranslateUi(this);
		break;
	case QEvent::StyleChange:
	case QEvent::PaletteChange:
		// The widget style or application palette changed while the dialog is
		// open: keep the scrollbar look in sync.
		updateScrollBarStyle();
		break;
	default:
		break;
	}
}
