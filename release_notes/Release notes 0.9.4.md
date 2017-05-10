# CsoundQt 0.9.4 released
 

version 0.9.4 fixes a number of bugs and adds some new convenience features. The author of most of the commits is **Tarmo Johannes**, the full-screen option of different panels has been written by **Michael Gogins**. 

The source and upcoming binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.4>.

Please note that from 0.9.2 on there is **develop branch** in CsoundQt's repository for latest improvements and fixes. For instructions how to check out the branch see  
<https://github.com/CsoundQt/CsoundQt/wiki/Checking-out-develop-branch>

### New in version 0.9.4:

* Options are saved in runtime (closing Configuration panel or applying configuration changes, opening or creating new documents), not only on exit -  so the settings are not lost if CsoundQt crashes.

* It is possible to set different panels to full screen (editor, manual, widgets and html panels) especially useful for smaller screens. Default shortcuts are: 
	- Crtl-Alt-0 (Alt-Cmd-0 for Mac): editor
	- Crtl-Alt-1: help 
	- Ctrl-Alt-2: widgets
	- Crtl-Alt-3: html panel

To activate the new shortcuts, you must reset the shorcuts in Edit->Set Keyboard Shortcuts->Restore Defaults or set them in the shortcuts editor by your own preference.

* Handling Live Event Sheet windows is more flexible: you can open the  LE controller, create or open necessary LE sheets, then close LE conroller and keep working with the LE windows as you need.

* In Confiiguration->Editor there is now an option to set editors background colour. The same colour is used also for Inspector, Scratchpad and Python Console panel. The font-color of editor cannot be changed (for now) due to fixed higlighting colors of different keywords.   The background color of Console panel can be set from Configure->General.

* "Add chn_k declaration" in widgets' cotext menu - now it easy to add the chn_k lines for widget's channel to be used with chnget/chnset opcode.

* Added support for jack midi

* Experimental support for choosing midi module for internal RT-midi (Linux only): add line 


		Run\rtMidiApi=UNIX_JACK

or

	Run\rtMidiApi=LINUX_ALSA

to configuration file `($HOME/.config/csound/qutecsound.conf)`.

### Fixes

* MIDI interfaces for CsoundQt internal MIDI are stored now by name, not port number -  this fixes error of opening wrong ports on nexts restart of the program when MIDI setting has changed. Also if the order of the MIDI devices has changed, the correct dvice is used for input/output.

* Fixed non-visible font color of widget channels on widget panel in editing mode.

* Fixed bug of black console background color on OSX 10.12

* Toolbar positions are saved and restored correctly

* Support for building with PuthonQt3.1 (OSX)

* Better switching between internal RT-midi and Csound midi modules.





