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

#include "editorthemes.h"
// #include "types.h"

#include <QLatin1StringView>
#include <QRegularExpression>
#include <QStringView>

#include <algorithm>


TextBlockData::TextBlockData() = default;

void TextBlockData::insert(const BracketInfo &info)
{
    // highlightBlock() discovers brackets left to right, so the common case
    // is an append. Keep the search for any callers that insert out of order.
    if (m_brackets.isEmpty()
            || info.position > m_brackets.constLast().position) {
        m_brackets.append(info);
        return;
    }

	int i = 0;
    while (i < m_brackets.size() && info.position > m_brackets.at(i).position)
		++i;

	m_brackets.insert(i, info);
}


namespace CsoundLex {

void scanInto(QStringView line, int startState, Line &info)
{
	info.clear();
	const int length = line.length();
	int pos = 0;

	// A line can continue a comment or a string from the previous one.
	if (startState == 1) {
		const int end = line.indexOf(u"*/"_s);
		if (end < 0) {
			info.comments.append({0, length});
			info.endState = 1;
			return;
		}
		info.comments.append({0, end + 2});
		pos = end + 2;
	} else if (startState == 2) {
		const int end = line.indexOf(u"}}"_s);
		if (end < 0) {
			info.multilineStrings.append({0, length});
			info.endState = 2;
			return;
		}
		info.multilineStrings.append({0, end + 2});
		pos = end + 2;
	}

	while (pos < length) {
		const QChar c = line.at(pos);
		if (c == QLatin1Char('"')) {
			// A string ends at the next quote; an unterminated one runs to the
			// end of the line.
			const int end = line.indexOf('"', pos + 1);
			if (end < 0) {
				info.strings.append({pos, length});
				pos = length;
			} else {
				info.strings.append({pos, end + 1});
				pos = end + 1;
			}
		} else if (c == QLatin1Char('/')
		&& pos + 1 < length) {
			const QChar next = line.at(pos + 1);
			if (next == QLatin1Char('*')) {
				const int end = line.indexOf(u"*/"_s, pos + 2);
				if (end < 0) {
					info.comments.append({pos, length});
					info.endState = 1;
					return; // the comment goes on in the next line
				}
				info.comments.append({pos, end + 2});
				pos = end + 2;
				continue;
			}
			if (next == QLatin1Char('/')) {
				info.comments.append({pos, length});
				return; // the comment goes to the end of the line
			}
			++pos;
		} else if (c == QLatin1Char(';')) {
			info.comments.append({pos, length});
			return; // the comment goes to the end of the line
		} else if (c == QLatin1Char('{') && pos + 1 < length
				   && line.at(pos + 1) == QLatin1Char('{')) {
			// A {{ ... }} string, which may span lines.
			const int end = line.indexOf(u"}}"_s, pos + 2);
			if (end < 0) {
				info.multilineStrings.append({pos, length});
				info.endState = 2;
				return; // the string goes on in the next line
			}
			info.multilineStrings.append({pos, end + 2});
			pos = end + 2;
		} else {
			++pos;
		}
	}
}

Line scan(QStringView line, int startState)
{
	Line info;
	scanInto(line, startState, info);
	return info;
}

} // namespace CsoundLex

namespace {

// These expressions are used for every highlighted line. Keep them compiled
// once for the lifetime of the process instead of guarding a function-local
// static on every call.
const QRegularExpression csdtagRx(
        QStringLiteral("^\\s*<\\/?(CsInstruments|CsOptions|CsoundSynthesizer|CsScore|CsFileB|CsLicense|html).*>"));
const QRegularExpression defineRx(
        QStringLiteral("^\\s*#define\\s+[_\\w\\ \\t]*#.*#"));
const QRegularExpression instOpcodeRx(
        QStringLiteral("^\\s*\\b(instr|opcode)\\s+(\\w+)\\b"));
// A label is an identifier followed by ':' and then whitespace/end-of-line.
// The lookahead keeps the match ending at the colon so trailing whitespace
// (e.g. before a comment) is not highlighted, and it prevents mistaking a
// Csound 7 typed variable definition ("name:type") for a label.
const QRegularExpression labelRx(
        QStringLiteral("^\\s*([a-zA-Z]\\w*):(?=\\s|$)"));
const QRegularExpression udoSignatureRx(
        QStringLiteral("^\\s*opcode\\s+[A-Za-z_]\\w*\\s*"
                       "\\(([^)]*)\\)\\s*"
                       "(?::\\s*(?:\\(([^)]*)\\)|"
                       "([A-Za-z_]\\w*(?:\\[\\])?)))?"));
const QRegularExpression typedParamRx(
        QStringLiteral("([A-Za-z_]\\w*)\\s*:\\s*"
                       "([A-Za-z_]\\w*(?:\\[\\])?)"));
const QRegularExpression typeRx(
        QStringLiteral("[A-Za-z_]\\w*(?:\\[\\])?"));
const QRegularExpression structRx(
        QStringLiteral("^\\s*\\bstruct\\b\\s+(\\w+)\\b"));
const QRegularExpression globalRx(
        QStringLiteral("(\\w+)@global:(\\w+(?:\\[\\])?)"));
const QRegularExpression expressionRx(
        QStringLiteral("\\b[\\w:]+\\b"));

// The names of the Csound preprocessor directives. A '#' anywhere else is
// ordinary text -- a colour in a string, a stray symbol, a comment -- and
// must not be painted as a preprocessor directive.
bool isPreprocessorDirective(QStringView name)
{
    static const QSet<QString> directives = {
        u"define"_s, u"include"_s, u"undef"_s,
        u"ifdef"_s, u"ifndef"_s, u"if"_s,
        u"elseif"_s, u"else"_s, u"end"_s, u"endif"_s
    };
    return directives.contains(name.toString());
}

const QSet<QString> builtinTypes = {
    u"i"_s, u"k"_s, u"a"_s, u"S"_s, u"f"_s, u"b"_s, u"B"_s,
    u"Complex"_s, u"InstrDef"_s, u"Instr"_s, u"Opcode"_s,
};

} // namespace

