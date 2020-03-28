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

#ifdef USE_QT5
#include <QtWidgets>
#else
#include <QtGui>
#endif

#include "highlighter.h"
#include "scoreeditor.h"
#include "filebeditor.h"

class TextEditor;
class OpEntryParser;

typedef enum {
	EDIT_CSOUND_MODE = 0,
	EDIT_PYTHON_MODE = 1,
	EDIT_XML_MODE = 2,
	EDIT_ORC_MODE = 3,
	EDIT_SCO_MODE = 4,
	EDIT_INC_MODE = 5,
	EDIT_HTML_MODE = 6,
	EDIT_GENERIC_MODE = -1
} editor_mode_t;

class AppProperties {
public:
	bool used; // Flag to mark if properties are used
	QString appName;
	QString targetDir;
	QString author;
	QString version;
	QString date;
	QString email;
	QString website;
	QString instructions;

	bool autorun;
	bool showRun;
	bool saveState;
	int runMode;
	bool newParser;

	bool useSdk;

	bool useCustomPaths;
	QString libDir;
	QString opcodeDir;
};

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
	void setTabStopWidth(int width);
	void setTabIndents(bool indents);
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
	void clearFileBText();
	void appendFileBText(QString text);
	void setOptionsText(QString text);
	void setLadspaText(QString text);
	void setCabbageText(QString text);
	QString getCabbageText();
	void setOtherCsdText(QString text);
	void setOtherText(QString text);
	void setAppText(QString text);
	void setAppProperties(AppProperties properties);
	void showLineArea(bool visible);
    void setTheme(const QString &theme) {
        m_highlighter.setTheme(theme);
        auto defaultFormat = m_highlighter.getFormat("default");
        auto fg = defaultFormat.foreground().color();
        auto bg = defaultFormat.background().color();
        if(fg.lightness() < bg.lightness()) {
            // light
            m_mainEditor->setLineAreaColors(fg.lighter(140),
                                            bg.darker(125));
            // m_mainEditor->setLineAreaColors(QColor("#303030"), QColor("#C0C0C0"));
        } else {
            m_mainEditor->setLineAreaColors(fg.darker(140),
                                            bg.lighter(125));
            // m_mainEditor->setLineAreaColors(QColor("#C0C0C0"), QColor("#303030"));

        }
    }

    QTextCharFormat getDefaultFormat() {
        return m_highlighter.getFormat("default");
    }

	QString getFullText();
	QString getOrc();  // Without tags
	QString getSco();  // Without tags
	QString getOptionsText();  // Without tags
	QString getFileB(); // Embedded files. With tags (for filenames)
	QString getExtraCsdText();  // All other tags like version and licence with tags
	QString getExtraText(); // Text outside any known tags
	QString getAppText();
	AppProperties getAppProperties();

	void clearUndoRedoStack();

	QString getBasicText();  // What Csound needs (no widgets, misc text, etc.)


signals:

public slots:
	void toggleLineArea();
	void toggleParameterMode();

protected:
	void hideAllEditors();

	editor_mode_t m_mode; //type of text 0=csound 1=python 2=xml 3=orc 4=sco   -1=anything else
	int m_viewMode; // 0 = csd without widget + preset section
	// 1 = full plain text
	// From here on, you can have an or'd combination
	// 2 = show CsInstruments Section
	// 4 = show CsScore Section
	// 8 = show CsOptions Section
	// 16 = show <CsFileB> Section(s)
	// 32 = show remaining Text outside CsoundSynthesizer tag
	// 64 = show remaining text inside CsoundSynthesizer tag
	// 128 = show Widget, Preset and Extra Options sections
	// 256 = show CsApp section
	Highlighter m_highlighter;
	OpEntryParser *m_opcodeTree;
	QSplitter *splitter;
	TextEditLineNumbers *m_mainEditor;
	TextEditor *m_orcEditor;
	ScoreEditor *m_scoreEditor;
	TextEditor *m_optionsEditor;
	FileBEditor *m_filebEditor;
	TextEditor *m_otherEditor;  // Extra text after removing all sections. All this text is to be presented at the start of the csd. Also called information text elsewhere
	TextEditor *m_otherCsdEditor;  // Extra text and tags inside CsoundSynthesizer tags
	TextEditor *m_widgetEditor;
	TextEditor *m_appEditor;
	AppProperties m_appProperties;

	int m_orcStartLine;
	int m_scoStartLine;

	QVector<QWidget *> editors; // A vector to hold pointers for the above for easy processing
};

#endif // BASEVIEW_H

