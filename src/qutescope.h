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

#ifndef QUTESCOPE_H
#define QUTESCOPE_H

#include "qutewidget.h"
#include "csoundengine.h"  //necessary for the CsoundUserData struct

class ScopeParams;
class DataDisplay;
class ScopeData;
class LissajouData;
class PoincareData;

//
// To add a new kind of display you have to derive a class from the abstract
// class DataDisplay. This new class will be created in the constructor of
// the QuteScope class and referenced through a pointer, member of the
// later class.
// You have then to modify the QuteScope destructor and setType member
// accordingly.
// Finally the new type has to appear in the createPropertiesDialog method
//
class QuteScope : public QuteWidget
{
	Q_OBJECT
public:
	QuteScope(QWidget *parent);

	~QuteScope();

	virtual QString getWidgetLine();
	virtual QString getWidgetXmlText();
	virtual QString getWidgetType();
	//    virtual void setWidgetGeometry(int x,int y,int width,int height);
	virtual void createPropertiesDialog();
	void setType(QString type);
	void setValue(double value); //Value for this widget indicates zoom level
	//    void setChannel(int channel);
	void setUd(CsoundUserData *ud);

	virtual void applyInternalProperties();

protected:
	//    QString m_type;
	//    int m_channel;
	//    int m_zoom;
	QLabel * m_label;
	QComboBox *typeComboBox;
	QComboBox *channelBox;
	QDoubleSpinBox *zoomxBox;
	QDoubleSpinBox *zoomyBox;
	ScopeParams *m_params;
	DataDisplay *m_dataDisplay;
	ScopeData *m_scopeData;
	LissajouData *m_lissajouData;
	PoincareData *m_poincareData;

	virtual void resizeEvent(QResizeEvent * event);
	virtual void applyProperties();
	QReadWriteLock scopeLock;

private:
	void updateLabel();

public slots:
	void updateData();
};

class ScopeWidget : public QGraphicsView
{
	Q_OBJECT
public:
	ScopeWidget(QWidget* parent) : QGraphicsView(parent)
	{
		setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
		setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
		freeze = false;
	}
	~ScopeWidget() {}

	bool freeze;

protected:
	//     virtual void contextMenuEvent(QContextMenuEvent *event)
	//     {emit(popUpMenu(event->globalPos()));}
	virtual void mousePressEvent(QMouseEvent *event)
	{
		if (event->button() & Qt::LeftButton)
			freeze = true;
	}
    virtual void mouseReleaseEvent(QMouseEvent * /* event */)
	{
		freeze = false;
	}

	//   signals:
	//     void popUpMenu(QPoint pos);
};


//
// This class encapsulates data common to all types of displays
// ie ud (user data), scene, widget, mutex, width and height
//
class ScopeParams
{
public:
	ScopeParams(CsoundUserData *ud, QGraphicsScene *scene, ScopeWidget *widget,
				QReadWriteLock *mutex, int width, int height)
	{
		this->ud = ud;
		this->scene = scene;
		this->widget = widget;
		this->mutex = mutex;
		this->width = width;
		this->height = height;
	}
	void setWidth(int width)
	{
		this->width = width;
	}
	void setHeight(int height)
	{
		this->height = height;
	}

	CsoundUserData *ud;
	QGraphicsScene *scene;
	ScopeWidget *widget;
	QReadWriteLock *mutex;
	int width;
	int height;
};


//
// A custom QGraphicsItem to display sets of points
//
class ScopeItem : public QGraphicsItem
{
public:
	ScopeItem(int width, int height);
	QRectF boundingRect() const
	{
		return QRectF(-m_width/2, -m_height/2, m_width, m_height);
	}
	void paint(QPainter *p, const QStyleOptionGraphicsItem *option, QWidget *widget);
	void setPen(const QPen & pen);
	void setPolygon(const QPolygonF & polygon);
	void setSize(int width, int height);

protected:
	int m_width;
	int m_height;
	QPen m_pen;
	QPolygonF m_polygon;
};


//
// Abstract base class for displays. The inherited classes will differ
// mainly through the updateData method
//
class DataDisplay
{
public:
	DataDisplay(ScopeParams *params)
	{
		m_params = params;
	}
	virtual void resize() = 0;
	virtual void updateData(int channel, double zoomx, double zoomy, bool freeze) = 0;
	virtual void show() = 0;
	virtual void hide() = 0;

protected:
	ScopeParams *m_params;
};


//
// Display class for oscilloscope view
//
class ScopeData : public DataDisplay
{
public:
	ScopeData(ScopeParams *params);
	virtual ~ScopeData() {}
	virtual void resize();
	virtual void updateData(int channel, double zoomx, double zoomy, bool freeze);
	virtual void show();
	virtual void hide();

protected:
	QPolygonF curveData;
	QGraphicsPolygonItem *curve;
};


//
// Display class for Lissajou curves or two dimensional map
//
class LissajouData : public DataDisplay
{
public:
	LissajouData(ScopeParams *params);
	virtual ~LissajouData() {}
	virtual void resize();
	virtual void updateData(int channel, double zoomx, double zoomy, bool freeze);
	virtual void show();
	virtual void hide();

protected:
	QPolygonF curveData;
	ScopeItem *curve;
};


//
// Display class for Poincare map
//
class PoincareData : public DataDisplay
{
public:
	PoincareData(ScopeParams *params);
	virtual ~PoincareData() {}
	virtual void resize();
	virtual void updateData(int channel, double zoomx, double zoomy, bool freeze);
	virtual void show();
	virtual void hide();

protected:
	QPolygonF curveData;
	ScopeItem *curve;
	double lastValue;  // holds the last ordinate value to become abcsissa value of the next pass
};

#endif

