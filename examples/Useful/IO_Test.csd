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
k2 max_k ain1, ktrig, 1

; slow decay time for meters (but fast attack)
if (k1 < koldk1) then
	k1 = koldk1 - (koldk1 - k1)*0.3
endif

if (k2 < koldk2) then
	k2 = koldk1 - (koldk2 - k2)*0.3
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
  <objectName2>in2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>-0.13005050</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>62</r>
   <g>255</g>
   <b>51</b>
  </color>
  <randomizable mode="both">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor2</objectName>
  <x>27</x>
  <y>65</y>
  <width>20</width>
  <height>167</height>
  <uuid>{9b761a44-1f92-480b-9656-ffdbfa02e0ed}</uuid>
  <objectName2>in1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>-0.13005050</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>62</r>
   <g>255</g>
   <b>51</b>
  </color>
  <randomizable mode="both">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>27</x>
  <y>228</y>
  <width>23</width>
  <height>25</height>
  <uuid>{cf92f08d-bb58-4a3d-acda-479165db96d4}</uuid>
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
  <value>-51.44692230</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable>false</randomizable>
  <mouseControl act="continuous"/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>indb2</objectName>
  <x>66</x>
  <y>255</y>
  <width>41</width>
  <height>21</height>
  <uuid>{38bd1f5e-dcf7-4897-a5c6-565e19983e63}</uuid>
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
  <value>-51.44692230</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable>false</randomizable>
  <mouseControl act="continuous"/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>117</x>
  <y>191</y>
  <width>131</width>
  <height>92</height>
  <uuid>{3b5a051f-f624-4116-b580-fb3fba6d3063}</uuid>
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
  <type>event</type>
  <value>1.00000000</value>
  <stringvalue> </stringvalue>
  <text>Generate note</text>
  <image>/</image>
  <eventLine>i3 0 0.5</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor21</objectName>
  <x>135</x>
  <y>217</y>
  <width>19</width>
  <height>19</height>
  <uuid>{a4ab00b5-62ab-45b1-9b1f-2978742d4057}</uuid>
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
  <randomizable mode="both">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>signal</objectName>
  <x>133</x>
  <y>81</y>
  <width>99</width>
  <height>23</height>
  <uuid>{6d7e91db-0e40-4c78-8ff3-e01a436b45af}</uuid>
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
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>146</x>
  <y>125</y>
  <width>23</width>
  <height>25</height>
  <uuid>{ebf16146-fe15-4a31-a76b-a9556d01ac6c}</uuid>
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
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>on2</objectName>
  <x>197</x>
  <y>109</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3887034c-1195-41f0-aaf4-fb6bbcf576b6}</uuid>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>level</objectName>
  <x>188</x>
  <y>149</y>
  <width>42</width>
  <height>22</height>
  <uuid>{766ecd94-db0b-4271-803c-f740b6ced0d6}</uuid>
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
  <randomizable>false</randomizable>
  <mouseControl act="continuous"/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>128</x>
  <y>149</y>
  <width>61</width>
  <height>25</height>
  <uuid>{d4f48a72-3837-4d07-9f63-c637cf212fc2}</uuid>
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
 <objectName/>
 <x>925</x>
 <y>371</y>
 <width>260</width>
 <height>294</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 925 371 260 294
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {33924, 32639, 22873}
ioText {4, 4} {386, 32} label 0.000000 0.00100 "" center "Helvetica" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder I/O Test
ioText {115, 40} {134, 216} label 0.000000 0.00100 "" left "Helvetica" 8 {0, 0, 0} {43520, 43520, 32512} nobackground noborder Audio Output
ioText {122, 82} {120, 165} label 0.000000 0.00100 "" left "Helvetica" 8 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Signal generator
ioText {1, 40} {107, 216} label 0.000000 0.00100 "" left "Helvetica" 8 {0, 0, 0} {43520, 43520, 32512} nobackground noborder Audio Input
ioMeter {75, 65} {20, 167} {15872, 65280, 13056} "hor2" 0.235294 "in2" -0.130050 fill 1 0 mouse
ioMeter {27, 65} {20, 167} {15872, 65280, 13056} "hor2" 0.235294 "in1" -0.130050 fill 1 0 mouse
ioText {18, 195} {23, 25} label 1.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 1
ioText {69, 195} {23, 25} label 2.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 2
ioText {13, 255} {41, 21} scroll -51.446922 0.100000 "indb1" center "Helvetica" 10 {15872, 65280, 13056} {0, 0, 0} background noborder -71.57502747
ioText {66, 255} {41, 21} scroll -51.446922 0.100000 "indb2" center "Helvetica" 10 {15872, 65280, 13056} {0, 0, 0} background noborder -56.08641434
ioText {253, 39} {134, 216} label 0.000000 0.00100 "" left "Helvetica" 8 {0, 0, 0} {43520, 43520, 32512} nobackground noborder MIDI note IO
ioText {290, 63} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Note in
ioButton {126, 241} {117, 28} event 1.000000 "button1" "Generate note" "/" i3 0 0.5
ioMeter {135, 217} {19, 19} {0, 59904, 0} "hor21" 0.000000 "notein" 0.000000 fill 1 0 mouse
ioMenu {133, 81} {99, 23} 2 303 "none,sine,noise" signal
ioText {140, 167} {23, 25} label 1.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 1
ioText {191, 167} {23, 25} label 2.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 2
ioCheckbox {147, 108} {20, 20} off on1
ioCheckbox {197, 109} {20, 20} off on2
ioText {188, 149} {42, 22} scroll -20.000000 0.100000 "level" center "Helvetica" 11 {0, 0, 0} {65280, 65280, 65280} background noborder -20.10000000
ioText {133, 204} {61, 25} label 0.000000 0.00100 "" right "Helvetica" 10 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Level
</MacGUI>
