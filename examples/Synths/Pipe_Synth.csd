<CsoundSynthesizer>
<CsOptions>
;-fdhm0 -odac -b16 -B512 --expression-opt
--midi-key=4
</CsOptions>
<CsInstruments>
;Physical Waveguide Midi synth with Qutecsound GUI by René Djack 2009.
;Modified for QuteCsound examples by Andres Cabrera

sr = 44100
ksmps	= 256
nchnls	= 2

maxalloc	1, 10	;maximum polyphony
prealloc	1, 8 ;preallocate voices
gaIn_Reverb	init	0

; all midi channels to instrument 1
massign		0, 1

opcode	PIPE, a, iiiiiiikkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk

iPitch,\			;midi pitch
\;AIR ENV
iAtt_ENV,\		;knob Att
iDec_ENV,\		;knob Dec
iSus_ENV,\		;knob Sus
iRel_ENV,\		;knob Rel
iVel_ENV,\		;knob Vel
iScaling_ENV,\		;knob Scaling
\;AIR GEN
kDC_Noise_GEN,\	;knob DC/Noise
kCut_GEN,\		;knob Cut
kRes_GEN,\		;knob Res
kK_Track_GEN,\		;knob K-Track
kV_Track_GEN,\		;knob V-Track
k1_Pole_GEN,\		;button 1-Pole
\;Pipe
kCtr_MW,\			;knob ModWheel
kPolarity,\		;button Polarity
\;Pipe DELTUNE
kTune_DT,\		;knob Tune
kFine_DT,\		;knob Fine
kSREC_DT,\		;knob Srec
kMW_DT,\			;knob MW
\;Pipe FEEDBACK
kRT_FB,\			;knob RT
kK_TrackFB,\		;knob K-Track
kDamp_FB,\		;knob Damp
\;Pipe ALLPASS TUNE
kTune_AP,\		;knob Tune
kFine_AP,\		;knob Fine
kSREC_AP,\		;knob Srec
kMW_AP,\			;knob MW
\;Pipe ALLPASS
kDffs_AP,\		;knob Dffs
kPower_AP,\		;button Power
\;Pipe PUSH PULL
kOffset,\			;knob Offset
kPush,\			;knob Push
\;Pipe SATURATION
kSoftHard,\		;knob Soft/Hard
kSym,\			;knob Sym
\;Pipe MW FILTER
kHP0,\			;knob HP0
kHP1,\			;knob HP1
kK_TrackH,\		;knob K-TrackH
kLP0,\			;knob LP0
kLP1,\			;knob LP1
kK_TrackL,\		;knob K-TrackL
		xin

		setksmps	1
;******************************************************************************************AIR SECTION
;Input iPitch
;Output aout_Air (to PIPE)
;************************************************************************************************ENV
;Output kout_ENV (to GEN)
iScaling_ENV	= iScaling_ENV * (iPitch - 60)
iAtt_ENV	= iAtt_ENV + iScaling_ENV
iDec_ENV	= iDec_ENV + iScaling_ENV
iRel_ENV	= iRel_ENV + iScaling_ENV
iGate_ENV	= 1 - 0.5 * iVel_ENV

iAtt_ENV	table	iAtt_ENV + 44, 10		;exp table; add 44 for positive index
iDec_ENV	table	iDec_ENV + 44, 10		;exp table; add 44 for positive index
iRel_ENV	table	iRel_ENV + 44, 10		;exp table; add 44 for positive index

iRel_ENV	= iRel_ENV * 6

		xtratim	iRel_ENV + 0.1

krel_ENV	init	0

krel_ENV	release									;outputs release-stage flag
		if   (krel_ENV > .5)	kgoto	rel_ENV		;if in release-stage goto release section
;attack decay and sustain
kmp1_ENV	transeg	0.001, iAtt_ENV, 0, iGate_ENV, iDec_ENV*10,-10, iGate_ENV * iSus_ENV, 1, 0, iGate_ENV * iSus_ENV
kout_ENV	= kmp1_ENV
		kgoto	done_ENV
;release
rel_ENV:
kmp2_ENV	transeg	1, iRel_ENV, -6, 0.0024787521
kout_ENV	= kmp2_ENV * kmp1_ENV

done_ENV:
;kout_ENV is envelope
;************************************************************************************************GEN
;Input kout_ENV (output from ENV)
;Output aout_Air (to PIPE section)

;iPitch_GEN from -48 to +168
kPitch_GEN	= ((iPitch - 60) * kK_Track_GEN + kCut_GEN) * (1 - (0.5 * kV_Track_GEN))

kCut_GEN	table	kPitch_GEN + 192, 11	;exp table; add 192 for positive index

anoise_GEN	noise	kout_ENV, 0

	if (k1_Pole_GEN < 0.5)	kgoto Deux_Pole_GEN

;One pole filter LPF1
i2Pisr		= 2*$M_PI/sr
kPhic_GEN	= (kCut_GEN < 6948.89 ? i2Pisr * kCut_GEN : 0.99005)

;LP
aout_LPF	biquad	anoise_GEN, kPhic_GEN, 0, 0, 1, kPhic_GEN-1, 0

		kgoto	Done_GEN
Deux_Pole_GEN:
;Two poles filter LPF2
kRes_GEN	= 0.5  / (1 - kRes_GEN)

aout_LPF	lowpass2	anoise_GEN, kCut_GEN, kRes_GEN

Done_GEN:
aout_Air	= aout_LPF * kDC_Noise_GEN + a (kout_ENV) *  (1 - kDC_Noise_GEN)

;*******************************************************************************************PIPE SECTION
;Input aout_Air (output from AIR)
;Output aout_Pipe (to AMPLI)
;*******************************************************************************************DEL TUNE
;Output idly_DT (to SINGLE DELAY and FEEDBACK)

;iPitch_DT from -27 to +147
kPitch_DT		= iPitch + kTune_DT + kFine_DT + kCtr_MW * kMW_DT
kFreq_DT		table	kPitch_DT + 192, 11		;exp table; add 192 for positive index
kdly_DT		= (1/kFreq_DT)+( kSREC_DT/sr)

