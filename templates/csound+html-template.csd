; Template for Csound-wasm html file that runs also in CsoundQt, Csound For Android and elsewhere
; (c) Tarmo Johannes 2018

<html>
  <head>
  </head>
  <body bgcolor="lightgreen">
   <h2>Csd+html template</h2><br>
   Press "Run" in CsoundQt (or other host) to start the csd. 
   <br><br>
   Frequency: 
   <input type="range" id="slider" min="100" max="1000" oninput='csound.setControlChannel("freq",parseFloat(value)); '></input><br>
    <button id="button" onclick='csound.readScore("i 1 0 3")' >Event</button>
   <br>
  </body>
</html>

<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
nchnls = 2
0dbfs = 1
ksmps = 32

chnset 400, "freq" 

instr 1 
  kfreq chnget "freq"
  printk2 kfreq
  aenv linen 1,0.1,p3,0.25
  out poscil(0.5,kfreq)*aenv
endin


</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>button0</objectName>
  <x>10</x>
  <y>19</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d5a1d1e3-eb6f-461c-90dc-95647307dc87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i1 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