QColor saturateColor(QColor color, int percent) {
    int sat = color.saturation();
    sat = sat * percent / 100;
    if(sat > 255)
        sat = 255;
    return QColor::fromHsl(color.hue(), sat, color.lightness());
}

void Highlighter::finishTheme()
{
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

    // Closing csd tags are less intrusive when their colour is halfway
    // between the tag colour and the editor background.
    csdtagCloseFormat = csdtagFormat;
    const QColor tagColor = csdtagFormat.foreground().color();
    const QColor background = defaultFormat.background().color();
    if (tagColor.isValid() && background.isValid()) {
        csdtagCloseFormat.setForeground(QColor(
                (tagColor.red() + background.red()) / 2,
                (tagColor.green() + background.green()) / 2,
                (tagColor.blue() + background.blue()) / 2));
    }

    // html
    htmlTagFormat = csdtagFormat;
    tagNameFormat = arateFormat;
    attrFormat = irateFormat;
    jsKeywordFormat =  krateFormat;// keywordFormat;
}

void Highlighter::resetFormats()
{
    // Start every theme from scratch. Otherwise attributes that a previous
    // theme set (bold, underline, ...) would leak into the next one.
    csdtagFormat = QTextCharFormat();
    csdtagCloseFormat = QTextCharFormat();
    instFormat = QTextCharFormat();
    headerFormat = QTextCharFormat();
    irateFormat = QTextCharFormat();
    krateFormat = QTextCharFormat();
    arateFormat = QTextCharFormat();
    girateFormat = QTextCharFormat();
    gkrateFormat = QTextCharFormat();
    garateFormat = QTextCharFormat();
    stringVarFormat = QTextCharFormat();
    gstringVarFormat = QTextCharFormat();
    fsigFormat = QTextCharFormat();
    gfsigFormat = QTextCharFormat();
    booleanFormat = QTextCharFormat();
    complexFormat = QTextCharFormat();
    opcodeFormat = QTextCharFormat();
    udoFormat = QTextCharFormat();
    macroDefineFormat = QTextCharFormat();
    pfieldFormat = QTextCharFormat();
    singleLineCommentFormat = QTextCharFormat();
    importantCommentFormat = QTextCharFormat();
    multiLineCommentFormat = QTextCharFormat();
    quotationFormat = QTextCharFormat();
    functionFormat = QTextCharFormat();
    nameFormat = QTextCharFormat();
    ioFormat = QTextCharFormat();
    deprecatedFormat = QTextCharFormat();
    operatorFormat = QTextCharFormat();
    scoreLetterFormat = QTextCharFormat();
    errorFormat = QTextCharFormat();
    labelFormat = QTextCharFormat();
    csoundOptionFormat = QTextCharFormat();
    defaultFormat = QTextCharFormat();
    keywordFormat = QTextCharFormat();
    jsKeywordFormat = QTextCharFormat();
    htmlTagFormat = QTextCharFormat();
    tagNameFormat = QTextCharFormat();
    attrFormat = QTextCharFormat();
}

QTextCharFormat *Highlighter::formatForName(const QString &name)
{
    if (name == QLatin1String("default")) return &defaultFormat;
    if (name == QLatin1String("csdtag")) return &csdtagFormat;
    if (name == QLatin1String("csdtagClose")) return &csdtagCloseFormat;
    if (name == QLatin1String("inst")) return &instFormat;
    if (name == QLatin1String("header")) return &headerFormat;
    if (name == QLatin1String("keyword")) return &keywordFormat;
    if (name == QLatin1String("opcode")) return &opcodeFormat;
    if (name == QLatin1String("deprecated")) return &deprecatedFormat;
    if (name == QLatin1String("singleLineComment")) return &singleLineCommentFormat;
    if (name == QLatin1String("importantComment")) return &importantCommentFormat;
    if (name == QLatin1String("multiLineComment")) return &multiLineCommentFormat;
    if (name == QLatin1String("macroDefine")) return &macroDefineFormat;
    if (name == QLatin1String("pfield")) return &pfieldFormat;
    if (name == QLatin1String("irate")) return &irateFormat;
    if (name == QLatin1String("krate")) return &krateFormat;
    if (name == QLatin1String("arate")) return &arateFormat;
    if (name == QLatin1String("stringVar")) return &stringVarFormat;
    if (name == QLatin1String("fsig")) return &fsigFormat;
    if (name == QLatin1String("boolean")) return &booleanFormat;
    if (name == QLatin1String("complex")) return &complexFormat;
    if (name == QLatin1String("label")) return &labelFormat;
    if (name == QLatin1String("name")) return &nameFormat;
    if (name == QLatin1String("quotation")) return &quotationFormat;
    if (name == QLatin1String("io")) return &ioFormat;
    if (name == QLatin1String("udo")) return &udoFormat;
    if (name == QLatin1String("operator")) return &operatorFormat;
    if (name == QLatin1String("scoreLetter")) return &scoreLetterFormat;
    return nullptr;
}

void Highlighter::applyFormats(const QHash<QString, EditorThemes::FormatSpec> &formats)
{
    for (auto it = formats.constBegin(); it != formats.constEnd(); ++it) {
        QTextCharFormat *format = formatForName(it.key());
        if (!format) {
            qDebug() << "CsoundQt: editor theme - unknown format"
                     << it.key() << "; ignored";
            continue;
        }
        const EditorThemes::FormatSpec &spec = it.value();
        if (spec.foreground)
            format->setForeground(*spec.foreground);
        if (spec.background)
            format->setBackground(*spec.background);
        if (spec.underlineColor)
            format->setUnderlineColor(*spec.underlineColor);
        if (spec.bold)
            format->setFontWeight(*spec.bold ? QFont::Bold : QFont::Normal);
        if (spec.italic)
            format->setFontItalic(*spec.italic);
        if (spec.underline)
            format->setFontUnderline(*spec.underline);
        if (spec.strikeout)
            format->setFontStrikeOut(*spec.strikeout);
    }
}

