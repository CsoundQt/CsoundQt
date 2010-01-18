<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****DIFFERENT METHODS OF CROSS SYNTHESIS*****/
;example for qutecsound
;written by joachim heintz
;jan 2010
;please send bug reports and suggestions
;to jh at joachimheintz.de


ksmps = 16
0dbfs = 1

		seed		0

  opcode FileToPvsBuf1, iik, Siiii
;;writes the first channel of an audio file at the first k-cycle to a fft-buffer (via pvsbuffer)
Sfile, ifftsize, ioverlap, iwinsize, iwinshape xin
ktimek		timeinstk
if ktimek == 1 then
ilen		filelen	Sfile
kcycles	=		ilen * kr; number of k-cycles to write the fft-buffer
kcount		init		0
ichnls		filenchnls	Sfile
if ichnls == 1 then; Mono
loopmono:
ain		soundin	Sfile
fftin		pvsanal	ain, ifftsize, ioverlap, iwinsize, iwinshape
ibuf, ktim	pvsbuffer	fftin, ilen + (ifftsize / sr)
		loop_lt	kcount, 1, kcycles, loopmono
else; Stereo
loopstereo:
ain, anull	soundin	Sfile
fftin		pvsanal	ain, ifftsize, ioverlap, iwinsize, iwinshape
ibuf, ktim	pvsbuffer	fftin, ilen + (ifftsize / sr)
		loop_lt	kcount, 1, kcycles, loopstereo
endif
		xout		ibuf, ilen, ktim
endif
  endop

  opcode	ShowLED_a, 0, Sakkk
;shows an audiosignal in an outvalue channel, in dB or raw amplitudes
;Soutchan: string as name of the outvalue channel
;asig: audio signal to be shown
;kdispfreq: refresh frequency of the display (Hz)
;kdb: 1 = show as db, 0 = show as raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: which dB range is shown
Soutchan, asig, ktrig, kdb, kdbrange	xin
kdispval	max_k	asig, ktrig, 1
	if kdb != 0 then
kdb 		= 		dbfsamp(kdispval)
kval 		= 		(kdbrange + kdb) / kdbrange
	else
kval		=		kdispval
	endif
	if ktrig == 1 then
		outvalue	Soutchan, kval
	endif
  endop

  opcode ShowOver_a, 0, Sakk
;shows if asig has been larger than 1 and stays khold seconds
;Soutchan: string as name of the outvalue channel
;kdispfreq: refresh frequency of the display (Hz)
Soutchan, asig, ktrig, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
kmax		max_k		asig, ktrig, 1
	if kon == 0 && kmax > 1 && ktrig == 1 then
kstart		=		ktim
kend		=		kstart + khold
		outvalue	Soutchan, kmax
kon		=		1
	endif
	if kon == 1 && ktim > kend && ktrig == 1 then
		outvalue	Soutchan, 0
kon		=		0
	endif
  endop


instr 1
;;FILE INPUT AND FFT-BUFFER LOAD
Sfile1		invalue	"_Browse1"
Sfile2		invalue	"_Browse2"
ifftsize	=		1024
ioverlap	=		ifftsize / 4
iwinsize	=		ifftsize
iwinshape	=		1; von-Hann window
ibuffer1, ilen1, k01  FileToPvsBuf1  Sfile1, ifftsize, ioverlap, iwinsize, iwinshape
ibuffer2, ilen2, k02  FileToPvsBuf1  Sfile2, ifftsize, ioverlap, iwinsize, iwinshape
;;TIME POINTER IN BUFFER 1 AND 2
;Select method
ktimreadmeth	invalue	"timreadmeth"; 0=phasor, 1=gui, 2=random
 if ktimreadmeth == 0 then; 1) PHASOR
kphaspeed1	invalue	"phaspeed1"
kphaspeed2	invalue	"phaspeed2"
kphasfq1	=		kphaspeed1 / ilen1
kphasfq2	=		kphaspeed2 / ilen2
kphaspnt1	phasor		kphasfq1
kphaspnt2	phasor		kphasfq2
kpnt1		=		kphaspnt1 * ilen1
kpnt2		=		kphaspnt2 * ilen2
 elseif ktimreadmeth == 1 then; 2) CONTROLLER WIDGET (MOUSE)
kpos1		invalue	"livepos1"; horizontal (left to right) = position in file 1
kpos2		invalue	"livepos2"; vertical (bottom to top) = position in file 2
kpnt1		=		kpos1 * ilen1
kpnt2		=		kpos2 * ilen2
 else; 3) RANDOM POSITIONS AND INTERPOLATIONS
