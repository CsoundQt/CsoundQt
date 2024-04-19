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


</CsInstruments>
<CsScore>
f 1 0 4096 -7 1 2048 1 0 0 2048 0

i 1 0 1000
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
  <x>144</x>
  <y>1</y>
  <width>191</width>
  <height>39</height>
  <uuid>{22e4de93-d80c-453b-8a76-a6ad3bb5c4b8}</uuid>
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
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>10</x>
  <y>90</y>
  <width>465</width>
  <height>95</height>
  <uuid>{14105eb1-daf6-406d-845b-f4f1895cb1f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <y>190</y>
  <width>465</width>
  <height>95</height>
  <uuid>{09dd2a94-dcc8-49cc-b819-890da8bd1506}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <objectName/>
  <x>10</x>
  <y>290</y>
  <width>465</width>
  <height>95</height>
  <uuid>{41f59e5e-61e3-445d-833a-7b9624803ad9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>With trigger</description>
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
  <y>435</y>
  <width>231</width>
  <height>90</height>
  <uuid>{b65d33f6-9d4a-4330-acdb-a097f4ca52b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <y>390</y>
  <width>465</width>
  <height>40</height>
  <uuid>{7c7b875f-7bff-4359-9a43-ebc3ca6b92ac}</uuid>
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
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>250</x>
  <y>435</y>
  <width>226</width>
  <height>90</height>
  <uuid>{edce6d38-8f7b-435e-8ced-a81d92e1af20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>With trigger up</description>
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
  <y>535</y>
  <width>84</width>
  <height>84</height>
  <uuid>{cf5bf13a-2037-4bbc-a089-279ff65e160d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <y>535</y>
  <width>84</width>
  <height>84</height>
  <uuid>{fa0440bd-3026-4686-8df8-6562dcbc37fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <y>535</y>
  <width>281</width>
  <height>82</height>
  <uuid>{8263c934-5d38-47ba-a842-06c9e6981ef6}</uuid>
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
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>freq</objectName>
  <x>500</x>
  <y>155</y>
  <width>80</width>
  <height>80</height>
  <uuid>{a8e7f48f-cdfd-4b90-8620-34b479088dc6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>100.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>717.50000000</value>
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
  <x>500</x>
  <y>240</y>
  <width>83</width>
  <height>38</height>
  <uuid>{f7bc5048-75ac-4422-9b37-e03695421ebd}</uuid>
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
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>396</x>
  <y>88</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ff10449d-c7e7-44fe-ab19-7a9ea63b7d45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>No trigger</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>394</x>
  <y>188</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9bb7b498-b8b1-46e5-ac6c-119ca88cef38}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>No trigger</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>396</x>
  <y>291</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4ea1f73b-b11b-436a-97bb-8b1d0e618499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>With trigger
</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>397</x>
  <y>434</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a5f816e1-bf92-4c2d-b56e-c86e35431271}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>With trigger
</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
