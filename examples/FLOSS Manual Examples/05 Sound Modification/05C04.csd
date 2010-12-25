see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>

<CsOptions>
-odac ;activates real time sound output
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

  instr 1
; generate an input audio signal (noise impulses)
kEnv         loopseg   1,0, 0,1,0.005,1,0.0001,0,0.9949,0; repeating amplitude envelope
aSig         pinkish   kEnv*0.6; pink noise signal - repeating amplitude envelope applied

; apply comb filter to input signal
krvt    linseg  0.1, 5, 2; reverb time envelope for comb filter
alpt    expseg  0.005, 5, 0.005, 6, 0.0005, 10, 0.1, 1, 0.1; loop time envelope for comb filter - using an a-rate variable here will produce better results
aRes    vcomb   aSig, krvt, alpt, 0.1; comb filter
        out     aRes; comb filtered audio sent to output
  endin

</CsInstruments>

<CsScore>
i 1 0 25
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
