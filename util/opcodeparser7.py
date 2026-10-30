#!/usr/bin/env python3
"""Generate CsoundQt's opcodes.xml from the mkdocs based Csound manual.

The manual (https://github.com/csound/manual) documents every opcode in its own
markdown page under docs/opcodes. This script reads those pages and writes the
opcodes.xml that CsoundQt embeds as a resource (src/application.qrc) and parses
at startup (OpEntryParser::parseOpcodesXml).

The output format is fixed by that parser:

    <category name="Main:Sub">
    <opcode deprecated="true" aliases="OldName"><desc>text</desc>
    <synopsis>ares <opcodename>name</opcodename> xamp, xcps</synopsis>
    </opcode>
    </category>

The out-arguments are the text before the <opcodename> element, the
in-arguments the text after it; the parser reads those text nodes. The
in-arguments are stored as CsoundQt displays them: the manual's repeated
optional argument groups, "[, iskip] [, insmps]", are joined into one group,
"[,iskip, insmps]".

The category order and the symbol names of the operator pages come from the
manual itself (categories.py and diffopnames.py), so the manual stays the only
source of truth.

Usage:
    util/opcodeparser7.py --manual ~/dev/forks/manual --out src/opcodes.xml
    util/opcodeparser7.py --manual ~/dev/forks/manual --check
"""

import argparse
import html
import importlib.util
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from xml.sax.saxutils import escape

# The identifier of an opcode call: "oscili(" in "ares = oscili(xamp, xcps)".
# The parenthesis has to follow directly, so that the classic notation
# "a + b  (no rate restriction)" is not mistaken for a call.
CALL_RE = re.compile(r'([A-Za-z_][A-Za-z0-9_]*)\(')

# A name that is an ordinary word is matched on word boundaries, so that
# "max" does not match in "kmax = max(...)".
def name_pattern(name):
    pattern = re.escape(name)
    if name[:1].isalnum() or name[:1] == '_':
        pattern = r'(?<![\w])' + pattern
    if name[-1:].isalnum() or name[-1:] == '_':
        pattern = pattern + r'(?![\w])'
    return pattern


# The manual gives every optional argument its own group, which repeats the
# comma: "ilpt [, iskip] [, insmps]". Shown as one group it reads
# "ilpt [,iskip, insmps]" and means the same: either none of these arguments or
# all of them, in this order. Only adjacent groups are joined, so nested
# optional arguments are left as they are.
ADJACENT_OPTIONAL_GROUPS = re.compile(r'\[(\s*,[^\[\]]*)\]\s*\[\s*,([^\[\]]*)\]')


def merge_optional_groups(in_args):
    """Join the manual's repeated optional argument groups.

    The transformation is done here rather than in the application so that the
    opcodes.xml already holds the form CsoundQt shows.
    """
    while True:
        match = ADJACENT_OPTIONAL_GROUPS.search(in_args)
        if match is None:
            return in_args
        first = match.group(1)
        first_args = first[first.index(',') + 1:].strip()
        in_args = (in_args[:match.start()]
                   + '[,{}, {}]'.format(first_args, match.group(2).strip())
                   + in_args[match.end():])


def tidy_syntax(text):
    """Tighten the syntax text stored in opcodes.xml.

    The autocomplete menu shows these lines verbatim, so the typographic
    cleanup belongs in the generated data: a single ellipsis instead of three
    dots (common for unlimited argument lists), and no space directly after
    the opening bracket of an optional argument group.
    """
    return text.replace('...', '…').replace(' [, ', ' [,')


@dataclass
class OpcodeDef:
    """One opcode, as it is written in the manual."""
    name: str
    description: str
    synopsis: list = field(default_factory=list)
    category: str = ''
    deprecated: bool = False
    aliases: list = field(default_factory=list)

    def signature(self):
        """The synopsis lines with the opcode name marked, for the report."""
        return self.synopsis


@dataclass
class Page:
    """One manual page."""
    path: Path
    identifier: str = ''
    category: str = ''
    status: str = ''
    heading: str = ''
    description: str = ''
    syntax: list = field(default_factory=list)


def load_module(path, name):
    """Import a python file by path, without touching sys.path."""
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def read_front_matter(text):
    """The <!-- id: ... category: ... status: ... --> block at the top."""
    fields = {}
    end = text.find('-->')
    if end < 0:
        return fields
    for key in ('id', 'category', 'status'):
        match = re.search(rf'^{key}:\s*(.+)$', text[:end], re.M)
        if match:
            fields[key] = match.group(1).strip()
    return fields


