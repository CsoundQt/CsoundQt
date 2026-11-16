<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1
A4 = 442


instr 1  ; always on
  kmidi = chnget("midi")
  ka    = chnget("a")
  kb    = chnget("b")

  if changed(kmidi, ka, kb) == 1 then
    khertz = mtof(kmidi)
    chnset(sprintfk( "%.1f Hz.", khertz), "hertz")
    chnset(sprintfk( "is %.3f", ka*kb), "c")
  endif

endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>






<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>735</x>
 <y>252</y>
 <width>281</width>
 <height>319</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#8a959c</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>21</x>
  <y>7</y>
  <width>228</width>
  <height>62</height>
  <uuid>{e0d516ac-0bd9-4502-a3a2-9fa4f22f7054}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Scroll Number Widget</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <padding>2</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#bfccea</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>70</y>
  <width>250</width>
  <height>108</height>
  <uuid>{1972f251-3570-4dc4-8a87-50de9868eebe}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Scroll Number Widgets are just like display widgets but their values can be changed by dragging with the mouse. The number of decimal places used and the size of the step for each mouse pixel is set by the resolution in the properties.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="background">#bfccea</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>247</y>
  <width>250</width>
  <height>43</height>
  <uuid>{e42a48e9-9ee1-4337-8488-301faeedb988}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>6</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="background">#c1a38e</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>a</objectName>
  <x>16</x>
  <y>254</y>
  <width>55</width>
  <height>26</height>
  <uuid>{d46c4956-ab0b-4024-987f-e277c708d41a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <color>#1e1e1e</color>
  <bgcolor mode="background">#dcdcdc</bgcolor>
  <value>3.28400000</value>
  <resolution>0.00100000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>b</objectName>
  <x>111</x>
  <y>254</y>
  <width>55</width>
  <height>26</height>
  <uuid>{81904718-714a-4157-a559-e688b0c0205c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <color>#1e1e1e</color>
  <bgcolor mode="background">#dcdcdc</bgcolor>
  <value>18.40000000</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>71</x>
  <y>254</y>
  <width>44</width>
  <height>26</height>
  <uuid>{2ee5bcc9-bff7-4d21-a848-8b2af2c72899}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>times</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>c</objectName>
  <x>166</x>
  <y>254</y>
  <width>90</width>
  <height>26</height>
  <uuid>{73266aa0-0ae3-4bcd-bbaf-911453733b6c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>is 60.426</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>185</y>
  <width>250</width>
  <height>54</height>
  <uuid>{e0e82cee-79df-4f1c-9011-fd8655d840a5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="background">#c1a38e</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>midi</objectName>
  <x>19</x>
  <y>193</y>
  <width>87</width>
  <height>25</height>
  <uuid>{ae8f1ea4-e737-4ace-ba33-16f1b5c32b32}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>16</fontsize>
  <color>#ffffff</color>
  <bgcolor mode="background">#363f45</bgcolor>
  <value>88.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>16</x>
  <y>218</y>
  <width>110</width>
  <height>24</height>
  <uuid>{de1f7fcb-de33-4c40-a4fa-2c9aed935b86}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MIDI note number</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>108</x>
  <y>194</y>
  <width>38</width>
  <height>23</height>
  <uuid>{658fc00b-9195-42be-9887-1a49b2734e83}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>has</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>2</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>hertz</objectName>
  <x>151</x>
  <y>193</y>
  <width>97</width>
  <height>25</height>
  <uuid>{566a8d25-ee1d-4705-ba26-c36c772cd35f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1324.5 Hz.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>1</precision>
  <padding>3</padding>
  <color>#000000</color>
  <bgcolor mode="background">#ced6a9</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
