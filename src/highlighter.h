/*
    Copyright (C) 2008, 2009 Andres Cabrera
    mantaraya36@gmail.com

    This file is part of QuteCsound.

    QuteCsound is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    QuteCsound is distributed in the hope that it will be useful,
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

 class Highlighter : public QSyntaxHighlighter
{
  Q_OBJECT

  public:
    Highlighter(QTextDocument *parent = 0);
    ~Highlighter();
    void setOpcodeNameList(QStringList list);
    void setColorVariables(bool color);
    void setMode(int mode);

  protected:
    void highlightBlock(const QString &text);
    void highlightCsoundBlock(const QString &text);
    void highlightPythonBlock(const QString &text);
    void highlightXmlBlock(const QString &text);
    int findOpcode(QString opcodeName, int start, int end);

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

    QTextCharFormat /*csdBlockFormat,*/ csdtagFormat, instFormat;
    QTextCharFormat irateFormat, krateFormat, arateFormat, girateFormat, gkrateFormat, garateFormat;
    QTextCharFormat stringVarFormat, gstringVarFormat, fsigFormat, gfsigFormat;
    QTextCharFormat opcodeFormat, macroDefineFormat, pfieldFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat quotationFormat;
    QTextCharFormat functionFormat;
    QTextCharFormat labelFormat;

    QStringList tagPatterns, headerPatterns, instPatterns; //Csound

    QStringList keywords;  //Python
    QTextCharFormat keywordFormat;

//     void setFirstRules();
    void setLastRules();

    QStringList m_list;
    bool colorVariables;
    int m_mode;  // 0 = Csound generic mode, 1 = Python Mode, 2 = XML mode
};

#endif
