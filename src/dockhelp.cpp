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


HelpPage::HelpPage(DockHelp* parent) : QWebEnginePage(parent), dock(parent) {}

bool HelpPage::acceptNavigationRequest(const QUrl &url, NavigationType type, bool isMainFrame) {
    if (type == NavigationTypeLinkClicked) {
        // Check for .csd files (examples)
        if (url.path().endsWith(".csd", Qt::CaseInsensitive)) {
            QString path = url.toLocalFile();
            emit dock->openManualExample(path);
            return false; // Don't navigate in the help panel
        }
        
        // Handle external links
        if (url.scheme() == "http" || url.scheme() == "https") {
            QDesktopServices::openUrl(url);
            return false; 
        }
    }
    return QWebEnginePage::acceptNavigationRequest(url, type, isMainFrame);
}


DockHelp::DockHelp(QWidget *parent)
	: QDockWidget(parent), ui(new Ui::DockHelp)
{
	ui->setupUi(this);
    findCaseSensitive = false;
    findWholeWords = false;
    lastFindText = "";
    setWindowTitle("Help"); // titlebar and overall layout
	setMinimumSize(400,200);

	// Create web engine view and custom page
	webView = new QWebEngineView(this);
	helpPage = new HelpPage(this);
	webView->setPage(helpPage);
	
	// Enable cross-origin loading
	webView->settings()->setAttribute(QWebEngineSettings::LocalContentCanAccessRemoteUrls, true);
	webView->settings()->setAttribute(QWebEngineSettings::LocalContentCanAccessFileUrls, true);

	// Replace the text widget with webView in the UI
	ui->verticalLayout->addWidget(webView);

    ui->backButton->setIcon(QIcon(":/themes/breeze/br_prev.png"));
    ui->forwardButton->setIcon(QIcon(":/themes/breeze/br_next.png"));

    connect(ui->toggleFindButton, SIGNAL(toggled(bool)), this, SLOT(toggleFindBarVisible(bool)));
    connect(ui->backButton, SIGNAL(released()), this, SLOT(browseBack()));
	connect(ui->forwardButton, SIGNAL(released()), this, SLOT(browseForward()));
	connect(ui->homeToolButton, SIGNAL(released()), this, SLOT(showManual()));
	connect(ui->findLine,SIGNAL(returnPressed()),this,SLOT(onReturnPressed()));
	connect(ui->findLine,SIGNAL(textEdited(QString)),this,SLOT(onTextChanged()));
	ui->findPreviousAct->setShortcut(QKeySequence::FindPrevious);
	ui->nextFindAct->setShortcut(QKeySequence::FindNext);
	connect(ui->findPreviousAct,SIGNAL(triggered()),this,SLOT(onPreviousButtonPressed()));
	connect(ui->nextFindAct,SIGNAL(triggered()),this,SLOT(onNextButtonPressed()));
	ui->previousFindButton->setDefaultAction(ui->findPreviousAct);
	ui->nextFindButton->setDefaultAction(ui->nextFindAct);

	connect(ui->caseBox,SIGNAL(stateChanged(int)),this,SLOT(onCaseBoxChanged(int)));
	connect(ui->wholeWordBox,SIGNAL(stateChanged(int)),this,SLOT(onWholeWordBoxChanged(int)));

    ui->toggleFindButton->setChecked(false);
    ui->findLine->setVisible(false);
    ui->caseBox->setVisible(false);
    ui->wholeWordBox->setVisible(false);
    ui->label->setVisible(false);
    ui->nextFindButton->setVisible(false);
    ui->previousFindButton->setVisible(false);
}

DockHelp::~DockHelp()
{
}

bool DockHelp::hasFocus()
{
    return QDockWidget::hasFocus()
           || webView->hasFocus()
           || ui->findLine->hasFocus();
}

void DockHelp::loadFile(QString fileName, QString anchor) {
    if(!QFile::exists(fileName)) {
        webView->setHtml(tr("Not Found! Make sure the documentation path is set in the Configuration Dialog."));
		return;
	}

    QUrl url = QUrl::fromLocalFile(fileName);
    if(!anchor.isEmpty()) {
        url.setUrl(url.toString() + "#" + anchor);
    }
    webView->setUrl(url);
}

