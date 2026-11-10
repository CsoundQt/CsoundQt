<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

; The sliders write their values to channels. The first two drive the sound;
; the other two demonstrate the thumb/fill modes and the ruler.

instr 1
  kamp  = chnget("amp")
  kfreq = chnget("freq")
  kdetune = chnget("detune")
  asig  = oscil(kamp, kfreq * (1 + 0.01 * kdetune), -1)
  asig2 = oscil(kamp, kfreq * (1 - 0.01 * kdetune), -1)
  out(asig, asig2)
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>560</width>
 <height>410</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>45</r>
  <g>45</g>
  <b>48</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>8</y>
  <width>530</width>
  <height>40</height>
  <uuid>{0cff9c5f-31c1-4d7e-bf62-c7f8b59cad59}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat Slider Widget</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>45</r>
   <g>45</g>
   <b>48</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>48</y>
  <width>530</width>
  <height>52</height>
  <uuid>{1f98ff6f-42c3-4fb8-b540-9257b034b63e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Select "Flat style" in a slider's properties to enable this appearance. The slider can be filled up to the thumb or show the thumb only, and can have a numeric ruler on the side. Drag the thumb to change the value; hold Alt while dragging for fine control. Click the background to jump or nudge, according to the "Background click" setting.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>196</r>
   <g>196</g>
   <b>196</b>
  </color>
  <bgcolor mode="nobackground">
   <r>45</r>
   <g>45</g>
   <b>48</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>amp</objectName>
  <x>30</x>
  <y>120</y>
  <width>70</width>
  <height>230</height>
  <uuid>{71dbd9c6-e170-4a98-8707-7e9c1979dcac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.30000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#2b2b30</bgcolor>
  <foreground>#e8e8e8</foreground>
  <fillcolor>#4a9eff</fillcolor>
  <bordercolor>#5a5a60</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>7</borderRadius>
  <thumbWidth>24</thumbWidth>
  <thumbPadding>8</thumbPadding>
  <thumbRadius>5</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>full</rulermode>
  <rulercolor>#b8b8c0</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>115</x>
  <y>120</y>
  <width>100</width>
  <height>24</height>
  <uuid>{895616f0-61bd-45e9-9331-461ad9591b26}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>amp (fill)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>45</r>
   <g>45</g>
   <b>48</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>freq</objectName>
  <x>200</x>
  <y>120</y>
  <width>70</width>
  <height>230</height>
  <uuid>{0dfc171b-a9b0-474f-8ce4-b1f6b33c8cd6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <exponent>2.00000000</exponent>
  <value>440.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#2b2b30</bgcolor>
  <foreground>#ff9d3c</foreground>
  <fillcolor>#ff9d3c</fillcolor>
  <bordercolor>#5a5a60</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>5</borderRadius>
  <thumbWidth>20</thumbWidth>
  <thumbPadding>7</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>nudge</backgroundMode>
  <rulermode>compact</rulermode>
  <rulercolor>#b8b8c0</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>285</x>
  <y>120</y>
  <width>130</width>
  <height>24</height>
  <uuid>{42741935-d2fc-4dba-835e-98f2f4724598}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>freq (thumb, nudge)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>45</r>
   <g>45</g>
   <b>48</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>detune</objectName>
  <x>30</x>
  <y>300</y>
  <width>390</width>
  <height>46</height>
  <uuid>{27f82f14-4ef7-4583-b866-54f9ad160c30}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-20.00000000</minimum>
  <maximum>20.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#2b2b30</bgcolor>
  <foreground>#d8d8e8</foreground>
  <fillcolor>#64d07a</fillcolor>
  <bordercolor>#5a5a60</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>9</borderRadius>
  <thumbWidth>36</thumbWidth>
  <thumbPadding>8</thumbPadding>
  <thumbRadius>7</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>full</rulermode>
  <rulercolor>#b8b8c0</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>30</x>
  <y>352</y>
  <width>390</width>
  <height>24</height>
  <uuid>{7bb3bcb1-8124-4983-baf5-b8a92db266c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>detune, -20 to 20 cents (horizontal, fill with ruler)</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>45</r>
   <g>45</g>
   <b>48</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
