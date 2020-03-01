/*
	Copyright (C) 2010 Andres Cabrera
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

#ifdef USE_QT5
#include <QtWidgets>
#else
#include <QtGui>
#endif

#include "texteditor.h"


TextEditor::TextEditor(QWidget *parent) :
	QTextEdit(parent)
{
	setAcceptDrops(true);
	setAcceptRichText(false);
	m_parameterMode = false;
	m_commaTyped = false;
	//  qDebug() << "TextEditor::TextEditor" << acceptDrops();
}

void TextEditor::keyPressEvent (QKeyEvent * event)
{
	if (m_commaTyped && event->key() != Qt::Key_Space) {
		m_commaTyped = false;
	}
	switch(event->key()) {
	case Qt::Key_Tab:
		if (m_parameterMode) {
			emit tabPressed();
        } else if(m_tabIndents) {
            // this blocks default behaviour and only tab does not move any further
			emit requestIndent();
        } else {
			QTextEdit::keyPressEvent(event);
		}
		return;
	case Qt::Key_Backtab:
		if (m_parameterMode) {
			emit backtabPressed();
		} else if(m_tabIndents) {
			emit requestUnindent();
		}
		return;
	case Qt::Key_Return:
	case Qt::Key_Enter:
		emit enterPressed();
		break;
	case Qt::Key_Space:
		if (m_commaTyped) {
			emit showParameterInfo();
		}
		m_commaTyped = false;
		break;
	case Qt::Key_Comma:
		m_commaTyped = true;
		break;
	}
	QTextEdit::keyPressEvent(event); // Process key events in the rest of the application
	if (event->key() == Qt::Key_Up || event->key() == Qt::Key_Down
			|| event->key() == Qt::Key_Left || event->key() == Qt::Key_Right) {
		emit arrowPressed();
	}

	if (event->key() == Qt::Key_Escape) {
		emit escapePressed();
	} else if(event->key() == Qt::Key_Return || event->key() == Qt::Key_Enter) {
		emit newLine();
	}
    return;
}

void TextEditor::mouseReleaseEvent(QMouseEvent *e)
{
	QTextEdit::mouseReleaseEvent(e); // and do all the necessary qt job
	if (m_parameterMode) {
		emit requestParameterModeExit();
	}

}

//The following makes the editor almost accept drop events on OS X, but breaks all dragging on the same document on linux
//void TextEditor::dropEvent(QDropEvent *event)
//{
//  qDebug() << "TextEditor::dropEvent" << event->format();
////  QString fileName = QString(event->encodedData("text/uri-list")).remove("file://");
////  event->;
//
//  event->acceptProposedAction();
//}
//
//void TextEditor::dragEnterEvent(QDragEnterEvent *event)
//{
////  qDebug() << "TextEditor::dragEnterEvent" << event->format();
//  // TODO remove file:// text from text
//  event->acceptProposedAction();
//}
//
//void TextEditor::dragMoveEvent(QDragMoveEvent *event)
//{
////  qDebug() << "TextEditor::dragMoveEvent" << event->mimeData()->text();
//  event->acceptProposedAction();
//}

TextEditLineNumbers::TextEditLineNumbers(QWidget *parent)
	: TextEditor(parent)
{
	setLineAreaVisble(false);
	lineNumberArea = new LineNumberArea(this);
	connect(this->document(),SIGNAL(blockCountChanged(int)),this,SLOT(updateLineArea(int)));
	connect(this->verticalScrollBar(),SIGNAL(valueChanged(int)),this,SLOT(updateLineArea(int)));
	connect(this,SIGNAL(cursorPositionChanged()),this,SLOT(updateLineArea()));
    lineNumberArea->setLineNumberSizeScaling(0.8);
}

int TextEditLineNumbers::getAreaWidth()
{
    qreal scaling = lineNumberArea->lineNumberSizeScaling();
    int right_padding = lineNumberArea->padding();
    int left_padding  = lineNumberArea->padding();
    int numDigits = 4;
    int oneDigit = this->fontMetrics().width(QLatin1Char('9'));
    return oneDigit * scaling * numDigits + left_padding + right_padding;
}

void TextEditLineNumbers::resizeEvent(QResizeEvent *e)
{
	QTextEdit::resizeEvent(e);
	if (m_lineAreaVisble) {
		setViewportMargins(getAreaWidth(),0,0,0); // since font might have changed
		QRect cr = contentsRect();
		lineNumberArea->setGeometry(QRect(cr.left(), cr.top(), getAreaWidth(), cr.height()));
	}
}

void TextEditLineNumbers::setLineAreaVisble(bool visible)
{
	m_lineAreaVisble = visible;
	if (m_lineAreaVisble) {
		setViewportMargins(getAreaWidth(),0,0,0);
	}
	else {
		setViewportMargins(0,0,0,0);
	}
}

void TextEditLineNumbers::markDebugLine(int line)
{
	m_debugLines.append(line);
	lineNumberArea->setDebugLines(m_debugLines);
}

void TextEditLineNumbers::unmarkDebugLine(int line)
{
	int index = m_debugLines.indexOf(line);
	if (index >= 0) {
		m_debugLines.remove(index);
	} else {
		qDebug() << "TextEditLineNumbers::unmarkDebugLine no marker at line " << line;
	}
	lineNumberArea->setDebugLines(m_debugLines);
	updateLineArea();
}

void TextEditLineNumbers::setCurrentDebugLine(int line)
{
	lineNumberArea->setCurrentDebugLine(line);
	updateLineArea();
}

void TextEditLineNumbers::updateLineArea(int)
{
	lineNumberArea->update();
}

void TextEditLineNumbers::updateLineArea()
{
	lineNumberArea->update();
}

void LineNumberArea::paintEvent(QPaintEvent *)
{
    if ( !codeEditor->lineAreaVisble() )
		return;
	QPainter painter(this);
	painter.fillRect(rect(), Qt::lightGray);
	//code based partly on: http://john.nachtimwald.com/2009/08/15/qtextedit-with-line-numbers/
	QTextBlock block = codeEditor->document()->begin();
	int contents_y = codeEditor->verticalScrollBar()->value();
	int page_bottom = contents_y + codeEditor->viewport()->height();
	QTextBlock current_block = codeEditor->document()->findBlock(codeEditor->textCursor().position());

	int line_count = 0;
    // painter.setPen(QColor(Qt::darkGray).darker()); // not exactly black
    painter.setPen(QColor(Qt::darkGray)); // not exactly black

    bool bold;
	QFont font = painter.font();
    // font.setPixelSize((int)(font.pixelSize() * 0.8));
    font.setPointSizeF(font.pointSizeF() * m_lineNumberSizeScaling);
    painter.setFont(font);

    while (block.isValid()) {
		line_count += 1;
		QString number = QString::number(line_count);
		QPointF position = codeEditor->document()->documentLayout()->blockBoundingRect(block).topLeft();
		if (position.y() > page_bottom)
			break;
		int y = round(position.y()) - contents_y + codeEditor->fontMetrics().ascent();
		if (y>=0) { // the line is visible
			if (block == current_block) {
				bold = true;
				font.setBold(true);
				painter.setFont(font);
			}
            painter.drawText(codeEditor->getAreaWidth() - codeEditor->fontMetrics().width(number)*m_lineNumberSizeScaling - m_padding, y, number); // 3 - add some padding


			if (bold) {
				font.setBold(false);
				painter.setFont(font);
			}
			if (m_debugLines.indexOf(line_count) >= 0) {
				painter.setPen(QColor(Qt::red));
				painter.setBrush(QColor(Qt::red));
				int height = codeEditor->fontMetrics().ascent() ;
				painter.drawEllipse(position.x(), y - height, height, height);
				painter.setBrush(QBrush());
				painter.setPen(QColor(Qt::darkGray).darker()); // not exactly black
			}
			if (m_currentDebugLine >= 0 && line_count == m_currentDebugLine) {
				QImage image("://themes/boring/gtk-media-play-ltr.png");
				painter.drawImage(position.x(), y, image);
			}
		}
		block = block.next();
	}
}
