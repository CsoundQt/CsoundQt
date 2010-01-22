<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****LIVE GRANULAR SYNTHESIS*****/
;example for qutecsound
;written by joachim heintz
;jan 2010
;please send bug reports and suggestions
;to jh at joachimheintz.de


ksmps = 16
0dbfs = 1

giWin1		ftgen		1, 0, 4096, 20, 1, 1		; Hamming
giWin2		ftgen		2, 0, 4096, 20, 2, 1		; von Hann
giWin3		ftgen		3, 0, 4096, 20, 3, 1		; Triangle (Bartlett)
giWin4		ftgen		4, 0, 4096, 20, 4, 1		; Blackman (3-term)
giWin5		ftgen		5, 0, 4096, 20, 5, 1		; Blackman-Harris (4-term)
giWin6		ftgen		6, 0, 4096, 20, 6, 1		; Gauss
giWin7		ftgen		7, 0, 4096, 20, 7, 1, 6		; Kaiser
giWin8		ftgen		8, 0, 4096, 20, 8, 1		; Rectangle
giWin9		ftgen		9, 0, 4096, 20, 9, 1		; Sync
giLiveBuf	ftgen		0, 0, 16384, 2, 0			; buffer for writing and reading live input
giDisttab	ftgen		0, 0, 32768, 7, 0, 32768, 1	; for kdistribution
giCosine	ftgen		0, 0, 8193, 9, 1, 1, 90		; cosine
giMaxGrLen	=		0.1					; maximaum grain length in seconds

  opcode PartikkelSimpB, a, iakkkkkkkiii
/* Simplified Version of the partikkel opcode, with a time pointer input.
ifiltab:	function table to read
apnter:	pointer in the function table (0-1)
kgrainamp:	multiplier of the grain amplitude (the overall amplitude depends also on grainrate and grainsize)
kgrainrate:	number of grains per seconds
kgrainsize:	grain duration in ms
kdist:		0 = periodic (synchronous), 1 = scattered (asynchronous)
kcent:		transposition in cent
kposrand:	random deviation (offset) of the pointer in ms
kcentrand:	random transposition in cents (up and down)
icosintab:	function table with cosine (e.g. giCosine ftgen 0, 0, 8193, 9, 1, 1, 90)
idisttab:	function table with distribution (e.g. giDisttab ftgen 0, 0, 32768, 7, 0, 32768, 1)
iwin:		function table with window shape (e.g. giWin ftgen 0, 0, 4096, 20, 9, 1)
*/

ifiltab, apnter, kgrainamp, kgrainrate, kgrainsize, kdist, kcent, kposrand, kcentrand, icosintab, idisttab, iwin	xin

/*amplitude*/
kamp		= 		kgrainamp * 0dbfs
/*transposition*/
kcentrand	rand 		kcentrand; random transposition
iorig		= 		1 / (ftlen(ifiltab)/sr); original pitch
kwavfreq	= 		iorig * cent(kcent + kcentrand)	
/*pointer*/
kposrand	=		(kposrand/1000) * (sr/ftlen(ifiltab)); random offset converted from ms to phase (0-1)
arndpos	linrand	kposrand; random offset in phase values
asamplepos	=		apnter + arndpos 
/* other parameters */
imax_grains	= 		1000; maximum number of grains per k-period
async		=		0; no sync input
awavfm		=		0; no audio input for fm

aout		partikkel 	kgrainrate, kdist, idisttab, async, 1, iwin, \
				-1, -1, 0, 0, kgrainsize, kamp, -1, \
				kwavfreq, 0, -1, -1, awavfm, \
				-1, -1, icosintab, kgrainrate, 1, \
				1, -1, 0, ifiltab, ifiltab, ifiltab, ifiltab, \
				-1, asamplepos, asamplepos, asamplepos, asamplepos, \
				1, 1, 1, 1, imax_grains
		xout		aout
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


