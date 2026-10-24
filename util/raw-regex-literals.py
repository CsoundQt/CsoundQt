#!/usr/bin/env python3
"""Convert single-line QRegularExpression literals to raw UTF-16 literals.

The script finds ordinary string literals used to build a QRegularExpression,
for example

    static const QRegularExpression rx(u"\\bfoo\\s+(\\w+)"_s);
    static const QRegularExpression rx("\\bfoo\\s+(\\w+)");
    static const QRegularExpression rx(QStringLiteral("\\bfoo\\s+(\\w+)"));

and turns them into raw UTF-16 literals, removing the C++ escaping that only
existed because the literal was not raw:

    static const QRegularExpression rx(uR"(\\bfoo\\s+(\\w+))"_s);

Plain narrow literals and the QStringLiteral wrapper are replaced by the
uR"..."_s form as well. Only single-line literals are touched. A literal that
is concatenated with another string literal, or whose QRegularExpression call
continues on another line, is left alone. The decoded value is compared before
and after the conversion, and Python's re module is used as a sanity check that
the pattern still compiles. Use --no-regex-check for PCRE patterns that
Python's regular expression engine does not understand.

The literal must be the complete first argument of a QRegularExpression
constructor or setPattern() call on the same line. Other string literals are
ignored. The required Qt::StringLiterals using-directive is added to changed
files when absent.

    python3 util/raw-regex-literals.py src tests
    python3 util/raw-regex-literals.py --dry-run src

"""

from __future__ import annotations

import argparse
import difflib
import re
import sys
from dataclasses import dataclass
from pathlib import Path


CPP_SUFFIXES = {
    ".h", ".hh", ".hpp", ".hxx", ".c", ".cc", ".cpp", ".cxx", ".m", ".mm"
}
SKIP_DIRS = {".git", "build", "build-appimage", "build-dir", "node_modules"}

# Prefixes of string literals, longest first. Only the ordinary "u" prefix is
# converted; the others still have to be recognised and skipped.
ORDINARY_PREFIXES = ("u8", "u", "U", "L", "")
RAW_PREFIXES = ("u8R", "uR", "UR", "LR", "R")

CONTEXT_RE = re.compile(r"\bQRegularExpression\b|\bsetPattern\b")
STRING_LITERAL_USING = "using namespace Qt::StringLiterals;"
STRING_LITERAL_USING_RE = re.compile(
    r"(?m)^\s*using\s+namespace\s+Qt\s*::\s*StringLiterals\s*;"
)


@dataclass
class ReplacementSpan:
    start: int
    end: int


@dataclass
class StringToken:
    start: int
    end: int          # includes the _s suffix, when present
    prefix: str
    raw: bool
    content_start: int
    content_end: int
    has_suffix: bool
    concatenated: bool = False


def is_identifier_start(char: str) -> bool:
    return char == "_" or char.isalpha() or ord(char) >= 0x80


def is_identifier_continue(char: str) -> bool:
    return is_identifier_start(char) or char.isdigit()


def quoted_literal_end(source: str, quote: int, terminator: str = '"') -> int | None:
    """End of an ordinary quoted literal, or None if it is malformed."""
    i = quote + 1
    while i < len(source):
        char = source[i]
        if char == "\\":
            if i + 1 >= len(source):
                return None
            i += 2
        elif char == terminator:
            return i + 1
        elif char in "\r\n":
            return None
        else:
            i += 1
    return None


def ordinary_literal_end(source: str, quote: int) -> int | None:
    """End of an ordinary string literal, or None if it is malformed."""
    return quoted_literal_end(source, quote, '"')


def raw_literal_end(source: str, start: int, prefix: str) -> int | None:
    """End of a raw string literal, or None if the opener is malformed."""
    quote = start + len(prefix)
    paren = source.find("(", quote + 1)
    if paren < 0:
        return None
    delimiter = source[quote + 1 : paren]
    if len(delimiter) > 16:
        return None
    if any(char.isspace() or char in "()\\" for char in delimiter):
        return None
    closing = ")" + delimiter + '"'
    end = source.find(closing, paren + 1)
    return len(source) if end < 0 else end + len(closing)


