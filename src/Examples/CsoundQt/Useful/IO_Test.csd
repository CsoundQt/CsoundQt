<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

massign 0, 2

instr 1
; Signal generator
ksignal invalue "signal"
klevel invalue "level"
kon1 invalue "on1"
kon2 invalue "on2"

k1 init -90
k2 init -90

klevel = ampdbfs(klevel)
asig = 0
if ksignal == 1 then
	asig oscil klevel, 1000, 1
elseif ksignal == 2 then
	asig rand klevel
endif

outs asig*kon1, asig*kon2

; Measure inputs

irange = 48
imin = ampdbfs(-irange)
ain1 inch 1
ain2 inch 2

ktrig metro 15

koldk1 = k1
koldk2 = k2
k1 max_k ain1, ktrig, 1
k2 max_k ain2, ktrig, 1

; slow decay time for meters (but fast attack)
if (k1 < koldk1) then
	k1 = koldk1 - (koldk1 - k1)*0.3
endif

if (k2 < koldk2) then
	k2 = koldk2 - (koldk2 - k2)*0.3
endif

if ktrig == 1 then
	outvalue "in1", (irange + dbfsamp(k1))/irange
	outvalue "in2", (irange + dbfsamp(k2))/irange
endif

;update tex display at slower rate
ktrig2 metro 4
if ktrig2 == 1 then
	outvalue "indb1", dbfsamp(k1)
	outvalue "indb2", dbfsamp(k2)
endif

endin

instr 2  ; midi note input
xtratim 0.1
kflag release
outvalue "notein", (kflag * -1)+ 1
endin

instr 3
noteondur 1, 60, 100, p3
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>957</x>
 <y>473</y>
 <width>260</width>
 <height>294</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>132</r>
  <g>127</g>
  <b>89</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>4</y>
  <width>245</width>
  <height>31</height>
  <uuid>{dc5604fd-41c0-4189-abe2-55c72f10172b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>I/O Test</label>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>117</x>
  <y>39</y>
  <width>131</width>
  <height>149</height>
  <uuid>{5685dc7a-1a9a-4199-ae42-93b1214fbf71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Audio Output</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>124</x>
  <y>57</y>
  <width>117</width>
  <height>122</height>
  <uuid>{fd6fcd6b-0db4-4c22-aeed-3c260dbe55c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Signal generator</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>8</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>39</y>
  <width>108</width>
  <height>244</height>
  <uuid>{6b0524fe-c62b-443e-a7cc-2786168abc62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Audio Input</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>75</x>
  <y>65</y>
  <width>20</width>
  <height>167</height>
  <uuid>{9144966e-0db1-4ae8-a1ad-3fb19f21a144}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>-0.75600833</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>62</r>
   <g>255</g>
   <b>51</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>27</x>
  <y>65</y>
  <width>20</width>
  <height>167</height>
  <uuid>{9b761a44-1f92-480b-9656-ffdbfa02e0ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>62</r>
   <g>255</g>
   <b>51</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>27</x>
  <y>228</y>
  <width>23</width>
  <height>25</height>
  <uuid>{cf92f08d-bb58-4a3d-acda-479165db96d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
  <x>76</x>
  <y>229</y>
  <width>23</width>
  <height>25</height>
  <uuid>{6065bd9d-67ac-4c5e-ba35-921b1df329a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>indb1</objectName>
  <x>13</x>
  <y>255</y>
  <width>41</width>
  <height>21</height>
  <uuid>{557e7fb7-3fab-45bd-b4ea-cbe3fd20a92a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>10</fontsize>
  <color>
   <r>62</r>
   <g>255</g>
   <b>51</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <value>-54.89196014</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>indb2</objectName>
  <x>66</x>
  <y>255</y>
  <width>41</width>
  <height>21</height>
  <uuid>{38bd1f5e-dcf7-4897-a5c6-565e19983e63}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>10</fontsize>
  <color>
   <r>62</r>
   <g>255</g>
   <b>51</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <value>-84.28839874</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>117</x>
  <y>191</y>
  <width>131</width>
  <height>92</height>
  <uuid>{3b5a051f-f624-4116-b580-fb3fba6d3063}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>MIDI note IO</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>170</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>156</x>
  <y>215</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b484dae2-4501-4669-9708-26b5a86ea084}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Note in</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>126</x>
  <y>241</y>
  <width>117</width>
  <height>28</height>
  <uuid>{a3545b15-5470-4efb-9dfd-eee56bc47d2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue> </stringvalue>
  <text>Generate note</text>
  <image>/</image>
  <eventLine>i3 0 0.5</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor21</objectName>
  <x>135</x>
  <y>217</y>
  <width>19</width>
  <height>19</height>
  <uuid>{a4ab00b5-62ab-45b1-9b1f-2978742d4057}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>notein</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>signal</objectName>
  <x>133</x>
  <y>81</y>
  <width>99</width>
  <height>23</height>
  <uuid>{6d7e91db-0e40-4c78-8ff3-e01a436b45af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>none</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sine</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>noise</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>146</x>
  <y>125</y>
  <width>23</width>
  <height>25</height>
  <uuid>{ebf16146-fe15-4a31-a76b-a9556d01ac6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
  <x>197</x>
  <y>125</y>
  <width>23</width>
  <height>25</height>
  <uuid>{e6cf4d14-2fc7-48b0-a54b-29da5244fd8c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>on1</objectName>
  <x>147</x>
  <y>108</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3c136c88-19ed-4e92-9def-eacb6213dc7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>on2</objectName>
  <x>197</x>
  <y>109</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3887034c-1195-41f0-aaf4-fb6bbcf576b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>level</objectName>
  <x>188</x>
  <y>149</y>
  <width>42</width>
  <height>22</height>
  <uuid>{766ecd94-db0b-4271-803c-f740b6ced0d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>11</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>-20.00000000</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>128</x>
  <y>149</y>
  <width>61</width>
  <height>25</height>
  <uuid>{d4f48a72-3837-4d07-9f63-c637cf212fc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>right</alignment>
  <font>Helvetica</font>
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
