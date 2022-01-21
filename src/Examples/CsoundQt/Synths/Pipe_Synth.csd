<CsoundSynthesizer>
<CsOptions>
-fdm0 --midi-key=4
</CsOptions>
<CsInstruments>
;Physical Waveguide Midi synth with CsoundQt GUI by René Djack 2009.
;Modified for CsoundQt examples by Andres Cabrera

sr 		= 48000
ksmps	= 512
nchnls	= 2

maxalloc	1, 10	;maximum polyphony
;prealloc	1, 9 ;preallocate voices
gaIn_Reverb	init	0

; all midi channels to instrument 1
massign		0, 1

chn_k "kC1", 1
chn_k "kC10", 1
chn_k "kC11", 1
chn_k "kC12", 1
chn_k "kC13", 1
chn_k "kC14", 1
chn_k "kC15", 1
chn_k "kC16", 1
chn_k "kC17", 1
chn_k "kC18", 1
chn_k "kC19", 1
chn_k "kC2", 1
chn_k "kC20", 1
chn_k "kC21", 1
chn_k "kC22", 1
chn_k "kC23", 1
chn_k "kC24", 1
chn_k "kC25", 1
chn_k "kC26", 1
chn_k "kC27", 1
chn_k "kC28", 1
chn_k "kC29", 1
chn_k "kC3", 1
chn_k "kC30", 1
chn_k "kC31", 1
chn_k "kC32", 1
chn_k "kC33", 1
chn_k "kC34", 1
chn_k "kC35", 1
chn_k "kC36", 1
chn_k "kC37", 1
chn_k "kC38", 1
chn_k "kC39", 1
chn_k "kC4", 1
chn_k "kC40", 1
chn_k "kC41", 1
chn_k "kC42", 1
chn_k "kC43", 1
chn_k "kC44", 1
chn_k "kC45", 1
chn_k "kC46", 1
chn_k "kC47", 1
chn_k "kC48", 1
chn_k "kC49", 1
chn_k "kC5", 1
chn_k "kC50", 1
chn_k "kC6", 1
chn_k "kC7", 1
chn_k "kC8", 1
chn_k "kC9", 1
chn_k "tempo", 2
chn_k "vu_Left", 2
chn_k "vu_Right", 2

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
kK_TrackL\		;knob K-TrackL
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
aout_Air	= aout_LPF * kDC_Noise_GEN + a(kout_ENV) *  (1 - kDC_Noise_GEN)

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

if kPower_AP > 0.5	kgoto	Allpasstune

aout_AP	= aout_SD
		kgoto Saturation
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
kLevel_FB	= 0.001 * ampdb(kLevel_FB)

kPitch_FB_Rel	= kPitch_FB + kDamp_FB
kFreq_FB_Rel	table	kPitch_FB_Rel + 192, 11						;exp table; add 192 for positive index
kLevel_FB_Rel	= 60.0 * (1 - kdly_DT * kFreq_FB_Rel)
kLevel_FB_Rel	= 0.001 * ampdb(kLevel_FB_Rel)

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


opcode	REVERB, aa, akkkkkkkkkkkk

aIn_Reverb,\	;audio input
\
kTime_Rev,\	;knob Time
kLR_Rev,\		;knob L/R
kSize_Rev,\	;knob Size
kRT_Rev,\		;knob RT
kLP_Rev,\		;knob LP
kLD_Rev,\		;knob LD
kHD_Rev,\		;knob HD
kFrq_Rev,\	;knob Frq,	LFO sinus frequency
kSpin_Rev,\	;knob Spin,	LFO sinus amplitude
kDizzy_Rev,\	;knob Dizzy,	Slow Random amplitude
kPos_Rev,\	;knob Pos	0 à 1
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

kdelL		=		kTime_Rev * (1 + kLR_Rev)
kdelR		=		kTime_Rev * (1 - kLR_Rev)

aoutL_Del		vdelay	ainL_dry, kdelL, 500
aoutR_Del		vdelay	ainR_dry, kdelR, 500

;*************************************************************************************DEL SECTION END

;**********************************************************************************DIFFUSION SECTION
;***********************************************************************************************
;Inputs aoutL_Del and aoutR_Del (from DEL)
;Outputs ainL_wet and ainR_wet (to OUT)

;**************************************************************************************EARLY DIFF
;Inputs aoutL_Del and aoutR_Del (from DEL)
;Outputs ainL_EDiff and ainR_EDiff (to LOPASS)

;Diffusion with variable Delay ;ktime mini=2/sr
kDffs		=		0.5 + (kSize_Rev * 0.0041666666)

ktime_1L_ED	table	kSize_Rev + 4, 1	;exp table; in seconds
ktime_2L_ED	table	kSize_Rev + 8, 1	;exp table; in seconds
ktime_3L_ED	table	kSize_Rev + 12, 1	;exp table; in seconds

ktime_1R_ED	table	kSize_Rev + 6, 1	;exp table; in seconds
ktime_2R_ED	table	kSize_Rev + 10, 1	;exp table; in seconds
ktime_3R_ED	table	kSize_Rev + 14, 1	;exp table; in seconds

;Diffuser delay 1L
adel1L_ED		init		0
amaxtime1L_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_1L		=		adel1L_ED + kDffs * aoutL_Del		; FEED FORWARD
adel1L_ED		deltap	ktime_1L_ED					; DELAY
			delayw	aoutL_Del - kDffs * aEDiff_1L		; FEEDBACK
;Diffuser delay 2L
adel2L_ED		init	0
amaxtime2L_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_2L		=		adel2L_ED + kDffs * aEDiff_1L		; FEED FORWARD
adel2L_ED		deltap	ktime_2L_ED					; DELAY
			delayw	aEDiff_1L - kDffs * aEDiff_2L		; FEEDBACK
;Diffuser delay 3L
adel3L_ED		init	0
amaxtime3L_ED	delayr	0.2							; set maximum delay 200 ms
ainL_EDiff	=		adel3L_ED + kDffs * aEDiff_2L		; FEED FORWARD
adel3L_ED		deltap	ktime_3L_ED					; DELAY
			delayw	aEDiff_2L - kDffs * ainL_EDiff	; FEEDBACK

;Diffuser delay 1R
adel1R_ED		init	0
amaxtime1R_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_1R		=		adel1R_ED + kDffs * aoutR_Del		; FEED FORWARD
adel1R_ED		deltap	ktime_1R_ED					; DELAY
			delayw	aoutR_Del - kDffs * aEDiff_1R		; FEEDBACK
;Diffuser delay 2R
adel2R_ED		init	0
amaxtime2R_ED	delayr	0.2							; set maximum delay 200 ms
aEDiff_2R		=		adel2R_ED + kDffs * aEDiff_1R		; FEED FORWARD
adel2R_ED		deltap	ktime_2R_ED					; DELAY
			delayw	aEDiff_1R - kDffs * aEDiff_2R		; FEEDBACK
;Diffuser delay 3R
adel3R_ED		init	0
amaxtime3R_ED	delayr	0.2							; set maximum delay 200 ms
ainR_EDiff	=		adel3R_ED + kDffs * aEDiff_2R		; FEED FORWARD
adel3R_ED		deltap	ktime_3R_ED					; DELAY
			delayw	aEDiff_2R - kDffs * ainR_EDiff	; FEEDBACK

;*****************************************************************************************LOPASS
;Inputs ainL_EDiff and ainR_EDiff (from EARLY DIFF)
;Outputs aoutL_LP and aoutR_LP  (to DAMP L, POWER FADE L, DAMP R, POWER FADE R)

kfreq_LP		table	kLP_Rev, 2			;exp2 table; Pitch to freq convertion in hertz

aoutL_LP		tone		ainL_EDiff, kfreq_LP
aoutR_LP		tone		ainR_EDiff, kfreq_LP

;**************************************************************************************DAMP L et R
;Inputs aoutL_LP (from LOPASS) and aoutR_Feed (from DIFF R)
;Inputs aoutR_LP (from LOPASS) and aoutL_Feed (from DIFF L)
;Outputs aoutL_Damp (to DIFF L) and aoutR_Damp (to DIFF R)

kvH			= ampdb(-kHD_Rev)
kvL			= ampdb(-kLD_Rev)

ainL_Damp		=		aoutL_LP + aoutR_Feed
aH			pareq	ainL_Damp, 2093, kvH, 0.707 , 2	;L Damp HiShelfEQ
aoutL_Damp	pareq	aH, 262, kvL, 0.707 , 1			;L Damp LoShelfEQ

ainR_Damp		=		aoutR_LP + aoutL_Feed
aH			pareq	ainR_Damp, 2093, kvH, 0.707 , 2	;R Damp HiShelfEQ
aoutR_Damp	pareq	aH, 262, kvL, 0.707 , 1			;R Damp LoShelfEQ

;***************************************************************************************16 PHASE
;Outputs kphase1,kphase2,kphase3,kphase4 (to DIFF L)
;Outputs kphase5,kphase6,kphase7,kphase8 (to DIFF R)

