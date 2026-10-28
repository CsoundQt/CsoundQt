#!/usr/bin/env python3

# Split a .csd (Csound unified file) into a plain .orc orchestra, a .sco
# score and, when there is a widget panel, a .cswidget file, next to the
# input file.
#
# Only these parts are used:
#   <CsInstruments>  becomes the .orc body
#   <CsOptions>      is copied into the .orc as comments, at the top
#   <CsScore>        becomes the .sco body
#   <bsbPanel>       becomes the .cswidget file, including its tags
#
# Every other part of the .csd -- the header prose before the first tag, the
# closing tags, <bsbPresets>, <EventPanel> and anything after
# </CsoundSynthesizer> -- is ignored.
#
# The orchestra header (sr, ksmps, nchnls, 0dbfs, ...) lives inside
# <CsInstruments> in a .csd, so it ends up in the .orc as expected.
#
# Section bodies are copied verbatim apart from surrounding blank lines.
# The line endings of the input file are preserved, and so is UTF-8 text.
#
# Usage: util/split-csd.py [-o DIR] file.csd [file.csd ...]
#   -o DIR   write the output files into DIR instead of next to each input
#
# Missing <CsInstruments> or <CsScore> sections are reported and produce an
# empty file; an empty <CsOptions> adds no comment block. No .cswidget file
# is written unless a <bsbPanel> has something inside it.

import argparse
import os
import re
import sys

SECTION_RE = re.compile(
    r"<Cs(Instruments|Options|Score)\b[^>]*>(.*?)</Cs\1\s*>",
    re.IGNORECASE | re.DOTALL)
# A widget panel, with the tags; group 1 is its content.
PANEL_RE = re.compile(r"<bsbPanel\b[^>]*>(.*?)</bsbPanel\s*>",
                      re.IGNORECASE | re.DOTALL)


def extract_sections(text):
    """Map lower-case section name -> body. The first of each name wins."""
    sections = {}
    for match in SECTION_RE.finditer(text):
        sections.setdefault(match.group(1).lower(), match.group(2))
    return sections


def detect_newline(text):
    """Line ending used by the file; mixed files follow their first line."""
    return "\r\n" if "\r\n" in text else "\n"


def clean_body(body):
    """Section content without the blank lines around the tags."""
    return body.strip("\r\n")


def compose_orc(options, instruments, newline):
    """<CsInstruments> body, preceded by the <CsOptions> lines as comments."""
    lines = []
    option_lines = [line.strip() for line in options.splitlines()
                    if line.strip()]
    if option_lines:
        lines.append("; CsOptions:")
        lines.extend("; %s" % line for line in option_lines)
    body = clean_body(instruments)
    if body:
        if option_lines:
            lines.append("")
        lines.extend(body.splitlines())
    if not lines:
        return ""
    return newline.join(lines) + newline


def compose_sco(score, newline):
    """<CsScore> body, ready to be written to the .sco file."""
    body = clean_body(score)
    return body + newline if body else ""


def extract_panel(text):
    """First <bsbPanel>...</bsbPanel> block that is not empty, tags included."""
    for match in PANEL_RE.finditer(text):
        if match.group(1).strip():
            return match.group(0)
    return None


def split_text(text):
    """Return (orc, sco, widget, missing) for the text of one .csd file."""
    sections = extract_sections(text)
    newline = detect_newline(text)
    missing = [name for name in ("instruments", "score")
               if name not in sections]
    orc = compose_orc(sections.get("options", ""),
                      sections.get("instruments", ""), newline)
    sco = compose_sco(sections.get("score", ""), newline)
    panel = extract_panel(text)
    if panel is not None:
        panel = clean_body(panel) + newline
    return orc, sco, panel, missing


def output_paths(path, output_dir):
    base = os.path.splitext(os.path.basename(path))[0]
    directory = output_dir if output_dir else os.path.dirname(path)
    return (os.path.join(directory, base + ".orc"),
            os.path.join(directory, base + ".sco"),
            os.path.join(directory, base + ".cswidget"))


def write_file(path, text):
    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(text)


def main(argv=None):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-o", "--output-dir", metavar="DIR",
                        help="write the output files into DIR "
                             "(default: next to each input)")
    parser.add_argument("paths", nargs="+", metavar="CSD",
                        help=".csd file(s) to split")
    args = parser.parse_args(argv)

    if args.output_dir:
        os.makedirs(args.output_dir, exist_ok=True)

    status = 0
    for path in args.paths:
        try:
            with open(path, "r", encoding="utf-8-sig", newline="") as handle:
                text = handle.read()
        except OSError as error:
            print("%s: %s" % (path, error), file=sys.stderr)
            status = 1
            continue

        if not SECTION_RE.search(text):
            print("%s: no Csound sections found, not a .csd file?" % path,
                  file=sys.stderr)
            status = 1
            continue

        orc, sco, panel, missing = split_text(text)
        for name in missing:
            print("%s: warning: no <Cs%s> section, writing an empty file" %
                  (path, "Instruments" if name == "instruments" else "Score"),
                  file=sys.stderr)

        orc_path, sco_path, widget_path = output_paths(path, args.output_dir)
        write_file(orc_path, orc)
        write_file(sco_path, sco)
        written = [orc_path, sco_path]
        if panel is not None:
            write_file(widget_path, panel)
            written.append(widget_path)
        print("wrote %s" % ", ".join(written))

    return status


if __name__ == "__main__":
    sys.exit(main())
