
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

#ifndef CODESCAN_H
#define CODESCAN_H

#include <QHash>
#include <QSharedPointer>
#include <QString>
#include <QStringList>
#include <QVector>

// One scan of a piece of Csound source text, shared by everything that needs
// to know what is defined in it: the syntax highlighter (user-defined opcode
// names), autocompletion (globals, instrument names, opcode arguments),
// "Go to Source" (definitions and their lines) and the inspector tree.
//
// The scanner is pure: text goes in, data comes out. It knows nothing about
// editors, documents, files or timers, so it can be called from anywhere and
// tested without a main window.
namespace CodeScan {

// How the text is laid out. A .csd document has its orchestra between
// <CsInstruments> tags; an orchestra-only document (.orc, .udo, .inc) is a
// single orchestra section that starts at the first line.
enum class Mode {
    None,   // not a Csound document: nothing to scan
    Csd,    // full .csd, orchestra between the tags
    Orc     // bare orchestra code
};

enum class Kind {
    Udo,        // opcode Foo, S, k
    Instrument, // instr Foo
    Macro,      // #define FOO #1#
    Struct,     // struct Foo val0:i
    FTable,     // ftgen line, listed in the inspector tree only
    Include     // #include line, listed in the inspector tree only
};

// A file that an #include directive pulled in, with the stamp it had when it
// was read. The stamp lets the scheduler notice that the file changed on disk
// without reading it again.
struct Dependency
{
    QString path;
    qint64 lastModified = 0;
    qint64 size = 0;
};

struct IncludeFile
{
    QString path;   // canonical: the identity of the file
    QString text;
    qint64 lastModified = 0;
    qint64 size = 0;
};

// Supplies the text of the files a document includes. The scanner never reads
// files itself; the implementation decides where includes are looked for and
// caches what it has already read.
class IncludeProvider
{
public:
    virtual ~IncludeProvider() = default;
    // The file named by an #include directive in includingFile (empty when the
    // directive is in the scanned text itself). angled is true for
    // #include <file> and false for #include "file". Returns an IncludeFile
    // with an empty path when the file cannot be found or read.
    virtual IncludeFile include(const QString &spec, const QString &includingFile,
                                bool angled) = 0;
};

struct Definition
{
    QString name;
    Kind kind = Kind::Udo;
    int line = -1;   // 1-based line of the definition
    int endLine = -1; // 1-based line of endin/endop, when one was seen
    int column = 0;  // 0-based column of the name within that line

    // One local variable of an instrument or user-defined opcode: its inferred
    // type and the place it was first introduced in the block.
    struct Variable
    {
        QString name;
        QString type;      // normalized type, e.g. "k", "a", "OpcodeDef"
        bool array = false;
        int line = -1;     // 1-based
        int column = 0;    // 0-based
        QString file;      // empty for the scanned document
    };
    // Instruments and UDOs only. Insertion keeps the first introduction; later
    // uses or repeated typed declarations do not replace it.
    QHash<QString, Variable> localVariables;
    // The line as shown in the inspector tree. Only the entries of the tree
    // lists (udos, instruments, preprocessor, ftables) fill it.
    QString text;
    // Empty for the scanned text. Reserved for definitions that come from an
    // included file, which will carry the path of that file.
    QString file;
    // User-defined opcodes only: the arguments declared with xin and xout,
    // and the lines they were found on (for the tree). A Csound 7 signature,
    // "opcode Foo(a:i):k", fills inArgs from the parameter names and outArgs
    // from the output types, and sets newStyle. Such an opcode has no xin
    // line, but its outputs are still assigned with xout.
    QString inArgs, outArgs;
    int inArgsLine = -1, outArgsLine = -1;
    bool newStyle = false;
    // The documentation comment that follows the declaration line: the body
    // of a /* ... */ block without the delimiters and the indentation the
    // comment shares. Empty when the opcode or instrument has no docstring.
    QString docstring;
    // Instruments only: the direct p-field assignments in the body, as shown
    // in the help page: "ifoo:i(p4)", "kbar:k(p5)". This covers single and
    // list assignments as well as passign; only assignments whose right-hand
    // side is just p-fields are listed, once per variable.
    QStringList pFields;
    // How the definition is shown in its help page. For a user-defined opcode
    // the call with its arguments and outputs: "myop(foo:k, bar:i) -> asig:a";
    // for an instrument the name and its p-fields: "bar ifoo:i(p4), kbar:k(p5)".
    // Built by the scanner, because the declared types and the xin/xout or
    // p-field variables have to be combined.
    QString callSignature;
    // User-defined opcodes only: the parts callSignature is built from. A
    // Csound 7 declaration keeps its parameter list, types included, in
    // signatureParams; the classic "opcode Foo, a, kk" form instead has the
    // type strings in outTypes and inTypes. outVars are the names given to
    // xout, for both forms.
    QString signatureParams, outTypes, inTypes, outVars;
};

// The first sentence of a docstring, used as its abstract: the text up to the
// first '.' or line break, trimmed. Empty when there is no such text.
QString docstringAbstract(const QString &docstring);

struct Result
{
    // What the inspector tree lists, in the order the entries appear.
    QVector<Definition> udos;
    QVector<Definition> instruments;   // every instr line, numbered ones too
    QVector<Definition> preprocessor;  // #define and #include lines
    QVector<Definition> ftables;

