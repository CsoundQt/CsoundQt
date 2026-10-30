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

bool startsWithKeyword(QStringView text, QStringView keyword);

// Types that Csound 7 recognises without a struct declaration. User-defined
// structs are added by the scanner as it meets them.
bool isBuiltinVariableType(const QString &type)
{
    static const QSet<QString> builtins = {
        u"i"_s, u"k"_s, u"a"_s, u"S"_s, u"p"_s, u"f"_s,
        u"b"_s, u"B"_s, u"Complex"_s, u"InstrDef"_s, u"Instr"_s,
        u"OpcodeDef"_s, u"Opcode"_s
    };
    return builtins.contains(type);
}

bool isKnownVariableType(const QString &type, const QSet<QString> &userTypes)
{
    return isBuiltinVariableType(type) || userTypes.contains(type);
}

// A typed declaration in the body: "var:k", "array:k[]", "myop:OpcodeDef".
// A label at the beginning of a line ("loop: ...") is not a declaration.
const QRegularExpression typedVariableRx(
            uR"((?<![@\w])([A-Za-z_]\w*)\s*:\s*([A-Za-z_]\w*(?:\[\])?))"_s);
const QRegularExpression assignmentRx(
            uR"((?<![=!<>+\-*/])=(?!=))"_s);

void addLocalVariable(Definition &definition, const QString &name,
                      const QString &type, bool array, int line, int column,
                      const QString &file)
{
    if (name.isEmpty() || type.isEmpty()
            || definition.localVariables.contains(name)) {
        return; // keep the first introduction
    }
    Definition::Variable variable;
    variable.name = name;
    variable.type = type;
    variable.array = array;
    variable.line = line;
    variable.column = column;
    variable.file = file;
    definition.localVariables.insert(name, variable);
}

void collectTypedVariables(QStringView statement, int indent,
                           const CsoundLex::Line &lex, int lineIndex,
                           const QString &file, Definition &definition,
                           const QSet<QString> &userTypes)
{
    for (auto it = typedVariableRx.globalMatchView(statement); it.hasNext(); ) {
        const QRegularExpressionMatch match = it.next();
        const int nameStart = static_cast<int>(match.capturedStart(1));
        if (!CsoundLex::isCode(lex, indent + nameStart))
            continue;
        QString type = match.captured(2);
        bool array = type.endsWith(u"[]"_s);
        if (array)
            type.chop(2);
        if (!isKnownVariableType(type, userTypes))
            continue;
        // "label: statement" is a label, not a typed variable. Typed
        // declarations are written without a space after the colon.
        const int colon = static_cast<int>(statement.indexOf(
                    QLatin1Char(':'), match.capturedEnd(1)));
        if (nameStart == 0 && colon >= 0 && colon + 1 < statement.size()
                && statement.at(colon + 1).isSpace()) {
            continue;
        }
        addLocalVariable(definition, match.captured(1), type, array,
                         lineIndex + 1, indent + nameStart, file);
    }
}

// A legacy typed name: the type follows the first character, or the g of a
// global name. Globals are not tracked per block.
bool addLegacyVariable(QStringView token, int column, int lineIndex,
                       const QString &file, Definition &definition)
{
    QString name = token.toString().trimmed();
    if (name.isEmpty() || name.contains(QLatin1Char(':')))
        return false;
    bool array = name.endsWith(u"[]"_s);
    if (array)
        name.chop(2);
    if (name.isEmpty() || !isNameStart(name.at(0)))
        return false;
    for (const QChar c : name) {
        if (!isNameChar(c))
            return false;
    }
    int typeIndex = 0;
    if (name.size() > 1 && name.at(0) == QLatin1Char('g')
            && isTypeChar(name.at(1))) {
        typeIndex = 1;
    }
    else if (name.size() > 1 && name.at(0) == QLatin1Char('g')) {
        // An untyped g-prefixed name is not a variable, but might be a UDO.
        return false;
    }
    if (!isTypeChar(name.at(typeIndex)))
        return false;
    // A legacy g-prefixed variable is global, even inside a block.
    if (typeIndex == 1)
        return false;
    addLocalVariable(definition, name, QString(name.at(0)), array,
                     lineIndex + 1, column, file);
    return true;
}