def skip_comment(source: str, start: int) -> int:
    if source.startswith("//", start):
        newline = source.find("\n", start + 2)
        return len(source) if newline < 0 else newline + 1
    if source.startswith("/*", start):
        end = source.find("*/", start + 2)
        return len(source) if end < 0 else end + 2
    return start


def scan_strings(source: str) -> list[StringToken]:
    """String literals in lexical order, ignoring comments and char literals."""
    tokens: list[StringToken] = []
    i = 0
    while i < len(source):
        if source.startswith("//", i) or source.startswith("/*", i):
            i = skip_comment(source, i)
            continue
        if source[i] == "'":
            end = quoted_literal_end(source, i, "'")
            i = len(source) if end is None else end
            continue

        matched = False
        for prefix in RAW_PREFIXES:
            text = prefix + '"'
            if source.startswith(text, i):
                end = raw_literal_end(source, i, prefix)
                if end is not None:
                    tokens.append(StringToken(
                        i, end, prefix, True, i + len(text), end, False))
                    i = end
                    matched = True
                    break
        if matched:
            continue

        for prefix in ORDINARY_PREFIXES:
            text = prefix + '"'
            if not source.startswith(text, i):
                continue
            quote = i + len(prefix)
            end = ordinary_literal_end(source, quote)
            if end is None:
                i = len(source)
                matched = True
                break
            suffix_end = end
            has_suffix = source.startswith("_s", end)
            if has_suffix:
                after = end + 2
                if after >= len(source) or not is_identifier_continue(source[after]):
                    suffix_end = after
                else:
                    has_suffix = False
            tokens.append(StringToken(
                i, suffix_end, prefix, False,
                quote + 1, end - 1, has_suffix))
            i = suffix_end
            matched = True
            break
        if matched:
            continue

        if is_identifier_start(source[i]):
            i += 1
            while i < len(source) and is_identifier_continue(source[i]):
                i += 1
            continue
        i += 1
    return tokens


def only_trivia(text: str) -> bool:
    """True when text contains only whitespace and comments."""
    i = 0
    while i < len(text):
        if text[i].isspace():
            i += 1
        elif text.startswith("//", i):
            newline = text.find("\n", i + 2)
            i = len(text) if newline < 0 else newline + 1
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end < 0:
                return False
            i = end + 2
        else:
            return False
    return True


def skip_trivia_prefix(text: str, start: int = 0) -> int | None:
    """Index of the first non-trivia character at/after start.

    A line comment before the end of the text means the rest of the line is
    gone: there is no code after it on this line, so None is returned.
    """
    i = start
    while i < len(text):
        if text[i].isspace():
            i += 1
        elif text.startswith("//", i):
            return None
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end < 0:
                return None
            i = end + 2
        else:
            break
    return i


def mark_concatenated(tokens: list[StringToken], source: str) -> None:
    for previous, current in zip(tokens, tokens[1:]):
        if only_trivia(source[previous.end:current.start]):
            previous.concatenated = True
            current.concatenated = True


