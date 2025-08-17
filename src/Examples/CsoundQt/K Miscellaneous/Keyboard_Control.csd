<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This example shows the usage of sense key to use the ascii keyboard
; as a keyboard to play notes. It uses an always on instrument (1), which
; listens to key events and turns on and off notes.
; It is important to give focus to the main Csound Output Console (giving focus
; to a console widget will not work!).
; Note that key press auto-repeats are discarded!


; This table calculates the pitch values for the ascii key codes
; Using shift or caps lock will raise 2 octaves (except for the numbers)

giascii ftgen 0, 0, 256, -17, 0,0, \
	48, 9.03, 49, 0, 50, 8.01, 51, 8.03, 52, 0, 53, 8.06, 54, 8.08, \
	55, 8.10, 56,0, 57, 9.01, \
	65, 0, 66, 9.07, 67, 9.04, 68, 9.03, 69, 10.04, 70, 0, 71, 9.06, 72, 9.08, \
	73, 11.00, 74, 9.10, 75, 0, 76, 0, 77, 9.11, 78, 9.09, 79, 11.02, 80, 11.04, \
	81, 10.00, 82, 10.05, 83, 9.01, 84, 10.07, 85, 10.11, 86, 9.05, 87, 10.02, \
	88, 9.02, 89, 10.09, 90, 9.00, \
	97, 0, 98, 7.07, 99, 7.04, 100, 7.03, 101, 8.04, 102, 0, 103, 7.06, 104, 7.08, \
	105, 9.00, 106, 7.10, 107, 0, 108, 0, 109, 7.11, 110, 7.09, 111, 9.02, 112, 9.04, \
	113, 8.00, 114, 8.05, 115, 7.01, 116, 8.07, 117, 8.11, 118, 7.05, 119, 8.02, \
	120, 7.02, 121, 8.09, 122, 7.00

instr 1 ;always on, sensing key events
kres,kkeydown sensekey

ktrig changed  kres, kkeydown

if ktrig == 1 then 
	printks "kres %i. kkeydown %i\n", 0, kres, kkeydown
endif

kpch table kres, giascii
if kkeydown == 1 then
	Smessage sprintfk "Key pressed. Code = %i", kres
	outvalue "data", Smessage
	event "i", 2 + (kpch/100), 0, -5, kpch 
elseif (kkeydown == 0 && kres != -1) then
	turnoff2 2 + (kpch/100), 4, 1
	Smessage sprintfk "Key released. Code = %i", kres
	outvalue "data", Smessage
endif
endin

instr 2  ;actual synth. Put anything here
iamp = 0.2
iatt = 0.03
idec = 0.01
irel = 1.3
ifreq = cpspch(p4)
print ifreq
if ifreq < 20 then
	turnoff
endif
kenv madsr iatt, idec, 0.6, irel
asig vco2 kenv*iamp, ifreq
asig moogladder asig, ifreq*2, 0.8
outs asig, asig
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>294</width>
 <height>189</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>85</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>52</y>
  <width>289</width>
  <height>104</height>
  <uuid>{b7cc6e90-2fe6-429e-a4c2-59bece5d87ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The sensekey opcode can be used to receive keyboard action. It is VERY  IMPORTANT to click on the Dock Console or the Widget Panel to give it focus, otherwise key events will NOT be passed to Csound.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>11</y>
  <width>287</width>
  <height>37</height>
  <uuid>{4cd046a0-3748-49fd-b4da-b1fe395b72dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Keyboard control</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>97</r>
   <g>194</g>
   <b>144</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>data</objectName>
  <x>46</x>
  <y>163</y>
  <width>198</width>
  <height>26</height>
  <uuid>{9a382452-2e20-4ccd-8eb3-28a5bf34dee1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Key released. Code = 115</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
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
