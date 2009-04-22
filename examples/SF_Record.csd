<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2; change this in respect to your audio device
0dbfs = 1

/*****Recording a soundfile*****/
;example for qutecsound
;written by joachim heintz apr 2009
;please send bug reports and suggestions
;to jh at joachimheintz.de

	opcode	ShowLED_a, 0, Sakkk
;Shows an audio signal in an outvalue channel.
;You can choose to show the value in dB or in raw amplitudes.
;
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;kdb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;kdbrange: if kdb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)

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
gSfile		invalue	"_Browse1"; output file name
krecord	invalue	"record"
kstop		invalue	"stop"
kchn1onoff	invalue	"chn1onoff"; 1=record this channel, 0=not
kchn2onoff	invalue	"chn2onoff"
kchn3onoff	invalue	"chn3onoff"
kchn4onoff	invalue	"chn4onoff"
kchn5onoff	invalue	"chn5onoff"
kchn6onoff	invalue	"chn6onoff"
kchn7onoff	invalue	"chn7onoff"
kchn8onoff	invalue	"chn8onoff"
kchn1		invalue	"chn1"; which physical channel goes here
kchn2		invalue	"chn2"
kchn3		invalue	"chn3"
kchn4		invalue	"chn4"
kchn5		invalue	"chn5"
kchn6		invalue	"chn6"
kchn7		invalue	"chn7"
kchn8		invalue	"chn8"
kfilfrmt	invalue	"fileformat"; 0=wav, 1=aiff
kfilfrmt	=		kfilfrmt + 1
kbitdepth	invalue	"bitdepth"; 0=16bit, 1=24bit, 2=32bit
kdbrange	invalue	"dbrange"
kpeakhold	invalue	"peakhold"
kampdisp	invalue	"ampdisp"; 0=dB, 1=raw
kgain		invalue	"gain"
Sgain_disp	sprintfk	"%+.2f dB", kgain
		outvalue	"gain_disp", Sgain_disp

;saying hello
ktimek		timek
if ktimek == 1 then
		outvalue	"message", "Waiting ..."
		outvalue	"hor", "00"
		outvalue	"min", "00"
		outvalue	"sec", "00"
		outvalue	"ms", "000"
endif

;format number for fout (e.g. aiff 24 bit gives the number 28)
kformat	=		(kbitdepth == 0 ? kfilfrmt*10+2 : (kbitdepth == 1 ? kfilfrmt*10+8 : kfilfrmt*10+6))

;number of the instr which records
krecinstr	init		0

;how many channels are checked
kchnsum	=		kchn1onoff + kchn2onoff + kchn3onoff + kchn4onoff + kchn5onoff + kchn6onoff + kchn7onoff + kchn8onoff

;calling the record instrument and stopping
krecstat	init		0
krechanged	changed	krecord
   if krecord == 1 && krecstat == 0 then
krecstat	=		1
		outvalue	"message", "Recording..."
kinstr		=		100 + kchnsum
krecinstr	=		kinstr
		event		"i", kinstr, 0, p3, kformat, \
				kchn1onoff, kchn2onoff, kchn3onoff, kchn4onoff, kchn5onoff, kchn6onoff, kchn7onoff, kchn8onoff, \
				kchn1, kchn2, kchn3, kchn4, kchn5, kchn6, kchn7, kchn8
   elseif krecord == 1 && krecstat == 1 && krechanged == 1 then
		outvalue	"message", "Can't start new record. Stop previous record first."
   endif
   if kstop == 1 then
krecstat	=		0
		turnoff2	krecinstr, 0, 0
		outvalue	"message", "Record stopped."
		outvalue	"message2", ""
   endif

;display
kTrigDisp	metro		10; refresh rate of display
ain1pre	inch		kchn1
ain2pre	inch		kchn2
ain3pre	inch		kchn3
ain4pre	inch		kchn4
ain5pre	inch		kchn5
ain6pre	inch		kchn6
ain7pre	inch		kchn7
ain8pre	inch		kchn8
		ShowLED_a	"in1_pre", ain1pre, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in2_pre", ain2pre, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in3_pre", ain3pre, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in4_pre", ain4pre, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in5_pre", ain5pre, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in6_pre", ain6pre, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in7_pre", ain7pre, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in8_pre", ain8pre, kTrigDisp, kampdisp, kdbrange
		ShowOver_a	"in1over_pre", ain1pre, kTrigDisp, kpeakhold
		ShowOver_a	"in2over_pre", ain2pre, kTrigDisp, kpeakhold
		ShowOver_a	"in3over_pre", ain3pre, kTrigDisp, kpeakhold
		ShowOver_a	"in4over_pre", ain4pre, kTrigDisp, kpeakhold
		ShowOver_a	"in5over_pre", ain5pre, kTrigDisp, kpeakhold
		ShowOver_a	"in6over_pre", ain6pre, kTrigDisp, kpeakhold
		ShowOver_a	"in7over_pre", ain7pre, kTrigDisp, kpeakhold
		ShowOver_a	"in8over_pre", ain8pre, kTrigDisp, kpeakhold