def pattern_argument(source: str, token: StringToken) -> ReplacementSpan | None:
    """Find the regex pattern literal and the text to replace.

    The literal has to be the complete first argument of a QRegularExpression
    constructor or setPattern() call, on the same source line. It may be a
    QStringLiteral wrapper; the replacement then covers the whole wrapper, so
    that QStringLiteral is not left around a uR"..."_s argument.
    """
    if token.raw:
        return None
    if token.prefix == "u":
        if not token.has_suffix:
            return None
    elif token.prefix != "":
        return None

    line_start = source.rfind("\n", 0, token.start) + 1
    line_end = source.find("\n", token.start)
    if line_end < 0:
        line_end = len(source)
    before = source[line_start:token.start]

    matches = list(CONTEXT_RE.finditer(before))
    if not matches:
        return None
    marker = matches[-1]
    paren = before.find("(", marker.end())
    if paren < 0:
        return None

    # Make sure the parentheses belong to QRegularExpression/setPattern and
    # not to an unrelated call later on the same line (for example after a
    # QRegularExpression declaration ending in a semicolon).
    bridge = before[marker.end():paren]
    if marker.group(0) == "setPattern":
        if skip_trivia_prefix(bridge) != len(bridge):
            return None
    else:
        index = skip_trivia_prefix(bridge)
        if index is None:
            return None
        if bridge.startswith("::", index):
            index = skip_trivia_prefix(bridge, index + 2)
            if (index is None or index >= len(bridge)
                    or not is_identifier_start(bridge[index])):
                return None
            index += 1
            while index < len(bridge) and is_identifier_continue(bridge[index]):
                index += 1
            index = skip_trivia_prefix(bridge, index)
            if index is None:
                return None
        if index < len(bridge):
            if not is_identifier_start(bridge[index]):
                return None
            index += 1
            while index < len(bridge) and is_identifier_continue(bridge[index]):
                index += 1
            index = skip_trivia_prefix(bridge, index)
            if index is None or index != len(bridge):
                return None

    call_open = line_start + paren
    between = source[call_open + 1:token.start]

    index = skip_trivia_prefix(between)
    if index is None:
        return None

    wrapped = False
    wrapper_start = token.start
    if index < len(between):
        # QStringLiteral("...") is the only wrapper we can remove cleanly; any
        # other expression (QLatin1String, QString::fromUtf8, ...) would be
        # broken by inserting a UTF-16 literal inside it.
        if token.prefix != "":
            return None
        if not between.startswith("QStringLiteral", index):
            return None
        name_end = index + len("QStringLiteral")
        if name_end < len(between) and is_identifier_continue(between[name_end]):
            return None
        wrapper_start = call_open + 1 + index
        index = skip_trivia_prefix(between, name_end)
        if index is None or index >= len(between) or between[index] != "(":
            return None
        index = skip_trivia_prefix(between, index + 1)
        if index != len(between):
            return None
        wrapped = True

    rest = source[token.end:line_end]
    index = skip_trivia_prefix(rest)
    if index is None or index >= len(rest):
        return None

    if wrapped:
        if rest[index] != ")":
            return None
        wrapper_end = token.end + index + 1
        index = skip_trivia_prefix(rest, index + 1)
        if index is None or index >= len(rest) or rest[index] not in ",)":
            return None
        return ReplacementSpan(wrapper_start, wrapper_end)

    if rest[index] not in ",)":
        return None
    return ReplacementSpan(token.start, token.end)


def decode_literal(content: str) -> str | None:
    """Decode a non-raw literal, accepting only escapes that raw strings keep.

    \\, \" and \' are C++ quoting escapes whose backslash is not part of the
    value. Any other escape (\\n, \\t, hex, ...) would change meaning when the
    literal becomes raw and is deliberately left alone.
    """
    result: list[str] = []
    i = 0
    while i < len(content):
        char = content[i]
        if char != "\\":
            result.append(char)
            i += 1
            continue
        if i + 1 >= len(content):
            return None
        escaped = content[i + 1]
        if escaped in '\\"\'?':
            result.append(escaped)
            i += 2
        else:
            return None
    return "".join(result)


def choose_delimiter(value: str) -> str | None:
    if ')"' not in value:
        return ""
    for number in range(1, 100):
        delimiter = f"RX{number}"
        if f'){delimiter}"' not in value:
            return delimiter
    return None


