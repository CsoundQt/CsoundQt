# CsoundQt 0.9.8 release notes

Version 0.9.8 is a major release, with multiple changes

The source and binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.8>.

### New in version 0.9.8:

* New icon theme based on KDE's "breeze"
* New color themes (for text, background and syntax highlighting): classic, light, dark.
* New look and features for the knob widget.
* New "Table Plot" widget allows to efficiently plot tables in real time.
* Graph widget has been highly optimized, drawing is between 10x and 20x faster,
  depending on how many widgets are used
* Graph widget fixed for the use together with display opcode. Many display instances can be used simultaneusly for one or multiple widgets without any loss in performance.
* Spectrogram widget now reacts to different sample rates, gained a better grid and zoom. Also grid and selecting combobox can be hidden.
* Meter / Controller widget gained many options to control its aspect (border, line width, background, etc)
* New action to test the audio setup
* Text labels allow to set a vertical alignment
* New settings dialogs, allows to use the current system sample rate and set the
  number of channels without the need to modify the .csd
* Help panel recieved a more streamlined look
* New icon / new splashscreen
* More streamlined toolbar, removed toolbar buttons which are for more expert use
  (these can still be reached from the menus), icon size can be set in the preferences.
* Many widgets gained the possibility to set their value by double-clicking (knob, scroll number)
* Now it is possible to move the widgets with the keyboard in edit mode. The arrow keys move the
  widgets within a grid of 5 pixels (with the alt key widgets are nudged by 1 pixel)
* More nuanced syntax highlighting
* Syntax highlighting for user defined opcodes. The work for this lays the ground for features like autocomplete and code hints for udos.
* Graph widget for tables optiized for big tables (soundfiles),  now detects the actual size of the graph and does not draw superfluous points
* Button widget can set the size of the font
* Checkbox can be resized if the platform allows this (works on linux and windows, macOS uses native checkboxes which are fixed in size)
* Added a setting to control the update rate of the gui
* Graph widget (Spectrogram) can control the zoom with keyboard shortcuts (+, -). Also scrollbars can be hidden (user can scroll with scrollwheel/arrow keys)

### Fixes

* Race condition fixed which would cause CsoundQt to crash when started/stopped in very fast succession
* Locking issues fixed which prevented CsoundQt to stop properly when a graph widget was used.
* Saving issues where fixed. New option to prevent CsoundQt from asking if user wants to save a temporary file before playing.
* in macOS startup delay has been somewhat reduced.
* Wrong rendering for the Meter / Controller widget fixed is macOS
* Better font defaults for the different platforms
* CTRL-F now searches in manual if help dock is focused.
* Search bar is made visible and focused when clicked on search icon in the help widget
* Fixed a bug where activating the widgets panel when the widgets are in a separate window would
  result in an empty widgets panel or, worse, a crash.
* Fixed selection and dragging of widgets. Now responds to usual keyboard modifiers, such as CTRL toggling selection, and shift adding an item to a selection, etc.
* Changing rt audio module now clears the device selection
* Fixes last used dir in linux falling back to /tmp
* macOS: fix to background color in widgets panel
* Better options for selecting an audio device if jack is selected as module (now the default does not connect to other ports other than the system)
* In the config dialog, if jack is not running then this is shown in the menu and jack can't be selected
* scope now has much lower latency
* native toolbar in macOS
* Less instrusive line numbers, adjust colors to the color theme
* Each platform has own defaults for fonts, sizes, etc., resulting in a better first time experience

Eduardo Moguillansky
