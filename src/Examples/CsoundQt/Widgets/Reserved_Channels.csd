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
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>692</x>
 <y>38</y>
 <width>451</width>
 <height>719</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>97</r>
  <g>136</g>
  <b>103</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>11</y>
  <width>418</width>
  <height>106</height>
  <uuid>{fc076c62-215e-488d-bcf5-138b70a1746f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Some channel names are reserved for special operations inside CsoundQt. These channel names send information to CsoundQt instead of to Csound allowing you to control certain aspects of CsoundQt from the Widget Panel.

NOTE: Buttons must be of "value" type for this to work!</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>20</r>
   <g>52</g>
   <b>6</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>315</y>
  <width>418</width>
  <height>234</height>
  <uuid>{399dce6a-681a-4961-8ae8-7b8fb6d03fdf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>File browsing</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>327</x>
  <y>325</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1b05c8d3-36bc-4176-8ff6-d61831b81cf7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/em/dev/forks/CsoundQt/src/Examples/CsoundQt/Widgets/Display_Widget.csd</stringvalue>
  <text>Browse A</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>204</x>
  <y>326</y>
  <width>118</width>
  <height>24</height>
  <uuid>{4f643090-f06a-4ea7-8f4d-771e6a7b3a36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_Browse1 channel -></label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse2</objectName>
  <x>327</x>
  <y>359</y>
  <width>80</width>
  <height>25</height>
  <uuid>{43808bcd-4a67-4a87-89e1-3001c45a33c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/em/dev/forks/CsoundQt/src/Examples/CsoundQt/Widgets/Menu_Widget.csd</stringvalue>
  <text>Browse B</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>204</x>
  <y>360</y>
  <width>118</width>
  <height>24</height>
  <uuid>{09e70074-0e92-426b-ba43-bbf301d6ae94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_Browse2 channel -></label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse1</objectName>
  <x>22</x>
  <y>390</y>
  <width>387</width>
  <height>25</height>
  <uuid>{42da76ac-45e4-4f72-98be-6362be9ea398}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>/home/em/dev/forks/CsoundQt/src/Examples/CsoundQt/Widgets/Display_Widget.csd</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse2</objectName>
  <x>22</x>
  <y>445</y>
  <width>387</width>
  <height>25</height>
  <uuid>{04667b55-26f5-4e76-9849-7fdbf28a49dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>/home/em/dev/forks/CsoundQt/src/Examples/CsoundQt/Widgets/Menu_Widget.csd</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>22</x>
  <y>362</y>
  <width>118</width>
  <height>24</height>
  <uuid>{c251528e-0c77-480c-a88f-dcf672ab3bb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>File A:</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>22</x>
  <y>419</y>
  <width>118</width>
  <height>24</height>
  <uuid>{b63de630-9bb9-4897-b5e6-153e703aea6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>File B:</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>122</y>
  <width>418</width>
  <height>184</height>
  <uuid>{474ddc50-8726-482c-a758-b314f7a5acde}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transport</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>315</x>
  <y>140</y>
  <width>78</width>
  <height>26</height>
  <uuid>{f29385c0-ccc3-42a0-a0a0-ec9f708e63a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Play</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Stop</objectName>
  <x>315</x>
  <y>205</y>
  <width>80</width>
  <height>26</height>
  <uuid>{32f3dc8e-90b5-4f9e-8022-7bae21b5ea44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>140</y>
  <width>101</width>
  <height>24</height>
  <uuid>{e8e89a83-2bb8-4a66-a4f9-2b21a9229b54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_Play channel</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>205</y>
  <width>101</width>
  <height>24</height>
  <uuid>{c2b21ba5-15a9-4a20-a2eb-415285fdac1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_Stop channel</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Render</objectName>
  <x>315</x>
  <y>250</y>
  <width>80</width>
  <height>25</height>
  <uuid>{24796cb7-0ffe-49bf-8f77-277e8ea029d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Render</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>186</x>
  <y>237</y>
  <width>126</width>
  <height>53</height>
  <uuid>{8fe255b4-f448-4fa1-babb-902a789dcd1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_Render channel
Run offline
(non-realtime)</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>counter</objectName>
  <x>21</x>
  <y>175</y>
  <width>161</width>
  <height>115</height>
  <uuid>{0c8d4057-e2b8-4655-ae97-4d8f55af0aec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>20</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Courier New</font>
  <fontsize>80</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>166</r>
   <g>232</g>
   <b>171</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>5</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>43</x>
  <y>149</y>
  <width>115</width>
  <height>23</height>
  <uuid>{8fb95296-1497-43e8-b493-9bfd10bd1972}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Playback counter</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Pause</objectName>
  <x>315</x>
  <y>170</y>
  <width>78</width>
  <height>26</height>
  <uuid>{e4765922-06cc-4238-8ee7-c748f3ebfcec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>1</stringvalue>
  <text>Pause</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>170</y>
  <width>101</width>
  <height>24</height>
  <uuid>{1396d5e8-585a-46c9-bd76-b12d218261bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_Pause channel
</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_MBrowse</objectName>
  <x>284</x>
  <y>483</y>
  <width>124</width>
  <height>25</height>
  <uuid>{77158a8c-3e82-49c6-93b4-0b6609df4451}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Browse Multiple</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>156</x>
  <y>484</y>
  <width>123</width>
  <height>24</height>
  <uuid>{91b7ceb5-d03d-460b-ac07-dc07d712410b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_MBrowse channel -></label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_MBrowse</objectName>
  <x>22</x>
  <y>512</y>
  <width>387</width>
  <height>25</height>
  <uuid>{b8e0ccf4-85f9-4796-9daf-ed969397268f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <bgcolor mode="nobackground">
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>556</y>
  <width>418</width>
  <height>113</height>
  <uuid>{b2673d42-3f27-4ff2-87c6-2aad0e0cb943}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Presets</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName>_GetPresetName</objectName>
  <x>170</x>
  <y>604</y>
  <width>66</width>
  <height>25</height>
  <uuid>{361f3003-e9f0-4666-8659-2fb56b36869e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Clear</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>633</y>
  <width>155</width>
  <height>24</height>
  <uuid>{7801bc93-343b-4de3-82cd-3ae912a1855d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_GetPresetNumber channel -></label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>605</y>
  <width>155</width>
  <height>24</height>
  <uuid>{04543569-031c-4aba-bff8-10a0fe3cebbd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_GetPresetName channel -></label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>_GetPresetNumber</objectName>
  <x>169</x>
  <y>632</y>
  <width>66</width>
  <height>25</height>
  <uuid>{68a4de7a-92b1-4778-b644-a9f9e516abe4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>_SetPreset</objectName>
  <x>293</x>
  <y>589</y>
  <width>65</width>
  <height>25</height>
  <uuid>{20d9fb5d-ca06-4568-a17f-9edf28ff2d2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </color>
  <bgcolor mode="background">
   <r>230</r>
   <g>230</g>
   <b>230</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>272</x>
  <y>566</y>
  <width>105</width>
  <height>24</height>
  <uuid>{2e7090d7-317c-4364-8f34-8671b3cd3fed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_SetPreset channel:</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>249</x>
  <y>615</y>
  <width>152</width>
  <height>24</height>
  <uuid>{a4407b84-550a-4096-a377-a369d31885bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>_SetPresetIndex channel:</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>_SetPresetIndex</objectName>
  <x>270</x>
  <y>637</y>
  <width>112</width>
  <height>25</height>
  <uuid>{45dfd95c-441a-4feb-9f87-4bb41c90e896}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <randomizable group="0">false</randomizable>
 </bsbObject>
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
