/* Getting Started .. Realtime Interaction: Widgets 2

Make the Widgets-panel visible, by clicking the Widgets symbol 
in the toolbar or pressing Cmd+1 for Mac or Ctrl+1 for Windows and Linux.

*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr     = 44100
ksmps  = 64
nchnls = 2
0dbfs  = 1

instr 1
  kfreq = chnget("freq")
  asig  = oscil(0.1, kfreq, 1)
  out(asig, asig)
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1 		;Sine wave for table 1
i 1 0 300 			; Play for 300 seconds
e
</CsScore>
</CsoundSynthesizer>
; written by Andres Cabrera




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>7</r>
  <g>95</g>
  <b>162</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>14</x>
  <y>12</y>
  <width>209</width>
  <height>38</height>
  <uuid>{19774345-2e9f-4969-bf1e-dcb12478dea6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Using Widgets</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>50</y>
  <width>365</width>
  <height>93</height>
  <uuid>{61b4de03-c3bd-49a6-9e54-2f027c7d8b0d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>You can receive Widget values in the Csound orchestra using "channels". You use channel names to identify them, and you must set the channel name in the Widget and in the orchestra's invalue opcode.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>200</y>
  <width>380</width>
  <height>220</height>
  <uuid>{ba0489e8-4f09-443d-bd82-4a57532c1e31}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Enter the slider's properties by right-clicking (or control-clicking) and selecting "Properties". This will open the Widget Properties dialog, which will allow you to set the Widget's channel name. Set the channel name to "freq" (without the quotes).
Now run Csound, and notice how the widget is controlling the frequency of the oscillator!</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>freq</objectName>
  <x>10</x>
  <y>160</y>
  <width>366</width>
  <height>21</height>
  <uuid>{2d44d97e-66cb-491f-bb9e-d9e6f20e16f5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>300.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>581.14754098</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>425</y>
  <width>380</width>
  <height>51</height>
  <uuid>{56667bda-b29d-49dc-a2d0-560ec1aa5f6c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>You can change a slider's range in its properties dialog, if you want a broader or smaller range.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
