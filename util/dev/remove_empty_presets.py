#!/usr/bin/env python3

# Removes empty <bsbPresets> ... </bsbPresets> sections from CSD files.
#
# Newer CsoundQt versions do not write this section when a document has no
# presets. This script cleans files written by older versions.
#
# Usage:
#   remove_empty_presets.py [--check] [paths...]
#
# With no paths, src/Examples and templates are scanned. Directories are
# searched recursively for *.csd files. --check reports changes without
# writing them.

import argparse
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
DEFAULT_PATHS = [REPO_ROOT / "src" / "Examples", REPO_ROOT / "templates"]

# Match an empty preset section, including the line it occupies. The search is
# done on bytes so the original encoding and line endings are preserved.
EMPTY_PRESETS_RE = re.compile(
    rb"(?m)^[ \t]*<bsbPresets\s*>\s*</bsbPresets\s*>[ \t]*(?:\r?\n|$)"
)


def iter_csd_files(paths):
    for path in paths:
        path = Path(path)
        if path.is_file():
            if path.suffix.lower() == ".csd":
                yield path
        elif path.is_dir():
            yield from sorted(path.rglob("*.csd"))
        else:
            print(f"error: path does not exist: {path}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        description="Remove empty <bsbPresets> sections from CSD files."
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="files or directories to scan (default: src/Examples and templates)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="report files that would change without writing them",
    )
    args = parser.parse_args()

    paths = [Path(p) for p in args.paths] if args.paths else DEFAULT_PATHS
    paths = [p if p.is_absolute() else (Path.cwd() / p) for p in paths]

    changed_files = 0
    removed_sections = 0
    for path in iter_csd_files(paths):
        try:
            data = path.read_bytes()
        except OSError as error:
            print(f"error: cannot read {path}: {error}", file=sys.stderr)
            continue
        new_data, count = EMPTY_PRESETS_RE.subn(b"", data)
        if count == 0:
            continue
        changed_files += 1
        removed_sections += count
        action = "would remove" if args.check else "removed"
        print(f"{path}: {action} {count} empty <bsbPresets> section(s)")
        if not args.check:
            try:
                path.write_bytes(new_data)
            except OSError as error:
                print(f"error: cannot write {path}: {error}", file=sys.stderr)
                changed_files -= 1
                removed_sections -= count

    if args.check:
        print(f"{changed_files} file(s) would change, "
              f"{removed_sections} empty section(s)")
    else:
        print(f"{changed_files} file(s) changed, "
              f"{removed_sections} empty section(s)")
    return 1 if args.check and changed_files else 0


if __name__ == "__main__":
    sys.exit(main())
