import importlib.util
import sys
import unittest
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / "raw-regex-literals.py"
spec = importlib.util.spec_from_file_location("raw_regex_literals", SCRIPT)
raw_regex_literals = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = raw_regex_literals
spec.loader.exec_module(raw_regex_literals)


class RawRegexLiteralTests(unittest.TestCase):
    def test_single_line_regex_is_converted(self):
        source = 'static const QRegularExpression rx(u"\\\\bfoo\\\\s+(\\\\w+)"_s);\n'
        expected = 'static const QRegularExpression rx(uR"(\\bfoo\\s+(\\w+))"_s);\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_set_pattern_is_converted(self):
        converted, count = raw_regex_literals.convert(
            'rx.setPattern(u"\\\\d+"_s);\n')
        self.assertEqual(count, 1)
        self.assertEqual(converted, 'rx.setPattern(uR"(\\d+)"_s);\n')

    def test_plain_literal_is_converted(self):
        source = r'QRegularExpression rx("\\bfoo\\s+(\\w+)");' + "\n"
        expected = r'QRegularExpression rx(uR"(\bfoo\s+(\w+))"_s);' + "\n"
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_plain_literal_with_options_is_converted(self):
        source = (r'QRegularExpression rx("[a-z]", '
                  r'QRegularExpression::CaseInsensitiveOption);' + "\n")
        expected = (r'QRegularExpression rx(uR"([a-z])"_s, '
                    r'QRegularExpression::CaseInsensitiveOption);' + "\n")
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_plain_set_pattern_is_converted(self):
        source = r'rx.setPattern("\\d+");' + "\n"
        expected = r'rx.setPattern(uR"(\d+)"_s);' + "\n"
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_qstringliteral_wrapper_is_replaced(self):
        source = r'auto rx = QRegularExpression(QStringLiteral("\\d+"));' + "\n"
        expected = r'auto rx = QRegularExpression(uR"(\d+)"_s);' + "\n"
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_qstringliteral_wrapper_with_options_is_replaced(self):
        source = (r'QRegularExpression(QStringLiteral("[a-z]"), '
                  r'QRegularExpression::CaseInsensitiveOption);' + "\n")
        expected = (r'QRegularExpression(uR"([a-z])"_s, '
                    r'QRegularExpression::CaseInsensitiveOption);' + "\n")
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_other_wrapper_is_left_alone(self):
        source = r'QRegularExpression(QLatin1String("abc"));' + "\n"
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_plain_non_regex_literal_is_left_alone(self):
        source = 'QString s = "abc";\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_plain_multiline_regex_is_left_alone(self):
        source = (
            'QRegularExpression rx(\n'
            '    "\\\\bfoo"\n'
            '    "\\\\s+");\n'
        )
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_plain_adjacent_literals_are_left_alone(self):
        source = 'QRegularExpression rx("foo" "bar");\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_plain_literal_after_a_closed_regex_call_is_left_alone(self):
        source = 'QRegularExpression rx("a"); QString s = "b";\n'
        expected = 'QRegularExpression rx(uR"(a)"_s); QString s = "b";\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_unrelated_call_after_a_regex_declaration_is_left_alone(self):
        for source in (
            'QRegularExpression rx; QString s("b");\n',
            'QRegularExpression rx = makeRegex("b");\n',
        ):
            with self.subTest(source=source):
                converted, count = raw_regex_literals.convert(source)
                self.assertEqual(count, 0)
                self.assertEqual(converted, source)

    def test_qregexp_from_wildcard_is_converted(self):
        source = 'QRegularExpression::fromWildcard("[a-z]*");\n'
        expected = 'QRegularExpression::fromWildcard(uR"([a-z]*)"_s);\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_plain_invalid_regex_is_skipped_by_the_check(self):
        source = 'QRegularExpression rx("([");\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_raw_delimiter_is_added_when_needed(self):
        value = '\\)"'
        cpp_content = value.replace("\\", "\\\\").replace('"', '\\"')
        source = f'QRegularExpression rx(u"{cpp_content}"_s);\n'
        expected = 'QRegularExpression rx(uR"RX1(\\)")RX1"_s);\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        self.assertEqual(converted, expected)

    def test_multiline_regex_is_left_alone(self):
        source = (
            'static const QRegularExpression rx(\n'
            '    u"\\\\bfoo"\n'
            '    u"\\\\s+"_s);\n'
        )
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_adjacent_literals_are_left_alone(self):
        source = 'QRegularExpression rx(u"foo"_s u"bar");\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_non_regex_literal_is_left_alone(self):
        source = 'QString s = u"\\\\bfoo"_s;\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_literal_after_a_closed_regex_call_is_left_alone(self):
        source = 'QRegularExpression rx(u"a"); QString s = u"b"_s;\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_already_raw_literal_is_left_alone(self):
        source = 'QRegularExpression rx(uR"(\\\\d+)"_s);\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_literal_in_comment_or_string_is_left_alone(self):
        source = (
            '// QRegularExpression rx(u"\\\\d+"_s);\n'
            'QString s = "QRegularExpression rx(u\\"\\\\\\\\d+\\"_s)";\n'
        )
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_non_quoting_escape_is_left_alone(self):
        source = 'QRegularExpression rx(u"\\t"_s);\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_invalid_regex_is_skipped_by_the_check(self):
        source = 'QRegularExpression rx(u"(["_s);\n'
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 0)
        self.assertEqual(converted, source)

    def test_invalid_regex_can_be_converted_without_check(self):
        source = 'QRegularExpression rx(u"(["_s);\n'
        converted, count = raw_regex_literals.convert(source, check_regex=False)
        self.assertEqual(count, 1)
        self.assertEqual(converted, 'QRegularExpression rx(uR"(([)"_s);\n')

    def test_choose_delimiter(self):
        self.assertEqual(raw_regex_literals.choose_delimiter(r"\d+"), "")
        self.assertEqual(raw_regex_literals.choose_delimiter(r'foo)"bar'), "RX1")
        self.assertEqual(
            raw_regex_literals.choose_delimiter(r'foo)"bar)RX1"baz'), "RX2")

    def test_missing_string_literal_using_is_added(self):
        source = (
            '#include <QRegularExpression>\n'
            '\n'
            'QRegularExpression rx("a");\n'
        )
        converted, count = raw_regex_literals.convert(source)
        self.assertEqual(count, 1)
        updated = raw_regex_literals.add_string_literal_using(converted)
        self.assertIn("using namespace Qt::StringLiterals;", updated)

    def test_existing_string_literal_using_is_not_duplicated(self):
        source = (
            '#include <QRegularExpression>\n'
            '\n'
            'using namespace Qt::StringLiterals;\n'
            'QRegularExpression rx(uR"(a)"_s);\n'
        )
        self.assertEqual(raw_regex_literals.add_string_literal_using(source), source)

    def test_using_is_not_placed_inside_a_conditional(self):
        source = (
            '#include "a.h"\n'
            '\n'
            '#ifdef FOO\n'
            '#include "b.h"\n'
            '#endif\n'
            '\n'
            'void f();\n'
        )
        updated = raw_regex_literals.add_string_literal_using(source)
        self.assertLess(updated.index("using namespace Qt::StringLiterals;"),
                        updated.index("#ifdef FOO"))


if __name__ == "__main__":
    unittest.main()