;************************************************************************************SINGLE DELAY
;Input idly_DT (output from DEL TUNE)
;Input aout_FeedBack (output from FEEDBACK)
;Output aout_SD  (to ALLPASS)

aout_FeedBack	init	0

amaxtime_SD	delayr	1			;set maximum delay
aout_SD		deltap3	 kdly_DT
			delayw	aout_FeedBack

;Send the signal aout_SD to Saturation (Allpass is bypassed) if iPower_AP = 0.

if kPower_AP > 0.5	goto	Allpasstune

aout_AP	= aout_SD
		goto Saturation
Allpasstune:
;************************************************************************************ALLPASS TUNE
;Output idly_APTune (to ALLPASS)

;iPitch_AP from -27 to +147
kPitch_AP		= iPitch + kTune_AP + kFine_AP + kCtr_MW * kMW_AP
kFreq_AP		table	kPitch_AP + 192, 11			;exp table; add 192 for positive index
kdly_APTune	= (1/kFreq_AP)+( kSREC_AP/sr)

;******************************************************************************************ALLPASS
;Input aout_SD (from SINGLE DELAY)
;Input idly_APTune (from ALLPASS TUNE)
;Output aout_AP  (to SATURATION)

;Interp Diffusion	;atime mini=1/sr
adel1_APA	init	0

amaxtime_APA	delayr	0.2						;set maximum delay
aout_AP		= adel1_APA + kDffs_AP * aout_SD		;FEED FORWARD
adel1_APA		deltap3	kdly_APTune				;DELAY
			delayw	aout_SD - kDffs_AP * aout_AP	;FEEDBACK
Saturation:
;**************************************************************************************SATURATION
;Input aout_AP  (from ALLPASS)
;Output aout_Sat  (to MW FILTER)

;Event Clip
kSoftHard_Clip	= ( kSoftHard == 0 ? 0.00001 : kSoftHard)
kSoftHard_Clip = ( kSoftHard == 1 ? 0.99999 : kSoftHard)

kSHS		= kSoftHard_Clip * kSym
kMaxClipper	= kSHS +  kSoftHard_Clip
kMinClipper	= kSHS -  kSoftHard_Clip

aoutClip	limit	aout_AP, kMinClipper, kMaxClipper

;Positive signal
kSat_coefPlus	= 0.5 * (1 + kSym - kMaxClipper)
;Saturator
ain_SatPlus	= (aout_AP - aoutClip) / kSat_coefPlus
;Clipper (to limit output to +2, when input is > +4)
ain_SatPlus	limit	ain_SatPlus, 0, 4							;Positive clip and remove negative signal
aSat_outPlus	= (-0.125 * ain_SatPlus * ain_SatPlus) + ain_SatPlus		;Out=-0.125*In*In+In if In>0 ; In = 4 -> Out = 2

;Negative signal
kSat_coefMoins	= 0.5 * (1 - kSym + kMinClipper)
;Saturator
ain_SatMoins	= (aout_AP - aoutClip) / kSat_coefMoins
;Clipper (to limit output to -2, when input is <-4)
ain_SatMoins	limit	ain_SatMoins, -4, 0							;Negative clip and remove negative signal
aSat_outMoins	= (0.125 * ain_SatMoins * ain_SatMoins) + ain_SatMoins		;Out=0.125*In*In+In if In<0  ; In = -4 -> Out = -2

aout_Sat	= (aSat_outPlus * kSat_coefPlus) +  (aSat_outMoins * kSat_coefMoins) + aoutClip

;*****************************************************************************************MW FILTER
;Input aout_Sat  (from SATURATION)
;Output aout_Pipe (to AMPLI, FEEDBACK, PUSH PULL)

;HPF1
;iPitch_MWHP from -48 to +168
kPitch_MWHP	= (iPitch-60) * kK_TrackH + (1- kCtr_MW) * kHP0 + kCtr_MW * kHP1
kFreq_MWHP	table	kPitch_MWHP + 192, 11						;exp table; add 192 for positive index
kPhic_MWHP	= (kFreq_MWHP < 6948.89 ? i2Pisr * kFreq_MWHP : 0.99005)

aout_HPF1	biquad	aout_Sat, 1, -1, 0, 1, kPhic_MWHP-1, 0

;LPF1
;iPitch_MWLP from -48 to +168
kPitch_MWLP	= (iPitch-60) * kK_TrackL + (1- kCtr_MW) * kLP0 + kCtr_MW * kLP1
kFreq_MWLP	table	kPitch_MWLP + 192, 11						;exp table; add 192 for positive index
kPhic_MWLP	= (kFreq_MWLP < 6948.89 ? i2Pisr * kFreq_MWLP : 0.99005)

aout_Pipe	biquad	aout_HPF1, kPhic_MWLP, 0, 0, 1, kPhic_MWLP-1, 0

;******************************************************************************************PUSH PULL
;Input aout_Air (from AIR)
;Input aout_Pipe  (from MW FILTER)
;Output aout_PPull (to FEEDBACK)

aout_PPull	= (aout_Pipe * kPush + kPolarity * kOffset) * aout_Air

;******************************************************************************************FEEDBACK
;Input aout_Pipe  (from MW FILTER)
;entrée kdly_DelTune (from DEL TUNE)
;Output aout_FeedBack (to SINGLE DELAY)

;Midi to freq conversion (note 69 = 440Hz)
;Cannot use cpsoct (P/12 + 3) because P can go below -36
kPitch_FB	= (iPitch - 60) * kK_TrackFB  + kRT_FB
kFreq_FB	table	kPitch_FB + 192, 11								;exp table; add 192 for positive index
kLevel_FB	= 60.0 * (1 - kdly_DT * kFreq_FB)
kLevel_FB	= 0.001 * ampdb (kLevel_FB)

kPitch_FB_Rel	= kPitch_FB + kDamp_FB
kFreq_FB_Rel	table	kPitch_FB_Rel + 192, 11						;exp table; add 192 for positive index
kLevel_FB_Rel	= 60.0 * (1 - kdly_DT * kFreq_FB_Rel)
kLevel_FB_Rel	= 0.001 * ampdb (kLevel_FB_Rel)

		if   (krel_ENV > .5)	kgoto	Rel_FB
