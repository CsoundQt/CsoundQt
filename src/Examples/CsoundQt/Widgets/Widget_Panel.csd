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
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>308</x>
 <y>167</y>
 <width>428</width>
 <height>551</height>
 <visible>true</visible>
 <uuid/>
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
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>39.84375000</value>
  <mode>lin</mode>
  <mouseControl act="jump" >continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0" >true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>16</x>
  <y>55</y>
  <width>273</width>
  <height>155</height>
  <uuid>{e2d67816-aec0-4d10-9c1c-91e0aff6a55a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The widget panel contains widgets which can interact with Csound. It has two modes: an action mode and an edit mode. In the action mode widgets are used to send and receive values from Csound channels and can be modified using the mouse or the keyboard. In edit mode the widgets can be moved resized copied dupicated and pasted.</label>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>162</x>
  <y>218</y>
  <width>243</width>
  <height>126</height>
  <uuid>{992f7bb4-3b06-4921-89e7-62a852239c53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The modes are toggled using Ctrl+E or Command+E. When in edit mode red frames appear around every widget. Using these frames widgets can be moved and resized. You can also copy paste and duplicate widgets.</label>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob" >
  <objectName>knob3</objectName>
  <x>297</x>
  <y>49</y>
  <width>51</width>
  <height>53</height>
  <uuid>{b7fdac27-8f78-4a58-a7cc-2a8442859b2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.26262626</value>
  <mode>lin</mode>
  <mouseControl act="jump" >continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName/>
  <x>298</x>
  <y>109</y>
  <width>100</width>
  <height>26</height>
  <uuid>{d64e707e-94a6-4d6f-91fa-96a6281b0653}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>4502.01</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>button1</objectName>
  <x>298</x>
  <y>140</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2a151994-be4c-43b0-aa83-3e5d9b4eead4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>New Button</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>menu6</objectName>
  <x>298</x>
  <y>176</y>
  <width>80</width>
  <height>26</height>
  <uuid>{cff4de90-d3d2-4b91-a46f-3bd89cf01ce9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>scroll1</objectName>
  <x>42</x>
  <y>219</y>
  <width>105</width>
  <height>43</height>
  <uuid>{935af565-14cd-47de-bdb0-b4721b5a2377}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Courier New</font>
  <fontsize>40</fontsize>
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
  <value>55.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>4</borderwidth>
  <randomizable group="0" >false</randomizable>
  <mouseControl act="" />
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>scroll1</objectName>
  <x>41</x>
  <y>269</y>
  <width>107</width>
  <height>73</height>
  <uuid>{36487753-397c-4830-bd3b-687a703c7d1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>slider1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>100.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>100.00000000</yMax>
  <xValue>55.00000000</xValue>
  <yValue>39.84375000</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>16</x>
  <y>356</y>
  <width>297</width>
  <height>99</height>
  <uuid>{39cc7164-674c-412c-b9d2-b4f7e2c9fec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Widget properties can be accessed by right clicking on the widget and selecting 'Properties'. This works on both modes. Properties are different for every widget. If you right click where there are no widgets, you can set the Widget Panel's background color.</label>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox" >
  <objectName>checkbox10</objectName>
  <x>321</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a55de8f0-2955-43ea-934b-14f624928a0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName/>
  <x>319</x>
  <y>387</y>
  <width>87</width>
  <height>25</height>
  <uuid>{4f65c81a-84db-465e-b856-65cbd3aacb73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Type here</label>
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
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>14</x>
  <y>462</y>
  <width>388</width>
  <height>41</height>
  <uuid>{2528f251-f1cd-4b35-a099-65e0f983ffce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Note that none of the widgets shown here have effect since their channels are not being used by Csound.</label>
  <alignment>left</alignment>
  <font>Times New Roman</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>75</x>
  <y>4</y>
  <width>237</width>
  <height>38</height>
  <uuid>{72622cd0-4b49-49ee-92ae-ab788d0c3051}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The Widget Panel</label>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>24</fontsize>
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
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <objectName/>
 <x>308</x>
 <y>167</y>
 <width>428</width>
 <height>551</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {56026, 56026, 41891}
ioSlider {17, 219} {17, 128} 0.000000 100.000000 39.843750 slider1
ioText {16, 55} {273, 155} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder The widget panel contains widgets which can interact with Csound. It has two modes: an action mode and an edit mode. In the action mode widgets are used to send and receive values from Csound channels and can be modified using the mouse or the keyboard. In edit mode the widgets can be moved resized copied dupicated and pasted.
ioText {162, 218} {243, 126} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder The modes are toggled using Ctrl+E or Command+E. When in edit mode red frames appear around every widget. Using these frames widgets can be moved and resized. You can also copy paste and duplicate widgets.
ioKnob {297, 49} {51, 53} 1.000000 0.000000 0.010000 0.262626 knob3
ioText {298, 109} {100, 26} editnum 4502.010000 0.001000 "" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 4502.010000
ioButton {298, 140} {100, 30} event 1.000000 "button1" "New Button" "/" i1 0 10
ioMenu {298, 176} {80, 26} 1 303 "item1,item2,item3" menu6
ioText {42, 219} {105, 43} scroll 55.000000 1.000000 "scroll1" center "Courier New" 40 {65280, 65280, 65280} {10240, 20224, 12544} background noborder 
ioMeter {41, 269} {107, 73} {0, 59904, 0} "scroll1" 55.000000 "slider1" 39.843750 crosshair 1 0 mouse
ioText {16, 356} {297, 99} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Widget properties can be accessed by right clicking on the widget and selecting 'Properties'. This works on both modes. Properties are different for every widget. If you right click where there are no widgets, you can set the Widget Panel's background color.
ioCheckbox {321, 362} {20, 20} on checkbox10
ioText {319, 387} {87, 25} edit 0.000000 0.00100 ""  "Arial" 12 {0, 0, 0} {59392, 59392, 59392} falsenoborder Type here
ioText {14, 462} {388, 41} display 0.000000 0.00100 "" left "Times New Roman" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Note that none of the widgets shown here have effect since their channels are not being used by Csound.
ioText {75, 4} {237, 38} display 0.000000 0.00100 "" center "Helvetica" 24 {0, 0, 0} {43520, 43520, 32512} nobackground noborder The Widget Panel
</MacGUI>
