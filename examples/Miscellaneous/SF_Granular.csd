<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****GRANULAR SYNTHESIS OF A SOUNDFILE*****/
;example for qutecsound
;written by joachim heintz (with thanks to Oeyvind Brandtsegg)
;jan 2010
;please send bug reports and suggestions
;to jh at joachimheintz.de


nchnls = 2
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
giDisttab	ftgen		0, 0, 32768, 7, 0, 32768, 1	; for kdistribution
giCosine	ftgen		0, 0, 8193, 9, 1, 1, 90		; cosine
giPan		ftgen		0, 0, 32768, -21, 1			; for panning (random values between 0 and 1)


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
;;write the soundfile to the buffer (ftable) giSound
Sfile		invalue	"_Browse1"
giFile		ftgen		0, 0, 0, -1, Sfile, 0, 0, 1

;;select shape of the grain envelope and show it
kwinshape	invalue	"winshape"; 0=Hamming, 1=von Hann, 2=Bartlett, 3=Triangle, 4=Blackman-Harris,
						;5=Gauss, 6=Kaiser, 7=Rectangle, 8=Sync
		event_i	"i", 10, 0, -1, i(kwinshape)+1
		outvalue	"ftab", 12-(kwinshape); graph widget shows selected window shape

;;triggers i 10 at the beginning and whenever the grain envelope has changed
gksamplepos	init		0; position of the pointer through the sample
kchanged	changed	kwinshape; sends 1 if the windowshape has changed
 if kchanged == 1 then
		event		"i", -10, 0, -1; turn off previous instance of i10
		event		"i", 10, 0, -1, kwinshape+1, gksamplepos; turn on new instance
 endif
endin

instr 10; performs granular synthesis
;;used parameters for the partikkel opcode
iwin		=		p4; shape of the grain window 
igksamplepos	=		p5; pointer position at the beginning
ifiltab	=		giFile; buffer to read
kspeed		invalue	"speed"; speed of reading the buffer (1=normal)
kspeed0	invalue	"speed0"; set playback speed to 0
kspeed1	invalue	"speed1"; set playback speed to 1
kgrainrate	invalue	"grainrate"; grains per second
kgrainsize	invalue	"grainsize"; length of the grains in ms
kcent		invalue	"transp"; pitch transposition in cent
kgrainamp	invalue	"gain"; volume
kdist		invalue	"dist"; distribution (0=periodic, 1=scattered)
kposrand	invalue	"posrand"; time position randomness (offset) of the read pointer in ms
kcentrand	invalue	"centrand"; transposition randomness in cents (up and down)
kpan		invalue	"pan"; panning narrow (0) to wide (1)
icosintab	=		giCosine; ftable with a cosine waveform
idisttab	=		giDisttab; ftable with values for scattered distribution 
kwaveform	= 		giFile; source waveform
imax_grains	=		200; maximum number of grains per k-period

;;speed either by slider value or by checkbox
kspeed		=		(kspeed0==1 && kspeed1==1 ? 1 : (kspeed0==1 ? 0 : (kspeed1==1 ? 1 : kspeed)))

;;unused parameters for the partikkel opcode
async		= 		0; sync input (disabled)	
kenv2amt	= 		1; use only secondary envelope
ienv2tab 	= 		iwin; grain (secondary) envelope
ienv_attack	= 		-1; default attack envelope (flat)
ienv_decay	= 		-1; default decay envelope (flat)
ksustain_amount = 		0.5; no meaning in this case (use only secondary envelope, ienv2tab)
ka_d_ratio	= 		0.5; no meaning in this case (use only secondary envelope, ienv2tab)
igainmasks	= 		-1; (default) no gain masking
ksweepshape	= 		0; no frequency sweep
iwavfreqstarttab = 		-1; default frequency sweep start
iwavfreqendtab = 		-1; default frequency sweep end
awavfm		= 		0; no FM input
ifmamptab	= 		-1; default FM scaling (=1)
kfmenv		= 		-1; default FM envelope (flat)
icosine	= 		giCosine; cosine ftable
kTrainCps	= 		kgrainrate; set trainlet cps equal to grain rate
knumpartials	= 		1; number of partials in trainlet
kchroma	= 		1; balance of partials in trainlet
krandommask	= 		0; random gain masking (disabled)
iwaveamptab	=		-1; (default) equal mix of source waveforms and no amplitude for trainlets
kwavekey	= 		1; original key for each source waveform

;get length of source wave file, needed for both transposition and time pointer
ifilen		tableng	giFile
ifildur	= 		ifilen / sr
;amplitude
kamp		= 		kgrainamp * 0dbfs; grain amplitude
;transposition
kcentrand	rand 		kcentrand; random transposition
iorig		= 		1 / ifildur; original pitch
kwavfreq	= 		iorig * cent(kcent + kcentrand)
;panning, using channel masks
		tableiw	0, 0, giPan; change index 0 ...
		tableiw	32766, 1, giPan; ... and 1 for ichannelmasks
ichannelmasks = 		giPan; ftable for panning

;;time pointer
afilposphas		phasor kspeed / ifildur, igksamplepos; in general
;generate random deviation of the time pointer
kposrandsec		= kposrand / 1000	; ms -> sec
kposrand		= kposrandsec / ifildur	; phase values (0-1)
arndpos		linrand	 kposrand	; random offset in phase values
;add random deviation to the time pointer
asamplepos		= afilposphas + arndpos; resulting phase values (0-1)
gksamplepos		downsamp	asamplepos; export pointer position 

