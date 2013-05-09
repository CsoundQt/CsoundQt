<CsoundSynthesizer>
<CsOptions>
-nm0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 441
0dbfs = 1
nchnls = 1

instr 1
kCycle timek
prints "Instrument 1 is here at initialization.\n"
printks "Instrument 1: kCycle = %d\n", 0, kCycle
endin

instr 2
kCycle timek
prints "  Instrument 2 is here at initialization.\n"
printks "  Instrument 2: kCycle = %d\n", 0, kCycle
 if kCycle == 1 then
event "i", 3, 0, .02
event "i", 1, 0, .02
 endif
printks "  Instrument 2: still in kCycle = %d\n", 0, kCycle
endin

instr 3
kCycle timek
prints "    Instrument 3 is here at initialization.\n"
printks "    Instrument 3: kCycle = %d\n", 0, kCycle
endin

instr 4
kCycle timek
prints "      Instrument 4 is here at initialization.\n"
printks "      Instrument 4: kCycle = %d\n", 0, kCycle
endin

</CsInstruments>
<CsScore>
i 4 0 .02
i 2 0 .02
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
