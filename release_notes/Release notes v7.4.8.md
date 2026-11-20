# CsoundQt 7.4.8 Release Notes

CsoundQt 7.4.8 adds per-document widget windows and Kiosk mode, reworks the
virtual keyboard and the widget property dialogs, and removes the obsolete
Python/EventSheet scripting stack. It also refreshes several bundled examples
and fixes launching macOS builds made against a source-installed Csound.

The notes cover the changes since 7.4.7.

The source and binaries can be downloaded from:
<https://github.com/CsoundQt/CsoundQt/releases/tag/v7.4.8>.

## User-facing changes

### Per-document widget windows

* The Widgets panel context menu now offers **Detach as Window**. It moves the
  current document's live widget layout into its own top-level windo. Widget values 
  and channel bindings are preserved.
* A detached widget window stays visible when you switch to another document
  tab, making it possible to interact with multiple windet windows at the same 
  time, route audio and osc between documents, etc.
* The context menu of a detached window offers **Attach as Panel**, which puts
  the same live layout back into the dock.
* Detaching is a per-document, session-only state. Switching the global
  *Show widgets in separate window* mode resets all per-document detachments.
* Playing a document with *Show widgets on run* raises its detached widget
  window instead of the docked panel. The **Widgets** toggle and **Focus
  widgets** action follow the detached window as well.

### Kiosk mode

* **File → Switch to Kiosk mode** (formerly *Open in NoEditor Mode*) converts
  the current editor tab into a widget-only top-level window. It uses the live
  editor buffer, including unsaved changes, then closes the editor tab without
  asking to save. Playback stops during the conversion.
* Kiosk windows remember that the user converted them from the editor and offer
  **File → Switch to Normal Mode**, which recreates the editor tab with the
  current text and modification state. Widget-only windows opened directly from
  the command line or from a file do not offer this action.
* While a Kiosk window is open for a file, opening the same file in the editor
  is refused with a message and the Kiosk window is raised.

### File menu

* Export actions are grouped into an **Export** submenu: *Export without
  widgets*, *Export widgets to QML* and *Export to PDF...*.
* **Close current tab** is now **Close Tab**.
* **Reload** always reloads the document from disk and rescans its included
  files. It no longer refuses to reload an unmodified document. The separate
  *Reload Included Files* action (and its `Ctrl+Shift+B` shortcut) was removed.
* *File Information* is hidden from the File menu. Its action and code remain
  available.

### Virtual keyboard

* The CC controls are now compact flat rotary knobs with the current value in
  the centre and a single shared **CC** caption. The knob track follows the
  window palette in dark mode.
* A layout selector offers US, French, German, Spanish, UK, Italian, Swiss and
  Nordic computer-keyboard layouts. Keys show their mapped letters, and the
  labels keep a fixed size.
* The displayed octave count is chosen from the available width (between two
  and eight octaves, keeping white keys between 12 and 26 pixels where
  possible). MIDI note numbers are shown above every C key.
* Clicking a key or pressing Escape returns keyboard focus to the piano, so the
  computer keyboard keeps playing after using a spin box or knob.
* Shift-click toggles a sustained note that stays on after the mouse leaves the
  key; a normal click releases it. An optional **Click→Velocity** mode derives
  the velocity from the vertical click position (top = 1, bottom = 127).
* Layout, channel, velocity, octave and click-position velocity are remembered
  between sessions.
* Virtual MIDI and CC messages go to the most recently started real-time
  document, including detached widget-only windows, instead of always going to
  the current main-window tab.
* Fixed the CC controls sending the controller number as both the controller
  and the value; the slider value is now transmitted correctly.

### Widget properties and panel defaults

* Widget property dialogs are organised into **Geometry**, **Value**,
  **Appearance**, **Prefix**, **Widget** and **MIDI** groups instead of one
  long grid. Scroll Number reuses the shared Geometry, Widget and MIDI groups.
* Scroll Number has an optional Max/MSP-style triangle prefix with a
  configurable baseline and relative vertical and horizontal size. New scroll
  numbers enable it by default.
* Captioned colour buttons show the colour as a rounded 24 px icon with a thin
  border, leaving the button background untouched. Uncaptioned buttons keep the
  original full-button fill.
