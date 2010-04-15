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
 <bgcolor mode="background" >
  <r>170</r>
  <g>161</g>
  <b>169</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>8</x>
  <y>155</y>
  <width>275</width>
  <height>242</height>
  <uuid>{085c635a-66f9-4532-8df3-1dfcf28600cb}</uuid>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>87</r>
   <g>89</g>
   <b>78</b>
  </color>
  <bgcolor mode="background" >
   <r>194</r>
   <g>203</g>
   <b>197</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>15</x>
  <y>161</y>
  <width>262</width>
  <height>228</height>
  <uuid>{b37e9f05-df2d-4a31-ab50-f93173624086}</uuid>
  <label>The Line Edit Widget can also be used to receive strings from Csound. Put the keyboard focus on the line edit widget below and type on the ASCII keyboard.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>85</g>
   <b>127</b>
  </color>
  <bgcolor mode="background" >
   <r>194</r>
   <g>197</g>
   <b>214</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>lineedit</objectName>
  <x>187</x>
  <y>275</y>
  <width>25</width>
  <height>25</height>
  <uuid>{eca8b99c-5d0e-4bd0-adb5-199c226b5305}</uuid>
  <label>-</label>
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
 <bsbObject version="2" type="BSBKnob" >
  <objectName>level</objectName>
  <x>48</x>
  <y>315</y>
  <width>50</width>
  <height>49</height>
  <uuid>{d6a1bbac-0b3f-49ba-b281-6a31c464d7b4}</uuid>
  <minimum>0.05000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.21363636</value>
  <randomizable/>
  <resolution>0.01000000</resolution>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>43</x>
  <y>275</y>
  <width>146</width>
  <height>25</height>
  <uuid>{f9f54980-38ff-4721-97d6-8afa7a524711}</uuid>
  <label>Put keyboard focus here --></label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>53</x>
  <y>359</y>
  <width>37</width>
  <height>24</height>
  <uuid>{2cd5cd9d-6ca7-4350-b274-ef793f5dedce}</uuid>
  <label>Level</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>dur</objectName>
  <x>127</x>
  <y>327</y>
  <width>109</width>
  <height>19</height>
  <uuid>{7b7e5745-622f-411c-97d8-b4136ee2b401}</uuid>
  <minimum>0.20000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.57981651</value>
  <resolution>-1.00000000</resolution>
  <randomizable>true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>156</x>
  <y>347</y>
  <width>53</width>
  <height>22</height>
  <uuid>{0f74a0f5-f1a9-4ef5-962c-e1753a6e6cc5}</uuid>
  <label>duration</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>9</x>
  <y>4</y>
  <width>274</width>
  <height>148</height>
  <uuid>{187b22e7-31c4-4f4c-bb47-168034be6765}</uuid>
  <label>The Line Edit Widget can be used to pass strings from the widget panel to the csound program.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>85</g>
   <b>127</b>
  </color>
  <bgcolor mode="background" >
   <r>194</r>
   <g>197</g>
   <b>214</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>instring</objectName>
  <x>16</x>
  <y>62</y>
  <width>262</width>
  <height>27</height>
  <uuid>{b3c2f590-724b-404e-8eac-a32bc9bf0185}</uuid>
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
  <objectName>display</objectName>
  <x>16</x>
  <y>93</y>
  <width>260</width>
  <height>49</height>
  <uuid>{546df023-1aa4-43be-919e-c873c18a3ec7}</uuid>
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
  <bgcolor mode="background" >
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <objectName/>
 <x>797</x>
 <y>225</y>
 <width>300</width>
 <height>439</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 








</EventPanel>