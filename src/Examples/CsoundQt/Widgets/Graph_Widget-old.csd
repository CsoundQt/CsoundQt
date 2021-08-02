<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 20
	ktab invalue "tabnum" ; table number selected
	kspectrum invalue "spectrum" ;spectrum checkbox
	if (ktab>5 || ktab<1) then
		ktab = 1 ; only allow existing tables
	endif
	asig oscilikt 0.2, 440, ktab
	outs asig*0.1,asig*0.1
	dispfft asig, 0.5, 1024 ;calculate spectrum
	if (kspectrum == 1) then
		ktab = -5 ;set to show graph index 5
	endif
	ktrig metro 2
	if ktrig == 1 then 
		outvalue "graph", -ktab ;show appropriate graph
	endif
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1  ;sine
f 2 0 1024 10 1 0.5 0.333
f 3 0 1024 10 1 0 0.333 0 0.25
f 4 0 1024 7 1 512 1 0 -1 512 -1 ;square
f 5 0 1024 7 1 1024 -1 ;saw

i 20 0 3600

</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>249</x>
 <y>230</y>
 <width>706</width>
 <height>474</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background" >
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBGraph" >
  <objectName>graph</objectName>
  <x>389</x>
  <y>98</y>
  <width>292</width>
  <height>142</height>
  <uuid>{22cb97ab-2ca3-4c1d-8261-438750bdafb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>5</value>
  <objectName2>graph_ft</objectName2>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>69</x>
  <y>4</y>
  <width>559</width>
  <height>40</height>
  <uuid>{8089dfa0-23c8-499b-9574-c5448e6c9b31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Graph Widget</label>
  <alignment>center</alignment>
  <font>Helvetica</font>
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
  <x>7</x>
  <y>41</y>
  <width>376</width>
  <height>199</height>
  <uuid>{0c1459a8-a5dd-4f20-8ac4-c6db15ad3fbc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Graph Widgets display Csound's tables. The currently visible table can be changed by sending values on the widget's channel. Positive values change the table by index and negative values change the table by f-table number. The second channel can be used to display tables by f-table number instead of index. The displayed table can also be changed with the mouse using the menu on the upper left corner. Doing this will produce output on both channels.
Graph widgets can also show the spectrum from signals using the dispfft opcode, or time varying signals (a-rate and k-rate) using the display opcode.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>tabnum</objectName>
  <x>479</x>
  <y>244</y>
  <width>45</width>
  <height>25</height>
  <uuid>{c5184ca2-1e56-4172-93fb-2cb07b8446d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>5</maximum>
  <randomizable group="0" >false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>390</x>
  <y>244</y>
  <width>91</width>
  <height>26</height>
  <uuid>{713fa927-1f41-48d2-9a62-9917b1394f7a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Use f-table</label>
  <alignment>right</alignment>
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
  <x>388</x>
  <y>276</y>
  <width>294</width>
  <height>80</height>
  <uuid>{83a3100c-6bc8-4953-8812-8b41812f6028}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Note that the numbers in the lower section will only have effect if Csound is running as they pass through Csound, while the ones on the top are connected directly by channel number.</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
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
 <bsbObject version="2" type="BSBCheckBox" >
  <objectName>spectrum</objectName>
  <x>543</x>
  <y>249</y>
  <width>20</width>
  <height>20</height>
  <uuid>{856bd0e3-fab2-4aea-bfbf-109f1707a92c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>559</x>
  <y>247</y>
  <width>111</width>
  <height>27</height>
  <uuid>{fd65e87a-e8e2-4111-a0c9-3a4b758ac437}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Show spectrum</label>
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
 <bsbObject version="2" type="BSBGraph" >
  <objectName>graph_direct</objectName>
  <x>8</x>
  <y>245</y>
  <width>373</width>
  <height>142</height>
  <uuid>{5812135b-97d7-4337-8654-8d72fdba2a8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <objectName2>graph_direct_table</objectName2>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>graph_direct</objectName>
  <x>98</x>
  <y>395</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4fc79c4a-802a-4463-8920-823beabf229c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>-5</minimum>
  <maximum>5</maximum>
  <randomizable group="0" >false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>graph_direct_table</objectName>
  <x>290</x>
  <y>395</y>
  <width>80</width>
  <height>25</height>
  <uuid>{688dfcfc-c8da-4815-b9ad-952c95e4caac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>10</maximum>
  <randomizable group="0" >false</randomizable>
  <value>-1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>27</x>
  <y>395</y>
  <width>73</width>
  <height>26</height>
  <uuid>{18951768-4bc4-46c5-99bc-68bd75158ed4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Index</label>
  <alignment>right</alignment>
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
  <x>181</x>
  <y>395</y>
  <width>111</width>
  <height>25</height>
  <uuid>{e241df28-b3f8-488a-aaba-4072ea72e73c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>F-table number</label>
  <alignment>right</alignment>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {35466, 38293, 40092}
ioGraph {389, 98} {292, 142} table 5.000000 1.000000 graph
ioText {69, 4} {559, 40} label 0.000000 0.00100 "" center "Helvetica" 24 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Graph Widget
ioText {7, 41} {376, 199} label 0.000000 0.00100 "" left "Arial" 14 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Graph Widgets display Csound's tables. The currently visible table can be changed by sending values on the widget's channel. Positive values change the table by index and negative values change the table by f-table number. The second channel can be used to display tables by f-table number instead of index. The displayed table can also be changed with the mouse using the menu on the upper left corner. Doing this will produce output on both channels.Â¬Graph widgets can also show the spectrum from signals using the dispfft opcode, or time varying signals (a-rate and k-rate) using the display opcode.
ioText {479, 244} {45, 25} editnum 3.000000 1.000000 "tabnum" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 3.000000
ioText {390, 244} {91, 26} label 0.000000 0.00100 "" right "Arial" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Use f-table
ioText {388, 276} {294, 80} label 0.000000 0.00100 "" left "Nimbus Sans L" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Note that the numbers in the lower section will only have effect if Csound is running as they pass through Csound, while the ones on the top are connected directly by channel number.
ioCheckbox {543, 249} {20, 20} on spectrum
ioText {559, 247} {111, 27} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Show spectrum
ioGraph {8, 245} {373, 142} table 0.000000 1.000000 graph_direct
ioText {91, 395} {80, 25} editnum 0.000000 1.000000 "graph_direct" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 0.000000
ioText {299, 395} {80, 25} editnum 0.000000 1.000000 "graph_direct_table" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 0.000000
ioText {11, 395} {80, 25} label 0.000000 0.00100 "" right "Arial" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Index
ioText {188, 395} {111, 25} label 0.000000 0.00100 "" right "Arial" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder F-table number
</MacGUI>
