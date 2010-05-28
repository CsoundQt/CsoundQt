<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	asig oscils 0.2, 440, 0
	kpan oscil 1, 1, 1
	outs asig*kpan, asig*(1-kpan)
endin


</CsInstruments>
<CsScore>
f 1 0 4096 -7 1 2048 1 0 0 2048 0

i 1 0 1000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>859</x>
 <y>253</y>
 <width>491</width>
 <height>658</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>144</x>
  <y>1</y>
  <width>191</width>
  <height>39</height>
  <uuid>{22e4de93-d80c-453b-8a76-a6ad3bb5c4b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Scope Widget</label>
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
  <x>10</x>
  <y>41</y>
  <width>465</width>
  <height>44</height>
  <uuid>{5a8df46b-c8e6-46ce-bb0d-80380ff2884a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The Scope widget is an oscilloscope which can show the output of Csound. The oscilloscope can show individual channels or a sum of all output channels. Clicking on a Scope widget freezes it.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>9</x>
  <y>88</y>
  <width>466</width>
  <height>98</height>
  <uuid>{14105eb1-daf6-406d-845b-f4f1895cb1f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>9</x>
  <y>188</y>
  <width>467</width>
  <height>99</height>
  <uuid>{09dd2a94-dcc8-49cc-b819-890da8bd1506}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>9</x>
  <y>291</y>
  <width>466</width>
  <height>97</height>
  <uuid>{41f59e5e-61e3-445d-833a-7b9624803ad9}</uuid>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>9</x>
  <y>437</y>
  <width>231</width>
  <height>90</height>
  <uuid>{b65d33f6-9d4a-4330-acdb-a097f4ca52b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>8.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>393</y>
  <width>465</width>
  <height>37</height>
  <uuid>{7c7b875f-7bff-4359-9a43-ebc3ca6b92ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The decimation property averages sample, allowing a larger time frame to be displayed. The default without decimation is one audio sample per screen pixel.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>248</x>
  <y>437</y>
  <width>226</width>
  <height>90</height>
  <uuid>{edce6d38-8f7b-435e-8ced-a81d92e1af20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>9</x>
  <y>535</y>
  <width>84</width>
  <height>84</height>
  <uuid>{cf5bf13a-2037-4bbc-a089-279ff65e160d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-1.00000000</value>
  <type>lissajou</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>101</x>
  <y>535</y>
  <width>84</width>
  <height>84</height>
  <uuid>{fa0440bd-3026-4686-8df8-6562dcbc37fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-1.00000000</value>
  <type>poincare</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>194</x>
  <y>535</y>
  <width>281</width>
  <height>82</height>
  <uuid>{8263c934-5d38-47ba-a842-06c9e6981ef6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The Scope widget can also show Lissajou and Poincare graphs. The decimation parameter in these cases determines the "zoom".</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
 <objectName/>
 <x>859</x>
 <y>253</y>
 <width>491</width>
 <height>658</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {145, 6} {191, 39} display 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Scope Widget
ioText {10, 41} {465, 44} display 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {48896, 52224, 59904} nobackground noborder The Scope widget is an oscilloscope which can show the output of Csound. The oscilloscope can show individual channels or a sum of all output channels. Clicking on a Scope widget freezes it.
ioGraph {9, 88} {466, 98} scope 2.000000 1 
ioGraph {9, 188} {467, 99} scope 2.000000 2 
ioGraph {9, 291} {466, 97} scope 2.000000 -1 
ioGraph {9, 437} {231, 90} scope 8.000000 -1 
ioText {10, 393} {466, 34} display 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {48896, 52224, 59904} nobackground noborder The decimation property averages sample, allowing a larger time frame to be displayed. The default without decimation is one audio sample per screen pixel.
ioGraph {248, 437} {226, 90} scope 1.000000 -1 
ioGraph {9, 535} {84, 84} lissajou 2.000000 -1 
ioGraph {101, 535} {84, 84} poincare 2.000000 -1 
ioText {193, 528} {281, 82} display 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {48896, 52224, 59904} nobackground noborder The Scope widget can also show Lissajou and Poincare graphs. The decimation parameter in these cases determines the "zoom".
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="425" y="326" width="614" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
