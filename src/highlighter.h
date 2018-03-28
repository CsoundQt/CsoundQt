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

#include <QTextDocument>

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
	int findOpcode(QString opcodeName, int start = 0, int end = -1);

private:
	struct HighlightingRule
	{
		QRegExp pattern;
		QTextCharFormat format;
	};
	QVector<HighlightingRule> highlightingRules;
	QVector<HighlightingRule> lastHighlightingRules;

	QRegExp commentStartExpression;
	QRegExp commentEndExpression;
	//    QRegExp b64encStartExpression;
	//    QRegExp b64encEndExpression;

	QTextCharFormat /*csdBlockFormat,*/ csdtagFormat, instFormat;
	QTextCharFormat irateFormat, krateFormat, arateFormat, girateFormat, gkrateFormat, garateFormat;
	QTextCharFormat stringVarFormat, gstringVarFormat, fsigFormat, gfsigFormat;
	QTextCharFormat opcodeFormat, macroDefineFormat, pfieldFormat;
	QTextCharFormat singleLineCommentFormat;
	QTextCharFormat multiLineCommentFormat;
	QTextCharFormat quotationFormat;
	QTextCharFormat functionFormat;
	QTextCharFormat labelFormat;

	QStringList tagPatterns, headerPatterns, instPatterns, keywordPatterns, htmlKeywords, javascriptKeywords; //Csound

	QStringList keywords;  //Python
	QTextCharFormat keywordFormat;

	//     void setFirstRules();
	void setLastRules();

	QStringList m_opcodeList;
	bool colorVariables;
	// TODO this is duplicated in documentview class. Should it be unified?
	int m_mode; //type of text 0=csound 1=python 2=xml 3=orc 4=sco   -1=anything else

	// for html
	QTextCharFormat jsKeywordFormat, htmlTagFormat;
	QTextCharFormat m_formats[LastConstruct + 1];
};

#endif
