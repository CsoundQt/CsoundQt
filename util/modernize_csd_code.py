#!/usr/bin/env python3

# Modernize the Csound orchestra code inside .csd example files.
#
# Only lines strictly inside <CsInstruments>...</CsInstruments> are ever
# changed. Header prose, <CsOptions>, <CsScore>, every XML tag and
# everything after </CsoundSynthesizer> (widget panels etc.) is left
# byte-for-byte identical.
#
# Transformations applied to the code region:
#   0. Structural indentation, inside <CsInstruments>/<CsScore> only: the
#      level changes solely on flow-control keywords (instr/opcode/if/
#      then/else/elseif/endif/for/while/until/do/od/switch/endsw/endin/
#      endop). Any other line (rireturn, outs, ...) is rendered at the
#      current level, except `<label>:` lines, which go to column 0 like
#      instr/opcode. Header prose, <CsOptions> and XML tags keep
#      their existing indentation.
#   1. Tabs expanded: leading tabs become 2 spaces each, all other tabs
#      become a single space. Runs of spaces in code (outside string
#      literals) collapse to one; `,`, `=`, `==`, `!=`, `<=`, `>=` get
#      single surrounding spaces (`kast` arithmetic is left alone).
#   2. Comments that are (almost) entirely UPPERCASE become sentence case:
#      first letter (and first letter after `.`/`!`/`?`) uppercased, the rest
#      lowercased. Known acronyms (MIDI, GUI, LFO, FLTK, N.B.) keep their
#      capitals. Already mixed-case comments are left alone.
#   3. Consecutive lines of the form `<variable> <opcode> ...` sharing the
#      same opcode (second whitespace-separated token) get their variable
#      column padded so the opcodes line up. Control keywords (instr, if,
#      for, ...) never start a run.
#   4. A trailing comment that would push its line past ~90 columns is moved
#      above the code (wrapped to fit) instead.
#   5. Trailing `;` comments of consecutive commented code lines are aligned
#      in one column. If alignment would push a line past ~90 columns, that
#      comment is moved above instead (the ~90 limit wins over alignment).
#   6. Opt-in (--new-syntax): old-style single-output opcode calls
#      `kval opcode p1, p2` become `kval = opcode(p1, p2)` (array outputs
#      like `karr[] init 30` convert as well). Multi-output calls
#      (`a1, a2 opcode ...`, recognizable by the comma) and unknown
#      opcodes are left alone. Output arity comes from file-local
#      `opcode Name, outtypes, ...` definitions first, then src/opcodes.xml.
#   7. Opt-in (--ksmps N): set the orchestra header assignment to
#      `ksmps = N`, adding it after the `sr` line when missing.
#
# The script is idempotent: re-running it on a formatted file changes
# nothing.
#
# Usage: util/modernize_csd_code.py [--check] [--new-syntax]
#                                    [--ksmps N] [path ...]
#   --check      report files that would change, modify nothing
#   --new-syntax also rewrite single-output calls in functional syntax
#   --ksmps N    set `ksmps = N` in the orchestra header
#   path         file or directory to scan (default: McCurdy Collection)

import argparse
import os
import re
import sys
import xml.etree.ElementTree as ET

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_PATHS = [os.path.join(REPO_ROOT, "src", "Examples",
                              "McCurdy Collection")]
OPCODES_XML = os.path.join(REPO_ROOT, "src", "opcodes.xml")

LINE_LIMIT = 90
ACRONYMS = ["MIDI", "GUI", "LFO", "FLTK"]

# First tokens that never count as `<variable>` for rule 4.
SKIP_FIRST = {"instr", "endin", "opcode", "endop", "if", "then", "else",
              "endif", "elseif", "for", "od", "do", "while", "until",
              "switch", "case", "default", "endsw", "break", "continue",
              "return", "goto", "igoto", "kgoto"}

# Keywords that close one block level (counted per occurrence).
CLOSERS = {"endin", "endop", "endif", "od", "endsw"}
# Keywords rendered one level above the current one, without net change.
DEDENT_SELF = {"else", "elseif"}
# Keywords that open a fresh top-level block.
TOP_OPEN = {"instr", "opcode"}
# A label starting a line: `<name>:` followed by space or end of code
# (flow keywords excluded on use). The lookahead keeps Csound 7 typed
# identifiers such as `indxs:i[]` from matching.
LABEL_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*:(?=\s|$)")


def code_words(code):
    """Word tokens of code, ignoring double-quoted string literals."""
    chunks = re.split(r'("[^"]*")', code)
    return re.findall(r"[A-Za-z_][A-Za-z0-9_]*", " ".join(chunks[0::2]))


