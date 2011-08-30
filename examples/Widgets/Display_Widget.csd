<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

gibeats init 0

instr 1  ; Always on
	ktime timeinsts
	ktempo	invalue "tempo"
	outvalue "time", ktime

	kfreq = ktempo/60
	ktrig metro kfreq
	schedkwhen ktrig, 0.5, 1, 2, 0, 0.5
endin

instr 2 ; triggered once every second from instr 1
	gibeats = gibeats + 1
	ibar = int(gibeats/4)
	ibeat = (gibeats % 4) + 1
	Sloc sprintf "Bar:Beat - %i:%i", ibar, ibeat
	outvalue "location", Sloc 
	turnoff
endin


</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>292</x>
 <y>90</y>
 <width>385</width>
 <height>275</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>82</x>
  <y>5</y>
  <width>211</width>
  <height>40</height>
  <uuid>{8910a9af-b5e5-40df-a55d-f3ccb55c17be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Display Widget</label>
  <alignment>center</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>45</y>
  <width>362</width>
  <height>58</height>
  <uuid>{e525e33c-5cae-41a8-ac9d-80bcae4880c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Display widgets are labels whose value can be set from Csound through channels. The Display Widget can display both numbers and text.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>87</x>
  <y>117</y>
  <width>116</width>
  <height>29</height>
  <uuid>{b0670b97-c937-4c65-9751-c2aeaf31107b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Time elapsed:</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>tempo</objectName>
  <x>6</x>
  <y>153</y>
  <width>249</width>
  <height>26</height>
  <uuid>{e577cd24-27ff-47d4-9e61-8d53430df5f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>30.00000000</minimum>
  <maximum>180.00000000</maximum>
  <value>103.49397590</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>117</x>
  <y>178</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c23fb7ff-a3d4-4e89-9628-1b0f3221e3db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Tempo</label>
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
  <x>326</x>
  <y>153</y>
  <width>49</width>
  <height>25</height>
  <uuid>{5de22031-4f6c-49d1-b5ac-d4512bc4d7ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>bpm</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>time</objectName>
  <x>203</x>
  <y>111</y>
  <width>166</width>
  <height>35</height>
  <uuid>{c21e0e5c-fe9a-442a-838c-3cc6a6a79766}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3.396</label>
  <alignment>center</alignment>
  <font>Courier New</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>195</r>
   <g>240</g>
   <b>206</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>location</objectName>
  <x>10</x>
  <y>205</y>
  <width>367</width>
  <height>48</height>
  <uuid>{12fa0947-bffd-4521-8e3b-93f0a01c7861}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Bar:Beat - 1:3</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>106</r>
   <g>106</g>
   <b>106</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>tempo</objectName>
  <x>259</x>
  <y>153</y>
  <width>68</width>
  <height>26</height>
  <uuid>{cacc9d21-8be0-474f-a070-8a5be7834973}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>131.205</label>
  <alignment>right</alignment>
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
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {35466, 38293, 40092}
ioText {82, 5} {211, 40} label 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {61440, 60160, 57856} nobackground noborder Display Widget
ioText {6, 45} {362, 58} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Display widgets are labels whose value can be set from Csound through channels. The Display Widget can display both numbers and text.
ioText {87, 117} {116, 29} label 0.000000 0.00100 "" right "Arial" 12 {0, 0, 0} {61440, 60160, 57856} nobackground noborder Time elapsed:
ioSlider {6, 153} {249, 26} 30.000000 180.000000 103.493976 tempo
ioText {117, 178} {80, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61440, 60160, 57856} nobackground noborder Tempo
ioText {326, 153} {49, 25} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {61440, 60160, 57856} nobackground noborder bpm
ioText {203, 111} {166, 35} display 3.396000 0.00100 "time" center "Courier New" 20 {0, 0, 0} {49920, 61440, 52736} nobackground noborder 3.396
ioText {10, 205} {367, 48} display 0.000000 0.00100 "location" center "Arial" 24 {65280, 65280, 65280} {61440, 60160, 57856} nobackground noborder Bar:Beat - 1:3
ioText {259, 153} {68, 26} display 131.205000 0.00100 "tempo" right "Arial" 12 {0, 0, 0} {61440, 60160, 57856} nobackground noborder 131.205
</MacGUI>
