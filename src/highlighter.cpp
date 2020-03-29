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

#include <QDebug>

TextBlockData::TextBlockData()
{
	// Nothing to do
}

QVector<ParenthesisInfo *> TextBlockData::parentheses()
{
	return m_parentheses;
}


void TextBlockData::insert(ParenthesisInfo *info)
{
	int i = 0;
	while (i < m_parentheses.size() &&
		info->position > m_parentheses.at(i)->position)
		++i;

	m_parentheses.insert(i, info);
}

QColor saturateColor(QColor color, int percent) {
    int sat = color.saturation();
    sat = sat * percent / 100;
    if(sat > 255)
        sat = 255;
    return QColor::fromHsl(color.hue(), sat, color.lightness());
}

void Highlighter::setTheme(const QString &theme) {
    if(theme == "none") {
        defaultFormat.setForeground(QColor("black"));
        defaultFormat.setBackground(QColor(250, 250, 250));
        /*
        csdtagFormat = defaultFormat;
        instFormat = defaultFormat;
        keywordFormat = defaultFormat;
        headerFormat = defaultFormat;
        opcodeFormat = defaultFormat;
        singleLineCommentFormat  = defaultFormat;
        */


    }
    else if(theme == "classic") {
        defaultFormat.setForeground(QColor("black"));
        defaultFormat.setBackground(QColor(250, 250, 250));

        csdtagFormat.setForeground(QColor("brown"));
        csdtagFormat.setFontWeight(QFont::Bold);

        instFormat.setForeground(QColor("purple"));
        instFormat.setFontWeight(QFont::Bold);

        keywordFormat.setForeground(QColor("#E65100"));
        keywordFormat.setFontWeight(QFont::Bold);

        headerFormat.setForeground(QColor("red"));

        opcodeFormat.setForeground(QColor("blue"));
        opcodeFormat.setFontWeight(QFont::Bold);

        singleLineCommentFormat.setForeground(QColor("green"));
        singleLineCommentFormat.setFontItalic(true);

        macroDefineFormat.setForeground(QColor("green"));
        macroDefineFormat.setFontWeight(QFont::Bold);

        pfieldFormat.setFontWeight(QFont::Bold);

        irateFormat.setForeground(QColor("darkCyan"));
        krateFormat.setForeground(QColor("darkCyan"));

        arateFormat.setForeground(QColor("darkCyan"));
        arateFormat.setFontWeight(QFont::Bold);

        stringVarFormat.setForeground(QColor(Qt::darkYellow));
        stringVarFormat.setFontWeight(QFont::Bold);

        fsigFormat.setForeground(QColor(Qt::gray));
        fsigFormat.setFontWeight(QFont::Bold);

        labelFormat.setForeground(QColor(205,92,92));
        labelFormat.setFontWeight(QFont::Bold);

        nameFormat.setForeground(QColor("#880E4F"));
        nameFormat.setFontWeight(QFont::Bold);
        // nameFormat.setFontUnderline(true);

        quotationFormat.setForeground(Qt::red);
        multiLineCommentFormat.setForeground(QColor("green"));

        ioFormat = opcodeFormat;
    }
    else if(theme == "light") {
        defaultFormat.setForeground(QColor("#030303"));
        defaultFormat.setBackground(QColor("#FCFCFC"));

        // csdtagFormat.setFontWeight(QFont::Bold);

        instFormat.setForeground(QColor("#82387B"));
        instFormat.setFontWeight(QFont::Bold);

        keywordFormat.setForeground(QColor("#D64100"));
        keywordFormat.setFontWeight(QFont::Bold);

        // headerFormat.setForeground(QColor("#C62828"));
        // headerFormat.setFontWeight(QFont::Bold);
        headerFormat = keywordFormat;

        opcodeFormat.setForeground(QColor("#303F9F"));
        opcodeFormat.setFontWeight(QFont::Bold);

        singleLineCommentFormat.setForeground(QColor("#8F8F7F"));
        singleLineCommentFormat.setFontItalic(true);

        macroDefineFormat.setForeground(QColor("#00695C"));
        macroDefineFormat.setFontWeight(QFont::Bold);

        pfieldFormat.setFontWeight(QFont::Bold);


        krateFormat.setForeground(QColor("#10796C"));
        irateFormat.setForeground(QColor("#303F9F"));

        // arateFormat.setForeground(QColor("#C62828"));
        arateFormat.setForeground(QColor("#B71C1C"));
        arateFormat.setFontWeight(QFont::Bold);

        stringVarFormat.setForeground(QColor(Qt::darkYellow));
        stringVarFormat.setFontWeight(QFont::Normal);

        fsigFormat.setForeground(QColor("#Ad1457"));
        fsigFormat.setFontWeight(QFont::Bold);

        labelFormat.setForeground(QColor(205,92,92));
        labelFormat.setFontWeight(QFont::Bold);
        labelFormat.setFontUnderline(true);

        nameFormat.setForeground(QColor("#F50057"));
        nameFormat.setFontWeight(QFont::Bold);
        // nameFormat.setFontUnderline(true);

        // quotationFormat.setForeground(QColor("#4CAf50"));
        quotationFormat.setForeground(QColor("#827717"));
        multiLineCommentFormat.setForeground(quotationFormat.foreground());

        ioFormat.setForeground(opcodeFormat.foreground().color().lighter(150));
        ioFormat.setFontWeight(QFont::Bold);
        ioFormat.setFontItalic(true);
        csdtagFormat.setForeground(instFormat.foreground());
    }
    else if(theme == "dark") {
        defaultFormat.setForeground(QColor("#FBFBFB"));
        defaultFormat.setBackground(QColor("#161616"));

        // csdtagFormat.setFontWeight(QFont::Bold);

        instFormat.setForeground(QColor("#B268AB"));
        instFormat.setFontWeight(QFont::Bold);

        keywordFormat.setForeground(QColor("#FF9800"));
        keywordFormat.setFontWeight(QFont::Bold);

        // headerFormat.setForeground(QColor("#FFD54F"));
        // headerFormat.setFontWeight(QFont::Bold);
        headerFormat = keywordFormat;

        opcodeFormat.setForeground(QColor("#4FC3F7"));
        opcodeFormat.setFontWeight(QFont::Bold);

        // singleLineCommentFormat.setForeground(QColor("#9F9F8F"));
        singleLineCommentFormat.setForeground(QColor("#755CB0"));
        singleLineCommentFormat.setFontItalic(true);

        macroDefineFormat.setForeground(QColor("#F06292"));
        macroDefineFormat.setFontWeight(QFont::Bold);

        pfieldFormat.setFontWeight(QFont::Bold);

        krateFormat.setForeground(QColor("#EF9A9A"));
        irateFormat.setForeground(QColor("#FFFFFF"));

        // arateFormat.setForeground(QColor("#C62828"));
        arateFormat.setForeground(QColor("#F75C5C"));
        arateFormat.setFontWeight(QFont::Bold);


        fsigFormat.setForeground(QColor("#Ad1457"));
        fsigFormat.setFontWeight(QFont::Bold);

        labelFormat.setForeground(instFormat.foreground());
        labelFormat.setFontWeight(QFont::Bold);
        labelFormat.setFontUnderline(true);

        nameFormat.setForeground(QColor("#D298FB"));
        nameFormat.setFontWeight(QFont::Bold);
        // nameFormat.setFontUnderline(true);

        // quotationFormat.setForeground(QColor("#66FFAA"));
        quotationFormat.setForeground(QColor("#91FF55"));
        stringVarFormat.setForeground(quotationFormat.foreground());
        stringVarFormat.setFontWeight(QFont::Normal);

        multiLineCommentFormat.setForeground(quotationFormat.foreground());

        ioFormat.setForeground(QColor("#FFD54F"));
        ioFormat.setFontWeight(QFont::Bold);
        // ioFormat.setFontItalic(true);
        csdtagFormat.setForeground(instFormat.foreground());


    }
    else {
        qDebug() << "Theme" << theme << "not defined, using default";
        this->setTheme("classic");
        return;
    }
    // --------------------------------------
    girateFormat.setForeground(irateFormat.foreground());
    // girateFormat.setFontWeight(QFont::Bold);
    girateFormat.setFontItalic(true);

    gkrateFormat.setForeground(krateFormat.foreground());
    // gkrateFormat.setFontWeight(QFont::Bold);
    gkrateFormat.setFontItalic(true);

    garateFormat.setForeground(arateFormat.foreground());
    garateFormat.setFontWeight(arateFormat.fontWeight());
    garateFormat.setFontItalic(true);

    gfsigFormat.setForeground(fsigFormat.foreground());
    gfsigFormat.setFontWeight(fsigFormat.fontWeight());
    gfsigFormat.setFontItalic(true);

    gstringVarFormat.setForeground(stringVarFormat.foreground());
    gstringVarFormat.setFontWeight(QFont::Bold);
    gstringVarFormat.setFontItalic(true);

    // ioFormat.setFontItalic(true);

    QColor color = saturateColor(headerFormat.foreground().color().lighter(150), 150);
    csoundOptionFormat.setForeground(color);
    jsKeywordFormat = keywordFormat;

    m_theme = theme;
    emit this->rehighlight();
}

