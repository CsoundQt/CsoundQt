# CsoundQt 0.9.8 release notes
 

version 0.9.8 is a major release, with multiple changes

The source and binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.8>.

### New in version 0.9.8:

* New icon theme based on KDE's "breeze"
* Graph widget has been highly optimized, drawing is between 10x and 20x faster, 
  depending on how many widgets are used
* New look and features for the knob widget
* New "Table Plot" widget allows to plot tables in real time. 
* Meter / Controller widget gained many options to control its aspect (border, line width, background, etc)
* New action to test the audio setup
* Text labels allow to set a vertical alignment
* New settings dialogs, allows to use the current system sample rate and set the
  number of channels without the need to modify the .csd
* Help panel recieved a more streamlined look
* New icon / new splashscreen
* More streamlined toolbar, removed toolbar buttons which are for more expert use 
  (these can still be reached from the menus)
* Many widgets gained the possibility to set their value by double-clicking (knob, scroll number)
* Now it is possible to move the widgets with the keyboard in edit mode. The arrow keys move the widgets
  within a grid of 5 pixels, with the alt key widgets are nudged by 1 pixel
 
### Fixes

* Race condition fixed which would cause CsoundQt to crash when started/stopped in very fast succession
* Wrong rendering for the Meter / Controller widget fixed is macOS
* Better font defaults for the different platforms
* CTRL-F now searches in manual if help dock is focused. 
* Search bar is made visible and focused when clicked on search icon in the help widget


--------------------------


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





