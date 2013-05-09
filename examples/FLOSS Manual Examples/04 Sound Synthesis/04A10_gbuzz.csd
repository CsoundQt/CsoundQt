<CsoundSynthesizer>

<CsOptions>
-o dac
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

; a cosine wave
gicos ftgen 0, 0, 2^10, 11, 1

 instr 1
knh  line  1, p3, 20  ; number of harmonics
klh  =     1          ; lowest harmonic
kmul =     1          ; amplitude coefficient multiplier
asig gbuzz 1, 100, knh, klh, kmul, gicos
     outs  asig, asig
 endin

</CsInstruments>

<CsScore>
i 1 0 8
e
</CsScore>

</CsoundSynthesizer>
