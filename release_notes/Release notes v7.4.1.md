# CsoundQt 7.4.1 Release Notes

* reworks the panels and their shortcuts
* syntax theme can be selected independent of app theme
* user defined syntax themes 
* The editor gains a Go to Source action (to jump to the place where an opcode or an 
instr is defined), 
* autocomplete menu: configurable width
* modified tabs are marked by a parenthesis mark
* The help panel can be zoomed
* playback always runs what is in the editor
* the opcode list is regenerated from the new manual. 

The notes cover the changes since 7.3.1.

The source and binaries can be downloaded from:
<https://github.com/CsoundQt/CsoundQt/releases/tag/v7.4.1>.

## User-facing changes

### New features

* **The Qt style can be chosen:** Settings → Advanced has a *Widget Style*
  dropdown. macOS and Windows keep their native style, Linux uses Fusion, which
  looks the same everywhere. Styles that do not follow the application palette
  (Breeze on Linux, for instance) are given CsoundQt's own colours, so the
  whole window, the toolbars and the icons stay in the chosen colour theme.
* **Logging from the GUI:** the old *Log file* setting is replaced by a new
  logging system. Settings → Environment has *Log debug info* and an *Open
  log* button, which is useful on Windows and macOS, where there is no
  terminal to read the output from.
* **Editor themes are data now, and you can write your own:** the syntax
  highlighting theme is no longer the same thing as the application colour
  theme. Settings → Editor has an *Editor theme* dropdown (*auto*, *light*,
  *dark*, *light classic*), so a light editor can be combined with dark
  chrome. A theme is a JSON file with a name and a foreground and background
  colour; every other role is optional and falls back to the built-in theme it
  is based on. Themes are read from the user theme folder
  (`~/.local/share/csoundqt/themes` on Linux,
  `~/Library/Application Support/csoundqt/themes` on macOS,
  `%LOCALAPPDATA%\csoundqt\themes` on Windows), and the built-in names are
  reserved. Settings → Editor has *Duplicate* and *Open Themes Folder* beside
  the theme dropdown, and the Help panel has *Open Themes Folder*, so a theme
  can be copied and edited without leaving the application.
* **Go to Source:** the editor can now jump from a use of a name to the place
  where it is defined. The action is in the Edit menu (Ctrl+B) and in the
  context menu of the editor, where the name under the mouse is used, so a
  name can be jumped to without putting the cursor there first. User-defined
  opcodes, named instruments, macros and the struct types of Csound 7 are
  recognised; definitions inside comments and strings are ignored.
* **The autocomplete menu can be tuned:** Settings → Editor, next to
  *Autocomplete while typing*, lets users change its width and set a maximum
  number of visible rows. It defaults to 20; the full list remains available
  by scrolling, with opcode suggestions shown first.
* **One tab size, in characters:** the Editor page had *Tab Width* (pixels)
  and *Spaces per Tab*, which were hard to relate. There is now a single *Tab
  Size*, the number of spaces a tab is displayed with and inserted as, as in
  most other editors. Tabs and space indentation line up, and the number is
  always enabled.
* **The help panel can be zoomed:** Ctrl+wheel over the manual zooms the page
  instead of scrolling, and Ctrl+plus / Ctrl+minus do the same while the view
  has the focus. The zoom is smooth: the page is scaled while the wheel turns
  and laid out once when the gesture ends, instead of rebuilding the document
  for every notch.
* **Starting a second CsoundQt on purpose:** the new command line option
  `--force-new` skips the check for a running instance, so a script or an IDE
  can start its own instance with its own files.
* **Panels can be toggled with one shortcut:** Ctrl+T followed by a key
  toggles a panel: Ctrl+T, E for the editor, W for the Widgets, H for Help, I
  for the Inspector and C for the Console. The View menu entries are toggles
  as well, and the checked state follows the visibility of the panel. The
  Widgets tab now comes before the Help tab, matching the focus shortcuts
  (Ctrl+1 Widgets, Ctrl+2 Help). *Insert Opcode* is F2.
* **"Quit when all tabs are closed"** is a new setting in Settings → Advanced,
  next to *Allow simultaneous play*. Closing the last tab then closes the
  application, without asking twice about a modified document.
* **Playback runs what is in the editor:** Ctrl-R always plays the text of the
  editor, also for the read-only documents such as the bundled examples, which
  were played from their old file on disk. The copies live in a directory of
  the session, guarded so that a second instance does not mistake a live
  session for a crash; at startup the newest leftover session is offered and
  its files open as temporary documents that ask for a name when they are
  saved. The modified marker in the tab label is back as well.
* **The editor and the dock column keep their share of the window:** resizing
  the window (or maximising it) now grows the Widgets, Help and Console column
  with it, instead of leaving it at a fixed pixel width. The ratio is taken
  from the layout at startup and updated when the divider is dragged.
* **The virtual keyboard can be resized:** the MIDI keyboard window followed
  the size of its frame; the keys now fill the window.
