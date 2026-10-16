#!/usr/bin/env python3

# Applies the example widget style modernization to CsoundQt .csd files.
# Only the <bsbPanel> widget section is touched; orchestra, score and all
# widget geometry, behaviour and text content are left byte-identical.
#
# The style (agreed from the hand-styled HarmonicAdditiveSynthesis1):
#   1. Panel background          -> neutral #efefef (239,239,239)
#   2. Text buttons (event/value)-> flat style, fixed lavender palette:
#        background #cbceff, pressed #9a9cc1, border #9a9cc1 (= pressed),
#        text #202020, pressed-text unset, borderWidth 2, borderRadius 5
#      (pictorial buttons are always native-rendered: left alone)
#   3. Label/display text        -> #202020, except long paragraphs
#      (>= LONG_TEXT_CHARS) which get #414141
#   4. Dark functional backgrounds (slider troughs etc.) -> #343434
#   5. Hard white anywhere       -> #e0e0e0
#   6. Visible framed label/display borders keep width/radius,
#      border colour becomes #9e9e9e
#   7. Nothing else is touched: no serializer tags (widgetName/enabled/
#      padding/locked/...) are added, no geometry, MIDI, values, event
#      lines, fonts or text edits.
#   8. Button labels are stripped: no leading/trailing spaces on the text
#      (each line of multi-line labels). Inner spacing is preserved.
#   9. Saturation cap (configurable --max-saturation, default 200 on the
#      0-255 HSV saturation scale): colours more saturated than that are
#      desaturated in HSV (hue and value kept, so pastels are unaffected),
#      then scaled darker to move luminosity back toward the original.
#      The darkening is capped (configurable --max-darken, default 10%)
#      so vivid colours are muted but never dulled aggressively.
#      Greys and the already-muted palette above are unaffected.
#
# Usage: util/modernize_example_style.py [--dry-run] [--check] <file.csd|dir>...
#   --dry-run  report what would change, change nothing
#   --check    like --dry-run but exit 1 when a file needs changes
#
# The transformation is idempotent: re-running changes nothing.

import argparse
import colorsys
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

BLACK = "<r>0</r>\n   <g>0</g>\n   <b>0</b>"
WHITE = "<r>255</r>\n   <g>255</g>\n   <b>255</b>"
T32 = "<r>32</r>\n   <g>32</g>\n   <b>32</b>"      # #202020 text
T52 = "<r>52</r>\n   <g>52</g>\n   <b>52</b>"      # #343434 dark backgrounds
T65 = "<r>65</r>\n   <g>65</g>\n   <b>65</b>"      # #414141 body copy
T224 = "<r>224</r>\n   <g>224</g>\n   <b>224</b>"  # #e0e0e0 softened white
T158 = "<r>158</r>\n   <g>158</g>\n   <b>158</b>"  # #9e9e9e frame borders
LONG_TEXT_CHARS = 300  # label/display text at/above this is body copy (#414141)

FLAT_BUTTON = """  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
"""

DEFAULT_MAX_SATURATION = 200  # on the 0-255 (HSV) saturation scale


def luma(rgb):
    """Perceived-brightness proxy (Rec.601 luma), 0..1."""
    r, g, b = rgb
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255.0


