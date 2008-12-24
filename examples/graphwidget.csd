<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

ginumtabs = 7
gicurrent init 6

instr setcurrent
	gicurrent = p4
endin

instr 10 ;previous index
	kcurr invalue "graph"
	if (kcurr >= 0) then 
		kcurrent = (gicurrent > 0 ? gicurrent - 1 : 0)
	else
		kcurrent = 0
	endif
	event "i", "setcurrent", 0, 1, kcurrent
	outvalue "graph", kcurrent
	turnoff
endin

instr 11 ;next index
	kcurr invalue "graph"
	if (kcurr >= 0) then 
		kcurrent = (gicurrent < ginumtabs - 1 ? gicurrent + 1 : 0)
	else
		kcurrent = 0
	endif
	event "i", "setcurrent", 0, 1, kcurrent
	outvalue "graph", kcurrent
	turnoff 
endin

instr 12
	ktab invalue "tabnum"
	outvalue "graph", -ktab
	turnoff 
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
f 2 0 1024 10 1 0.5 0.333
f 3 0 1024 10 1 0 0.333 0 0.25
f 10 0 1024 7 1 512 1 0 -1 512 -1
f 11 0 1024 7 1 1024 -1
f 20 0 1024 5 1 1024 0.1
f 21 0 1024 5 1 1024 0.0000001

f 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 867 203 403 445
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioGraph {8, 131} {377, 198} table -10.000000 graph
ioText {116, 6} {160, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Graph Widget
ioText {7, 45} {377, 83} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Graph Widgets display Csound's f-tables. The table shown can be changed with the mouse using the menu on the upper left corner. It can also be changed by sending values on the widget's channel Positive values change the table by index and negative values change the table by f-table number. Note that tabes are actually in reverse order in the menu.
ioButton {9, 338} {66, 25} event 1.000000 "previous" "Previous" "/" i10 0 1
ioButton {77, 338} {66, 25} event 1.000000 "next" "Next" "/" i11 0 1
ioText {275, 339} {45, 25} editnum 10.000000 1.000000 "tabnum" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10.000000
ioText {186, 339} {101, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show f-table
ioButton {320, 339} {66, 25} event 1.000000 "" "Apply" "/" i12 0 1
ioText {9, 368} {377, 38} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Note that the buttons will only only work if Csound is running, as they generate events which are processed by Csound
</MacGUI>

