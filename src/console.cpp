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

#include <QDebug>
#include <QtWidgets>


Console::Console(QWidget *parent) : QTextEdit(parent)
{
	error = false;
	errorLine = false;
	setReadOnly(true);
    m_warningColor = QColor("orange");
}

Console::~Console()
{
	disconnect(this, 0,0,0);
}

void Console::appendMessage(QString msg)
{
    QMutexLocker locker(&consoleLock);
	logMessage(msg);

    // Filter unnecessary messages
    if (msg.startsWith("libsndfile-1")
            || msg.startsWith("UnifiedCSD: ")
            || msg.startsWith("orchname: ")
            || msg.startsWith("scorename: ")) {
        return;
	}
	setTextColor(m_textColor);
    // if "unexpected token error", remove this newline, otherwise line number stays
    // in next messageLine
    if ( msg.contains("(token") )
		msg.remove("\n");
	messageLine.append(msg);

    if (messageLine.contains("\n")) {
        // line finished, analyze it now
        if (messageLine.contains("error:", Qt::CaseInsensitive)
                && messageLine.contains("line ")) {
            errorTexts.append(messageLine);
			errorTexts.last().remove("\n");

			QStringList parts = messageLine.split("line "); // get the line number
            QString lnr = parts.last().remove(">>>");
			lnr = lnr.remove(":");
			lnr = lnr.trimmed();
			errorLines.append(lnr.toInt());
			qDebug() << "error line appended --- " << lnr.toInt();
		}
        if (messageLine.contains("Line:", Qt::CaseSensitive))  {
            // as in type erroris in csound6 like  'Line: 54 Loc: 1'
            errorTexts.append("Error");
            QStringList parts = messageLine.split(" ");  // get the line number
            QString lnr = parts[1];                      // 2nd element in the array
            errorLines.append(lnr.toInt());
            qDebug() << "error line appended --- " << lnr.toInt();
        }

        if (messageLine.startsWith("B ")
                || messageLine.contains("rtevent", Qt::CaseInsensitive)
                ||  messageLine.contains("evaluated", Qt::CaseInsensitive)) {
            setTextColor(QColor("#4040FF"));
		}
		if (messageLine.contains("overall samples out of range")
                || messageLine.contains("disabled")
                || messageLine.contains("error", Qt::CaseInsensitive)
                || messageLine.contains("Found:")
                || messageLine.contains("Line:")) { // any error
            qDebug() << "Error found in console" << messageLine;
            setTextColor(QColor("#FF4040"));
		}
		if (messageLine.contains("warning", Qt::CaseInsensitive)) {
            setTextColor(m_warningColor);
		}
		insertPlainText(messageLine);
		setTextColor(m_textColor);
		moveCursor(QTextCursor::End);
		messageLine.clear();
	}
}

void Console::setDefaultFont(QFont font)
{
	document()->setDefaultFont(font);
}

void Console::setColors(QColor textColor, QColor bgColor)
{
    // before it was setPalette, but that does not work runtime.
    auto sheet = QString("QTextEdit { color: %1; background-color: %2 }")
            .arg(textColor.name(), bgColor.name());
    this->setStyleSheet(sheet);
	m_textColor = textColor;
	m_bgColor = bgColor;
    if(m_textColor.lightness() < m_bgColor.lightness()) {
        // dark text on light background
        m_warningColor = QColor("#AC7F00");
    }
    else {
        m_warningColor = QColor("orange");
    }
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

void Console::contextMenuEvent(QContextMenuEvent *event)
{
	QMenu *menu = createStandardContextMenu();
	menu->addAction("Clear", this, SLOT(reset()));
	menu->exec(event->globalPos());
	delete menu;
}

void Console::keyPressEvent(QKeyEvent *event)
{
    if (!event->isAutoRepeat() || m_repeatKeys) {
		QString keyText = event->text();
		if (!keyText.isEmpty()) {
			appendMessage(keyText);
			emit keyPressed(static_cast<int>(keyText[0].toLatin1()));
		} else {
			emit keyPressed(event->key());
		}
	}
}

void Console::keyReleaseEvent(QKeyEvent *event)
{
    if (!event->isAutoRepeat() || m_repeatKeys) {
		QString keyText = event->text();
		if (!keyText.isEmpty()) {
			appendMessage(keyText);
			emit keyReleased(static_cast<int>(keyText[0].toLatin1()));
		} else {
			emit keyReleased(event->key());
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
	qDebug() ;
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
