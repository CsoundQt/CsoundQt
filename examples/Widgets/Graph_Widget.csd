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
	dispfft asig, 0.2, 1024 ;calculate spectrum
	if (kspectrum == 1) then
		ktab = -5 ;set to show graph index 6
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
WindowBounds: 751 121 404 597
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioGraph {7, 332} {373, 142} table 0.000000 1.000000 graph
ioText {116, 6} {160, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Graph Widget
ioText {7, 45} {376, 98} label 0.000000 0.00100 "" left "Helvetica" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Graph Widgets display Csound's f-tables. The table shown can be changed with the mouse using the menu on the upper left corner. It can also be changed by sending values on the widget's channel Positive values change the table by index and negative values change the table by f-table number. Note that tabes are actually in reverse order in the menu. Graph widgets can also show the spectrum from signals using the dispfft opcode, or time varying signals (a-rate and k-rate) using the display opcode.
ioText {97, 479} {45, 25} editnum 1.000000 1.000000 "tabnum" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {8, 479} {101, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Use f-table
ioText {7, 508} {373, 53} label 0.000000 0.00100 "" left "Helvetica" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Note that the numbers in the lower section will only have effect if Csound is running as they pass through Csound, while the ones on the top are connected directly by channel number.
ioCheckbox {161, 483} {20, 20} on spectrum
ioText {179, 480} {111, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show spectrum
ioGraph {8, 147} {373, 142} table 0.000000 1.000000 graph_direct
ioText {150, 295} {80, 25} editnum 0.000000 1.000000 "graph_direct" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>