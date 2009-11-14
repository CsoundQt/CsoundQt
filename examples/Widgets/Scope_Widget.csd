<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	asig oscils 0.2, 440, 0
	kpan oscil 1, 1, 1
	outs asig*kpan, asig*(1-kpan)
endin


</CsInstruments>
<CsScore>
f 1 0 4096 -7 1 2048 1 0 0 2048 0

i 1 0 1000
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 624 25 496 703
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {160, 9} {160, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Scope Widget
ioText {11, 49} {463, 48} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder The Scope widget is an oscilloscope which can show the output of Csound. The oscilloscope can show individual channels or a sum of all output channels. Clicking on a Scope widget freezes it.
ioGraph {10, 101} {466, 98} scope 2.000000 1.000000 
ioGraph {9, 201} {467, 99} scope 2.000000 2.000000 
ioGraph {9, 304} {466, 97} scope 2.000000 -1.000000 
ioGraph {10, 457} {231, 92} scope 8.000000 -1.000000 
ioText {10, 406} {463, 46} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder The decimation property averages sample, allowing a larger time frame to be displayed. The default without decimation is one audio sample per screen pixel.
ioGraph {247, 457} {226, 91} scope 1.000000 -1.000000 
ioGraph {12, 553} {84, 84} lissajou 2.000000 -1.000000 
ioGraph {101, 553} {84, 84} poincare 2.000000 -1.000000 
ioText {192, 555} {281, 82} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder The Scope widget can also show Lissajou and Poincare graphs. The decimation parameter in these cases determines the "zoom".
</MacGUI>