void Highlighter::applyTheme(const EditorThemes::Theme &theme)
{
    defaultFormat.setForeground(theme.defaultForeground);
    defaultFormat.setBackground(theme.defaultBackground);
    applyFormats(theme.formats);
}

void Highlighter::setTheme(const QString &theme)
{
    // Re-applying an unchanged theme would force a full rehighlight of the
    // document. On an already laid-out, visible editor that is extremely
    // expensive (seconds on large files), so skip it. A refreshed theme
    // registry bumps the generation even when the name did not change.
    const int generation = EditorThemes::refreshGeneration();
    if (m_themeSet && theme == m_theme && m_themeGeneration == generation)
        return;

    QString applied = theme;
    const EditorThemes::Theme *definition = EditorThemes::find(theme);
    if (!definition) {
        qDebug() << "CsoundQt: editor theme" << theme
                 << "not found, falling back to light";
        applied = QStringLiteral("light");
        definition = EditorThemes::find(applied);
    }

    resetFormats();
    if (definition && definition->source != EditorThemes::Source::BuiltIn) {
        // A JSON theme only describes what it changes. Start from its built-in
        // light or dark base, then overlay the defined values.
        const EditorThemes::Theme *base =
                EditorThemes::find(definition->dark ? QStringLiteral("dark")
                                                    : QStringLiteral("light"));
        if (base)
            applyTheme(*base);
        defaultFormat.setForeground(definition->defaultForeground);
        defaultFormat.setBackground(definition->defaultBackground);
        applyFormats(definition->formats);
    }
    else if (definition) {
        applyTheme(*definition);
    }
    finishTheme();
    // finishTheme() derives a dimmed colour for closing tags from csdtag and
    // the background. A theme may define csdtagClose explicitly; that value
    // wins, and it is also what shows up in a duplicated theme file.
    if (definition) {
        const auto closeSpec =
                definition->formats.constFind(u"csdtagClose"_s);
        if (closeSpec != definition->formats.constEnd()) {
            QHash<QString, EditorThemes::FormatSpec> explicitClose;
            explicitClose.insert(u"csdtagClose"_s, *closeSpec);
            applyFormats(explicitClose);
        }
    }

    m_theme = applied;
    m_themeSet = true;
    m_themeGeneration = generation;
    clearTypedVars();
    rehighlight();
}

