;Written by Iain McCurdy, 2006


; Modified for QuteCsound by René, December 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI ONLY, instrument 2 is activated by instrument 1 only
;	Removed Recording instr, included in QuteCsound
;	Removed midi controlers, included in QuteCsound widgets
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

;	                         FOF x 6                             
;	---------------------------------------------------------------------------------------------------------------------------------------
;	This example make use of six simultaneous instances of the opcode to imitate a variety of singing voices singing various vowel sounds.
;	The interface allows for inputting the essential parameter values and the patch incorporates several additional effects and elaborations.
;	The instrument is monophonic with portamento between notes controllable using the 'Portamento on Fundamental' control.
;	MIDI continuous controller 2 can be used to modulate the vowel type produced and controller 1 controls vibrato depth.

;	A bordered panel contains various controls for fundamental and amplitude LFO modulation. 'Vibrato' refers to fundamental
;	modulation and 'tremolo' refers to amplitude modulation. There are controls for how quickly the modulation builds,
;	('ModRis') and the delay time before it begins to build, ('ModDly'). There is overall control of modulation depth and
;	frequency ('ModDep' and 'ModFrq') and independent control over vibrato and tremolo depth ('VibDep' and 'TrmDep').


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 10		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gasend		init		0										;GLOBAL VARIABLE USED TO PASS AUDIO BETWEEN INSTRUMENTS 

giExp20_20000	ftgen	202, 0, 129, -25, 0,  20.0, 128, 20000.0		;TABLE FOR EXP SLIDER
giExp100_8000	ftgen	203, 0, 129, -25, 0, 100.0, 128,  8000.0		;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkvoice		invalue	"Voice"
		gkLFOmode		invalue	"LFOmode"

		gkndx		invalue	"A_E_I_O_U"				;MIDI CC 1

		gkoct		invalue	"Octaviation"
		gkoutamp		invalue	"Amplitude"
		gkporttime1	invalue	"Porta_Fund"
		gkporttime2	invalue	"Porta_Formant"
		gkVlRndType	invalue	"Voxel_RndType"
		gkFundRndType	invalue	"Fund_RndType"

		gkmoddep		invalue	"ModDep"					;MIDI CC 2
		gkmodfrq		invalue	"ModFrq"
		gkvibdep		invalue	"VibDep"
		gktrmdep		invalue	"TrmDep"
		gkmoddly		invalue	"ModDly"
		gkmodris		invalue	"ModRis"
		gkamprand		invalue	"AmpOS"
		gkamprandF	invalue	"AmpOSF"
		gkfrqrand		invalue	"FrqOS"
		gkfrqrandF	invalue	"FrqOSF"
		gkFundRndA	invalue	"RandAmp"
		gkFundRndF	invalue	"RandFrq"
		gkris		invalue	"Rise"
		gkdur		invalue	"Dur"
		gkdec		invalue	"Dec"
		gkrndfund		invalue	"Random_Fund"
		gkVlLFOAmp	invalue	"Depth"
		gkVlLFOFrq	invalue	"Rate"
		gkVlRndAmp	invalue	"RndAmt"
		gkVlRndFrq	invalue	"RndFrq"
		kHPF			invalue	"EQ_HPF"
		gkHPF		tablei	kHPF, giExp20_20000, 1
					outvalue	"EQ_HPF_Value", gkHPF
		kcf			invalue	"EQ_Cutoff"
		gkcf			tablei	kcf, giExp100_8000, 1
					outvalue	"EQ_Cutoff_Value", gkcf
		gkgain		invalue	"EQ_Gain"
		gkq			invalue	"EQ_Res"
		kLPF			invalue	"EQ_LPF"
		gkLPF		tablei	kLPF, giExp20_20000, 1
					outvalue	"EQ_LPF_Value", gkLPF
		gkEQlev		invalue	"EQ_Level"
		gkChoRate		invalue	"Cho_Rate"
		gkChoDep		invalue	"Cho_Depth"
		gkrvbmix		invalue	"REV_Mix"
		gkrvbtim		invalue	"REV_Size"
		gkhfdiff		invalue	"REV_HFDiff"
		gkDlyMix		invalue	"DEL_Mix"
		gkDlyTim		invalue	"DEL_Time"
		gkDlyFB		invalue	"DEL_FB"
		gkDlyModDep	invalue	"DEL_ModDep"
		gkDlyModFrq	invalue	"DEL_ModFrq"
	endif
endin

instr	1	;MIDI ACTIVATED INSTRUMENT 
	icps			cpsmidi											;READ VALUES FOR FREQUENCY FROM A MIDI KEYBOARD 
	gkfund		init		icps										;CREATE A K-RATE GLOBAL VARIABLE FROM MIDI FREQ. VALUES AND
																;READ VALUES FOR FUNDAMENTAL FROM MIDI KEYBOARD IF MIDI ACTIVATED.
	iNumInst1		active	1										;SENSE THE NUMBER OF ACTIVE INSTANCES OF INSTR 1 (THIS INSTRUMENT)
	if	iNumInst1=1	then											;IF THE NUMBER OF ACTIVE INSTANCES OF INSTR 1 (THIS INSTRUMENT) IS EQUAL TO 1.
		event_i	"i", 2, 0, 3600									;TRIGGER A LONG NOTE IN INSTRUMENT 2
	endif														;END OF CONDITIONAL BRANCHING
endin
	
