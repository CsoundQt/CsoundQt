<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac
</CsOptions>
<CsInstruments>
sr = 44100
nchnls = 1
ksmps = 32
0dbfs = 1

instr 1
out poscil(linseg(0, p3/2, 1, p3/2, 0), expseg(400, p3/2, random(700, 1400), p3/2, 600))
endin

</CsInstruments>
<CsScore>
r 5
i 1 0 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
