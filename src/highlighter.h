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
#include <QSet>
#include <QVector>
#include <QTextCharFormat>
#include <QStringList>
#include <QStringView>
#include <QRegularExpression>

#include <QTextDocument>

#include <QRegularExpression>

using namespace Qt::StringLiterals;

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
// (which may span lines). The scanner walks the line from left to right, so a
// ';' inside a string does not start a comment. The highlighter uses these
// ranges to keep code colouring out of comments and strings.
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

	// Clears the ranges while keeping their capacity. The highlighter reuses
	// one Line for every block to avoid allocating the range vectors again.
	void clear()
	{
		comments.clear();
		strings.clear();
		multilineStrings.clear();
		endState = 0;
	}
};

// Scans one line. startState is the state at the end of the previous line.
Line scan(QStringView line, int startState);
// Same, but fills an existing Line and reuses its vector capacity.
void scanInto(QStringView line, int startState, Line &info);

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
	void setOpcodeNameList(const QStringList& list);
    void setDisabledOpcodes(QStringList list);
	void setColorVariables(bool color);
	void setMode(int mode);
    void setSectionType(CsdSection sectionType=CsdSection::UnknownSection) {
        m_sectionType = sectionType;
    }
    void setTheme(const QString &theme);
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

    void setUDOs(const QStringList &udos);
    // One instrument/opcode block of local variables, as collected by CodeScan.
    struct VariableScope
    {
        int startLine = -1;   // 1-based
        int endLine = -1;     // 1-based, or -1 when unterminated
        QHash<QString, QString> variables; // name -> normalized type
    };
    // Local variables collected by CodeScan. Looked up per block so the same
    // name can have different types in different instruments/opcodes.
    void setLocalVariableScopes(const QVector<VariableScope> &scopes);

protected:
	enum State {
		NormalState = -1,
		InComment,
		InTag
	};


protected:
	void highlightBlock(const QString &text);
	void highlightCsoundBlock(const QString &text, bool paintStrings = true);
	void highlightXmlBlock(const QString &text);
	void highlightHtmlBlock(const QString &text);
    void highlightScore(const QString &text, int start, int end);
	int findOpcode(QString opcodeName, int start = 0, int end = -1);
    bool isOpcode(const QString &name);

