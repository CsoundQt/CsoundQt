# CsoundQt 7.4.6 Release Notes

CsoundQt 7.4.6 brings the widget panel closer to a small GUI toolkit: flat
sliders, menus and checkboxes, Markdown and vertical text, display bold, widget
name overlays and a searchable New Widget palette. The editor gains a new
scanning pipeline, Go to Anything, embedded files, docstring help and
type-aware completion, while large documents and widget editing are
substantially faster.

The notes cover the changes since 7.4.1.

The source and binaries can be downloaded from:
<https://github.com/CsoundQt/CsoundQt/releases/tag/v7.4.6>.

## User-facing changes

### Widget panel

* **A New Widget palette:** double-clicking the empty panel, pressing N while
  the panel has focus in edit mode, or choosing Edit → Add Widget opens a
  palette with large icons, shortcut hints and arrow-key navigation.
  Widgets are created at the mouse position. Creation shortcuts now
  exist for all widgets
* **Edit-mode toolbar:** the right edge of the panel has an adaptive widget
  toolbar. It creates the selected widget in the centre of the visible panel,
  follows the panel background for its icons, and can be hidden in
  Settings → Widgets. The name-overlay toggle is also available there.
* **Panel appearance stays under control:** the panel background is taken from
  the document rather than from the live theme, so switching Qt styles or
  colour themes no longer changes the saved design. 
* **Flat sliders:** sliders now have a self-painted flat style with configurable
  background, border, foreground and fill colours; border width and radius;
  thumb width, padding and roundness; thumb-only or filled display; nudge/jump
  background clicks; and the same exponential value mapping as the knob. A
  ruler can be shown in compact or full form with linear or dB scales. 
* **Shared ruler:** the slider and VU meter use the same WidgetRuler
  implementation. It chooses sensible tick steps and reduces minor ticks on
  compressed scale parts 
* **Flat menus:** menu widgets have a self-painted closed box and popup, configurable
  colours, border width and radius, and Font Family/Size settings. New menus
  follow the global flat-style default. The menu widget also gained string
  methods:
  - `invalue("<menu>/menuitems")` returns the item names.
  - `outvalue "<menu>/menuitems", "a,b,c"` replaces them.
  - `invalue("<menu>/getitem")` returns the selected item text.
  - `outvalue "<menu>/setitem", "item"` selects an item by exact text.
* **Flat checkboxes:** checkboxes can use the flat style with `x` or `full`
  marks, configurable colours, border radius/width and padding.
* **SpinBox improvements:** a Show Arrows option, new panel-aware defaults,
  always-present background and cleaner property dialogs.
* **Table plots:** configurable line width, line/bar/filled-line plot types,
  optional point markers, horizontal zoom, scrolling and panning, and an x
  axis that can follow the table sample rate. Axes, labels and gridlines are
  now readable and stay inside the widget.
* **Graphs and scopes:** configurable background colours; scopes also gain a
  global and per-widget antialiasing option.
* **Markdown labels:** labels can render GitHub-flavoured Markdown using Qt's
  built-in parser. Plain remains the default. The format is saved as
  `<textformat>markdown</textformat>` and can be changed at runtime with
  `outvalue "<name>/textformat", "markdown"`.
* **Display bold:** displays have a Bold checkbox, saved as
  `<bold>true</bold>`.
* **Vertical text:** labels and displays can use Horizontal,
  Vertical (bottom to top) or Vertical (top to bottom) text. This works for 
  narrow overlays on sliders and for labels with little horizontal room. 
  The orientation is saved as `<textorientation>` and can be changed with
  `outvalue "<name>/textorientation", "vertical-up"`.
* **Widget names in tooltips and highlighting:** tooltips now show a widget's
  Name in addition to its channels and MIDI information. Editor lines that
  reference `"<name>/<property>"` highlight the named widget, and hovering or
  selecting a widget highlights lines that use either its channels or its
  name.
* **Edit-mode name overlay:** Settings → Widgets → Show name overlay in edit
  mode draws the widget Name and channel as a compact badge in the top-right
  corner. Narrow widgets use vertical text. The action Toggle Widget Name
  Overlay is in the View menu and defaults to Ctrl+T, N.
