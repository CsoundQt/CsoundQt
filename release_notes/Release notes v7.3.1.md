# CsoundQt 7.3.1 Release Notes

CsoundQt 7.3.1 improves widget-panel editing and graph control, and smooths out
several panel, theme, and notification interactions. These notes cover changes
since 7.3.0.

## User-facing changes

### New features

* **More flexible widget editing:** configure the edit-frame colours in
  Settings → Widgets and resize from either the top-left or bottom-right corner.
  Locked widgets have a distinct dotted frame and are skipped by rubber-band
  selection and Select All. Escape clears the selection, and Enter opens the
  properties dialog for a single selected widget.
* **Graph controls as methods:** graph widgets now support property-style
  commands such as `outvalue "graph1/findfft", "asig"`. Available methods are
  `findfft`, `findaudio`, `findtable`, `freeze`, and `peakchannel`; these act
  immediately and are not saved as widget settings.

### Fixes and improvements

* **Widget addresses:** property messages can identify a widget by its Name as
  well as by its channel. Names address a specific widget even when channels are
  shared. UUIDs are no longer accepted as channel aliases; use the widget Name
  instead.
* **Labels and displays behave more clearly:** labels no longer change in
  response to values sent to their channel (they can still be addressed by Name).
  Displays retain value updates and now show their descriptions as tooltips.
* **Graph-command compatibility:** the old graph `@` commands have been removed.
  Use the new methods above instead of `@set`, `@find`, `@freeze`, `@showPeak`,
  or `@getPeak`. The undocumented forced-peak behavior of `@showPeak` has no
  replacement.
* **Dark themes:** the Table Editor and Virtual Keyboard Quick Controls now use
  the application palette, fixing unreadable text in dark themes.
* **Panel behavior:** the docked Widgets and Help panels hide their title bars
  and offer Float/Dock from the context menu. Alt+Left no longer triggers the
  editor's Go Back action while the widget panel has focus.
* **Less intrusive reload feedback:** reloading an unchanged file now shows a
  transient notification instead of a modal dialog. Short notification banners
  are sized to their content rather than appearing overly wide.
* **Examples refreshed:** shipped examples were updated for the current widget
  format and graph methods, with fixes to several examples, including AudioMidiTest,
  Hello World, VUMeter, and the Spectrum Analyzer.

## Developer-only changes

* Graph methods use **transitory properties**: they are available through the
  normal property-addressing and validation path but are omitted from widget
  serialization. The legacy graph string-command interpreter and its
  `QuteGraph::setValue(QString)` override were removed.
* Widget lookup now uses a Name-to-widget map alongside channel lookup. The
  UUID-as-channel fallback was removed; labels are matched by Name only. The
  scroll-number widget also has its own widget type ID for value dispatch.
* Widget-frame resizing uses global coordinates so moving the top-left handle
  preserves the opposite edges. Corner handles pass pointer events through to
  the frame.
* The Table Editor and Virtual Keyboard receive palette roles as QML context
  properties. Example files were re-saved with current serializer metadata and
  without live runtime values.
