<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 2
seed 1

opcode Resonator, a, akk
 aSig, kFreq, kQ xin
 kRatio[] fillarray 1, 2.89, 4.95, 6.99, 8.01, 9.02
 a1 = mode:a(aSig, kFreq*kRatio[0], kQ)
 a2 = mode:a(aSig, kFreq*kRatio[1], kQ)
 a3 = mode:a(aSig, kFreq*kRatio[2], kQ)
 a4 = mode:a(aSig, kFreq*kRatio[3], kQ)
 a5 = mode:a(aSig, kFreq*kRatio[4], kQ)
 a6 = mode:a(aSig, kFreq*kRatio[5], kQ)
 aSum sum a1, a2, a3, a4, a5, a6
 aOut = balance:a(aSum, aSig)
 xout aOut
endop

instr Equal
 kTrig metro 80/60
 schedkwhen kTrig, 0, 0, "Perc", 0, 1, .4, 1
 schedkwhen kTrig, 0, 0, "Perc", 0, 1, .4, 2
endin

instr Beat
 kRoutArr[] fillarray 1, 2, 2
 kIndex init 0
 if metro:k(80/60) == 1 then
  event "i", "Perc", 0, 1, .6, kRoutArr[kIndex]
  kIndex = (kIndex+1) % 3
 endif
endin

instr Dialog
 if metro:k(80/60) == 1 then
  event "i", "Perc", 0, 1, .6, int(random:k(1,2.999))
 endif
endin

instr Perc
 iAmp = p4
 iChannel = p5
 aBeat pluck iAmp, 100, 100, 0, 3, .5
 aOut Resonator aBeat, 300, 5
 outch iChannel, aOut
endin

</CsInstruments>
<CsScore>
i "Equal" 0 9.5
i "Beat" 11 9.5
i "Dialog" 22 9.5
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz and philipp henkel