* **The graph picks the peak under the mouse:** a click in the spectrum
  selects the nearest peak, weighted by its distance to the cursor, instead of
  the loudest peak in a window around the click.
* **The examples were modernised:** new scripts bring the shipped examples up
  to date (the `%n` of the Csound 6 files is `\n` now, the indentation and
  the trailing spaces in the buttons and the labels are gone), and a number of
  examples were fixed, among them the AudioMidiTest, the Hello World, the
  VUMeter and the Spectrum Analyzer.

### Fixes and improvements

* **The parenthesis mark no longer covers the text.** The bracket next to the
  cursor and its partner used to be marked with a background colour, which was
  very disturbing while typing. They are now bold and in a contrasting colour
  (white on a dark theme, black on a light one), chosen by the lightness of
  the text and background colours of the theme; the background of the editor
  is left alone. Brackets inside a string or a comment are not marked any
  more, and the contents of a `{{ … }}` string are not highlighted as code.
* **The opcode list follows the new manual.** The manual is written in mkdocs
  now, so the list of the opcodes is generated from it again. The opcodes
  carry the names Csound 7 uses, and the names they had before are kept as
  aliases, so that older code still resolves. The opcodes that Csound does
  not support any more, the FLTK and plugin ones, are gone.
* **The Apply button of the settings dialog applies.** It was connected, but
  nothing copied the values of the widgets into the settings, so Apply
  applied the values of the last time the dialog was accepted.
* **The manual is found and reloaded.** The manual is reloaded when the
  documentation path in the settings changes, and the path is expanded, so a
  path that starts with `~` works. When no path is set, for instance after a
  reset of the preferences, the manual that CsoundQt downloaded earlier is
  used instead of looking for it in the usual places only. A path that is not
  a usable manual is reported without a modal dialog.
* **The search roots of the help panel can be removed,** and the page can be
  cleared, so that no stale manual stays when the documentation path changes.
* **The Examples menu does not disappear in a development build.** The menu
  was only created when the examples folder was found, and a shadow build
  (Qt Creator, CMake) puts the binary somewhere none of the paths matched. The
  folder is now searched for along the path of the executable, and the menu is
  always there: if the folder really cannot be found, it says so and offers
  the configuration dialog.
* **The autocomplete menu is visible in the light theme.** It is its own
  window with its own colours, and against the light editor it had no
  outline at all. It now has a warm background and a border in the light
  theme, and the separators between the groups of opcodes are painted (the
  colour was missing its `#`, so Qt dropped the declaration).
* **More control over the editor's appearance:** *Line number contrast* (0 to
  100) blends the numbers towards the background of the gutter, *Show line
  numbers* is renamed *Line Numbers* and grouped with it, and *Editor padding*
  sets the space between the edge of the editor and the text.
* **Files always use Unix line endings**; loading still converts CRLF and CR.
* **"light classic" is an application colour theme** as well, next to the
  editor theme of that name. Existing configurations move to "light".
* **The toolbars can be locked** by right-clicking on them, and the focus
  flash of the editor can be switched off.
* **Flat widget buttons** get default colours that follow the background of
  the widget panel, instead of the colours of the global palette, which
  could clash with it.
* **The shortcut selector accepts multi-chord sequences** such as `Ctrl+T, E`,
  and the conflict check understands prefixes: two shortcuts conflict when one
  is the beginning of the other, because the shorter one fires immediately.
* **The "Tab key always indents" option is gone.** It duplicated the existing
  *Indent* action (Ctrl+I). Tab keeps the normal behaviour of an editor: with
  no selection it inserts a tab or the configured number of spaces, with a
  selection it indents the selected lines. Shift+Tab still unindents.
* **The virtual keyboard** has a MIDI icon, and the *Show/hide line number
  area* action is renamed *Toggle line numbers*.
* **The graph of the spectrum analyzer** is smoother to use, and the manual
  asks before guessing when a detail is missing.

### Removals

* **Python support is gone.** CsoundQt does not run Python any more: the
  Python highlighting mode, the Python console, the script execution per
  document and the settings of the script directory are removed. *Evaluate
  selection* and *Evaluate section* evaluate Csound code.
* **The features that were not maintained any more are gone:** the Create App
  wizard and the `<CsApp>` section (which now round-trips as ordinary extra
  text), the CsLADSPA section command, the code graph (the *dot* setting and
  the graph window), and the QuteApp SDK directory setting with its bundled
  resources.
* **The settings of the versions before 7 are not migrated** any more. They
  are discarded with a one-time notice, because the panel shortcuts changed.
* **Saving on run is off by default.** *Save changes automatically on run*
  now defaults to false, which means that playing an ordinary saved document
  does not write the file first. Existing configurations keep their value.
* **The settings *Autoplay files when launched from file* and *Ask when
  playing a temporary file* are gone**; `--play` is the only way to autoplay.

## Developer-only changes

