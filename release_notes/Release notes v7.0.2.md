# CsoundQt 7.0.2 Release Notes

**CsoundQt 7.0.2** replaces the
QtWebEngine-based help/documentation viewer with a fast and lightweight
html viewer based on **litehtml** (so default builds no longer need QtWebEngine at all),
adds whole-manual search, improves the help panel and Help menu, and introduces
a new **Linux AppImage** build.

The source and binaries can be downloaded from:
<https://github.com/CsoundQt/CsoundQt/releases/tag/v7.0.2>.

---

## 1. Changes from 7.0.1 

### New litehtml documentation viewer

* **QtWebEngine dropped from the default build**: The embedded manual viewer no
  longer uses QtWebEngine (which is qt's wrapper for chrome). It now uses **litehtml** 
  (a small, in-process HTML5/CSS3 renderer). Default
  builds have *zero* QtWebEngine dependency and are lighter and
  faster to start. The interactive HTML5 GUI feature (`CsoundHtmlView`, `<html>`
  elements in CSDs) still uses QtWebEngine, but only when built with the
  optional `CONFIG+=html_support` flag.
* **DockHelp rewritten around the new viewer**: back/forward history, zoom,
  text selection (Ctrl+C / Ctrl+A), anchor deep-linking and link handling are
  implemented in the viewer. Clicking a `.csd` example link opens it in the
  editor; external links open in the system browser.

### Whole-manual search

* **In-dock manual search panel**: searches across all
  installed manuals (the built-in Csound manual and plugins installed via risset, 
  support for the Csound FLOSS manual is on the way), reusing the index
  files the manuals already provide. 
* **Incremental search**: results are shown as you type
* **Better ranking**: exact matches first, then partial matches in a page title,
  then partial matches in the page body; at most one (best) match per page.
* Search is lazy and built once per session

### Help panel improvements
* **In-panel find box**: a Ctrl+F find box lives inside the viewer with
  next/previous (Enter/Shift+Enter) 
* **Keyboard navigation**: **Alt+Left / Alt+Right** to go to the previous/next page; 
* **Manual home page**: the help panel now defaults to the manual's general
  index as start/home page when available (requires a recent version of the
  manual).

### Help menu
* Help menu targets updated to the current manual layout (GEN routines, opcode
  quick reference, opcode overview); the panel opens the opcode reference on
  startup.
* **New "Csound FLOSS Manual" entry** (opens the online FLOSS manual).
* "Csound Manual" opens the offline manual in an external browser; "Csound
  Manual Online" points to <https://csound.com/manual>.

### Packaging and platforms
* **New Linux AppImage build with built-in csound**: a self-contained
  AppImage is now produced for each release  with **Qt, Csound, manual and plugins bundled**. This
  includes the most recent csound 7 and the most recent manual. The appimage supports
  risset, so any external plugin installed via risset will be available to csoundqt 
  within the appimage
* **macOS**: a .dmg is built with each commit. Improved build/signing/notarisation scripts, audio-input
  entitlement added so input works in signed builds, universal (arm64/x86_64)
  builds, and macOS tab close-button handling.
* **Flatpak**: a flatpak version of csoundqt is available via flathub. This flatpak, similar to the 
  appimage, includes the most recent version of csound 7, the manual and external plugins. Since flatpak
  apps run in a sandbox, the csound provided cannot load external plugins installed via risset. risset can
  still be installed within the sandbox and any plugin installed that way will be picked up by csound 
  and csoundqt

---

## 2. Changes from the 1.x series to CsoundQt 7.0

CsoundQt 7.0 is a major rewrite. Everything below summarises what changed
between the last 1.x release (**v1.1.x**, which was Qt 5 + Csound 6 based) and
the 7.0.0/7.0.1 releases. CsoundQt 7 is built and released from the
`csoundqt7` branch.

### Platform and dependency updates
* **Csound 7 required**: all engine code migrated to the Csound 7 API (new API,
  `csoundGetTable`, changed headers, removal of `CS_API`). Csound 6 is no longer
  supported.
* **Qt 6 required** (tested with Qt 6.5 and newer); the Qt 5 code paths were
  removed. QtWebKit support was dropped (see *HTML* below).
* **`OPCODE7DIR64`** is used for the Csound plugin directory; the older
  `OPCODEDIR`/`OPCODEDIR64` variables were dropped.
* The local `csound_threaded_csqt.hpp` keeps `CsoundHtmlOnlyWrapper` working
  with Csound 7.

### Reorganisation and removed features
* **PythonQt support removed**.
* **Live Event Sheets removed** (live coding now uses live code evaluation and
  the Scratch Pad).
* New icon and new splash screen; the About dialog and logo were refreshed.

### User interface
* **Dark / light themes**: comprehensive dark-theme support across editor,
  console, widgets, table editors and the virtual keyboard; a new colour theme
  menu allows runtime switching, and CsoundQt can automatically follow the
  system light/dark preference (theme switching works best outside Windows).
* **Editor**: syntax highlighting improvements for Csound 7 and for the new
  split view (orchestra/score), highlighting of `@global` variables and `@` as a
  word delimiter, improved word completion (works on any word, e.g. instrument
  names; better boundaries inside quotes/parentheses), a **Show/Hide editor**
  action (**Ctrl/Cmd+0**), and automatic **reload when the file changes**
  externally.
* **Open by drag & drop** of `.csd` and other supported files onto the window.

### Performance

* Large optimisations in channel handling: a hash map from channel names to
  widgets replaces the previous linear scans; `outvalue` / `invalue`
  and string channels are now much more efficient and only changed values are
  written per control cycle. 

* `chn_` declarations are no longer needed for
  control channels. 
  

### Other
* **Windows**: `windeployqt6`, Fusion style forced for a consistent look, UTF-8
  encoding fixes for non-ASCII characters.
* **\*BSD / OpenBSD**: library detection and default executable definitions
  added; `runInTerm` made more portable; `examplePath`/`templatePath` resolved
  correctly on all platforms.
* GitHub Actions CI was introduced for automated macOS/Linux builds.

---

### Known issues and notes
* CMake build support is still under development; the supported build system is
  qmake (`qcs.pro`).
* Text selection in the litehtml viewer is run-granularity (not
  character-precise), a known trade-off.

Please report any issues on the
[CsoundQt GitHub repository](https://github.com/CsoundQt/CsoundQt/issues).
