<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr=44100
ksmps=32
nchnls=2
0dbfs=1

instr 1
ipos       ftgen      1, 0, 128, 10, 1 ; Initial Shape, sine
imass      ftgen      2, 0, 128, -7, 1, 128, 1 ;Masses(adj.), constant value 1
istiff     ftgen      3, 0, 128, -7, 0, 64, 100, 64, 0 ;Stiffness triangle
idamp      ftgen      4, 0, 128, -7, 1, 128, 1; ;Damping; constant value 1
ivel       ftgen      5, 0, 128, -7, 0, 128, 0 ;Initial Velocity 0
iamp       =          0.2
a1         scantable  iamp, 60, ipos, imass, istiff, idamp, ivel
           outs       a1, a1
endin
</CsInstruments>
<CsScore>
i 1 0 14
f 1 1 128 10 1 1 1 1 1 1 1 1 1 1 1
f 1 2 128 10 1 1 0 0 0 0 0 0 0 1 1
f 1 3 128 10 1 1 1 1 1
f 1 4 128 10 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
f 1 5 128 10 1 1
f 1 6 128 13 1 1 0 0 0 -.1 0 .3 0 -.5 0 .7 0 -.9 0 1 0 -1 0
f 1 7 128 21 6 5.745
</CsScore>
</CsoundSynthesizer>
;example by Christopher Saunders
