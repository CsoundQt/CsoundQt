<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 8
0dbfs = 1

/*****Simple 8 channel soundfile player*****/
;example for qutecsound
;written by joachim heintz
;apr 2009
;please send bug reports and suggestions
;to jh at joachimheintz.de

instr 1
Sfile		invalue	"_Browse1"
kskip		invalue	"skiptime"
iskip 		=		i(kskip)
ifilen		filelen	Sfile
p3		=		ifilen - iskip; plays until the end of the file, then ends preformance
a1, a2, a3, a4, a5, a6, a7, a8	soundin	Sfile, iskip
		outch	1,a1, 2,a2, 3,a3, 4,a4, 5,a5, 6,a6, 7,a7, 8,a8; change the numbers for other output channels
endin

</CsInstruments>
<CsScore>
i 1 0 1
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 684 341 441 361
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {46, 172} {80, 25} editnum 0.000000 0.001000 "skiptime" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioText {13, 135} {387, 25} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {44, 197} {83, 28} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Skiptime (sec)
ioButton {154, 95} {100, 30} value 1.000000 "_Browse1" "Open" "/" 
ioButton {151, 172} {100, 30} value 1.000000 "_Play" "Play" "/" 
ioButton {261, 172} {100, 30} value 1.000000 "_Stop" "Stop" "/" 
ioText {7, 8} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SIMPLE 8 CHANNEL
ioText {6, 50} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder  SOUNDFILE PLAYER
ioText {11, 232} {392, 85} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Uses the reserved channels for Start and Stop. Just select your soundfile and push the Play button (No need to use the Run Button in QuteCsound).
</MacGUI>

