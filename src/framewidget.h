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

#ifndef FRAMEWIDGET_H
#define FRAMEWIDGET_H

#include <QFrame>
#include <QWidget>
#include <QColor>

class QuteWidget;

class FrameWidget : public QFrame
{
	Q_OBJECT
public:
	FrameWidget(QWidget* parent);
	~FrameWidget();

	void select();
	void deselect();
	bool isSelected();
    void setSelected(bool status);

	void setWidget(QuteWidget* widget) {m_widget = widget;}
	QuteWidget* getWidget() {return m_widget;}

	// Edit-frame colours, set from Settings/Widgets. Static because the setting
	// is global; every frame reads the current values.
	static QColor frameColorUnselected();
	static QColor frameColorSelected();
	static void setFrameColors(const QColor &unselected, const QColor &selected);
	// Re-apply the stylesheet after the colours changed.
	void refreshFrameAppearance();

protected:
	virtual void contextMenuEvent(QContextMenuEvent *event);
	virtual void mousePressEvent ( QMouseEvent * event );
	virtual void mouseReleaseEvent ( QMouseEvent * event );
	virtual void mouseMoveEvent (QMouseEvent* event);
	virtual void mouseDoubleClickEvent (QMouseEvent * event);
	virtual void resizeEvent (QResizeEvent* event);

private:
	int startx, starty, oldx, oldy;
	// Transparent children that only provide the diagonal resize cursor for the
	// bottom-right and top-left corners. They ignore mouse events, so the frame
	// still receives press/move/release and drives the resize.
	QWidget *m_resizeHitBR;
	QWidget *m_resizeHitTL;
	QFrame *m_resizeHandleBR;
	QFrame *m_resizeHandleTL;
	QuteWidget *m_widget;
	bool m_resize;
	bool m_resizeTopLeft;
	bool m_moving;
	bool m_selecting;
	bool m_selected;
	bool m_changed;
	bool m_ctrlPress;
	bool m_dragStarted;
	QPoint m_lastGlobal;

	// Shift-constrained resize: the axis is fixed for the whole drag to the
	// first coordinate that changed (or the larger one if both changed at once).
	// Ctrl is used because Shift starts a rubber-band selection on press.
	enum class ResizeAxis { None, Horizontal, Vertical };
	QPoint m_resizeStartGlobal;
	ResizeAxis m_resizeAxis = ResizeAxis::None;

signals:
	void popUpMenu(QPoint pos);
	void deselectAllSignal();
	void moved(QPair<int, int>);
	void resized(QPair<int, int>);
	void resizedTopLeft(QPair<int, int>);
	void editWidget();
	void mouseReleased();  // When mouse released, send to set undo history
	void widgetSelected(QuteWidget *widget);
	void widgetUnselected(QuteWidget *widget);
	// Rubber-band selection forwarded to the layout (global screen coords).
	void selectionStarted(QPoint globalPos);
	void selectionMoved(QPoint globalPos);
	void selectionFinished();
	// Alt+click: select the next widget below the cursor.
	void selectThrough(QPoint globalPos);
};

#endif
