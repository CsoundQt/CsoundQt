<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1  ;random frequencies
kcount init 0
kfreq  randomh  80, 1000, 4
aout oscil 0.2, kfreq, 1
outs aout, aout
ktrig metro 1, 0.99999999
Stime sprintfk "%i", kcount
outvalue "counter", Stime
if ktrig = 1 then
kcount = kcount + 1
endif
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 10  ;turn on instr 1 for 3600 seconds
</CsScore>
</CsoundSynthesizer>









<bsbPanel>
 <bgcolor mode="background" >
  <r>97</r>
  <g>136</g>
  <b>103</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>6</x>
  <y>11</y>
  <width>418</width>
  <height>94</height>
  <uuid>{fc076c62-215e-488d-bcf5-138b70a1746f}</uuid>
  <label>Some channel names are reserved for special operations inside QuteCsound. These channel names send information to QuteCsound instead of to Csound allowing you to control certain aspects of QuteCsound from the Widget Panel.

NOTE: Buttons must be of "value" type for this to work!</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>20</r>
   <g>52</g>
   <b>6</b>
  </color>
  <bgcolor mode="background" >
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>7</x>
  <y>304</y>
  <width>416</width>
  <height>171</height>
  <uuid>{399dce6a-681a-4961-8ae8-7b8fb6d03fdf}</uuid>
  <label>File browsing</label>
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
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Browse1</objectName>
  <x>327</x>
  <y>314</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1b05c8d3-36bc-4176-8ff6-d61831b81cf7}</uuid>
  <type>value</type>
  <value>1.00000000</value>
  <stringvalue>/home/andres/src/qutecsound/branches/new-format/qutecsound/examples/Widgets/Lineedit_Widget.csd</stringvalue>
  <text>Browse A</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>204</x>
  <y>315</y>
  <width>118</width>
  <height>24</height>
  <uuid>{4f643090-f06a-4ea7-8f4d-771e6a7b3a36}</uuid>
  <label>_Browse1 channel -></label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Browse2</objectName>
  <x>327</x>
  <y>348</y>
  <width>80</width>
  <height>25</height>
  <uuid>{43808bcd-4a67-4a87-89e1-3001c45a33c3}</uuid>
  <type>value</type>
  <value>1.00000000</value>
  <stringvalue>/home/andres/src/qutecsound/branches/new-format/qutecsound/examples/Widgets/SpinBox_Widget.csd</stringvalue>
  <text>Browse B</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>204</x>
  <y>349</y>
  <width>118</width>
  <height>24</height>
  <uuid>{09e70074-0e92-426b-ba43-bbf301d6ae94}</uuid>
  <label>_Browse2 channel -></label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>_Browse1</objectName>
  <x>22</x>
  <y>379</y>
  <width>387</width>
  <height>25</height>
  <uuid>{42da76ac-45e4-4f72-98be-6362be9ea398}</uuid>
  <label/>
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
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>_Browse2</objectName>
  <x>22</x>
  <y>434</y>
  <width>387</width>
  <height>25</height>
  <uuid>{04667b55-26f5-4e76-9849-7fdbf28a49dd}</uuid>
  <label/>
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
  <x>22</x>
  <y>351</y>
  <width>118</width>
  <height>24</height>
  <uuid>{c251528e-0c77-480c-a88f-dcf672ab3bb8}</uuid>
  <label>File A:</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>22</x>
  <y>408</y>
  <width>118</width>
  <height>24</height>
  <uuid>{b63de630-9bb9-4897-b5e6-153e703aea6e}</uuid>
  <label>File B:</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>6</x>
  <y>112</y>
  <width>418</width>
  <height>184</height>
  <uuid>{474ddc50-8726-482c-a758-b314f7a5acde}</uuid>
  <label>Transport</label>
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
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Play</objectName>
  <x>316</x>
  <y>126</y>
  <width>78</width>
  <height>26</height>
  <uuid>{f29385c0-ccc3-42a0-a0a0-ec9f708e63a4}</uuid>
  <type>value</type>
  <value>1.00000000</value>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Stop</objectName>
  <x>318</x>
  <y>194</y>
  <width>80</width>
  <height>25</height>
  <uuid>{32f3dc8e-90b5-4f9e-8022-7bae21b5ea44}</uuid>
  <type>value</type>
  <value>1.00000000</value>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>211</x>
  <y>128</y>
  <width>101</width>
  <height>24</height>
  <uuid>{e8e89a83-2bb8-4a66-a4f9-2b21a9229b54}</uuid>
  <label>_Play channel -></label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>212</x>
  <y>195</y>
  <width>101</width>
  <height>24</height>
  <uuid>{c2b21ba5-15a9-4a20-a2eb-415285fdac1f}</uuid>
  <label>_Stop channel -></label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Render</objectName>
  <x>319</x>
  <y>226</y>
  <width>80</width>
  <height>25</height>
  <uuid>{24796cb7-0ffe-49bf-8f77-277e8ea029d2}</uuid>
  <type>value</type>
  <value>1.00000000</value>
  <stringvalue/>
  <text>Render</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>157</x>
  <y>227</y>
  <width>157</width>
  <height>52</height>
  <uuid>{8fe255b4-f448-4fa1-babb-902a789dcd1f}</uuid>
  <label>_Render channel ->
Run offline
(non-realtime)</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>counter</objectName>
  <x>20</x>
  <y>164</y>
  <width>160</width>
  <height>63</height>
  <uuid>{0c8d4057-e2b8-4655-ae97-4d8f55af0aec}</uuid>
  <label>0</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>26</fontsize>
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
  <x>43</x>
  <y>138</y>
  <width>115</width>
  <height>23</height>
  <uuid>{8fb95296-1497-43e8-b493-9bfd10bd1972}</uuid>
  <label>Playback counter</label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Pause</objectName>
  <x>317</x>
  <y>159</y>
  <width>78</width>
  <height>26</height>
  <uuid>{e4765922-06cc-4238-8ee7-c748f3ebfcec}</uuid>
  <type>value</type>
  <value>1.00000000</value>
  <stringvalue/>
  <text>Pause</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>212</x>
  <y>161</y>
  <width>101</width>
  <height>24</height>
  <uuid>{1396d5e8-585a-46c9-bd76-b12d218261bf}</uuid>
  <label>_Pause channel -></label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <objectName/>
 <x>795</x>
 <y>228</y>
 <width>444</width>
 <height>518</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>