* The parenthesis matching moved into a `BracketMatcher` component, which owns
  the document, the marked pair and the scan that finds the partner. The scan
  walks the blocks iteratively, so an unmatched bracket in a long file cannot
  turn the number of blocks into stack depth, and a pair can never be marked
  in a document it does not belong to.
* The highlighter records only the brackets that are code. A new lexical
  scanner, `CsoundLex`, knows the comments and the strings of a Csound line,
  including the `/* */` comments and the `{{ }}` strings that span lines, and
  keeps that state across the lines, so that a string is a string on every
  line of it.
* The opcode list is generated by `util/opcodeparser7.py`, which reads the
  pages of the manual. The manual is the only source of truth now: the order
  of the categories comes from its `categories.py` and the symbols of the
  operator pages from its `diffopnames.py`, so `util/categories.py` and the
  old `util/opcodeparser.py` are gone. The name of an opcode is the one used
  in its syntax line, so that a page can document several opcodes (the rate
  variants of a family) and a page that was renamed carries the name Csound 7
  uses. The syntax is recorded in the modern notation of the manual; the
  classic notation can be derived from it. A category that the manual does
  not list, a page without a syntax section and a syntax line without an
  opcode name are reported instead of being dropped silently.
* The opcodes.xml can mark an opcode as deprecated and name the aliases of an
  opcode. The aliases are known to the editor, so that they are completed and
  highlighted, but they are not listed in the menu. The menu inserts the
  modern notation without a space between the name and the arguments:
  `ares = oscili(xamp, xcps)`.
* The built-in editor themes are compiled-in `EditorThemes::Theme` data
  instead of branches in the highlighter. The highlighter resets its formats
  before applying a theme, which also stops attributes like bold or underline
  from leaking from one theme into the next.
* `SourceDefinitions` indexes the user opcodes, the named instruments, the
  macros and the struct types of a document, ignoring the definitions inside
  comments and strings. The index lives in the document page, the request is
  passed on from the view, so that the view does not have to know where the
  definitions come from.
* The new logging system replaces the *Log file* setting: the messages of
  CsoundQt itself go to a log file that can be opened from the settings.
* The playback copies live in a directory of the session under the temporary
  directory, guarded with a `QLockFile`, so that a second instance does not
  mistake a live session for a crash. They are written as UTF-8.
* Opening the theme folder does not launch a child file manager any more: on
  Linux the freedesktop portal is used through D-Bus, which adds a Linux-only
  QtDBus dependency.
* RtMidi is built from the submodule of the repository, as the CMake build
  already did; a system library is only used when the submodule is missing.
* The build of the examples and of the application was cleaned up: the
  scripts that modernise the examples and the styles of the widgets are in
  `util/`, and the new tests of the bracket matcher, of the opcode list and of
  the Go to Source action are built from their own project files in `tests/`.
* A working-style note was added for the agents that work on the code: when
  a test path, an expected behaviour or a design choice is unclear, ask
  instead of inventing an assumption.

## The bigger picture: since 7.2.0

For the readers who did not follow the development, this is what the releases
since 7.2.0 brought, in short.

**7.2.0 — the widget panel grows.** A new **waveform widget** draws the
samples of a table, with the cursor read and written through a second
channel. Buttons can opt into a **flat style** that CsoundQt draws itself, so
that they look the same on every platform. Any widget property can be changed
from Csound with `outvalue "<channel>/<property>"`, which makes **widget
animation** possible, and a widget can be given a name of its own. The
find/replace dialog became an **inline find bar**, and CsoundQt can now
**evaluate Csound code on the running performance thread** and get the result
back.

**7.2.1 and 7.2.3 — the rough edges.** A safer **0dBFS fallback** setting,
a **drop menu** for soundfiles and other non-Csound files, spaces-for-tabs
support, the widget state preserved across a reload, and a set of fixes for
the autocomplete, the panel focus and the widget teardown.

**7.3.0 — the same look everywhere.** The widget panel **bundles 11 font
families** and restricts the font picker to them, so a panel looks the same
whatever the machine has installed. Widgets got **Copy Style / Apply Style**,
a new **VUMeter** widget, a unified **Maximize Panel / Focus panel** system
with a focus indicator, and a number of crash fixes around editing while
playing.

**7.3.1 — the panels, edited.** The **frame colours of a widget are
configurable** and it can be resized from either corner, the **graph controls
are methods** (`outvalue "graph1/findfft", "asig"`), a widget can be
addressed by its **name** as well as by its channel, and the docked panels
lost their title bars in favour of a Float/Dock entry in the context menu.

**7.4.0 and 7.4.1 — the application around the panels.** The panels are
toggled with one shortcut, the **editor theme is independent of the
application theme** and can be written in JSON, the editor gets **Go to
Source** and a **parenthesis mark that does not cover the text**, the help
panel can be **zoomed**, playback always **runs what is in the editor** and
can be recovered after a crash, the **opcode list follows the new manual**,
and the application can be **logged from the GUI**. Along the way, the
**Python support** and the features that were no longer maintained were
removed.
