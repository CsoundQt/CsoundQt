#!/usr/bin/env python3

# Migrate old native sliders to the current flat slider style.
#
# The script applies the same flat-slider defaults that CsoundQt uses when
# creating a new slider, choosing the colour set from the widget panel's
# background colour:
#
#   light panel: fg #34393a, bg #f0f0f0, border #aebcd2,
#                fill #dfdfdf, ruler #aebcd2
#   dark panel:  fg #daeff3, bg #434343, border #a1a1a1,
#                fill #828282, ruler #a1a1a1
#
# Common defaults: border width 2, radius 3, fill mode, hidden ruler,
# thumb width 4, padding 0, roundness 2.
#
# Native sliders draw a fixed strip (20 px wide/high by default) centred in
# their widget rectangle. Flat sliders use the actual widget rectangle, so the
# script sets the cross-axis size to --slidersize and moves the widget to the
# centre of the old rectangle. Existing flat sliders are left untouched.
#
# The file is edited as text, not parsed as whole XML, because orchestra code
# may contain characters that are invalid in XML.
#
# Usage:
#   python3 util/dev/migrate-sliders.py [--slidersize N] file.csd

import argparse
import re
import sys
from pathlib import Path

DEFAULT_SLIDER_SIZE = 20

LIGHT_COLORS = {
    "foreground": "#34393a",
    "bgcolor": "#f0f0f0",
    "bordercolor": "#aebcd2",
    "fillcolor": "#dfdfdf",
    "rulercolor": "#aebcd2",
}
DARK_COLORS = {
    "foreground": "#daeff3",
    "bgcolor": "#434343",
    "bordercolor": "#a1a1a1",
    "fillcolor": "#828282",
    "rulercolor": "#a1a1a1",
}

SLIDER_RE = re.compile(
    r'(<bsbObject\b[^>]*type="(BSB[VH]?Slider)"[^>]*>)(.*?)(</bsbObject>)',
    re.DOTALL,
)
PANEL_RE = re.compile(r"<bsbPanel\b[^>]*>(.*?)</bsbPanel>", re.DOTALL)
PANEL_BG_RE = re.compile(r"<bgcolor\b[^>]*>(.*?)</bgcolor>", re.DOTALL)


def parse_color(text):
    hex_match = re.search(r"#[0-9a-fA-F]{6}", text)
    if hex_match:
        return hex_match.group(0).lower()
    components = {}
    for channel in ("r", "g", "b"):
        match = re.search(rf"<{channel}>\s*(\d+)\s*</{channel}>", text)
        if match is None:
            return None
        components[channel] = max(0, min(255, int(match.group(1))))
    return "#{:02x}{:02x}{:02x}".format(
        components["r"], components["g"], components["b"]
    )


def panel_background(text):
    panel = PANEL_RE.search(text)
    if panel is None:
        return None
    background = PANEL_BG_RE.search(panel.group(1))
    if background is None:
        return None
    return parse_color(background.group(1))


def is_light_color(color):
    if color is None or not re.fullmatch(r"#[0-9a-fA-F]{6}", color):
        return True
    r = int(color[1:3], 16)
    g = int(color[3:5], 16)
    b = int(color[5:7], 16)
    # QColor::lightness() is the HSL lightness, (max + min) / 2.
    return (max(r, g, b) + min(r, g, b)) // 2 > 128


def get_int(body, tag):
    match = re.search(rf"<{tag}>\s*(-?\d+)\s*</{tag}>", body)
    return int(match.group(1)) if match is not None else None


def set_int(body, tag, value):
    pattern = re.compile(rf"<{tag}>\s*-?\d+\s*</{tag}>")
    return pattern.sub(f"<{tag}>{value}</{tag}>", body, count=1)


def tag_pattern(tag):
    return re.compile(rf"<{tag}\b[^>]*(?:/>|>.*?</{tag}>)", re.DOTALL)


