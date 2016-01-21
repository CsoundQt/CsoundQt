<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>
ksmps = 32

 instr Call
kNumCall init 1
kTrig metro 1
if kTrig == 1 then
  event "i", "Called", 0, 1, kNumCall
  kNumCall += 1
endif
 endin

 instr Called
iNumCall = p4
kRndVal random 0, 10
prints "Initialization value of kRnd in call %d = %.3f\n", iNumCall, i(kRndVal)
printks "  New random value of kRnd generated in call %d = %.3f\n", 0, iNumCall, kRndVal
turnoff
 endin

</CsInstruments>
<CsScore>
i "Call" 0 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
