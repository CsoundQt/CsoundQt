<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

/*****OUTPUT TEST*****/
/*example for qutecsound
written by joachim heintz
jan 2009*/

sr = 44100
ksmps = 128
nchnls = 2; change here if your output device has more channels
0dbfs = 1

giLen		=	1; duration of the test signal in one channel/speaker
giPaus		=	1; pause between two signals

	opcode	ShowLED_a, 0, Sakii
/*Shows an audio signal in an outvalue channel.
You can choose to show the value in dB or in raw amplitudes.
*/
/*Input:
Soutchan: string with the name of the outvalue channel
asig: audio signal which is to displayed
kdispfreq: refresh frequency (Hz)
idb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
idbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)
*/
Soutchan, asig, kdispfreq, idb, idbrange	xin
kdispval	max_k	asig, kdispfreq, 1
	if idb != 0 then
kdb 		= 		dbfsamp(kdispval)
kval 		= 		(idbrange + kdb) / idbrange
	else
kval		=		kdispval
	endif
			outvalue	Soutchan, kval
	endop

	opcode ShowOver_a, 0, Sakk
/*Shows if the incoming audio signal was more than 1 and stays there for some time*/
/*Input:
Soutchan: string with the name of the outvalue channel
asig: audio signal which is to displayed
kdispfreq: refresh frequency (Hz)
khold: time in seconds to "hold the red light"
*/
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


instr 1
;GUI input
kSel		invalue	"signal"; 0-4 for the selected signals2
kChnA		invalue	"chnA"; first channel to be tested
kChnZ		invalue	"chnZ"; last channel to be tested
kVol		invalue	"vol"; volume in dB
iNewChn	init		i(kChnA)
gkTrigDisp	metro		20; refresh rate for the LED's

;loop over the desired output channels
loop:		timout		0, giLen + giPaus, play
		reinit		loop
play:
iChn		=		iNewChn
instrmt	=		i(kSel) + 10
iVol		=		i(kVol)
		event_i	"i", instrmt, 0, giLen, iVol, iChn
iChnA		=		i(kChnA)
iChnZ		=		i(kChnZ)
iNewChn	=		(iChn >= iChnZ ? iChnA : iChn + 1)
endin

instr 10; white noise
ivol		=		ampdbfs(p4)
ichn		=		p5
Sout		sprintf	"out%d", ichn
Soutover	sprintf	"out%dover", ichn
ktim		timeinsts
		xtratim	.1
	if ktim > p3 then
anull		=		0
		ShowLED_a	Sout, anull, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, anull, gkTrigDisp, 0
	else
asig		rnd31		ivol, 0
		outch		ichn, asig
		ShowLED_a	Sout, asig, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, asig, gkTrigDisp, 0
	endif
endin

instr 11; pink noise
ivol		=		ampdbfs(p4)
ichn		=		p5
Sout		sprintf	"out%d", ichn
Soutover	sprintf	"out%dover", ichn
ktim		timeinsts
		xtratim	.1
	if ktim > p3 then
anull		=		0
		ShowLED_a	Sout, anull, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, anull, gkTrigDisp, 0
	else
asig		pinkish	ivol
		outch		ichn, asig
		ShowLED_a	Sout, asig, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, asig, gkTrigDisp, 0
	endif
endin

instr 12
ivol		=		ampdbfs(p4)
ichn		=		p5
Sout		sprintf	"out%d", ichn
Soutover	sprintf	"out%dover", ichn
ktim		timeinsts
		xtratim	.1
	if ktim > p3 then
anull		=		0
		ShowLED_a	Sout, anull, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, anull, gkTrigDisp, 0
	else
asig		oscils		ivol, 10000, 0
aenv		linen		asig, .005, p3, .005
		outch		ichn, aenv
		ShowLED_a	Sout, asig, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, asig, gkTrigDisp, 0
	endif
endin

instr 13
ivol		=		ampdbfs(p4)
ichn		=		p5
Sout		sprintf	"out%d", ichn
Soutover	sprintf	"out%dover", ichn
ktim		timeinsts
		xtratim	.1
	if ktim > p3 then
anull		=		0
		ShowLED_a	Sout, anull, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, anull, gkTrigDisp, 0
	else
asig		oscils		ivol, 1000, 0
aenv		linen		asig, .005, p3, .005
		outch		ichn, aenv
		ShowLED_a	Sout, asig, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, asig, gkTrigDisp, 0
	endif
endin

instr 14
ivol		=		ampdbfs(p4)
ichn		=		p5
Sout		sprintf	"out%d", ichn
Soutover	sprintf	"out%dover", ichn
ktim		timeinsts
		xtratim	.1
	if ktim > p3 then
anull		=		0
		ShowLED_a	Sout, anull, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, anull, gkTrigDisp, 0
	else
asig		oscils		ivol, 100, 0
aenv		linen		asig, .005, p3, .005
		outch		ichn, aenv
		ShowLED_a	Sout, asig, gkTrigDisp, 1, 36
		ShowOver_a	Soutover, asig, gkTrigDisp, 0
	endif
endin

