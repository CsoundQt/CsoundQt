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

#ifndef TEXTEDITOR_H
#define TEXTEDITOR_H

#include <QTextEdit>
#include <QAction>

class TextEditor : public QTextEdit
{
	Q_OBJECT
public:
	TextEditor(QWidget *parent = 0);

	void setTabIndents(bool indents) {m_tabIndents = indents;}
	void setParameterMode(bool on) {m_parameterMode = on; setCursorWidth(on ? 8 : 1);}
	bool getParameterMode() {return m_parameterMode;}

protected:
	virtual void keyPressEvent (QKeyEvent * event);
    virtual void mouseReleaseEvent(QMouseEvent * e);
	//    virtual void dropEvent(QDropEvent *event);  // See note on code
	//    virtual void dragEnterEvent(QDragEnterEvent *event);
	//    virtual void dragMoveEvent(QDragMoveEvent *event);

	bool m_tabIndents;
	bool m_parameterMode;
	bool m_commaTyped;

signals:
	void showParameterInfo();
	void escapePressed();
	void enterPressed();
	void arrowPressed();
	void tabPressed();
	void backtabPressed();
	void newLine();
	void requestIndent();
	void requestUnindent();
	void requestParameterModeExit();
    void mouseReleased();
};

class LineNumberArea;

class TextEditLineNumbers : public TextEditor
{
	Q_OBJECT
public:
	TextEditLineNumbers(QWidget *parent = 0);
	int getAreaWidth();
	void setLineAreaVisible(bool visible);
    bool lineAreaVisble() {return m_lineAreaVisble;}
	QAction *toggleAction;
    void setLineAreaColors(QColor foreground, QColor background);

public slots:
	void markDebugLine(int line);
	void unmarkDebugLine(int line);
	void setCurrentDebugLine(int line);

protected:
	void resizeEvent(QResizeEvent *e);

private:
	LineNumberArea *lineNumberArea;
	bool m_lineAreaVisble;
	QVector<int> m_debugLines;

private slots:
	void updateLineArea(int);
	void updateLineArea();
};

class LineNumberArea : public QWidget
{
	Q_OBJECT

public:
	LineNumberArea(TextEditLineNumbers *editor) : QWidget(editor) {
		codeEditor = editor;
		m_currentDebugLine = -1;
        m_lineNumbersSizeFactor = 1;
        m_padding = 8;
        m_background = QColor("#A0A0A0");
        m_foreground = QColor("#303030");

	}
	void setDebugLines(QVector<int> debugLines) {m_debugLines = debugLines;}
	void setCurrentDebugLine(int line) {m_currentDebugLine = line;}
    void setLineNumberSizeScaling(qreal factor) {m_lineNumbersSizeFactor = factor;}
    qreal lineNumberSizeScaling() { return m_lineNumbersSizeFactor; }
    int padding() { return m_padding; }
    void setColors(QColor foreground, QColor background) {
        m_foreground = foreground;
        m_background = background;
    }

protected:
	void paintEvent(QPaintEvent *event);

private:
	QVector<int> m_debugLines;
	int m_currentDebugLine;
    int m_padding;
    double m_lineNumbersSizeFactor;
    QColor m_background;
    QColor m_foreground;
    TextEditLineNumbers *codeEditor;
};

#endif // TEXTEDITOR_H
