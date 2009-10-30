<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

chn_S "hertz", 1  ;String channels must be declared
chn_S "c", 1  ;String channels must be declared

instr 1
	kmidi invalue "midi"
	khertz = 440 * 2^((kmidi -69)/12)
	Shertz sprintfk "%f Hz.", khertz
	outvalue "hertz", Shertz

	ka invalue "a"
	kb invalue "b"
	printk2 ka
	printk2 kb
	Sc sprintfk "is %f.", ka*kb
	outvalue "c", Sc
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 735 284 398 292
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {57, 6} {265, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Scroll Number Widget
ioText {6, 45} {364, 78} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Scroll Number Widgets are just like display widgets but their values can be changed by dragging with the mouse. The number of decimal places used and the size of the step for each mouse pixel is set by the resolution in the properties.
ioText {103, 196} {259, 43} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {49408, 41728, 36352} background noborder 
ioText {113, 204} {55, 23} scroll 1.200000 0.001000 "a" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border 1.200
ioText {211, 204} {55, 23} scroll 1.500000 0.100000 "b" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border 1.5
ioText {168, 204} {44, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder times
ioText {265, 204} {80, 25} display 0.000000 0.00100 "c" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder is 6.031900.
ioText {10, 129} {250, 54} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {49408, 41728, 36352} background noborder 
ioText {19, 135} {87, 25} scroll 60.000000 1.000000 "midi" center "Times New Roman" 16 {65280, 65280, 65280} {22528, 26368, 28928} background noborder 60
ioText {16, 160} {110, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MIDI note number
ioText {108, 136} {38, 23} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder has
ioText {151, 135} {97, 25} display 0.000000 0.00100 "hertz" left "DejaVu Sans" 8 {0, 0, 0} {52736, 54784, 43264} background border 174.614120 Hz.
</MacGUI>

