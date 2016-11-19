; Minimal example about using html section in CSD
; by Tarmo Johannes trmjhnns@gmail.com 2016

<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<html>
  <head>
  </head>
  <body bgcolor="lightblue">
  <script>
  function onGetControlChannelCallback(value) {
    document.getElementById('testChannel').innerHTML = value;
   } // to test csound.getControlChannel with QtWebEngine 
  </script>
   <h2>Minimal Csound-Html5 example</h2><br>
   <br>
   Frequency: 
   <input type="range" id="slider" oninput='csound.setControlChannel("testChannel",this.value/100.0); '></input><br>
    <button id="button" onclick='csound.readScore("i 1 0 3")' >Event</button>
   <br><br>
   Get channel from csound with callback (QtWebchannel): <label id="getchannel"></label> <button onclick='csound.getControlChannel("testChannel", onGetControlChannelCallback)' >Get</button><br>
        Value from channel "testChannel":  <label id="testChannel"></label><br>
   <br>
    Get as return value (QtWebkit) <button onclick='alert("TestChannel: "+csound.getControlChannel("testChannel"))'>Get as retrun value</button>

   <br>
  </body>
</html>
<CsInstruments>

sr = 44100
nchnls = 2
0dbfs = 1
ksmps = 32

chnset 0.5, "testChannel" ; to test chnget in the host

instr 1 
  kfreq= 200+chnget:k("testChannel")*500	
  printk2 kfreq
  aenv linen 1,0.1,p3,0.25
  out poscil(0.5,kfreq)*aenv
endin

; schedule 1,0,0.1, 1

</CsInstruments>
<CsScore>
i 1 0 0.5 ; to hear if Csound is loaded
f 0 3600
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
