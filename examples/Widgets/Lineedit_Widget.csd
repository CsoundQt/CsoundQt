<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1

	Sin invalue "instring"
	outvalue "display", Sin

	Sline invalue "lineedit"
	klevel invalue "level"
	kdur invalue "dur"
	kcomp strcmpk Sline, "-"
	; trigger notes only when line is not empty
	ktrig = (kcomp != 0? 1: 0)
	kchr strchark Sline, 1
	schedkwhen ktrig, 0.05, 10, 2, 0, kdur, kchr, klevel
	outvalue "lineedit", "-" ;empty line edit widget
endin

instr 2
	idur = p3
	ilevel = p5
	icps = 440 * 2^((p4 - 100)/12)
	aout oscils ilevel, icps, 0
	aenv adsr 0.2*idur, 0.2*idur, 0.7, 0.3*idur
	outs aout*aenv, aout*aenv
endin

</CsInstruments>
<CsScore>
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>797</x>
 <y>193</y>
 <width>295</width>
 <height>431</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>161</g>
  <b>169</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>197</y>
  <width>277</width>
  <height>213</height>
  <uuid>{085c635a-66f9-4532-8df3-1dfcf28600cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>87</r>
   <g>89</g>
   <b>78</b>
  </color>
  <bgcolor mode="background">
   <r>194</r>
   <g>203</g>
   <b>197</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>203</y>
  <width>264</width>
  <height>199</height>
  <uuid>{b37e9f05-df2d-4a31-ab50-f93173624086}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The Line Edit Widget can also be used to receive strings from Csound. Put the keyboard focus on the line edit widget below and type on the ASCII keyboard.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>85</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>194</r>
   <g>197</g>
   <b>214</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>lineedit</objectName>
  <x>188</x>
  <y>283</y>
  <width>25</width>
  <height>25</height>
  <uuid>{eca8b99c-5d0e-4bd0-adb5-199c226b5305}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>level</objectName>
  <x>50</x>
  <y>323</y>
  <width>50</width>
  <height>49</height>
  <uuid>{d6a1bbac-0b3f-49ba-b281-6a31c464d7b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.21363636</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>45</x>
  <y>283</y>
  <width>146</width>
  <height>25</height>
  <uuid>{f9f54980-38ff-4721-97d6-8afa7a524711}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Put keyboard focus here --></label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>51</x>
  <y>367</y>
  <width>49</width>
  <height>24</height>
  <uuid>{2cd5cd9d-6ca7-4350-b274-ef793f5dedce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>center</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>dur</objectName>
  <x>128</x>
  <y>335</y>
  <width>109</width>
  <height>19</height>
  <uuid>{7b7e5745-622f-411c-97d8-b4136ee2b401}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.20000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.12477064</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>158</x>
  <y>353</y>
  <width>60</width>
  <height>22</height>
  <uuid>{0f74a0f5-f1a9-4ef5-962c-e1753a6e6cc5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>duration</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>46</y>
  <width>274</width>
  <height>148</height>
  <uuid>{187b22e7-31c4-4f4c-bb47-168034be6765}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The Line Edit Widget can be used to pass strings from the widget panel to the csound program.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>85</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>194</r>
   <g>197</g>
   <b>214</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>instring</objectName>
  <x>15</x>
  <y>92</y>
  <width>262</width>
  <height>27</height>
  <uuid>{b3c2f590-724b-404e-8eac-a32bc9bf0185}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>display</objectName>
  <x>15</x>
  <y>123</y>
  <width>261</width>
  <height>64</height>
  <uuid>{546df023-1aa4-43be-919e-c873c18a3ec7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Courier New</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>85</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>27</x>
  <y>8</y>
  <width>226</width>
  <height>38</height>
  <uuid>{f252e58c-f68b-4d35-a641-077bd7762802}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Line Edit Widget</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
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
 <x>797</x>
 <y>193</y>
 <width>295</width>
 <height>431</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {43690, 41377, 43433}
ioText {8, 155} {275, 242} display 0.000000 0.00100 "" left "Helvetica" 6 {22272, 22784, 19968} {49664, 51968, 50432} nobackground noborder 
ioText {15, 161} {262, 228} display 0.000000 0.00100 "" left "Arial" 12 {0, 21760, 32512} {49664, 50432, 54784} nobackground noborder The Line Edit Widget can also be used to receive strings from Csound. Put the keyboard focus on the line edit widget below and type on the ASCII keyboard.
ioText {188, 283} {25, 25} edit 0.000000 0.00100 "lineedit"  "Arial" 12 {0, 0, 0} {58880, 56576, 54528} falsenoborder -
ioKnob {50, 323} {50, 49} 0.500000 0.050000 0.010000 0.213636 level
ioText {43, 275} {146, 25} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Put keyboard focus here -->
ioText {52, 325} {49, 24} display 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Level
ioSlider {128, 335} {109, 19} 0.200000 2.000000 1.124771 dur
ioText {157, 345} {53, 22} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder duration
ioText {9, 4} {274, 148} display 0.000000 0.00100 "" left "Arial" 12 {0, 21760, 32512} {49664, 50432, 54784} nobackground noborder The Line Edit Widget can be used to pass strings from the widget panel to the csound program.
ioText {15, 92} {262, 27} edit 0.000000 0.00100 "instring"  "Arial" 12 {0, 0, 0} {58880, 56576, 54528} falsenoborder  
ioText {16, 93} {260, 49} display 0.000000 0.00100 "display" left "Courier New" 18 {21760, 65280, 65280} {0, 0, 0} nobackground noborder  
ioText {59, 24} {80, 25} label 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Line Edit Widget
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="425" y="326" width="614" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
