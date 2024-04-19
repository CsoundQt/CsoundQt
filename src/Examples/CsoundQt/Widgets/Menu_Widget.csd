<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1 ; make sound
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
	event "i", 1, 0, 2 
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
 <label>Widgets</label>
 <objectName/>
 <x>654</x>
 <y>238</y>
 <width>357</width>
 <height>279</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>177</r>
  <g>191</g>
  <b>200</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>83</x>
  <y>6</y>
  <width>197</width>
  <height>41</height>
  <uuid>{2d5f32c3-fe84-423c-bf3a-c17e7e332060}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Menu Widget</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>23</x>
  <y>50</y>
  <width>291</width>
  <height>104</height>
  <uuid>{f6d0f932-fa22-486e-8167-b37311d339c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Menu widgets can show menus with user defined elements. The elements are set as a comma separated list in the properties.The menu widget transmits the index of the currently selected item counting from 0. The current index can also be set from Csound</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>160</r>
   <g>172</g>
   <b>180</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>type</objectName>
  <x>90</x>
  <y>170</y>
  <width>80</width>
  <height>30</height>
  <uuid>{941b60cb-e13f-45c3-b7c3-cba6c825c8bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
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
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>185</x>
  <y>170</y>
  <width>160</width>
  <height>30</height>
  <uuid>{ada21fd8-091b-4dc6-bc5f-b140c2284ef5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Make sound</text>
  <image>/</image>
  <eventLine>i1 0 2</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>transp</objectName>
  <x>90</x>
  <y>205</y>
  <width>80</width>
  <height>30</height>
  <uuid>{39df8add-fa10-4f77-a705-e163fc12ee36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
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
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>185</x>
  <y>205</y>
  <width>160</width>
  <height>30</height>
  <uuid>{64b6bf1d-6215-4db6-8d37-8f14cf2fcb38}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Randomize and play</text>
  <image>/</image>
  <eventLine>i2 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>35</x>
  <y>175</y>
  <width>56</width>
  <height>25</height>
  <uuid>{78057116-2f3b-472a-bd12-7aa070157cb6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sound</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>210</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c3561f00-6a33-4e0a-8274-6b876f838c1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
