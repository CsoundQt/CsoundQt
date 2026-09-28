# CsoundQt 0.9.2.2 released 

This is second bug-fix release to CsoundQt version 0.9.2. There is one important and numerous minor fixes. 
The source can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.2.2>.



### Fixes

* Fixed serious error on Linux that made CsoundQt crash when STK-opcode plugin was present but RAWWAVE_PATH was not set (typical when Csound was installed with package manager).

* Work and improvements on html5 support (Michael Gogins)

* Fixed build failure with Csound debugger enabled (Felipe Sateler)

* Work on different examples + some new examples (Joachim Heintz)

* Fixed Configuration dialog resizing so it cannot be out of screen any more

* Fixed crash on closing first tabs and using midi (midi-listeners' corrected removal, issue #211)

* Corrected auto-completion of functions (like int, ampdb etc issue #214)

* Removed (most of) lines causing "Slot not found" messages in command line output.

### Miscellaneous

* Thorough documentation on CsoundQt web-page
<http://csoundqt.github.io/pages/documentation.html> (by Joachim Heintz)

* Link to the documentation in Help menu (shortcut F1)
<br>		

Tarmo Johannes trmjhnns@gmail.com