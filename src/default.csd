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
WindowBounds: 324 204 572 424
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32125, 41634, 41120}
ioSlider {266, 7} {20, 98} 0.000000 1.000000 0.367347 amp
ioSlider {10, 29} {239, 22} 100.000000 1000.000000 261.924686 freq
ioGraph {8, 112} {265, 116} table 0.000000 1.000000 
ioListing {279, 112} {266, 266}
ioText {293, 44} {41, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder Amp:
ioText {333, 44} {70, 24} display 0.000000 0.00100 "amp" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder 0.3673
ioText {66, 57} {41, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder Freq:
ioText {106, 57} {69, 24} display 0.000000 0.00100 "freq" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder 261.9247
ioText {425, 6} {120, 100} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {449, 68} {78, 24} display 0.000000 0.00100 "freqsweep" center "DejaVu Sans" 8 {0, 0, 0} {14080, 31232, 29696} background border 999.6769
ioButton {435, 24} {100, 30} event 1.000000 "Button 1" "Sweep" "/" i1 0 10
ioGraph {8, 233} {266, 147} scope 2.000000 -1.000000 
</MacGUI>

