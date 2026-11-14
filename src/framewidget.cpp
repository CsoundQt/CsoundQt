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
#include <QFontMetrics>
#include <QPainter>
#include <QStringList>

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

FrameWidget::FrameWidget(QWidget* parent) : QFrame(parent)
{
	this->setMinimumSize(2,2);
	// m_widget is assigned by createEditFrame() (setWidget) after construction.
	m_widget = nullptr;
	m_resize = false;
	startx = starty = oldx = oldy = 0;
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
	emit widgetUnselected(m_widget);
}

bool FrameWidget::isSelected()
{
	return m_selected;
}

void FrameWidget::refreshFrameAppearance()
{
    // Locked widgets get a dotted frame so it is obvious they cannot be moved.
    m_locked = m_widget && m_widget->property("CSQT_locked").toBool();
    update();
}

void FrameWidget::setShowNameOverlay(bool show)
{
    if (m_showNameOverlay == show)
        return;
    m_showNameOverlay = show;
    update();
}

void FrameWidget::paintNameOverlay(QPainter &painter)
{
    if (m_widget == nullptr)
        return;

    QStringList lines;
    const QString widgetName = m_widget->getWidgetName();
    if (!widgetName.isEmpty())
        lines << widgetName;

    const QString channel = m_widget->getChannelName();
    const QString channel2 = m_widget->getChannel2Name();
    QString channelLine;
    if (!channel.isEmpty() && !channel2.isEmpty())
        channelLine = channel + QStringLiteral(" / ") + channel2;
    else if (!channel.isEmpty())
        channelLine = channel;
    else
        channelLine = channel2;
    if (!channelLine.isEmpty() && channelLine != widgetName)
        lines << channelLine;

    if (lines.isEmpty())
        return;

    QFont font = painter.font();
    font.setPointSizeF(7.0);
    font.setBold(true);
    const QFontMetrics metrics(font);

    // The badge is flush with the widget's top-right corner, so it uses no
    // outer padding. A little internal padding keeps the glyphs off the edge.
    const int pad = 0;
    const int maxWidth = width() - 2 * pad;
    const int lineHeight = qMax(1, metrics.height());
    const int maxLines = (height() - 2 * pad) / lineHeight;

    // Narrow widgets (typically vertical sliders) have no room for a
    // horizontal badge. Draw a single line down the right edge instead.
    if (width() < 32 && height() >= 48) {
        const int vpad = 0;
        QFont verticalFont = font;
        verticalFont.setPointSizeF(6.0);
        const QFontMetrics verticalMetrics(verticalFont);
        const int thickness = verticalMetrics.height() + 2;
        const int available = height() - 2 * vpad - 4;
        if (width() - 2 * vpad < thickness || available < 8)
            return;
        const QString text = verticalMetrics.elidedText(
                    lines.join(QStringLiteral(": ")), Qt::ElideRight,
                    available);
        if (text.isEmpty())
            return;
        const int textWidth = verticalMetrics.horizontalAdvance(text);

        painter.save();
        painter.setRenderHint(QPainter::Antialiasing, true);
        painter.translate(width() - vpad, vpad);
        painter.rotate(90);
        const QRect box(0, 0, textWidth + 4, thickness);
        painter.setPen(Qt::NoPen);
        painter.setBrush(QColor(0, 0, 0, 175));
        painter.drawRect(box);
        painter.setFont(verticalFont);
        painter.setPen(QColor(255, 255, 255, 240));
        painter.drawText(box.adjusted(2, 0, -2, 0),
                         Qt::AlignLeft | Qt::AlignVCenter, text);
        painter.restore();
        return;
    }

    if (maxWidth < 24 || maxLines < 1)
        return;
    if (lines.size() > maxLines)
        lines = lines.mid(0, maxLines);

    QStringList elided;
    int textWidth = 0;
    for (const QString &line : lines) {
        const QString text = metrics.elidedText(line, Qt::ElideRight,
                                                maxWidth - 4);
        elided << text;
        textWidth = qMax(textWidth, metrics.horizontalAdvance(text));
    }
    if (elided.isEmpty())
        return;

    const int boxWidth = qMin(maxWidth, textWidth + 4);
    const QRect box(width() - boxWidth, pad,
                    boxWidth, elided.size() * lineHeight + 4);

    painter.save();
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.setPen(Qt::NoPen);
    painter.setBrush(QColor(0, 0, 0, 175));
    painter.drawRect(box);

    painter.setFont(font);
    painter.setPen(QColor(255, 255, 255, 240));
    int y = box.top() + 2;
    for (const QString &line : elided) {
        painter.drawText(QRect(box.left() + 2, y, box.width() - 4, lineHeight),
                         Qt::AlignLeft | Qt::AlignVCenter, line);
        y += lineHeight;
    }
    painter.restore();
}

