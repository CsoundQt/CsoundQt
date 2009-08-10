<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****Universal Convolution*****/
;example for qutecsound
;written by joachim heintz
;jul 2009
;please send bug reports and suggestions
;to jh at joachimheintz.de

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

#define LOG2 #0,301029996#

 opcode nextpowof2, i, i
ilen    xin ;given length as input
iout = 1
loop:
iout = iout * 2
if iout < ilen igoto loop
xout iout
 endop

  opcode TakeAll2, aa, Skii
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aL		diskin2	Sfil, kspeed, iskip, iloop
aR		=		aL
else
aL, aR		diskin2	Sfil, kspeed, iskip, iloop
endif
		xout		aL, aR
  endop

  opcode	ShowLED_k, 0, Skkik
Soutchan, kdispval, ktrig, idb, kdbrange	xin
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

  opcode ShowOver_k, 0, Skkk
Soutchan, kmax, ktrig, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
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
;;values for file 1 (playback)
Sfile1		invalue	"_Browse1"; soundfile which is played back
kspeed		invalue	"speed"; playback speed (1 = original speed)
kskip		invalue	"skip"; skiptime in seconds
kloop		invalue	"loop"; 0 = no loop, 1 = loop
;;values and calculations for file 2 (convolution)
Sfile2		invalue	"_Browse2"; soundfile which is used as impulse response
kstartabs	invalue	"startabs"; 0-1
kirlen		invalue	"irlen"; length of selected impulse response in secs (0 = take the whole length)
kpartsiz	invalue	"partsiz"; partitionsize of convolution
kplen		=		(kpartsiz == 0 ? 256 : (kpartsiz == 1 ? 512 : (kpartsiz == 2 ? 1024 : (kpartsiz == 3 ? 2048 : 4096))))
iconvsr	filesr		Sfile2; sample rate of convolution file
iconvlen	filelen	Sfile2; length of convolution file in seconds ...
iconvlensmps	=		iconvlen * iconvsr; ... and in samples
kselstart	=		kstartabs * iconvlen; startpoint of selection for convolution in seconds ...
		outvalue	"start", kselstart
kskpsmps	=		kselstart * iconvsr; ... and in samples
kirlensmps	=		(kirlen == 0? (iconvlen - kselstart) * iconvsr : kirlen * iconvsr); length of selection in samples

;;creating two ftables (left and right channel) for ftconv
ichnlsfil2	filenchnls	Sfile2
if ichnlsfil2 == 2 then
iftlen		nextpowof2	iconvlensmps / 2
giftL		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 1
giftR		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 2
else; if mono impulse response, create two identical tables
iftlen		nextpowof2	iconvlensmps
giftL		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 1
giftR		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 1
endif

;;creating the playback audio stream as global audio
gaL, gaR	TakeAll2	Sfile1, kspeed, i(kskip), i(kloop)

;;calling a subinstrument with a release time (to avoid clicks) for performing the convolution 
ktrig		changed	kplen, kskpsmps, kirlensmps; if there are new values for the selection in file 2:
if ktrig == 1 then
		event		"i", -10, 0, 0; stop previous instance of instr 10
		event		"i", 10, 0, -p3, kplen, kskpsmps, kirlensmps; call new instance with new values
endif

;;show output
gkshowL	init		0
gkshowR	init		0
kTrigDisp	metro		10
		ShowLED_k	"outL", gkshowL, kTrigDisp, 0, 50
		ShowLED_k	"outR", gkshowR, kTrigDisp, 0, 50
		ShowOver_k	"outLover", gkshowL, kTrigDisp, 2
		ShowOver_k	"outRover", gkshowR, kTrigDisp, 2
endin

