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

#include "highlighter.h"


Highlighter::Highlighter(QTextDocument *parent)
	: QSyntaxHighlighter(parent)
{
	commentStartExpression = QRegExp("/\\*");
	commentEndExpression = QRegExp("\\*/");
	//  b64encStartExpression = QRegExp("<CsFileB .*>");
	//  b64encEndExpression = QRegExp("<CsFileB>");
	colorVariables = true;
	m_mode = 0; // default to Csound mode

	// For Csound
	csdtagFormat.setForeground(QColor("brown"));
	csdtagFormat.setFontWeight(QFont::Bold);
	tagPatterns << "<CsoundSynthesizer>" << "</CsoundSynthesizer>"
				<< "<CsInstruments>" << "</CsInstruments>"
				<< "<CsOptions>" << "</CsOptions>"
				<< "<CsScore>" << "</CsScore>"
				<< "<CsVersion>" << "</CsVersion>"
				<< "<MacOptions>" << "</MacOptions>"
				<< "<MacGUI>" << "</MacGUI>"
				<< "<csLADSPA>" << "</csLADSPA>";
	instFormat.setForeground(QColor("purple"));
	instFormat.setFontWeight(QFont::Bold);
	instPatterns << "instr" << "endin" << "opcode" << "endop";
	headerPatterns << "sr" << "kr" << "ksmps" << "nchnls" << "0dbfs";
	csdtagFormat.setForeground(QColor("brown"));
	csdtagFormat.setFontWeight(QFont::Bold);
	opcodeFormat.setForeground(QColor("blue"));
	opcodeFormat.setFontWeight(QFont::Bold);

	// For Python
	keywords << "and" << "or" << "not" << "is";
	keywords << "global" << "with" << "from" << "import" << "as";
	keywords << "if" << "else" << "elif";
	keywords << "print" << "class" << "del" << "exec";
	keywords << "for" << "in" << "while" << "continue" << "pass" << "break";
	keywords << "def" << "return" << "lambda";
	keywords << "yield" << "assert" << "try" << "except" << "finally" << "raise";
	keywords << "True" << "False" << "None";

	keywordFormat.setForeground(QColor("blue"));
	keywordFormat.setFontWeight(QFont::Bold);

	singleLineCommentFormat.setForeground(QColor("green"));
	singleLineCommentFormat.setFontItalic(true);

	macroDefineFormat.setForeground(QColor("green"));
	macroDefineFormat.setFontWeight(QFont::Bold);

	pfieldFormat.setFontWeight(QFont::Bold);

	irateFormat.setForeground(QColor("darkCyan"));
	krateFormat.setForeground(QColor("darkCyan"));
	arateFormat.setForeground(QColor("darkCyan"));
	arateFormat.setFontWeight(QFont::Bold);

	girateFormat.setForeground(QColor("darkCyan"));
	girateFormat.setFontItalic(true);
	gkrateFormat.setForeground(QColor("darkCyan"));
	gkrateFormat.setFontItalic(true);
	garateFormat.setForeground(QColor("darkCyan"));
	garateFormat.setFontWeight(QFont::Bold);
	garateFormat.setFontItalic(true);

	stringVarFormat.setForeground(QColor(Qt::darkYellow));
	stringVarFormat.setFontWeight(QFont::Bold);
	gstringVarFormat.setForeground(QColor(Qt::darkYellow));
	gstringVarFormat.setFontWeight(QFont::Bold);
	gstringVarFormat.setFontItalic(true);

	fsigFormat.setForeground(QColor(Qt::gray));
	fsigFormat.setFontWeight(QFont::Bold);
	gfsigFormat.setForeground(QColor(Qt::gray));
	gfsigFormat.setFontItalic(true);
	gfsigFormat.setFontWeight(QFont::Bold);
}


Highlighter::~Highlighter()
{
}

void Highlighter::setOpcodeNameList(QStringList list)
{
	m_list = list;
	//   setFirstRules();
	setLastRules();
}

void Highlighter::setMode(int mode)
{
	m_mode = mode;
}

void Highlighter::setColorVariables(bool color)
{
	colorVariables = color;

	highlightingRules.clear();
	setLastRules();
}

void Highlighter::highlightBlock(const QString &text)
{
	switch (m_mode) {
	case 0:  // Csound mode
		highlightCsoundBlock(text);
		break;
	case 1:  // Python mode
		highlightPythonBlock(text);
		break;
	case 2:  // Xml mode
		highlightXmlBlock(text);
		break;
	case 3:  // Orc
		highlightCsoundBlock(text);
		break;
	case 4:  // Orc
		highlightCsoundBlock(text);
		break;
	}
}

