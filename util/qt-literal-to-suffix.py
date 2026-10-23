#!/usr/bin/env python3
"""Replace Qt string wrappers with Qt's string-literal suffixes.

Pass source files or directories. Directories are searched recursively for C++
source/header files; build and VCS directories are skipped. Literal-only
QStringLiteral and QLatin1String calls are converted. The required
Qt::StringLiterals using-directive is added to changed files when absent. Use
--dry-run to inspect the diff first.
"""

from __future__ import annotations

import argparse
import difflib
import re
import sys
from pathlib import Path


CPP_SUFFIXES = {
    ".h", ".hh", ".hpp", ".hxx", ".c", ".cc", ".cpp", ".cxx", ".m", ".mm"
}
SKIP_DIRS = {".git", "build", "build-appimage", "build-dir", "node_modules"}
STRING_LITERAL_USING = "using namespace Qt::StringLiterals;"
STRING_LITERAL_USING_RE = re.compile(
    r"(?m)^\s*using\s+namespace\s+Qt\s*::\s*StringLiterals\s*;"
)
TRANSFORMATIONS = {
    "QStringLiteral": ("u", "_s"),
    "QLatin1String": ("", "_L1"),
}


def quoted_end(text: str, start: int, quote: str) -> int | None:
    """Return the position after a terminated ordinary quoted literal."""
    i = start + 1
    while i < len(text):
        if text[i] == "\\":
            i += 2
        elif text[i] == quote:
            return i + 1
        else:
            i += 1
    return None


def skip_quoted(text: str, start: int, quote: str) -> int:
    """Skip an ordinary string/character literal, terminated or otherwise."""
    end = quoted_end(text, start, quote)
    return len(text) if end is None else end


def raw_literal_end(text: str, start: int, prefix: str) -> int | None:
    """Return the end of a raw string, or None if the opener is malformed."""
    quote = start + len(prefix) - 1  # prefix ends in R\"
    paren = text.find("(", quote + 1)
    if paren < 0:
        return None
    delimiter = text[quote + 1 : paren]
    if len(delimiter) > 16 or any(c.isspace() or c in "()\\" for c in delimiter):
        return None
    closing = ")" + delimiter + '"'
    end = text.find(closing, paren + 1)
    return len(text) if end < 0 else end + len(closing)


def raw_prefix_at(text: str, start: int) -> str | None:
    for prefix in ('u8R"', 'uR"', 'UR"', 'LR"', 'R"'):
        if text.startswith(prefix, start):
            return prefix
    return None


def skip_trivia(text: str, start: int) -> int | None:
    """Skip whitespace/comments; None means an unterminated block comment."""
    i = start
    while i < len(text):
        if text[i].isspace():
            i += 1
        elif text.startswith("//", i):
            newline = text.find("\n", i + 2)
            i = len(text) if newline < 0 else newline + 1
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end < 0:
                return None
            i = end + 2
        else:
            break
    return i


def string_token_end(text: str, start: int) -> int | None:
    """Parse one unprefixed narrow ordinary or raw string literal."""
    if text.startswith('"', start):
        return quoted_end(text, start, '"')
    if text.startswith('R"', start):
        return raw_literal_end(text, start, 'R"')
    return None


def parse_literal_argument(
    text: str, open_paren: int, literal_prefix: str, suffix: str
) -> tuple[int, str] | None:
    """Parse adjacent narrow string literals inside a call and suffix them."""
    i = open_paren + 1
    literal_spans: list[tuple[int, int]] = []
    close_paren = -1
    while True:
        i = skip_trivia(text, i)
        if i is None:
            return None
        if i < len(text) and text[i] == ")":
            if not literal_spans:
                return None
            close_paren = i
            break
        end = string_token_end(text, i)
        if end is None:
            return None
        literal_spans.append((i, end))
        i = end

    # Add any requested prefix to each literal and the suffix to the final one,
    # preserving comments and spacing between adjacent literal tokens.
    argument = text[open_paren + 1 : close_paren]
    insertions: list[tuple[int, str]] = []
    if literal_prefix:
        for literal_start, _ in literal_spans:
            insertions.append((literal_start, literal_prefix))
    last_end = literal_spans[-1][1]
    insertions.append((last_end, suffix))
    for position, insertion in sorted(insertions, reverse=True):
        relative = position - (open_paren + 1)
        argument = argument[:relative] + insertion + argument[relative:]
    return close_paren + 1, argument


def is_identifier_start(char: str) -> bool:
    return char == "_" or char.isalpha() or ord(char) >= 0x80


def is_identifier_continue(char: str) -> bool:
    return is_identifier_start(char) or char.isdigit()


def convert(source: str) -> tuple[str, int]:
    """Convert supported literal calls, ignoring comments and string contents."""
    replacements: list[tuple[int, int, str]] = []
    i = 0
    while i < len(source):
        if source.startswith("//", i):
            newline = source.find("\n", i + 2)
            i = len(source) if newline < 0 else newline + 1
            continue
        if source.startswith("/*", i):
            end = source.find("*/", i + 2)
            i = len(source) if end < 0 else end + 2
            continue

        raw_prefix = raw_prefix_at(source, i)
        if raw_prefix:
            end = raw_literal_end(source, i, raw_prefix)
            i = len(source) if end is None else end
            continue
        if source[i] in ('"', "'"):
            i = skip_quoted(source, i, source[i])
            continue

        if is_identifier_start(source[i]):
            start = i
            i += 1
            while i < len(source) and is_identifier_continue(source[i]):
                i += 1
            name = source[start:i]
            if name in TRANSFORMATIONS and i < len(source) and source[i] == "(":
                literal_prefix, suffix = TRANSFORMATIONS[name]
                parsed = parse_literal_argument(source, i, literal_prefix, suffix)
                if parsed is not None:
                    end, replacement = parsed
                    replacements.append((start, end, replacement))
                    i = end
            continue
        i += 1

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
            i += 1
            continue
        if not stripped or stripped.startswith("//"):
            offset = line_end
            i += 1
            continue
        if stripped.startswith("/*"):
            in_block_comment = "*/" not in stripped
            offset = line_end
            i += 1
            continue
        if stripped.startswith("#"):
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
    parser.add_argument("paths", nargs="+", type=Path, help="C++ files or directories")
    parser.add_argument("--dry-run", action="store_true", help="print diffs without writing")
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
        updated, count = convert(original)
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
            print(f"{path}: converted {count} string literal call(s)")
    if args.dry_run:
        print(f"Would convert {total} QStringLiteral call(s) in {changed_files} file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
