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
#include "types.h"

#include <QRegularExpression>


TextBlockData::TextBlockData()
{
	// Nothing to do
    section = UnknownSection;
}

QVector<ParenthesisInfo *> TextBlockData::parentheses()
{
	return m_parentheses;
}


void TextBlockData::insert(ParenthesisInfo *info)
{
	int i = 0;
    while (i < m_parentheses.size() && info->position > m_parentheses.at(i)->position)
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

        headerFormat.setForeground(QColor("brown"));
        headerFormat.setFontWeight(QFont::Bold);

        opcodeFormat.setForeground(QColor("blue"));
        opcodeFormat.setFontWeight(QFont::Bold);
        deprecatedFormat = opcodeFormat;

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

        booleanFormat.setForeground(QColor("darkorange"));
        booleanFormat.setFontWeight(QFont::Bold);

        complexFormat.setForeground(QColor("teal"));
        complexFormat.setFontWeight(QFont::Bold);

        labelFormat.setForeground(QColor(205,92,92));
        labelFormat.setFontWeight(QFont::Bold);

        nameFormat.setForeground(QColor("#880E4F"));
        nameFormat.setFontWeight(QFont::Bold);
        // nameFormat.setFontUnderline(true);

        quotationFormat.setForeground(Qt::red);
        multiLineCommentFormat.setForeground(QColor("green"));

        ioFormat = opcodeFormat;
        udoFormat = opcodeFormat;
        operatorFormat = defaultFormat;
        importantCommentFormat = singleLineCommentFormat;
        scoreLetterFormat = opcodeFormat;
    }
    else if(theme == "light") {
        defaultFormat.setForeground(QColor("#030303"));
        defaultFormat.setBackground(QColor("#F9F9F9"));

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

        deprecatedFormat.setForeground(QColor("#880000"));
        deprecatedFormat.setFontUnderline(true);

        singleLineCommentFormat.setForeground(QColor("#8F8F7F"));
        singleLineCommentFormat.setFontItalic(true);


        importantCommentFormat.setBackground(QColor("#FFFFA0"));
        importantCommentFormat.setForeground(
                    singleLineCommentFormat.foreground().color().darker(150));
        // importantCommentFormat.setFontItalic(true);

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

        booleanFormat.setForeground(QColor("#E65100"));
        booleanFormat.setFontWeight(QFont::Bold);

        complexFormat.setForeground(QColor("#00695C"));
        complexFormat.setFontWeight(QFont::Bold);

        labelFormat.setForeground(QColor(205,92,92));
        labelFormat.setFontWeight(QFont::Bold);
        labelFormat.setFontUnderline(true);

        nameFormat.setForeground(QColor("#F50057"));
        nameFormat.setFontWeight(QFont::Bold);
        // nameFormat.setFontUnderline(true);

        // quotationFormat.setForeground(QColor("#4CAf50"));
        quotationFormat.setForeground(QColor("#827717"));
        multiLineCommentFormat.setForeground(quotationFormat.foreground());

        ioFormat.setForeground(QColor("#8844BB"));
        ioFormat.setFontWeight(QFont::Bold);
        // ioFormat.setFontItalic(true);

        udoFormat = opcodeFormat;
        udoFormat.setForeground(opcodeFormat.foreground().color().darker(150));

        csdtagFormat.setForeground(instFormat.foreground());

        operatorFormat.setForeground(instFormat.foreground().color());

        scoreLetterFormat.setForeground(opcodeFormat.foreground());
        scoreLetterFormat.setFontWeight(QFont::Bold);

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

        deprecatedFormat.setForeground(saturateColor(opcodeFormat.foreground().color(), 50));
        deprecatedFormat.setUnderlineColor("#880000");
        deprecatedFormat.setFontUnderline(true);

        // singleLineCommentFormat.setForeground(QColor("#9F9F8F"));
        singleLineCommentFormat.setForeground(QColor("#856CB0"));
        singleLineCommentFormat.setFontItalic(true);

        importantCommentFormat.setBackground(defaultFormat.background().color().lighter(140));
        importantCommentFormat.setForeground(
                    singleLineCommentFormat.foreground().color().lighter(175));

        macroDefineFormat.setForeground(QColor("#F06292"));
        macroDefineFormat.setFontWeight(QFont::Bold);

        pfieldFormat.setFontWeight(QFont::Bold);

        krateFormat.setForeground(QColor("#66EEBB"));
        irateFormat.setForeground(QColor("#FFFFFF"));

        arateFormat.setForeground(QColor("#F75C5C"));
        arateFormat.setFontWeight(QFont::Bold);


        fsigFormat.setForeground(QColor("#BD2467"));
        fsigFormat.setFontWeight(QFont::Bold);

        booleanFormat.setForeground(QColor("#FFB74D"));
        booleanFormat.setFontWeight(QFont::Bold);

        complexFormat.setForeground(QColor("#4DD0E1"));
        complexFormat.setFontWeight(QFont::Bold);

        labelFormat.setForeground(instFormat.foreground());
        labelFormat.setFontWeight(QFont::Bold);
        labelFormat.setFontUnderline(true);

        nameFormat.setForeground(QColor("#D298FB"));
        nameFormat.setFontWeight(QFont::Bold);

        // quotationFormat.setForeground(QColor("#66FFAA"));
        quotationFormat.setForeground(QColor("#91FF55"));
        stringVarFormat.setForeground(quotationFormat.foreground());
        stringVarFormat.setFontWeight(QFont::Normal);

        multiLineCommentFormat.setForeground(quotationFormat.foreground());

        ioFormat.setForeground(QColor("#FFD54F"));
        ioFormat.setFontWeight(QFont::Bold);

        udoFormat.setForeground(opcodeFormat.foreground());
        udoFormat.setFontWeight(QFont::Normal);

        // ioFormat.setFontItalic(true);
        csdtagFormat.setForeground(instFormat.foreground());
        operatorFormat.setForeground(nameFormat.foreground().color());

        scoreLetterFormat.setForeground(opcodeFormat.foreground());
        scoreLetterFormat.setFontWeight(QFont::Bold);

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

    errorFormat.setForeground(deprecatedFormat.foreground().color());
    errorFormat.setFontStrikeOut(true);

    importantCommentFormat.setFontWeight(QFont::Bold);

    // ioFormat.setFontItalic(true);

    QColor color = saturateColor(headerFormat.foreground().color().lighter(150), 150);
    csoundOptionFormat.setForeground(color);

    // html
    htmlTagFormat = csdtagFormat;
    tagNameFormat = arateFormat;
    attrFormat = irateFormat;
    jsKeywordFormat =  krateFormat;// keywordFormat;

    m_theme = theme;
    clearTypedVars();
    rehighlight();
    // emit this->rehighlight();
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
    commentStartExpression.setPattern("/\\*");
    commentEndExpression.setPattern("\\*/");

    //  b64encStartExpression = QRegularExpression("<CsFileB .*>");
    //  b64encEndExpression = QRegularExpression("<CsFileB>");
	colorVariables = true;
	m_mode = 0; // default to Csound mode
    m_scoreSyntaxHighlighting = true;
    m_sectionType = CsdSection::UnknownSection;

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
                << "<CsFileB>" << "</CsFileB>"
                << "<CsLicense>" << "</CsLincense>";

    instPatterns << "instr" << "endin" << "opcode" << "endop";
    headerPatterns << "sr" << "kr" << "ksmps" << "nchnls" << "nchnls_i" << "0dbfs" << "A4"
                   << "zakinit" << "massign";

    keywordLiterals << "init" << "if" << "then" << "else" << "endif" << "elseif"
                    << "while" << "goto" << "igoto" << "kgoto"
                    << "do" << "od"
                    << "int" << "turnoff" << "xin" << "xout"
                    << "passign"
                    // Csound 7 keywords
                    << "create" << "delete" << "run" << "struct" << "for" << "global"
                    << "InstrDef" << "Instr";

    ioPatterns      << "in" << "ins" << "inch" << "out" << "outs" << "outch"
                    << "outvalue" << "invalue" << "chnget" << "chngetk" << "chnset" << "chn_k"
                    << "chn_a" << "chn_S" << "zaw" << "zar" << "zkw" << "zkr" << "zawm"
                    << "OSCsend" << "OSClisten" << "OSCraw" << "OSCinit";

    // look here for checking if an opcode is deprecated: https://csound.com/docs/manual/DeprecatedTop.html
    deprecatedOpcodes << "abetarand" << "abexprnd" << "acauchy" << "aexprand" << "agauss" << "agogobel"
                      << "alinrand" << "apcauchy" << "apoisson" << "apow" << "array" << "atrirand"
                      << "aunirand" << "aweibull"
                      << "bformdec" << "bformenc"
                      << "clock"
                      << "fin"
                      << "hrtfer"
                      << "ibetarand" << "ibexprnd" << "icauchy" << "ictrl14" << "ictrl21" << "ictrl7"
                      << "iexprand" << "igauss" << "ilinrand" << "imidic14" << "imidic21" << "imidic7"
                      << "instimek" << "instimes" << "ioff" << "ion" << "iondur2" << "iondur" << "ioutat"
                      << "ioutc14" << "ioutc" << "ioutpat" << "ioutpb" << "ioutpc" << "ipcauchy"
                      << "ipoisson" << "ipow" << "is16b14" << "is32b14" << "islider16" << "islider32"
                      << "islider64" << "islider8" << "itablecopy" << "itablegpw" << "itablemix"
                      << "itablew" << "itrirand" << "iunirand" << "iweibull"
                      << "kbetarand" << "kbexprnd" << "kcauchy" << "kdump2" << "kdump3" << "kdump4"
                      << "kdump" << "kexprand" << "kfilter2" << "kgauss" << "klinrand" << "kon"
                      << "koutat" << "koutc14" << "koutc" << "koutpat" << "koutpb" << "koutpc"
                      << "kpcauchy" << "kpoisson" << "kpow" << "kread2" << "kread3" << "kread4"
                      << "kread" << "ktableseg" << "ktrirand" << "kunirand" << "kweibull"
                      << "peakk" << "pop" << "pop_f" << "ptable" << "ptablei" << "ptable3" << "ptablew"
                      << "push" << "push_f"
                      << "sc_lag" << "sc_lagud" << "sc_phasor" << "sc_trig"
                      << "sndload" << "soundout" << "soundouts" << "stack"
                      << "tb" << "tableiw"
                      << "xscanmap" << "xscansmap" << "xscans" << "xscanu"
                      ;

    operatorPatterns << "&&" << "||";

    csoundOptions << "-+rtaudio=" << "-+rtmidi=" << "--nodisplays" << "--nosound"
                  << "--syntax-check-only" << "--control-rate=" << "--messagelevel="
                  << "--env:" << "--dither" << "--sched" << "--omacro:"
                  << "--smacro:" << "--verbose" << "--sample-accurate" << "--realtime"
                  << "--nchnls=" << "--nchnls_i=" << "--sinesize" << "--daemon"
                  << "--port=" << "--use-system-sr" << "--ksmps=" << "-+jack_client="
                  << "--limiter" << "--udp-echo" << "--opcode-dir="
                  ;

    csoundOptionsRx = QRegularExpression(
                        "-(-(env|nodisplays|nosound|control-rate|messagelevel="
                        "|dither|sched|omacro:|smacro:|verbose|sample-accurate|"
                        "realtime|nchnls|nchnls_i|sinesize=|daemon|port=|use-system-sr|"
                        "ksmps|midi-key-cps=|midi-velocity=)|"
                        "\\+(rtaudio=|rtmidi=|jack_client=))");
    /*
    csoundOptionsRx = QRegularExpression("--(env|nodisplays|nosound|control-rate|messagelevel=|"
                              "dither|sched|omacro:|smacro:|verbose|sample-accurate|"
                              "realtime|nchnls|nchnls_i|sinesize=|daemon|port=|"
                              "use-system-sr|ksmps|midi-key-cps=|midi-velocity=)");
    */
    csoundOptionsRx2 = QRegularExpression("-+(rtaudio=|rtmidi=|jack_client=)");


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
    /* not used at the moment as tags are highlighted
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
    */

    javascriptKeywords
        << "break" << "case" << "catch" << "class" << "const" << "continue"
        << "debugger" << "default" << "delete" << "do" << "else" << "enum"
        << "export" << "extends" << "false" << "finally" << "for" << "function"
        << "if" << "import" << "in" << "instanceof" << "let" << "new"
        << "null" << "return" << "super" << "switch" << "this" << "throw"
        << "true" << "try" << "typeof" << "var" << "void" << "while"
        << "with" << "yield"
        // ES2015+ keywords
        << "await" << "async" << "of"
        // Common built-ins and objects
        << "Array" << "Date" << "eval" << "function" << "hasOwnProperty"
        << "Infinity" << "isFinite" << "isNaN" << "isPrototypeOf" << "length"
        << "Math" << "NaN" << "name" << "Number" << "Object" << "prototype"
        << "String" << "toString" << "undefined" << "valueOf"
        // Global objects
        << "console" << "console.log" << "console.warn" << "console.error"
        << "window" << "document" << "alert" << "parseInt" << "parseFloat"
        << "setTimeout" << "setInterval" << "Promise" << "RegExp" << "Error"
        // Special values
        << "undefined" << "null" << "true" << "false";

    QStringList jsOperators = { // not implemented at the moment
        "+", "-", "*", "/", "===", "==", "=", "++", "--", "&&", "||", "!", ">", "<", ">=", "<=", "!=", "!=="
    };

    rxScoreLetter.setPattern("^\\s*(i|f|e|d|s)");
    rxQuotation.setPattern("\"[^\"]*\"");

    // this->setTheme("classic");
}


