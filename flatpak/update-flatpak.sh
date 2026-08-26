#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
MANIFEST="$SCRIPT_DIR/io.github.CsoundQt.CsoundQt.yml"
DEST_DIR="${1:-$HOME/dev/forks/io.github.CsoundQt.CsoundQt}"

CSOUNDQT_COMMIT="$(git -C "$REPO_DIR" rev-parse HEAD)"
CSOUND_COMMIT="$(git -C "$HOME/dev/forks/csound" rev-parse HEAD)"
CSOUND_PLUGINS_COMMIT="$(git -C "$HOME/dev/csound/csound-plugins" rev-parse HEAD)"

awk -v csoundqt="$CSOUNDQT_COMMIT" -v csound="$CSOUND_COMMIT" -v plugins="$CSOUND_PLUGINS_COMMIT" '
    /url: https:\/\/github.com\/CsoundQt\/CsoundQt.git/ { flag_csoundqt=1 }
    flag_csoundqt && /commit:/ { sub(/commit: .*/, "commit: " csoundqt); flag_csoundqt=0 }
    /url: https:\/\/github.com\/csound\/csound/ { flag_csound=1 }
    flag_csound && /commit:/ { sub(/commit: .*/, "commit: " csound); flag_csound=0 }
    flag_csound && /url: .*\/csound\/raw\// { sub(/raw\/[0-9a-f]+\//, "raw/" csound "/"); flag_csound=0 }
    /url: https:\/\/github.com\/csound-plugins\/csound-plugins/ { flag_plugins=1 }
    flag_plugins && /commit:/ { sub(/commit: .*/, "commit: " plugins); flag_plugins=0 }
    { print }
' "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"

cp "$MANIFEST" "$DEST_DIR/io.github.CsoundQt.CsoundQt.yml"

echo "Updated CsoundQt commit to $CSOUNDQT_COMMIT"
echo "Updated csound commit to $CSOUND_COMMIT"
echo "Updated csound-plugins commit to $CSOUND_PLUGINS_COMMIT"
echo "Manifest copied to $DEST_DIR/io.github.CsoundQt.CsoundQt.yml"
