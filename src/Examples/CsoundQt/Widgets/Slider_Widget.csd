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
i 1 0 1000
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>608</x>
 <y>211</y>
 <width>408</width>
 <height>357</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>230</r>
  <g>230</g>
  <b>230</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>90</x>
  <y>5</y>
  <width>202</width>
  <height>41</height>
  <uuid>{c5f4063e-4a46-4f9d-96db-839bea9a983f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Slider Widget</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>45</y>
  <width>373</width>
  <height>78</height>
  <uuid>{7650f5b0-e83a-46a4-ba7f-45a47f71997e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sliders are used to send and receive data from the running Csound using channels. If a slider's width is greater than its height it becomes a horizontal slider. You can set a slider's range in it's properties.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>amp</objectName>
  <x>40</x>
  <y>155</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a99d91b7-f92c-4044-a927-70a2943b968e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.21000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>freq</objectName>
  <x>65</x>
  <y>155</y>
  <width>313</width>
  <height>23</height>
  <uuid>{dfc109a0-ff5a-40e4-9a56-bb67e10acb6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>703.83386581</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>140</x>
  <y>175</y>
  <width>198</width>
  <height>41</height>
  <uuid>{6b918bc4-f76f-460e-8f7b-5054495f2143}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frequency (from 100 to 1000 transmitting on channel 'freq'</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>260</y>
  <width>86</width>
  <height>86</height>
  <uuid>{baae2608-4500-4d99-99f3-941f5e2b5a84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amplitude (transmitting from 0 to 0.5 on channel 'amp'</label>
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
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>100</x>
  <y>215</y>
  <width>281</width>
  <height>130</height>
  <uuid>{9d18e25d-d310-4e60-9109-541fdad0d7df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
