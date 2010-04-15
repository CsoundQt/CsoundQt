<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kamp invalue "amp"
kfreq invalue "freq"
aout oscil kamp/ 10, kfreq, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <bgcolor mode="background" >
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>35</x>
  <y>8</y>
  <width>218</width>
  <height>40</height>
  <uuid>{0df0bb40-d88d-4022-a006-19902725d853}</uuid>
  <label>SpinBox Widget</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>7</x>
  <y>51</y>
  <width>269</width>
  <height>53</height>
  <uuid>{fb0b903a-20d0-4307-b80b-69ddd86d4e33}</uuid>
  <label>SpinBox widgets allow insertion of numbers with the keyboard and the mouse. They work in a similar way to other text or value widgets.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>freq</objectName>
  <x>138</x>
  <y>114</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0cc03e61-cc21-4839-983f-4de92e55cd2d}</uuid>
  <type>editnum</type>
  <value>440</value>
  <resolution>10.00000000</resolution>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>6</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+14</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>amp</objectName>
  <x>138</x>
  <y>148</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ee8084d6-7831-4975-8cac-acd49502e1d7}</uuid>
  <type>editnum</type>
  <value>0.3</value>
  <resolution>0.10000000</resolution>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>6</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+14</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <randomizable>false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>56</x>
  <y>114</y>
  <width>80</width>
  <height>25</height>
  <uuid>{96332145-309f-415d-aa55-16c7240bc9b2}</uuid>
  <label>Freq</label>
  <alignment>right</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>56</x>
  <y>147</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8cadb868-6f73-4336-9628-1bb720666234}</uuid>
  <label>Amp</label>
  <alignment>right</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <objectName/>
 <x>635</x>
 <y>265</y>
 <width>303</width>
 <height>219</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>