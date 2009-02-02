<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kfreq line 100, p3, 1000
aout oscil 0.2, kfreq, 1
outvalue "freqsweep", kfreq
outs aout, aout
endin

instr 2
kamp  invalue  "amp"
kfreq  invalue  "freq"
aout oscil kamp, kfreq, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 2 0 20
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 324 204 287 407
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioSlider {8, 7} {20, 98} 0.000000 1.000000 0.418367 amp
ioSlider {34, 6} {239, 22} 100.000000 1000.000000 427.615063 freq
ioGraph {8, 112} {265, 116} table 0.000000 1.000000 
ioListing {8, 234} {266, 158}
ioText {34, 37} {41, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder Amp:
ioText {74, 37} {70, 24} display 0.000000 0.00100 "amp" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder 0.4184
ioText {35, 67} {41, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder Freq:
ioText {75, 67} {69, 24} display 0.000000 0.00100 "freq" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder 427.6151
ioText {152, 34} {119, 69} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {169, 72} {78, 24} display 0.000000 0.00100 "freqsweep" center "Lucida Grande" 8 {0, 0, 0} {50432, 44032, 17664} background border 999.6769
ioButton {160, 37} {100, 30} event 1.000000 "Button 1" "Sweep" "/" i1 0 10
</MacGUI>

