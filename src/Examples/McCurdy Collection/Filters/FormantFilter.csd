;WRITTEN BY IAIN MCCURDY, 2008

;Modified for QuteCsound by René, October 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files
;	replaced (1-gkf1)...(1-gkf5) by gkf1...gkf5 because QC slider limit values cannot be reversed
;	Changed macro FORMANT_DATA to accept NUM as a parameter.


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


givoice_os	ftgen	0, 0, 8, -2, 0, 15, 30, 45, 60		;TABLE OF OFFSET VALUES USED WHEN READING FORMANT DATA - WHICH OFFSET VALUE IS CHOSEN DEPENDS ON WHAT VOICE TYPE IS SELECTED	

;TABLE FOR EXP SLIDER
giExp4a		ftgen	0, 0, 129, -25, 0, 0.01, 128, 4.0
giExp4b		ftgen	0, 0, 129, -25, 0, 0.25, 128, 4.0
giExp500		ftgen	0, 0, 129, -25, 0, 20.0, 128, 500.0


opcode FilePlay2, aa, Skoo		; Credit to Joachim Heintz
	;gives stereo output regardless your soundfile is mono or stereo
	Sfil, kspeed, iskip, iloop	xin
	ichn		filenchnls	Sfil
	if ichn == 1 then
		aL		diskin2	Sfil, kspeed, iskip, iloop
		aR		=		aL
	else
		aL, aR	diskin2	Sfil, kspeed, iskip, iloop
	endif
		xout		aL, aR
endop


instr	1	;GUI

	Sfile_new			strcpy		""						;INIT TO EMPTY STRING

	ktrig	metro	10
	if (ktrig == 1)	then
		kBWMlt		invalue	 	"Bandwidths_Multiply"
		gkBWMlt		tablei		kBWMlt, giExp4a, 1
					outvalue		"Bandwidths_Multiply_Value", gkBWMlt
		kFrqMlt		invalue 		"Frequencies_Multiply"
		gkFrqMlt		tablei		kFrqMlt, giExp4b, 1
					outvalue		"Frequencies_Multiply_Value", gkFrqMlt
		gkmix		invalue 		"Dry_Wet_Mix"
		gkgain		invalue 		"Global_Gain"
		gkInGain		invalue 		"In_Gain"
		kBuzFrq		invalue 		"Buzz_Freq"
		gkBuzFrq		tablei		kBuzFrq, giExp500, 1
					outvalue		"Buzz_Freq_Value", gkBuzFrq

		gkf1			invalue 		"f1"
		gkf2			invalue 		"f2"
		gkf3			invalue 		"f3"
		gkf4			invalue 		"f4"
		gkf5			invalue 		"f5"

		gkx			invalue		"Vowel_X"
		gky			invalue		"Vowel_Y"

		gkinput		invalue		"Input"
		gkvoice		invalue		"Voice"

		gSfile		invalue		"_Browse"
		Sfile_old		strcpyk		Sfile_new
		Sfile_new		strcpyk		gSfile
		gkfile 		strcmpk		Sfile_new, Sfile_old
	endif
endin

