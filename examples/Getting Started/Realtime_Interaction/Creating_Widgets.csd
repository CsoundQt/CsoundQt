/* Getting Started .. Realtime Interaction: Widgets

Qutecsound's Widgets provide a quick and easy way to build your customised GUI to communicate with csound's synthesis engine in realtime. 
To make the Widgets-Panel visible, click the Widgets symbol in the menu or press (Alt+1).

*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
;Nothing here...
endin
</CsInstruments>
<CsScore>
e
</CsScore>
</CsoundSynthesizer>
; written by Andres Cabreras 



<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 520 169 429 450
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 6} {210, 39} label 0.000000 0.00100 "" left "Helvetica" 24 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Widgets
ioText {14, 45} {373, 66} label 0.000000 0.00100 "" left "Helvetica" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder You can create Widgets by right-clicking (or control-clicking on OS X) anywhere in the Widget Panel where there are no widgets. Try it here:
ioText {11, 322} {392, 84} label 0.000000 0.00100 "" left "Helvetica" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border You can delete widgets by right-clicking the Widgets and selecting delete. Using this menu or the keyboard commands, you can also copy, paste, cut and duplicate widgets.
ioText {14, 234} {371, 62} label 0.000000 0.00100 "" left "Helvetica" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border You can move and resize widgets by entering the EDIT MODE, pressing Ctrl+E or Command+E on OS X.
</MacGUI>


<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" name="Events" x="320" y="218" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>
