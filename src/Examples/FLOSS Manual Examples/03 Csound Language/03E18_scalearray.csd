<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>
ksmps = 32

           seed       0

instr 1
;create an array with 10 elements
kArr[]     init       10
;fill in random numbers and print them out
           printks    "kArr in maximum range 0..100:\n", 0
kIndx      =          0
  until kIndx == 10 do
kNum       random     0, 100
kArr[kIndx] =         kNum
           printf     "kArr[%d] = %10f\n", kIndx+1, kIndx, kNum
kIndx      +=         1
  od
;scale numbers 0...1 and print them out again
           scalearray kArr, 0, 1
kIndx      =          0
           printks    "kArr in range 0..1\n", 0
  until kIndx == 10 do
           printf     "kArr[%d] = %10f\n", kIndx+1, kIndx, kArr[kIndx]
kIndx      +=         1
  od
           turnoff
endin
</CsInstruments>
<CsScore>
i1 0 0.1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