* **Style copying and geometry:** Copy Style now also stores width and height;
  Apply Style and Geometry applies the copied appearance and size while
  keeping the destination position. Values and selection state are never
  copied, and applying a style no longer resets a widget's current value.
* **Presets and locking:** preset actions are available in the relevant modes,
  Store Preset replaces the removed New Preset entry, and Ctrl+L toggles the
  locked state of the selected lockable widgets.
* **Display formats:** displays have a printf-style Format field. An empty
  field uses Precision; one numeric conversion is accepted, `%%` is a literal
  percent sign, invalid input is flagged, and Precision is disabled while a
  valid format is active.
* **Labels and displays as overlays:** outside edit mode they pass mouse
  events through, so a transparent display or label can sit on top of a slider
  without blocking it. Ctrl-clicking a value widget resets it to the value
  captured when the document was opened.
* **Widget defaults:** Settings → Widgets gained a Default Font and options for
  the widget toolbar and edit-mode-while-playing. New widgets use panel-aware
  colours by default.

### Editor and code intelligence

* **New scanning pipeline:** `CodeScan`, `IncludeCache` and `ScanService`
  parse the document and its `#include` files, including preprocessor
  conditionals and include guards. The scanner understands classic and Csound
  7 UDO signatures, instruments, structs, macros and per-block local variable
  types.
* **Go to Source:** jumps from a name to its definition in the current file or
  an included file. It covers opcodes, named instruments, macros, structs and
  include paths.
* **Go to Anything:** Ctrl+Shift+P opens a fuzzy command palette over opcodes,
  instruments and the score tag in the current document and its includes.
* **Inspector:** updates are debounced instead of polling every three seconds.
  The Inspector marks the instrument/opcode containing the cursor and lists
  embedded files as well as symbols.
* **Autocomplete:** the popup now scrolls, shows aligned name/arguments/type
  columns, ranks opcodes by a known output variable type, completes local and
  global variables from the scanner, completes widget channels and names in
  `invalue`/`outvalue`, supports `<name>/<property>` paths, and completes
  include names and CsOptions. It stays off the line being typed and cancels
  when the cursor moves.
* **Quick reference and docstrings:** F1 opens a Quick Reference card for
  opcodes, UDOs and instruments. UDO and instrument docstrings are rendered as
  Markdown in the help panel, with the first sentence shown in the status bar.
  Ctrl+hover always shows the help card; plain hover can be enabled in
  Settings → Editor → Behavior with a configurable delay.
* **Type-aware editing:** Show Type for local variables, Show Occurrences for
  the symbol under the cursor, variable-type-aware syntax highlighting,
  Go to Source for variables, and autocomplete ranking by output type.
* **Editor line actions:** Kill Line, Kill to End of Line, Duplicate Line and
  Move Line Up/Down.
* **Embedded files:** File → Embedded Files lists `<CsFileB>` entries with
  decoded sizes and supports adding, removing and extracting files. The
  original blocks round-trip losslessly when unchanged.
* **PDF export:** File → Export to PDF replaces the system print dialog.
  Ctrl+P exports the current document with the light syntax theme and optional
  line numbers.
* **Read-only and widget-only modes:** `--readonly` opens a non-editable
  document with a visible READONLY marker; `--noeditor` opens a detached
  widget-only window with its own toolbar, console and document engine.
* **Codepad:** renamed from ScratchPad, uses the editor theme and orchestra
  highlighting, has its own font size, and evaluates score lines correctly.
* **Channel highlighting:** four modes for outlining widgets from editor
  channels (Never, Cursor only, Mouse only, Full), and three modes for marking
  editor lines that reference a selected widget's channels or name. Marks can
  be pinned with Ctrl+Shift+J and cleared with Esc.
* **External plugin opcodes:** opcodes discovered through Risset's
  `opcodes.xml` now become part of syntax highlighting in already-open
  editors as soon as Risset detection finishes, instead of waiting for a
  restart.
* **Faster large documents:** syntax rehighlighting suspends the document
  layout, reducing loading a large file by a factor of 30x. The highlighter 
  itself was optimised, the Inspector is debounced, and widget edit mode now 
  draws frames directly instead of
  applying a style sheet per frame, reducing setup by a factor of 12x