QTextCharFormat Highlighter::getFormat(QString tag) {
    if(tag == "" || tag == "default") {
        return defaultFormat;
    }
    if(tag == "csdtag")
        return csdtagFormat;
    if(tag == "csdtagClose")
        return csdtagCloseFormat;
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
    //  b64encStartExpression = QRegularExpression("<CsFileB .*>");
    //  b64encEndExpression = QRegularExpression("<CsFileB>");
	colorVariables = true;
	m_mode = 0; // default to Csound mode
    m_scoreSyntaxHighlighting = true;
    m_sectionType = CsdSection::UnknownSection;

    // look here for checking if an opcode is deprecated: https://csound.com/docs/manual/DeprecatedTop.html
    deprecatedOpcodes << "dbfsamp" << "ampdbfs" << "max_k";

    operatorPatterns << "&&" << "||";



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

    rxScoreLetter.setPattern(uR"(^\s*(i|f|e|d|s))"_s);
    rxQuotation.setPattern(uR"("[^"]*")"_s);

    // this->setTheme("classic");
}


Highlighter::~Highlighter()
{
}

void Highlighter::setOpcodeNameList(const QStringList &list)
{
	m_opcodeList = list;
    m_opcodesSet = QSet<QString>(list.begin(), list.end());
    // Opcodes added after src/opcodes.xml was generated. Keep the highlighter
    // in step with the current Csound 7 built-ins until the XML is regenerated.
    static const QSet<QString> extraBuiltinOpcodes = {
        u"B"_s,       u"b"_s,
        u"cingoto"_s,        u"cnkgoto"_s,
        u"convle"_s,         u"declare"_s,
        u"memplay"_s,        u"opcode"_s,
        u"oscilx"_s,         u"pvslock"_s,
        u"sense"_s,
        u"stmaddcondedge"_s, u"stmaddedge"_s,
        u"stmaddnode"_s,     u"stmadvance"_s,
        u"stmcall"_s,        u"stmcompile"_s,
        u"stmcreate"_s,      u"stmcurrent"_s,
        u"stmcurrentid"_s,   u"stmdelete"_s,
        u"stmedgecount"_s,   u"stmentry"_s,
        u"stmevent"_s,       u"stminstance"_s,
        u"stmnext"_s,        u"stmnodecount"_s,
        u"stmnodeid"_s,      u"stmnodename"_s,
        u"stmnodetime"_s,    u"stmonenter"_s,
        u"stmonexit"_s,      u"stmpause"_s,
        u"stmrecall"_s,      u"stmreset"_s,
        u"stmresume"_s,      u"stmtick"_s,
        u"stmtime"_s,
        u"trigExpseg"_s,     u"trigLinseg"_s
    };
    m_opcodesSet.unite(extraBuiltinOpcodes);
	//   setFirstRules();
	setLastRules();
}


void Highlighter::setMode(int mode)
{
    m_mode = mode;
    // A standalone orchestra, include or score document has no csd tags to
    // discover the section from. It is one section.
    switch (mode) {
    case 3: // Orc (.orc and .udo)
    case 5: // Inc
        m_sectionType = OrchestraSection;
        break;
    case 4: // Sco
        m_sectionType = ScoreSection;
        break;
    default:
        m_sectionType = UnknownSection;
        break;
    }
    // A mode change alters the highlighting even when the text is unchanged
    // (for example after saving a .csd under a new extension).
    if (document() != nullptr)
        rehighlight();
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
    m_giVariables.clear();
    m_gkVariables.clear();
    m_gaVariables.clear();
    m_gSVariables.clear();
    m_gfVariables.clear();
    m_namedInstruments.clear();
}

QTextCharFormat Highlighter::formatForType(QStringView typeStr) const
{
    if (typeStr.endsWith(QLatin1StringView("[]")))
        typeStr.chop(2);
    if (typeStr.compare(QLatin1StringView("i")) == 0) return irateFormat;
    if (typeStr.compare(QLatin1StringView("k")) == 0) return krateFormat;
    if (typeStr.compare(QLatin1StringView("a")) == 0) return arateFormat;
    if (typeStr.compare(QLatin1StringView("S")) == 0) return stringVarFormat;
    if (typeStr.compare(QLatin1StringView("f")) == 0) return fsigFormat;
    if (typeStr.compare(QLatin1StringView("b")) == 0
            || typeStr.compare(QLatin1StringView("B")) == 0) return booleanFormat;
    if (typeStr.compare(QLatin1StringView("Complex")) == 0) return complexFormat;
    if (typeStr.compare(QLatin1StringView("InstrDef")) == 0
            || typeStr.compare(QLatin1StringView("Instr")) == 0) return nameFormat;
    if (typeStr.compare(QLatin1StringView("OpcodeDef")) == 0
            || typeStr.compare(QLatin1StringView("Opcode")) == 0) return opcodeFormat;
    if (m_userTypeNames.contains(typeStr.toString())) return nameFormat;
    return defaultFormat;
}

void Highlighter::registerTypedVar(QStringView name, QStringView typeStr)
{
    if (typeStr.endsWith(QLatin1StringView("[]")))
        typeStr.chop(2);
    QSet<QString> *target = nullptr;
    if (typeStr.compare(QLatin1StringView("i")) == 0) target = &m_iVariables;
    else if (typeStr.compare(QLatin1StringView("k")) == 0) target = &m_kVariables;
    else if (typeStr.compare(QLatin1StringView("a")) == 0) target = &m_aVariables;
    else if (typeStr.compare(QLatin1StringView("S")) == 0) target = &m_SVariables;
    else if (typeStr.compare(QLatin1StringView("f")) == 0) target = &m_fVariables;
    else if (typeStr.compare(QLatin1StringView("b")) == 0
             || typeStr.compare(QLatin1StringView("B")) == 0) target = &m_bVariables;
    else if (typeStr.compare(QLatin1StringView("Complex")) == 0) target = &m_complexVariables;
    else if (typeStr.compare(QLatin1StringView("InstrDef")) == 0
             || typeStr.compare(QLatin1StringView("Instr")) == 0) target = &m_instrDefVariables;
    else if (typeStr.compare(QLatin1StringView("OpcodeDef")) == 0
             || typeStr.compare(QLatin1StringView("Opcode")) == 0) target = &m_opcodeVariables;
    else if (m_userTypeNames.contains(typeStr.toString())) target = &m_structVariables;
    if (target)
        target->insert(name.toString());
}

void Highlighter::registerGlobalTypedVar(QStringView name, QStringView typeStr)
{
    if (typeStr.endsWith(QLatin1StringView("[]")))
        typeStr.chop(2);
    QSet<QString> *target = nullptr;
    if (typeStr.compare(QLatin1StringView("i")) == 0) target = &m_giVariables;
    else if (typeStr.compare(QLatin1StringView("k")) == 0) target = &m_gkVariables;
    else if (typeStr.compare(QLatin1StringView("a")) == 0) target = &m_gaVariables;
    else if (typeStr.compare(QLatin1StringView("S")) == 0) target = &m_gSVariables;
    else if (typeStr.compare(QLatin1StringView("f")) == 0) target = &m_gfVariables;
    if (target)
        target->insert(name.toString());
    else
        // Other global types fall back to the regular sets.
        registerTypedVar(name, typeStr);
}

void Highlighter::highlightBlock(const QString &text)
{
    auto data = static_cast<TextBlockData*>(currentBlockUserData());
    if(data == nullptr) {
        data = new TextBlockData;
    }
    else {
        data->clearBrackets();
    }
    setCurrentBlockUserData(data);

    // The lexical scan runs first: it knows which parts of the line are
    // comments, strings and {{ }} strings, and it provides the state that the
    // next line continues from. Only Csound code is scanned; the other
    // languages keep their brackets as they are.
    CsoundLex::Line &lex = m_lexScratch;
    const bool csoundCode = (m_mode == 0 || m_mode == 3 || m_mode == 4 || m_mode == 5);
    if (csoundCode)
        CsoundLex::scanInto(text, previousBlockState(), lex);
    else
        lex.clear();

    // A line that lies inside a {{ ... }} string is not code: the code
    // highlighting is skipped for it, so that its contents stay plain.
    bool insideMultilineString = false;
    for (const QPair<int, int> &range : lex.multilineStrings) {
        if (range.first == 0 && range.second >= text.length()) {
            insideMultilineString = true;
            break;
        }
    }

    // Highlight only code, not the contents of comments or strings. The lexer
    // also reports an unterminated quote as a string that runs to the end of
    // the line, so "chnget \"fftsize" does not colour fftsize as an fsig
    // variable.
    const auto maskRanges = [](QString &codeText,
                               const QVector<QPair<int, int>> &ranges) {
        const int size = codeText.size();
        if (size == 0 || ranges.isEmpty())
            return;
        QChar *chars = codeText.data();
        for (const QPair<int, int> &range : ranges) {
            const int start = qMax(0, range.first);
            const int end = qMin(range.second, size);
            if (start < end)
                std::fill(chars + start, chars + end, QChar(u' '));
        }
    };

    QString maskedText;
    const QString *highlightText = &text;
    if (m_theme != "none" && !insideMultilineString
            && (!lex.comments.isEmpty() || !lex.strings.isEmpty()
                || !lex.multilineStrings.isEmpty())) {
        maskedText = text;
        maskRanges(maskedText, lex.comments);
        maskRanges(maskedText, lex.strings);
        maskRanges(maskedText, lex.multilineStrings);
        highlightText = &maskedText;
    }

    // The theme only decides whether the block is decorated; the mark below is
    // painted in any case.
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

        if (!insideMultilineString) {
            switch (m_mode) { // mode is set by the file type
            case 0:  // Csound mode
                highlightCsoundBlock(*highlightText, false);

                break;
            case 1:  // Python mode
                break;
            case 2:  // Xml mode
                highlightXmlBlock(text);
                break;
            case 3:  // Orc
                highlightCsoundBlock(*highlightText, false);
                break;
            case 4:  // Sco
                highlightCsoundBlock(*highlightText, false);
                break;
            case 5:  // Inc
                highlightCsoundBlock(*highlightText, false); // maybe anything not python or xml should be higlighter as csound?
                break;
            case 6:  // Html
                highlightHtmlBlock(text);
                break;
            }
        }

        // The quoted strings are painted after the code highlighting, so that
        // the contents keep the colour of a string. This includes a string
        // whose closing quote has not been typed yet.
        for (const QPair<int, int> &range : lex.strings) {
            setFormat(range.first, range.second - range.first, quotationFormat);
        }
        // The {{ ... }} strings are painted the same way.
        for (const QPair<int, int> &range : lex.multilineStrings) {
            setFormat(range.first, range.second - range.first, quotationFormat);
        }

        // Comments are painted last, after the code, so that words inside them
        // keep the comment colour instead of being coloured as opcodes,
        // variables or headers. The scan already knows the exact ranges; a
        // range that starts at the beginning of a continuation line belongs to
        // a /* ... */ comment.
        for (const QPair<int, int> &range : lex.comments) {
            const int start = range.first;
            const int length = range.second - start;
            const QStringView marker = QStringView(text).mid(start, 2);
            QTextCharFormat format = singleLineCommentFormat;
            if ((start == 0 && previousBlockState() == 1)
                    || marker == QLatin1StringView("/*")) {
                format = multiLineCommentFormat;
            } else if (marker == QLatin1StringView(";;")) {
                format = importantCommentFormat;
            }
            setFormat(start, length, format);
        }
    }

    if (csoundCode)
        setCurrentBlockState(lex.endState);

    const bool hasNonCode = !lex.comments.isEmpty()
            || !lex.strings.isEmpty() || !lex.multilineStrings.isEmpty();
    qsizetype commentRange = 0;
    qsizetype stringRange = 0;
    qsizetype multilineRange = 0;
    const auto inRange = [](const QVector<QPair<int, int>> &ranges,
                            qsizetype &index, int position) {
        while (index < ranges.size() && ranges.at(index).second <= position)
            ++index;
        return index < ranges.size() && ranges.at(index).first <= position;
    };
    const auto isCodeAt = [&](int position) {
        return !inRange(lex.comments, commentRange, position)
                && !inRange(lex.strings, stringRange, position)
                && !inRange(lex.multilineStrings, multilineRange, position);
    };

    const int textLength = text.length();
    BracketInfo info;
    for (int i = 0; i < textLength; ++i) {
        const QChar ch = text.at(i);
        switch (ch.unicode()) {
        case '(':
        case ')':
        case '[':
        case ']':
        case '{':
        case '}':
            break;
        default:
            continue;
        }
        if (csoundCode && hasNonCode && !isCodeAt(i))
            continue; // a bracket in a comment or a string is not code
        info.character = ch.toLatin1();
        info.position = i;
        data->insert(info);
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


void Highlighter::highlightCsoundBlock(const QString &line, bool paintStrings)
{
    QRegularExpressionMatch rxmatch;

	// text is processed one line at a time
    if(m_theme == "none")
        return;

    // Comments and strings were masked out by highlightBlock(), so the text
    // that reaches this function is code only. They are painted afterwards,
    // which keeps their contents from being coloured as opcodes or variables.
    int index = 0;

    auto blockdata = static_cast<TextBlockData*>(currentBlockUserData());

    const QStringView trimmedLine = QStringView(line).trimmed();
    if (trimmedLine.startsWith(QLatin1Char('<'))) {
        rxmatch = csdtagRx.match(line);
        if(rxmatch.hasMatch() ) {
            const QStringView tagName = rxmatch.capturedView(1);
            if(tagName == QLatin1StringView("CsInstruments") ) {
                blockdata->section = OrchestraSection;
            } else if(tagName == QLatin1StringView("CsScore") ) {
                blockdata->section = ScoreSection;
            } else if(tagName == QLatin1StringView("CsOptions") )  {
                blockdata->section = OptionsSection;
            } else if(tagName == QLatin1StringView("html") )  {
                blockdata->section = HtmlSection;
            } else {
                blockdata->section = UnknownSection;
            }
            const int nameStart = static_cast<int>(rxmatch.capturedStart(1));
            const bool closing = nameStart > 0
                    && line.at(nameStart - 1) == QLatin1Char('/');
            setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(),
                      closing ? csdtagCloseFormat : csdtagFormat);
            return;
        }
    }

    if(blockdata->section == ScoreSection || m_sectionType == ScoreSection) {
        if(m_scoreSyntaxHighlighting) {
            highlightScore(line, 0, static_cast<int>(line.size()));
        }
        return;
    } else if (blockdata->section == HtmlSection || m_sectionType == HtmlSection) {
        highlightHtmlBlock(line);
        return;
    } else if(blockdata->section == OptionsSection || m_sectionType == OptionsSection ) {
        // Options are simple command-line tokens. Walk the line without
        // splitting it into a QStringList and check the option name (without
        // its =value or :value part) against the known option set.
        const QStringView optionsLine(line);
        for (qsizetype i = 0; i < optionsLine.size(); ) {
            while (i < optionsLine.size() && optionsLine.at(i).isSpace())
                ++i;
            const qsizetype tokenStart = i;
            while (i < optionsLine.size() && !optionsLine.at(i).isSpace())
                ++i;
            if (i == tokenStart)
                break;

            const QStringView token = optionsLine.mid(tokenStart, i - tokenStart);
            qsizetype separator = token.indexOf(QLatin1Char('='));
            const qsizetype colon = token.indexOf(QLatin1Char(':'));
            if (colon >= 0 && (separator < 0 || colon < separator))
                separator = colon;
            const QStringView optionName = separator < 0 ? token
                                                         : token.left(separator);

            if (csoundOptions.contains(optionName.toString()))
                setFormat(static_cast<int>(tokenStart),
                          static_cast<int>(optionName.size()), csoundOptionFormat);
        }
        return;
    }
    else if(blockdata->section == OrchestraSection || m_sectionType == OrchestraSection) {
        const QStringView text = QStringView(line);
        const QStringView codeText = text.trimmed();

        // define
        if (codeText.startsWith(QLatin1Char('#'))) {
            rxmatch = defineRx.match(text);
            if(rxmatch.hasMatch()) {
                setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(), macroDefineFormat);
                return;
            }
        }

        if (codeText.startsWith(QLatin1StringView("instr"))
                || codeText.startsWith(QLatin1StringView("opcode"))) {
            rxmatch = instOpcodeRx.match(text);
        } else {
            rxmatch = QRegularExpressionMatch();
        }
        if(rxmatch.hasMatch()) {
            //auto group = rxmatch.captured(2);
            setFormat(rxmatch.capturedStart(1), rxmatch.capturedLength(1), instFormat);
            setFormat(rxmatch.capturedStart(2), rxmatch.capturedLength(2), nameFormat);
            const QStringView declaration = rxmatch.capturedView(1);
            // Track non-numeric instrument names so they can be highlighted at call sites
            if(declaration == QLatin1StringView("instr")) {
                const QStringView instrName = rxmatch.capturedView(2);
                bool isNumber = false;
                static_cast<void>(instrName.toInt(&isNumber));
                if(!isNumber)
                    m_namedInstruments.insert(instrName.toString());
            }
            else {
                // Csound 7 UDO signature:
                //   opcode Route(asigs:a[], hwouts:k[]):()
                // The old form "opcode Name, ..." has no parentheses and is
                // left to the normal word highlighting.
                const auto signature = udoSignatureRx.match(text);
                if (signature.hasMatch()) {
                    const int inputStart = signature.capturedStart(1);
                    for (auto it = typedParamRx.globalMatch(signature.capturedView(1));
                         it.hasNext(); ) {
                        const auto param = it.next();
                        const QStringView name = param.capturedView(1);
                        const QStringView type = param.capturedView(2);
                        setFormat(inputStart + static_cast<int>(param.capturedStart(1)),
                                  static_cast<int>(name.size()), formatForType(type));
                        setFormat(inputStart + static_cast<int>(param.capturedStart(2)),
                                  static_cast<int>(type.size()), keywordFormat);
                        registerTypedVar(name, type);
                    }
                    if (signature.capturedLength(2) > 0) {
                        // Output types in parentheses: :(a, k)
                        const int outputStart = signature.capturedStart(2);
                        for (auto it = typeRx.globalMatch(signature.capturedView(2));
                             it.hasNext(); ) {
                            const auto type = it.next();
                            setFormat(outputStart + static_cast<int>(type.capturedStart()),
                                      static_cast<int>(type.capturedLength()), keywordFormat);
                        }
                    }
                    else if (signature.capturedLength(3) > 0) {
                        // Single output type: :a
                        setFormat(signature.capturedStart(3),
                                  signature.capturedLength(3), keywordFormat);
                    }
                }
            }
            return;
        }

        // Csound 7: detect struct type definitions, e.g. "struct MyType val0:i, val1:i"
        if (codeText.startsWith(QLatin1StringView("struct"))) {
            rxmatch = structRx.match(text);
            if(rxmatch.hasMatch()) {
                m_userTypeNames.insert(rxmatch.capturedView(1).toString());
                setFormat(rxmatch.capturedStart(1), rxmatch.capturedLength(1), nameFormat);
                // 'struct' keyword will be formatted by the word loop via keywordLiterals
            }
        }

        // Csound 7: detect @global typed variable definitions, e.g. "maxamp@global:i = 0dbfs / 5"
        // Register the var name in the global-rate sets so later uses get girateFormat etc.
        if (text.contains(QLatin1StringView("@global"))) {
            QRegularExpressionMatchIterator globalIt = globalRx.globalMatch(text);
            while(globalIt.hasNext()) {
                auto m = globalIt.next();
                registerGlobalTypedVar(m.capturedView(1), m.capturedView(2));
            }
        }

        // Scan operators directly. A regular expression for a handful of
        // fixed symbols costs more than a single pass over the line.
        const int textSize = static_cast<int>(text.size());
        for (int i = 0; i < textSize; ++i) {
            const QChar c = text.at(i);
            int opLength = 0;
            if (i + 1 < textSize) {
                const QChar next = text.at(i + 1);
                if ((c == QLatin1Char('&') && next == QLatin1Char('&'))
                        || (c == QLatin1Char('|') && next == QLatin1Char('|'))
                        || (c == QLatin1Char('=') && next == QLatin1Char('='))
                        || (c == QLatin1Char('!') && next == QLatin1Char('='))
                        || (c == QLatin1Char('<') && next == QLatin1Char('='))
                        || (c == QLatin1Char('>') && next == QLatin1Char('=')))
                    opLength = 2;
            }
            if (opLength == 0
                    && (c == QLatin1Char('<') || c == QLatin1Char('>')
                        || c == QLatin1Char('\\')))
                opLength = 1;
            if (opLength > 0) {
                setFormat(i, opLength, operatorFormat);
                // The previous regex scan continued at capturedEnd() + 1, so
                // skip the character after the operator as well.
                i += opLength;
            }
        }

        index = 0;
        while((rxmatch = expressionRx.match(text, index)).hasMatch()) {
            const int wordStart = static_cast<int>(rxmatch.capturedStart());
            const int wordEnd = static_cast<int>(rxmatch.capturedEnd());
            index = wordEnd;

            if(wordStart > 0) {
                const QChar prev = text.at(wordStart - 1);
                // "$name" is a macro expansion anywhere. "#name" is a
                // preprocessor directive only when name is one: "#" followed
                // by anything else is not highlighted.
                if(prev == QLatin1Char('$')
                        || (prev == QLatin1Char('#')
                            && isPreprocessorDirective(rxmatch.capturedView()))) {
                    setFormat(wordStart - 1, wordEnd - wordStart + 1, macroDefineFormat);
                    continue;
                }
            }

            const QStringView word = rxmatch.capturedView();
            const int wordLength = static_cast<int>(word.size());
            bool isPfield = wordLength > 1 && word.at(0) == QLatin1Char('p');
            for (int i = 1; isPfield && i < wordLength; ++i) {
                if (!word.at(i).isDigit())
                    isPfield = false;
            }
            if(isPfield) {
                setFormat(wordStart, wordLength, pfieldFormat);
                continue;
            }

            // QSet<QString> has no heterogeneous lookup; this is the one copy
            // needed for the membership tests below.
            const QString wordKey = word.toString();
            if(instPatterns.contains(wordKey)) {
                setFormat(wordStart, wordLength, instFormat);
                break; // was: return. For any case, to go through lines after while loop
            }
            else if(tagPatterns.contains(wordKey) && wordStart > 0
                    && (text.at(wordStart - 1) == QLatin1Char('<')
                        || (wordStart > 1 && text.at(wordStart - 2) == QLatin1Char('<')
                            && text.at(wordStart - 1) == QLatin1Char('/')))) {
                const bool closing = text.at(wordStart - 1) == QLatin1Char('/');
                setFormat(wordStart - (closing ? 2 : 1),
                          wordLength + (closing ? 3 : 2),
                          closing ? csdtagCloseFormat : csdtagFormat);
            }
            else if(headerPatterns.contains(wordKey)) {
                setFormat(wordStart, wordLength, headerFormat);
            }
            else if(keywordLiterals.contains(wordKey)) {
                setFormat(wordStart, wordLength, keywordFormat);
            }
            else if(ioPatterns.contains(wordKey)) {
                setFormat(wordStart, wordLength, ioFormat);
            }
            else if(word.at(wordLength - 1) != QLatin1Char(':')
                    && word.indexOf(QLatin1Char(':')) >= 0) {
                const int colon = static_cast<int>(word.indexOf(QLatin1Char(':')));
                const int secondColon = static_cast<int>(
                            word.indexOf(QLatin1Char(':'), colon + 1));
                if (secondColon < 0) {
                    const QStringView varName  = word.left(colon);
                    const QStringView typeName = word.mid(colon + 1);
                    // "@global:type" annotation: the token is "global:type", preceded by '@'
                    if(wordStart > 0 && text.at(wordStart - 1) == QLatin1Char('@')) {
                        // Highlight "@global:type" together as a keyword annotation
                        setFormat(wordStart - 1, wordLength + 1, keywordFormat);
                    }
                    else if(isOpcode(varName.toString())) {
                        // functional style opcode:type(...) — existing behaviour
                        setFormat(wordStart, wordLength, opcodeFormat);
                    }
                    else {
                        // Csound 7: typed variable definition  varname:type
                        QStringView typeBase = typeName;
                        if (typeBase.endsWith(QLatin1StringView("[]")))
                            typeBase.chop(2);
                        const QString typeKey = typeBase.toString();
                        if(builtinTypes.contains(typeKey) || m_userTypeNames.contains(typeKey)) {
                            registerTypedVar(varName, typeName);
                            // varname portion — colour by its type
                            setFormat(wordStart, static_cast<int>(varName.size()),
                                      formatForType(typeName));
                            // ":type" portion — highlight as keyword
                            setFormat(wordStart + static_cast<int>(varName.size()),
                                      wordLength - static_cast<int>(varName.size()),
                                      keywordFormat);
                        }
                    }
                }
                else {
                    setFormat(wordStart, wordLength, errorFormat);
                }
            }
            else if(m_parsedUDOs.contains(wordKey)) {
                setFormat(wordStart, wordLength, udoFormat);
            }
            else if(deprecatedOpcodes.contains(wordKey)) {
                setFormat(wordStart, wordLength, deprecatedFormat);
            }
            else if(isOpcode(wordKey)) {
                setFormat(wordStart, wordLength, opcodeFormat);
            }
            else if(m_namedInstruments.contains(wordKey)) {
                setFormat(wordStart, wordLength, nameFormat);
            }
            else if(colorVariables) {
                QTextCharFormat variableFormat;
                bool haveVariableFormat = false;
                // @global:type sets — these take precedence over local typed sets
                if(m_gaVariables.contains(wordKey)) {
                    variableFormat = garateFormat; haveVariableFormat = true;
                }
                else if(m_gkVariables.contains(wordKey)) {
                    variableFormat = gkrateFormat; haveVariableFormat = true;
                }
                else if(m_giVariables.contains(wordKey)) {
                    variableFormat = girateFormat; haveVariableFormat = true;
                }
                else if(m_gSVariables.contains(wordKey)) {
                    variableFormat = gstringVarFormat; haveVariableFormat = true;
                }
                else if(m_gfVariables.contains(wordKey)) {
                    variableFormat = gfsigFormat; haveVariableFormat = true;
                }
                // Csound 7: check explicitly typed (local) variable sets
                else if(m_aVariables.contains(wordKey)) {
                    variableFormat = arateFormat; haveVariableFormat = true;
                }
                else if(m_kVariables.contains(wordKey)) {
                    variableFormat = krateFormat; haveVariableFormat = true;
                }
                else if(m_iVariables.contains(wordKey)) {
                    variableFormat = irateFormat; haveVariableFormat = true;
                }
                else if(m_SVariables.contains(wordKey)) {
                    variableFormat = stringVarFormat; haveVariableFormat = true;
                }
                else if(m_fVariables.contains(wordKey)) {
                    variableFormat = fsigFormat; haveVariableFormat = true;
                }
                else if(m_bVariables.contains(wordKey)) {
                    variableFormat = booleanFormat; haveVariableFormat = true;
                }
                else if(m_complexVariables.contains(wordKey)) {
                    variableFormat = complexFormat; haveVariableFormat = true;
                }
                else if(m_instrDefVariables.contains(wordKey)) {
                    variableFormat = nameFormat; haveVariableFormat = true;
                }
                else if(m_opcodeVariables.contains(wordKey)) {
                    variableFormat = opcodeFormat; haveVariableFormat = true;
                }
                else if(m_structVariables.contains(wordKey)) {
                    variableFormat = nameFormat; haveVariableFormat = true;
                }
                // Fall back to classic prefix-based detection
                else if(word.startsWith(QLatin1Char('a'))) {
                    variableFormat = arateFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1Char('k'))) {
                    variableFormat = krateFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1Char('i'))) {
                    variableFormat = irateFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1StringView("ga"))) {
                    variableFormat = garateFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1StringView("gk"))) {
                    variableFormat = gkrateFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1StringView("gi"))) {
                    variableFormat = girateFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1Char('S'))) {
                    variableFormat = stringVarFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1StringView("gS"))) {
                    variableFormat = gstringVarFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1Char('f'))) {
                    variableFormat = fsigFormat; haveVariableFormat = true;
                }
                else if(word.startsWith(QLatin1StringView("gf"))) {
                    variableFormat = gfsigFormat; haveVariableFormat = true;
                }
                if (haveVariableFormat)
                    setFormat(wordStart, wordLength, variableFormat);
            }

        }

        // String ranges are normally painted by highlightBlock() from the
        // lexical scan, after the code has been highlighted.
        if (paintStrings) {
            for (qsizetype quote = text.indexOf(QLatin1Char('"')); quote >= 0; ) {
                const qsizetype end = text.indexOf(QLatin1Char('"'), quote + 1);
                if (end < 0)
                    break;
                setFormat(static_cast<int>(quote), static_cast<int>(end - quote + 1),
                          quotationFormat);
                quote = text.indexOf(QLatin1Char('"'), end + 1);
            }
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

        // label (separate). Only lines with a colon can contain a label; skip
        // the expression for the much more common lines without one.
        if (text.indexOf(QLatin1Char(':')) >= 0) {
            rxmatch = labelRx.match(text);
            if (rxmatch.hasMatch()) {
                // Highlight "<label>:" only, not the leading indentation.
                setFormat(rxmatch.capturedStart(1), rxmatch.capturedLength(1) + 1, labelFormat);
            }
        }

        // Multiline {{ ... }} strings are handled by the lexical scan in
        // highlightBlock(), which paints them after the code highlighting.
    } else {
        return;
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

    rx.setPattern(uR"(^\s*<\/?(CsInstruments|CsOptions|CsoundSynthesizer|CsScore|CsFileB|CsLicense|html).*>)"_s);
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
        const int nameStart = static_cast<int>(rxmatch.capturedStart(1));
        const bool closing = nameStart > 0
                && text.at(nameStart - 1) == QLatin1Char('/');
        setFormat(rxmatch.capturedStart(), rxmatch.capturedLength(),
                  closing ? csdtagCloseFormat : csdtagFormat);
        return;
    }

    if (blockdata->section >= UnknownSection && blockdata->section < HtmlSection ) {
        highlightCsoundBlock(text);
        return;
    }

    static const QRegularExpression tagRx(uR"(<[^>]+>)"_s);
    int index = text.indexOf(tagRx);
    while (index >= 0) {
        int len = tagRx.match(text, index).capturedLength();
        setFormat(index, len, htmlTagFormat);
        index = text.indexOf(tagRx, index + len);
    }

    static const QRegularExpression tagNameRx(uR"(<\s*/?\s*([a-zA-Z][a-zA-Z0-9-]*))"_s);
    QRegularExpressionMatch match = tagNameRx.match(text);
    while (match.hasMatch()) {
        setFormat(match.capturedStart(1), match.capturedLength(1), tagNameFormat); // or tagNameFormat
        match = tagNameRx.match(text, match.capturedEnd());
    }

    static const QRegularExpression attrNameRx(uR"(\s([a-zA-Z_:][a-zA-Z0-9_:.-]*)=)"_s);
    QRegularExpressionMatch attrMatch = attrNameRx.match(text);
    while (attrMatch.hasMatch()) {
        setFormat(attrMatch.capturedStart(1), attrMatch.capturedLength(1), attrFormat );
        attrMatch = attrNameRx.match(text, attrMatch.capturedEnd());
    }



    static const QRegularExpression strings( QRegularExpression(uR"("[^"]*")"_s));
    index = text.indexOf(strings);
	while (index >= 0) {
        int length = strings.match(text).capturedLength(); //strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
    static const QRegularExpression strings2(uR"('[^'']*')"_s);
    index = text.indexOf(strings2);
	while (index >= 0) {
        int length = strings.match(text).capturedLength(); //strings.matchedLength();
		setFormat(index, length, quotationFormat);
		index = text.indexOf(strings, index + length);
	}
	int commentIndex = -1;
    static const QRegularExpression expComment(uR"(//.*)"_s); // TODO: avaoid https://
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
    static const QRegularExpression htmlCommentStartExpression(uR"(<!--)"_s);
    static const QRegularExpression htmlCommentEndExpression(uR"(-->)"_s);


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

    // labels (kept in sync with labelRx in highlightCsoundBlock; this list is
    // currently unused, the active label highlight lives there)
    rule = {QRegularExpression(uR"(^\s*([a-zA-Z]\w*):(?=\s|$))"_s), labelFormat, 1};
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

bool Highlighter::isOpcode(const QString &name) {
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

void Highlighter::setUDOs(const QStringList &udos)
{
    m_parsedUDOs = QSet<QString>(udos.begin(), udos.end());
}
