/*
	Copyright (C) 2008, 2009 Andres Cabrera
	mantaraya36@gmail.com

	This file is part of QuteCsound.

	QuteCsound is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	QuteCsound is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#include "dockhelp.h"
#include <QtGui>

DockHelp::DockHelp(QWidget *parent)
	: QDockWidget(parent)
{
	findFlags = 0;
	setWindowTitle("Opcode Help"); // titlebar and overall layout
	setMinimumSize(400,200);
	QPushButton* toggleFindButton = new QPushButton(QIcon(":/images/gtk-search.png"), "", this);
	toggleFindButton->resize(25,25);
	toggleFindButton->move(fontMetrics().width("Opcode help")+10 ,0);
	toggleFindButton->setFlat(true);
	connect(toggleFindButton, SIGNAL(released()), this, SLOT(toggleFindBarVisible()));
	backButton = new QPushButton(QIcon(":/images/br_prev.png"), "", this);
	backButton->move(frameGeometry().width()/2-25, 0);
	backButton->resize(25, 25);
	backButton->setFlat(true); // no border
	connect(backButton, SIGNAL(released()), this, SLOT(browseBack()));
	forwardButton = new QPushButton(QIcon(":/images/br_next.png"), "", this);
	forwardButton->move(this->width()/2, 0);
	forwardButton->resize(25, 25);
	forwardButton->setFlat(true);
	connect(forwardButton, SIGNAL(released()), this, SLOT(browseForward()));
	setContentsMargins(3,3,3,3);
	QGroupBox *helpBox = new QGroupBox;
	QVBoxLayout *helpLayout = new QVBoxLayout;
	helpLayout->setContentsMargins(3,3,3,3);
	helpBox->setLayout(helpLayout);

	findBar = new QToolBar("findBar");   // search bar, hidden by default
	findBar->setIconSize(QSize(10,10));
	QLabel *findLabel = new QLabel(tr("Find:"));
	findBar->addWidget(findLabel);
	findLine = new QLineEdit();
	//findLine->setMaximumWidth(120);
	connect(findLine,SIGNAL(returnPressed()),this,SLOT(onReturnPressed()));
	findBar->addWidget(findLine);
	QAction *previousAction = findBar->addAction(QIcon(":/images/br_prev.png"), "Previous");
	previousAction->setShortcut(QKeySequence::FindPrevious);
	QAction *nextAction = findBar->addAction(QIcon(":/images/br_next.png"), "Next");
	nextAction->setShortcut(QKeySequence::FindNext);
	connect(previousAction,SIGNAL(triggered()),this,SLOT(onPreviousButtonPressed()));
	connect(nextAction,SIGNAL(triggered()),this,SLOT(onNextButtonPressed()));
	QCheckBox *caseBox = new QCheckBox("&Match case");
	connect(caseBox,SIGNAL(stateChanged(int)),this,SLOT(onCaseBoxChanged(int)));
	findBar->addWidget(caseBox);
	QCheckBox *wholeWordBox = new QCheckBox("&Whole words");
	connect(wholeWordBox,SIGNAL(stateChanged(int)),this,SLOT(onWholeWordBoxChanged(int)));
	findBar->addWidget(wholeWordBox);
	findBar->setVisible(false);
	helpLayout->addWidget(findBar);

	text = new QTextBrowser();  // text area
	text->setAcceptRichText(true);
	text->setOpenLinks(false);
	connect(text, SIGNAL(anchorClicked(QUrl)), this, SLOT(followLink(QUrl)));
	helpLayout->addWidget(text);
	setWidget(helpBox);
}

DockHelp::~DockHelp()
{
}

bool DockHelp::hasFocus()
{
	return QDockWidget::hasFocus() || text->hasFocus();
}

void DockHelp::loadFile(QString fileName)
{
	QFile file(fileName);
	if (!file.open(QFile::ReadOnly | QFile::Text)) {
		//     QMessageBox::warning(this, tr("CsoundQt"),
		//                          tr("Cannot read file %1:\n%2.")
		//                              .arg(fileName)
		//                              .arg(file.errorString()));
		text->setText(tr("Not Found! Make sure the documentation path is set in the Configuration Dialog."));
		return;
	}
#ifdef Q_OS_WIN32
	QStringList searchPaths;
	searchPaths << docDir;
	text->setSearchPaths(searchPaths);
	QTextStream in(&file);
	in.setAutoDetectUnicode(true);
	text->setHtml(in.readAll());
#else
	text->setSource(QUrl::fromLocalFile(fileName));
#endif

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
	text->backward();
}

void DockHelp::browseForward()
{
	text->forward();
}

void DockHelp::followLink(QUrl url)
{
	if (url.host() == "") {
		// Will not follow external links for safety, only local files
		if (url.toString().endsWith(".csd")) {
			emit openManualExample(url.toLocalFile());
		}
		else {
			if (!url.toString().endsWith("indexframes.html") ) {
				text->setSource(url);
			}
			else { // Don't do anything with frames version...
				// This could be fixed using the WebKit rendering engine
				QMessageBox::warning(this, tr("CsoundQt"),
									 tr("Frames version only available in external browser."));
			}
		}
	}
	else {
		QMessageBox::warning(this, tr("CsoundQt"),
							 tr("External links can't be followed in help browser."));
	}
}

void DockHelp::copy()
{
	text->copy();
}

void DockHelp::onReturnPressed()
{
	findFlags &= 6; // first bit (FindBackward) to zero
	findText(findLine->text());
}

void DockHelp::onNextButtonPressed()
{
	findFlags &= 6; // first bit to zero
	findText(findLine->text());
}

void DockHelp::onPreviousButtonPressed()
{
	findFlags |= QTextDocument::FindBackward;
	findText(findLine->text());
}

void DockHelp::toggleFindBarVisible()
{
	findBar->setVisible(!findBar->isVisible());
}

void DockHelp::onCaseBoxChanged(int value)
{
	if (value)
		findFlags |=  QTextDocument::FindCaseSensitively;
	else
		findFlags &= 5; // set 2 bit to 0
}

void DockHelp::onWholeWordBoxChanged(int value)
{
	if (value)
		findFlags |=  QTextDocument::FindWholeWords;
	else
		findFlags &= 3; // set 3rd bit to 0
}

void DockHelp::findText(QString expr)
{
	QTextCursor tmpCursor = text->textCursor();
	if (!text->find(expr,findFlags)) { // if not found, try from start
		text->moveCursor(QTextCursor::Start);
		if (!text->find(findLine->text(),findFlags)) {
			text->setTextCursor(tmpCursor); // if not found at all, restore position
		}
	}
}

void DockHelp::resizeEvent(QResizeEvent *e)
{
	QDockWidget::resizeEvent(e);
	backButton->move(frameGeometry().width()/2-25, 0);
	forwardButton->move(frameGeometry().width()/2, 0);
}
