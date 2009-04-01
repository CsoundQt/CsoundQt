<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

/*****Playing a soundfile 1a: simple play from the Harddisk*****/
;written by joachim heintz and andres cabrera
;mar 2009

instr 1
	Sfile		invalue		"_Browse1"
	kskip		invalue		"skip"
	kloop		invalue		"loop"
	ichn		filenchnls		Sfile; check if mono or stereo
	if ichn == 1 then		;mono
		aL	diskin2	Sfile, 1, i(kskip), i(kloop), 0, 1
		aR	=	aL
	else				;stereo
		aL, aR	diskin2		Sfile, 1, i(kskip), i(kloop), 0, 1
	endif
	outs	aL, aR
endin

instr 2
	turnoff2		1, 0, 0
endin

</CsInstruments>
<CsScore>
f 0 36000; don't listen to music longer than 10 hours
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 356 205 435 562
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {37008, 43690, 33153}
ioText {15, 97} {295, 24} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {314, 95} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioButton {112, 138} {78, 26} event 1.000000 "" "Play" "/" i 1 0 9999
ioButton {213, 139} {80, 25} event 1.000000 "" "Stop" "/" i 2 0 .1
ioText {144, 184} {87, 25} editnum 0.000000 0.001000 "skip" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioCheckbox {306, 187} {20, 20} off loop
ioText {64, 183} {80, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder skiptime
ioText {255, 182} {52, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder loop
ioText {15, 9} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SIMPLE SOUNDFILE PLAYER
ioText {14, 51} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (playing from the hard disk)
ioText {17, 406} {393, 122} label 0.000000 0.00100 "" center "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This simple example shows how a mono or stereo soundfile can be played in Csound directly from the hard disk.Â¬Note that the sample rate of the file is NOT converted to the orchestra sample rate!
ioGraph {15, 220} {397, 89} scope 2.000000 1.000000 
ioGraph {15, 306} {397, 89} scope 2.000000 2.000000 
</MacGUI>

