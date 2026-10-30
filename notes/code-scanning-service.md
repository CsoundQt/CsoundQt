# Code scanning service

This note describes how CsoundQt scans Csound source and who consumes the
result. The scanner is pure data processing: source text goes in, a structured
result comes out. Nothing in `CodeScan` depends on widgets, editors, files or
timers.

## Pipeline

```text
editor text
   |
   v
DocumentPage::textChanged()
   |
   v
ScanService::sourceChanged()          (mark dirty + start debounce if active)
   |
   v
ScanService::scanActive()             (after 250 ms without typing)
   |
   v
CodeScan::scanPtr(text, mode, includeProvider, filePath)
   |
   v
CodeScan::Result                      (immutable, shared)
   |
   v
DocumentPage::applyScan()
   |
   +--> syntax highlighter
   +--> autocomplete
   +--> Go to Source
   +--> Show Type
   +--> Inspector tree
   +--> UDO / instrument / variable lists
```

## When scanning is triggered

### Typing in the active document

Every text change calls:

```text
DocumentPage::textChanged()
  -> ScanService::sourceChanged(this)
```

`sourceChanged()`:

- marks that document dirty;
- if the document is the currently active scan source, starts/resets the
  single-shot debounce timer.

The debounce interval is **250 ms**. This coalesces continuous typing into one
scan once the user pauses.

### Switching tabs or opening a file

Activating a page calls:

```text
ScanService::setActiveSource(page)
ScanService::scanNow(page)
```

`scanNow()` scans immediately when the document is dirty. When it is not dirty,
the cached `Result` is re-emitted without parsing the text again.

This is also why a background document does not cost anything while it is not
being edited.

### Save As / file name changes

Changing the file name invalidates the scan because the path affects:

- how `#include` directives are resolved;
- how the document is classified (`.csd`, `.orc`, `.udo`, `.inc`, ...).

The document is marked dirty and, if active, scanned after the normal debounce.

### Go to Source / UDO help

Actions that need current definitions call `ScanService::scanNow()` before
looking things up. They therefore see the latest text even if the debounce has
not fired yet.

### Included files changing on disk

`ScanService` has a dependency timer with a **2 second** interval. It only
`stat()`s the files recorded as dependencies; no parsing happens during the
poll.

If an included file's modification time or size changed:

- the owning source is marked dirty;
- the active document is rescanned after the normal debounce;
- a background document is rescanned when it is next activated.

The `Reload Included Files` action clears the include cache, marks every known
document dirty and scans them immediately.

## Scan scope

A scan is **whole-document**, not “current instrument/opcode only”.

For a `.csd`, the orchestra is the scanned part:

```text
<CsInstruments>
    ...
</CsInstruments>
```

For a bare orchestra file (`.orc`, `.udo`, `.inc`) the whole text is scanned.
`.html` and `.sco` files get an empty result (`Mode::None`).

The result, however, is structured **per block**. Instruments and UDOs carry:

- their start/end line (`line`, `endLine`);
- their local variables and types;
- arguments, docstrings, p-fields, call signatures, etc.

This is what lets consumers answer block-sensitive questions such as “what is
the type of this variable on this line?” without rescanning the text.

## Included files

Includes are not independent scan sources. They are expanded recursively while
scanning the containing document:

```text
main.csd
  #include "udo.inc"
      #include "more.inc"
```

Each included file:

- is parsed in orchestra mode;
- contributes its definitions to the same overall result;
- carries its own file path in definitions and variable locations;
- is recorded in `Result::dependencies` with its modification stamp.

`IncludeCache` avoids reading unchanged files from disk, but the included text
is still parsed again whenever the parent document is rescanned.

Nested includes are supported up to `MAX_INCLUDE_DEPTH`; cycles are prevented
by tracking open files.

## Background documents

`ScanService` keeps state for every document, not only the active one:

- a background document is marked dirty when its text or dependencies change;
- it is **not** repeatedly rescanned in the background;
- its cached result stays available;
- it is rescanned on activation if dirty.

This keeps typing responsive even with many open tabs.

## Result data model

`CodeScan::Result` contains the document-level information:

- `udos`
- `instruments`
- `preprocessor`
- `ftables`
- `definitions` — the global definition index
- `globalVariables`
- `globalStringVariables`
- `instrumentNames`
- `dependencies`
- `orchestraLine` / `scoreLine`

A `Definition` contains, among other things:

```cpp
QString name;
Kind kind;
int line;       // 1-based start line
int endLine;    // 1-based endin/endop line, or -1
int column;     // 0-based
QString file;   // empty for the scanned document
QHash<QString, Variable> localVariables;
```

A local variable stores:

```cpp
QString name;
QString type;   // normalized: "a", "k", "S", "OpcodeDef", "MyStruct", ...
bool array;
int line;       // first introduction
int column;
QString file;
```

`Result::blockAt(line)` finds the instrument/UDO containing a line.
`Result::variableAt(line, name)` looks up a local variable in that block.
Both are used for scope-sensitive operations such as Go to Source and Show Type.

## Consumers

### Syntax highlighter

`DocumentPage::applyScan()` sends one `Highlighter::VariableScope` per block:

```cpp
struct VariableScope
{
    int startLine;
    int endLine;
    QHash<QString, QString> variables; // name -> type
};
```

The highlighter looks up a word by the current block line, so the same name can
have different colours in different instruments/opcodes. The scanner does not
yet provide global types; those are still handled by the highlighter itself.

`Global variables`, UDO names and other lists are also refreshed from the scan.
A full rehighlight happens only when the relevant sets changed.

### Autocomplete

Autocomplete consumes:

- global variable names;
- global string variable names;
- instrument names;
- UDO names;
- the current block’s local variable names and types.

The current-block provider is line-based, so completions follow the instrument
or opcode containing the cursor. Type-aware opcode ranking uses the scanner’s
type for the assignment target when it is already known, and falls back to the
legacy name prefix for a variable being introduced.

### Go to Source

`DocumentPage::goToSource()` first tries a block-local variable on the reference
line. If found, it jumps to the variable’s first-introduction line/column; its
`file` path is used when it has one. Only if no local variable matches does it
fall back to the document-level definition index for instruments, UDOs, macros,
etc.

### Show Type

The editor context menu asks `DocumentPage::variableTypeAt(line, name)`, which
uses `Result::variableAt()`. The action is shown only when the clicked word is
a local variable in the current block.

### Inspector

The inspector receives the scan result and builds its tree from:

- UDOs;
- instruments;
- preprocessor entries;
- ftables.

It also uses the current scope line to highlight the active instrument/opcode.

## Important properties

- Scanning is **text-only** and synchronous. Timers decide *when* to run it, not
  what it does.
- `Result` is immutable and shared as `QSharedPointer<const Result>`.
- Only the active document is scanned at typing speed.
- Included files are parsed as part of the parent scan; disk reads are cached
  separately.
- Per-block data is retained, so consumers do not need to re-parse “the current
  instrument” themselves.
