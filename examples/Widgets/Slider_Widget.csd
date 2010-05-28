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
 <label>Widgets</label>
 <objectName/>
 <x>608</x>
 <y>227</y>
 <width>400</width>
 <height>321</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>102</x>
  <y>4</y>
  <width>202</width>
  <height>41</height>
  <uuid>{c5f4063e-4a46-4f9d-96db-839bea9a983f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Slider Widget</label>
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
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>45</y>
  <width>377</width>
  <height>56</height>
  <uuid>{7650f5b0-e83a-46a4-ba7f-45a47f71997e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Sliders are used to send and receive data from the running Csound using channels. If a slider's width is greater than its height it becomes a horizontal slider. You can set a slider's range in it's properties.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>amp</objectName>
  <x>41</x>
  <y>109</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a99d91b7-f92c-4044-a927-70a2943b968e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.23500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>freq</objectName>
  <x>67</x>
  <y>109</y>
  <width>313</width>
  <height>23</height>
  <uuid>{dfc109a0-ff5a-40e4-9a56-bb67e10acb6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>689.45686901</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>140</x>
  <y>125</y>
  <width>198</width>
  <height>41</height>
  <uuid>{6b918bc4-f76f-460e-8f7b-5054495f2143}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frequency (from 100 to 1000 transmitting on channel 'freq'</label>
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
  <x>10</x>
  <y>214</y>
  <width>86</width>
  <height>86</height>
  <uuid>{baae2608-4500-4d99-99f3-941f5e2b5a84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amplitude (transmitting from 0 to 0.5 on channel 'amp'</label>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>100</x>
  <y>169</y>
  <width>281</width>
  <height>130</height>
  <uuid>{9d18e25d-d310-4e60-9109-541fdad0d7df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <objectName/>
 <x>608</x>
 <y>227</y>
 <width>400</width>
 <height>321</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {102, 4} {202, 41} display 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Slider Widget
ioText {7, 45} {377, 56} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Sliders are used to send and receive data from the running Csound using channels. If a slider's width is greater than its height it becomes a horizontal slider. You can set a slider's range in it's properties.
ioSlider {41, 109} {20, 100} 0.000000 0.500000 0.235000 amp
ioSlider {67, 109} {313, 23} 100.000000 1000.000000 689.456869 freq
ioText {140, 125} {198, 41} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Frequency (from 100 to 1000 transmitting on channel 'freq'
ioText {10, 214} {86, 86} display 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Amplitude (transmitting from 0 to 0.5 on channel 'amp'
ioGraph {100, 169} {281, 130} scope 2.000000 -1 
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="425" y="326" width="614" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
