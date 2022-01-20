<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	khipass invalue "hipass"
	klowpass invalue "lowpass"
	kbandpass invalue "bandpass"
	asig noise 1, 0
	if (khipass == 1) then
		asig atone asig, 3000
		asig atone asig, 3000
		asig atone asig, 3000
	endif
	if (klowpass == 1) then
		asig tone asig, 8000
		asig tone asig, 8000
		asig tone asig, 8000
	endif
	dispfft asig*20, 1/18, 1024
	outs asig*0.1, asig*0.1
endin

instr 2 ; set checkbox values
	kstate init 0
	ktrig metro 1
	if (ktrig == 1) then
		kstate = (kstate == 0 ? 1 : 0)
	endif
	kenable invalue "enable"
	if (kenable == 1) then
		outvalue "checkbox", kstate
		kenable = 0
	endif
endin

</CsInstruments>
<CsScore>
i 1 0 1000
i 2 0 1000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>691</x>
 <y>154</y>
 <width>412</width>
 <height>491</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>212</r>
  <g>223</g>
  <b>230</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>80</x>
  <y>5</y>
  <width>247</width>
  <height>44</height>
  <uuid>{ad8c5fad-d76a-425a-a10e-4b87d3142e8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Checkbox Widget</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>50</y>
  <width>500</width>
  <height>56</height>
  <uuid>{35d4a9c6-98b9-4783-aed1-9ad640324b68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The checkbox widget is a simple widget which sends a value of 1 on its channel when its checked and a 0 when not. It's value can also be set using a channel.</label>
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
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>30</x>
  <y>115</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c9d833b8-a125-42dc-bddd-fe01cedac125}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Hi Pass filter</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>30</x>
  <y>140</y>
  <width>80</width>
  <height>25</height>
  <uuid>{660ba30b-432e-4ba9-aa47-1fc6de0c1e14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Low Pass filter</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>15</x>
  <y>165</y>
  <width>500</width>
  <height>300</height>
  <uuid>{d4ba5f84-006d-44f5-8ad1-4959acf47abb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>475</y>
  <width>500</width>
  <height>96</height>
  <uuid>{95f875a7-941b-45b5-b4f9-d353d1f2e483}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Setting the value of a checkbox</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>checkbox</objectName>
  <x>25</x>
  <y>535</y>
  <width>22</width>
  <height>20</height>
  <uuid>{4784a930-dd88-408c-b5eb-9c17c28e0b5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>40</x>
  <y>535</y>
  <width>313</width>
  <height>28</height>
  <uuid>{0cea6f98-f6a5-4bba-9a75-2fb84e817366}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This Checkbox's value is set from Csound</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>enable</objectName>
  <x>25</x>
  <y>505</y>
  <width>21</width>
  <height>22</height>
  <uuid>{f773da97-1a7b-4950-aa2b-146323c34897}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>40</x>
  <y>505</y>
  <width>336</width>
  <height>27</height>
  <uuid>{6e3bc69c-c7b1-4f5e-a83c-73474a679066}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Tick this checkbox to enable changing the one below</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>hipass</objectName>
  <x>15</x>
  <y>115</y>
  <width>23</width>
  <height>20</height>
  <uuid>{95ffad56-9b0a-4f4d-9698-26fea6b90a73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>lowpass</objectName>
  <x>15</x>
  <y>140</y>
  <width>22</width>
  <height>19</height>
  <uuid>{b931c42f-6de4-4e79-add7-eb71793915ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
