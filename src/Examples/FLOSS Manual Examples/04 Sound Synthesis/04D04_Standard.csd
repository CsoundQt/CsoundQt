<CsoundSynthesizer>
<CsOptions>
-odac  -m128
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Standard

//input
 iC = 400
 iR = p4 ;ratio
 iI = p5 ;index
 prints "Ratio = %.3f, Index = %.3f\n", iR, iI

 //transform
 iM = iC / iR
 iD = iI * iM

 //apply to standard model
 aModulator poscil iD, iM
 aCarrier poscil 0.3, iC + aModulator
 aOut linen aCarrier, .1, p3, 1
 out aOut, aOut

endin

instr PlayMess

 kC randomi 300, 500, 1, 2, 400
 kR randomi 1, 2, 2, 3
 kI randomi 1, 5, randomi:k(3,10,1,3), 3

 //transform
 kM = kC / kR
 kD = kI * kM

 //apply to standard model
 aModulator poscil kD, kM
 aCarrier poscil ampdb(port:k(kI*5-30,.1)), kC + aModulator
 aOut linen aCarrier, .1, p3, p3/10
 out aOut, aOut

endin

</CsInstruments>
<CsScore>
//changing the ratio at constant index=3
i "Standard" 0 3 1 3
i . + . 1.41 .
i . + . 1.75 .
i . + . 2.07 .
s
//changing the index at constant ratio=3.3
i "Standard" 0 3 3.3 0
i . + . . 1
i . + . . 5
i . + . . 10
s
//let some nonsense happen
i "PlayMess" 0 30
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
