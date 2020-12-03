<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 1

giSine     ftgen      0, 0, 1024, 10, 1

instr 1
kPitch     expseg     500, p3, 1000
aSine      poscil     .2, kPitch, giSine
           out        aSine
endin
</CsInstruments>
<CsScore>
i 1 0 10
</CsScore>
</CsoundSynthesizer>
