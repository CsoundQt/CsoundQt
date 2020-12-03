<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
nchnls = 1
ksmps = 32
0dbfs = 1

instr 1
kFade    linseg   0, p3/2, 0.2, p3/2, 0
kSlide   expseg   400, p3/2, 800, p3/2, 600
aTone    poscil   kFade, kSlide
         out      aTone
endin

</CsInstruments>
<CsScore>
i 1 0 5
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
