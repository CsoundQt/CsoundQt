opcode trirnd, i, ii
iMin, iMax xin
 ;set a counter and a maximum count
iCount     =          0
iMaxCount  =          2
 ;set the accumulator to zero as initial value
iAccum     =          0
 ;perform loop and accumulate
 until iCount == iMaxCount do
iUniRnd    random     iMin, iMax
iAccum     +=         iUniRnd
iCount     +=         1
 enduntil
 ;get the mean and output
iRnd       =          iAccum / 2
           xout       iRnd
endop