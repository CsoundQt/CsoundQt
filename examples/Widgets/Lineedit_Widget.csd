<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

chn_S "lineedit", 2

instr 1

	Sin invalue "instring"
	outvalue "display", Sin

	Sline invalue "lineedit"
	klevel invalue "level"
	kdur invalue "dur"
	kcomp strcmpk Sline, "-"
	; trigger notes only when line is not empty
	ktrig = (kcomp != 0? 1: 0)
	kchr strchark Sline, 1
	schedkwhen ktrig, 0.05, 10, 2, 0, kdur, kchr, klevel
	outvalue "lineedit", "-" ;empty line edit widget
endin

instr 2
	idur = p3
	ilevel = p5
	icps = 440 * 2^((p4 - 100)/12)
	aout oscils ilevel, icps, 0
	aenv adsr 0.2*idur, 0.2*idur, 0.7, 0.3*idur
	outs aout*aenv, aout*aenv
endin

</CsInstruments>
<CsScore>
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 550 219 306 465
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 41377, 43433}
ioText {8, 181} {275, 242} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {22272, 22784, 19968} {49664, 51968, 50432} background border 
ioText {15, 187} {262, 228} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 21760, 32512} {49664, 50432, 54784} background border The Line Edit Widget can also be used to receive strings from Csound. Put the keyboard focus on the line edit widget below and type on the ASCII keyboard.
ioText {187, 301} {25, 25} edit 0.000000 0.00100 "lineedit" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -
ioKnob {48, 341} {50, 49} 0.050000 0.500000 0.010000 0.336364 level
ioText {43, 301} {146, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Put keyboard focus here -->
ioText {53, 385} {37, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioSlider {127, 353} {109, 19} 0.200000 2.000000 0.596330 dur
ioText {156, 373} {53, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder duration
ioText {9, 4} {275, 173} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 21760, 32512} {49664, 50432, 54784} background border The Line Edit Widget can be used to pass strings from the widget panel to the csound program. See the "Reserved Channels" example for another usage.
ioText {17, 90} {262, 27} edit 0.000000 0.00100 "instring" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {17, 121} {260, 49} display 0.000000 0.00100 "display" left "Courier New" 20 {21760, 65280, 65280} {0, 0, 0} background border 
</MacGUI>

