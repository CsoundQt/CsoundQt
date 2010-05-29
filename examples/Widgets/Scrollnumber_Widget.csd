<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1 ; always on
	kmidi invalue "midi"
	khertz = 440 * 2^((kmidi -69)/12)
	Shertz sprintfk "%.3f Hz.", khertz
	outvalue "hertz", Shertz

	ka invalue "a"
	kb invalue "b"
	Sc sprintfk "is %.3f", ka*kb
	outvalue "c", Sc
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>735</x>
 <y>252</y>
 <width>281</width>
 <height>319</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background" >
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>21</x>
  <y>7</y>
  <width>227</width>
  <height>37</height>
  <uuid>{e0d516ac-0bd9-4502-a3a2-9fa4f22f7054}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Scroll Number Widget</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>8</x>
  <y>46</y>
  <width>250</width>
  <height>108</height>
  <uuid>{1972f251-3570-4dc4-8a87-50de9868eebe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Scroll Number Widgets are just like display widgets but their values can be changed by dragging with the mouse. The number of decimal places used and the size of the step for each mouse pixel is set by the resolution in the properties.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>8</x>
  <y>223</y>
  <width>250</width>
  <height>43</height>
  <uuid>{e42a48e9-9ee1-4337-8488-301faeedb988}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>193</r>
   <g>163</g>
   <b>142</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>a</objectName>
  <x>18</x>
  <y>231</y>
  <width>55</width>
  <height>23</height>
  <uuid>{d46c4956-ab0b-4024-987f-e277c708d41a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <value>1.00200000</value>
  <resolution>0.00100000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0" >false</randomizable>
  <mouseControl act="" />
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>b</objectName>
  <x>116</x>
  <y>231</y>
  <width>55</width>
  <height>23</height>
  <uuid>{81904718-714a-4157-a559-e688b0c0205c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <value>4.40000000</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0" >false</randomizable>
  <mouseControl act="" />
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>73</x>
  <y>231</y>
  <width>44</width>
  <height>25</height>
  <uuid>{2ee5bcc9-bff7-4d21-a848-8b2af2c72899}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>times</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>c</objectName>
  <x>171</x>
  <y>230</y>
  <width>90</width>
  <height>23</height>
  <uuid>{73266aa0-0ae3-4bcd-bbaf-911453733b6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>is 4.409</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>8</x>
  <y>161</y>
  <width>250</width>
  <height>54</height>
  <uuid>{e0e82cee-79df-4f1c-9011-fd8655d840a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>193</r>
   <g>163</g>
   <b>142</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>midi</objectName>
  <x>18</x>
  <y>169</y>
  <width>87</width>
  <height>25</height>
  <uuid>{ae8f1ea4-e737-4ace-ba33-16f1b5c32b32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Times New Roman</font>
  <fontsize>14</fontsize>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background" >
   <r>88</r>
   <g>103</g>
   <b>113</b>
  </bgcolor>
  <value>60.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0" >false</randomizable>
  <mouseControl act="" />
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>15</x>
  <y>194</y>
  <width>110</width>
  <height>24</height>
  <uuid>{de1f7fcb-de33-4c40-a4fa-2c9aed935b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>MIDI note number</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>107</x>
  <y>170</y>
  <width>38</width>
  <height>23</height>
  <uuid>{658fc00b-9195-42be-9887-1a49b2734e83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>has</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>hertz</objectName>
  <x>150</x>
  <y>169</y>
  <width>97</width>
  <height>25</height>
  <uuid>{566a8d25-ee1d-4705-ba26-c36c772cd35f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>261.626 Hz.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>206</r>
   <g>214</g>
   <b>169</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <objectName/>
 <x>735</x>
 <y>252</y>
 <width>281</width>
 <height>319</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {21, 7} {227, 37} display 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Scroll Number Widget
ioText {8, 46} {250, 108} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Scroll Number Widgets are just like display widgets but their values can be changed by dragging with the mouse. The number of decimal places used and the size of the step for each mouse pixel is set by the resolution in the properties.
ioText {8, 223} {250, 43} display 0.000000 0.00100 "" left "Helvetica" 6 {0, 0, 0} {49408, 41728, 36352} nobackground noborder 
ioText {18, 231} {55, 23} scroll 1.002000 0.001000 "a" center "Arial" 12 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {116, 231} {55, 23} scroll 4.400000 0.100000 "b" center "Arial" 12 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {73, 231} {44, 25} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder times
ioText {171, 230} {90, 23} display 0.000000 0.00100 "c" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder is 4.409
ioText {8, 161} {250, 54} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {49408, 41728, 36352} nobackground noborder 
ioText {18, 169} {87, 25} scroll 60.000000 1.000000 "midi" center "Times New Roman" 14 {65280, 65280, 65280} {22528, 26368, 28928} background noborder 
ioText {15, 194} {110, 24} display 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder MIDI note number
ioText {107, 170} {38, 23} display 0.000000 0.00100 "" right "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder has
ioText {150, 169} {97, 25} display 0.000000 0.00100 "hertz" left "Arial" 12 {0, 0, 0} {52736, 54784, 43264} nobackground noborder 261.626 Hz.
</MacGUI>
