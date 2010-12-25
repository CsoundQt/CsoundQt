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

giSine   ftgen   0, 0, 2^12, 10, 1; a sine wave
giLFOShape  ftgen   0, 0, 2^12, 19, 0.5, 1, 180, 1; u-shaped parabola

  instr 1
aSig    pinkish  0.1; pink noise

aMod    poscil   0.005, 0.05, giLFOShape    ;oscillator that makes use of the positive domain only u-shape parabola with function table number gilfoshape

iOffset =        ksmps/sr; minimum delay time
iFdback =        0.9; amount of signal that will be fed back into the input
; create a delay buffer
aBufOut delayr   0.5; read audio from end of 0.5 buffer
aTap    deltap3  aMod + iOffset; tap audio from within delay buffer with a modulating delay time
        delayw   aSig + (aTap*iFdback); write audio into the delay buffer

; send audio to ther output (mix the input signal with the delayed signal)
        out      aSig + aTap
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
