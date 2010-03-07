<CsoundSynthesizer>
<CsOptions>
-odac --midi-key-cps=4 --midi-velocity-amp=5 -m0
</CsOptions>
<CsInstruments>
/*****WAVEFORM MIX*****/
;example for qutecsound
;written by joachim heintz
;feb 2010

ksmps = 64
massign 0, 2; assigns all incoming MIDI to instr 2

  opcode SinesToSSTI, i, pooo
;produces the waveforms saw (iwf=1, which is also the default), square (iwf=2), triangle (3), impulse (4) by the addition of inparts sinusoides (default = 10) and returns the result in a function table of itabsiz length (must be a power-of-2 or a power-of-2 plus 1, the default is 1024 points) with number ifno (default = 0 which means the number is given automatically)
iwf, inparts, itabsiz, ifno xin
inparts	=		(inparts == 0 ? 10 : inparts)
itabsiz	=		(itabsiz == 0 ? 1024 : itabsiz)
iftemp		ftgen		0, 0, -(inparts * 3), -2, 0;temp ftab for writing the str-pna-phas vals
indx		=		1
loop:
if iwf == 1 then; saw = 1, 1/2, 1/3, ... as strength of partials
		tabw_i		1/indx, (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 2 then; square = 1, 1/3, 1/5, ... for odd partials
		tabw_i		1/(indx*2-1), (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx*2-1, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 3 then; triangle = 1, -1/9, 1/25, -1/49, 1/81, ... for odd partials
ieven		=		indx % 2; 0 = even index, 1 = odd index
istr		=		(ieven == 0 ? -1/(indx*2-1)^2 : 1/(indx*2-1)^2); results in 1, -1/9, 1/25, ...
		tabw_i		istr, (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx*2-1, (indx-1)*3+1, iftemp; writes partial number
else; impulse = 1, 1, 1, ... for all partials
		tabw_i		1, (indx-1)*3, iftemp; writes strength of partial (always 1)
		tabw_i		indx, (indx-1)*3+1, iftemp; writes partial number
endif
		tabw_i		0, (indx-1)*3+2, iftemp; writes phase (always 0)
		loop_le	indx, 1, inparts, loop
iftout		ftgen		ifno, 0, itabsiz, 34, iftemp, inparts, 1; write table with GEN34 
		ftfree		iftemp, 0; remove iftemp
		xout		iftout
  endop

  opcode ShowLED_a, 0, Sakkk
;Shows an audio signal in an outvalue channel. You can choose to show the value in dB or in raw amplitudes.
;;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;kdb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)
Soutchan, asig, kdispfreq, kdb, kdbrange	xin
kdispval	max_k	asig, kdispfreq, 1
	if kdb != 0 then
kdb 		= 		dbfsamp(kdispval)
kval 		= 		(kdbrange + kdb) / kdbrange
	else
kval		=		kdispval
	endif
			outvalue	Soutchan, kval
  endop

  opcode ShowOver_a, 0, Sakk
;Shows if the incoming audio signal was more than 1 and stays there for some time
;;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"
Soutchan, asig, kdispfreq, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
kmax		max_k		asig, kdispfreq, 1
	if kon == 0 && kmax > 1 then
kstart		=		ktim
kend		=		kstart + khold
		outvalue	Soutchan, kmax
kon		=		1
	endif
	if kon == 1 && ktim > kend then
		outvalue	Soutchan, 0
kon		=		0
	endif
  endop


instr 1;;RECEIVE GUI INPUT AN GENERATE WAVEFORMS
iftlen		=		4097; length of a function table with the shape of a waveform
;GENERATE SINE WAVEFORM
giftsin	ftgen		1, 0, iftlen, 10, 1
;RECEIVE NUMBER OF PARTIALS FOR SAW, SQUARE, TRIANGLE AN IMPULSE
knp_saw	invalue	"np_saw"
knp_squ	invalue	"np_squ"
knp_tri	invalue	"np_tri"
knp_imp	invalue	"np_imp"
;LOOK IF AN OF THIS VALUES HAS CHANGED
knewnp		changed	knp_saw, knp_squ, knp_tri, knp_imp
;IF YES GO AGAIN TO THE "newnp" BLOCK AND RECALCULATE THE WAVEFORMS
 if knewnp == 1 then
		reinit		newnp
 endif
;CALCULATION OF SAW, SQUARE, TRIANGLE AN IMPULSE ACCORDING TO THE DESIRED NUMBER OF PARTIALS
newnp:
inp_saw	=		i(knp_saw)
inp_squ	=		i(knp_squ)
inp_tri	=		i(knp_tri)
inp_imp	=		i(knp_imp)
giftsaw	SinesToSSTI	1, inp_saw, iftlen, 2
giftsqu	SinesToSSTI	2, inp_squ, iftlen, 3
gifttri	SinesToSSTI	3, inp_tri, iftlen, 4
giftimp	SinesToSSTI	4, inp_imp, iftlen, 5
		rireturn
;RECEIVE RELATIVE AMPLITUDES, AND MASTER VOLUME FROM THE GUI
gkamp_sin	invalue	"amp_sin"
gkamp_saw	invalue	"amp_saw"
gkamp_squ	invalue	"amp_squ"
gkamp_tri	invalue	"amp_tri"
gkamp_imp	invalue	"amp_imp"
gk_vol		invalue	"vol"; master volume
;SMOOTH AMPLTUDE CHANGES
gkamp_sin	port		gkamp_sin, .1
gkamp_saw	port		gkamp_saw, .1
gkamp_squ	port		gkamp_squ, .1
gkamp_tri	port		gkamp_tri, .1
gkamp_imp	port		gkamp_imp, .1
gk_vol		port		gk_vol, .1
;LET THE GRAPH WIDGET SHOW THE WAVEFORMS (and be happy if it happens)
		outvalue	"sine", -1
		outvalue	"saw", -2
		outvalue	"square", -3
		outvalue	"triangle", -4
		outvalue	"impulse", -5
endin

instr 2;;PLAY ONE NOTE
;GENERATE THE FIVE AUDIO SIGNALS
asin		oscil3		p5, p4, giftsin
asaw		oscil3		p5, p4, giftsaw
asqu		oscil3		p5, p4, giftsqu
atri		oscil3		p5, p4, gifttri
aimp		oscil3		p5, p4, giftimp
;MIX THEM, APPLY A SIMPLE ENVELOPE AND SEND THE MIX OUT
amix		sum		asin*gkamp_sin, asaw*gkamp_saw, asqu*gkamp_squ, atri*gkamp_tri, aimp*gkamp_imp
kenv		linsegr	0, .1, 1, p3-.1, 1, .1, 0; simple envelope
aenv		=		amix*kenv*gk_vol; apply alo master volume
		out		aenv
endin

instr 3; SHOW THE SUM OF ALL SINGLE NOTES TO SEE CLIPPING
aout		monitor
kTrigDisp	metro		10
		ShowLED_a	"out", aout, kTrigDisp, 1, 50
		ShowOver_a	"outover", aout/0dbfs, kTrigDisp, 1
endin

</CsInstruments>
<CsScore>
i 1 0 36000; play 10 hours
i 3 0 36000
e
</CsScore>
</CsoundSynthesizer>

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 188 132 1134 607
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {34, 265} {1028, 44} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {73, 116} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Sine
ioGraph {35, 161} {178, 96} table 0.000000 1.000000 sine
ioText {290, 116} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Saw
ioGraph {252, 161} {178, 96} table 0.000000 1.000000 saw
ioText {509, 115} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Square
ioGraph {471, 160} {178, 96} table 0.000000 1.000000 square
ioText {713, 115} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Triangle
ioGraph {675, 160} {178, 96} table 0.000000 1.000000 triangle
ioText {922, 114} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Impulse
ioGraph {884, 159} {178, 96} table 0.000000 1.000000 impulse
ioText {314, 272} {59, 28} editnum 4.000000 1.000000 "np_saw" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioText {533, 272} {59, 28} editnum 4.000000 1.000000 "np_squ" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioText {740, 272} {59, 28} editnum 4.000000 1.000000 "np_tri" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioText {949, 272} {59, 28} editnum 4.000000 1.000000 "np_imp" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioGraph {26, 407} {766, 165} scope 1.000000 -1.000000 
ioMeter {824, 405} {31, 166} {0, 59904, 0} "amp_sin" 0.337349 "hor21" 0.322581 fill 1 0 mouse
ioMeter {855, 405} {31, 166} {0, 59904, 0} "amp_saw" 0.283133 "hor21" 0.322581 fill 1 0 mouse
ioMeter {886, 405} {31, 166} {0, 59904, 0} "amp_squ" 0.186747 "hor21" 0.322581 fill 1 0 mouse
ioMeter {917, 405} {31, 166} {0, 59904, 0} "amp_tri" 0.216867 "hor21" 0.322581 fill 1 0 mouse
ioMeter {947, 405} {31, 166} {0, 59904, 0} "amp_imp" 0.295181 "hor21" 0.322581 fill 1 0 mouse
ioText {824, 345} {148, 54} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Relative Strength of the Five Waveforms
ioSlider {1008, 406} {22, 165} 0.000000 2.000000 0.836364 vol
ioMeter {1039, 424} {18, 147} {0, 59904, 0} "out" 0.000000 "hor8" 0.592593 fill 1 0 mouse
ioMeter {1039, 406} {18, 23} {50176, 3584, 3072} "outover" 0.000000 "in1over_pre" 0.000000 fill 1 0 mouse
ioText {999, 346} {64, 55} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MasterÂ¬Volume
ioText {63, 368} {214, 33} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Scope Resulting Waveform
ioButton {525, 363} {91, 27} value 1.000000 "_Play" "START" "/" i1 0 10
ioButton {639, 363} {91, 27} value 1.000000 "_Stop" "STOP" "/" i1 0 10
ioText {35, 273} {176, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Number of Harmonics:
ioText {91, 59} {903, 53} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Standard Waveforms are built here by superposition of harmonics. The higher the number of harmonics, the sharper the shape. You can change here in realtime the number of harmonics and the relative strength of the five shapes in the resulting mix.
ioText {190, 11} {712, 43} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Waveform Mix
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="537" y="272" width="596" height="322">i 1 0 3 
 
 
 
 
 
 
 
 </EventPanel>