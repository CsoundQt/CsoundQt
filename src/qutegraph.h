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
#include "curve.h"         // necessary for CurveType

#include <QPointer>
#include <atomic>

class Curve;

enum GraphType { GRAPH_FTABLE=1, GRAPH_AUDIOSIGNAL=2, GRAPH_SPECTRUM=3 };


class QuteGraph : public QuteWidget
{
	Q_OBJECT

//	Q_PROPERTY(bool CSQT_grid MEMBER m_grid)
//	Q_PROPERTY(bool CSQT_logx MEMBER m_logx)
//	Q_PROPERTY(bool CSQT_logy MEMBER m_logy)

public:
	QuteGraph(QWidget *parent);

	~QuteGraph();

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
        setProperty("CSQT_showTableInfo", state?"true":"false");
        if(m_label != nullptr) {
            if(state)
                m_label->show();
            else
                m_label->hide();
        }
    }
    int findCurve(CurveType type, QStringView text);
	virtual void applyInternalProperties();
	virtual bool applyProperty(const QString &name);
	QStringList transitoryProperties() const override;
	virtual void setWidgetEnabled(bool enabled);
    size_t spectrumGetPeak(Curve *curve, double freq, double relativeBandwidth);
    size_t spectrumGetNearestPeak(Curve *curve, double freq, double windowHz, int step);
    QuteWidgetType getWidgetTypeID() override;

protected:
	CsoundUserData *m_ud;
	QLabel * m_label;
	QComboBox *m_pageComboBox;
	QLineEdit* name2LineEdit;
	QDoubleSpinBox *zoomxBox;
	QDoubleSpinBox *zoomyBox;
    QCheckBox *acceptTablesCheckBox;
    QCheckBox *acceptDisplaysCheckBox;
    QCheckBox *showSelectorCheckBox;
    QCheckBox *showGridCheckBox;
    QCheckBox *showTableInfoCheckBox;
    QCheckBox *showScrollbarsCheckBox;

	QVector<Curve *> curves;
	QVector<QGraphicsPolygonItem *> polygons;
    QVector<GraphType>graphtypes;

	QVector<QVector <QGraphicsLineItem *> > m_gridlines;
    QVector<QVector <QGraphicsTextItem *> > m_gridTextsX;
    QVector<QVector <QGraphicsTextItem *> > m_gridTextsY;

    // Persistent scene items for the signal/ftable paths. They are created once
    // in addCurve() and redrawn with setPath(), so the scene is not cleared and
    // rebuilt on every update.
    QVector<QGraphicsPathItem *> m_pathItems;   // data curve (signal / ftable)
    QVector<QGraphicsPathItem *> m_axisItems;   // baseline for signal displays

    // Cache of the parameters the grid was last built with, per curve index,
    // so the (static) grid items are only touched when something changes.
    struct GridCache {
        bool valid = false;
        bool drawn = false;
        int curveSize = -1;
        double dbRange = 0.0;
        int numTicksY = -1;
        int numTicksX = -1;
    };
    QVector<GridCache> m_gridCache;

    // speactrum peak
    QVector<QGraphicsTextItem*> m_spectrumPeakTexts;
    QVector<QGraphicsRectItem*> m_spectrumPeakMarkers;


	virtual void refreshWidget();
	virtual void createPropertiesDialog();
	virtual void applyProperties();
    virtual void keyPressEvent(QKeyEvent *ev);
    virtual void mousePressEvent(QMouseEvent *ev);
    // virtual void mouseReleaseEvent(QMouseEvent *ev);
    // virtual void mouseMoveEvent(QMouseEvent *ev);

public slots:
	void changeCurve(int index);
	void indexChanged(int index);
    void mouseReleased();

