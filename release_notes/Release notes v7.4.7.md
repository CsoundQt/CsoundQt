# CsoundQt 7.4.7 Release Notes

CsoundQt 7.4.7 adds a complete plugin manager built on risset and automatic
detection of missing plugin dependencies. It also lets you create widgets by
dragging them from the edit-mode overlay, and reorganizes the bundled examples.

The notes cover the changes since 7.4.6.

The source and binaries can be downloaded from:
<https://github.com/CsoundQt/CsoundQt/releases/tag/v7.4.7>.

## User-facing changes

### Plugin manager

* **File → Plugins...** opens the plugin manager. When risset is not available,
  the window explains what risset is and offers **Install risset (plugin
  manager)**. It installs risset into the user's CsoundQt
  data directory without administrator rights. Risset is detected only through
  the managed executable or a `risset` script on `PATH`; CsoundQt no longer
  probes system Python modules.
* Once risset is available, the window lists the plugins that have a binary
  for the current platform and Csound version. A spinner indicates that the
  plugin data is still loading; the table appears when the data is ready.
* The table has one row per plugin with its name, a check column, the installed
  version (or a dash when the plugin is not installed), the latest version,
  a short description, an **Info** button that opens `risset show` output, and
  an upgrade column.
* Install and remove: checking a row installs the plugin, unchecking removes
  it, and **Apply** or **OK** performs the changes. **Cancel** discards them.
  Apply stays disabled while there is nothing to do.
* Upgrades: an installed plugin with a newer compatible version gets an
  upgrade checkbox, which runs `risset install --force <plugin>` on Apply or
  OK. Plugins without an upgrade get no checkbox. When no plugin can be
  upgraded the whole Upgrade column is hidden; otherwise an extra **All** row
  selects every available upgrade.
* **Update** runs `risset update`. **Update Documentation** runs
  `risset makedocs`. Their output appears in a collapsible panel, which remains
  available after an error so a failed command can be inspected.
* Risset 4 compatibility: generating `opcodes.xml` uses
  `risset dev opcodesxml --outfile <path>`, the order required by risset 4.
  The previous argument order is tried as a fallback for older installations;
  with risset 4.0.1 it made detection succeed but left the plugin opcodes
  unloaded.
* After plugins are installed, removed or upgraded, risset's `opcodes.xml` is
  regenerated and the editor's opcode highlighter, completion data and opcode
  insert bar are refreshed. Newly installed opcodes appear and removed ones
  disappear without restarting CsoundQt.
* In Fusion dark the table rows use a slightly lighter background so the
  native checkbox stays visible. Other styles keep their native table
  appearance.
* **Info** runs `risset show <plugin>` in a dialog, with a loading state and
  the command output as plain text.

### Plugin dependencies

* CSD files can declare required plugins in a TOML `plugins` array inside
  `<CsMeta>`:

  ```text
  <CsMeta>
  plugins = ["klib", "else"]
  </CsMeta>
  ```

  When a document has no such declaration, CsoundQt detects plugin opcodes used
  in the orchestra against an opcode map bundled with the application. This
  also works before risset is installed, so the user can be pointed to the
  plugins they need and to risset as the way to install them.
* Detection avoids the common false positives. Comments (`;`, `//`,
  `/* ... */`) and strings (`"..."` and `{{ ... }}`) are ignored, UDOs defined
  in the document shadow plugin opcodes with the same name, and names that are
  variables are never treated as opcodes. Variables are recognised from typed
  declarations and uses (`accum:k`), assignment targets (`accum = ...`) and
  array subscripts (`accum[0]`).
* A banner above the editor reports missing dependencies. For declared
  dependencies it shows “Plugin dependencies are not installed: …”; for
  detected dependencies it names each plugin and up to three triggering
  opcodes with their line numbers, for example:

  `Detected missing plugin klib, opcodes: dict_new (line 8)`

  The banner can be dismissed, and it returns when the dependency situation
  changes.