instr 10
;;input values
iplen		=		p4; partitionsize of convolution
iskpsmps	=		p5; how many samples to skip
iirlen		=		p6; length of selection for impulse response in samples
kwdmix		invalue	"wdmix"; 0 = dry (just playback stream), 1 = wet (just convoluted signal)
kgain		invalue	"gain"
;;performing convolution
acvL		ftconv  	gaL, giftL, iplen, iskpsmps, iirlen
acvR		ftconv  	gaR, giftR, iplen, iskpsmps, iirlen
;;mixing dry and wet parts
awetL		=		acvL * kwdmix
awetR		=		acvR * kwdmix
adryL		=		gaL * (1 - kwdmix)
adryR		=		gaR * (1 - kwdmix)
aL		=		(awetL + adryL) * kgain
aR		=		(awetR + adryR) * kgain
;;declicking envelope and output
aenv		linsegr	0, .01, 1, p3-.01, 1, .01, 0
aoutL		=		aL * aenv
aoutR		=		aR * aenv
		outs		aoutL, aoutR
gaL		=		0; zero global audio
gaR		=		0
;;send the peak information to the display
kTrigDisp	metro		10
gkshowL	max_k		aoutL, kTrigDisp, 1
gkshowR	max_k		aoutR, kTrigDisp, 1
endin

</CsInstruments>
<CsScore>
i 1 0 9999
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 637 25 534 741
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {68, 6} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder UNIVERSAL CONVOLUTION
ioText {23, 91} {472, 141} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {23, 468} {474, 209} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {23, 237} {474, 223} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {39, 134} {346, 25} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {389, 133} {100, 30} value 1.000000 "_Browse1" "Open File 1" "/" 
ioText {150, 96} {192, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Soundfile 1 for Playback
ioText {55, 162} {63, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder speed
ioText {172, 199} {80, 25} editnum 0.000000 0.001000 "skip" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioText {166, 163} {85, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder skiptime
ioText {295, 165} {85, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder loop
ioMenu {312, 199} {56, 22} 1 303 "no,yes" loop
ioText {49, 197} {80, 25} editnum 1.000000 0.001000 "speed" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {39, 280} {348, 25} edit 0.000000 0.00100 "_Browse2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {393, 279} {100, 30} value 1.000000 "_Browse2" "Open File 2" "/" 
ioText {147, 242} {192, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Soundfile 2 for Convolution
ioText {25, 331} {280, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Selection in Soundfile 2 for Convolution
ioText {78, 372} {63, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder start
ioText {250, 370} {63, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder length
ioText {344, 333} {105, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Partitionsize
ioMenu {357, 370} {84, 24} 2 303 "256,512,1024,2048,4096" partsiz
ioSlider {34, 397} {156, 29} 0.000000 1.000000 0.500000 startabs
ioSlider {204, 396} {156, 29} 0.000000 1.000000 0.147436 irlen
ioText {84, 430} {62, 34} display 0.000000 0.00100 "start" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.2507
ioText {229, 429} {55, 28} display 0.000000 0.00100 "irlen" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.1474
ioText {284, 429} {212, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0 = take the whole file length
ioSlider {113, 521} {282, 29} 0.000000 1.000000 0.748227 wdmix
ioText {191, 483} {130, 30} label 0.000000 0.00100 "" center "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet-Dry Mix
ioText {73, 521} {34, 27} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {402, 522} {34, 27} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {308, 570} {130, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output Gain
ioSlider {102, 566} {201, 34} 0.100000 2.000000 0.544279 gain
ioText {36, 566} {62, 34} display 0.000000 0.00100 "gain" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5537
ioText {325, 481} {62, 34} display 0.000000 0.00100 "wdmix" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.7553
ioMeter {124, 614} {250, 19} {0, 59904, 0} "out1_post" 0.578947 "outL" 0.658561 fill 1 0 mouse
ioMeter {371, 614} {21, 19} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {124, 641} {250, 19} {0, 59904, 0} "out2_post" 1.000000 "outR" 0.336022 fill 1 0 mouse
ioMeter {371, 641} {21, 19} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {23, 49} {472, 47} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder You can convolve here any file with any other (or usually a selection of it). 
</MacGUI>