* **Smaller editor improvements:** F3 for Find next, bracket pairs marked with
  a background selection, automatic `endin`/`endop`/`od` closing, fractional
  editor font sizes, configurable tab font size, and a compact status-bar
  summary of the actual sample rate, channels and ksmps during realtime
  performance.
* **New editor themes and roles:** the midnight, neon and paper themes were
  added, together with a dedicated syntax role for quoted channel names and
  clearer comment/string handling.

### Audio, MIDI and rendering

* **Realtime audio settings were reworked:** the Audio tab now reflects the
  modules, devices and sample rates that the installed Csound build can
  actually use. Device lists and channel counts come from Csound, JACK ports
  are aggregated by client, and unsupported or unhelpful modules are hidden.
* **Channels and ksmps:** channel setup can use the Device, an Override or the
  Orchestra; `nchnls`/`nchnls_i` and Samples per cycle are configured
  explicitly. Fixed-rate backends such as JACK, PipeWire and CoreAudio show
  their fixed rate and use a 16–512 ksmps selector.
* **Pre-play validation:** an unavailable module/device or a fixed-rate
  mismatch is reported before Csound starts, with Open Audio Settings as the
  default action.
* **Realtime MIDI:** RtMidi is the default and is built from the bundled
  submodule. The input/output menus are shared between internal MIDI and
  Csound MIDI, and the Internal MIDI checkbox now clearly enables widget MIDI
  controls. If the host has no MIDI subsystem (for example a headless machine
  without an ALSA sequencer), CsoundQt now starts without MIDI instead of
  aborting.
* **Recording is always available**, and the old `record_support` build
  switch is a deprecated no-op.
* **Render settings** now follow the document's Csound options, have a
  configurable Render Folder, show a progress bar during offline rendering,
  and can pass `--nodisplay` to disable widget displays. Render History lists
  the files rendered in the session and can open their folder or the file
  externally.
* **Faster startup:** audio devices are cached per module and validated once
  per settings snapshot; Csound modules are discovered once per session.
  Repeated runs no longer re-enumerate every device.

### Application, settings and UI

* **Settings dialog:** the Audio, Render, Widgets, Editor, Shortcuts and
  Environment pages were reorganised, with What's This help on every setting
  and a reading-order Tab chain. The template editor is now opened from the
  Editor page instead of taking a whole tab.
* **Configurable shortcuts:** the separate Keyboard Shortcuts window is now
  the Shortcuts tab of Settings. Shortcuts can be assigned immediately,
  conflicts are reported, deviations from defaults are marked, and scopes let
  the same key serve the editor and the widget panel separately.
* **Defaults and obsolete options:** the default panel-toggle shortcuts use the
  Ctrl+T chords, the toolbar and editor scrollbar can be toggled from View,
  and a number of obsolete settings were removed (global widget font scaling,
  “save widgets in csd”, the utilities shell, SFDIR/RAWWAVE_PATH, the PDF
  viewer, the system samplerate option and the old external-tool entries).
* **Dock panels:** shared title-bar and context-menu handling for Help,
  Widgets and Console, smaller dock titles, an option to hide docked panel
  titles, bottom panels constrained to the editor width, and drag-to-float for
  tabbed panels.
* **More configurable feedback:** the tooltip delay can be adjusted, and the
  configuration dialog uses What's This help as described above.
* **Icons:** the bundled Breeze and Breeze-dark icons are now SVG, with
  dark variants generated from the light set and panel-aware widget-toolbar
  icons.
* **Session restore and window titles:** the previously selected file is
  opened first and the rest of a remembered session loads in the background;
  the window title can include the active file, and tab tooltips show full
  paths.
* **Wayland:** Qt Quick uses its software scene graph on Wayland, so opening
  the virtual MIDI keyboard no longer slows down widget painting or leaves the
  main window inactive.
* **Plugins window:** File → Plugins shows whether risset is available. When it
  is not, the window can install risset with uv into the user's CsoundQt data
  directory without administrator rights. External plugin opcodes are added to
  the editor's syntax highlighting once risset detection finishes. Risset is
  detected only through the managed executable or a `risset` script on `PATH`;
  CsoundQt no longer probes system Python modules.
