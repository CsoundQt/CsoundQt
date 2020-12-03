<CsoundSynthesizer>
<CsOptions>
-nm0
</CsOptions>
<CsInstruments>
ksmps = 32
seed 0

opcode ArrPermRnd, i[], i[]
 iInArr[]     xin
 iLen         =        lenarray(iInArr)
 ;create output array and set index
 iOutArr[]    init     iLen
 iWriteIndx   =        0
 iReadLen     =        iLen
 ;for all elements:
 while iWriteIndx < iLen do
  ;get one random element and put it in iOutArr
  iRndIndx    =        int(random:i(0, iReadLen-.0001))
  iOutArr[iWriteIndx] = iInArr[iRndIndx]
  ;shift the elements after this one to the left
  while iRndIndx < iReadLen-1 do
   iInArr[iRndIndx] =  iInArr[iRndIndx+1]
   iRndIndx   +=       1
  od
  ;decrease length to read in and increase write index
  iReadLen    -=       1
  iWriteIndx  +=       1
  od
              xout     iOutArr
  endop

;create i-array as 1, 2, 3, ... 12
giArr[] genarray 1, 12

;permutation of giArr ...
instr Permut
 iPermut[] ArrPermRnd giArr
 printarray iPermut, "%d"
endin

;... which has not been touched by these operations
instr Print
 printarray giArr, "%d"
endin

</CsInstruments>
<CsScore>
i "Permut" 0  .01
i "Permut" +  .
i "Permut" +  .
i "Permut" +  .
i "Permut" +  .
i "Print" .05 .01
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
