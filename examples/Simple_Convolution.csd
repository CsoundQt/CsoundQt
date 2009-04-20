<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2	
0dbfs = 1

/*****Simple convolution*****/
;example for qutecsound
;written by joachim heintz
;apr 2009
;using the code from matt ingalls (manual for pconvolve)
;please send bug reports and suggestions
;to jh at joachimheintz.de


instr 1
Sfile		invalue	"_Browse1"
Simpulse	invalue	"_Browse2"
kwdmix		invalue	"wdmix"
kgain		invalue	"gain"
ilenfil	filelen	Sfile
ilenimp	filelen	Simpulse
inchnfil	filenchnls	Sfile
inchnimp	filenchnls	Simpulse
ipart		=		2048; partitionsize (see manual page for pconvolve)

kwet		=		kwdmix
kdry		=		1 - kwdmix
idur		=		ilenfil + ilenimp; overall duration
p3		=		idur; let this instr play for this duration

  ; for the following see the example from matt ingalls in the csound manual (pconvolve)
idel		=		(ksmps < ipart ? ipart + ksmps : ipart) / sr; delay introduced by pconvolve
kcount		init		idel * kr
loop:
  if inchnfil == 1 then	;soundfile mono
a1		soundin	Sfile
a2		=		a1
  else				;soundfile stereo
a1, a2		soundin	Sfile
  endif
  if inchnimp == 1 then	;impulsefile mono
awetL	  	pconvolve  	kwet * a1, Simpulse, ipart, 1
awetR	  	pconvolve  	kwet * a2, Simpulse, ipart, 1
  else				;impulsefile stereo
awetL	  	pconvolve  	kwet * a1, Simpulse, ipart, 1
awetR	  	pconvolve  	kwet * a2, Simpulse, ipart, 2
  endif

adryL		delay		kdry * a1, idel
adryR		delay		kdry * a2, idel

kcount		=		kcount - 1
  if kcount > 0 kgoto loop

		outs		(awetL + adryL) * kgain, (awetR + adryR) * kgain
endin

</CsInstruments>
<CsScore>
i 1 0 1; plays the whole soundfile
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 669 224 437 444
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {13, 107} {387, 25} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {98, 73} {226, 29} value 1.000000 "_Browse1" "Browse Soundfile" "/" 
ioText {17, 19} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SIMPLE CONVOLUTION
ioText {26, 290} {226, 109} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Convolves a mono or stereo soundfile with a mono or stereo impulse response file. Usually you will need a gain factor below 1 to avoid clipping.
ioText {14, 178} {387, 25} edit 0.000000 0.00100 "_Browse2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {99, 140} {229, 31} value 1.000000 "_Browse2" "Browse Impulse Response File" "/" 
ioSlider {67, 253} {282, 29} 0.000000 1.000000 0.521277 wdmix
ioText {145, 215} {130, 30} label 0.000000 0.00100 "" center "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet-Dry Mix
ioText {27, 253} {34, 27} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {356, 254} {34, 27} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {260, 289} {130, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output Gain
ioText {287, 324} {80, 25} editnum 0.100000 0.001000 "gain" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.100000
</MacGUI>

