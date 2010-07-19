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
; written by Andres Cabrera




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>520</x>
 <y>153</y>
 <width>429</width>
 <height>450</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>7</r>
  <g>95</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>6</y>
  <width>210</width>
  <height>39</height>
  <uuid>{ee6146d0-64e9-4c42-98da-f5d144c2d06e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Widgets</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>26</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>45</y>
  <width>392</width>
  <height>75</height>
  <uuid>{7300709a-a337-4357-8292-f78e20b003b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>You can create Widgets by right-clicking (or control-clicking on OS X) anywhere in the Widget Panel. Try it here:</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>322</y>
  <width>391</width>
  <height>113</height>
  <uuid>{62393637-5d87-4d05-978d-fa18be6cc92c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>You can delete widgets by right-clicking the Widgets and selecting delete. Using this menu or the keyboard commands, you can also copy, paste, cut and duplicate widgets.</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>234</y>
  <width>390</width>
  <height>73</height>
  <uuid>{b38cec05-f765-43a8-9353-ddc36f0b0abd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>You can move and resize widgets by entering the EDIT MODE, pressing Ctrl+E or Command+E on OS X.</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 520 153 429 450
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 6} {210, 39} label 0.000000 0.00100 "" left "Helvetica" 26 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Widgets
ioText {11, 45} {390, 92} label 0.000000 0.00100 "" left "Helvetica" 18 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder You can create Widgets by right-clicking (or control-clicking on OS X) anywhere in the Widget Panel. Try it here:
ioText {11, 322} {392, 84} label 0.000000 0.00100 "" left "Helvetica" 18 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder You can delete widgets by right-clicking the Widgets and selecting delete. Using this menu or the keyboard commands, you can also copy, paste, cut and duplicate widgets.
ioText {14, 234} {371, 62} label 0.000000 0.00100 "" left "Helvetica" 18 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder You can move and resize widgets by entering the EDIT MODE, pressing Ctrl+E or Command+E on OS X.
</MacGUI>
<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
