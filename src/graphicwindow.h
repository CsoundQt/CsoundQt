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

#ifndef GRAPHICWINDOW_H
#define GRAPHICWINDOW_H

#include <QtGui>

class GraphicWindow : public QWidget
{
	Q_OBJECT
public:
	GraphicWindow(QWidget *parent);

	~GraphicWindow();

	void openPng(QString fileName);

private slots:
	void zoomIn();
	void zoomOut();
	void normalSize();
	void fitToWindow();
	void save();
	void print();

protected:
	//     virtual void closeEvent (QCloseEvent * event);

private:
	//     QGraphicsScene *m_scene;
	void createActions();
	//     void createMenus();
	void updateActions();
	void scaleImage(double factor);
	void adjustScrollBar(QScrollBar *scrollBar, double factor);

	QLabel *imageLabel;
	QScrollArea *scrollArea;
	double scaleFactor;

	QPrinter printer;

	QToolBar *m_toolbar;
	//     QAction *openAct;
	QAction *saveAct;
	QAction *printAct;
	QAction *exitAct;
	QAction *zoomInAct;
	QAction *zoomOutAct;
	QAction *normalSizeAct;
	QAction *fitToWindowAct;
	//     QAction *aboutAct;
	//     QAction *aboutQtAct;

	QMenu *fileMenu;
	QMenu *viewMenu;
	QMenu *helpMenu;
};

#endif
