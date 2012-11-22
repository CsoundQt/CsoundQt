/* Getting Started .. Realtime Interaction: Widgets-Buttontypes

This example concentrates on the different button-types. 

Buttons send momentary values (0 or 1) to a channel. There are some reserved Channel names in CsoundQt, which enable to control functionality of CsoundQt from the Widgets Panel. In this example we use Channel "_Play", to run Csound. Therefor button has to be in "value" mode! 
Read more about reserved channels in: (Examples-> Widgets->Reserved Channels)

The "Move Fader!" button is in "event" mode, so it sends a "scoreline-event", when pressed.

1. Open the Widgets-Panel. 
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 1
0dbfs = 1

instr 1 		; Move Fader
kMoveUp linseg 0, 3, 1, 1, 1, 0.5, 0
outvalue "movefader", kMoveUp
endin

</CsInstruments>
<CsScore>
e 3600
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 









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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>34</x>
  <y>3</y>
  <width>312</width>
  <height>32</height>
  <uuid>{e394b4c5-4b96-4375-8fff-e22d8b415d8c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2. Run Csound with the button below!</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>movefader</objectName>
  <x>37</x>
  <y>78</y>
  <width>25</width>
  <height>136</height>
  <uuid>{954093bc-bde7-4825-b1c7-9fe9a9b9b774}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>movefader</objectName>
  <x>33</x>
  <y>235</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c9c2fb70-e2e0-44bb-a5a7-bc0779c99317}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.0000</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>32</x>
  <y>215</y>
  <width>112</width>
  <height>21</height>
  <uuid>{ed434eea-f1c1-45b5-a365-6fb7ecd397c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Display Values:</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>35</x>
  <y>37</y>
  <width>100</width>
  <height>30</height>
  <uuid>{07e6521d-fa43-4400-b438-b27145bfcf06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Run Csound</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>135</x>
  <y>37</y>
  <width>201</width>
  <height>184</height>
  <uuid>{54d6d435-1afb-48c6-809f-8f2063919f77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Look into the buttons properties: "Channel name: _Play"</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>33</x>
  <y>282</y>
  <width>100</width>
  <height>30</height>
  <uuid>{5b60623f-edba-48f3-b0bd-1d309d4cb022}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Move Fader!</text>
  <image>/</image>
  <eventLine>i1 0 5</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>138</x>
  <y>282</y>
  <width>198</width>
  <height>113</height>
  <uuid>{d4071760-571f-4e86-8f1f-d565ec6a674f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This button is in event mode. When pressed, it sends a score line. Here it starts instrument 1."i1 0 5"</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>33</x>
  <y>410</y>
  <width>100</width>
  <height>30</height>
  <uuid>{c5a28bd5-80cf-4ee9-9150-50a5ac207c6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop Csound</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>144</x>
  <y>409</y>
  <width>182</width>
  <height>31</height>
  <uuid>{0927aac1-4f96-4c85-a917-6164e7caad6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Reserved Channel: _Stop</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>135</x>
  <y>117</y>
  <width>203</width>
  <height>117</height>
  <uuid>{8cc654c8-64f8-4d08-a799-ca91dedc29ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>_Play is a reserved channel to control CsoundQt functionality. (Run Csound) The button has to be in value mode, to send this message. </label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="261" y="207" width="513" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