aout_FBack	= aout_Pipe * kLevel_FB
		kgoto	done_FB
Rel_FB:
aout_FBack	= aout_Pipe * kLevel_FB_Rel

done_FB:
aout_FeedBack	= (aout_FBack + aout_PPull) * kPolarity
;*****************************************************************************************PIPE SECTION END
		xout	aout_Pipe
endop


opcode	REVERB, aa, aiiiiiiiiiiik

aIn_Reverb,\	;audio input
\
iTime_Rev,\	;knob Time
iLR_Rev,\		;knob L/R
iSize_Rev,\	;knob Size
iRT_Rev,\		;knob RT
iLP_Rev,\		;knob LP
iLD_Rev,\		;knob LD
iHD_Rev,\		;knob HD
iFrq_Rev,\	;knob Frq,	LFO sinus frequency
iSpin_Rev,\	;knob Spin,	LFO sinus amplitude
iDizzy_Rev,\	;knob Dizzy,	Slow Random amplitude
iPos_Rev,\	;knob Pos	0 à 1
kMix_Rev\		;knob Mix	0 à 1
		xin

		setksmps	128	

aoutL_Feed	init	0
aoutR_Feed	init	0

;****************************************************************************************DEL SECTION
;***********************************************************************************************
;Inputs ainL_dry and ainR_dry (global stereo signal)
;Outputs aoutL_Del et aoutR_Del (to DIFFUSION)

;direct signal
ainL_dry	= aIn_Reverb
ainR_dry	= aIn_Reverb

idelL		=		iTime_Rev * (1 + iLR_Rev)
idelR		=		iTime_Rev * (1 - iLR_Rev)

aoutL_Del		vdelay	ainL_dry, idelL, 500
aoutR_Del		vdelay	ainR_dry, idelR, 500

;*************************************************************************************DEL SECTION END

;**********************************************************************************DIFFUSION SECTION
;***********************************************************************************************
;Inputs aoutL_Del and aoutR_Del (from DEL)
;Outputs ainL_wet and ainR_wet (to OUT)

;**************************************************************************************EARLY DIFF
;Inputs aoutL_Del and aoutR_Del (from DEL)
;Outputs ainL_EDiff and ainR_EDiff (to LOPASS)

;Diffusion with variable Delay ;ktime mini=2/sr
iDffs		=		0.5 + (iSize_Rev * 0.0041666666)

itime_1L_ED	table	iSize_Rev + 4, 1	;exp table; in seconds
itime_2L_ED	table	iSize_Rev + 8, 1	;exp table; in seconds
itime_3L_ED	table	iSize_Rev + 12, 1	;exp table; in seconds

itime_1R_ED	table	iSize_Rev + 6, 1	;exp table; in seconds
itime_2R_ED	table	iSize_Rev + 10, 1	;exp table; in seconds
itime_3R_ED	table	iSize_Rev + 14, 1	;exp table; in seconds

;Diffuser delay 1L
adel1L_ED		init		0
amaxtime1L_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_1L		=		adel1L_ED + iDffs * aoutL_Del		; FEED FORWARD
adel1L_ED		deltap	itime_1L_ED					; DELAY
			delayw	aoutL_Del - iDffs * aEDiff_1L		; FEEDBACK
;Diffuser delay 2L
adel2L_ED		init	0
amaxtime2L_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_2L		=		adel2L_ED + iDffs * aEDiff_1L		; FEED FORWARD
adel2L_ED		deltap	itime_2L_ED					; DELAY
			delayw	aEDiff_1L - iDffs * aEDiff_2L		; FEEDBACK
;Diffuser delay 3L
adel3L_ED		init	0
amaxtime3L_ED	delayr	0.2							; set maximum delay 200 ms
ainL_EDiff	=		adel3L_ED + iDffs * aEDiff_2L		; FEED FORWARD
adel3L_ED		deltap	itime_3L_ED					; DELAY
			delayw	aEDiff_2L - iDffs * ainL_EDiff	; FEEDBACK

;Diffuser delay 1R
adel1R_ED		init	0
amaxtime1R_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_1R		=		adel1R_ED + iDffs * aoutR_Del		; FEED FORWARD
adel1R_ED		deltap	itime_1R_ED					; DELAY
			delayw	aoutR_Del - iDffs * aEDiff_1R		; FEEDBACK
;Diffuser delay 2R
adel2R_ED		init	0
amaxtime2R_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_2R		=		adel2R_ED + iDffs * aEDiff_1R		; FEED FORWARD
adel2R_ED		deltap	itime_2R_ED					; DELAY
			delayw	aEDiff_1R - iDffs * aEDiff_2R		; FEEDBACK
;Diffuser delay 3R
adel3R_ED		init	0
amaxtime3R_ED	delayr	0.2							; set maximum delay 200 ms
ainR_EDiff	=		adel3R_ED + iDffs * aEDiff_2R		; FEED FORWARD
adel3R_ED		deltap	itime_3R_ED					; DELAY
			delayw	aEDiff_2R - iDffs * ainR_EDiff	; FEEDBACK

;*****************************************************************************************LOPASS
;Inputs ainL_EDiff and ainR_EDiff (from EARLY DIFF)
;Outputs aoutL_LP and aoutR_LP  (to DAMP L, POWER FADE L, DAMP R, POWER FADE R)

ifreq_LP		table	iLP_Rev, 2			;exp2 table; Pitch to freq convertion in hertz

aoutL_LP		tone		ainL_EDiff, ifreq_LP
aoutR_LP		tone		ainR_EDiff, ifreq_LP

;**************************************************************************************DAMP L et R
;Inputs aoutL_LP (from LOPASS) and aoutR_Feed (from DIFF R)
;Inputs aoutR_LP (from LOPASS) and aoutL_Feed (from DIFF L)
;Outputs aoutL_Damp (to DIFF L) and aoutR_Damp (to DIFF R)

ivH			= ampdb (-iHD_Rev)
ivL			= ampdb (-iLD_Rev)

ainL_Damp		=		aoutL_LP + aoutR_Feed
aH			pareq	ainL_Damp, 2093, ivH, 0.707 , 2	;L Damp HiShelfEQ
aoutL_Damp	pareq	aH, 262, ivL, 0.707 , 1			;L Damp LoShelfEQ