def desaturate(rgb, max_sat, max_dark_pct=10.0):
    """Cap HSV saturation at max_sat (0-255), muting the darkening.

    Returns None when the colour is already compliant (or achromatic).
    Otherwise desaturates in HSV keeping hue/value (so pastels, which
    have low HSV saturation, are untouched), then scales the result
    darker toward the original luminosity -- but never by more than
    max_dark_pct percent, so the colour is muted, not dulled.
    """
    if max(rgb) == min(rgb):
        return None  # achromatic: saturation is already 0
    h, s, v = colorsys.rgb_to_hsv(*(c / 255.0 for c in rgb))
    if s * 255.0 <= max_sat + 1e-9:
        return None
    r, g, b = colorsys.hsv_to_rgb(h, max_sat / 255.0, v)
    cand = [r * 255.0, g * 255.0, b * 255.0]
    luma0, luma1 = luma(rgb), luma(cand)
    if luma1 > luma0:
        f = max(luma0 / luma1, 1.0 - max_dark_pct / 100.0)
        cand = [c * f for c in cand]
    out = [min(255, max(0, int(round(c)))) for c in cand]
    # Int rounding can nudge saturation back over the cap; force compliance
    # so the transformation stays idempotent.
    guard = 0
    while max(out) != min(out):
        _, s_out, _ = colorsys.rgb_to_hsv(*(c / 255.0 for c in out))
        if s_out * 255.0 <= max_sat + 1e-9 or guard > 64:
            break
        out[out.index(max(out))] -= 1
        guard += 1
    return tuple(out) if tuple(out) != tuple(rgb) else None


HEX_COLOR_RE = re.compile(r"#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b")
HEX_TAGS = ("pressedColor", "borderColor", "textColor",
            "pressedTextColor", "textcolor")


