<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 8192, 10, 1

instr 1; basic FM using the foscil opcode
 kDenominator = 110
 kCar = 3
 kMod = 1
 kIndex randomi 1, 2, 20
 aFM foscil 0.1, kDenominator, kCar, kMod, kIndex, giSine
 outs aFM, aFM
endin

instr 2; basic FM with jumping (noisy) Denominator value
 kDenominator random 100, 120
 kCar = 3
 kMod = 1
 kIndex randomi 1, 2, 20
 aFM foscil 0.1, kDenominator, kCar, kMod, kIndex, giSine
 outs aFM, aFM
endin

instr 3; basic FM with jumping Denominator and moving Modulator
 kDenominator random 100, 120
 kCar = 3
 kMod randomi 0, 5, 100, 3
 kIndex randomi 1, 2, 20
 aFM foscil 0.1, kDenominator, kCar, kMod, kIndex, giSine
outs aFM, aFM
endin

</CsInstruments>
<CsScore>
i 1 0 10
i 2 12 10
i 3 24 10
</CsInstruments>
</CsScore>
</CsoundSynthesizer>
;example by Marijana Janevska
