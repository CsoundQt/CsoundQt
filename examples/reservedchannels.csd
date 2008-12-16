<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kfreq  randomh  80, 1000, 4
aout oscil 0.2, kfreq, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 242 225 412 435
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {0, 21845, 0}
ioButton {316, 101} {78, 26} value 1.000000 "_Play" "Play" "/" i1 0 10
ioButton {316, 138} {80, 25} value 1.000000 "_Stop" "Stop" "/" i1 0 10
ioText {6, 11} {396, 79} label 0.000000 0.00100 "" center "DejaVu Sans" 10 {65280, 65280, 65280} {0, 39168, 0} background noborder Some channel names are reserved for special operations inside QuteCsound. These channel names send information to QuteCsound instead of to Csound allowing you to control certain aspects of QuteCsound from the Widget Panel
ioText {211, 103} {101, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Play channel ->
ioText {210, 139} {101, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Stop channel ->
ioGraph {6, 172} {389, 150}
</MacGUI>

