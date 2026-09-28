<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	kfreq invalue "freq"
	asig oscili 0.2, kfreq
	kpan oscil 1, 1, 1
	apan = interp(lag(kpan, 0.1))
	outs asig*apan, asig*(1-apan)
endin

instr 2
  kfreq = chnget("freq")
  kdb = chnget("db")
  asig = oscili(1, kfreq * (1 + oscili(1, kfreq*1.68)))
  asig *= ampdb(kdb)
  ; send the audio to the scope
  chnset asig, "scope1"
endin


</CsInstruments>
<CsScore>
f 1 0 4096 -7 1 2048 1 0 0 2048 0

i 1 0 1000
i 2 0 1000
</CsScore>
</CsoundSynthesizer>








<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>326</x>
 <y>88</y>
 <width>491</width>
 <height>658</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>557</y>
  <width>463</width>
  <height>161</height>
  <uuid>{f024dfc1-5a4e-4cd0-85a4-655fd457eb39}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Scope can also read audio from a named channel</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>48</r>
   <g>48</g>
   <b>48</b>
  </bgcolor>
  <bordercolor>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>144</x>
  <y>1</y>
  <width>191</width>
  <height>39</height>
  <uuid>{22e4de93-d80c-453b-8a76-a6ad3bb5c4b8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Scope Widget</label>
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
  <x>10</x>
  <y>41</y>
  <width>465</width>
  <height>44</height>
  <uuid>{5a8df46b-c8e6-46ce-bb0d-80380ff2884a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The Scope widget is an oscilloscope which can show the output of Csound. The oscilloscope can show individual channels or a sum of all output channels. Clicking on a Scope widget freezes it.</label>
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
  <bgcolor mode="background">
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
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>10</x>
  <y>90</y>
  <width>465</width>
  <height>80</height>
  <uuid>{14105eb1-daf6-406d-845b-f4f1895cb1f3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2/>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>10</x>
  <y>173</y>
  <width>465</width>
  <height>80</height>
  <uuid>{09dd2a94-dcc8-49cc-b819-890da8bd1506}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2/>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName>80</objectName>
  <x>10</x>
  <y>256</y>
  <width>465</width>
  <height>80</height>
  <uuid>{41f59e5e-61e3-445d-833a-7b9624803ad9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>With trigger</description>
  <objectName2/>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>TriggerUp</triggermode>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>10</x>
  <y>386</y>
  <width>231</width>
  <height>80</height>
  <uuid>{b65d33f6-9d4a-4330-acdb-a097f4ca52b2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2/>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>8.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>344</y>
  <width>465</width>
  <height>40</height>
  <uuid>{7c7b875f-7bff-4359-9a43-ebc3ca6b92ac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The decimation property averages sample, allowing a larger time frame to be displayed. The default without decimation is one audio sample per screen pixel.</label>
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
  <bgcolor mode="background">
   <r>191</r>
   <g>204</g>
   <b>234</b>
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
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>250</x>
  <y>386</y>
  <width>226</width>
  <height>80</height>
  <uuid>{edce6d38-8f7b-435e-8ced-a81d92e1af20}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>With trigger up</description>
  <objectName2/>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>TriggerUp</triggermode>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>10</x>
  <y>470</y>
  <width>84</width>
  <height>84</height>
  <uuid>{cf5bf13a-2037-4bbc-a089-279ff65e160d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2/>
  <value>-1.00000000</value>
  <type>lissajou</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>100</x>
  <y>470</y>
  <width>84</width>
  <height>84</height>
  <uuid>{fa0440bd-3026-4686-8df8-6562dcbc37fe}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2/>
  <value>-1.00000000</value>
  <type>poincare</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>195</x>
  <y>470</y>
  <width>281</width>
  <height>82</height>
  <uuid>{8263c934-5d38-47ba-a842-06c9e6981ef6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The Scope widget can also show Lissajou and Poincare graphs. The decimation parameter in these cases determines the "zoom".</label>
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
  <bgcolor mode="background">
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
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>freq</objectName>
  <x>485</x>
  <y>88</y>
  <width>80</width>
  <height>80</height>
  <uuid>{a8e7f48f-cdfd-4b90-8620-34b479088dc6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>100.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>1013.52000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <textcolor>#ffaa00</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>true</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>485</x>
  <y>173</y>
  <width>83</width>
  <height>38</height>
  <uuid>{f7bc5048-75ac-4422-9b37-e03695421ebd}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Signal Frequency</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>77</r>
   <g>52</g>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>404</x>
  <y>388</y>
  <width>73</width>
  <height>28</height>
  <uuid>{a5f816e1-bf92-4c2d-b56e-c86e35431271}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>With trigger
</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>84</x>
  <y>584</y>
  <width>330</width>
  <height>120</height>
  <uuid>{cbbb5b65-37c5-4e81-805d-4a8c03736e1f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>scope1</objectName2>
  <value>0.00000000</value>
  <type>scope</type>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>TriggerUp</triggermode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>db</objectName>
  <x>576</x>
  <y>87</y>
  <width>80</width>
  <height>80</height>
  <uuid>{306097e3-bce9-4931-bb48-f487c50cac65}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-12.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#4a2600</textcolor>
  <border>1</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>true</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>576</x>
  <y>173</y>
  <width>83</width>
  <height>38</height>
  <uuid>{7a9f125c-6da1-405d-85ea-0f82b33f0181}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Volume (dB)</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>77</r>
   <g>52</g>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>404</x>
  <y>256</y>
  <width>73</width>
  <height>28</height>
  <uuid>{5191cfbe-5e29-44f8-932d-e22b80de05d7}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>With trigger
</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>404</x>
  <y>90</y>
  <width>73</width>
  <height>28</height>
  <uuid>{f596498b-aca0-4d45-b1af-26b3612fd560}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>No trigger</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>402</x>
  <y>172</y>
  <width>73</width>
  <height>28</height>
  <uuid>{2b8d5c63-96d7-4fb0-a6e8-ccb950659f16}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>No trigger</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
