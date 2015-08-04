<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>
ksmps = 32

gkArray[] fillarray 1, 2, 3, 5, 8

instr Call
kNumCall init 1
kTrig metro 1
if kTrig == 1 then
  event "i", "Called", 0, 1, kNumCall
  kNumCall += 1
endif
endin

instr Called
  ;get the number of the instrument instance
iNumCall = p4
  ;set the start index for the while-loop
kIndex = 0
  ;get the init value of kIndex
prints "Initialization value of kIndx in call %d = %d\n", iNumCall, i(kIndex)
  ;perform the while-loop until kIndex equals five
while kIndex < lenarray(gkArray) do
  printf "Index %d of gkArray has value %d\n", kIndex+1, kIndex, gkArray[kIndex]
  kIndex += 1
od
  ;last value of kIndex is 5 because of increment
printks "  Last value of kIndex in call %d = %d\n", 0, iNumCall, kIndex
  ;turn this instance off after first k-cycle
turnoff
endin

</CsInstruments>
<CsScore>
i "Call" 0 1 ;change performance time to 2 to get an error!
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
