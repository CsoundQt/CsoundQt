# CsoundQt 7.0.0-beta3 Release Notes

<br>

*<small>Written by Github Copilot Agent. Edited by Tarmo Johannes</small>*


**CsoundQt 7.0.0-beta3** continues the stabilization and feature work started in beta1, bringing new editor workflow features, an integrated help panel, improved theming, and numerous portability and stability fixes.

The source and upcoming binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/v7.0.0-beta3>.

<br>

## New Features

### Integrated Csound Manual Panel
* **HTML help dock**: The Csound 7 HTML manual can now be displayed in a dockable panel inside CsoundQt, powered by QWebEngineView. Download the prbuilt manual from CsoundQt release page,if needed, and set the manual path in preferences and browse documentation without leaving the editor.On brebuilt bundles manual will be included.

### Auto-reload on External Changes
* **Automatic file reload**: When a `.csd` file is modified on disk by an external editor or tool, CsoundQt detects the change and offers to reload the file automatically. Can be useful when working with some AI helper in VS Code, Claude Code or any other of your favourite editors.

### Show / Hide Editor
* **Toggle editor panel**: A new toolbar button (and shortcut **Ctrl/Cmd+0**) lets you hide the text editor to show only the necessary panels, and bring it back with the same action. It can be usefyl when working with an external editor.
* **Proper resize behaviour**: The main window and other panels resize correctly when the editor is toggled.



### Drag and Drop
* **Drop files to open**: `.csd` and other supported files can now be opened by dragging them onto the CsoundQt window.

<br>

## User Interface Improvements

### Theme and Color Refinements
* **Theme-agnostic widget colors**: Colors for the text component of widgets (based on QuteText), Knob widget and hover-frame are now derived from the active palette. The suitable colours are offered on creating new widgets, existing widgets keep the colours as defined.


### Syntax Highlighting
* **Csound 7 highlighting**: Begun improvements to syntax highlighting to cover new Csound 7 opcodes and constructs.
* **`@global` detection**: Global variables declared with `@global` are now recognised and included in word completion and highlighting.
* **`@` as word delimiter**: The `@` character is treated as a word boundary so that completions and double-click selection work correctly around variable names.

### Toolbar and Buttons
* **Clearer checked state**: Toolbar toggle buttons (such as Run, Record, etc.) now have a more visible stylesheet to indicate their active/checked state (Windows/MacOS).

### Editor and Font
* **Increase/Decrease font in View menu**: Font zoom actions are now accessible from the **View** menu in addition to the existing keyboard shortcuts.

### Examples
* **Examples are read-only**: All built-in examples are now opened as read-only, preventing accidental overwrites via "Save" instead of "Save As".

<br>

## Bug Fixes

### Stability
* **Crash fix — graph display**: Added bounds check for `graphtypes` to prevent a crash when displaying function table graphs.
* **Crash fix — tab close**: Focus is now cleared before a document tab is removed, avoiding a rare crash on tab close.

### Editor
* **Shift-F1 (open manual entry)**: Fixed opening the manual entry for the opcode under the cursor from within a `.csd` file for Csound 7 manual.
* **Window resize on editor toggle**: Editor show/hide no longer leaves incorrect window geometry.
* **Icon color on toggle**: Editor toggle icon now reflects the correct color in dark and light themes.

### MacOS
* **Audio input fixed**: Added the required microphone entitlement so audio input now works in signed/notarized builds.
* **QWebEngine entitlements**: Corrected entitlements needed for the embedded Chromium process.
* **Install script improvements**: MacOS install and signing script updated for reliability.

<br>

## Portability and Platform Improvements

* **OpenBSD support**: Fixed csound library detection on \*BSD and added default executable defines for OpenBSD (#465, #454). Many thanks to **Raphael Graf** for this and the following commits!
* **Cross-platform paths**: `examplePath` and `templatePath` are now resolved correctly on all platforms, not just the primary build target (#456, #455).
* **Portable terminal execution**: `runInTerm` improved for better cross-platform behaviour (#459).
* **`refreshModules` cross-platform**: Moved the module refresh call into the shared CsoundQt code so it runs on all platforms.
* **Default `commandLine`**: A safe default value is now set for the `commandLine` configuration variable to avoid a potential null-access (#452).
* **Build fix**: Removed the `-v` flag from `mkdir` calls that is not available on all systems (#451).

<br>

## Build and Code Cleanup

* **perfThread removed on Windows**: CsPerformanceThread sources are no longer compiled on Windows, simplifying the build.
* **`DEFAULT_HTML_DIR` removed**: Residual constant cleaned up from the source (#462).
* **Opcode plugin directory detection improved**: More robust logic for finding the Csound plugin directory at startup (#463).
* **`perfThread` removed from `src.pri`**: Build file cleaned up.

<br>

## Known Issues and Limitations

* CMake build support is still in development; use the qmake build system (`qcs.pro`).
* Dynamic theme switching does not work well on Windows.
* Some Csound 7 syntax highlighting improvements are still in progress.

<br>

## Acknowledgments

Special thanks to all community members who submitted pull requests and bug reports! Thanks to everyone who tested, reported issues, or provided feedback!

---

**Note**: This is a beta release intended for testing and feedback. Please report any issues on the [CsoundQt GitHub repository](https://github.com/CsoundQt/CsoundQt/issues).
