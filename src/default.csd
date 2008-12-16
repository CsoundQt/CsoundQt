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
outvalue "slider3", kfreq/1000
outvalue "label", kfreq
outs aout, aout
endin

instr 2
kamp  invalue  "slider1"
kfreq  invalue  "slider2"
aout oscil kamp, kfreq, 1
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
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 627 177 401 704
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1
ioSlider {37, 5} {20, 100} 100.000000 1000.000000 100.000000 slider2
ioSlider {70, 5} {20, 100} 0.000000 1.000000 0.989899 slider3
ioText {102, 50} {169, 56} label 0.000000 0.00100 "chann" left "DejaVu Sans" 8 {0, 0, 0} {51712, 51712, 38656} background noborder Receive the values from widgets using chnget. Change a widget's properties by right-clicking.
ioText {207, 6} {65, 30} display 0.000000 0.00100 "label" left "Lucida Grande" 8 {0, 0, 0} {50432, 44032, 17664} background border 988.9664
ioButton {101, 5} {100, 30} event 1.000000 "button1" "Button 1" "/" i1 0 10
ioMeter {276, 6} {107, 101} {0, 59904, 0} "vert6" 0.000000 "hor6" 0.591304 crosshair 1 0 mouse
ioGraph {6, 114} {377, 198}
ioListing {6, 317} {379, 346}
</MacGUI>

