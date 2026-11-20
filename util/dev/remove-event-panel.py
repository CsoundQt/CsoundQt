#!/usr/bin/env python3

"""Remove legacy <EventPanel>...</EventPanel> sections from CSD files.

EventPanel was the persistence format of the removed EventSheet feature.
CsoundQt no longer reads these sections, so they are dead data in old files.

Usage:
    util/dev/remove-event-panel.py FILE_OR_DIRECTORY [...]
    util/dev/remove-event-panel.py --check FILE_OR_DIRECTORY [...]

Directories are searched recursively for *.csd files. --check only reports
what would change. The script preserves the file encoding and line endings.
"""

import argparse
import sys
from pathlib import Path

EVENT_PANEL_OPEN = b"<EventPanel"
EVENT_PANEL_CLOSE = b"</EventPanel"
# Tags that mark the end of an unclosed EventPanel section. Some old files
# never wrote the closing tag; their event lines run until one of these.
TOP_LEVEL_TAGS = (
    b"<bsbPanel",
    b"<bsbPresets",
    b"<EventPanel",
    b"<CsoundSynthesizer",
    b"</CsoundSynthesizer",
)


def is_top_level(line):
    stripped = line.lstrip()
    return any(stripped.startswith(tag) for tag in TOP_LEVEL_TAGS)


def remove_event_panels(data):
    lines = data.splitlines(keepends=True)
    output = []
    removed = 0
    index = 0
    while index < len(lines):
        line = lines[index]
        if not line.lstrip().startswith(EVENT_PANEL_OPEN):
            output.append(line)
            index += 1
            continue

        removed += 1
        if EVENT_PANEL_CLOSE in line:
            index += 1
            continue

        # A closed panel can span several lines. If no closing tag exists,
        # stop before the next top-level section instead of eating the rest of
        # the file.
        index += 1
        while index < len(lines):
            if EVENT_PANEL_CLOSE in lines[index]:
                index += 1
                break
            if is_top_level(lines[index]):
                break
            index += 1
    return b"".join(output), removed


def collect_files(paths):
    files = []
    seen = set()
    for value in paths:
        path = Path(value)
        if path.is_dir():
            candidates = sorted(path.rglob("*.csd"))
        elif path.is_file() and path.suffix.lower() == ".csd":
            candidates = [path]
        else:
            print(f"error: not a .csd file or directory: {value}",
                  file=sys.stderr)
            return None
        for candidate in candidates:
            resolved = candidate.resolve()
            if resolved not in seen:
                seen.add(resolved)
                files.append(candidate)
    return files


def main():
    parser = argparse.ArgumentParser(
        description="Remove legacy <EventPanel> sections from CSD files."
    )
    parser.add_argument(
        "paths",
        nargs="+",
        help="CSD files or directories to scan",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="report changes without writing them",
    )
    args = parser.parse_args()

    files = collect_files(args.paths)
    if files is None:
        return 2

    changed_files = 0
    removed_sections = 0
    for path in files:
        try:
            data = path.read_bytes()
        except OSError as error:
            print(f"error: cannot read {path}: {error}", file=sys.stderr)
            continue

        new_data, count = remove_event_panels(data)
        if count == 0:
            continue

        changed_files += 1
        removed_sections += count
        action = "would remove" if args.check else "removed"
        print(f"{path}: {action} {count} EventPanel section(s)")
        if not args.check:
            try:
                path.write_bytes(new_data)
            except OSError as error:
                print(f"error: cannot write {path}: {error}", file=sys.stderr)

    if args.check:
        print(f"{changed_files} file(s) would change, "
              f"{removed_sections} EventPanel section(s) would be removed")
    else:
        print(f"{changed_files} file(s) changed, "
              f"{removed_sections} EventPanel section(s) removed")
    return 1 if args.check and changed_files else 0


if __name__ == "__main__":
    sys.exit(main())