Highlighter::~Highlighter()
{
}

void Highlighter::setOpcodeNameList(QStringList list)
{
	m_opcodeList = list;
    m_opcodesSet = QSet<QString>(list.begin(), list.end());
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

void Highlighter::clearTypedVars()
{
    m_iVariables.clear();
    m_kVariables.clear();
    m_aVariables.clear();
    m_SVariables.clear();
    m_fVariables.clear();
    m_bVariables.clear();
    m_complexVariables.clear();
    m_instrDefVariables.clear();
    m_opcodeVariables.clear();
    m_structVariables.clear();
    m_userTypeNames.clear();
}

QTextCharFormat Highlighter::formatForType(const QString &typeStr) const
{
    QString t = typeStr;
    t.remove("[]");
    if(t == "i") return irateFormat;
    if(t == "k") return krateFormat;
    if(t == "a") return arateFormat;
    if(t == "S") return stringVarFormat;
    if(t == "f") return fsigFormat;
    if(t == "b" || t == "B") return booleanFormat;
    if(t == "Complex") return complexFormat;
    if(t == "InstrDef" || t == "Instr") return nameFormat;
    if(t == "Opcode") return opcodeFormat;
    if(m_userTypeNames.contains(t)) return nameFormat;
    return defaultFormat;
}

void Highlighter::registerTypedVar(const QString &name, const QString &typeStr)
{
    QString t = typeStr;
    t.remove("[]");
    if(t == "i")                          m_iVariables.insert(name);
    else if(t == "k")                     m_kVariables.insert(name);
    else if(t == "a")                     m_aVariables.insert(name);
    else if(t == "S")                     m_SVariables.insert(name);
    else if(t == "f")                     m_fVariables.insert(name);
    else if(t == "b" || t == "B")         m_bVariables.insert(name);
    else if(t == "Complex")               m_complexVariables.insert(name);
    else if(t == "InstrDef" || t == "Instr") m_instrDefVariables.insert(name);
    else if(t == "Opcode")                m_opcodeVariables.insert(name);
    else if(m_userTypeNames.contains(t))  m_structVariables.insert(name);
}

void Highlighter::highlightBlock(const QString &text)
{
    if(m_theme == "none")
        return;

    // for parenthesis
    auto data = static_cast<TextBlockData*>(currentBlockUserData());
    if(data == nullptr) {
        data = new TextBlockData;
    }
    else {
        data->clearParenthesis();
    }

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

    if(m_theme != "none") {
        // find previous valid block
        auto block = currentBlock().previous();
        while (block.isValid()) {
            auto userData = static_cast<TextBlockData*>(block.userData());
            if(userData != nullptr) {
                data->section = userData->section;
                break;
            }
            block = block.previous();
        }
    }

    switch (m_mode) { // mode is set by the file type
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

}


void Highlighter::highlightScore(const QString &text, int start, int end) {
    // things to highlight:
    // 1) score command (i, f, e, etc)
    // 2) strings
    // 3) macros: $foo
    // qDebug() << "highlighting score text: " << text << "\n";
    // return;
    // QRegularExpression rx;
    // rx.setPattern("^\\s*(i|f|e|d|s)");
    QRegularExpressionMatch match;
    match = rxScoreLetter.match(text, start);
    if(match.hasMatch()) {
        setFormat(match.capturedStart(1), 1, scoreLetterFormat);
    }
    int pos = start;
    while(pos < end) {
        match = rxQuotation.match(text, pos);
        if(!match.hasMatch())
            break;
        setFormat(match.capturedStart(), match.capturedLength(), quotationFormat);
        pos = match.capturedEnd() + 1;
    }
    /*
    pos = start;
    rx.setPattern("\\$[a-zA-Z_]\\w+");
    while(pos < end) {
        match = rx.match(text, pos);
        if(!match.hasMatch())
            break;
        setFormat(match.capturedStart(), match.capturedLength(), macroDefineFormat);
        pos = match.capturedEnd() + 1;
    }
    */
}


void Highlighter::highlightCsoundBlock(const QString &line)
{
    QRegularExpression rx;
    QRegularExpressionMatch rxmatch;

	// text is processed one line at a time
    if(m_theme == "none")
        return;

    // comments first

    // multiline comments
    setCurrentBlockState(0);

    int startIndex = 0;
    //int commentIndex = -1;
    if(previousBlockState() != 1) {
        rxmatch = commentStartExpression.match(line, 0);
        startIndex = rxmatch.hasMatch() ? rxmatch.capturedStart() : -1;
    }

    QRegularExpressionMatch endMatch;

    while (startIndex >= 0 ) {
        endMatch = commentEndExpression.match(line, startIndex);
        int endIndex = endMatch.hasMatch() ? endMatch.capturedStart() : -1;
        int commentLength;
        if (endIndex == -1) {
            setCurrentBlockState(1);
            commentLength = line.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + endMatch.capturedLength();
        }
        setFormat(startIndex, commentLength, multiLineCommentFormat);
        rxmatch = commentStartExpression.match(line, startIndex + commentLength);
        startIndex = rxmatch.hasMatch() ? rxmatch.capturedStart() : -1;
    }

    // single line comments
    int commentIndex = line.indexOf(';'); // try both comment markings
	if (commentIndex < 0) {
        commentIndex = line.indexOf("//");
	}

    if(commentIndex >= 0) {
        if(line[commentIndex] == ';' && line.size() > commentIndex+1 && line[commentIndex+1] == ';') {
            setFormat(commentIndex, line.size() - commentIndex, importantCommentFormat);
            return;
        } else {
            setFormat(commentIndex, line.size() - commentIndex, singleLineCommentFormat);
        }
    } else {
        commentIndex = line.size() + 1;
    }

    int index = 0;
    int length = 0;

    auto blockdata = static_cast<TextBlockData*>(currentBlockUserData());

    rx.setPattern("^\\s*<\\/?(CsInstruments|CsOptions|CsoundSynthesizer|CsScore|CsFileB|CsLicense|html).*>");
    rxmatch = rx.match(line);
    if(rxmatch.hasMatch() ) {
        if(rxmatch.captured(1) == "CsInstruments" ) {
            blockdata->section = OrchestraSection;
        } else if(rxmatch.captured(1) == "CsScore" ) {
            blockdata->section = ScoreSection;
        } else if(rxmatch.captured(1) == "CsOptions" )  {
            blockdata->section = OptionsSection;
        } else if(rxmatch.captured(1) == "html" )  {
            blockdata->section = HtmlSection;
        } else {
            blockdata->section = UnknownSection;
        }
        setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(), csdtagFormat);
        return;
    }

    if(blockdata->section == ScoreSection || m_sectionType == ScoreSection) {
        if(m_scoreSyntaxHighlighting) {
            highlightScore(line, 0, commentIndex);
        }
        return;
    } else if (blockdata->section == HtmlSection || m_sectionType == HtmlSection) {
        highlightHtmlBlock(line);
        return;
    } else if(blockdata->section == OptionsSection || m_sectionType == OptionsSection ) {
        index = 0;
        while((rxmatch = csoundOptionsRx.match(line, index)).hasMatch()) {
            length = rxmatch.capturedLength();
            setFormat(rxmatch.capturedStart(), length, csoundOptionFormat);
            index += length;
        }
        return;
    }
    else if(blockdata->section == OrchestraSection || m_sectionType == OrchestraSection) {
        //auto text = QStringRef(&line, 0, commentIndex);
        auto text = QStringView(line).mid(0,commentIndex);

        if (format(0)==multiLineCommentFormat) {
            return;
        }

        // define
        rx.setPattern("^\\s*#define\\s+[_\\w\\ \\t]*#.*#");
        rxmatch = rx.match(text);
        if(rxmatch.hasMatch()) {
            setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(), macroDefineFormat);
            return;
        }

        rx.setPattern("^\\s*\\b(instr|opcode)\\s+(\\w+)\\b");
        rxmatch = rx.match(text);
        if(rxmatch.hasMatch()) {
            //auto group = rxmatch.captured(2);
            setFormat(rxmatch.capturedStart(1), rxmatch.capturedLength(1), instFormat);
            setFormat(rxmatch.capturedStart(2), rxmatch.capturedLength(2), nameFormat);
            return;
        }

        // Csound 7: detect struct type definitions, e.g. "struct MyType val0:i, val1:i"
        {
            static const QRegularExpression structRx("^\\s*\\bstruct\\b\\s+(\\w+)\\b");
            rxmatch = structRx.match(text);
            if(rxmatch.hasMatch() && rxmatch.capturedStart(1) < commentIndex) {
                m_userTypeNames.insert(rxmatch.captured(1));
                setFormat(rxmatch.capturedStart(1), rxmatch.capturedLength(1), nameFormat);
                // 'struct' keyword will be formatted by the word loop via keywordLiterals
            }
        }

        // Csound 7: detect @global typed variable definitions, e.g. "maxamp@global:i = 0dbfs / 5"
        // Register the var name in the appropriate typed set so later uses are highlighted.
        {
            static const QRegularExpression globalRx("(\\w+)@global:(\\w+(?:\\[\\])?)");
            QRegularExpressionMatchIterator globalIt = globalRx.globalMatch(text);
            while(globalIt.hasNext()) {
                auto m = globalIt.next();
                if(m.capturedStart() < commentIndex) {
                    registerTypedVar(m.captured(1), m.captured(2));
                }
            }
        }

        rx.setPattern(R"(&&|==|\|\||<|>|<=|>=|!=|\\)");
        index = 0;
        while((rxmatch=rx.match(text, index)).hasMatch()) {
            length = rxmatch.capturedLength();
            setFormat(rxmatch.capturedStart(), length, operatorFormat);
            index = rxmatch.capturedEnd()+1;
        }

        static const QRegularExpression expressionRx("\\b[\\w:]+\\b");
        static const QRegularExpression pfieldRx("\\bp[\\d]+\\b");
        index = 0;
        while((rxmatch = expressionRx.match(text, index)).hasMatch()) {
            int wordStart = rxmatch.capturedStart();
            int wordEnd = rxmatch.capturedEnd();
            index = wordEnd;

            if(wordStart > 0) {
                auto prev = text.at(wordStart - 1);
                if(prev == '$' || prev == '#') {
                    // check if macro name - replacement for regexp solution
                    setFormat(wordStart-1, wordEnd - wordStart + 1, macroDefineFormat);
                    index = wordEnd;
                    continue;
                }
            }
            wordEnd = (wordEnd > 0 ? wordEnd : text.size());
            QString word = rxmatch.captured();
            if(pfieldRx.match(word).hasMatch()) {
                setFormat(wordStart, wordEnd - wordStart, pfieldFormat);
            }
            else if(instPatterns.contains(word)) {
                setFormat(wordStart, wordEnd - wordStart, instFormat);
                break; // was: return. For any case, to go through lines after while loop
            }
            else if(tagPatterns.contains("<" + word + ">") && wordStart > 0) {
                setFormat(wordStart - (text[wordStart - 1] == '/'? 2: 1),
                          wordEnd - wordStart + (text[wordStart - 1] == '/'? 3: 2),
                          csdtagFormat);
            }
            else if(headerPatterns.contains(word)) {
                setFormat(wordStart, wordEnd - wordStart, headerFormat);
            }
            else if(keywordLiterals.contains(word)) {
                setFormat(wordStart, wordEnd - wordStart, keywordFormat);
            }
            else if(ioPatterns.contains(word)) {
                setFormat(wordStart, wordEnd - wordStart, ioFormat);
            }
            else if(word[word.size()-1] != ':' && word.contains(":")) {
                auto parts = word.split(":");
                if (parts.size() == 2) {
                    const QString &varName  = parts[0];
                    const QString &typeName = parts[1];
                    // "@global:type" annotation: the token is "global:type", preceded by '@'
                    if(wordStart > 0 && text.at(wordStart - 1) == '@') {
                        // Highlight "@global:type" together as a keyword annotation
                        setFormat(wordStart - 1, wordEnd - wordStart + 1, keywordFormat);
                    }
                    else if(isOpcode(varName)) {
                        // functional style opcode:type(...) — existing behaviour
                        setFormat(wordStart, wordEnd - wordStart, opcodeFormat);
                    }
                    else {
                        // Csound 7: typed variable definition  varname:type
                        static const QSet<QString> builtinTypes = {
                            "i", "k", "a", "S", "f", "b", "B",
                            "Complex", "InstrDef", "Instr", "Opcode"
                        };
                        QString typeBase = typeName;
                        typeBase.remove("[]");
                        if(builtinTypes.contains(typeBase) || m_userTypeNames.contains(typeBase)) {
                            registerTypedVar(varName, typeName);
                            // varname portion — colour by its type
                            setFormat(wordStart, varName.size(), formatForType(typeName));
                            // ":type" portion — highlight as keyword
                            setFormat(wordStart + varName.size(),
                                      wordEnd - wordStart - varName.size(),
                                      keywordFormat);
                        }
                    }
                }
                else {
                    setFormat(wordStart, wordEnd - wordStart, errorFormat);
                }
            }
            else if(m_parsedUDOs.contains(word)) {
                setFormat(wordStart, wordEnd - wordStart, udoFormat);
            }
            else if(deprecatedOpcodes.contains(word)) {
                setFormat(wordStart, wordEnd - wordStart, deprecatedFormat);
            }
            else if(isOpcode(word)) {
                setFormat(wordStart, wordEnd - wordStart, opcodeFormat);
            }
            else if(colorVariables) {
                // Csound 7: check explicitly typed variable sets first
                if(m_aVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, arateFormat);
                }
                else if(m_kVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, krateFormat);
                }
                else if(m_iVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, irateFormat);
                }
                else if(m_SVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, stringVarFormat);
                }
                else if(m_fVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, fsigFormat);
                }
                else if(m_bVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, booleanFormat);
                }
                else if(m_complexVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, complexFormat);
                }
                else if(m_instrDefVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, nameFormat);
                }
                else if(m_opcodeVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, opcodeFormat);
                }
                else if(m_structVariables.contains(word)) {
                    setFormat(wordStart, wordEnd - wordStart, nameFormat);
                }
                // Fall back to classic prefix-based detection
                else if(word.startsWith('a')) {
                    setFormat(wordStart, wordEnd - wordStart, arateFormat);
                }
                else if(word.startsWith('k')) {
                    setFormat(wordStart, wordEnd - wordStart, krateFormat);
                }
                else if(word.startsWith('i')) {
                    setFormat(wordStart, wordEnd - wordStart, irateFormat);
                }
                else if(word.startsWith("ga")) {
                    setFormat(wordStart, wordEnd - wordStart, garateFormat);
                }
                else if(word.startsWith("gk")) {
                    setFormat(wordStart, wordEnd - wordStart, gkrateFormat);
                }
                else if(word.startsWith("gi")) {
                    setFormat(wordStart, wordEnd - wordStart, girateFormat);
                }
                else if(word.startsWith("S")) {
                    setFormat(wordStart, wordEnd - wordStart, stringVarFormat);
                }
                else if(word.startsWith("gS")) {
                    setFormat(wordStart, wordEnd - wordStart, gstringVarFormat);
                }
                else if(word.startsWith("f")) {
                    setFormat(wordStart, wordEnd - wordStart, fsigFormat);
                }
                else if(word.startsWith("gf")) {
                    setFormat(wordStart, wordEnd - wordStart, gfsigFormat);
                }
            }

        }

        // string
        rx.setPattern("\"[^\"]*\"");
        index = 0;
        while ((rxmatch = rx.match(text, index)).hasMatch()) {
            setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(), quotationFormat);
            index = rxmatch.capturedEnd();
        }

        //last rules  -- earlier for label, npw not used any more
        // for(auto rule: lastHighlightingRules) {
        //     index = 0;
        //     while((rxmatch = rule.pattern.match(text, index)).hasMatch()) {
        //         int group = rule.group;
        //         //qDebug() << "last rule matched: " << rule.pattern.pattern();
        //         setFormat(rxmatch.capturedLength(group), rxmatch.capturedStart(group), rule.format);
        //         index = rxmatch.capturedEnd();
        //     }
        // }

        // label (separate)
        rx.setPattern("^\\s*([a-zA-Z]\\w*):\\s*$");
        rxmatch = rx.match(text);

        if (rxmatch.hasMatch()) {
            setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(), labelFormat);
            // setFormat(rxmatch.capturedEnd(1), 1, colonFormat);
            return;
        }

        // Multiline {{ ... }} strings
        if (previousBlockState() == 2) {
            int endIdx = line.indexOf("}}");
            if (endIdx == -1) {
                setFormat(0, line.length(), quotationFormat);
                setCurrentBlockState(2);
                return;
            } else {
                setFormat(0, endIdx + 2, quotationFormat);
                setCurrentBlockState(0);  // string closed
            }
        }

        int startIdx = line.indexOf("{{");
        while (startIdx >= 0) {
            int endIdx = line.indexOf("}}", startIdx + 2);
            int stringLength;
            if (endIdx == -1) {
                setCurrentBlockState(2);
                stringLength = line.length() - startIdx;
            } else {
                stringLength = endIdx - startIdx + 2;
            }
            setFormat(startIdx, stringLength, quotationFormat);

            if (endIdx == -1)
                break;
            else
                startIdx = line.indexOf("{{", endIdx + 2);
        }
    } else {
        return;
    }
}


