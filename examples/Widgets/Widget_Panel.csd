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


<bsbPresets>
</bsbPresets>


<bsbPresets>
</bsbPresets>


<bsbPresets>
</bsbPresets>


<bsbPresets>
</bsbPresets>

<bsbPanel>
 <bgcolor mode="background" >
  <r>218</r>
  <g>218</g>
  <b>163</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider" >
  <objectName>slider1</objectName>
  <x>17</x>
  <y>219</y>
  <width>17</width>
  <height>128</height>
  <uuid>{5491438a-64c2-4645-943c-964c1a77396d}</uuid>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.67187500</value>
  <resolution>-1.00000000</resolution>
  <randomizable>true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>16</x>
  <y>55</y>
  <width>273</width>
  <height>155</height>
  <uuid>{e2d67816-aec0-4d10-9c1c-91e0aff6a55a}</uuid>
  <label>The widget panel contains widgets which can interact with Csound. It has two modes: an action mode and an edit mode. In the action mode widgets are used to send and receive values from Csound channels and can be modified using the mouse or the keyboard. In edit mode the widgets can be moved resized copied dupicated and pasted.</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>162</x>
  <y>218</y>
  <width>243</width>
  <height>126</height>
  <uuid>{992f7bb4-3b06-4921-89e7-62a852239c53}</uuid>
  <label>The modes are toggled using Ctrl+E or Command+E. When in edit mode red frames appear around every widget. Using these frames widgets can be moved and resized. You can also copy paste and duplicate widgets.</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob" >
  <objectName>knob3</objectName>
  <x>297</x>
  <y>49</y>
  <width>51</width>
  <height>53</height>
  <uuid>{b7fdac27-8f78-4a58-a7cc-2a8442859b2c}</uuid>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.28282828</value>
  <randomizable/>
  <resolution>0.01000000</resolution>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName/>
  <x>298</x>
  <y>109</y>
  <width>100</width>
  <height>26</height>
  <uuid>{d64e707e-94a6-4d6f-91fa-96a6281b0653}</uuid>
  <type>editnum</type>
  <value>4502.01</value>
  <resolution>0.00100000</resolution>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>6</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+14</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>button1</objectName>
  <x>298</x>
  <y>140</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2a151994-be4c-43b0-aa83-3e5d9b4eead4}</uuid>
  <type>event</type>
  <value>1.00000000</value>
  <stringvalue/>
  <text>New Button</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>menu6</objectName>
  <x>298</x>
  <y>176</y>
  <width>80</width>
  <height>30</height>
  <uuid>{cff4de90-d3d2-4b91-a46f-3bd89cf01ce9}</uuid>
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
  <selectedIndex>1</selectedIndex>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName/>
  <x>42</x>
  <y>219</y>
  <width>105</width>
  <height>43</height>
  <uuid>{935af565-14cd-47de-bdb0-b4721b5a2377}</uuid>
  <alignment>center</alignment>
  <font>Courier New</font>
  <fontsize>26</fontsize>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background" >
   <r>40</r>
   <g>79</g>
   <b>49</b>
  </bgcolor>
  <value>40.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <randomizable>false</randomizable>
  <mouseControl act="" />
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>vert8</objectName>
  <x>41</x>
  <y>269</y>
  <width>107</width>
  <height>73</height>
  <uuid>{36487753-397c-4830-bd3b-687a703c7d1f}</uuid>
  <objectName2>hor8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.42465753</xValue>
  <yValue>0.38317757</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>16</x>
  <y>358</y>
  <width>291</width>
  <height>111</height>
  <uuid>{39cc7164-674c-412c-b9d2-b4f7e2c9fec2}</uuid>
  <label>Widget properties can be accessed by right clicking on the widget and selecting 'Properties'. This works on both modes. Properties are different for every widget. If you right click where there are no widgets, you can set the Widget Panel's background color.</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox" >
  <objectName>checkbox10</objectName>
  <x>321</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a55de8f0-2955-43ea-934b-14f624928a0b}</uuid>
  <selected>true</selected>
  <label/>
  <value>1.00000000</value>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName/>
  <x>319</x>
  <y>387</y>
  <width>87</width>
  <height>25</height>
  <uuid>{4f65c81a-84db-465e-b856-65cbd3aacb73}</uuid>
  <label>Type here</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>16</x>
  <y>475</y>
  <width>388</width>
  <height>41</height>
  <uuid>{2528f251-f1cd-4b35-a099-65e0f983ffce}</uuid>
  <label>Note that none of the widgets shown here have effect since their channels are not being used by Csound.</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>75</x>
  <y>4</y>
  <width>237</width>
  <height>38</height>
  <uuid>{72622cd0-4b49-49ee-92ae-ab788d0c3051}</uuid>
  <label>The Widget Panel</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <objectName/>
 <x>776</x>
 <y>162</y>
 <width>425</width>
 <height>557</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>