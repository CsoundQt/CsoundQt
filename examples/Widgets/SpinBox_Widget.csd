<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kamp invalue "amp"
kfreq invalue "freq"
aout oscil kamp/ 10, kfreq, 1
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
WindowBounds: 648 88 400 220
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {90, 5} {218, 33} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder SpinBox Widget
ioText {8, 44} {374, 52} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder SpinBox widgets allow insertion of numbers with the keyboard and the mouse. They work in a similar way to other text or value widgets.
ioText {129, 105} {80, 25} editnum 220.000000 10.000000 "freq" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 220.000000
ioText {129, 139} {80, 25} editnum 0.500000 0.100000 "amp" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.500000
ioText {52, 105} {80, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq
ioText {52, 138} {80, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 








</EventPanel>