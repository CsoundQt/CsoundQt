<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

/*****Playing a soundfile 2b: Play from a buffer with more features*****/
;written by joachim heintz and andres cabrera
;mar 2009

	opcode 	PlayBuf, ak, iiikiki
/*Plays a buffer (function table) with a known length,
and gives the time in the range 0-1.*/
/*input:
ifn: name or nummer of the function table
ifnlen: its length in samples resp. indices
ifnsr: its samplerate
kspeed: speed of reading (1 = normal)
iskip: skiptime in seconds
kvol: volume multiplier (1 = normal)
icnvrt: 1 = samplerate conversion if the sr of the soundfile is not the same as in the orchestra; 0 = no conversion
*/
/*output:
asig: audio signal reading the table
ktimout: time in the table in seconds
*/
	ifn, ifnlen, ifnsr, kspeed, iskip, kvol, icnvrt	 xin
  if ifnsr != sr then
			setksmps	1; if sr is different, set local ksmps to 1 for best quality
  endif
  if icnvrt == 1 then
irel			=		ifnlen / ifnsr
  else
irel			=		ifnlen / sr
  endif
kcps			=		kspeed / irel
iphs			=		iskip / irel
asig			poscil3 	kvol, kcps, ifn, iphs
ktim			phasor		kcps, iphs
ktimout		=		ktim * irel
  	xout	asig, ktimout
	endop

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



instr 1; always on
gkpaus		init		0; status of the pause button
gkspeed	init		1; speed for reading the buffer
gkconvertsr	invalue	"convertsr"
kdb		invalue	"db"; gain value in dB
gkskip		invalue	"skip"; skiptime in sec
gkloop		invalue	"loop"; value 1 if checked
   ;volume display
gkmult		=		ampdbfs(kdb)
Sdb_disp	sprintfk	"%+.2f dB", kdb
		outvalue	"db_disp", Sdb_disp
endin

instr 2  ;play
Sfile		invalue	"_Browse1"; get the name (look at the example  in Examples->Reserved Channels)
gilen		filelen	Sfile; duration of the file
gichn		filenchnls	Sfile; is the file mono or stereo
gifilesr	filesr		Sfile

   ;reading the data in the buffers (function tables)
giL		ftgen		0, 0, 0, -1, Sfile, 0, 0, 1
gilenbuf	=		ftlen(giL)
  if gichn == 2 then		
giR		ftgen		0, 0, 0, -1, Sfile, 0, 0, 2
  endif

   ;send a message if the sr of the file doesn't match the sr of the orchestra
  if gifilesr != sr then
    if i(gkconvertsr) == 1 then
Swarn		sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will be converted by changing speed of reading.", gifilesr, sr
		outvalue	"message", Swarn
    else
Swarn		sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will not be converted, so you will have changes in tempo and pitch.", gifilesr, sr
		outvalue	"message", Swarn
    endif
  else
Smess		sprintf	"Length = %.3f\nSamplerate = %d\nChannels = %d", gilen, gifilesr, gichn
		outvalue	"message", Smess 
 endif


  if gkpaus == 1 then	;if pause
		event		"i", 4, 0, .1; call the pause instr
  else
		event		"i", 10, 0, 1
  endif
		turnoff
endin

instr 3; stop
turnoff2 1, 0,0
endin

instr 4; pause/resume
  if gkpaus == 0 then
gkspeed	=		0
gkpaus		=		1
  else
gkspeed	=		1
gkpaus		=		0
  endif
		turnoff
endin


instr 10; playing
iloop		=		i(gkloop)
iskip		=		i(gkskip)
icnvrt		=		i(gkconvertsr)

kdbrange	invalue	"dbrange"  ;dB range for the meters
kpeakhold	invalue	"peakhold"  ;Duration of clip indicator hold in seconds

idur		=		(iloop == 1 ? 9999 : gilen - iskip)
p3		=		idur
  if gichn == 1 then
aL, ktimout	PlayBuf		giL, gilenbuf, gifilesr, gkspeed, iskip, gkmult, icnvrt
aR		=			aL		
  else
aL, ktimout	PlayBuf		giL, gilenbuf, gifilesr, gkspeed, iskip, gkmult, icnvrt
aR, knix	PlayBuf		giR, gilenbuf, gifilesr, gkspeed, iskip, gkmult, icnvrt
  endif
   ;show output
kTrigDisp	metro		10
		ShowLED_a	"outL", aL, kTrigDisp, 1, kdbrange
		ShowLED_a	"outR", aR, kTrigDisp, 1, kdbrange
		ShowOver_a	"outLover", aL, kTrigDisp, kpeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, kpeakhold
   ;read and show time
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		int(ktimout % 60)
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms

		outs		aL, aR
endin


</CsInstruments>
<CsScore>
i 1 0 36000; don't listen to music longer than 10 hours
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 615 380 498 584
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {30840, 35466, 43690}
ioText {15, 95} {345, 24} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {362, 92} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioSlider {110, 235} {160, 31} -18.000000 18.000000 0.000000 db
ioText {248, 235} {98, 31} display 0.000000 0.00100 "db_disp" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder +0.00 dB
ioButton {13, 138} {78, 26} event 1.000000 "" "Play" "/" i 2 0 .1
ioButton {221, 138} {80, 25} value 1.000000 "_Stop" "Stop" "/" i 3 0 .1
ioText {13, 203} {87, 25} editnum 0.000000 0.001000 "skip" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioButton {115, 137} {80, 25} event 1.000000 "" "Pause" "/" i 4 0 .1
ioCheckbox {141, 200} {20, 20} off loop
ioText {331, 296} {37, 30} display 0.000000 0.00100 "min" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {378, 296} {35, 31} display 0.000000 0.00100 "sec" right "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {366, 296} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {11, 172} {88, 30} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder skiptime
ioText {120, 174} {59, 30} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder loop
ioText {12, 234} {88, 30} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder volume
ioText {9, 399} {464, 131} display 0.000000 0.00100 "message" center "DejaVu Sans" 12 {0, 0, 0} {50432, 50432, 50432} background border 
ioText {11, 364} {462, 30} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Messages
ioMeter {10, 273} {250, 19} {0, 59904, 0} "out1_post" 0.526316 "outL" 0.000000 fill 1 0 mouse
ioMeter {258, 273} {21, 19} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {10, 300} {250, 19} {0, 59904, 0} "out2_post" 0.526316 "outR" 0.000000 fill 1 0 mouse
ioMeter {258, 300} {21, 19} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {96, 330} {80, 25} editnum 48.000000 0.100000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 48.000000
ioText {11, 329} {131, 27} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB Range
ioText {340, 330} {57, 25} editnum 3.000000 1.000000 "peakhold" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioText {218, 329} {131, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Peak Hold time
ioCheckbox {216, 201} {20, 20} off convertsr
ioText {192, 174} {62, 30} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder convert
ioText {289, 295} {32, 32} display 0.000000 0.00100 "hor" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {424, 297} {44, 30} display 0.000000 0.00100 "ms" right "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 000
ioText {320, 297} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {411, 296} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {286, 268} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder hh
ioText {331, 268} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder min
ioText {377, 268} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder sec
ioText {426, 268} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ms
ioText {256, 173} {218, 54} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (sample rate conversion if the sr of the file doesn't match the sr of the orchestra)
ioText {15, 9} {450, 46} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SOUNDFILE PLAYER
ioText {14, 51} {450, 46} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (playing from a buffer)
</MacGUI>

