<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 512
nchnls = 2
0dbfs = 1

zakinit 2, 2

instr 1
asig inch 1
krms rms asig, 3

outvalue "rms", krms
endin


</CsInstruments>
<CsScore>
i 1 0 3600

</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>386</width>
 <height>281</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>rms</objectName>
  <x>82</x>
  <y>25</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a80824ce-6415-4b0d-a929-e397f58d781d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.013</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
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
  <x>15</x>
  <y>55</y>
  <width>221</width>
  <height>84</height>
  <uuid>{7ed3476c-86ea-4636-90b9-f401e8a1ed41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>This has to be here as a bridge between Csound and the QuteCsound python API, which reads values from widgets, not from Csound.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 886 250 98 28
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView nobackground {59367, 11822, 65535}
ioText {82, 25} {80, 25} display 0.012531 0.00100 "rms" left "Arial" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder 0.013
ioText {15, 55} {221, 84} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder This has to be here as a bridge between Csound and the QuteCsound python API, which reads values from widgets, not from Csound.
</MacGUI>