;LFO +Slow Random gen N1
iseed1		=		0
krand1		randh	kDizzy_Rev, 400, iseed1
krand1		tonek	krand1, kFrq_Rev * 0.7
klfo1		poscil	kSpin_Rev, kFrq_Rev, 3, 0.9375	;phase=1-1/16
kphase1		=		klfo1 * 0.001 + krand1 * 0.004
kphase5		=		- kphase1
;LFO +Slow Random gen N2
iseed2		=		0.2
krand2		randh	kDizzy_Rev, 400, iseed2
krand2		tonek	krand2, kFrq_Rev * 0.7
klfo2		poscil	kSpin_Rev, kFrq_Rev, 3, 0.875		;phase=1-2/16
kphase2		=		klfo2 * 0.001 + krand2 * 0.004
kphase6		=		- kphase2
;LFO +Slow Random gen N3
iseed3		=		0.4
krand3		randh	kDizzy_Rev, 400, iseed3
krand3		tonek	krand3, kFrq_Rev * 0.7
klfo3		poscil	kSpin_Rev, kFrq_Rev, 3, 0.8125	;phase=1-3/16
kphase3		=		klfo3 * 0.001 + krand3 * 0.004
kphase7		=		- kphase3
;LFO +Slow Random gen N4
iseed4		=		0.6
krand4		randh	kDizzy_Rev, 400, iseed4
krand4		tonek	krand4, kFrq_Rev * 0.7
klfo4		poscil	kSpin_Rev, kFrq_Rev, 3, 0.75		;phase=1-4/16
kphase4		=		klfo4 * 0.001 + krand4 * 0.004
kphase8		=		- kphase4

;******************************************************************************************DIFF L
;Input aoutL_Damp (from DAMP L)
;Outputs aoutL_Diff (to POWER FADE L) and aoutL_Feed (to DAMP R)

;Diffusion with variable Delay ;ktime mini=2/sr
;iDffs same value as in EARLY DIFF

ktime_1L_Diff	table	kSize_Rev + 31, 1	;exp table; in seconds
ktime_2L_Diff	table	kSize_Rev + 35, 1	;exp table; in seconds
ktime_3L_Diff	table	kSize_Rev + 39, 1	;exp table; in seconds
ktime_4L_Diff	table	kSize_Rev + 46, 1	;exp table; in seconds

ktime_1L_Diff	=		ktime_1L_Diff + kphase1
ktime_2L_Diff	=		ktime_2L_Diff + kphase2
ktime_3L_Diff	=		ktime_3L_Diff + kphase3
ktime_4L_DiffRT	=	ktime_4L_Diff + kphase4

ktime_1L_Diff	portk	ktime_1L_Diff, 0.1
ktime_2L_Diff	portk	ktime_2L_Diff, 0.1
ktime_3L_Diff	portk	ktime_3L_Diff, 0.1
ktime_4L_Diff	portk	ktime_4L_DiffRT, 0.1

;Diffuser delay 1L
adel1L_Diff	init	0
amaxtime1L_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_1L		=	adel1L_Diff + kDffs * aoutL_Damp	; FEED FORWARD
adel1L_Diff	deltap3	ktime_1L_Diff				; DELAY
			delayw	aoutL_Damp - kDffs * aDiff_1L	; FEEDBACK

;Diffuser delay 2L
adel2L_Diff	init	0
amaxtime2L_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_2L		=	adel2L_Diff + kDffs * aDiff_1L	; FEED FORWARD
adel2L_Diff	deltap3	ktime_2L_Diff				; DELAY
			delayw	aDiff_1L - kDffs * aDiff_2L	; FEEDBACK

;Diffuser delay 3L
adel3L_Diff	init	0
amaxtime3L_Diff	delayr	1.0					; set maximum delay 1000 ms
aoutL_Diff	=	adel3L_Diff + kDffs * aDiff_2L	; FEED FORWARD
adel3L_Diff	deltap3	ktime_3L_Diff				; DELAY
			delayw	aDiff_2L - kDffs * aoutL_Diff	; FEEDBACK

;Single delay 4L
aoutL_SD		vdelay	aoutL_Diff, a(ktime_4L_Diff), 1500

kFeed1		table	kRT_Rev, 1				;exp table
kFeed2		=	-1.115 / kFeed1

aoutL_Feed	= aoutL_SD * ampdb( ktime_4L_DiffRT * kFeed2)

;******************************************************************************************DIFF R
;Input aoutR_Damp (from DAMP R)
;Outputs aoutR_Diff (to POWER FADE R) and aoutR_Feed (to DAMP L)

;Diffusion with variable Delay ;ktime mini=2/sr
;iDffs same value as in EARLY DIFF

ktime_1R_Diff	table	kSize_Rev + 31, 1	;exp table; in seconds
ktime_2R_Diff	table	kSize_Rev + 35, 1	;exp table; in seconds
ktime_3R_Diff	table	kSize_Rev + 39, 1	;exp table; in seconds
ktime_4R_Diff	table	kSize_Rev + 46, 1	;exp table; in seconds

ktime_1R_Diff	= ktime_1R_Diff + kphase5
ktime_2R_Diff	= ktime_2R_Diff + kphase6
ktime_3R_Diff	= ktime_3R_Diff + kphase7
ktime_4R_DiffRT	= ktime_4R_Diff + kphase8

ktime_1R_Diff	portk	ktime_1R_Diff, 0.1
ktime_2R_Diff	portk	ktime_2R_Diff, 0.1
ktime_3R_Diff	portk	ktime_3R_Diff, 0.1
ktime_4R_Diff	portk	ktime_4R_DiffRT, 0.1

;Diffuser delay 1R
adel1R_Diff	init	0
amaxtime1R_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_1R		=	adel1R_Diff + kDffs * aoutR_Damp	; FEED FORWARD
adel1R_Diff	deltap3	ktime_1R_Diff				; DELAY
			delayw	aoutR_Damp - kDffs * aDiff_1R	; FEEDBACK

;Diffuser delay 2R
adel2R_Diff	init	0
amaxtime2R_Diff	delayr	1.0					; set maximum delay 1000 ms
aDiff_2R		=	adel2R_Diff + kDffs * aDiff_1R	; FEED FORWARD
adel2R_Diff	deltap3	ktime_2R_Diff				; DELAY
			delayw	aDiff_1R - kDffs * aDiff_2R	; FEEDBACK

;Diffuser delay 3R
adel3R_Diff	init	0
amaxtime3R_Diff	delayr	1.0					; set maximum delay 1000 ms
aoutR_Diff	=	adel3R_Diff + kDffs * aDiff_2R	; FEED FORWARD
adel3R_Diff	deltap3	ktime_3R_Diff				; DELAY
			delayw	aDiff_2R - kDffs * aoutR_Diff	; FEEDBACK

;Single delay 4R
aoutR_SD		vdelay	aoutR_Diff, a(ktime_4R_Diff), 1500

;iFeed2 same as in DIFF L
aoutR_Feed	= aoutR_SD * ampdb( ktime_4R_DiffRT * kFeed2)

;*******************************************************************************POWER FADE L and R
;Inputs aoutL_LP (from LOPASS) and aoutL_Diff (from DIFF L)
;Inputs aoutR_LP (from LOPASS) and aoutR_Diff (from DIFF R)
;Outputs ainL_wet and ainR_wet (to OUT)

ksqrtPos_Rev0	= sqrt(1 - kPos_Rev)
ksqrtPos_Rev1	= sqrt(kPos_Rev)

ainL_wet		= ksqrtPos_Rev0 * aoutL_LP + ksqrtPos_Rev1 * aoutL_Diff
ainR_wet		= ksqrtPos_Rev0 * aoutR_LP + ksqrtPos_Rev1 * aoutR_Diff

;*******************************************************************************DIFFUSION SECTION END

;****************************************************************************************OUT SECTION
;***********************************************************************************************
;Inputs ainL_dry and ainR_dry (global inputs of stereo signal)
;Inputs ainL_wet and ainR_wet (from DIFFUSION)
;Outputs audio aoutL and aoutR

ksqrtMix_Rev0	= sqrt(1 - kMix_Rev)
ksqrtMix_Rev1	= sqrt(kMix_Rev)

aoutL		= ksqrtMix_Rev0 * ainL_dry + ksqrtMix_Rev1 * ainL_wet
aoutR		= ksqrtMix_Rev0 * ainR_dry + ksqrtMix_Rev1 * ainR_wet

;*************************************************************************************OUT SECTION END

		xout		aoutL, aoutR
endop


instr	1	;Pipe (physical waveguide)
;ctrl reading
;ENV
iAtt_ENV		chnget	"kC1"	;knob Att
iDec_ENV		chnget	"kC2"	;knob Dec
iSus_ENV		chnget	"kC3"	;knob Sus
iRel_ENV		chnget	"kC4"	;knob Rel
iVel_ENV		chnget	"kC5"	;knob Vel
iScaling_ENV	chnget	"kC6"	;knob Scaling
;GEN
kDC_Noise_GEN	chnget	"kC7"	;knob DC/Noise
kCut_GEN		chnget	"kC8"	;knob Cut
kRes_GEN		chnget	"kC9"	;knob Res
kK_Track_GEN	chnget	"kC10"	;knob K-Track
kV_Track_GEN	chnget	"kC11"	;knob V-Track
k1_Pole_GEN	chnget	"kC12"	;button 1-Pole
;Pipe
kCtr_MW		chnget	"kC13"	;knob ModWheel
iPolarity		chnget	"kC14"	;button Polarity
;Pipe DELTUNE
kTune_DT		chnget	"kC15"	;knob Tune
kFine_DT		chnget	"kC16"	;knob Fine
kSREC_DT		chnget	"kC17"	;knob Srec
kMW_DT		chnget	"kC18"	;knob MW
;Pipe FEEDBACK
kRT_FB		chnget	"kC19"	;knob RT
kK_TrackFB	chnget	"kC20"	;knob K-Track
kDamp_FB		chnget	"kC21"	;knob Damp
;Pipe ALLPASS TUNE
kTune_AP		chnget	"kC22"	;knob Tune
kFine_AP		chnget	"kC23"	;knob Fine
kSREC_AP		chnget	"kC24"	;knob Srec
kMW_AP		chnget	"kC25"	;knob MW
;Pipe ALLPASS
kDffs_AP		chnget	"kC26"	;knob Dffs
kPower_AP		chnget	"kC27"	;button Power
;Pipe PUSH PULL
kOffset		chnget	"kC28"	;knob Offset
kPush		chnget	"kC29"	;knob Push
;Pipe SATURATION
kSoftHard		chnget	"kC30"	;knob Soft/Hard
kSym			chnget	"kC31"	;knob Sym
;Pipe MW FILTER
kHP0			chnget	"kC32"	;knob HP0
kHP1			chnget	"kC33"	;knob HP1
kK_TrackH		chnget	"kC34"	;knob K-Track
kLP0			chnget	"kC35"	;knob LP0
kLP1			chnget	"kC36"	;knob LP1
kK_TrackL		chnget	"kC37"	;knob K-Track