ain1post	=		ain1pre * ampdbfs(kgain)
ain2post	=		ain2pre * ampdbfs(kgain)
ain3post	=		ain3pre * ampdbfs(kgain)
ain4post	=		ain4pre * ampdbfs(kgain)
ain5post	=		ain5pre * ampdbfs(kgain)
ain6post	=		ain6pre * ampdbfs(kgain)
ain7post	=		ain7pre * ampdbfs(kgain)
ain8post	=		ain8pre * ampdbfs(kgain)
		ShowLED_a	"in1_post", ain1post, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in2_post", ain2post, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in3_post", ain3post, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in4_post", ain4post, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in5_post", ain5post, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in6_post", ain6post, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in7_post", ain7post, kTrigDisp, kampdisp, kdbrange
		ShowLED_a	"in8_post", ain8post, kTrigDisp, kampdisp, kdbrange
		ShowOver_a	"in1over_post", ain1pre, kTrigDisp, kpeakhold
		ShowOver_a	"in2over_post", ain2pre, kTrigDisp, kpeakhold
		ShowOver_a	"in3over_post", ain3pre, kTrigDisp, kpeakhold
		ShowOver_a	"in4over_post", ain4pre, kTrigDisp, kpeakhold
		ShowOver_a	"in5over_post", ain5pre, kTrigDisp, kpeakhold
		ShowOver_a	"in6over_post", ain6pre, kTrigDisp, kpeakhold
		ShowOver_a	"in7over_post", ain7pre, kTrigDisp, kpeakhold
		ShowOver_a	"in8over_post", ain8pre, kTrigDisp, kpeakhold
endin


instr 101; records mono
iformat	=		p4
   ;which channel is checked and what is its input channel number
ichnls		=		1
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
Smessage	sprintf	"Writing input channel %d to file %s", inchn1, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
		fout		gSfile, iformat, a1

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

instr 102; records stereo
iformat	=		p4
   ;which channels are checked and what are their input channel numbers
ichnls		=		2
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
inchn2		tab_i		1, itab
Smessage	sprintf	"Writing input channels %d and %d to file %s", inchn1, inchn2, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
a2		inch		inchn2
		fout		gSfile, iformat, a1, a2

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

instr 103; records 3 channels
iformat	=		p4
   ;which channels are checked and what are their input channel numbers
ichnls		=		3
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
inchn2		tab_i		1, itab
inchn3		tab_i		2, itab
Smessage	sprintf	"Writing input channels %d, %d and %d to file %s", inchn1, inchn2, inchn3, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
a2		inch		inchn2
a3		inch		inchn3
		fout		gSfile, iformat, a1, a2, a3

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

instr 104; records 4 channels
iformat	=		p4
   ;which channels are checked and what are their input channel numbers
ichnls		=		4
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
inchn2		tab_i		1, itab
inchn3		tab_i		2, itab
inchn4		tab_i		3, itab
Smessage	sprintf	"Writing input channels %d, %d, %d and %d to file %s", inchn1, inchn2, inchn3,inchn4, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
a2		inch		inchn2
a3		inch		inchn3
a4		inch		inchn4
		fout		gSfile, iformat, a1, a2, a3, a4

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

instr 105; records 5 channels
iformat	=		p4
   ;which channels are checked and what are their input channel numbers
ichnls		=		5
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
inchn2		tab_i		1, itab
inchn3		tab_i		2, itab
inchn4		tab_i		3, itab
inchn5		tab_i		4, itab
Smessage	sprintf	"Writing input channels %d, %d, %d, %d and %d to file %s",\
				 inchn1, inchn2, inchn3,inchn4, inchn5, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
a2		inch		inchn2
a3		inch		inchn3
a4		inch		inchn4
a5		inch		inchn5
		fout		gSfile, iformat, a1, a2, a3, a4, a5

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

instr 106; records 6 channels
iformat	=		p4
   ;which channels are checked and what are their input channel numbers
ichnls		=		6
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
inchn2		tab_i		1, itab
inchn3		tab_i		2, itab
inchn4		tab_i		3, itab
inchn5		tab_i		4, itab
inchn6		tab_i		5, itab
Smessage	sprintf	"Writing input channels %d, %d, %d, %d, %d and %d to file %s",\
				 inchn1, inchn2, inchn3,inchn4, inchn5, inchn6, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
a2		inch		inchn2
a3		inch		inchn3
a4		inch		inchn4
a5		inch		inchn5
a6		inch		inchn6
		fout		gSfile, iformat, a1, a2, a3, a4, a5, a6

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

