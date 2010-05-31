<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This file introduces the Live Event Panels of QuteCsound
; First Run this file!
; Then open the Live Event Controller window from the View Menu
; (If it's not currently at the front, you may need to hide it first and then show it)
; You can play the contents of the panels by clicking on the play buttons
; Alternatively, you can show the panels, to control events individually
; Right click there on the cells to see actions.
; Try the "Send events" action when standing over one of the event lines

instr 1 ;simple sine wave
ifreq = p4 ; in cps
iamp = p5 ; in relation to 0dbfs
iatt = p6 ; in seconds
idec = p7 ; in seconds
aenv linenr iamp, iatt, idec, 0.01
aout oscil aenv, ifreq, 1
outs aout, aout
endin

instr 2 ;saw wave
ifreq = p4 ; in cps
iamp = p5 ; in relation to 0dbfs
iatt = p6 ; in seconds
idec = p7 ; in seconds
aenv linenr iamp, iatt, idec, 0.01
aout vco2 1, ifreq
outs aout*aenv, aout*aenv
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
e 3600
</CsScore>
</CsoundSynthesizer>









<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>517</x>
 <y>162</y>
 <width>544</width>
 <height>383</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground" >
  <r>230</r>
  <g>221</g>
  <b>213</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>17</x>
  <y>65</y>
  <width>502</width>
  <height>146</height>
  <uuid>{723c1401-6b94-4801-8d2c-3e08afd5745d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>; This file introduces the Live Event Panel of QuteCsound
; First Run this file!
; Then open the Live Event Controller window from the View Menu
; (If it's not currently at the front, you may need to hide it first and then show it)
; You can play the contents of the panels by clicking on the play buttons
; Alternatively, you can show the panels, to control events individually
; Right click there on the cells to see actions.
; Try the "Send events" action when standing over one of the event lines
</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Play</objectName>
  <x>110</x>
  <y>305</y>
  <width>318</width>
  <height>29</height>
  <uuid>{8e38fdf7-2bf5-4ff2-9c18-d280d0bb4925}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Run</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>17</x>
  <y>9</y>
  <width>503</width>
  <height>47</height>
  <uuid>{66aa869b-be3d-4a31-8c24-9c44edff9877}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Event Panels</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>127</r>
   <g>190</g>
   <b>190</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>17</x>
  <y>215</y>
  <width>503</width>
  <height>78</height>
  <uuid>{aedbddec-77b7-4279-9427-89c3b74288c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Note that you can send individual events, setting independent tempos for each panel.
You can also set a loop range for each panel, and loop each panel independently.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <objectName/>
 <x>517</x>
 <y>162</y>
 <width>544</width>
 <height>383</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 517 162 544 383
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView nobackground {59110, 56797, 54741}
ioText {17, 65} {504, 224} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ; This file introduces the Live Event Panel of QuteCsoundÂ¬; First Run this file!Â¬; Then open the Live Event Controller window from the View MenuÂ¬; (If it's not currently at the front, you may need to hide it first and then show it)Â¬; You can play the contents of the panels by clicking on the play buttonsÂ¬; Alternatively, you can show the panels, to control events individuallyÂ¬; Right click there on the cells to see actions.Â¬; Try the "Send events" action when standing over one of the event linesÂ¬
ioButton {110, 305} {318, 29} value 1.000000 "_Play" "Run" "/" 
ioText {17, 9} {503, 47} label 0.000000 0.00100 "" center "DejaVu Sans" 22 {0, 0, 0} {32512, 48640, 48640} nobackground noborder Event Panels
ioText {17, 215} {502, 146} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Note that you can send individual events, setting independent tempos for each panel.Â¬You can also set a loop range for each panel, and loop each panel independently.
</MacGUI>
<EventPanel name="Demo 1" tempo="60.00000000" loop="8.00000000" x="616" y="297" width="603" height="374" visible="false" loopStart="0" loopEnd="7">        
i 1 0 1 440 0.2 0.3 1 
i 1 0 1 880 0.2 0.3 1 
i 1 0 1 220 0.2 0.3 1 
; You    ;can    ;label   ;columns     
i 1 0 1 220 0.2 0.3 1 
i 1 1 1 220 0.2 0.3 1 
i 1 2 1 220 0.2 0.3 1 
; Have ;a ;look  ;at the  ;text ;view   
        </EventPanel>
<EventPanel name="Demo 2" tempo="60.00000000" loop="8.00000000" x="380" y="178" width="762" height="583" visible="false" loopStart="0" loopEnd="0">        
i 1 0 1 440 0.2 0.3 1 
i 1 0 1 880 0.2 0.3 1 
i 1 0 1 220 0.2 0.3 1 
        
i 2 0 1 220 0.2 0.3 1 
i 2 1 1 440 0.2 0.3 1 
i 2 2 1 880 0.2 0.3 1 
        
i 2 0 5 440 0.2 0.3 1 
;off        
;You     ;can use    ;negative    ;p1    ;to    ;turn    ;off    ;notes 
        
        
        </EventPanel>