void Highlighter::highlightPythonBlock(const QString &text)
{
    //static const QRegularExpression expression("\\b\\w\\b");
    //int index = text.indexOf(expression, 0);
    for (int i = 0; i < pythonKeywords.size(); i++) {
        QRegularExpression expression("\\b" + pythonKeywords[i] + "\\b");
		int index = text.indexOf(expression);
		while (index >= 0) {
            // Qt6: Test this substitution and compare with Qt 5!!!
            int length = expression.match(pythonKeywords[i]).capturedLength();// was: expression.matchedLength();
			setFormat(index, length, keywordFormat);
			index = text.indexOf(expression, index + length);
		}
	}
    static const QRegularExpression strings("\"[^\"]*\"");
    int index = text.indexOf(strings);
	while (index >= 0) {
        int length = strings.match(text).capturedLength();//strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
    static const QRegularExpression strings2("'[^'']*'");
    index = text.indexOf(strings2);
	while (index >= 0) {
        int length = strings.match(text).capturedLength(); // strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
    static const QRegularExpression  expComment("#.*");
    index = text.indexOf(expComment);
	while (index >= 0) {
        int length = expComment.match(text).capturedLength();//expComment.matchedLength();
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
    //QRegularExpression expression("\\b\\w\\b");
    //int index = text.indexOf(expression, 0);

    // htmlKeywords seems not needed, as the tags are highlighted anyway
/*
    for (int i = 0; i < htmlKeywords.size(); i++) {
        QRegularExpression expression("\\b" + htmlKeywords[i] + "\\b");
        int index = text.indexOf(expression);
        while (index >= 0) {
            int length = expression.match(text).capturedLength();
            setFormat(index, length, keywordFormat); // keyword format
            index = text.indexOf(expression, index + length);
        }
    }
*/
    // TODO: NB! duplicated code! create separate function
    QRegularExpression rx;
    QRegularExpressionMatch rxmatch;
    // check what type of block it is:
    auto blockdata = static_cast<TextBlockData*>(currentBlockUserData());

    rx.setPattern("^\\s*<\\/?(CsInstruments|CsOptions|CsoundSynthesizer|CsScore|CsFileB|CsLicense|html).*>");
    rxmatch = rx.match(text);
    if(rxmatch.hasMatch() ) {
        if(rxmatch.captured(1) == "CsInstruments" ) {
            blockdata->section = OrchestraSection;
        } else if(rxmatch.captured(1) == "CsScore" ) {
            blockdata->section = ScoreSection;
        } else if(rxmatch.captured(1) == "CsOptions" )  {
            blockdata->section = OptionsSection;
        } else if(rxmatch.captured(1) == "html" )  {
            blockdata->section = HtmlSection;
        } else {
            blockdata->section = UnknownSection;
        }
        setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(), csdtagFormat);
        return;
    }

    if (blockdata->section >= UnknownSection && blockdata->section < HtmlSection ) {
        highlightCsoundBlock(text);
        return;
    }


    for (int i=0; i<javascriptKeywords.size(); i++) {
        QRegularExpression expression("\\b" + javascriptKeywords[i] + "\\b");
        int index = text.indexOf(expression);
        while (index >= 0) {
            int length =  expression.match(text).capturedLength(); //expression.matchedLength();
            setFormat(index, length, jsKeywordFormat); // TODO javascriptformat
            index = text.indexOf(expression, index + length);
        }
    }


    static const QRegularExpression tagRx("<[^>]+>");
    int index = text.indexOf(tagRx);
    while (index >= 0) {
        int len = tagRx.match(text, index).capturedLength();
        setFormat(index, len, htmlTagFormat);
        index = text.indexOf(tagRx, index + len);
    }

    static const QRegularExpression tagNameRx("<\\s*/?\\s*([a-zA-Z][a-zA-Z0-9-]*)");
    QRegularExpressionMatch match = tagNameRx.match(text);
    while (match.hasMatch()) {
        setFormat(match.capturedStart(1), match.capturedLength(1), tagNameFormat); // or tagNameFormat
        match = tagNameRx.match(text, match.capturedEnd());
    }

    static const QRegularExpression attrNameRx("\\s([a-zA-Z_:][a-zA-Z0-9_:.-]*)=");
    QRegularExpressionMatch attrMatch = attrNameRx.match(text);
    while (attrMatch.hasMatch()) {
        setFormat(attrMatch.capturedStart(1), attrMatch.capturedLength(1), attrFormat );
        attrMatch = attrNameRx.match(text, attrMatch.capturedEnd());
    }



    static const QRegularExpression strings( QRegularExpression("\"[^\"]*\""));
    index = text.indexOf(strings);
	while (index >= 0) {
        int length = strings.match(text).capturedLength(); //strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
    static const QRegularExpression strings2("'[^'']*'");
    index = text.indexOf(strings2);
	while (index >= 0) {
        int length = strings.match(text).capturedLength(); //strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
	int commentIndex = -1;
    static const QRegularExpression expComment("//.*"); // TODO: avaoid https://
	index = text.indexOf(expComment);
	if (index>0 ) {
		if (text.at(index-1)!=':') { // clumsy way to avoid addresses like https://
			while (index >= 0) { // did not manage to do it with regular expression
                int length = expComment.match(text).capturedLength(); //expComment.matchedLength();
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
    static const QRegularExpression htmlCommentStartExpression("<!--");
    static const QRegularExpression htmlCommentEndExpression("-->");


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
                    + htmlCommentEndExpression.match(text).capturedLength(); //htmlCommentEndExpression.matchedLength();
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

    // labels
    rule = {QRegularExpression("^\\s*([a-zA-Z]\\w*):\\s*$"), labelFormat, 1};
    lastHighlightingRules.append(rule);

    // strings
    // lastHighlightingRules.append({QRegularExpression("\"[^\"]*\""), quotationFormat, 0});

    // NB: multiline strings should be implemented like multi-line comments
    // NB2: qt does syntax highlighting on a line-per-line basis
    // multi line strings
    // rule = {QRegularExpression("\\{\\{.*"), quotationFormat, 0};
    // lastHighlightingRules.append(rule);

    // end multi line strings
    // rule = {QRegularExpression(".*\\}\\}"), quotationFormat, 0};
    // lastHighlightingRules.append(rule);
}

bool Highlighter::isOpcode(QString name) {
    // Returns true if name is a known opcode
    return m_opcodesSet.contains(name);
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
    else if(start == end)
		return -1;
    else if(opcodeName < m_opcodeList[pos])
		return findOpcode(opcodeName, start, pos);
    else if(opcodeName > m_opcodeList[pos])
		return findOpcode(opcodeName, pos + 1, end);
	return -1;
}

void Highlighter::setUDOs(QStringList udos)
{
       m_parsedUDOs = udos;
}