kMain_Vol		chnget	"kC50"	;knob Main Vol

kPolarity		= 1 - 2*iPolarity

iPitch = p4			;iPitch, midi note from 36 to 84 with midi keyboard

aout_Pipe		PIPE	iPitch, iAtt_ENV, iDec_ENV, iSus_ENV, iRel_ENV, iVel_ENV, iScaling_ENV, kDC_Noise_GEN, kCut_GEN, kRes_GEN, kK_Track_GEN, kV_Track_GEN, k1_Pole_GEN, kCtr_MW, kPolarity, kTune_DT, kFine_DT, kSREC_DT, kMW_DT, kRT_FB, kK_TrackFB, kDamp_FB, kTune_AP, kFine_AP, kSREC_AP, kMW_AP, kDffs_AP, kPower_AP, kOffset, kPush, kSoftHard, kSym, kHP0, kHP1, kK_TrackH, kLP0, kLP1, kK_TrackL

		gaIn_Reverb	= gaIn_Reverb + aout_Pipe * kMain_Vol
endin

instr	99		;Reverb unit

;Running LED, just for fun ***********************
ktempo		lfo		1, 0.5, 2
			chnset	 ktempo, "tempo"
;**********************************************

kTime_Rev		chnget	"kC38"	;knob Time
kLR_Rev		chnget	"kC39"	;knob L/R
kSize_Rev		chnget	"kC40"	;knob Size
kRT_Rev		chnget	"kC41"	;knob RT
kLP_Rev		chnget	"kC42"	;knob LP
kLD_Rev		chnget	"kC43"	;knob LD
kHD_Rev		chnget	"kC44"	;knob HD
kFrq_Rev		chnget	"kC45"	;knob Frq,	LFO sinus frequency
kSpin_Rev		chnget	"kC46"	;knob Spin,	LFO sinus amplitude
kDizzy_Rev	chnget	"kC47"	;knob Dizzy,	Slow Random amplitude
kPos_Rev		chnget	"kC48"	;knob Pos,	0 to 1
kMix_Rev		chnget	"kC49"	;knob Mix,	0 to 1

			denorm			gaIn_Reverb

aoutL, aoutR	REVERB	gaIn_Reverb, kTime_Rev, kLR_Rev, kSize_Rev, kRT_Rev, kLP_Rev, kLD_Rev, kHD_Rev, kFrq_Rev, kSpin_Rev, kDizzy_Rev, kPos_Rev, kMix_Rev