instr	2	;FOF INSTRUMENT
	;REINITILIZATION CHECK=================================================================================================================================================	
	kSwitch		changed		gkvoice, gkLFOmode						;IF VARIABLES THAT NEED RE-INITIALIZATION ARE CHANGED kSwitch WILL BE A MOMENTARY '1', OTHERWISE IT IS ZERO
	if	kSwitch=1	then												;IF kSwitch=1 THEN
		reinit	UPDATE											;BEGIN A REINITIALIZATION PASS FROM LABEL 'UPDATE'
	endif														;END OF CONDITIONAL BRANCHING
	UPDATE:														;A LABEL
	;======================================================================================================================================================================	
	
	;NOTE ACTIVE STATUS CHECK==============================================================================================================================================
	gkNumInstr1 		active 		1								;DETERMINE THE NUMBER OF INSTANCES OF INSTR 1 (MIDI ACTIVATED) THAT ARE PLAYING
	if			gkNumInstr1!=0	kgoto	CONTINUE						;KEEP PLAYING UNLESS MIDI POLYPHONY IS ZERO
				turnoff											;TURNOFF THIS INSTRUMENT IMMEDIATELY
	CONTINUE:  
	;======================================================================================================================================================================	
	
	;AMPLITUDE ENVELOPE===========================================================================================
	aenv			linsegr		.0001, .1, 1.5, .3, 1, .1, .0001
	;=============================================================================================================
	
	;PORTAMENTO FUNCTION==========================================================================================
	kporttime		linseg	0,.001,1,1,1								;PORTAMENTO FUNCTION
	kporttime1	=		kporttime * gkporttime1						;PORTAMENTO FUNCTION
	kporttime2	=		kporttime * gkporttime2						;PORTAMENTO FUNCTION
	
	iolaps 		= 		14850									;MAXIMUM NUMBER OF OVERLAPS (OVERESTIMATE)
	ifna 		= 		101										;WAVEFORM FOR GRAIN CONTENTS
	ifnb 		= 		102										;EXPONENTIAL SHAPE USED FOR GRAIN ENVELOPING
	itotdur 		= 		3600										;NOTE WILL LAST FOR 1 HOUR (OVERESTIMATE)
	;==============================================================================================================
	
	;FUNDAMENTAL/FORMANT INPUT FORMAT==============================================================================
	ivoice		table	i(gkvoice), 103

	kndx		=	gkndx
	kfund	=	gkfund
	;===============================================================================================================
	
	;FUNDAMENTAL_RANDOM_OFFSET======================================================================================
	irandfundrange		=		i(gkrndfund)
	ifundrand		random		irandfundrange, -irandfundrange
	kFundRndi		randomi		gkFundRndA, -gkFundRndA, gkFundRndF
	kFundRndh		randomh		gkFundRndA, -gkFundRndA, gkFundRndF
	kFundRnd		ntrpol		kFundRndi, kFundRndh, gkFundRndType
	kfund			=		kfund*(1+ifundrand)*(1+kFundRnd)
	;===============================================================================================================
	
	;VOWEL_MODULATION===============================================================================================
	kvowelLFO		lfo		gkVlLFOAmp, gkVlLFOFrq, i(gkLFOmode)
	kvowelRndi	randomi	-gkVlRndAmp, gkVlRndAmp, gkVlRndFrq
	kvowelRndh	randomh	-gkVlRndAmp, gkVlRndAmp, gkVlRndFrq
	kvowelRnd		ntrpol	kvowelRndi, kvowelRndh, gkVlRndType
	kndx			=		kndx+kvowelLFO+kvowelRnd
	kndx			mirror	kndx, 0, 1
	;===============================================================================================================
	
	;FOF_AMPLITUDE_BANDWIDTH_&_FORMANT_DERIVATION===================================================================
	k1form 		table	kndx, 1+ivoice, 1
	k1amp 		table 	kndx, 6+ivoice, 1
	k1amp		=		ampdb(k1amp)
	k1band 		table 	kndx, 11+ivoice, 1
	
	k2form 		table	kndx, 2+ivoice, 1
	k2amp 		table 	kndx, 7+ivoice, 1
	k2amp		=		ampdb(k2amp)
	k2band 		table 	kndx, 12+ivoice, 1
	
	k3form 		table	kndx, 3+ivoice, 1
	k3amp 		table 	kndx, 8+ivoice, 1
	k3amp		=		ampdb(k3amp)
	k3band 		table 	kndx, 13+ivoice, 1
	
	k4form 		table	kndx, 4+ivoice, 1
	k4amp 		table 	kndx, 9+ivoice, 1
	k4amp		=		ampdb(k4amp)
	k4band 		table 	kndx, 14+ivoice, 1
	
	k5form 		table	kndx, 5+ivoice, 1
	k5amp 		table 	kndx, 10+ivoice, 1
	k5amp		=		ampdb(k5amp)
	k5band 		table 	kndx, 15+ivoice, 1
	;===============================================================================================================
	
	rireturn			;RETURN TO PERFORMANCE TIME PASSES
	
	;PORTAMENTO PARAMETER SMOOTHING APPLIED TO FORMANT, BANDWIDTH AND FUNDAMENTAL PARAMETERS========================
	k1form		portk	k1form, kporttime2
	k2form		portk	k2form, kporttime2
	k3form		portk	k3form, kporttime2
	k4form		portk	k4form, kporttime2
	k5form		portk	k5form, kporttime2
	k1band		portk	k1band, kporttime2
	k2band		portk	k2band, kporttime2
	k3band		portk	k3band, kporttime2
	k4band		portk	k4band, kporttime2
	k5band		portk	k5band, kporttime2
	kfund		portk	kfund,  kporttime1
	;==============================================================================================================
	
	;MODULATION====================================================================================================
	kamprnd		randomi	0, gkamprand, gkamprandF
	kmoddep		=		gkmoddep + kamprnd
	kmoddep		limit	kmoddep, 0, 1
	kfrqrnd		randomi	0, gkfrqrand, gkfrqrandF
	kmodfrq		=		gkmodfrq+kfrqrnd
	kmoddep		limit	kmoddep, 0, 10
	kmodenv		linseg	0, i(gkmoddly)+.00001, 0, i(gkmodris), 1, 1, 1
	kvib			oscili	gkvibdep*kmodenv*gkmoddep, kmodfrq, 101
	kvib			=		kvib+1
	kfund		=		kfund*kvib
	ktrm			oscil	gktrmdep*.5*kmodenv*kmoddep, gkmodfrq, 101
	ktrm			=		ktrm+.5
	;===============================================================================================================

	;FOF============================================================================================================
	a1 			fof 		k1amp, kfund, k1form, gkoct, k1band, gkris, gkdur, gkdec, iolaps, ifna, ifnb, itotdur
	a2 			fof 		k2amp, kfund, k2form, gkoct, k2band, gkris, gkdur, gkdec, iolaps, ifna, ifnb, itotdur
	a3 			fof 		k3amp, kfund, k3form, gkoct, k3band, gkris, gkdur, gkdec, iolaps, ifna, ifnb, itotdur
	a4 			fof 		k4amp, kfund, k4form, gkoct, k4band, gkris, gkdur, gkdec, iolaps, ifna, ifnb, itotdur
	a5 			fof 		k5amp, kfund, k5form, gkoct, k5band, gkris, gkdur, gkdec, iolaps, ifna, ifnb, itotdur
	;===============================================================================================================

	;OUT============================================================================================================
	avoice		=		(a1+a2+a3+a4+a5) * ktrm * gkoutamp * aenv
	gasend		=		gasend + avoice 
	;================================================================================================================
endin

instr	3	;EQ
	aEQ 			pareq	gasend, gkcf, ampdb(gkgain), gkq			;APPLY PARAMETRIC EQ
	aEQ			buthp	aEQ, gkHPF							;APPLY HIGH PASS FILTER
	aEQ			butlp	aEQ, gkLPF							;APPLY LOW PASS FILTER
	gasend		=		aEQ*gkEQlev							;CREATE NEW gasend AUDIO VARIABLE
endin

instr	4	;DRY SIGNAL OUTPUT
	aSigL		=		gasend*(1-gkrvbmix)						;LEFT CHANNEL AUDIO
	aSigR		=		gasend*(1-gkrvbmix)						;RIGHT CHANNEL AUDIO	
				outs 	aSigL, aSigR							;SEND AUDIO TO OUTPUTS
endin