QTextCharFormat Highlighter::getFormat(QString tag) {
    if(tag == "" || tag == "default") {
        return defaultFormat;
    }
    if(tag == "csdtag")
        return csdtagFormat;
    if(tag == "inst")
        return instFormat;
    if(tag == "keyword")
        return keywordFormat;
    if(tag == "opcode")
        return opcodeFormat;
    if(tag == "singleLineComment")
        return singleLineCommentFormat;
    if(tag == "macroDefine")
        return macroDefineFormat;
    if(tag == "pfield")
        return pfieldFormat;
    QTextCharFormat fallback;
    fallback.setForeground(QColor("black"));
    fallback.setBackground(QColor(250, 250, 250));
    return fallback;
}

Highlighter::Highlighter(QTextDocument *parent)
	: QSyntaxHighlighter(parent)
{
	commentStartExpression = QRegExp("/\\*");
	commentEndExpression = QRegExp("\\*/");

	//  b64encStartExpression = QRegExp("<CsFileB .*>");
	//  b64encEndExpression = QRegExp("<CsFileB>");
	colorVariables = true;
	m_mode = 0; // default to Csound mode

    tagPatterns << "<CsoundSynthesizer>" << "</CsoundSynthesizer>"
				<< "<CsInstruments>" << "</CsInstruments>"
				<< "<CsOptions>" << "</CsOptions>"
				<< "<CsScore>" << "</CsScore>"
				<< "<CsVersion>" << "</CsVersion>"
				<< "<MacOptions>" << "</MacOptions>"
				<< "<MacGUI>" << "</MacGUI>"
				<< "<csLADSPA>" << "</csLADSPA>"
                << "<Cabbage>" << "</Cabbage>"
				<< "<CsHtml5>" << "</CsHtml5>"
                << "<CsFileB>" << "</CsFileB>";

    instPatterns << "instr" << "endin" << "opcode" << "endop";
    headerPatterns << "sr" << "kr" << "ksmps" << "nchnls" << "nchnls_i" << "0dbfs" << "A4"
                   << "zakinit" << "massign";

    keywordLiterals << "init" << "if" << "then" << "endif" << "elseif" << "while" << "goto"
                    << "do" << "od"
                    << "int" << "turnoff" << "xin" << "xout"
                    << "passign";

    ioPatterns      << "in" << "ins" << "inch" << "out" << "outs" << "outch"
                    << "outvalue" << "invalue" << "chnget" << "chnset" << "chn_k" << "chn_a"
                    << "zaw" << "zar" << "zkw" << "zkr" << "zawm"
                    << "OSCsend" << "OSClisten" << "OSCraw" << "OSCinit";

    csoundOptions << "-+rtaudio=" << "-+rtmidi=" << "--nodisplays" << "--nosound"
                  << "--syntax-check-only" << "--control-rate=" << "--messagelevel="
                  << "--env:" << "--dither" << "--sched" << "--omacro:"
                  << "--smacro:" << "--verbose" << "--sample-accurate" << "--realtime"
                  << "--nchnls=" << "--nchnls_i=" << "--sinesize" << "--daemon"
                  << "--port=" << "--use-system-sr" << "--ksmps=" << "-+jack_client="
                  ;

    csoundOptionsRx = QRegExp("--(env|nodisplays|nosound|control-rate|messagelevel=|"
                              "dither|sched|omacro:|smacro:|verbose|sample-accurate|"
                              "realtime|nchnls|nchnls_i|sinesize=|daemon|port=|"
                              "use-system-sr|ksmps|midi-key-cps=|midi-velocity=)");

    csoundOptionsRx2 = QRegExp("-+(rtaudio=|rtmidi=|jack_client=)");

    // For Python
    pythonKeywords << "and" << "or" << "not" << "is"
                   << "global" << "with" << "from" << "import" << "as"
                   << "if" << "else" << "elif"
                   << "print" << "class" << "del" << "exec"
                   << "for" << "in" << "while" << "continue" << "pass" << "break"
                   << "def" << "return" << "lambda"
                   << "yield" << "assert" << "try" << "except" << "finally" << "raise"
                   << "True" << "False" << "None";

	// for html
    htmlKeywords << "<\\ba\\b" << "<\\babbr\\b" << "<\\bacronym\\b" << "<\\baddress\\b"
                 << "<\\bapplet\\b" << "<\\barea\\b" << "<\\barticle\\b" << "<\\baside\\b"
                 << "<\\baudio\\b" << "<\\bb\\b" << "<\\bbase\\b" << "<\\bbasefont\\b"
                 << "<\\bbdi\\b" << "<\\bbdo\\b" << "<\\bbgsound\\b" << "<\\bblockquote\\b"
                 << "<\\bbig\\b" << "<\\bbody\\b" << "<\\bblink\\b" << "<\\bbr\\b"
                << "<\\bbutton\\b" << "<\\bcanvas\\b" << "<\\bcaption\\b" << "<\\bcenter\\b"
                << "<\\bcite\\b" << "<\\bcode\\b" << "<\\bcol\\b" << "<\\bcolgroup\\b"
                << "<\\bcomment\\b" << "<\\bdata\\b" << "<\\bdatalist\\b" << "<\\bdd\\b"
                << "<\\bdel\\b" << "<\\bdetails\\b" << "<\\bdfn\\b" << "<\\bdialog\\b"
                << "<\\bdir\\b" << "<\\bdiv\\b" << "<\\bdl\\b" << "<\\bdt\\b"
                << "<\\bem\\b" << "<\\bembed\\b"
                << "<\\bfieldset\\b" << "<\\bfigcaption\\b" << "<\\bfigure\\b"
                << "<\\bfont\\b" << "<\\bfooter\\b" << "<\\bform\\b" << "<\\bframe\\b"
				<< "<\\bframeset\\b" << "<\\bh1\\b" << "<\\bh2\\b" << "<\\bh3\\b" << "<\\bh4\\b"
				<< "<\\bh5\\b" << "<\\bh6\\b" << "<\\bhead\\b" << "<\\bheader\\b" << "<\\bhgroup\\b"
				<< "<\\bhr\\b" << "<\\bhtml\\b" << "<\\bi\\b" << "<\\biframe\\b" << "<\\bimg\\b"
                << "<\\binput\\b" << "<\\bins\\b" << "<\\bisindex\\b" << "<\\bkbd\\b"
                << "<\\bkeygen\\b" << "<\\blabel\\b" << "<\\blegend\\b" << "<\\bli\\b"
                << "<\\blink\\b" << "<\\blisting\\b" << "<\\bmain\\b" << "<\\bmap\\b"
                << "<\\bmarquee\\b" << "<\\bmark\\b" << "<\\bmenu\\b"
                << "<\\bamenuitem\\b" << "<\\bmeta\\b" << "<\\bmeter\\b" << "<\\bmulticol\\b"
                << "<\\bnav\\b" << "<\\bnobr\\b" << "<\\bnoembed\\b" << "<\\bnoindex\\b"
                << "<\\bnoframes\\b" << "<\\bnoscript\\b" << "<\\bobject\\b" << "<\\bol\\b"
                << "<\\boptgroup\\b" << "<\\boption\\b" << "<\\boutput\\b"
                << "<\\bp\\b" << "<\\bparam\\b" << "<\\bpicture\\b" << "<\\bplaintext\\b"
                << "<\\bpre\\b" << "<\\bprogress\\b" << "<\\bq\\b" << "<\\brp\\b"
                << "<\\brt\\b" << "<\\brtc\\b" << "<\\bruby\\b" << "<\\bs\\b"
                << "<\\bsamp\\b" << "<\\bscript\\b" << "<\\bsection\\b" << "<\\bselect\\b"
                << "<\\bsmall\\b" << "<\\bsource\\b" << "<\\bspacer\\b" << "<\\bspan\\b"
                << "<\\bstrike\\b" << "<\\bstrong\\b" << "<\\bstyle\\b" << "<\\bsub\\b"
                << "<\\bsummary\\b" << "<\\bsup\\b" << "<\\btable\\b" << "<\\btbody\\b"
                << "<\\btd\\b" << "<\\btemplate\\b" << "<\\btextarea\\b"
                << "<\\btfoot\\b" << "<\\bth\\b" << "<\\bthead\\b" << "<\\btime\\b"
                << "<\\btitle\\b" << "<\\btr\\b" << "<\\btrack\\b" << "<\\btt\\b"
                << "<\\bu\\b" << "<\\bul\\b" << "<\\bvar\\b" << "<\\bwbr\\b" << "<\\bxmp\\b"
                << "<!\\bDOCTYPE\\b";

	javascriptKeywords << "function" << "var" << "if" << "===" << "console.log"  << "console.warn";

    // this->setTheme("classic");
}


