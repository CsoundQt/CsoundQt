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
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>292</x>
 <y>90</y>
 <width>435</width>
 <height>298</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>195</r>
  <g>210</g>
  <b>220</b>
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
  <description/>
  <label>Display Widget</label>
  <alignment>center</alignment>
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
  <x>6</x>
  <y>45</y>
  <width>362</width>
  <height>58</height>
  <uuid>{e525e33c-5cae-41a8-ac9d-80bcae4880c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Display widgets are labels whose value can be set from Csound through channels. The Display Widget can display both numbers and text.</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
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
  <x>87</x>
  <y>117</y>
  <width>116</width>
  <height>29</height>
  <uuid>{b0670b97-c937-4c65-9751-c2aeaf31107b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Time elapsed:</label>
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
  <description/>
  <minimum>30.00000000</minimum>
  <maximum>180.00000000</maximum>
  <value>93.25301205</value>
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
  <description/>
  <label>Tempo</label>
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
  <x>326</x>
  <y>153</y>
  <width>49</width>
  <height>25</height>
  <uuid>{5de22031-4f6c-49d1-b5ac-d4512bc4d7ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>bpm</label>
  <alignment>left</alignment>
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
  <description/>
  <label>14.721</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Mono</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>221</r>
   <g>240</g>
   <b>226</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
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
  <description/>
  <label>Bar:Beat - 5:2</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>170</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>50</r>
   <g>55</g>
   <b>60</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
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
  <description/>
  <label>93.253</label>
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
