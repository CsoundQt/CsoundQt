<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1


instr 1
	ioffx = 100
	ioffy = 0
	iscalex = 3
	iscaley = 200
	
	krelx  invalue  "_MouseRelX"
	krely  invalue  "_MouseRelY"
	
	kcps = (krelx /iscalex) + ioffx
	kcps portk kcps, 0.04 ;smooth signal
	
	kamp = (krely/iscaley) + ioffy
	kamp portk kamp, 0.04 ;smooth signal
	
	aout oscil3 kamp, kcps, 1
	outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 200
e
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>166</x>
 <y>212</y>
 <width>661</width>
 <height>315</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>187</r>
  <g>255</g>
  <b>166</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_MouseX</objectName>
  <x>70</x>
  <y>43</y>
  <width>59</width>
  <height>25</height>
  <uuid>{7772e70f-3b40-4ccb-bad8-890272f5eca1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>243.000</label>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_MouseY</objectName>
  <x>70</x>
  <y>71</y>
  <width>59</width>
  <height>25</height>
  <uuid>{1b005161-106a-4dee-b690-394f2ca0d542}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>227.000</label>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_MouseRelX</objectName>
  <x>71</x>
  <y>100</y>
  <width>59</width>
  <height>25</height>
  <uuid>{c0b4e6d9-ae0f-43ff-bd6c-5d5cc1f4069a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>77.000</label>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_MouseRelY</objectName>
  <x>71</x>
  <y>128</y>
  <width>59</width>
  <height>25</height>
  <uuid>{42b32b09-6dd2-4fb1-8937-f9a98dcd0fd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>15.000</label>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>43</y>
  <width>64</width>
  <height>25</height>
  <uuid>{661a920f-1940-42c5-a3a9-805e987cdaa5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_MouseX</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <y>71</y>
  <width>64</width>
  <height>25</height>
  <uuid>{22a18513-ee55-4776-9d7a-810f17c896df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_MouseY</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <y>100</y>
  <width>64</width>
  <height>25</height>
  <uuid>{eadf5acb-93f6-48e7-963d-1d89e9eae369}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_MouseRelX</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <y>128</y>
  <width>64</width>
  <height>25</height>
  <uuid>{f3e65bf7-2675-4ac6-ba8c-13161b753ad3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_MouseRelY</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <y>18</y>
  <width>126</width>
  <height>26</height>
  <uuid>{7dedb7e5-2c10-41ca-80e3-2bc86484b6d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chan. name</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_MouseBut1</objectName>
  <x>71</x>
  <y>157</y>
  <width>59</width>
  <height>25</height>
  <uuid>{1b8b98ee-a972-4b2d-aaa8-afbfaa9c61e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_MouseBut2</objectName>
  <x>71</x>
  <y>185</y>
  <width>59</width>
  <height>25</height>
  <uuid>{7a5f18f6-fe30-4506-8946-b4f37bacec28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>157</y>
  <width>64</width>
  <height>25</height>
  <uuid>{aa9a39f0-0d4d-4633-b603-35fa9519ba95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_MouseBut1</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <y>185</y>
  <width>64</width>
  <height>25</height>
  <uuid>{e74bf658-19b7-463f-9a1c-dd4f5fb507e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_MouseBut2</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>621</x>
  <y>295</y>
  <width>40</width>
  <height>20</height>
  <uuid>{de2a31b8-e6c8-4572-a6c9-e11f6dbdc8b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>140</x>
  <y>68</y>
  <width>251</width>
  <height>86</height>
  <uuid>{74a96012-3452-49c8-9647-03aee70f32ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>The reserved mouse channels receive the mouse position and button state within the widget panel, even while Csound is not running.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>255</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>5</borderwidth>
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
WindowBounds: 166 212 666 326
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {48059, 65535, 42662}
ioText {70, 43} {59, 25} display 243.000000 0.00100 "_MouseX" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 243.000
ioText {70, 71} {59, 25} display 227.000000 0.00100 "_MouseY" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 227.000
ioText {71, 100} {59, 25} display 77.000000 0.00100 "_MouseRelX" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 77.000
ioText {71, 128} {59, 25} display 15.000000 0.00100 "_MouseRelY" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 15.000
ioText {7, 43} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder _MouseX
ioText {7, 71} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder _MouseY
ioText {7, 100} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder _MouseRelX
ioText {7, 128} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder _MouseRelY
ioText {7, 18} {80, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 14 {0, 0, 0} {61440, 60160, 57856} nobackground noborder Chan. name
ioText {71, 157} {59, 25} display 0.000000 0.00100 "_MouseBut1" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000
ioText {71, 185} {59, 25} display 1.000000 0.00100 "_MouseBut2" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000
ioText {7, 157} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder _MouseBut1
ioText {7, 185} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder _MouseBut2
ioText {525, 272} {80, 25} display 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder 
ioText {139, 42} {245, 165} label 0.000000 0.00100 "" left "Arial" 14 {0, 0, 0} {43520, 65280, 32512} nobackground noborder The reserved mouse channels receive the mouse position and button state within the widget panel, even while Csound is not running.
</MacGUI>
