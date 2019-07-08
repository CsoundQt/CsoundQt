# CsoundQt 0.9.6 release notes
 

version 0.9.6 introduces **HTML support** on all supported platforms, enables **exporting widgets to QML code** (to be used with [CsoundRemote](https://github.com/tarmoj/CsoundRemote/)) and   fixes a number of bugs.

The source and binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.6>.


### New in version 0.9.6:

* **HTML support** 

Support for HTML is available now on Windows, MacOS and Linux (before it was realized only on Windows). It is based by default on QtWebEngine technology that uses Chromium engine as its core.   With older Qt versions (before Qt 5.6)  Html support can be built using QtWebKit, but this is not suggested solution.  

To build CsoundQt with HTML support, use one of the following flags in your qmake options (or put it to config.user.pri file):

	CONFIG+=html_webengine # (preferably use Qt 5.8 or later) 
	
or

	CONFIG+=html_webkit #  (Qt 5.5 or earlier)

Html code can be used within csd file or the as an complete html file that uses Csound via Csound api - similar to [WebAudio Csound](https://vlazzarini.github.io/paw/examples/index.html) or [Csound on Node.js](https://www.npmjs.com/package/csound-api). 

To get started, see **Examples-> Html5 support**

Documentation: <http://csoundqt.github.io/pages/html5-support.html> 

There are also two **new templates** accessible via **File->Templates menu**: *cound+html-template.csd* and *csoundqt-or-webcsound-template.html*.  The latter helps to write html files that work both in CsoundQt and on web (using WebCsound javascript API).

*NB!* The installer package on Windows and MacOS is now considerably bigger since it has to include the QtWebEngine core.

Essential part of the code for HTML support is written by **Michael Gogins**. Thanks!

* **Export widgets as QML code**

Via *File->Export Widgets to QML* menu not yet all, but the main CsoundQt widgets can be converted to QML code. This is useful to export the user interface to separate device that controls Csound using UDP messages with the help of application [CsoundRemote](https://github.com/tarmoj/CsoundRemote/)). More information: <https://github.com/tarmoj/CsoundRemote/blob/master/README.md> 

* New translations to Korean, Persian and Turkish, several translations updated (Thanks to Joachim Heintz)

* Added "Midi Learn"  to widgets' context menu.


### Fixes

* Improvements to Linux intall rules

* Added support to use system rtmidi (Linux)

* Support for PythonQt 3.2 and RtMidi 3.0

* Correct highlighting for // comment mark

* Correct "Download manual" link

* Fixes and improvements to Floss Manual and several other examples

* _Start _Stop and other reserved channels' wisgets work also now via rtmidi (using midi controller).

* Support for Retina and HDPI screens.

* Highlighting for .udo files

* Added .udo, .inc and .html to known files in file dialogs and allow opening from file manager (corrected mime-types on Linux).

* Improvements to sensekey support -  now keys (like arrow keys) with several bytes of ANSI key sequence are handled.

* Workaround for mysterious bug to round floating point division on first run (9/4 = 2.0).

* Fixed crash on running .orc file when there is no .sco. Now orc without score can be run as scoreless csd.

* Better Midi Learn dialog, added Set/Cancel buttons, fixed crash on assigning MIDI slider/knob to button, spinbox and similar.


Tarmo Johannes
trmjhnns@gmail.com





