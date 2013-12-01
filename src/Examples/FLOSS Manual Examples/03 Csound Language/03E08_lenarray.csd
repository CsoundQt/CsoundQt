<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>

instr 1 ;simple i-rate example
iArr[]   array    1, 3, 5, 7, 9
iLen     lenarray iArr
         prints   "Length of iArr = %d\n", iLen
endin

instr 2 ;simple k-rate example
kArr[]   array    2, 4, 6, 8
kLen     lenarray kArr
         printks  "Length of kArr = %d\n", 0, kLen
         turnoff
endin

instr 3 ;i-rate with functional syntax
iArr[]   genarray 1, 9, 2
iIndx    =        0
  until iIndx == lenarray(iArr) do
         prints   "iArr[%d] = %d\n", iIndx, iArr[iIndx]
iIndx    +=       1
  od
endin

instr 4 ;k-rate with functional syntax
kArr[]   genarray_i -2, -8, -2
kIndx    =        0
  until kIndx == lenarray(kArr) do
         printf   "kArr[%d] = %d\n", kIndx+1, kIndx, kArr[kIndx]
kIndx    +=       1
  od
         turnoff
endin

</CsInstruments>
<CsScore>
i 1 0 0
i 2 0 .1
i 3 0 0
i 4 0 .1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
