#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/flatpak/org.csoundqt.CsoundQt.yaml"
BACKUP="$MANIFEST.bak"

cp "$MANIFEST" "$BACKUP"
trap 'mv "$BACKUP" "$MANIFEST"' EXIT

python3 - "$MANIFEST" "$ROOT" <<'PY'
from pathlib import Path
import sys

manifest = Path(sys.argv[1])
root = Path(sys.argv[2]).resolve()

text = manifest.read_text()

old = """      - type: git
        url: https://github.com/CsoundQt/CsoundQt.git
        commit:"""

start = text.find(old)
if start == -1:
    raise SystemExit("Could not find CsoundQt Git source")

# Find the end of the commit line
commit_end = text.find("\n", start)
if commit_end == -1:
    raise SystemExit("Could not find end of CsoundQt source")

replacement = f"""      - type: dir
        path: {root}"""

text = text[:start] + replacement + text[commit_end:]

manifest.write_text(text)
PY

flatpak-builder \
    --force-clean \
    "$ROOT/build-dir" \
    "$MANIFEST"
    
