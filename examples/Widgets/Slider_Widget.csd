<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	kfreq invalue "freq"
	kamp invalue "amp"
	asig oscil kamp, kfreq, 1
	outs asig, asig
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1 ;Sine wave
i 1 0 1000
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
  <x>102</x>
  <y>4</y>
  <width>202</width>
  <height>41</height>
  <uuid>{c5f4063e-4a46-4f9d-96db-839bea9a983f}</uuid>
  <label>Slider Widget</label>
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
  <y>45</y>
  <width>377</width>
  <height>56</height>
  <uuid>{7650f5b0-e83a-46a4-ba7f-45a47f71997e}</uuid>
  <label>Sliders are used to send and receive data from the running Csound using channels. If a slider's width is greater than its height it becomes a horizontal slider. You can set a slider's range in it's properties.</label>
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
 <bsbObject version="2" type="BSBVSlider" >
  <objectName>amp</objectName>
  <x>41</x>
  <y>109</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a99d91b7-f92c-4044-a927-70a2943b968e}</uuid>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.22500000</value>
  <resolution>-1.00000000</resolution>
  <randomizable>true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>freq</objectName>
  <x>67</x>
  <y>109</y>
  <width>313</width>
  <height>23</height>
  <uuid>{dfc109a0-ff5a-40e4-9a56-bb67e10acb6a}</uuid>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>269.64856230</value>
  <resolution>-1.00000000</resolution>
  <randomizable>true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>140</x>
  <y>125</y>
  <width>163</width>
  <height>43</height>
  <uuid>{6b918bc4-f76f-460e-8f7b-5054495f2143}</uuid>
  <label>Frequency (from 100 to 1000 transmitting on channel 'freq'</label>
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
  <x>10</x>
  <y>214</y>
  <width>86</width>
  <height>84</height>
  <uuid>{baae2608-4500-4d99-99f3-941f5e2b5a84}</uuid>
  <label>Amplitude (transmitting from 0 to 0.5 on channel 'amp'</label>
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
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>139</x>
  <y>171</y>
  <width>241</width>
  <height>110</height>
  <uuid>{9d18e25d-d310-4e60-9109-541fdad0d7df}</uuid>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <objectName/>
 <x>608</x>
 <y>275</y>
 <width>429</width>
 <height>344</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>