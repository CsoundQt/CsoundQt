<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1  ; Equal temperament
; p4 in pitch class
xtratim 0.3
aenv linenr 0.4, 0.01, 0.3, 0.01
aout oscili aenv, cpspch(p4), 1
outs aout*p5, aout*(1-p5)
endin

instr 2  ; Just intonation
; p4 in interval fraction
xtratim 0.3
aenv linenr 0.4, 0.01, 0.3, 0.01
aout oscili aenv, p4 * cpspch(8.00), 1
outs aout*p5, aout*(1-p5)
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1
; Equal tempered
i 1 0 3 8.00 0
i . 0 . 9.00 1
i . + . 8.00 0
i . ^ . 8.07 1
i . + . 8.00 0
i . ^ . 8.04 1
i . + . 8.00 0
i . ^ . 8.10 1
i . + . 8.00 0
i . ^ . 8.04 1
i . ^ . 8.07 0
i . ^ . 8.10 1
i . + . 8.00 1
i . ^ . 8.04 1
i . ^ . 8.07 0
i . ^ . 8.10 0
s
; Now with just intonation

i 2 0 3 [1/1] 0
i . 0 . [2/1] 1
i . + . [1/1] 0
i . ^ . [3/2] 1
i . + . [1/1] 0
i . ^ . [5/4] 1
i . + . [1/1] 0
i . ^ . [16/9] 1
i . + . [1/1] 0
i . ^ . [5/4] 1
i . ^ . [3/2] 0
i . ^ . [15/8] 1
i . + . [1/1] 1
i . ^ . [5/4] 1
i . ^ . [3/2] 0
i . ^ . [15/8] 0
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 479 322 608 353
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {15934, 41634, 17733}
ioGraph {9, 8} {290, 299} lissajou 2.000000 -1.000000 
ioText {310, 10} {277, 255} label 0.000000 0.00100 "" center "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} background border This file shows the difference for a few intervals with Equal temperament and Just Intonation. One note of the interval is placed on the left channel and the other note on the right. The lissajous scope on the left shows the correlation between the channels. Since just intonation intervals are more closely related the graphic dispay is cleaner.
ioButton {310, 273} {278, 33} value 1.000000 "_Play" "Run" "/" 
</MacGUI>