private:
    // Theme handling: applyTheme() applies a complete definition (built-in or
    // an already based-upon user theme), applyFormats() applies overrides, and
    // finishTheme() derives the remaining roles (gi*, error, html, ...).
    void resetFormats();
    void applyTheme(const EditorThemes::Theme &theme);
    void applyFormats(const QHash<QString, EditorThemes::FormatSpec> &formats);
    void finishTheme();
    QTextCharFormat *formatForName(const QString &name);
    QString localVariableType(int line, const QString &name) const;

	struct HighlightingRule
	{
        QRegularExpression pattern;
		QTextCharFormat format;
        int group;
	};
	QVector<HighlightingRule> highlightingRules;
	QVector<HighlightingRule> lastHighlightingRules;

    QRegularExpression rxScoreLetter;
    QRegularExpression rxQuotation;

    QTextCharFormat csdtagFormat, csdtagCloseFormat, instFormat, headerFormat;
	QTextCharFormat irateFormat, krateFormat, arateFormat, girateFormat, gkrateFormat, garateFormat;
	QTextCharFormat stringVarFormat, gstringVarFormat, fsigFormat, gfsigFormat;
    QTextCharFormat channelnameFormat; // quoted string used as a Csound channel name
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

    QStringList htmlKeywords, javascriptKeywords; //Csound

    const QSet<QString> instPatterns = {
        u"instr"_s, u"endin"_s, u"opcode"_s, u"endop"_s,
    };

    const QSet<QString> headerPatterns = {
        u"sr"_s, u"kr"_s, u"ksmps"_s, u"nchnls"_s, u"nchnls_i"_s,
        u"0dbfs"_s, u"A4"_s, u"zakinit"_s, u"massign"_s,
    };

    const QSet<QString> ioPatterns = {
        u"in"_s, u"ins"_s, u"inch"_s, u"out"_s, u"outs"_s, u"outch"_s,
        u"outvalue"_s, u"invalue"_s, u"chnget"_s, u"chngetk"_s, u"chnset"_s,
        u"zaw"_s, u"zar"_s, u"zkw"_s, u"zkr"_s, u"zawm"_s,
        u"OSCsend"_s, u"OSClisten"_s, u"OSCraw"_s, u"OSCinit"_s,
    };

    const QSet<QString> csoundOptions = {
        u"-+rtaudio"_s,
        u"-+rtmidi"_s,
        u"-+jack_client"_s,
        u"--nodisplays"_s,
        u"--nosound"_s,
        u"--syntax-check-only"_s,
        u"--control-rate"_s,
        u"--messagelevel"_s,
        u"--env"_s,
        u"--dither"_s,
        u"--sched"_s,
        u"--omacro"_s,
        u"--smacro"_s,
        u"--verbose"_s,
        u"--sample-accurate"_s,
        u"--realtime"_s,
        u"--nchnls"_s,
        u"--nchnls_i"_s,
        u"--sinesize"_s,
        u"--daemon"_s,
        u"--port"_s,
        u"--use-system-sr"_s,
        u"--ksmps"_s,
        u"--midi-key-cps"_s,
        u"--midi-velocity"_s,
        u"--limiter"_s,
        u"--udp-echo"_s,
        u"--opcode-dir"_s,
    };

    const QSet<QString> tagPatterns = {
        u"CsoundSynthesizer"_s,
        u"MacOptions"_s,
        u"csLADSPA"_s,
        u"Cabbage"_s,
        u"CsInstruments"_s,
        u"CsOptions"_s,
        u"CsScore"_s,
        u"CsVersion"_s,
        u"CsHtml5"_s,
        u"CsFileB"_s,
        u"CsLicense"_s, u"CsLincense"_s,
    };

    const QSet<QString> keywordLiterals = {
        u"init"_s,
        u"if"_s,
        u"then"_s,
        u"else"_s,
        u"endif"_s,
        u"elseif"_s,
        u"while"_s,
        u"goto"_s,
        u"igoto"_s,
        u"kgoto"_s,
        u"do"_s,
        u"od"_s,
        u"int"_s,
        u"turnoff"_s,
        u"xin"_s,
        u"xout"_s,
        u"passign"_s,
        u"schedule"_s,
        u"schedulek"_s,

        // Csound 7 keywords
        u"create"_s,
        u"delete"_s,
        u"run"_s,
        u"struct"_s,
        u"endstruct"_s,
        u"for"_s,
        u"in"_s,
        u"@global"_s,
        u"oversample"_s,
        u"undersample"_s,
        u"setksmps"_s,
        u"switch"_s,
        u"case"_s,
        u"default"_s,
        u"endsw"_s,
        u"InstrDef"_s,
        u"Instr"_s,
        u"OpcodeDef"_s,
        u"Opcode"_s,
    };

    QStringList operatorPatterns;

    QSet<QString> deprecatedOpcodes;


    QTextCharFormat keywordFormat;

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
    int m_themeGeneration = -1;

	// for html
    QTextCharFormat jsKeywordFormat, htmlTagFormat, attrFormat, tagNameFormat;
	QTextCharFormat m_formats[LastConstruct + 1];

    QSet<QString> m_parsedUDOs;
    CsoundLex::Line m_lexScratch;
    CsdSection m_sectionType;

    // Csound 7: explicitly typed variable sets
    QSet<QString> m_iVariables, m_kVariables, m_aVariables;
    QSet<QString> m_SVariables, m_fVariables, m_bVariables, m_complexVariables;
    QSet<QString> m_instrDefVariables, m_opcodeVariables, m_structVariables;
    QSet<QString> m_userTypeNames;
    // Local variable scopes supplied by CodeScan, kept across theme changes.
    QVector<VariableScope> m_localVariableScopes;
    // @global:type — separate global sets so they get girateFormat/gkrateFormat/garateFormat etc.
    QSet<QString> m_giVariables, m_gkVariables, m_gaVariables;
    QSet<QString> m_gSVariables, m_gfVariables;
    // Named (non-numeric) instruments: instr Foo → highlight Foo wherever it appears
    QSet<QString> m_namedInstruments;

    void clearTypedVars();
    QTextCharFormat formatForType(QStringView typeStr) const;
    // Detects whether the quoted string at `stringStart` is a channel name
    // argument of chnget/chnset/outvalue/invalue/chnmix. `line` is the same
    // line with comments and strings masked out (spaces).
    bool isChannelNameArgument(const QString &line, int stringStart) const;
    void registerTypedVar(QStringView name, QStringView typeStr);
    void registerGlobalTypedVar(QStringView name, QStringView typeStr);
};

#endif