instr	2															;PLAYS FILE AND SENSES FADER MOVEMENT AND RESTARTS INSTR FOR I-RATE CONTROLLERS
	ibit		=		16												;BIT DEPTH OF THE SOUNDFILE USED
	ginorm	=		(2^ibit)*0.5										;MULTIPLIER USED TO NORMALISE THE AUDIO SIGNAL BETWEEN ZERO AND 1
	iporttime	=		.1
	kporttime	linseg	0,.001,iporttime,1,iporttime							;PORTAMENTO TIME                                                      
	kBuzFrq	portk	gkBuzFrq, kporttime                   					;K-RATE PORTAMENTO TIME - RISES QUICKLY TO DESIRED VALUE THEN HOLDS IT

	if		gkinput=0	then												;IF 'Live' IS SELECTED FOR INPUT
		asigL	inch	1												;READ AUDIO FROM CHANNEL 1 (LEFT)
		asigL	=	asigL * gkInGain									;ATTENUATE AUDIO FROM CHANNEL 1 USING 'gkInGain' CONTROL
		asigR	inch	2                         							;READ AUDIO FROM CHANNEL 2 (RIGHT)                       
		asigR	=	asigR * gkInGain									;ATTENUATE AUDIO FROM CHANNEL 2 USING 'gkInGain' CONTROL
	elseif	gkinput=1	then												;IF 'Buzz' IS SELECTED FOR INPUT
		;OUT		OPCODE	AMPLITUDE | INTERVAL (BETWEEN PULSES)
		asigL	mpulse	32768,      1/kBuzFrq
		asigR	=	asigL											;SET asigR TO BE IDENTICAL TO asigL (THE 'BUZZING' TONE) 
	else																;IF NEITHER OF THE FIRST 2 OPTIONS FOR INPUT ARE USED... (ONLY ONE OPTION REMAINS)
		kNew_file		changed	gkfile									;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
		if	kNew_file=1	then											;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
			reinit	NEW_FILE											;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
		endif
		NEW_FILE:
		;OUTPUTS		OPCODE	FILE  | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
		asigL, asigR	FilePlay2	gSfile,  1,      0,         1					;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE
					rireturn											;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
	endif
		
	asigL		=	asigL/ginorm										;NORMALISE BOTH CHANNELS OF AUDIO
	asigR		=	asigR/ginorm										;NORMALISE BOTH CHANNELS OF AUDIO
	                                                                                                                                                           
	kSwitch		changed	gkvoice										;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then													;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif
	START:
	ivoice_os		table	i(gkvoice), givoice_os							;READ TABLE OFFSET VALUE FROM FUNCTION TABLE 'givoice_os' - THESE ARE USED TO SELECT THE DIFFERENT DATA SET CORRESPONDING TO THE 5 DIFFERENT VOICE TYPES
		
	;A TEXT MACRO IS DEFINED THAT WILL BE THE CODE FOR DERIVING DATA FOR EACH FORMANT. A MACRO IS USED TO AVOID HAVING TO USING CODE REPETITION AND TO EASIER FACICLITATE CODE MODIFICATION