void addLegacyTokensSequentially(const QStringList &tokens, QStringView statement,
                                 int indent, int lineIndex, const QString &file,
                                 Definition &definition, bool stopAtFirstToken)
{
    int searchFrom = 0;
    const QString text = statement.toString();
    for (const QString &token : tokens) {
        const int position = text.indexOf(token, searchFrom);
        if (position < 0)
            break;
        searchFrom = position + token.size();
        if (!addLegacyVariable(token, indent + position, lineIndex, file,
                               definition)) {
            if (stopAtFirstToken)
                break;
        }
    }
}

void collectClassicOutputs(QStringView statement, int indent, int lineIndex,
                           const QString &file, Definition &definition)
{
    const QString text = statement.toString();
    int position = 0;
    while (position < text.size()) {
        while (position < text.size() && text.at(position).isSpace())
            ++position;
        if (position >= text.size())
            break;
        const int start = position;
        while (position < text.size() && !text.at(position).isSpace()
               && text.at(position) != QLatin1Char(',')) {
            ++position;
        }
        const QString token = text.mid(start, position - start);
        if (!addLegacyVariable(token, indent + start, lineIndex, file,
                               definition)) {
            break;
        }
        while (position < text.size() && text.at(position).isSpace())
            ++position;
        // Further output variables have to be separated by a comma. Once only
        // whitespace follows, the next word is the opcode, not another output.
        if (position < text.size() && text.at(position) == QLatin1Char(','))
            ++position;
        else
            break;
    }
}

void collectLegacyVariables(QStringView statement, int indent, int lineIndex,
                            const QString &file, Definition &definition)
{
    const QString code = statement.toString();
    const QRegularExpressionMatch assignment = assignmentRx.match(code);
    if (assignment.hasMatch()) {
        const QString lhs = code.left(assignment.capturedStart());
        const QStringList targets = lhs.split(QLatin1Char(','));
        for (QString target : targets) {
            target = target.trimmed();
            const QStringList words = target.split(
                        QRegularExpression(uR"(\s+)"_s), Qt::SkipEmptyParts);
            if (words.isEmpty())
                continue;
            const QString token = words.last();
            // The column of the target is not at the start of the whole left
            // side; find its position so the recorded location points at it.
            const int position = code.lastIndexOf(token, assignment.capturedStart());
            addLegacyVariable(token, indent + qMax(0, position), lineIndex,
                              file, definition);
        }
        return;
    }

    if (startsWithKeyword(statement, u"xin"_s)
            || startsWithKeyword(statement, u"xout"_s)) {
        const QStringList tokens = code.split(
                    QRegularExpression(uR"([,\s]+)"_s), Qt::SkipEmptyParts);
        if (tokens.size() > 1) {
            // Skip the xin/xout keyword itself.
            const QString rest = code.mid(code.indexOf(tokens.at(0))
                                          + tokens.at(0).size());
            addLegacyTokensSequentially(tokens.mid(1), rest, indent,
                                        lineIndex, file, definition, false);
        }
        return;
    }

    // Classic opcode syntax: the output names come before the opcode name.
    collectClassicOutputs(statement, indent, lineIndex, file, definition);
}

