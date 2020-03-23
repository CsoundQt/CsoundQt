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

#ifndef QUTEGRAPH_H
#define QUTEGRAPH_H

#include "qutewidget.h"
#include "csoundengine.h"  //necessary for the CsoundUserData struct
#include "selectcolorbutton.h"

class Curve;

enum GraphType { GRAPH_FTABLE=1, GRAPH_AUDIOSIGNAL=2, GRAPH_SPECTRUM=3 };


class QuteGraph : public QuteWidget
{
	Q_OBJECT

//	Q_PROPERTY(bool QCS_grid MEMBER m_grid)
//	Q_PROPERTY(bool QCS_logx MEMBER m_logx)
//	Q_PROPERTY(bool QCS_logy MEMBER m_logy)

public:
	QuteGraph(QWidget *parent);

	~QuteGraph();

	virtual QString getWidgetLine();
	virtual QString getWidgetXmlText();
    virtual QString getWidgetType();
	virtual void setWidgetGeometry(int x,int y,int width,int height);
	void setValue(double value);
	void clearCurves();
	void addCurve(Curve *curve);
	int getCurveIndex(Curve * curve);
	void setCurveData(Curve * curve);
    void setUd(CsoundUserData *ud) { m_ud = ud; }
    void showGrid(bool visible) { m_drawGrid = visible; }
    void showTableInfo(bool state) {
        m_drawTableInfo = state;
        setProperty("QCS_showTableInfo", state?"true":"false");
        if(m_label != nullptr) {
            if(state)
                m_label->show();
            else
                m_label->hide();
        }
    }
	virtual void applyInternalProperties();

protected:
	CsoundUserData *m_ud;
	QLabel * m_label;
	QComboBox *m_pageComboBox;
	QLineEdit* name2LineEdit;
	QDoubleSpinBox *zoomxBox;
	QDoubleSpinBox *zoomyBox;
    QCheckBox *showSelectorCheckBox;
    QCheckBox *showGridCheckBox;
    QCheckBox *showTableInfoCheckBox;
	QVector<Curve *> curves;
	QVector<QVector <QGraphicsLineItem *> > lines;
	QVector<QGraphicsPolygonItem *> polygons;
    QVector<QPainterPath *>painterPaths;
    QVector<GraphType>graphtypes;

	QVector<QVector <QGraphicsLineItem *> > m_gridlines;
    QVector<QVector <QGraphicsTextItem *> > m_gridTextsX;
    QVector<QVector <QGraphicsTextItem *> > m_gridTextsY;


    QPainterPath *gridPath;

	virtual void refreshWidget();
	virtual void createPropertiesDialog();
	virtual void applyProperties();
    virtual void keyPressEvent(QKeyEvent *ev);

public slots:
	void changeCurve(int index);
	void indexChanged(int index);

private:
	void drawFtable(Curve * curve, int index);
    void drawFtablePath(Curve * curve, int index);

    void drawSpectrum(Curve * curve, int index);
    void drawSpectrumPath(Curve * curve, int index);

    void drawSignal(Curve * curve, int index);
    void drawSignalPath(Curve * curve, int index);

	void scaleGraph(int index);
	int getTableNumForIndex(int index);
    int getIndexForTableNum(int GRAPH_FTABLE);
	void setInternalValue(double value);
    void drawGraph(Curve *curve, int index);

    QGraphicsView* getView(int index);

	//    QMutex curveLock;
	bool m_grid;
	bool m_logx;
	bool m_logy;
    bool m_drawGrid;
    bool m_drawTableInfo;
    int m_numticksY;

signals:
    void requestUpdateCurve(Curve *curve);

};

class StackedLayoutWidget : public QStackedWidget
{
	Q_OBJECT
public:
	StackedLayoutWidget(QWidget* parent) : QStackedWidget(parent)
	{
		setFrameShape(QFrame::StyledPanel);
	}
	~StackedLayoutWidget() {}

	void setWidgetGeometry(int x,int y,int width,int height)
	{
		setGeometry(x,y,width, height);
		setMaximumSize(width, height);
	}

	void clearCurves()
	{
		QWidget *widget;
		widget = currentWidget();
		while (widget != 0) {
			removeWidget(widget);
			widget = currentWidget();
		}
	}
	/*
  protected:
	virtual void contextMenuEvent(QContextMenuEvent *event)
	{emit(popUpMenu(event->globalPos()));}

  signals:
	void popUpMenu(QPoint pos);*/
};

// ----------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------

class QuteTableWidget : public QWidget {
    Q_OBJECT

public:
    QuteTableWidget(QWidget *parent = nullptr)
        : QWidget(parent)
        , m_tabnum(0)
        , m_ud(nullptr)
        , m_running(false)
        , m_data(nullptr)
        , m_tabsize(0)
        , m_margin(8)
        , m_maxy(1.0)
        , m_autorange(true)
        , m_path(nullptr)
        , m_showGrid(true)
    {}
    virtual ~QuteTableWidget() override;
    void setUserData(CsoundUserData *ud) { m_ud = ud; }
    void updateData(int tabnum, bool check=true);
    int currentTableNumber() { return m_tabnum; }
    void updatePath();
    void setColor(QColor color) { m_color = color; }
    void setRange(double maxy=1.0);
    void showGrid(bool show) { m_showGrid = show; }
    void reset();
    void paintGrid(QPainter *painter);

protected:
    virtual void paintEvent(QPaintEvent *event) override;

private:
    int m_tabnum;
    CsoundUserData *m_ud;
    bool m_running;
    QColor m_color;
    MYFLT *m_data;
    int m_tabsize;
    int m_margin;
    double m_maxy;
    bool m_autorange;
    QPainterPath *m_path;
    QMutex mutex;
    bool m_showGrid;

// public slot:

};


class QuteTable : public QuteWidget {
    Q_OBJECT

public:
    QuteTable(QWidget *parent);
    ~QuteTable();
    virtual QString getWidgetLine() { return QString(""); }
    virtual QString getWidgetXmlText();
    virtual QString getWidgetType() { return QString("BSBTableDisplay"); }
    // virtual void setWidgetGeometry(int x,int y,int width,int height);
    virtual void applyInternalProperties();
    virtual void createPropertiesDialog();
    virtual void refreshWidget();

    virtual void setCsoundUserData(CsoundUserData *ud);
    virtual void setValue(double value);
    virtual void setValue(QString s);
    virtual void setColor(QColor color);

public slots:
    void onStop();

private:
    int m_tabnum;

protected:
    // virtual void mousePressEvent(QMouseEvent *event);
    // virtual void mouseReleaseEvent(QMouseEvent *event);

    virtual void applyProperties();
    SelectColorButton *colorButton;
    QCheckBox *rangeCheckBox;
    QDoubleSpinBox *rangeSpinBox;
    QCheckBox *gridCheckBox;
    QMutex mutex;

};



#endif
