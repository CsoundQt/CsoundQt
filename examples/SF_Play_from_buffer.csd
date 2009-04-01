<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

/*****Playing a soundfile 1b: play from a buffer*****/
;written by joachim heintz and andres cabrera
;mar 2009

instr 1; fill the buffer and play
	Sfile	invalue	"_Browse1"  ;GUI input
	
	gichn	filenchnls	Sfile; check if mono or stereo
	   ;reading the data in the buffers (function tables)
	giL		ftgen	0, 0, 0, 1, Sfile, 0, 0, 1
	if gichn == 2 then		
		giR		ftgen	0, 0, 0, 1, Sfile, 0, 0, 2
	endif
	turnon 2
endin

instr 2; read the buffer
   ;GUI input
kskip		invalue		"skip"
kloop		invalue		"loop"
iskip		=			i(kskip)
iloop		=			i(kloop)
   ;comparing the sample rates and reading the buffer
ilensmps	=			ftlen(giL)		
idur		=			ilensmps / sr; duration to read the buffer
ireadfreq	=			sr / ilensmps; frequency of reading the buffer
iphs		=			iskip / idur; starting point as phase
aL		poscil3		1, ireadfreq, giL, iphs
  if gichn == 2 then
aR		poscil3		1, ireadfreq, giR, iphs; right channel for stereo soundfile
  else
aR		=			aL; right channel for mono soundfile
  endif
   ;stop instr after playing the buffer if no loop
ktim		timeinsts		
  if iloop == 0 && ktim > idur-iskip then
		turnoff
  endif
		outs			aL, aR
endin

instr 3; turns off instr 2
		turnoff2		2, 0, 0
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
WindowBounds: 512 231 462 631
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32639, 43690, 34438}
ioText {27, 96} {295, 24} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {327, 93} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioButton {124, 139} {78, 26} event 1.000000 "" "Play" "/" i 1 0 9999
ioButton {225, 140} {80, 25} event 1.000000 "" "Stop" "/" i 3 0 .1
ioText {156, 185} {87, 25} editnum 0.000000 0.001000 "skip" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioCheckbox {318, 188} {20, 20} off loop
ioText {76, 184} {80, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder skiptime
ioText {267, 183} {52, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder loop
ioText {29, 10} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SIMPLE SOUNDFILE PLAYER
ioText {28, 52} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (playing from a buffer)
ioText {25, 410} {410, 182} label 0.000000 0.00100 "" center "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This simple example shows how a mono or stereo soundfile can be played in Csound from a memory buffer. The disadvantage of playing a soundfile in this way is that it takes some time to read the file in your RAM (and you must have enough RAM), but you have better performance and stability.Â¬Note that the file's sample rate is NOT converted to the orchestra sample rate!
ioGraph {31, 228} {397, 89} scope 2.000000 1.000000 
ioGraph {32, 314} {397, 89} scope 2.000000 2.000000 
</MacGUI>