ainR_Damp		=		aoutR_LP + aoutL_Feed
aH			pareq	ainR_Damp, 2093, ivH, 0.707 , 2	;R Damp HiShelfEQ
aoutR_Damp	pareq	aH, 262, ivL, 0.707 , 1			;R Damp LoShelfEQ

;***************************************************************************************16 PHASE
;Outputs kphase1,kphase2,kphase3,kphase4 (to DIFF L)
;Outputs kphase5,kphase6,kphase7,kphase8 (to DIFF R)

;LFO +Slow Random gen N1
iseed1		=		0
krand1		randh	iDizzy_Rev, 400, iseed1
krand1		tonek	krand1, iFrq_Rev * 0.7
klfo1		poscil	iSpin_Rev, iFrq_Rev, 3, 0.9375	;phase=1-1/16
kphase1		=		klfo1 * 0.001 + krand1 * 0.004
kphase5		=		- kphase1
;LFO +Slow Random gen N2
iseed2		=		0.2
krand2		randh	iDizzy_Rev, 400, iseed2
krand2		tonek	krand2, iFrq_Rev * 0.7
klfo2		poscil	iSpin_Rev, iFrq_Rev, 3, 0.875		;phase=1-2/16
kphase2		=		klfo2 * 0.001 + krand2 * 0.004
kphase6		=		- kphase2
;LFO +Slow Random gen N3
iseed3		=		0.4
krand3		randh	iDizzy_Rev, 400, iseed3
krand3		tonek	krand3, iFrq_Rev * 0.7
klfo3		poscil	iSpin_Rev, iFrq_Rev, 3, 0.8125	;phase=1-3/16
kphase3		=		klfo3 * 0.001 + krand3 * 0.004
kphase7		=		- kphase3
;LFO +Slow Random gen N4
iseed4		=		0.6
krand4		randh	iDizzy_Rev, 400, iseed4
krand4		tonek	krand4, iFrq_Rev * 0.7
klfo4		poscil	iSpin_Rev, iFrq_Rev, 3, 0.75		;phase=1-4/16
kphase4		=		klfo4 * 0.001 + krand4 * 0.004
kphase8		=		- kphase4

;******************************************************************************************DIFF L
;Input aoutL_Damp (from DAMP L)
;Outputs aoutL_Diff (to POWER FADE L) and aoutL_Feed (to DAMP R)

;Diffusion with variable Delay ;ktime mini=2/sr
;iDffs same value as in EARLY DIFF

itime_1L_Diff	table	iSize_Rev + 31, 1	;exp table; in seconds
itime_2L_Diff	table	iSize_Rev + 35, 1	;exp table; in seconds
itime_3L_Diff	table	iSize_Rev + 39, 1	;exp table; in seconds
itime_4L_Diff	table	iSize_Rev + 46, 1	;exp table; in seconds

ktime_1L_Diff	=		itime_1L_Diff + kphase1
ktime_2L_Diff	=		itime_2L_Diff + kphase2
ktime_3L_Diff	=		itime_3L_Diff + kphase3
ktime_4L_DiffRT	=	itime_4L_Diff + kphase4

ktime_1L_Diff	portk	ktime_1L_Diff, 0.1
ktime_2L_Diff	portk	ktime_2L_Diff, 0.1
ktime_3L_Diff	portk	ktime_3L_Diff, 0.1
ktime_4L_Diff	portk	ktime_4L_DiffRT, 0.1

;Diffuser delay 1L
adel1L_Diff	init	0
amaxtime1L_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_1L		=	adel1L_Diff + iDffs * aoutL_Damp	; FEED FORWARD
adel1L_Diff	deltap3	ktime_1L_Diff				; DELAY
			delayw	aoutL_Damp - iDffs * aDiff_1L	; FEEDBACK

;Diffuser delay 2L
adel2L_Diff	init	0
amaxtime2L_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_2L		=	adel2L_Diff + iDffs * aDiff_1L	; FEED FORWARD
adel2L_Diff	deltap3	ktime_2L_Diff				; DELAY
			delayw	aDiff_1L - iDffs * aDiff_2L	; FEEDBACK

;Diffuser delay 3L
adel3L_Diff	init	0
amaxtime3L_Diff	delayr	1.0					; set maximum delay 1000 ms
aoutL_Diff	=	adel3L_Diff + iDffs * aDiff_2L	; FEED FORWARD
adel3L_Diff	deltap3	ktime_3L_Diff				; DELAY
			delayw	aDiff_2L - iDffs * aoutL_Diff	; FEEDBACK

;Single delay 4L
aoutL_SD		vdelay	aoutL_Diff, a (ktime_4L_Diff), 1500

iFeed1		table	iRT_Rev, 1				;exp table
iFeed2		=	-1.115 / iFeed1

aoutL_Feed	= aoutL_SD * ampdb ( ktime_4L_DiffRT * iFeed2)

;******************************************************************************************DIFF R
;Input aoutR_Damp (from DAMP R)
;Outputs aoutR_Diff (to POWER FADE R) and aoutR_Feed (to DAMP L)

;Diffusion with variable Delay ;ktime mini=2/sr
;iDffs same value as in EARLY DIFF

itime_1R_Diff	table	iSize_Rev + 31, 1	;exp table; in seconds
itime_2R_Diff	table	iSize_Rev + 35, 1	;exp table; in seconds
itime_3R_Diff	table	iSize_Rev + 39, 1	;exp table; in seconds
itime_4R_Diff	table	iSize_Rev + 46, 1	;exp table; in seconds

ktime_1R_Diff	= itime_1R_Diff + kphase5
ktime_2R_Diff	= itime_2R_Diff + kphase6
ktime_3R_Diff	= itime_3R_Diff + kphase7
ktime_4R_DiffRT	= itime_4R_Diff + kphase8

ktime_1R_Diff	portk	ktime_1R_Diff, 0.1
ktime_2R_Diff	portk	ktime_2R_Diff, 0.1
ktime_3R_Diff	portk	ktime_3R_Diff, 0.1
ktime_4R_Diff	portk	ktime_4R_DiffRT, 0.1

