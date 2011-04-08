see http://www.flossmanuals.net/csound/ch035_e-reverberation

<CsoundSynthesizer>

<CsOptions>
-odac ;activates real time sound output
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr =  44100
ksmps = 32
nchnls = 2
0dbfs = 1

             zakinit   1, 1; initialize zak space (one a-rate and one k-rate variable. We will only be using the a-rate variable)

  instr 1 ;sound generating instrument (sparse noise bursts)
kEnv         loopseg   0.5,0, 0,1,0.003,1,0.0001,0,0.9969,0; amplitude envelope: a repeating pulse
aSig         pinkish   kEnv; pink noise. pulse envelope applied
             outs      aSig, aSig; send audio to outputs
iRvbSendAmt  =         0.4; reverb send amount (try range 0 - 1)
             zawm      aSig*iRvbSendAmt, 1; write to zak audio channel 1 with mixing
  endin

  instr 5; reverb - always on
aInSig       zar       1; read first zak audio channel
kFblvl       init      0.85; feedback level - i.e. reverb time
kFco         init      7000; cutoff frequency of a filter within the feedback loop
aRvbL,aRvbR  reverbsc  aInSig, aInSig, kFblvl, kFco; create reverberated version of input signal (note stereo input and output)
             outs      aRvbL, aRvbR; send audio to outputs
             zacl      0, 1; clear zak audio channels
  endin

</CsInstruments>

<CsScore>
i 1 0 10; noise pulses (input sound)
i 5 0 12; start reverb
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
