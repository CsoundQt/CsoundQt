# Changes to CsoundQt7

CsoundQt 1.x is the bugfix series for the current CsoundQt, designed to work
with Csound 6. It is based on Qt 5 but can also be built with Qt 6 from the
`Qt6` branch. The main branch is `develop`; the `master` branch is used for
releases of CsoundQt 1.x.

CsoundQt 7 requires Qt 6 and Csound 7. The main branch is `csoundqt7`.
Development is done in separate branches or via pull requests, merging when
ready.

## User-facing changes
- Support for Csound 7 (no syntax highlighting changes yet)
- Removed PythonQt
- Removed Live Event Sheets (replaced by live code evaluation and Scratch Pad)
- New icon and splash screen
- More to come

## Building
- Check out the `csoundqt7` branch:
  https://github.com/CsoundQt/CsoundQt/tree/csoundqt7
- CMake support is in progress but not yet ready
- If Csound 7 is not installed in the usual path, use `config.user.pri` (for
  qmake builds) to set it. For example:
  ```
  CSOUND_LIBRARY_DIR=~/.local/lib
  CSOUND_INCLUDE_DIR=~/.local/include/csound/
  ```
- Requires Qt 6 (tested with Qt 6.5)
- The new option to build with HTML support is `CONFIG+=html_support`
  (previously `html_webengine` or `html_webkit`). WebKit support has been
  dropped.

## Changes in the code

- Porting to Qt 6: see the `Qt6` branch:
  https://github.com/CsoundQt/CsoundQt/tree/Qt6
- Csound 7-related changes: see the `csound7` branch:
  https://github.com/CsoundQt/CsoundQt/tree/csound7
- Initial work on CMake support:
  https://github.com/CsoundQt/CsoundQt/tree/cmake_support
- Renamed *qutecsound* throughout:
  - The main source file `qutecsound.cpp/h` is renamed to `csoundqt.cpp/h`
  - Macros are renamed from `QCS_something` to `CSQT_something`
  - Settings are now handled as `QSettings("csoundqt", "csoundqt")`
    (was: `"csound"`, `"qutecsound"`. On Linux this means the config file is
    at `~/.config/csoundqt/csoundqt.conf`)
  - Icons are named `csoundqt.png` and `csoundqt.svg` (was: `qtcs.png`)
- Use the `OPCODE7DIR64` environment variable for plugins. Dropped support for
  `OPCODEDIR64` and `OPCODEDIR`.
- To keep `CsoundHtmlOnlyWrapper` functional, `csound_threaded.hpp` was copied
  from the Csound 6 sources and adapted for Csound 7. The local file is
  `csound_threaded_csqt.hpp`. It is no longer maintained in the Csound 7
  source. In the future, this file should be replaced in favor of
  `CsoundEngine`.
- Fixed most warnings and problems reported by code analysis

Due to the many changes, CsoundQt may be less stable but is functional.
