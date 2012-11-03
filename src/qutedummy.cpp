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

#include "qutedummy.h"

QuteDummy::QuteDummy(QWidget *parent) : QuteWidget(parent)
{
	m_widget = new QFrame(this);
	m_widget->setAutoFillBackground (true);
	m_widget->setPalette(QPalette(Qt::gray));
	m_widget->setMouseTracking(true); // Necessary to pass mouse tracking to widget panel for _MouseX channels
}

QuteDummy::~QuteDummy()
{
}


QString QuteDummy::getWidgetLine()
{
	return QString();
}

QString QuteDummy::getWidgetXmlText()
{
	// Just an empty place holder
	xmlText = "";
	QXmlStreamWriter s(&xmlText);
	createXmlWriter(s);

#ifdef  USE_WIDGET_MUTEX
	widgetLock.lockForRead();
#endif
	s.writeEndElement();
#ifdef  USE_WIDGET_MUTEX
	widgetLock.unlock();
#endif
	return xmlText;
}

QString QuteDummy::getWidgetType()
{
	return QString("BSBDummy");
}