Highlighter::~Highlighter()
{
}

void Highlighter::setOpcodeNameList(QStringList list)
{
	m_opcodeList = list;
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
    case 4:  // Sco
		highlightCsoundBlock(text);
		break;
    case 5:  // Inc
        highlightCsoundBlock(text); // maybe anything not python or xml should be higlighter as csound?
        break;
	case 6:  // Html
		highlightHtmlBlock(text);
		break;
	}
	// for parenthesis
	TextBlockData *data = new TextBlockData;

	int leftPos = text.indexOf('(');
	while (leftPos != -1) {
		ParenthesisInfo *info = new ParenthesisInfo;
		info->character = '(';
		info->position = leftPos;

		data->insert(info);
		leftPos = text.indexOf('(', leftPos + 1);
	}

	int rightPos = text.indexOf(')');
	while (rightPos != -1) {
		ParenthesisInfo *info = new ParenthesisInfo;
		info->character = ')';
		info->position = rightPos;

		data->insert(info);

		rightPos = text.indexOf(')', rightPos +1);
	}

	setCurrentBlockUserData(data);
}




void Highlighter::highlightCsoundBlock(const QString &text)
{
	// text is processed one line at a time
    if(m_theme == "none")
        return;

	int commentIndex = text.indexOf("//"); // try both comment markings
	if (commentIndex < 0) {
		commentIndex = text.indexOf(';');
	}
	if (commentIndex >= 0) {
		setFormat(commentIndex, text.size() - commentIndex, singleLineCommentFormat);
//		return;
	}
	else {
		commentIndex = text.size() + 1;
    }

    QRegExp regexp;
    int index = 0;
    int length;

    // string
    regexp = QRegExp("\"[^\"]*\"");

    index = text.indexOf(regexp);
    while (index >= 0 && index < commentIndex) {
        length = regexp.matchedLength();
        setFormat(index, length, quotationFormat);
        index = text.indexOf(regexp, index + length);
    }

    // define
    regexp = QRegExp("^\\s*#define\\s+[_\\w\\ \\t]*#.*#");
    index = text.indexOf(regexp);
    if(index >= 0 && index < commentIndex) {
        int length = regexp.matchedLength();
        setFormat(index, length, macroDefineFormat);
        index = text.indexOf(regexp,index+length);
    }

    regexp = QRegExp("\\b(instr|opcode)\\s+(\\w+)\\b");
    index = 0;
    while ((index = regexp.indexIn(text, index)) != -1) {
        auto group = regexp.cap(2);
        length = regexp.matchedLength();
        setFormat(regexp.pos(2), group.length(), nameFormat);
        index += length;
    }

    index = 0;
    while ((index = csoundOptionsRx.indexIn(text, index)) != -1 && index < commentIndex) {
        length = csoundOptionsRx.matchedLength();
        setFormat(index, length, csoundOptionFormat);
        index += length;
    }

    index = 0;
    while ((index = csoundOptionsRx2.indexIn(text, index)) != -1 && index < commentIndex) {
        length = csoundOptionsRx2.matchedLength();
        setFormat(index, length, csoundOptionFormat);
        index += length;
    }

    QRegExp expression("\\b[\\w:]+\\b");
    index = text.indexOf(expression, 0);
    length = expression.matchedLength();

	while (index >= 0 && index < commentIndex) {
		int wordStart = index;
		int wordEnd = wordStart + length;

		if (index>0) {
			auto prev = text.at(index - 1);
			if (prev == '$' || prev == '#') {
				// check if macro name - replacement for regexp solution which I could not find
				wordStart--;
				length++;
				setFormat(wordStart, wordEnd - wordStart, macroDefineFormat);
				index = text.indexOf(expression, wordEnd);
				length = expression.matchedLength();
				continue;
			}
		}
		wordEnd = (wordEnd > 0 ? wordEnd : text.size());
		QString word = text.mid(wordStart, length);
        if (word.indexOf(QRegExp("p[\\d]+\\b")) != -1) {
			setFormat(wordStart, wordEnd - wordStart, pfieldFormat);
		}
		if (instPatterns.contains(word)) {
			setFormat(wordStart, wordEnd - wordStart, instFormat);
			break; // was: return. FOr any case, to go through lines after while loop
		}
		else if (tagPatterns.contains("<" + word + ">") && wordStart > 0) {
            setFormat(wordStart - (text[wordStart - 1] == '/'? 2: 1),
                      wordEnd - wordStart + (text[wordStart - 1] == '/'? 3: 2),
                      csdtagFormat);
		}
		else if (headerPatterns.contains(word)) {
            setFormat(wordStart, wordEnd - wordStart, headerFormat);
		}
        else if (keywordLiterals.contains(word)) {
            setFormat(wordStart, wordEnd - wordStart, keywordFormat);
		}
        else if (ioPatterns.contains(word)) {
            setFormat(wordStart, wordEnd - wordStart, ioFormat);
        }

		else if (word.contains(":")) {
			QStringList parts = word.split(":");
			if (parts.size() == 2) {
				if (findOpcode(parts[0]) >= 0) {
					setFormat(wordStart, wordEnd - wordStart, opcodeFormat);
				}
			}
		}
        else if (findOpcode(word) >= 0) {
			setFormat(wordStart, wordEnd - wordStart, opcodeFormat);
		}
		else if (word.startsWith('a') && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, arateFormat);
		}
        else if (word.startsWith('k') && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, krateFormat);
		}
        else if (word.startsWith('i') && colorVariables) {
            setFormat(wordStart, wordEnd - wordStart, irateFormat);
        }
		else if (word.startsWith("ga")  && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, garateFormat);
		}
        else if (word.startsWith("gk")  && colorVariables) {
			setFormat(wordStart, wordEnd - wordStart, gkrateFormat);
		}
        else if (word.startsWith("gi")  && colorVariables) {
            setFormat(wordStart, wordEnd - wordStart, girateFormat);
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
        int index = 0, length;
        while((index = expression.indexIn(text, index)) != -1 && index < commentIndex) {
            int group = lastHighlightingRules[i].group;
            if(group == 0) {
                length = expression.matchedLength();
                setFormat(index, length, lastHighlightingRules[i].format);
            } else {
                auto capture = expression.cap(group);
                length = expression.matchedLength();
                setFormat(expression.pos(group), capture.length(), lastHighlightingRules[i].format);
            }
            index += length;
        }
    }

	setCurrentBlockState(0);

	int startIndex = 0;
	if (previousBlockState() != 1) {
		startIndex = text.indexOf(commentStartExpression);
	}

	while (startIndex >= 0 && startIndex < commentIndex) {
		int endIndex = text.indexOf(commentEndExpression, startIndex);
		if (format(startIndex) == quotationFormat) {
			startIndex = text.indexOf(commentStartExpression,
									  startIndex + 1);
			continue;
		}
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
    for (int i = 0; i < pythonKeywords.size(); i++) {
        QRegExp expression("\\b+" + pythonKeywords[i] + "\\b+");
		int index = text.indexOf(expression);
		while (index >= 0) {
			int length = expression.matchedLength();
			setFormat(index, length, keywordFormat);
			index = text.indexOf(expression, index + length);
		}
	}
	QRegExp strings( QRegExp("\"[^\"]*\""));
	index = text.indexOf(strings);
	while (index >= 0) {
		int length = strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
	strings = QRegExp("'[^'']*'");
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

// for html

void Highlighter::highlightHtmlBlock(const QString &text)
{
	QRegExp expression("\\b+\\w\\b+");
	int index = text.indexOf(expression, 0);
	for (int i = 0; i < htmlKeywords.size(); i++) {
		QRegExp expression(htmlKeywords[i]);//expression("\\b+" + htmlKeywords[i] + "\\b+");
		int index = text.indexOf(expression);
		while (index >= 0) {
			int length = expression.matchedLength();
			setFormat(index, length, keywordFormat);
			index = text.indexOf(expression, index + length);
		}
	}

	for (int i=0; i<javascriptKeywords.size(); i++) {
		QRegExp expression("\\b+" + javascriptKeywords[i] + "\\b+");
		int index = text.indexOf(expression);
		while (index >= 0) {
			int length = expression.matchedLength();
			setFormat(index, length, jsKeywordFormat); // TODO javascriptformat
			index = text.indexOf(expression, index + length);
		}
	}

	QRegExp endTag( QRegExp(">$"));
	index = text.indexOf(endTag);
	while (index >= 0) {
		int length = endTag.matchedLength();
		setFormat(index, length, keywordFormat);
		index = text.indexOf(endTag, index + length);
	}

	QRegExp strings( QRegExp("\"[^\"]*\""));
	index = text.indexOf(strings);
	while (index >= 0) {
		int length = strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
	strings = QRegExp("'[^'']*'");
	index = text.indexOf(strings);
	while (index >= 0) {
		int length = strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
	int commentIndex = -1;
	QRegExp expComment("//.*"); // TODO: avaoid https://
	index = text.indexOf(expComment);
	if (index>0 ) {
		if (text.at(index-1)!=':') { // clumsy way to avoid addresses like https://
			while (index >= 0) { // did not manage to do it with regular expression
				int length = expComment.matchedLength();
				setFormat(index, length, singleLineCommentFormat);
				index = text.indexOf(expComment, index + length);
			}
			commentIndex = index; // better do other way
		}
	}

//	if (commentIndex >= 0) {
//		setFormat(commentIndex, text.size() - commentIndex, singleLineCommentFormat);
////		return;
//	}
	if (commentIndex < 0) {
		commentIndex = text.size() + 1;
	}

	// multiline
	setCurrentBlockState(0);
	QRegExp htmlCommentStartExpression = QRegExp("<!--");
	QRegExp htmlCommentEndExpression = QRegExp("-->");


	int startIndex = 0;
	if (previousBlockState() != 1) {
		startIndex = text.indexOf(htmlCommentStartExpression);
	}

	while (startIndex >= 0 && startIndex < commentIndex) {
		int endIndex = text.indexOf(htmlCommentEndExpression, startIndex);
		if (format(startIndex) == quotationFormat) {
			startIndex = text.indexOf(htmlCommentStartExpression,
									  startIndex + 1);
			continue;
		}
		int commentLength;
		if (endIndex == -1) {
			setCurrentBlockState(1);
			commentLength = text.length() - startIndex;
		} else {
			commentLength = endIndex - startIndex
					+ htmlCommentEndExpression.matchedLength();
		}
		setFormat(startIndex, commentLength, multiLineCommentFormat);
		startIndex = text.indexOf(htmlCommentStartExpression,
								  startIndex + commentLength);
	}
}

// void Highlighter::setFirstRules()
// {
//   highlightingRules.clear();
// }

void Highlighter::setLastRules()
{
	HighlightingRule rule;

    rule = {QRegExp("^\\s*([a-zA-Z]\\w*):\\s*"), labelFormat, 1};
    lastHighlightingRules.append(rule);

    // strings
    rule = {QRegExp("\"[^\"]*\""), quotationFormat, 0};
    lastHighlightingRules.append(rule);

    // multi line strings
    rule = {QRegExp("\\{\\{.*"), quotationFormat, 0};
	lastHighlightingRules.append(rule);

    // end multi line strings
    rule = {QRegExp(".*\\}\\}"), quotationFormat, 0};
	lastHighlightingRules.append(rule);
}

int Highlighter::findOpcode(QString opcodeName, int start, int end)
{
	//   fprintf(stderr, "%i - %i\n", start, end);
	Q_ASSERT(m_opcodeList.size() > 0);
	if (end == -1) {
		end = m_opcodeList.size() -1;
	}
	int pos = ((end - start)/2) + start;
	if (opcodeName == m_opcodeList[pos])
		return pos;
	else if (start == end)
		return -1;
	else if (opcodeName < m_opcodeList[pos])
		return findOpcode(opcodeName, start, pos);
	else if (opcodeName > m_opcodeList[pos])
		return findOpcode(opcodeName, pos + 1, end);
	return -1;
}
