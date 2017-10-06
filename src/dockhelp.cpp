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

#ifdef USE_QT5
#include <QtWidgets>
#else
#include <QtGui>
#endif

DockHelp::DockHelp(QWidget *parent)
	: QDockWidget(parent), ui(new Ui::DockHelp)
{
	ui->setupUi(this);
	findFlags = 0;
	setWindowTitle("Opcode Help"); // titlebar and overall layout
	setMinimumSize(400,200);

//	connect(ui->toggleFindButton, SIGNAL(released()), this, SLOT(toggleFindBarVisible()));
	connect(ui->backButton, SIGNAL(released()), this, SLOT(browseBack()));
	connect(ui->forwardButton, SIGNAL(released()), this, SLOT(browseForward()));
	connect(ui->opcodesToolButton, SIGNAL(released()), this, SLOT(showOverview()));
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
	connect(ui->text, SIGNAL(anchorClicked(QUrl)), this, SLOT(followLink(QUrl)));
}

DockHelp::~DockHelp()
{
}

bool DockHelp::hasFocus()
{
	return QDockWidget::hasFocus() || ui->text->hasFocus();
}

void DockHelp::loadFile(QString fileName)
{
	QFile file(fileName);
	if (!file.open(QFile::ReadOnly | QFile::Text)) {
		ui->text->setText(tr("Not Found! Make sure the documentation path is set in the Configuration Dialog."));
		return;
	}
#ifdef Q_OS_WIN32
	QStringList searchPaths;
	searchPaths << docDir;
	ui->text->setSearchPaths(searchPaths);
	QTextStream in(&file);
	in.setAutoDetectUnicode(true);
	ui->text->setHtml(in.readAll());
#else
	ui->text->setSource(QUrl::fromLocalFile(fileName));
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
	ui->text->backward();
}

void DockHelp::browseForward()
{
	ui->text->forward();
}

void DockHelp::followLink(QUrl url)
{
	if (url.host() == "") {
		// Will not follow external links for safety, only local files
		if (url.toString().endsWith(".csd")) {
            QString csdFile = url.toLocalFile().isEmpty() ? url.toString() : url.toLocalFile(); // necessary for windows 10
            emit openManualExample(csdFile);
		}
		else {
			if (!url.toString().endsWith("indexframes.html") ) {
				ui->text->setSource(url);
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
	ui->text->copy();
}

void DockHelp::onTextChanged()
{
	QTextCursor tmpCursor = ui->text->textCursor();
	tmpCursor.setPosition(ui->text->textCursor().selectionStart());
	ui->text->setTextCursor(tmpCursor);
	findFlags &= 6; // first bit (FindBackward) to zero
	findText(ui->findLine->text());
}

void DockHelp::onReturnPressed()
{
	findFlags &= 6; // first bit (FindBackward) to zero
	findText(ui->findLine->text());
}

void DockHelp::onNextButtonPressed()
{
	findFlags &= 6; // first bit to zero
	findText(ui->findLine->text());
}

void DockHelp::onPreviousButtonPressed()
{
	findFlags |= QTextDocument::FindBackward;
	findText(ui->findLine->text());
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
	QTextCursor tmpCursor = ui->text->textCursor();
	if (!ui->text->find(expr,findFlags)) { // if not found, try from start
		ui->text->moveCursor(QTextCursor::Start);
		if (!ui->text->find(ui->findLine->text(),findFlags)) {
			ui->text->setTextCursor(tmpCursor); // if not found at all, restore position
		}
	} else {
		int cursorY = ui->text->cursorRect().top();
		QScrollBar *vbar = ui->text->verticalScrollBar();
		vbar->setValue(vbar->value() + cursorY);
	}
}

void DockHelp::resizeEvent(QResizeEvent *e)
{
	QDockWidget::resizeEvent(e);
	ui->backButton->move(frameGeometry().width()/2-25, 0);
	ui->forwardButton->move(frameGeometry().width()/2, 0);
}