;Diffuser delay 1R
adel1R_Diff	init	0
amaxtime1R_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_1R		=	adel1R_Diff + iDffs * aoutR_Damp	; FEED FORWARD
adel1R_Diff	deltap3	ktime_1R_Diff				; DELAY
			delayw	aoutR_Damp - iDffs * aDiff_1R	; FEEDBACK

;Diffuser delay 2R
adel2R_Diff	init	0
amaxtime2R_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_2R		=	adel2R_Diff + iDffs * aDiff_1R	; FEED FORWARD
adel2R_Diff	deltap3	ktime_2R_Diff				; DELAY
			delayw	aDiff_1R - iDffs * aDiff_2R	; FEEDBACK

;Diffuser delay 3R
adel3R_Diff	init	0
amaxtime3R_Diff	delayr	1.0					; set maximum delay 1000 ms
aoutR_Diff	=	adel3R_Diff + iDffs * aDiff_2R	; FEED FORWARD
adel3R_Diff	deltap3	ktime_3R_Diff				; DELAY
			delayw	aDiff_2R - iDffs * aoutR_Diff	; FEEDBACK

;Single delay 4R
aoutR_SD		vdelay	aoutR_Diff, a (ktime_4R_Diff), 1500

;iFeed2 same as in DIFF L
aoutR_Feed	= aoutR_SD * ampdb ( ktime_4R_DiffRT * iFeed2)

;*******************************************************************************POWER FADE L and R
;Inputs aoutL_LP (from LOPASS) and aoutL_Diff (from DIFF L)
;Inputs aoutR_LP (from LOPASS) and aoutR_Diff (from DIFF R)
;Outputs ainL_wet and ainR_wet (to OUT)

isqrtPos_Rev0	= sqrt (1 - iPos_Rev)
isqrtPos_Rev1	= sqrt (iPos_Rev)

ainL_wet		= isqrtPos_Rev0 * aoutL_LP + isqrtPos_Rev1 * aoutL_Diff
ainR_wet		= isqrtPos_Rev0 * aoutR_LP + isqrtPos_Rev1 * aoutR_Diff

;*******************************************************************************DIFFUSION SECTION END

;****************************************************************************************OUT SECTION
;***********************************************************************************************
;Inputs ainL_dry and ainR_dry (global inputs of stereo signal)
;Inputs ainL_wet and ainR_wet (from DIFFUSION)
;Outputs audio aoutL and aoutR

ksqrtMix_Rev0	= sqrt (1 - kMix_Rev)
ksqrtMix_Rev1	= sqrt (kMix_Rev)

aoutL		= ksqrtMix_Rev0 * ainL_dry + ksqrtMix_Rev1 * ainL_wet
aoutR		= ksqrtMix_Rev0 * ainR_dry + ksqrtMix_Rev1 * ainR_wet

;*************************************************************************************OUT SECTION END

		xout		aoutL, aoutR
endop


instr	1	;Pipe (physical waveguide)
;ctrl reading
;ENV
kAtt_ENV		invalue	"kC1"	;knob Att
kDec_ENV		invalue	"kC2"	;knob Dec
kSus_ENV		invalue	"kC3"	;knob Sus
kRel_ENV		invalue	"kC4"	;knob Rel
kVel_ENV		invalue	"kC5"	;knob Vel
kScaling_ENV	invalue	"kC6"	;knob Scaling
;GEN
kDC_Noise_GEN	invalue	"kC7"	;knob DC/Noise
kCut_GEN		invalue	"kC8"	;knob Cut
kRes_GEN		invalue	"kC9"	;knob Res
kK_Track_GEN	invalue	"kC10"	;knob K-Track
kV_Track_GEN	invalue	"kC11"	;knob V-Track
k1_Pole_GEN	invalue	"kC12"	;button 1-Pole
;Pipe
kCtr_MW		invalue	"kC13"	;knob ModWheel
kPolarity		invalue	"kC14"	;button Polarity
;Pipe DELTUNE
kTune_DT		invalue	"kC15"	;knob Tune
kFine_DT		invalue	"kC16"	;knob Fine
kSREC_DT		invalue	"kC17"	;knob Srec
kMW_DT		invalue	"kC18"	;knob MW
;Pipe FEEDBACK
kRT_FB		invalue	"kC19"	;knob RT
kK_TrackFB	invalue	"kC20"	;knob K-Track
kDamp_FB		invalue	"kC21"	;knob Damp
;Pipe ALLPASS TUNE
kTune_AP		invalue	"kC22"	;knob Tune
kFine_AP		invalue	"kC23"	;knob Fine
kSREC_AP		invalue	"kC24"	;knob Srec
kMW_AP		invalue	"kC25"	;knob MW
;Pipe ALLPASS
kDffs_AP		invalue	"kC26"	;knob Dffs
kPower_AP		invalue	"kC27"	;button Power
;Pipe PUSH PULL
kOffset		invalue	"kC28"	;knob Offset
kPush		invalue	"kC29"	;knob Push
;Pipe SATURATION
kSoftHard		invalue	"kC30"	;knob Soft/Hard
kSym			invalue	"kC31"	;knob Sym
;Pipe MW FILTER
kHP0			invalue	"kC32"	;knob HP0
kHP1			invalue	"kC33"	;knob HP1
kK_TrackH		invalue	"kC34"	;knob K-Track
kLP0			invalue	"kC35"	;knob LP0
kLP1			invalue	"kC36"	;knob LP1
kK_TrackL		invalue	"kC37"	;knob K-Track

kMain_Vol		invalue	"kC50"	;knob Main Vol

kPolarity		= 1 - 2*i(kPolarity)

iPitch = p4			;iPitch, midi note from 36 to 84 with midi keyboard