def set_or_insert(body, tag, value, missing):
    pattern = tag_pattern(tag)
    if pattern.search(body):
        return pattern.sub(f"<{tag}>{value}</{tag}>", body, count=1)
    missing.append((tag, value))
    return body


def child_indent(body):
    match = re.search(r"\n([ \t]+)<", body)
    return match.group(1) if match is not None else "  "


def append_tags(body, tags):
    if not tags:
        return body
    indent = child_indent(body)
    trailing = re.search(r"\s*$", body).group(0)
    core = body[:-len(trailing)] if trailing else body
    insertion = "".join(
        f"\n{indent}<{tag}>{value}</{tag}>" for tag, value in tags
    )
    return core + insertion + trailing


def slider_is_flat(body):
    match = re.search(r"<flatStyle>\s*(.*?)\s*</flatStyle>", body, re.DOTALL)
    if match is None:
        return False
    return match.group(1).strip().lower() in {"true", "1", "yes", "on"}


def fix_slider(match, colors, slider_size):
    opening, slider_type, body, closing = match.groups()
    if slider_is_flat(body):
        return match.group(0)

    width = get_int(body, "width")
    height = get_int(body, "height")
    x = get_int(body, "x")
    y = get_int(body, "y")

    horizontal = slider_type == "BSBHSlider"
    if slider_type == "BSBSlider" and width is not None and height is not None:
        horizontal = width > height

    if horizontal:
        if height is not None and y is not None:
            body = set_int(body, "height", slider_size)
            body = set_int(body, "y", y + (height - slider_size) // 2)
    else:
        if width is not None and x is not None:
            body = set_int(body, "width", slider_size)
            body = set_int(body, "x", x + (width - slider_size) // 2)

    missing = []
    body = set_or_insert(body, "flatStyle", "true", missing)
    for tag in ("bgcolor", "foreground", "fillcolor", "bordercolor",
                "rulercolor"):
        body = set_or_insert(body, tag, colors[tag], missing)
    body = set_or_insert(body, "borderWidth", "2", missing)
    body = set_or_insert(body, "borderRadius", "3", missing)
    body = set_or_insert(body, "thumbWidth", "4", missing)
    body = set_or_insert(body, "thumbPadding", "0", missing)
    body = set_or_insert(body, "thumbRadius", "2", missing)
    body = set_or_insert(body, "fillMode", "fill", missing)
    body = set_or_insert(body, "rulermode", "hide", missing)
    body = append_tags(body, missing)

    return opening + body + closing


def migrate_file(path, slider_size):
    with open(path, "r", encoding="utf-8", newline="") as handle:
        original = handle.read()

    panel = panel_background(original)
    colors = LIGHT_COLORS if is_light_color(panel) else DARK_COLORS

    changed = [0]

    def replace(match):
        fixed = fix_slider(match, colors, slider_size)
        if fixed != match.group(0):
            changed[0] += 1
        return fixed

    migrated = SLIDER_RE.sub(replace, original)
    if changed[0] == 0:
        return 0, panel

    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(migrated)
    return changed[0], panel


def positive_int(value):
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError("slider size must be at least 1")
    return number


def main():
    parser = argparse.ArgumentParser(
        description="Migrate native sliders in a .csd to the flat slider style."
    )
    parser.add_argument("--slidersize", type=positive_int, default=DEFAULT_SLIDER_SIZE,
                        metavar="N",
                        help="cross-axis size of the migrated slider (default: %(default)s)")
    parser.add_argument("file", type=Path, metavar="FILE.csd")
    args = parser.parse_args()

    try:
        count, panel = migrate_file(args.file, args.slidersize)
    except OSError as error:
        print(f"{args.file}: {error}", file=sys.stderr)
        return 1

    if count == 0:
        print(f"{args.file}: no non-flat sliders found.")
    else:
        tone = "light" if is_light_color(panel) else "dark"
        print(f"{args.file}: migrated {count} slider(s) using {tone}-panel colours.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
