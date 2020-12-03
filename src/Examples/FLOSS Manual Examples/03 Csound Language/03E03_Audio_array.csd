<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr AudioArray
 aArr[]  init    2
 aArr[0] poscil  .2, 400
 aArr[1] poscil  .2, 500
 aEnv    transeg 1, p3, -3, 0
         out     aArr*aEnv
endin

</CsInstruments>
<CsScore>
i "AudioArray" 0 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