</CsInstruments>
<CsScore>
i 1 0 3660
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 305 242 614 615
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {31, 76} {67, 48} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder first channel
ioText {108, 77} {67, 48} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder last channel
ioText {186, 76} {67, 48} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder volume (dB)
ioText {191, 123} {53, 29} scroll -20.000000 0.100000 "vol" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} background border -20.0
ioText {289, 94} {63, 28} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder signal
ioMenu {268, 124} {113, 28} 3 303 "white noise,pink noise,sine 10kHz,sine1kHz,sine 100Hz" signal
ioText {28, 315} {552, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This file tests if your outputs are working. Please adjust it at the following places to your needs:
ioText {145, 18} {299, 44} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder OUTPUT TESTER
ioText {49, 125} {31, 28} scroll 1.000000 1.000000 "chnA" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} background border 1
ioText {122, 126} {30, 27} scroll 2.000000 1.000000 "chnZ" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} background border 2
ioText {27, 367} {552, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1. Change the nchnls (number of channels) parameter in the orchestra header to the value you wish and your output device can.
ioText {28, 420} {553, 36} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2. Set the correct device in the Cofiguration Dialog.
ioText {27, 456} {551, 58} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3. Choose the parameters above: the first and the last channel you want to test the volume and the signal you want to use for testing.
ioText {27, 512} {553, 65} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4. If you wish you can also change the length of the test signal in one channel and the pause. You can find this values in the orchestra header (giLen and giPaus).
ioMeter {26, 214} {20, 80} {0, 59904, 0} "out1" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {26, 196} {20, 20} {50176, 3584, 3072} "out1over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {48, 214} {20, 80} {0, 59904, 0} "out2" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {48, 196} {20, 20} {50176, 3584, 3072} "out2over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {70, 214} {20, 80} {0, 59904, 0} "out3" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {70, 196} {20, 20} {50176, 3584, 3072} "out3over" 0.150000 "DelayMute" 0.450000 fill 1 0 mouse
ioMeter {92, 214} {20, 80} {0, 59904, 0} "out4" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {92, 196} {20, 20} {50176, 3584, 3072} "out4over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {114, 214} {20, 80} {0, 59904, 0} "out5" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {114, 196} {20, 20} {50176, 3584, 3072} "out5over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {136, 214} {20, 80} {0, 59904, 0} "out6" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {136, 196} {20, 20} {50176, 3584, 3072} "out6over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {158, 214} {20, 80} {0, 59904, 0} "out7" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {158, 196} {20, 20} {50176, 3584, 3072} "out7over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {180, 214} {20, 80} {0, 59904, 0} "out8" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {180, 196} {20, 20} {50176, 3584, 3072} "out8over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {214, 214} {20, 80} {0, 59904, 0} "out9" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {214, 196} {20, 20} {50176, 3584, 3072} "out9over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {236, 214} {20, 80} {0, 59904, 0} "out10" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {236, 196} {20, 20} {50176, 3584, 3072} "out10over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {258, 214} {20, 80} {0, 59904, 0} "out11" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {258, 196} {20, 20} {50176, 3584, 3072} "out11over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {281, 213} {20, 80} {0, 59904, 0} "out12" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {281, 195} {20, 20} {50176, 3584, 3072} "out12over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {303, 213} {20, 80} {0, 59904, 0} "out13" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {303, 195} {20, 20} {50176, 3584, 3072} "out13over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {325, 213} {20, 80} {0, 59904, 0} "out14" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {325, 195} {20, 20} {50176, 3584, 3072} "out14over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {347, 213} {20, 80} {0, 59904, 0} "out15" 0.062500 "hor8" 0.450000 fill 1 0 mouse
ioMeter {347, 195} {20, 20} {50176, 3584, 3072} "out15over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {369, 213} {20, 80} {0, 59904, 0} "out16" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {369, 195} {20, 20} {50176, 3584, 3072} "out16over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {403, 213} {20, 80} {0, 59904, 0} "out17" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {403, 195} {20, 20} {50176, 3584, 3072} "out17over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {425, 213} {20, 80} {0, 59904, 0} "out18" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {425, 195} {20, 20} {50176, 3584, 3072} "out18over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {447, 213} {20, 80} {0, 59904, 0} "out19" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {447, 195} {20, 20} {50176, 3584, 3072} "out19over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {469, 213} {20, 80} {0, 59904, 0} "out20" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {469, 195} {20, 20} {50176, 3584, 3072} "out20over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {491, 213} {20, 80} {0, 59904, 0} "out21" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {491, 195} {20, 20} {50176, 3584, 3072} "out21over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {513, 213} {20, 80} {0, 59904, 0} "out22" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {513, 195} {20, 20} {50176, 3584, 3072} "out22over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {535, 213} {20, 80} {0, 59904, 0} "out23" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {535, 195} {20, 20} {50176, 3584, 3072} "out23over" 0.000000 "DelayMute" 0.350000 fill 1 0 mouse
ioMeter {557, 213} {20, 80} {0, 59904, 0} "out24" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {557, 195} {20, 20} {50176, 3584, 3072} "out24over" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioText {26, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {48, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioText {70, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3
ioText {92, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4
ioText {114, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5
ioText {136, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6
ioText {158, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7
ioText {180, 168} {20, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8
ioText {209, 169} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9
ioText {231, 169} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10
ioText {253, 169} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11
ioText {275, 169} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12
ioText {298, 168} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 13
ioText {320, 168} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 14
ioText {342, 168} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 15
ioText {364, 168} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 16
ioText {399, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 17
ioText {421, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 18
ioText {443, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 19
ioText {465, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 20
ioText {487, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 21
ioText {509, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 22
ioText {531, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 23
ioText {553, 167} {28, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 24
</MacGUI>

