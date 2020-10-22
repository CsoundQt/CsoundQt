<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
nchnls = 2
ksmps = 32
0dbfs = 1

opcode FourModes, a, akk[]
 aIn, kBasFreq, kFQ[] xin
 aOut1 = mode:a(aIn,kBasFreq*kFQ[0],kFQ[1])
 aOut2 = mode:a(aIn,kBasFreq*kFQ[2],kFQ[3])
 aOut3 = mode:a(aIn,kBasFreq*kFQ[4],kFQ[5])
 aOut4 = mode:a(aIn,kBasFreq*kFQ[6],kFQ[7])
 xout (aOut1+aOut2+aOut3+aOut4) / 4
endop

instr 1
 kArr[] = fillarray(1, 2000, 2.8, 2000, 5.2, 2000, 8.2, 2000)
 aImp   = mpulse:a(.3, 1)
 aOut   = FourModes(aImp, randomh:k(200,195,1), kArr)
 out(aOut, aOut)
endin

</CsInstruments>
<CsScore>
i 1 0 10
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz, based on an example of iain mccurdy