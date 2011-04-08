see http://www.flossmanuals.net/csound/ch032_b-panning-and-spatialization

<CsoundSynthesizer>

<CsOptions>
-odac ;activates real time sound output
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr = 44100
ksmps = 10
nchnls = 2
0dbfs = 1

giSine         ftgen       0, 0, 2^12, 10, 1
giLFOShape     ftgen       0, 0, 131072, 19, 0.5, 1, 180, 1    ;U-SHAPE PARABOLA

  instr 1
; create an audio signal (noise impulses)
krate          oscil       30,0.2,giLFOShape; rate of impulses
kEnv           loopseg     krate+3,0, 0,1, 0.1,0, 0.9,0; amplitude envelope: a repeating pulse
aSig           pinkish     kEnv; pink noise. pulse envelope applied

; apply binaural 3d processing
kAz            linseg      0, 8, 360; break point envelope defines azimuth (one complete circle)
kElev          linseg      0, 8,   0, 4, 90, 8, -40, 4, 0; break point envelope defines elevation (held horizontal for 8 seconds then up then down then back to horizontal
aLeft, aRight  hrtfmove2   aSig, kAz, kElev, "hrtf-44100-left.dat","hrtf-44100-right.dat"; apply hrtfmove2 opcode to audio source - create stereo ouput
               outs        aLeft, aRight; audio sent to outputs
endin

</CsInstruments>

<CsScore>
i 1 0 60; instr 1 plays a note for 60 seconds
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
