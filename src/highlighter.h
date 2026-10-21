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

#ifndef HIGHLIGHTER_H
#define HIGHLIGHTER_H

#include <QSyntaxHighlighter>

#include <QHash>
#include <QTextCharFormat>
#include <QStringList>
#include <QRegularExpression>

#include <QTextDocument>

#include <QRegularExpression>

namespace EditorThemes { struct Theme; struct FormatSpec; }

enum CsdSection { UnknownSection, OptionsSection, OrchestraSection, ScoreSection, HtmlSection };

struct BracketInfo
{
	char character;
	int position;
};

class TextBlockData : public QTextBlockUserData
{
public:
	TextBlockData();

	// Brackets of the block, sorted by position. Stored by value: the data
	// object is replaced on every rehighlight, so pointers would leak.
	const QVector<BracketInfo> &brackets() const { return m_brackets; }
	void insert(const BracketInfo &info);
    CsdSection section = UnknownSection;
    void clearBrackets() { m_brackets.clear(); }

private:
	QVector<BracketInfo> m_brackets;

};

// Lexical scanning of a Csound line: the parts that are comments or strings.
// Brackets inside them are not part of the matching, so the scanner keeps them
// out of the bracket index.
//
// The rules are the ones of the Csound language: /* ... */ comments (which
// may span lines), ; and // line comments, "..." strings and {{ ... }} strings
// (which may span lines). Unlike the highlighter, which colours a line as it
// finds it, the scanner walks the line from left to right, so a ';' inside a
// string does not start a comment.
namespace CsoundLex {

struct Line
{
	QVector<QPair<int, int>> comments; // half-open [start, end) ranges
	QVector<QPair<int, int>> strings;  // half-open [start, end) ranges
	// The {{ ... }} strings, which may span lines. They are kept apart from
	// the "..." strings because the highlighter paints them.
	QVector<QPair<int, int>> multilineStrings;
	// State at the end of the line: 0 none, 1 inside a /* */ comment,
	// 2 inside a {{ }} string.
	int endState = 0;
};

// Scans one line. startState is the state at the end of the previous line.
Line scan(const QString &line, int startState);

// True when the position is not part of a comment or a string.
inline bool isCode(const Line &info, int position)
{
	for (const QPair<int, int> &range : info.comments) {
		if (position >= range.first && position < range.second)
			return false;
	}
	for (const QPair<int, int> &range : info.strings) {
		if (position >= range.first && position < range.second)
			return false;
	}
	for (const QPair<int, int> &range : info.multilineStrings) {
		if (position >= range.first && position < range.second)
			return false;
	}
	return true;
}

} // namespace CsoundLex

class Highlighter : public QSyntaxHighlighter
{
	Q_OBJECT

//for parentheses matching:


public:
	Highlighter(QTextDocument *parent = 0);
	~Highlighter();
	void setOpcodeNameList(QStringList list);
    void setDisabledOpcodes(QStringList list);
	void setColorVariables(bool color);
	void setMode(int mode);
    void setSectionType(CsdSection sectionType=CsdSection::UnknownSection) {
        m_sectionType = sectionType;
    }
    void setTheme(const QString &theme);
    // Marks the parenthesis pair at the given document positions (the one next
    // to the cursor). The mark is drawn by the highlighter itself, because a
    // QTextEdit extra selection cannot change the font weight. Pass -1 to clear.
    void setMatchedParentheses(int first, int second);
    void enableScoreSyntaxHighlighting(bool status) {
        m_scoreSyntaxHighlighting = status;
    }
    QTextCharFormat getFormat(QString tag);

	// for html
	enum Construct {
		Entity,
		Tag,
		Comment,
		LastConstruct = Comment
	};

	void setFormatFor(Construct construct, const QTextCharFormat &format);
	QTextCharFormat formatFor(Construct construct) const
	{ return m_formats[construct]; }