instr 1; master instrument
;;get live input and write to buffer (ftable) giLiveBuf
aLiveInPre	inch		1
kLiveInGain	invalue	"LiveInGain"
aLiveInPost	=		aLiveInPre * kLiveInGain
iphasfreq	=		1 / (ftlen(giLiveBuf) / sr); phasor frequency
kfreeze	invalue	"freeze"; if checked, freeze writing (and reading) of the buffer
kphasfreq	=		(kfreeze == 1 ? 0 : iphasfreq)
awritpnt	phasor		kphasfreq
		tablew		aLiveInPost, awritpnt, giLiveBuf, 1, 0, 1

;;create an instrument for a readpointer which is giMaxGrLen seconds later than the writepointer
		event_i	"i", 2, giMaxGrLen, -1, iphasfreq

;;show live input
gkTrigDisp	metro		10
gkshowdb	invalue	"showdb"
gkdbrange	invalue	"dbrange"
		ShowLED_a	"LiveInPre", aLiveInPre, gkTrigDisp, gkshowdb, gkdbrange
		ShowOver_a	"LiveInPreOver", aLiveInPre, gkTrigDisp, 2
		ShowLED_a	"LiveInPost", aLiveInPost, gkTrigDisp, gkshowdb, gkdbrange
		ShowOver_a	"LiveInPostOver", aLiveInPost, gkTrigDisp, 2

;;select shape of the grain envelope and show it
kwinshape	invalue	"winshape"; 0=Hamming, 1=von Hann, 2=Bartlett, 3=Triangle, 4=Blackman-Harris,
						;5=Gauss, 6=Kaiser, 7=Rectangle, 8=Sync
		event_i	"i", 10, 0, -1, i(kwinshape)+1
		outvalue	"ftab", 11-(kwinshape); graph widget shows selected window shape

;;triggers i 10 at the beginning and whenever the grain envelope has changed
kchanged	changed	kwinshape; sends 1 if the windowshape has changed
 if kchanged == 1 then
		event		"i", -10, 0, -1; turn off previous instance of i10
		event		"i", 10, 0, -1, kwinshape+1; turn on new instance
 endif
endin

instr 2; creates the pointer for reading the buffer giLiveBuf
iphasfreq	=		p4; usual phasor frequency (calculated and sent by instr 1) 
kfreeze	invalue	"freeze"; if checked, freeze reading of the buffer
kphasfreq	=		(kfreeze == 1 ? 0 : iphasfreq); otherwise use kphasfreq
areadpnt	phasor		kphasfreq
		chnset		areadpnt, "readpnt"; sends areadpnt to the channel 'readpnt'
endin

instr 10; performs granular synthesis
;;parameters for the partikkel opcode
iwin		=		p4; shape of the grain window 
ifiltab	=		giLiveBuf; buffer to read
apnt		init		0; initializing the read pointer
kgrainrate	invalue	"grainrate"; grains per second
kgrainsize	invalue	"grainsize"; length of the grains in ms
kcent		invalue	"transp"; pitch transposition in cent
kgrainamp	invalue	"gain"; volume
kdist		invalue	"dist"; distribution (0=periodic, 1=scattered)
kposrand	invalue	"posrand"; time position randomness (offset) of the read pointer in ms
kcentrand	invalue	"centrand"; transposition randomness in cents (up and down)
icosintab	=		giCosine; ftable with a cosine waveform
idisttab	=		giDisttab; ftable with values for scattered distribution 
apnt		chnget		"readpnt"; pointer generated 

;;granular synthesis
agrain 	PartikkelSimpB 	ifiltab, apnt, kgrainamp, kgrainrate, kgrainsize,\
					kdist, kcent, kposrand, kcentrand, icosintab, idisttab, iwin
		out		agrain