kfqnewval1	invalue	"fqnewval1"; frequency of new random values for file 1
kfqnewval2	invalue	"fqnewval2"; and for file 2
kpnt1		randomi	0, ilen1, kfqnewval1
kpnt2		randomi	0, ilen2, kfqnewval2
 endif
;show pointer positions
		outvalue	"kpnt1", kpnt1; time in seconds for display widget
		outvalue	"kpnt2", kpnt2
		outvalue	"showpos1", kpnt1/ilen1; time 0-1 for controller widget
		outvalue	"showpos2", kpnt2/ilen2
;;CREATE PVS STREAMS
kchangeorder	invalue	"changeorder"
kbuffer1	=		(kchangeorder == 0 ? ibuffer1 : ibuffer2)
kbuffer2	=		(kchangeorder == 0 ? ibuffer2 : ibuffer1)
fread1		pvsbufread	kpnt1, kbuffer1
fread2		pvsbufread	kpnt2, kbuffer2
;;PERFORM CROSS SYNTHESIS
kselcross	invalue	"selcross"
if kselcross == 0 then
;PVSCROSS: freqs from fread1, amps according crossamp from fread1 and fread2
kcrossamp2	invalue	"crossamp"; 0-1
kcrossamp1	=		1 - kcrossamp2
fcross		pvscross	fread1, fread2, kcrossamp1, kcrossamp2
elseif kselcross == 1 then
;PVSFILTER: freqs from fread1, amps from fread1 are multipied by those from fread2 scaled by kfiltdepth
kfiltdepth	invalue	"filtdepth"
fcross		pvsfilter	fread1, fread2, kfiltdepth
elseif kselcross == 2 then
;PVSVOC: amps from fread1, freqs from fread2 according to kvocdepth
kvocdepth	invalue	"vocdepth"; freqs from fread1 (0) or fread2 (1)
fcross		pvsvoc		fread1, fread2, kvocdepth, 1
else
;PVSMORPH: interpolates between the freqs and the amps from both streams according to kmorphfreq and kmorphamp
kmorphamp	invalue	"morphamp"
kmorphfreq	invalue	"morphfreq"
fcross		pvsmorph	fread1, fread2, kmorphamp, kmorphfreq
endif
;;RESYNTHESIZE 
across		pvsynth	fcross
kvol		invalue	"vol"
avol		=		across * kvol
		out		avol
