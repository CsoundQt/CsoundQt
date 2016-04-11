# CsoundQt 0.9.2.1 released 

This is first bug-fix release to CsoundQt version 0.9.2. Next to numerous improvements and corrections there are also some new features.

The source and upcoming binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.2.1>.


### New in version 0.9.2.1:

* **Run as temporary file** dialog: when user creates a new file (displayed as *default.csd*) and runs it first time, it is possible now to run the file immediately as a temporary file (without going through the *Save as* dialog). Of course one can choose also to save the file with given name. It is useful when trying out snippets, checking code from mailing list posts etc.

* **Create a shareable OSX bundle** with *make install*. An install target is added to *qcs.pro* that deploys all necessary libraries and other components to the CsoundQt app bundle in *bin* folder of the build directory so it is possible to share the built application to other OSX computers. Just navigate to the build directory (where *Makefile* is generated) and run

>	`$ make install`


*NB! Csound framework is not included in the bundle (to avoid conflicts with system installation) -  Csound must be installed separately!*

* Johannes Schütt has prepared also a script that will make a nice installation bundle on OSX ( *bin/build-deploy-csoundqt-osx.sh* )

* **Scanned Synthesis Sandbox** - a demo and tool to learn and try out scanned synthesis using *scanu* opcode. Placed in menu Examples -> Synths.

### Fixes

* Better install target and script for Linux install (by Felipe Sateler)

* Fix for OSX architecture detecting problem in *qcs-macx.pro*. Now x86_64 is default, i386 or universal can be set with `CONFIG+=<architecture\>`

* Scripts ad Examples are added automatically to OSX app.

* Added install target for extended examples (Floss Manual, McCurdy Collection, Stria Synth). Now installed to */usr/share/qutecsound/Examples* with `make install` (Linux)

* Csound Manual is found automatically (if installed with "official" installer), even if the path is not set in configuration (Linux, OSX, Windows).

* Improved highlighting rules (instrument names and macro names are not highlighted any more as k- i- S- etc variables) -  thanks to Joachim Heintz

* Fixes in configuration files for Windows build

* Fix for clean shut-down, if built with html5 support

* Fixes for building with rtmidi in Windows 64-bit build

* Added missing toolbutton for OPCODE6DIR64 in Configuration -> Environment.

### Miscellaneous

* Better documentation on CsoundQt web-page
<http://csoundqt.github.io/pages/documentation.html> (thanks to Joachim Heintz)

* Wiki page for building CsoundQt on Windows (currently 32-bit build):
<https://github.com/CsoundQt/CsoundQt/wiki/Building-on-Windows-with-QtCreator>

* Bundleing script (OSX) and necessary files in source tree *bin* folder (by Johannes Schütt) - it will be used also for nightly builds and OSX installers in future.

* Improvements in BUILDING.md

<br>		

Tarmo Johannes trmjhnns@gmail.com