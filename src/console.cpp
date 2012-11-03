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

#include "console.h"

Console::Console(QWidget *parent) : QTextEdit(parent)
{
	error = false;
	errorLine = false;
	setReadOnly(true);
}

Console::~Console()
{
	disconnect(this, 0,0,0);
}

void Console::appendMessage(QString msg)
{
	//  consoleLock.lock();
	logMessage(msg);
	// Filter unnecessary messages
	if (msg.startsWith("libsndfile-1") || msg.startsWith("UnifiedCSD: ")
			|| msg.startsWith("orchname: ") || msg.startsWith("scorename: ")
			|| msg.startsWith("PortMIDI real time MIDI plugin for Csound")
			|| msg.startsWith("PortAudio real-time audio module for Csound")
			|| msg.startsWith("virtual_keyboard real time MIDI plugin for Csound")
			|| msg.startsWith("Removing temporary file")
			//          || msg.startsWith("Csound version")
			|| msg.startsWith("STARTING")
			|| msg.startsWith("Creating")
			|| msg.startsWith("Parsing")
			//          || msg.startsWith("0dBFS")
			|| msg.startsWith("add a global")
			|| msg.startsWith("rtaudio:")
			) {
		// This filtering should ideally happen inside Csound!
		//    consoleLock.unlock();
		return;
	}
	setTextColor(m_textColor);
	if ( msg.contains("(token") ) // if "unexpected token error", remove this newline, otherwise line number stays in next messageLine
		msg.remove("\n");
	messageLine.append(msg);

	if (messageLine.contains("\n")) { // line finished, analyze it now
		// qDebug() << "Messageline: " << messageLine;
		if (messageLine.contains("error:", Qt::CaseInsensitive) && messageLine.contains("line ")) { // kas vahel ka nii, et rea numbrit pole?
			errorTexts.append(messageLine); // .remove("\n")
			errorTexts.last().remove("\n");

			QStringList parts = messageLine.split("line "); // get the line number
			QString lnr = parts.last().remove(">>>"); // somehow all the .removes in one line did not always work correctly
			lnr = lnr.remove(":");
			lnr = lnr.trimmed();
			errorLines.append(lnr.toInt());
			qDebug() << "error line appended --- " << lnr.toInt();

		}
		if (messageLine.startsWith("B ") or messageLine.contains("rtevent", Qt::CaseInsensitive)) {
			setTextColor(QColor("blue"));
		}
		if (messageLine.contains("overall samples out of range")
				or messageLine.contains("disabled")
				or messageLine.contains("error", Qt::CaseInsensitive)) { // any error
			setTextColor(QColor("red"));
		}
		if (messageLine.contains("warning", Qt::CaseInsensitive)) {
			setTextColor(QColor("orange"));
		}

		insertPlainText(messageLine);
		setTextColor(m_textColor);
		moveCursor(QTextCursor::End);
		messageLine.clear();

	}
	//  consoleLock.unlock();
}

void Console::setDefaultFont(QFont font)
{
	document()->setDefaultFont(font);
}

void Console::setColors(QColor textColor, QColor bgColor)
{
	setTextColor(textColor);
	//       text->setTextBackgroundColor(bgColor);
	QPalette p = palette();
	p.setColor(QPalette::WindowText, textColor);
	p.setColor(static_cast<QPalette::ColorRole>(9), bgColor);
	setPalette(p);
	setAutoFillBackground(true);
	m_textColor = textColor;
	m_bgColor = bgColor;
}

void Console::reset()
{
	clear();
	errorLines.clear();
	errorTexts.clear();
	error = false;
}

void Console::scrollToEnd()
{
	moveCursor(QTextCursor::End);
}

void Console::setKeyRepeatMode(bool repeat)
{
	m_repeatKeys = repeat;
}

// void Console::refresh()
// {
//   // This is a necessary hack since QTextEdit appears to not refresh correctly
//   // Not working...
//   //text->repaint(QRect(0,0, text->width(), text->height()));
// }

void Console::contextMenuEvent(QContextMenuEvent *event)
{
	QMenu *menu = createStandardContextMenu();
	menu->addAction("Clear", this, SLOT(reset()));
	menu->exec(event->globalPos());
	delete menu;
}

void Console::keyPressEvent(QKeyEvent *event)
{
	if (!event->isAutoRepeat() or m_repeatKeys) {
		QString key = event->text();
		if (key != "") {
			appendMessage(key);
			emit keyPressed(key);
		}
	}
}

void Console::keyReleaseEvent(QKeyEvent *event)
{
	if (!event->isAutoRepeat() or m_repeatKeys) {
		QString key = event->text();
		if (key != "") {
			//           appendMessage("rel:" + key);
			emit keyReleased(key);
		}
	}
}

// ---------------------------------------------------------------

DockConsole::DockConsole(QWidget * parent): QDockWidget(parent)
{
	setWindowTitle(tr("Output Console"));
	//  text = new Console(parent);
	//  text->setReadOnly(true);
	//  text->setContextMenuPolicy(Qt::NoContextMenu);
	//  text->document()->setDefaultFont(QFont("Courier", 10));
	//  setWidget(text);
	//      QStackedLayout *l = new QStackedLayout(this);
	//      l->addWidget(text);
	//      setLayout(l);
}

DockConsole::~DockConsole()
{;}

void DockConsole::copy()
{
	qDebug() << "DockConsole::copy()";
	static_cast<Console *>(widget())->copy();
}

bool DockConsole::widgetHasFocus()
{
	return widget()->hasFocus();
}

void DockConsole::appendMessage(QString msg)
{
	static_cast<Console *>(widget())->appendMessage(msg);
	//  static_cast<Console *>(widget())->scrollToEnd();
}


void DockConsole::closeEvent(QCloseEvent * /*event*/)
{
	emit Close(false);
}

// ---------------------------------------------------------------

void ConsoleWidget::setWidgetGeometry(int /*x*/,int /*y*/,int width,int height)
{
	setGeometry(QRect(0,0,width, height));
}
