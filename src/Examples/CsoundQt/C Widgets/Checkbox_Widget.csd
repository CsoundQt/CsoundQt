<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

instr 1
  khipass = chnget("hipass")
  klowpass = chnget("lowpass")
  kbandpass = chnget("bandpass")
  asig = noise(1, 0)
  if (khipass == 1) then
    asig = atone(asig, 3000)
    asig = atone(asig, 3000)
    asig = atone(asig, 3000)
  endif
  if (klowpass == 1) then
    asig = tone(asig, 8000)
    asig = tone(asig, 8000)
    asig = tone(asig, 8000)
  endif
  dispfft asig*20, 1/18, 1024
  out(asig*0.1, asig*0.1)
endin

instr 2  ; set checkbox values
  kstate = init(0)
  ktrig  = metro(1)
  if (ktrig == 1) then
    kstate = (kstate == 0 ? 1 : 0)
  endif
  kenable = chnget("enable")
  if (kenable == 1) then
    chnset(kstate, "checkbox")
    kenable = 0
  endif
endin

</CsInstruments>
<CsScore>
i 1 0 1000
i 2 0 1000
</CsScore>
</CsoundSynthesizer>












<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>691</x>
 <y>154</y>
 <width>412</width>
 <height>491</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#d4dfe6</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>80</x>
  <y>5</y>
  <width>247</width>
  <height>44</height>
  <uuid>{ad8c5fad-d76a-425a-a10e-4b87d3142e8b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Checkbox Widget</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#bfccea</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>50</y>
  <width>500</width>
  <height>56</height>
  <uuid>{35d4a9c6-98b9-4783-aed1-9ad640324b68}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The checkbox widget is a simple widget which sends a value of 1 on its channel when its checked and a 0 when not. It's value can also be set using a channel.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="background">#b8c3c8</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>48</x>
  <y>114</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c9d833b8-a125-42dc-bddd-fe01cedac125}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Hi Pass filter</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>48</x>
  <y>138</y>
  <width>105</width>
  <height>24</height>
  <uuid>{660ba30b-432e-4ba9-aa47-1fc6de0c1e14}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Low Pass filter</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName/>
  <x>15</x>
  <y>167</y>
  <width>500</width>
  <height>300</height>
  <uuid>{d4ba5f84-006d-44f5-8ad1-4959acf47abb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>false</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>false</showTableInfo>
  <showScrollbars>false</showScrollbars>
  <enableTables>false</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>475</y>
  <width>500</width>
  <height>96</height>
  <uuid>{95f875a7-941b-45b5-b4f9-d353d1f2e483}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Setting the value of a checkbox</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="background">#b8c3c8</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>checkbox</objectName>
  <x>25</x>
  <y>535</y>
  <width>20</width>
  <height>20</height>
  <uuid>{4784a930-dd88-408c-b5eb-9c17c28e0b5d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>false</flatStyle>
  <color>#0c0c0c</color>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <padding>0</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>533</y>
  <width>313</width>
  <height>28</height>
  <uuid>{0cea6f98-f6a5-4bba-9a75-2fb84e817366}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This Checkbox's value is set from Csound</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>enable</objectName>
  <x>25</x>
  <y>505</y>
  <width>20</width>
  <height>20</height>
  <uuid>{f773da97-1a7b-4950-aa2b-146323c34897}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>false</flatStyle>
  <color>#0c0c0c</color>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <padding>0</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>503</y>
  <width>336</width>
  <height>27</height>
  <uuid>{6e3bc69c-c7b1-4f5e-a83c-73474a679066}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Tick this checkbox to enable changing the one below</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>hipass</objectName>
  <x>25</x>
  <y>115</y>
  <width>20</width>
  <height>20</height>
  <uuid>{95ffad56-9b0a-4f4d-9698-26fea6b90a73}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>false</flatStyle>
  <color>#0c0c0c</color>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <padding>0</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>lowpass</objectName>
  <x>25</x>
  <y>140</y>
  <width>20</width>
  <height>20</height>
  <uuid>{b931c42f-6de4-4e79-add7-eb71793915ab}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>false</flatStyle>
  <color>#0c0c0c</color>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <padding>0</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>580</y>
  <width>500</width>
  <height>161</height>
  <uuid>{797e979d-345b-44d1-950b-b97de2c72d21}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat checkboxes</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>true</locked>
  <color>#000000</color>
  <bgcolor mode="background">#c1a9c8</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>check2</objectName>
  <x>25</x>
  <y>639</y>
  <width>20</width>
  <height>20</height>
  <uuid>{2bf922b1-d564-4d94-89a9-7b918f73a340}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <color>#191919</color>
  <borderColor>#525252</borderColor>
  <textColor>#cecece</textColor>
  <borderWidth>0</borderWidth>
  <borderRadius>0</borderRadius>
  <padding>2</padding>
  <checkstyle>full</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>636</y>
  <width>300</width>
  <height>28</height>
  <uuid>{a6b6ec39-4aaa-4b7b-9ca6-dfa50ad92a3c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat check box with "full" style check</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>check1</objectName>
  <x>25</x>
  <y>609</y>
  <width>20</width>
  <height>20</height>
  <uuid>{19a0bea3-2a25-48d4-9fb2-0f75971c0ac3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <color>#0c0c0c</color>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <padding>2</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>604</y>
  <width>300</width>
  <height>27</height>
  <uuid>{8f09dba5-6641-45a2-8d57-8126615c8c30}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat checkbox with x</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>check2</objectName>
  <x>25</x>
  <y>700</y>
  <width>20</width>
  <height>20</height>
  <uuid>{e444bfc3-8ac9-4cb0-9584-ab73b428e143}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <color>#732600</color>
  <borderColor>#643119</borderColor>
  <textColor>#ff6720</textColor>
  <borderWidth>2</borderWidth>
  <borderRadius>9</borderRadius>
  <padding>3</padding>
  <checkstyle>full</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>696</y>
  <width>300</width>
  <height>28</height>
  <uuid>{d71d653a-3038-4ff8-9c88-5cd3fa21dcbd}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat check box with "full" style check, round</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>check1</objectName>
  <x>25</x>
  <y>670</y>
  <width>20</width>
  <height>20</height>
  <uuid>{72c2a786-018f-47ee-ac6f-70d27a9b6dad}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <color>#0c0c0c</color>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <padding>4</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>665</y>
  <width>300</width>
  <height>27</height>
  <uuid>{c00259b3-8b09-4657-b885-f08cfd010ec3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat checkbox with x, more padding, square corners</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
