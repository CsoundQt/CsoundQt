<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

/*****Playing a soundfile 2a: Play from the Harddisk with more features*****/
;written by joachim heintz and andres cabrera
;mar 2009

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



instr 1; stop
		turnoff2	4, 0, 0
		turnoff2	10, 0, 0
		outvalue "outL", 0
		outvalue "outR", 0
		outvalue "outLover", 0
		outvalue "outRover", 0
gktimi10k	=		0; reset the clock
gkpaus		=		0; reset pause status
		turnoff
endin


instr 2 ;read file info and play
gSfile		invalue	"_Browse1"; get the name (look at the example in Examples->Reserved Channels)

gilen		filelen	gSfile; duration of the file
gichn		filenchnls	gSfile; is the file mono or stereo
gifilesr		filesr		gSfile
kconvertsr	invalue	"convertsr"
giconvrt	=		i(kconvertsr)
gktimi10k		init		0; time instr 10 has performed in k-cycles
gkpaus		init		0; status of the pause button
imaxlen	=		36000; maximum length of loop play 

   ;send a message if the sr of the file doesn't match the sr of the orchestra
  if gifilesr != sr then
    if giconvrt == 1 then
Swarn	sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will be converted by changing speed of reading.", gifilesr, sr
		outvalue	"message", Swarn
    else
Swarn	sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will not be converted, so you will have changes in tempo and pitch.", gifilesr, sr
		outvalue	"message", Swarn
    endif
  else
Smess	sprintf	"Length = %.3f\nSamplerate = %d\nChannels = %d", gilen, gifilesr, gichn
		outvalue	"message", Smess 
 endif
		event_i "i", 4, 0, imaxlen
		turnoff
endin


instr 3; pause and resume
  if gkpaus == 0 then
		turnoff2	4, 0, 0
		turnoff2	10, 0, 0
gkpaus		=		1
  else
		turnoff2	10, 0, 0
		event		"i", 4, 0, 1
gkpaus		=		0
  endif
		turnoff
endin


instr 4
ilen		=		gilen
ilenk		=		ilen * kr; duration of the file in k-cycles
ichn		=		gichn
gkdb		invalue	"db"; gain value in dB
kskip	invalue	"skip"; skiptime in sec
iskip		=		i(kskip)
itimi10k	=		i(gktimi10k) % ilenk; time instr 10 was active in control cycles in respect to the loops
kloop	invalue	"loop"; value 1 if checked
iloop		=		i(kloop)
istart		=		iskip + (itimi10k / kr)

   ;playing
iplaylen	=		(iloop == 1 ? p3 : ilen)
		event_i	"i", 10, 0, iplaylen, istart, ichn, giconvrt

   ;time output
ktimout	=		(gktimi10k / kr + iskip) % ilen; position in the soundfile in seconds
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

   ;turnoff if no loop and end of file is reached
  if iloop == 0 && ktimout > ilen then
		event		"i", 1, 0, .1
		turnoff
  endif
endin


instr 10
iskip	=		p4
ichn		=		p5
iconvrt	=		(p6 == 1 ? 0 : 1)

kdbrange	invalue	"dbrange"  ;dB range for the meters
kpeakhold	invalue	"peakhold"  ;Duration of clip indicator hold in seconds
	if ichn == 1 then
aL		diskin2	gSfile, 1, iskip, 1, 0, iconvrt
aR		=		aL
	else
aL, aR	diskin2	gSfile, 1, iskip, 1, 0, iconvrt
	endif

   ;Volume
kmult		=		ampdbfs(gkdb)
Sdb_disp	sprintfk	"%+.2f dB", gkdb
		outvalue	"db_disp", Sdb_disp
aL		=		aL * kmult
aR		=		aR * kmult

   ;show output
kTrigDisp	metro		10
		ShowLED_a		"outL", aL, kTrigDisp, 1, kdbrange
		ShowLED_a		"outR", aR, kTrigDisp, 1, kdbrange
		ShowOver_a	"outLover", aL, kTrigDisp, kpeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, kpeakhold

		outs		aL, aR
gktimi10k	=		gktimi10k + 1; count the time instr 10 was active
endin

</CsInstruments>
<CsScore>
f 0 36000; don't listen to music longer than 10 hours
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 559 211 512 596
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {33153, 43690, 42148}
ioText {19, 113} {351, 23} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {378, 111} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioSlider {117, 262} {136, 31} -18.000000 18.000000 0.000000 db
ioText {258, 262} {98, 31} display 0.000000 0.00100 "db_disp" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder +0.00 dB
ioButton {20, 148} {78, 26} event 1.000000 "" "Play" "/" i 2 0 1
ioButton {223, 150} {80, 25} event 1.000000 "" "Stop" "/" i 1 0 .1
ioText {21, 216} {87, 25} editnum 0.000000 0.001000 "skip" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioButton {122, 149} {80, 25} event 1.000000 "" "Pause" "/" i 3 0 .1
ioCheckbox {152, 216} {20, 20} off loop
ioText {344, 348} {37, 30} display 0.000000 0.00100 "min" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {391, 348} {35, 31} display 0.000000 0.00100 "sec" right "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {379, 348} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {21, 190} {88, 30} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder skiptime
ioText {130, 192} {59, 30} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder loop
ioText {22, 261} {88, 30} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder volume
ioText {24, 449} {460, 93} display 0.000000 0.00100 "message" center "DejaVu Sans" 12 {0, 0, 0} {55552, 55552, 55552} background border 
ioText {25, 422} {460, 25} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Messages
ioMeter {24, 328} {250, 19} {0, 59904, 0} "out1_post" 0.578947 "outL" 0.000000 fill 1 0 mouse
ioMeter {271, 328} {21, 19} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {24, 355} {250, 19} {0, 59904, 0} "out2_post" 1.000000 "outR" 0.000000 fill 1 0 mouse
ioMeter {271, 355} {21, 19} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {109, 390} {80, 25} editnum 48.000000 0.100000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 48.000000
ioText {24, 389} {131, 27} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB Range
ioText {357, 390} {57, 25} editnum 3.000000 1.000000 "peakhold" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioText {235, 389} {131, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Peak Hold time
ioCheckbox {224, 216} {20, 20} off convertsr
ioText {202, 192} {62, 30} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder convert
ioText {302, 347} {32, 32} display 0.000000 0.00100 "hor" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {437, 349} {44, 30} display 0.000000 0.00100 "ms" right "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 000
ioText {333, 349} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {424, 348} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {299, 320} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder hh
ioText {344, 320} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder min
ioText {390, 320} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder sec
ioText {439, 320} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ms
ioText {277, 194} {187, 54} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (sample rate conversion if the sr of the file doesn't match the sr of the orchestra)
ioText {49, 18} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SOUNDFILE PLAYER
ioText {48, 60} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (playing from the hard disk)
</MacGUI>

