#!/usr/bin/env python3

# Sorts the XML attributes inside the <bsbPanel> widget section of .csd files
# into alphabetical order.
#
# CsoundQt saves the widget panel through QDomDocument::toString(), which
# writes attributes in alphabetical order (QDom sorts them to guarantee
# reproducible output). Files that were saved before that behaviour, or edited
# by hand, can have their attributes in a different order, which then shows up
# in git as a change that is not a real change. This script normalizes the
# committed examples so that re-saving them in CsoundQt is a no-op.
#
# Only the <bsbPanel>...</bsbPanel> section is touched. Everything else - the
# Csound code and the other XML sections - is left byte-for-byte unchanged, and
# the existing formatting (indentation, line endings) is preserved; the only
# changes are the order of attributes within a start tag and the collapsing of
# empty element pairs (<tag></tag> -> <tag/>), which is how QDom writes them.
#
# Panels that are not well-formed XML are left untouched and reported.
#
# Usage: util/sort_bsbpanel_attributes.py [--check] [path ...]
#   --check   report files that would change, modify nothing
#   path      file or directory to scan (default: the bundled examples)

import argparse
import os
import re
import sys
import xml.etree.ElementTree as ET

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_PATHS = [os.path.join(REPO_ROOT, "src", "Examples"),
                 os.path.join(REPO_ROOT, "templates")]

PANEL_RE = re.compile(r"<bsbPanel\b.*?</bsbPanel>", re.S)
# A start tag: <name attr="value" attr2='value2' ... > or <name ... />
TAG_RE = re.compile(r"""<([A-Za-z_][\w:.-]*)"""
                    r"""((?:\s+[\w:.-]+\s*=\s*(?:"[^"]*"|'[^']*'))*)"""
                    r"""\s*(/?)>""")
# One attribute with a quoted value.
ATTR_RE = re.compile(r"""([\w:.-]+)\s*=\s*("[^"]*"|'[^']*')""")
# An empty element written as <tag></tag> (QDom writes these as <tag/>).
EMPTY_PAIR_RE = re.compile(r"""<([A-Za-z_][\w:.-]*)"""
                           r"""((?:\s+[\w:.-]+\s*=\s*(?:"[^"]*"|'[^']*'))*)"""
                           r"""\s*></\1>""")


def sort_tag(tag_match):
    name = tag_match.group(1)
    attrs = tag_match.group(2)
    slash = tag_match.group(3)
    pairs = ATTR_RE.findall(attrs)
    if len(pairs) < 2:
        return tag_match.group(0)
    ordered = sorted(pairs, key=lambda pair: pair[0])
    if ordered == pairs:
        return tag_match.group(0)
    rebuilt = "".join(" %s=%s" % (key, value) for key, value in ordered)
    return "<%s%s%s>" % (name, rebuilt, slash)


def fix_text(text):
    """Return (new_text, number_of_malformed_panels)."""
    malformed = 0

    def repl(match):
        nonlocal malformed
        panel = match.group(0)
        try:
            ET.fromstring(panel)
        except ET.ParseError:
            malformed += 1
            return panel
        panel = TAG_RE.sub(sort_tag, panel)
        return EMPTY_PAIR_RE.sub(lambda m: "<%s%s/>" % (m.group(1), m.group(2)),
                                 panel)

    return PANEL_RE.sub(repl, text), malformed


def iter_csd_files(paths):
    for path in paths:
        if os.path.isfile(path):
            if path.endswith(".csd"):
                yield path
            continue
        for dirpath, _dirs, files in os.walk(path):
            for name in files:
                if name.endswith(".csd"):
                    yield os.path.join(dirpath, name)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true",
                        help="report files needing changes, do not modify")
    parser.add_argument("paths", nargs="*", default=None,
                        help="files or directories to scan (default: examples)")
    args = parser.parse_args()

    paths = args.paths if args.paths else DEFAULT_PATHS

    scanned = 0
    changed = 0
    malformed = 0
    for path in sorted(iter_csd_files(paths)):
        with open(path, "r", encoding="utf-8") as handle:
            text = handle.read()
        scanned += 1
        fixed, bad = fix_text(text)
        malformed += bad
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

    print("%s %d file(s), %d changed, %d malformed panel(s) skipped." %
          ("Checked" if args.check else "Processed", scanned, changed, malformed))
    return 0


if __name__ == "__main__":
    sys.exit(main())