void FrameWidget::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event);
    // Draw the frame directly. A style sheet per frame (or even one inherited
    // from the panel) makes creating hundreds of frames very slow, because Qt
    // resolves and applies the sheet for every widget.
    QPainter painter(this);
    const QColor frameColor = m_selected ? s_frameColorSelected : s_frameColorUnselected;
    if (!m_selected && m_locked) {
        QPen pen(frameColor);
        pen.setWidth(2);
        pen.setStyle(Qt::DotLine);
        painter.setPen(pen);
        painter.setBrush(Qt::NoBrush);
        painter.drawRect(rect().adjusted(1, 1, -1, -1));
    } else {
        // Fill non-overlapping strips instead of stroking a thick rectangle:
        // QPainter's rasterized 2 px pen can omit the lower-left corner pixel.
        constexpr int borderWidth = 2;
        const int topHeight = qMin(borderWidth, height());
        const int bottomY = qMax(topHeight, height() - borderWidth);
        const int leftWidth = qMin(borderWidth, width());
        const int rightX = qMax(leftWidth, width() - borderWidth);
        painter.fillRect(QRect(0, 0, width(), topHeight), frameColor);
        painter.fillRect(QRect(0, bottomY, width(), height() - bottomY), frameColor);
        painter.fillRect(QRect(0, topHeight, leftWidth, bottomY - topHeight), frameColor);
        painter.fillRect(QRect(rightX, topHeight, width() - rightX, bottomY - topHeight),
                         frameColor);
    }

    if (m_showNameOverlay)
        paintNameOverlay(painter);

    if (m_selected) {
        const int size = resizeHandleSize(this);
        if (size <= 1)
            return;
        QColor fill = s_frameColorSelected;
        fill.setAlphaF(kResizeHandleFillOpacity);
        QPen borderPen(s_frameColorSelected);
        borderPen.setWidth(kResizeHandleBorder);
        painter.setPen(borderPen);
        painter.setBrush(fill);
        painter.drawRect(QRect(0, 0, size, size));
        painter.drawRect(QRect(width() - size, height() - size,
                               size, size));
    }
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
        // Ctrl-drag works like a normal drag outside the resize corners, and
        // constrains a resize to one axis on them. Selection is resolved later
        // (see mouseMoveEvent/mouseReleaseEvent) so that a Ctrl-drag does not
        // unselect.
        const bool ctrl = event->modifiers() & Qt::ControlModifier;
        m_ctrlPress = ctrl;
        m_dragStarted = false;
        if (inResizeHitZoneBR(this, startx, starty)) {
			m_resize = true;
			m_resizeTopLeft = false;
		}
		else if (inResizeHitZoneTL(this, startx, starty)) {
			m_resize = true;
			m_resizeTopLeft = true;
		}
		else {
			m_resize = false;
			m_resizeTopLeft = false;
		}
        m_moving = !m_resize;
        m_lastGlobal = event->globalPosition().toPoint();
        m_resizeStartGlobal = m_lastGlobal;
        m_resizeAxis = ResizeAxis::None;
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
	if (m_ctrlPress && !m_dragStarted && !m_resize) {
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
        const QPoint global = event->globalPosition().toPoint();
        const QPoint total = global - m_resizeStartGlobal;
        // Fix the constrained axis as soon as the drag has a direction. Once
        // chosen it stays fixed for the rest of the gesture, so the resize
        // cannot flip between axes while the mouse jitters.
        if (m_resizeAxis == ResizeAxis::None && (total.x() != 0 || total.y() != 0)) {
            if (total.x() != 0 && total.y() != 0) {
                m_resizeAxis = qAbs(total.x()) >= qAbs(total.y())
                        ? ResizeAxis::Horizontal : ResizeAxis::Vertical;
            } else if (total.x() != 0) {
                m_resizeAxis = ResizeAxis::Horizontal;
            } else {
                m_resizeAxis = ResizeAxis::Vertical;
            }
        }
        QPoint d = global - m_lastGlobal;
        if (event->modifiers() & Qt::ControlModifier) {
            if (m_resizeAxis == ResizeAxis::Horizontal)
                d.setY(0);
            else if (m_resizeAxis == ResizeAxis::Vertical)
                d.setX(0);
        }
        m_lastGlobal = global;
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
	// Cursor zones on top: full size normally, scaled down for very small widgets.
	const int z = resizeZoneSize(this);
	m_resizeHitBR->setGeometry(width()-z, height()-z, z, z);
	m_resizeHitBR->raise();
	m_resizeHitTL->setGeometry(0, 0, z, z);
	m_resizeHitTL->raise();
}
