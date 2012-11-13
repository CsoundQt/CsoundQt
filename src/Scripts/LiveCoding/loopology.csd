<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
icps = 440 * 2^((p4 -69)/12)
iamp = p5/600

print icps

iplk = 0.1
kpick = 0.75
krefl = 0.15

xtratim 1

aenv linseg 1, (p3 + 1) - 0.1, 1, 0.1, 0

aout wgpluck2 iplk, iamp, icps, kpick, krefl
outs aout*aenv,aout*aenv
endin

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>22</y>
 <width>400</width>
 <height>140</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
