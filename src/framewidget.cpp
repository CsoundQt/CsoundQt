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

#include "framewidget.h"
#include "qutewidget.h"

#include <QColor>
using namespace Qt::StringLiterals;

// Grab zones at the bottom-right and top-left corners of an edit-mode frame.
// The zones shrink for very small widgets so that both always fit without
// overlapping. The visible 6x6 square is drawn only for selected widgets.
static constexpr int kResizeHitSize = 8;
static constexpr int kResizeHandleSize = 8;
static constexpr int kResizeHandleBorder = 1;         // px, opaque
static constexpr qreal kResizeHandleFillOpacity = 0.4;

// Default edit-frame colours, used until Settings/Widgets overrides them.
static const char *kDefaultFrameColorSelected = "#1e96f0";   // rgb(30, 150, 240)
static const char *kDefaultFrameColorUnselected = "#00bbbb"; // used to be "#008000"
static constexpr qreal kDefaultFrameOpacityUnselected = 0.8;

// Current edit-frame colours (a global setting). Unlike the unselected colour,
// the selected colour has no opacity; the resize handle is derived from it.
static QColor s_frameColorUnselected = [] {
    QColor c(kDefaultFrameColorUnselected);
    c.setAlphaF(kDefaultFrameOpacityUnselected);
    return c;
}();
static QColor s_frameColorSelected = QColor(kDefaultFrameColorSelected);

QColor FrameWidget::frameColorUnselected() { return s_frameColorUnselected; }
QColor FrameWidget::frameColorSelected() { return s_frameColorSelected; }

void FrameWidget::setFrameColors(const QColor &unselected, const QColor &selected)
{
    if (unselected.isValid())
        s_frameColorUnselected = unselected;
    if (selected.isValid())
        s_frameColorSelected = selected;
}

// Effective corner zone size: the full size, but never more than half of either
// dimension, so the two zones can never overlap (at least 2 px for the minimum
// widget size).
static inline int resizeZoneSize(const QWidget *w)
{
    return qMin(kResizeHitSize, qMin(w->width()/2, w->height()/2));
}

// Visible handle size, clamped to the widget.
static inline int resizeHandleSize(const QWidget *w)
{
    return qMin(kResizeHandleSize, qMin(w->width(), w->height()));
}

static inline bool inResizeHitZoneBR(const QWidget *w, int x, int y)
{
    const int z = resizeZoneSize(w);
    return z > 0 && x >= w->width() - z && y >= w->height() - z;
}

static inline bool inResizeHitZoneTL(const QWidget *w, int x, int y)
{
    const int z = resizeZoneSize(w);
    return z > 0 && x < z && y < z;
}

static QString unselectedFrameStyleSheet(bool dotted)
{
    const QColor border = s_frameColorUnselected;
    return QString("FrameWidget { color:%1; border:2px %2 rgba(%3, %4, %5, %6); }")
            .arg(qApp->palette().color(QPalette::WindowText).name(),
                 dotted ? u"dotted"_s : u"solid"_s)
            .arg(border.red()).arg(border.green()).arg(border.blue()).arg(border.alpha());
}

static QString selectedFrameStyleSheet()
{
    return QString("FrameWidget { color:%1; border:2px solid %2; }")
            .arg(qApp->palette().color(QPalette::WindowText).name(),
                 s_frameColorSelected.name());
}

static QString resizeHandleStyleSheet(const QString &name)
{
    QColor fill = s_frameColorSelected;
    fill.setAlphaF(kResizeHandleFillOpacity);
    return QString("QFrame#%1 { background-color: rgba(%2, %3, %4, %5); border: %6px solid %7; }")
            .arg(name)
            .arg(fill.red()).arg(fill.green()).arg(fill.blue()).arg(fill.alpha())
            .arg(kResizeHandleBorder)
            .arg(s_frameColorSelected.name());
}