aout_Pipe		PIPE	iPitch, i(kAtt_ENV), i(kDec_ENV), i(kSus_ENV), i(kRel_ENV), i(kVel_ENV), i(kScaling_ENV), kDC_Noise_GEN, kCut_GEN, kRes_GEN, kK_Track_GEN, kV_Track_GEN, k1_Pole_GEN, kCtr_MW, kPolarity, kTune_DT, \
				kFine_DT, kSREC_DT, kMW_DT, kRT_FB, kK_TrackFB, kDamp_FB, kTune_AP, kFine_AP, kSREC_AP, kMW_AP, kDffs_AP, kPower_AP, kOffset, kPush, kSoftHard, kSym, kHP0, kHP1, \
				kK_TrackH, kLP0, kLP1, kK_TrackL

		gaIn_Reverb	= gaIn_Reverb + aout_Pipe * kMain_Vol
endin

instr	99		;Reverb unit

;Running LED, just for fun ***********************
ktempo		lfo		1, 0.5, 2
			outvalue	"tempo", ktempo
;**********************************************

kTime_Rev		invalue	"kC38"	;knob Time
kLR_Rev		invalue	"kC39"	;knob L/R
kSize_Rev		invalue	"kC40"	;knob Size
kRT_Rev		invalue	"kC41"	;knob RT
kLP_Rev		invalue	"kC42"	;knob LP
kLD_Rev		invalue	"kC43"	;knob LD
kHD_Rev		invalue	"kC44"	;knob HD
kFrq_Rev		invalue	"kC45"	;knob Frq,	LFO sinus frequency
kSpin_Rev		invalue	"kC46"	;knob Spin,	LFO sinus amplitude
kDizzy_Rev	invalue	"kC47"	;knob Dizzy,	Slow Random amplitude
kPos_Rev		invalue	"kC48"	;knob Pos,	0 to 1
kMix_Rev		invalue	"kC49"	;knob Mix,	0 to 1

			denorm			gaIn_Reverb

k110_active		active	110

PRESET:
aoutL, aoutR	REVERB	gaIn_Reverb, i(kTime_Rev), i(kLR_Rev), i(kSize_Rev), i(kRT_Rev), i(kLP_Rev), i(kLD_Rev), i(kHD_Rev), i(kFrq_Rev), i(kSpin_Rev), i(kDizzy_Rev), i(kPos_Rev), kMix_Rev

; to give some delay for the preset to have the correct values before doing the reinit
			if ( k110_active == 1) then 
				kpreset = 1
			endif

			if (kpreset == 1 && k110_active == 0) then
				kpreset = 0
				reinit PRESET
			endif

;vu-meters
kLeft			rms		aoutL
kRight		rms		aoutR
			outvalue	"vu_Left", kLeft
			outvalue	"vu_Right", kRight

			outs		aoutL*10000, aoutR*10000

gaIn_Reverb	= 0
endin

</CsInstruments>
<CsScore>
;Table  exp= (1/1000) * pow(10; (indx-44)/20) for ADSR (in sec)
f 10 0 256 -25 0 0.000006 12 0.000025 24 0.0001 36 0.000398 48 0.001584 60 0.006309 72 0.02511 84 0.1 96 0.398107 108 1.5848931 120 6.3095734 132 25.1188 144 100.0 156 398.10 168 1584.89 256 2000
;Table  exp= 440 * pow(2; (indx-192-69)/12) Pitch to Frequency table for P=-192 à +198
f 11 0 512 -25 0 0.00012475 12 0.00024951 24 0.00049901 36 0.00099802 48 0.00199604 60 0.00399209 72 0.00798418 84 0.01596836 96 0.03193671 108 0.06387343 120 0.12774686 132 0.25549372 144 0.51098743 156 1.02197486 168 2.04394973 180 4.08789946 192 8.17579892 204 16.3515978 216 32.7031957 228 65.4063913 240 130.812783 252 261.625565 264 523.251131 276 1046.50226 288 2093.00452 300 4186.00904 312 8372.01809 324 16744.0362 336 33488.0724 348 66976.1447 360 133952.289 372 267904.579 384 535809.158 396 1071618.32 512 100

;Reverb
f 1 0 128 -25 0 0.00227272727 128 3.69431518	;Table  exp1= (1/440) * pow(2; (indx)/12)
f 2 0 128 -25 0 8.17579892 128 13289.7503	;Table  exp2= 440 * pow(2; (indx-69)/12)
f 3 0 512 10 1							;sinus for poscil