def convert(source: str, check_regex: bool = True) -> tuple[str, int]:
    """Return the converted source and the number of literals changed."""
    tokens = scan_strings(source)
    mark_concatenated(tokens, source)

    replacements: list[tuple[int, int, str]] = []
    for token in tokens:
        if token.concatenated:
            continue
        span = pattern_argument(source, token)
        if span is None:
            continue

        content = source[token.content_start:token.content_end]
        value = decode_literal(content)
        if value is None:
            print(f"Skipping a regex literal with a non-quoting escape at "
                  f"offset {token.start}", file=sys.stderr)
            continue
        if check_regex:
            try:
                re.compile(value)
            except re.error as error:
                print(f"Skipping a regex literal that Python cannot compile "
                      f"at offset {token.start}: {error}", file=sys.stderr)
                continue

        delimiter = choose_delimiter(value)
        if delimiter is None:
            print(f"Skipping a regex literal with no usable raw delimiter at "
                  f"offset {token.start}", file=sys.stderr)
            continue

        replacement = f'uR"{delimiter}({value}){delimiter}"_s'
        replacements.append((span.start, span.end, replacement))

    converted = source
    for start, end, replacement in reversed(replacements):
        converted = converted[:start] + replacement + converted[end:]
    return converted, len(replacements)


def add_string_literal_using(source: str) -> str:
    """Add the string-literal namespace after the file's initial directives."""
    if STRING_LITERAL_USING_RE.search(source):
        return source

    lines = source.splitlines(keepends=True)
    offset = 0
    insertion = 0
    in_block_comment = False
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        line_end = offset + len(line)

        if in_block_comment:
            if "*/" in stripped:
                in_block_comment = False
            offset = line_end
            insertion = line_end
            i += 1
            continue
        if not stripped or stripped.startswith("//"):
            offset = line_end
            insertion = line_end
            i += 1
            continue
        if stripped.startswith("/*"):
            in_block_comment = "*/" not in stripped
            offset = line_end
            insertion = line_end
            i += 1
            continue
        if stripped.startswith("#"):
            # Do not place the using-directive inside a conditional block:
            # the code that needs it may be outside the condition.
            directive = stripped[1:].lstrip()
            if re.match(r"(if|ifdef|ifndef|else|elif|endif)\b", directive):
                break
            # Keep a continued preprocessor directive together.
            while line.rstrip("\r\n").endswith("\\") and i + 1 < len(lines):
                i += 1
                line = lines[i]
                line_end = offset + len(line)
            insertion = line_end
            offset = line_end
            i += 1
            continue
        break

    prefix = source[:insertion]
    separator = "" if not prefix or prefix.endswith("\n") else "\n"
    return prefix + separator + STRING_LITERAL_USING + "\n" + source[insertion:]


def source_files(paths: list[Path]) -> list[Path]:
    files: set[Path] = set()
    for path in paths:
        if not path.exists():
            raise FileNotFoundError(path)
        if path.is_file():
            files.add(path)
            continue
        for candidate in path.rglob("*"):
            if any(part in SKIP_DIRS or part.startswith(".") for part in candidate.parts):
                continue
            if candidate.is_file() and candidate.suffix.lower() in CPP_SUFFIXES:
                files.add(candidate)
    return sorted(files)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="+", type=Path,
                        help="C++ files or directories")
    parser.add_argument("--dry-run", action="store_true",
                        help="print diffs without writing")
    parser.add_argument("--no-regex-check", action="store_true",
                        help="convert PCRE patterns Python's re cannot compile")
    args = parser.parse_args()

    try:
        files = source_files(args.paths)
    except OSError as error:
        parser.error(str(error))

    total = 0
    changed_files = 0
    for path in files:
        original_bytes = path.read_bytes()
        try:
            original = original_bytes.decode("utf-8")
        except UnicodeDecodeError as error:
            print(f"Skipping non-UTF-8 file {path}: {error}", file=sys.stderr)
            continue
        updated, count = convert(original, check_regex=not args.no_regex_check)
        if not count:
            continue
        updated = add_string_literal_using(updated)
        total += count
        changed_files += 1
        if args.dry_run:
            diff = difflib.unified_diff(
                original.splitlines(keepends=True),
                updated.splitlines(keepends=True),
                fromfile=str(path),
                tofile=str(path),
            )
            sys.stdout.writelines(diff)
        else:
            path.write_bytes(updated.encode("utf-8"))
            print(f"{path}: converted {count} regex literal(s)")
    if args.dry_run:
        print(f"Would convert {total} regex literal(s) in {changed_files} file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
