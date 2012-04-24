<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

chn_k "family", 1
chn_k "freq", 1
chn_k "graph_index", 2
chn_k "lvl", 1
chn_k "table", 1
chn_k "type", 1
chn_k "vco2type", 1

instr 1
kfreq chnget "freq" 
klvl chnget "lvl" 
kfamily chnget "family"
ktype chnget "type"
kvco2type chnget "vco2type"
ktable chnget "table"
ktrig changed ktable, kvco2type
if ktrig == 1 then
	reinit contin
endif
itable init 0
ktable init 0
contin:
if kfamily == 0 then
	itable = i(ktable) + 1
	if ktype == 0 then
		aout oscil klvl, kfreq, itable
	elseif ktype == 1 then
		aout oscili klvl, kfreq, itable
	elseif ktype == 2 then
		aout oscil3 klvl, kfreq, itable
	endif
elseif kfamily == 1 then
	ivcomode = (i(kvco2type) == 0 ? 0 : 10)
	aout vco2 klvl, kfreq, ivcomode
endif
rireturn

dispfft  aout*3, 0.3, 4096
chnset  9, "graph_index"
outs aout, aout
endin


</CsInstruments>
<CsScore>
f 1 0 128 10 1
f 2 0 256 10 1
f 3 0 512 10 1
f 4 0 1024 10 1
f 5 0 2048 10 1
f 6 0 128 7 1 64 1 0 -1 64 -1
f 7 0 2048 7 1 1024 1 0 -1 1024 -1
f 8 0 128 7 1 128 -1
f 9 0 2048 7 1 2048 -1
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>168</x>
 <y>24</y>
 <width>632</width>
 <height>686</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>125</r>
  <g>162</g>
  <b>160</b>
 </bgcolor>
 <bsbObject version="2" type="BSBKnob">
  <objectName>freq</objectName>
  <x>23</x>
  <y>17</y>
  <width>77</width>
  <height>64</height>
  <uuid>{f3f063d0-e763-4241-b7dc-e47faa49b683}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>40.00000000</minimum>
  <maximum>6000.00000000</maximum>
  <value>457.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq</objectName>
  <x>22</x>
  <y>79</y>
  <width>80</width>
  <height>25</height>
  <uuid>{73ca508f-e5c4-490f-8c0a-5b31942e0b1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>457.200</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName>graph_index</objectName>
  <x>10</x>
  <y>124</y>
  <width>614</width>
  <height>392</height>
  <uuid>{e8171400-2abc-4f5d-8e5f-2e0b41527b2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>9</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>family</objectName>
  <x>225</x>
  <y>44</y>
  <width>124</width>
  <height>24</height>
  <uuid>{c1439ada-3f5f-47da-96f7-767c03edf27d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>oscil</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>vco2</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>362</x>
  <y>18</y>
  <width>132</width>
  <height>98</height>
  <uuid>{8ed58262-e6e8-4614-bb91-6a5ea9d98b5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Oscil family</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>157</r>
   <g>181</g>
   <b>162</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>type</objectName>
  <x>368</x>
  <y>40</y>
  <width>114</width>
  <height>25</height>
  <uuid>{d128cdf9-d072-4160-bbb6-3b5b58766976}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>no interp</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>linear</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>cubic</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>table</objectName>
  <x>369</x>
  <y>78</y>
  <width>114</width>
  <height>25</height>
  <uuid>{928fc1c8-3a38-48e2-98bf-9f6abf40e7ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>sine 128 pts</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sine 256 pts</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sine 512 pts</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sine 1024 pts</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sine 2048 pts</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>square 128</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>square 2048</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw 128</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw 2048</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>8</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>501</x>
  <y>19</y>
  <width>122</width>
  <height>97</height>
  <uuid>{0cf41946-251a-4a14-aa8f-962365c6dd8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Vco2 family</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>157</r>
   <g>181</g>
   <b>162</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>vco2type</objectName>
  <x>510</x>
  <y>42</y>
  <width>97</width>
  <height>25</height>
  <uuid>{977db827-71cc-4eb3-965b-aad120d8bd01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>saw</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> square</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>224</x>
  <y>17</y>
  <width>124</width>
  <height>25</height>
  <uuid>{9f0b962d-d6cc-4317-993b-9b53bc3ac47c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Oscillator family</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>family</objectName>
  <x>225</x>
  <y>44</y>
  <width>124</width>
  <height>24</height>
  <uuid>{bf1aebb3-d79d-46c9-84e8-fe90cdfaa1b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>oscil</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>vco2</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>225</x>
  <y>71</y>
  <width>126</width>
  <height>47</height>
  <uuid>{b2f5280d-d686-41c1-bb84-f76d0a6dadc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Oscil are table oscillators. Vco2 are bandlimited oscillators</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>11</x>
  <y>522</y>
  <width>613</width>
  <height>150</height>
  <uuid>{01df1763-b781-4b18-8a57-a93494946f55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>3.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>96</y>
  <width>80</width>
  <height>25</height>
  <uuid>{61ffec35-7a1d-40ef-bb36-8d3bf776528b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>lvl</objectName>
  <x>116</x>
  <y>18</y>
  <width>77</width>
  <height>64</height>
  <uuid>{172a87cd-e693-49c8-aed0-7a436b62a38e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.09000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>lvl</objectName>
  <x>115</x>
  <y>80</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6313f989-3573-40bf-82ed-e8cbbc6038ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.090</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>115</x>
  <y>97</y>
  <width>80</width>
  <height>25</height>
  <uuid>{02671c0f-49e6-4501-b58d-47d62f46e581}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