void Highlighter::highlightCsoundBlock(const QString &text)
{
	// text is processed one line at a time
	//   qDebug("Text---------------------: %s", text.toStdString().c_str());

	int commentIndex = text.indexOf(';');
	if (commentIndex >= 0) {
		setFormat(commentIndex, text.size() - commentIndex, singleLineCommentFormat);
	}
	else {
		commentIndex = text.size() + 1;
	}
	int macroIndex = text.indexOf('#');
	if (macroIndex >= 0 && macroIndex < commentIndex) {
		setFormat(macroIndex, text.size() - macroIndex, macroDefineFormat);
		commentIndex = macroIndex;
	}
	QRegExp expression("\\b+\\w");
	int index = text.indexOf(expression, 0);
	int length = expression.matchedLength();
	while (index >= 0 && index < commentIndex) {
		int wordStart = index + length - 1;
		QRegExp endExpression("\\W");
		int wordEnd = text.indexOf(endExpression, wordStart);
		wordEnd = (wordEnd > 0 ? wordEnd : text.size());
		QString word = text.mid(wordStart, wordEnd - wordStart);
		//    qDebug() << "word: " << word;
		if (word.indexOf(QRegExp("p[\\d]+\\b")) != -1) {
			setFormat(wordStart, wordEnd - wordStart, pfieldFormat);
		}
		if (instPatterns.contains(word)) {
			setFormat(wordStart, wordEnd - wordStart, instFormat);
		}
		else if (tagPatterns.contains("<" + word + ">") && wordStart > 0) {
			setFormat(wordStart - (text[wordStart - 1] == '/' ?  2 : 1), wordEnd - wordStart + (text[wordStart - 1] == '/' ?  3 : 2), csdtagFormat);
		}
		else if (headerPatterns.contains(word)) {
			setFormat(wordStart, wordEnd - wordStart, csdtagFormat);
		}
		else if (findOpcode(word, 0, m_list.size() - 1) >= 0) {
			setFormat(wordStart, wordEnd - wordStart, opcodeFormat);
		}
		else if (word.startsWith('a') && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, arateFormat);
		}
		else if ((word.startsWith('k') || word.startsWith('i')) && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, krateFormat);
		}
		else if (word.startsWith("ga")  && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, garateFormat);
		}
		else if ((word.startsWith("gk") || word.startsWith("gi")) && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, gkrateFormat);
		}
		else if (word.startsWith("S")  && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, stringVarFormat);
		}
		else if (word.startsWith("gS")  && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, gstringVarFormat);
		}
		else if (word.startsWith("f") && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, fsigFormat);
		}
		else if (word.startsWith("gf") && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, gfsigFormat);
		}
		index = text.indexOf(expression, wordEnd);
		length = expression.matchedLength();
	}
	//last rules
	for (int i = 0; i < lastHighlightingRules.size(); i++) {
		QRegExp expression(lastHighlightingRules[i].pattern);
		//     QString temp = rule.pattern.pattern();
		int index = text.indexOf(expression);
		while (index >= 0 && index < commentIndex) {
			int length = expression.matchedLength();
			setFormat(index, length, lastHighlightingRules[i].format);
			index = text.indexOf(expression, index + length);
		}
	}

	setCurrentBlockState(0);

	int startIndex = 0;
	if (previousBlockState() != 1) {
		startIndex = text.indexOf(commentStartExpression);
	}

	while (startIndex >= 0) {
		int endIndex = text.indexOf(commentEndExpression, startIndex);
		int commentLength;
		if (endIndex == -1) {
			setCurrentBlockState(1);
			commentLength = text.length() - startIndex;
		} else {
			commentLength = endIndex - startIndex
					+ commentEndExpression.matchedLength();
		}
		setFormat(startIndex, commentLength, multiLineCommentFormat);
		startIndex = text.indexOf(commentStartExpression,
								  startIndex + commentLength);
	}
}


void Highlighter::highlightPythonBlock(const QString &text)
{
	QRegExp expression("\\b+\\w\\b+");
	int index = text.indexOf(expression, 0);
	for (int i = 0; i < keywords.size(); i++) {
		QRegExp expression("\\b+" + keywords[i] + "\\b+");
		int index = text.indexOf(expression);
		while (index >= 0) {
			int length = expression.matchedLength();
			setFormat(index, length, keywordFormat);
			index = text.indexOf(expression, index + length);
		}
	}
	QRegExp strings( QRegExp("[\"'].*[\"']"));
	//     QString temp = rule.pattern.pattern();
	index = text.indexOf(strings);
	while (index >= 0) {
		int length = strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
	QRegExp expComment("#.*");
	index = text.indexOf(expComment);
	while (index >= 0) {
		int length = expComment.matchedLength();
		setFormat(index, length, singleLineCommentFormat);
		index = text.indexOf(expComment, index + length);
	}
}

void Highlighter::highlightXmlBlock(const QString &/*text*/)
{
}


// void Highlighter::setFirstRules()
// {
//   highlightingRules.clear();
// }

void Highlighter::setLastRules()
{
	HighlightingRule rule;

	labelFormat.setForeground(QColor(205,92,92));
	labelFormat.setFontWeight(QFont::Bold);
	rule.pattern = QRegExp("\\b[\\w]*:[^\\w;]*");
	rule.format = labelFormat;
	lastHighlightingRules.append(rule);

	quotationFormat.setForeground(Qt::red);
	rule.pattern = QRegExp("\".*\"");
	rule.format = quotationFormat;
	lastHighlightingRules.append(rule);
	rule.pattern = QRegExp("\\{\\{.*");
	rule.format = quotationFormat;
	lastHighlightingRules.append(rule);
	rule.pattern = QRegExp(".*\\}\\}");
	rule.format = quotationFormat;
	lastHighlightingRules.append(rule);

	multiLineCommentFormat.setForeground(QColor("green"));
}

int Highlighter::findOpcode(QString opcodeName, int start, int end)
{
	//   fprintf(stderr, "%i - %i\n", start, end);
	Q_ASSERT(m_list.size() > 0);
	int pos = ((end - start)/2) + start;
	if (opcodeName == m_list[pos])
		return pos;
	else if (start == end)
		return -1;
	else if (opcodeName < m_list[pos])
		return findOpcode(opcodeName, start, pos);
	else if (opcodeName > m_list[pos])
		return findOpcode(opcodeName, pos + 1, end);
	return -1;
}