def _expand_hex(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def desaturate_panel(panel, max_sat, stats, max_dark_pct=10.0):
    """Rule 9: cap saturation of every widget colour (triplets and hex)."""
    def triple_repl(m):
        tag = m.group(1)
        old = (int(m.group(3)), int(m.group(4)), int(m.group(5)))
        new = desaturate(old, max_sat, max_dark_pct)
        if new is None:
            return m.group(0)
        stats["desat"] += 1
        mode = m.group(2) or ""
        return "<%s%s>\n   <r>%d</r>\n   <g>%d</g>\n   <b>%d</b>" % ((tag, mode) + new)

    panel = re.sub(
        r"<(color|bgcolor|textcolor|cursorcolor|bordercolor)( mode=\"[^\"]*\")?>\n"
        r"   <r>(\d+)</r>\n   <g>(\d+)</g>\n   <b>(\d+)</b>",
        triple_repl, panel)

    # Hex colours live in single-line tags such as
    # <borderColor>#512900</borderColor>.
    def tag_repl(m):
        tag, val = m.group(1), m.group(2)
        hm = HEX_COLOR_RE.fullmatch(val.strip())
        if hm is None:
            return m.group(0)
        new = desaturate(_expand_hex(hm.group(0)), max_sat, max_dark_pct)
        if new is None:
            return m.group(0)
        stats["desat"] += 1
        return "<%s>#%02x%02x%02x</%s>" % ((tag,) + new + (tag,))
    panel = re.sub(r"<(%s)>(.*?)</\1>" % "|".join(HEX_TAGS), tag_repl, panel)
    return panel

PANEL_RE = re.compile(r"<bsbPanel>.*</bsbPanel>", re.DOTALL)
OBJECT_RE = re.compile(r'<bsbObject type="(\w+)".*?</bsbObject>', re.DOTALL)
PANEL_BG_RE = re.compile(
    r'(?P<ind> *)<bgcolor mode="background">\n'
    r"(?P=ind)  <r>\d+</r>\n(?P=ind)  <g>\d+</g>\n(?P=ind)  <b>\d+</b>\n(?P=ind) </bgcolor>")


def _panel_bg_new(m):
    i = m.group("ind")
    return ("%s<bgcolor mode=\"background\">\n"
            "%s  <r>239</r>\n%s  <g>239</g>\n%s  <b>239</b>\n%s </bgcolor>" % (i, i, i, i, i))


def label_text_len(block):
    m = re.search(r"<label>(.*?)</label>", block, re.DOTALL)
    return len(m.group(1)) if m else 0


def _sub_color(block, tag, old, new):
    return block.replace("<%s>\n   %s" % (tag, old), "<%s>\n   %s" % (tag, new))


def style_label_display(block, stats):
    """Rules 3, 5 (text) + background part of 4 + rule 6 (frames)."""
    tier = T65 if label_text_len(block) >= LONG_TEXT_CHARS else T32
    if tier is T65:
        stats["longtext"] += 1
    block = block.replace("<color>\n   " + BLACK, "<color>\n   " + tier)
    block = block.replace("<color>\n   " + WHITE, "<color>\n   " + T224)
    for mode in ("background", "nobackground", None):
        open_tag = "<bgcolor%s>" % ((' mode="%s"' % mode) if mode else "")
        block = block.replace(open_tag + "\n   " + BLACK, open_tag + "\n   " + T52)
        block = block.replace(open_tag + "\n   " + WHITE, open_tag + "\n   " + T224)
    bw = re.search(r"<borderwidth>(\d+)</borderwidth>", block)
    bm = re.search(r"<bordermode>(.*?)</bordermode>", block)
    if bm and bm.group(1) in ("border", "true") and bw and int(bw.group(1)) > 0:
        stats["framed"] += 1
        if "<bordercolor>" not in block:
            block = block.replace("  " + bm.group(0),
                                  "  <bordercolor>\n   " + T158 + "\n  </bordercolor>\n"
                                  "  " + bm.group(0))
        else:
            block = block.replace("<bordercolor>\n   " + BLACK,
                                  "<bordercolor>\n   " + T158)
    return block


def style_button(block, stats, notes, name):
    """Rules 2 (flat style) and 8 (strip label). Returns (block, changed)."""
    m = re.search(r"<text>(.*?)</text>", block, re.DOTALL)
    if m:
        stripped = "\n".join(ln.strip() for ln in m.group(1).split("\n"))
        if stripped != m.group(1):
            block = block[:m.start(1)] + stripped + block[m.end(1):]
            stats["stripped"] += 1
    if "<flatStyle>" in block:
        return block, False
    btype = re.search(r"<type>(.*?)</type>", block)
    btype = btype.group(1) if btype else "?"
    if btype not in ("event", "value"):
        notes.append("%s: non-text button type %r left alone" % (name, btype))
        return block, False
    anchor = re.search(r"  <fontsize>.*?</fontsize>\n", block)
    if anchor is None:
        anchor = re.search(r"  <latched>.*?</latched>\n", block)
    if anchor is None:
        notes.append("%s: button has no fontsize/latched anchor, left alone" % name)
        return block, False
    stats["buttons"] += 1
    return block.replace(anchor.group(0), anchor.group(0) + FLAT_BUTTON), True


def style_generic(block):
    """Rules 4/5 for all other widget types (knobs, sliders, spinboxes...)."""
    block = re.sub(r"<(color|textcolor|cursorcolor)>\n   " + re.escape(BLACK),
                   r"<\1>\n   " + T32, block)
    block = re.sub(r"<(color|textcolor|cursorcolor)>\n   " + re.escape(WHITE),
                   r"<\1>\n   " + T224, block)
    block = re.sub(r"<bgcolor( mode=\"(?:background|nobackground)\")?>\n   " + re.escape(BLACK),
                   lambda m: "<bgcolor" + (m.group(1) or "") + ">\n   " + T52, block)
    block = re.sub(r"<bgcolor( mode=\"(?:background|nobackground)\")?>\n   " + re.escape(WHITE),
                   lambda m: "<bgcolor" + (m.group(1) or "") + ">\n   " + T224, block)
    return block


def style_panel(panel, stats, notes, name, max_sat=DEFAULT_MAX_SATURATION,
                max_dark_pct=10.0):
    """Apply the style rules to a <bsbPanel>...</bsbPanel> string."""
    panel, n = PANEL_BG_RE.subn(_panel_bg_new, panel, count=1)
    if n:
        stats["panel"] += 1
    parts, pos = [], 0
    for mo in OBJECT_RE.finditer(panel):
        parts.append(panel[pos:mo.start()])
        typ, blk = mo.group(1), mo.group(0)
        before = blk
        if typ in ("BSBLabel", "BSBDisplay"):
            blk = style_label_display(blk, stats)
        elif typ == "BSBButton":
            blk, _ = style_button(blk, stats, notes, name)
        else:
            blk = style_generic(blk)
        if blk != before:
            stats["objects"] += 1
        parts.append(blk)
        pos = mo.end()
    parts.append(panel[pos:])
    panel = "".join(parts)
    return desaturate_panel(panel, max_sat, stats, max_dark_pct)


def hard_triplets_left(panel):
    """Hard black/white triplets still in colour/background regions."""
    return re.findall(
        r"<(?:color|bgcolor|textcolor|cursorcolor)[^>]*>\n"
        r"   <r>(?:0|255)</r>\s*<g>(?:0|255)</g>\s*<b>(?:0|255)</b>", panel)


def process_file(path, dry_run=False, max_sat=DEFAULT_MAX_SATURATION,
                 max_dark_pct=10.0):
    stats = {"panel": 0, "objects": 0, "buttons": 0, "longtext": 0,
             "framed": 0, "stripped": 0, "desat": 0}
    notes = []
    text = path.read_text(encoding="utf-8")
    m = PANEL_RE.search(text)
    if not m:
        return stats, ["%s: no <bsbPanel>, skipped" % path], False
    new_panel = style_panel(m.group(0), stats, notes, str(path),
                          max_sat, max_dark_pct)
    changed = new_panel != m.group(0)
    if changed and not dry_run:
        path.write_text(text[:m.start()] + new_panel + text[m.end():], encoding="utf-8")
    if changed:
        root = ET.fromstring(new_panel)
        leftover = hard_triplets_left(new_panel)
        if leftover:
            notes.append("%s: %d hard triplets remain" % (path, len(leftover)))
    return stats, notes, changed


def collect(paths):
    files = []
    for p in paths:
        p = Path(p)
        if p.is_dir():
            files.extend(sorted(p.rglob("*.csd")))
        else:
            files.append(p)
    return files


def main():
    ap = argparse.ArgumentParser(
        description="Apply the example widget style modernization to .csd files.")
    ap.add_argument("paths", nargs="+", help=".csd file(s) or directorie(s, recursive)")
    ap.add_argument("--dry-run", action="store_true",
                    help="report what would change, change nothing")
    ap.add_argument("--check", action="store_true",
                    help="like --dry-run but exit 1 when a file needs changes")
    ap.add_argument("--max-saturation", type=int, default=DEFAULT_MAX_SATURATION,
                    metavar="0-255",
                    help="cap widget colour saturation (HSV scale, default %d)"
                    % DEFAULT_MAX_SATURATION)
    ap.add_argument("--max-darken", type=float, default=10.0, metavar="PCT",
                    help="darkening the saturation cap may add, at most "
                    "(default 10%%; 100 restores exact luminosity)")
    args = ap.parse_args()
    if not 0 <= args.max_saturation <= 255:
        ap.error("--max-saturation must be 0-255")
    if not 0 <= args.max_darken <= 100:
        ap.error("--max-darken must be 0-100")
    if args.check:
        args.dry_run = True
    needy = 0
    for path in collect(args.paths):
        if not path.exists():
            print("%s: ERROR no such file or directory, skipped" % path)
            needy += 1
            continue
        try:
            stats, notes, changed = process_file(
                path, dry_run=args.dry_run, max_sat=args.max_saturation,
                max_dark_pct=args.max_darken)
        except (AssertionError, OSError, ET.ParseError) as exc:
            print("%s: ERROR %s" % (path, exc))
            needy += 1
            continue
        flag = "NEEDS-STYLE" if changed else "ok"
        if changed:
            needy += 1
        print("%s: %s (buttons=%d stripped=%d longtext=%d framed=%d widgets=%d desat=%d)" % (
            path, flag, stats["buttons"], stats["stripped"], stats["longtext"],
            stats["framed"], stats["objects"], stats["desat"]))
        for note in notes:
            print("   note: %s" % note)
    if args.check and needy:
        sys.exit(1)


if __name__ == "__main__":
    main()
