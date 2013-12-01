<CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials -o dac
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

; a cosine wave
gicos ftgen 0, 0, 2^10, 11, 1

 instr 1
knh  =     20
klh  =     1
kmul line  0, p3, 2
asig gbuzz 1, 100, knh, klh, kmul, gicos
fout "gbuzz3.wav",4,asig
 endin

</CsInstruments>

<CsScore>
i 1 0 8
e
</CsScore>

</CsoundSynthesizer>
