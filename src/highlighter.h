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

  protected:
    void highlightBlock(const QString &text);
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

    QStringList tagPatterns, headerPatterns, instPatterns;

    void setFirstRules();
    void setLastRules();

    QStringList m_list;
    bool colorVariables;
};

#endif
