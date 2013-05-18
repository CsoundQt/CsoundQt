<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
nchnls = 2
sr=44100
ksmps = 32
0dbfs = 1
gipos   ftgen 1, 0, 128, 10, 1                  ;Initial Shape, sine wave range -1 to 1
gimass  ftgen 2, 0, 128, -7, 1, 128, 1          ;Masses(adj.), constant value 1
gistiff ftgen 3, 0, 128, -7, 50, 64, 100, 64, 0 ;Stiffness; unipolar triangle range 0 to 100
gidamp  ftgen 4, 0, 128, -7, 1, 128, 1          ;Damping; constant value 1
givel   ftgen 5, 0, 128, -7, 0, 128, 0          ;Initial Velocity; constant value 1
instr 1
iamp = .7
kfrq = 440
a1 scantable iamp, kfrq, gipos, gimass, gistiff, gidamp, givel
a1 dcblock2 a1
outs a1, a1
endin
</CsInstruments>
<CsScore>
i 1 0 10
e
</CsScore>
</CsoundSynthesizer>
;Example by Christopher Saunders</code>