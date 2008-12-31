<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	ktype invalue "type"
	ktransp invalue "transp"
	ktfactor tab ktransp, 1 ;map index to transposition factor
	if (ktype == 0) then
		axcite oscil 1, 1, 2
		asig wgflute 0.1, 880*ktfactor, 0.32, 0.1, 0.1, 0.15, 5.925, 0.1, 2
	elseif (ktype == 1) then
		kenv xadsr 0.2, 0.2, 1, p3/2
		asig vco2 kenv*0.1, 440*ktfactor
	elseif (ktype == 2) then
		asig shaker 0.5, 880*ktfactor, 64*ktfactor, 0.7, 3, 0
	endif
	outs asig, asig
endin

instr 2  ;randomize
	itype = rnd(3)
	itransp = rnd(3)
	outvalue "type", int(itype)
	outvalue "transp", int(itransp)
	event "i", 1, 0.1, 2 
	turnoff ;send values only once
endin

</CsInstruments>
<CsScore>
f 1 0 8 -2 2 1 0.5  ;Transp factors (octave up, none, octave down)
f 2 0 16384 10 1

f 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 762 238 396 217
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {116, 6} {160, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Menu Widget
ioText {7, 45} {375, 68} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Menu widgets can show menus with user defined elements. The elements are set as a comma separated list in the properties.The menu widget transmits the index of the currently selected item counting from 0. The current index can also be set from Csound
ioMenu {87, 118} {97, 25} 1 303 "wgflute,saw,shaker" type
ioButton {240, 116} {105, 25} event 1.000000 "button1" "Make sound" "/" i1 0 2
ioMenu {88, 147} {97, 26} 2 303 "12,0,-12" transp
ioButton {201, 146} {178, 26} event 1.000000 "button1" "Randomize and play" "/" i2 0 1
ioText {32, 119} {56, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Sound
ioText {9, 149} {80, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Transposition
</MacGUI>

