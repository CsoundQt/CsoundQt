/*
	Copyright (C) 2010 Andres Cabrera
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

#include "documentview.h"
#include "channeltext.h"
#include "docstringpopup.h"
#include "findbar.h"
#include "opcodeinsertbar.h"
#include "opentryparser.h"
#include "types.h"

#include "highlighter.h"
#include "sourcecursor.h"
#include "texteditor.h"

#include <QDir>
#include <QCursor>
#include <QFileInfo>
#include <QGuiApplication>
#include <QListWidget>
#include <QPainter>
#include <QScreen>
#include <QStyle>
#include <QStyledItemDelegate>
#include <QTimer>
#include <QVBoxLayout>

#include <algorithm>
using namespace Qt::StringLiterals;


static const QStringList tagWords = {"CsInstruments", "CsScore", "CsoundSynthesizer", "CsOptions"};

// While the completion popup is already open, wait this long after the last
// keystroke before filtering the list again.
static constexpr int COMPLETION_UPDATE_DELAY_MS = 100;

// Wait this long after the cursor stops moving before updating the status bar
// with the syntax of the opcode under it. Without this, holding an arrow key
// or dragging the cursor makes the status bar flicker through every opcode.
static constexpr int OPCODE_SYNTAX_DEBOUNCE_MS = 100;

// A word selected for "show occurrences" must be a plain Csound identifier.
static bool isIdentifierText(const QString &text)
{
    static const QRegularExpression identifierRx(uR"(^[A-Za-z_][A-Za-z0-9_]*$)"_s);
    return identifierRx.match(text).hasMatch();
}

// True when the selection boundaries do not cut through a longer identifier
// (so a double-clicked word qualifies, a partial drag-selection does not).
static bool selectionCoversWholeWord(const QTextCursor &cursor)
{
    if (!cursor.hasSelection())
        return false;
    QTextDocument *document = cursor.document();
    if (document == nullptr)
        return false;
    const auto isWordChar = [](QChar c) {
        return c.isLetterOrNumber() || c == QLatin1Char('_');
    };
    const int start = cursor.selectionStart();
    const int end = cursor.selectionEnd();
    if (start > 0 && isWordChar(document->characterAt(start - 1)))
        return false;
    if (end < document->characterCount() - 1
            && isWordChar(document->characterAt(end))) {
        return false;
    }
    return true;
}

// The inspector highlight follows the cursor much more slowly: it only needs
// to tell the user which instrument or opcode they are working in.
static constexpr int INSPECTOR_SCOPE_DEBOUNCE_MS = 1000;

// Keys that continue the token being completed. They are forwarded to the
// editor without closing the popup, so the popup can stay in place while the
// debounced update filters its entries. Delimiters, whitespace, editing keys
// and shortcuts still close the popup.
static bool keepsCompletionMenuOpen(const QKeyEvent *event)
{
    if (event->modifiers() & (Qt::ControlModifier | Qt::AltModifier | Qt::MetaModifier))
        return false;
    const QString text = event->text();
    if (text.isEmpty())
        return false;
    for (const QChar c : text) {
        if (!(c.isLetterOrNumber() || c == QLatin1Char('_') || c == QLatin1Char('/')
              || c == QLatin1Char('.') || c == QLatin1Char('-') || c == QLatin1Char('~')
              || c == QLatin1Char('$') || c == QLatin1Char('@')))
            return false;
    }
    return true;
}

// Colours of the opcode/word completion popup (MySyntaxMenu). The popup is its
// own top-level window and does not take the editor's colours, so they are
// chosen here. A warm off-white keeps it just off the light editor's white
// page, and a hairline border a little darker than that keeps its edge visible
// against it; the dark theme keeps the popup's original plain light background,
// which already stands out, so the separator below sits on a light background
// in both themes.
#define COMPLETION_MENU_BG_LIGHT     "#fffeef"
#define COMPLETION_MENU_BORDER_LIGHT "#b7b19a"
#define COMPLETION_MENU_SEPARATOR    "#7070c0"

// Smart case: only match case sensitively when the query itself contains an
// upper case character, otherwise search case insensitively (like the help
// panel find box).
static QTextDocument::FindFlags smartCaseFlags(const QString &query)
{
	QTextDocument::FindFlags flags;
	if (query != query.toLower())
		flags |= QTextDocument::FindCaseSensitively;
	return flags;
}

// True when the cursor sits inside a string literal or after an unmatched
// (open) quote on the current line, e.g. Sfile = "foo<cursor>. The
// autocomplete menu must never be triggered there. A quote escaped with a
// backslash (\") does not count; a double backslash (\\) does not escape.
// Position of the unmatched double quote in the text before the cursor, or
// -1. Escaped quotes do not count.
static int openDoubleQuoteIndex(const QString &text)
{
    int open = -1;
    bool inString = false;
    for (int i = 0; i < text.size(); ++i) {
        if (text[i] != QLatin1Char('"'))
            continue;
        int backslashes = 0;
        for (int j = i - 1; j >= 0 && text[j] == QLatin1Char('\\'); --j)
            ++backslashes;
        if (backslashes % 2 != 0)
            continue;
        inString = !inString;
        open = inString ? i : -1;
    }
    return inString ? open : -1;
}

static bool isSoundFile(const QFileInfo &file)
{
    static const QSet<QString> suffixes = {
        u"wav"_s,   u"wave"_s,  u"aif"_s,
        u"aiff"_s,  u"aifc"_s,  u"au"_s,
        u"avr"_s,   u"caf"_s,   u"flac"_s,
        u"htk"_s,   u"ircam"_s, u"mat"_s,
        u"mpc2k"_s, u"nist"_s,  u"pau"_s,
        u"raw"_s,   u"sf"_s,    u"svx"_s,
        u"voc"_s,   u"w64"_s,   u"wavex"_s,
        u"rf64"_s,  u"ogg"_s,   u"oga"_s,
        u"mp3"_s,   u"opus"_s,  u"m4a"_s
    };
    return suffixes.contains(file.suffix().toLower());
}

// The files an #include directive is likely to pull in: Csound source, but
// also plain text snippets used with #include. Sound files are not included.
static bool isIncludeFile(const QFileInfo &file)
{
    static const QSet<QString> suffixes = {
        u"udo"_s, u"inc"_s, u"csd"_s,
        u"txt"_s, u"orc"_s, u"sco"_s
    };
    return suffixes.contains(file.suffix().toLower());
}

// A completion after schedule(), chnget(), chnset() or diskin2() has a fixed
// set of candidates, so it must bypass the normal identifier/opcode completion.
struct CompletionContext
{
    enum Kind { None, Schedule, Channel, Path, Property, Include, Option, EnvPath };
    Kind kind = None;
    bool quoted = false;
    QString prefix;
    int prefixStart = -1; // relative to the start of the line
    // Candidates of an Option context, already without their "--" or "-+".
    QStringList candidates;
};

static CompletionContext completionContext(const QString &textBeforeCursor)
{
    CompletionContext context;

    // The path of an #include directive is completed from the files that are
    // likely to be included, not from sound files. Both Csound spellings are
    // handled: #include "file" and #include <file>.
    static const QRegularExpression includeQuotedRx(
        uR"(^\s*#\s*include\s*$)"_s);
    static const QRegularExpression includeAngledRx(
        uR"(^\s*#\s*include\s*<([^>]*)$)"_s);
    if (const auto angled = includeAngledRx.match(textBeforeCursor);
        angled.hasMatch()) {
        context.kind = CompletionContext::Include;
        context.quoted = true;
        context.prefix = angled.captured(1);
        context.prefixStart = angled.capturedStart(1);
        return context;
    }

    const int quote = openDoubleQuoteIndex(textBeforeCursor);
    if (quote >= 0) {
        const QString beforeQuote = textBeforeCursor.left(quote);
        static const QRegularExpression scheduleQuotedRx(
            uR"(\b(schedulek?)(?:\s*:\s*[akiSpfxbw]\b)?\s*(?:\(\s*)?$)"_s);
        static const QRegularExpression chngetQuotedRx(
            uR"(\bchnget(?:\s*:\s*[akiSpfxbw]\b)?\s*(?:\(\s*)?$)"_s);
        static const QRegularExpression chnsetLegacyQuotedRx(
            uR"(\bchnset(?:\s*:\s*[akiSpfxbw]\b)?\s+[^,]+,\s*$)"_s);
        static const QRegularExpression chnsetFunctionQuotedRx(
            uR"(\bchnset(?:\s*:\s*[akiSpfxbw]\b)?\s*\([^,]*,\s*$)"_s);
        static const QRegularExpression outvalueQuotedRx(
            uR"(\boutvalue(?:\s*:\s*[akiSpfxbw]\b)?\s*(?:\(\s*)?$)"_s);
        static const QRegularExpression invalueQuotedRx(
            uR"(\binvalue(?:\s*:\s*[akiSpfxbw]\b)?\s*(?:\(\s*)?$)"_s);
        if (includeQuotedRx.match(beforeQuote).hasMatch()) {
            context.kind = CompletionContext::Include;
        } else if (scheduleQuotedRx.match(beforeQuote).hasMatch()) {
            context.kind = CompletionContext::Schedule;
        } else if (chngetQuotedRx.match(beforeQuote).hasMatch()
                   || chnsetLegacyQuotedRx.match(beforeQuote).hasMatch()
                   || chnsetFunctionQuotedRx.match(beforeQuote).hasMatch()
                   || invalueQuotedRx.match(beforeQuote).hasMatch()) {
            context.kind = CompletionContext::Channel;
        } else if (outvalueQuotedRx.match(beforeQuote).hasMatch()) {
            // The first outvalue argument is a widget channel. Once a '/'
            // has been typed it is an addressable widget property instead.
            // This deliberately takes precedence over path completion.
            const QString prefix = textBeforeCursor.mid(quote + 1);
            context.kind = prefix.contains(QLatin1Char('/'))
                    ? CompletionContext::Property
                    : CompletionContext::Channel;
        } else {
            // A path-like string is useful in any opcode argument, not only
            // in diskin2. Absolute paths are included as well.
            const QString prefix = textBeforeCursor.mid(quote + 1);
            if (prefix.startsWith("./"_L1)
                    || prefix.startsWith("../"_L1)
                    || prefix.startsWith(QLatin1Char('/'))
                    || prefix.startsWith("~/"_L1)) {
                context.kind = CompletionContext::Path;
            }
        }
        if (context.kind != CompletionContext::None) {
            context.quoted = true;
            context.prefixStart = quote + 1;
            context.prefix = textBeforeCursor.mid(context.prefixStart);
            return context;
        }
    }

    // Legacy schedule syntax or a function call, with an unquoted name.
    static const QRegularExpression scheduleRx(
        uR"(\b(schedulek?)(?:\s*:\s*[akiSpfxbw]\b)?(?:\s+|\s*\(\s*)([A-Za-z_][A-Za-z0-9_]*)$)"_s);
    const auto match = scheduleRx.match(textBeforeCursor);
    if (match.hasMatch()) {
        context.kind = CompletionContext::Schedule;
        context.prefix = match.captured(2);
        context.prefixStart = match.capturedStart(2);
    }
    return context;
}

// True when the block lies between <CsOptions> and </CsOptions>. The split
// view puts the options in an editor of their own, which the caller detects
// separately: there are no tags in that editor.
static bool isInsideOptionsSection(const QTextBlock &block)
{
    for (QTextBlock candidate = block; candidate.isValid();
         candidate = candidate.previous()) {
        const QStringView text = QStringView(candidate.text()).trimmed();
        if (text.startsWith(u"</CsOptions>"))
            return false;
        if (text.startsWith(u"<CsOptions>"))
            return true;
        if (text.startsWith(u"<CsInstruments>") || text.startsWith(u"</CsInstruments>")
                || text.startsWith(u"<CsScore>") || text.startsWith(u"</CsScore>"))
            return false;
    }
    return false;
}

// The command-line option the cursor is on, in the <CsOptions> section. The
// token is replaced from after its "--" or "-+", or after "--env:" for the
// environment variable names, which are completed together with their '='.
// A quoted path value after the '=' is completed from the filesystem instead.
static CompletionContext optionCompletionContext(const QString &textBeforeCursor)
{
    static const QStringList longOptions = {
        u"format"_s,        u"nopeaks"_s,       u"nodisplays"_s,
        u"midifile="_s,     u"input"_s,         u"output"_s,
        u"logfile"_s,       u"nosound"_s,       u"tempo="_s,
        u"messagelevel="_s, u"env:"_s,          u"dither"_s,
        u"opcode-dir"_s,    u"opcode-lib"_s,    u"omacro:"_s,
        u"midi-key="_s,     u"midi-velocity="_s, u"no-default-paths"_s,
        u"sample-accurate"_s, u"realtime"_s,    u"daemon"_s,
        u"use-system-sr"_s, u"fftlib="_s,       u"udp-echo"_s,
        u"limiter=1.0"_s,   u"no-deprecation-warnings"_s,
        u"error-deprecated"_s, u"suppress-version"_s, u"vbr"_s,
        u"port="_s
    };
    static const QStringList realtimeOptions = {
        u"rtaudio"_s, u"rtmidi"_s, u"jack_client="_s,
        u"jack_outportname="_s, u"skip_seconds="_s
    };
    static const QStringList environmentNames = {
        u"INCDIR="_s, u"SFDIR="_s, u"SSDIR="_s
    };

    // The option token starts after the last whitespace.
    qsizetype start = textBeforeCursor.size();
    while (start > 0 && !textBeforeCursor.at(start - 1).isSpace())
        --start;
    const QStringView token = QStringView(textBeforeCursor).mid(start);

    CompletionContext context;
    if (token.startsWith(u"--env:")) {
        // A quoted path value, --env:VAR="/... or --env:VAR="./... (and
        // ../...): complete the path itself instead of the variable name.
        const QStringView afterEnv = token.mid(6);
        const qsizetype equals = afterEnv.indexOf(QLatin1Char('='));
        if (equals > 0 && equals + 1 < afterEnv.size()
                && afterEnv.at(equals + 1) == QLatin1Char('"')) {
            const QStringView value = afterEnv.mid(equals + 2);
            if (value.startsWith(QLatin1Char('/'))
                    || value.startsWith("./"_L1)
                    || value.startsWith("../"_L1)) {
                context.kind = CompletionContext::EnvPath;
                context.prefixStart = static_cast<int>(start + 6 + equals + 2);
                context.prefix = value.toString();
                return context;
            }
        }
        context.kind = CompletionContext::Option;
        context.prefixStart = static_cast<int>(start + 6); // after "--env:"
        context.prefix = token.mid(6).toString();
        context.candidates = environmentNames;
    } else if (token.startsWith(u"--")) {
        context.kind = CompletionContext::Option;
        context.prefixStart = static_cast<int>(start + 2); // after "--"
        context.prefix = token.mid(2).toString();
        context.candidates = longOptions;
    } else if (token.startsWith(u"-+")) {
        context.kind = CompletionContext::Option;
        context.prefixStart = static_cast<int>(start + 2); // after "-+"
        context.prefix = token.mid(2).toString();
        context.candidates = realtimeOptions;
    }
    return context;
}

static bool hasOpenQuote(const QString &textBeforeCursor)
{
    auto hasUnmatched = [](const QString &text, QChar quote) {
        int count = 0;
        for (int i = 0; i < text.size(); ++i) {
            if (text[i] != quote)
                continue;
            int backslashes = 0;
            int j = i - 1;
            while (j >= 0 && text[j] == QLatin1Char('\\')) {
                ++backslashes;
                --j;
            }
            if (backslashes % 2 == 0)
                ++count;
        }
        return (count % 2) != 0;
    };
    return hasUnmatched(textBeforeCursor, QLatin1Char('"')) ||
           hasUnmatched(textBeforeCursor, QLatin1Char('\''));
}

// The arguments of an opcode without the parentheses around them. The menu
// that lists the opcodes has too little space for them.
static QString withoutParentheses(const QString &args)
{
    const QString text = args.trimmed();
    if (text.startsWith(QLatin1Char('(')) && text.endsWith(QLatin1Char(')')))
        return text.mid(1, text.length() - 2).trimmed();
    return text;
}

DocumentView::DocumentView(QWidget * parent, OpEntryParser *opcodeTree) :
	BaseView(parent,opcodeTree)
{
	// The bracket matcher belongs to the document the highlighter is attached to.
	m_bracketMatcher.setDocument(m_highlighter.document());

	m_autoComplete = true;

	m_hoverWidget = new HoverWidget(m_mainEditor);
	m_hoverText= new QLabel("Hello", m_hoverWidget);
	m_hoverText->show();
	m_hoverText->setStyleSheet(
				"QLabel {"
                "  border: 1px solid #505050;"
                "  border-radius: 4px;"
                "  padding: 2px;"
                "  background-color: #eaeac5;"
                "  color: #202020; "
				"};");
	m_hoverText->setWordWrap(true);
    m_hoverText->setMinimumWidth(300);
	m_hoverWidget->hide();

	m_mainEditor->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
	m_mainEditor->setContextMenuPolicy(Qt::CustomContextMenu);
	connect(m_mainEditor, SIGNAL(customContextMenuRequested(QPoint)),
			this, SLOT(createContextMenu(QPoint)));
	setFocusProxy(m_mainEditor);  // for comment action from main application
	internalChange = false;

    //  m_highlighter = new Highlighter();
    connect(m_mainEditor, SIGNAL(textChanged()),
            this, SLOT(textChanged()));
    // connect(m_mainEditor, SIGNAL(cursorPositionChanged()),
    //        this, SLOT(updateContext()));
    connect(m_mainEditor, SIGNAL(cursorPositionChanged()),
            this, SLOT(syntaxCheck()));
	connect(m_mainEditor, &QTextEdit::cursorPositionChanged,
	        this, &DocumentView::updateOccurrencesFromSelection);
	connect(m_mainEditor, SIGNAL(escapePressed()),
			this, SLOT(escapePressed()));
	connect(m_mainEditor, SIGNAL(newLine()),
			this, SLOT(indentNewLine()));
	connect(m_mainEditor, SIGNAL(requestIndent()),
			this, SLOT(indent()));
	connect(m_mainEditor, SIGNAL(requestUnindent()),
			this, SLOT(unindent()));
	connect(m_mainEditor, SIGNAL(tabPressed()),
			this, SLOT(nextParameter()));
	connect(m_mainEditor, SIGNAL(backtabPressed()),
			this, SLOT(prevParameter()));
	connect(m_mainEditor, SIGNAL(arrowPressed()),
			this, SLOT(exitParameterMode()));
	connect(m_mainEditor, SIGNAL(enterPressed()),
			this, SLOT(finishParameterMode()));
	connect(m_mainEditor, SIGNAL(showParameterInfo()),
			this, SLOT(showHoverText()));
	connect(m_mainEditor, SIGNAL(requestParameterModeExit()),
			this, SLOT(exitParameterMode()));
	connect(m_mainEditor,SIGNAL(arrowPressed()), this, SLOT(restoreCursorPosition()) );

	//TODO put this for line reporting for score editor
	//  connect(scoreEditor, SIGNAL(textChanged()),
    //          this, SLOT(syntaxCheck())	//  connect(scoreEditor, SIGNAL(cursorPositionChanged()),
	//          this, SLOT(syntaxCheck()));

	errorMarked = false;
	m_isModified = false;

	syntaxMenu = new MySyntaxMenu(m_mainEditor);
	//  syntaxMenu->setFocusPolicy(Qt::NoFocus);
	// The stylesheet paints the background; leaving autofill on would paint the
	// whole (square) popup rect first and undo the rounded corners.
	syntaxMenu->setAutoFillBackground(false);
	// A key typed into the open popup is forwarded to the editor and the
	// popup stays visible. Filter its list after a short pause rather than on
	// every keystroke.
	connect(syntaxMenu, &MySyntaxMenu::completionKeyForwarded, this, [this]() {
		if (syntaxMenu->isVisible())
			scheduleAutoComplete(COMPLETION_UPDATE_DELAY_MS);
	});

	setAcceptDrops(true);

	// The channel probe also works while only navigating the text: hovering a
	// quoted channel with the mouse, or placing the text cursor inside it.
	for (TextEditor *editor : findChildren<TextEditor *>()) {
		editor->viewport()->setMouseTracking(true);
		editor->viewport()->installEventFilter(this);
		connect(editor, &QTextEdit::cursorPositionChanged,
				this, &DocumentView::updateChannelHighlightFromCursor);
		connect(editor, &QTextEdit::cursorPositionChanged,
				this, &DocumentView::cancelAutoCompleteOnCursorMove);
	}

	m_oldCursorPosition = -1; // 0 or positive, if cursor needs to be moved there
    markCurrentPosition();
    updateCompletionFont();

}

DocumentView::~DocumentView()
{
	disconnect(this, 0,0,0);
}

bool DocumentView::isModified()
{
	return m_isModified;
}

void DocumentView::markCurrentPosition() {
    int pos = this->currentLineNumber();
    cursorPositions.push_back(pos);
    if(cursorPositions.size() > 1000) {
        cursorPositions.pop_front();
    }
}

bool DocumentView::childHasFocus()
{
	return hasFocus() || m_mainEditor->hasFocus();
}

void DocumentView::print(QPrinter *printer)
{
	m_mainEditor->print(printer);
}

void DocumentView::updateContext()
{
    // this code is too expensive to be run at EACH keystroke. We need to think of something better
    // Until then I am disabling it (EM, Nov. 21)
    return;
	QStringList contextStart;
	contextStart << "<CsInstruments>" << "<CsScore" << "<CsOptions>";
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::LineUnderCursor);
	QString line = cursor.selection().toPlainText().simplified();
	while (!cursor.atStart()) {
		foreach(QString startText, contextStart) {
			if (line.startsWith(startText)) {
				m_currentContext = contextStart.indexOf(startText) + 1;
				break;
			}
		}
		cursor.movePosition(QTextCursor::Up);
		cursor.select(QTextCursor::BlockUnderCursor);
		line = cursor.selection().toPlainText();
		cursor.movePosition(QTextCursor::StartOfBlock);
	}
	if (m_currentContext == DocumentView::ORC_CONTEXT) { // Instrument section
		QString endText = "</CsInstruments>";
		QTextCursor linecursor = cursor;
		linecursor.select(QTextCursor::LineUnderCursor);
		line = linecursor.selection().toPlainText();
		linecursor.movePosition(QTextCursor::EndOfLine);
		while (!linecursor.atEnd() && !line.contains(endText)) {
			cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
			cursor.movePosition(QTextCursor::EndOfLine, QTextCursor::KeepAnchor);
			linecursor = cursor;
			linecursor.select(QTextCursor::LineUnderCursor);
			line = linecursor.selection().toPlainText();
			linecursor.movePosition(QTextCursor::EndOfLine);
		}
		QString orc = cursor.selection().toPlainText();
        updateOrcContext(orc);
	}
}

void DocumentView::updateOrcContext(QString orc)
{
    // This is disabled at the moment since updateContext is itself disabled
    (void) orc;
	// TODO: add string as context
	QStringList innerContextStart;
	innerContextStart << "instr" << "opcode";
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::LineUnderCursor);
	QString line = cursor.selection().toPlainText().trimmed();
    while (!cursor.atStart()) {
		foreach(QString startText, innerContextStart) {
			if (line.startsWith(startText)) {
				break;
			}
		}
		cursor.movePosition(QTextCursor::Up);
		cursor.select(QTextCursor::BlockUnderCursor);
		line = cursor.selection().toPlainText().trimmed();
		cursor.movePosition(QTextCursor::StartOfBlock);
	}
	cursor.movePosition(QTextCursor::NextBlock);
	QString endText = "endin";
	QTextCursor linecursor = cursor;
	linecursor.select(QTextCursor::LineUnderCursor);
	line = linecursor.selection().toPlainText().trimmed();
	linecursor.movePosition(QTextCursor::EndOfLine);
	while (!linecursor.atEnd() && !line.startsWith(endText)) {
		cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
		cursor.movePosition(QTextCursor::EndOfLine, QTextCursor::KeepAnchor);
		linecursor = cursor;
		linecursor.select(QTextCursor::LineUnderCursor);
		line = linecursor.selection().toPlainText().trimmed();
		linecursor.movePosition(QTextCursor::EndOfLine);
	}
	QString instr = cursor.selection().toPlainText();

    // TODO: work on this. At the moment the function is not called, but later QStrinView would be more efficient
    //QList <QStringView> lines = QStringView{instr}.split(u'\n', SKIP_EMPTY_PARTS); // old (preQt6): instr.splitRef("\n", SKIP_EMPTY_PARTS);
    auto lines = instr.split('\n', SKIP_EMPTY_PARTS); // here ther is not sense to use QStringView as QString is needed soon later

    static const QRegularExpression rxWordSplit(uR"([\s,+-/\*\.\^\(\)\[\]$])"_s);
	m_localVariables.clear();
    QSet<QString> seen;
    for(QString line: lines) {
        line = line.trimmed();
        if (line.isEmpty() || line.startsWith(";")) {
			continue;
		}
        auto words = line.split(rxWordSplit, SKIP_EMPTY_PARTS);
        for(const QString &word: words) {
            if(!seen.contains(word) && !m_opcodeTree->isOpcode(word)) {
                seen.insert(word);
            }
		}
	}
    //m_localVariables = QStringList(seen.begin(), seen.end());
    m_localVariables = seen.values();
}

void DocumentView::nextParameter()
{
	QChar character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	// First move forward a word
	while(!m_mainEditor->textCursor().atBlockEnd() &&
		  !(character.isSpace() || character == ',' || character == '(' || character == ')'
			|| character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::NextCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	// Then move forward all white space
	while(!m_mainEditor->textCursor().atBlockEnd() &&
		  (character.isSpace() || character == ',' || character == '(' || character == ')'
		   || character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::NextCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	if (m_mainEditor->textCursor().atBlockStart()) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::WordUnderCursor);
	if (cursor.selectedText() == "\"") {
		cursor.movePosition(QTextCursor::NextCharacter);
		while (!(cursor.selectedText().endsWith("\"") || cursor.atBlockEnd())) {
			cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
		}
		if (cursor.selectedText().endsWith("\"")) {
			cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
		}
	}
	m_mainEditor->blockSignals(true); // To avoid triggering the position changed action which hides the text cursor and disables parameter mode
	m_mainEditor->setTextCursor(cursor);
	m_mainEditor->blockSignals(false);
	showHoverText();
}

void DocumentView::prevParameter()
{
	if (!m_mainEditor->textCursor().atBlockStart()) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
	}
	QChar character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	while(!m_mainEditor->textCursor().atBlockStart() &&
		  !(character.isSpace() || character == ',' || character == '(' || character == ')'
			|| character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	while(!m_mainEditor->textCursor().atBlockStart() &&
		  (character.isSpace() || character == ',' || character == '(' || character == ')'
		   || character == '[' || character == ']' || character == '\\')) {
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
		character = m_mainEditor->document()->characterAt(m_mainEditor->textCursor().position());
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.select(QTextCursor::WordUnderCursor);
	if (cursor.selectedText().startsWith("\"")) {
		cursor.movePosition(QTextCursor::PreviousCharacter);
		while (!(cursor.selectedText().startsWith("\"") || cursor.atBlockEnd())) {
			cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
		}
		if (cursor.selectedText().startsWith("\"")) {
			cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
		}
	}
	m_mainEditor->blockSignals(true); // To avoid triggering the position changed action which hides the text cursor and disables parameter mode
	m_mainEditor->setTextCursor(cursor);
	m_mainEditor->blockSignals(false);
	showHoverText();
}

void DocumentView::showHoverText()
{
	QTextCursor cursor  = m_mainEditor->textCursor();
	QRect cursorRect = m_mainEditor->cursorRect();
	updateHoverText(cursorRect.x(), cursorRect.y(), cursor.selectedText());
}

void DocumentView::hideHoverText()
{
	m_hoverWidget->hide();
}

void DocumentView::updateHoverText(int x, int y, QString text)
{
	QString displayText = m_currentOpcodeText;
	if (!text.isEmpty()) {
		displayText.replace(text, "<b>" + text + "</b>");
	}
	m_hoverText->setText(displayText);
	m_hoverText->adjustSize();
	QRect textRect = m_hoverText->contentsRect();
	int textWidth = textRect.width() + 10;
    if (textWidth > this->width()) {
		textRect.setWidth(this->width());
		textWidth = this->width();
	}
	int xoffset = 0;
	if (m_currentOpcodeText.contains(text)) {
		xoffset = 10 + textRect.width() * (m_currentOpcodeText.indexOf(text)/(float) (m_currentOpcodeText.indexOf("<br />") + 5));
	}
	if (xoffset > x) {
		xoffset = x;
	} else if (textWidth + x - xoffset > this->width()) {
		xoffset = - (this->width() - (textWidth + x - xoffset));
	}
	m_hoverWidget->setGeometry(x - xoffset, y-textRect.height() - 10, textWidth, textRect.height() + 10);

	m_hoverWidget->show();
}

void DocumentView::setModified(bool mod)
{
//    auto sender = static_cast<QTextEdit*>(this->sender());
//    auto senderName = sender != nullptr ? sender->property("name").toString() : "";
//    qDebug() << "sender: " << senderName << "modified:"<<mod;
	m_isModified = mod;
    if (!mod) {
        // Clear the editors' save point too. Otherwise document()->isModified()
        // stays true after a save, and undoing back to the saved text would
        // keep reporting the document as modified.
        m_mainEditor->document()->setModified(false);
    }
}

void DocumentView::insertText(QString text, int section)
{
	if (section > 0) {
		qDebug() << "Section " << section << " not implemented.";
		return;
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	cursor.insertText(text);
	m_mainEditor->setTextCursor(cursor);
}

void DocumentView::setAutoComplete(bool autoComplete, int delay)
{
	m_autoComplete = autoComplete;
    if(delay > 0)
        m_autoCompleteDelay = delay;
}

void DocumentView::setFont(QFont font)
{
    BaseView::setFont(font);
    updateCompletionFont();
}

void DocumentView::updateCompletionFont()
{
    if (syntaxMenu == nullptr || m_mainEditor == nullptr)
        return;
    QFont font = m_mainEditor->font();
    if (font.pointSizeF() > 0.0) {
        font.setPointSizeF(qMax(1.0, font.pointSizeF() - 1.0));
    } else if (font.pixelSize() > 0) {
        font.setPixelSize(qMax(1, font.pixelSize() - 1));
    }
    syntaxMenu->setCompletionFont(font);
}

void DocumentView::setAutoCompleteMenuWidth(int width)
{
    if (width > 0)
        m_autoCompleteMenuWidth = width;
}

void DocumentView::setAutoCompleteMenuMaxLines(int lines)
{
    if (lines > 0)
        m_autoCompleteMenuMaxLines = lines;
}

void DocumentView::setAutoParameterMode(bool autoParameterMode)
{
	m_autoParameterMode = autoParameterMode;
}

QString DocumentView::getSelectedText(int section)
{
	if (section > 0) {
		qDebug() << "Section " << section << " not implemented.";
		return QString();
	}
	return m_mainEditor->textCursor().selectedText();
}

QString DocumentView::getWidgetsText()
{
	// With tags including presets, in new xml format. For text that is being edited in the text editor
	// Includes presets text
	qDebug() << "Not implemented and will crash!";
    return "Not implemented.";
}

int DocumentView::currentLineNumber()
{
	QTextCursor cursor = m_mainEditor->textCursor();
	return cursor.blockNumber() + 1;
}

QString DocumentView::channelAtCursor() const
{
	TextEditor *editor = activeEditor();
	if (!editor)
		return {};
	const QTextCursor cursor = editor->textCursor();
	return findChannelLiteral(cursor.block().text(),
	                          cursor.positionInBlock()).channel;
}

QString DocumentView::channelAtCursorPosition(const QTextCursor &cursor)
{
	const QTextBlock block = cursor.block();
	const int position = cursor.positionInBlock();
	const int revision = block.revision();
	if (!m_cachedChannel.isEmpty()
			&& m_cachedChannelBlock == block
			&& m_cachedBlockRevision == revision
			&& position > m_cachedChannelStart
			&& position < m_cachedChannelEnd) {
		return m_cachedChannel;
	}

	// Keep a per-document index of lines that contain a channel opcode.
	// Unchanged lines without one can be skipped without tokenizing them
	// again; any edit changes the document revision and invalidates the index.
	QTextDocument *document = cursor.document();
	const int documentRevision = document ? document->revision() : -1;
	if (document != m_channelLineCacheDocument
			|| documentRevision != m_channelLineCacheRevision) {
		m_channelLineCache.clear();
		m_channelLineCacheDocument = document;
		m_channelLineCacheRevision = documentRevision;
	}
	const int blockNumber = block.blockNumber();
	const auto lineIt = m_channelLineCache.constFind(blockNumber);
	if (lineIt != m_channelLineCache.constEnd() && !lineIt.value())
		return {};

	const ChannelTextResult result = findChannelLiteral(
				block.text(), position, true);
	m_channelLineCache.insert(blockNumber, result.hasChannelReference);
	if (result.channel.isEmpty()) {
		m_cachedChannel.clear();
		m_cachedChannelBlock = QTextBlock();
		m_cachedBlockRevision = -1;
		m_cachedChannelStart = -1;
		m_cachedChannelEnd = -1;
		return {};
	}
	m_cachedChannel = result.channel;
	m_cachedChannelBlock = block;
	m_cachedBlockRevision = revision;
	m_cachedChannelStart = result.start;
	m_cachedChannelEnd = result.end;
	return m_cachedChannel;
}

QString DocumentView::channelAtTextCursor()
{
	TextEditor *editor = activeEditor();
	if (!editor)
		return {};
	return channelAtCursorPosition(editor->textCursor());
}

void DocumentView::updateChannelHighlightFromCursor()
{
	if (m_channelHighlightMode == ChannelHighlightMode::Never
			|| m_channelHighlightMode == ChannelHighlightMode::MouseOnly)
		return;
	m_channelHighlightSource = ChannelHighlightSource::Cursor;
	updateChannelHighlight();
}

void DocumentView::updateChannelHighlight()
{
	QString target;
	if (m_channelHighlightMode == ChannelHighlightMode::CursorOnly) {
		target = channelAtTextCursor();
	} else if (m_channelHighlightMode == ChannelHighlightMode::MouseOnly) {
		target = m_hoverChannel;
	} else if (m_channelHighlightMode == ChannelHighlightMode::Full) {
		// In Full mode only the source that most recently moved may trigger
		// a highlight. In particular, when the mouse leaves a channel the
		// cursor must not take over until it has actually moved again.
		if (m_channelHighlightSource == ChannelHighlightSource::Cursor)
			target = channelAtTextCursor();
		else if (m_channelHighlightSource == ChannelHighlightSource::Mouse)
			target = m_hoverChannel;
	}
	// Repeated events for the same channel are harmless: the widget layout
	// keeps an existing outline instead of rebuilding it. Always re-send a
	// non-empty channel so hovering works again after Esc/click cleared it.
	if (target.isEmpty() && m_activeChannelHighlight.isEmpty())
		return;
	m_activeChannelHighlight = target;
	emit channelHighlightRequested(target);
}

QList<QTextEdit::ExtraSelection> DocumentView::extraSelectionsFor(
		TextEditor *editor) const
{
	QList<QTextEdit::ExtraSelection> selections;
	if (editor == m_mainEditor) {
		selections = m_occurrenceSelections;
		selections.append(m_findSelections);
	}
	if (editor == m_widgetChannelEditor)
		selections.append(m_widgetChannelSelections);

	if (editor->document() == m_bracketMatcher.document()
			&& m_bracketMatcher.first() >= 0
			&& m_bracketMatcher.second() >= 0) {
		QColor background = editor->palette().color(QPalette::Highlight);
		background.setAlpha(100);
		QTextCharFormat format;
		format.setBackground(background);
		const int positions[] = { m_bracketMatcher.first(),
		                          m_bracketMatcher.second() };
		for (int position : positions) {
			if (position < 0 || position >= editor->document()->characterCount())
				continue;
			QTextEdit::ExtraSelection selection;
			selection.cursor = QTextCursor(editor->document());
			selection.cursor.setPosition(position);
			selection.cursor.movePosition(QTextCursor::NextCharacter,
			                              QTextCursor::KeepAnchor);
			selection.format = format;
			selections.append(selection);
		}
	}
	return selections;
}

void DocumentView::clearWidgetChannelHighlights()
{
	m_widgetChannelSelections.clear();
	TextEditor *editor = m_widgetChannelEditor;
	m_widgetChannelEditor = nullptr;
	if (editor)
		editor->setExtraSelections(extraSelectionsFor(editor));
}

void DocumentView::highlightWidgetChannels(const QStringList &channels,
                                           bool jumpToFirstReference)
{
	clearWidgetChannelHighlights();
	if (channels.isEmpty())
		return;
	TextEditor *editor = currentLineEditor();
	if (!editor)
		return;

	QStringList uniqueChannels;
	for (const QString &channel : channels) {
		if (!channel.isEmpty() && !uniqueChannels.contains(channel))
			uniqueChannels.append(channel);
	}
	if (uniqueChannels.isEmpty())
		return;

	QTextDocument *document = editor->document();
	QSet<int> markedBlocks;
	int firstReferenceBlock = -1;
	int firstReferencePosition = -1;
	for (QTextBlock block = document->begin(); block.isValid(); block = block.next()) {
		const QString line = block.text();
		bool matches = false;
		int matchPosition = -1;
		for (const QString &channel : uniqueChannels) {
			// Also accept the widget-property form "<channel>/<property>"
			// used by outvalue, without matching a longer channel name.
			const QString prefix = QLatin1Char('"') + channel;
			int from = 0;
			while ((from = line.indexOf(prefix, from)) >= 0) {
				const int next = from + prefix.size();
				if (next >= line.size()
						|| (line.at(next) != QLatin1Char('"')
							&& line.at(next) != QLatin1Char('/'))) {
					from = next;
					continue;
				}
				const ChannelTextResult result = findChannelLiteral(
							line, from + 1, false);
				if (result.channel == channel
						|| result.channel.startsWith(channel + QLatin1Char('/'))) {
					matches = true;
					matchPosition = from;
					break;
				}
				from = next;
			}
			if (matches)
				break;
		}
		if (matches) {
			markedBlocks.insert(block.blockNumber());
			if (firstReferenceBlock < 0 && matchPosition >= 0) {
				firstReferenceBlock = block.blockNumber();
				firstReferencePosition = block.position() + matchPosition + 1;
			}
		}
	}

	QTextCharFormat format;
	format.setBackground(QColor(255, 200, 40, 80));
	format.setProperty(QTextFormat::FullWidthSelection, true);
	for (int blockNumber : markedBlocks) {
		const QTextBlock block = document->findBlockByNumber(blockNumber);
		if (!block.isValid())
			continue;
		QTextEdit::ExtraSelection selection;
		selection.cursor = QTextCursor(block);
		selection.cursor.select(QTextCursor::LineUnderCursor);
		selection.format = format;
		m_widgetChannelSelections.append(selection);
	}
	if (m_widgetChannelSelections.isEmpty())
		return;
	m_widgetChannelEditor = editor;
	editor->setExtraSelections(extraSelectionsFor(editor));
	if (jumpToFirstReference && firstReferencePosition >= 0) {
		QTextCursor cursor(document);
		cursor.setPosition(firstReferencePosition);
		editor->setTextCursor(cursor);
		editor->ensureCursorVisible();
	}
}

bool DocumentView::eventFilter(QObject *watched, QEvent *event)
{
	TextEditor *editor = qobject_cast<TextEditor *>(watched->parent());
	const bool onEditorViewport = editor && editor->viewport() == watched;
	// The quick reference follows the pointer: Ctrl+hover always asks for it,
	// and Settings/Editor/Behavior can make a plain hover enough. It is asked
	// for once per name: while the card is up the popup holds the pointer, so
	// these moves stop and checkHoverHelp() closes the card once it leaves.
	if (onEditorViewport && event->type() == QEvent::MouseMove) {
		auto *mouseEvent = static_cast<QMouseEvent *>(event);
		// Dragging (selecting text, moving text) must not pop cards up under the
		// pointer; Ctrl+hover during a drag keeps its old behaviour.
		const bool ctrl = mouseEvent->modifiers().testFlag(Qt::ControlModifier);
		const bool wantsHelp = ctrl
				|| (m_quickHelpOnHover && mouseEvent->buttons() == Qt::NoButton);
		if (wantsHelp)
			requestHoverHelp(editor, mouseEvent->position().toPoint(), ctrl);
		else
			cancelPendingHoverHelp();
	} else if (onEditorViewport
			&& (event->type() == QEvent::Leave
				|| event->type() == QEvent::MouseButtonPress)) {
		// The pointer left the editor, or a click started: a card still waiting
		// out its delay must not appear afterwards.
		cancelPendingHoverHelp();
	}
	if (m_channelHighlightMode != ChannelHighlightMode::Full
			&& m_channelHighlightMode != ChannelHighlightMode::MouseOnly)
		return QWidget::eventFilter(watched, event);
	if (onEditorViewport) {
		if (event->type() == QEvent::MouseMove) {
			auto *mouseEvent = static_cast<QMouseEvent *>(event);
			const QTextCursor cursor = editor->cursorAt(
						mouseEvent->position().toPoint());
			const QString channel = channelAtCursorPosition(cursor);
			const bool sourceChanged = m_channelHighlightSource
					!= ChannelHighlightSource::Mouse;
			m_channelHighlightSource = ChannelHighlightSource::Mouse;
			if (sourceChanged || channel != m_hoverChannel) {
				m_hoverChannel = channel;
				updateChannelHighlight();
			}
		} else if (event->type() == QEvent::Leave) {
			if (!m_hoverChannel.isEmpty()
					|| m_channelHighlightSource == ChannelHighlightSource::Mouse) {
				m_hoverChannel.clear();
				m_channelHighlightSource = ChannelHighlightSource::None;
				updateChannelHighlight();
			}
		}
	}
	return QWidget::eventFilter(watched, event);
}

QString DocumentView::hoverHelpWordAt(TextEditor *editor,
                                      const QPoint &viewportPos) const
{
    if (editor == nullptr)
        return QString();
    QTextCursor cursor = editor->cursorAt(viewportPos);
    cursor.select(QTextCursor::WordUnderCursor);
    if (!cursor.hasSelection())
        return QString();
    // A quoted name (an instrument in a schedule call, say) is left to the
    // explicit shortcuts: hovering over a string is too easy to trigger by
    // accident, and the quoted text does not reference a definition.
    const QTextDocument *document = editor->document();
    const int start = cursor.selectionStart();
    const int end = cursor.selectionEnd();
    if (start > 0 && document->characterAt(start - 1) == QLatin1Char('"')
            && document->characterAt(end) == QLatin1Char('"'))
        return QString();
    return cursor.selectedText();
}

bool DocumentView::isHelpName(const QString &name) const
{
    return m_opcodeTree->isOpcode(name) || m_udoNames.contains(name)
            || m_instrumentNames.contains(name);
}

void DocumentView::requestHoverHelp(TextEditor *editor, const QPoint &viewportPos,
                                    bool immediate)
{
    const QString word = hoverHelpWordAt(editor, viewportPos);
    // A name dismissed with Escape is left alone until the pointer moves to
    // another one.
    if (word != m_hoverHelpDismissedWord)
        m_hoverHelpDismissedWord.clear();
    if (word.isEmpty() || word == m_hoverHelpWord
            || word == m_hoverHelpDismissedWord || !isHelpName(word)) {
        // Whatever was waiting belonged to another name, or there is nothing
        // to wait for at all.
        cancelPendingHoverHelp();
        return;
    }

    if (immediate) {
        // Ctrl+hover is an explicit request: it should not be held up by a
        // delay the user did not ask for.
        cancelPendingHoverHelp();
        showHoverHelp(editor, word, viewportPos);
        return;
    }

    // A plain hover must rest on the name for the configured time. Moving to
    // another name starts the wait again; staying on this one keeps the
    // running timer.
    if (word == m_hoverHelpPendingWord && editor == m_hoverHelpPendingEditor)
        return;
    cancelPendingHoverHelp();
    m_hoverHelpPendingWord = word;
    m_hoverHelpPendingEditor = editor;
    if (m_hoverHelpDelayTimer == nullptr) {
        m_hoverHelpDelayTimer = new QTimer(this);
        m_hoverHelpDelayTimer->setSingleShot(true);
        connect(m_hoverHelpDelayTimer, &QTimer::timeout,
                this, &DocumentView::showPendingHoverHelp);
    }
    m_hoverHelpDelayTimer->start(m_quickHelpHoverDelay);
}

void DocumentView::showPendingHoverHelp()
{
    TextEditor *editor = m_hoverHelpPendingEditor.data();
    const QString word = m_hoverHelpPendingWord;
    m_hoverHelpPendingWord.clear();
    m_hoverHelpPendingEditor.clear();
    if (word.isEmpty() || editor == nullptr)
        return;
    // The timer can outlive a pointer move that never reached us (a leave, a
    // jump to another window); only show the card for the name that is still
    // under the pointer.
    const QPoint pos = editor->viewport()->mapFromGlobal(QCursor::pos());
    if (!editor->viewport()->rect().contains(pos)
            || hoverHelpWordAt(editor, pos) != word)
        return;
    if (word == m_hoverHelpWord || word == m_hoverHelpDismissedWord)
        return;
    showHoverHelp(editor, word, pos);
}

void DocumentView::showHoverHelp(TextEditor *editor, const QString &word,
                                 const QPoint &viewportPos)
{
    m_hoverHelpWord = word;
    m_hoverHelpEditor = editor;
    emit quickReferenceRequested(word,
                                 editor->viewport()->mapToGlobal(viewportPos));
    if (m_docstringPopup == nullptr || !m_docstringPopup->isVisible()
            || m_quickHelpShownWord != word) {
        // Nothing to show for this name after all.
        stopHoverHelpTracking();
        return;
    }
    if (m_hoverHelpTimer == nullptr) {
        m_hoverHelpTimer = new QTimer(this);
        m_hoverHelpTimer->setInterval(50);
        connect(m_hoverHelpTimer, &QTimer::timeout,
                this, &DocumentView::checkHoverHelp);
    }
    m_hoverHelpTimer->start();
}

void DocumentView::checkHoverHelp()
{
    TextEditor *editor = m_hoverHelpEditor.data();
    if (m_hoverHelpWord.isEmpty() || editor == nullptr) {
        stopHoverHelpTracking();
        return;
    }
    if (m_docstringPopup == nullptr || !m_docstringPopup->isVisible()) {
        // Closed with Escape or the close button while the pointer stayed on
        // the name: do not open it again for that name.
        m_hoverHelpDismissedWord = m_hoverHelpWord;
        stopHoverHelpTracking();
        return;
    }
    const QPoint pos = editor->viewport()->mapFromGlobal(QCursor::pos());
    if (editor->viewport()->rect().contains(pos)
            && hoverHelpWordAt(editor, pos) == m_hoverHelpWord)
        return;
    m_docstringPopup->hide();
    stopHoverHelpTracking();
}

void DocumentView::stopHoverHelpTracking()
{
    if (m_hoverHelpTimer != nullptr)
        m_hoverHelpTimer->stop();
    m_hoverHelpWord.clear();
    m_hoverHelpEditor.clear();
}

void DocumentView::cancelPendingHoverHelp()
{
    if (m_hoverHelpDelayTimer != nullptr)
        m_hoverHelpDelayTimer->stop();
    m_hoverHelpPendingWord.clear();
    m_hoverHelpPendingEditor.clear();
}

QString DocumentView::lineUnderCursor() {
    QTextCursor cursor = m_mainEditor->textCursor();
    cursor.select(QTextCursor::LineUnderCursor);
    auto line = cursor.selectedText();
    return line;
}

QString DocumentView::wordUnderCursor()
{
	QTextCursor cursor = m_mainEditor->textCursor();
	QString word = cursor.selectedText();
	if (word.isEmpty()) {
		cursor.select(QTextCursor::WordUnderCursor);
		word = cursor.selectedText();
	}
	return word;
}

QString DocumentView::helpWordUnderCursor()
{
	QTextCursor cursor = m_mainEditor->textCursor();
	if (cursor.hasSelection())
		return cursor.selectedText();
	cursor.select(QTextCursor::WordUnderCursor);
	QString word = cursor.selectedText();
	const auto knownName = [this](const QString &name) {
		return m_opcodeTree->isOpcode(name) || m_udoNames.contains(name);
	};
	if (knownName(word))
		return word;
	// The instrument that schedule and friends are asked to play: the name can
	// be written as a string, "bar", so the quotes are not part of it.
	QString instrument = word;
	if (instrument.size() >= 2 && instrument.startsWith(QLatin1Char('"'))
			&& instrument.endsWith(QLatin1Char('"')))
		instrument = instrument.mid(1, instrument.size() - 2);
	if (m_instrumentNames.contains(instrument))
		return instrument;
	// Fall back to the nearest known opcode before the cursor on the same
	// line, mirroring how the status bar signature matching behaves, so
	// help is found even when the cursor sits on an argument or whitespace
	// past the opcode.
	cursor = m_mainEditor->textCursor();
	cursor.movePosition(QTextCursor::EndOfWord, QTextCursor::MoveAnchor);
	cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
	static const QRegularExpression wordBoundary(uR"(\b)"_s);
	auto words = cursor.selectedText().split(wordBoundary, SKIP_EMPTY_PARTS);
	for (int i = words.size() - 1; i >= 0; --i) {
		if (knownName(words[i]))
			return words[i];
	}
	return word;
}

QString DocumentView::getActiveSection()
{
	// Will return all document if there are no ## boundaries (for any kind of file)
	QString section;
	if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE) {
		QTextCursor cursor = m_mainEditor->textCursor();
		m_oldCursorPosition = cursor.position(); // to move back there on next keypress
		cursor.select(QTextCursor::LineUnderCursor);
		QString text = cursor.selectedText().simplified();
		bool sectionStart = text.startsWith("instr") || text.startsWith(";;");
		while (!sectionStart && !(cursor.anchor() == 0)) {
			cursor.movePosition(QTextCursor::PreviousBlock);
			cursor.select(QTextCursor::LineUnderCursor);
			text = cursor.selectedText().simplified();
			sectionStart = text.startsWith("instr") || text.startsWith(";;");
		}
		int start = cursor.anchor();
		cursor = m_mainEditor->textCursor();
		cursor.movePosition(QTextCursor::NextBlock);
		cursor.select(QTextCursor::LineUnderCursor);
		text = cursor.selectedText().simplified();
		bool sectionEnd = text.startsWith("endin") || text.startsWith(";;");
		while (!sectionEnd && !cursor.atEnd()) {
			cursor.movePosition(QTextCursor::NextBlock);
			cursor.select(QTextCursor::LineUnderCursor);
			text = cursor.selectedText().simplified();
			sectionEnd = text.startsWith("endin") || text.startsWith(";;");
		}
		cursor.movePosition(QTextCursor::EndOfLine);
		cursor.setPosition(start, QTextCursor::KeepAnchor);
		m_mainEditor->setTextCursor(cursor);
		section = cursor.selectedText();
		section.replace(QChar(0x2029), QChar('\n'));
	}
	return section;
}

QString DocumentView::getActiveText()
{
	QTextCursor cursor = m_mainEditor->textCursor();
	QString selection = cursor.selectedText();
	if (selection == "") {
		cursor.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
		cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
		selection = cursor.selectedText();
	}
	selection.replace(QChar(0x2029), QChar('\n'));
	if (!selection.endsWith("\n")) {
		selection.append("\n");
	}
	return selection;
}

void DocumentView::syntaxCheck()
{
	TextEditor *editor = m_mainEditor;

    QTextCursor cursor = editor->textCursor();

    // send cursor position
    emit newLineAndColumn(cursor.blockNumber()+1 , cursor.positionInBlock()+1);


	// matchparenthesis. Code by Geir Vatterkar see https://doc.qt.io/archives/qq/QtQuarterly31.pdf
	// some corrections by Heinz van Saanen http://qt-apps.org/content/show.php/CLedit?content=125532 ; comments: http://www.qtcentre.org/archive/index.php/t-31084.html

	// Mark the bracket next to the cursor, then apply all extra selections:
	// find results, widget-channel lines and the matched bracket pair.
	m_bracketMatcher.updateForCursor(editor->textCursor());
	editor->setExtraSelections(extraSelectionsFor(editor));

	// syntax check
	cursor.movePosition(QTextCursor::EndOfWord, QTextCursor::MoveAnchor);
	cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);

    static const QRegularExpression wordBoundary(uR"(\b)"_s);
    auto words = cursor.selectedText().split(wordBoundary,
                                             SKIP_EMPTY_PARTS);
	QString opcodeSyntax;
	for(int i = 0; i < words.size(); i++) {
        auto word = words[words.size() - i - 1];
		if (m_opcodeTree->isOpcode(word)) {
            const QString syntax = m_opcodeTree->getSyntax(word);
			if(!syntax.isEmpty()) {
				opcodeSyntax = syntax;
				m_currentOpcodeText = syntax; // used by the parameter-mode hover
                break;
			}
		}
	}
	// Do not update the status bar on every cursor move: while the cursor is
	// travelling it would flicker through all the opcodes it passes. Only the
	// opcode under the settled cursor is reported.
	if (!opcodeSyntax.isEmpty()) {
		if (m_opcodeSyntaxTimer == nullptr) {
			m_opcodeSyntaxTimer = new QTimer(this);
			m_opcodeSyntaxTimer->setSingleShot(true);
			connect(m_opcodeSyntaxTimer, &QTimer::timeout, this, [this]() {
				if (!m_pendingOpcodeSyntax.isEmpty())
					emit opcodeSyntaxSignal(m_pendingOpcodeSyntax);
			});
		}
		m_pendingOpcodeSyntax = opcodeSyntax;
		m_opcodeSyntaxTimer->start(OPCODE_SYNTAX_DEBOUNCE_MS);
	}
	else {
		m_pendingOpcodeSyntax.clear();
		if (m_opcodeSyntaxTimer)
			m_opcodeSyntaxTimer->stop();
	}
	// Do not pop up the hover tooltip when a word is selected (e.g. on double
	// click): the opcode syntax is already shown in the status bar. The hover
	// is still used explicitly by parameter mode (showHoverText()).
	hideHoverText();

    // Tell the inspector which instrument/opcode contains the cursor, but only
    // after the cursor has settled. Moving around quickly must not repaint the
    // tree on every keystroke.
    if (m_scopeLineTimer == nullptr) {
        m_scopeLineTimer = new QTimer(this);
        m_scopeLineTimer->setSingleShot(true);
        connect(m_scopeLineTimer, &QTimer::timeout, this, [this]() {
            emit currentScopeLineChanged(currentScopeLine());
        });
    }
    m_scopeLineTimer->start(INSPECTOR_SCOPE_DEBOUNCE_MS);
}


QTextBlock DocumentView::currentScopeStartBlock() const
{
    TextEditor *editor = m_mainEditor;
    if (!editor)
        return {};

    // Find the instrument/opcode block that contains the cursor. Only names
    // from this block may be suggested: a variable defined in another
    // instrument is not visible here.
    static const QRegularExpression blockStartRx(
                u"^\\s*(instr|opcode)\\b"_s);
    static const QRegularExpression blockEndRx(
                u"^\\s*(endin|endop)\\b"_s);

    for (QTextBlock block = editor->textCursor().block(); block.isValid();
         block = block.previous()) {
        const QString line = block.text().trimmed();
        if (line.startsWith(QLatin1Char(';')) || line.startsWith("//"_L1))
            continue;
        // A closing line before the opening line means the cursor is between
        // two blocks, not inside either of them.
        if (blockEndRx.match(line).hasMatch())
            return {};
        if (blockStartRx.match(line).hasMatch())
            return block;
    }
    return {};
}

int DocumentView::currentScopeLine() const
{
    const QTextBlock block = currentScopeStartBlock();
    return block.isValid() ? block.blockNumber() + 1 : -1;
}

QTextBlock DocumentView::currentScopeEndBlock(const QTextBlock &startBlock) const
{
    if (!startBlock.isValid() || m_mainEditor == nullptr)
        return {};

    static const QRegularExpression startRx(uR"(^\s*(instr|opcode)\b)"_s);
    const QRegularExpressionMatch match = startRx.match(startBlock.text().trimmed());
    if (!match.hasMatch())
        return {};
    const QString endKeyword = match.captured(1) == "instr"_L1
            ? u"endin"_s : u"endop"_s;

    for (QTextBlock block = startBlock.next(); block.isValid(); block = block.next()) {
        if (block.text().trimmed().startsWith(endKeyword))
            return block;
    }
    return m_mainEditor->document()->lastBlock();
}

void DocumentView::setShowVariableOccurrences(bool enabled)
{
    m_showVariableOccurrences = enabled;
    if (enabled)
        updateOccurrencesFromSelection();
    else
        clearOccurrences();
}

void DocumentView::showWordOccurrences()
{
    if (m_mainEditor == nullptr)
        return;

    QTextCursor cursor = m_mainEditor->textCursor();
    QString word;
    if (cursor.hasSelection()) {
        const QString selected = cursor.selectedText();
        if (isIdentifierText(selected) && selectionCoversWholeWord(cursor))
            word = selected;
    }
    if (word.isEmpty()) {
        QTextCursor wordCursor = cursor;
        wordCursor.select(QTextCursor::WordUnderCursor);
        const QString underCursor = wordCursor.selectedText();
        if (isIdentifierText(underCursor))
            word = underCursor;
    }

    if (word.isEmpty()) {
        clearOccurrences();
        return;
    }
    showOccurrences(word);
}

void DocumentView::showOccurrences(const QString &word)
{
    m_occurrenceSelections.clear();
    m_occurrenceWord.clear();
    if (m_mainEditor == nullptr || word.isEmpty()) {
        applyOccurrenceSelections();
        return;
    }

    const QTextBlock start = currentScopeStartBlock();
    if (!start.isValid()) {
        applyOccurrenceSelections();
        return;
    }
    const QTextBlock end = currentScopeEndBlock(start);
    QTextDocument *document = m_mainEditor->document();
    const int startPosition = start.position();
    const int endPosition = end.isValid()
            ? end.position() + end.length()
            : document->characterCount();

    const QRegularExpression wordRx(
                uR"((?<![A-Za-z0-9_])%1(?![A-Za-z0-9_]))"_s.arg(
                    QRegularExpression::escape(word)));
    QColor background = m_mainEditor->palette().color(QPalette::Highlight);
    background.setAlpha(70);
    QTextCharFormat format;
    format.setBackground(background);

    QTextCursor search(document);
    search.setPosition(startPosition);
    while (true) {
        const QTextCursor match = document->find(
                    wordRx, search, QTextDocument::FindCaseSensitively);
        if (match.isNull() || match.selectionStart() >= endPosition)
            break;
        if (match.selectionEnd() <= endPosition) {
            QTextEdit::ExtraSelection selection;
            selection.cursor = match;
            selection.format = format;
            m_occurrenceSelections.append(selection);
        }
        search.setPosition(match.selectionEnd());
    }

    m_occurrenceWord = word;
    applyOccurrenceSelections();
}

void DocumentView::applyOccurrenceSelections()
{
    if (m_mainEditor != nullptr)
        m_mainEditor->setExtraSelections(extraSelectionsFor(m_mainEditor));
}

void DocumentView::clearOccurrences()
{
    m_occurrenceWord.clear();
    if (m_occurrenceSelections.isEmpty())
        return;
    m_occurrenceSelections.clear();
    applyOccurrenceSelections();
}

void DocumentView::updateOccurrencesFromSelection()
{
    if (!m_showVariableOccurrences || m_mainEditor == nullptr)
        return;

    const QTextCursor cursor = m_mainEditor->textCursor();
    QString word;
    if (cursor.hasSelection()) {
        const QString selected = cursor.selectedText();
        if (isIdentifierText(selected) && selectionCoversWholeWord(cursor))
            word = selected;
    }
    if (word.isEmpty()) {
        clearOccurrences();
        return;
    }
    showOccurrences(word);
}

QString DocumentView::currentScopeText() const
{
    TextEditor *editor = m_mainEditor;
    if (!editor)
        return {};

    const QTextBlock cursorBlock = editor->textCursor().block();
    const QTextBlock blockStart = currentScopeStartBlock();
    if (!blockStart.isValid())
        return {}; // not inside an instrument or opcode

    static const QRegularExpression blockStartRx(
                u"^\\s*(instr|opcode)\\b"_s);
    const QRegularExpressionMatch match =
            blockStartRx.match(blockStart.text().trimmed());
    const QString endKeyword = match.captured(1) == "instr"_L1
            ? u"endin"_s : u"endop"_s;

    QTextBlock blockEnd;
    for (QTextBlock block = cursorBlock; block.isValid(); block = block.next()) {
        if (block.text().trimmed().startsWith(endKeyword)) {
            blockEnd = block;
            break;
        }
    }
    if (!blockEnd.isValid())
        blockEnd = editor->document()->lastBlock();

    QString scopeText;
    for (QTextBlock block = blockStart; block.isValid(); block = block.next()) {
        QString line = block.text();
        // Ignore the rest of a line after a comment; semicolons inside string
        // literals are rare in variable names and do not matter here.
        const int semicolon = line.indexOf(QLatin1Char(';'));
        const int slashes = line.indexOf("//"_L1);
        int comment = -1;
        if (semicolon >= 0 && slashes >= 0)
            comment = qMin(semicolon, slashes);
        else
            comment = qMax(semicolon, slashes);
        if (comment >= 0)
            line.truncate(comment);
        scopeText += line;
        scopeText += QLatin1Char('\n');
        if (block == blockEnd)
            break;
    }
    return scopeText;
}

QStringList DocumentView::getCurrentScopeWords() const
{
    const QString scopeText = currentScopeText();
    if (scopeText.isEmpty())
        return {};

    // Names with an explicit type suffix take precedence over the classic
    // prefix convention: "gkfoo:a" is a local audio variable, while "gkfoo"
    // without a suffix is a global control variable.
    static const QRegularExpression localAnnotationRx(
                u"(?<!@)\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                               u":\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression globalAnnotationRx(
                u"\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                               u"@global\\s*:\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression globalSuffixRx(
                u"@global\\s*:\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression localSuffixRx(
                u":\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression identifierRx(
                u"\\b([A-Za-z_][A-Za-z0-9_]*)\\b"_s);
    // Language words which have a variable-like spelling but are not names.
    static const QSet<QString> keywords = {
        u"include"_s, u"endinclude"_s,
        u"opcode"_s, u"instr"_s,
        u"endin"_s, u"endop"_s
    };

    QSet<QString> explicitGlobals;
    for (auto it = globalAnnotationRx.globalMatch(scopeText); it.hasNext(); )
        explicitGlobals.insert(it.next().captured(1));

    QSet<QString> explicitLocals;
    for (auto it = localAnnotationRx.globalMatch(scopeText); it.hasNext(); )
        explicitLocals.insert(it.next().captured(1));

    const auto typeCharacter = [](QChar c) {
        static const QString types = u"akiSpfxbw"_s;
        return types.contains(c);
    };

    // Remove the type annotations before looking for identifiers, so the type
    // letter itself ("a" in "dry@global:a") is not mistaken for a variable.
    QString identifiersText = scopeText;
    identifiersText.remove(globalSuffixRx);
    identifiersText.remove(localSuffixRx);

    QSet<QString> seen;
    for (auto it = identifierRx.globalMatch(identifiersText); it.hasNext(); ) {
        const QString word = it.next().captured(1);
        if (keywords.contains(word))
            continue;
        if (m_opcodeTree && m_opcodeTree->isOpcode(word))
            continue;
        if (explicitGlobals.contains(word))
            continue; // offered from the global list instead
        if (explicitLocals.contains(word)) {
            seen.insert(word);
            continue;
        }
        // No explicit suffix: the first character decides the type, with a
        // leading g making it global.
        if (word.size() > 1 && word.at(0) == QLatin1Char('g')
                && typeCharacter(word.at(1)))
            continue; // classic global
        if (typeCharacter(word.at(0)))
            seen.insert(word);
    }

    QStringList words = seen.values();
    words.sort(Qt::CaseInsensitive);
    return words;
}

QStringList DocumentView::getCurrentScopeStringVariables() const
{
    const QString scopeText = currentScopeText();
    if (scopeText.isEmpty())
        return {};

    static const QRegularExpression localAnnotationRx(
                u"(?<!@)\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                               u":\\s*([akiSpfxbw])\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression globalAnnotationRx(
                u"\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                               u"@global\\s*:\\s*([akiSpfxbw])\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression globalSuffixRx(
                u"@global\\s*:\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression localSuffixRx(
                u":\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression identifierRx(
                u"\\b([A-Za-z_][A-Za-z0-9_]*)\\b"_s);

    QSet<QString> globalNames;
    for (auto it = globalAnnotationRx.globalMatch(scopeText); it.hasNext(); )
        globalNames.insert(it.next().captured(1));

    QSet<QString> localStrings;
    QSet<QString> localNonStrings;
    for (auto it = localAnnotationRx.globalMatch(scopeText); it.hasNext(); ) {
        const auto match = it.next();
        if (match.captured(2) == "S"_L1)
            localStrings.insert(match.captured(1));
        else
            localNonStrings.insert(match.captured(1));
    }

    QString identifiersText = scopeText;
    identifiersText.remove(globalSuffixRx);
    identifiersText.remove(localSuffixRx);

    QSet<QString> strings;
    for (auto it = identifierRx.globalMatch(identifiersText); it.hasNext(); ) {
        const QString word = it.next().captured(1);
        if (m_opcodeTree && m_opcodeTree->isOpcode(word))
            continue;
        if (globalNames.contains(word))
            continue; // global string variables come from the Inspector
        if (localStrings.contains(word)) {
            strings.insert(word);
            continue;
        }
        if (localNonStrings.contains(word))
            continue;
        if (word.size() > 1 && word.at(0) == QLatin1Char('g')
                && word.at(1) == QLatin1Char('S'))
            continue; // classic global string variable
        if (word.startsWith(QLatin1Char('S')))
            strings.insert(word);
    }

    QStringList result = strings.values();
    result.sort(Qt::CaseInsensitive);
    return result;
}


void DocumentView::scheduleAutoComplete(int delay)
{
    if (m_autoCompleteTimer == nullptr) {
        m_autoCompleteTimer = new QTimer(this);
        m_autoCompleteTimer->setSingleShot(true);
        connect(m_autoCompleteTimer, &QTimer::timeout,
                this, [this]() { autoCompleteAtCursor(false); });
    }
    m_autoCompleteTimer->stop();
    m_autoCompleteTimer->setInterval(delay);

    TextEditor *editor = (syntaxMenu->isVisible() && m_autocompleteEditor != nullptr)
            ? m_autocompleteEditor : activeEditor();
    if (editor != nullptr) {
        const QTextCursor cursor = editor->textCursor();
        m_autoCompleteCursorPosition = cursor.position();
        m_autoCompleteCursorAnchor = cursor.anchor();
    }
    m_autoCompleteTimer->start();
}


void DocumentView::autoCompleteAtCursor(bool force) {
    // While the popup is open the focus is on its list, so use the editor the
    // popup belongs to rather than the current focus widget.
    TextEditor *editor = (syntaxMenu->isVisible() && m_autocompleteEditor != nullptr)
            ? m_autocompleteEditor : activeEditor();
    m_autocompleteEditor = editor;
    syntaxMenu->setKeyTarget(editor);
    // TODO: replace all this with QCompleter
    QTextCursor cursor = editor->textCursor();
    int curIndex = cursor.position();

    // Use the logical block, not the visual line: a long path may wrap and
    // would otherwise be cut before the cursor.
    const QTextBlock block = cursor.block();
    QString line = block.text();
    const int lineStartPos = block.position();
    const int cursorPosInLine = cursor.positionInBlock();

    QString textBeforeCursor = line.left(cursorPosInLine);

    // Some constructs have a fixed candidate set (schedule, chnget, chnset).
    // They are allowed to complete inside an open string as well.
    CompletionContext context = completionContext(textBeforeCursor);

    // The command-line options of the <CsOptions> section are completed from
    // their own lists. Nothing else is offered there.
    const bool optionsSection = isInsideOptionsSection(block);
    if (optionsSection) {
        context = optionCompletionContext(textBeforeCursor);
        if (context.kind == CompletionContext::None) {
            destroySyntaxMenu();
            return;
        }
    }

    // Never complete inside an arbitrary string literal or after an open quote.
    if (context.kind == CompletionContext::None && hasOpenQuote(textBeforeCursor)) {
        destroySyntaxMenu();
        return;
    }

    textBeforeCursor = textBeforeCursor.remove(QRegularExpression(uR"([\)\,"'\]\}\s]+$)"_s)); // remove delimiters

    QRegularExpression rx(uR"(([\w]+)$)"_s);
    QRegularExpressionMatch match = rx.match(textBeforeCursor);

    QString word;
    int wordStartPosInLine = -1;
    if (match.hasMatch()) {
        word = match.captured(1);
        wordStartPosInLine = match.capturedStart(1);
    } else if (context.kind == CompletionContext::None) {
        destroySyntaxMenu();
        return; // No word found, exit
    }

    if (context.kind == CompletionContext::None
            && word.size() < (force ? 1 : 3)) {
        // Automatic completion starts after three characters. Invoking it
        // explicitly (Ctrl+M or the menu) also works for a single character,
        // but never for an empty word.
        destroySyntaxMenu();
        return;
    }

    QTextCursor selectionCursor;
    if (match.hasMatch()) {
        const int wordStartPosInDoc = lineStartPos + wordStartPosInLine;
        const int wordEndPosInDoc = wordStartPosInDoc + word.length();
        selectionCursor = editor->textCursor();
        selectionCursor.setPosition(wordStartPosInDoc);
        selectionCursor.setPosition(wordEndPosInDoc, QTextCursor::KeepAnchor);
    }

    int lineCommentIndex;

    if((lineCommentIndex = line.indexOf(";")) >= 0) {
        if(lineStartPos + lineCommentIndex < curIndex) {
            destroySyntaxMenu();
            return;
        }
    }
    if((lineCommentIndex = line.indexOf("//")) >= 0) {
        if(lineStartPos + lineCommentIndex < curIndex) {
            destroySyntaxMenu();
            return;
        }
    }

    static const QRegularExpression rxOpcodeOrInstrAtStart(uR"(^\s*(opcode|instr))"_s);
    if(rxOpcodeOrInstrAtStart.match(line).hasMatch()) {
        destroySyntaxMenu();
        return;
    }
    static const QRegularExpression rxTwoWords(uR"(\s*\w+\s+\w+)"_s);
    bool useFunction = false;
    if(!rxTwoWords.match(line).hasMatch()) {
        useFunction = true;
    }
    bool showSyntaxMenu = false;
    int completionWidth = qMax(14, m_autoCompleteMenuWidth);
    QSet<QString>menuWordsSeen;
    QRegularExpressionMatch rxmatch;

    // Add one of the fixed candidates (instrument, channel or string variable)
    // and remember the range to replace when it is accepted.
    QSet<QString> contextSeen;
    int contextMaxLength = 0;
    const int contextReplaceStart = lineStartPos + context.prefixStart;
    const int contextReplaceEnd = curIndex;
    static const QRegularExpression simpleNameRx(
                u"^[A-Za-z_][A-Za-z0-9_]*$"_s);
    auto addContextCompletion = [&](const QString &name, bool quoteIfNeeded) {
        if (name.isEmpty() || contextSeen.contains(name))
            return;
        if (!context.prefix.isEmpty()
                && !name.startsWith(context.prefix, Qt::CaseInsensitive))
            return;
        QString insert = name;
        if (!context.quoted && quoteIfNeeded
                && !simpleNameRx.match(name).hasMatch()) {
            insert = QLatin1Char('"') + name + QLatin1Char('"');
        }
        QAction *action = syntaxMenu->addCompletion(
                    name, insert, name, 0, this, SLOT(insertAutoCompleteText()));
        action->setProperty("autocompleteContext", true);
        action->setProperty("autocompleteReplaceStart", contextReplaceStart);
        action->setProperty("autocompleteReplaceEnd", contextReplaceEnd);
        contextSeen.insert(name);
        contextMaxLength = qMax(contextMaxLength, name.size());
        showSyntaxMenu = true;
    };

    if (context.kind != CompletionContext::None) {
        syntaxMenu->clearCompletions();
        if (context.kind == CompletionContext::Schedule) {
            for (const QString &instrument : m_instrumentNames)
                addContextCompletion(instrument, true);
            // A string variable is an expression, so it is only useful
            // outside the quoted form; inside quotes we suggest names only.
            if (!context.quoted) {
                for (const QString &variable : getCurrentScopeStringVariables())
                    addContextCompletion(variable, false);
                for (const QString &variable : m_globalStringVariables)
                    addContextCompletion(variable, false);
            }
        } else if (context.kind == CompletionContext::Property) {
            const QString prefix = context.prefix;
            const int slash = prefix.indexOf(QLatin1Char('/'));
            const QString channel = prefix.left(slash);
            const QString propertyPrefix = prefix.mid(slash + 1);
            const auto shortType = [](QString type) {
                if (type == "integer"_L1) return u"int"_s;
                if (type == "string"_L1) return u"str"_s;
                if (type == "boolean"_L1) return u"bool"_s;
                return type;
            };
            QList<WidgetPropertyInfo> matching;
            int nameWidth = 0;
            int typeWidth = 0;
            for (const WidgetPropertyInfo &property : widgetProperties(channel)) {
                if (!propertyPrefix.isEmpty()
                        && !property.name.startsWith(propertyPrefix,
                                                     Qt::CaseInsensitive)) {
                    continue;
                }
                matching.append(property);
                nameWidth = qMax(nameWidth, property.name.size());
                typeWidth = qMax(typeWidth, shortType(property.type).size());
            }
            // Keep the same three-column shape as the opcode menu: property,
            // type and description, separated by two spaces.
            nameWidth += 2;
            typeWidth += 2;
            for (const WidgetPropertyInfo &property : matching) {
                const QString insert = channel + QLatin1Char('/') + property.name;
                if (contextSeen.contains(insert))
                    continue;
                const QString type = shortType(property.type);
                QString toolTip = property.type;
                if (!property.description.isEmpty()) {
                    if (!toolTip.isEmpty())
                        toolTip += u" — "_s;
                    toolTip += property.description;
                }
                QString display = property.name.leftJustified(nameWidth)
                        + type.leftJustified(typeWidth)
                        + property.description;
                QAction *action = syntaxMenu->addCompletion(
                            display, insert,
                            toolTip.isEmpty() ? insert : toolTip,
                            0, this, SLOT(insertAutoCompleteText()));
                action->setProperty("autocompleteContext", true);
                action->setProperty("autocompleteReplaceStart",
                                    contextReplaceStart);
                action->setProperty("autocompleteReplaceEnd",
                                    contextReplaceEnd);
                contextSeen.insert(insert);
                contextMaxLength = qMax(contextMaxLength, display.size());
                showSyntaxMenu = true;
            }
        } else if (context.kind == CompletionContext::Path
                   || context.kind == CompletionContext::Include
                   || context.kind == CompletionContext::EnvPath) {
            const bool include = context.kind == CompletionContext::Include;
            const bool envPath = context.kind == CompletionContext::EnvPath;
            const QString prefix = context.prefix;
            const int slash = prefix.lastIndexOf(QLatin1Char('/'));
            const QString directoryPrefix = slash >= 0
                    ? prefix.left(slash + 1) : QString();
            const QString filePrefix = slash >= 0
                    ? prefix.mid(slash + 1) : prefix;

            // Where to look. An #include name is resolved next to the document
            // first, then in the configured include paths (CsoundQt's INCDIR
            // plus the document's --env:INCDIR options), then in the working
            // directory, as the scan does. QDir::filePath() keeps an absolute
            // prefix as it is, so an absolute path is looked up only once.
            QStringList lookups;
            if (include) {
                lookups.append(QDir(documentDirectory()).filePath(directoryPrefix));
                for (const QString &path : includeSearchPaths()) {
                    if (!path.isEmpty())
                        lookups.append(QDir(path).filePath(directoryPrefix));
                }
                lookups.append(QDir::current().filePath(directoryPrefix));
                lookups.removeDuplicates();
            } else if (envPath) {
                // The value of an --env: option is a path written in the
                // document. Relative paths are resolved like the other path
                // completions, against the document's directory.
                QString lookup = directoryPrefix;
                if (lookup.isEmpty())
                    lookup = documentDirectory();
                else if (!QDir::isAbsolutePath(lookup))
                    lookup = QDir(documentDirectory()).absoluteFilePath(lookup);
                lookups.append(lookup);
            } else {
                QString lookup = directoryPrefix;
                // A regular path (diskin2 etc.) keeps the shell-like
                // convenience of expanding '~'.
                if (lookup.startsWith("~/"_L1))
                    lookup = QDir::homePath() + lookup.mid(1);
                else if (lookup.isEmpty())
                    lookup = documentDirectory();
                else if (!QDir::isAbsolutePath(lookup))
                    lookup = QDir(documentDirectory()).absoluteFilePath(lookup);
                lookups.append(lookup);
            }

            for (const QString &lookup : lookups) {
                QDir directory(lookup);
                if (!directory.exists())
                    continue;
                const QFileInfoList entries = directory.entryInfoList(
                            QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot,
                            QDir::DirsFirst | QDir::Name);
                for (const QFileInfo &entry : entries) {
                    if (!entry.isDir()) {
                        if (include && !isIncludeFile(entry))
                            continue;
                        if (!include && !envPath && !isSoundFile(entry))
                            continue;
                    }
                    if (!filePrefix.isEmpty()
                            && !entry.fileName().startsWith(
                                filePrefix, Qt::CaseInsensitive)) {
                        continue;
                    }
                    QString insert = directoryPrefix + entry.fileName();
                    QString display = entry.fileName();
                    if (entry.isDir()) {
                        // Keep the directory open so the next path segment can
                        // be completed as well: Lib/sound/...
                        insert += QLatin1Char('/');
                        display += QLatin1Char('/');
                    }
                    if (contextSeen.contains(insert))
                        continue;
                    QAction *action = syntaxMenu->addCompletion(
                                display, insert, entry.absoluteFilePath(),
                                0, this, SLOT(insertAutoCompleteText()));
                    action->setProperty("autocompleteContext", true);
                    action->setProperty("autocompleteReplaceStart",
                                        contextReplaceStart);
                    action->setProperty("autocompleteReplaceEnd",
                                        contextReplaceEnd);
                    contextSeen.insert(insert);
                    contextMaxLength = qMax(contextMaxLength,
                                            display.size());
                    showSyntaxMenu = true;
                }
            }
        } else if (context.kind == CompletionContext::Option) {
            for (const QString &option : context.candidates)
                addContextCompletion(option, false);
        } else {
            for (const QString &channel : widgetChannels())
                addContextCompletion(channel, false);
        }
        if (!showSyntaxMenu)
            destroySyntaxMenu();
        else
            completionWidth = qMax(completionWidth, contextMaxLength + 2);
    }
    else if (selectionCursor.position() > selectionCursor.anchor()) { // Only at the end of the word
        syntaxMenu->clearCompletions();
        // Only variables used in the current instrument/opcode block. Do not
        // scan the whole document: names from other instruments are not in
        // scope here.
        const QStringList scopeWords = getCurrentScopeWords();
        for (const QString &var : scopeWords) {
            if (var.startsWith(word) && word != var) {
                syntaxMenu->addCompletion(var, var, QString(), 1, this,
                                          SLOT(insertAutoCompleteText()));
                showSyntaxMenu = true;
                menuWordsSeen.insert(var);
            }
        }
        // Global variables are visible from every instrument and opcode. The
        // Inspector scans them from the whole document.
        for (const QString &var : m_globalVariables) {
            if (!menuWordsSeen.contains(var) && var.startsWith(word) && word != var) {
                syntaxMenu->addCompletion(var, var, QString(), 1, this,
                                          SLOT(insertAutoCompleteText()));
                showSyntaxMenu = true;
                menuWordsSeen.insert(var);
            }
        }
        // opcodes and parameters
        auto opcodedefs = m_opcodeTree->getMatchingOpcodes(word);
        bool allEqual = true;
        for(int i = 0; i < opcodedefs.size(); i++) {
            if (opcodedefs[i].opcodeName != word) {
                allEqual = false;
                break;
            }
        }
        if (opcodedefs.size() > 0 && !allEqual) {
            // The width of the menu is configurable: the entries are as wide
            // as the setting says, in characters. The name column is as wide
            // as the longest opcode name plus two spaces, so that the
            // signatures line up.
            int nameColumn = 0;
            for (const Opcode &opcode : opcodedefs)
                nameColumn = qMax(nameColumn, opcode.opcodeName.size());
            nameColumn += 2;
            const int typeColumn = 5; // " :pvs"
            const int menuWidth = qMax(nameColumn + typeColumn + 4,
                                       m_autoCompleteMenuWidth);
            completionWidth = menuWidth;
            for(int i = 0; i < opcodedefs.size(); i++) {
                QString opcodeName = opcodedefs[i].opcodeName;
                QString outArgs = opcodedefs[i].outArgs;
                // The parentheses around the arguments are left out here, they
                // take too much space in the menu.
                auto inArgs = withoutParentheses(opcodedefs[i].inArgs);
                QString typeSuffix;
                if (!outArgs.isEmpty()) {
                    switch(outArgs[0].toLatin1()) {
                    case 'a':
                        typeSuffix = " :a"; break;
                    case 'k':
                        typeSuffix = " :k"; break;
                    case 'i':
                        typeSuffix = " :i"; break;
                    case 'x':
                        typeSuffix = " :x"; break;
                    case 'S':
                        typeSuffix = " :S"; break;
                    case 'f':
                        typeSuffix = " :pvs"; break;
                    }
                }
                // Keep three fixed columns. The middle column is elided on its
                // own, so the ellipsis stays in the arguments and never
                // replaces the output type. An empty output column is simply
                // left out, so it cannot cause an ellipsis at the line end.
                const int argsWidth = qMax(0, menuWidth - nameColumn - typeColumn);
                if (inArgs.size() > argsWidth && argsWidth > 0)
                    inArgs = inArgs.left(argsWidth - 1) + "…";
                else if (argsWidth == 0)
                    inArgs.clear();

                QString text = opcodeName.leftJustified(nameColumn)
                        + inArgs.leftJustified(argsWidth);
                if (!typeSuffix.isEmpty())
                    text += typeSuffix.rightJustified(typeColumn);
                else
                    text = text.trimmed();

                QString syntaxText;
                if (opcodedefs[i].newStyle) {
                    // Csound 7 UDOs are called with function syntax, and the
                    // output types are not variables to prepend.
                    syntaxText = QString("%1(%2)").arg(
                        opcodedefs[i].opcodeName.simplified(),
                        opcodedefs[i].inArgs.simplified());
                } else if (useFunction && !opcodedefs[i].inArgs.isEmpty()) {
                    syntaxText = QString("%1(%2)").arg(
                        opcodedefs[i].opcodeName.simplified(),
                        opcodedefs[i].inArgs.simplified());
                } else {
                    syntaxText= opcodedefs[i].outArgs.simplified();
                    if (!opcodedefs[i].outArgs.isEmpty())
                        syntaxText += " ";
                    syntaxText += opcodedefs[i].opcodeName.simplified();
                    if (!opcodedefs[i].inArgs.isEmpty()) {
                        if (opcodedefs[i].inArgs.contains("(x)") ) {
                            syntaxText += "(x)"; // avoid other text like (with no rate restriction)
                        } else {
                            // The arguments keep their parentheses, but there
                            // is no space between the name and them.
                            const QString inArgs = opcodedefs[i].inArgs.simplified();
                            syntaxText += inArgs.startsWith(QLatin1Char('(')) ? inArgs
                                                                             : " " + inArgs;
                        }
                    }
                }
                syntaxMenu->addCompletion(text, syntaxText, syntaxText, 0, this,
                                          SLOT(insertAutoCompleteText()));
                showSyntaxMenu = true;
                menuWordsSeen.insert(opcodeName);
            }
        }
        QString wordlow = word.toLower(); // this must be AFTER the word is corrected

        for(const QString &tag: tagWords) {
            if(tag.startsWith(wordlow, Qt::CaseInsensitive) && word != tag) {
                syntaxMenu->addCompletion(tag, tag, QString(), 3, this,
                                          SLOT(insertAutoCompleteText()));
                showSyntaxMenu = true;
            }
        }
    }
    else {
        destroySyntaxMenu();
    }
    if (showSyntaxMenu) {
        // Keep every match; the popup shows a bounded viewport instead of
        // dropping suggestions. The list scrolls with the wheel and the
        // arrow keys.
        syntaxMenu->refreshCompletions(m_autoCompleteMenuMaxLines,
                                       completionWidth);
    }
    int anchorPos = curIndex;
    if (context.kind != CompletionContext::None && context.prefixStart >= 0)
        anchorPos = lineStartPos + context.prefixStart;
    else if (match.hasMatch() && wordStartPosInLine >= 0)
        anchorPos = lineStartPos + wordStartPosInLine;
    anchorPos = qBound(block.position(), anchorPos,
                       block.position() + block.length() - 1);

    if(showSyntaxMenu && syntaxMenu->hasCompletions()) {

        // While the same token is being typed, the popup must not follow the
        // caret: keep its position and let the rebuilt list filter the
        // entries. A new token (or a different editor) is allowed to move it.
        const bool keepPosition = syntaxMenu->isVisible()
                && m_autocompleteAnchor == anchorPos
                && m_autocompleteAnchorEditor == editor;

        // Place the popup next to the start of the token. Near the lower edge
        // of the screen flip it above the token so it does not cover what is
        // being typed. If it cannot fit on either side, use the larger side
        // and cap its height.
        QTextCursor anchorCursor = editor->textCursor();
        anchorCursor.setPosition(anchorPos);
        const QRect anchorRect = editor->cursorRect(anchorCursor);
        const QWidget *viewport = editor->viewport();
        // Leave a small gap so the menu does not sit right against the token.
        const int gap = 4;
        const QPoint anchorBottomLeft =
                viewport->mapToGlobal(QPoint(anchorRect.left(), anchorRect.bottom() + 1 + gap));
        const QPoint anchorTopLeft =
                viewport->mapToGlobal(QPoint(anchorRect.left(), anchorRect.top() - gap));

        QScreen *screen = QGuiApplication::screenAt(anchorBottomLeft);
        if (!screen)
            screen = editor->screen();
        const QRect avail = screen ? screen->availableGeometry() : QRect();

        const QSize preferred = syntaxMenu->sizeHint();
        const int spaceBelow = avail.isValid()
                ? avail.bottom() - anchorBottomLeft.y() + 1 : preferred.height();
        const int spaceAbove = avail.isValid()
                ? anchorTopLeft.y() - avail.top() : preferred.height();

        bool above;
        if (preferred.height() <= spaceBelow)
            above = false;
        else if (preferred.height() <= spaceAbove)
            above = true;
        else
            above = spaceAbove > spaceBelow; // does not fit anywhere: scroll

        const int available = above ? spaceAbove : spaceBelow;
        const int height = qMin(preferred.height(), qMax(1, available));
        const int width = avail.isValid()
                ? qMin(preferred.width(), avail.width()) : preferred.width();
        // Constrain the height only when the popup really has to shrink. The
        // list inside it is what scrolls; the popup is sized to the visible
        // window. Reset the limits otherwise, since they persist between calls.
        if (height < preferred.height()) {
            syntaxMenu->setAvailableHeight(height);
            syntaxMenu->setMinimumHeight(height);
            syntaxMenu->setMaximumHeight(height);
        } else {
            syntaxMenu->setMinimumHeight(0);
            syntaxMenu->setMaximumHeight(QWIDGETSIZE_MAX);
        }
        // Force the size of this invocation so a changed width setting is
        // visible immediately, also while the popup is already open.
        syntaxMenu->resize(width, height);

        if (keepPosition) {
            // The popup is already on screen for this token: resizing keeps
            // its top-left corner, so it does not jump while the user types.
        } else {
            int x = anchorBottomLeft.x();
            int y = above ? anchorTopLeft.y() - height : anchorBottomLeft.y();
            if (avail.isValid()) {
                x = qBound(avail.left(), x, qMax(avail.left(), avail.right() - width + 1));
                y = qBound(avail.top(), y, qMax(avail.top(), avail.bottom() - height + 1));
            }

            syntaxMenu->move(x, y);
            m_autocompleteAnchor = anchorPos;
            m_autocompleteAnchorEditor = editor;
            syntaxMenu->show();
        }
    }
}

void DocumentView::rehighlightSyntax()
{
    m_highlightUpdate = true;
    m_highlighter.rehighlight();
    m_highlightUpdate = false;
}

void DocumentView::textChanged() {
    if (m_highlightUpdate) {
        // The highlighter applied formats; nothing was edited.
        return;
    }
    if (internalChange) {
        internalChange = false;
		return;
	}

    // Any edit invalidates the positions of the occurrence highlights.
    clearOccurrences();

    //test: seems to do the trick and solve "always modified bug
    bool modified = m_mainEditor->document()->isModified();
    setModified(modified);
    // Let the page update its modified indicator in both directions: an undo
    // back to the saved state must clear the marker as well.
    emit contentsChanged();
    if(!modified) {
        return;
    }

    // This should go somewhere else, maybe when escape is pressed?
    // unmarkErrorLines();

    if(!(m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE))
        return;
    syntaxCheck();
    if(m_autoComplete) {
        if(m_autoCompleteTimer != nullptr && m_autoCompleteTimer->isActive()) {
            m_autoCompleteTimer->stop();
        }
        // Never trigger autocomplete as a result of a paste. The flag is set
        // by TextEditor for every paste path (Ctrl+V, context menu, paste()
        // API, middle-click, drag-and-drop) and consumed here.
        const bool wasPaste = m_mainEditor->consumePaste();
        auto key = m_mainEditor->getLastKey();
        if(!wasPaste && key != Qt::Key_Backspace && key != Qt::Key_Delete && key != Qt::Key_Space && key != Qt::Key_Comma && key != Qt::Key_BraceLeft && key != Qt::Key_Colon) {
            // Only perform autocomplete if the change was not generated by deleting.
            // autoCompleteAtCursor decides whether an open quote belongs to a
            // context-aware completion (schedule/chnget/chnset) or not.
            // With the popup already open, a shorter pause is enough: the list
            // is only filtered, not opened from scratch.
            scheduleAutoComplete(syntaxMenu->isVisible()
                                 ? COMPLETION_UPDATE_DELAY_MS
                                 : m_autoCompleteDelay);
        }

        // this->autoCompleteAtCursor();
    }
    if (m_findBar && m_findBar->isVisible() && !m_findQuery.isEmpty()) {
        refreshFindAfterEdit();
    }
}

void DocumentView::cancelAutoCompleteOnCursorMove()
{
    if (!m_autoCompleteTimer || !m_autoCompleteTimer->isActive())
        return;

    auto *editor = qobject_cast<TextEditor *>(sender());
    if (!editor || editor != m_mainEditor) {
        m_autoCompleteTimer->stop();
        return;
    }

    const QTextCursor cursor = editor->textCursor();
    // Typing also moves the caret. The textChanged handler records that new
    // position when it schedules completion, so only a subsequent caret move
    // cancels the pending popup.
    if (cursor.position() != m_autoCompleteCursorPosition
            || cursor.anchor() != m_autoCompleteCursorAnchor)
        m_autoCompleteTimer->stop();
}

void DocumentView::escapePressed()
{
	// A card still waiting out the hover delay is cancelled, and Escape means
	// the same for that name as it does for a visible card: leave it alone
	// while the pointer stays on it.
	if (!m_hoverHelpPendingWord.isEmpty()) {
		m_hoverHelpDismissedWord = m_hoverHelpPendingWord;
		cancelPendingHoverHelp();
		return;
	}
	
	if (m_docstringPopup != nullptr && !m_docstringPopup->isHidden())
        m_docstringPopup->hide();
	
	// The ctrl+hover card is passive: it never has the focus, so Escape for it
	// arrives here. A dismissed name is not reopened while the pointer stays.
	if (!m_hoverHelpWord.isEmpty()) {
		m_hoverHelpDismissedWord = m_hoverHelpWord;
		// if (m_docstringPopup != nullptr)
        //     m_docstringPopup->hide();
		stopHoverHelpTracking();
		return;
	}
	if (!m_occurrenceSelections.isEmpty()) {
		clearOccurrences();
		return;
	}
	emit editorEscapePressed();
	if (!m_widgetChannelSelections.isEmpty()) {
		clearWidgetChannelHighlights();
		return;
	}
	if (m_opcodeInsertBar && m_opcodeInsertBar->isVisible()) {
		m_opcodeInsertBar->hideBar();
		return;
	}
	if (m_findBar && m_findBar->isVisible()) {
		closeFindBar();
		return;
	}
	if(errorMarked)
		unmarkErrorLines();

	if (m_mainEditor->getParameterMode()) {
		// Force unselecting
		m_mainEditor->moveCursor(QTextCursor::NextCharacter);
		m_mainEditor->moveCursor(QTextCursor::PreviousCharacter);
		exitParameterMode();
	} else if (m_hoverText->isVisible()){
		hideHoverText();
	} else {
		qDebug()<<"closeExtraPanels now omitted -  let know, if it should be brought back.";
		//emit closeExtraPanels();
	}
}

void DocumentView::finishParameterMode()
{
	if (m_mainEditor->getParameterMode()) {
		killToEnd();
		exitParameterMode();
	} else {
		hideHoverText();
	}
}

void DocumentView::exitParameterMode()
{
	m_mainEditor->setParameterMode(false);
	hideHoverText();
//	parameterButton->setVisible(false);
}

void DocumentView::indentNewLine()
{
	QTextCursor linecursor = m_mainEditor->textCursor();
	if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
			   || m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
		linecursor.movePosition(QTextCursor::PreviousBlock);
		linecursor.select(QTextCursor::LineUnderCursor);
		QString line = linecursor.selectedText();
        static const QRegularExpression regex(uR"(\s+)"_s);
		if (line.indexOf(regex) == 0) {
            // old: m_mainEditor->insertPlainText(regex.cap());

            // TODO: check! Not sure if done the right way! (Qt6)
            // see https://github.com/Komet/MediaElch/issues/1086
            QString text = regex.match(line).captured();
            qDebug() << "Captured text" << text; // SHORTHEN LATER!
            m_mainEditor->insertPlainText(text);
		}
	}
}

void DocumentView::findReplace()
{
	ensureFindBar();

	// If a word (or any selection) is selected, use it as the query.
	QString selection = m_mainEditor->textCursor().selectedText();
	if (!selection.isEmpty()
			&& !selection.contains(QChar::ParagraphSeparator)
			&& selection != m_findBar->query()) {
		m_findBar->setQuery(selection);
	}
	m_findBar->showBar();
	// Refresh matches for the retained query (the document may have changed).
	if (!m_findBar->query().isEmpty())
		findQueryChanged(m_findBar->query());
}

void DocumentView::ensureFindBar()
{
	if (m_findBar)
		return;
	m_findBar = new FindBar(m_mainEditor);
	connect(m_findBar, &FindBar::queryChanged, this, &DocumentView::findQueryChanged);
	connect(m_findBar, &FindBar::findNextRequested, this, &DocumentView::findNext);
	connect(m_findBar, &FindBar::findPreviousRequested, this, &DocumentView::findPrevious);
	connect(m_findBar, &FindBar::replaceRequested, this, &DocumentView::replaceCurrent);
	connect(m_findBar, &FindBar::replaceAllRequested, this, &DocumentView::replaceAll);
	connect(m_findBar, &FindBar::closed, this, &DocumentView::closeFindBar);
}

void DocumentView::ensureOpcodeInsertBar()
{
	if (m_opcodeInsertBar)
		return;
	m_opcodeInsertBar = new OpcodeInsertBar(m_mainEditor);
	connect(m_opcodeInsertBar, &OpcodeInsertBar::opcodeChosen, this, [this](const QString &opcode) {
		internalChange = true; // suppress autocomplete/syntax work for this edit
		QTextCursor cursor = m_mainEditor->textCursor();
		cursor.insertText(opcode);
		m_mainEditor->setTextCursor(cursor);
		m_opcodeInsertBar->hideBar();
	});
}

void DocumentView::showOpcodeInsertBar()
{
	ensureOpcodeInsertBar();
	m_opcodeInsertBar->setOpcodes(m_opcodeTree->opcodeNameList());
	m_opcodeInsertBar->showBar();
}

void DocumentView::collectFindMatches()
{
	m_findMatches.clear();
	if (m_findQuery.isEmpty() || !m_mainEditor)
		return;

	QTextDocument *doc = m_mainEditor->document();
	const QTextDocument::FindFlags flags = smartCaseFlags(m_findQuery);
	QTextCursor cursor(doc);
	while (true) {
		cursor = doc->find(m_findQuery, cursor, flags);
		if (cursor.isNull())
			break;
		const int start = cursor.selectionStart();
		const int length = cursor.selectionEnd() - start;
		m_findMatches.append(qMakePair(start, length));
		if (length == 0) // safety net against a zero-length match loop
			cursor.movePosition(QTextCursor::NextCharacter);
	}
}

void DocumentView::updateFindHighlights(bool moveCursor)
{
	m_findSelections.clear();
	if (!m_mainEditor)
		return;

	QTextDocument *doc = m_mainEditor->document();
	for (int i = 0; i < m_findMatches.size(); ++i) {
		const int start = m_findMatches.at(i).first;
		const int length = m_findMatches.at(i).second;
		QTextEdit::ExtraSelection selection;
		QTextCursor cursor(doc);
		cursor.setPosition(start);
		cursor.setPosition(start + length, QTextCursor::KeepAnchor);
		selection.cursor = cursor;
		selection.format.setBackground(i == m_findCurrent
									   ? QColor(255, 150, 0, 160)   // current match
									   : QColor(255, 235, 60, 110)); // other matches
		m_findSelections.append(selection);
	}

	if (moveCursor && m_findCurrent >= 0 && m_findCurrent < m_findMatches.size()) {
		const int start = m_findMatches.at(m_findCurrent).first;
		const int length = m_findMatches.at(m_findCurrent).second;
		QTextCursor cursor(doc);
		cursor.setPosition(start);
		cursor.setPosition(start + length, QTextCursor::KeepAnchor);
		m_mainEditor->setTextCursor(cursor);
		m_mainEditor->ensureCursorVisible();
	}
	// Re-apply the highlights together with the parenthesis matching
	// selections (syntaxCheck seeds its selection list from m_findSelections).
	syntaxCheck();
}

void DocumentView::updateFindStatus()
{
	if (!m_findBar)
		return;
	if (m_findQuery.isEmpty()) {
		m_findBar->setMatchCount(0, 0);
		return;
	}
	if (m_findMatches.isEmpty()) {
		m_findBar->setStatus(tr("No matches"));
		return;
	}
	m_findBar->setMatchCount(m_findCurrent + 1, m_findMatches.size());
}

void DocumentView::refreshFindAfterEdit()
{
	if (m_findQuery.isEmpty())
		return;
	collectFindMatches();
	if (m_findMatches.isEmpty())
		m_findCurrent = -1;
	else if (m_findCurrent >= m_findMatches.size())
		m_findCurrent = m_findMatches.size() - 1;
	else if (m_findCurrent < 0)
		m_findCurrent = 0;
	updateFindHighlights(false);
	updateFindStatus();
}

void DocumentView::findQueryChanged(const QString &query)
{
	m_findQuery = query;
	m_findCurrent = -1;
	collectFindMatches();
	if (!m_findMatches.isEmpty()) {
		// Start from the first match at or after the cursor; wrap if needed.
		const int pos = m_mainEditor->textCursor().position();
		m_findCurrent = 0;
		for (int i = 0; i < m_findMatches.size(); ++i) {
			if (m_findMatches.at(i).first >= pos) {
				m_findCurrent = i;
				break;
			}
		}
	}
	updateFindHighlights(true);
	updateFindStatus();
}

void DocumentView::findNext()
{
	if (m_findMatches.isEmpty())
        return;
	m_findCurrent = (m_findCurrent + 1) % m_findMatches.size();
	updateFindHighlights(true);
	updateFindStatus();
}

void DocumentView::findPrevious()
{
	ensureFindBar();
	if (!m_findBar->isVisible()) {
		// Triggered by a shortcut while the bar is closed: find backwards from
		// the cursor, wrapping to the end, without asking.
		const QString query = m_findBar->query();
		if (query.isEmpty())
			return;
		QTextDocument::FindFlags flags = smartCaseFlags(query);
		flags |= QTextDocument::FindBackward;
		if (!m_mainEditor->find(query, flags)) {
			QTextCursor cursor = m_mainEditor->textCursor();
			cursor.movePosition(QTextCursor::End);
			m_mainEditor->setTextCursor(cursor);
			m_mainEditor->find(query, flags);
		}
		return;
	}
	if (m_findMatches.isEmpty())
        return;
	m_findCurrent = (m_findCurrent - 1 + m_findMatches.size()) % m_findMatches.size();
	updateFindHighlights(true);
	updateFindStatus();
}

void DocumentView::replaceCurrent()
{
	if (!m_findBar || m_findQuery.isEmpty())
		return;

	QTextCursor cursor = m_mainEditor->textCursor();
	bool matches = cursor.hasSelection();
	if (matches) {
		const QString selected = cursor.selectedText();
		if (smartCaseFlags(m_findQuery).testFlag(QTextDocument::FindCaseSensitively))
			matches = selected == m_findQuery;
		else
			matches = QString::compare(selected, m_findQuery, Qt::CaseInsensitive) == 0;
	}
	if (matches) {
		internalChange = true; // suppress autocomplete/syntax work for this edit
		cursor.insertText(m_findBar->replacement());
	}

	// Recompute and select the next match at or after the cursor (wraps).
	collectFindMatches();
	if (m_findMatches.isEmpty()) {
		m_findCurrent = -1;
		updateFindHighlights(false);
		updateFindStatus();
		return;
	}
	const int pos = m_mainEditor->textCursor().position();
	m_findCurrent = 0;
	for (int i = 0; i < m_findMatches.size(); ++i) {
		if (m_findMatches.at(i).first >= pos) {
			m_findCurrent = i;
			break;
		}
	}
	updateFindHighlights(true);
	updateFindStatus();
}

void DocumentView::replaceAll()
{
	if (!m_findBar || m_findQuery.isEmpty())
		return;

	QTextDocument *doc = m_mainEditor->document();
	const QTextDocument::FindFlags flags = smartCaseFlags(m_findQuery);
	const QString replacement = m_findBar->replacement();
	QTextCursor cursor(doc);
	int count = 0;
	while (true) {
		cursor = doc->find(m_findQuery, cursor, flags);
		if (cursor.isNull())
			break;
		internalChange = true; // suppress autocomplete/syntax work per edit
		cursor.insertText(replacement);
		++count;
	}

	collectFindMatches();
	m_findCurrent = m_findMatches.isEmpty() ? -1 : 0;
	updateFindHighlights(m_findCurrent >= 0);
	if (count == 0)
		m_findBar->setStatus(tr("No matches"));
	else
		m_findBar->setStatus(tr("Replaced %n occurrence(s)", "", count));
}

void DocumentView::closeFindBar()
{
	if (!m_findBar)
		return;
	m_findBar->hideBar();
	m_findSelections.clear();
	m_findMatches.clear();
	m_findCurrent = -1;
	// Drop the find highlights, keeping any parenthesis highlight.
	syntaxCheck();
	m_mainEditor->setFocus();
}

void DocumentView::gotoLineDialog()
{
    auto dialog = new QDialog(this);
    dialog->resize(300, 120);
    dialog->setModal(true);
    dialog->setWindowTitle(tr("Go to Line"));

    auto layout = new QGridLayout(dialog);

    auto label = new QLabel(tr("Go To Line: "));
    layout->addWidget(label, 0, 0, Qt::AlignRight|Qt::AlignVCenter);

    auto lineSpinBox = new QSpinBox(dialog);
    lineSpinBox->unsetLocale(); // for chinease numbers to work
    lineSpinBox->setRange(0, 99999999);
    layout->addWidget(lineSpinBox, 0, 1, Qt::AlignLeft|Qt::AlignVCenter);

    auto okButton = new QPushButton(tr("Ok"));
    layout->addWidget(okButton, 10, 1, Qt::AlignCenter|Qt::AlignVCenter);
    connect(okButton, &QPushButton::clicked, this,
            [this, lineSpinBox](){ this->jumpToLine(lineSpinBox->value()); });
    connect(okButton, &QPushButton::clicked, this, [dialog](){ dialog->close(); });

    lineSpinBox->setFocus();
    lineSpinBox->selectAll();
    dialog->show();
}

void DocumentView::highlightWidgetChannel()
{
	const QString channel = channelAtCursor();
	// An empty channel also clears a previous outline when the shortcut is
	// pressed on a line that does not contain a literal channel.
	m_channelHighlightSource = ChannelHighlightSource::None;
	m_activeChannelHighlight = channel;
	emit channelHighlightRequested(channel);
}

void DocumentView::getToIn()
{
    // Change chnget/chnset to invalue/outvalue
	internalChange = true;
	m_mainEditor->setPlainText(changeToInvalue(m_mainEditor->toPlainText()));
	m_mainEditor->document()->setModified(true);  // Necessary, or is setting it locally enough?
}

void DocumentView::inToGet()
{
	internalChange = true;
	m_mainEditor->setPlainText(changeToChnget(m_mainEditor->toPlainText()));
	m_mainEditor->document()->setModified(true);
}

void DocumentView::insertAutoCompleteText()
{
    // The popup has the focus by now, so use the editor the completion was
    // opened for, not the current focus widget.
    TextEditor *editor = m_autocompleteEditor != nullptr
            ? m_autocompleteEditor : activeEditor();
	if (editor != 0) {
		internalChange = true;
		QAction *action = static_cast<QAction *>(QObject::sender());
		bool insertComplete = static_cast<MySyntaxMenu *>(action->parent())->insertComplete;

		if (action->property("autocompleteContext").toBool()) {
			const int start = action->property("autocompleteReplaceStart").toInt();
			const int end = action->property("autocompleteReplaceEnd").toInt();
			QTextCursor contextCursor = editor->textCursor();
			if (start >= 0 && end >= start) {
				contextCursor.setPosition(start);
				contextCursor.setPosition(end, QTextCursor::KeepAnchor);
				editor->setTextCursor(contextCursor);
			}
			const QString insert = action->data().toString();
			editor->insertPlainText(insert);
			// Completing a directory only gets the user into it. Offer its
			// contents right away, exactly as if completion had been invoked
			// again (Ctrl+M). Queued, because this runs from the triggered()
			// signal of an action the new completion will delete.
			if (insert.endsWith(QLatin1Char('/')))
				QTimer::singleShot(0, this, [this]() { autoCompleteAtCursor(true); });
			return;
		}

		QTextCursor cursor = editor->textCursor();
		cursor.select(QTextCursor::WordUnderCursor);

        while (!cursor.atBlockStart()) {
            cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
            QString selectedChar = cursor.selectedText();
            // Remove selection for next iteration
            cursor.clearSelection();
            if (!delimiters.contains(selectedChar)) {
                cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::MoveAnchor);
                break;
            }
        }

        cursor.select(QTextCursor::WordUnderCursor);

		editor->setTextCursor(cursor);

		QTextCursor cursor2 = editor->textCursor();
		cursor2.movePosition(QTextCursor::StartOfLine,QTextCursor::KeepAnchor);
		bool noOutargs = false;
		if (!cursor2.selectedText().simplified().isEmpty()) { // Text before cursor, don't put outargs
			noOutargs = true;
		}
		internalChange = true;
		if (insertComplete) {
			if (noOutargs) {
				QString syntaxText = action->data().toString();
                int index =syntaxText.indexOf(QRegularExpression(uR"(\w\s+\w)"_s));
				editor->insertPlainText(syntaxText.mid(index + 1).trimmed());  // right returns the whole string if index < 0
			}
			else {
				editor->insertPlainText(action->data().toString());
			}
            QString syntaxText = action->data().toString();
			QStringList syntaxSections = syntaxText.simplified().split(" "); // was split("")
            QString actionText = action->text();
            actionText = actionText.split(" ").at(0);
            if (m_autoParameterMode && m_opcodeTree->isOpcode(actionText) && syntaxSections.size() > 1) {
				m_mainEditor->moveCursor(QTextCursor::StartOfBlock);
				m_mainEditor->setParameterMode(true);
				prevParameter();
			}
		} else {
			int index = action->text().indexOf(" ");
			if (index > 0) {
				editor->insertPlainText(action->text().left(index));
			}
			else {
				editor->insertPlainText(action->text());
			}
		}
	}
}

void DocumentView::findString(QString query)
{
	ensureFindBar();
	if (!query.isEmpty())
		m_findBar->setQuery(query);

	const QString currentQuery = m_findBar->query();
	if (currentQuery.isEmpty())
		return;

	if (m_findBar->isVisible()) {
		// Search again from the current position, wrapping silently.
		if (currentQuery != m_findQuery) {
			m_findQuery = currentQuery;
			collectFindMatches();
			m_findCurrent = -1;
		}
		if (m_findMatches.isEmpty())
			refreshFindAfterEdit();
		findNext();
		return;
	}

	// Bar hidden: find next occurrence from the cursor, wrapping to the top
	// without asking (unlike the old dialog).
	const QTextDocument::FindFlags flags = smartCaseFlags(currentQuery);
	if (!m_mainEditor->find(currentQuery, flags)) {
		QTextCursor cursor = m_mainEditor->textCursor();
		cursor.movePosition(QTextCursor::Start);
		m_mainEditor->setTextCursor(cursor);
		m_mainEditor->find(currentQuery, flags);
	}
}

void DocumentView::evaluate()
{
	emit evaluate(getActiveText());
}

void DocumentView::createContextMenu(QPoint pos)
{
	QMenu *menu = m_mainEditor->createStandardContextMenu();
	menu->addSeparator();
	menu->addAction(tr("Evaluate Selection/Line"), this, SLOT(evaluate()));
	menu->addAction(tr("Opcode Help"), this, SLOT(opcodeHelp()));
	// The definition index lives in the document page, so the request is
	// passed on instead of jumping here. The name under the mouse is
	// used, not the one at the cursor: the user may right-click on a name
	// without having put the cursor there first.
	QAction *goToSource = menu->addAction(tr("Go to Source"));
	connect(goToSource, &QAction::triggered, this, [this, pos]() {
		const QTextCursor cursor = cursorAt(pos);
		const QString includePath = SourceCursor::includePathAt(cursor);
		if (!includePath.isEmpty())
			emit goToSourceIncludeRequested(includePath);
		else
			emit goToSourceRequested(SourceCursor::identifierAt(cursor),
									 SourceCursor::isScheduleArgument(cursor));
	});
	menu->addAction(tr("Show/hide line numbers"), this, SLOT(toggleLineArea()));
	menu->addSeparator();
	QMenu *opcodeMenu = menu->addMenu("Opcodes");
	QMenu *mainMenu = 0;
	QMenu *subMenu;
	QString currentMain = "";
	for (int i = 0; i < m_opcodeTree->getCategoryCount(); i++) {
		QString category = m_opcodeTree->getCategory(i);
		QStringList categorySplit = category.split(":");
		if (!categorySplit.isEmpty() && categorySplit[0] != currentMain) {
			mainMenu = opcodeMenu->addMenu(categorySplit[0]);
			currentMain = categorySplit[0];
		}
		if (categorySplit.size() < 2) {
			subMenu = mainMenu;
		}
		else {
			subMenu = mainMenu->addMenu(categorySplit[1]);
		}
		foreach(Opcode opcode, m_opcodeTree->getOpcodeList(i)) {
			QAction *action = subMenu->addAction(opcode.opcodeName, this, SLOT(opcodeFromMenu()));
			QString opcodeText = opcode.outArgs;
			opcodeText += (!opcode.outArgs.isEmpty()
						   && !opcode.outArgs.endsWith(" ")
						   && !opcode.opcodeName.startsWith(" ") ?
							   " " : "");
			opcodeText += opcode.opcodeName;
			opcodeText += (!opcode.inArgs.isEmpty()
						   && !opcode.inArgs.startsWith(" ")
						   && !opcode.inArgs.startsWith("(")
						   && !opcode.opcodeName.endsWith(" ") ?
							   " " : "");
			opcodeText += opcode.inArgs;
			action->setData(opcodeText);
		}
	}
	menu->exec(m_mainEditor->viewport()->mapToGlobal(pos));
	delete menu;
}

void DocumentView::cut()
{
	m_mainEditor->cut();
}

void DocumentView::copy()
{
	m_mainEditor->copy();
}

void DocumentView::paste()
{
	m_mainEditor->paste();
}

void DocumentView::undo()
{
	m_mainEditor->undo();
	escapePressed();
}

void DocumentView::redo()
{
	m_mainEditor->redo();
}

void DocumentView::comment()
{
	internalChange = true;
	QString commentChar = "";
	if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
			|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
		commentChar = ";";
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	if (cursor.position() > cursor.anchor()) {
		int temp = cursor.anchor();
		cursor.setPosition(cursor.position());
		cursor.setPosition(temp, QTextCursor::KeepAnchor);
	}
	if (!cursor.atBlockStart()) {
		cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
	}
	int start = cursor.selectionStart();
	QString text = cursor.selectedText();
	if (text.startsWith(commentChar)) {
		uncomment();
		return;
	}
	text.prepend(commentChar);
	text.replace(QChar(QChar::ParagraphSeparator), QString("\n" + commentChar));
	if (text.endsWith("\n" + commentChar) ) {
		text.chop(1);
	}
	cursor.insertText(text);
	cursor.setPosition(start);
	cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, text.size());
	m_mainEditor->setTextCursor(cursor);
}

void DocumentView::uncomment()
{
	internalChange = true;
	QString commentChar = "";
	if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
			|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
		commentChar = ";";
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	if (cursor.position() > cursor.anchor()) {
		int temp = cursor.anchor();
		cursor.setPosition(cursor.position());
		cursor.setPosition(temp, QTextCursor::KeepAnchor);
	}
	QString text = cursor.selectedText();
	if (!cursor.atBlockStart() && !text.startsWith(commentChar)) {
		cursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
		text = cursor.selectedText();
	}
	if (text.startsWith(commentChar)) {
		text.remove(0,1);
	}
	int start = cursor.selectionStart();
	text.replace(QChar(QChar::ParagraphSeparator), QString("\n"));
	text.replace(QString("\n" + commentChar), QString("\n")); //TODO make more robust
	cursor.insertText(text);
	cursor.setPosition(start);
	cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, text.size());
	m_mainEditor->setTextCursor(cursor);
}

QString DocumentView::indentString() const
{
	// When the "use spaces" option is on, indent with the configured number
	// of spaces. Otherwise keep the historical behaviour: a tab character,
	
	if (m_mainEditor->tabUseSpaces()) {
		return QString(m_mainEditor->tabSpaces(), QLatin1Char(' '));
	}
	return u"\t"_s;
}

void DocumentView::indent()
{
	internalChange = true;
	QString indentChar = "";
	if (m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
			|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE) {
		indentChar = indentString();
	}
	if (indentChar.isEmpty()) {
		return;  // nothing is indented in this mode
	}
	QTextCursor cursor = m_mainEditor->textCursor();
	QTextCursor::MoveMode moveMode = cursor.selectedText().isEmpty() ? QTextCursor::MoveAnchor : QTextCursor::KeepAnchor;
	if (cursor.position() > cursor.anchor()) {
		int temp = cursor.anchor();
		cursor.setPosition(cursor.position());
		cursor.setPosition(temp, QTextCursor::KeepAnchor);
	}
	if (!cursor.atBlockStart()) {
		cursor.movePosition(QTextCursor::StartOfLine, moveMode);
	}
	int start = cursor.selectionStart();
	QString text = cursor.selectedText();
	text.prepend(indentChar);
	text.replace(QChar(QChar::ParagraphSeparator), "\n" + indentChar);
	if (text.endsWith("\n" + indentChar)) {
		text.chop(indentChar.size());
	}
	cursor.insertText(text);
	cursor.setPosition(start);
	cursor.movePosition(QTextCursor::NextCharacter, moveMode, text.size());
	m_mainEditor->setTextCursor(cursor);
}

// Removes one indentation step from the start of a single line. In spaces mode
// that is a leading tab or up to tabSpaces leading spaces; otherwise it is a
// leading tab (Csound modes), or a leading tab 
static QString removeOneIndent(const QString &line, bool useSpaces, int tabSpaces)
{
	if (useSpaces) {
		if (line.startsWith(QLatin1Char('\t'))) {
			return line.mid(1);
		}
		int count = 0;
		while (count < tabSpaces && count < line.size()
			   && line.at(count) == QLatin1Char(' ')) {
			++count;
		}
		return line.mid(count);
	}
	if (line.startsWith(QLatin1Char('\t'))) {
		return line.mid(1);
	}
	return line;
}

void DocumentView::unindent()
{
	if (!(m_mode == EDIT_CSOUND_MODE || m_mode == EDIT_ORC_MODE
			|| m_mode == EDIT_SCO_MODE || m_mode == EDIT_INC_MODE)) {
		return;  // nothing is indented in this mode
	}

	internalChange = true;
	const bool useSpaces = m_mainEditor->tabUseSpaces();
	const int tabSpaces = m_mainEditor->tabSpaces();
	
	QTextCursor cursor = m_mainEditor->textCursor();
	const int anchor = cursor.anchor();
	const int position = cursor.position();
	const int selStart = qMin(anchor, position);
	const int selEnd = qMax(anchor, position);

	// Unindent whole lines: from the line containing the start of the
	// selection (or the cursor) up to the line containing its end. If the
	// selection ends exactly at the beginning of a line, that line is not
	// really selected and is left untouched. Working on whole lines keeps the
	// result independent of where the cursor sits within the line.
	QTextBlock firstBlock = m_mainEditor->document()->findBlock(selStart);
	QTextBlock lastBlock = m_mainEditor->document()->findBlock(selEnd);
	if (anchor != position && lastBlock != firstBlock
			&& lastBlock.position() == selEnd) {
		lastBlock = lastBlock.previous();
	}

	const int rangeStart = firstBlock.position();
	const int rangeEnd = lastBlock.position() + lastBlock.text().size();

	QTextCursor work(m_mainEditor->document());
	work.setPosition(rangeStart);
	work.setPosition(rangeEnd, QTextCursor::KeepAnchor);
	const QString oldText = work.selectedText();

	// Remove one indentation step from each line and remember how many
	// characters each line lost, so the cursor and selection can be kept.
	const QStringList oldLines = oldText.split(QChar(QChar::ParagraphSeparator));
	QStringList newLines;
	newLines.reserve(oldLines.size());
	for (const QString &line : oldLines) {
		newLines << removeOneIndent(line, useSpaces, tabSpaces);
	}
	const QString newText = newLines.join(u"\n"_s);
	if (newText == oldText) {
		return;  // the lines were not indented; nothing to do
	}

	// Map a position in the old text to the corresponding position after the
	// leading whitespace has been removed.
	auto adjustPosition = [&](int absPos) {
		int adjusted = absPos;
		int lineStart = rangeStart;
		for (int i = 0; i < oldLines.size(); ++i) {
			const int removed = oldLines[i].size() - newLines[i].size();
			if (removed > 0 && absPos > lineStart) {
				adjusted -= qMin(removed, absPos - lineStart);
			}
			lineStart += oldLines[i].size() + 1;  // + paragraph separator
		}
		return adjusted;
	};
	const int newAnchor = adjustPosition(anchor);
	const int newPosition = adjustPosition(position);

	work.insertText(newText);

	cursor.setPosition(newAnchor);
	cursor.setPosition(newPosition, QTextCursor::KeepAnchor);
	m_mainEditor->setTextCursor(cursor);
}

void DocumentView::tabsToSpaces()
{
	QTextDocument *document = m_mainEditor->document();

	// A tab only counts as indentation when everything before it on the line
	// is whitespace. Tabs after the first non-whitespace character (tabs
	// "within" a line) are never touched.
	auto isIndentationTab = [](const QString &line) {
		const int tabIndex = line.indexOf(QLatin1Char('\t'));
		if (tabIndex < 0) {
			return false;
		}
		for (int i = 0; i < tabIndex; ++i) {
			if (line.at(i) != QLatin1Char(' ') && line.at(i) != QLatin1Char('\t')) {
				return false;
			}
		}
		return true;
	};

	bool changed = false;
	for (QTextBlock block = document->begin(); block.isValid(); block = block.next()) {
		if (isIndentationTab(block.text())) {
			changed = true;
			break;
		}
	}
	if (!changed) {
		return;
	}

	internalChange = true;
	const QString spacesString(m_mainEditor->tabSpaces(), QLatin1Char(' '));
	QTextCursor cursor(document);
	cursor.beginEditBlock();
	for (QTextBlock block = document->begin(); block.isValid(); ) {
		QTextBlock next = block.next();
		const QString line = block.text();
		int i = 0;
		QString indent;
		while (i < line.size()
			   && (line.at(i) == QLatin1Char(' ') || line.at(i) == QLatin1Char('\t'))) {
			if (line.at(i) == QLatin1Char('\t')) {
				indent += spacesString;
			} else {
				indent += QLatin1Char(' ');
			}
			++i;
		}
		if (indent != line.left(i)) {  // the indentation contained a tab
			QTextCursor lineCursor(block);
			lineCursor.movePosition(QTextCursor::StartOfBlock);
			lineCursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, i);
			lineCursor.insertText(indent);
		}
		block = next;
	}
	cursor.endEditBlock();
}

void DocumentView::killLine()
{
	QTextCursor cursor = m_mainEditor->textCursor();
	if (!cursor.atBlockStart()) {
		cursor.movePosition(QTextCursor::StartOfBlock, QTextCursor::MoveAnchor);
	}
	cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
	cursor.insertText("");
}

void DocumentView::killToEnd()
{
	QTextCursor cursor = m_mainEditor->textCursor();
	if (!cursor.atBlockEnd()) {
		cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
	}
	cursor.insertText("");
}

void DocumentView::duplicateLine()
{
    QTextCursor cursor = m_mainEditor->textCursor();
    const QTextBlock block = cursor.block();
    const QString line = block.text();
    const int blockStart = block.position();
    // Where in the line the caret sits; kept on the copy.
    const int column = cursor.position() - blockStart;
    // Insert after the line's own text, before its line break (or at the end
    // of the document for the last line): in both cases the copy ends up on a
    // line of its own directly below.
    QTextCursor insertAt(cursor);
    insertAt.movePosition(QTextCursor::EndOfBlock);
    insertAt.insertText(QLatin1Char('\n') + line);
    // Put the caret on the copy, at the same column as before, so repeating
    // the action keeps duplicating the line the caret is now on.
    QTextCursor copy(m_mainEditor->document());
    copy.setPosition(blockStart + line.size() + 1
                     + qMin(column, line.size()));
    m_mainEditor->setTextCursor(copy);
}

void DocumentView::moveLineUp()
{
    moveLine(-1);
}

void DocumentView::applyEditorActions(const QList<QAction *> &actions)
{
    TextEditor *editor = m_mainEditor;
    for (QAction *action : actions) {
        // The action may still be registered with the editor of another page
        // (connectActions() runs on every tab switch), so take it back first:
        // an action registered on two editors would fire in both. Only editors
        // are touched: the action may also be in a menu or a toolbar, and must
        // stay there.
        const QList<QObject *> associated = action->associatedObjects();
        for (QObject *object : associated) {
            if (auto *oldEditor = qobject_cast<TextEditor *>(object))
                oldEditor->removeAction(action);
        }
        // Widget-scoped so the shortcut only fires with the editor focused.
        action->setShortcutContext(Qt::WidgetWithChildrenShortcut);
        // Shown in Settings -> Shortcuts so the user knows the key only applies
        // while the editor has focus.
        action->setProperty("shortcutScope", "editor");
        if (editor != nullptr)
            editor->addAction(action);
    }
}

void DocumentView::moveLineDown()
{
    moveLine(1);
}

void DocumentView::moveLine(int offset)
{
    QTextCursor cursor = m_mainEditor->textCursor();
    const QTextBlock current = cursor.block();
    const QTextBlock neighbour = offset < 0 ? current.previous() : current.next();
    if (!neighbour.isValid())
        return;
    const QString currentText = current.text();
    const QString neighbourText = neighbour.text();
    // The caret keeps its column; a shorter line cannot hold it.
    const int column = cursor.position() - current.position();
    // Replace both lines with the same two lines in the other order. The span
    // ends at the last character of the lower line, so the line break after it
    // is left where it is.
    const int start = qMin(current.position(), neighbour.position());
    const int end = qMax(current.position() + currentText.size(),
                         neighbour.position() + neighbourText.size());
    // Where the moved line starts once the swap is done: the neighbour's old
    // position above, or after the neighbour's text below.
    const int movedStart = offset < 0
            ? start : start + neighbourText.size() + 1;
    QTextCursor span(m_mainEditor->document());
    span.setPosition(start);
    span.setPosition(end, QTextCursor::KeepAnchor);
    span.beginEditBlock();
    span.insertText(offset < 0
                    ? currentText + QLatin1Char('\n') + neighbourText
                    : neighbourText + QLatin1Char('\n') + currentText);
    span.endEditBlock();
    QTextCursor moved(m_mainEditor->document());
    moved.setPosition(movedStart + qMin(column, currentText.size()));
    m_mainEditor->setTextCursor(moved);
}

void DocumentView::markErrorLines(QList<QPair<int, QString> > lines)
{
    auto fmt = m_highlighter.getFormat("default");
    auto fg = fmt.foreground().color();
    auto bg = fmt.background().color();
    bool originallyMod = m_mainEditor->document()->isModified();
	internalChange = true;
	QTextCharFormat errorFormat;
    // make error background depend on color theme
    QColor errbg = fg.lightness() < bg.lightness() ? bg.darker(200) : bg.lighter(200);
    errbg.setRed(errbg.blue() * 2.5);
    errorFormat.setBackground(QBrush(errbg));
	QTextCursor cur = m_mainEditor->textCursor();
	cur.movePosition(QTextCursor::Start, QTextCursor::MoveAnchor);
    for(int i = 0; i < lines.size(); i++) {
		int line = lines[i].first;
        cur.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor, line-1);
		cur.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
		cur.mergeCharFormat(errorFormat);
		internalChange = true;
		m_mainEditor->setTextCursor(cur);
		errorMarked = true;
		if (!originallyMod) {
			m_mainEditor->document()->setModified(false);
		}
	}
}

void DocumentView::unmarkErrorLines()
{
	if (!errorMarked)
		return;
	int position = m_mainEditor->verticalScrollBar()->value();
	QTextCursor currentCursor = m_mainEditor->textCursor();
	errorMarked = false;
	m_mainEditor->selectAll();
	internalChange = true;
	QTextCursor cur = m_mainEditor->textCursor();
	QTextCharFormat format = cur.blockCharFormat();
	format.clearBackground();
	cur.setCharFormat(format);
	internalChange = true;
	m_mainEditor->setTextCursor(cur);  //sets format
	internalChange = true;
	m_mainEditor->setTextCursor(currentCursor); //returns cursor to initial position
	m_mainEditor->verticalScrollBar()->setValue(position); //return document display to initial position
}


void editorJumpToLine(TextEditor *editor, int line) {
    int maxlines = editor->document()->blockCount();
    if(line > maxlines)
        line = maxlines;
    QTextCursor cursor(editor->document()->findBlockByLineNumber(line-1));
    editor->moveCursor(QTextCursor::End);
    editor->setTextCursor(cursor);
}

void DocumentView::jumpToLine(int line, bool mark)
{
    jumpToLineInternal(line, mark, true);
}

void DocumentView::jumpToLineWithoutFocus(int line)
{
    // Navigate the editor to the given line but leave keyboard focus where it
    // is (used when clicking/scrolling the inspector: the text position
    // follows, but the user keeps working in the tree).
    jumpToLineInternal(line, true, false);
}

void DocumentView::jumpToLineInternal(int line, bool mark, bool focus)
{
    if(mark)
        markCurrentPosition();
    TextEditor *editor = currentLineEditor();
    editorJumpToLine(editor, line);
    editor->ensureCursorVisible();
    if (focus) {
        // A jump (goto-line, go-back, inspector Enter) hands keyboard focus
        // to the editor so typing and cursor keys work right away.
        // activateWindow() first: the inspector may live in a floating dock
        // (its own window), in which case setFocus() alone would not transfer
        // focus out of it.
        editor->activateWindow();
        editor->setFocus(Qt::ActiveWindowFocusReason);
    }
}

TextEditor *DocumentView::currentLineEditor() const
{
    return m_mainEditor;
}

TextEditor *DocumentView::activeEditor() const
{
    return m_mainEditor;
}

QString DocumentView::identifierAtCursor() const
{
    TextEditor *editor = activeEditor();
    if (!editor)
        return QString();
    return SourceCursor::identifierAt(editor->textCursor());
}

bool DocumentView::isScheduleArgumentAtCursor() const
{
    TextEditor *editor = activeEditor();
    if (!editor)
        return false;
    return SourceCursor::isScheduleArgument(editor->textCursor());
}

QString DocumentView::includePathAtCursor() const
{
    TextEditor *editor = activeEditor();
    if (!editor)
        return QString();
    return SourceCursor::includePathAt(editor->textCursor());
}

QTextCursor DocumentView::cursorAt(const QPoint &pos) const
{
    // The position of a context menu request is in the coordinates of the
    // editor's viewport, which is what cursorForPosition() takes. It must not
    // be converted again: the line number area is a viewport margin, so
    // subtracting it a second time would move the position into the text to
    // the left of the one that was clicked.
    return m_mainEditor->cursorAt(pos);
}

void DocumentView::jumpToDefinition(int line, int column)
{
    if (line < 1)
        return;
    jumpToLine(line);
    // Leave the cursor on the name itself, so that the user sees where the
    // definition is and can carry on editing from there.
    TextEditor *editor = currentLineEditor();
    QTextBlock block = editor->document()->findBlockByNumber(line - 1);
    if (!block.isValid())
        return;
    const int position = block.position() + column;
    if (column < 0 || position > block.position() + block.length() - 1)
        return;
    QTextCursor cursor(editor->document());
    cursor.setPosition(position);
    editor->setTextCursor(cursor);
    editor->ensureCursorVisible();
}

void DocumentView::goBackToPreviousPosition() {
    if(cursorPositions.isEmpty())
        return;
    int lastPos = cursorPositions.takeLast();
    this->jumpToLine(lastPos, false);
}

void DocumentView::gotoNextLine()
{
	m_mainEditor->moveCursor(QTextCursor::Down);
}

void DocumentView::opcodeFromMenu()
{
	QAction *action = (QAction *) QObject::sender();
	QTextCursor cursor = m_mainEditor->textCursor();
	QString text = action->data().toString();
	cursor.insertText(text);
}

void DocumentView::contextMenuEvent(QContextMenuEvent *event)
{
	qDebug() << "DocumentView::contextMenuEvent";
	// The position is given in the coordinates of the editor's viewport, so
	// that the menu appears where the click was and the name under the mouse
	// is found.
	createContextMenu(m_mainEditor->viewport()->mapFromGlobal(event->globalPos()));
}

QString DocumentView::changeToChnget(QString text)
{
	QStringList lines = text.split("\n");
	QString newText = "";
	foreach (QString line, lines) {
		if (line.contains("invalue")) {
			line.replace("invalue", "chnget");
		}
		else if (line.contains("outvalue")) {
			line.replace("outvalue", "chnset");
			int arg1Index = line.indexOf("chnset") + 7;
			int arg2Index = line.indexOf(",") + 1;
            int arg2EndIndex = line.indexOf(QRegularExpression(uR"([\s]*[;])"_s), arg2Index);
			QString arg1 = line.mid(arg1Index, arg2Index-arg1Index - 1).trimmed();
			QString arg2 = line.mid(arg2Index, arg2EndIndex-arg2Index).trimmed();
			QString comment = line.mid(arg2EndIndex);
			qDebug() << arg1 << arg2 << arg2EndIndex;
			line = line.mid(0, arg1Index) + " " +  arg2 + ", " + arg1;
			if (arg2EndIndex > 0)
				line += " " + comment;
		}
		newText += line + "\n";
	}
	return newText;
}

QString DocumentView::changeToInvalue(QString text)
{
	QStringList lines = text.split("\n");
	QString newText = "";
	foreach (QString line, lines) {
		if (line.contains("chnget")) {
			line.replace("chnget", "invalue");
		}
		else if (line.contains("chnset")) {
			line.replace("chnset", "outvalue");
			int arg1Index = line.indexOf("outvalue") + 8;
			int arg2Index = line.indexOf(",") + 1;
            int arg2EndIndex = line.indexOf(QRegularExpression(uR"([\s]*[;])"_s), arg2Index);
			QString arg1 = line.mid(arg1Index, arg2Index-arg1Index - 1).trimmed();
			QString arg2 = line.mid(arg2Index, arg2EndIndex-arg2Index).trimmed();
			QString comment = line.mid(arg2EndIndex);
			qDebug() << arg1 << arg2 << arg2EndIndex;
			line = line.mid(0, arg1Index) + " " + arg2 + ", " + arg1;
			if (arg2EndIndex > 0)
				line += " " + comment;
		}
		newText += line + "\n";
	}
	return newText;
}

void DocumentView::destroySyntaxMenu()
{
    syntaxMenu->clearCompletions();
	syntaxMenu->hide();
    m_autocompleteAnchor = -1;
    m_autocompleteAnchorEditor = nullptr;
    //  syntaxMenu = 0;
}

void DocumentView::opcodeHelp()
{
	emit setHelp();
}

void DocumentView::restoreCursorPosition()
{
	// check if cursor must be moved to old position (after selecting a section)
	if (m_oldCursorPosition>=0) {
		qDebug()<<"Restoring cursor position to "<<m_oldCursorPosition;
		QTextCursor cursor = m_mainEditor->textCursor();
		cursor.setPosition(m_oldCursorPosition); 
		m_mainEditor->setTextCursor(cursor);
		m_oldCursorPosition = -1;
	}
}

void DocumentView::setGlobalVariables(const QStringList &variables) {
    m_globalVariables = variables;
}

void DocumentView::setGlobalStringVariables(const QStringList &variables) {
    m_globalStringVariables = variables;
}

void DocumentView::setInstrumentNames(const QStringList &names) {
    m_instrumentNames = names;
}

void DocumentView::setUdoNames(const QStringList &names) {
    m_udoNames = QSet<QString>(names.begin(), names.end());
}

void DocumentView::showQuickHelp(const QString &title, const QString &html)
{
    TextEditor *editor = activeEditor();
    if (editor == nullptr)
        editor = m_mainEditor;
    if (editor == nullptr)
        return;
    // An explicit lookup owns the card from here on: the pointer may well be
    // somewhere else, so the ctrl+hover tracking must not close it.
    stopHoverHelpTracking();
    cancelPendingHoverHelp();
    m_hoverHelpDismissedWord.clear();
    const bool ispassive = true;
    showQuickHelpAt(title, html,
                    editor->viewport()->mapToGlobal(editor->cursorRect().bottomLeft() + QPoint(0, 4)), ispassive);
}

void DocumentView::showQuickHelpAt(const QString &title, const QString &html,
                                   const QPoint &globalAnchor, bool passive)
{
    if (m_docstringPopup == nullptr)
        m_docstringPopup = new DocstringPopup(this);
    // Use the editor's syntax theme rather than the application palette: the
    // card is about the text under it.
    const QTextCharFormat theme = getDefaultFormat();
    m_quickHelpShownWord = title;
    m_docstringPopup->setThemeColors(theme.foreground().color(),
                                     theme.background().color());
    m_docstringPopup->showHtml(title, html, globalAnchor, passive);
}

void DocumentView::setWidgetChannels(const QStringList &channels) {
    m_widgetChannels = channels;
}

void DocumentView::setChannelHighlightMode(ChannelHighlightMode mode) {
	if (m_channelHighlightMode == mode)
		return;
	m_channelHighlightMode = mode;
	m_channelHighlightSource = ChannelHighlightSource::None;
	if (mode != ChannelHighlightMode::Full
			&& mode != ChannelHighlightMode::MouseOnly)
		m_hoverChannel.clear();
	if (mode == ChannelHighlightMode::Never
			|| mode == ChannelHighlightMode::MouseOnly) {
		m_activeChannelHighlight.clear();
		emit channelHighlightRequested(QString());
	} else {
		updateChannelHighlightFromCursor();
	}
}

void DocumentView::setWidgetChannelsProvider(
        const std::function<QStringList()> &provider) {
    m_widgetChannelsProvider = provider;
}

QStringList DocumentView::widgetChannels() const {
    return m_widgetChannelsProvider ? m_widgetChannelsProvider() : m_widgetChannels;
}

void DocumentView::setWidgetPropertiesProvider(
        const std::function<QList<WidgetPropertyInfo>(const QString &)> &provider) {
    m_widgetPropertiesProvider = provider;
}

QList<WidgetPropertyInfo> DocumentView::widgetProperties(
        const QString &channelOrName) const {
    return m_widgetPropertiesProvider
            ? m_widgetPropertiesProvider(channelOrName)
            : QList<WidgetPropertyInfo>();
}

void DocumentView::setDocumentDirectoryProvider(
        const std::function<QString()> &provider) {
    m_documentDirectoryProvider = provider;
}

QString DocumentView::documentDirectory() const {
    QString directory = m_documentDirectoryProvider
            ? m_documentDirectoryProvider() : QString();
    if (directory.isEmpty())
        directory = QDir::currentPath();
    return directory;
}

void DocumentView::setIncludeSearchPathsProvider(
        const std::function<QStringList()> &provider) {
    m_includeSearchPathsProvider = provider;
}

QStringList DocumentView::includeSearchPaths() const {
    return m_includeSearchPathsProvider
            ? m_includeSearchPathsProvider() : QStringList();
}

void DocumentView::setTheme(const QString &theme)
{
    BaseView::setTheme(theme);
    // The bracket background follows the editor palette.
    TextEditor *editor = currentLineEditor();
    if (editor)
        editor->setExtraSelections(extraSelectionsFor(editor));
    // The quick help card is a top-level window with colours of its own; keep a
    // visible one in step with a theme switch.
    if (m_docstringPopup != nullptr && m_docstringPopup->isVisible()) {
        const QTextCharFormat defaultFormat = getDefaultFormat();
        m_docstringPopup->setThemeColors(defaultFormat.foreground().color(),
                                         defaultFormat.background().color());
    }
    if (syntaxMenu)
        syntaxMenu->applyStyle();
}

namespace {

constexpr int CompletionSeparatorRole = Qt::UserRole + 1;

class CompletionSeparatorDelegate : public QStyledItemDelegate
{
public:
    using QStyledItemDelegate::QStyledItemDelegate;

    QSize sizeHint(const QStyleOptionViewItem &option,
                   const QModelIndex &index) const override
    {
        if (index.data(CompletionSeparatorRole).toBool())
            return QSize(option.rect.width(), 5);
        return QStyledItemDelegate::sizeHint(option, index);
    }

    void paint(QPainter *painter, const QStyleOptionViewItem &option,
               const QModelIndex &index) const override
    {
        if (!index.data(CompletionSeparatorRole).toBool()) {
            QStyledItemDelegate::paint(painter, option, index);
            return;
        }

        painter->save();
        painter->setPen(QColor(COMPLETION_MENU_SEPARATOR));
        const int y = option.rect.center().y();
        painter->drawLine(option.rect.left() + 6, y, option.rect.right() - 6, y);
        painter->restore();
    }
};

} // namespace

MySyntaxMenu::MySyntaxMenu(QWidget *parent) : QFrame(parent)
{
    // A frameless popup rather than a QMenu: the completion list is a normal
    // widget, with its own scrolling, and no QMenu/QWidgetAction ownership or
    // cached-layout rules get in the way.
    setObjectName(u"completionPopup"_s);
    setWindowFlags(Qt::Popup | Qt::FramelessWindowHint | Qt::NoDropShadowWindowHint);
    setAttribute(Qt::WA_TranslucentBackground);
    setFocusPolicy(Qt::NoFocus);

    auto *layout = new QVBoxLayout(this);
    layout->setContentsMargins(4, 4, 4, 4);
    layout->setSpacing(0);

    m_completionList = new QListWidget(this);
    m_completionList->setFrameShape(QFrame::NoFrame);
    m_completionList->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_completionList->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_completionList->setSelectionMode(QAbstractItemView::SingleSelection);
    // Opcode rows carry their own ellipsis in the arguments column. Letting the
    // view elide them again would replace the output type with "…".
    m_completionList->setTextElideMode(Qt::ElideNone);
    m_completionList->setFocusPolicy(Qt::StrongFocus);
    m_completionList->setUniformItemSizes(false);
    m_completionList->setWordWrap(false);
    m_completionList->setItemDelegate(new CompletionSeparatorDelegate(m_completionList));
    m_completionList->installEventFilter(this);
    layout->addWidget(m_completionList);
    setFocusProxy(m_completionList);

    connect(m_completionList, &QListWidget::itemClicked, this,
            [this](QListWidgetItem *item) { activateItem(item, false); });

    applyStyle();
}

void MySyntaxMenu::setCompletionFont(const QFont &font)
{
    m_completionList->setFont(font);
}

void MySyntaxMenu::showEvent(QShowEvent *event)
{
    QFrame::showEvent(event);
    if (m_completionList->count() > 0) {
        m_completionList->setCurrentRow(0);
        m_completionList->setFocus(Qt::PopupFocusReason);
    }
}

void MySyntaxMenu::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event);
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    // Draw inside the widget rectangle so the 1px border is not clipped.
    const QRectF frameRect = QRectF(rect()).adjusted(0.5, 0.5, -0.5, -0.5);
    if (m_borderColor.alpha() > 0)
        painter.setPen(QPen(m_borderColor, 1));
    else
        painter.setPen(Qt::NoPen);
    painter.setBrush(m_backgroundColor);
    painter.drawRoundedRect(frameRect, 8, 8);
}

QAction *MySyntaxMenu::addCompletion(const QString &text, const QVariant &data,
                                     const QString &toolTip, int priority,
                                     QObject *receiver, const char *slot)
{
    auto *action = new QAction(text, this);
    action->setData(data);
    if (!toolTip.isEmpty())
        action->setToolTip(toolTip);
    action->setProperty("autocompletePriority", priority);
    if (receiver && slot)
        connect(action, SIGNAL(triggered()), receiver, slot);
    m_completionActions.append(action);
    return action;
}

void MySyntaxMenu::clearCompletions()
{
    m_itemActions.clear();
    m_completionList->clear();
    qDeleteAll(m_completionActions);
    m_completionActions.clear();
    m_preferredListHeight = 0;
    m_minimumRowHeight = 1;
}

bool MySyntaxMenu::hasCompletions() const
{
    return !m_completionActions.isEmpty();
}

void MySyntaxMenu::refreshCompletions(int maxVisibleLines, int widthCharacters)
{
    m_itemActions.clear();
    m_completionList->clear();

    std::stable_sort(m_completionActions.begin(), m_completionActions.end(),
                     [](const QAction *a, const QAction *b) {
        return a->property("autocompletePriority").toInt()
                < b->property("autocompletePriority").toInt();
    });

    bool haveOpcode = false;
    bool separatorAdded = false;
    const int labelCharacters = qMax(14, widthCharacters);
    const QFontMetrics metrics(m_completionList->font());
    const int labelWidth = metrics.horizontalAdvance(
                QString(labelCharacters, QLatin1Char('M')));
    // The item delegate reserves a small horizontal margin on both sides. Add
    // it to the item width, not to the text: otherwise a 42-character row is
    // elided by a few pixels and its output type is replaced by "…".
    const int textMargin = m_completionList->style()->pixelMetric(
                QStyle::PM_FocusFrameHMargin, nullptr, m_completionList);
    const int listWidth = labelWidth + 2 * textMargin;
    const int rowHeight = metrics.height() + 2;
    for (QAction *action : m_completionActions) {
        const bool isOpcode = action->property("autocompletePriority").toInt() == 0;
        if (!isOpcode && haveOpcode && !separatorAdded) {
            auto *separator = new QListWidgetItem(m_completionList);
            separator->setFlags(Qt::NoItemFlags);
            separator->setData(CompletionSeparatorRole, true);
            separator->setSizeHint(QSize(0, 5));
            separatorAdded = true;
        }

        auto *item = new QListWidgetItem(m_completionList);
        // Opcode rows are already laid out to fit; eliding them again would
        // append a second ellipsis at the very end (after the type column).
        // Only non-opcode completions need the generic elision.
        const QString text = action->text();
        item->setText(isOpcode || metrics.horizontalAdvance(text) <= labelWidth
                      ? text
                      : metrics.elidedText(text, Qt::ElideRight, labelWidth));
        item->setToolTip(action->toolTip().isEmpty() ? action->text() : action->toolTip());
        item->setSizeHint(QSize(listWidth, rowHeight));
        m_itemActions.insert(item, action);
        haveOpcode |= isOpcode;
    }

    if (m_completionList->count() == 0) {
        m_completionList->setFixedSize(0, 0);
        return;
    }

    const int rowCount = qMin(qMax(1, maxVisibleLines), m_completionList->count());
    m_preferredListHeight = 0;
    for (int row = 0; row < rowCount; ++row) {
        const QListWidgetItem *item = m_completionList->item(row);
        int height = item->sizeHint().height();
        if (height <= 0)
            height = rowHeight;
        if (row == 0)
            m_minimumRowHeight = height;
        m_preferredListHeight += height;
    }

    m_completionList->setFixedSize(listWidth, m_preferredListHeight);
    // The popup width follows the configured number of characters.
    setFixedWidth(listWidth + 12);

    for (int row = 0; row < m_completionList->count(); ++row) {
        QListWidgetItem *item = m_completionList->item(row);
        if (!(item->flags() & Qt::ItemIsEnabled))
            continue;
        m_completionList->setCurrentItem(item);
        break;
    }
}

void MySyntaxMenu::setAvailableHeight(int height)
{
    const int listHeight = qMax(m_minimumRowHeight,
                                height - 12); // leave room for the menu frame/padding
    m_completionList->setFixedHeight(qMin(m_preferredListHeight, listHeight));
}

void MySyntaxMenu::activateCurrent(bool complete)
{
    activateItem(m_completionList->currentItem(), complete);
}

void MySyntaxMenu::activateItem(QListWidgetItem *item, bool complete)
{
    QAction *action = m_itemActions.value(item, nullptr);
    if (!action)
        return;

    insertComplete = complete;
    close();
    action->trigger();
}

bool MySyntaxMenu::eventFilter(QObject *watched, QEvent *event)
{
    if (watched == m_completionList && event->type() == QEvent::KeyPress) {
        auto *keyEvent = static_cast<QKeyEvent *>(event);
        switch (keyEvent->key()) {
        case Qt::Key_Escape:
            close();
            return true;
        case Qt::Key_Tab:
            activateCurrent(false);
            return true;
        case Qt::Key_Return:
        case Qt::Key_Enter:
            activateCurrent(true);
            return true;
        case Qt::Key_Up:
        case Qt::Key_Down:
        case Qt::Key_PageUp:
        case Qt::Key_PageDown:
        case Qt::Key_Home:
        case Qt::Key_End:
            insertComplete = false;
            return false; // QListWidget handles navigation and scrolling
        case Qt::Key_Shift:
        case Qt::Key_Control:
        case Qt::Key_Alt:
        case Qt::Key_Meta:
        case Qt::Key_AltGr:
            // A modifier alone must not dismiss the popup: the next letter
            // may be an upper-case character that continues the token.
            return false;
        default:
            if (keepsCompletionMenuOpen(keyEvent)) {
                // Continue typing without closing the popup. The editor gets
                // the key directly; the debounced update below filters the
                // list in place.
                QWidget *target = m_keyTarget ? m_keyTarget : parentWidget();
                if (target)
                    QApplication::sendEvent(target, keyEvent);
                emit completionKeyForwarded();
                event->accept();
                return true;
            }
            close();
            if (QWidget *target = m_keyTarget ? m_keyTarget : parentWidget())
                QApplication::sendEvent(target, keyEvent);
            event->accept();
            return true;
        }
    }
    return QFrame::eventFilter(watched, event);
}

// The popup is light in both themes -- it has always been, and against the dark
// editor it stands out well -- but it must not disappear into the light editor
// either, hence the border and the warm off-white in the light palette.
void MySyntaxMenu::applyStyle()
{
    // Same light/dark test CsoundQt uses for the "auto" theme mode.
    const QPalette pal = palette();
    const bool dark = pal.text().color().lightness() > pal.window().color().lightness();
    if (m_styleApplied && dark == m_darkStyle)
        return; // already styled for this palette
    m_styleApplied = true;
    m_darkStyle = dark;

    const QString background = dark ? u"#f8f8f8"_s
                                    : QStringLiteral(COMPLETION_MENU_BG_LIGHT);
    // The selected item is a solid blue bar, so its text only has to be light.
    const QString selectedText = dark ? u"#f8f8f8"_s : background;

    // The popup frame is painted by hand in paintEvent(), so its rounded
    // corners cannot be covered by the platform style's square background.
    m_backgroundColor = QColor(background);
    m_borderColor = dark ? QColor(Qt::transparent)
                         : QColor(COMPLETION_MENU_BORDER_LIGHT);

    m_completionList->setStyleSheet(
        "QListWidget {"
        "  background-color: " + background + ";"
        "  color: #5050A0;"
        "  border: none;"
        "  padding: 0px;"
        "}"
        "QListWidget::item {"
        "  padding: 0px;"
        "}"
        "QListWidget::item:selected {"
        "  color: " + selectedText + ";"
        "  background-color: #3daee9;"
        "}");

}

MySyntaxMenu::~MySyntaxMenu()
{

}

void MySyntaxMenu::keyPressEvent(QKeyEvent *event)
{
    // The list has focus and handles navigation. If it ignores a key (for
    // example Down on the last row), Qt propagates the event to this parent,
    // so do not send it back to the list: that would recurse until the stack
    // overflows. Just let the key be ignored.
    QFrame::keyPressEvent(event);
}

HoverWidget::HoverWidget(QWidget *parent) :
	QWidget(parent)
{

}

void HoverWidget::mousePressEvent(QMouseEvent *ev)
{
    (void) ev;
	this->hide();
}
