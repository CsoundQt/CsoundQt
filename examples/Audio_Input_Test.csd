<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

/*****INPUT TEST*****/
;example for qutecsound
;written by joachim heintz
;jan 2009

sr = 44100
ksmps = 128
nchnls = 2 ; change here if your input device has more channels
0dbfs = 1

	opcode	ShowLED_a, 0, Sakik
;Shows an audio signal in an outvalue channel.
;You can choose to show the value in dB or in raw amplitudes.
;
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;idb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;idbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)

Soutchan, asig, ktrig, idb, kdbrange	xin
kdispval	max_k	asig, ktrig, 1
	if idb != 0 then
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
;Shows if the incoming audio signal was more than 1 and stays there for some time
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"

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

kdbrange invalue "dbrange"  ;dB range for the meters
kpeakhold invalue "peakhold"  ;Duration of clip indicator hold in seconds

;input channels
a1		inch		1
a2		inch		2
a3		inch		3
a4		inch		4
a5		inch		5
a6		inch		6
a7		inch		7
a8		inch		8
a9		inch		9
a10		inch		10
a11		inch		11
a12		inch		12
a13		inch		13
a14		inch		14
a15		inch		15
a16		inch		16
a17		inch		17
a18		inch		18
a19		inch		19
a20		inch		20
a21		inch		21
a22		inch		22
a23		inch		23
a24		inch		24
;GUI
kTrigDisp	metro		10; refresh rate of display
		ShowLED_a	"in1", a1, kTrigDisp, 1, kdbrange
		ShowLED_a	"in2", a2, kTrigDisp, 1, kdbrange
		ShowLED_a	"in3", a3, kTrigDisp, 1, kdbrange
		ShowLED_a	"in4", a4, kTrigDisp, 1, kdbrange
		ShowLED_a	"in5", a5, kTrigDisp, 1, kdbrange
		ShowLED_a	"in6", a6, kTrigDisp, 1, kdbrange
		ShowLED_a	"in7", a7, kTrigDisp, 1, kdbrange
		ShowLED_a	"in8", a8, kTrigDisp, 1, kdbrange
		ShowLED_a	"in9", a9, kTrigDisp, 1, kdbrange
		ShowLED_a	"in10", a10, kTrigDisp, 1, kdbrange
		ShowLED_a	"in11", a11, kTrigDisp, 1, kdbrange
		ShowLED_a	"in12", a12, kTrigDisp, 1, kdbrange
		ShowLED_a	"in13", a13, kTrigDisp, 1, kdbrange
		ShowLED_a	"in14", a14, kTrigDisp, 1, kdbrange
		ShowLED_a	"in15", a15, kTrigDisp, 1, kdbrange
		ShowLED_a	"in16", a16, kTrigDisp, 1, kdbrange
		ShowLED_a	"in17", a17, kTrigDisp, 1, kdbrange
		ShowLED_a	"in18", a18, kTrigDisp, 1, kdbrange
		ShowLED_a	"in19", a19, kTrigDisp, 1, kdbrange
		ShowLED_a	"in20", a20, kTrigDisp, 1, kdbrange
		ShowLED_a	"in21", a21, kTrigDisp, 1, kdbrange
		ShowLED_a	"in22", a22, kTrigDisp, 1, kdbrange
		ShowLED_a	"in23", a23, kTrigDisp, 1, kdbrange
		ShowLED_a	"in24", a24, kTrigDisp, 1, kdbrange
		ShowOver_a	"in1over", a1, kTrigDisp, kpeakhold
		ShowOver_a	"in2over", a2, kTrigDisp, kpeakhold
		ShowOver_a	"in3over", a3, kTrigDisp, kpeakhold
		ShowOver_a	"in4over", a4, kTrigDisp, kpeakhold
		ShowOver_a	"in5over", a5, kTrigDisp, kpeakhold
		ShowOver_a	"in6over", a6, kTrigDisp, kpeakhold
		ShowOver_a	"in7over", a7, kTrigDisp, kpeakhold
		ShowOver_a	"in8over", a8, kTrigDisp, kpeakhold
		ShowOver_a	"in9over", a9, kTrigDisp, kpeakhold
		ShowOver_a	"in10over", a10, kTrigDisp, kpeakhold
		ShowOver_a	"in11over", a11, kTrigDisp, kpeakhold
		ShowOver_a	"in12over", a12, kTrigDisp, kpeakhold
		ShowOver_a	"in13over", a13, kTrigDisp, kpeakhold
		ShowOver_a	"in14over", a14, kTrigDisp, kpeakhold
		ShowOver_a	"in15over", a15, kTrigDisp, kpeakhold
		ShowOver_a	"in16over", a16, kTrigDisp, kpeakhold
		ShowOver_a	"in17over", a17, kTrigDisp, kpeakhold
		ShowOver_a	"in18over", a18, kTrigDisp, kpeakhold
		ShowOver_a	"in19over", a19, kTrigDisp, kpeakhold
		ShowOver_a	"in20over", a20, kTrigDisp, kpeakhold
		ShowOver_a	"in21over", a21, kTrigDisp, kpeakhold
		ShowOver_a	"in22over", a22, kTrigDisp, kpeakhold
		ShowOver_a	"in23over", a23, kTrigDisp, kpeakhold
		ShowOver_a	"in24over", a24, kTrigDisp, kpeakhold
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
WindowBounds: 354 253 588 526
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {15, 304} {543, 58} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This file tests whether your inputs are working. Please adjust it at the following places to your needs:
ioText {147, -1} {299, 44} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder INPUT TESTER
ioText {14, 362} {546, 56} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1. Change the nchnls (number of channels) parameter in the orchestra header to the value you wish and your output device can.
ioText {13, 419} {546, 59} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2. Make sure you are using the appropriate device by selecting it on the Configure dialog
ioMeter {13, 84} {20, 169} {0, 59904, 0} "in1" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {13, 70} {20, 20} {50176, 3584, 3072} "in1over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {35, 84} {20, 169} {0, 59904, 0} "in2" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {35, 70} {20, 20} {50176, 3584, 3072} "in2over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {57, 84} {20, 169} {0, 59904, 0} "in3" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {57, 70} {20, 20} {50176, 3584, 3072} "in3over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {79, 84} {20, 169} {0, 59904, 0} "in4" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {79, 70} {20, 20} {50176, 3584, 3072} "in4over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {101, 84} {20, 169} {0, 59904, 0} "in5" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {101, 70} {20, 20} {50176, 3584, 3072} "in5over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {123, 84} {20, 169} {0, 59904, 0} "in6" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {123, 70} {20, 20} {50176, 3584, 3072} "in6over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {145, 84} {20, 169} {0, 59904, 0} "in7" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {145, 70} {20, 20} {50176, 3584, 3072} "in7over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {167, 84} {20, 169} {0, 59904, 0} "in8" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {167, 70} {20, 20} {50176, 3584, 3072} "in8over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {200, 85} {20, 169} {0, 59904, 0} "out9" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {200, 70} {20, 20} {50176, 3584, 3072} "out9over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {222, 85} {20, 169} {0, 59904, 0} "out10" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {222, 70} {20, 20} {50176, 3584, 3072} "out10over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {243, 86} {20, 169} {0, 59904, 0} "out11" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {243, 70} {20, 20} {50176, 3584, 3072} "out11over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {265, 86} {20, 169} {0, 59904, 0} "out12" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {265, 70} {20, 20} {50176, 3584, 3072} "out12over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {287, 86} {20, 169} {0, 59904, 0} "out13" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {287, 70} {20, 20} {50176, 3584, 3072} "out13over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {310, 86} {20, 169} {0, 59904, 0} "out14" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {310, 69} {20, 20} {50176, 3584, 3072} "out14over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {332, 86} {20, 169} {0, 59904, 0} "out15" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {332, 69} {20, 20} {50176, 3584, 3072} "out15over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {354, 86} {20, 169} {0, 59904, 0} "out16" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {354, 69} {20, 20} {50176, 3584, 3072} "out16over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {388, 86} {20, 169} {0, 59904, 0} "out17" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {388, 69} {20, 20} {50176, 3584, 3072} "out17over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {410, 87} {20, 169} {0, 59904, 0} "out18" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {410, 69} {20, 20} {50176, 3584, 3072} "out18over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {432, 87} {20, 169} {0, 59904, 0} "out19" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {432, 69} {20, 20} {50176, 3584, 3072} "out19over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {454, 87} {20, 169} {0, 59904, 0} "out20" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {454, 69} {20, 20} {50176, 3584, 3072} "out20over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {476, 87} {20, 169} {0, 59904, 0} "out21" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {476, 69} {20, 20} {50176, 3584, 3072} "out21over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {498, 87} {20, 169} {0, 59904, 0} "out22" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {498, 69} {20, 20} {50176, 3584, 3072} "out22over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {520, 87} {20, 169} {0, 59904, 0} "out23" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {520, 69} {20, 20} {50176, 3584, 3072} "out23over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioMeter {542, 87} {20, 169} {0, 59904, 0} "out24" 0.000000 "hor8" 0.450000 fill 1 0 mouse
ioMeter {542, 69} {20, 20} {50176, 3584, 3072} "out24over" 0.000000 "DelayMute" 0.600000 fill 1 0 mouse
ioText {10, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {32, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioText {54, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3
ioText {76, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4
ioText {98, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5
ioText {120, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6
ioText {142, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7
ioText {164, 47} {25, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8
ioText {196, 48} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9
ioText {218, 48} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10
ioText {240, 48} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11
ioText {262, 48} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12
ioText {284, 48} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 13
ioText {307, 47} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 14
ioText {329, 47} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 15
ioText {351, 47} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 16
ioText {383, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 17
ioText {405, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 18
ioText {427, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 19
ioText {449, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 20
ioText {471, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 21
ioText {493, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 22
ioText {515, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 23
ioText {537, 46} {29, 23} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 24
ioText {178, 272} {80, 25} editnum 36.000000 0.100000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 36.000000
ioText {93, 270} {131, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB Range
ioText {422, 272} {57, 25} editnum 3.000000 1.000000 "peakhold" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioText {300, 271} {131, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Peak Hold time
</MacGUI>