def nonstring_code(code):
    """Code with double-quoted string literals removed (for `=` checks)."""
    return "".join(re.split(r'("[^"]*")', code)[0::2])


def load_opcode_arities(path):
    """Map opcode name -> set of output arities (0, 1 and/or 'multi').

    Arity comes from each <synopsis>: the text before <opcodename> holds
    the outputs. A single type token (including array types like `k[]`)
    counts as one output; commas, spaces, `...` or brackets mark several.
    An empty output slot followed by `(args)` is a functional-form
    synopsis such as `cpsoct(oct)`, which returns one value.
    """
    arities = {}
    tree = ET.parse(path)
    for synopsis in tree.getroot().iter("synopsis"):
        opcodename = synopsis.find("opcodename")
        if opcodename is None or not (opcodename.text or "").strip():
            continue
        name = opcodename.text.strip()
        before, after, seen = [], [], False
        if synopsis.text:
            before.append(synopsis.text)
        for child in synopsis:
            target = after if seen else before
            if child.tag == "opcodename":
                seen = True
                if child.tail:
                    after.append(child.tail)
            else:
                target.append("".join(child.itertext()))
                if child.tail:
                    target.append(child.tail)
        before_text, after_text = "".join(before), "".join(after)
        outs = set()
        if before_text.strip() == "":
            outs.add(1 if after_text.lstrip().startswith("(") else 0)
        else:
            for alt in before_text.split("|"):
                alt = alt.strip()
                if alt == "":
                    outs.add(0)
                elif re.fullmatch(r"[A-Za-z]+\[\]", alt) \
                        or re.fullmatch(r"[A-Za-z]+", alt):
                    outs.add(1)
                else:
                    outs.add("multi")
        arities.setdefault(name, set()).update(outs)
    return arities


def collect_udo_arities(text):
    """Map UDO name -> output count from `opcode Name, outtypes, ...`."""
    found = {}
    for line in text.splitlines():
        match = re.match(r"\s*opcode\s+([A-Za-z_][A-Za-z0-9_]*)\s*,\s*"
                         r"([^,;]*?)\s*(?:,|;|$)", line)
        if not match:
            continue
        outtypes = re.sub(r"[\s\[\]]", "", match.group(2))
        if outtypes in ("", "0"):
            found[match.group(1)] = 0
        elif re.fullmatch(r"[A-Za-z]+", outtypes):
            found[match.group(1)] = len(outtypes)
        # else: unparseable outtypes -> unknown, do not record
    return found


CALL_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*(?:\[\])*)\s+"
                     r"([A-Za-z_][A-Za-z0-9_]*)\b(.*)$", re.S)


def strip_outer_parens(args):
    """Drop one redundant surrounding paren pair: `(a+b)` -> `a+b`."""
    text = args.strip()
    if len(text) < 2 or not text.startswith("(") \
            or not text.endswith(")"):
        return text
    depth, in_string, match = 0, False, -1
    for pos, char in enumerate(text):
        if char == '"':
            in_string = not in_string
        elif not in_string:
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    match = pos
                    break
    if match == len(text) - 1:
        return text[1:-1].strip()
    return text


def new_syntax_code(code, udo_arities, opcode_arities):
    """Rewrite `kval opcode p1, p2` as `kval = opcode(p1, p2)`.

    Return the converted code, or None when the line must be left alone:
    already new syntax (any `=` outside strings), a control keyword,
    a statement-form call (`outs ...`, decided via the arity tables),
    a multi-output call (`a1, a2 opcode ...`, which can never match
    CALL_RE because of the comma), or an unknown opcode.
    """
    match = CALL_RE.match(code)
    if not match:
        return None
    var, op, args = match.group(1), match.group(2), match.group(3).strip()
    if var in SKIP_FIRST or op in SKIP_FIRST:
        return None
    if "=" in nonstring_code(code):
        return None
    if var in udo_arities or (opcode_arities is not None
                              and var in opcode_arities):
        # `var` is really the opcode: statement-form call, no outputs.
        return None
    arity = udo_arities.get(op)
    if arity is None and opcode_arities is not None:
        known = opcode_arities.get(op)
        arity = 1 if known is not None and 1 in known else None
    if arity != 1:
        return None
    return "%s = %s(%s)" % (var, op, strip_outer_parens(args))


