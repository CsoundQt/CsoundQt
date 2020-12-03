<CsoundSynthesizer>
<CsInstruments>

giGlobal   =          1/2

instr 1
iLocal     =          1/4
           print      giGlobal, iLocal
endin

instr 2
iLocal     =          1/5
           print      giGlobal, iLocal
endin

</CsInstruments>
<CsScore>
i 1 0 0
i 2 0 0
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
