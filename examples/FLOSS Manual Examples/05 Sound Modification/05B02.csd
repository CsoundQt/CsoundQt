see http://booki.flossmanuals.net/csound/

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

  instr 1
imethod        =         p4; read panning method variable from score (p4)
;generate a source sound====================
aSig           pinkish   0.5; pink noise
aSig           reson     aSig, 500, 30, 1; bandpass filtered
aPan           lfo       0.5, 1, 1; panning controlled by an lfo
aPan           =         aPan + 0.5; offset shifted +0.5
;===========================================

aSigL, aSigR   pan2      aSig, aPan, imethod; create stereo panned output

               outs      aSigL, aSigR; audio sent to outputs
  endin

</CsInstruments>

<CsScore>
;3 notes one after the other to demonstrate 3 methods used by pan2
;p1 p2  p3   p4
i 1  0  4.5   0; equal power (harmonic)
i 1  5  4.5   1; square root method
i 1 10  4.5   2; linear
e
</CsScore>

</CsoundSynthesizer> <bsbPanel>
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
