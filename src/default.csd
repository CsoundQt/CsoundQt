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
; You can receive the values from the sliders
; using chnget. The sliders are numbered
; from 1 to 5 in the current version

kslider1  chnget  "slider1"
kslider2  chnget  "slider2"
aout oscil kslider2*100, (kslider1+100)*2, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 2
i 2 2 20
e
</CsScore>
</CsoundSynthesizer>
