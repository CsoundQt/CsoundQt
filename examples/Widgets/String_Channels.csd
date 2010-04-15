<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1 ; Schedule triggering of the instruments
	event_i "i", 2, 0, 1
	event_i "i", 3, 2, 1
	event_i "i", 4, 4, 1
endin

instr 2
	outvalue "text", "hello"
	turnoff
endin

instr 3
	outvalue "text", "world!"
	turnoff
endin

instr 4
	outvalue "text", ""
	turnoff
endin

</CsInstruments>
<CsScore>
f 0 3600
i 1 0 1

</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <bgcolor mode="background" >
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>text</objectName>
  <x>38</x>
  <y>24</y>
  <width>120</width>
  <height>60</height>
  <uuid>{a22f0ffb-eb18-498f-bcf6-5f224cf453f8}</uuid>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>221</r>
   <g>218</g>
   <b>185</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>button1</objectName>
  <x>45</x>
  <y>94</y>
  <width>100</width>
  <height>40</height>
  <uuid>{d43733ec-7666-41ef-9791-c8a4243a970f}</uuid>
  <type>event</type>
  <value>0.00000000</value>
  <stringvalue/>
  <text>Do it again!</text>
  <image>/</image>
  <eventLine>i1 0 1</eventLine>
 </bsbObject>
 <objectName/>
 <x>813</x>
 <y>301</y>
 <width>202</width>
 <height>199</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>