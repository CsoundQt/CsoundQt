<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kfreq invalue "freq"
kamp invalue "amp"
kx oscil 0.4*kamp, kfreq*2, 1
ky oscil 0.4*kamp, kfreq*2, 1, 0.25
outvalue "x", kx + 0.5
outvalue "y", ky + 0.5
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 100
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 153 517 418 232
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {24158, 42662, 43690}
ioMeter {10, 10} {150, 150} {0, 59904, 0} "x" 0.301396 "y" 0.764380 point 10 0 mouse
ioText {225, 160} {35, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq
ioMeter {220, 10} {150, 150} {59904, 20992, 16640} "amp" 0.826667 "freq" 0.233333 crosshair 1 0 mouse
ioText {190, 130} {35, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
</MacGUI>

