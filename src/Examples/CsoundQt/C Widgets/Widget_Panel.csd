<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
; Nothing here...
endin

</CsInstruments>
<CsScore>
f 0 3600
e
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>308</x>
 <y>167</y>
 <width>428</width>
 <height>551</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>212</r>
  <g>224</g>
  <b>230</b>
 </bgcolor>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>slider1</objectName>
  <x>15</x>
  <y>261</y>
  <width>25</width>
  <height>90</height>
  <uuid>{5491438a-64c2-4645-943c-964c1a77396d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>67.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>57</y>
  <width>274</width>
  <height>151</height>
  <uuid>{e2d67816-aec0-4d10-9c1c-91e0aff6a55a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The widget panel contains widgets which can interact with Csound. It has two modes: an action mode and an edit mode. In the action mode widgets are used to send and receive values from Csound channels and can be modified using the mouse or the keyboard. In edit mode the widgets can be moved resized copied dupicated and pasted.</label>
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
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>162</x>
  <y>218</y>
  <width>243</width>
  <height>126</height>
  <uuid>{992f7bb4-3b06-4921-89e7-62a852239c53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The modes are toggled using Ctrl+E or Command+E. When in edit mode red frames appear around every widget. Using these frames widgets can be moved and resized. You can also copy paste and duplicate widgets.</label>
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
  <bgcolor mode="background">
   <r>183</r>
   <g>194</g>
   <b>199</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>knob3</objectName>
  <x>315</x>
  <y>57</y>
  <width>60</width>
  <height>60</height>
  <uuid>{b7fdac27-8f78-4a58-a7cc-2a8442859b2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.45000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>1</border>
  <borderColor>#b47800</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName/>
  <x>296</x>
  <y>119</y>
  <width>100</width>
  <height>28</height>
  <uuid>{d64e707e-94a6-4d6f-91fa-96a6281b0653}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <color>
   <r>15</r>
   <g>15</g>
   <b>15</b>
  </color>
  <bgcolor mode="background">
   <r>240</r>
   <g>240</g>
   <b>240</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>295</x>
  <y>150</y>
  <width>100</width>
  <height>28</height>
  <uuid>{2a151994-be4c-43b0-aa83-3e5d9b4eead4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>New Button</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>menu6</objectName>
  <x>295</x>
  <y>181</y>
  <width>100</width>
  <height>28</height>
  <uuid>{cff4de90-d3d2-4b91-a46f-3bd89cf01ce9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>item1</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>item2</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>item3</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>scroll1</objectName>
  <x>42</x>
  <y>219</y>
  <width>105</width>
  <height>36</height>
  <uuid>{935af565-14cd-47de-bdb0-b4721b5a2377}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Liberation Mono</font>
  <fontsize>32</fontsize>
  <color>
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </color>
  <bgcolor mode="background">
   <r>40</r>
   <g>79</g>
   <b>49</b>
  </bgcolor>
  <value>43.11926606</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>scroll1</objectName>
  <x>41</x>
  <y>266</y>
  <width>109</width>
  <height>80</height>
  <uuid>{36487753-397c-4830-bd3b-687a703c7d1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>slider1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>100.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>100.00000000</yMax>
  <xValue>43.11926606</xValue>
  <yValue>67.50000000</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#505050</borderColor>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>360</y>
  <width>300</width>
  <height>100</height>
  <uuid>{39cc7164-674c-412c-b9d2-b4f7e2c9fec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Widget properties can be accessed by right clicking on the widget and selecting 'Properties'. This works on both modes. Properties are different for every widget. If you right click where there are no widgets, you can set the Widget Panel's background color.</label>
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
  <bgcolor mode="background">
   <r>183</r>
   <g>194</g>
   <b>199</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>checkbox10</objectName>
  <x>320</x>
  <y>360</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a55de8f0-2955-43ea-934b-14f624928a0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName/>
  <x>320</x>
  <y>390</y>
  <width>87</width>
  <height>25</height>
  <uuid>{4f65c81a-84db-465e-b856-65cbd3aacb73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Type here</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>240</r>
   <g>240</g>
   <b>240</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>465</y>
  <width>390</width>
  <height>42</height>
  <uuid>{2528f251-f1cd-4b35-a099-65e0f983ffce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Note that none of the widgets shown here have effect since their channels are not being used by Csound.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Serif</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>183</r>
   <g>194</g>
   <b>199</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>7</y>
  <width>390</width>
  <height>42</height>
  <uuid>{72622cd0-4b49-49ee-92ae-ab788d0c3051}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The Widget Panel</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Nimbus Sans [urw]</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>30</r>
   <g>30</g>
   <b>30</b>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