FrameWidget::FrameWidget(QWidget* parent) : QFrame(parent)
{
	this->setMinimumSize(2,2);
	// m_widget is assigned by createEditFrame() (setWidget) after construction;
	// refreshFrameAppearance() at the end of this constructor must not read it
	// uninitialised.
	m_widget = nullptr;
	m_resize = false;
	startx = starty = oldx = oldy = 0;
	// Visible corner squares, shown only while the frame is selected. They must
	// not swallow mouse events.
	auto makeHandle = [this](const QString &name) {
		QFrame *h = new QFrame(this);
		h->setObjectName(name);
		h->setStyleSheet(resizeHandleStyleSheet(name));
		h->setAttribute(Qt::WA_TransparentForMouseEvents, true);
		h->hide();
		return h;
	};
	m_resizeHandleBR = makeHandle("resizeHandleBR");
	m_resizeHandleTL = makeHandle("resizeHandleTL");
	// Invisible children that only provide the resize cursor at the two corners.
	// They ignore mouse events (the default), so press/move/release propagate to
	// this frame and drive the resize (see mouseMoveEvent()).
	m_resizeHitBR = new QWidget(this);
	m_resizeHitBR->setObjectName("resizeHitBR");
	m_resizeHitBR->setCursor(Qt::SizeFDiagCursor);
	m_resizeHitBR->setGeometry(width()-kResizeHitSize, height()-kResizeHitSize,
	                           kResizeHitSize, kResizeHitSize);
	m_resizeHitBR->show();
	m_resizeHitTL = new QWidget(this);
	m_resizeHitTL->setObjectName("resizeHitTL");
	m_resizeHitTL->setCursor(Qt::SizeFDiagCursor);
	m_resizeHitTL->setGeometry(0, 0, kResizeHitSize, kResizeHitSize);
	m_resizeHitTL->show();
	m_selected = false;
	m_selecting = false;
	m_changed = false;
	m_moving = false;
	m_resizeTopLeft = false;
	m_ctrlPress = false;
	m_dragStarted = false;
    refreshFrameAppearance();
}

FrameWidget::~FrameWidget()
{
}

void FrameWidget::select()
{
	if (m_selected)
		return;
	m_selected = true;
    refreshFrameAppearance();
    m_resizeHandleBR->show();
    m_resizeHandleTL->show();

	emit widgetSelected(m_widget);
}

void FrameWidget::setSelected(bool status) {
    if(status) {
        this->select();
    } else
        this->deselect();
}

void FrameWidget::deselect()
{
	if (!m_selected)
		return;
	m_selected = false;
    refreshFrameAppearance();
    m_resizeHandleBR->hide();
    m_resizeHandleTL->hide();
	emit widgetUnselected(m_widget);
}

bool FrameWidget::isSelected()
{
	return m_selected;
}

void FrameWidget::refreshFrameAppearance()
{
    if (m_selected) {
        this->setStyleSheet(selectedFrameStyleSheet());
    } else {
        // Locked widgets get a dotted frame so it is obvious they cannot be moved.
        const bool locked = m_widget && m_widget->property("CSQT_locked").toBool();
        this->setStyleSheet(unselectedFrameStyleSheet(locked));
    }
    m_resizeHandleBR->setStyleSheet(resizeHandleStyleSheet("resizeHandleBR"));
    m_resizeHandleTL->setStyleSheet(resizeHandleStyleSheet("resizeHandleTL"));
}

void FrameWidget::contextMenuEvent(QContextMenuEvent *event)
{
	emit(popUpMenu(event->globalPos()));
}

void FrameWidget::mousePressEvent ( QMouseEvent * event )
{
	if ((event->button() & Qt::LeftButton)
			&& (event->modifiers() & Qt::AltModifier)) {
		// Alt+click cycles the selection through the widgets stacked under the
		// cursor, going one level deeper each time.
		emit selectThrough(event->globalPosition().toPoint());
		event->accept();
		return;
	}
	if ((event->button() & Qt::LeftButton)
			&& (event->modifiers() & Qt::ShiftModifier)) {
		// Shift+click starts a rubber-band selection that is driven by the
		// parent layout. The frame keeps the mouse grab (accepts the event) so
		// it receives the move events and forwards them.
		m_selecting = true;
		emit selectionStarted(event->globalPosition().toPoint());
		event->accept();
		return;
	}
	QFrame::mousePressEvent(event);
	this->setFocus(Qt::MouseFocusReason);
	if (event->button() & Qt::LeftButton) {
		startx = event->x();
		starty = event->y();
		oldx = event->x();
		oldy = event->y();
        // Ctrl forces a move, never a resize. Selection is resolved later (see
        // mouseMoveEvent/mouseReleaseEvent) so that a Ctrl-drag does not unselect.
        const bool ctrl = event->modifiers() & Qt::ControlModifier;
        m_ctrlPress = ctrl;
        m_dragStarted = false;
        if (!ctrl && inResizeHitZoneBR(this, startx, starty)) {
			m_resize = true;
			m_resizeTopLeft = false;
		}
		else if (!ctrl && inResizeHitZoneTL(this, startx, starty)) {
			m_resize = true;
			m_resizeTopLeft = true;
		}
		else {
			m_resize = false;
			m_resizeTopLeft = false;
		}
        m_moving = !m_resize;
        m_lastGlobal = event->globalPosition().toPoint();
        if (!ctrl && !isSelected()) {
            emit deselectAllSignal();
            this->select();
        }
    }
	event->accept(); //to avoid propagation of the event to parent widgets
}

