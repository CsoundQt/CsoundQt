#!/usr/bin/env python3
"""Tests for the .csd splitter (util/split-csd.py).

Run with:
    python3 -m unittest discover -s util/test -p 'test_*.py'
"""

import importlib.util
import io
import os
import tempfile
import unittest
from contextlib import redirect_stdout, redirect_stderr
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / "split-csd.py"
spec = importlib.util.spec_from_file_location("split_csd", SCRIPT)
split_csd = importlib.util.module_from_spec(spec)
spec.loader.exec_module(split_csd)

PANEL = (
    "<bsbPanel>\n"
    " <label>Widgets</label>\n"
    " <bsbObject type=\"BSBLabel\" version=\"2\">\n"
    "  <x>10</x>\n"
    " </bsbObject>\n"
    "</bsbPanel>\n"
)

CSD = (
    "<CsoundSynthesizer>\n"
    "<CsOptions>\n"
    "-dnm0\n"
    "--sample-rate=48000\n"
    "</CsOptions>\n"
    "<CsInstruments>\n"
    "sr = 48000\n"
    "instr 1\n"
    "  out(a1)\n"
    "endin\n"
    "</CsInstruments>\n"
    "<CsScore>\n"
    "i 1 0 1\n"
    "e\n"
    "</CsScore>\n"
    "</CsoundSynthesizer>\n"
    + PANEL +
    "<bsbPresets>\n"
    "</bsbPresets>\n"
)


class SplitCsdTests(unittest.TestCase):
    def test_orc_has_options_as_comments_then_instruments(self):
        orc, _sco, _widget, _missing = split_csd.split_text(CSD)
        self.assertEqual(
            orc,
            "; CsOptions:\n"
            "; -dnm0\n"
            "; --sample-rate=48000\n"
            "\n"
            "sr = 48000\n"
            "instr 1\n"
            "  out(a1)\n"
            "endin\n")

    def test_sco_is_only_the_score_body(self):
        _orc, sco, _widget, _missing = split_csd.split_text(CSD)
        self.assertEqual(sco, "i 1 0 1\ne\n")

    def test_widget_is_the_panel_including_its_tags(self):
        _orc, _sco, widget, _missing = split_csd.split_text(CSD)
        self.assertEqual(widget, PANEL)

    def test_other_parts_are_ignored(self):
        orc, sco, widget, _missing = split_csd.split_text(CSD)
        for text in (orc, sco):
            self.assertNotIn("bsbPanel", text)
            self.assertNotIn("bsbPresets", text)
            self.assertNotIn("CsoundSynthesizer", text)
        self.assertNotIn("bsbPresets", widget)

    def test_no_widget_file_without_a_panel(self):
        text = CSD.replace(PANEL, "")
        _orc, _sco, widget, _missing = split_csd.split_text(text)
        self.assertIsNone(widget)

    def test_empty_panel_produces_no_widget(self):
        cases = (
            "<bsbPanel></bsbPanel>\n",
            "<bsbPanel>\n   \n\t\n</bsbPanel>\n",
        )
        for panel in cases:
            with self.subTest(panel=panel):
                text = CSD.replace(PANEL, panel)
                _orc, _sco, widget, _missing = split_csd.split_text(text)
                self.assertIsNone(widget)

    def test_empty_options_add_no_comment_block(self):
        text = (
            "<CsoundSynthesizer>\n"
            "<CsOptions>\n"
            "</CsOptions>\n"
            "<CsInstruments>\ninstr 1\nendin\n</CsInstruments>\n"
            "<CsScore>\ne\n</CsScore>\n"
            "</CsoundSynthesizer>\n"
        )
        orc, sco, _widget, _missing = split_csd.split_text(text)
        self.assertEqual(orc, "instr 1\nendin\n")
        self.assertEqual(sco, "e\n")

    def test_missing_sections_produce_empty_files(self):
        text = "<CsoundSynthesizer>\n<CsOptions>\n-d\n</CsOptions>\n" \
               "</CsoundSynthesizer>\n"
        orc, sco, widget, missing = split_csd.split_text(text)
        self.assertEqual(orc, "; CsOptions:\n; -d\n")
        self.assertEqual(sco, "")
        self.assertIsNone(widget)
        self.assertEqual(sorted(missing), ["instruments", "score"])

    def test_crlf_line_endings_are_preserved(self):
        text = CSD.replace("\n", "\r\n")
        orc, sco, widget, _missing = split_csd.split_text(text)
        for output in (orc, sco, widget):
            self.assertNotIn("\n", output.replace("\r\n", ""))
        self.assertTrue(orc.startswith("; CsOptions:\r\n; -dnm0\r\n"))
        self.assertTrue(widget.startswith("<bsbPanel>\r\n"))

    def test_main_writes_orc_sco_and_widget_next_to_input(self):
        with tempfile.TemporaryDirectory() as tmp:
            csd = os.path.join(tmp, "demo.csd")
            Path(csd).write_text(CSD, encoding="utf-8")
            with redirect_stdout(io.StringIO()), \
                    redirect_stderr(io.StringIO()):
                status = split_csd.main([csd])
            self.assertEqual(status, 0)
            orc = Path(tmp, "demo.orc").read_text(encoding="utf-8")
            sco = Path(tmp, "demo.sco").read_text(encoding="utf-8")
            widget = Path(tmp, "demo.cswidget").read_text(encoding="utf-8")
            self.assertIn("; -dnm0\n", orc)
            self.assertIn("instr 1\n", orc)
            self.assertEqual(sco, "i 1 0 1\ne\n")
            self.assertEqual(widget, PANEL)

    def test_main_writes_no_widget_file_without_a_panel(self):
        with tempfile.TemporaryDirectory() as tmp:
            csd = os.path.join(tmp, "demo.csd")
            Path(csd).write_text(CSD.replace(PANEL, ""), encoding="utf-8")
            with redirect_stdout(io.StringIO()), \
                    redirect_stderr(io.StringIO()):
                status = split_csd.main([csd])
            self.assertEqual(status, 0)
            self.assertFalse(os.path.exists(os.path.join(tmp,
                                                         "demo.cswidget")))

    def test_main_honours_output_dir(self):
        with tempfile.TemporaryDirectory() as tmp:
            csd = os.path.join(tmp, "demo.csd")
            out = os.path.join(tmp, "out")
            Path(csd).write_text(CSD, encoding="utf-8")
            with redirect_stdout(io.StringIO()), \
                    redirect_stderr(io.StringIO()):
                status = split_csd.main(["-o", out, csd])
            self.assertEqual(status, 0)
            for suffix in ("orc", "sco", "cswidget"):
                self.assertTrue(os.path.isfile(
                    os.path.join(out, "demo." + suffix)))
            self.assertFalse(os.path.exists(os.path.join(tmp, "demo.orc")))


if __name__ == "__main__":
    unittest.main()
