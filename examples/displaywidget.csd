<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

gibeats init 0
chn_S "location", 1  ;String channels must be declared

instr 1
	ktime timeinsts
	outvalue "time", ktime

	ktempo invalue "tempo"
	outvalue "tempodisp", ktempo
	kfreq = ktempo/60
	ktrig metro kfreq
	schedkwhen ktrig, 0.5, 1, 2, 0, 0.5
endin

instr 2 ; triggered once every second from instr 1
	gibeats = gibeats + 1
	ibar = int(gibeats/4)
	ibeat = (gibeats % 4) + 1
	Sloc sprintf "Bar:Beat - %i:%i", ibar, ibeat
	outvalue "location", Sloc 
	turnoff
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
WindowBounds: 735 284 393 300
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {116, 6} {199, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Display Widget
ioText {6, 45} {363, 48} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Display widgets are labels whose value can be set from Csound through channels. The Display Widget can display both numbers and text.
ioText {204, 102} {166, 35} display 0.000000 0.00100 "time" center "Courier New" 20 {0, 0, 0} {56064, 65280, 56576} background noborder 44.7913
ioText {88, 108} {116, 29} label 0.000000 0.00100 "" right "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Time elapsed:
ioSlider {12, 155} {249, 26} 30.000000 180.000000 52.727273 tempo
ioText {117, 178} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Tempo
ioText {259, 153} {68, 26} display 0.000000 0.00100 "tempodisp" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 52.7273
ioText {326, 153} {49, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder bpm
ioText {10, 205} {367, 48} display 0.000000 0.00100 "location" center "DejaVu Sans" 24 {65280, 65280, 65280} {25088, 25088, 25088} nobackground border Bar:Beat - 10:1
</MacGUI>

