<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

instr 1  ; make sound
  ktransp  = chnget("transp")
  ktype    = chnget("type")
  if changed(ktype) == 1 then
    Stype = invalue("type/getitem")
    println "Menu idx: %d, item: %s", ktype, Stype
  endif
  ktfactor = tab(ktransp, 1)  ; map index to transposition factor
  if (ktype == 0) then
    axcite = oscil(1, 1, 2)
    asig   = wgflute(0.1, 880*ktfactor, 0.32, 0.1, 0.1, 0.15, 5.925, 0.1, 2)
  elseif (ktype == 1) then
    kenv = linsegr(0, 0.2, 1, 0.2, 0)
    asig = vco2(kenv*0.1, 440*ktfactor)
  elseif (ktype == 2) then
    asig = shaker(0.5, 880*ktfactor, 64*ktfactor, 0.7, 3, 0)
  endif
  out(asig*0.3, asig*0.3)
endin

instr 2  ; randomize
  itype   = rnd(3)
  itransp = rnd(3)
  chnset(int(itype),   "type")
  chnset(int(itransp), "transp")
  event "i", 1, 0, 2
  turnoff  ; send values only once
endin

</CsInstruments>
<CsScore>
f 1 0 8 -2 2 1 0.5  ;Transp factors (octave up, none, octave down)
f 2 0 16384 10 1

f 0 3600
</CsScore>
</CsoundSynthesizer>










<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>654</x>
 <y>238</y>
 <width>357</width>
 <height>279</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#f1f1e9</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>100</x>
  <y>5</y>
  <width>197</width>
  <height>41</height>
  <uuid>{2d5f32c3-fe84-423c-bf3a-c17e7e332060}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Menu Widget</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#bfccea</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>40</x>
  <y>49</y>
  <width>290</width>
  <height>114</height>
  <uuid>{f6d0f932-fa22-486e-8167-b37311d339c2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Menu widgets can show menus with user defined elements. The elements are set as a comma separated list in the properties. The menu widget transmits the index of the currently selected item counting from 0. The current index can also be set from Csound. </label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>11</fontsize>
  <padding>10</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="background">#dadad3</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>type</objectName>
  <x>107</x>
  <y>169</y>
  <width>80</width>
  <height>30</height>
  <uuid>{941b60cb-e13f-45c3-b7c3-cba6c825c8bf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>wgflute</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>shaker</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <bgcolor>#eff0f1</bgcolor>
  <foreground>#34393a</foreground>
  <bordercolor>#adbdc2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>0</borderRadius>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>199</x>
  <y>168</y>
  <width>160</width>
  <height>30</height>
  <uuid>{ada21fd8-091b-4dc6-bc5f-b140c2284ef5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Make sound</text>
  <eventLine>i1 0 2</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>true</latched>
  <fontsize>10</fontsize>
  <font/>
  <flatStyle>false</flatStyle>
  <color>#b1bfc8</color>
  <pressedColor/>
  <borderColor>#767f85</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>transp</objectName>
  <x>107</x>
  <y>204</y>
  <width>80</width>
  <height>30</height>
  <uuid>{39df8add-fa10-4f77-a705-e163fc12ee36}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>12</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>0</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>-12</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <bgcolor>#eff0f1</bgcolor>
  <foreground>#34393a</foreground>
  <bordercolor>#adbdc2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>0</borderRadius>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>199</x>
  <y>203</y>
  <width>160</width>
  <height>30</height>
  <uuid>{64b6bf1d-6215-4db6-8d37-8f14cf2fcb38}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Randomize and play</text>
  <eventLine>i2 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>true</latched>
  <fontsize>10</fontsize>
  <font/>
  <flatStyle>false</flatStyle>
  <color>#b1bfc8</color>
  <pressedColor/>
  <borderColor>#767f85</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>47</x>
  <y>172</y>
  <width>56</width>
  <height>25</height>
  <uuid>{78057116-2f3b-472a-bd12-7aa070157cb6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sound</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>13</x>
  <y>207</y>
  <width>90</width>
  <height>25</height>
  <uuid>{c3561f00-6a33-4e0a-8274-6b876f838c1b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>type</objectName>
  <x>105</x>
  <y>401</y>
  <width>80</width>
  <height>30</height>
  <uuid>{0a06aaa0-4226-47b1-b389-275169f5f2bf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>wgflute</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>shaker</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <flatStyle>true</flatStyle>
  <bgcolor>#eff0f1</bgcolor>
  <foreground>#34393a</foreground>
  <bordercolor>#adbdc2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>0</borderRadius>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>194</x>
  <y>401</y>
  <width>160</width>
  <height>30</height>
  <uuid>{b7c4fae4-b858-4b2f-b3c6-68a052314ec9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Make sound</text>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>true</latched>
  <fontsize>10</fontsize>
  <font>Liberation Sans</font>
  <flatStyle>true</flatStyle>
  <color>#b1bfc8</color>
  <pressedColor>#ffaa00</pressedColor>
  <borderColor>#767f85</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>transp</objectName>
  <x>105</x>
  <y>435</y>
  <width>80</width>
  <height>30</height>
  <uuid>{3398f729-e96c-4f86-bf87-7cbbf0c53a9d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>12</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>0</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>-12</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <flatStyle>true</flatStyle>
  <bgcolor>#eff0f1</bgcolor>
  <foreground>#34393a</foreground>
  <bordercolor>#adbdc2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>0</borderRadius>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>193</x>
  <y>435</y>
  <width>160</width>
  <height>30</height>
  <uuid>{6313a94e-a7a1-49f2-a165-2cd8463d70f4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Randomize and play</text>
  <eventLine>i2 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>true</latched>
  <fontsize>10</fontsize>
  <font>Liberation Sans</font>
  <flatStyle>true</flatStyle>
  <color>#b1bfc8</color>
  <pressedColor>#ffaa00</pressedColor>
  <borderColor>#767f85</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>44</x>
  <y>403</y>
  <width>56</width>
  <height>25</height>
  <uuid>{5c93b16e-22cb-477e-9ff6-35701a9808c9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sound</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>438</y>
  <width>90</width>
  <height>25</height>
  <uuid>{aa07968d-122c-4c1d-807c-d3bca984c4d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>38</x>
  <y>315</y>
  <width>288</width>
  <height>69</height>
  <uuid>{d5620c04-f6e3-4f20-8f2d-7cf28f032371}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Menus, like most other widgets, have a flat version which is the same across all platforms and independent from any application theme</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>11</fontsize>
  <padding>10</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="background">#dadad3</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>39</x>
  <y>283</y>
  <width>197</width>
  <height>41</height>
  <uuid>{d42448c6-8816-4724-9b74-a8000597fe35}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat Menus</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>16</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#bfccea</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
