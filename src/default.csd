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
outs aout, aout
endin

instr 2
kamp  chnget  "slider1"
kfreq  chnget  "slider2"
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
WindowBounds: 72 179 850 930
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1
ioSlider {45, 5} {20, 100} 100.000000 1000.000000 0.000000 slider2
ioSlider {85, 5} {20, 100} 0.000000 1.000000 0.000000 slider3
ioSlider {125, 5} {20, 100} 0.000000 1.000000 0.000000 slider4
ioSlider {165, 5} {20, 100} 0.000000 1.000000 0.000000 slider5
ioText {200, 5} {140, 100} label 0.000000 0.001000 "chann" left "Lucida Grande" 6 {0, 0, 0} {65535, 65535, 65535} nobackground border Receive the values from widgets using chnget. Change a widget's properties by right-clicking.
ioButton {5, 140} {100, 30} event 1.000000 "button1" "Button 1" "/" i1 0 10
</MacGUI>