* The widget panel has a per-panel **Foreground** default colour, stored in
  `<bsbPanel>` and editable in the panel properties dialog. Labels use it.
  Older panels derive a sensible value from their background. The panel
  background field is now labelled **Background**.
* Knobs are square widgets. The defaults for dark panels use `#f57c00` for the
  text and a 1 px `#f57c00` border.
* Old rectangular knob geometry is converted on load using the smaller side,
  with x/y shifted so the knob stays at the same visual centre. This also
  applies after pasting old widget XML.
* Knobs have a configurable **Background** colour and a **Use background**
  option. When the option is off (the default), the background is still derived
  from the foreground colour; when it is on, the selected colour is used as the
  flat-knob background fill.
* Button dialogs put the font size next to the family, use a placeholder for
  the event text, give the text editor two lines and share a row for Type and
  Value. 
* The Menu widget groups its style controls under **Flat** and gives the Items
  field more room.
* SpinBox, Slider and Knob have a shared **Value** group. Knob and Slider keep
  the exponent control inside it.
* The Controller widget no longer exposes the unused fade-speed and behaviour
  controls, groups its value ranges and puts the vertical channel in the Widget
  group. The border colour is disabled when the border width is zero.
* Newly created VU meters, scopes, graphs, waveforms and table displays now get
  their edit frame at their final position instead of at (0, 0).
* Right-clicking the docked **Widgets** tab opens the same menu as right-clicking
  the panel background. Widgets created from that menu are placed at the centre
  of the visible panel.

### Checkboxes

* Checkboxes are square controls. Their properties dialog now has one **Size**
  field instead of separate width and height fields, and both sides stay equal
  when the widget is resized from the edit frame or through geometry updates.
  Existing rectangular checkboxes are normalised to their smaller side when the
  dialog is opened.
* Flat checkboxes have a **Circle** option. It draws the border and the filled
  check state as ellipses and disables the corner-radius control while active.
  The option is stored as `<circle>` in the widget XML and is available as the
  `circle` property.

### Widget presets

* The Widgets context menu's **Presets** submenu now offers **Manage** and
  **New**, followed by the stored presets listed by name.
* **Manage** opens a **Presets** dialog with Name, Index and Description
  columns, a name filter, an **Update** button that stores the current widget
  values in the selected preset, and a **+** button for creating a preset.
