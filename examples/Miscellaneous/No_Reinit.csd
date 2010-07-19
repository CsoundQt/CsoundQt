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

instr 1 ;read widgets
; When values from sliders are to be used on the init pass,
; they must be read outside the instrument, because
; they are not read during the init pass
gkwave invalue "wave"
gkfreq invalue "freq"
endin

instr 10
kenv adsr p3/5, p3/5, 0.6, p3/2
imode tab_i i(gkwave), giwavemodes
aout  vco2  0.1, i(gkfreq), imode
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
 <x>207</x>
 <y>302</y>
 <width>373</width>
 <height>293</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>wave</objectName>
  <x>25</x>
  <y>30</y>
  <width>120</width>
  <height>23</height>
  <uuid>{209046cb-065c-45d2-a8af-c6cc76c4e15b}</uuid>
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
  <x>150</x>
  <y>31</y>
  <width>204</width>
  <height>25</height>
  <uuid>{fd5594a3-7a80-40e3-be90-7335292cd7b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>&lt;-- Select waveform from this menu</label>
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
  <x>25</x>
  <y>70</y>
  <width>180</width>
  <height>20</height>
  <uuid>{6a07f97c-5c18-46b2-8515-bdd1d252fce1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>200.00000000</minimum>
  <maximum>800.00000000</maximum>
  <value>703.03030300</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>220</x>
  <y>65</y>
  <width>130</width>
  <height>25</height>
  <uuid>{9795fb33-ed0e-40cd-be54-4e72136ba27b}</uuid>
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
  <x>26</x>
  <y>98</y>
  <width>180</width>
  <height>40</height>
  <uuid>{9346008b-c023-4171-84ec-419a0542d75e}</uuid>
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
  <x>208</x>
  <y>100</y>
  <width>130</width>
  <height>36</height>
  <uuid>{d0e5f205-22ef-46a1-9e95-a0dad502c127}</uuid>
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
  <x>28</x>
  <y>148</y>
  <width>308</width>
  <height>101</height>
  <uuid>{bd0c8e45-f7e6-4d91-948f-b571a61c20ec}</uuid>
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
   <r>169</r>
   <g>191</g>
   <b>120</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>42</x>
  <y>180</y>
  <width>277</width>
  <height>66</height>
  <uuid>{1ea04247-ebf6-41f1-979d-83efd84fc316}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Values for waveform and frequency are only applied during the init pass so they remain constant for every note. Changes only apply for new notes</label>
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
  <x>118</x>
  <y>153</y>
  <width>105</width>
  <height>24</height>
  <uuid>{bda3bb14-efd3-4e02-b523-a58928c5437f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>No Reinit</label>
  <alignment>left</alignment>
  <font>Bitstream Vera Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>82</r>
   <g>111</g>
   <b>63</b>
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
WindowBounds: 207 302 373 293
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioMenu {25, 30} {120, 23} 1 303 "saw,square,triangle" wave
ioText {150, 31} {202, 26} label 0.000000 0.00100 "" center "Helvetica" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder <-- Select waveform from this menu
ioSlider {25, 70} {180, 20} 200.000000 800.000000 703.030303 freq
ioText {220, 65} {130, 25} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Frequency
ioButton {26, 98} {180, 40} event 1.000000 "button1" "Generate note" "/" i10 0 5
ioText {208, 100} {130, 36} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Push this button to generate notes
ioText {28, 148} {308, 101} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {43264, 48896, 30720} nobackground noborder 
ioText {42, 180} {277, 66} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 10 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Values for waveform and frequency are only applied during the init pass so they remain constant for every note. Changes only apply for new notes
ioText {118, 153} {105, 24} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 16 {20992, 28416, 16128} {65280, 65280, 65280} nobackground noborder No Reinit
</MacGUI>
