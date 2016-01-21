<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
nchnls = 1
ksmps = 32
0dbfs = 1
seed 0

opcode FourModes, a, akk[]
  ;kFQ[] contains four frequency-quality pairs
  aIn, kBasFreq, kFQ[] xin
aOut1 mode aIn, kBasFreq*kFQ[0], kFQ[1]
aOut2 mode aIn, kBasFreq*kFQ[2], kFQ[3]
aOut3 mode aIn, kBasFreq*kFQ[4], kFQ[5]
aOut4 mode aIn, kBasFreq*kFQ[6], kFQ[7]
      xout (aOut1+aOut2+aOut3+aOut4) / 4
endop


instr ham
gkPchMovement = randomi:k(50, 1000, (random:i(.2, .4)), 3)
schedule("hum", 0, p3)
endin

instr hum
if metro(randomh:k(1, 10, random:k(1, 4), 3)) == 1 then
event("i", "play", 0, 5, gkPchMovement)
endif
endin

instr play
iQ1 = random(100, 1000)
kArr[] fillarray 1*random:i(.9, 1.1), iQ1,
                 2.8*random:i(.8, 1.2), iQ1*random:i(.5, 2),
                 5.2*random:i(.7, 1.4), iQ1*random:i(.5, 2),
                 8.2*random:i(.6, 1.8), iQ1*random:i(.5, 2)
aImp   mpulse    ampdb(random:k(-30, 0)), p3
       out       FourModes(aImp, p4, kArr)*linseg(1, p3/2, 1, p3/2, 0)
endin

</CsInstruments>
<CsScore>
i "ham" 0 60
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz, with thanks to steven and iain
