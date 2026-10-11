#!/usr/bin/env python3

# Rewrites widget fonts (<font>...</font> in widget panels) in the bundled
# examples and templates to the fonts CsoundQt ships, keeping the category
# (sans -> sans, serif -> serif, mono -> mono). This keeps the examples looking
# the same on every platform and avoids the "font replaced" notification.
#
# Usage: util/fix_example_fonts.py [--check]
#   --check  report files that still need fixing, change nothing

import argparse
import os
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGET_DIRS = [os.path.join(REPO_ROOT, "src", "Examples"),
               os.path.join(REPO_ROOT, "templates")]

# Bundled families that are left untouched.
KEEP = {
    "Liberation Sans", "Liberation Serif", "Liberation Mono",
    "Noto Sans", "Inter", "Source Sans 3", "IBM Plex Sans",
    "IBM Plex Serif", "Source Serif 4", "JetBrains Mono", "IBM Plex Mono",
}

# Non-bundled source fonts -> bundled target (category-preserving).
REPLACE = {
    # Sans
    "Arial": "Liberation Sans",
    "Arial Black": "Liberation Sans",
    "Helvetica": "Liberation Sans",
    "Helvetica Neue": "Liberation Sans",
    "Lucida Grande": "Liberation Sans",
    "Lucida Sans": "Liberation Sans",
    "DejaVu Sans": "Liberation Sans",
    "Bitstream Vera Sans": "Liberation Sans",
    "Nimbus Sans L": "Liberation Sans",
    "Nimbus Sans [urw]": "Liberation Sans",
    "Lato Heavy": "Liberation Sans",
    "TeX Gyre Heros": "Liberation Sans",
    "Eurostile": "Liberation Sans",
    "Papyrus": "Liberation Sans",
    "Verdana": "Liberation Sans",
    "Geneva": "Liberation Sans",
    "Tahoma": "Liberation Sans",
    "MS Shell Dlg 2": "Liberation Sans",
    "MS Shell Dlg": "Liberation Sans",
    "sans": "Liberation Sans",
    "Sans Serif": "Liberation Sans",
    # Serif
    "Times New Roman": "Liberation Serif",
    "Times": "Liberation Serif",
    "FreeSerif": "Liberation Serif",
    "Georgia": "Liberation Serif",
    "DejaVu Serif": "Liberation Serif",
    "Nimbus Roman": "Liberation Serif",
    "Palatino": "Liberation Serif",
    "Book Antiqua": "Liberation Serif",
    # Mono
    "Courier": "Liberation Mono",
    "Courier New": "Liberation Mono",
    "Courier 10 Pitch": "Liberation Mono",
    "DejaVu Sans Mono": "Liberation Mono",
    "Monaco": "Liberation Mono",
    "Andale Mono": "Liberation Mono",
    "Consolas": "Liberation Mono",
    "Nimbus Mono": "Liberation Mono",
}

FONT_RE = re.compile(r"<font>([^<]*)</font>")


def map_font(name):
    if name in KEEP:
        return name
    return REPLACE.get(name, "Liberation Sans")


def fix_text(text):
    def repl(match):
        return "<font>%s</font>" % map_font(match.group(1))
    return FONT_RE.sub(repl, text)


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true",
                        help="report files needing changes, do not modify")
    args = parser.parse_args()

    changed = 0
    scanned = 0
    for target in TARGET_DIRS:
        for dirpath, _dirs, files in os.walk(target):
            for name in files:
                if not name.endswith(".csd"):
                    continue
                path = os.path.join(dirpath, name)
                with open(path, "r", encoding="utf-8") as handle:
                    text = handle.read()
                scanned += 1
                fixed = fix_text(text)
                if fixed == text:
                    continue
                changed += 1
                relpath = os.path.relpath(path, REPO_ROOT)
                if args.check:
                    print("NEEDS FIX %s" % relpath)
                else:
                    with open(path, "w", encoding="utf-8") as handle:
                        handle.write(fixed)
                    print("fixed %s" % relpath)
    print("%s %d file(s), %d changed." %
          ("Checked" if args.check else "Processed", scanned, changed))
    return 0


if __name__ == "__main__":
    sys.exit(main())
