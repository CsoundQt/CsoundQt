<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This table maps menu values to vco2 oscillator modes
giwavemodes ftgen 0, 0, 8, -2, 0, 10, 12

instr 1  ;read widgets
; When values from sliders are to be used on the init pass,
; they must be read outside the instrument, because
; they are not read during the init pass
	gkwave invalue "wave"
	gkfreq invalue "freq"
	gkfreq portk gkfreq, 0.05 ;smooth frequency values
endin

instr 10
	ktrig  changed  gkwave
	if ktrig = 1 then
		; forces a new init pass from label newwaveform
		; this makes waveform change even if a note is already on
		reinit newwaveform
	endif

;The envelope is outside the reinit loop, otherwise it is reinitialized
	kenv adsr p3/5, p3/5, 0.6, p3/2

newwaveform:
	prints "instr 1-init"
	imode tab_i i(gkwave), giwavemodes ;This line is only run every init pass
	aout  vco2  0.2, gkfreq, imode ;This line must be within the reinit section
	rireturn ;End of reinit section

	outs aout*kenv, aout*kenv
endin

</CsInstruments>
<CsScore>
i 1 0 3600
f 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>375</x>
 <y>213</y>
 <width>361</width>
 <height>291</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>wave</objectName>
  <x>11</x>
  <y>8</y>
  <width>122</width>
  <height>23</height>
  <uuid>{a391e289-ce5a-454b-9817-083317d177d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>saw</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>square</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>triangle</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>137</x>
  <y>8</y>
  <width>205</width>
  <height>26</height>
  <uuid>{ae683ee8-7638-47e1-8b00-bb719111dd7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>&lt;--Select waveform from this menu</label>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>freq</objectName>
  <x>11</x>
  <y>44</y>
  <width>180</width>
  <height>20</height>
  <uuid>{0aada694-ff37-4a9b-a312-5e9fec7b6e6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>200.00000000</minimum>
  <maximum>800.00000000</maximum>
  <value>520.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>207</x>
  <y>39</y>
  <width>130</width>
  <height>25</height>
  <uuid>{f4ca4244-ba74-4152-940e-d6b763ed5666}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frequency</label>
  <alignment>left</alignment>
  <font>Bitstream Vera Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>11</x>
  <y>71</y>
  <width>180</width>
  <height>40</height>
  <uuid>{eb1f02f6-2cb9-419c-8ae6-ee9b3a8aa079}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Generate note</text>
  <image>/</image>
  <eventLine>i10 0 5</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>196</x>
  <y>69</y>
  <width>148</width>
  <height>44</height>
  <uuid>{72a619e9-5162-49f8-bc95-498c21af9846}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Push this button to generate notes</label>
  <alignment>center</alignment>
  <font>Bitstream Vera Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>10</x>
  <y>117</y>
  <width>332</width>
  <height>131</height>
  <uuid>{58f8a5b4-2172-4465-bd99-c96814d417d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
   <r>153</r>
   <g>158</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>121</x>
  <y>130</y>
  <width>91</width>
  <height>26</height>
  <uuid>{f2f1ffb7-e499-450f-ac22-a2d9d7c3cae7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Reinit</label>
  <alignment>left</alignment>
  <font>Bitstream Vera Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>131</r>
   <g>65</g>
   <b>48</b>
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
  <x>18</x>
  <y>160</y>
  <width>313</width>
  <height>73</height>
  <uuid>{94d46c4e-b4b7-4c46-85c5-cb2ac3d2d94b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Using a reinit pass values for vco2 waveform (which is i-rate) are changed. Values for frequency are no longer used with i() so they change whenever the slider changes</label>
  <alignment>center</alignment>
  <font>Bitstream Vera Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
WindowBounds: 375 213 361 291
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioMenu {11, 8} {122, 23} 1 303 "saw,square,triangle" wave
ioText {137, 8} {205, 26} label 0.000000 0.00100 "" center "Helvetica" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder <--Select waveform from this menu
ioSlider {11, 44} {180, 20} 200.000000 800.000000 520.000000 freq
ioText {207, 39} {130, 25} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Frequency
ioButton {11, 71} {180, 40} event 1.000000 "button1" "Generate note" "/" i10 0 5
ioText {196, 69} {148, 44} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Push this button to generate notes
ioText {10, 117} {332, 131} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {39168, 40448, 25600} nobackground noborder 
ioText {121, 130} {91, 26} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 16 {33536, 16640, 12288} {65280, 65280, 65280} nobackground noborder Reinit
ioText {18, 160} {313, 73} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Using a reinit pass values for vco2 waveform (which is i-rate) are changed. Values for frequency are no longer used with i() so they change whenever the slider changes
</MacGUI>
