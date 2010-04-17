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
 <bgcolor mode="background" >
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>144</x>
  <y>6</y>
  <width>191</width>
  <height>39</height>
  <uuid>{22e4de93-d80c-453b-8a76-a6ad3bb5c4b8}</uuid>
  <label>Scope Widget</label>
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
  <x>10</x>
  <y>41</y>
  <width>465</width>
  <height>44</height>
  <uuid>{5a8df46b-c8e6-46ce-bb0d-80380ff2884a}</uuid>
  <label>The Scope widget is an oscilloscope which can show the output of Csound. The oscilloscope can show individual channels or a sum of all output channels. Clicking on a Scope widget freezes it.</label>
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
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>9</x>
  <y>88</y>
  <width>466</width>
  <height>98</height>
  <uuid>{14105eb1-daf6-406d-845b-f4f1895cb1f3}</uuid>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>9</x>
  <y>188</y>
  <width>467</width>
  <height>99</height>
  <uuid>{09dd2a94-dcc8-49cc-b819-890da8bd1506}</uuid>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>9</x>
  <y>291</y>
  <width>466</width>
  <height>97</height>
  <uuid>{41f59e5e-61e3-445d-833a-7b9624803ad9}</uuid>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>8</x>
  <y>432</y>
  <width>231</width>
  <height>92</height>
  <uuid>{b65d33f6-9d4a-4330-acdb-a097f4ca52b2}</uuid>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>8.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>10</x>
  <y>393</y>
  <width>466</width>
  <height>34</height>
  <uuid>{7c7b875f-7bff-4359-9a43-ebc3ca6b92ac}</uuid>
  <label>The decimation property averages sample, allowing a larger time frame to be displayed. The default without decimation is one audio sample per screen pixel.</label>
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
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>247</x>
  <y>430</y>
  <width>226</width>
  <height>91</height>
  <uuid>{edce6d38-8f7b-435e-8ced-a81d92e1af20}</uuid>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>8</x>
  <y>528</y>
  <width>84</width>
  <height>84</height>
  <uuid>{cf5bf13a-2037-4bbc-a089-279ff65e160d}</uuid>
  <value>-1.00000000</value>
  <type>lissajou</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope" >
  <objectName/>
  <x>100</x>
  <y>528</y>
  <width>84</width>
  <height>84</height>
  <uuid>{fa0440bd-3026-4686-8df8-6562dcbc37fe}</uuid>
  <value>-1.00000000</value>
  <type>poincare</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <zoomy>1.00000000</zoomy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>193</x>
  <y>528</y>
  <width>281</width>
  <height>82</height>
  <uuid>{8263c934-5d38-47ba-a842-06c9e6981ef6}</uuid>
  <label>The Scope widget can also show Lissajou and Poincare graphs. The decimation parameter in these cases determines the "zoom".</label>
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
 <objectName/>
 <x>706</x>
 <y>55</y>
 <width>491</width>
 <height>658</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>