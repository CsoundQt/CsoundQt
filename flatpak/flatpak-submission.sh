#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <destination-directory>"
    echo
    echo "Copies files required for a Flathub submission to DESTINATION_DIR."
    echo "The destination should be the root of your flathub repo checkout."
    exit 1
fi

DEST="${1%/}"

SRCDIR="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$DEST"

cp "$SRCDIR/flatpak/io.github.CsoundQt.CsoundQt.yml" "$DEST/"
cp "$SRCDIR/flatpak/io.github.CsoundQt.CsoundQt.metainfo.xml" "$DEST/"
cp "$SRCDIR/flatpak/io.github.CsoundQt.CsoundQt.desktop" "$DEST/"
cp "$SRCDIR/flatpak/csoundqt.png" "$DEST/"

echo "Copied flatpak submission files to $DEST"
echo
echo "Files:"
for f in io.github.CsoundQt.CsoundQt.yml \
         io.github.CsoundQt.CsoundQt.metainfo.xml \
         io.github.CsoundQt.CsoundQt.desktop \
         csoundqt.png; do
    echo "  $DEST/$f"
done
