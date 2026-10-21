
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


#include <QtWidgets>

#include "texteditor.h"


TextEditor::TextEditor(QWidget *parent) :
	QTextEdit(parent)
{
	setAcceptDrops(true);
	setAcceptRichText(false);
    m_parameterMode = false;
    m_commaTyped = false;
    m_tabUseSpaces = false;
    m_tabSpaces = 2;
    m_lastkey = 0;
    m_pasteHappened = false;
    //  qDebug() << "TextEditor::TextEditor" << acceptDrops();
}

void TextEditor::keyPressEvent (QKeyEvent * event)
{
    m_lastkey = event->key();
	if (m_commaTyped && event->key() != Qt::Key_Space) {
		m_commaTyped = false;
	}
	switch(event->key()) {
	case Qt::Key_Tab:
        if (m_parameterMode) {
            emit tabPressed();
        } else if (textCursor().hasSelection()) {
            // A selection is present: indent all selected lines instead of
            // replacing the selection with a tab or spaces.
			emit requestIndent();
        } else if (m_tabUseSpaces) {
            // Insert spaces instead of a tab character.
            insertPlainText(tabString());
        } else {
            QTextEdit::keyPressEvent(event);
		}
		return;
	case Qt::Key_Backtab:
		if (m_parameterMode) {
			emit backtabPressed();
		} else if (m_tabUseSpaces || textCursor().hasSelection()) {
			// Unindent the current line / selected lines. This also handles
			// the case where Tab inserts spaces rather than a tab character.
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
    } else if (event->key() == Qt::Key_Escape) {
		emit escapePressed();
	} else if(event->key() == Qt::Key_Return || event->key() == Qt::Key_Enter) {
		emit newLine();
    }
    return;
}

QTextCursor TextEditor::cursorAt(const QPoint &pos) const
{
    // cursorForPosition() takes the position in the coordinates of the
    // editor's viewport.
    return cursorForPosition(pos);
}

void TextEditor::mouseReleaseEvent(QMouseEvent *e)
{
    if (e->button() == Qt::MiddleButton
            && QApplication::clipboard()
            && QApplication::clipboard()->supportsSelection()) {
        // X11 middle-click pastes the selection without going through
        // insertFromMimeData(), so flag it here beforehand.
        m_pasteHappened = true;
    }
	QTextEdit::mouseReleaseEvent(e); // and do all the necessary qt job
	if (m_parameterMode) {
		emit requestParameterModeExit();
	}

}

void TextEditor::insertFromMimeData(const QMimeData *source)
{
    // All clipboard pastes (Ctrl+V, context menu, paste() API) and
    // drag-and-drop of text funnel through here.
    m_pasteHappened = true;
    QTextEdit::insertFromMimeData(source);
}

void TextEditor::dragEnterEvent(QDragEnterEvent *event)
{
    if (event->mimeData()->hasUrls())
        event->acceptProposedAction();
    else
        QTextEdit::dragEnterEvent(event);
}

void TextEditor::dragMoveEvent(QDragMoveEvent *event)
{
    if (event->mimeData()->hasUrls())
        event->acceptProposedAction();
    else
        QTextEdit::dragMoveEvent(event);
}

void TextEditor::dropEvent(QDropEvent *event)
{
    if (event->mimeData()->hasUrls()) {
        // Report the drop point (in global coordinates) so the caller can show
        // its menu right there. Do not use QCursor::pos(): it is unreliable
        // during a drag and unusable on Wayland. The text cursor is left
        // alone: path insertion happens at the cursor, not at the drop point.
        setFocus();
        emit fileDropped(event->mimeData()->urls(),
                         viewport()->mapToGlobal(event->position().toPoint()));
        // Never let the source move/delete the file: we only reference it.
        if (event->possibleActions() & Qt::CopyAction)
            event->setDropAction(Qt::CopyAction);
        event->accept();
    } else {
        QTextEdit::dropEvent(event);
    }
}

TextEditLineNumbers::TextEditLineNumbers(QWidget *parent)
    : TextEditor(parent)
{
	lineNumberArea = new LineNumberArea(this);
	paddingArea = new EditorPaddingArea(this);
	setLineAreaVisible(false);
	connect(this->document(),SIGNAL(blockCountChanged(int)),this,SLOT(updateLineArea(int)));
	connect(this->verticalScrollBar(),SIGNAL(valueChanged(int)),this,SLOT(updateLineArea(int)));
	connect(this,SIGNAL(cursorPositionChanged()),this,SLOT(updateLineArea()));
    lineNumberArea->setLineNumberSizeScaling(0.8);
    // Palette-based colours are used at runtime (BaseView::setColors clears the
    // stylesheet), so remove the frame itself instead of relying on CSS.
    setFrameShape(QFrame::NoFrame);
    this->setStyleSheet("QTextEdit { border: none !important; }");

}

int TextEditLineNumbers::getAreaWidth()
{
    qreal scaling = lineNumberArea->lineNumberSizeScaling();
    int right_padding = lineNumberArea->padding();
    int left_padding  = lineNumberArea->padding();
    int numDigits = 4;
    int oneDigit = this->fontMetrics().horizontalAdvance(QLatin1Char('9'));
    return oneDigit * scaling * numDigits + left_padding + right_padding;
}

void TextEditLineNumbers::resizeEvent(QResizeEvent *e)
{
	QTextEdit::resizeEvent(e);
    updateMargins(); // font might have changed, so the gutter width changed

}

void TextEditLineNumbers::setLineAreaVisible(bool visible)
{
	m_lineAreaVisble = visible;
    updateMargins();
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

void TextEditLineNumbers::setLineAreaColors(QColor foreground, QColor background,
                                            int contrast)
{
    lineNumberArea->setColors(foreground, background, contrast);
}

void TextEditLineNumbers::setEditorPadding(int padding)
{
    m_leftPadding = qMax(0, padding);
    updateMargins();
}

void TextEditLineNumbers::setEditorBackground(const QColor &color)
{
    paddingArea->setColor(color);
}

void TextEditLineNumbers::updateMargins()
{
    const QRect cr = contentsRect();
    const int gutterWidth = m_lineAreaVisble ? getAreaWidth() : 0;
    setViewportMargins(gutterWidth + m_leftPadding, 0, 0, 0);
    lineNumberArea->setVisible(m_lineAreaVisble);
    if (m_lineAreaVisble)
        lineNumberArea->setGeometry(cr.left(), cr.top(), gutterWidth, cr.height());
    paddingArea->setGeometry(cr.left() + gutterWidth, cr.top(),
                             m_leftPadding, cr.height());
    paddingArea->setVisible(m_leftPadding > 0);
}

void EditorPaddingArea::paintEvent(QPaintEvent *)
{
    QPainter painter(this);
    painter.fillRect(rect(), m_color);
}

void LineNumberArea::paintEvent(QPaintEvent *)
{
    if ( !codeEditor->lineAreaVisble() )
		return;
	QPainter painter(this);
    painter.fillRect(rect(), m_background);
	//code based partly on: http://john.nachtimwald.com/2009/08/15/qtextedit-with-line-numbers/
	QTextBlock block = codeEditor->document()->begin();
	int contents_y = codeEditor->verticalScrollBar()->value();
	int page_bottom = contents_y + codeEditor->viewport()->height();
	QTextBlock current_block = codeEditor->document()->findBlock(codeEditor->textCursor().position());

	int line_count = 0;
    // Blend the number colour towards the gutter background. 100 keeps the
    // full foreground colour, 0 makes the numbers disappear into the gutter.
    const qreal contrast = qBound(0, m_contrast, 100) / 100.0;
    const QColor numberColor(
                qRound(m_background.red()   + (m_foreground.red()   - m_background.red())   * contrast),
                qRound(m_background.green() + (m_foreground.green() - m_background.green()) * contrast),
                qRound(m_background.blue()  + (m_foreground.blue()  - m_background.blue())  * contrast));
    painter.setPen(numberColor);

    bool bold;
	QFont font = painter.font();
    font.setPointSizeF(font.pointSizeF() * m_lineNumbersSizeFactor);
    painter.setFont(font);
    auto width = codeEditor->getAreaWidth();
    auto metrics = codeEditor->fontMetrics();

    while (block.isValid()) {
		line_count += 1;
		QString number = QString::number(line_count);
		QPointF position = codeEditor->document()->documentLayout()->blockBoundingRect(block).topLeft();
		if (position.y() > page_bottom)
			break;
        int y = round(position.y()) - contents_y + metrics.ascent();
		if (y>=0) { // the line is visible
			if (block == current_block) {
				bold = true;
				font.setBold(true);
				painter.setFont(font);
			}
            int x = width - metrics.horizontalAdvance(number)*m_lineNumbersSizeFactor - m_padding;
            painter.drawText(x, y, number);
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

    // A single-pixel separator between the gutter and the editor. There is no
    // margin between them any more, so this is the only divider.
    QColor separator = m_foreground;
    separator.setAlpha(60);
    painter.setPen(QPen(separator, 1));
    painter.drawLine(this->width() - 1, 0, this->width() - 1, this->height());
}
