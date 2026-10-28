#!/usr/bin/env python3
"""Tests for the opcodes.xml generator (util/opcodeparser7.py).

Run with:
    python3 -m unittest discover -s util/test -p 'test_*.py'
"""

import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / 'opcodeparser7.py'
spec = importlib.util.spec_from_file_location('opcodeparser7', SCRIPT)
opcodeparser7 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(opcodeparser7)

PAGE = '''<!--
id:{id}
category:{category}
{status}-->
# {heading}
{description}

## Syntax
=== "Modern"
    ``` csound-orc
{modern}
    ```

=== "Classic"
    ``` csound-orc
{classic}
    ```

### Initialization
'''


def make_page(heading, modern, classic='', description='Does something.',
              category='Signal Generators:Basic Oscillators', status='',
              identifier=None, path='oscili.md'):
    """A manual page like the ones in the manual repository."""
    text = PAGE.format(id=identifier or heading, category=category,
                       status=('status:' + status + '\n') if status else '',
                       heading=heading, description=description,
                       modern=modern, classic=classic)
    return opcodeparser7.read_page(_FakePath(path, text))


class _FakePath:
    """A path that carries its text, for read_page()."""

    def __init__(self, name, text):
        self.name = name
        self._text = text
        self.stem = name[:-3] if name.endswith('.md') else name

    def read_text(self, encoding='utf-8', errors='replace'):
        return self._text


class TestSyntaxSection(unittest.TestCase):
    def test_reads_the_modern_tab(self):
        page = make_page('oscili', 'ares = oscili(xamp, xcps)')
        self.assertEqual(page.syntax, ['ares = oscili(xamp, xcps)'])

    def test_falls_back_to_the_plain_block(self):
        text = ('<!--\nid:abs\ncategory:X\n-->\n# abs\nTakes the absolute value.\n'
                '\n## Syntax\n``` csound-orc\nabs(x)\n```\n')
        page = opcodeparser7.read_page(_FakePath('abs.md', text))
        self.assertEqual(page.syntax, ['abs(x)'])

    def test_joins_continued_lines(self):
        page = make_page('bamboo',
                          'ares = bamboo(kamp, idettack) \\\n      [, inum]')
        self.assertEqual(page.syntax,
                         ['ares = bamboo(kamp, idettack) [, inum]'])

    def test_stops_at_the_next_heading(self):
        text = ('<!--\nid:x\ncategory:X\n-->\n# x\nDesc.\n\n## Syntax\n'
                '``` csound-orc\nx = 1\n```\n\n## Legacy forms\n'
                '``` csound-orc\nnot syntax\n```\n')
        page = opcodeparser7.read_page(_FakePath('x.md', text))
        self.assertEqual(page.syntax, ['x = 1'])

    def test_ignores_other_code_languages(self):
        text = ('<!--\nid:x\ncategory:X\n-->\n# x\nDesc.\n\n## Syntax\n'
                '``` csound-sco\ni 1 0 1\n```\n')
        page = opcodeparser7.read_page(_FakePath('x.md', text))
        self.assertEqual(page.syntax, [])


class TestNameResolution(unittest.TestCase):
    def test_modern_call(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'ares = oscili(xamp, xcps)', ['oscili'])
        self.assertEqual(name, 'oscili')
        self.assertEqual(out_args, 'ares =')
        self.assertEqual(in_args, '(xamp, xcps)')

    def test_call_without_out_arguments(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'outall(asig)', ['outall'])
        self.assertEqual(name, 'outall')
        self.assertEqual(out_args, '')
        self.assertEqual(in_args, '(asig)')

    def test_classic_call_uses_the_page_name(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'ares oscili xamp, xcps', ['oscili'])
        self.assertEqual(name, 'oscili')
        self.assertEqual(out_args, 'ares')
        self.assertEqual(in_args, 'xamp, xcps')

    def test_operator_uses_the_symbol(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'a + b  (no rate restriction)', ['+', 'adds'])
        self.assertEqual(name, '+')
        self.assertEqual(out_args, 'a')
        self.assertEqual(in_args, 'b  (no rate restriction)')

    def test_a_name_is_not_matched_inside_a_word(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'kmax = max(ain1, ain2)', ['max'])
        self.assertEqual(name, 'max')
        self.assertEqual(out_args, 'kmax =')
        self.assertEqual(in_args, '(ain1, ain2)')

    def test_unresolved_line(self):
        self.assertIsNone(opcodeparser7.resolve('...', ['for']))

    def test_repeated_optional_groups_are_joined(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'ares = comb(asig, krvt, ilpt [, iskip] [, insmps])', ['comb'])
        self.assertEqual(in_args, '(asig, krvt, ilpt [,iskip, insmps])')

    def test_more_than_two_optional_groups_keep_joining(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'ares = vco2(kamp, kcps [, imode] [, kpw] [, kphs] [, inyx])',
            ['vco2'])
        self.assertEqual(in_args, '(kamp, kcps [,imode, kpw, kphs, inyx])')

    def test_optional_groups_already_in_one_group_are_kept(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'ares = oscili(xamp, xcps[, ifn, iphs])', ['oscili'])
        self.assertEqual(in_args, '(xamp, xcps[, ifn, iphs])')

    def test_nested_optional_groups_are_left_alone(self):
        name, out_args, in_args = opcodeparser7.resolve(
            'kres = x(kamp [, iatt [, idec]])', ['x'])
        self.assertEqual(in_args, '(kamp [, iatt [, idec]])')