private:
    void drawFtablePath(Curve * curve, int index);

    void drawSpectrum(Curve * curve, int index);

    void drawSignalPath(Curve * curve, int index);

	void scaleGraph(int index);
	int getTableNumForIndex(int index);
    int getIndexForTableNum(int GRAPH_FTABLE);
	void setInternalValue(double value);
    void drawGraph(Curve *curve, int index);
    void showScrollbars(bool show);
    void freezeSpectrum(bool status);

    // Transitory graph "methods" (see transitoryProperties()). Each is reachable
    // as an outvalue "<name>/<method>" property.
    void findFft(const QString &text);
    void findAudio(const QString &text);
    void findTable(int tabnum);
    void freezeGraph(int status);
    void setPeakChannel(const QString &channel);

    QVector<double> frozenCurve;

    QGraphicsView* getView(int index);

    QMutex curveLock;
	bool m_grid;
	bool m_logx;
	bool m_logy;
    bool m_drawGrid;
    bool m_drawTableInfo;
    int m_numticksY;
    bool m_showScrollbars;
    double m_showPeakCenterFrequency;
    double m_showPeakRelativeBandwidth;
    bool m_showPeak;
    bool m_showPeakTemp;
    bool m_frozen;
    double m_lastPeakFreq;
    double m_lastTextMarkerY;
    double m_lastTextMarkerX;
    QString m_getPeakChannel;
    cs_float *m_peakChannelPtr;
    bool m_mouseDragging;
    double m_showPeakTempFrequency;
    double m_dbRange;
    bool m_enableTables;
    bool m_enableDisplays;
    double m_zoomx;
    double m_zoomy;

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
        while (widget != nullptr) {
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
        , m_miny(-1.0)
        , m_autorange(true)
        , m_showGrid(true)
        , gridFont(QStringLiteral("JetBrains Mono"), 8)
        , gridFontMetrics(QFont(QStringLiteral("JetBrains Mono"), 8))
    {}
    virtual ~QuteTableWidget() override;
    void setUserData(CsoundUserData *ud) {
        mutex.lock(); m_ud = ud; mutex.unlock(); }
    void updateData(int tabnum);
    void setRunningStatus(int running) { m_running = running; }
    int currentTableNumber() { return m_tabnum; }
    void updatePath();
    void setColor(QColor color) { m_color = color; }
    // Colour of the plot background.
    void setBackgroundColor(const QColor &color) {
        if (m_background == color) return;
        m_background = color;
        update();
    }
    // Colour of the grid and of the zero line.
    void setGridColor(const QColor &color) {
        if (m_gridColor == color) return;
        m_gridColor = color;
        update();
    }
    // Sample rate used to convert the table index to time on the x axis.
    // Zero selects the auto mode: the table's sample rate if it defines one,
    // otherwise 1. Any positive value is used as the sample rate.
    void setSampleRate(double sampleRate) {
        if (sampleRate < 0.0) sampleRate = 0.0;
        if (m_sampleRate == sampleRate) return;
        m_sampleRate = sampleRate;
        if (m_sampleRate == 0.0)
            startSampleRateQuery();
        update();
    }
    // Seconds per table index, used to lay out the x axis.
    double xFactor() const {
        if (m_sampleRate > 0.0) return 1.0 / m_sampleRate;
        if (m_tableSampleRate > 0.0) return 1.0 / m_tableSampleRate;
        return 1.0;
    }
    void setRange(double maxy=1.0);
    void setMaxRange(double maxy);
    void setMinRange(double miny);
    void showGrid(bool show) { m_showGrid = show; }
    void reset();
    void paintGrid(QPainter *painter);
    void stop(CsoundUserData *ud) {
        mutex.lock();
        m_ud = ud;
        reset();
        mutex.unlock();
    }
    // Called by the engine just before the Csound instance is destroyed, while
    // the table is still valid, to copy it so the plot can persist after the
    // performance stops.
    void persistTable(CSOUND *cs);

protected:
    virtual void paintEvent(QPaintEvent *event) override;
    virtual void resizeEvent(QResizeEvent *event) override;

private:
    void buildPath(const cs_float *data, int tabsize);
    // Redraw the persisted table copy (used when Csound is not running).
    void showSnapshot();

    // Area used for the curve and the grid, inside the tick labels.
    QRectF plotRect() const;
    // Map a data value to a vertical pixel position in the plot area.
    double valueToY(double value, const QRectF &plot) const;
    // A "nice" tick interval (1, 2 or 5 times a power of ten).
    static double niceTickStep(double range, int targetTicks);
    // Format a tick value with a precision that suits the tick interval.
    QString formatTickValue(double value, double step) const;

    // Ask Csound for the sample rate of the current table. A table can be
    // loaded asynchronously, so the query waits for Csound to perform and is
    // retried a few times (see qutewaveform.cpp).
    void startSampleRateQuery();
    void querySampleRate();
    void finishSampleRateQuery();
    void retrySampleRateQuery();
    // Runs on the performance thread; only touches atomics.
    static void sampleRateQueryCallback(cs_float out, void *userdata);

    int m_tabnum;
    CsoundUserData *m_ud;
    bool m_running;
    QColor m_color = QColor(255, 193, 3);
    QColor m_background = QColor(24, 24, 24);
    QColor m_gridColor = QColor(160, 160, 160, 72);
    double m_sampleRate = 1.0;
    double m_tableSampleRate = 0.0;
    int m_sampleRateTable = -1;          // table whose sample rate is known
    int m_sampleRateQueryAttempt = 0;
    bool m_sampleRateQueryActive = false;
    std::atomic<int> m_detectedSampleRate{0};
    std::atomic<int> m_sampleRateReady{0};
    cs_float *m_data;
    int m_tabsize;
    int m_margin;
    double m_maxy;
    double m_miny;
    bool m_autorange;
    QPainterPath m_path;
    // QPainterPath *m_path;
    QMutex mutex;
    bool m_showGrid;
    QFont gridFont;
    QFontMetrics gridFontMetrics;

    QVector<cs_float> m_snapshot;          // table copy kept after stop
    std::atomic<int> m_snapshotTabnum{0};
    std::atomic<bool> m_hasSnapshot{false};

// public slot:

};


