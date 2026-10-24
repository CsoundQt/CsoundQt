
/***************************************************************************
 *   Copyright (C) 2010 by Andres Cabrera                                  *
 *   mantaraya36@gmail.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/

#ifndef BASEVIEW_H
#define BASEVIEW_H

#include <QtWidgets>

#include "highlighter.h"

class TextEditor;
class TextEditLineNumbers;
class OpEntryParser;

typedef enum {
	EDIT_CSOUND_MODE = 0,
	EDIT_ORC_MODE = 3,
	EDIT_SCO_MODE = 4,
	EDIT_INC_MODE = 5,
	EDIT_HTML_MODE = 6,
	EDIT_GENERIC_MODE = -1
} editor_mode_t;

class BaseView : public QScrollArea
{
	friend class CsoundQt; // FIXME now that it's a friend class some things can be simplified in the code
	Q_OBJECT
public:
	explicit BaseView(QWidget *parent, OpEntryParser *opcodeTree);
	~BaseView();

	void setFullText(QString text, bool goToTop = false);
	void setBasicText(QString text);
	void setFileType(editor_mode_t mode); // For higlighting mode
	void setFont(QFont font);
	void setFontPointSize(float size);
	void setTabSize(int tabSize);
	void setTabUseSpaces(bool useSpaces);
	void setTabSpaces(int spaces);
	void setLineWrapMode(QTextEdit::LineWrapMode mode);
	void setAutoComplete(bool autoComplete);
	void setColorVariables(bool color);
	void setBackgroundColor(QColor color);
    void setTextColor(QColor color);
    void setColors(QColor text, QColor background);
    //    void setOpcodeNameList(QStringList list);
	//    void setOpcodeTree(OpEntryParser *opcodeTree);
	void setOrc(QString text);
	void setSco(QString text);
	// Drag & drop helpers: insert a file path at the cursor, global orchestra
	// code (before the first instr/opcode), or at the top of the score.
	void insertPathAtCursor(const QString &path);
	void insertOrchestraGlobal(QString text);
	void insertAtScoreStart(QString text);
	void clearFileBText();
	void appendFileBText(QString text);
	void setOptionsText(QString text);
	void showLineArea(bool visible);
	// 0 makes the numbers vanish into the gutter, 100 uses the full editor
	// foreground colour.
	void setLineNumberContrast(int contrast);
	void setEditorPadding(int padding);
	void updateLineAreaColors();
    virtual void setTheme(const QString &theme) {
        m_highlighter.setTheme(theme);
        updateLineAreaColors();
    }
    void enableScoreSyntaxHighlighting(bool state) {
        m_highlighter.enableScoreSyntaxHighlighting(state);
    }

    QTextCharFormat getDefaultFormat() {
        return m_highlighter.getFormat("default");
    }

    QTextCharFormat getHighlighterFormat(QString format) {
        return m_highlighter.getFormat(format);
    }

	QString getFullText();
	QString getOrc();  // Without tags
	QString getSco();  // Without tags
	QString getOptionsText();  // Without tags
	QString getFileB(); // Embedded files. With tags (for filenames)

	void clearUndoRedoStack();

	QString getBasicText();  // What Csound needs (no widgets, misc text, etc.)

signals:
    void fileDropped(QList<QUrl> urls, QPoint globalPos);

public slots:
	void toggleLineArea();
	void toggleParameterMode();

protected:
	editor_mode_t m_mode; //type of text: csound, orc, sco
	Highlighter m_highlighter;
	int m_lineNumberContrast = 50;
	OpEntryParser *m_opcodeTree;
	TextEditLineNumbers *m_mainEditor;
	// Embedded files are kept out of the editable text (and therefore out of
	// the scanner and the Csound code). getFullText() puts them back.
	QString m_filebText;

	int m_tabSize = 2; // tab size in spaces, see setTabSize()
	void applyTabSize();
};

#endif // BASEVIEW_H
