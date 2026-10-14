# CsoundQt 7.3.0 Release Notes

**CsoundQt 7.3.0** makes widget panels look the same on every platform by
bundling a curated set of open source fonts and restricting the widget font
picker to them, adds **Copy Style / Apply Style** for widgets, a new
**VUMeter widget**, a **drag & drop menu** for soundfiles and other non-Csound
files, a unified **Maximize Panel / Focus panel** system with a focus
indicator, **spaces-for-tabs** editor support and a safer **0dBFS fallback**
setting. It replaces the intrusive "unknown font" dialog with a non-intrusive
transient notification, and fixes a widget crash, editing-while-playing
crashes, a latched-button flicker and duplicate "Recent files" entries.

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

**VUMeter widget** — a flexible peak meter widget, with a
`C Widgets/VUMeter_Widget.csd` example (AudioMidiTest updated to use it).

**Drag & drop onto the editor** — only `.csd`/`.udo`/`.orc` files are opened;
anything else offers a menu at the drop point:
* Insert absolute / relative path (quoting-aware, never double-quoted inside
  an existing string);
* Read soundfile as `ftgen` (inserted among the orchestra global code, or at
  the cursor when already there) or as a score table (top of score), using the
  next free table number. Works in the unified and split-view editors.

**Panel focus system** — the status bar shows which panel holds keyboard focus
(`[Editor]`/`[Widgets]`/`[Help]`/`[Inspector]`/`[Console]`/`[HTML]`/`[CodePad]`),
with a brief fading outline flash on focus change (toggleable via Editor →
Behavior → "Flash focus"). New Focus actions (`Ctrl+0`…`Ctrl+3`) jump to
editor/widgets/help/inspector, and a single checkable Maximize Panel action
(`Alt+Ctrl+M`) replaces the four per-panel fullscreen actions. F11 application
fullscreen is unchanged.

**Editor tabs and spaces** — new "Insert spaces instead of tabs" + "Spaces per
Tab" settings (Tab/Shift+Tab, auto-indent and indent actions honor them), plus
Edit → Convert Tabs to Spaces (leading whitespace only, single undo step).
Tab with a selection now indents instead of replacing it; unindent works on
whole lines.

**Insert Opcode action** — dedicated opcode list with search bar; duplicate
opcodes removed; opcode-under-cursor detection extended so help still finds the
right opcode after the cursor moved away. The keyboard-shortcuts list gains a
filter.

**0dBFS fallback** — the old combo (which always passed `--0dbfs=` and could
override a csd) is replaced by a "Fallback 0dBFS = 1.0" checkbox (default on):
checked passes `--0dbfs=1` only when the csd sets neither `0dbfs = …` nor
`--0dbfs=` itself; unchecked passes nothing and leaves Csound's default alone.

**Widget editing** — every widget gains a persisted `enabled` flag (disabled
widgets ignore Csound/MIDI/mouse input); configurable label/display padding;
label-only lock; Shift-drag rubber-band selection from widget frames;
Alt-click cycling through overlapping widgets; Tab traversal and Ctrl+arrow
directional navigation; stacking shortcuts.

## Widgets and editor
* Removed the **"Add chn_k to csd"** and **"Delete Selected"** entries from the
  widget context menu (the Delete key already removes the selection).

## Improvements and fixes
* **Autocomplete**: viewport-correct positioning with a gap from the cursor,
  flips above the cursor near the screen edge, capped/scrollable height; no
  longer fires on paste or inside string literals.
* **Undo/redo during performance is now safe**: geometry-only steps move widgets
  in place; add/remove steps touch only the changed widgets; nothing is deleted
  while Csound runs (fixes a segfault when pressing Ctrl-Z during playback).
  Runtime state (values, latched buttons, strings) survives undo and panel
  reloads; labels no longer reset to `"0.000"`; VU/display channels no longer
  cross-contaminate after a cache rebuild.
* **Inspector navigation**: click/Space navigates without stealing focus,
  Enter/double-click navigates and focuses the editor, arrow keys no longer
  drive the editor. Go Back (`Alt+Left`) works again.
* **Widget panel** opens with correct geometry and scroll position the first
  time it is shown, and is raised on Run whether docked, floating or tabified.
* **Examples/templates**: `<bsbPanel>` attribute order normalized
  (`util/sort_bsbpanel_attributes.py`), two malformed panels repaired; new
  `G Synths/Pipe_Synth2.csd`.
* **Crash when writing to a channel after a widget was deleted**: the
  channel→widgets lookup cache is now invalidated whenever widgets are added or
  removed.
* **Latched buttons no longer flicker on mouse release**: the widget update loop
  no longer forces the checked state while the button is being held down, which
  previously made the release toggle it back.
* **"Recent files"**: entries are no longer duplicated; the most recently used
  file is moved to the top, and lists polluted by older versions are de-duplicated
  on load.

## Compatibility note
* **Legacy MacCsound (`io*`) widget format removed**: widgets are stored and
  read in XML (`bsbObject`) format only, with the old-format checkbox, converters
  and `<MacGUI>` sections gone.

## Packaging, platforms and CI
* **Linux**: AppImage fixes (external links, commit tracking).
* **macOS**: `.dmg` and action fixes.
* **Build/docs**: reworked `BUILDING.md`, tree restructure, new tests for
  external launchers (results now visible in the Windows CI log).
