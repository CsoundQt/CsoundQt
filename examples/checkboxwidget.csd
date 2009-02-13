<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	khipass invalue "hipass"
	klowpass invalue "lowpass"
	kbandpass invalue "bandpass"
	asig noise 1, 0
	if (khipass == 1) then
		asig atone asig, 3000
		asig atone asig, 3000
		asig atone asig, 3000
	endif
	if (klowpass == 1) then
		asig tone asig, 8000
		asig tone asig, 8000
		asig tone asig, 8000
	endif
	dispfft asig*20, 0.25, 1024
	outs asig*0.1, asig*0.1
endin

instr 2 ; set checkbox values
	kstate init 0
	ktrig metro 1
	if (ktrig == 1) then
		kstate = (kstate == 0 ? 1 : 0)
	endif
	kenable invalue "enable"
	if (kenable == 1) then
		outvalue "checkbox", kstate
	endif
endin

</CsInstruments>
<CsScore>
i 1 0 1000
i 2 0 1000
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 623 358 406 520
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {116, 6} {160, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Checkbox Widget
ioText {7, 45} {377, 56} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder The checkbox widget is a simple widget which sends a value of 1 on its channel when its checked and a 0 when not. It's value can also be set using a channel
ioText {35, 111} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Hi Pass filter
ioText {35, 138} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Low Pass filter
ioGraph {125, 106} {258, 263} table 0.000000 1.000000 
ioText {11, 381} {372, 96} label 0.000000 0.00100 "" center "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border Setting the value of a checkbox
ioCheckbox {18, 441} {22, 20} off checkbox
ioText {37, 440} {313, 28} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This Checkbox's value is set from Csound
ioCheckbox {18, 410} {21, 22} on enable
ioText {35, 410} {336, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Tick this checkbox to enable changing the one below
ioCheckbox {19, 112} {23, 20} off hipass
ioCheckbox {19, 139} {22, 19} off lowpass
</MacGUI>