instr	5	;CHORUS
	atim1 		jspline 	.005*gkChoDep, 4  *gkChoRate, 4.1*gkChoRate	;RANDOM SPLINE CURVE FOR DELAY TIME TO BE USED BY CHORUS
	atim2 		jspline 	.005*gkChoDep, 4.1*gkChoRate, 4.2*gkChoRate	;RANDOM SPLINE CURVE FOR DELAY TIME TO BE USED BY CHORUS
	atim3 		jspline 	.005*gkChoDep, 4.2*gkChoRate, 4.3*gkChoRate	;RANDOM SPLINE CURVE FOR DELAY TIME TO BE USED BY CHORUS
	;DELAY LINE=========================================================================================================================
	aignore		delayr	.01
	atap1		deltap3	abs(atim1)+.001
	atap2		deltap3	abs(atim2)+.001
	atap3		deltap3	abs(atim3)+.001
				delayw	gasend
	;====================================================================================================================================
	aSigL		=		atap1+(atap2*.7)						;LEFT CHANNEL AUDIO
	aSigR		=		atap3+(atap2*.7)						;RIGHT CHANNEL AUDIO	
				outs 	aSigL, aSigR							;SEND AUDIO TO OUTPUTS
endin

instr 	100	;REVERB
				denorm	gasend								;DENORMALIZE AUDIO SIGNAL
	arvbL, arvbR 	freeverb 	gasend, gasend, gkrvbtim, gkhfdiff, sr
	aSigL		=		arvbL*gkrvbmix							;LEFT CHANNEL AUDIO
	aSigR		=		arvbR*gkrvbmix							;RIGHT CHANNEL AUDIO	
				outs 	aSigL, aSigR							;SEND AUDIO TO OUTPUTS
endin

instr	102	;PING PONG DELAY
	iporttime		init		.2
	kporttime		linseg	0,.001,iporttime,1,iporttime
	
	kDlyTim		portk	gkDlyTim, kporttime
	kDlyMod		lfo		gkDlyModDep, gkDlyModFrq, 0
	kDlyTim		=		kDlyTim+kDlyMod
	kDlyTim		limit	kDlyTim, .001, 2
	aDlyTim		interp	kDlyTim
	
	imaxdelay		=		2									;MAXIMUM DELAY TIME
	
	;LEFT CHANNEL OFFSETTING DELAY (NO FEEDBACK!)
	aBuffer		delayr	imaxdelay*.5
	aLeftOffset	deltap3	aDlyTim*.5
				delayw	gasend*gkDlyMix
			
	;LEFT CHANNEL DELAY WITH FEEDBACK
	aFBsigL		init		0
	aBuffer		delayr	imaxdelay
	aDlySigL		deltap3	aDlyTim
				delayw	aLeftOffset + aFBsigL
	aFBsigL			=	aDlySigL * gkDlyFB
	
	;RIGHT CHANNEL DELAY WITH FEEDBACK
	aFBsigR		init		0
	aBuffer		delayr	imaxdelay
	aDlySigR		deltap3	aDlyTim
				delayw	(gasend*gkDlyMix) + aFBsigR
	aFBsigR		=		aDlySigR * gkDlyFB	
	aSigL		=		aDlySigL+aLeftOffset					;LEFT CHANNEL AUDIO
	aSigR		=		aDlySigR								;RIGHT CHANNEL AUDIO	
				outs 	aSigL, aSigR							;SEND AUDIO TO OUTPUTS
endin

instr	300													;CLEAR GLOBAL VARIBLES
	gasend		=		0
endin

instr	400	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
f 101 0 4096 10 1					;SINE WAVE
f 102 0 1024 19 0.5 0.5 270 0.5		;EXPONENTIAL CURVE USED TO DEFINE THE ENVELOPE SHAPE OF FOF PULSES
f 103 0 16 -2 0 15 30 45 60			;INDEXING USED BY VOICE SELECTER BUTTON 

;FUNCTION TABLES STORING DATA FOR VARIOUS VOICE FORMANTS
;BASS
f 1  0 32768 -7 	600	10922	400	10922	250	10924	350	;FREQ
f 2  0 32768 -7	 1040	10922	1620	10922	1750	10924	600	;FREQ
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
f 16 0 32768 -7	 650 8192	400 	8192	290	8192	400	8192	350	;FREQ
f 17 0 32768 -7	 1080 8192 1700    8192	1870	8192	800	8192	600	;FREQ
f 18 0 32768 -7	2650	8192	2600    8192	2800	8192	2600	8192	2700	;FREQ
f 19 0 32768 -7	2900	8192	3200    8192	3250	8192	2800	8192	2900	;FREQ
f 20 0 32768 -7	3250	8192	3580    8192	3540	8192	3000	8192	3300	;FREQ
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
i 10		0		3600		;GUI

