<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2; change this in respect to your audio device
0dbfs = 1

/*****Recording a soundfile*****/
;example for CsoundQt
;written by joachim heintz apr 2009 / dec 2013
;please send bug reports and suggestions
;to jh at joachimheintz.de



/********UDOs for Signal Display*********/

gi_db_range =         60 ;dB range to be displayed in the LED widget
gi_hold    =          2 ;time (sec) to hold "red light" if signal is over maxmimum

	opcode	ShowLED_a, 0, Saki
Soutchan, asig, ktrig, idbrange xin
kdispval   max_k      asig, ktrig, 1
kdb        =          dbfsamp(kdispval)
kval       =          (idbrange + kdb) / idbrange
	if ktrig == 1 then
           chnset     kval, Soutchan
	endif
	endop

	opcode ShowOver_a, 0, Saki
Soutchan, asig, ktrig, iholdtm xin
kon        init       0
ktim       times
kstart     init       0
kend       init       0
iholdtm    =          (iholdtm < .01 ? .01 : iholdtm); avoiding too short hold times
kmax       max_k      asig, ktrig, 1
	if kon == 0 && kmax > 1 && ktrig == 1 then
kstart     =          ktim
kend       =          kstart + iholdtm
           chnset     kmax, Soutchan
kon        =          1
	endif
	if kon == 1 && ktim > kend && ktrig == 1 then
           chnset     ktim-ktim, Soutchan
kon        =          0
	endif
	endop



/**************Declare Channels for Widgets**************/
           chn_S      "_Browse1", 1
           chn_k      "record", 1
           chn_k      "stop", 1
           chn_k      "chn1onoff", 1
           chn_k      "chn2onoff", 1
           chn_k      "chn3onoff", 1
           chn_k      "chn4onoff", 1
           chn_k      "chn5onoff", 1
           chn_k      "chn6onoff", 1
           chn_k      "chn7onoff", 1
           chn_k      "chn8onoff", 1
           chn_k      "chn1", 1
           chn_k      "chn2", 1
           chn_k      "chn3", 1
           chn_k      "chn4", 1
           chn_k      "chn5", 1
           chn_k      "chn6", 1
           chn_k      "chn7", 1
           chn_k      "chn8", 1
           chn_k      "fileformat", 1
           chn_k      "bitdepth", 1
           chn_k      "dbrange", 1
           chn_k      "peakhold", 1
           chn_k      "ampdisp", 1
           chn_k      "gain", 1
           chn_S      "gain_disp", 2
           chn_S      "message", 2
           chn_S      "message2", 2
           chn_S      "hor", 2
           chn_S      "min", 2
           chn_S      "sec", 2
           chn_S      "ms", 2
           chn_k      "in1_pre", 2
           chn_k      "in2_pre", 2
           chn_k      "in3_pre", 2
           chn_k      "in4_pre", 2
           chn_k      "in5_pre", 2
           chn_k      "in6_pre", 2
           chn_k      "in7_pre", 2
           chn_k      "in8_pre", 2
           chn_k      "in1over_pre", 2
           chn_k      "in2over_pre", 2
           chn_k      "in3over_pre", 2
           chn_k      "in4over_pre", 2
           chn_k      "in5over_pre", 2
           chn_k      "in6over_pre", 2
           chn_k      "in7over_pre", 2
           chn_k      "in8over_pre", 2
           chn_k      "in1_post", 2
           chn_k      "in2_post", 2
           chn_k      "in3_post", 2
           chn_k      "in4_post", 2
           chn_k      "in5_post", 2
           chn_k      "in6_post", 2
           chn_k      "in7_post", 2
           chn_k      "in8_post", 2
           chn_k      "in1over_post", 2
           chn_k      "in2over_post", 2
           chn_k      "in3over_post", 2
           chn_k      "in4over_post", 2
           chn_k      "in5over_post", 2
           chn_k      "in6over_post", 2
           chn_k      "in7over_post", 2
           chn_k      "in8over_post", 2


instr 1; always on