;vu-meters
kLeft		rms		aoutL
kRight		rms		aoutR
			chnset	 kLeft, "vu_Left"
			chnset	 kRight, "vu_Right"

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




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>316</x>
 <y>79</y>
 <width>968</width>
 <height>707</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>102</r>
  <g>102</g>
  <b>102</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>5</y>
  <width>948</width>
  <height>42</height>
  <uuid>{f83c8ed4-8272-4a39-bad4-3c33ba26d04c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SYNTH PIPE</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>194</g>
   <b>144</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>4</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>125</x>
  <y>395</y>
  <width>665</width>
  <height>163</height>
  <uuid>{f376f702-0fc4-49ee-b31d-2d81d753a714}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>REVERB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>50</y>
  <width>299</width>
  <height>166</height>
  <uuid>{2ca39be8-1821-4dec-996a-f569b84a3e69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>AIR ENVELOPPE</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC1</objectName>
  <x>23</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{7fd81566-d369-4ff6-9521-5075574ef5f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-20.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>-20.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>19</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{47f7f726-dea9-4e8a-9d9e-e8a59afed0e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Att</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC2</objectName>
  <x>68</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{bff2ae19-cec4-450c-810d-c6488d7eb3db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-20.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>20.79999924</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>64</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{27a88303-354c-4d1f-bab0-07164d6017a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Dec</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC2</objectName>
  <x>56</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>20.800</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC3</objectName>
  <x>114</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <x>110</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{b7c3c7b2-2fe4-4a71-98ae-f10bdceb0f09}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sus</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC3</objectName>
  <x>106</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC4</objectName>
  <x>159</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{43be06ea-c25a-46b0-af06-752d2cff8551}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-20.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>10.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>156</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{58df6e7c-5ff7-4b2b-8036-5e504d393732}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Rel</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC4</objectName>
  <x>147</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0694c706-5d4e-4014-93d9-33d327a25321}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>10.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC5</objectName>
  <x>207</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{28520397-fba4-4c4b-8150-b52fa58d9b99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <x>204</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{ab510ca9-6b0f-4398-bae2-946baaf02990}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Vel</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC5</objectName>
  <x>199</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f50669c7-e80c-4bb2-b167-0c5c274ced7f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC6</objectName>
  <x>253</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>249</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{8fce4f81-f2b3-4852-8d5d-3da6fab154cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Scal</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC6</objectName>
  <x>245</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5b929364-1b98-42bf-ba22-52e4fda9cf68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-0.250</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC38</objectName>
  <x>158</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{a986b8e4-01de-477e-85b6-714e13688232}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>240.00000000</maximum>
  <value>24.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>151</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{a6bccc4b-946b-4dd5-8242-cf08451d345c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Time</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC38</objectName>
  <x>145</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>24.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC39</objectName>
  <x>211</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{671ab614-13de-4602-8709-f5db18fa64bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>-0.57999998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>209</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{50922850-f5bf-48ba-a12d-a25b93ca44e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>L/R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC39</objectName>
  <x>202</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{92d0f455-e73b-450a-afb0-739549eda08b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-0.580</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC40</objectName>
  <x>264</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{4e074954-5881-4b46-a89e-301e06cae77f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>60.00000000</maximum>
  <value>16.79999924</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>258</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{ade400d8-b038-4d5d-b1c7-7d27ed612351}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Size</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC40</objectName>
  <x>253</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{44966c39-c062-4957-abc1-566fcf18a13e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>16.800</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC41</objectName>
  <x>317</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{0eb610ed-724e-4bb9-b114-c02de5747bf9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>45.59999847</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>316</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{9f27fb2a-695c-4038-bba7-a9345a833c52}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>RT</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC41</objectName>
  <x>305</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>45.600</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC42</objectName>
  <x>370</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>24.00000000</minimum>
  <maximum>144.00000000</maximum>
  <value>144.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>369</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{c4e3ac8f-beb5-45f5-876d-bd0be2ca0c53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>LP</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC42</objectName>
  <x>360</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>144.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC43</objectName>
  <x>423</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{1fa0c649-a386-4006-992a-a95697f3f7c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>30.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>422</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{ff8cc24f-4dca-42f0-9cc4-20f58dd80000}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>LD</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC43</objectName>
  <x>415</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC44</objectName>
  <x>476</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{90efec9c-f402-4cfd-8904-fa607901e247}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>30.00000000</maximum>
  <value>1.79999995</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>473</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{6fa8d1b1-b823-4bb2-8340-8bf9634cd545}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>HD</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC44</objectName>
  <x>466</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.800</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC45</objectName>
  <x>529</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.41999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>523</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{f5bd7ffe-9f49-44d7-848a-34e16cced6d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Freq</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC45</objectName>
  <x>520</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2e81a519-a4b9-41f6-a608-3e11683ae600}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.420</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC46</objectName>
  <x>582</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{374207f4-395f-42d7-8882-eedb7adb808a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>576</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{b2306a7e-a0c2-42b9-a738-d434b1f2810d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Spin</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC46</objectName>
  <x>574</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f435a121-b76c-4a37-a0a7-ad0325e77ac9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.300</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC47</objectName>
  <x>635</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{8d683189-6b51-44c6-a767-893da9e946ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>626</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{85b73678-5e18-49e3-b3f7-d1bc396173a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Dizzy</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC47</objectName>
  <x>626</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{96f462d5-ac3f-4af8-96b4-9eea077e7e79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.500</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC48</objectName>
  <x>688</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{10e3f36f-cc25-415a-a68a-e91700369291}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>684</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{10977936-78d2-4edf-b15a-b5810cb6278e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Pos</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC48</objectName>
  <x>678</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{675f8a7e-27b7-4890-90d5-847e16a649ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.510</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC49</objectName>
  <x>741</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{724ee7ed-0664-4d23-8c8f-8a838961033e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.34000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>737</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{b376e3fd-8e78-4618-a80a-06cc32951b6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Mix</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC49</objectName>
  <x>730</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f5c8b864-c25d-4794-95a5-f3375afe7441}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.340</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>306</x>
  <y>50</y>
  <width>316</width>
  <height>166</height>
  <uuid>{21e2b54c-b094-4c9d-a216-e8584b0d1b41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>AIR GENERATOR</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC7</objectName>
  <x>320</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <x>313</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{12c18cce-24ba-4c8d-aecb-6e4fdc2579d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Noise</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC7</objectName>
  <x>313</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{24473f93-644e-4ba6-b546-985061bed64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC8</objectName>
  <x>374</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{030982cd-2ca9-4d8c-a4c5-bd52986694fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>78.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>370</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{4edba405-eb55-4bef-a2e1-69bda2bfde3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Cut</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC8</objectName>
  <x>363</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{352c09d0-6a36-485b-888a-8061baa98105}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>78.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC9</objectName>
  <x>427</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{b0b80165-f444-46ab-b910-2460e89832ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.34000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>423</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{7a78a651-b2b6-4a33-bb8b-58bab6661e9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Res</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC9</objectName>
  <x>420</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.340</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC10</objectName>
  <x>480</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{786c1d28-38eb-4413-a727-f694abd512c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.31999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>477</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{a63a2bfa-1f65-4bef-bf63-debe1fbeb04f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>KTr</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC10</objectName>
  <x>471</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.320</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC11</objectName>
  <x>533</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>530</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{2271d147-cdea-4598-b60c-6f83e5602e71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>VTr</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC11</objectName>
  <x>525</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{941dbfd1-06be-4cae-a2ac-2379813d77fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.400</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>575</x>
  <y>141</y>
  <width>50</width>
  <height>30</height>
  <uuid>{978bad4d-b77d-4dd2-b12d-cc56aae66b1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1P</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>kC12</objectName>
  <x>579</x>
  <y>121</y>
  <width>20</width>
  <height>20</height>
  <uuid>{ffd14281-62ce-4b97-aa29-6e0011faffdd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>625</x>
  <y>222</y>
  <width>325</width>
  <height>166</height>
  <uuid>{eed781d9-7cf6-4c73-bc9a-a1a9c7c814e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>FILTER</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC32</objectName>
  <x>643</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{489e07b5-3656-4234-90e3-4a624792042a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>638</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{f002643f-2c79-4320-9c60-cf34f7fafd19}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>HP0</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC32</objectName>
  <x>632</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8eca1bef-7a98-4291-a154-6f6ea920ae32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC33</objectName>
  <x>696</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ea8d2f19-8b05-4949-9475-f5c979385b29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>692</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{e485397d-a0a0-4ecf-81de-2cdcd695b472}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>HP1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC33</objectName>
  <x>685</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC34</objectName>
  <x>750</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{dec2259d-53e8-4816-8889-79df24673d63}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>745</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{1569ca4d-b17c-452b-a846-6c55515b3c13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>KTrH</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC34</objectName>
  <x>742</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c36e748b-b4fe-4542-ba69-86bf429e82c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC35</objectName>
  <x>802</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{d5d6958b-3384-4309-b3c2-32bb51af3b54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>79.19999695</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>799</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{6345b7f7-fc94-4ade-9834-05696fe7e127}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>LP0</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC35</objectName>
  <x>790</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>79.200</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC36</objectName>
  <x>855</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{c0341d29-c062-4ea0-9eba-bc3506bac638}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>60.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>852</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{6e8ea7c5-2371-4454-9b4f-9f9f39d6619d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>LP1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC36</objectName>
  <x>844</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{445be958-7d5d-4191-8242-a1baefd9d08d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>60.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC37</objectName>
  <x>908</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{4e745abf-a50b-4f6b-9116-83e74d208f0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>904</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{17ca2efd-c799-4615-b631-7241b5d31820}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>KTrL</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC37</objectName>
  <x>898</x>
  <y>361</y>
  <width>50</width>
  <height>30</height>
  <uuid>{42ac1c06-8b9d-40a8-832b-43ed222d4f55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>625</x>
  <y>50</y>
  <width>98</width>
  <height>166</height>
  <uuid>{70f0e897-7c06-49d8-9372-01a92d8fc58e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>PIPE</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC13</objectName>
  <x>642</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ff8df6e8-8296-44ae-b47f-4557ed73739c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <x>637</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{158f7499-dbf4-4ba2-b8e0-dca3f1d39d6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MW</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC13</objectName>
  <x>633</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>679</x>
  <y>141</y>
  <width>50</width>
  <height>30</height>
  <uuid>{062f98cd-fdee-4488-9bd7-7029e85e1ebf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Pol</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>kC14</objectName>
  <x>683</x>
  <y>121</y>
  <width>20</width>
  <height>20</height>
  <uuid>{4d779359-0ae9-4707-a90e-f256666535b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>726</x>
  <y>50</y>
  <width>225</width>
  <height>166</height>
  <uuid>{33b5032c-d000-46db-b587-52d0b97f2d39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>DELAY TUNE</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC15</objectName>
  <x>746</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{75058e27-8b12-4dc2-a7ae-647dd9de3e49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>60.00000000</maximum>
  <value>-12.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>739</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{cc44bdf5-d32b-4a3f-b4d4-8bc0ae2c7674}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Tune</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC15</objectName>
  <x>738</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bb06148d-c105-475b-9e4a-163f8888ce4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-12.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC16</objectName>
  <x>797</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{7780e271-fc33-403c-88cc-3001b50553bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>793</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{b24303a8-a7d5-4a2d-8622-0ee547851769}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Fine</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC16</objectName>
  <x>790</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{eeac9c7d-9ace-4107-9e35-bdd460e0918c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.200</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC17</objectName>
  <x>849</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{506f081b-e5c7-4e53-9971-c3764aad174c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-5.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-0.44999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>846</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{58cfff2d-1172-48ed-9b54-5f9fbb086f89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Srec</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC17</objectName>
  <x>841</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b8dccf73-34ce-48b1-b276-6ad0f407580f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-0.450</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC18</objectName>
  <x>902</x>
  <y>71</y>
  <width>19</width>
  <height>100</height>
  <uuid>{b009a56e-e255-4ca5-a236-a8f6a076ed77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.23999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>899</x>
  <y>171</y>
  <width>50</width>
  <height>30</height>
  <uuid>{a03159ce-b98b-4ae8-b916-17b81353f981}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MW</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC18</objectName>
  <x>896</x>
  <y>189</y>
  <width>50</width>
  <height>30</height>
  <uuid>{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.240</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>221</y>
  <width>163</width>
  <height>166</height>
  <uuid>{870a58b1-8c64-4f91-aabc-3a59bffe547b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>FEEDBACK</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC19</objectName>
  <x>17</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{292cb4d1-41a9-44cb-a8fd-bc375600433f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>30.00000000</maximum>
  <value>-90.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{92e09f8c-3f90-43b8-b56b-b69b753a5f15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>RT</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC19</objectName>
  <x>7</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{00ca8466-07bc-4875-9d42-49a11a31146e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-90.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC20</objectName>
  <x>71</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.63999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>69</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{83d77d3f-e562-4022-b460-6c1c718fa111}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>KTr</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC20</objectName>
  <x>62</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.640</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC21</objectName>
  <x>124</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>79.19999695</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>114</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{cd4e8717-d18a-4c75-a626-17654a30c9c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Damp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC21</objectName>
  <x>112</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{13745bf8-e49a-4773-a561-39c17e1ac831}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>79.200</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>221</y>
  <width>210</width>
  <height>166</height>
  <uuid>{d182f4f9-356c-4df6-b1ee-efb4f1c18a10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>ALLPASS TUNE</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC22</objectName>
  <x>184</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{7fd7515c-a091-4d27-955d-5a6e08c44e0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>60.00000000</maximum>
  <value>-12.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>178</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{e565f62b-1916-43ff-9ae6-d13f772204ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Tune</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC22</objectName>
  <x>174</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{163a86c6-d25a-4415-a9eb-4669b81b21ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-12.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC23</objectName>
  <x>239</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>235</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{d2fce105-f4f9-449a-a4e7-a453ff6142d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Fine</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC23</objectName>
  <x>231</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{194a05f5-61ed-41ed-a89a-2c293dc12af4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.200</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC24</objectName>
  <x>292</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{2234b84c-6d59-4de2-84a6-486454385684}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-5.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-0.44999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>287</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{1cc6bfce-23cd-4dba-8cfd-11251e7b0766}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Srec</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC24</objectName>
  <x>283</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-0.450</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC25</objectName>
  <x>344</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{72fc9987-a42a-46e8-96f6-0a02f25ae92f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>340</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{c34125cd-3519-43df-99d2-a89cdd0bc842}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MW</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC25</objectName>
  <x>336</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>383</x>
  <y>221</y>
  <width>120</width>
  <height>166</height>
  <uuid>{6edcb84f-47f9-4648-8332-444296ecdc60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>DELAY + ALLPASS</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC26</objectName>
  <x>453</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{86f9ba4b-d465-4b9c-9401-e96243ae08fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>449</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{c29e0a66-4ef3-4b47-a230-714dc433bbc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Diff</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC26</objectName>
  <x>444</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e0723488-4eee-47e1-a218-ada83f1ff6af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>393</x>
  <y>308</y>
  <width>50</width>
  <height>30</height>
  <uuid>{686e1c90-a13a-4955-8526-3260570c3ed8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>On</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>kC27</objectName>
  <x>396</x>
  <y>288</y>
  <width>20</width>
  <height>20</height>
  <uuid>{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>506</x>
  <y>222</y>
  <width>116</width>
  <height>166</height>
  <uuid>{2ce49cab-ac19-426f-999a-b9042e94522a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>PUSH PULL</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC28</objectName>
  <x>526</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{69cc53a4-30b2-4a5e-900a-4acc0bddb704}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>518</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{27fbefe4-3f1e-41ac-b4e7-33bd23c4dc69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Offset</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC28</objectName>
  <x>518</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC29</objectName>
  <x>580</x>
  <y>243</y>
  <width>19</width>
  <height>100</height>
  <uuid>{49df04c2-baac-4801-80dc-1dc7ee81b0f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.36000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>574</x>
  <y>343</y>
  <width>50</width>
  <height>30</height>
  <uuid>{4640cf8e-419b-48f3-a8e3-5d62af7389fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Push</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC29</objectName>
  <x>573</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{76447115-2a94-4b39-a237-2f2be5022e0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.360</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>395</y>
  <width>116</width>
  <height>163</height>
  <uuid>{16f0808c-2bc4-4e19-ac21-6746f6110cd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SATURATION</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC30</objectName>
  <x>22</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{03ca5ad6-5038-43dd-aab6-1ff801b9a819}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <x>16</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{ac2ce990-042e-453e-9792-e125e244eb1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S / H</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC30</objectName>
  <x>14</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{faefc165-edb5-408b-a710-5c628066cc15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kC31</objectName>
  <x>76</x>
  <y>409</y>
  <width>19</width>
  <height>100</height>
  <uuid>{e0f63106-0a7d-46cd-8200-f9e62336cf10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.19000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>70</x>
  <y>509</y>
  <width>50</width>
  <height>30</height>
  <uuid>{cfd899a5-b433-4e5a-b3d0-e8c1116bb2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sym</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC31</objectName>
  <x>68</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{242cde03-7d61-492e-95fb-0f618c381ba2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.190</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>795</x>
  <y>395</y>
  <width>159</width>
  <height>304</height>
  <uuid>{1e61f964-13f2-4645-b869-89571c89516d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MAIN</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>194</g>
   <b>144</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>kC50</objectName>
  <x>815</x>
  <y>454</y>
  <width>60</width>
  <height>60</height>
  <uuid>{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>5.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>1</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>819</x>
  <y>525</y>
  <width>100</width>
  <height>35</height>
  <uuid>{15d2b8f3-a681-489c-84c8-8cfdf3391aa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Volume</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC50</objectName>
  <x>824</x>
  <y>543</y>
  <width>80</width>
  <height>30</height>
  <uuid>{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>5.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor210</objectName>
  <x>899</x>
  <y>411</y>
  <width>14</width>
  <height>146</height>
  <uuid>{62b015b8-119a-4016-8372-b47f22d0a073}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>vu_Left</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.42857099</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor210</objectName>
  <x>916</x>
  <y>411</y>
  <width>14</width>
  <height>146</height>
  <uuid>{b076f37e-0a9e-4351-bd25-7a00befe5542}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>vu_Right</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.42857099</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>898</x>
  <y>557</y>
  <width>30</width>
  <height>30</height>
  <uuid>{185aa014-45f3-4492-902c-bb1a2932f484}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>L</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>914</x>
  <y>557</y>
  <width>30</width>
  <height>30</height>
  <uuid>{7bcfd5cc-868d-4cd8-9b06-7e9fb33cfc48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>839</x>
  <y>399</y>
  <width>10</width>
  <height>10</height>
  <uuid>{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>tempo</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.27777800</xValue>
  <yValue>-1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>24</r>
   <g>232</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>560</y>
  <width>784</width>
  <height>140</height>
  <uuid>{e017f23d-c316-4143-9c96-3c867dc2d2b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>85</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kC1</objectName>
  <x>10</x>
  <y>189</y>
  <width>60</width>
  <height>30</height>
  <uuid>{115f6545-8b1e-4026-9b27-fecb23726c6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-20.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>16</x>
  <y>564</y>
  <width>375</width>
  <height>120</height>
  <uuid>{17dcb866-30bb-4dac-bdf1-126e885d668b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>401</x>
  <y>564</y>
  <width>375</width>
  <height>120</height>
  <uuid>{0065ae48-aaaa-4992-9c61-42342bd369a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_GetPresetName</objectName>
  <x>735</x>
  <y>9</y>
  <width>213</width>
  <height>34</height>
  <uuid>{4868e68a-6bc0-4401-b7d3-978bdfba9fae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Bass + Reverb 4</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>DejaVu Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>220</g>
   <b>162</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>4</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>_SetPresetIndex</objectName>
  <x>686</x>
  <y>12</y>
  <width>45</width>
  <height>28</height>
  <uuid>{80352a97-9fc4-45d7-81c2-e60673aaa267}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>16</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>156</g>
   <b>75</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Pause</objectName>
  <x>822</x>
  <y>615</y>
  <width>100</width>
  <height>25</height>
  <uuid>{0de26e96-b126-4753-8fba-13e3ddb3a1c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>822</x>
  <y>648</y>
  <width>100</width>
  <height>25</height>
  <uuid>{3c5cfd97-9bf2-45c7-b66d-8026870f0a92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>822</x>
  <y>581</y>
  <width>100</width>
  <height>25</height>
  <uuid>{768a8172-bac8-4099-aa9b-7c382b00502d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="Banjo + Reverb 6" number="0" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.000</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >10.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.000</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >0.000</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >28.800</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.380</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >30.000</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >60.000</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.800</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.750</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.750</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >1.000</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >120.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >120.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >120.000</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.30000001</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.30000001</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.300</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.58999997</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.58999997</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.590</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >1.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >120.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >60.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >1.000</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >0.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.08000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.08000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.080</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.16000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.16000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.160</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-44.40000153</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-44.40000153</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-44.400</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >0.57999998</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >0.57999998</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >0.580</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >19.20000076</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >19.20000076</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >19.200</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >-0.20000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >-0.20000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >-0.200</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-1.29999995</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-1.29999995</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-1.300</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.16000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.16000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.160</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.86000001</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.86000001</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.860</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.00000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.00000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.000</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >1.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.000</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >3.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >3.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >3.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.01093521</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00942687</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >-1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Banjo + Reverb 6</value>
</preset>
<preset name="Bass + Reverb 4" number="1" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.000</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >10.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.000</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.250</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >24.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >24.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >24.000</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-0.57999998</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-0.57999998</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-0.580</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >16.800</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >45.59999847</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >45.59999847</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >45.600</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.500</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50999999</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50999999</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.510</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.34000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.34000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.340</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >1.000</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >78.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >78.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >78.000</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.340</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.40000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.40000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.400</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >79.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >79.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >79.200</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >60.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >1.000</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >-12.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >-12.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >-12.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.20000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.20000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.200</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-0.44999999</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-0.44999999</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-0.450</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.23999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.23999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.240</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-90.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-90.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-90.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.63999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.63999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.640</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >79.19999695</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >79.19999695</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >79.200</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >-12.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >-12.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >-12.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.20000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.20000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.200</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-0.44999999</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-0.44999999</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-0.450</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.36000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.36000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.360</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >1.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.19000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.19000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.190</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >5.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >5.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >5.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00299152</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00272315</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Bass + Reverb 4</value>
</preset>
<preset name="Bell + Reverb 6" number="2" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.000</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >10.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.000</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.250</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >28.800</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.380</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >30.000</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >60.000</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.800</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.750</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.750</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >1.000</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >90.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >90.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >90.000</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.85000002</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.85000002</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.850</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >34.79999924</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >34.79999924</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >34.800</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >120.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >60.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >1.000</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >3.59999990</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >3.59999990</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >3.600</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.02000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.02000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.020</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-2.50000000</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-2.50000000</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-2.500</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.47999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.47999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.480</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-72.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-72.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-72.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >0.68000001</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >0.68000001</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >0.680</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >0.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >-10.80000019</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >-10.80000019</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >-10.800</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.25999999</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.25999999</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.260</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-0.30000001</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-0.30000001</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-0.300</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.47999999</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.47999999</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.480</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.25999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.25999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.260</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.00000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.00000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.000</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >1.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.000</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >5.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >5.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >5.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00000011</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00000005</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Bell + Reverb 6</value>
</preset>
<preset name="Cello + Reverb 3" number="3" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >36.40000153</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >36.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >36.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >36.400</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.50000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.50000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.500</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >10.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.50000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.50000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.500</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >0.000</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >7.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.300</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >12.600</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >25.200</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >3.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.150</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.81000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.81000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.810</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >86.40000153</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >86.40000153</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >86.400</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.28000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.28000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.280</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >108.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >108.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >108.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >60.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.57999998</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.57999998</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.580</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >0.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.20000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.20000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.200</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.89999998</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.89999998</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.900</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.000</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-42.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-42.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-42.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >12.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >-0.12000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >-0.12000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >-0.120</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-1.29999995</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-1.29999995</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-1.300</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.68000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.68000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.680</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.50000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.50000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.500</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.000</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >36.40000153</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >36.400</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Cello + Reverb 3</value>
</preset>
<preset name="Flute + Reverb 5" number="4" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >25.60000038</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.900</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.34000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.34000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.340</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >31.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-1.000</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >16.800</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >58.800</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >2.70000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >2.70000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >2.700</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.500</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.540</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.25000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.25000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.250</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.66000003</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.66000003</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.660</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >79.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >79.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >79.200</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.28000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.28000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.280</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >1.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >12.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >67.19999695</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >67.19999695</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >67.200</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >67.200</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >97.19999695</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >97.19999695</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >97.200</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.38000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.38000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.380</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >1.200</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.12000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.12000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.120</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.54999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.54999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.550</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-1.24000001</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-1.24000001</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-1.240</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-60.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >7.200</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.41999999</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.41999999</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.420</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.55999994</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.55999994</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.560</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.34000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.34000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.340</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >25.60000038</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >25.600</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Flute + Reverb 5</value>
</preset>
<preset name="Glasswood + Reverb 1" number="5" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >11.19999981</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >11.19999981</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >11.200</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.000</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >10.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.000</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >0.000</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >0.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >0.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >0.000</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-1.000</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >7.19999981</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >7.19999981</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >7.200</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >26.39999962</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >26.39999962</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >26.400</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.20000005</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.20000005</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.200</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.20000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.20000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.200</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.69999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.69999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.700</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.50000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.50000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.500</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >1.000</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >120.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >120.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >120.000</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.34999999</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.34999999</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.350</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.08000004</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.08000004</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.080</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >111.59999847</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >111.59999847</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >111.600</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >120.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.98000002</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.98000002</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.980</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >45.59999847</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >45.59999847</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >45.600</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.060</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.000</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-19.20000076</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-19.20000076</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-19.200</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >0.81999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >0.81999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >0.820</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >0.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >26.39999962</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >26.39999962</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >26.400</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >-0.56000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >-0.56000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >-0.560</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-1.20000005</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-1.20000005</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-1.200</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.41999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.41999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.420</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >-1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >-1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >-1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.63999999</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.63999999</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.640</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >1.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.66000003</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.66000003</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.660</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >2.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >2.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >2.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Glasswood + Reverb 1</value>
</preset>
<preset name="Guitar + Reverb 2" number="6" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.000</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >10.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.00000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.000</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.250</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >21.60000038</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >21.60000038</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >21.600</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-0.36000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-0.36000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-0.360</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >15.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >15.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >15.600</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >30.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >30.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >30.000</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >0.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >0.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >0.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.30000001</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.30000001</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.300</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.43000001</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.43000001</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.430</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.37000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.37000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.370</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >1.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >1.000</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >120.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >120.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >120.000</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.340</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.85000002</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.85000002</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.850</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >120.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >60.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >1.000</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >0.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.000</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.04999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.04999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.050</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.23999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.23999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.240</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-90.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-90.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-90.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.63999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.63999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.640</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >78.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >78.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >78.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.00000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.00000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.000</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >1.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.000</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >2.50000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >2.50000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >2.500</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Guitar + Reverb 2</value>
</preset>
<preset name="Harmonix + Reverb 3" number="7" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >24.39999962</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.09000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.09000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.090</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.75000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.75000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.750</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >7.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.300</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >12.600</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >25.200</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >3.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.150</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.44000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.44000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.440</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >72.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >72.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >72.000</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.15000001</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.15000001</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.150</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.150</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >25.20000076</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >25.20000076</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >25.200</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >60.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >60.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >60.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >120.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >72.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >72.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >72.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >1.000</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >0.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.000</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.20000005</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.20000005</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.200</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-0.60000002</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-0.60000002</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-0.600</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-90.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-90.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-90.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >102.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >102.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >102.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.30000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.30000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.300</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.92000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.92000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.920</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >1.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >1.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.52999997</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.52999997</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.530</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >0.50000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >0.50000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >0.500</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >24.39999962</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >24.400</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Harmonix + Reverb 3</value>
</preset>
<preset name="Harp + Reverb 5" number="8" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-11.60000038</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >11.19999981</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >11.19999981</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >11.200</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.000</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >25.60000038</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >25.60000038</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >25.600</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.52999997</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.52999997</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.530</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >0.000</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >31.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-1.000</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >16.800</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >58.800</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >2.09999990</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >2.09999990</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >2.100</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.500</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.540</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.25000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.25000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.250</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.81000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.81000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.810</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >58.79999924</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >58.79999924</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >58.800</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >1.29999995</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >1.29999995</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >1.300</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.44000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.44000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.440</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >120.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >120.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >1.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >1.000</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >0.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.060</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-0.30000001</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-0.30000001</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-0.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >2.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >2.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >2.000</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-79.19999695</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-79.19999695</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-79.200</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.01999998</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.01999998</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.020</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >0.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.69999999</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.69999999</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.700</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.20000005</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.20000005</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.200</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.18000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.18000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.180</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.000</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >5.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >5.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >5.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-11.60000038</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-11.600</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Harp + Reverb 5</value>
</preset>
<preset name="Organ + Reverb 5" number="9" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >25.60000038</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.62000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.62000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.620</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.34000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.34000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.340</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >31.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-1.000</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >16.800</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >58.800</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >2.70000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >2.70000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >2.700</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.500</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.540</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.25000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.25000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.250</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.66000003</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.66000003</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.660</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >61.20000076</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >61.20000076</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >61.200</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.56000000</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.56000000</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.560</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.31000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.31000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.310</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >26.39999962</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >26.39999962</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >26.400</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >67.19999695</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >67.19999695</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >67.200</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >78.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >78.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >78.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >97.19999695</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >97.19999695</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >97.200</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >1.200</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.62000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.62000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.620</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.75000000</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.75000000</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.750</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-1.24000001</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-1.24000001</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-1.240</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-60.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >0.47999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >0.47999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >0.480</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >7.200</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.62000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.62000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.620</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.75999999</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.75999999</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.760</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.10000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.10000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.100</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >25.60000038</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >25.600</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Organ + Reverb 5</value>
</preset>
<preset name="Pan + Reverb 6" number="10" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >25.60000038</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.900</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.34000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.34000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.340</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >28.800</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.380</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >30.000</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >60.000</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.800</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.750</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.750</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.50000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.50000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.500</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >98.40000153</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >98.40000153</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >98.400</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.68000001</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.68000001</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.680</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.34000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.34000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.340</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >1.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >12.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >60.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >60.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >60.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >60.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >60.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >60.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >97.19999695</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >97.19999695</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >97.200</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.37000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.37000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.370</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >14.39999962</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >14.39999962</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >14.400</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.060</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-1.60000002</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-1.60000002</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-1.600</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-60.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >7.200</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.47999999</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.47999999</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.480</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.55999994</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.55999994</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.560</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.34000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.34000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.340</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.44000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.44000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.440</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >25.60000038</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >25.600</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Pan + Reverb 6</value>
</preset>
<preset name="Pipe + Reverb 6" number="11" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-4.40000010</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.900</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.660</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >28.800</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.380</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >30.000</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >60.000</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.800</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.750</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.750</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.31999999</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.31999999</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.320</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >100.800</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.340</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.150</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >12.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >70.80000305</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >70.80000305</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >70.800</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >67.200</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >90.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >90.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >90.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.31000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.31000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.310</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >1.200</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.000</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-1.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-1.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-1.120</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-60.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >12.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.88000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.88000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.880</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.48000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.48000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.480</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.49000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.49000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.490</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.75000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.75000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.750</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-4.40000010</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-4.400</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Pipe + Reverb 6</value>
</preset>
<preset name="Sax + Reverb 3" number="12" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >31.60000038</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >31.60000038</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >31.60000038</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >31.600</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.900</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >31.60000038</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >31.60000038</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >31.600</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.660</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >0.000</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >7.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.300</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >12.600</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >25.200</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >3.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.150</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.54000002</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.54000002</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.540</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >72.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >72.00000000</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >72.000</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.150</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >118.80000305</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >118.80000305</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >118.800</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >120.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.00000000</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.000</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >0.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.14000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.14000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.140</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-0.94999999</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-0.94999999</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-0.950</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.120</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-28.79999924</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-28.79999924</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-28.800</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >3.59999990</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >3.59999990</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >3.600</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >60.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >60.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >60.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.02000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.02000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.020</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-1.10000002</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-1.10000002</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-1.100</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.12000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.12000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.120</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.75999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.75999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.760</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.36000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.36000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.360</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.17999995</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.17999995</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.180</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.28000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.28000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.280</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.31000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.31000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.310</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >31.60000038</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >31.600</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Sax + Reverb 3</value>
</preset>
<preset name="Air_Pipe + Reverb 5" number="13" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >25.60000038</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.900</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.70999998</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.70999998</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.710</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >31.20000076</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >31.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-1.000</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >17.39999962</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >17.39999962</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >17.400</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >58.79999924</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >58.800</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >3.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.500</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.54000002</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.540</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.25999999</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.25999999</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.260</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.69000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.69000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.690</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >109.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >109.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >109.200</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.50000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.50000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.500</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.37000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.37000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.370</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >60.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >60.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >60.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >56.40000153</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >56.40000153</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >56.400</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >100.80000305</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >100.80000305</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >100.800</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.56000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.56000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.560</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >7.19999981</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >7.19999981</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >7.200</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.12000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.12000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.120</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.60000002</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.60000002</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.600</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-0.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-0.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-0.120</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-60.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >7.19999981</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >7.200</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >15.60000038</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >15.60000038</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >15.600</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >-0.12000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >-0.12000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >-0.120</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-1.60000002</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-1.60000002</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-1.600</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.50000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.50000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.500</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.50000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.50000000</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.500</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.00000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.000</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.25000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.25000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.250</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >25.60000038</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >25.600</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Air_Pipe + Reverb 5</value>
</preset>
<preset name="String + Reverb 3" number="14" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >36.40000153</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >36.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >36.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >36.400</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.50000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.50000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.500</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >10.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >10.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.50000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.50000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.500</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.25000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.250</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >7.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.300</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >12.600</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >25.200</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >3.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.15000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.150</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.79000002</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.79000002</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.790</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >86.40000153</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >86.40000153</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >86.400</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.15000001</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.15000001</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.150</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.28000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.28000000</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.280</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >1.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >108.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >108.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >108.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >60.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >60.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.57999998</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.57999998</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.580</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >0.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >0.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.06000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.060</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-0.50000000</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-0.50000000</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-0.500</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >1.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >1.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >1.000</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-42.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-42.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-42.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >15.60000038</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >15.60000038</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >15.600</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >-0.02000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >-0.02000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >-0.020</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >0.68000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >0.68000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >0.680</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.50000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.50000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.500</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.15000001</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.15000001</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.150</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >36.40000153</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >36.400</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >String + Reverb 3</value>
</preset>
<preset name="Water_Drum + Reverb 1" number="15" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >20.79999924</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >29.20000076</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >29.20000076</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >29.200</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.00000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.000</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >28.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >28.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >28.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.46000001</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.46000001</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.460</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >0.000</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >0.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >0.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >0.000</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-1.00000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-1.000</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >7.19999981</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >7.19999981</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >7.200</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >26.39999962</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >26.39999962</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >26.400</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.20000005</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.20000005</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.200</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.20000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.20000005</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.200</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.69999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.69999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.700</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.50000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.50000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.500</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.79000002</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.79000002</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.790</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >91.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >91.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >91.200</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >1.29999995</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >1.29999995</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >1.300</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.34999999</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.34999999</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.350</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.41999996</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.41999996</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.420</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >109.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >109.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >109.200</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >102.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >102.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >102.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.31999999</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.31999999</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.320</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >26.39999962</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >26.39999962</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >26.400</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >-0.23999999</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >-0.23999999</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >-0.240</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.60000002</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.60000002</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.600</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >2.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >2.00000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >2.000</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-7.19999981</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-7.19999981</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-7.200</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.25999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.25999999</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.260</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >0.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >0.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >1.20000005</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >1.20000005</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >1.200</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.14000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.14000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.140</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-1.20000005</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-1.20000005</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-1.200</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >2.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >2.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >2.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.41999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.41999999</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.420</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.80000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.80000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.800</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.24000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.24000001</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.240</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.66000003</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.66000003</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.660</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.12000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.12000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.120</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >2.50000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >2.50000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >2.500</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >20.79999924</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >20.800</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Water_Drum + Reverb 1</value>
</preset>
<preset name="Piano + Reverb 4" number="16" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >29.20000076</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >29.20000076</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >29.200</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.50000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.50000000</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.500</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >-20.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >-20.00000000</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >-20.000</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.44000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.44000000</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.440</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >0.00000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >0.000</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >24.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >24.00000000</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >24.000</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >-0.57999998</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >-0.57999998</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >-0.580</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >16.79999924</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >16.800</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >45.59999847</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >45.59999847</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >45.600</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.50000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.500</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50999999</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50999999</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.510</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.34000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.34000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.340</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.000</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >91.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >91.19999695</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >91.200</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.00000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.000</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >1.29999995</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >1.29999995</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >1.300</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.34999999</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.34999999</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.350</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >0.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >0.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >0.00000000</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >0.000</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.13999999</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.13999999</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.140</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >120.00000000</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >120.000</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >0.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >0.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >0.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.31999999</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.31999999</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.320</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.13000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.13000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.130</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >60.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >60.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >60.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.12000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.12000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.120</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.60000002</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.60000002</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.600</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >0.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >0.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >0.120</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-45.59999847</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-45.59999847</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-45.600</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.36000001</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.36000001</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.360</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >90.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >90.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >90.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >-60.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >-60.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >-60.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >-0.06000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >-0.06000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >-0.060</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >-1.20000005</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >-1.20000005</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >-1.200</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >-2.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >-2.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >-2.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.18000001</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.18000001</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.180</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >-1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >-1.00000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >-1.000</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.63999999</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.63999999</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.640</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.00000000</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.000</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.52999997</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.52999997</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.530</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >2.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >2.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >2.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00299152</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00272315</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Piano + Reverb 4</value>
</preset>
<preset name="Fog + Reverb 6" number="17" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-4.40000010</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.900</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.660</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >28.800</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.380</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >30.000</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >60.000</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.800</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.750</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.750</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.31999999</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.31999999</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.320</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >100.800</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.340</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.150</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >12.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >70.80000305</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >70.80000305</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >70.800</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >67.200</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >90.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >90.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >90.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.19000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.19000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.190</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >1.20000005</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >1.200</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.000</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-1.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-1.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-1.120</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-60.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >12.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.88000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.88000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.880</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.48000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.48000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.480</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.49000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.49000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.490</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.75000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.75000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.750</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00055289</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00109676</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-4.40000010</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-4.400</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Fog + Reverb 6</value>
</preset>
<preset name="Metal_Drone + Reverb 6" number="18" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-4.40000010</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >20.79999924</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >20.800</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.89999998</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.900</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.660</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >28.79999924</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >28.800</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.38000000</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.380</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >30.00000000</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >30.000</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >60.00000000</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >60.000</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >1.79999995</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >1.800</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >1.79999995</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >1.800</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.41999999</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.420</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.30000001</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.300</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.75000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.750</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.75000000</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.750</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.31999999</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.31999999</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.320</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >100.800</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.340</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.150</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >12.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >70.80000305</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >70.80000305</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >70.800</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >67.19999695</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >67.200</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >90.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >90.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >90.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.95999998</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.95999998</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.960</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >-60.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >-60.00000000</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >-60.000</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.000</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-1.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-1.12000000</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-1.120</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-60.00000000</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-60.000</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >12.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >12.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.88000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.88000000</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.880</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.48000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.48000002</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.480</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.49000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.49000001</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.490</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.75000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.75000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.750</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00539102</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00468890</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-4.40000010</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-4.400</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Metal_Drone + Reverb 6</value>
</preset>
<preset name="Synth1 + Reverb 3" number="19" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >48.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >48.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >48.400</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.83999997</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.83999997</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.840</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.660</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >7.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.300</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >12.600</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >25.200</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >3.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.18000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.18000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.180</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.00000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.000</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >100.800</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.34000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.340</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.150</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >12.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >63.59999847</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >63.59999847</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >63.600</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >68.40000153</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >68.40000153</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >68.400</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >120.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >0.50000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >0.50000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >0.500</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >1.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >3.59999990</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >3.59999990</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >3.600</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.000</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-0.75999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-0.75999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-0.760</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-55.20000076</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-55.20000076</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-55.200</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >120.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >120.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >120.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >60.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >60.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >60.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >0.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.68000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.68000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.680</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.44000006</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.44000006</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.440</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.50999999</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.50999999</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.510</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.87000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.87000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.870</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >1.00000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >1.000</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00539102</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00468890</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Synth1 + Reverb 3</value>
</preset>
<preset name="Synth2 + Reverb 3" number="20" >
<value id="{7fd81566-d369-4ff6-9521-5075574ef5f4}" mode="1" >-20.00000000</value>
<value id="{bff2ae19-cec4-450c-810d-c6488d7eb3db}" mode="1" >48.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="1" >48.40000153</value>
<value id="{0fea90fb-ac1c-4925-bcd8-2b1e85d94751}" mode="4" >48.400</value>
<value id="{466c1f2d-3d92-45cb-9c78-0e7e7c2e0e51}" mode="1" >0.83999997</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="1" >0.83999997</value>
<value id="{ffbc0ada-d2d6-4b6c-9ae3-6451f3049a70}" mode="4" >0.840</value>
<value id="{43be06ea-c25a-46b0-af06-752d2cff8551}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="1" >20.79999924</value>
<value id="{0694c706-5d4e-4014-93d9-33d327a25321}" mode="4" >20.800</value>
<value id="{28520397-fba4-4c4b-8150-b52fa58d9b99}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="1" >0.66000003</value>
<value id="{f50669c7-e80c-4bb2-b167-0c5c274ced7f}" mode="4" >0.660</value>
<value id="{24c1b37e-83f8-4b0b-9b02-3b9def7ecfa5}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="1" >-0.50000000</value>
<value id="{5b929364-1b98-42bf-ba22-52e4fda9cf68}" mode="4" >-0.500</value>
<value id="{a986b8e4-01de-477e-85b6-714e13688232}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="1" >7.19999981</value>
<value id="{8aaae027-8c7a-49af-b6b1-a8a4b15683f8}" mode="4" >7.200</value>
<value id="{671ab614-13de-4602-8709-f5db18fa64bc}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="1" >0.30000001</value>
<value id="{92d0f455-e73b-450a-afb0-739549eda08b}" mode="4" >0.300</value>
<value id="{4e074954-5881-4b46-a89e-301e06cae77f}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="1" >12.60000038</value>
<value id="{44966c39-c062-4957-abc1-566fcf18a13e}" mode="4" >12.600</value>
<value id="{0eb610ed-724e-4bb9-b114-c02de5747bf9}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="1" >25.20000076</value>
<value id="{b07cec19-c077-4b0c-b28a-a5aa4974fc6d}" mode="4" >25.200</value>
<value id="{99c0b327-ffcd-4bc9-a90e-1fe3bda7b065}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="1" >144.00000000</value>
<value id="{a6d6103e-8402-4e90-8e9f-0380c19e2bb6}" mode="4" >144.000</value>
<value id="{1fa0c649-a386-4006-992a-a95697f3f7c0}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="1" >0.00000000</value>
<value id="{38537cf0-ab8b-48a9-85a7-e4e73e3bb7f3}" mode="4" >0.000</value>
<value id="{90efec9c-f402-4cfd-8904-fa607901e247}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="1" >3.00000000</value>
<value id="{3566ce76-d79b-4d9e-a03f-dc1ac9e01743}" mode="4" >3.000</value>
<value id="{9de7cc67-9fc7-471e-8145-8d1a6d6eeff6}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="1" >0.50000000</value>
<value id="{2e81a519-a4b9-41f6-a608-3e11683ae600}" mode="4" >0.500</value>
<value id="{374207f4-395f-42d7-8882-eedb7adb808a}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="1" >0.50000000</value>
<value id="{f435a121-b76c-4a37-a0a7-ad0325e77ac9}" mode="4" >0.500</value>
<value id="{8d683189-6b51-44c6-a767-893da9e946ff}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="1" >0.20000000</value>
<value id="{96f462d5-ac3f-4af8-96b4-9eea077e7e79}" mode="4" >0.200</value>
<value id="{10e3f36f-cc25-415a-a68a-e91700369291}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="1" >0.50000000</value>
<value id="{675f8a7e-27b7-4890-90d5-847e16a649ad}" mode="4" >0.500</value>
<value id="{724ee7ed-0664-4d23-8c8f-8a838961033e}" mode="1" >0.18000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="1" >0.18000001</value>
<value id="{f5c8b864-c25d-4794-95a5-f3375afe7441}" mode="4" >0.180</value>
<value id="{0ecb0018-3c93-4429-a1a2-2b24b39abb2b}" mode="1" >0.34000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="1" >0.34000000</value>
<value id="{24473f93-644e-4ba6-b546-985061bed64f}" mode="4" >0.340</value>
<value id="{030982cd-2ca9-4d8c-a4c5-bd52986694fc}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="1" >100.80000305</value>
<value id="{352c09d0-6a36-485b-888a-8061baa98105}" mode="4" >100.800</value>
<value id="{b0b80165-f444-46ab-b910-2460e89832ca}" mode="1" >0.44000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="1" >0.44000000</value>
<value id="{d7c5a314-9ce5-4f1c-90c6-9a5d024c32b6}" mode="4" >0.440</value>
<value id="{786c1d28-38eb-4413-a727-f694abd512c1}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="1" >0.31999999</value>
<value id="{4c91aaa7-9fe5-445c-969f-56ed424b5d6e}" mode="4" >0.320</value>
<value id="{fa7b7b5d-9826-4a5c-b7a4-bb79e9b8a1cd}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="1" >0.15000001</value>
<value id="{941dbfd1-06be-4cae-a2ac-2379813d77fa}" mode="4" >0.150</value>
<value id="{ffd14281-62ce-4b97-aa29-6e0011faffdd}" mode="1" >0.00000000</value>
<value id="{489e07b5-3656-4234-90e3-4a624792042a}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="1" >12.00000000</value>
<value id="{8eca1bef-7a98-4291-a154-6f6ea920ae32}" mode="4" >12.000</value>
<value id="{ea8d2f19-8b05-4949-9475-f5c979385b29}" mode="1" >63.59999847</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="1" >63.59999847</value>
<value id="{5fddf5db-b5d0-4efd-a334-f6c5b777a1cb}" mode="4" >63.600</value>
<value id="{dec2259d-53e8-4816-8889-79df24673d63}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="1" >1.00000000</value>
<value id="{c36e748b-b4fe-4542-ba69-86bf429e82c5}" mode="4" >1.000</value>
<value id="{d5d6958b-3384-4309-b3c2-32bb51af3b54}" mode="1" >68.40000153</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="1" >68.40000153</value>
<value id="{4a1d3c47-18aa-49f7-ac8c-93d35233cafc}" mode="4" >68.400</value>
<value id="{c0341d29-c062-4ea0-9eba-bc3506bac638}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="1" >120.00000000</value>
<value id="{445be958-7d5d-4191-8242-a1baefd9d08d}" mode="4" >120.000</value>
<value id="{4e745abf-a50b-4f6b-9116-83e74d208f0d}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="1" >0.80000001</value>
<value id="{42ac1c06-8b9d-40a8-832b-43ed222d4f55}" mode="4" >0.800</value>
<value id="{ff8df6e8-8296-44ae-b47f-4557ed73739c}" mode="1" >1.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="1" >1.00000000</value>
<value id="{ad63500e-7fa6-48a7-8e4f-cbc819b7bc06}" mode="4" >1.000</value>
<value id="{4d779359-0ae9-4707-a90e-f256666535b9}" mode="1" >0.00000000</value>
<value id="{75058e27-8b12-4dc2-a7ae-647dd9de3e49}" mode="1" >3.59999990</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="1" >3.59999990</value>
<value id="{bb06148d-c105-475b-9e4a-163f8888ce4e}" mode="4" >3.600</value>
<value id="{7780e271-fc33-403c-88cc-3001b50553bb}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="1" >0.00000000</value>
<value id="{eeac9c7d-9ace-4107-9e35-bdd460e0918c}" mode="4" >0.000</value>
<value id="{506f081b-e5c7-4e53-9971-c3764aad174c}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="1" >-1.29999995</value>
<value id="{b8dccf73-34ce-48b1-b276-6ad0f407580f}" mode="4" >-1.300</value>
<value id="{b009a56e-e255-4ca5-a236-a8f6a076ed77}" mode="1" >-0.75999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="1" >-0.75999999</value>
<value id="{2a1845b5-378c-42cf-a1a9-81aa4e9669b3}" mode="4" >-0.760</value>
<value id="{292cb4d1-41a9-44cb-a8fd-bc375600433f}" mode="1" >-55.20000076</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="1" >-55.20000076</value>
<value id="{00ca8466-07bc-4875-9d42-49a11a31146e}" mode="4" >-55.200</value>
<value id="{53f7ad7e-4353-4adf-b1af-b8668cb8d86d}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="1" >1.00000000</value>
<value id="{5cca6723-c3ff-4a76-beb5-2bef0ca8f941}" mode="4" >1.000</value>
<value id="{4147e11e-5c11-41cf-9cc9-a14dbd1b17fa}" mode="1" >120.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="1" >120.00000000</value>
<value id="{13745bf8-e49a-4773-a561-39c17e1ac831}" mode="4" >120.000</value>
<value id="{7fd7515c-a091-4d27-955d-5a6e08c44e0b}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="1" >0.00000000</value>
<value id="{163a86c6-d25a-4415-a9eb-4669b81b21ef}" mode="4" >0.000</value>
<value id="{ebf38056-f6fe-46de-87ab-89f0b4e5aa81}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="1" >0.00000000</value>
<value id="{194a05f5-61ed-41ed-a89a-2c293dc12af4}" mode="4" >0.000</value>
<value id="{2234b84c-6d59-4de2-84a6-486454385684}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="1" >0.00000000</value>
<value id="{76b958c4-6632-4f56-96cb-d59ebbe7b9fb}" mode="4" >0.000</value>
<value id="{72fc9987-a42a-46e8-96f6-0a02f25ae92f}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="1" >0.00000000</value>
<value id="{5ef2257d-81b1-410f-bc1a-ce623b2c6f82}" mode="4" >0.000</value>
<value id="{86f9ba4b-d465-4b9c-9401-e96243ae08fa}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="1" >0.00000000</value>
<value id="{e0723488-4eee-47e1-a218-ada83f1ff6af}" mode="4" >0.000</value>
<value id="{d1f6a1c7-6c7e-42cc-90a7-7a775d971ebf}" mode="1" >1.00000000</value>
<value id="{69cc53a4-30b2-4a5e-900a-4acc0bddb704}" mode="1" >0.68000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="1" >0.68000001</value>
<value id="{fdb58dea-80dc-4bed-8d1e-26b911fc19ae}" mode="4" >0.680</value>
<value id="{49df04c2-baac-4801-80dc-1dc7ee81b0f0}" mode="1" >1.44000006</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="1" >1.44000006</value>
<value id="{76447115-2a94-4b39-a237-2f2be5022e0e}" mode="4" >1.440</value>
<value id="{03ca5ad6-5038-43dd-aab6-1ff801b9a819}" mode="1" >0.50999999</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="1" >0.50999999</value>
<value id="{faefc165-edb5-408b-a710-5c628066cc15}" mode="4" >0.510</value>
<value id="{e0f63106-0a7d-46cd-8200-f9e62336cf10}" mode="1" >0.87000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="1" >0.87000000</value>
<value id="{242cde03-7d61-492e-95fb-0f618c381ba2}" mode="4" >0.870</value>
<value id="{d1d11f9a-d929-4b2d-bf8e-a057790e14f2}" mode="1" >0.75000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="1" >0.75000000</value>
<value id="{f1edd2c7-0b12-4fd9-a6e1-67d43da336a7}" mode="4" >0.750</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="1" >0.42857099</value>
<value id="{62b015b8-119a-4016-8372-b47f22d0a073}" mode="2" >0.00539102</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="1" >0.42857099</value>
<value id="{b076f37e-0a9e-4351-bd25-7a00befe5542}" mode="2" >0.00468890</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="1" >0.27777800</value>
<value id="{148f2aec-4b3e-4dd6-87ab-4ff2f32a5b6f}" mode="2" >1.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="1" >-20.00000000</value>
<value id="{115f6545-8b1e-4026-9b27-fecb23726c6b}" mode="4" >-20.000</value>
<value id="{17dcb866-30bb-4dac-bdf1-126e885d668b}" mode="1" >1.00000000</value>
<value id="{0065ae48-aaaa-4992-9c61-42342bd369a8}" mode="1" >2.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="1" >0.00000000</value>
<value id="{4868e68a-6bc0-4401-b7d3-978bdfba9fae}" mode="4" >Synth2 + Reverb 3</value>
</preset>
</bsbPresets>
<EventPanel name="New" tempo="100.00000000" loop="8.00000000" x="0" y="0" width="582" height="720" visible="false" loopStart="0" loopEnd="0">i 1 0 0.4 40 
i 1 0.5 0.4 44 
i 1 1 0.4 47 
i 1 1.5 0.4 45 
i 1 2 0.4 36 
i 1 2.5 0.4 37 
i 1 3 0.4 37 
i 1 3.5 0.4 44 
i 1 4 0.4 37 
i 1 4.5 0.4 43 
i 1 5 0.4 44 
i 1 5.5 0.1 73 
i 1 6 0.1 36 
i 1 6.5 0.1 49 
i 1 7 0.1 42 
i 1 7.5 0.1 37 
    
    
    
    
    
    
    
    
    
    </EventPanel>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="118" y="351" width="655" height="346" visible="true" loopStart="0" loopEnd="0">i 1 0 0.1 73 </EventPanel>
