<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1  ;random frequencies
kfreq  randomh  80, 1000, 4
aout oscil 0.2, kfreq, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600  ;turn on instr 1 for 3600 seconds
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 511 232 423 450
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {24929, 34952, 26471}
ioButton {316, 111} {78, 26} value 1.000000 "_Play" "Play" "/" i1 0 10
ioButton {316, 148} {80, 25} value 1.000000 "_Stop" "Stop" "/" i1 0 10
ioText {6, 11} {389, 93} label 0.000000 0.00100 "" center "DejaVu Sans" 10 {5120, 13312, 1536} {62464, 63488, 51200} background noborder Some channel names are reserved for special operations inside QuteCsound. These channel names send information to QuteCsound instead of to Csound allowing you to control certain aspects of QuteCsound from the Widget Panel.Â¬NOTE: Buttons must be of "value" type for this to work!
ioText {211, 113} {101, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Play channel ->
ioText {210, 149} {101, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Stop channel ->
ioButton {316, 182} {80, 25} value 1.000000 "_Browse1" "Browse A" "/" i1 0 10
ioText {193, 183} {118, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Browse1 channel ->
ioButton {316, 216} {80, 25} value 1.000000 "_Browse2" "Browse B" "/" i1 0 10
ioText {193, 217} {118, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Browse2 channel ->
ioText {9, 319} {387, 25} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {9, 374} {387, 25} edit 0.000000 0.00100 "_Browse2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {9, 293} {118, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder File A:
ioText {9, 348} {118, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder File B:
ioButton {317, 250} {80, 25} value 1.000000 "_Render" "Render" "/" i1 0 10
ioText {155, 251} {157, 52} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder      _Render channel ->Â¬Run offlineÂ¬(non-realtime)
</MacGUI>

