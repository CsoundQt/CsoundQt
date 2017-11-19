# CsoundQt 0.9.5 released
 

version 0.9.5 fixes a number of bugs and adds some new convenience features.

The source and binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.5>.

Please note that from 0.9.2 on there is **develop branch** in CsoundQt's repository for latest improvements and fixes. For instructions how to check out the branch see  
<https://github.com/CsoundQt/CsoundQt/wiki/Checking-out-develop-branch>

### New in version 0.9.5:

* **New principles and shortcuts to handle document tabs and other panels** 

**_NB! You must reset keyboard shortcuts to defaults to activate those!_ **

-- Document tabs can be switched by pessing Alt-1, Alt-2 etc, as in most browsers; Alt-Left and Alt-Right move the active tab accordingly to left or right

-- The principle of opening/closing/raising Help, Widgets and other panels has changed:

Next to "Show/Hide panel" as action button on the toolbar or entries in "View" menu, there is now also action "Show/Raise panel". The reason is to be able to quickly switch between panels, if they are docked into the same area. For example if you have Widgets and Help panel set to the same size and same area, it is comfortable to raise the one you need and not to always open/close them one by one.

The behaviour is different when the panel is docked or not: - if the panel is floating (separate window) - the shortcut opens or closes the panel; if docked, it raises it to on top if it is covered, opens if it closed or does nothing if it is visible.

The new shortcuts for the according panels are:

>- Crtl-1 (Cmd-1 on Mac): widgets
- Ctrl-2: help (manual)
- Crtl-3: console
- Crtl-4: html view (for next releases)	
- Crtl-5: inspector
- Crtl-6: live event sheets (always separate window)
- Crtl-7: python console
- Crtl-8: code pad
- Crtl-9: Csound utilities

To open/close a panel, you can still use the button on toolbar or entry in View menu.

There are also shortcuts to bring some panels to fullscreen. This feature needs more work, always bring a panel back from fullscreen to normal before you change to other panel in fullscreen.

> - Crtl-Alt-0 (Cmd-Alt-0 on Mac): toggle editor full screen
- Crtl-Alt-1: toggle widgets full screen
- Ctrl-2: toggle manual full scrren
- Crtl-4: toggle html view full screen (for next releases)	

To activate the new shortcuts, you must reset the shorcuts in *Edit->Set Keyboard Shortcuts->Restore Defaults* or set them in the shortcuts editor by your own preference.

* All text based widgets (Labels, Display, Scrollnumber etc) can have now very big fonts (max size 999).

### Fixes

* "Run in terminal" works now on Windows (since 0.9.4.1)

* Fixed copy-and paste issue on Windows

* Recording now works on Windows

* Fixed opening csd files from manual on Windows

* Fixed missing "close tab button" on MacOS

* Corrected conditions in install script on Linux

* Fixes and improvements in several examples

* Examples (files beginningg with :/examples) can be started with "Run in terminal" now.

Tarmo Johannes
trmjhnns@gmail.com





