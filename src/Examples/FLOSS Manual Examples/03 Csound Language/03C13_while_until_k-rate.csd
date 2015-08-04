<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>
ksmps = 32

  ;create and fill an array
gkArray[] fillarray 1, 2, 3, 4, 5

instr 1
  ;count performance cycles and print it
kCycle timeinstk
printks "kCycle = %d\n", 0, kCycle
  ;set index to zero
kIndex = 0
  ;perform the loop
while kIndex < lenarray(gkArray) do
    ;print array value
  printf "  gkArray[%d] = %d\n", kIndex+1, kIndex, gkArray[kIndex]
    ;square array value
  gkArray[kIndex] = gkArray[kIndex] * gkArray[kIndex]
  ;increment index
kIndex += 1
od
  ;stop after third control cycle
if kCycle == 3 then
  turnoff
endif
endin

</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
