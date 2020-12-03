<CsoundSynthesizer>
<CsOptions>
-m0
</CsOptions>
<CsInstruments>
ksmps = 32
seed 0

opcode RndInt, i, ii
 iStart, iEnd xin
 iRnd random iStart, iEnd+.999
 iRndInt = int(iRnd)
 xout iRndInt
endop

opcode ArrShuffle, i[], i[]
	iInArr[] xin
	iLen = lenarray(iInArr)
	iOutArr[] init iLen
	iIndx = 0
	iEnd = iLen-1
 while iIndx < iLen do
  ;get one random element and put it in iOutArr
  iRndIndx RndInt 0, iEnd
  iOutArr[iIndx] = iInArr[iRndIndx]
  ;shift the elements after this one to the left
  while iRndIndx < iEnd do
   iInArr[iRndIndx] = iInArr[iRndIndx+1]
   iRndIndx += 1
  od
  ;reset end and increase counter
  iIndx += 1
  iEnd -= 1
  od
 xout iOutArr
endop

instr Test
 iValues[] fillarray 1, 2, 3, 4, 5, 6, 7
 indx = 0
 while indx < 5 do
  iOut[] ArrShuffle iValues
  printarray(iOut,"%d")
  indx += 1
 od
endin

</CsInstruments>
<CsScore>
i "Test" 0 0
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
