# CsoundQt 0.9.7 release notes
 

version 0.9.7 is mainly bug fix release. 

The source and binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.7>.


### New in version 0.9.7:

* Includes new version of Stria Synth (v30a) by **Eugenio Giordani** (Examples->Synths->Stria Synth)

* Added support to export following widgets to Qml: display, combobox, checkbox, meter  

* Support for rtmidi 4.0

* Preparations for AppImage build (universal package for different Linuxes).
<br>


### Fixes

* More careful way to store settings -  hopefully fixes problem on MacOS when prefernces file was corrupted now and then (icons disappeared and similar)  

* Storing/restoring window size on MacOS fixed

* Fixed problems in Linux install rules, now builds also for FreeBSD packaging system

* Fixed accessing templates from File->Templates menu

* Better workaround for mysterious bug to round floating point division on first run (9/4 = 2.0) on Linux.

* Improvements and fixes in examples (by Joachim Heintz)




Tarmo Johannes
trmjhnns@gmail.com