;;SHOW OUTPUT
kshowdb	invalue	"showdb"; 0=raw amplitudes, 1=db as display in the widgets
kdbrange	invalue	"dbrange"; if kshowdb==1: which db range
kTrigDisp	metro		10
		ShowLED_a	"out", avol, kTrigDisp, kshowdb, kdbrange
		ShowOver_a	"outover", avol, kTrigDisp, 2
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
WindowBounds: 198 30 1074 797
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioMenu {832, 69} {110, 25} 0 303 "Phasor,Live,Random" timreadmeth
ioText {525, 64} {295, 32} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select a Method of Time Reading
ioText {492, 96} {473, 98} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioSlider {551, 126} {339, 28} -2.000000 2.000000 1.339233 phaspeed1
ioText {889, 128} {70, 26} display 0.000000 0.00100 "phaspeed1" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.3510
ioSlider {550, 154} {339, 28} -2.000000 2.000000 0.513274 phaspeed2
ioText {888, 156} {70, 26} display 0.513274 0.00100 "phaspeed2" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5133
ioText {500, 125} {52, 30} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 1
ioText {499, 152} {52, 30} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 2
ioText {8, 258} {479, 73} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border pvscross
ioText {8, 397} {479, 70} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border pvsvoc
ioText {8, 330} {479, 68} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border pvsfilter
ioText {8, 466} {479, 134} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border pvsmorph
ioSlider {74, 293} {275, 29} 0.000000 1.000000 0.501818 crossamp
ioText {406, 295} {70, 26} display 0.000000 0.00100 "crossamp1" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5709
ioText {17, 292} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 1
ioText {146, 265} {160, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amplitudes from 
ioText {351, 294} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 2
ioSlider {79, 559} {275, 29} 0.000000 1.000000 0.236364 morphfreq
ioText {411, 561} {70, 26} display 0.236364 0.00100 "morphfreq" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.2364
ioText {22, 558} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 1
ioText {88, 531} {307, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequencies from 
ioText {356, 560} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 2
ioMenu {357, 231} {108, 22} 0 303 "pvscross,pvsfilter,pvsvoc,pvsmorph" selcross
ioText {45, 227} {325, 32} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select a Method of Cross Synthesis
ioSlider {73, 362} {275, 29} 0.000000 1.000000 0.549091 filtdepth
ioText {405, 364} {70, 26} display 0.549091 0.00100 "filtdepth" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5491
ioText {16, 361} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder low
ioText {82, 336} {307, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Depth of filtering
ioText {350, 363} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder high
ioSlider {71, 429} {275, 29} 0.000000 1.000000 0.650909 vocdepth
ioText {403, 431} {70, 26} display 0.650909 0.00100 "vocdepth" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.6509
ioText {14, 428} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder low
ioText {80, 403} {307, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Depth of vocoding
ioText {348, 430} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder high
ioSlider {79, 497} {275, 29} 0.000000 1.000000 0.723636 morphamp
ioText {411, 499} {70, 26} display 0.723636 0.00100 "morphamp" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.7236
ioText {22, 496} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 1
ioText {90, 471} {307, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amplitudes from 
ioText {356, 498} {52, 30} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 2
ioText {499, 101} {227, 27} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder For Method "Phasor": Set Speed
ioText {492, 196} {474, 291} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {502, 202} {98, 267} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder For Method "Live":Â¬Set Positions for File 1 from left to right and for File 2 from bottom to top
ioMeter {631, 201} {313, 280} {0, 59904, 0} "livepos2" 0.678571 "livepos1" 0.619808 crosshair 1 0 mouse
ioText {492, 490} {474, 110} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {498, 498} {464, 44} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder For Method "Random":Â¬Set Frequency for new Random Positions in File 1 and File 2
ioSlider {518, 542} {170, 27} 0.000000 2.000000 0.400000 fqnewval1
ioText {591, 565} {61, 28} display 0.000000 0.00100 "fqnewval1" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.4000
ioSlider {728, 541} {171, 28} 0.000000 2.000000 0.421053 fqnewval2
ioText {799, 565} {70, 29} display 0.000000 0.00100 "fqnewval2" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.4211
ioText {536, 564} {52, 30} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 1
ioText {747, 564} {52, 30} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File 2
ioText {8, 603} {736, 150} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {114, 656} {81, 28} display 11.034742 0.00100 "kpnt1" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11.0347
ioText {12, 642} {103, 43} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Position (sec) in File 1
ioText {115, 708} {81, 28} display 1.983411 0.00100 "kpnt2" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.9834
ioText {12, 693} {103, 43} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Position (sec) in File 2
ioMeter {372, 683} {336, 22} {0, 59904, 0} "out2_post" 0.545455 "out" 0.790586 fill 1 0 mouse
ioMeter {706, 683} {27, 22} {50176, 3584, 3072} "outRover" 0.000000 "outover" 0.000000 fill 1 0 mouse
ioText {654, 715} {80, 25} editnum 50.000000 0.100000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50.000000
ioText {575, 714} {80, 26} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB-Range
ioText {372, 714} {117, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show LED as
ioMenu {489, 714} {84, 26} 1 303 "Amplitudes,dB" showdb
ioSlider {373, 642} {293, 31} 0.000000 4.000000 0.505119 vol
ioText {396, 618} {307, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Volume
ioMeter {202, 612} {152, 130} {0, 59904, 0} "showpos2" 0.349932 "showpos1" 0.943702 crosshair 1 0 mouse
ioText {665, 645} {69, 27} display 0.505119 0.00100 "vol" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5051
ioText {12, 612} {147, 30} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output
ioText {8, 96} {480, 123} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {14, 117} {358, 22} edit 0.000000 0.00100 "_Browse1" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {373, 115} {107, 29} value 1.000000 "_Browse1" "File 1" "/" 
ioText {14, 151} {358, 22} edit 0.000000 0.00100 "_Browse2" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {373, 149} {107, 29} value 1.000000 "_Browse2" "File 2" "/" 
ioText {14, 184} {311, 27} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Let File 1 be File 2 and vice versa
ioCheckbox {324, 187} {27, 19} off changeorder
ioText {43, 66} {190, 30} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Choose Files
ioText {8, 14} {958, 49} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder CROSS SYNTHESIS
ioText {747, 603} {219, 150} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground border Here you can perform four different methods of Cross Synthesis in Csound.Â¬First, choose two files you want to cross. Second, select a method of cross synthesis (see the relevant manual pages for detailed descriptions).Â¬Third, select a method of time reading: phasor (constant speed), mouse input or random. 
</MacGUI>