* Double-clicking a preset applies it. Enter recalls the selected preset and
  Delete removes it. Clicking a name or description of an already-selected row
  edits it in place (also F2 and the row's **Edit** context-menu action); the
  index is read-only. While the dialog is open, Ctrl+Z (Cmd+Z on macOS)
  restores a deleted preset.
* **New** asks for a required name and an optional description, then stores the
  current widget values. Names must be unique (case-insensitively); indexes are
  assigned automatically and are no longer entered by hand.
* The preset data now includes creation and last-recall timestamps. Older
  presets without a description or timestamps load normally; missing or
  duplicate names are made unique when the document is loaded.
* Saving a document without presets no longer writes an empty `<bsbPresets>`
  section. The bundled examples and templates were cleaned of empty sections
  with `util/dev/remove_empty_presets.py`.

### Editor

* Autocomplete now prefers commonly used opcodes when the completion category
  and output-type match are otherwise equal. Common opcodes such as `schedule`,
  `outvalue`, `init`, `turnoff` and `interp` no longer get buried among many 
  matches. An opcode whose output type matches the typed variable still
  ranks above an unrelated one, and unlisted opcodes keep their previous order.
* Auto-close blocks now also handles CSD XML tags. Pressing Enter after a line
  containing only an opening tag such as `<CsOptions>`, `<CsScore>` or
  `<CsMeta>` inserts the matching closing tag and indents the body, unless a
  matching closing tag already exists later in the document. Self-closing tags
  and lines that mix the tag with other text are left alone.
* The obsolete `<Cabbage>`, `<csLADSPA>` and `<MacOptions>` section tags, and
  the misspelled `<CsLincense>`, are no longer highlighted or auto-closed.

### Settings

* The output and input channel spin boxes in *Settings → Audio* have a minimum
  of 1. Values saved as zero by older versions are shown as 1, matching Csound's
  own clamping. To disable an audio side, select the *Disabled* device instead.
  The output channel tooltip now describes `nchnls` rather than `nchnls_i`.
* **Allow simultaneous play** is checked by default in *Settings → General*.
  It can still be disabled to stop other performances before starting a new
  one.
* Settings are no longer written to disk in the middle of loading them, which
  caused **Update Rate** under *Settings → Widgets* to be reset to 30 on the
  next start.
* The **Jack Client Name** field accepts names up to 31 characters instead of
  silently truncating them to 16, and the field itself refuses longer input.
  When the name contains `*`, the current document name is inserted without its
  file extension. 31 characters is the limit imposed by Csound's `rtjack`
  module; longer names would be rejected by Csound.

### Plugin manager

* On Linux, risset installation now prefers the distribution Python instead of
  a uv-managed Python. Managed Python builds can be linked against an older
  libffi than the distribution provides (`libffi.so.7` versus `libffi.so.8`),
  which made risset fail on import. The tool environment is recreated so an
  earlier broken installation is replaced.
* If Qt's network backend cannot download the uv installer, for example because
  TLS initialization fails in a packaged Qt build, CsoundQt retries the
  download with `curl`, then `wget`.

### Application and legacy scripting

* The old Python/EventSheet scripting support was removed. This includes the
  Scripts menu, the EventSheet/QuteSheet editor, the PythonQt build
  configuration, the bundled legacy Python scripts and the obsolete
  `qutecsound_*.ts` translation memories. Risset/uv and the Python 3 maintainer
  tools are unaffected.
* Python mode was removed from the syntax highlighter; non-XML text continues
  to fall back to Csound highlighting.
* On Linux, the QML panels (virtual keyboard and table editor) now use Qt
  Quick's software scene graph unless `QT_QUICK_BACKEND` is set explicitly.
  This avoids freezes seen with some Qt 6.9/driver combinations while keeping
  normal widget painting responsive.

### Examples

* Large source materials used by the bundled examples were converted from WAV
  and AIFF to FLAC, reducing the size of the example set. Examples that refer
  to the converted files were updated, and `repluck`/`wgpluck` resolve the
  shared source materials through `SSDIR`.
* *Chowning Stria* and *Kung Xanadu* were refreshed with current widget colours,
  panel backgrounds, fonts and a Markdown label; stale image paths and broken
  borders were removed.
* *Spectrum Analyzer* now uses the current array syntax, drops redundant
  `<CsOptions>` and orchestra defaults, and enables its channel controls based
  on `nchnls`. Its initial check states were corrected.

## Developer-only changes

* Removed the unused `EventSheet`/`QuteSheet` implementation, `liveeventcontrol`,
  `qutedummy`, `util.h`, `scriptsMenu`, `pythonscripts.qrc`, the PythonQt qmake
  configuration and the old translation files.
* Removed the unused Cabbage and LADSPA widget export helpers
  (`getCabbageLine()`, `getCsladspaLine()` and `getCsladspaLines()`).
* Per-document detach and attach signals are connected directly from the widget
  layout to CsoundQt, because `connectActions()` clears document-page
  connections on every tab change.
* The opcode completion priority table is separate from the completion category
  priority, so only the ordering inside the opcode group changed.
* On macOS, the link-time Csound framework root (or the library directory for
  plain dylib builds) is added to `QMAKE_RPATHDIR`. An un-bundled `qmake; make`
  build now launches with a source-installed Csound, which the opt-in Risset CI
  test needs.
* The opt-in Risset CI test now also covers the detected-dependency workflow:
  it starts without risset, detects undeclared plugin opcodes in a CSD, follows
  the banner, installs risset and the plugin through the real windows and runs
  the example. The workflow input is now called *Run risset end-to-end network
  tests*.
* `CsoundEngine::flushQueues()` now emits `passMessages()` instead of appending
  each queued message directly to every console and the widget layout. Queued
  messages follow the same signal path as live messages and are visible to
  additional listeners.
* The embedded-file tests use FLAC names, and `tests/data/dict_get.csd` was added
  as the fixture for the dependency self-test.
