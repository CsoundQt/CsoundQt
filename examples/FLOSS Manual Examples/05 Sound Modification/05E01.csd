see http://booki.flossmanuals.net/csound/

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

gaRvbSend    init      0; global audio variable initialized to zero

  instr 1 ;sound generating instrument (sparse noise bursts)
kEnv         loopseg   0.5,0, 0,1,0.003,1,0.0001,0,0.9969,0; amplitude envelope: a repeating pulse
aSig         pinkish   kEnv; pink noise. pulse envelope applied
             outs      aSig, aSig; send audio to outputs
iRvbSendAmt  =         0.4; reverb send amount (try range 0 - 1)
gaRvbSend    =         gaRvbSend + (aSig * iRvbSendAmt); add a proportion of the audio from this instrument to the global reverb send variable
  endin

  instr 5; reverb - always on
kroomsize    init      0.85; room size (range zero to 1)
kHFDamp      init      0.5; high frequency damping (range zero to 1)
aRvbL,aRvbR  freeverb  gaRvbSend, gaRvbSend,kroomsize,kHFDamp; create reverberated version of input signal (note stereo input and output)
             outs      aRvbL, aRvbR; send audio to outputs
             clear     gaRvbSend
  endin

</CsInstruments>

<CsScore>
i 1 0 300; noise pulses (input sound)
i 5 0 300; start reverb
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
