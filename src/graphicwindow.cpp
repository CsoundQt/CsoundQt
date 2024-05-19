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

#include "graphicwindow.h"

GraphicWindow::GraphicWindow(QWidget *parent) :
	QWidget(parent)
{
	qDebug("GraphicWindow::GraphicWindow");
	imageLabel = new QLabel;
	imageLabel->setBackgroundRole(QPalette::Base);
	imageLabel->setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
	imageLabel->setScaledContents(true);

	m_toolbar = new QToolBar(this);
	m_toolbar->setFloatable(false);

	scrollArea = new QScrollArea(this);
	scrollArea->setBackgroundRole(QPalette::Dark);
	scrollArea->setWidget(imageLabel);
	//   setCentralWidget(scrollArea);

	QVBoxLayout *m_layout = new QVBoxLayout(this);
	m_layout->addWidget(m_toolbar);
	m_layout->addWidget(scrollArea);
	createActions();
	//   createMenus();

	setWindowTitle(tr("Code Graphic Viewer"));
	//   show()

	resize(800, 600);
	setWindowFlags(Qt::Window);

	//   setWindowModality(Qt::WindowModal);
	//   m_scene = new QGraphicsScene(this);
	//
	//   QGraphicsView view(m_scene, this);
	//   view.show();
}

GraphicWindow::~GraphicWindow()
{
	qDebug("GraphicWindow::~GraphicWindow()");
	//   delete m_scene;
	//   QWidget::destroy();
}

void GraphicWindow::openPng(QString fileName)
{
	qDebug() << "GraphicWindow::openPng" << fileName;
	if (!fileName.isEmpty()) {
		QImage image(fileName);
		if (image.isNull()) {
			QMessageBox::information(this, tr("Image Viewer"),
									 tr("Cannot load %1.").arg(fileName));
			return;
		}
		imageLabel->setPixmap(QPixmap::fromImage(image));
		scaleFactor = 1.0;

		printAct->setEnabled(true);
		saveAct->setEnabled(true);
		fitToWindowAct->setEnabled(true);
		updateActions();

		if (!fitToWindowAct->isChecked())
			imageLabel->adjustSize();
	}
	//   fitToWindowAct->setChecked(true);
	//   fitToWindow();
}

void GraphicWindow::save()
{
	QString fileName = QFileDialog::getSaveFileName(this,
													tr("Save Image"), QString(), tr("Image Files (*.png *.jpg *.bmp)"));
	if (fileName != "")
        imageLabel->pixmap().save(fileName);
}

void GraphicWindow::print()
{
	QPrintDialog dialog(&printer, this);
	if (dialog.exec()) {
		QPainter painter(&printer);
		QRect rect = painter.viewport();
        QSize size = imageLabel->pixmap().size();
		size.scale(rect.size(), Qt::KeepAspectRatio);
		painter.setViewport(rect.x(), rect.y(), size.width(), size.height());
        painter.setWindow(imageLabel->pixmap().rect());
        painter.drawPixmap(0, 0, imageLabel->pixmap());
	}
}

void GraphicWindow::zoomIn()
{
	scaleImage(1.25);
}

void GraphicWindow::zoomOut()
{
	scaleImage(0.8);
}

void GraphicWindow::normalSize()
{
	imageLabel->adjustSize();
	scaleFactor = 1.0;
}

void GraphicWindow::fitToWindow()
{
	bool fitToWindow = fitToWindowAct->isChecked();
	scrollArea->setWidgetResizable(fitToWindow);
	if (!fitToWindow) {
		normalSize();
	}
	updateActions();
}

void GraphicWindow::scaleImage(double factor)
{
	scaleFactor *= factor;
    imageLabel->resize(scaleFactor * imageLabel->pixmap().size());

	adjustScrollBar(scrollArea->horizontalScrollBar(), factor);
	adjustScrollBar(scrollArea->verticalScrollBar(), factor);

	zoomInAct->setEnabled(scaleFactor < 3.0);
	zoomOutAct->setEnabled(scaleFactor > 0.333);
}

