<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 20
	ktab invalue "tabnum" ; table number selected
	kspectrum invalue "spectrum" ;spectrum checkbox
	if (ktab>5 || ktab<1) then
		ktab = 1 ; only allow existing tables
	endif
	asig oscilikt 0.2, 440, ktab
	outs asig*0.1,asig*0.1
	if (kspectrum == 1) then
		dispfft asig, 0.2, 1024 ;calculate spectrum
		ktab = 0 ;set to show graph index 0
	endif
	outvalue "graph", -ktab ;show appropriate graph
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1  ;sine
f 2 0 1024 10 1 0.5 0.333
f 3 0 1024 10 1 0 0.333 0 0.25
f 4 0 1024 7 1 512 1 0 -1 512 -1 ;square
f 5 0 1024 7 1 1024 -1 ;saw

i 20 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 634 273 407 498
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioGraph {8, 150} {377, 198} table 0.000000 1.000000 graph
ioText {116, 6} {160, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Graph Widget
ioText {7, 45} {376, 98} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Graph Widgets display Csound's f-tables. The table shown can be changed with the mouse using the menu on the upper left corner. It can also be changed by sending values on the widget's channel Positive values change the table by index and negative values change the table by f-table number. Note that tabes are actually in reverse order in the menu. Graph widgets can also show the spectrum from signals using the dispfft opcode.
ioText {339, 352} {45, 25} editnum 1.000000 1.000000 "tabnum" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {250, 352} {101, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Use f-table
ioText {8, 417} {377, 38} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Note that the buttons will only only work if Csound is running as they generate events which are processed by Csound
ioCheckbox {254, 384} {20, 20} on spectrum
ioText {272, 381} {111, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show spectrum
</MacGUI>