* If all missing dependencies are available, **Install Plugins** opens the
  Plugins window in a filtered mode showing only those plugins, already
  selected for installation. That mode offers **Update**, **OK** and
  **Cancel**, with no Apply button.
* If a dependency has no compatible binary for the platform or Csound version,
  the banner adds a second line, “Some plugins are not available for this
  platform/Csound version: …”, and offers **Manage Plugins** instead, which
  opens the full Plugins window where risset can be updated and compatible
  plugins can be chosen.
* If risset itself is not installed, **Manage Plugins** opens the full window
  to install risset first. After risset is detected, the banner can offer the
  filtered install flow for the missing plugins.

### Editor and help

* External plugin opcodes discovered through risset's `opcodes.xml` are added
  to syntax highlighting, completion and the opcode insert bar in already-open
  editors as soon as risset detection finishes, instead of waiting for a
  restart.
* The opcode tree is reset before every risset refresh, so opcodes from removed
  plugins disappear and repeated refreshes do not duplicate built-in entries.
* Risset's HTML manual is registered as a help search root when it is
  available.

### Widgets

* Widgets can be created by dragging an icon from the edit-mode create overlay
  onto the panel. The new widget is centered on the drop point. Clicking the
  same overlay button still creates the widget in the centre of the panel.
* The drag uses an internal CsoundQt MIME type, so other drag sources cannot
  accidentally create widgets.

### Examples

* The bundled examples were reorganized into clearly named folders without the
  old letter prefixes: Getting Started, Csound 7, Widgets, Useful, Synths,
  Music, Miscellaneous, Live Collection, HTML5 Support and External Plugins.
* The Examples menu honours an optional `.order` file in any example folder.
  It lists the folder's files and subfolders one per line in the desired menu
  order; entries it does not mention follow alphabetically.
* `External Plugins/CircularBuffer.csd` now declares its `klib` and `else`
  dependencies in `<CsMeta>` and demonstrates the typed-variable syntax that
  the dependency detector understands.

### Application and UI

* Menu icons exported to a desktop global menu (for example KDE Plasma's
  Global Menu) now carry their freedesktop icon names, so the shell resolves
  them in the system icon theme and they follow the desktop palette even when
  CsoundQt uses a different theme. Local menus and toolbars keep the bundled
  artwork.
* CsoundQt starts cleanly on machines without a MIDI subsystem, such as
  headless CI runners. Missing MIDI input or output is reported as a warning
  and the corresponding operations are skipped instead of aborting startup.

## Developer-only changes

* `--self-test-risset-install` runs the same uv/risset installation as the
  Plugins window in a headless session, waits for CsoundQt to re-detect risset,
  and writes a JSON report with the version, executable, `opcodes.xml` path and
  `risset info --full` output. `--self-test-risset-report FILE` chooses the
  report path. The test is opt-in in CI because it uses external network
  services.
* `--self-test-risset-dependencies FILE` starts with risset uninstalled and
  checks the complete dependency workflow: it verifies that FILE's klib
  opcodes are detected without a `<CsMeta>` declaration, installs risset from
  the banner, checks the filtered **Install Plugins** window, installs klib
  through it, and runs FILE with `-n` to confirm that it compiles and
  completes without errors. The CI job runs this on Linux, macOS and Windows
  when the opt-in risset test is enabled.
* `tests/run-tests.sh` covers the risset discovery paths, the bundled opcode
  map and opcode-usage detection (including comments, strings, UDOs, variables
  and line numbers), and opcode-tree reloading without duplicate or stale
  entries.
* The Windows CI workflow retries nightly.link downloads and falls back to the
  GitHub artifacts API when nightly.link returns an error.
* `util/dev/qt-literal-to-suffix.py` now also converts `QLatin1Char('x')` to
  `'x'_L1`. The source tree was converted to the `u"..."_s` and `"..."_L1`
  literal suffixes where possible.
* `src/risset-opcodemap.json` is embedded through `src/risset.qrc`. It is the
  fallback opcode-to-plugin map used when risset is not installed.
