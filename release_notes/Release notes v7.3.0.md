# CsoundQt 7.3.0 Release Notes

**CsoundQt 7.3.0** makes widget panels look the same on every platform by
bundling a curated set of open source fonts and restricting the widget font
picker to them, adds **Copy Style / Apply Style** for widgets, replaces the
intrusive "unknown font" dialog with a non-intrusive transient notification, and
fixes a widget crash, a latched-button flicker and duplicate "Recent files"
entries.

The source and binaries can be downloaded from:
<https://github.com/CsoundQt/CsoundQt/releases/tag/v7.3.0>.

## What's new

**Bundled, platform-independent widget fonts** — a widget panel now looks the
same regardless of the fonts installed on the machine:
* CsoundQt ships **11 font families** (SIL OFL 1.1): Sans — Liberation Sans,
  Noto Sans, Inter, Source Sans 3, IBM Plex Sans; Serif — Liberation Serif,
  IBM Plex Serif, Source Serif 4; Mono — Liberation Mono, IBM Plex Mono,
  JetBrains Mono. The files and their licenses are embedded as Qt resources.
* The **widget font picker** is limited to these families (each entry is shown
  in its own typeface, and the closed box previews the current selection). The
  editor, console and configuration fonts are unaffected and can still be any
  system font.
* Existing widget fonts are **normalized** to a bundled family. Well-known
  equivalents are mapped silently (Arial/Helvetica → Liberation Sans,
  Times New Roman → Liberation Serif, Courier → Liberation Mono, …); unknown
  families fall back to Liberation Sans.
* When a file uses a font that is not bundled, a **transient notification**
  reports the replacements instead of a modal dialog. The bundled examples and
  templates were updated to use the bundled fonts.
* New helper scripts: `util/fetch_fonts.py` (downloads and verifies the fonts
  and licenses, `--check` for integrity) and `util/fix_example_fonts.py`
  (category-preserving font normalization for examples/templates).

**Copy Style / Apply Style for widgets** — a widget's appearance can be reused:
* Right-click a widget → **Copy Style** stores everything that defines its look
  (all properties except position, size, channel(s) and text) in a per-widget-
  type clipboard.
* **Apply Style** is offered on a widget of the same type and applies the stored
  style; when several widgets are selected it applies to all of them at once, as
  long as they all share the type.
* With a multi-selection, **Copy Style** is not offered (it would be ambiguous).

**Transient notifications** — a new non-modal banner (shown in a corner,
auto-fading after a few seconds) replaces message boxes for purely informational
messages. It is anchored to a visible window without forcing the widget panel
open, and waits until a window is available if the file is loaded before the UI
is up.

## Widgets and editor
* Removed the **"Add chn_k to csd"** and **"Delete Selected"** entries from the
  widget context menu (the Delete key already removes the selection).

## Fixes
* **Crash when writing to a channel after a widget was deleted**: the
  channel→widgets lookup cache is now invalidated whenever widgets are added or
  removed.
* **Latched buttons no longer flicker on mouse release**: the widget update loop
  no longer forces the checked state while the button is being held down, which
  previously made the release toggle it back.
* **"Recent files"**: entries are no longer duplicated; the most recently used
  file is moved to the top, and lists polluted by older versions are de-duplicated
  on load.