gSfile     chnget     "_Browse1"; output file name
krecord    chnget     "record"
kstop      chnget     "stop"
kchn1onoff chnget     "chn1onoff"; 1=record this channel, 0=not
kchn2onoff chnget     "chn2onoff"
kchn3onoff chnget     "chn3onoff"
kchn4onoff chnget     "chn4onoff"
kchn5onoff chnget     "chn5onoff"
kchn6onoff chnget     "chn6onoff"
kchn7onoff chnget     "chn7onoff"
kchn8onoff chnget     "chn8onoff"
kchn1      chnget     "chn1"; which physical channel goes here
kchn2      chnget     "chn2"
kchn3      chnget     "chn3"
kchn4      chnget     "chn4"
kchn5      chnget     "chn5"
kchn6      chnget     "chn6"
kchn7      chnget     "chn7"
kchn8      chnget     "chn8"
kfilfrmt   chnget     "fileformat"; 0=wav, 1=aiff
kfilfrmt   =          kfilfrmt + 1
kbitdepth  chnget     "bitdepth"; 0=16bit, 1=24bit, 2=32bit
kdbrange   chnget     "dbrange"
kpeakhold  chnget     "peakhold"
kampdisp   chnget     "ampdisp"; 0=dB, 1=raw
kampdisp   =          (kampdisp == 1 ? 0 : 1); 1=dB, 0=raw
gkgain     chnget     "gain"
Sgain_disp sprintfk   "%+.2f dB", gkgain
           chnset     Sgain_disp, "gain_disp"

;saying hello
ktimek     timek
if ktimek == 1 then
           chnset     "Waiting ...", "message"
           chnset     "00", "hor"
           chnset     "00", "min"
           chnset     "00", "sec"
           chnset     "000", "ms"
endif

;format number for fout (e.g. aiff 24 bit gives the number 28)
kformat    =          (kbitdepth == 0 ? kfilfrmt*10+2 : (kbitdepth == 1 ? kfilfrmt*10+8 : kfilfrmt*10+6))

;number of the instr which records
krecinstr  init       0

;how many channels are checked
kchnsum    =          kchn1onoff + kchn2onoff + kchn3onoff + kchn4onoff + kchn5onoff + kchn6onoff + kchn7onoff + kchn8onoff

;calling the record instrument and stopping
krecstat   init       0
krechanged changed    krecord
   if krecord == 1 && krecstat == 0 then
krecstat   =          1
           chnset     "Recording...", "message"
kinstr     =          100 + kchnsum
krecinstr  =          kinstr
           event      "i", kinstr, 0, p3, kformat, kchn1onoff, kchn2onoff, kchn3onoff, kchn4onoff, kchn5onoff, kchn6onoff, kchn7onoff, kchn8onoff, kchn1, kchn2, kchn3, kchn4, kchn5, kchn6, kchn7, kchn8
   elseif krecord == 1 && krecstat == 1 && krechanged == 1 then
           chnset     "Can't start new record. Stop previous record first.", "message"
   endif
   if kstop == 1 then
krecstat   =          0
           turnoff2   krecinstr, 0, 0
           chnset     "Record stopped.", "message"
           chnset     "", "message2"
   endif

;display
 if kchn1 <= nchnls then ;this check is necessary (csound crashes if inch > nchnls)
ain1pre    inch       kchn1
           else
ain1pre    =          0
 endif
 if kchn2 <= nchnls then
ain2pre    inch       kchn2
           else
ain2pre    =          0
 endif
 if kchn3 <= nchnls then
ain3pre    inch       kchn3
           else
ain3pre    =          0
 endif
 if kchn4 <= nchnls then
ain4pre    inch       kchn4
           else
ain4pre    =          0
 endif
 if kchn5 <= nchnls then
ain5pre    inch       kchn5
           else
ain5pre    =          0
 endif
 if kchn6 <= nchnls then
ain6pre    inch       kchn6
           else
ain6pre    =          0
 endif
 if kchn7 <= nchnls then
ain7pre    inch       kchn7
           else