class TestPage(unittest.TestCase):
    def test_front_matter(self):
        page = make_page('adsr', 'ares = adsr(iatt, idec)',
                         category='Signal Generators:Envelope Generators',
                         status='deprecated')
        self.assertEqual(page.category, 'Signal Generators:Envelope Generators')
        self.assertEqual(page.status, 'deprecated')

    def test_description_is_the_first_sentence(self):
        page = make_page('oscili', 'ares = oscili(xamp)',
                         description='A simple oscillator. It reads a table.')
        self.assertEqual(page.description, 'A simple oscillator.')

    def test_description_ignores_a_parenthesis(self):
        page = make_page('x', 'x = 1', description='Sets a value (e.g. 0.5).')
        self.assertEqual(page.description, 'Sets a value (e.g. 0.5).')

    def test_markup_is_removed(self):
        page = make_page('x', 'x = 1',
                         description='Uses _x_ and [the manual](https://x).')
        self.assertEqual(page.description, 'Uses x and the manual.')


class TestOpcodesOfPage(unittest.TestCase):
    def test_a_page_can_document_several_opcodes(self):
        page = make_page('chnget', 'ival = chnget(Sname)\n'
                                   'kval = chngetk(Sname)\n'
                                   'Sval = chngetks(Sname)')
        opcodes, unresolved = opcodeparser7.opcodes_of_page(page, {})
        self.assertEqual(sorted(op.name for op in opcodes),
                         ['chnget', 'chngetk', 'chngetks'])
        self.assertEqual(unresolved, [])
        for opcode in opcodes:
            self.assertEqual(len(opcode.synopsis), 1)
            self.assertEqual(opcode.description, page.description)

    def test_deprecated_pages_are_marked(self):
        page = make_page('adsr', 'ares = adsr(iatt)', status='deprecated')
        opcodes, _ = opcodeparser7.opcodes_of_page(page, {})
        self.assertTrue(opcodes[0].deprecated)

    def test_lines_without_an_opcode_are_reported(self):
        page = make_page('for', '...')
        opcodes, unresolved = opcodeparser7.opcodes_of_page(page, {})
        self.assertEqual(opcodes, [])
        self.assertEqual(len(unresolved), 1)


class TestXml(unittest.TestCase):
    def test_the_out_arguments_are_a_text_node(self):
        opcodes = [opcodeparser7.OpcodeDef(
            name='oscili', description='A simple oscillator.',
            synopsis=['ares =\x1foscili\x1f(xamp, xcps)'],
            category='Signal Generators:Basic Oscillators')]
        xml = opcodeparser7.render_xml(opcodes, ['Signal Generators:Basic Oscillators'])
        self.assertIn('<synopsis>ares =<opcodename>oscili</opcodename>(xamp, xcps)</synopsis>',
                      xml)

    def test_the_aliases_and_the_deprecated_flag(self):
        opcodes = [opcodeparser7.OpcodeDef(
            name='atsadd', description='Reads a file.',
            synopsis=['ar =\x1fatsadd\x1f(ktimepnt)'],
            category='Signal Generators:Basic Oscillators',
            deprecated=True, aliases=['ATSadd'])]
        xml = opcodeparser7.render_xml(opcodes, ['Signal Generators:Basic Oscillators'])
        self.assertIn('<opcode deprecated="true" aliases="ATSadd">', xml)

    def test_special_characters_are_escaped(self):
        opcodes = [opcodeparser7.OpcodeDef(
            name='x', description='a < b & c', synopsis=[],
            category='Cat')]
        xml = opcodeparser7.render_xml(opcodes, ['Cat'])
        self.assertIn('a &lt; b &amp; c', xml)

    def test_categories_not_in_the_manual_are_kept(self):
        opcodes = [opcodeparser7.OpcodeDef(name='x', description='d',
                                           synopsis=[], category='Other')]
        xml = opcodeparser7.render_xml(opcodes, ['Known'])
        self.assertIn('<category name="Other">', xml)


if __name__ == '__main__':
    unittest.main()