def strip_markup(text):
    """Plain text from a markdown paragraph."""
    text = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', text)   # links
    text = re.sub(r'[*_`]+', '', text)                       # emphasis, code
    text = text.replace('\\|', '|')
    return ' '.join(text.split())


def first_sentence(text, start):
    """The first sentence of the paragraph, like the manual's own tooling.

    A dot inside parentheses does not end the sentence, and neither do the
    dots of an "i.e." or "e.g.".
    """
    body = text[start:]
    position = 0
    while True:
        dot = body.find('.', position)
        if dot < 0:
            return ''
        depth = body.count('(', 0, dot) - body.count(')', 0, dot)
        if depth > 0:
            position = dot + 1
            continue
        if body[dot - 1:dot + 3] in ('i.e.', 'e.g.'):
            position = dot + 3
            continue
        return body[:dot + 1]


def read_syntax(text):
    """The syntax lines of the '## Syntax' section.

    The modern notation is preferred; it is what Csound 7 writes. Lines
    continued with a backslash are joined.
    """
    section = re.search(r'^##\s+Syntax\s*$(.*?)(?=^#{1,6}\s|\Z)',
                        text, re.S | re.M)
    if not section:
        return []
    body = section.group(1)
    tab = re.search(r'===\s*"Modern"\s*$(.*?)(?=\n===\s*"|\Z)', body, re.S | re.M)
    if tab:
        body = tab.group(1)
    lines = []
    for block in re.findall(r'```\s*csound-orc\s*\n(.*?)```', body, re.S):
        continued = ''
        for raw in block.splitlines():
            line = raw.strip()
            if not line:
                continue
            if line.endswith('\\'):
                continued += line[:-1].strip() + ' '
                continue
            lines.append((continued + line).strip())
            continued = ''
        if continued:
            lines.append(continued.strip())
    return lines


def read_page(path):
    """Read one manual page."""
    text = path.read_text(encoding='utf-8', errors='replace')
    page = Page(path=path)
    front = read_front_matter(text)
    page.identifier = front.get('id', '')
    page.category = front.get('category', '')
    page.status = front.get('status', '')

    heading = re.search(r'^#\s+(.+)$', text, re.M)
    if heading:
        page.heading = html.unescape(heading.group(1).strip())
        sentence = first_sentence(text, heading.end())
        page.description = strip_markup(sentence)
    page.syntax = read_syntax(text)
    return page


def resolve(line, candidates):
    """Split a syntax line into (name, out-arguments, in-arguments).

    The name is the opcode that is called in the line; the candidates (the
    symbol of the page, its heading and its file name) are used for the pages
    whose syntax does not name an opcode.
    """
    call = CALL_RE.search(line)
    if call:
        name = call.group(1)
        return (name, tidy_syntax(line[:call.start(1)].strip()),
                tidy_syntax(merge_optional_groups(
                    line[call.end(1):].strip())))

    for candidate in candidates:
        if not candidate:
            continue
        match = re.search(name_pattern(candidate), line)
        if match:
            return (candidate, tidy_syntax(line[:match.start()].strip()),
                    tidy_syntax(merge_optional_groups(
                        line[match.end():].strip())))
    return None


def page_candidates(page, symbols):
    """The names a syntax line of this page may use."""
    candidates = []
    symbol = symbols.get(page.path.stem)
    if symbol:
        candidates.append(symbol)
    candidates.append(page.heading)
    candidates.append(page.path.stem)
    return candidates


def opcodes_of_page(page, symbols):
    """The opcodes a manual page documents.

    A page can document more than one opcode (the rate variants of a family
    such as chnget, chngetk and chngetks), so the opcodes are collected from
    the syntax lines, not from the page itself.
    """
    candidates = page_candidates(page, symbols)
    found = {}
    unresolved = []
    for line in page.syntax:
        resolved = resolve(line, candidates)
        if resolved is None:
            unresolved.append(line)
            continue
        name, out_args, in_args = resolved
        opcode = found.get(name)
        if opcode is None:
            opcode = OpcodeDef(name=name, description=page.description,
                               category=page.category,
                               deprecated=(page.status == 'deprecated'))
            found[name] = opcode
        opcode.synopsis.append(f'{out_args}\x1f{name}\x1f{in_args}')

    if not found and page.syntax:
        # A page whose syntax names no opcode at all: the control structures
        # (for, while, until) are not opcodes. Their lines are reported above.
        pass
    return list(found.values()), unresolved