def reindent(records):
    """Rule 0: recompute indentation from block structure.

    Callers pass only <CsInstruments> body lines. The level changes solely
    on flow-control keywords (instr/opcode/if/then/else/elseif/endif/for/
    while/until/do/od/switch/endsw/endin/endop); every other line
    (rireturn, outs, ...) is rendered at the current level, except
    `<label>:` lines, which go to column 0 like instr/opcode. A trailing
    `\\` continues the statement: the next non-blank line gets one extra
    level.
    """
    level = 0
    extra = 0
    for record in records:
        if record["tag"] is not None:
            continue
        if not record["code"] and not record["comment"]:
            record["indent"] = ""
            continue
        words = code_words(record["code"]) if record["code"] else []
        first = words[0] if words else None
        label = None
        if record["code"]:
            match = LABEL_RE.match(record["code"])
            if match and match.group(1) not in SKIP_FIRST:
                # A `<label>:` line lives at column 0 like instr/opcode.
                # Only the statement after the colon (if any) can still
                # affect the level.
                label = match.group(1)
                words = code_words(record["code"][match.end():])
                first = words[0] if words else None
        if label is not None:
            render = 0
            nclose = sum(1 for word in words if word in CLOSERS)
            nopen = 0
            if "if" in words and "then" in words:
                nopen += 1
            for keyword in ("for", "while", "until"):
                if keyword in words and "do" in words:
                    nopen += 1
            if "switch" in words:
                nopen += 1
            level = max(0, level + nopen - nclose)
        elif first in TOP_OPEN:
            render = 0
            level = 1
        elif first in ("endin", "endop"):
            render = 0
            level = 0
        else:
            nclose = sum(1 for word in words if word in CLOSERS)
            nopen = 0
            if "if" in words and "then" in words:
                nopen += 1
            for keyword in ("for", "while", "until"):
                if keyword in words and "do" in words:
                    nopen += 1
            if "switch" in words:
                nopen += 1
            net = nopen - nclose
            if first in DEDENT_SELF:
                render = max(0, level - 1)
            else:
                render = max(0, level + min(0, net))
            level = max(0, level + net)
        record["indent"] = "  " * (render + extra)
        if record["code"] and record["code"].rstrip().endswith("\\"):
            extra = 1
        else:
            extra = 0

TAG_LINE_RE = re.compile(r"\s*<[^>]+>\s*$")


def split_comment(line):
    """Split line at the first `;` outside double quotes.

    Return (code, comment) where comment is None when there is no `;`.
    """
    in_string = False
    for pos, char in enumerate(line):
        if char == '"':
            in_string = not in_string
        elif char == ";" and not in_string:
            return line[:pos], line[pos + 1:]
    return line, None


def sentence_case(text):
    """Lowercase all-caps comment, then capitalize each sentence start."""
    lowered = text.strip().lower()
    for acronym in ACRONYMS:
        lowered = re.sub(r"\b%s\b" % re.escape(acronym.lower()),
                         acronym, lowered)
    lowered = lowered.replace("n.b.", "N.B.")
    chars = list(lowered)
    for pos, char in enumerate(chars):
        if char.isalpha():
            chars[pos] = char.upper()
            break
    result = "".join(chars)
    for mark in (".", "!", "?"):
        result = re.sub(re.escape(mark) + r"\s+([a-z])",
                        lambda m: m.group(0)[:-1] + m.group(0)[-1].upper(),
                        result)
    return result


def is_mostly_upper(text):
    letters = [char for char in text if char.isalpha()]
    if not letters:
        return False
    upper = sum(1 for char in letters if char.isupper())
    # Deliberately below 1.0: shouting comments often embed lowercase
    # identifiers ('Live Input', gkmode, (ktrigger)) that pull the ratio
    # down; anything over 0.6 reads as all-caps.
    return upper / len(letters) > 0.6


def normalize_code_segment(segment):
    segment = re.sub(r",\s*", ", ", segment)
    segment = re.sub(r"\s*==\s*", " == ", segment)
    segment = re.sub(r"\s*!=\s*", " != ", segment)
    segment = re.sub(r"\s*<=\s*", " <= ", segment)
    segment = re.sub(r"\s*>=\s*", " >= ", segment)
    segment = re.sub(r"(?<![=!<>])\s*=\s*(?!=)", " = ", segment)
    return re.sub(r" +", " ", segment).strip()


def normalize_code(code):
    """Collapse whitespace runs outside string literals to one space."""
    parts = re.split(r'("[^"]*")', code)
    for pos in range(0, len(parts), 2):
        parts[pos] = normalize_code_segment(parts[pos])
    joined = " ".join(part for part in parts if part != "")
    joined = re.sub(r" +", " ", joined).strip()
    joined = re.sub(r"\s+,", ",", joined)
    joined = re.sub(r"\(\s+", "(", joined)
    joined = re.sub(r"\s+\)", ")", joined)
    return joined