ain7pre    =          0
 endif
 if kchn8 <= nchnls then
ain8pre    inch       kchn8
           else
ain8pre    =          0
 endif


kTrigDisp  metro      10; refresh rate of display

           ShowLED_a  "in1_pre", ain1pre, kTrigDisp, gi_db_range
           ShowLED_a  "in2_pre", ain2pre, kTrigDisp, gi_db_range
           ShowLED_a  "in3_pre", ain3pre, kTrigDisp, gi_db_range
           ShowLED_a  "in4_pre", ain4pre, kTrigDisp, gi_db_range
           ShowLED_a  "in5_pre", ain5pre, kTrigDisp, gi_db_range
           ShowLED_a  "in6_pre", ain6pre, kTrigDisp, gi_db_range
           ShowLED_a  "in7_pre", ain7pre, kTrigDisp, gi_db_range
           ShowLED_a  "in8_pre", ain8pre, kTrigDisp, gi_db_range
           ShowOver_a "in1over_pre", ain1pre, kTrigDisp, gi_hold
           ShowOver_a "in2over_pre", ain2pre, kTrigDisp, gi_hold
           ShowOver_a "in3over_pre", ain3pre, kTrigDisp, gi_hold
           ShowOver_a "in4over_pre", ain4pre, kTrigDisp, gi_hold
           ShowOver_a "in5over_pre", ain5pre, kTrigDisp, gi_hold
           ShowOver_a "in6over_pre", ain6pre, kTrigDisp, gi_hold
           ShowOver_a "in7over_pre", ain7pre, kTrigDisp, gi_hold
           ShowOver_a "in8over_pre", ain8pre, kTrigDisp, gi_hold
ain1post   =          ain1pre * ampdbfs(gkgain)
ain2post   =          ain2pre * ampdbfs(gkgain)
ain3post   =          ain3pre * ampdbfs(gkgain)
ain4post   =          ain4pre * ampdbfs(gkgain)
ain5post   =          ain5pre * ampdbfs(gkgain)
ain6post   =          ain6pre * ampdbfs(gkgain)
ain7post   =          ain7pre * ampdbfs(gkgain)
ain8post   =          ain8pre * ampdbfs(gkgain)
           ShowLED_a  "in1_post", ain1post, kTrigDisp, gi_db_range
           ShowLED_a  "in2_post", ain2post, kTrigDisp, gi_db_range
           ShowLED_a  "in3_post", ain3post, kTrigDisp, gi_db_range
           ShowLED_a  "in4_post", ain4post, kTrigDisp, gi_db_range
           ShowLED_a  "in5_post", ain5post, kTrigDisp, gi_db_range
           ShowLED_a  "in6_post", ain6post, kTrigDisp, gi_db_range
           ShowLED_a  "in7_post", ain7post, kTrigDisp, gi_db_range
           ShowLED_a  "in8_post", ain8post, kTrigDisp, gi_db_range
           ShowOver_a "in1over_post", ain1post, kTrigDisp, gi_hold
           ShowOver_a "in2over_post", ain2post, kTrigDisp, gi_hold
           ShowOver_a "in3over_post", ain3post, kTrigDisp, gi_hold
           ShowOver_a "in4over_post", ain4post, kTrigDisp, gi_hold
           ShowOver_a "in5over_post", ain5post, kTrigDisp, gi_hold
           ShowOver_a "in6over_post", ain6post, kTrigDisp, gi_hold
           ShowOver_a "in7over_post", ain7post, kTrigDisp, gi_hold
           ShowOver_a "in8over_post", ain8post, kTrigDisp, gi_hold

endin


instr 101; records mono
iformat    =          p4
   ;which channel is checked and what is its input channel number
ichnls     =          1
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
Smessage   sprintf    "Writing input channel %d to file %s", inchn1, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
           fout       gSfile, iformat, a1*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin

instr 102; records stereo
iformat    =          p4
   ;which channels are checked and what are their input channel numbers
