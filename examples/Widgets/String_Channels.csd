<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1 ; Schedule triggering of the instruments
	event_i "i", 2, 0, 1
	event_i "i", 3, 2, 1
	event_i "i", 4, 4, 1
endin

instr 2
	outvalue "text", "hello"
	turnoff
endin

instr 3
	outvalue "text", "world!"
	turnoff
endin

instr 4
	outvalue "text", ""
	turnoff
endin

</CsInstruments>
<CsScore>
f 0 3600
i 1 0 1

</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>577</x>
 <y>221</y>
 <width>200</width>
 <height>161</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName>text</objectName>
  <x>38</x>
  <y>24</y>
  <width>120</width>
  <height>60</height>
  <uuid>{a22f0ffb-eb18-498f-bcf6-5f224cf453f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>32</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>221</r>
   <g>218</g>
   <b>185</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>5</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>45</x>
  <y>94</y>
  <width>100</width>
  <height>40</height>
  <uuid>{d43733ec-7666-41ef-9791-c8a4243a970f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Do it again!</text>
  <image>/</image>
  <eventLine>i1 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <objectName/>
 <x>577</x>
 <y>221</y>
 <width>200</width>
 <height>161</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {38, 24} {120, 60} display 0.000000 0.00100 "text" center "Arial" 32 {0, 0, 0} {56576, 55808, 47360} nobackground noborder 
ioButton {45, 94} {100, 40} event 1.000000 "button1" "Do it again!" "/" i1 0 1
</MacGUI>
