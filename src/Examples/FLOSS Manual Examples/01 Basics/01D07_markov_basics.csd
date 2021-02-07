<CsoundSynthesizer>
<CsOptions>
-ndm0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 1
seed 0

instr 1
iLine[]    array      .2, .5, .3
iVal       random     0, 1
iAccum     =          iLine[0]
iIndex     =          0
 until iAccum >= iVal do
iIndex     +=         1
iAccum     +=         iLine[iIndex]
 enduntil
printf_i "Random number = %.3f, next element = %c!\n", 1, iVal, iIndex+97
endin
</CsInstruments>
<CsScore>
r 10
i 1 0 0
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