* **risset 4 command line:** generating `opcodes.xml` now uses
  `risset dev opcodesxml --outfile <path>`, the order required by risset 4. The
  previous argument order is tried as a fallback for older installations. With
  risset 4.0.1 the old order made detection succeed but left the plugin opcodes
  unloaded.
* **Read-only and detached windows** keep their own themed menu bar and
  toolbar; Test Audio Setup opens the AudioMidiTest example in widget-only
  mode.

### Widget templates and utilities

* New widget templates for sliders, buttons, Markdown labels and vertical
  labels.
* `util/dev/migrate-sliders.py` converts native sliders to the flat style and
  centres them in their old rectangle.
* `util/dev/fix_controller_borders.py` converts the old controller border tags
  to `borderWidth`.
* `util/dev/flat_menus.py` sets every menu widget in one or more `.csd` files
  to `flatStyle=true` in place.
* `util/dev/split-csd.py` splits a `.csd` into `.orc`, `.sco` and `.cswidget`
  files for use with plain Csound tools.
* The bundled examples were modernized for Csound 7 and the current widget
  format. Obsolete or broken examples were removed, and the McCurdy haikus
  were reorganized.

### Removed or changed

* The split editor view and its section actions were removed; the single
  editor remains the editing surface.
* Printing was replaced by PDF export.
* The separate Keyboard Shortcuts window was folded into Settings.
* The Python and XML editor modes were removed.
* `.udo` files cannot be run; run, render, record, pause and stop are disabled
  for them. File → Switch orc/sco and File → Convert to .csd were added for
  the separate orchestra/score workflow.
* The CMake build is no longer maintained on this branch; qmake is the build
  system here. CMake support lives on the `cmake_support` branch.

## Developer-only changes

* The old source-definition parser was replaced by `CodeScan`, `IncludeCache`
  and `ScanService`. The scanner records block ranges, local variable types,
  UDO/instrument signatures and docstrings. It is covered by tests for classic
  and Csound 7 syntax, includes, conditional blocks, variable scope and Go to
  Source.
* The editor now consumes scanner results for highlighting, completion,
  Inspector, Go to Source, Go to Anything and quick help instead of reparsing
  text in each feature.
* Widget colours are written as hex strings in XML; the loader still accepts
  the old `<r>/<g>/<b>` triplet form. New widget properties include
  `textformat`, `textorientation`, `bold`, scope `antialias` and the table-plot
  display options.
* The channel tokenizer and lookup moved to `channeltext.{h,cpp}` and gained a
  standalone benchmark. Widget property metadata includes value types,
  descriptions and transitory methods.
* `tests/run-tests.sh` builds and runs the standalone QtTest suites and
  benchmarks in CI, including the Markdown renderer, embedded files, scanner,
  Inspector, bracket matcher, Go to Source and external launcher. A new
  `risset` test covers the managed plugin paths, script-only detection, the
  absence of a Python-module fallback and the `opcodes.xml` command line. On
  macOS arm64 the script forces `<arm_acle.h>` into the compiler, because Qt
  up to 6.10.3 calls `__yield()` from `qyieldcpu.h` without including it.
* The opt-in `workflow_dispatch` test in `testbuild-qt6.yml` runs the built
  CsoundQt with `--self-test-risset-install` on Linux, macOS and Windows. The
  application itself downloads uv, installs risset into a throw-away data
  directory through the Plugins window code, waits for its own re-detection
  and writes a JSON report (`risset info --full` plus the detected version and
  executable). It is opt-in because it depends on external network services.
* The build layout is qmake-only: `qcs.pro` stays in the root, other project
  and `.pri` files live in `qmake/`, and third-party submodules live under
  `third_party/`. RtMidi is bundled and enabled by default, recording is
  always available, the splash screen is off by default, and litehtml was
  updated to a newer revision. CI uses Qt 6.8.3; Qt 6.7 or newer remains the
  documented minimum.
* Development utilities were moved to `util/dev` and their tests to
  `util/test`. `flat_menus.py`, `migrate-sliders.py`,
  `fix_controller_borders.py`, `split-csd.py` and the Qt-literal and regex
  rewriting helpers are documented there.
* The Qt string-literal convention now uses `u"..."_s` and `"..."_L1` where
  possible.

