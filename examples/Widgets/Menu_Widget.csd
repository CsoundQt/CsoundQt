<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	ktype invalue "type"
	ktransp invalue "transp"
	ktfactor tab ktransp, 1 ;map index to transposition factor
	if (ktype == 0) then
		axcite oscil 1, 1, 2
		asig wgflute 0.1, 880*ktfactor, 0.32, 0.1, 0.1, 0.15, 5.925, 0.1, 2
	elseif (ktype == 1) then
		kenv xadsr 0.2, 0.2, 1, p3/2
		asig vco2 kenv*0.1, 440*ktfactor
	elseif (ktype == 2) then
		asig shaker 0.5, 880*ktfactor, 64*ktfactor, 0.7, 3, 0
	endif
	outs asig*0.3, asig*0.3
endin

instr 2  ;randomize
	itype = rnd(3)
	itransp = rnd(3)
	outvalue "type", int(itype)
	outvalue "transp", int(itransp)
	event "i", 1, 0.1, 2 
	turnoff ;send values only once
endin

</CsInstruments>
<CsScore>
f 1 0 8 -2 2 1 0.5  ;Transp factors (octave up, none, octave down)
f 2 0 16384 10 1

f 0 3600
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
  <x>83</x>
  <y>6</y>
  <width>197</width>
  <height>41</height>
  <uuid>{2d5f32c3-fe84-423c-bf3a-c17e7e332060}</uuid>
  <label>Menu Widget</label>
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
  <x>23</x>
  <y>50</y>
  <width>291</width>
  <height>59</height>
  <uuid>{f6d0f932-fa22-486e-8167-b37311d339c2}</uuid>
  <label>Menu widgets can show menus with user defined elements. The elements are set as a comma separated list in the properties.The menu widget transmits the index of the currently selected item counting from 0. The current index can also be set from Csound</label>
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
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>type</objectName>
  <x>87</x>
  <y>118</y>
  <width>83</width>
  <height>26</height>
  <uuid>{941b60cb-e13f-45c3-b7c3-cba6c825c8bf}</uuid>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>wgflute</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>shaker</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>button1</objectName>
  <x>197</x>
  <y>117</y>
  <width>105</width>
  <height>25</height>
  <uuid>{ada21fd8-091b-4dc6-bc5f-b140c2284ef5}</uuid>
  <type>event</type>
  <value>1.00000000</value>
  <stringvalue/>
  <text>Make sound</text>
  <image>/</image>
  <eventLine>i1 0 2</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>transp</objectName>
  <x>88</x>
  <y>147</y>
  <width>83</width>
  <height>27</height>
  <uuid>{39df8add-fa10-4f77-a705-e163fc12ee36}</uuid>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>12</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>0</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>-12</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>button1</objectName>
  <x>174</x>
  <y>147</y>
  <width>151</width>
  <height>26</height>
  <uuid>{64b6bf1d-6215-4db6-8d37-8f14cf2fcb38}</uuid>
  <type>event</type>
  <value>1.00000000</value>
  <stringvalue/>
  <text>Randomize and play</text>
  <image>/</image>
  <eventLine>i2 0 1</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>32</x>
  <y>119</y>
  <width>56</width>
  <height>25</height>
  <uuid>{78057116-2f3b-472a-bd12-7aa070157cb6}</uuid>
  <label>Sound</label>
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
  <objectName/>
  <x>9</x>
  <y>149</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c3561f00-6a33-4e0a-8274-6b876f838c1b}</uuid>
  <label>Transposition</label>
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
 <objectName/>
 <x>654</x>
 <y>270</y>
 <width>352</width>
 <height>215</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 








</EventPanel>