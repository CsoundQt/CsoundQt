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

enum CsdSection { UnknownSection, OptionsSection, OrchestraSection, ScoreSection };

struct ParenthesisInfo
{
	char character;
	int position;
};

class TextBlockData : public QTextBlockUserData
{
public:
	TextBlockData();

	QVector<ParenthesisInfo *> parentheses();
	void insert(ParenthesisInfo *info);
    CsdSection section;

private:
	QVector<ParenthesisInfo *> m_parentheses;

};

class Highlighter : public QSyntaxHighlighter
{
	Q_OBJECT

//for parentheses matching:


public:
	Highlighter(QTextDocument *parent = 0);
	~Highlighter();
	void setOpcodeNameList(QStringList list);
	void setColorVariables(bool color);
	void setMode(int mode);
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
    QRegExp functionRegex;

    QRegularExpression rxScoreLetter;
    QRegularExpression rxQuotation;
    //    QRegExp b64encStartExpression;
	//    QRegExp b64encEndExpression;


    QTextCharFormat csdtagFormat, instFormat, headerFormat;
	QTextCharFormat irateFormat, krateFormat, arateFormat, girateFormat, gkrateFormat, garateFormat;
	QTextCharFormat stringVarFormat, gstringVarFormat, fsigFormat, gfsigFormat;
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

	// for html
	QTextCharFormat jsKeywordFormat, htmlTagFormat;
	QTextCharFormat m_formats[LastConstruct + 1];

    QStringList m_parsedUDOs;
};

#endif