ichnls     =          2
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
inchn2     tab_i      1, itab
Smessage   sprintf    "Writing input channels %d and %d to file %s", inchn1, inchn2, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
a2         inch       inchn2
           fout       gSfile, iformat, a1*ampdbfs(gkgain), a2*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin

instr 103; records 3 channels
iformat    =          p4
   ;which channels are checked and what are their input channel numbers
ichnls     =          3
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
inchn2     tab_i      1, itab
inchn3     tab_i      2, itab
Smessage   sprintf    "Writing input channels %d, %d and %d to file %s", inchn1, inchn2, inchn3, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
a2         inch       inchn2
a3         inch       inchn3
           fout       gSfile, iformat, a1*ampdbfs(gkgain), a2*ampdbfs(gkgain), a3*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin

instr 104; records 4 channels
iformat    =          p4
   ;which channels are checked and what are their input channel numbers
ichnls     =          4
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
inchn2     tab_i      1, itab
inchn3     tab_i      2, itab
inchn4     tab_i      3, itab
Smessage   sprintf    "Writing input channels %d, %d, %d and %d to file %s", inchn1, inchn2, inchn3,inchn4, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
a2         inch       inchn2
a3         inch       inchn3
a4         inch       inchn4
           fout       gSfile, iformat, a1*ampdbfs(gkgain), a2*ampdbfs(gkgain), a3*ampdbfs(gkgain), a4*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin

instr 105; records 5 channels
iformat    =          p4
   ;which channels are checked and what are their input channel numbers
ichnls     =          5
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
inchn2     tab_i      1, itab
inchn3     tab_i      2, itab
inchn4     tab_i      3, itab
inchn5     tab_i      4, itab
Smessage   sprintf    "Writing input channels %d, %d, %d, %d and %d to file %s",\
inchn1, inchn2, inchn3,inchn4, inchn5, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
a2         inch       inchn2
a3         inch       inchn3
a4         inch       inchn4
a5         inch       inchn5
           fout       gSfile, iformat, a1*ampdbfs(gkgain), a2*ampdbfs(gkgain), a3*ampdbfs(gkgain), a4*ampdbfs(gkgain), a5*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin

instr 106; records 6 channels
iformat    =          p4
   ;which channels are checked and what are their input channel numbers
ichnls     =          6
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
inchn2     tab_i      1, itab
inchn3     tab_i      2, itab
inchn4     tab_i      3, itab
inchn5     tab_i      4, itab
inchn6     tab_i      5, itab
Smessage   sprintf    "Writing input channels %d, %d, %d, %d, %d and %d to file %s",\
inchn1, inchn2, inchn3,inchn4, inchn5, inchn6, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
a2         inch       inchn2
a3         inch       inchn3
a4         inch       inchn4
a5         inch       inchn5
a6         inch       inchn6
           fout       gSfile, iformat, a1*ampdbfs(gkgain), a2*ampdbfs(gkgain), a3*ampdbfs(gkgain), a4*ampdbfs(gkgain), a5*ampdbfs(gkgain), a6*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin

instr 107; records 7 channels
iformat    =          p4
   ;which channels are checked and what are their input channel numbers
ichnls     =          7
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
inchn2     tab_i      1, itab
inchn3     tab_i      2, itab
inchn4     tab_i      3, itab
inchn5     tab_i      4, itab
inchn6     tab_i      5, itab
inchn7     tab_i      6, itab
Smessage   sprintf    "Writing input channels %d, %d, %d, %d, %d, %d and %d to file %s",\
inchn1, inchn2, inchn3,inchn4, inchn5, inchn6, inchn7, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
a2         inch       inchn2
a3         inch       inchn3
a4         inch       inchn4
a5         inch       inchn5
a6         inch       inchn6
a7         inch       inchn7
           fout       gSfile, iformat, a1*ampdbfs(gkgain), a2*ampdbfs(gkgain), a3*ampdbfs(gkgain), a4*ampdbfs(gkgain), a5*ampdbfs(gkgain), a6*ampdbfs(gkgain), a7*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin

instr 108; records 8 channels
iformat    =          p4
   ;which channels are checked and what are their input channel numbers