;;show output
		ShowLED_a	"out", agrain, gkTrigDisp, gkshowdb, gkdbrange
		ShowOver_a	"outover", agrain, gkTrigDisp, 2
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
WindowBounds: 119 133 925 752
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {9, 9} {886, 44} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder LIVE GRANULAR SYNTHESIS
ioText {10, 58} {886, 66} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Granulates a (mono) input stream, with optional freezing at a certain point.Â¬If you want to reduce the delay of the granulated output, set giMaxGrLen in the orc header to a lower value (the delay also depends on your -B and -b size).Â¬
ioText {12, 130} {484, 148} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border  INPUT
ioMeter {120, 164} {336, 22} {0, 59904, 0} "out1_post" 0.730769 "LiveInPre" 0.629041 fill 1 0 mouse
ioMeter {454, 164} {27, 22} {50176, 3584, 3072} "outLover" 0.000000 "LiveInPreOver" 0.000000 fill 1 0 mouse
ioMeter {116, 240} {336, 22} {0, 59904, 0} "out2_post" 0.590909 "LiveInPost" 0.419889 fill 1 0 mouse
ioMeter {450, 240} {27, 22} {50176, 3584, 3072} "outRover" 0.000000 "LiveInPostOver" 0.000000 fill 1 0 mouse
ioText {21, 164} {93, 25} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Live in Pre
ioText {19, 240} {97, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Live in Post
ioText {20, 202} {93, 25} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Input Gain
ioSlider {185, 186} {173, 0} 0.000000 1.000000 0.000000 slider7
ioSlider {120, 199} {360, 26} 0.000000 4.000000 0.300000 LiveInGain
ioText {518, 131} {380, 215} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border  OUTPUT
ioMeter {528, 197} {335, 24} {0, 59904, 0} "out2_post" 0.545455 "out" 0.089142 fill 1 0 mouse
ioMeter {863, 198} {26, 24} {50176, 3584, 3072} "outRover" 0.000000 "outover" 0.000000 fill 1 0 mouse
ioText {354, 294} {79, 27} editnum 50.000000 0.100000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50.000000
ioText {275, 293} {79, 28} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB-Range
ioText {12, 295} {139, 24} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show LED's as
ioMenu {151, 292} {108, 28} 1 303 "Amplitudes,dB" showdb
ioGraph {525, 228} {368, 105} scope 2.000000 -1.000000 
ioText {9, 351} {702, 343} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border GRANULAR
ioText {529, 164} {95, 27} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output Gain
ioSlider {625, 165} {205, 24} 0.000000 5.000000 1.000000 gain
ioText {831, 165} {61, 27} display 0.000000 0.00100 "gain" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.0000
ioText {26, 391} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Grains per Second
ioText {25, 478} {147, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Transposition (Cent)
ioSlider {19, 502} {154, 25} -1200.000000 1200.000000 0.000000 transp
ioText {53, 526} {81, 26} display 0.000000 0.00100 "transp" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0000
ioText {46, 564} {101, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Grainsize (ms)
ioSlider {21, 586} {152, 25} 1.000000 100.000000 30.309211 grainsize
ioText {53, 609} {81, 26} display 0.000000 0.00100 "grainsize" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 30.9605
ioSlider {21, 418} {152, 25} 1.000000 200.000000 92.644737 grainrate
ioText {53, 440} {81, 26} display 0.000000 0.00100 "grainrate" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 92.6447
ioText {244, 389} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Distribution
ioSlider {239, 415} {152, 25} 0.000000 1.000000 0.460526 dist
ioText {224, 476} {191, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Position Randomness (ms)
ioSlider {240, 501} {152, 25} 0.000000 100.000000 0.000000 posrand
ioText {274, 523} {81, 26} display 0.000000 0.00100 "posrand" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0000
ioSlider {245, 582} {152, 25} 0.000000 100.000000 0.000000 centrand
ioText {278, 606} {81, 26} display 0.000000 0.00100 "centrand" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0000
ioText {204, 562} {234, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Transposition Randomness (Cent)
ioText {220, 435} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder periodic
ioText {342, 435} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder scattered
ioText {511, 390} {115, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Window Shape
ioMenu {499, 441} {144, 24} 0 303 "Hamming,von Hann,Triangle,Blackman,Blackman-Harris,Gauss,Kaiser,Rectangle,Sync" winshape
ioGraph {442, 494} {256, 145} table 0.000000 1.000000 ftab
ioText {186, 644} {73, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freeze
ioCheckbox {167, 648} {20, 20} off freeze
ioText {483, 466} {168, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ... and see its shape
ioText {469, 416} {185, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select window function ...
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="360" y="248" width="596" height="322"> 








</EventPanel>