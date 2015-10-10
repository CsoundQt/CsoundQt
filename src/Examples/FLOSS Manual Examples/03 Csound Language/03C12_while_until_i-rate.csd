<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>
ksmps = 32

instr 1
iCounter = 0
while iCounter < 5 do
  print iCounter
iCounter += 1
od
prints "\n"
endin

instr 2
iCounter = 0
until iCounter >= 5 do
  print iCounter
iCounter += 1
od
endin

</CsInstruments>
<CsScore>
i 1 0 .1
i 2 .1 .1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