def tokens_outside_strings(code):
    chunks = re.split(r'("[^"]*")', code)
    return " ".join(chunks[0::2]).split()


def wrap_comment(comment, indent):
    """Wrap comment into `indent + '; ' + words` lines within LINE_LIMIT."""
    width = LINE_LIMIT - len(indent) - 2
    chunks = []
    current = ""
    for word in comment.split():
        if not current:
            current = word
        elif len(current) + 1 + len(word) <= width:
            current += " " + word
        else:
            chunks.append(current)
            current = word
    chunks.append(current)
    return [{"indent": indent, "code": "", "comment": chunk, "tag": None}
            for chunk in chunks]


def parse_region(lines):
    records = []
    for line in lines:
        if TAG_LINE_RE.match(line):
            records.append({"indent": "", "code": "", "comment": None,
                            "tag": line.rstrip()})
            continue
        indent = re.match(r"^[ \t]*", line).group(0).replace("\t", "  ")
        rest = line[len(re.match(r"^[ \t]*", line).group(0)):].replace(
            "\t", " ")
        code, comment = split_comment(rest)
        comment = comment.strip() if comment is not None else None
        record = {"indent": indent, "code": normalize_code(code),
                  "comment": comment if comment else None, "tag": None}
        if record["comment"] and is_mostly_upper(record["comment"]):
            record["comment"] = sentence_case(record["comment"])
        records.append(record)
    return records


def align_key(record):
    if record["tag"] is not None or not record["code"]:
        return None
    words = tokens_outside_strings(record["code"])
    if len(words) < 2 or words[0] in SKIP_FIRST:
        return None
    return words[1]


KSAMPS_RE = re.compile(r"^ksmps\s*=")
SR_RE = re.compile(r"^sr\s*=")


def apply_ksmps(records, value):
    """Rule 7: set the header assignment to `ksmps = <value>`.

    Existing assignments are replaced wholesale; when none exists, one is
    inserted right after the `sr` line (or first in the body). Callers pass
    only <CsInstruments> body lines.
    """
    replaced = False
    found_sr = None
    for pos, record in enumerate(records):
        if record["tag"] is not None or not record["code"]:
            continue
        if KSAMPS_RE.match(record["code"]):
            record["code"] = "ksmps = %d" % value
            replaced = True
        elif found_sr is None and SR_RE.match(record["code"]):
            found_sr = pos
    if replaced:
        return
    anchor = found_sr if found_sr is not None else -1
    indent = records[anchor]["indent"] if anchor >= 0 else ""
    records.insert(anchor + 1, {"indent": indent,
                                "code": "ksmps = %d" % value,
                                "comment": None, "tag": None})


def align_variable_columns(records):
    """Rule 3: pad the variable column within same-opcode runs."""
    pos = 0
    while pos < len(records):
        key = align_key(records[pos])
        if key is None:
            pos += 1
            continue
        end = pos
        while (end + 1 < len(records)
               and align_key(records[end + 1]) == key):
            end += 1
        if end > pos:
            width = max(len(tokens_outside_strings(records[m]["code"])[0])
                        for m in range(pos, end + 1))
            for m in range(pos, end + 1):
                first = tokens_outside_strings(records[m]["code"])[0]
                rest = records[m]["code"][
                    records[m]["code"].find(first) + len(first):].lstrip()
                records[m]["code"] = first.ljust(width) + " " + rest
        pos = end + 1


def align_trailing_comments(records):
    """Rule 5: align `;` within consecutive commented-code runs."""
    pos = 0
    while pos < len(records):
        if records[pos]["tag"] is None and records[pos]["code"] \
                and records[pos]["comment"]:
            end = pos
            while (end + 1 < len(records)
                   and records[end + 1]["tag"] is None
                   and records[end + 1]["code"]
                   and records[end + 1]["comment"]):
                end += 1
            if end > pos:
                column = max(len(records[m]["indent"] + records[m]["code"])
                             for m in range(pos, end + 1))
                for m in range(pos, end + 1):
                    missing = column - len(records[m]["indent"]
                                             + records[m]["code"])
                    records[m]["code"] += " " * missing
            pos = end + 1
        else:
            pos += 1


def rendered_length(record):
    # Measured with alignment padding intact: this is the length the line
    # will actually be rendered with, so alignment-induced overflow also
    # triggers rule 4 (the ~90 limit wins over alignment).
    return len(record["indent"] + record["code"]
                + "  ; " + record["comment"])