void GraphicWindow::adjustScrollBar(QScrollBar *scrollBar, double factor)
{
	scrollBar->setValue(int(factor * scrollBar->value()
							+ ((factor - 1) * scrollBar->pageStep()/2)));
}

void GraphicWindow::createActions()
{
	//   openAct = new QAction(tr("&Open..."), this);
	//   openAct->setShortcut(tr("Ctrl+O"));
	//   connect(openAct, SIGNAL(triggered()), this, SLOT(open()));
	saveAct = new QAction(tr("Save"), this);
	saveAct->setShortcut(tr("Ctrl+S"));
	saveAct->setEnabled(false);
	connect(saveAct, SIGNAL(triggered()), this, SLOT(save()));
	m_toolbar->addAction(saveAct);

	printAct = new QAction(tr("&Print..."), this);
	printAct->setShortcut(tr("Ctrl+P"));
	printAct->setEnabled(false);
	connect(printAct, SIGNAL(triggered()), this, SLOT(print()));
	m_toolbar->addAction(printAct);

	exitAct = new QAction(tr("E&xit"), this);
	exitAct->setShortcut(tr("Ctrl+Q"));
	connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

	zoomInAct = new QAction(tr("Zoom &In (25%)"), this);
	zoomInAct->setShortcut(tr("Ctrl++"));
	zoomInAct->setEnabled(false);
	connect(zoomInAct, SIGNAL(triggered()), this, SLOT(zoomIn()));
	m_toolbar->addAction(zoomInAct);

	zoomOutAct = new QAction(tr("Zoom &Out (25%)"), this);
	zoomOutAct->setShortcut(tr("Ctrl+-"));
	zoomOutAct->setEnabled(false);
	connect(zoomOutAct, SIGNAL(triggered()), this, SLOT(zoomOut()));
	m_toolbar->addAction(zoomOutAct);

	normalSizeAct = new QAction(tr("&Normal Size"), this);
	normalSizeAct->setShortcut(tr("Ctrl+S"));
	normalSizeAct->setEnabled(false);
	connect(normalSizeAct, SIGNAL(triggered()), this, SLOT(normalSize()));
	m_toolbar->addAction(normalSizeAct);

	fitToWindowAct = new QAction(tr("&Fit to Window"), this);
	fitToWindowAct->setEnabled(false);
	fitToWindowAct->setCheckable(true);
	fitToWindowAct->setShortcut(tr("Ctrl+F"));
	connect(fitToWindowAct, SIGNAL(triggered()), this, SLOT(fitToWindow()));
	m_toolbar->addAction(fitToWindowAct);

	//   aboutAct = new QAction(tr("&About"), this);
	//   connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));
	//
	//   aboutQtAct = new QAction(tr("About &Qt"), this);
	//   connect(aboutQtAct, SIGNAL(triggered()), qApp, SLOT(aboutQt()));
}

// void GraphicWindow::createMenus()
// {
//   fileMenu = new QMenu(tr("&File"), this);
//   fileMenu->addAction(openAct);
//   fileMenu->addAction(printAct);
//   fileMenu->addSeparator();
//   fileMenu->addAction(exitAct);
//
//   viewMenu = new QMenu(tr("&View"), this);
//   viewMenu->addAction(zoomInAct);
//   viewMenu->addAction(zoomOutAct);
//   viewMenu->addAction(normalSizeAct);
//   viewMenu->addSeparator();
//   viewMenu->addAction(fitToWindowAct);
//
//   helpMenu = new QMenu(tr("&Help"), this);
//   helpMenu->addAction(aboutAct);
//   helpMenu->addAction(aboutQtAct);

//   menuBar()->addMenu(fileMenu);
//   menuBar()->addMenu(viewMenu);
//   menuBar()->addMenu(helpMenu);
// }

void GraphicWindow::updateActions()
{
	zoomInAct->setEnabled(!fitToWindowAct->isChecked());
	zoomOutAct->setEnabled(!fitToWindowAct->isChecked());
	normalSizeAct->setEnabled(!fitToWindowAct->isChecked());
}

// void GraphicWindow::closeEvent (QCloseEvent * event)
// {
//   qDebug("GraphicWindow::closeEvent");
// //   destroy();
// }
