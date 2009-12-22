<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1


instr 1
krelx  invalue  "_MouseRelX"
krely  invalue  "_MouseRelY"

outvalue "anything", krelx ; Must call the outvalue callback to update widgets

ioffx = 100
ioffy = 0
iscalex = 3
iscaley = 200

kcps = (krelx /iscalex) + ioffx
kcps portk kcps, 0.04 ;smooth signal

kamp = (krely/iscaley) + ioffy
kamp portk kamp, 0.04 ;smooth signal

aout oscil3 kamp, kcps, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 200
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 625 358 643 251
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {48059, 65535, 42662}
ioText {70, 43} {59, 25} display 636.000000 0.00100 "_MouseX" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 636.0000
ioText {70, 71} {59, 25} display 367.000000 0.00100 "_MouseY" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 367.0000
ioText {71, 100} {59, 25} display 11.000000 0.00100 "_MouseRelX" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 11.0000
ioText {71, 128} {59, 25} display 9.000000 0.00100 "_MouseRelY" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 9.0000
ioText {7, 43} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder _MouseX
ioText {7, 71} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder _MouseY
ioText {7, 100} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder _MouseRelX
ioText {7, 128} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder _MouseRelY
ioText {7, 18} {80, 25} label 0.000000 0.00100 "" center "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Chan. name
ioText {71, 157} {59, 25} display 0.000000 0.00100 "_MouseBut1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 0.0000
ioText {71, 185} {59, 25} display 1.000000 0.00100 "_MouseBut2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 1.0000
ioText {7, 157} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder _MouseBut1
ioText {7, 185} {64, 25} label 0.000000 0.00100 "" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder _MouseBut2
</MacGUI>