    // The names defined in the text, for "Go to Source". A later definition
    // of a name replaces the earlier one, as in Csound. Numbered instruments
    // ("instr 1,2") are not names and are not indexed.
    QHash<QString, Definition> definitions;

    // Names that autocompletion offers; UDO names are not variables.
    QStringList globalVariables;
    QStringList globalStringVariables;
    QStringList instrumentNames;

    int orchestraLine = -1;  // first line inside the orchestra section
    int scoreLine = -1;      // line of <CsScore>, in .csd documents

    // The files that were pulled in by #include, with the stamps they had when
    // they were read. Empty when the document has no includes.
    QVector<Dependency> dependencies;

    // The definition of name, or nullptr when the name is not defined here.
    const Definition *find(const QString &name) const;
    // The instrument/UDO block containing a 1-based editor line in the main
    // document, or nullptr when the line is outside every block.
    const Definition *blockAt(int line) const;
    // The local variable `name` in the block containing line, or nullptr.
    const Definition::Variable *variableAt(int line, const QString &name) const;
};

// A shared, immutable result: consumers only read it, so passing it around is
// cheap and a later background scan can hand it over without copying.
using ResultPtr = QSharedPointer<const Result>;

// Anything whose text can be scanned and that shows the result: a document,
// for now. The interface keeps the scanning service independent of the
// editor, and lets the service be tested with a source that is not a widget.
class Source
{
public:
    virtual ~Source() = default;
    // The text to scan, as Csound sees it.
    virtual QString scanText() = 0;
    // How that text is laid out.
    virtual Mode scanMode() const = 0;
    // The file the text came from, used to resolve its #include directives.
    // Empty for a document that has not been saved yet.
    virtual QString scanFilePath() const { return QString(); }
    // Directories searched for #include names that are not relative to the
    // including file: the editor's configured include path plus the document's
    // own --env:INCDIR options. Empty when there are none.
    virtual QStringList includeSearchPaths() { return QStringList(); }
    // Takes the result: highlighting, completion, "Go to Source", the tree.
    virtual void applyScan(const ResultPtr &scan) = 0;
};

// The result of scanning nothing: an empty document, or a document that is not
// Csound source (HTML, a score file).
ResultPtr empty();

// Scans text. With an include provider, #include directives are expanded in
// place and the files they pull in are added to the result; filePath is the
// path of the scanned text, needed to resolve relative includes and to keep
// the result free of cycles.
Result scan(const QString &text, Mode mode,
            IncludeProvider *includes = nullptr,
            const QString &filePath = QString());
ResultPtr scanPtr(const QString &text, Mode mode,
                  IncludeProvider *includes = nullptr,
                  const QString &filePath = QString());

} // namespace CodeScan

Q_DECLARE_METATYPE(CodeScan::ResultPtr)

#endif // CODESCAN_H