void collectLocalVariables(QStringView statement, int indent,
                           const CsoundLex::Line &lex, int lineIndex,
                           const QString &file, Definition &definition,
                           const QSet<QString> &userTypes)
{
    collectTypedVariables(statement, indent, lex, lineIndex, file, definition,
                          userTypes);
    collectLegacyVariables(statement, indent, lineIndex, file, definition);
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

// The documentation comment of a UDO: a /* ... */ block that starts on the
// first non-empty line after the opcode declaration. The delimiters are
// removed and the indentation shared by the lines is stripped, so the
// docstring reads as written without the indentation of the block. Returns an
// empty string when the declaration is not followed by a block comment.
QString readDocstring(const QVector<QStringView> &lines, int declarationLine)
{
    int openLine = declarationLine + 1;
    while (openLine < lines.size() && lines.at(openLine).trimmed().isEmpty())
        ++openLine;
    if (openLine >= lines.size())
        return QString();

    const QStringView opening = lines.at(openLine);
    const qsizetype open = opening.indexOf(u"/*"_s);
    // The comment must start the line: code before it is not a docstring.
    if (open < 0 || !opening.left(open).trimmed().isEmpty())
        return QString();

    QStringList body;
    const qsizetype closeOnOpening = opening.indexOf(u"*/"_s, open + 2);
    if (closeOnOpening >= 0) {
        body.append(opening.mid(open + 2, closeOnOpening - open - 2).toString());
    }
    else {
        body.append(opening.mid(open + 2).toString());
        qsizetype close = -1;
        for (int i = openLine + 1; i < lines.size(); ++i) {
            const QStringView line = lines.at(i);
            close = line.indexOf(u"*/"_s);
            if (close >= 0) {
                body.append(line.left(close).toString());
                break;
            }
            body.append(line.toString());
        }
        // An unterminated comment is not a docstring: Csound will reject the
        // text anyway.
        if (close < 0)
            return QString();
    }

    // The delimiters usually sit on lines of their own; the empty lines around
    // the text are not part of the docstring.
    while (!body.isEmpty() && body.first().trimmed().isEmpty())
        body.removeFirst();
    while (!body.isEmpty() && body.last().trimmed().isEmpty())
        body.removeLast();
    if (body.isEmpty())
        return QString();

    // Strip the indentation shared by all non-empty lines. Relative
    // indentation (nested lists, code examples) is kept.
    QString indent;
    bool haveIndent = false;
    for (const QString &line : body) {
        if (line.trimmed().isEmpty())
            continue;
        qsizetype spaces = 0;
        while (spaces < line.size() && line.at(spaces).isSpace())
            ++spaces;
        const QString prefix = line.left(spaces);
        if (!haveIndent) {
            indent = prefix;
            haveIndent = true;
            continue;
        }
        qsizetype common = 0;
        while (common < indent.size() && common < prefix.size()
               && indent.at(common) == prefix.at(common))
            ++common;
        indent.truncate(common);
    }
    for (QString &line : body) {
        if (line.trimmed().isEmpty()) {
            line.clear();
            continue;
        }
        if (line.startsWith(indent))
            line.remove(0, indent.size());
        while (line.endsWith(QLatin1Char(' ')) || line.endsWith(QLatin1Char('\t')))
            line.chop(1);
    }
    return body.join(QLatin1Char('\n'));
}

// One variable of a p-field assignment, with the field it takes: "ifoo" and
// 4 -> "ifoo:i(p4)". The type is a Csound 7 annotation ("foo:i") or, in the
// classic form, the letter in the name ("ifoo", "gkbar", where the type follows
// the g of a global). Returns an empty string when the variable has no type.
QString variableField(const QString &variable, int pField)
{
    static const QRegularExpression variableRx(
                uR"(^\s*([A-Za-z_]\w*)(?:\s*:\s*([akiSpfxbw]))?\s*$)"_s);
    const QRegularExpressionMatch match = variableRx.match(variable);
    if (!match.hasMatch())
        return QString();

    const QString name = match.captured(1);
    QString type = match.captured(2);
    if (type.isEmpty()) {
        const qsizetype prefix =
                name.startsWith(QLatin1Char('g')) && name.size() > 1 ? 1 : 0;
        if (prefix >= name.size() || !isTypeChar(name.at(prefix)))
            return QString();
        type = QString(name.at(prefix));
    }
    return name + QLatin1Char(':') + type + u"(p"_s
            + QString::number(pField) + QLatin1Char(')');
}

// The p-fields of a direct assignment inside an instrument, as shown in its
// help page:
//   "ifoo = p4"                   -> {"ifoo:i(p4)"}
//   "ichan, icc = p4, p5"         -> {"ichan:i(p4)", "icc:i(p5)"}
//   "ichan, icc passign 4"        -> {"ichan:i(p4)", "icc:i(p5)"}
//   "ichan, icc = passign(4)"     -> {"ichan:i(p4)", "icc:i(p5)"}
// Only assignments whose right-hand side is p-fields count: "kfreq = p5 * 2"
// depends on more than the field, so the help page cannot spell it as a
// parameter. An empty list means the line is not a p-field assignment.
QStringList pAssignmentFields(QStringView statement)
{
    // passign takes its variables from consecutive p-fields. The classic
    // "vars passign [istart][, iend]" and the modern
    // "vars = passign([istart][, iend])" spell the same thing. Without istart
    // the assignment starts at p1, the instrument number, as in Csound. iend
    // only limits how many p-fields may be taken; it does not renumber them.
    static const QRegularExpression passignClassicRx(
                uR"(^(.+?)\s+passign\s*(?:(\d+)(?:\s*,\s*\d+)?)?\s*$)"_s);
    static const QRegularExpression passignFunctionRx(
                uR"(^(.+?)\s*=\s*passign\s*\(\s*(?:(\d+)(?:\s*,\s*\d+)?)?\s*\)$)"_s);
    static const QRegularExpression assignmentRx(
                uR"(^(.+?)\s*=\s*(.+?)\s*$)"_s);
    static const QRegularExpression pFieldRx(uR"(^p(\d+)$)"_s);

    QRegularExpressionMatch match;
    if ((match = passignClassicRx.matchView(statement)).hasMatch()
            || (match = passignFunctionRx.matchView(statement)).hasMatch()) {
        int pField = match.captured(2).isEmpty() ? 1 : match.captured(2).toInt();
        if (pField < 1)
            return QStringList();
        QStringList fields;
        for (const QString &variable : match.captured(1).split(QLatin1Char(','))) {
            const QString field = variableField(variable, pField++);
            if (field.isEmpty())
                return QStringList();
            fields.append(field);
        }
        return fields;
    }

    if (!(match = assignmentRx.matchView(statement)).hasMatch())
        return QStringList();
    const QStringList variables = match.captured(1).split(QLatin1Char(','));
    const QStringList values = match.captured(2).split(QLatin1Char(','));
    // Each variable takes the p-field at the same position; a line that does
    // not pair them one to one is not a plain parameter list.
    if (variables.size() != values.size())
        return QStringList();
    QStringList fields;
    for (qsizetype i = 0; i < variables.size(); ++i) {
        const QRegularExpressionMatch pField =
                pFieldRx.match(values.at(i).trimmed());
        if (!pField.hasMatch())
            return QStringList();
        const QString field = variableField(variables.at(i),
                                            pField.captured(1).toInt());
        if (field.isEmpty())
            return QStringList();
        fields.append(field);
    }
    return fields;
}

// The variable of a p-field entry: "ifoo:i(p4)" -> "ifoo". An instrument body
// can assign a variable more than once; its parameter is the first assignment.
QString fieldVariable(const QString &field)
{
    const qsizetype colon = field.indexOf(QLatin1Char(':'));
    return colon < 0 ? field : field.left(colon);
}

// The names of "asig, kout" -> {"asig", "kout"}.
QStringList nameList(const QString &names)
{
    QStringList result;
    for (const QString &name : names.split(QLatin1Char(','))) {
        const QString trimmed = name.trimmed();
        if (!trimmed.isEmpty())
            result.append(trimmed);
    }
    return result;
}

// The type characters of a declared parameter: the regular variable types
// plus the optional argument types, which stand for a type and a default.
bool isParameterTypeChar(QChar c)
{
    switch (c.unicode()) {
    case 'o': case 'O': case 'j': case 'J': case 'P':
        return true;
    default:
        return isTypeChar(c);
    }
}

// The type names of a declaration. Csound 7 writes them separately, "(k, a)",
// the classic form as a string of type characters, "ka"; both list k and a.
// A lone "0" is how a classic declaration says "no arguments".
QStringList typeList(const QString &types)
{
    QString text = types.trimmed();
    if (text == u"0"_s)
        return QStringList();
    if (text.startsWith(QLatin1Char('(')) && text.endsWith(QLatin1Char(')')))
        text = text.mid(1, text.size() - 2);

    QStringList result;
    for (const QString &part : text.split(QLatin1Char(','))) {
        const QString type = part.trimmed();
        if (type.isEmpty())
            continue;
        bool characters = type.size() > 1;
        for (const QChar c : type) {
            if (!isParameterTypeChar(c))
                characters = false;
        }
        if (characters) {
            for (const QChar c : type)
                result.append(QString(c));
        }
        else {
            result.append(type);
        }
    }
    return result;
}

// The type shown in an input parameter list. The optional type characters
// carry their default value:
//   o -> i=0   O -> k=0   j -> i=-1   J -> k=-1   p -> i=1   P -> k=1
QString parameterType(QString type)
{
    if (type.isEmpty())
        return type;
    QChar replacement;
    int defaultValue = 0;
    switch (type.at(0).unicode()) {
    case 'o': replacement = QLatin1Char('i'); defaultValue = 0; break;
    case 'O': replacement = QLatin1Char('k'); defaultValue = 0; break;
    case 'j': replacement = QLatin1Char('i'); defaultValue = -1; break;
    case 'J': replacement = QLatin1Char('k'); defaultValue = -1; break;
    case 'p': replacement = QLatin1Char('i'); defaultValue = 1; break;
    case 'P': replacement = QLatin1Char('k'); defaultValue = 1; break;
    default:
        return type;
    }
    return QString(replacement) + type.mid(1)
            + QLatin1Char('=') + QString::number(defaultValue);
}

// A Csound 7 parameter list with the optional types made explicit:
// "bar:i, baz:o" -> "bar:i, baz:i=0".
QString parameterList(const QString &parameters)
{
    QStringList result;
    for (const QString &parameter : parameters.split(QLatin1Char(','))) {
        const QString trimmed = parameter.trimmed();
        if (trimmed.isEmpty())
            continue;
        const qsizetype colon = trimmed.indexOf(QLatin1Char(':'));
        if (colon < 0) {
            result.append(trimmed);
            continue;
        }
        result.append(trimmed.left(colon).trimmed() + QLatin1Char(':')
                      + parameterType(trimmed.mid(colon + 1).trimmed()));
    }
    return result.join(u", "_s);
}

// True when xout names plain variables, as opposed to an expression such as
// "kfoo + kbar", which has no name to show in the signature.
bool isVariableList(const QString &names)
{
    static const QRegularExpression identifier(uR"(^[A-Za-z_]\w*$)"_s);
    const QStringList list = nameList(names);
    if (list.isEmpty())
        return false;
    for (const QString &name : list) {
        if (!identifier.match(name).hasMatch())
            return false;
    }
    return true;
}

// "kin, kfreq" with "k, i" -> "kin:k, kfreq:i". A name without a type and a
// type without a name are kept alone, so a declaration with only output types
// still reads sensibly.
QString variablesWithTypes(const QStringList &variables, const QStringList &types)
{
    QStringList pairs;
    for (qsizetype i = 0; i < qMax(variables.size(), types.size()); ++i) {
        const QString variable = i < variables.size() ? variables.at(i) : QString();
        const QString type = i < types.size() ? types.at(i) : QString();
        if (!variable.isEmpty() && !type.isEmpty())
            pairs.append(variable + QLatin1Char(':') + type);
        else if (!variable.isEmpty())
            pairs.append(variable);
        else
            pairs.append(type);
    }
    return pairs.join(u", "_s);
}

// The call signature of a UDO, as a call would spell it: the parameter list
// from the declaration, and the output variables from xout with the declared
// output types: "myop(foo:k, bar:i) -> asig:a".
QString buildCallSignature(const Definition &udo)
{
    QString signature = udo.name;
    if (udo.newStyle) {
        signature += QLatin1Char('(') + parameterList(udo.signatureParams)
                + QLatin1Char(')');
    }
    else {
        QStringList inputTypes;
        for (const QString &type : typeList(udo.inTypes))
            inputTypes.append(parameterType(type));
        signature += QLatin1Char('(')
                + variablesWithTypes(nameList(udo.inArgs), inputTypes)
                + QLatin1Char(')');
    }

    // An xout expression has no variable name to show, only its type.
    const QStringList outVariables = isVariableList(udo.outVars)
            ? nameList(udo.outVars) : QStringList();
    const QString outputs = variablesWithTypes(outVariables,
                                               typeList(udo.outTypes));
    if (!outputs.isEmpty())
        signature += u" -> "_s + outputs;
    return signature;
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
    QSet<QString> userTypeNames;
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
    static const QRegularExpression structDeclRx(
                uR"(^struct\s+([A-Za-z_]\w*)\b)"_s);
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
    int instrumentIndex = -1; // index into result.instruments while inside one
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
            if (statement == u"endop"_s) {
                opcode.endLine = i + 1;
                opcodeIndex = -1;
                continue;
            }
            QRegularExpressionMatch match;
            if (!opcode.newStyle) {
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
                    opcode.outVars = opcode.outArgs;
                }
            }
            else if (opcode.outVars.isEmpty()
                     && (match = xoutRx.matchView(statement)).hasMatch()) {
                // The outputs are named on xout even with a Csound 7
                // signature; the call signature needs those names.
                opcode.outVars = statement.mid(match.capturedEnd())
                        .toString().simplified();
            }
            collectLocalVariables(statement, static_cast<int>(firstCode), lex,
                                  i, definitionFile, opcode,
                                  accumulator.userTypeNames);
            continue;
        }

        // Inside an instrument only the direct p-field assignments are of
        // interest: they are the instrument's parameters, shown in its help
        // page. Everything else in the body is skipped.
        if (inInstrument) {
            if (statement == u"endin"_s) {
                if (instrumentIndex >= 0)
                    result.instruments[instrumentIndex].endLine = i + 1;
                inInstrument = false;
                instrumentIndex = -1;
            }
            else if (instrumentIndex >= 0) {
                Definition &instrument = result.instruments[instrumentIndex];
                const QStringList fields = pAssignmentFields(statement);
                for (const QString &field : fields) {
                    // A variable can be assigned again later in the body; the
                    // first direct assignment is the parameter.
                    const QString variable = fieldVariable(field);
                    bool known = false;
                    for (const QString &existing : instrument.pFields)
                        known = known || fieldVariable(existing) == variable;
                    if (!known)
                        instrument.pFields.append(field);
                }
                collectLocalVariables(statement, static_cast<int>(firstCode),
                                      lex, i, definitionFile, instrument,
                                      accumulator.userTypeNames);
            }
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
            definition.docstring = readDocstring(lines, i);
            result.instruments.append(definition);
            if (!definition.name.isEmpty())
                accumulator.instrumentNames.insert(definition.name);
            inInstrument = true;
            instrumentIndex = result.instruments.size() - 1;
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
                definition.outTypes = outputs;
                definition.signatureParams = signature.captured(1).trimmed();
            }
            else {
                // Classic form: "opcode Name, outtypes, intypes".
                const QStringList parts =
                        definition.text.split(QLatin1Char(','), Qt::SkipEmptyParts);
                if (parts.size() >= 2)
                    definition.outTypes = parts.at(1).trimmed();
                if (parts.size() >= 3)
                    definition.inTypes = QStringList(parts.mid(2))
                            .join(QLatin1Char(',')).trimmed();
            }
            definition.docstring = readDocstring(lines, i);
            result.udos.append(definition);
            // Csound 7 declares its parameters in the signature: a:i, b:k.
            collectLocalVariables(statement, static_cast<int>(firstCode), lex,
                                  i, definitionFile, result.udos.last(),
                                  accumulator.userTypeNames);
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
        else if (startsWithKeyword(statement, u"struct"_s)) {
            const QRegularExpressionMatch structMatch =
                    structDeclRx.matchView(statement);
            if (structMatch.hasMatch())
                accumulator.userTypeNames.insert(structMatch.captured(1));
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

const Definition *Result::blockAt(int line) const
{
    const Definition *best = nullptr;
    const auto consider = [&](const QVector<Definition> &definitions) {
        for (const Definition &definition : definitions) {
            if (!definition.file.isEmpty()) // included-file block
                continue;
            if (definition.line < 1 || line < definition.line)
                continue;
            if (definition.endLine >= definition.line
                    && line > definition.endLine) {
                continue;
            }
            if (best == nullptr || definition.line > best->line)
                best = &definition;
        }
    };
    consider(instruments);
    consider(udos);
    return best;
}

const Definition::Variable *Result::variableAt(int line,
                                               const QString &name) const
{
    if (name.isEmpty())
        return nullptr;
    const Definition *block = blockAt(line);
    if (block == nullptr)
        return nullptr;
    const auto it = block->localVariables.constFind(name);
    return it == block->localVariables.constEnd() ? nullptr : &it.value();
}

QString docstringAbstract(const QString &docstring)
{
    const QString text = docstring.trimmed();
    qsizetype end = text.size();
    const qsizetype period = text.indexOf(QLatin1Char('.'));
    if (period >= 0)
        end = qMin(end, period);
    const qsizetype newline = text.indexOf(QLatin1Char('\n'));
    if (newline >= 0)
        end = qMin(end, newline);
    // The delimiter itself is not part of the abstract.
    return text.left(end).trimmed();
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

    // The help page shows how the opcode is called. The xin/xout variables of
    // a classic declaration are only known once the body has been scanned, so
    // the signatures are built after the whole program (includes included).
    for (Definition &udo : result.udos)
        udo.callSignature = buildCallSignature(udo);
    // An instrument's help signature is its name and the p-fields assigned in
    // its body. Anonymous (numeric) instruments have no name to show.
    for (Definition &instrument : result.instruments) {
        if (!instrument.name.isEmpty() && !instrument.pFields.isEmpty())
            instrument.callSignature = instrument.name + QLatin1Char(' ')
                    + instrument.pFields.join(u", "_s);
    }

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
