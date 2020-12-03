<CsoundSynthesizer>
<CsOptions>
-m0
</CsOptions>
<CsInstruments>
ksmps = 32

opcode FirstEl, k, k[]
 kArr[] xin
 kOut = kArr[0]
 xout kOut
endop

opcode FirstEl, i, i[]
 iArr[] xin
 iOut = iArr[0]
 xout iOut
endop

opcode FirstEl, S, S[]
 SArr[] xin
 SOut = SArr[0]
 xout SOut
endop

instr Test
 iTest[] fillarray 1, 2, 3
 kTest[] fillarray 4, 5, 6
 STest[] fillarray "x", "y", "z"
 prints "First element of i-array: %d\n", FirstEl(iTest)
 printks "First element of k-array: %d\n", 0, FirstEl(kTest)
 printf "First element of S-array: %s\n", 1, FirstEl(STest)
 turnoff
endin
</CsInstruments>
<CsScore>
i "Test" 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