def build(manual, legacy):
    """Read the manual and return the opcodes and a report."""
    symbols_module = load_module(manual / 'diffopnames.py', 'manual_diffopnames')
    categories_module = load_module(manual / 'categories.py', 'manual_categories')
    categories = list(categories_module.categories)
    symbols = dict(symbols_module.diff_opcnames)

    opcodes = []
    unknown_categories = []
    unresolved = []
    pages_without_syntax = []

    for path in sorted((manual / 'docs' / 'opcodes').glob('*.md')):
        page = read_page(path)
        if not page.syntax:
            pages_without_syntax.append(page)
            continue
        found, missing = opcodes_of_page(page, symbols)
        for line in missing:
            unresolved.append((page, line))
        for opcode in found:
            if opcode.category not in categories:
                unknown_categories.append(opcode.category)
            opcode.aliases = legacy.get(opcode.name, [])
            opcodes.append(opcode)

    report = {
        'opcodes': len(opcodes),
        'categories': len(categories),
        'unknown_categories': sorted(set(unknown_categories)),
        'pages_without_syntax': [page.path.name for page in pages_without_syntax],
        'unresolved': [(page.path.name, line) for page, line in unresolved],
    }
    return opcodes, categories, report


def render_xml(opcodes, categories):
    """The opcodes.xml, the categories in the order of the manual."""
    by_category = {}
    for opcode in opcodes:
        by_category.setdefault(opcode.category, []).append(opcode)

    order = list(categories)
    for category in sorted(by_category):
        if category not in order:
            order.append(category)

    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             "<!-- Don't modify this file. It is generated automatically by "
             "opcodeparser7.py\nThis file is distributed under the GNU Free "
             'Documentation Licence-->',
             '<opcodes>']
    for category in order:
        entries = by_category.get(category)
        if not entries:
            continue
        lines.append(f'<category name="{escape(category)}">')
        for opcode in entries:
            attributes = ''
            if opcode.deprecated:
                attributes += ' deprecated="true"'
            if opcode.aliases:
                attributes += ' aliases="%s"' % escape(','.join(opcode.aliases))
            lines.append(f'<opcode{attributes}><desc>{escape(opcode.description)}</desc>')
            for synopsis in opcode.synopsis:
                out_args, name, in_args = synopsis.split('\x1f')
                parts = []
                if out_args:
                    parts.append(escape(out_args))
                parts.append(f'<opcodename>{escape(name)}</opcodename>')
                if in_args:
                    parts.append(escape(in_args))
                lines.append('<synopsis>%s</synopsis>' % ''.join(parts))
            lines.append('</opcode>')
        lines.append('</category>')
    lines.append('</opcodes>')
    return '\n'.join(lines) + '\n'


def write_xml(opcodes, categories, out):
    """Write the opcodes.xml."""
    out.write_text(render_xml(opcodes, categories), encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manual', required=True,
                        help='the root of the manual repository')
    parser.add_argument('--out', default='src/opcodes.xml',
                        help='the opcodes.xml to write')
    parser.add_argument('--legacy', default=None,
                        help='the file with the legacy opcode names')
    parser.add_argument('--check', action='store_true',
                        help='only report whether the file is up to date')
    args = parser.parse_args()

    manual = Path(args.manual).expanduser()
    if not (manual / 'docs' / 'opcodes').is_dir():
        print(f'no opcode pages in {manual}', file=sys.stderr)
        return 2

    legacy = {}
    legacy_path = Path(args.legacy) if args.legacy else Path(__file__).with_name('legacy_opcodes.json')
    if legacy_path.is_file():
        legacy = json.loads(legacy_path.read_text(encoding='utf-8'))

    opcodes, categories, report = build(manual, legacy)

    out = Path(args.out)
    if args.check:
        current = out.read_text(encoding='utf-8') if out.is_file() else ''
        if render_xml(opcodes, categories) != current:
            print(f'{out} is not up to date', file=sys.stderr)
            return 1
        print(f'{out} is up to date')
        return 0

    write_xml(opcodes, categories, out)

    print(f'{len(opcodes)} opcodes in {len(categories)} categories written to {out}',
          file=sys.stderr)
    if report['unknown_categories']:
        print('categories not listed in the manual (placed at the end):',
              file=sys.stderr)
        for category in report['unknown_categories']:
            print(f'  {category}', file=sys.stderr)
    if report['pages_without_syntax']:
        print('pages without a syntax section (skipped):', file=sys.stderr)
        for name in report['pages_without_syntax']:
            print(f'  {name}', file=sys.stderr)
    if report['unresolved']:
        print('syntax lines without an opcode name (skipped):', file=sys.stderr)
        for name, line in report['unresolved']:
            print(f'  {name}: {line}', file=sys.stderr)
    return 0


if __name__ == '__main__':
    sys.exit(main())