class QuteTable : public QuteWidget {
    Q_OBJECT

public:
    QuteTable(QWidget *parent);
    ~QuteTable();
    virtual QString getWidgetXmlText();
    virtual QString getWidgetType() { return QString("BSBTableDisplay"); }
    // virtual void setWidgetGeometry(int x,int y,int width,int height);
    virtual void applyInternalProperties();
    virtual bool applyProperty(const QString &name);
    virtual void createPropertiesDialog();
    virtual void refreshWidget();
    QStringList transitoryProperties() const override;
    QHash<QString, QString> propertyDescriptions() const override;

    virtual void setCsoundUserData(CsoundUserData *ud);
    virtual void setValue(double value);
    virtual void setValue(QString s);
    virtual void setColor(QColor color);
    QuteWidgetType getWidgetTypeID() override;
	
    void setTableNumber(int tabnum);

public slots:
    void onStop();

private:
    int m_tabnum;

protected:
    // virtual void mousePressEvent(QMouseEvent *event);
    // virtual void mouseReleaseEvent(QMouseEvent *event);

    virtual void applyProperties();
    SelectColorButton *colorButton;
    SelectColorButton *backgroundColorButton;
    SelectColorButton *gridColorButton;
    QDoubleSpinBox *sampleRateSpinBox;
    QCheckBox *rangeCheckBox;
    QDoubleSpinBox *rangeSpinBox;
    QCheckBox *gridCheckBox;
    QMutex mutex;
    bool m_csoundRunning;
    QPointer<CsoundEngine> m_registeredEngine;  // engine the snapshot callback is registered with

};

class SpectralView : public QGraphicsView {
    Q_OBJECT

public:

    SpectralView(QWidget *parent) : QGraphicsView(parent) {}

    ~SpectralView();
    // virtual void mousePressEvent(QMouseEvent *ev);
    virtual void mouseReleaseEvent(QMouseEvent *ev);
    // virtual void mouseMoveEvent(QMouseEvent *ev);

signals:
    void mouseReleased();

};


#endif
