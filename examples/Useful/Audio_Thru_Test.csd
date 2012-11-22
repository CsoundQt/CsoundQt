<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

/*****SIMPLE LIVE INPUT AND OUTPUT TEST (STEREO)*****/

/*example for CsoundQt
written by joachim heintz
jan 2009*/

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1; do not change this

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
ain1, ain2		ins		;stereo input
kTrigDisp		metro		10; frequency for refreshing the display

;On/Off state and envelope; show if mutet
kOnOff1		invalue	"OnOff1"
kOnOff2		invalue	"OnOff2"
kenv1			port		kOnOff1, .001; no clicks when pressing on or off
kenv2			port		kOnOff2, .001
kmute1			=		(kOnOff1 == 0 ? 1 : 0)
kmute2			=		(kOnOff2 == 0 ? 1 : 0)
			outvalue	"ShowOnOff1", kmute1
			outvalue	"ShowOnOff2", kmute2

;show pre fader input
			ShowLED_a	"in1_pre", ain1, kTrigDisp, 1, 36
			ShowLED_a	"in2_pre", ain2, kTrigDisp, 1, 36
			ShowOver_a	"in1over_pre", ain1, kTrigDisp, 2
			ShowOver_a	"in2over_pre", ain2, kTrigDisp, 2

;input gain
kInputGain1		invalue	"gain_in1"
kInputGain2		invalue	"gain_in2"
SInputGain1		sprintfk	"%.1f", kInputGain1
SInputGain2		sprintfk	"%.1f", kInputGain2
			outvalue	"gain_in1_disp", SInputGain1
			outvalue	"gain_in2_disp", SInputGain2
ain1gain		=		ain1 * ampdbfs(kInputGain1)
ain2gain		=		ain2 * ampdbfs(kInputGain2)

;show post fader input
			ShowLED_a	"in1_post", ain1gain, kTrigDisp, 1, 36
			ShowLED_a	"in2_post", ain2gain, kTrigDisp, 1, 36
			ShowOver_a	"in1over_post", ain1gain, kTrigDisp, 2
			ShowOver_a	"in2over_post", ain2gain, kTrigDisp, 2

;output gain
kOutputGain1		invalue	"gain_out1"
kOutputGain2		invalue	"gain_out2"
SOutputGain1		sprintfk	"%.1f", kOutputGain1
SOutputGain2		sprintfk	"%.1f", kOutputGain2
			outvalue	"gain_out1_disp", SOutputGain1
			outvalue	"gain_out2_disp", SOutputGain2
aout1gain		=		ain1gain * ampdbfs(kOutputGain1) * kenv1
aout2gain		=		ain2gain * ampdbfs(kOutputGain2) * kenv2

;show output
			ShowLED_a	"out1_post", aout1gain, kTrigDisp, 1, 36
			ShowLED_a	"out2_post", aout2gain, kTrigDisp, 1, 36
			ShowOver_a	"out1over_post", aout1gain, kTrigDisp, 2
			ShowOver_a	"out2over_post", aout2gain, kTrigDisp, 2

			outs		aout1gain, aout2gain

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
WindowBounds: 344 245 582 651
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {253, 117} {306, 77} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This example shows how you can display your inputs and outputs and how you can control the level.
ioText {7, 78} {227, 284} label 0.000000 0.00100 "" center "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border Input
ioText {9, 373} {548, 233} label 0.000000 0.00100 "" center "DejaVu Sans" 20 {0, 0, 0} {65280, 65280, 65280} nobackground border Output
ioText {9, 16} {552, 47} label 0.000000 0.00100 "" center "DejaVu Sans" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder AUDIO THRU TEST
ioText {251, 77} {308, 33} label 0.000000 0.00100 "" center "DejaVu Sans" 16 {0, 0, 0} {65280, 44032, 14336} background noborder (Be careful - feedback is likely!)
ioText {251, 185} {308, 68} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This example connects the inputs of your audio device to its outputs
ioText {250, 231} {307, 143} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder For Live-Input it's very important to adjust the software (-b) and the hardware (-B) buffer size in conjunction with the number of audio samples per control period (ksmps). For this see the page Optimizing Audio i/O Latency in the Csound Manual.
ioMeter {22, 126} {120, 22} {0, 59904, 0} "in1_pre" 0.000000 "in1_pre" 0.000000 fill 1 0 mouse
ioMeter {140, 126} {21, 21} {50176, 3584, 3072} "in1over_pre" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {21, 154} {121, 22} {0, 59904, 0} "in1_pre" 0.000000 "in2_pre" 0.000000 fill 1 0 mouse
ioMeter {139, 154} {21, 21} {50176, 3584, 3072} "in1over_pre" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioText {162, 126} {58, 51} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Pre Fader
ioText {159, 204} {52, 68} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Input Gain (dB)
ioMeter {21, 284} {118, 22} {0, 59904, 0} "in1_post" 0.000000 "in1_post" 0.000000 fill 1 0 mouse
ioMeter {137, 284} {21, 21} {50176, 3584, 3072} "in1over_post" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {21, 315} {119, 21} {0, 59904, 0} "in2_post" 0.000000 "in2_post" 0.000000 fill 1 0 mouse
ioMeter {137, 315} {21, 21} {50176, 3584, 3072} "in2over_post" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioText {161, 287} {58, 51} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Post Fader
ioCheckbox {54, 544} {20, 20} off OnOff1
ioText {107, 552} {87, 30} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder On/Off
ioCheckbox {81, 544} {20, 20} off OnOff2
ioMeter {54, 569} {20, 19} {50176, 3584, 3072} "in1over_pre" 0.000000 "ShowOnOff1" 1.000000 fill 1 0 mouse
ioMeter {80, 569} {20, 19} {50176, 3584, 3072} "in1over_pre" 0.000000 "ShowOnOff2" 1.000000 fill 1 0 mouse
ioKnob {49, 189} {45, 51} -18.000000 18.000000 0.010000 -5.272727 gain_in1
ioKnob {93, 189} {45, 51} -18.000000 18.000000 0.010000 -5.272727 gain_in2
ioText {45, 238} {49, 30} display 0.000000 0.00100 "gain_in1_disp" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border -5.3
ioText {93, 238} {50, 30} display 0.000000 0.00100 "gain_in2_disp" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border -5.3
ioText {111, 421} {68, 69} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output Gain (dB)
ioMeter {237, 468} {250, 19} {0, 59904, 0} "out1_post" 0.000000 "out1_post" 0.000000 fill 1 0 mouse
ioMeter {486, 468} {21, 21} {50176, 3584, 3072} "out1over_post" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioMeter {237, 495} {250, 19} {0, 59904, 0} "out2_post" 0.000000 "out2_post" 0.000000 fill 1 0 mouse
ioMeter {486, 495} {21, 21} {50176, 3584, 3072} "out2over_post" 0.000000 "DelayMute" 0.000000 fill 1 0 mouse
ioText {22, 504} {49, 30} display 0.000000 0.00100 "gain_out1_disp" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border -21.4
ioText {72, 503} {50, 30} display 0.000000 0.00100 "gain_out2_disp" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border -21.4
ioSlider {47, 380} {24, 122} -48.000000 12.000000 -21.934426 gain_out1
ioSlider {81, 380} {24, 122} -48.000000 12.000000 -21.934426 gain_out2
</MacGUI>

