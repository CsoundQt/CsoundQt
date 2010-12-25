see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>
<CsOptions>
-Ma -odac ;activates all midi devices and real time sound output
</CsOptions>
<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

gisine ftgen 0,0,2^12,10,1

  instr 1; 1 impulse (midi channel 1)
prints "instrument/midi channel: %d%n",p1; print instrument number to terminal
reset:
     timout 0, 1, impulse; jump to pulse generation section for 1 second
     reinit reset; reninitialize pass from label 'reset'
impulse:
aenv expon     1, 0.3, 0.0001; a short percussive amplitude envelope
aSig poscil    aenv, 500, gisine
     out       aSig
     rireturn
  endin

  instr 2; 2 impulses (midi channel 2)
prints "instrument/midi channel: %d%n",p1; print instrument number to terminal
reset:
     timout 0, 1, impulse; jump to pulse generation section for 1 second
     reinit reset; reninitialize pass from label 'reset'
impulse:
aenv expon     1, 0.3, 0.0001; a short percussive amplitude envelope
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15
     out       aSig+a2
     rireturn
  endin

  instr 3; 3 impulses (midi channel 3)
prints "instrument/midi channel: %d%n",p1; print instrument number to terminal
reset:
     timout 0, 1, impulse; jump to pulse generation section for 1 second
     reinit reset; reninitialize pass from label 'reset'
impulse:
aenv expon     1, 0.3, 0.0001; a short percussive amplitude envelope
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15
a3   delay     a2, 0.15
     out       aSig+a2+a3
     rireturn
  endin

</CsInstruments>
<CsScore>
f 0 300
e
</CsScore>
<CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>630</x>
 <y>260</y>
 <width>380</width>
 <height>205</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>230</r>
  <g>140</g>
  <b>36</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {59110, 35980, 9252}
</MacGUI>
