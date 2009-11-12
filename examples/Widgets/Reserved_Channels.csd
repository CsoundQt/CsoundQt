<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1  ;random frequencies
kcount init 0
kfreq  randomh  80, 1000, 4
aout oscil 0.2, kfreq, 1
outs aout, aout
ktrig metro 1, 0.99999999
Stime sprintfk "%i", kcount
outvalue "counter", Stime
if ktrig = 1 then
kcount = kcount + 1
endif
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
WindowBounds: 795 228 444 518
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {24929, 34952, 26471}
ioText {6, 11} {418, 94} label 0.000000 0.00100 "" center "DejaVu Sans" 10 {5120, 13312, 1536} {62464, 63488, 51200} background noborder Some channel names are reserved for special operations inside QuteCsound. These channel names send information to QuteCsound instead of to Csound allowing you to control certain aspects of QuteCsound from the Widget Panel.Â¬NOTE: Buttons must be of "value" type for this to work!
ioText {7, 304} {416, 171} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border File browsingÂ¬
ioButton {327, 314} {80, 25} value 1.000000 "_Browse1" "Browse A" "/" i1 0 10
ioText {204, 315} {118, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Browse1 channel ->
ioButton {327, 348} {80, 25} value 1.000000 "_Browse2" "Browse B" "/" i1 0 10
ioText {204, 349} {118, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Browse2 channel ->
ioText {22, 379} {387, 25} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {22, 434} {387, 25} edit 0.000000 0.00100 "_Browse2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {22, 351} {118, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder File A:
ioText {22, 408} {118, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder File B:
ioText {6, 112} {418, 184} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border TransportÂ¬
ioButton {316, 126} {78, 26} value 1.000000 "_Play" "Play" "/" i1 0 10
ioButton {318, 194} {80, 25} value 1.000000 "_Stop" "Stop" "/" i1 0 10
ioText {211, 128} {101, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Play channel ->
ioText {212, 195} {101, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Stop channel ->
ioButton {319, 226} {80, 25} value 1.000000 "_Render" "Render" "/" i1 0 10
ioText {157, 227} {157, 52} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder      _Render channel ->Â¬Run offlineÂ¬(non-realtime)
ioText {20, 164} {161, 45} display 0.000000 0.00100 "counter" center "DejaVu Sans" 28 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {43, 138} {115, 23} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Playback counter
ioButton {317, 159} {78, 26} value 1.000000 "_Pause" "Pause" "/" i1 0 10
ioText {212, 161} {101, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Pause channel ->
</MacGUI>

