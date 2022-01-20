<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1 ; Schedule triggering of the instruments
	event_i "i", 2, 0, 1
	event_i "i", 3, 2, 1
	event_i "i", 4, 4, 1
endin

instr 2
	outvalue "text", "hello"
	turnoff
endin

instr 3
	outvalue "text", "world!"
	turnoff
endin

instr 4
	outvalue "text", ""
	turnoff
endin

instr 5
	Stext invalue "newtext"
	outvalue "newtext2", Stext
	turnoff
endin

</CsInstruments>
<CsScore>
f 0 3600
i 1 0 1

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>526</x>
 <y>244</y>
 <width>400</width>
 <height>215</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>184</x>
  <y>4</y>
  <width>187</width>
  <height>160</height>
  <uuid>{6d07505e-2f8f-4008-b92d-931960181272}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Bidirectional</label>
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
  <borderradius>4</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>13</x>
  <y>4</y>
  <width>143</width>
  <height>159</height>
  <uuid>{c70af99b-02b9-4385-9006-d86acfdc99a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>From Csound</label>
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
  <borderradius>4</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>text</objectName>
  <x>23</x>
  <y>28</y>
  <width>120</width>
  <height>60</height>
  <uuid>{a22f0ffb-eb18-498f-bcf6-5f224cf453f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>32</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>221</r>
   <g>218</g>
   <b>185</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>5</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>30</x>
  <y>98</y>
  <width>100</width>
  <height>40</height>
  <uuid>{d43733ec-7666-41ef-9791-c8a4243a970f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Do it again!</text>
  <image>/</image>
  <eventLine>i1 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>newtext</objectName>
  <x>197</x>
  <y>36</y>
  <width>155</width>
  <height>28</height>
  <uuid>{0099d584-ea13-403e-a054-8f4f27a583fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Type something</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>242</r>
   <g>241</g>
   <b>240</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName/>
  <x>197</x>
  <y>73</y>
  <width>157</width>
  <height>31</height>
  <uuid>{1500ee14-9464-4880-9ffe-7e694aaedd9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Now press here</text>
  <image>/</image>
  <eventLine>i5 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>newtext2</objectName>
  <x>198</x>
  <y>109</y>
  <width>157</width>
  <height>34</height>
  <uuid>{96db6328-fbc0-4de5-b709-22eab61db06b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
