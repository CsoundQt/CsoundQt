/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/

#include "simpledocument.h"
#include "documentview.h"
#include "widgetlayout.h"
#include "qutebutton.h"
#include "quteapp.h"

SimpleDocument::SimpleDocument(QWidget *parent, OpEntryParser *opcodeTree) :
	BaseDocument(parent,opcodeTree)
{
	init(parent,opcodeTree);
}

void SimpleDocument::setTextString(QString &text)
{
	m_widgetLayouts[0]->setFontScaling(1.0); // Must come before parsing
	parseTextString(text);
	m_widgetLayouts[0]->show();
	m_widgetLayouts[0]->setWidgetsLocked(true);
	m_view->setFullText(text, true);  // TODO do something different if not a csd file?
}

void SimpleDocument::registerButton(QuteButton *b)
{
	connect(b, SIGNAL(play()), static_cast<QuteApp *>(parent()), SLOT(start()));
	//  connect(b, SIGNAL(render()), static_cast<qutecsound *>(parent()), SLOT(render()));
	connect(b, SIGNAL(pause()), static_cast<QuteApp *>(parent()), SLOT(pause()));
	connect(b, SIGNAL(stop()), static_cast<QuteApp *>(parent()), SLOT(stop()));
}

void SimpleDocument::init(QWidget *parent, OpEntryParser *opcodeTree)
{
	m_view = new DocumentView(parent, opcodeTree);
	m_view->hide();
}
