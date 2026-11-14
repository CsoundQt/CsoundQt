#!/usr/bin/env python3

# Set every menu widget in a .csd to the flat style.
#
# Menu widgets are stored as <bsbObject type="BSBDropdown"> blocks. The script
# edits the file as text rather than parsing the whole document as XML, because
# orchestra code may contain characters that are invalid in XML.
#
# Existing <flatStyle> values are replaced; a missing element is inserted.
# Each file is saved back to its original filename.
#
# Usage:
#   python3 util/dev/flat_menus.py file1.csd [file2.csd ...]

import argparse
import re
import sys
from pathlib import Path

MENU_RE = re.compile(
    r'(<bsbObject\b[^>]*type="BSBDropdown"[^>]*>)(.*?)(</bsbObject>)',
    re.DOTALL,
)
FLAT_STYLE_RE = re.compile(
    r"<flatStyle\b[^>]*(?:/>|>.*?</flatStyle>)", re.DOTALL
)


def child_indent(body):
    match = re.search(r"\n([ \t]+)<", body)
    return match.group(1) if match is not None else "  "


def append_tag(body, tag, value):
    indent = child_indent(body)
    trailing = re.search(r"\s*$", body).group(0)
    core = body[:-len(trailing)] if trailing else body
    return core + f"\n{indent}<{tag}>{value}</{tag}>" + trailing


def set_flat(body):
    if FLAT_STYLE_RE.search(body):
        return FLAT_STYLE_RE.sub("<flatStyle>true</flatStyle>", body, count=1)
    return append_tag(body, "flatStyle", "true")


def make_flat(match):
    opening, body, closing = match.groups()
    return opening + set_flat(body) + closing


def flatten_file(path):
    with open(path, "r", encoding="utf-8", newline="") as handle:
        original = handle.read()

    changed = [0]

    def replace(match):
        flattened = make_flat(match)
        if flattened != match.group(0):
            changed[0] += 1
        return flattened

    updated = MENU_RE.sub(replace, original)
    if changed[0] > 0:
        with open(path, "w", encoding="utf-8", newline="") as handle:
            handle.write(updated)
    return changed[0]


def main():
    parser = argparse.ArgumentParser(
        description="Set all menu widgets in .csd files to the flat style."
    )
    parser.add_argument("files", nargs="+", type=Path, metavar="FILE.csd")
    args = parser.parse_args()

    failed = False
    for path in args.files:
        try:
            count = flatten_file(path)
        except OSError as error:
            print(f"{path}: {error}", file=sys.stderr)
            failed = True
            continue

        if count == 0:
            print(f"{path}: no non-flat menus found.")
        else:
            print(f"{path}: set {count} menu(s) to flat style.")

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
