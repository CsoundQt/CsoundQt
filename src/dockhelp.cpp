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

#include "dockhelp.h"
#include "ui_dockhelp.h"

#include <QtWidgets>
#include <QMainWindow>
#include <QStatusBar>
#include <QFile>


DockHelp::DockHelp(QWidget *parent)
	: QDockWidget(parent), ui(new Ui::DockHelp)
{
	ui->setupUi(this);
    setWindowTitle("Help"); // titlebar and overall layout
	setMinimumSize(400,200);

	// LiteHtml viewer replaces the previous QtWebEngine view.
	m_view = new LiteHtmlView(this);
	ui->verticalLayout->addWidget(m_view);

    ui->backButton->setIcon(QIcon(":/themes/breeze/br_prev.png"));
    ui->forwardButton->setIcon(QIcon(":/themes/breeze/br_next.png"));

    connect(ui->toggleFindButton, SIGNAL(toggled(bool)), this, SLOT(toggleFindBarVisible(bool)));
    connect(ui->backButton, SIGNAL(released()), this, SLOT(browseBack()));
	connect(ui->forwardButton, SIGNAL(released()), this, SLOT(browseForward()));
	connect(ui->homeToolButton, SIGNAL(released()), this, SLOT(showManual()));
	connect(ui->searchToolButton, &QToolButton::clicked, m_view, &LiteHtmlView::showSearchPanel);

	ui->findPreviousAct->setShortcut(QKeySequence::FindPrevious);
	ui->nextFindAct->setShortcut(QKeySequence::FindNext);
	connect(ui->findPreviousAct, &QAction::triggered, m_view, &LiteHtmlView::findPrevious);
	connect(ui->nextFindAct, &QAction::triggered, m_view, &LiteHtmlView::findNext);

    ui->toggleFindButton->setChecked(false);

	// Forward viewer signals to the host app.
	connect(m_view, &LiteHtmlView::externalLinkRequested, this, &DockHelp::requestExternalBrowser);
	connect(m_view, &LiteHtmlView::exampleFileRequested, this, &DockHelp::openManualExample);
	connect(m_view, &LiteHtmlView::statusMessage, this, [this](const QString &msg) {
		if (auto *mw = qobject_cast<QMainWindow *>(window()))
			mw->statusBar()->showMessage(msg, 5000);
	});
	connect(m_view, &LiteHtmlView::escapePressed, this, [this] { toggleFindBarVisible(false); });
}

DockHelp::~DockHelp()
{
	delete ui;
}

bool DockHelp::hasFocus()
{
    return QDockWidget::hasFocus()
           || m_view->hasFocus();
}

void DockHelp::loadFile(QString fileName, QString anchor) {
    m_view->loadFile(fileName, anchor);
}

void DockHelp::setIconTheme(QString theme)
{
    ui->backButton->setIcon(QIcon(QString(":/themes/%1/browse-prev.png").arg(theme)));
    ui->forwardButton->setIcon(QIcon(QString(":/themes/%1/browse-next.png").arg(theme)));
    ui->homeToolButton->setIcon(QIcon(QString(":/themes/%1/home.png").arg(theme)));
    ui->toggleFindButton->setIcon(QIcon(QString(":/themes/%1/edit-find.png").arg(theme)));
}

void DockHelp::changeFontSize(int change)
{
    m_view->setZoomFactor(m_view->zoomFactor() + change * 0.1);
}

void DockHelp::addSearchRoot(const QString &rootPath, const QString &label)
{
    m_view->addSearchRoot(rootPath, label);
}

void DockHelp::closeEvent(QCloseEvent * /*event*/)
{
	emit Close(false);
}

void DockHelp::showManual()
{
	this->setVisible(true);
	this->loadFile(docDir + "/index.html");
}


void DockHelp::showGen()
{
	this->setVisible(true);
	this->loadFile(docDir + "/reference/genRoutinesRef.html");
}

void DockHelp::showOverview()
{
	this->setVisible(true);
	this->loadFile(docDir + "/opcodesQuickRef.html");
}

void DockHelp::showOpcodeQuickRef()
{
	this->setVisible(true);
	this->loadFile(docDir + "/opcodesQuickRef.html");
}

void DockHelp::browseBack()
{
	m_view->back();
}

void DockHelp::browseForward()
{
	m_view->forward();
}

void DockHelp::followLink(QUrl url)
{
	m_view->loadFile(url.toLocalFile());
}

void DockHelp::copy()
{
	m_view->copySelection();
}

void DockHelp::resizeEvent(QResizeEvent *e)
{
	QDockWidget::resizeEvent(e);
}


void DockHelp::focusText() {
    m_view->setFocus();
}

void DockHelp::keyPressEvent(QKeyEvent *event) {
    if(event->key() == Qt::Key_Escape) {
        toggleFindBarVisible(false);
    }
}

void DockHelp::toggleFindBarVisible(bool show) {
    ui->toggleFindButton->blockSignals(true);
    ui->toggleFindButton->setChecked(show);
    ui->toggleFindButton->blockSignals(false);
    if(show) {
        m_view->showFindBar();
    } else {
        m_view->clearFind();
    }
}
