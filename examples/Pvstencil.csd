<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

/*****pvstencil simple*****/
;example for qutecsound
;written by joachim heintz
;mai 2009

gifftsize	=		1024
gitab		ftgen		0, 0, gifftsize, 7, 1, gifftsize, 1; ftable just filled with 1

  opcode TakeAll, a, Si
;don't care whether your sound is mono or stereo
Sfil, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aout		diskin2	Sfil, 1, 0, iloop
else ;if stereo, just the first channel is taken
aout, ano	diskin2	Sfil, 1, 0, iloop
endif
		xout		aout
  endop

instr 1
Sfile		invalue	"_Browse1"
asig		TakeAll	Sfile, 1; 1=loop, 0=no loop
fsig		pvsanal	asig, gifftsize, gifftsize/4, gifftsize, 0
klevel		invalue	"level"
fstencil	pvstencil	fsig, 0, klevel, gitab
aout		pvsynth	fstencil
		outs		aout, aout
endin


</CsInstruments>
<CsScore>
i 1 0 999
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 608 212 442 354
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {48316, 45489, 38036}
ioText {13, 50} {295, 24} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {313, 47} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioText {18, 89} {213, 224} label 0.000000 0.00100 "" right "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border Limit for Binamps to pass
ioText {248, 93} {166, 201} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The opcode pvstencil gives you many opportunities to mask the result of a fft-analysis before resynthesizing. In this simple case, you can select amplitudes of the fft-bins which are beyond a certain threshold.Â¬For another application, see the Noise Reduction example.
ioText {14, 9} {398, 35} label 0.000000 0.00100 "" center "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder pvstencil simple example
ioSlider {24, 96} {25, 210} 0.000000 0.300000 0.021429 level
ioText {62, 273} {57, 26} display 0.000000 0.00100 "level" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0223
ioText {57, 121} {160, 118} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (According to your sound you may want to change the upper limit in the Properties dialog)
</MacGUI>

