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

#ifndef WIDGETPANEL_H
#define WIDGETPANEL_H

#ifdef USE_QT5
#include <QtWidgets>
#else
#include <QtGui>
#endif

class WidgetLayout;

class WidgetPanel : public QDockWidget
{
	Q_OBJECT

	friend class CsoundQt;  // To allow edit actions- TODO- can this be done all here?
	friend class QuteWidget;  // To allow edit actions
public:
	WidgetPanel(QWidget *parent);
	~WidgetPanel();

	void addWidgetLayout(WidgetLayout *layoutWidget);
	WidgetLayout * takeWidgetLayout(QRect outerGeometry);
	
	QRect getOuterGeometry();

	void setWidgetScrollBarsActive(bool active);

public slots:

protected:
	virtual void contextMenuEvent(QContextMenuEvent *event);
	virtual void mousePressEvent(QMouseEvent * event);
	virtual void mouseReleaseEvent(QMouseEvent * event);
	virtual void mouseMoveEvent (QMouseEvent * event);

	virtual void closeEvent(QCloseEvent * event);

private:
	QStackedWidget *m_stack;

	QStringList clipboard;
	QSize oldSize;
	int m_width;
	int m_height;

private slots:
	void scrollBarMoved(int);

signals:
	void Close(bool visible);
};

#endif
