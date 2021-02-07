<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Simple
 aSig diskin "fox.wav"
 fSig pvsanal aSig, 1024, 256, 1024, 1
 fTrace pvstrace fSig, p4
 aTrace pvsynth fTrace
 out aTrace, aTrace
endin

</CsInstruments>
<CsScore>
i "Simple" 0 3 1
i . + . 2
i . + . 4
i . + . 8
i . + . 16
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
