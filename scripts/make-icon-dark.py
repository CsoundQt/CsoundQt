#!/usr/bin/env python3
"""Create the dark-theme variant of a bundled icon.

The CsoundQt icon themes live in src/themes/breeze (light) and
src/themes/breeze-dark (dark). Both use the same file names and geometry; only
the drawing colour differs. This script copies an SVG from the light theme and
turns its dark foreground colour into white, leaving bright accent colours
(red, blue, ...) and Inkscape metadata untouched.

Usage:
    # Convert one icon into src/themes/breeze-dark/ (default for breeze files)
    scripts/make-icon-dark.py src/themes/breeze/media-play.svg

    # Convert a whole theme folder (skips Inkscape *~.svg backups)
    scripts/make-icon-dark.py src/themes/breeze

    # Explicit output file / colour
    scripts/make-icon-dark.py icon.svg --out /tmp/icon-dark.svg --color '#eff0f1'

Only the actual drawing colours are rewritten: fill, stroke, stop-color and the
CSS `color` used by `fill="currentColor"`. Any colour whose brightest channel is
at most --threshold (default 0x80) is considered "dark foreground" and replaced.
If the drawing relies on SVG's default black fill (paths without a fill), a
white fill is put on the root <svg> element so those shapes turn light as well.
"""

import argparse
import os
import re
import sys

# Properties that carry a visible colour. Both attribute syntax
# (fill="#000000") and inline/CSS syntax (fill:#000000) are handled.
COLOR_PROPERTY_RE = re.compile(
    r'(?P<prefix>\b(?:fill|stroke|stop-color|color)\s*[:=]\s*["\']?)'
    r'(?P<color>#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b|\bblack\b)',
    re.IGNORECASE,
)


def parse_color(value):
    """Return (r, g, b) for #rgb, #rrggbb or 'black', else None."""
    v = value.lower()
    if v == "black":
        return (0, 0, 0)
    if not v.startswith("#"):
        return None
    digits = v[1:]
    if len(digits) == 3:
        digits = "".join(c * 2 for c in digits)
    if len(digits) != 6:
        return None
    try:
        return (int(digits[0:2], 16), int(digits[2:4], 16), int(digits[4:6], 16))
    except ValueError:
        return None


def make_dark(svg, target, threshold):
    """Replace dark drawing colours in `svg` (text) with `target`."""
    replaced = 0

    def substitute(match):
        nonlocal replaced
        rgb = parse_color(match.group("color"))
        if rgb is None:
            return match.group(0)
        if max(rgb) > threshold:
            return match.group(0)          # bright enough: keep (accent colour)
        replaced += 1
        return match.group("prefix") + target

    result = COLOR_PROPERTY_RE.sub(substitute, svg)

    # Some SVGs rely on SVG's default fill (black) for paths without an
    # explicit fill, e.g. when only a CSS class exists but is not applied. Give
    # the root element the target fill so those shapes become light too.
    root = re.search(r'<svg\b[^>]*>', result, re.IGNORECASE)
    if root is not None:
        tag = root.group(0)
        if not re.search(r'\bfill\s*=', tag, re.IGNORECASE):
            if tag.endswith("/>"):
                new_tag = tag[:-2] + f' fill="{target}"/>'
            else:
                new_tag = tag[:-1] + f' fill="{target}">'
            result = result[:root.start()] + new_tag + result[root.end():]
            replaced += 1

    return result, replaced


def default_output(source):
    """breeze/<name>.svg -> breeze-dark/<name>.svg; otherwise write to stdout."""
    directory, name = os.path.split(source)
    parent, theme = os.path.split(os.path.normpath(directory))
    if theme == "breeze":
        return os.path.join(parent, "breeze-dark", name)
    return None


def convert_file(source, output, target, threshold, dry_run):
    with open(source, "r", encoding="utf-8") as f:
        svg = f.read()
    result, replaced = make_dark(svg, target, threshold)
    print(f"{source}: {replaced} colour(s) -> {target}")
    if dry_run:
        return True
    if output is None:
        sys.stdout.write(result)
        return True
    os.makedirs(os.path.dirname(output) or ".", exist_ok=True)
    with open(output, "w", encoding="utf-8") as f:
        f.write(result)
    print(f"  written to {output}")
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("path", help="SVG file or a theme folder (e.g. src/themes/breeze)")
    parser.add_argument("--out", help="output file (single input only)")
    parser.add_argument("--outdir", help="output folder (folder input)")
    parser.add_argument("--color", default="#ffffff", help="replacement colour (default #ffffff)")
    parser.add_argument("--threshold", default="0x80",
                        help="replace colours whose brightest channel is <= this (default 0x80)")
    parser.add_argument("--dry-run", action="store_true", help="only report what would change")
    args = parser.parse_args()

    if parse_color(args.color) is None:
        parser.error(f"invalid --color: {args.color}")
    try:
        threshold = int(args.threshold, 0)
    except ValueError:
        parser.error(f"invalid --threshold: {args.threshold}")

    if os.path.isdir(args.path):
        if args.out:
            parser.error("--out is only valid for a single input file")
        parent, theme = os.path.split(os.path.normpath(args.path))
        outdir = args.outdir or os.path.join(parent, theme + "-dark")
        names = [f for f in sorted(os.listdir(args.path))
                 if f.endswith(".svg") and "~" not in f]
        if not names:
            parser.error(f"no SVG files in {args.path}")
        for name in names:
            convert_file(os.path.join(args.path, name),
                         os.path.join(outdir, name),
                         args.color, threshold, args.dry_run)
        return 0

    output = args.out or default_output(args.path)
    if output is None and not args.dry_run and sys.stdout.isatty():
        parser.error("cannot infer an output path; use --out or pipe the result")
    convert_file(args.path, output, args.color, threshold, args.dry_run)
    return 0


if __name__ == "__main__":
    sys.exit(main())