instr 107; records 7 channels
iformat	=		p4
   ;which channels are checked and what are their input channel numbers
ichnls		=		7
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
inchn2		tab_i		1, itab
inchn3		tab_i		2, itab
inchn4		tab_i		3, itab
inchn5		tab_i		4, itab
inchn6		tab_i		5, itab
inchn7		tab_i		6, itab
Smessage	sprintf	"Writing input channels %d, %d, %d, %d, %d, %d and %d to file %s",\
				 inchn1, inchn2, inchn3,inchn4, inchn5, inchn6, inchn7, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
a2		inch		inchn2
a3		inch		inchn3
a4		inch		inchn4
a5		inch		inchn5
a6		inch		inchn6
a7		inch		inchn7
		fout		gSfile, iformat, a1, a2, a3, a4, a5, a6, a7

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

instr 108; records 8 channels
iformat	=		p4
   ;which channels are checked and what are their input channel numbers
ichnls		=		8
itab		ftgentmp	0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt	init		0
ipfld		init		5; first check p5
check:
if p(ipfld) == 1 then
ipfldval	=		ipfld + 8
		tabw_i		p(ipfldval), iwrtpnt, itab
iwrtpnt	=		iwrtpnt + 1
endif
ipfld		=		ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1		tab_i		0, itab
inchn2		tab_i		1, itab
inchn3		tab_i		2, itab
inchn4		tab_i		3, itab
inchn5		tab_i		4, itab
inchn6		tab_i		5, itab
inchn7		tab_i		6, itab
inchn8		tab_i		7, itab
Smessage	sprintf	"Writing input channels %d, %d, %d, %d, %d, %d, %d and %d to file %s",\
				 inchn1, inchn2, inchn3,inchn4, inchn5, inchn6, inchn7, inchn8, gSfile
		outvalue	"message2", Smessage
a1		inch		inchn1
a2		inch		inchn2
a3		inch		inchn3
a4		inch		inchn4
a5		inch		inchn5
a6		inch		inchn6
a7		inch		inchn7
a8		inch		inchn8
		fout		gSfile, iformat, a1, a2, a3, a4, a5, a6, a7, a8

   ;showing the clock
ktimout	timeinsts	
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		ktimout % 60
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms
endin

