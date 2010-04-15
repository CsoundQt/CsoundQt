<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

gibeats init 0
chn_S "location", 1  ;String channels must be declared

instr 1
	ktime timeinsts
	outvalue "time", ktime

	ktempo invalue "tempo"
	outvalue "tempodisp", ktempo
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
f 1 0 1024 10 1
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
  <x>82</x>
  <y>5</y>
  <width>211</width>
  <height>40</height>
  <uuid>{8910a9af-b5e5-40df-a55d-f3ccb55c17be}</uuid>
  <label>Display Widget</label>
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
  <width>363</width>
  <height>48</height>
  <uuid>{e525e33c-5cae-41a8-ac9d-80bcae4880c0}</uuid>
  <label>Display widgets are labels whose value can be set from Csound through channels. The Display Widget can display both numbers and text.</label>
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
  <objectName>time</objectName>
  <x>204</x>
  <y>102</y>
  <width>166</width>
  <height>35</height>
  <uuid>{2b90fe9e-7c4d-41e5-b71f-0ef964c8d620}</uuid>
  <label>12.934</label>
  <alignment>center</alignment>
  <font>Courier New</font>
  <fontsize>18</fontsize>
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
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>88</x>
  <y>108</y>
  <width>116</width>
  <height>29</height>
  <uuid>{b0670b97-c937-4c65-9751-c2aeaf31107b}</uuid>
  <label>Time elapsed:</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>tempo</objectName>
  <x>12</x>
  <y>155</y>
  <width>249</width>
  <height>26</height>
  <uuid>{e577cd24-27ff-47d4-9e61-8d53430df5f2}</uuid>
  <minimum>30.00000000</minimum>
  <maximum>180.00000000</maximum>
  <value>109.51807229</value>
  <resolution>-1.00000000</resolution>
  <randomizable>true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>117</x>
  <y>178</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c23fb7ff-a3d4-4e89-9628-1b0f3221e3db}</uuid>
  <label>Tempo</label>
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
  <objectName>tempodisp</objectName>
  <x>259</x>
  <y>153</y>
  <width>68</width>
  <height>26</height>
  <uuid>{ac09e11e-8901-469f-872c-c52266573f61}</uuid>
  <label>95.663</label>
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
  <x>326</x>
  <y>153</y>
  <width>49</width>
  <height>25</height>
  <uuid>{5de22031-4f6c-49d1-b5ac-d4512bc4d7ad}</uuid>
  <label>bpm</label>
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
  <objectName>location</objectName>
  <x>10</x>
  <y>205</y>
  <width>367</width>
  <height>48</height>
  <uuid>{50a6fa28-9118-4dee-a089-14c9a3bc7594}</uuid>
  <label>Bar:Beat - 4:3</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
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
  <borderradius>1</borderradius>
 </bsbObject>
 <objectName/>
 <x>515</x>
 <y>238</y>
 <width>406</width>
 <height>313</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>