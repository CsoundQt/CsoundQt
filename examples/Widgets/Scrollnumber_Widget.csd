<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

chn_S "hertz", 1  ;String channels must be declared
chn_S "c", 1  ;String channels must be declared

instr 1
	kmidi invalue "midi"
	khertz = 440 * 2^((kmidi -69)/12)
	Shertz sprintfk "%f Hz.", khertz
	outvalue "hertz", Shertz

	ka invalue "a"
	kb invalue "b"
	printk2 ka
	printk2 kb
	Sc sprintfk "is %f.", ka*kb
	outvalue "c", Sc
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <bgcolor mode="background" >
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>32</x>
  <y>6</y>
  <width>227</width>
  <height>37</height>
  <uuid>{e0d516ac-0bd9-4502-a3a2-9fa4f22f7054}</uuid>
  <label>Scroll Number Widget</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>6</x>
  <y>45</y>
  <width>261</width>
  <height>61</height>
  <uuid>{1972f251-3570-4dc4-8a87-50de9868eebe}</uuid>
  <label>Scroll Number Widgets are just like display widgets but their values can be changed by dragging with the mouse. The number of decimal places used and the size of the step for each mouse pixel is set by the resolution in the properties.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>8</x>
  <y>192</y>
  <width>259</width>
  <height>43</height>
  <uuid>{e42a48e9-9ee1-4337-8488-301faeedb988}</uuid>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>a</objectName>
  <x>18</x>
  <y>200</y>
  <width>55</width>
  <height>23</height>
  <uuid>{d46c4956-ab0b-4024-987f-e277c708d41a}</uuid>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
  <value>1.00000000</value>
  <resolution>0.00100000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <randomizable>false</randomizable>
  <mouseControl act="continuous" />
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>b</objectName>
  <x>116</x>
  <y>200</y>
  <width>55</width>
  <height>23</height>
  <uuid>{81904718-714a-4157-a559-e688b0c0205c}</uuid>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
  <value>1.50000000</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <randomizable>false</randomizable>
  <mouseControl act="continuous" />
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>73</x>
  <y>200</y>
  <width>44</width>
  <height>25</height>
  <uuid>{2ee5bcc9-bff7-4d21-a848-8b2af2c72899}</uuid>
  <label>times</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>c</objectName>
  <x>170</x>
  <y>200</y>
  <width>80</width>
  <height>25</height>
  <uuid>{73266aa0-0ae3-4bcd-bbaf-911453733b6c}</uuid>
  <label>is 1.500000.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>11</x>
  <y>119</y>
  <width>250</width>
  <height>54</height>
  <uuid>{e0e82cee-79df-4f1c-9011-fd8655d840a5}</uuid>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>midi</objectName>
  <x>20</x>
  <y>125</y>
  <width>87</width>
  <height>25</height>
  <uuid>{ae8f1ea4-e737-4ace-ba33-16f1b5c32b32}</uuid>
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
  <borderradius>1</borderradius>
  <randomizable>false</randomizable>
  <mouseControl act="continuous" />
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>17</x>
  <y>150</y>
  <width>110</width>
  <height>24</height>
  <uuid>{de1f7fcb-de33-4c40-a4fa-2c9aed935b86}</uuid>
  <label>MIDI note number</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>109</x>
  <y>126</y>
  <width>38</width>
  <height>23</height>
  <uuid>{658fc00b-9195-42be-9887-1a49b2734e83}</uuid>
  <label>has</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>hertz</objectName>
  <x>152</x>
  <y>125</y>
  <width>97</width>
  <height>25</height>
  <uuid>{566a8d25-ee1d-4705-ba26-c36c772cd35f}</uuid>
  <label>261.625549 Hz.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
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
  <borderradius>1</borderradius>
 </bsbObject>
 <objectName/>
 <x>735</x>
 <y>284</y>
 <width>289</width>
 <height>284</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 








</EventPanel>