i 99 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 103 52 974 798
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32125, 41634, 41120}
ioText {3, 0} {952, 30} label 0.000000 0.00100 "" center "DejaVu Sans" 20 {0, 0, 0} {45056, 44544, 32512} background noborder SYNTH PIPE
ioText {137, 440} {658, 218} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border REVERB
ioText {5, 32} {302, 203} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border AIR ENVELOPPE
ioSlider {23, 79} {19, 99} -20.000000 100.000000 20.000000 kC1
ioText {21, 182} {30, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Att
ioText {13, 204} {51, 23} display 0.000000 0.00100 "kC1" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 25.0000
ioText {24, 54} {26, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 01
ioSlider {68, 79} {19, 99} -20.000000 100.000000 18.787879 kC2
ioText {66, 182} {30, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dec
ioText {58, 204} {51, 23} display 0.000000 0.00100 "kC2" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 20.0000
ioText {69, 55} {26, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 02
ioSlider {114, 79} {19, 99} 0.000000 1.000000 0.898990 kC3
ioText {112, 182} {30, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Sus
ioText {104, 204} {51, 23} display 0.000000 0.00100 "kC3" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.9000
ioText {115, 55} {26, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 03
ioSlider {159, 79} {19, 99} -20.000000 100.000000 47.878788 kC4
ioText {157, 182} {30, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Rel
ioText {149, 204} {51, 23} display 0.000000 0.00100 "kC4" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 49.0909
ioText {160, 55} {26, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 04
ioSlider {207, 78} {19, 99} 0.000000 1.000000 0.202020 kC5
ioText {205, 181} {30, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Vel
ioText {197, 204} {51, 23} display 0.000000 0.00100 "kC5" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.3300
ioText {208, 54} {26, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 05
ioSlider {254, 78} {19, 99} -1.000000 0.000000 -0.626263 kC6
ioText {252, 181} {30, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Scal
ioText {244, 203} {51, 23} display 0.000000 0.00100 "kC6" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border -0.5000
ioText {255, 54} {26, 22} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 06
ioSlider {158, 497} {20, 100} 0.000000 240.000000 16.800000 kC38
ioText {156, 600} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Time
ioText {148, 622} {52, 24} display 0.000000 0.00100 "kC38" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 16.8000
ioText {159, 473} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 38
ioSlider {211, 497} {20, 100} -1.000000 1.000000 0.380000 kC39
ioText {209, 600} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder L/R
ioText {201, 622} {52, 24} display 0.000000 0.00100 "kC39" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.3800
ioText {212, 473} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 39
ioSlider {264, 497} {20, 100} 0.000000 60.000000 30.000000 kC40
ioText {262, 600} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Size
ioText {254, 622} {52, 24} display 0.000000 0.00100 "kC40" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 30.0000
ioText {265, 473} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 40
ioSlider {317, 497} {20, 100} 0.000000 120.000000 60.000000 kC41
ioText {315, 600} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder RT
ioText {307, 622} {52, 24} display 0.000000 0.00100 "kC41" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 60.0000
ioText {318, 473} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 41
ioSlider {370, 497} {20, 100} 24.000000 144.000000 144.000000 kC42
ioText {368, 600} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder LP
ioText {360, 622} {52, 24} display 0.000000 0.00100 "kC42" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 144.0000
ioText {371, 473} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 42
ioSlider {423, 496} {20, 100} 0.000000 30.000000 1.500000 kC43
ioText {421, 599} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder LD
ioText {413, 621} {52, 24} display 0.000000 0.00100 "kC43" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 1.5000
ioText {424, 472} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 43
ioSlider {476, 496} {20, 100} 0.000000 30.000000 1.500000 kC44
ioText {474, 599} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder HD
ioText {466, 621} {52, 24} display 0.000000 0.00100 "kC44" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 1.5000
ioText {477, 472} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 44
ioSlider {529, 496} {20, 100} 0.000000 2.000000 0.400000 kC45
ioText {527, 599} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq
ioText {519, 621} {52, 24} display 0.000000 0.00100 "kC45" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.4000
ioText {530, 472} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 45
ioSlider {582, 496} {20, 100} 0.000000 2.000000 0.280000 kC46
ioText {580, 599} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Spin
ioText {572, 621} {52, 24} display 0.000000 0.00100 "kC46" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.3000
ioText {583, 472} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 46
ioSlider {635, 496} {20, 100} 0.000000 2.000000 0.200000 kC47
ioText {633, 599} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dizzy
ioText {625, 621} {52, 24} display 0.000000 0.00100 "kC47" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.2000
ioText {636, 472} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 47
ioSlider {688, 496} {20, 100} 0.000000 1.000000 0.750000 kC48
ioText {686, 599} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Pos
ioText {678, 621} {52, 24} display 0.000000 0.00100 "kC48" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.7500
ioText {689, 472} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 48
ioSlider {741, 496} {20, 100} 0.000000 1.000000 0.080000 kC49
ioText {739, 599} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Mix
ioText {731, 621} {52, 24} display 0.000000 0.00100 "kC49" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0800
ioText {742, 472} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 49
ioText {310, 31} {315, 204} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border AIR GENERATOR
ioSlider {325, 77} {20, 100} 0.000000 1.000000 0.500000 kC7
ioText {323, 180} {36, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Noise
ioText {315, 202} {52, 24} display 0.000000 0.00100 "kC7" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.5000
ioText {326, 52} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 07
ioSlider {379, 77} {20, 100} 0.000000 120.000000 97.200000 kC8
ioText {377, 180} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Cut
ioText {369, 202} {52, 24} display 0.000000 0.00100 "kC8" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 98.0000
ioText {380, 53} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 08
ioSlider {432, 77} {20, 100} 0.000000 1.000000 0.000000 kC9
ioText {430, 180} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Res
ioText {422, 202} {52, 24} display 0.000000 0.00100 "kC9" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioText {433, 53} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 09
ioSlider {485, 77} {20, 100} 0.000000 2.000000 0.660000 kC10
ioText {483, 180} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder KTr
ioText {475, 202} {52, 24} display 0.000000 0.00100 "kC10" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.6600
ioText {486, 53} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10
ioSlider {538, 76} {20, 100} 0.000000 1.000000 0.330000 kC11
ioText {536, 179} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder VTr
ioText {528, 202} {52, 24} display 0.000000 0.00100 "kC11" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.3300
ioText {539, 52} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11
ioText {571, 93} {46, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12: 1P
ioCheckbox {584, 123} {20, 20} on kC12
ioText {633, 239} {322, 198} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border FILTER
ioSlider {646, 286} {20, 100} 0.000000 120.000000 12.000000 kC32
ioText {643, 389} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder HP0
ioText {635, 411} {52, 24} display 0.000000 0.00100 "kC32" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 12.0000
ioText {646, 261} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 32
ioSlider {699, 286} {20, 100} 0.000000 120.000000 60.000000 kC33
ioText {697, 389} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder HP1
ioText {689, 411} {52, 24} display 0.000000 0.00100 "kC33" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 60.0000
ioText {700, 262} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 33
ioSlider {753, 286} {20, 100} 0.000000 2.000000 1.000000 kC34
ioText {750, 389} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder KTrH
ioText {742, 411} {52, 24} display 0.000000 0.00100 "kC34" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 1.0000
ioText {753, 262} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 34
ioSlider {805, 286} {20, 100} 0.000000 120.000000 60.000000 kC35
ioText {803, 389} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder LP0
ioText {795, 411} {52, 24} display 0.000000 0.00100 "kC35" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 60.0000
ioText {806, 262} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 35
ioSlider {858, 285} {20, 100} 0.000000 120.000000 96.000000 kC36
ioText {856, 388} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder LP1
ioText {848, 411} {52, 24} display 0.000000 0.00100 "kC36" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 96.0000
ioText {859, 261} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 36
ioSlider {911, 286} {20, 100} 0.000000 2.000000 0.780000 kC37
ioText {909, 389} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder KTrL
ioText {901, 411} {52, 24} display 0.000000 0.00100 "kC37" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.7800
ioText {912, 262} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 37
ioText {628, 31} {107, 204} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border PIPE
ioSlider {646, 78} {20, 100} 0.000000 1.000000 0.350000 kC13
ioText {642, 181} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MW
ioText {634, 204} {52, 24} display 0.000000 0.00100 "kC13" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.3622
ioText {645, 54} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 13
ioText {679, 96} {46, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 14: Pol
ioCheckbox {692, 124} {20, 20} on kC14
ioText {738, 31} {217, 203} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border DELAY TUNE
ioSlider {747, 77} {20, 100} -60.000000 60.000000 12.000000 kC15
ioText {746, 180} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Tune
ioText {738, 202} {52, 24} display 0.000000 0.00100 "kC15" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 14.0000
ioText {747, 52} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 15
ioSlider {803, 78} {20, 100} -1.000000 1.000000 -0.060000 kC16
ioText {800, 180} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Fine
ioText {792, 202} {52, 24} display 0.000000 0.00100 "kC16" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border -0.0600
ioText {803, 53} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 16
ioSlider {855, 77} {20, 100} -5.000000 0.000000 -1.400000 kC17
ioText {853, 180} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Srec
ioText {845, 202} {52, 24} display 0.000000 0.00100 "kC17" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border -1.3000
ioText {856, 53} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 17
ioSlider {908, 77} {20, 100} -2.000000 2.000000 -1.640000 kC18
ioText {906, 180} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MW
ioText {898, 202} {52, 24} display 0.000000 0.00100 "kC18" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border -1.6000
ioText {909, 53} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 18
ioText {6, 239} {160, 199} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border FEEDBACK
ioSlider {15, 285} {20, 100} -90.000000 30.000000 -87.600000 kC19
ioText {13, 388} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder RT
ioText {5, 410} {52, 24} display 0.000000 0.00100 "kC19" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border -86.4000
ioText {16, 260} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 19
ioSlider {69, 285} {20, 100} 0.000000 2.000000 1.000000 kC20
ioText {67, 388} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder KTr
ioText {59, 410} {52, 24} display 0.000000 0.00100 "kC20" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 1.0000
ioText {70, 261} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 20
ioSlider {122, 285} {20, 100} 0.000000 120.000000 110.400000 kC21
ioText {120, 388} {38, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Damp
ioText {112, 410} {52, 24} display 0.000000 0.00100 "kC21" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 110.4000
ioText {122, 261} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 21
ioText {179, 238} {213, 199} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border ALLPASS TUNE
ioSlider {188, 282} {20, 100} -60.000000 60.000000 -40.800000 kC22
ioText {187, 385} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Tune
ioText {179, 407} {52, 24} display 0.000000 0.00100 "kC22" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border -40.8000
ioText {190, 257} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 22
ioSlider {243, 282} {20, 100} -1.000000 1.000000 0.000000 kC23
ioText {241, 385} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Fine
ioText {233, 407} {52, 24} display 0.000000 0.00100 "kC23" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioText {244, 258} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 23
ioSlider {296, 282} {20, 100} -5.000000 0.000000 0.000000 kC24
ioText {294, 385} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Srec
ioText {286, 407} {52, 24} display 0.000000 0.00100 "kC24" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioText {297, 258} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 24
ioSlider {348, 282} {20, 100} -2.000000 2.000000 0.000000 kC25
ioText {346, 385} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MW
ioText {338, 407} {52, 24} display 0.000000 0.00100 "kC25" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioText {349, 258} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 25
ioText {406, 237} {86, 201} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border DELAY + ALLPASS
ioSlider {417, 282} {20, 100} -1.000000 1.000000 0.000000 kC26
ioText {415, 385} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Diff
ioText {407, 408} {52, 24} display 0.000000 0.00100 "kC26" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.0000
ioText {418, 257} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 26
ioText {441, 312} {46, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 27: On
ioCheckbox {452, 332} {20, 20} on kC27
ioText {508, 238} {110, 198} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border PUSH PULL
ioSlider {519, 283} {20, 100} -1.000000 1.000000 0.460000 kC28
ioText {517, 386} {39, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Offset
ioText {509, 408} {52, 24} display 0.000000 0.00100 "kC28" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.4800
ioText {520, 258} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 28
ioSlider {573, 283} {20, 100} 0.000000 2.000000 1.560000 kC29
ioText {571, 386} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Push
ioText {563, 408} {52, 24} display 0.000000 0.00100 "kC29" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 1.5600
ioText {574, 259} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 29
ioText {7, 441} {117, 216} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border SATURATION
ioSlider {18, 487} {20, 100} 0.000000 1.000000 0.330000 kC30
ioText {16, 590} {39, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S / H
ioText {8, 612} {52, 24} display 0.000000 0.00100 "kC30" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.3300
ioText {19, 462} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 30
ioSlider {72, 487} {20, 100} 0.000000 1.000000 0.450000 kC31
ioText {70, 590} {31, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Sym
ioText {62, 612} {48, 24} display 0.000000 0.00100 "kC31" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 0.4500
ioText {73, 463} {27, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 31
ioText {806, 441} {149, 216} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {21760, 43520, 32512} background border MAIN
ioKnob {815, 489} {80, 80} 0.000000 5.000000 0.010000 0.959596 kC50
ioText {812, 575} {88, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50 : Volume
ioText {826, 606} {57, 27} display 0.000000 0.00100 "kC50" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border 1.0000
ioGraph {3, 660} {283, 120} scope 2.000000 1.000000 
ioMeter {906, 447} {14, 178} {0, 59904, 0} "vu_Left" 0.000000 "hor210" 0.214286 fill 1 0 mouse
ioMeter {923, 447} {14, 178} {0, 59904, 0} "vu_Right" 0.000000 "hor210" 0.214286 fill 1 0 mouse
ioText {905, 624} {17, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder L
ioText {921, 624} {17, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioGraph {291, 661} {257, 120} scope 2.000000 2.000000 
ioMeter {856, 446} {18, 19} {6144, 59392, 0} "tempo" 1.000000 "hor220" 0.333333 fill 1 0 mouse
ioListing {551, 661} {405, 119}
</MacGUI>


<EventPanel name="" tempo="60.00000000" loop="9.00000000" name="" x="900" y="451" width="683" height="426">
i 1 0 3 60 







</EventPanel>