</CsInstruments>
<CsScore>
i 1 0 36000
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 305 102 787 696
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {27, 131} {324, 24} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {141, 89} {100, 30} value 1.000000 "_Browse1" "Output File" "/" 
ioSlider {128, 465} {136, 31} -18.000000 18.000000 0.264706 gain
ioText {269, 465} {98, 31} display 0.000000 0.00100 "gain_disp" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder +0.26 dB
ioButton {99, 174} {78, 26} value 1.000000 "record" "Record" "/" 
ioButton {189, 174} {80, 25} value 1.000000 "stop" "Stop" "/" 
ioText {614, 259} {37, 30} display 0.000000 0.00100 "min" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {661, 259} {35, 31} display 0.000000 0.00100 "sec" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {649, 259} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {58, 465} {65, 32} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder gain
ioText {560, 80} {208, 28} display 0.000000 0.00100 "message" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Waiting ...
ioText {612, 49} {102, 31} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Messages
ioText {539, 448} {56, 28} editnum 48.000000 1.000000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 48.000000
ioText {446, 449} {87, 28} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB Range
ioText {546, 476} {48, 24} editnum 2.000000 1.000000 "peakhold" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioText {438, 476} {106, 24} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Peak Hold Time
ioText {572, 258} {32, 32} display 0.000000 0.00100 "hor" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {707, 260} {44, 30} display 0.000000 0.00100 "ms" right "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 000
ioText {603, 260} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {694, 259} {14, 29} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {569, 231} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder hh
ioText {614, 231} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder min
ioText {660, 231} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder sec
ioText {709, 231} {39, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ms
ioText {59, 18} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SOUNDFILE RECORD
ioText {17, 295} {46, 24} editnum 1.000000 1.000000 "chn1" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {133, 227} {189, 30} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Channels to Record
ioCheckbox {28, 269} {20, 20} on chn1onoff
ioText {71, 296} {46, 24} editnum 2.000000 1.000000 "chn2" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioCheckbox {82, 270} {20, 20} on chn2onoff
ioText {125, 296} {46, 24} editnum 3.000000 1.000000 "chn3" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioCheckbox {136, 270} {20, 20} off chn3onoff
ioText {179, 297} {46, 24} editnum 4.000000 1.000000 "chn4" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioCheckbox {190, 271} {20, 20} off chn4onoff
ioText {234, 296} {46, 24} editnum 5.000000 1.000000 "chn5" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5.000000
ioCheckbox {245, 270} {20, 20} off chn5onoff
ioText {288, 297} {46, 24} editnum 6.000000 1.000000 "chn6" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6.000000
ioCheckbox {299, 271} {20, 20} off chn6onoff
ioText {342, 297} {46, 24} editnum 7.000000 1.000000 "chn7" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7.000000
ioCheckbox {353, 271} {20, 20} off chn7onoff
ioText {396, 298} {46, 24} editnum 8.000000 1.000000 "chn8" right "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8.000000
ioCheckbox {407, 272} {20, 20} off chn8onoff
ioMeter {20, 348} {27, 94} {0, 59904, 0} "in1_pre" 0.192927 "hor8" 0.370370 fill 1 0 mouse
ioMeter {20, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in1over_pre" 0.000000 fill 1 0 mouse
ioMeter {74, 348} {27, 94} {0, 59904, 0} "in2_pre" 0.191341 "hor8" 0.370370 fill 1 0 mouse
ioMeter {74, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in2over_pre" 0.000000 fill 1 0 mouse
ioMeter {128, 348} {27, 94} {0, 59904, 0} "in3_pre" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {128, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in3over_pre" 0.000000 fill 1 0 mouse
ioMeter {181, 348} {27, 94} {0, 59904, 0} "in4_pre" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {181, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in4over_pre" 0.000000 fill 1 0 mouse
ioMeter {237, 348} {27, 94} {0, 59904, 0} "in5_pre" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {237, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in5over_pre" 0.000000 fill 1 0 mouse
ioMeter {291, 348} {27, 94} {0, 59904, 0} "in6_pre" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {291, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in6over_pre" 0.000000 fill 1 0 mouse
ioMeter {343, 348} {27, 94} {0, 59904, 0} "in7_pre" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {343, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in7over_pre" 0.000000 fill 1 0 mouse
ioMeter {397, 348} {27, 94} {0, 59904, 0} "in8_pre" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {397, 330} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in8over_pre" 0.000000 fill 1 0 mouse
ioText {371, 90} {116, 32} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File Format
ioMenu {389, 127} {83, 25} 0 303 "WAV,AIFF" fileformat
ioText {379, 161} {101, 32} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Bit Depth
ioMenu {391, 197} {83, 25} 1 303 "16bit,24bit,32bit" bitdepth
ioText {559, 114} {212, 104} display 0.000000 0.00100 "message2" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {442, 504} {94, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp Display
ioMenu {537, 502} {61, 26} 1 303 "dB,raw" ampdisp
ioText {457, 299} {129, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select Input Channels
ioText {435, 412} {167, 130} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border LED Display Properties
ioMeter {21, 536} {27, 94} {0, 59904, 0} "in1_post" 0.198442 "hor8" 0.370370 fill 1 0 mouse
ioMeter {21, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in1over_post" 0.000000 fill 1 0 mouse
ioMeter {75, 536} {27, 94} {0, 59904, 0} "in2_post" 0.196856 "hor8" 0.370370 fill 1 0 mouse
ioMeter {75, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in2over_post" 0.000000 fill 1 0 mouse
ioMeter {129, 536} {27, 94} {0, 59904, 0} "in3_post" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {129, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in3over_post" 0.000000 fill 1 0 mouse
ioMeter {182, 536} {27, 94} {0, 59904, 0} "in4_post" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {182, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in4over_post" 0.000000 fill 1 0 mouse
ioMeter {238, 536} {27, 94} {0, 59904, 0} "in5_post" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {238, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in5over_post" 0.000000 fill 1 0 mouse
ioMeter {292, 536} {27, 94} {0, 59904, 0} "in6_post" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {292, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in6over_post" 0.000000 fill 1 0 mouse
ioMeter {344, 536} {27, 94} {0, 59904, 0} "in7_post" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {344, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in7over_post" 0.000000 fill 1 0 mouse
ioMeter {398, 536} {27, 94} {0, 59904, 0} "in8_post" 0.000000 "hor8" 0.370370 fill 1 0 mouse
ioMeter {398, 518} {27, 22} {50176, 3584, 3072} "in1over" 0.636364 "in8over_post" 0.000000 fill 1 0 mouse
ioText {606, 296} {166, 327} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Records a soundfile (1-8 channels) with arbitrary input routing. The file will have as many channels as you select to record with the checkboxes. E.g. if you check channels 2, 3, 5 and 8 for recording, a sound file with 4 channels will be written. Set the nchnls in the orchestra header and select your audio device in the CsOptions or in the Configure dialog.
ioText {435, 553} {166, 71} label 0.000000 0.00100 "" left "Lucida Grande" 8 {21504, 28672, 21248} {65280, 65280, 65280} nobackground noborder Note: You can also us the Record Button in the QuteCsound interface for quick simple recording on any csd.
</MacGUI>

