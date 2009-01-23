/***************************************************************************
 *   Copyright (C) 2008 by Andres Cabrera   *
 *   mantaraya36@gmail.com   *
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
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.             *
 ***************************************************************************/
#include "highlighter.h"


Highlighter::Highlighter(QTextDocument *parent)
  : QSyntaxHighlighter(parent)
{
     commentStartExpression = QRegExp("/\\*");
     commentEndExpression = QRegExp("\\*/");
     colorVariables = true;
}


Highlighter::~Highlighter()
{
}

void Highlighter::setOpcodeNameList(QStringList list)
{
  m_list = list;
  setFirstRules();
  setLastRules();
}

void Highlighter::setColorVariables(bool color)
{
  colorVariables = color;
  setFirstRules();
  setLastRules();
}

void Highlighter::highlightBlock(const QString &text)
{
  foreach (HighlightingRule rule, highlightingRules) {
    QRegExp expression(rule.pattern);
    QString temp = rule.pattern.pattern();
    int index = text.indexOf(expression);
    while (index >= 0) {
      int length = expression.matchedLength();
      setFormat(index, length, rule.format);
      index = text.indexOf(expression, index + length);
    }
  }
  setCurrentBlockState(0);

  int startIndex = 0;
  if (previousBlockState() != 1)
    startIndex = text.indexOf(commentStartExpression);

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

void Highlighter::setFirstRules()
{
  highlightingRules.clear();
  HighlightingRule rule;
  QString pattern;

  if (colorVariables) {
    QTextCharFormat irateFormat;
    irateFormat.setForeground(QColor("darkCyan"));
  //   irateFormat.setFontWeight(QFont::Bold);
    pattern = "\\bi[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = irateFormat;
    highlightingRules.append(rule);

    QTextCharFormat krateFormat;
    krateFormat.setForeground(QColor("darkCyan"));
  //   krateFormat.setFontWeight(QFont::Bold);
    pattern = "\\bk[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = krateFormat;
    highlightingRules.append(rule);

    QTextCharFormat arateFormat;
    arateFormat.setForeground(QColor("darkCyan"));
    arateFormat.setFontWeight(QFont::Bold);
    pattern = "\\ba[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = arateFormat;
    highlightingRules.append(rule);

    QTextCharFormat girateFormat;
    girateFormat.setForeground(QColor("darkCyan"));
  //   irateFormat.setFontWeight(QFont::Bold);
    girateFormat.setFontItalic(true);
    pattern = "\\bgi[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = girateFormat;
    highlightingRules.append(rule);

    QTextCharFormat gkrateFormat;
    gkrateFormat.setForeground(QColor("darkCyan"));
  //   krateFormat.setFontWeight(QFont::Bold);
    gkrateFormat.setFontItalic(true);
    pattern = "\\bgk[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = gkrateFormat;
    highlightingRules.append(rule);

    QTextCharFormat garateFormat;
    garateFormat.setForeground(QColor("darkCyan"));
    garateFormat.setFontWeight(QFont::Bold);
    garateFormat.setFontItalic(true);
    pattern = "\\bga[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = garateFormat;
    highlightingRules.append(rule);

    QTextCharFormat stringVarFormat;
    stringVarFormat.setForeground(QColor(Qt::darkYellow));
    stringVarFormat.setFontWeight(QFont::Bold);
    pattern = "\\bS[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = stringVarFormat;
    highlightingRules.append(rule);

    QTextCharFormat gstringVarFormat;
    gstringVarFormat.setForeground(QColor(Qt::darkYellow));
    gstringVarFormat.setFontWeight(QFont::Bold);
    gstringVarFormat.setFontItalic(true);
    pattern = "\\bgS[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = gstringVarFormat;
    highlightingRules.append(rule);

    QTextCharFormat fsigFormat;
    fsigFormat.setForeground(QColor(Qt::gray));
    fsigFormat.setFontWeight(QFont::Bold);
    pattern = "\\bf[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = fsigFormat;
    highlightingRules.append(rule);

    QTextCharFormat gfsigFormat;
    gfsigFormat.setForeground(QColor(Qt::gray));
    gfsigFormat.setFontItalic(true);
    gfsigFormat.setFontWeight(QFont::Bold);
    pattern = "\\bf[a-zA-Z0-9_]+\\b";
    rule.pattern = QRegExp(pattern);
    rule.format = gfsigFormat;
    highlightingRules.append(rule);
  }

  opcodeFormat.setForeground(QColor("blue"));
  opcodeFormat.setFontWeight(QFont::Bold);
  foreach (QString opPattern, m_list) {
//     pattern = "[ \\t\\r\\n]" + pattern + "[ \\t\\r\\n]";
    opPattern = "\\b" + opPattern + "\\b";
//     qDebug("%s",pattern.toStdString().c_str());
    rule.pattern = QRegExp(opPattern);
    rule.format = opcodeFormat;
    highlightingRules.append(rule);
  }
}

void Highlighter::setLastRules()
{
  HighlightingRule rule;

  csdtagFormat.setForeground(QColor("brown"));
//      csdtagFormat.setFontWeight(QFont::Bold);
  QStringList keywordPatterns;
  keywordPatterns << "<CsoundSynthesizer>" << "</CsoundSynthesizer>"
      << "<CsOptions>" << "</CsOptions>"
      << "<CsInstruments>" << "</CsInstruments>"
      << "<CsScore>" << "</CsScore>"
      << "<CsVersion>" << "</CsVersion>"
      << "<MacOptions>" << "</MacOptions>"
      << "<MacGUI>" << "</MacGUI>";
  foreach (QString pattern, keywordPatterns) {
    rule.pattern = QRegExp(pattern);
    rule.format = csdtagFormat;
    highlightingRules.append(rule);
  }

  QStringList instPatterns;
  instPatterns << "\\binstr\\b" << "\\bendin\\b" << "\\bopcode\\b" << "\\bendop\\b";
  csdtagFormat.setForeground(QColor("purple"));
  csdtagFormat.setFontWeight(QFont::Bold);
  foreach (QString pattern, instPatterns) {
    rule.pattern = QRegExp(pattern);
    rule.format = csdtagFormat;
    highlightingRules.append(rule);
  }

  QStringList headerPatterns;
  headerPatterns << "\\bsr\\b" << "\\bkr\\b" << "\\bksmps\\b" << "\\bnchnls\\b" << "\\b0dbfs\\b";
  csdtagFormat.setForeground(QColor("brown"));
  csdtagFormat.setFontWeight(QFont::Bold);
  foreach (QString pattern, headerPatterns) {
    rule.pattern = QRegExp(pattern);
    rule.format = csdtagFormat;
    highlightingRules.append(rule);
  }

  quotationFormat.setForeground(Qt::red);
  rule.pattern = QRegExp("\".*\"");
  rule.format = quotationFormat;
  highlightingRules.append(rule);
  rule.pattern = QRegExp("\\{\\{.*\\}\\}");
  rule.format = quotationFormat;
  highlightingRules.append(rule);

  labelFormat.setForeground(QColor(205,92,92));
  labelFormat.setFontWeight(QFont::Bold);
  rule.pattern = QRegExp("[\\s]*[a-zA-Z0-9]*:[^a-zA-Z0-9]*");
  rule.format = labelFormat;
  highlightingRules.append(rule);

  singleLineCommentFormat.setForeground(QColor("green"));
  singleLineCommentFormat.setFontItalic(true);
  rule.pattern = QRegExp(";[^\n]*");
  rule.format = singleLineCommentFormat;
  highlightingRules.append(rule);

  multiLineCommentFormat.setForeground(QColor("green"));

//      classFormat.setFontWeight(QFont::Bold);
//      classFormat.setForeground(Qt::darkMagenta);
//      rule.pattern = QRegExp("\\bQ[A-Za-z]+\\b");
//      rule.format = classFormat;
//      highlightingRules.append(rule);


//      functionFormat.setFontItalic(true);
//      functionFormat.setForeground(Qt::blue);
//      rule.pattern = QRegExp("\\b[A-Za-z0-9_]+(?=\\()");
//      rule.format = functionFormat;
//      highlightingRules.append(rule);
}