ichnls     =          8
itab       ftgentmp   0, 0, -ichnls, -2, 0; ftable for writing the result
iwrtpnt    init       0
ipfld      init       5; first check p5
check:
if p(ipfld) == 1 then
ipfldval   =          ipfld + 8
           tabw_i     p(ipfldval), iwrtpnt, itab
iwrtpnt    =          iwrtpnt + 1
endif
ipfld      =          ipfld + 1
if iwrtpnt < ichnls igoto check

   ;read the values from itab and write the soundfile
inchn1     tab_i      0, itab
inchn2     tab_i      1, itab
inchn3     tab_i      2, itab
inchn4     tab_i      3, itab
inchn5     tab_i      4, itab
inchn6     tab_i      5, itab
inchn7     tab_i      6, itab
inchn8     tab_i      7, itab
Smessage   sprintf    "Writing input channels %d, %d, %d, %d, %d, %d, %d and %d to file %s",\
inchn1, inchn2, inchn3,inchn4, inchn5, inchn6, inchn7, inchn8, gSfile
           chnset     Smessage, "message2"
a1         inch       inchn1
a2         inch       inchn2
a3         inch       inchn3
a4         inch       inchn4
a5         inch       inchn5
a6         inch       inchn6
a7         inch       inchn7
a8         inch       inchn8
           fout       gSfile, iformat, a1*ampdbfs(gkgain), a2*ampdbfs(gkgain), a3*ampdbfs(gkgain), a4*ampdbfs(gkgain), a5*ampdbfs(gkgain), a6*ampdbfs(gkgain), a7*ampdbfs(gkgain), a8*ampdbfs(gkgain)

   ;showing the clock
ktimout    timeinsts
ktimouthor =          int(ktimout / 3600)
Shor       sprintfk   "%02d", ktimouthor
ktimoutmin =          int(ktimout / 60)
Smin       sprintfk   "%02d", ktimoutmin
ktimoutsec =          ktimout % 60
Ssec       sprintfk   "%02d", ktimoutsec
ktimoutms  =          frac(ktimout) * 1000
Sms        sprintfk   "%03d", ktimoutms
           chnset     Shor, "hor"
           chnset     Smin, "min"
           chnset     Ssec, "sec"
           chnset     Sms, "ms"