    void setUDOs(QStringList udos);

protected:
	enum State {
		NormalState = -1,
		InComment,
		InTag
	};


protected:
	void highlightBlock(const QString &text);
	void highlightCsoundBlock(const QString &text);
	void highlightPythonBlock(const QString &text);
	void highlightXmlBlock(const QString &text);
	void highlightHtmlBlock(const QString &text);
    void highlightScore(const QString &text, int start, int end);
	int findOpcode(QString opcodeName, int start = 0, int end = -1);
    bool isOpcode(QString name);

private:
    // Theme handling: applyTheme() applies a complete definition (built-in or
    // an already based-upon user theme), applyFormats() applies overrides, and
    // finishTheme() derives the remaining roles (gi*, error, html, ...).
    void resetFormats();
    void applyTheme(const EditorThemes::Theme &theme);
    void applyFormats(const QHash<QString, EditorThemes::FormatSpec> &formats);
    void finishTheme();
    QTextCharFormat *formatForName(const QString &name);

	struct HighlightingRule
	{
        QRegularExpression pattern;
		QTextCharFormat format;
        int group;
	};
	QVector<HighlightingRule> highlightingRules;
	QVector<HighlightingRule> lastHighlightingRules;

    QRegularExpression commentStartExpression;
    QRegularExpression commentEndExpression;
    QRegularExpression rxScoreLetter;
    QRegularExpression rxQuotation;

    QTextCharFormat csdtagFormat, instFormat, headerFormat;
	QTextCharFormat irateFormat, krateFormat, arateFormat, girateFormat, gkrateFormat, garateFormat;
	QTextCharFormat stringVarFormat, gstringVarFormat, fsigFormat, gfsigFormat;
    QTextCharFormat booleanFormat; // Csound 7: :b / :B boolean typed variables
    QTextCharFormat complexFormat; // Csound 7: :Complex typed variables
    QTextCharFormat opcodeFormat, udoFormat, macroDefineFormat, pfieldFormat;
    QTextCharFormat singleLineCommentFormat, importantCommentFormat;
	QTextCharFormat multiLineCommentFormat;
	QTextCharFormat quotationFormat;
	QTextCharFormat functionFormat;
    QTextCharFormat nameFormat;
    QTextCharFormat ioFormat;
    QTextCharFormat deprecatedFormat;
    QTextCharFormat operatorFormat;
    QTextCharFormat scoreLetterFormat;
    QTextCharFormat errorFormat;

	QTextCharFormat labelFormat;
    QTextCharFormat csoundOptionFormat;
    QTextCharFormat defaultFormat;

    QStringList tagPatterns, headerPatterns, instPatterns,
                keywordLiterals, htmlKeywords, javascriptKeywords,
                csoundOptions, ioPatterns; //Csound
    QStringList operatorPatterns;

    QSet<QString> deprecatedOpcodes;


    QStringList pythonKeywords;  //Python
	QTextCharFormat keywordFormat;
    QRegularExpression csoundOptionsRx, csoundOptionsRx2;

	//     void setFirstRules();
	void setLastRules();

	QStringList m_opcodeList;
    QSet<QString> m_opcodesSet;

    bool colorVariables;
	// TODO this is duplicated in documentview class. Should it be unified?
	int m_mode; //type of text 0=csound 1=python 2=xml 3=orc 4=sco   -1=anything else

    bool m_scoreSyntaxHighlighting;

    QString m_theme;
    bool m_themeSet = false;

    // The pair currently marked next to the cursor (document positions).
    int m_matchedParentheses[2] = { -1, -1 };
    QTextCharFormat matchedParenthesisFormat;

	// for html
    QTextCharFormat jsKeywordFormat, htmlTagFormat, attrFormat, tagNameFormat;
	QTextCharFormat m_formats[LastConstruct + 1];

    QStringList m_parsedUDOs;
    CsdSection m_sectionType;

    // Csound 7: explicitly typed variable sets
    QSet<QString> m_iVariables, m_kVariables, m_aVariables;
    QSet<QString> m_SVariables, m_fVariables, m_bVariables, m_complexVariables;
    QSet<QString> m_instrDefVariables, m_opcodeVariables, m_structVariables;
    QSet<QString> m_userTypeNames;
    // @global:type — separate global sets so they get girateFormat/gkrateFormat/garateFormat etc.
    QSet<QString> m_giVariables, m_gkVariables, m_gaVariables;
    QSet<QString> m_gSVariables, m_gfVariables;
    // Named (non-numeric) instruments: instr Foo → highlight Foo wherever it appears
    QSet<QString> m_namedInstruments;

    void clearTypedVars();
    QTextCharFormat formatForType(const QString &typeStr) const;
    void registerTypedVar(const QString &name, const QString &typeStr);
    void registerGlobalTypedVar(const QString &name, const QString &typeStr);
};

#endif
