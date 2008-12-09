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
WindowBounds: 72 179 850 930
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 41377, 43433}
ioText {19, 5} {275, 242} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {22272, 22784, 19968} {49664, 51968, 50432} background border 
ioText {26, 11} {262, 228} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 21760, 32512} {49664, 50432, 54784} background border The Line Edit Widget can be used to pass strings from the widget panel to the csound program. Put the keyboard focus on the line edit widget below and type on the keyboard
ioText {198, 125} {25, 25} edit 0.000000 0.00100 "lineedit"  "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -
ioKnob {59, 165} {50, 49} 0.050000 0.500000 0.010000 0.336364 level
ioText {54, 125} {146, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Put keyboard focus here -->
ioText {64, 209} {37, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioSlider {138, 177} {109, 19} 0.200000 2.000000 0.618182 dur
ioText {167, 197} {53, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder duration
</MacGUI>

