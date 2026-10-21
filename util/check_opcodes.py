#!/usr/bin/env python3
"""Check that src/opcodes.xml is what CsoundQt reads from it.

The opcodes.xml is parsed by OpEntryParser::parseOpcodesXml(), which reads the
out-arguments from the text before the <opcodename> element and the
in-arguments from the text after it. This script mirrors that parser and
compares the result with a fresh extraction from the manual, so that a change
of the format cannot go unnoticed.

Usage:
    util/check_opcodes.py --manual ~/dev/forks/manual
    util/check_opcodes.py --manual ~/dev/forks/manual --opcodes src/opcodes.xml
"""

import argparse
import importlib.util
import json
import re
import sys
from pathlib import Path
from xml.dom import minidom

SCRIPT = Path(__file__).with_name('opcodeparser7.py')
spec = importlib.util.spec_from_file_location('opcodeparser7', SCRIPT)
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)

# The opcodes the parser leaves out, see OpEntryParser::parseOpcodesXml().
EXCLUDED = ['|', '||', '^', '+', '*', '-', '/']


def parse_like_csoundqt(path):
    """Read the opcodes.xml the way OpEntryParser does."""
    document = minidom.parse(str(path))
    categories = []
    opcodes = {}
    for category in document.getElementsByTagName('category'):
        name = category.getAttribute('name')
        entries = []
        for element in category.getElementsByTagName('opcode'):
            description = ''
            deprecated = element.getAttribute('deprecated') == 'true'
            aliases = [alias.strip()
                       for alias in element.getAttribute('aliases').split(',')
                       if alias.strip()]
            for child in element.childNodes:
                if child.nodeName == 'desc':
                    description = ''.join(node.data for node in child.childNodes
                                          if node.nodeType == node.TEXT_NODE).strip()
                elif child.nodeName == 'synopsis':
                    out_args, op_name, in_args = '', '', ''
                    for node in child.childNodes:
                        if node.nodeName == 'opcodename':
                            op_name = node.firstChild.data.strip() if node.firstChild else ''
                        elif node.nodeType == node.TEXT_NODE:
                            if op_name:
                                in_args = node.data.strip()
                            else:
                                out_args = node.data.strip()
                    if not op_name or op_name in EXCLUDED or name == 'Utilities':
                        continue
                    entries.append((op_name, out_args, in_args))
                    opcodes[op_name] = (out_args, in_args, description, deprecated)
                    for alias in aliases:
                        opcodes.setdefault(alias, (out_args, in_args, description, True))
        categories.append((name, entries))
    return categories, opcodes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manual', required=True,
                        help='the root of the manual repository')
    parser.add_argument('--opcodes', default=None,
                        help='the opcodes.xml to check')
    args = parser.parse_args()

    manual = Path(args.manual).expanduser()
    opcodes_file = Path(args.opcodes) if args.opcodes else \
        Path(__file__).parent.parent / 'src' / 'opcodes.xml'

    categories, parsed = parse_like_csoundqt(opcodes_file)

    legacy = {}
    legacy_file = Path(__file__).with_name('legacy_opcodes.json')
    if legacy_file.is_file():
        legacy = json.loads(legacy_file.read_text(encoding='utf-8'))

    opcodes, category_order, _ = generator.build(manual, legacy)

    extracted = {}
    for opcode in opcodes:
        if opcode.category == 'Utilities':
            continue
        for synopsis in opcode.synopsis:
            out_args, name, in_args = synopsis.split('\x1f')
            if name in EXCLUDED:
                continue
            extracted.setdefault(name, []).append((out_args, in_args))

    problems = []
    for name, signatures in extracted.items():
        if name not in parsed:
            problems.append(f'{name}: in the manual, not in the opcodes.xml')
            continue
        out_args, in_args = parsed[name][0], parsed[name][1]
        if (out_args, in_args) not in signatures:
            problems.append(f'{name}: the opcodes.xml has ({out_args!r}, {in_args!r}), '
                            f'the manual has {signatures}')
        if not parsed[name][2]:
            problems.append(f'{name}: no description')

    aliases = {alias for opcode in opcodes for alias in opcode.aliases}
    for name in parsed:
        if name not in extracted and name not in aliases:
            problems.append(f'{name}: in the opcodes.xml, not in the manual')

    xml_categories = [name for name, _ in categories]
    listed = [name for name in category_order if name in xml_categories]
    extra = [name for name in xml_categories if name not in listed]
    if xml_categories != listed + extra:
        problems.append('the categories are not in the order of the manual')

    print(f'{len(categories)} categories, {len(parsed)} opcode names')
    if problems:
        print(f'{len(problems)} problems:')
        for problem in problems:
            print('  ', problem)
        return 1
    print('the opcodes.xml matches the manual')
    return 0


if __name__ == '__main__':
    sys.exit(main())