void DockHelp::setIconTheme(QString theme)
{
    ui->backButton->setIcon(QIcon(QString(":/themes/%1/browse-prev.png").arg(theme)));
    ui->forwardButton->setIcon(QIcon(QString(":/themes/%1/browse-next.png").arg(theme)));
    ui->homeToolButton->setIcon(QIcon(QString(":/themes/%1/home.png").arg(theme)));
    ui->toggleFindButton->setIcon(QIcon(QString(":/themes/%1/edit-find.png").arg(theme)));
    ui->previousFindButton->setIcon(QIcon(QString(":/themes/%1/browse-prev.png").arg(theme)));
    ui->nextFindButton->setIcon(QIcon(QString(":/themes/%1/browse-next.png").arg(theme)));
}

void DockHelp::changeFontSize(int change)
{
    // Use zoom factor for web engine view
    qreal currentZoom = webView->zoomFactor();
    qreal zoomChange = change * 0.1; // 0.1 zoom per point size change
    webView->setZoomFactor(currentZoom + zoomChange);
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
	this->loadFile(docDir + "/ScoreGenRef.html");
}

void DockHelp::showOverview()
{
	this->setVisible(true);
	this->loadFile(docDir + "/PartOpcodesOverview.html");
}

void DockHelp::showOpcodeQuickRef()
{
	this->setVisible(true);
	this->loadFile(docDir + "/MiscQuickref.html");
}

void DockHelp::browseBack()
{
	webView->back();
}

void DockHelp::browseForward()
{
	webView->forward();
}

void DockHelp::followLink(QUrl url)
{
	// This method is deprecated with QWebEngineView
	// Navigation is now handled by HelpPage::acceptNavigationRequest
	webView->setUrl(url);
}

void DockHelp::copy()
{
	webView->page()->triggerAction(QWebEnginePage::Copy);
}

void DockHelp::onTextChanged()
{
	lastFindText = ui->findLine->text();
	findText(lastFindText, false);
}

void DockHelp::onReturnPressed()
{
	lastFindText = ui->findLine->text();
	findText(lastFindText, false);
}

void DockHelp::onNextButtonPressed()
{
	findText(lastFindText, false);
}

void DockHelp::onPreviousButtonPressed()
{
	findText(lastFindText, true);
}


void DockHelp::onCaseBoxChanged(int value)
{
	findCaseSensitive = (value != 0);
}

void DockHelp::onWholeWordBoxChanged(int value)
{
	findWholeWords = (value != 0);
}

void DockHelp::findText(QString expr, bool backward)
{
	if (expr.isEmpty()) {
		return;
	}
	
	QWebEnginePage::FindFlags flags = QWebEnginePage::FindFlags();
	if (backward) {
		flags |= QWebEnginePage::FindBackward;
	}
	if (findCaseSensitive) {
		flags |= QWebEnginePage::FindCaseSensitively;
	}
	
	webView->findText(expr, flags);
}

void DockHelp::resizeEvent(QResizeEvent *e)
{
	QDockWidget::resizeEvent(e);
    // ui->backButton->move(frameGeometry().width()/2-25, 0);
    // ui->forwardButton->move(frameGeometry().width()/2, 0);
}


void DockHelp::focusText() {
    webView->setFocus();
}

void DockHelp::keyPressEvent(QKeyEvent *event) {
    if(event->key() == Qt::Key_Escape) {
        toggleFindBarVisible(false);
    }
}

void DockHelp::toggleFindBarVisible(bool show) {
    ui->findLine->setVisible(show);
    ui->label->setVisible(show);
    ui->caseBox->setVisible(show);
    ui->wholeWordBox->setVisible(show);
    ui->nextFindButton->setVisible(show);
    ui->previousFindButton->setVisible(show);
    if(show) {
        ui->findLine->setFocus();
    }
}