agrL, agrR	partikkel kgrainrate, kdist, giDisttab, async, kenv2amt, ienv2tab, \
		ienv_attack, ienv_decay, ksustain_amount, ka_d_ratio, kgrainsize, kamp, igainmasks, \
		kwavfreq, ksweepshape, iwavfreqstarttab, iwavfreqendtab, awavfm, \
		ifmamptab, kfmenv, icosine, kTrainCps, knumpartials, \
		kchroma, ichannelmasks, krandommask, kwaveform, kwaveform, kwaveform, kwaveform, \
		iwaveamptab, asamplepos, asamplepos, asamplepos, asamplepos, \
		kwavekey, kwavekey, kwavekey, kwavekey, imax_grains

;panning, modifying the values of ichannelmasks
imid		= 		.5; center
kleft		= 		imid - kpan/2
kright		=		imid + kpan/2
apL1, apR1	pan2		agrL, kleft
apL2, apR2	pan2		agrR, kright
aL		=		apL1 + apL2
aR		=		apR1 + apR2
		outs		aL, aR

;;show output
kdbrange	invalue	"dbrange"  ;dB range for the meters
kpeakhold	invalue	"peakhold"  ;Duration of clip indicator hold in seconds
kTrigDisp	metro		10
		ShowLED_a	"outL", aL, kTrigDisp, 1, kdbrange
		ShowLED_a	"outR", aR, kTrigDisp, 1, kdbrange
		ShowOver_a	"outLover", aL, kTrigDisp, kpeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, kpeakhold
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
WindowBounds: 356 92 906 818
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {9, 9} {872, 43} label 0.000000 0.00100 "" center "Lucida Grande" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder GRANULAR SYNTHESIS OF A SOUNDFILE
ioText {9, 58} {872, 66} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Granulates a stored sound. You can use either a mono or stereo soundfile (from the latter just channel 1 is used).
ioText {9, 130} {483, 72} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border  INPUT
ioSlider {185, 186} {173, 0} 0.000000 1.000000 0.000000 slider7
ioText {499, 131} {383, 119} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border  OUTPUT
ioMeter {511, 197} {335, 18} {0, 59904, 0} "out2_post" 0.000000 "outL" 0.371216 fill 1 0 mouse
ioMeter {844, 197} {26, 18} {50176, 3584, 3072} "outRover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioText {374, 210} {79, 27} editnum 50.000000 0.100000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50.000000
ioText {295, 209} {79, 28} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB-Range
ioText {32, 211} {139, 24} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show LED's as
ioMenu {171, 208} {108, 28} 1 303 "Amplitudes,dB" showdb
ioGraph {9, 254} {432, 82} scope 2.000000 1.000000 
ioText {10, 352} {873, 399} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border GRANULAR
ioText {510, 164} {95, 27} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output Gain
ioSlider {606, 165} {205, 24} 0.000000 5.000000 0.780488 gain
ioText {812, 164} {61, 27} display 0.000000 0.00100 "gain" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.8293
ioText {47, 389} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Grains per Second
ioText {279, 555} {235, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Transposition (Cent)
ioSlider {269, 579} {242, 25} -1200.000000 1200.000000 0.000000 transp
ioText {307, 603} {169, 26} display 0.000000 0.00100 "transp" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0000
ioText {66, 558} {101, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Grainsize (ms)
ioSlider {41, 580} {152, 25} 1.000000 100.000000 30.309211 grainsize
ioText {73, 603} {81, 26} display 0.000000 0.00100 "grainsize" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 31.6118
ioSlider {42, 416} {152, 25} 1.000000 200.000000 67.769737 grainrate
ioText {74, 438} {81, 26} display 67.769737 0.00100 "grainrate" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 67.7697
ioText {45, 472} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Distribution
ioSlider {40, 498} {152, 25} 0.000000 1.000000 1.000000 dist
ioText {264, 475} {258, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Position Randomness (ms)
ioSlider {269, 500} {248, 26} 0.000000 1000.000000 0.000000 posrand
ioText {312, 522} {148, 26} display 0.000000 0.00100 "posrand" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0000
ioSlider {271, 661} {242, 26} 0.000000 600.000000 0.000000 centrand
ioText {351, 688} {81, 26} display 0.000000 0.00100 "centrand" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0000
ioText {271, 638} {234, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Transposition Randomness (Cent)
ioText {21, 518} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder periodic
ioText {143, 518} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder scattered
ioText {676, 366} {115, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Window Shape
ioMenu {664, 417} {144, 24} 0 303 "Hamming,von Hann,Triangle,Blackman,Blackman-Harris,Gauss,Kaiser,Rectangle,Sync" winshape
ioGraph {607, 470} {264, 176} table 12.000000 1.000000 ftab
ioText {648, 442} {168, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ... and see its shape
ioText {634, 392} {185, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select window function ...
ioText {24, 162} {351, 23} edit 0.000000 0.00100 "_Browse1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioButton {383, 160} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioGraph {452, 254} {431, 82} scope 2.000000 2.000000 
ioMeter {511, 222} {335, 18} {0, 59904, 0} "out2_post" 0.000000 "outR" 0.412916 fill 1 0 mouse
ioMeter {844, 222} {26, 18} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {51, 637} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Panning
ioSlider {46, 663} {152, 25} 0.000000 1.000000 0.506579 pan
ioText {27, 683} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder narrow
ioText {149, 683} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder wide
ioText {334, 386} {119, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Playback Speed
ioSlider {269, 415} {245, 28} -2.000000 2.000000 1.020408 speed
ioText {303, 439} {172, 29} display 1.020408 0.00100 "speed" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.0204
ioCheckbox {268, 388} {20, 20} off speed0
ioCheckbox {496, 388} {20, 20} off speed1
ioText {288, 386} {20, 25} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0
ioText {475, 386} {20, 25} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="360" y="248" width="596" height="322"> 








</EventPanel>