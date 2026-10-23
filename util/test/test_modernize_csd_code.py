import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / "modernize_csd_code.py"
spec = importlib.util.spec_from_file_location("modernize_csd_code", SCRIPT)
modernize = importlib.util.module_from_spec(spec)
spec.loader.exec_module(modernize)


class ModernizeCodeTests(unittest.TestCase):
    def test_compound_assignments_are_not_split(self):
        cases = {
            "k+=1": "k += 1",
            "k *= 2": "k *= 2",
            "k-=1": "k -= 1",
            "k /= 2": "k /= 2",
            "k %= 2": "k %= 2",
            "k <<= 1": "k <<= 1",
            "k >>= 1": "k >>= 1",
            "k **= 2": "k **= 2",
            "k &&= 2": "k &&= 2",
            "k ||= 2": "k ||= 2",
        }
        for source, expected in cases.items():
            with self.subTest(source=source):
                self.assertEqual(modernize.normalize_code(source), expected)

    def test_ordinary_assignment_still_gets_spaces(self):
        self.assertEqual(modernize.normalize_code("kfreq=440"), "kfreq = 440")
        self.assertEqual(modernize.normalize_code("k = 440"), "k = 440")

    def test_assignments_are_aligned_only_for_small_length_gaps(self):
        def fixed(body):
            text = (
                "<CsoundSynthesizer>\n"
                "<CsInstruments>\n" + body +
                "</CsInstruments>\n"
                "<CsScore>\ne\n</CsScore>\n"
                "</CsoundSynthesizer>\n"
            )
            return modernize.fix_text(text)

        wide = fixed("k = 1\nkLong = 2\n")
        self.assertIn("k = 1\nkLong = 2", wide)

        close = fixed("kk = 1\nkkk = 2\nkkkk = 3\n")
        self.assertIn("kk   = 1\nkkk  = 2\nkkkk = 3", close)

    def test_option_values_are_left_alone(self):
        for source in ("--myoption=foo", "-+rtaudio=alsa",
                       "--env:FOO=bar", "--myoption=foo=bar"):
            with self.subTest(source=source):
                self.assertEqual(modernize.normalize_code(source), source)

    def test_long_trailing_comment_is_moved_above_and_wrapped(self):
        comment = "word " * 20
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "asig opcode 0.1, 0.5 ; " + comment.strip() + "\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text)
        lines = fixed.splitlines()
        code_pos = next(pos for pos, line in enumerate(lines)
                        if "asig opcode" in line)
        self.assertNotIn(";", lines[code_pos])
        self.assertGreaterEqual(code_pos, 2)  # wrapped above, not inline
        self.assertTrue(any("word" in line for line in lines[:code_pos]))

    def test_short_trailing_comment_stays_inline(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "asig opcode 0.1, 0.5 ; short comment\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text)
        self.assertIn("asig opcode 0.1, 0.5  ; short comment", fixed)

    def test_outs_is_written_as_out(self):
        cases = {
            "outs asig1, asig2": "out(asig1, asig2)",
            "outs(asig1, asig2)": "out(asig1, asig2)",
            "outs (asig1, asig2)": "out(asig1, asig2)",
        }
        for source, expected in cases.items():
            with self.subTest(source=source):
                self.assertEqual(
                    modernize.replace_outs_code(
                        modernize.normalize_code(source)), expected)

    def test_outs_replacement_preserves_trailing_comment(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "outs asig1, asig2 ; stereo output\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text)
        self.assertIn("out(asig1, asig2)  ; stereo output", fixed)

    def test_chnget_option_converts_invalue_and_outvalue(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "kval invalue \"freq\"\n"
            "outvalue \"freq\", kval\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text, chnget=True)
        self.assertIn('kval chnget "freq"', fixed)
        self.assertIn('chnset kval, "freq"', fixed)

    def test_chnget_option_uses_new_syntax(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "kval invalue \"freq\"\n"
            "outvalue \"freq\", kval\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text, chnget=True, new_syntax=True)
        self.assertIn('kval = chnget("freq")', fixed)
        self.assertIn('chnset(kval, "freq")', fixed)

    def test_chnget_option_keeps_outvalue_with_slash(self):
        code = modernize.normalize_code('outvalue "knob/color", kval')
        self.assertIsNone(modernize.replace_chnget_code(code, False))
        self.assertIsNone(modernize.replace_chnget_code(code, True))

    def test_chnget_is_opt_in(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "kval invalue \"freq\"\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        self.assertIn("invalue", modernize.fix_text(text))

    def test_multiline_comment_is_not_rewritten(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "/*\n"
            "outs a, b\n"
            "kval invalue \"freq\"\n"
            "outvalue \"slashed/chan\", kValue\n"
            "*/\n"
            "instr 1\n"
            "kval invalue \"freq\"\n"
            "endin\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text, chnget=True, new_syntax=True)
        self.assertIn('outs a, b\nkval invalue "freq"', fixed)
        self.assertIn('kval = chnget("freq")', fixed)

    def test_multiline_string_is_not_rewritten(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "instr 1\n"
            "S = {{\n"
            "outs a, b\n"
            "kval invalue \"freq\"\n"
            "outvalue \"slashed/chan\", kValue\n"
            "}}\n"
            "kval invalue \"freq\"\n"
            "endin\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text, chnget=True, new_syntax=True)
        self.assertIn('outs a, b\nkval invalue "freq"', fixed)
        self.assertIn('kval = chnget("freq")', fixed)

    def test_string_contents_are_not_rewritten(self):
        self.assertEqual(
            modernize.normalize_code('S="a  b"'), 'S = "a  b"')
        self.assertEqual(
            modernize.normalize_code('chnget("a  b")'),
            'chnget("a  b")')
        self.assertEqual(
            modernize.normalize_code('prints "outs a, b"'),
            'prints "outs a, b"')

    def test_line_comments_are_not_rewritten(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "instr 1\n"
            "kval invalue \"freq\" ; outs a, b\n"
            "// invalue \"other\"\n"
            "endin\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text, chnget=True, new_syntax=True)
        self.assertIn('kval = chnget("freq")  ; outs a, b', fixed)
        self.assertIn('// invalue "other"', fixed)

    def test_new_udos_converts_signature_and_removes_xin(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "opcode foo,kk,k\n"
            "  kvar1, kvar2 xin\n"
            "  xout kvar1, kvar2\n"
            "endop\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text, new_udos=True)
        self.assertIn("opcode foo(kvar1:k, kvar2:k):k", fixed)
        self.assertNotIn("xin", fixed)

    def test_new_udos_handles_arrays_and_no_output(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "opcode Foo, 0, i[]\n"
            "  arr:i[] xin\n"
            "endop\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text, new_udos=True)
        self.assertIn("opcode Foo(arr:i[]):()", fixed)
        self.assertNotIn("xin", fixed)

    def test_new_udos_is_opt_in(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsInstruments>\n"
            "opcode foo,k,kk\n"
            "  k1, k2 xin\n"
            "endop\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        self.assertIn("opcode foo, k, kk", modernize.fix_text(text))
        self.assertIn("opcode foo(k1:k, k2:k):k",
                      modernize.fix_text(text, new_udos=True))

    def test_new_syntax_converts_single_output_calls(self):
        arities = modernize.load_opcode_arities(modernize.OPCODES_XML)
        self.assertEqual(
            modernize.new_syntax_code(
                modernize.normalize_code("kFreq expon 100, 5, 1000"),
                {}, arities),
            "kFreq = expon(100, 5, 1000)")
        self.assertEqual(
            modernize.new_syntax_code(
                modernize.normalize_code("aOut oscili 0.2, kFreq, 1"),
                {}, arities),
            "aOut = oscili(0.2, kFreq, 1)")

    def test_new_syntax_leaves_multi_output_calls_alone(self):
        arities = modernize.load_opcode_arities(modernize.OPCODES_XML)
        self.assertIsNone(modernize.new_syntax_code(
            modernize.normalize_code("a1, a2 partikkel 1, 2"),
            {}, arities))

    def test_cs_options_region_is_untouched(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsOptions>\n"
            "--myoption=foo\n"
            "</CsOptions>\n"
            "<CsInstruments>\n"
            "k+=1\n"
            "</CsInstruments>\n"
            "</CsoundSynthesizer>\n"
        )
        fixed = modernize.fix_text(text)
        self.assertIn("--myoption=foo", fixed)
        self.assertIn("k += 1", fixed)
        self.assertNotIn("+ =", fixed)


if __name__ == "__main__":
    unittest.main()
