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
  <r>199</r>
  <g>216</g>
  <b>225</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>82</x>
  <y>5</y>
  <width>211</width>
  <height>40</height>
  <uuid>{8910a9af-b5e5-40df-a55d-f3ccb55c17be}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Display Widget</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>45</y>
  <width>362</width>
  <height>58</height>
  <uuid>{e525e33c-5cae-41a8-ac9d-80bcae4880c0}</uuid>
  <widgetName/>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>87</x>
  <y>117</y>
  <width>116</width>
  <height>29</height>
  <uuid>{b0670b97-c937-4c65-9751-c2aeaf31107b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Time elapsed:</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>117</x>
  <y>178</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c23fb7ff-a3d4-4e89-9628-1b0f3221e3db}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Tempo</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>326</x>
  <y>153</y>
  <width>49</width>
  <height>25</height>
  <uuid>{5de22031-4f6c-49d1-b5ac-d4512bc4d7ad}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>bpm</label>
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
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>time</objectName>
  <x>203</x>
  <y>111</y>
  <width>166</width>
  <height>35</height>
  <uuid>{c21e0e5c-fe9a-442a-838c-3cc6a6a79766}</uuid>
  <widgetName/>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>location</objectName>
  <x>10</x>
  <y>205</y>
  <width>367</width>
  <height>48</height>
  <uuid>{12fa0947-bffd-4521-8e3b-93f0a01c7861}</uuid>
  <widgetName/>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>tempo</objectName>
  <x>259</x>
  <y>153</y>
  <width>68</width>
  <height>26</height>
  <uuid>{cacc9d21-8be0-474f-a070-8a5be7834973}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.718</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>tempo</objectName>
  <x>10</x>
  <y>153</y>
  <width>250</width>
  <height>24</height>
  <uuid>{829997bc-e773-4bf3-a169-4d5f061f0d94}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.71759375</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>border</bordermode>
  <borderColor>#00622f</borderColor>
  <color>
   <r>0</r>
   <g>177</g>
   <b>83</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>65</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
