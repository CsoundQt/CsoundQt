see http://www.flossmanuals.net/csound/ch031_a-envelopes

<CsoundSynthesizer>

<CsOptions>
-odac -+rtmidi=virtual -M0; activates real time sound output and virtual midi device
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine   ftgen    0, 0, 2^12, 10, 1; a sine wave

  instr 1
icps     cpsmidi
;                 attack-|sustain-|-release
aEnv     linsegr  0, 0.01,   1,      0.5,0; envelope that senses note releases
aSig     poscil   aEnv, icps, giSine; audio oscillator
         out      aSig; audio sent to output
  endin

</CsInstruments>

<CsScore>
f 0 240; extend csound performance for 4 minutes
e
</CsScore>

</CsoundSynthesizer>
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
