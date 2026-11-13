#!/usr/bin/env python3

# Convert old BSBController border settings to the current borderWidth property.
#
# Older controller widgets stored the border state as
#   <bordermode>border</bordermode>      (draw a border)
#   <bordermode>noborder</bordermode>    (no border)
# The current widget uses <borderWidth>, where 0 means no border. This script
# adds/updates <borderWidth> from the old bordermode tag:
#   noborder -> 0
#   border   -> 1, unless a borderWidth already exists
#
# It also handles the even older boolean <border> tag for controllers.
#
# The script rewrites only <bsbObject type="BSBController"> blocks and leaves
# the rest of the .csd byte-for-byte unchanged. It does not parse the whole
# file as XML, because orchestra code may contain characters that are invalid
# in XML.
#
# Usage:
#   python3 util/dev/fix_controller_borders.py file1.csd [file2.csd ...]

import argparse
import re
import sys
from pathlib import Path

CONTROLLER_RE = re.compile(
    r'(<bsbObject\b[^>]*\btype="BSBController"[^>]*>)(.*?)(</bsbObject>)',
    re.DOTALL,
)
BORDER_RE = re.compile(r"<border>\s*(.*?)\s*</border>", re.DOTALL)
BORDER_MODE_RE = re.compile(r"<bordermode>\s*(.*?)\s*</bordermode>", re.DOTALL)
BORDER_WIDTH_RE = re.compile(r"<borderWidth>\s*.*?\s*</borderWidth>", re.DOTALL)
FALSE_VALUES = {"0", "false", "no", "off"}


def old_border_is_visible(value):
    return value.strip().lower() not in FALSE_VALUES


def insert_after_tag(body, match, width):
    line_start = body.rfind("\n", 0, match.start()) + 1
    indent = body[line_start:match.start()]
    inserted = f"\n{indent}<borderWidth>{width}</borderWidth>"
    return body[:match.end()] + inserted + body[match.end():]


def fix_controller_block(match):
    opening, body, closing = match.groups()

    old_border = BORDER_RE.search(body)
    if old_border is not None:
        width = 1 if old_border_is_visible(old_border.group(1)) else 0
        if BORDER_WIDTH_RE.search(body):
            body = BORDER_WIDTH_RE.sub(
                f"<borderWidth>{width}</borderWidth>", body, count=1
            )
            body = BORDER_RE.sub("", body, count=1)
        else:
            body = BORDER_RE.sub(
                f"<borderWidth>{width}</borderWidth>", body, count=1
            )
        return opening + body + closing

    border_mode = BORDER_MODE_RE.search(body)
    if border_mode is None:
        return match.group(0)

    mode = border_mode.group(1).strip().lower()
    has_width = BORDER_WIDTH_RE.search(body) is not None
    if mode == "noborder":
        width = 0
    elif mode == "border":
        if has_width:
            return match.group(0)
        width = 1
    else:
        return match.group(0)

    if has_width:
        body = BORDER_WIDTH_RE.sub(
            f"<borderWidth>{width}</borderWidth>", body, count=1
        )
    else:
        body = insert_after_tag(body, border_mode, width)

    return opening + body + closing


def fix_file(path):
    with open(path, "r", encoding="utf-8", newline="") as handle:
        original = handle.read()

    changed = [0]

    def replace(match):
        fixed = fix_controller_block(match)
        if fixed != match.group(0):
            changed[0] += 1
        return fixed

    fixed = CONTROLLER_RE.sub(replace, original)
    if changed[0] == 0 or fixed == original:
        return 0

    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(fixed)
    return changed[0]


def main():
    parser = argparse.ArgumentParser(
        description="Convert old BSBController border settings to borderWidth."
    )
    parser.add_argument("files", nargs="+", type=Path, metavar="FILE.csd")
    args = parser.parse_args()

    changed_files = 0
    changed_controllers = 0
    for path in args.files:
        try:
            changed = fix_file(path)
        except OSError as error:
            print(f"{path}: {error}", file=sys.stderr)
            continue
        if changed:
            changed_files += 1
            changed_controllers += changed
            print(f"{path}: updated {changed} controller(s)")

    print(f"Updated {changed_controllers} controller(s) in {changed_files} file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
