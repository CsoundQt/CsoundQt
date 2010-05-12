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
	dispfft asig, 0.2, 1024 ;calculate spectrum
	if (kspectrum == 1) then
		ktab = -5 ;set to show graph index 5
	endif
	outvalue "graph", -ktab ;show appropriate graph
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
</CsoundSynthesizer>










<bsbPanel version="2">
 <bgcolor mode="background">
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBGraph">
  <objectName>graph</objectName>
  <x>7</x>
  <y>332</y>
  <width>373</width>
  <height>142</height>
  <uuid>{22cb97ab-2ca3-4c1d-8261-438750bdafb7}</uuid>
  <value>5</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>95</x>
  <y>6</y>
  <width>192</width>
  <height>41</height>
  <uuid>{8089dfa0-23c8-499b-9574-c5448e6c9b31}</uuid>
  <label>Graph Widget</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>45</y>
  <width>376</width>
  <height>98</height>
  <uuid>{0c1459a8-a5dd-4f20-8ac4-c6db15ad3fbc}</uuid>
  <label>Graph Widgets display Csound's f-tables. The table shown can be changed with the mouse using the menu on the upper left corner. It can also be changed by sending values on the widget's channel Positive values change the table by index and negative values change the table by f-table number. Note that tabes are actually in reverse order in the menu. Graph widgets can also show the spectrum from signals using the dispfft opcode, or time varying signals (a-rate and k-rate) using the display opcode.</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>7</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>tabnum</objectName>
  <x>97</x>
  <y>479</y>
  <width>45</width>
  <height>25</height>
  <uuid>{c5184ca2-1e56-4172-93fb-2cb07b8446d9}</uuid>
  <type>editnum</type>
  <value>1</value>
  <resolution>1.00000000</resolution>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>6</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+14</maximum>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>479</y>
  <width>101</width>
  <height>25</height>
  <uuid>{713fa927-1f41-48d2-9a62-9917b1394f7a}</uuid>
  <label>Use f-table</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>508</y>
  <width>373</width>
  <height>53</height>
  <uuid>{83a3100c-6bc8-4953-8812-8b41812f6028}</uuid>
  <label>Note that the numbers in the lower section will only have effect if Csound is running as they pass through Csound, while the ones on the top are connected directly by channel number.</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>7</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>spectrum</objectName>
  <x>161</x>
  <y>483</y>
  <width>20</width>
  <height>20</height>
  <uuid>{856bd0e3-fab2-4aea-bfbf-109f1707a92c}</uuid>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>179</x>
  <y>480</y>
  <width>111</width>
  <height>27</height>
  <uuid>{fd65e87a-e8e2-4111-a0c9-3a4b758ac437}</uuid>
  <label>Show spectrum</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName>graph_direct</objectName>
  <x>8</x>
  <y>147</y>
  <width>373</width>
  <height>142</height>
  <uuid>{5812135b-97d7-4337-8654-8d72fdba2a8a}</uuid>
  <value>1</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>graph_direct</objectName>
  <x>150</x>
  <y>295</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4fc79c4a-802a-4463-8920-823beabf229c}</uuid>
  <type>editnum</type>
  <value>1</value>
  <resolution>1.00000000</resolution>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>6</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+14</maximum>
  <randomizable>false</randomizable>
 </bsbObject>
 <objectName/>
 <x>820</x>
 <y>61</y>
 <width>433</width>
 <height>476</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>


<MacGUI>
ioView background {35466, 38293, 40092}
ioGraph {7, 332} {373, 142} table 5.000000 1.000000 graph
ioText {95, 6} {192, 41} display 0.000000 0.00100 "" left "DejaVu Sans" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Graph Widget
ioText {7, 45} {376, 98} display 0.000000 0.00100 "" left "Nimbus Sans L" 7 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Graph Widgets display Csound's f-tables. The table shown can be changed with the mouse using the menu on the upper left corner. It can also be changed by sending values on the widget's channel Positive values change the table by index and negative values change the table by f-table number. Note that tabes are actually in reverse order in the menu. Graph widgets can also show the spectrum from signals using the dispfft opcode, or time varying signals (a-rate and k-rate) using the display opcode.
ioText {97, 479} {45, 25} editnum 1.000000 1.000000 "tabnum" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {8, 479} {101, 25} display 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Use f-table
ioText {7, 508} {373, 53} display 0.000000 0.00100 "" left "Nimbus Sans L" 7 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Note that the numbers in the lower section will only have effect if Csound is running as they pass through Csound, while the ones on the top are connected directly by channel number.
ioCheckbox {161, 483} {20, 20} on spectrum
ioText {179, 480} {111, 27} display 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show spectrum
ioGraph {8, 147} {373, 142} table 1.000000 1.000000 graph_direct
ioText {150, 295} {80, 25} editnum 1.000000 1.000000 "graph_direct" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="512" y="320" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