#define	FORMANT_DATA(NUM')	#
	kfreq$NUM._U	table	(gkx)*(3/5),$NUM+ivoice_os, 1					;READ DATA FOR FREQUENCY (UPPER EDGE OF PANEL)
	kfreq$NUM._L	table	((1-gkx)*(1/5))+(4/5),$NUM+ivoice_os, 1				;READ DATA FOR FREQUENCY (LOWER EDGE OF PANEL)
	kfreq$NUM		ntrpol	kfreq$NUM._L, kfreq$NUM._U, gky						;INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)                          
	kfreq$NUM		=		kfreq$NUM * gkFrqMlt							;MULTIPLY FREQUENCY VALUE BY VALUE FROM 'Frequency Multiply' SLIDER
	kdbamp$NUM._U	table	(gkx)*(3/5),$NUM+ivoice_os+5, 1					;READ DATA FOR INTENSITY (UPPER EDGE OF PANEL)                                      
	kdbamp$NUM._L	table	((1-gkx)*(1/5))+(4/5),$NUM+ivoice_os+5, 1				;READ DATA FOR INTENSITY (LOWER EDGE OF PANEL)                                      
	kdbamp$NUM	ntrpol	kdbamp$NUM._L, kdbamp$NUM._U, gky						;INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)
	kbw$NUM._U		table	(gkx)*(3/5),$NUM+ivoice_os+10, 1					;READ DATA FOR BANDWIDTH (UPPER EDGE OF PANEL)                                      
	kbw$NUM._L		table	((1-gkx)*(1/5))+(4/5),$NUM+ivoice_os+10, 1				;READ DATA FOR BANDWIDTH (LOWER EDGE OF PANEL)                                      
	kbw$NUM		ntrpol	kbw$NUM._L, kbw$NUM._U, gky							;INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)
	kbw$NUM		=		kbw$NUM*gkBWMlt								;MULTIPLY BANDWIDTH VALUE BY VALUE FROM 'Bandwidth Multiply' SLIDER

	if 	kDisplayTrigger == 1	then
		outvalue	"freq$NUM", kfreq$NUM									;UPDATE DISPLAY OF FREQUENCY VALUE IN THE ON-SCREEN VALUATOR BOX                                                          
		outvalue	"db$NUM", kdbamp$NUM									;UPDATE DISPLAY OF INTENSITY VALUE IN THE ON-SCREEN VALUATOR BOX                                                          
		outvalue	"bw$NUM", kbw$NUM										;UPDATE DISPLAY OF BANDWIDTH VALUE IN THE ON-SCREEN VALUATOR BOX                                                          
	endif
	#																;END OF MACRO!
	
	kDisplayTrigger	metro	10										;CREATE A TRIGGER METRONOME (USED TO UPDATE VALUATOR BOX DISPLAYS

;READING DATA FOR FORMANTS (MACROS IMPLEMENTED)
	$FORMANT_DATA(1')
	$FORMANT_DATA(2')
	$FORMANT_DATA(3')
	$FORMANT_DATA(4')
	$FORMANT_DATA(5')

				rireturn											;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
	
	kfreq1		portk	kfreq1,	kporttime							;PORTAMENTO APPLIED TO VALUE TO SMOOTH TRANSITIONS
	kfreq2		portk	kfreq2,	kporttime
	kfreq3		portk	kfreq3,	kporttime
	kfreq4		portk	kfreq4,	kporttime
	kfreq5		portk	kfreq5,	kporttime
	kdbamp1		portk	kdbamp1,	kporttime
	kdbamp2		portk	kdbamp2,	kporttime
	kdbamp3		portk	kdbamp3,	kporttime
	kdbamp4		portk	kdbamp4,	kporttime
	kdbamp5		portk	kdbamp5,	kporttime
	kbw1			portk	kbw1,	kporttime
	kbw2			portk	kbw2,	kporttime
	kbw3			portk	kbw3,	kporttime
	kbw4			portk	kbw4,	kporttime
	kbw5			portk	kbw5,	kporttime
	
	aBPF1L		reson	asigL, kfreq1, kbw1, 1						;FORMANT 1
	aBPF1R		reson	asigR, kfreq1, kbw1, 1

	aBPF2L		reson	asigL, kfreq2, kbw2, 1						;FORMANT 2
	aBPF2R		reson	asigR, kfreq2, kbw2, 1

	aBPF3L		reson	asigL, kfreq3, kbw3, 1						;FORMANT 3
	aBPF3R		reson	asigR, kfreq3, kbw3, 1

	aBPF4L		reson	asigL, kfreq4, kbw4, 1						;FORMANT 4
	aBPF4R		reson	asigR, kfreq4, kbw4, 1

	aBPF5L		reson	asigL, kfreq5, kbw5, 1						;FORMANT 5
	aBPF5R		reson	asigR, kfreq5, kbw5, 1
	
	;FORMANTS ARE MIXED AND MULTIPLIED BOTH BY INTENSITY VALUES DERIVED FROM TABLES AND BY THE ON-SCREEN GAIN CONTROLS FOR EACH FORMANT 
	aMixL		sum		aBPF1L*(ampdbfs(kdbamp1))*gkf1, aBPF2L*(ampdbfs(kdbamp2))*gkf2, aBPF3L*(ampdbfs(kdbamp3))*gkf3, aBPF4L*(ampdbfs(kdbamp4))*gkf4, aBPF5L*(ampdbfs(kdbamp5))*gkf5
	aMixR		sum		aBPF1R*(ampdbfs(kdbamp1))*gkf1, aBPF2R*(ampdbfs(kdbamp2))*gkf2, aBPF3R*(ampdbfs(kdbamp3))*gkf3, aBPF4R*(ampdbfs(kdbamp4))*gkf4, aBPF5R*(ampdbfs(kdbamp5))*gkf5

	aOutMixL		ntrpol	asigL*ginorm, aMixL*gkgain, gkmix				;MIX BETWEEN DRY AND WET SIGNALS
	aOutMixR		ntrpol	asigR*ginorm, aMixR*gkgain, gkmix

				outs		aOutMixL, aOutMixR							;SEND AUDIO TO OUTPUTS
endin
</CsInstruments>
<CsScore>
;FUNCTION TABLES STORING FORMANT DATA FOR EACH OF THE FIVE VOICE TYPES REPRESENTED
;BASS
f 1  0 32768 -7 	600	10922	400	10922	250	10924	350	;FREQ
f 2  0 32768 -7 	1040	10922	1620	10922	1750	10924	600	;FREQ
f 3  0 32768 -7	2250	10922	2400	10922	2600	10924	2400	;FREQ
f 4  0 32768 -7	2450	10922	2800	10922	3050	10924	2675	;FREQ
f 5  0 32768 -7	2750	10922	3100	10922	3340	10924	2950	;FREQ
f 6  0 32768 -7	0	10922	0	10922	0	10924	0	;dB
f 7  0 32768 -7	-7	10922	-12	10922	-30	10924	-20	;dB
f 8  0 32768 -7	-9	10922	-9	10922	-16	10924	-32	;dB
f 9  0 32768 -7	-9	10922	-12	10922	-22	10924	-28	;dB
f 10 0 32768 -7	-20	10922	-18	10922	-28	10924	-36	;dB
f 11 0 32768 -7	60	10922	40	10922	60	10924	40	;BAND WIDTH
f 12 0 32768 -7	70	10922	80	10922	90	10924	80	;BAND WIDTH
f 13 0 32768 -7	110	10922	100	10922	100	10924	100	;BAND WIDTH
f 14 0 32768 -7	120	10922	120	10922	120	10924	120	;BAND WIDTH
f 15 0 32768 -7	130	10922	120	10922	120	10924	120	;BAND WIDTH
;TENOR
f 16 0 32768 -7	 650 8192	 400	8192	290	8192	400	8192	350	;FREQ
f 17 0 32768 -7	1080 8192	1700 8192	1870	8192	800	8192	600	;FREQ
f 18 0 32768 -7	2650	8192	2600 8192	2800	8192	2600	8192	2700	;FREQ
f 19 0 32768 -7	2900	8192	3200 8192	3250	8192	2800	8192	2900	;FREQ
f 20 0 32768 -7	3250	8192	3580 8192	3540	8192	3000	8192	3300	;FREQ
f 21 0 32768 -7	0	8192	0	8192	0	8192	0	8192	0	;dB
f 22 0 32768 -7	-6	8192	-14	8192	-15	8192	-10	8192	-20	;dB
f 23 0 32768 -7	-7	8192	-12	8192	-18	8192	-12	8192	-17	;dB
f 24 0 32768 -7	-8	8192	-14	8192	-20	8192	-12	8192	-14	;dB
f 25 0 32768 -7	-22	8192	-20	8192	-30	8192	-26	8192	-26	;dB
f 26 0 32768 -7	80	8192	70	8192	40	8192	40	8192	40	;BAND WIDTH
f 27 0 32768 -7	90	8192	80	8192	90	8192	80	8192	60	;BAND WIDTH
f 28 0 32768 -7	120	8192	100	8192	100	8192	100	8192	100	;BAND WIDTH
f 29 0 32768 -7	130	8192	120	8192	120	8192	120	8192	120	;BAND WIDTH
f 30 0 32768 -7	140	8192	120	8192	120	8192	120	8192	120	;BAND WIDTH
;COUNTER TENOR
f 31 0 32768 -7 	660	8192	440	8192	270	8192	430	8192	370	;FREQ
f 32 0 32768 -7 	1120	8192	1800	8192	1850	8192	820	8192	630	;FREQ
f 33 0 32768 -7	2750	8192	2700	8192	2900	8192	2700	8192	2750	;FREQ
f 34 0 32768 -7	3000	8192	3000	8192	3350	8192	3000	8192	3000	;FREQ
f 35 0 32768 -7	3350	8192	3300	8192	3590	8192	3300	8192	3400	;FREQ
f 36 0 32768 -7	0	8192	0	8192	0	8192	0	8192	0	;dB
f 37 0 32768 -7	-6	8192	-14	8192	-24	8192	-10	8192	-20	;dB
f 38 0 32768 -7	-23	8192	-18	8192	-24	8192	-26	8192	-23	;dB
f 39 0 32768 -7	-24	8192	-20	8192	-36	8192	-22	8192	-30	;dB
f 40 0 32768 -7	-38	8192	-20	8192	-36	8192	-34	8192	-30	;dB
f 41 0 32768 -7	80	8192	70	8192	40	8192	40	8192	40	;BAND WIDTH
f 42 0 32768 -7	90	8192	80	8192	90	8192	80	8192	60	;BAND WIDTH
f 43 0 32768 -7	120	8192	100	8192	100	8192	100	8192	100	;BAND WIDTH
f 44 0 32768 -7	130	8192	120	8192	120	8192	120	8192	120	;BAND WIDTH
f 45 0 32768 -7	140	8192	120	8192	120	8192	120	8192	120	;BAND WIDTH
;ALTO
f 46 0 32768 -7	800	8192	400	8192	350	8192	450	8192	325	;FREQ
f 47 0 32768 -7	1150	8192	1600	8192	1700	8192	800	8192	700	;FREQ
f 48 0 32768 -7	2800	8192	2700	8192	2700	8192	2830	8192	2530	;FREQ
f 49 0 32768 -7	3500	8192	3300	8192	3700	8192	3500	8192	2500	;FREQ
f 50 0 32768 -7	4950	8192	4950	8192	4950	8192	4950	8192	4950	;FREQ
f 51 0 32768 -7	0	8192	0	8192	0	8192	0	8192	0	;dB
f 52 0 32768 -7	-4	8192	-24	8192	-20	8192	-9	8192	-12	;dB
f 53 0 32768 -7	-20	8192	-30	8192	-30	8192	-16	8192	-30	;dB
f 54 0 32768 -7	-36	8192	-35	8192	-36	8192	-28	8192	-40	;dB
f 55 0 32768 -7	-60	8192	-60	8192	-60	8192	-55	8192	-64	;dB
f 56 0 32768 -7	50	8192	60	8192	50	8192	70	8192	50	;BAND WIDTH
f 57 0 32768 -7	60	8192	80	8192	100	8192	80	8192	60	;BAND WIDTH
f 58 0 32768 -7	170	8192	120	8192	120	8192	100	8192	170	;BAND WIDTH
f 59 0 32768 -7	180	8192	150	8192	150	8192	130	8192	180	;BAND WIDTH
f 60 0 32768 -7	200	8192	200	8192	200	8192	135	8192	200	;BAND WIDTH
;SOPRANO
f 61 0 32768 -7	800	8192	350	8192	270	8192	450	8192	325	;FREQ
f 62 0 32768 -7	1150	8192	2000	8192	2140	8192	800	8192	700	;FREQ
f 63 0 32768 -7	2900	8192	2800	8192	2950	8192	2830	8192	2700	;FREQ
f 64 0 32768 -7	3900	8192	3600	8192	3900	8192	3800	8192	3800	;FREQ
f 65 0 32768 -7	4950	8192	4950	8192	4950	8192	4950	8192	4950	;FREQ
f 66 0 32768 -7	0	8192	0	8192	0	8192	0	8192	0	;dB
f 67 0 32768 -7	-6	8192	-20	8192	-12	8192	-11	8192	-16	;dB
f 68 0 32768 -7	-32	8192	-15	8192	-26	8192	-22	8192	-35	;dB
f 69 0 32768 -7	-20	8192	-40	8192	-26	8192	-22	8192	-40	;dB
f 70 0 32768 -7	-50	8192	-56	8192	-44	8192	-50	8192	-60	;dB
f 71 0 32768 -7	80	8192	60	8192	60	8192	70	8192	50	;BAND WIDTH
f 72 0 32768 -7	90	8192	90	8192	90	8192	80	8192	60	;BAND WIDTH
f 73 0 32768 -7	120	8192	100	8192	100	8192	100	8192	170	;BAND WIDTH
f 74 0 32768 -7	130	8192	150	8192	120	8192	130	8192	180	;BAND WIDTH
f 75 0 32768 -7	140	8192	200	8192	120	8192	135	8192	200	;BAND WIDTH

;INSTR | START | DURATION
i  1      0       3600		;INSTRUMENT 1 PLAYS FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>73</x>
 <y>60</y>
 <width>857</width>
 <height>702</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>512</width>
  <height>700</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Formant Filter</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>515</x>
  <y>2</y>
  <width>342</width>
  <height>700</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Formant Filter</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>33</y>
  <width>334</width>
  <height>659</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------
This example uses five 'reson' bandpass filters to imitate the filtering effect of the human mouth when expressing various vowel sounds.
 These five resonant peaks are referred to as 'formants'. Each formant consists of data for frequency, intensity (in decibels) and bandwith for each of the five filters.
 The user can morph between different vowel sounds by dragging the cross-hairs of an X-Y panel. The locations of specific vowel sounds are indicated around the edge of the panel.
 Data-sets for five different voice types are selectable using a button-bank selecter.
 Individual gain controls are provided for each formant. Normally these are left at their maximum setting (gain=1, therefore no attenuation).
 Attenuating all formants except the first two will reveal that the character of the formant is chiefly defined by just these two formants. An economic formant filter could be created with just two reson filters. Frequencies can be warped using a global multiplier control. Normally this is set to '1' - no warping.
Bandwidths can be warped in a similar fashion with the 'Bandwidths Multiply' control. The user can choose between three different input sources: the computer's live input, a 'buzz' tone and a soundfile. The 'buzz' tone provides a good imitation of the tone provided by the human vocal chords.
When unpitched noise-like sounds (like the soundfile option) are used the resulting output resembles a whisper. The live audio input is stereo, reading from both channels. A matrix of 15 values boxes at the bottom of the GUI provides the user with information about current frequency, intensity and bandwidth values for the five formants. These boxes are displaying values only.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>6</y>
  <width>100</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  ON / OFF</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Bandwidths_Multiply_Value</objectName>
  <x>448</x>
  <y>169</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.997</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <objectName>Bandwidths_Multiply</objectName>
  <x>8</x>
  <y>152</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.76800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>169</y>
  <width>140</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidths Multiply</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <objectName>_Browse</objectName>
  <x>7</x>
  <y>665</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>Seashore.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>178</x>
  <y>666</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seashore.wav</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>644</y>
  <width>150</width>
  <height>30</height>
  <uuid>{936f6eb0-5225-4bd7-a5fe-a49df1c9c5ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Audio File</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>8</x>
  <y>246</y>
  <width>140</width>
  <height>30</height>
  <uuid>{2e52a7a7-dc13-405e-896d-db2a7431d8dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry / Wet Mix</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <objectName>Dry_Wet_Mix</objectName>
  <x>8</x>
  <y>229</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6ab84e0f-82a7-4b9c-af23-35bd7d9b7fa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Dry_Wet_Mix</objectName>
  <x>448</x>
  <y>246</y>
  <width>60</width>
  <height>30</height>
  <uuid>{99d6bf8b-3c85-4911-a29a-7dd678a940ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <objectName>Global_Gain</objectName>
  <x>448</x>
  <y>286</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aa25cbea-3c62-4a2e-ac25-d9601917f135}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.744</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <objectName>Global_Gain</objectName>
  <x>8</x>
  <y>268</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9f52feb1-7613-4427-b719-6d1431e31982}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>2.74400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>286</y>
  <width>140</width>
  <height>30</height>
  <uuid>{365caef3-3cca-43e5-98c1-92d8f0f139b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Global Gain</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <objectName>Input</objectName>
  <x>141</x>
  <y>40</y>
  <width>80</width>
  <height>30</height>
  <uuid>{3860f844-45b7-4121-8956-590544b3d470}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Live</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Buzz</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>File</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Voice</objectName>
  <x>227</x>
  <y>40</y>
  <width>130</width>
  <height>30</height>
  <uuid>{697d0635-6121-4516-9ebe-ea61fbbaf227}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Bass</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tenor</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Counter Tenor</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Alto</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Soprano</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>f1</objectName>
  <x>382</x>
  <y>6</y>
  <width>19</width>
  <height>120</height>
  <uuid>{952daae8-ce9e-4784-84bc-e773820aa758}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>94</y>
  <width>140</width>
  <height>30</height>
  <uuid>{34e52a93-49d2-46fc-a639-203f6d7305f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live Input Gain</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <objectName>In_Gain</objectName>
  <x>8</x>
  <y>77</y>
  <width>350</width>
  <height>27</height>
  <uuid>{182ed0f4-b0cc-4866-b05f-be5cce1d25f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.63428571</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>In_Gain</objectName>
  <x>298</x>
  <y>94</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0b88f27c-f1c5-4101-a3be-14ce2d3efae1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.634</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>f2</objectName>
  <x>405</x>
  <y>6</y>
  <width>19</width>
  <height>120</height>
  <uuid>{2798de5d-07b5-41db-81ed-eca0d30d88bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>f3</objectName>
  <x>430</x>
  <y>6</y>
  <width>19</width>
  <height>120</height>
  <uuid>{d0daea88-de57-47ed-8a83-a7eecbba00ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>f4</objectName>
  <x>454</x>
  <y>6</y>
  <width>19</width>
  <height>120</height>
  <uuid>{b7e26fad-6a22-4c35-800a-fc5cdc7b65cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>f5</objectName>
  <x>480</x>
  <y>6</y>
  <width>19</width>
  <height>120</height>
  <uuid>{d959b93e-a451-43fb-a220-599d9080d69f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>380</x>
  <y>122</y>
  <width>120</width>
  <height>30</height>
  <uuid>{7db2216b-82db-4029-b459-54ed2f05430e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>f1     f2     f3     f4     f5</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>380</x>
  <y>132</y>
  <width>120</width>
  <height>30</height>
  <uuid>{04e01703-1f49-4ac2-a6f9-83b97af4d60d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Formant Gain</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <objectName>Buzz_Freq_Value</objectName>
  <x>298</x>
  <y>132</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e62e7538-c901-40aa-9f94-5eeda7ec1ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>79.463</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <objectName>Buzz_Freq</objectName>
  <x>8</x>
  <y>115</y>
  <width>350</width>
  <height>27</height>
  <uuid>{8d0d9847-470c-484c-884c-d8c59b63fb3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.42857143</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>132</y>
  <width>140</width>
  <height>30</height>
  <uuid>{8d1a9690-4913-45a9-9270-7e3b4f4a8da6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Buzz Freq</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>8</x>
  <y>207</y>
  <width>140</width>
  <height>30</height>
  <uuid>{f9f4369b-a39e-45aa-ba99-7457a534535f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequencies Multiply</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <objectName>Frequencies_Multiply</objectName>
  <x>8</x>
  <y>190</y>
  <width>500</width>
  <height>27</height>
  <uuid>{42fe25e5-e98f-4f00-872c-f791822a1b3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Frequencies_Multiply_Value</objectName>
  <x>448</x>
  <y>207</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a8f35453-f236-447d-88d9-1a0b135383b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <objectName>Vowel_X</objectName>
  <x>54</x>
  <y>319</y>
  <width>400</width>
  <height>200</height>
  <uuid>{bf2f89b9-a3d7-4443-bf94-f31a51d7e204}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Vowel_Y</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45250000</xValue>
  <yValue>0.54500000</yValue>
  <type>crosshair</type>
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
  <x>27</x>
  <y>319</y>
  <width>29</width>
  <height>31</height>
  <uuid>{d2bbb454-0e36-4bbf-9ac3-8fb65c07c480}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <x>25</x>
  <y>488</y>
  <width>29</width>
  <height>31</height>
  <uuid>{ee772249-cfd6-4da9-a7a4-42cc2e9b34a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>U</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <x>453</x>
  <y>319</y>
  <width>29</width>
  <height>31</height>
  <uuid>{bd4f4431-f257-41b1-9003-488437ebc28a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>I</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <x>454</x>
  <y>488</y>
  <width>29</width>
  <height>31</height>
  <uuid>{16609366-8e1b-4b7c-bd7f-9a72a946047e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>O</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <x>243</x>
  <y>295</y>
  <width>29</width>
  <height>31</height>
  <uuid>{7cc67e00-ba43-4a75-97d5-5397740375a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>E</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <x>209</x>
  <y>512</y>
  <width>92</width>
  <height>29</height>
  <uuid>{9f7b7ad8-88b0-4a40-87ba-8cde4a72a8f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vowel</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <objectName>freq1</objectName>
  <x>137</x>
  <y>567</y>
  <width>60</width>
  <height>25</height>
  <uuid>{d2770e02-dff6-403c-9cee-48ab74bc304e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>410.073</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq2</objectName>
  <x>201</x>
  <y>567</y>
  <width>60</width>
  <height>25</height>
  <uuid>{068a599b-f84e-407a-9ac2-c74a0541eaa1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1301.296</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq4</objectName>
  <x>329</x>
  <y>567</y>
  <width>60</width>
  <height>25</height>
  <uuid>{5622859c-c076-4f6c-b54b-cd2a3b9a2a88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3016.402</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq3</objectName>
  <x>265</x>
  <y>567</y>
  <width>60</width>
  <height>25</height>
  <uuid>{7ccea2e6-e299-4906-9fd8-c86b8fbbf869}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2723.888</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq5</objectName>
  <x>393</x>
  <y>567</y>
  <width>60</width>
  <height>25</height>
  <uuid>{4214c51a-159f-457d-89bf-707a3a956adc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3342.619</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db5</objectName>
  <x>393</x>
  <y>593</y>
  <width>60</width>
  <height>25</height>
  <uuid>{79820299-0d31-48b2-a353-328f35247520}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-25.958</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db3</objectName>
  <x>265</x>
  <y>593</y>
  <width>60</width>
  <height>25</height>
  <uuid>{82ca6c83-81b8-42d7-9fe6-c12e39565c23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-21.050</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db4</objectName>
  <x>329</x>
  <y>593</y>
  <width>60</width>
  <height>25</height>
  <uuid>{49491eba-205e-4fee-adcc-9aa9be1d03fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-23.981</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db2</objectName>
  <x>201</x>
  <y>593</y>
  <width>60</width>
  <height>25</height>
  <uuid>{44a01fdf-a30b-47f5-bf62-4f9cff759b75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-15.551</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db1</objectName>
  <x>137</x>
  <y>593</y>
  <width>60</width>
  <height>25</height>
  <uuid>{f8788d52-b867-4f2c-85ed-586ff34e167b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>bw5</objectName>
  <x>393</x>
  <y>619</y>
  <width>60</width>
  <height>25</height>
  <uuid>{f4427736-1bdd-4581-b1ce-77d7559993ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>119.581</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>bw3</objectName>
  <x>265</x>
  <y>619</y>
  <width>60</width>
  <height>25</height>
  <uuid>{d3a4f46a-7996-470f-b450-03559c4a2250}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>99.651</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>bw4</objectName>
  <x>329</x>
  <y>619</y>
  <width>60</width>
  <height>25</height>
  <uuid>{be2e1690-8a79-4bd3-bed0-c9340259d05d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>119.581</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>bw2</objectName>
  <x>201</x>
  <y>619</y>
  <width>60</width>
  <height>25</height>
  <uuid>{e752f609-fc30-47f7-8098-208f80bfba75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>74.402</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>bw1</objectName>
  <x>137</x>
  <y>619</y>
  <width>60</width>
  <height>25</height>
  <uuid>{8ebf9df6-8925-4b76-ac06-c4c8cf61ede4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>54.753</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>45</x>
  <y>545</y>
  <width>92</width>
  <height>24</height>
  <uuid>{fff72837-e480-4277-b364-3792683c5324}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Formant:</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>45</x>
  <y>569</y>
  <width>92</width>
  <height>24</height>
  <uuid>{9293ad6e-c22a-44f3-8510-f5e7844826d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq:</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>45</x>
  <y>595</y>
  <width>92</width>
  <height>24</height>
  <uuid>{2a1638fd-d6cc-4700-9455-ae921c707f54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>dB:</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>45</x>
  <y>620</y>
  <width>92</width>
  <height>24</height>
  <uuid>{3616e502-d3d0-48c4-908f-cb26e9b13613}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth:</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>137</x>
  <y>543</y>
  <width>60</width>
  <height>24</height>
  <uuid>{3234c261-6b5d-4634-ab0b-fc8463f9923e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <x>201</x>
  <y>544</y>
  <width>60</width>
  <height>24</height>
  <uuid>{a5e5e4b9-545e-4763-961f-c6d9c53e8aab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <x>265</x>
  <y>543</y>
  <width>60</width>
  <height>24</height>
  <uuid>{a4c7626d-467b-4074-8120-c79d0673315b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <x>329</x>
  <y>543</y>
  <width>60</width>
  <height>24</height>
  <uuid>{ce6d489c-f21d-4158-9d61-7315e18b9cfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <x>393</x>
  <y>543</y>
  <width>60</width>
  <height>24</height>
  <uuid>{4e52b728-046d-4632-9c3a-76d1cd7bdee2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
