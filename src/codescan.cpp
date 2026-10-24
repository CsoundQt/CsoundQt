/*
	Copyright (C) 2026 CsoundQt contributors
	This file is part of CsoundQt.
	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.
*/

#include "codescan.h"

#include "highlighter.h" // CsoundLex

#include <QFileInfo>
#include <QRegularExpression>
#include <QSet>

using namespace Qt::StringLiterals;

namespace CodeScan {

namespace {

// How deep #include directives are followed. A file that includes itself,
// directly or through others, is caught by the chain of open files; the depth
// is the backstop for pathological trees.
constexpr int MAX_INCLUDE_DEPTH = 16;

bool isNameChar(QChar c)
{
    return c.isLetterOrNumber() || c == QLatin1Char('_');
}

bool isNameStart(QChar c)
{
    return c.isLetter() || c == QLatin1Char('_');
}

// The type characters of Csound variables, as in gkFoo or gSFoo.
bool isTypeChar(QChar c)
{
    switch (c.unicode()) {
    case 'a': case 'k': case 'i': case 'S': case 'p':
    case 'f': case 'x': case 'b': case 'w':
        return true;
    default:
        return false;
    }
}

// The line with a trailing comment (";" or "//") removed, trimmed. Used where
// only the code part of a line matters, for example for the name of an
// instrument or an opcode declaration.
QStringView withoutComment(QStringView line)
{
    qsizetype cut = -1;
    const qsizetype semicolon = line.indexOf(QLatin1Char(';'));
    if (semicolon >= 0)
        cut = semicolon;
    const qsizetype slashes = line.indexOf(u"//"_s);
    if (slashes >= 0 && (cut < 0 || slashes < cut))
        cut = slashes;
    if (cut >= 0)
        line = line.left(cut);
    return line.trimmed();
}

void sortCaseInsensitive(QStringList &names)
{
    names.sort(Qt::CaseInsensitive);
}

// True when the text starts with the keyword as a word of its own:
// "instr 1" but not "instrnum".
bool startsWithKeyword(QStringView text, QStringView keyword)
{
    if (!text.startsWith(keyword))
        return false;
    return text.size() == keyword.size() || !isNameChar(text.at(keyword.size()));
}

// True for "#name" with the name immediately after the '#'. Csound also
// accepts "# name", but that is not supported here: it is an unusual spelling
// and the scanner deliberately keeps the directive syntax strict.
bool isDirective(QStringView code, QStringView name)
{
    if (!code.startsWith(QLatin1Char('#')))
        return false;
    const QStringView rest = code.mid(1);
    if (!rest.startsWith(name))
        return false;
    return rest.size() == name.size() || !isNameChar(rest.at(name.size()));
}

// The name of a preprocessor directive, or an empty view for anything else.
// "# define" is deliberately not a directive.
QStringView directiveName(QStringView code)
{
    if (!code.startsWith(QLatin1Char('#')))
        return QStringView();
    qsizetype end = 1;
    while (end < code.size() && isNameChar(code.at(end)))
        ++end;
    return code.mid(1, end - 1);
}

bool isConditionalStart(QStringView code)
{
    const QStringView name = directiveName(code);
    return name == u"ifdef"_s || name == u"ifndef"_s;
}

bool isConditionalEnd(QStringView code)
{
    const QStringView name = directiveName(code);
    return name == u"end"_s || name == u"endif"_s;
}

// An include guard is "#ifndef NAME" immediately followed by "#define NAME".
// Its content is real code on the first inclusion (the guard is not defined
// yet), so it must not be skipped like an ordinary conditional block.
bool isIncludeGuardStart(const QVector<QStringView> &lines, int index,
                         QStringView statement)
{
    if (!statement.startsWith(u"#ifndef"_s))
        return false;
    const QStringView after = statement.mid(7).trimmed();
    qsizetype nameEnd = 0;
    while (nameEnd < after.size() && isNameChar(after.at(nameEnd)))
        ++nameEnd;
    if (nameEnd == 0)
        return false;
    const QStringView name = after.left(nameEnd);

    for (int j = index + 1; j < lines.size(); ++j) {
        const QStringView next = lines.at(j).trimmed();
        if (next.isEmpty() || next.startsWith(QLatin1Char(';'))
                || next.startsWith(u"//"_s))
            continue;
        if (!next.startsWith(QLatin1Char('#')))
            return false;
        const QStringView define = withoutComment(next);
        if (!isDirective(define, u"define"_s))
            return false;
        const QStringView rest = define.mid(7).trimmed();
        qsizetype end = 0;
        while (end < rest.size() && isNameChar(rest.at(end)))
            ++end;
        return end > 0 && rest.left(end) == name;
    }
    return false;
}

// The parameter names of a Csound 7 UDO signature, "x:a, c1:k" -> "x, c1".
// The types are declarations, not something a call template can use.
QString parameterNames(const QString &parameters)
{
    QStringList names;
    for (const QString &parameter : parameters.split(QLatin1Char(','))) {
        const QString trimmed = parameter.trimmed();
        if (trimmed.isEmpty())
            continue;
        const qsizetype colon = trimmed.indexOf(QLatin1Char(':'));
        names.append((colon > 0 ? trimmed.left(colon) : trimmed).trimmed());
    }
    return names.join(u", "_s);
}

// One program, however many files it is spread over: globals, instruments and
// the names of the opcodes are shared by the document and everything it
// includes.
struct Accumulator
{
    QSet<QString> globalVariables;
    QSet<QString> globalStringVariables;
    QSet<QString> explicitGlobals;
    QSet<QString> explicitLocals;
    QSet<QString> instrumentNames;
    QSet<QString> udoNames;
};

// The definition that starts this line, if any: the keyword, then a name.
// A name in a comment or in a string is not a definition. Hand-written rather
// than a regex because this is asked of every line of the document.
void addDefinition(QStringView line, QStringView code, const CsoundLex::Line &lex,
                   int lineIndex, const QString &filePath,
                   QHash<QString, Definition> &definitions)
{
    // Most lines cannot start a definition: a cheap first-character test
    // keeps the keyword comparisons out of the way.
    if (code.isEmpty())
        return;
    const QChar first = code.at(0);
    if (first != QLatin1Char('o') && first != QLatin1Char('i')
            && first != QLatin1Char('s') && first != QLatin1Char('#'))
        return;

    Kind kind;
    qsizetype pos = 0;
    if (code.startsWith(u"opcode"_s)) {
        kind = Kind::Udo;
        pos = 6;
    }
    else if (code.startsWith(u"instr"_s)) {
        kind = Kind::Instrument;
        pos = 5;
    }
    else if (code.startsWith(u"struct"_s)) {
        kind = Kind::Struct;
        pos = 6;
    }
    else if (code.startsWith(QLatin1Char('#'))) {
        kind = Kind::Macro;
        if (!isDirective(code, u"define"_s))
            return;
        pos = 7; // after "#define"
    }
    else {
        return;
    }
    // The keyword has to be a word of its own, followed by the name.
    if (pos >= code.size() || !code.at(pos).isSpace())
        return;
    while (pos < code.size() && code.at(pos).isSpace())
        ++pos;
    if (pos >= code.size() || !isNameStart(code.at(pos)))
        return;
    qsizetype end = pos + 1;
    while (end < code.size() && isNameChar(code.at(end)))
        ++end;

    // The column is what the editor needs to place the cursor.
    qsizetype indent = 0;
    while (indent < line.size() && line.at(indent).isSpace())
        ++indent;
    const int column = static_cast<int>(indent + pos);
    if (!CsoundLex::isCode(lex, column))
        return;

    Definition definition;
    definition.kind = kind;
    definition.name = code.mid(pos, end - pos).toString();
    definition.line = lineIndex + 1;
    definition.column = column;
    definition.file = filePath;
    definitions.insert(definition.name, definition);
}

// The file named by an #include directive.
struct IncludeSpec
{
    QString name;
    bool angled = false;
};

bool parseInclude(QStringView code, IncludeSpec *spec)
{
    // "#include "file"" or "#include <file>". Anything else, a macro for
    // example, cannot be resolved without running the preprocessor. The
    // directive name must follow the '#' directly; "# include" is rejected.
    if (!isDirective(code, u"include"_s))
        return false;
    qsizetype pos = 8; // after "#include"
    while (pos < code.size() && code.at(pos).isSpace())
        ++pos;
    if (pos >= code.size())
        return false;
    const QChar open = code.at(pos);
    QChar close;
    if (open == QLatin1Char('"'))
        close = QLatin1Char('"');
    else if (open == QLatin1Char('<'))
        close = QLatin1Char('>');
    else
        return false;
    const qsizetype end = code.indexOf(close, pos + 1);
    if (end < 0)
        return false;
    spec->name = code.mid(pos + 1, end - pos - 1).toString().trimmed();
    spec->angled = open == QLatin1Char('<');
    return !spec->name.isEmpty();
}

// The lines of the text, as views into it. The scanner looks at every line a
// few times, so it avoids a copy of each one.
QVector<QStringView> splitLines(QStringView text)
{
    QVector<QStringView> lines;
    qsizetype start = 0;
    for (;;) {
        const qsizetype newline = text.indexOf(QLatin1Char('\n'), start);
        if (newline < 0) {
            lines.append(text.mid(start));
            break;
        }
        lines.append(text.mid(start, newline - start));
        start = newline + 1;
    }
    return lines;
}

// Scans one document. Includes are expanded where they appear, with their own
// file path and in orchestra mode: a .udo or .inc file is the body of an
// orchestra section, without the .csd tags.
void scanDocument(Result &result, Accumulator &accumulator, const QString &text,
                  Mode mode, const QString &filePath, IncludeProvider *includes,
                  QSet<QString> &openFiles, int depth)
{
    const QVector<QStringView> lines = splitLines(text);
    const int lineCount = static_cast<int>(lines.size());

    // Definitions of the scanned document keep an empty file: consumers use
    // that to tell them apart from the definitions an #include pulled in. The
    // path itself is still needed below to resolve relative includes.
    const QString definitionFile = depth == 0 ? QString() : filePath;

    static const QRegularExpression orcStartRx(uR"(^\s*<CsInstruments>)"_s);
    static const QRegularExpression scoreRx(uR"(^\s*<CsScore>)"_s);

    // The orchestra is the only part of the text that is scanned. In a .csd
    // it is delimited by tags; an orchestra-only document is all orchestra.
    int first = 0;
    int last = lineCount;

    if (mode == Mode::Csd) {
        int tagLine = -1;
        for (int i = 0; i < lineCount; ++i) {
            if (lines.at(i).contains(QLatin1Char('<'))
                    && orcStartRx.matchView(lines.at(i)).hasMatch()) {
                tagLine = i;
                break;
            }
        }
        if (tagLine < 0) {
            // No orchestra section: the document may still have a score.
            for (int i = 0; i < lineCount; ++i) {
                if (lines.at(i).contains(QLatin1Char('<'))
                        && scoreRx.matchView(lines.at(i)).hasMatch()) {
                    result.scoreLine = i + 1;
                    break;
                }
            }
            return;
        }
        first = tagLine + 1;
        if (depth == 0)
            result.orchestraLine = first + 1;
        // The section ends at the first tag line after it.
        for (int i = first; i < lineCount; ++i) {
            if (lines.at(i).trimmed().startsWith(QLatin1Char('<'))) {
                last = i;
                break;
            }
        }
        for (int i = last; i < lineCount; ++i) {
            if (lines.at(i).contains(QLatin1Char('<'))
                    && scoreRx.matchView(lines.at(i)).hasMatch()) {
                result.scoreLine = i + 1;
                break;
            }
        }
    }
    else if (depth == 0) {
        result.orchestraLine = 1;
    }

    // The structure shown in the inspector tree.
    static const QRegularExpression opcodeRx(uR"(\bopcode\s+(\w+)\s*(?:,|\())"_s);
    static const QRegularExpression udoSignatureRx(
                uR"RX(^\s*opcode\s+[A-Za-z_]\w*\s*\(([^)]*)\)\s*(?::\s*(?:\(([^)]*)\)|([A-Za-z_]\w*(?:\[\])?)))?)RX"_s);
    static const QRegularExpression instrNameRx(uR"(^([^\s(,;]+))"_s);
    static const QRegularExpression ftableRx(uR"(^\w*\s*ftgen\b)"_s);
    static const QRegularExpression xinRx(uR"(\bxin\b)"_s);
    static const QRegularExpression xoutRx(uR"(\bxout\s+)"_s);

    // Csound 7 annotates globals and locals with a type: name@global:<type>
    // is global, name:<type> is local. An explicit type suffix takes
    // precedence over the g prefix: gkfoo:a is local, not global.
    static const QRegularExpression annotatedGlobalRx(
                u"\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                "@global\\s*:\\s*([akiSpfxbw])\\b(?:\\s*\\[\\])?"_s);
    static const QRegularExpression annotatedLocalRx(
                u"(?<!@)\\b([A-Za-z_][A-Za-z0-9_]*)\\s*"
                ":\\s*[akiSpfxbw]\\b(?:\\s*\\[\\])?"_s);

    int lexState = 0;
    CsoundLex::Line lex;
    bool inInstrument = false;
    int opcodeIndex = -1; // index into result.udos while inside an opcode
    int conditionalDepth = 0; // inside a skipped #ifdef/#ifndef block
    int guardDepth = 0;       // inside an include guard (#ifndef/#define)

    for (int i = first; i < last; ++i) {
        const QStringView line = lines.at(i);
        CsoundLex::scanInto(line, lexState, lex);
        lexState = lex.endState;

        const QStringView code = line.trimmed();
        if (code.isEmpty())
            continue;

        // A line inside a /* ... */ comment or a {{ ... }} string is not
        // code, even when it looks like a declaration. Without this, an
        // "instr" in a block comment becomes an instrument.
        qsizetype firstCode = 0;
        while (firstCode < line.size() && line.at(firstCode).isSpace())
            ++firstCode;
        if (!CsoundLex::isCode(lex, static_cast<int>(firstCode)))
            continue;

        const QStringView statement = withoutComment(code);

        // Conditional compilation is not evaluated. Everything between
        // #ifdef/#ifndef and the matching #end/#endif is skipped, including
        // the #else branch. Nested conditionals are counted. An include guard
        // is the exception: its body is the file's actual code.
        if (conditionalDepth > 0) {
            if (isConditionalStart(statement))
                ++conditionalDepth;
            else if (isConditionalEnd(statement))
                --conditionalDepth;
            continue;
        }
        if (isConditionalStart(statement)) {
            if (isIncludeGuardStart(lines, i, statement))
                ++guardDepth;
            else
                conditionalDepth = 1;
            continue;
        }
        if (isConditionalEnd(statement)) {
            if (guardDepth > 0)
                --guardDepth;
            continue;
        }

        // Inside an opcode only the classic xin/xout declarations are
        // scanned. A Csound 7 signature was already read on the declaration
        // line, and nothing else in the body is of interest.
        if (opcodeIndex >= 0) {
            Definition &opcode = result.udos[opcodeIndex];
            QRegularExpressionMatch match;
            if (statement == u"endop"_s) {
                opcodeIndex = -1;
            }
            else if (!opcode.newStyle) {
                if (opcode.inArgs.isEmpty()
                        && (match = xinRx.matchView(statement)).hasMatch()) {
                    opcode.inArgs = statement.left(match.capturedStart())
                            .toString().simplified();
                    opcode.inArgsLine = i + 1;
                }
                else if (opcode.outArgs.isEmpty()
                         && (match = xoutRx.matchView(statement)).hasMatch()) {
                    opcode.outArgs = statement.mid(match.capturedEnd())
                            .toString().simplified();
                    opcode.outArgsLine = i + 1;
                }
            }
            continue;
        }

        // Inside an instrument there is nothing to scan: only endin matters,
        // so that the header is recognised again after it.
        if (inInstrument) {
            if (statement == u"endin"_s)
                inInstrument = false;
            continue;
        }

        // From here on the line is in the header (the global / "instr 0"
        // level), the only place where globals, instruments and opcodes are
        // defined.
        //
        // Global variables are found by hand rather than with a regex: this
        // runs on every header line of every scan.
        if (line.contains(QLatin1Char('g'))) {
            const int length = static_cast<int>(line.size());
            for (int k = 0; k + 1 < length; ++k) {
                if (line.at(k) != QLatin1Char('g'))
                    continue;
                // A name starts at a word boundary: it must not continue an
                // identifier.
                if (k > 0 && isNameChar(line.at(k - 1)))
                    continue;
                if (!isTypeChar(line.at(k + 1)))
                    continue;
                int end = k + 2;
                while (end < length && isNameChar(line.at(end)))
                    ++end;
                if (!CsoundLex::isCode(lex, k))
                    continue;
                const QString name = line.mid(k, end - k).toString();
                accumulator.globalVariables.insert(name);
                if (name.size() > 1 && name.at(1) == QLatin1Char('S'))
                    accumulator.globalStringVariables.insert(name);
                k = end - 1;
            }
        }
        if (line.contains(QLatin1Char('@'))) {
            for (auto it = annotatedGlobalRx.globalMatchView(line); it.hasNext(); ) {
                const QRegularExpressionMatch match = it.next();
                if (!CsoundLex::isCode(lex, static_cast<int>(match.capturedStart(1))))
                    continue;
                const QString name = match.captured(1);
                accumulator.globalVariables.insert(name);
                accumulator.explicitGlobals.insert(name);
                if (match.captured(2) == u"S"_s)
                    accumulator.globalStringVariables.insert(name);
            }
        }
        if (line.contains(QLatin1Char(':'))) {
            for (auto it = annotatedLocalRx.globalMatchView(line); it.hasNext(); ) {
                const QRegularExpressionMatch match = it.next();
                if (CsoundLex::isCode(lex, static_cast<int>(match.capturedStart(1))))
                    accumulator.explicitLocals.insert(match.captured(1));
            }
        }

        // Definitions for "Go to Source".
        addDefinition(line, statement, lex, i, definitionFile, result.definitions);

        QRegularExpressionMatch match;

        // The structure of the orchestra, for the inspector tree. This is only
        // reached in the header: inside a block there are no declarations.
        if (startsWithKeyword(statement, u"instr"_s)) {
            const QStringView instrText = statement.mid(5).trimmed();
            QStringView instrName = instrText;
            if (instrName.startsWith(QLatin1Char('"'))) {
                const qsizetype close = instrName.indexOf(QLatin1Char('"'), 1);
                instrName = close > 0 ? instrName.mid(1, close - 1) : instrName.mid(1);
            }
            else if (const QRegularExpressionMatch nameMatch =
                     instrNameRx.matchView(instrName); nameMatch.hasMatch()) {
                instrName = nameMatch.capturedView(1);
            }
            else {
                instrName = QStringView();
            }
            Definition definition;
            definition.kind = Kind::Instrument;
            definition.line = i + 1;
            definition.text = instrText.toString();
            definition.file = definitionFile;
            if (!instrName.isEmpty() && !instrName.at(0).isDigit())
                definition.name = instrName.toString();
            result.instruments.append(definition);
            if (!definition.name.isEmpty())
                accumulator.instrumentNames.insert(definition.name);
            inInstrument = true;
        }
        else if (startsWithKeyword(statement, u"opcode"_s)
                 && (match = opcodeRx.matchView(statement)).hasMatch()) {
            Definition definition;
            definition.kind = Kind::Udo;
            definition.name = match.captured(1);
            definition.line = i + 1;
            definition.text = statement.mid(7).toString();
            definition.file = definitionFile;
            if (const QRegularExpressionMatch signature =
                    udoSignatureRx.matchView(statement); signature.hasMatch()) {
                definition.newStyle = true;
                definition.inArgs = parameterNames(signature.captured(1));
                QString outputs;
                if (signature.capturedStart(2) >= 0)
                    outputs = signature.captured(2).trimmed();
                else if (signature.capturedStart(3) >= 0)
                    outputs = signature.captured(3).trimmed();
                if (outputs == u"void"_s)
                    outputs.clear();
                definition.outArgs = outputs;
            }
            result.udos.append(definition);
            opcodeIndex = result.udos.size() - 1;
            accumulator.udoNames.insert(definition.name);
        }
        else if (isDirective(statement, u"define"_s)) {
            Definition definition;
            definition.kind = Kind::Macro;
            definition.line = i + 1;
            definition.file = definitionFile;
            definition.text = statement.mid(8).toString();
            result.preprocessor.append(definition);
        }
        else if (isDirective(statement, u"include"_s)) {
            Definition definition;
            definition.kind = Kind::Include;
            definition.line = i + 1;
            definition.file = definitionFile;
            definition.text = statement.toString();
            result.preprocessor.append(definition);
        }
        else if (ftableRx.matchView(statement).hasMatch()) {
            Definition definition;
            definition.kind = Kind::FTable;
            definition.line = i + 1;
            definition.text = statement.toString();
            definition.file = definitionFile;
            result.ftables.append(definition);
        }

        // An include pulls the file in at this point, so that "last definition
        // wins" works across the file boundary, as it does for Csound.
        if (includes != nullptr && depth < MAX_INCLUDE_DEPTH
                && isDirective(statement, u"include"_s)) {
            IncludeSpec spec;
            if (CsoundLex::isCode(lex, static_cast<int>(firstCode))
                    && parseInclude(statement, &spec)) {
                const IncludeFile file = includes->include(spec.name, filePath,
                                                           spec.angled);
                if (!file.path.isEmpty() && !openFiles.contains(file.path)) {
                    openFiles.insert(file.path);
                    bool known = false;
                    for (const Dependency &dependency : result.dependencies) {
                        if (dependency.path == file.path) {
                            known = true;
                            break;
                        }
                    }
                    if (!known)
                        result.dependencies.append(
                                    {file.path, file.lastModified, file.size});
                    scanDocument(result, accumulator, file.text, Mode::Orc,
                                 file.path, includes, openFiles, depth + 1);
                    openFiles.remove(file.path);
                }
            }
        }

    }
}

} // namespace


const Definition *Result::find(const QString &name) const
{
    const auto it = definitions.constFind(name);
    if (it == definitions.constEnd())
        return nullptr;
    return &it.value();
}

ResultPtr empty()
{
    using MutablePtr = QSharedPointer<Result>;
    static const ResultPtr result = MutablePtr(new Result);
    return result;
}

ResultPtr scanPtr(const QString &text, Mode mode, IncludeProvider *includes,
                  const QString &filePath)
{
    using MutablePtr = QSharedPointer<Result>;
    return MutablePtr(new Result(scan(text, mode, includes, filePath)));
}


Result scan(const QString &text, Mode mode, IncludeProvider *includes,
            const QString &filePath)
{
    Result result;
    if (mode == Mode::None)
        return result;

    Accumulator accumulator;

    // The file of the scanned text is open from the start, so a chain of
    // includes that leads back to it stops there.
    QSet<QString> openFiles;
    if (!filePath.isEmpty()) {
        const QString canonical = QFileInfo(filePath).canonicalFilePath();
        openFiles.insert(canonical.isEmpty() ? filePath : canonical);
    }

    scanDocument(result, accumulator, text, mode, filePath, includes, openFiles, 0);

    for (const QString &name : accumulator.globalVariables) {
        // An explicit local type wins over the g prefix: gkfoo:a is local.
        if (accumulator.explicitLocals.contains(name)
                && !accumulator.explicitGlobals.contains(name))
            continue;
        // A UDO can have a g-prefixed name too; it is not a variable.
        if (accumulator.udoNames.contains(name))
            continue;
        result.globalVariables.append(name);
    }
    for (const QString &name : accumulator.globalStringVariables) {
        if (accumulator.explicitLocals.contains(name)
                && !accumulator.explicitGlobals.contains(name))
            continue;
        if (accumulator.udoNames.contains(name))
            continue;
        result.globalStringVariables.append(name);
    }
    result.instrumentNames = accumulator.instrumentNames.values();
    sortCaseInsensitive(result.globalVariables);
    sortCaseInsensitive(result.globalStringVariables);
    sortCaseInsensitive(result.instrumentNames);

    return result;
}

} // namespace CodeScan
