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
 <x>445</x>
 <y>182</y>
 <width>400</width>
 <height>303</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background" >
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
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
  <objectName>time</objectName>
  <x>203</x>
  <y>111</y>
  <width>166</width>
  <height>35</height>
  <uuid>{2b90fe9e-7c4d-41e5-b71f-0ef964c8d620}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>12.934</label>
  <alignment>center</alignment>
  <font>Courier New</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>219</r>
   <g>255</g>
   <b>221</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>tempo</objectName>
  <x>12</x>
  <y>155</y>
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
  <mouseControl act="jump" >continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0" >true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
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
  <objectName>tempo</objectName>
  <x>259</x>
  <y>153</y>
  <width>68</width>
  <height>26</height>
  <uuid>{ac09e11e-8901-469f-872c-c52266573f61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>103.494</label>
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
  <objectName>location</objectName>
  <x>10</x>
  <y>205</y>
  <width>367</width>
  <height>48</height>
  <uuid>{50a6fa28-9118-4dee-a089-14c9a3bc7594}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Bar:Beat - 4:3</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>98</r>
   <g>98</g>
   <b>98</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <objectName/>
 <x>445</x>
 <y>182</y>
 <width>400</width>
 <height>303</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {82, 5} {211, 40} display 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Display Widget
ioText {6, 45} {362, 58} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Display widgets are labels whose value can be set from Csound through channels. The Display Widget can display both numbers and text.
ioText {203, 111} {166, 35} display 12.934000 0.00100 "time" center "Courier New" 20 {0, 0, 0} {56064, 65280, 56576} nobackground noborder 12.934
ioText {87, 117} {116, 29} display 0.000000 0.00100 "" right "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Time elapsed:
ioSlider {12, 155} {249, 26} 30.000000 180.000000 103.493976 tempo
ioText {117, 178} {80, 25} display 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Tempo
ioText {259, 153} {68, 26} display 103.494000 0.00100 "tempo" right "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 103.494
ioText {326, 153} {49, 25} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder bpm
ioText {10, 205} {367, 48} display 0.000000 0.00100 "location" center "Arial" 24 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder Bar:Beat - 4:3
</MacGUI>
