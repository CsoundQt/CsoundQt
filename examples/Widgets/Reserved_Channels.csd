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

	ktrig metro 1, 0.99999
	Stime sprintfk "%i", kcount
	outvalue "counter", Stime
	if ktrig = 1 then
		kcount = kcount + 1
	endif
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600  ;turn on instr 1 for 3600 seconds
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>692</x>
 <y>38</y>
 <width>451</width>
 <height>719</height>
 <visible>true</visible>
 <uuid/>
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
  <height>106</height>
  <uuid>{fc076c62-215e-488d-bcf5-138b70a1746f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Some channel names are reserved for special operations inside QuteCsound. These channel names send information to QuteCsound instead of to Csound allowing you to control certain aspects of QuteCsound from the Widget Panel.

NOTE: Buttons must be of "value" type for this to work!</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>7</x>
  <y>315</y>
  <width>418</width>
  <height>234</height>
  <uuid>{399dce6a-681a-4961-8ae8-7b8fb6d03fdf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File browsing</label>
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
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Browse1</objectName>
  <x>327</x>
  <y>325</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1b05c8d3-36bc-4176-8ff6-d61831b81cf7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Browse A</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>204</x>
  <y>326</y>
  <width>118</width>
  <height>24</height>
  <uuid>{4f643090-f06a-4ea7-8f4d-771e6a7b3a36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_Browse1 channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Browse2</objectName>
  <x>327</x>
  <y>359</y>
  <width>80</width>
  <height>25</height>
  <uuid>{43808bcd-4a67-4a87-89e1-3001c45a33c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Browse B</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>204</x>
  <y>360</y>
  <width>118</width>
  <height>24</height>
  <uuid>{09e70074-0e92-426b-ba43-bbf301d6ae94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_Browse2 channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>_Browse1</objectName>
  <x>22</x>
  <y>390</y>
  <width>387</width>
  <height>25</height>
  <uuid>{42da76ac-45e4-4f72-98be-6362be9ea398}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <y>445</y>
  <width>387</width>
  <height>25</height>
  <uuid>{04667b55-26f5-4e76-9849-7fdbf28a49dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <y>362</y>
  <width>118</width>
  <height>24</height>
  <uuid>{c251528e-0c77-480c-a88f-dcf672ab3bb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File A:</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>22</x>
  <y>419</y>
  <width>118</width>
  <height>24</height>
  <uuid>{b63de630-9bb9-4897-b5e6-153e703aea6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File B:</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>6</x>
  <y>123</y>
  <width>418</width>
  <height>184</height>
  <uuid>{474ddc50-8726-482c-a758-b314f7a5acde}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Transport</label>
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
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Play</objectName>
  <x>316</x>
  <y>137</y>
  <width>78</width>
  <height>26</height>
  <uuid>{f29385c0-ccc3-42a0-a0a0-ec9f708e63a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Play</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Stop</objectName>
  <x>316</x>
  <y>204</y>
  <width>80</width>
  <height>25</height>
  <uuid>{32f3dc8e-90b5-4f9e-8022-7bae21b5ea44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>211</x>
  <y>138</y>
  <width>101</width>
  <height>24</height>
  <uuid>{e8e89a83-2bb8-4a66-a4f9-2b21a9229b54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_Play channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>211</x>
  <y>203</y>
  <width>101</width>
  <height>24</height>
  <uuid>{c2b21ba5-15a9-4a20-a2eb-415285fdac1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_Stop channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Render</objectName>
  <x>316</x>
  <y>237</y>
  <width>80</width>
  <height>25</height>
  <uuid>{24796cb7-0ffe-49bf-8f77-277e8ea029d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Render</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>186</x>
  <y>237</y>
  <width>126</width>
  <height>53</height>
  <uuid>{8fe255b4-f448-4fa1-babb-902a789dcd1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_Render channel ->
Run offline
(non-realtime)</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>counter</objectName>
  <x>21</x>
  <y>175</y>
  <width>161</width>
  <height>115</height>
  <uuid>{0c8d4057-e2b8-4655-ae97-4d8f55af0aec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0</label>
  <alignment>center</alignment>
  <font>Courier New</font>
  <fontsize>80</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>166</r>
   <g>232</g>
   <b>171</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>5</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>43</x>
  <y>149</y>
  <width>115</width>
  <height>23</height>
  <uuid>{8fb95296-1497-43e8-b493-9bfd10bd1972}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Playback counter</label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Pause</objectName>
  <x>316</x>
  <y>170</y>
  <width>78</width>
  <height>26</height>
  <uuid>{e4765922-06cc-4238-8ee7-c748f3ebfcec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Pause</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>211</x>
  <y>171</y>
  <width>101</width>
  <height>24</height>
  <uuid>{1396d5e8-585a-46c9-bd76-b12d218261bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_Pause channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_MBrowse</objectName>
  <x>284</x>
  <y>483</y>
  <width>124</width>
  <height>25</height>
  <uuid>{77158a8c-3e82-49c6-93b4-0b6609df4451}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Browse Multiple</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>156</x>
  <y>484</y>
  <width>123</width>
  <height>24</height>
  <uuid>{91b7ceb5-d03d-460b-ac07-dc07d712410b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_MBrowse channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>_MBrowse</objectName>
  <x>22</x>
  <y>512</y>
  <width>387</width>
  <height>25</height>
  <uuid>{b8e0ccf4-85f9-4796-9daf-ed969397268f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>7</x>
  <y>556</y>
  <width>418</width>
  <height>113</height>
  <uuid>{b2673d42-3f27-4ff2-87c6-2aad0e0cb943}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Presets</label>
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
  <objectName>_GetPresetName</objectName>
  <x>170</x>
  <y>604</y>
  <width>66</width>
  <height>25</height>
  <uuid>{361f3003-e9f0-4666-8659-2fb56b36869e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Clear</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>15</x>
  <y>633</y>
  <width>155</width>
  <height>24</height>
  <uuid>{7801bc93-343b-4de3-82cd-3ae912a1855d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_GetPresetNumber channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>15</x>
  <y>605</y>
  <width>155</width>
  <height>24</height>
  <uuid>{04543569-031c-4aba-bff8-10a0fe3cebbd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_GetPresetName channel -></label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber" >
  <objectName>_GetPresetNumber</objectName>
  <x>169</x>
  <y>632</y>
  <width>66</width>
  <height>25</height>
  <uuid>{68a4de7a-92b1-4778-b644-a9f9e516abe4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0" >false</randomizable>
  <mouseControl act="" />
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>_SetPreset</objectName>
  <x>293</x>
  <y>589</y>
  <width>65</width>
  <height>25</height>
  <uuid>{20d9fb5d-ca06-4568-a17f-9edf28ff2d2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>100</maximum>
  <randomizable group="0" >false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>272</x>
  <y>566</y>
  <width>105</width>
  <height>24</height>
  <uuid>{2e7090d7-317c-4364-8f34-8671b3cd3fed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_SetPreset channel:</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>249</x>
  <y>615</y>
  <width>152</width>
  <height>24</height>
  <uuid>{a4407b84-550a-4096-a377-a369d31885bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_SetPresetIndex channel:</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>_SetPresetIndex</objectName>
  <x>270</x>
  <y>637</y>
  <width>112</width>
  <height>25</height>
  <uuid>{45dfd95c-441a-4feb-9f87-4bb41c90e896}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Preset 1</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Clear</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Preset 2</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Last Preset</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <objectName/>
 <x>692</x>
 <y>38</y>
 <width>451</width>
 <height>719</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
<preset name="Preset 1" number="1" >
<value id="{1b05c8d3-36bc-4176-8ff6-d61831b81cf7}" mode="4" ></value>
<value id="{43808bcd-4a67-4a87-89e1-3001c45a33c3}" mode="4" ></value>
<value id="{42da76ac-45e4-4f72-98be-6362be9ea398}" mode="4" >File A From Preset 1</value>
<value id="{04667b55-26f5-4e76-9849-7fdbf28a49dd}" mode="4" >File B From Preset 1</value>
<value id="{f29385c0-ccc3-42a0-a0a0-ec9f708e63a4}" mode="4" >1</value>
<value id="{32f3dc8e-90b5-4f9e-8022-7bae21b5ea44}" mode="4" >1</value>
<value id="{24796cb7-0ffe-49bf-8f77-277e8ea029d2}" mode="4" >1</value>
<value id="{e4765922-06cc-4238-8ee7-c748f3ebfcec}" mode="4" >1</value>
<value id="{77158a8c-3e82-49c6-93b4-0b6609df4451}" mode="4" ></value>
<value id="{b8e0ccf4-85f9-4796-9daf-ed969397268f}" mode="4" >Files From Preset 1</value>
</preset>
<preset name="Clear" number="0" >
<value id="{1b05c8d3-36bc-4176-8ff6-d61831b81cf7}" mode="4" ></value>
<value id="{43808bcd-4a67-4a87-89e1-3001c45a33c3}" mode="4" ></value>
<value id="{42da76ac-45e4-4f72-98be-6362be9ea398}" mode="4" ></value>
<value id="{04667b55-26f5-4e76-9849-7fdbf28a49dd}" mode="4" ></value>
<value id="{f29385c0-ccc3-42a0-a0a0-ec9f708e63a4}" mode="4" >1</value>
<value id="{32f3dc8e-90b5-4f9e-8022-7bae21b5ea44}" mode="4" >1</value>
<value id="{24796cb7-0ffe-49bf-8f77-277e8ea029d2}" mode="4" >1</value>
<value id="{e4765922-06cc-4238-8ee7-c748f3ebfcec}" mode="4" >1</value>
<value id="{77158a8c-3e82-49c6-93b4-0b6609df4451}" mode="4" ></value>
<value id="{b8e0ccf4-85f9-4796-9daf-ed969397268f}" mode="4" ></value>
</preset>
<preset name="Preset 2" number="2" >
<value id="{1b05c8d3-36bc-4176-8ff6-d61831b81cf7}" mode="4" ></value>
<value id="{43808bcd-4a67-4a87-89e1-3001c45a33c3}" mode="4" ></value>
<value id="{42da76ac-45e4-4f72-98be-6362be9ea398}" mode="4" >File A From Preset 2</value>
<value id="{04667b55-26f5-4e76-9849-7fdbf28a49dd}" mode="4" >File B From Preset 2</value>
<value id="{f29385c0-ccc3-42a0-a0a0-ec9f708e63a4}" mode="4" >1</value>
<value id="{32f3dc8e-90b5-4f9e-8022-7bae21b5ea44}" mode="4" >1</value>
<value id="{24796cb7-0ffe-49bf-8f77-277e8ea029d2}" mode="4" >1</value>
<value id="{e4765922-06cc-4238-8ee7-c748f3ebfcec}" mode="4" >1</value>
<value id="{77158a8c-3e82-49c6-93b4-0b6609df4451}" mode="4" ></value>
<value id="{b8e0ccf4-85f9-4796-9daf-ed969397268f}" mode="4" >Files From Preset 2</value>
</preset>
<preset name="Last Preset" number="99" >
<value id="{1b05c8d3-36bc-4176-8ff6-d61831b81cf7}" mode="4" ></value>
<value id="{43808bcd-4a67-4a87-89e1-3001c45a33c3}" mode="4" ></value>
<value id="{42da76ac-45e4-4f72-98be-6362be9ea398}" mode="4" >File A From Preset 99</value>
<value id="{04667b55-26f5-4e76-9849-7fdbf28a49dd}" mode="4" >File B From Preset 99-Called "Last Preset"</value>
<value id="{f29385c0-ccc3-42a0-a0a0-ec9f708e63a4}" mode="4" >1</value>
<value id="{32f3dc8e-90b5-4f9e-8022-7bae21b5ea44}" mode="4" >1</value>
<value id="{24796cb7-0ffe-49bf-8f77-277e8ea029d2}" mode="4" >1</value>
<value id="{e4765922-06cc-4238-8ee7-c748f3ebfcec}" mode="4" >1</value>
<value id="{77158a8c-3e82-49c6-93b4-0b6609df4451}" mode="4" ></value>
<value id="{b8e0ccf4-85f9-4796-9daf-ed969397268f}" mode="4" >Files From Preset 9</value>
</preset>
</bsbPresets>
<MacGUI>
ioView background {24929, 34952, 26471}
ioText {6, 11} {418, 106} label 0.000000 0.00100 "" center "Arial" 12 {5120, 13312, 1536} {62464, 63488, 51200} nobackground noborder Some channel names are reserved for special operations inside QuteCsound. These channel names send information to QuteCsound instead of to Csound allowing you to control certain aspects of QuteCsound from the Widget Panel.Â¬Â¬NOTE: Buttons must be of "value" type for this to work!
ioText {7, 315} {418, 234} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder File browsing
ioButton {327, 325} {80, 25} value 1.000000 "_Browse1" "Browse A" "/" i1 0 10
ioText {204, 326} {118, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _Browse1 channel ->
ioButton {327, 359} {80, 25} value 1.000000 "_Browse2" "Browse B" "/" i1 0 10
ioText {204, 360} {118, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _Browse2 channel ->
ioText {22, 390} {387, 25} edit 0.000000 0.00100 "_Browse1"  "Arial" 10 {0, 0, 0} {58880, 56576, 54528} falsenoborder 
ioText {22, 445} {387, 25} edit 0.000000 0.00100 "_Browse2"  "Arial" 10 {0, 0, 0} {58880, 56576, 54528} falsenoborder 
ioText {22, 362} {118, 24} label 0.000000 0.00100 "" left "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder File A:
ioText {22, 419} {118, 24} label 0.000000 0.00100 "" left "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder File B:
ioText {6, 123} {418, 184} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Transport
ioButton {316, 137} {78, 26} value 1.000000 "_Play" "Play" "/" i1 0 10
ioButton {316, 204} {80, 25} value 1.000000 "_Stop" "Stop" "/" i1 0 10
ioText {211, 138} {101, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _Play channel ->
ioText {211, 203} {101, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _Stop channel ->
ioButton {316, 237} {80, 25} value 1.000000 "_Render" "Render" "/" i1 0 10
ioText {186, 237} {126, 53} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _Render channel ->Â¬Run offlineÂ¬(non-realtime)
ioText {21, 175} {161, 115} label 0.000000 0.00100 "counter" center "Courier New" 80 {0, 0, 0} {42496, 59392, 43776} nobackground noborder 0
ioText {43, 149} {115, 23} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Playback counter
ioButton {316, 170} {78, 26} value 1.000000 "_Pause" "Pause" "/" i1 0 10
ioText {211, 171} {101, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _Pause channel ->
ioButton {284, 483} {124, 25} value 1.000000 "_MBrowse" "Browse Multiple" "/" i1 0 10
ioText {156, 484} {123, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _MBrowse channel ->
ioText {22, 512} {387, 25} edit 0.000000 0.00100 "_MBrowse"  "Arial" 10 {0, 0, 0} {58880, 56576, 54528} falsenoborder 
ioText {7, 556} {418, 113} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Presets
ioText {170, 604} {66, 25} label 0.000000 0.00100 "_GetPresetName" left "Arial" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Clear
ioText {15, 633} {155, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _GetPresetNumber channel ->
ioText {15, 605} {155, 24} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _GetPresetName channel ->
ioText {169, 632} {66, 25} scroll 0.000000 1.000000 "_GetPresetNumber" center "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {293, 589} {65, 25} editnum 0.000000 1.000000 "_SetPreset" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 0.000000
ioText {272, 566} {105, 24} label 0.000000 0.00100 "" center "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _SetPreset channel:
ioText {249, 615} {152, 24} label 0.000000 0.00100 "" center "Arial" 10 {65280, 65280, 65280} {58880, 56576, 54528} nobackground noborder _SetPresetIndex channel:
ioMenu {270, 637} {112, 25} 1 303 "Preset 1,Clear,Preset 2,Last Preset" _SetPresetIndex
</MacGUI>