void FrameWidget::mouseReleaseEvent ( QMouseEvent * event )
{
	if (m_selecting && (event->button() & Qt::LeftButton)) {
		m_selecting = false;
		emit selectionFinished();
		event->accept();
		return;
	}
	QFrame::mouseReleaseEvent(event);
	if (m_ctrlPress && !m_dragStarted) {
		// Plain Ctrl-click: toggle this widget, leaving the others untouched.
		this->setSelected(!this->isSelected());
	}
	m_ctrlPress = false;
	m_dragStarted = false;
	m_resize = false;
	m_moving = false;
	emit mouseReleased();
	event->accept(); //to avoid propagation of the event to parent widgets
}

void FrameWidget::mouseMoveEvent (QMouseEvent* event)
{
    // Mouse tracking is off, so this only runs while a button is held. Guard
    // anyway: a stale flag (missed release) must never move/resize on hover.
    const bool leftDown = event->buttons() & Qt::LeftButton;
    if (!leftDown) {
        m_resize = false;
        m_moving = false;
    }
    if (m_selecting) {
        if (leftDown)
            emit selectionMoved(event->globalPosition().toPoint());
        return;
    }
    if (!leftDown || (!m_resize && !m_moving)) {
        return;
    }
    if (m_resize) {
        // Use global coordinates: when resizing from the top-left the frame
        // itself moves, so frame-local deltas would cancel out.
        QPoint d = event->globalPosition().toPoint() - m_lastGlobal;
        if (event->modifiers() & Qt::ShiftModifier) {
            if (qAbs(d.x()) > qAbs(d.y()))
                d.setY(0);
            else
                d.setX(0);
        }
        m_lastGlobal = event->globalPosition().toPoint();
        const QPair<int, int> pair(d.x(), d.y());
        if (m_resizeTopLeft)
            emit resizedTopLeft(pair);
        else
            emit resized(pair);
	}
	else {
		// A locked widget (labels) keeps its position when dragged.
		if (m_widget->property("CSQT_locked").toBool()) {
			return;
		}
		if (m_ctrlPress && !m_dragStarted) {
			// Ctrl-drag works like a normal drag: bring the widget into the
			// selection if needed, but never unselect what was already selected.
			m_dragStarted = true;
			if (!isSelected()) {
				emit deselectAllSignal();
				this->select();
			}
		}
		QPair<int, int> pair(event->x()- startx, event->y()- starty);
		emit moved(pair);
	}
	oldx = event->x();
	oldy = event->y();
	m_widget->markChanged();
	m_changed = true;
}

void FrameWidget::mouseDoubleClickEvent (QMouseEvent * event)
{
	event->accept();
	emit editWidget();
}

void FrameWidget::resizeEvent (QResizeEvent* event)
{
	QWidget::resizeEvent(event);
	// Visible squares (clamped) at the two corners.
	const int h = resizeHandleSize(this);
	m_resizeHandleBR->setGeometry(width()-h, height()-h, h, h);
	m_resizeHandleTL->setGeometry(0, 0, h, h);
	// Cursor zones on top: full size normally, scaled down for very small widgets.
	const int z = resizeZoneSize(this);
	m_resizeHitBR->setGeometry(width()-z, height()-z, z, z);
	m_resizeHitBR->raise();
	m_resizeHitTL->setGeometry(0, 0, z, z);
	m_resizeHitTL->raise();
}
