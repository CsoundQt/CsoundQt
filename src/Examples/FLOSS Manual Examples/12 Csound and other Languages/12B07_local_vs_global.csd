<CsoundSynthesizer>
<CsOptions>
-dnm0
</CsOptions>
<CsInstruments>
ksmps=32

pyinit

instr 1 ;local python variable 'value'
 pylassigni "value", p4
 if timeinstk() == 1 then
  kvalue pyleval "value"
  printks "Python variable 'value' in instr %d, instance %d, at start = %d\n",
           0, p1, frac(p1)*10, kvalue
 elseif release() == 1 then
  kvalue pyleval "value"
  printks "Python variable 'value' in instr %d, instance %d, at end = %d\n",
           0, p1, frac(p1)*10, kvalue
 endif
endin

instr 2 ;global python variable 'value'
 pyassigni "value", p4
 if timeinstk() == 1 then
  kvalue pyeval "value"
  printks "Python variable 'value' in instr %d, instance %d, at start = %d\n",
           0, p1, frac(p1)*10, kvalue
 elseif release() == 1 then
  kvalue pyeval "value"
  printks "Python variable 'value' in instr %d, instance %d, at end = %d\n",
           0, p1, frac(p1)*10, kvalue
 endif
endin

</CsInstruments>
<CsScore>
;             p4
i 1.1 0.0  1  100
i 1.2 0.1  1  200
i 1.3 0.2  1  300
i 1.4 0.3  1  400

i 2.1 2.0  1  100
i 2.2 2.1  1  200
i 2.3 2.2  1  300
i 2.4 2.3  1  400
</CsScore>
</CsoundSynthesizer>
;Example by Andrés Cabrera and Joachim Heintz
