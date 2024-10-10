# CsoundQt 1.1.3 release notes

Version 1.1.3 is a elease with minor improvements.

The source and binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/v1.1.3>.


### New features

* Resize font in Editor and Help panel with system's ZoomIn/ZoomOut shortcut (Ctrl/Cmd + Plus/Minus)
* Line and columen number indicator in Status bar. Column number turns red, when above 80.
* Wordcomplete acts on any words (like instrumen names etc), not only keywords and variable.
* Updated Russian translation (by Gelb Rogozinski).

### Fixes/optimizations

* Protect Spinboxes with unsetLocale() to avoid Chinese numbers
* Fixed Github Action for MacOS automatic build.
* Fixed About dialog colors in Dark mode.
* If html is in nonwritable location (like examples installed on Linux), save working copy to tempoaray folder.



Tarmo Johannes