i 4		0		3600		;DRY OUTPUT
i 300	0		3600		;RESETTING OF GLOBAL AUDIO VARIABLES
i 400     0.1		 0		;INIT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
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
  <width>1028</width>
  <height>520</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>fof x 6 (MIDI activated Instrument)</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>85</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>A_E_I_O_U</objectName>
  <x>8</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2f9f9de8-c3ea-4d8e-8359-7f41e2a836f1}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>64</y>
  <width>40</width>
  <height>30</height>
  <uuid>{bb6b2a39-ac56-4b6f-a0b5-e590b03ca177}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>522</x>
  <y>64</y>
  <width>180</width>
  <height>30</height>
  <uuid>{8d67138b-037d-461e-8a25-108f849b03c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Amplitude</objectName>
  <x>522</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>962</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{04617e86-7abe-4120-bb9b-1d6ccd2f0983}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>522</x>
  <y>106</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2c02703f-de38-40de-bc69-7c787c5a13b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento on Fundamental</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Porta_Fund</objectName>
  <x>522</x>
  <y>83</y>
  <width>250</width>
  <height>27</height>
  <uuid>{513ad202-18da-4809-8de3-7ddf8934ab6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.03600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Porta_Fund</objectName>
  <x>712</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{530115a7-4f85-423e-99b4-263da41530d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.036</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Porta_Formant</objectName>
  <x>962</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bc7ab1c8-85da-4714-889e-9a193e4c685c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.052</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Porta_Formant</objectName>
  <x>772</x>
  <y>83</y>
  <width>250</width>
  <height>27</height>
  <uuid>{c4ac15bd-d639-4a18-834e-ece88a35c131}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.05200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>772</x>
  <y>106</y>
  <width>180</width>
  <height>30</height>
  <uuid>{4e98b9a0-55c5-4aef-b473-1d0b761def5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento on Formant</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>106</y>
  <width>180</width>
  <height>30</height>
  <uuid>{e9630e49-145d-44f3-82c4-3eccb65a4d31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octaviation Factor</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Octaviation</objectName>
  <x>8</x>
  <y>83</y>
  <width>500</width>
  <height>27</height>
  <uuid>{501c8951-2ca3-4fe6-98fd-6fe4b9428ec8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Octaviation</objectName>
  <x>448</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e9c5a112-aff7-4f41-9ec9-af77b0212b8c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>132</x>
  <y>64</y>
  <width>40</width>
  <height>30</height>
  <uuid>{497dc4a4-ae7c-42a5-bddc-0b168d56c4b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>E</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>237</x>
  <y>63</y>
  <width>40</width>
  <height>30</height>
  <uuid>{ae436fe0-3f11-4599-9eef-903b0033f1b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>I</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>366</x>
  <y>64</y>
  <width>40</width>
  <height>30</height>
  <uuid>{83440b61-7758-4faa-aab1-7ad07b03406b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>O</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>484</x>
  <y>63</y>
  <width>40</width>
  <height>30</height>
  <uuid>{5f7c107d-67b2-446e-8bd9-a3a82f233666}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>U</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>136</y>
  <width>362</width>
  <height>126</height>
  <uuid>{1a0e3237-5e3a-4a46-bfbe-d7e1c792a2e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fundamental and Amplitude LFO</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>ModDep</objectName>
  <x>13</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{524a8afe-f415-4803-a4fa-09c2190ea618}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.22000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d613bc04-32d0-42b8-a68f-390f652553e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ModDep</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>ModDep</objectName>
  <x>8</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7280fb77-345b-4a14-8784-95889ff8474e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.220</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>ModFrq</objectName>
  <x>68</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7c883192-96f8-4fd2-8e14-3a20d95e07fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.300</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>68</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{754e5b4c-e7a6-4184-8472-22b4e3212b5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ModFrq</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ModFrq</objectName>
  <x>73</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{09b76660-be28-48a3-b4cb-680e4d1e34b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>5.30000019</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>VibDep</objectName>
  <x>128</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{93064945-a8ff-4ace-a55b-26656a27da83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.030</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>128</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{163cfb35-416a-498c-a14c-535a490b7c2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VibDep</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>VibDep</objectName>
  <x>133</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c44c6c2a-1b6c-426a-b0dc-167cbda2cfcc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.03000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>TrmDep</objectName>
  <x>188</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fa6490db-c5c5-4f0c-9c3e-67c456c14153}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.150</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>188</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c19462c2-d9f7-44ef-aea2-7999653d86fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>TrmDep</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>TrmDep</objectName>
  <x>193</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{4ee9cc18-ec42-45a5-ae3d-32cdfbe72749}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.15000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ModDly</objectName>
  <x>248</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0361cbd6-8fa7-4ec8-a647-c49de9909891}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.510</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>248</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6c2849b4-51e7-49d8-9feb-3135c0168172}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ModDly</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ModDly</objectName>
  <x>253</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c238422d-cf84-4c7c-a160-9c29d14671d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.50999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ModRis</objectName>
  <x>307</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{eaaba679-97be-4824-b6e4-e37c2df1ff73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.510</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>307</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f68b6890-3c96-4a85-a7a1-579da5f09acd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ModRis</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ModRis</objectName>
  <x>312</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{22ef872d-5ace-4d1b-bccf-d564ca1ae731}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.50999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>370</x>
  <y>136</y>
  <width>136</width>
  <height>252</height>
  <uuid>{08ff8632-5993-404d-893f-b445cffd0fbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LFO Variability</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>AmpOSF</objectName>
  <x>443</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6f9c90fa-e7e9-4ccb-8834-6d90c12f3ba1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>438</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{58588688-1a27-4b9c-bc71-b3a838f62d31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp OSF</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>AmpOSF</objectName>
  <x>438</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{38315915-888f-4e30-b023-cba0472e63b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>AmpOS</objectName>
  <x>383</x>
  <y>166</y>
  <width>50</width>
  <height>50</height>
  <uuid>{b033fb99-ca21-4242-aa7c-a7f6beab8c34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>378</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0d8c61cf-6c9e-4143-b6bd-6a942d3d2399}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp OS</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>AmpOS</objectName>
  <x>378</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c925802e-0887-40da-9b0d-06d0e7bbb609}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>262</y>
  <width>362</width>
  <height>126</height>
  <uuid>{88294ff1-2d1e-4275-a3a7-a9ebfcf7ed7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fundamental Randomization</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>RandFrq</objectName>
  <x>73</x>
  <y>291</y>
  <width>50</width>
  <height>50</height>
  <uuid>{8073b842-7317-4e36-bf7a-25673bfe3541}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>30.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>68</x>
  <y>341</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5ff94703-b4bc-477c-a421-2967476e777b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RandFrq</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>RandFrq</objectName>
  <x>68</x>
  <y>360</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8f174b8b-d392-4117-91dd-5b8772ef9d8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>RandAmp</objectName>
  <x>8</x>
  <y>360</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0ee2bed3-609a-4899-8de4-d8258d530361}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.020</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>341</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0c8f9a94-f796-4789-a272-ba8c296b783d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RandAmp</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>RandAmp</objectName>
  <x>13</x>
  <y>291</y>
  <width>50</width>
  <height>50</height>
  <uuid>{60e0cd47-1f05-4389-98ad-0972970d65aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.02000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>137</x>
  <y>330</y>
  <width>220</width>
  <height>34</height>
  <uuid>{91284e25-742a-4e1d-bace-def7e810687e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Interp &lt;-----------------------------> S &amp; H</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Fund_RndType</objectName>
  <x>137</x>
  <y>307</y>
  <width>220</width>
  <height>27</height>
  <uuid>{4e570d27-8f06-44d4-8f0f-212ced49075c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00454545</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FrqOS</objectName>
  <x>377</x>
  <y>360</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0fd91d3a-4ba4-4904-b7af-b4f418a2843a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>377</x>
  <y>341</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d23955fd-1b28-4d9b-9d76-1f419f64617c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frq OS</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>FrqOS</objectName>
  <x>382</x>
  <y>291</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9dda9c49-f7e6-4c80-9b29-4a2c9fb337ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FrqOSF</objectName>
  <x>437</x>
  <y>360</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7fa8efd5-7ba0-4f76-b9fc-4660a75180c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>437</x>
  <y>341</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b0df311b-32d6-4bf3-8124-37730a20cb4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frq OSF</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>FrqOSF</objectName>
  <x>442</x>
  <y>291</y>
  <width>50</width>
  <height>50</height>
  <uuid>{16576554-b8ca-4375-bbd6-2ae7d7ea9e28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>10.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>136</y>
  <width>200</width>
  <height>126</height>
  <uuid>{b93a7536-af10-4b55-b4ed-9cd5f9ffee6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Envelope</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Rise</objectName>
  <x>537</x>
  <y>165</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f919e96d-cc3a-425b-ba7f-8cf508604c14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.05000000</maximum>
  <value>0.00394000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>532</x>
  <y>215</y>
  <width>60</width>
  <height>30</height>
  <uuid>{23b07e10-93d9-4265-be9f-5753140e3795}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rise</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Rise</objectName>
  <x>532</x>
  <y>234</y>
  <width>60</width>
  <height>30</height>
  <uuid>{41c652f4-3baa-4edd-a3ae-d3a068811043}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.004</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Dur</objectName>
  <x>592</x>
  <y>234</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d82691ae-052a-46e8-9012-c9cb1245258e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.017</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>592</x>
  <y>215</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e7af5594-4196-45f6-a833-03fedfdfcc02}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dur</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Dur</objectName>
  <x>597</x>
  <y>165</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ed11cfba-2dec-4353-926d-501d5ccc39c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01700000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01700000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Dec</objectName>
  <x>652</x>
  <y>234</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e14216f5-0ee7-4255-b12e-924bd694d925}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.005</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>652</x>
  <y>215</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b8f757db-2506-423d-acd0-9ce659c3e4f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dec</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Dec</objectName>
  <x>657</x>
  <y>165</y>
  <width>50</width>
  <height>50</height>
  <uuid>{e51bacc0-b884-4e57-a6bf-1708b4cdbe3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.05000000</maximum>
  <value>0.00541000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>262</y>
  <width>284</width>
  <height>126</height>
  <uuid>{9c1242ea-7457-4aba-a8d9-a813b0ad3d54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vowel LFO</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>LFOmode</objectName>
  <x>532</x>
  <y>302</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7d29435c-c9a7-47fb-a166-bda6c6b373a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Bipolar Square</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Unipolar Square</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sawtooth Up</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sawtooth Down</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Rate</objectName>
  <x>748</x>
  <y>289</y>
  <width>50</width>
  <height>50</height>
  <uuid>{762c3965-be6c-4105-8f81-28766f5157d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>743</x>
  <y>339</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8f3b079a-4e7b-45e3-a88d-99f346f46b6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate (Hz)</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Rate</objectName>
  <x>743</x>
  <y>358</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f21851ca-720f-4887-974c-ae2942dc59da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Depth</objectName>
  <x>688</x>
  <y>289</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ad121fe3-49be-4db9-9906-98470a6f05b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>683</x>
  <y>339</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ea816d91-fbdc-4632-abff-d258020036cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Depth</objectName>
  <x>683</x>
  <y>358</y>
  <width>60</width>
  <height>30</height>
  <uuid>{70ba4641-ac7e-4ef1-8a70-96444e08c6c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>806</x>
  <y>262</y>
  <width>216</width>
  <height>126</height>
  <uuid>{21fbad21-817a-40a5-b3a8-244ed5de8269}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vowel Randomization</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RndAmt</objectName>
  <x>857</x>
  <y>310</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7c9fa51d-9e63-4021-a3ee-fa943ae83cc9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>857</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9aeb30e2-2090-4e4c-977a-3114e492b7ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rnd Amt</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>RndAmt</objectName>
  <x>810</x>
  <y>289</y>
  <width>50</width>
  <height>50</height>
  <uuid>{333e5ade-3715-47de-8d9b-4b23f736d91c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RndFrq</objectName>
  <x>961</x>
  <y>309</y>
  <width>60</width>
  <height>30</height>
  <uuid>{17d41d3d-fec8-45a3-818b-77f5573a5b58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>961</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{371281ed-9e3c-4c8c-af95-0e1aab040a5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rnd Frq</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>RndFrq</objectName>
  <x>922</x>
  <y>290</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9b4a8e9a-35c8-4d3a-96fb-547c56fbd4e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Voxel_RndType</objectName>
  <x>814</x>
  <y>341</y>
  <width>200</width>
  <height>27</height>
  <uuid>{7f9079f7-30c3-4706-a67f-3e65983a87ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>814</x>
  <y>364</y>
  <width>200</width>
  <height>34</height>
  <uuid>{2b28faf9-cefe-4945-b9af-e25927ddbea4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Interp &lt;------------------------> S &amp; H</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>388</y>
  <width>362</width>
  <height>126</height>
  <uuid>{db90e054-7d98-4154-97a2-3c8e4ed77ae0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>EQ On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>60</x>
  <y>395</y>
  <width>16</width>
  <height>16</height>
  <uuid>{0b5dce4b-7d9e-4c92-8f3e-9edd0a83f615}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>EQ_Level</objectName>
  <x>314</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c786a5c1-55f7-4d84-b7c6-16b1545d706d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.95999998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>309</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ae4a460a-a739-45c5-9da9-c64479a0d4d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>EQ_Level</objectName>
  <x>309</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fe0a4d7b-f7f9-474a-8953-7c1f90f8be7f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.960</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>EQ_LPF</objectName>
  <x>255</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ec99233a-d3c5-4a6a-ae69-eb2fb53781b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.98000002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>250</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6bec282a-b5ea-4376-818e-fae0c70f78f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>EQ_LPF_Value</objectName>
  <x>250</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{29abc6f1-2975-42bb-b96b-531960520b4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>17425.538</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>EQ_Res</objectName>
  <x>195</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0fa35bf4-ad33-447f-899f-f23be0bc5d75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.70700000</minimum>
  <maximum>10.00000000</maximum>
  <value>2.10095000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>190</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c3c14d59-cfb1-4116-a7d1-a7276214cd1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Res</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>EQ_Res</objectName>
  <x>190</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a7d70703-073b-4cde-88a0-25b7c321b24d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.101</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>EQ_Gain</objectName>
  <x>135</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d998de98-dde0-481d-a0bb-41c1a1a560e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>1.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>130</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{32ee477d-d96b-4f19-a5bb-e4985960379d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>EQ_Gain</objectName>
  <x>130</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c99196d7-7f6a-4a30-8c45-ca0c071a5014}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.500</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>EQ_Cutoff</objectName>
  <x>75</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6f603b8b-492a-4dcb-8a00-b1e7899a3fbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.23000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>70</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{323a963f-cbb7-49fe-9390-9af07c99156c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cutoff</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>EQ_Cutoff_Value</objectName>
  <x>70</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5bc40956-7be0-4b4a-9e9c-2b6a3cea4c4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>274.014</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>EQ_HPF_Value</objectName>
  <x>10</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{71f2f8f6-de31-49e8-9dc0-3b93e7431be5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>10</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3690cf04-82f6-4a2f-88a8-a5a65971e19e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>HPF</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>EQ_HPF</objectName>
  <x>15</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a769e725-e63d-4c6e-92f4-365b3035fbb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>370</x>
  <y>388</y>
  <width>136</width>
  <height>126</height>
  <uuid>{7e4daabe-8bd3-4ce2-b148-b063c9519f53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chorus On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Cho_Rate</objectName>
  <x>384</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{30fe78f4-f745-4400-9a4e-05ef408d2f65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.18091001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>379</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7161baac-afe0-460b-829c-eca773add8c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Cho_Rate</objectName>
  <x>379</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2d3fd28b-30b1-433f-9de4-3fb5ff7312a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.181</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Cho_Depth</objectName>
  <x>439</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0e5424f6-0c84-4803-a1c7-bbb940a22f8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.480</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>439</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fa9d1012-bde7-4c99-83e2-3f5453fd5d68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Cho_Depth</objectName>
  <x>444</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{13cc07c4-cb28-4550-b7df-9e9f174e0681}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>447</x>
  <y>395</y>
  <width>16</width>
  <height>16</height>
  <uuid>{37a559b1-b652-4290-b35e-9eb227517cf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 5 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>388</y>
  <width>185</width>
  <height>126</height>
  <uuid>{5cf4c51b-4f0e-45a9-8eca-99fdfb3b87ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>707</x>
  <y>388</y>
  <width>315</width>
  <height>126</height>
  <uuid>{a428e733-ac4a-4891-b87a-ff2a60924e4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>597</x>
  <y>395</y>
  <width>16</width>
  <height>16</height>
  <uuid>{0f3ee55c-273f-490a-9f10-969db826aea7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 100 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>774</x>
  <y>395</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f427fa5e-853e-4162-9c0b-791825044238}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 102 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>DEL_Mix</objectName>
  <x>719</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{20132fd3-595d-4085-b9e7-5c8f7c008a3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>714</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{af32b598-77e0-4852-8bb2-6fed6a47496b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>DEL_Mix</objectName>
  <x>714</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c8801cdb-ca31-4a64-97ac-12986f278348}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.480</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>DEL_Time</objectName>
  <x>774</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5e07a025-2f61-4d5f-b64b-5cae6db5d6cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.941</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>774</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4dd46ebe-7541-439b-80fc-31fb0511ca08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Time</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>DEL_Time</objectName>
  <x>779</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6200b8b0-7062-4bda-8e3c-d8f59840da86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.94053000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DEL_FB</objectName>
  <x>834</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{50a5bac3-f815-4093-ba79-32414761bbe9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.257</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>834</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3bcba281-e26c-4866-9c27-732cf286d85c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FB</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>DEL_FB</objectName>
  <x>839</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{3169a633-fc36-45e8-8ebd-abb23bbce317}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.95000000</maximum>
  <value>0.25650001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DEL_ModDep</objectName>
  <x>894</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2ba5f4e2-1d05-4787-a8aa-ccfa831e565e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.020</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>894</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9095ce56-1f2a-47f5-8369-f557ebbdcfff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ModDep</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>DEL_ModDep</objectName>
  <x>899</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{b24d5b19-c7b7-4dbd-b96a-34c953b1d7d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.02000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DEL_ModFrq</objectName>
  <x>954</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4ecfd073-f67b-4b52-a223-a7f95d0afccd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>954</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{901f686f-7a09-4f6d-9803-4a406bd9c155}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ModFrq</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>DEL_ModFrq</objectName>
  <x>959</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0c5d55d3-2bb0-447d-b381-38209c39d56e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>REV_Mix</objectName>
  <x>529</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c599c82b-db83-4128-8d11-8dc8d13cb9a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>524</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{29e3f7be-5c51-47ee-be2c-3194adf7e70e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>REV_Mix</objectName>
  <x>524</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{935a1596-87ad-4762-9f3d-5d8a8f751251}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.490</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>REV_Size</objectName>
  <x>584</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c7e9577c-29e7-4a21-8ac0-08de99d4c09a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.490</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>584</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{79bdeff8-1e10-46bd-9727-5aeeac2572a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Size</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>REV_Size</objectName>
  <x>589</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c6d31254-31f8-4fb0-a0dc-4646697cdcbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>REV_HFDiff</objectName>
  <x>644</x>
  <y>488</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b952f699-4232-439b-bd63-f31c30ef5c34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.110</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>644</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c736cd8f-1a0e-4d06-8725-63d5238f9767}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>HF Diff</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>REV_HFDiff</objectName>
  <x>649</x>
  <y>419</y>
  <width>50</width>
  <height>50</height>
  <uuid>{52a6c8c0-8f9d-428f-989c-b8fe246c37c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.11000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>722</x>
  <y>136</y>
  <width>158</width>
  <height>126</height>
  <uuid>{82daaa40-fcba-4c92-bfc0-1d6fe91e6bdb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Voice</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Voice</objectName>
  <x>734</x>
  <y>182</y>
  <width>130</width>
  <height>28</height>
  <uuid>{610263dd-c34c-48ca-9189-7bc22554109d}</uuid>
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
    <name>Counter-Tenor</name>
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
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>880</x>
  <y>136</y>
  <width>142</width>
  <height>126</height>
  <uuid>{eb8f40b2-5d84-4371-b6ce-d00e00f2f547}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random Fundamental</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Random_Fund</objectName>
  <x>922</x>
  <y>165</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d8f6ae23-60a0-42cb-b531-baf070387a97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>877</x>
  <y>214</y>
  <width>140</width>
  <height>32</height>
  <uuid>{b67a2a63-08da-4382-9893-37afbb0b4234}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RndFund</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>Random_Fund</objectName>
  <x>915</x>
  <y>234</y>
  <width>65</width>
  <height>31</height>
  <uuid>{5362ffed-b9d8-4381-ae6c-b90a96f93a95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
<preset name="INIT" number="0" >
<value id="{2f9f9de8-c3ea-4d8e-8359-7f41e2a836f1}" mode="1" >0.00000000</value>
<value id="{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}" mode="1" >0.30000001</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="1" >0.30000001</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="4" >0.300</value>
<value id="{513ad202-18da-4809-8de3-7ddf8934ab6f}" mode="1" >0.03600000</value>
<value id="{530115a7-4f85-423e-99b4-263da41530d9}" mode="1" >0.03600000</value>
<value id="{530115a7-4f85-423e-99b4-263da41530d9}" mode="4" >0.036</value>
<value id="{bc7ab1c8-85da-4714-889e-9a193e4c685c}" mode="1" >0.05200000</value>
<value id="{bc7ab1c8-85da-4714-889e-9a193e4c685c}" mode="4" >0.052</value>
<value id="{c4ac15bd-d639-4a18-834e-ece88a35c131}" mode="1" >0.05200000</value>
<value id="{501c8951-2ca3-4fe6-98fd-6fe4b9428ec8}" mode="1" >0.00000000</value>
<value id="{e9c5a112-aff7-4f41-9ec9-af77b0212b8c}" mode="1" >0.00000000</value>
<value id="{e9c5a112-aff7-4f41-9ec9-af77b0212b8c}" mode="4" >0.000</value>
<value id="{524a8afe-f415-4803-a4fa-09c2190ea618}" mode="1" >0.22000000</value>
<value id="{7280fb77-345b-4a14-8784-95889ff8474e}" mode="1" >0.22000000</value>
<value id="{7280fb77-345b-4a14-8784-95889ff8474e}" mode="4" >0.220</value>
<value id="{7c883192-96f8-4fd2-8e14-3a20d95e07fa}" mode="1" >5.30000019</value>
<value id="{7c883192-96f8-4fd2-8e14-3a20d95e07fa}" mode="4" >5.300</value>
<value id="{09b76660-be28-48a3-b4cb-680e4d1e34b0}" mode="1" >5.30000019</value>
<value id="{93064945-a8ff-4ace-a55b-26656a27da83}" mode="1" >0.03000000</value>
<value id="{93064945-a8ff-4ace-a55b-26656a27da83}" mode="4" >0.030</value>
<value id="{c44c6c2a-1b6c-426a-b0dc-167cbda2cfcc}" mode="1" >0.03000000</value>
<value id="{fa6490db-c5c5-4f0c-9c3e-67c456c14153}" mode="1" >0.15000001</value>
<value id="{fa6490db-c5c5-4f0c-9c3e-67c456c14153}" mode="4" >0.150</value>
<value id="{4ee9cc18-ec42-45a5-ae3d-32cdfbe72749}" mode="1" >0.15000001</value>
<value id="{0361cbd6-8fa7-4ec8-a647-c49de9909891}" mode="1" >0.50999999</value>
<value id="{0361cbd6-8fa7-4ec8-a647-c49de9909891}" mode="4" >0.510</value>
<value id="{c238422d-cf84-4c7c-a160-9c29d14671d6}" mode="1" >0.50999999</value>
<value id="{eaaba679-97be-4824-b6e4-e37c2df1ff73}" mode="1" >0.50999999</value>
<value id="{eaaba679-97be-4824-b6e4-e37c2df1ff73}" mode="4" >0.510</value>
<value id="{22ef872d-5ace-4d1b-bccf-d564ca1ae731}" mode="1" >0.50999999</value>
<value id="{6f9c90fa-e7e9-4ccb-8834-6d90c12f3ba1}" mode="1" >1.00000000</value>
<value id="{38315915-888f-4e30-b023-cba0472e63b1}" mode="1" >1.00000000</value>
<value id="{38315915-888f-4e30-b023-cba0472e63b1}" mode="4" >1.000</value>
<value id="{b033fb99-ca21-4242-aa7c-a7f6beab8c34}" mode="1" >0.00000000</value>
<value id="{c925802e-0887-40da-9b0d-06d0e7bbb609}" mode="1" >0.00000000</value>
<value id="{c925802e-0887-40da-9b0d-06d0e7bbb609}" mode="4" >0.000</value>
<value id="{8073b842-7317-4e36-bf7a-25673bfe3541}" mode="1" >0.00001000</value>
<value id="{8f174b8b-d392-4117-91dd-5b8772ef9d8a}" mode="1" >0.00000000</value>
<value id="{8f174b8b-d392-4117-91dd-5b8772ef9d8a}" mode="4" >0.000</value>
<value id="{0ee2bed3-609a-4899-8de4-d8258d530361}" mode="1" >0.02000000</value>
<value id="{0ee2bed3-609a-4899-8de4-d8258d530361}" mode="4" >0.020</value>
<value id="{60e0cd47-1f05-4389-98ad-0972970d65aa}" mode="1" >0.02000000</value>
<value id="{4e570d27-8f06-44d4-8f0f-212ced49075c}" mode="1" >0.00454545</value>
<value id="{0fd91d3a-4ba4-4904-b7af-b4f418a2843a}" mode="1" >0.50000000</value>
<value id="{0fd91d3a-4ba4-4904-b7af-b4f418a2843a}" mode="4" >0.500</value>
<value id="{9dda9c49-f7e6-4c80-9b29-4a2c9fb337ca}" mode="1" >0.50000000</value>
<value id="{7fa8efd5-7ba0-4f76-b9fc-4660a75180c2}" mode="1" >10.00000000</value>
<value id="{7fa8efd5-7ba0-4f76-b9fc-4660a75180c2}" mode="4" >10.000</value>
<value id="{16576554-b8ca-4375-bbd6-2ae7d7ea9e28}" mode="1" >10.00000000</value>
<value id="{f919e96d-cc3a-425b-ba7f-8cf508604c14}" mode="1" >0.00394000</value>
<value id="{41c652f4-3baa-4edd-a3ae-d3a068811043}" mode="1" >0.00400000</value>
<value id="{41c652f4-3baa-4edd-a3ae-d3a068811043}" mode="4" >0.004</value>
<value id="{d82691ae-052a-46e8-9012-c9cb1245258e}" mode="1" >0.01700000</value>
<value id="{d82691ae-052a-46e8-9012-c9cb1245258e}" mode="4" >0.017</value>
<value id="{ed11cfba-2dec-4353-926d-501d5ccc39c9}" mode="1" >0.01700000</value>
<value id="{e14216f5-0ee7-4255-b12e-924bd694d925}" mode="1" >0.00500000</value>
<value id="{e14216f5-0ee7-4255-b12e-924bd694d925}" mode="4" >0.005</value>
<value id="{e51bacc0-b884-4e57-a6bf-1708b4cdbe3e}" mode="1" >0.00541000</value>
<value id="{7d29435c-c9a7-47fb-a166-bda6c6b373a2}" mode="1" >0.00000000</value>
<value id="{762c3965-be6c-4105-8f81-28766f5157d2}" mode="1" >1.00000000</value>
<value id="{f21851ca-720f-4887-974c-ae2942dc59da}" mode="1" >1.00000000</value>
<value id="{f21851ca-720f-4887-974c-ae2942dc59da}" mode="4" >1.000</value>
<value id="{ad121fe3-49be-4db9-9906-98470a6f05b1}" mode="1" >0.00000000</value>
<value id="{70ba4641-ac7e-4ef1-8a70-96444e08c6c4}" mode="1" >0.00000000</value>
<value id="{70ba4641-ac7e-4ef1-8a70-96444e08c6c4}" mode="4" >0.000</value>
<value id="{7c9fa51d-9e63-4021-a3ee-fa943ae83cc9}" mode="1" >0.00000000</value>
<value id="{7c9fa51d-9e63-4021-a3ee-fa943ae83cc9}" mode="4" >0.000</value>
<value id="{333e5ade-3715-47de-8d9b-4b23f736d91c}" mode="1" >0.00000000</value>
<value id="{17d41d3d-fec8-45a3-818b-77f5573a5b58}" mode="1" >1.00000000</value>
<value id="{17d41d3d-fec8-45a3-818b-77f5573a5b58}" mode="4" >1.000</value>
<value id="{9b4a8e9a-35c8-4d3a-96fb-547c56fbd4e7}" mode="1" >1.00000000</value>
<value id="{7f9079f7-30c3-4706-a67f-3e65983a87ef}" mode="1" >0.00000000</value>
<value id="{0b5dce4b-7d9e-4c92-8f3e-9edd0a83f615}" mode="1" >0.00000000</value>
<value id="{0b5dce4b-7d9e-4c92-8f3e-9edd0a83f615}" mode="4" >0</value>
<value id="{c786a5c1-55f7-4d84-b7c6-16b1545d706d}" mode="1" >0.95999998</value>
<value id="{fe0a4d7b-f7f9-474a-8953-7c1f90f8be7f}" mode="1" >0.95999998</value>
<value id="{fe0a4d7b-f7f9-474a-8953-7c1f90f8be7f}" mode="4" >0.960</value>
<value id="{ec99233a-d3c5-4a6a-ae69-eb2fb53781b0}" mode="1" >0.98000002</value>
<value id="{29abc6f1-2975-42bb-b96b-531960520b4c}" mode="1" >17425.53906250</value>
<value id="{29abc6f1-2975-42bb-b96b-531960520b4c}" mode="4" >17425.538</value>
<value id="{0fa35bf4-ad33-447f-899f-f23be0bc5d75}" mode="1" >2.10095000</value>
<value id="{a7d70703-073b-4cde-88a0-25b7c321b24d}" mode="1" >2.10100007</value>
<value id="{a7d70703-073b-4cde-88a0-25b7c321b24d}" mode="4" >2.101</value>
<value id="{d998de98-dde0-481d-a0bb-41c1a1a560e3}" mode="1" >1.50000000</value>
<value id="{c99196d7-7f6a-4a30-8c45-ca0c071a5014}" mode="1" >1.50000000</value>
<value id="{c99196d7-7f6a-4a30-8c45-ca0c071a5014}" mode="4" >1.500</value>
<value id="{6f603b8b-492a-4dcb-8a00-b1e7899a3fbe}" mode="1" >0.23000000</value>
<value id="{5bc40956-7be0-4b4a-9e9c-2b6a3cea4c4b}" mode="1" >274.01446533</value>
<value id="{5bc40956-7be0-4b4a-9e9c-2b6a3cea4c4b}" mode="4" >274.014</value>
<value id="{71f2f8f6-de31-49e8-9dc0-3b93e7431be5}" mode="1" >20.00000000</value>
<value id="{71f2f8f6-de31-49e8-9dc0-3b93e7431be5}" mode="4" >20.000</value>
<value id="{a769e725-e63d-4c6e-92f4-365b3035fbb9}" mode="1" >0.00000000</value>
<value id="{30fe78f4-f745-4400-9a4e-05ef408d2f65}" mode="1" >0.18091001</value>
<value id="{2d3fd28b-30b1-433f-9de4-3fb5ff7312a1}" mode="1" >0.18099999</value>
<value id="{2d3fd28b-30b1-433f-9de4-3fb5ff7312a1}" mode="4" >0.181</value>
<value id="{0e5424f6-0c84-4803-a1c7-bbb940a22f8a}" mode="1" >0.47999999</value>
<value id="{0e5424f6-0c84-4803-a1c7-bbb940a22f8a}" mode="4" >0.480</value>
<value id="{13cc07c4-cb28-4550-b7df-9e9f174e0681}" mode="1" >0.47999999</value>
<value id="{37a559b1-b652-4290-b35e-9eb227517cf5}" mode="1" >0.00000000</value>
<value id="{37a559b1-b652-4290-b35e-9eb227517cf5}" mode="4" >0</value>
<value id="{0f3ee55c-273f-490a-9f10-969db826aea7}" mode="1" >0.00000000</value>
<value id="{0f3ee55c-273f-490a-9f10-969db826aea7}" mode="4" >0</value>
<value id="{f427fa5e-853e-4162-9c0b-791825044238}" mode="1" >0.00000000</value>
<value id="{f427fa5e-853e-4162-9c0b-791825044238}" mode="4" >0</value>
<value id="{20132fd3-595d-4085-b9e7-5c8f7c008a3c}" mode="1" >0.47999999</value>
<value id="{c8801cdb-ca31-4a64-97ac-12986f278348}" mode="1" >0.47999999</value>
<value id="{c8801cdb-ca31-4a64-97ac-12986f278348}" mode="4" >0.480</value>
<value id="{5e07a025-2f61-4d5f-b64b-5cae6db5d6cf}" mode="1" >0.94099998</value>
<value id="{5e07a025-2f61-4d5f-b64b-5cae6db5d6cf}" mode="4" >0.941</value>
<value id="{6200b8b0-7062-4bda-8e3c-d8f59840da86}" mode="1" >0.94053000</value>
<value id="{50a5bac3-f815-4093-ba79-32414761bbe9}" mode="1" >0.25700000</value>
<value id="{50a5bac3-f815-4093-ba79-32414761bbe9}" mode="4" >0.257</value>
<value id="{3169a633-fc36-45e8-8ebd-abb23bbce317}" mode="1" >0.25650001</value>
<value id="{2ba5f4e2-1d05-4787-a8aa-ccfa831e565e}" mode="1" >0.02000000</value>
<value id="{2ba5f4e2-1d05-4787-a8aa-ccfa831e565e}" mode="4" >0.020</value>
<value id="{b24d5b19-c7b7-4dbd-b96a-34c953b1d7d7}" mode="1" >0.02000000</value>
<value id="{4ecfd073-f67b-4b52-a223-a7f95d0afccd}" mode="1" >0.10000000</value>
<value id="{4ecfd073-f67b-4b52-a223-a7f95d0afccd}" mode="4" >0.100</value>
<value id="{0c5d55d3-2bb0-447d-b381-38209c39d56e}" mode="1" >0.10000000</value>
<value id="{c599c82b-db83-4128-8d11-8dc8d13cb9a4}" mode="1" >0.49000001</value>
<value id="{935a1596-87ad-4762-9f3d-5d8a8f751251}" mode="1" >0.49000001</value>
<value id="{935a1596-87ad-4762-9f3d-5d8a8f751251}" mode="4" >0.490</value>
<value id="{c7e9577c-29e7-4a21-8ac0-08de99d4c09a}" mode="1" >0.49000001</value>
<value id="{c7e9577c-29e7-4a21-8ac0-08de99d4c09a}" mode="4" >0.490</value>
<value id="{c6d31254-31f8-4fb0-a0dc-4646697cdcbe}" mode="1" >0.49000001</value>
<value id="{b952f699-4232-439b-bd63-f31c30ef5c34}" mode="1" >0.11000000</value>
<value id="{b952f699-4232-439b-bd63-f31c30ef5c34}" mode="4" >0.110</value>
<value id="{52a6c8c0-8f9d-428f-989c-b8fe246c37c4}" mode="1" >0.11000000</value>
<value id="{610263dd-c34c-48ca-9189-7bc22554109d}" mode="1" >0.00000000</value>
<value id="{d8f6ae23-60a0-42cb-b531-baf070387a97}" mode="1" >0.00000000</value>
<value id="{5362ffed-b9d8-4381-ae6c-b90a96f93a95}" mode="1" >0.00000000</value>
<value id="{5362ffed-b9d8-4381-ae6c-b90a96f93a95}" mode="4" >0.000</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