def move_overlong_comments(records):
    """Rule 4 (+ standalone wrapping): move comments past the limit above.

    Return True when anything moved.
    """
    moved = False
    output = []
    for record in records:
        if record["tag"] is not None:
            output.append(record)
            continue
        if record["code"] and record["comment"] \
                and rendered_length(record) > LINE_LIMIT:
            code = record["code"].rstrip()
            output.extend(wrap_comment(record["comment"], record["indent"]))
            output.append({"indent": record["indent"], "code": code,
                           "comment": None, "tag": None})
            moved = True
        elif not record["code"] and record["comment"] \
                and len(record["indent"] + "; " + record["comment"]) \
                > LINE_LIMIT:
            output.extend(wrap_comment(record["comment"], record["indent"]))
            moved = True
        else:
            output.append(record)
    records[:] = output
    return moved


def build_line(record):
    if record["tag"] is not None:
        return record["tag"]
    if record["code"] and record["comment"]:
        # NOTE: code is *not* rstripped here: align_trailing_comments
        # pads it with the spaces that put `;` in a shared column.
        return (record["indent"] + record["code"]
                + "  ; " + record["comment"]).rstrip()
    if record["code"]:
        return (record["indent"] + record["code"]).rstrip()
    if record["comment"]:
        return (record["indent"] + "; " + record["comment"]).rstrip()
    return ""


def fix_once(text, new_syntax=False, opcode_arities=None, ksmps=None):
    """A single modernization pass over the <CsInstruments> body.

    Everything outside <CsInstruments>...</CsInstruments> -- header prose,
    <CsOptions>, <CsScore>, all XML tags and the widget panels -- is left
    byte-for-byte identical.
    """
    lines = text.split("\n")
    start = next((pos for pos, line in enumerate(lines)
                  if line.strip() == "<CsInstruments>"), None)
    stop = next((pos for pos, line in enumerate(lines)
                 if line.strip() == "</CsInstruments>"), None)
    if start is None or stop is None or stop <= start:
        return text
    records = parse_region(lines[start + 1:stop])
    reindent(records)
    if ksmps is not None:
        apply_ksmps(records, ksmps)
    if new_syntax:
        udo_arities = collect_udo_arities(text)
        for record in records:
            if record["tag"] is None and record["code"]:
                converted = new_syntax_code(record["code"], udo_arities,
                                            opcode_arities)
                if converted is not None:
                    record["code"] = converted
    move_overlong_comments(records)
    align_variable_columns(records)
    for _ in range(10):
        for record in records:
            if record["tag"] is None and record["code"]:
                record["code"] = record["code"].rstrip()
        align_trailing_comments(records)
        if not move_overlong_comments(records):
            break
    for record in records:
        if record["tag"] is None and record["code"] \
                and not record["comment"]:
            record["code"] = record["code"].rstrip()
    new_body = [build_line(record) for record in records]
    return "\n".join(lines[:start + 1] + new_body + lines[stop:])


def fix_text(text, new_syntax=False, opcode_arities=None, ksmps=None):
    """Return the modernized file text (only the code region changes).

    Passes run until a fixpoint: moving a long comment above its line can
    split an alignment run, which changes padding on the next pass. Comment
    moves only ever go one way (trailing -> above), so this terminates.
    """
    for _ in range(10):
        fixed = fix_once(text, new_syntax=new_syntax,
                         opcode_arities=opcode_arities, ksmps=ksmps)
        if fixed == text:
            return fixed
        text = fixed
    return text


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
    parser.add_argument("--new-syntax", action="store_true",
                        help="also rewrite single-output calls "
                             "kval opcode ... as kval = opcode(...)")
    parser.add_argument("--ksmps", type=int, default=None, metavar="N",
                        help="set `ksmps = N` in the orchestra header")
    parser.add_argument("paths", nargs="*", default=None,
                        help="files or directories to scan "
                             "(default: McCurdy Collection)")
    args = parser.parse_args()

    if args.ksmps is not None and args.ksmps <= 0:
        parser.error("--ksmps needs a positive integer")

    paths = args.paths if args.paths else DEFAULT_PATHS

    opcode_arities = None
    if args.new_syntax:
        try:
            opcode_arities = load_opcode_arities(OPCODES_XML)
        except (OSError, ET.ParseError) as exc:
            print("error: cannot load %s: %s" % (OPCODES_XML, exc),
                  file=sys.stderr)
            return 1

    scanned = 0
    changed = 0
    for path in sorted(iter_csd_files(paths)):
        with open(path, "r", encoding="utf-8") as handle:
            text = handle.read()
        scanned += 1
        fixed = fix_text(text, new_syntax=args.new_syntax,
                         opcode_arities=opcode_arities, ksmps=args.ksmps)
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
