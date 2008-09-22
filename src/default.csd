<CsoundSynthesizer>
<CsOptions>
; -odac -iadc
; -o test.wav -W
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2

instr 1
kfreq line 100, p3, 1000
aout oscil 10000, kfreq, 1
outs aout, aout
endin

instr 2

endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 5
e
</CsScore>
</CsoundSynthesizer>