endin
</CsInstruments>
<CsScore>
i 1 0 36000
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>771</width>
 <height>710</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>23</x>
  <y>185</y>
  <width>324</width>
  <height>24</height>
  <uuid>{13ef4f41-afd7-401f-af30-ce7f8c53c3f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>/home/jh/record.wav</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>437</x>
  <y>597</y>
  <width>129</width>
  <height>33</height>
  <uuid>{908e4f2c-66e4-4055-87f7-1fca6aa22364}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Post Fader</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>440</x>
  <y>400</y>
  <width>129</width>
  <height>33</height>
  <uuid>{42891488-8258-4fd6-b988-2b46ab37f8e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Pre Fader</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>435</x>
  <y>456</y>
  <width>164</width>
  <height>101</height>
  <uuid>{04f26f1f-e12c-4825-9a8c-dbbb5f2212d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Note: You can also use the Record Button in the CsoundQt interface for quick simple recording on any csd.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>84</r>
   <g>112</g>
   <b>83</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>606</x>
  <y>296</y>
  <width>159</width>
  <height>313</height>
  <uuid>{951439c2-768b-4837-8dc1-06b29611b1a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Records a soundfile (1-8 channels) with arbitrary input routing. The file will have as many channels as you select to record with the checkboxes. E.g. if you check channels 2, 3, 5 and 8 for recording, a sound file with 4 channels will be written. Set the nchnls in the orchestra header and select your audio device in the CsOptions or in the Configure dialog.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in8over_post</objectName>
  <x>395</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{617fca26-166b-476f-a634-c6a35e0e4ec0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>395</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{7e1097a0-da28-41c0-bd09-6a5df53452fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in8_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in7over_post</objectName>
  <x>341</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{f7318335-811b-4b95-800a-2dedeffedd04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>341</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{9fbd4836-8f1c-491f-8a06-ebe3d5e225d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in7_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in6over_post</objectName>
  <x>289</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{cecce0bd-30cc-46ce-9608-3f5120fdced5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>289</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{08c5446b-2c74-4a7f-95e8-9a96092861b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in6_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in5over_post</objectName>
  <x>235</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{cd4b8086-1c5e-43ca-b665-95fd31b75cac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>235</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{6f1fcd97-3760-4bfc-afcd-ad442dfc0950}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in5_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in4over_post</objectName>
  <x>179</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{126f5cac-d10f-4805-a963-b87a22305fca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>179</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{c5dc13f7-d9f2-4607-b5ab-942c4346821e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in4_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in3over_post</objectName>
  <x>126</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{e17125b3-2f20-441d-a058-c67e7437f87d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>126</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{bd44c863-c32d-4973-a25f-2f09cf541f1a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in3_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in2over_post</objectName>
  <x>72</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{67724e73-c1fb-4606-8281-45dc80d08b47}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>72</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{04cb23a7-e299-4acd-95cf-b211fdb2fb7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.79627118</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in1over_post</objectName>
  <x>18</x>
  <y>556</y>
  <width>27</width>
  <height>22</height>
  <uuid>{fbe5c18f-b4d1-45e7-9af3-ac14b334eef0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>18</x>
  <y>574</y>
  <width>27</width>
  <height>94</height>
  <uuid>{a3d60196-1bb4-418e-a40d-dbbe4cf22ea0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.81004137</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>444</x>
  <y>338</y>
  <width>160</width>
  <height>28</height>
  <uuid>{689683d6-a7a4-4c43-9cdc-e64b44632884}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select Input Channels</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>message2</objectName>
  <x>559</x>
  <y>114</y>
  <width>212</width>
  <height>104</height>
  <uuid>{9e40f3d3-9067-42e6-8f11-cb1b465ccecc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>bitdepth</objectName>
  <x>388</x>
  <y>235</y>
  <width>83</width>
  <height>25</height>
  <uuid>{8976122f-4026-4cb1-9182-588fb77616b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>16bit</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24bit</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>32bit</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>376</x>
  <y>199</y>
  <width>101</width>
  <height>32</height>
  <uuid>{20f2a78a-57b2-4e24-a9da-5065a8b20d93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Bit Depth</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>fileformat</objectName>
  <x>386</x>
  <y>165</y>
  <width>83</width>
  <height>25</height>
  <uuid>{7ae09982-2f62-4f36-8438-1f2b6341c2b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>WAV</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>AIFF</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>368</x>
  <y>128</y>
  <width>116</width>
  <height>32</height>
  <uuid>{76e056af-5663-46a0-80ab-041d67b00ca6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File Format</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in8over_pre</objectName>
  <x>394</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{68087bf2-5239-4f42-9f96-5d2f98bd1ea9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>394</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{ecf2cc00-2499-4caf-b4e8-2d3870341bd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in8_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in7over_pre</objectName>
  <x>340</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{b80feb90-153f-4b1b-bd55-4a521a27de0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>340</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{365eaebd-10f4-4161-9bdb-e4239f98d087}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in7_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in6over_pre</objectName>
  <x>288</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{578ae6da-9cc1-4485-84d4-2a27c108e380}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>288</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{81e2d6ae-0827-47ab-a854-5eb0be369ccc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in6_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in5over_pre</objectName>
  <x>234</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{4032e775-ab58-4556-9a34-c89b1eb54773}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>234</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{f2bce172-1501-4fc3-b4a6-889209f43db8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in5_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in4over_pre</objectName>
  <x>178</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{ed5dd815-0ce1-43ec-9c6e-ff66c56a0e67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>178</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{9a7c78fa-7191-4c2c-a205-091a649ad9b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in4_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in3over_pre</objectName>
  <x>125</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{3b428c95-05f1-4011-ab79-e72a94be2347}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>125</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{28866427-bf18-4553-9205-d47c173af814}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in3_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in2over_pre</objectName>
  <x>71</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{4977e06a-977a-4404-91b3-370563d2797a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>71</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{c7fc0494-b7fe-4eb1-a4ae-19655116e59b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in2_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.98156529</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>in1over_pre</objectName>
  <x>17</x>
  <y>368</y>
  <width>27</width>
  <height>22</height>
  <uuid>{2b8b84d7-c4d0-45c8-8cf2-069d20661cf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>17</x>
  <y>386</y>
  <width>27</width>
  <height>94</height>
  <uuid>{6d3da117-7c00-4977-b271-65f92698df9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.99533548</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn8onoff</objectName>
  <x>404</x>
  <y>310</y>
  <width>20</width>
  <height>20</height>
  <uuid>{534bd3a1-c528-424e-9a09-3526ed16831a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn8</objectName>
  <x>393</x>
  <y>336</y>
  <width>46</width>
  <height>24</height>
  <uuid>{35dfa325-e805-4129-b04d-aa970089b9a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn7onoff</objectName>
  <x>350</x>
  <y>309</y>
  <width>20</width>
  <height>20</height>
  <uuid>{afb0987c-4e13-4e15-a997-7840575a22ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn7</objectName>
  <x>339</x>
  <y>335</y>
  <width>46</width>
  <height>24</height>
  <uuid>{8af8cf71-dce7-49c4-be2b-c8ef25dd5990}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn6onoff</objectName>
  <x>296</x>
  <y>309</y>
  <width>20</width>
  <height>20</height>
  <uuid>{476cbcbe-7813-4256-8085-28b8b2922a97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn6</objectName>
  <x>285</x>
  <y>335</y>
  <width>46</width>
  <height>24</height>
  <uuid>{9f018654-8404-43c5-a2bb-9c207144bcd6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>6</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn5onoff</objectName>
  <x>242</x>
  <y>308</y>
  <width>20</width>
  <height>20</height>
  <uuid>{9135a666-1272-4ae1-a067-7c22cccff5a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn5</objectName>
  <x>231</x>
  <y>334</y>
  <width>46</width>
  <height>24</height>
  <uuid>{ec7045f9-c406-454d-8541-f2a07c64cbc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn4onoff</objectName>
  <x>187</x>
  <y>309</y>
  <width>20</width>
  <height>20</height>
  <uuid>{94882fa4-d421-43d9-b2d2-0ac2c8efb45c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn4</objectName>
  <x>176</x>
  <y>335</y>
  <width>46</width>
  <height>24</height>
  <uuid>{34e8adc1-1b29-43b9-b3f9-cf7b993af60d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>4</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn3onoff</objectName>
  <x>133</x>
  <y>308</y>
  <width>20</width>
  <height>20</height>
  <uuid>{44a6a0ea-a97a-45c3-830e-64da5fa439fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn3</objectName>
  <x>122</x>
  <y>334</y>
  <width>46</width>
  <height>24</height>
  <uuid>{313fcf20-6a83-4d8a-98e2-3add34c94a4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn2onoff</objectName>
  <x>79</x>
  <y>308</y>
  <width>20</width>
  <height>20</height>
  <uuid>{de51d045-5e82-47ed-a601-d107b13bc9d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn2</objectName>
  <x>68</x>
  <y>334</y>
  <width>46</width>
  <height>24</height>
  <uuid>{19ec1833-8ce6-4442-a859-7279b5e3ddc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>chn1onoff</objectName>
  <x>25</x>
  <y>307</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c47bfdb9-3494-4095-93fa-3eae4461f4fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>130</x>
  <y>265</y>
  <width>245</width>
  <height>31</height>
  <uuid>{e2268fc2-cf52-45fa-b654-a8c601f1ccd5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Channels to Record</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn1</objectName>
  <x>14</x>
  <y>333</y>
  <width>46</width>
  <height>24</height>
  <uuid>{745c8cba-6467-4659-9d40-ec087f7772a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>3</y>
  <width>760</width>
  <height>40</height>
  <uuid>{f3f21629-5cab-4c50-a594-46213a503e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SOUNDFILE RECORD</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>26</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>709</x>
  <y>231</y>
  <width>39</width>
  <height>29</height>
  <uuid>{1d062c89-e661-430e-8647-f03a8a4fadb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ms</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>660</x>
  <y>231</y>
  <width>39</width>
  <height>29</height>
  <uuid>{e18b5191-3e6c-4a61-a388-41f20c8f43d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>sec</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>614</x>
  <y>231</y>
  <width>39</width>
  <height>29</height>
  <uuid>{634cb2c0-49e3-4ef0-b971-09ba27ff5129}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>min</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>569</x>
  <y>231</y>
  <width>39</width>
  <height>29</height>
  <uuid>{4cb96290-1301-43e5-bd39-cb8ed59f8d4d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>hh</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>694</x>
  <y>259</y>
  <width>14</width>
  <height>29</height>
  <uuid>{3f0ac4fd-450b-482f-ab72-96412d3d8deb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>603</x>
  <y>260</y>
  <width>14</width>
  <height>29</height>
  <uuid>{4beef8d4-ae1b-4c10-bc10-87c79e5ef023}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ms</objectName>
  <x>707</x>
  <y>260</y>
  <width>44</width>
  <height>30</height>
  <uuid>{d9a6d4d0-802f-4933-bc59-2bccd93d25e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>000</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>hor</objectName>
  <x>572</x>
  <y>258</y>
  <width>32</width>
  <height>32</height>
  <uuid>{72671701-102b-4ea4-937e-44e883530d3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>612</x>
  <y>49</y>
  <width>102</width>
  <height>31</height>
  <uuid>{b479e267-dbf7-4fa1-ae08-add2be618296}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Messages</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>message</objectName>
  <x>560</x>
  <y>80</y>
  <width>210</width>
  <height>42</height>
  <uuid>{3a1133e2-10fd-4f4c-ae93-037ed64cb051}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Waiting ...</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>55</x>
  <y>503</y>
  <width>65</width>
  <height>32</height>
  <uuid>{29891b99-799b-4dd5-ad28-b964808743e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>gain</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>649</x>
  <y>259</y>
  <width>14</width>
  <height>29</height>
  <uuid>{dd92fbfd-79d6-4290-8009-71394ba42296}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sec</objectName>
  <x>661</x>
  <y>259</y>
  <width>35</width>
  <height>31</height>
  <uuid>{776dbf01-4b01-4f20-9b43-879ef0e01b42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>min</objectName>
  <x>614</x>
  <y>259</y>
  <width>37</width>
  <height>30</height>
  <uuid>{ecfd7c3d-fce6-46a9-b1fc-cf364f93a1c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>stop</objectName>
  <x>185</x>
  <y>228</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ffae3ed8-07b3-4b32-b5c8-e207d5948519}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>record</objectName>
  <x>95</x>
  <y>228</y>
  <width>78</width>
  <height>26</height>
  <uuid>{17b5a29b-6c4d-46e0-b743-23f8dcd30d46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Record</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>gain_disp</objectName>
  <x>266</x>
  <y>503</y>
  <width>98</width>
  <height>31</height>
  <uuid>{8b592579-fea3-4ccc-afa8-8247970d271a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-11.12 dB</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gain</objectName>
  <x>125</x>
  <y>503</y>
  <width>136</width>
  <height>31</height>
  <uuid>{76022b63-0105-462d-ac4a-df6484e17d4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-18.00000000</minimum>
  <maximum>18.00000000</maximum>
  <value>-11.11764706</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>137</x>
  <y>143</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f9e7606f-af68-4856-9eae-13c95f9d334f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/jh/record.wav</stringvalue>
  <text>Output File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>46</y>
  <width>543</width>
  <height>72</height>
  <uuid>{d54cb51a-9937-4d7c-aeca-8a9ff7836ef0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Set nchnls according to your audio device. Select output file. Adjust input channels and check the channels to want to reacord. Run Csound. Push the Record button to start recording.</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
