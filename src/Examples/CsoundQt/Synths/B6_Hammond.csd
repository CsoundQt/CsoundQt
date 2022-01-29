;From DirectHammond v2 by Josep M Comajuncosas

; Add midi controlers for vibrato control

;My csound flags on Ubuntu: -dm0 -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100
ksmps	= 128
nchnls	= 2

#define	CC_Amp	#1#		;Vibrato amplitude midi controler
#define	CC_Freq	#74#		;Vibrato frequency midi controler

			massign		0,2

chn_k "Acc", "f"
chn_k "Asymm", 1
chn_k "C", 1
chn_k "Csound_On", 2
chn_k "Cutoff", 1
chn_k "Del", 1
chn_k "Delay", 1
chn_k "Depth", 1
chn_k "Det_L", 1
chn_k "Dist", 1
chn_k "Drive", 1
chn_k "Fdbk", 1
chn_k "Fq_Sep", 1
chn_k "Fst", 1
chn_k "H_16ft_lvl", 1
chn_k "H_1_23ft_lvl", 1
chn_k "H_1_35ft_lvl", 1
chn_k "H_1ft_lvl", 1
chn_k "H_2_23ft_lvl", 1
chn_k "H_2ft_lvl", 1
chn_k "H_4ft_lvl", 1
chn_k "H_5_13ft_lvl", 1
chn_k "H_8ft_lvl", 1
chn_k "H_Acc", 1
chn_k "H_Att", 1
chn_k "H_Attack", 1
chn_k "H_Cut", 1
chn_k "H_Dec", 1
chn_k "H_Doppler", 1
chn_k "H_Fast", 1
chn_k "H_Harm", 1
chn_k "H_Leak", 1
chn_k "H_Level", 1
chn_k "H_Oct", 1
chn_k "H_Perc_lvl", 1
chn_k "H_Q", 1
chn_k "H_Slow", 1
chn_k "High", 1
chn_k "L_16ft_lvl", 1
chn_k "L_1_23ft_lvl", 1
chn_k "L_1_35ft_lvl", 1
chn_k "L_1ft_lvl", 1
chn_k "L_2_23ft_lvl", 1
chn_k "L_2ft_lvl", 1
chn_k "L_4ft_lvl", 1
chn_k "L_5_13ft_lvl", 1
chn_k "L_8ft_lvl", 1
chn_k "L_Acc", 1
chn_k "L_Att", 1
chn_k "L_Attack", 1
chn_k "L_Cut", 1
chn_k "L_Dec", 1
chn_k "L_Doppler", 1
chn_k "L_Fast", 1
chn_k "L_Harm", 1
chn_k "L_Leak", 1
chn_k "L_Level", 1
chn_k "L_Oct", 1
chn_k "L_Perc_lvl", 1
chn_k "L_Q", 1
chn_k "L_Slow", 1
chn_k "Low", 1
chn_k "Main_Vol", 1
chn_k "Master_Tune", 1
chn_k "Mix", 1
chn_k "P_Display", 2
chn_k "PreEff", 1
chn_k "Rev", 1
chn_k "Rot", 1
chn_k "Scan", 1
chn_k "Size", 1
chn_k "Slow_Fast_Rot", 1
chn_k "Slw", 1
chn_k "Soft", 1
chn_k "Split", 1
chn_k "aM", 1
chn_k "frq_Att", 1
chn_k "postGain", 1

opcode	Parameter_Display, 0, k

	kParam		xin
	ktrig		changed	kParam
	if (ktrig == 1) then
		chnset	 kParam, "P_Display"
	endif
endop

instr	1	;GUI

	kCsound_On	lfo	1, 1, 2
	chnset  kCsound_On, "Csound_On" ;Flickering LED when Csound is running

	ktrig		metro	10

	if (ktrig == 1) then
		;L
		gkL_16ft_lvl		chnget	"L_16ft_lvl"
		gkL_8ft_lvl		chnget	"L_8ft_lvl"
		gkL_5_13ft_lvl		chnget	"L_5_13ft_lvl"
		gkL_4ft_lvl		chnget	"L_4ft_lvl"
		gkL_2_23ft_lvl		chnget	"L_2_23ft_lvl"
		gkL_2ft_lvl		chnget	"L_2ft_lvl"
		gkL_1_35ft_lvl		chnget	"L_1_35ft_lvl"
		gkL_1_23ft_lvl		chnget	"L_1_23ft_lvl"
		gkL_1ft_lvl		chnget	"L_1ft_lvl"
		gk_L_Att			chnget	"L_Attack"
		gkL_leak			chnget	"L_Leak"
		gkL_lvl			chnget	"L_Level"
		gk_L_perc_Dec		chnget	"L_Dec"
		gkL_perc_Harm		chnget	"L_Harm"
		gkL_perc_lvl		chnget	"L_Perc_lvl"
		gkOct_Lo			chnget	"L_Oct"
		;H
		gkH_16ft_lvl		chnget	"H_16ft_lvl"
		gkH_8ft_lvl		chnget	"H_8ft_lvl"
		gkH_5_13ft_lvl		chnget	"H_5_13ft_lvl"
		gkH_4ft_lvl		chnget	"H_4ft_lvl"
		gkH_2_23ft_lvl		chnget	"H_2_23ft_lvl"
		gkH_2ft_lvl		chnget	"H_2ft_lvl"
		gkH_1_35ft_lvl		chnget	"H_1_35ft_lvl"
		gkH_1_23ft_lvl		chnget	"H_1_23ft_lvl"
		gkH_1ft_lvl		chnget	"H_1ft_lvl"
		gk_H_Att			chnget	"H_Attack"
		gkH_leak			chnget	"H_Leak"
		gkH_lvl			chnget	"H_Level"
		gk_H_perc_Dec		chnget	"H_Dec"
		gkH_perc_Harm		chnget	"H_Harm"
		gkH_perc_lvl		chnget	"H_Perc_lvl"
		gkOct_Hi			chnget	"H_Oct"
		;Gen
		gkTune			chnget	"Master_Tune"
		gkDetl			chnget	"Det_L"
		gkDet_L1			chnget	"Mix"
		;Effect returns
		gkMain_PreEff		chnget	"PreEff"
		gkfx_Scan			chnget	"Scan"
		gkfx_Dist			chnget	"Dist"
		gkfx_Rot			chnget	"Rot"
		gkfx_Del			chnget	"Del"
		gkfx_Rev			chnget	"Rev"
		gkSlowFast		chnget	"Slow_Fast_Rot"
		;Main ctrl
		gkSplit			chnget	"Split"
		gkMain_Vol		chnget	"Main_Vol"
		;Scanner
		gkSc_C			chnget  "C"
		gkSc_Acc			chnget  "Acc"
		gkSc_Fst			chnget  "Fst"
		gkSc_Slw			chnget  "Slw"
		gkSc_Depth		chnget  "Depth"
		gkSc_Delay		chnget  "Delay"
		;Distortion
		gkSoft_Drive		chnget  "Soft"
		gkDist_Drive		chnget  "Drive"
		gkDist_Cutoff		chnget  "Cutoff"
		gkAsymm			chnget  "Asymm"
		gkDist_postGain	chnget  "postGain"
		;Delay
		gkFlanger_dlt		chnget  "Delay"
		gkFlanger_fdbk		chnget  "Fdbk"
		;Reverb
		gkRvb_time		chnget  "Size"
		gkRvb_Attn		chnget  "frq_Att"
		;Leslie
		gkH_Slw			chnget  "H_Slow"
		gkL_Slw			chnget  "L_Slow"
		gkH_Fst			chnget  "H_Fast"
		gkL_Fst			chnget  "L_Fast"
		gkH_Acc			chnget  "H_Acc"
		gkL_Acc			chnget  "L_Acc"
		gkFq_Sep			chnget  "Fq_Sep"
		gkaM				chnget  "aM"
		gkH_Att2			chnget  "H_Att"
		gkL_Att2			chnget  "L_Att"
		gkHCut			chnget  "H_Cut"
		gkLCut			chnget  "L_Cut"
		gkHQ				chnget  "H_Q"
		gkLQ				chnget  "L_Q"
		gkHigh			chnget  "High"
		gkLow			chnget  "Low"
		gkH_Doppler		chnget  "H_Doppler"
		gkL_Doppler		chnget  "L_Doppler"
	endif
endin

instr	2	;Midi Organ

	gasig		init		0

	ikey			notnum
	ioct			octmidi

	;PITCH BEND=============================================================================================
	iSemitoneBendRange = 12										;PITCH BEND RANGE IN SEMITONES
	imin		= 0												;EQUILIBRIUM POSITION
	imax		= iSemitoneBendRange * .0833333						;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend	pchbend	imin, imax								;PITCH BEND VARIABLE (IN oct FORMAT)
	kcps		=	cpsoct(ioct + kbend)							;SET FUNDAMENTAL
	;=======================================================================================================

	kamp_vib		midictrl	$CC_Amp, 0, 0.1
	kfreq_vib		midictrl	$CC_Freq, 0.01, 5

	kvib			lfo		kcps*kamp_vib, kfreq_vib
	kcps			=		kcps + kvib
	kOct_Hi		=		2^(gkOct_Hi-1)
	kOct_Lo		=		2^(gkOct_Lo-1)
	kfreq0		=		kcps * gkTune
	kfreq1		=		kfreq0 * kOct_Hi
	kfreq2		=		kfreq0 * gkDetl*kOct_Lo

	;GENERATORS
	;tonewheels
	a01			oscil	1,kfreq1,1
	a02			oscil	1,2*kfreq1,1
	a03			oscil	1,3*kfreq1,1
	a04			oscil	1,4*kfreq1,1
	a06			oscil	1,6*kfreq1,1
	a08			oscil	1,8*kfreq1,1
	a10			oscil	1,10*kfreq1,1
	a12			oscil	1,12*kfreq1,1
	a16			oscil	1,16*kfreq1,1

	ad01			oscil	1,kfreq2,1
	ad02			oscil	1,2*kfreq2,1
	ad03			oscil	1,3*kfreq2,1
	ad04			oscil	1,4*kfreq2,1
	ad06			oscil	1,6*kfreq2,1
	ad08			oscil	1,8*kfreq2,1
	ad10			oscil	1,10*kfreq2,1
	ad12			oscil	1,12*kfreq2,1
	ad16			oscil	1,16*kfreq2,1

	;add both tonewheel arrays
	a16ft		sum		a01,ad01
	a8ft			sum		a02,ad02
	a5_13ft		sum		a03,ad03
	a4ft			sum		a04,ad04
	a2_23ft		sum		a06,ad06
	a2ft			sum		a08,ad08
	a1_35ft		sum		a10,ad10
	a1_23ft		sum		a12,ad12
	a1ft			sum		a16,ad16

	aftSum		sum		a16ft,a8ft,a5_13ft,a4ft,a2_23ft,a2ft,a1_35ft,a1_23ft,a1ft

	aNull		init		0

	;DRAWBARS HIGH
	aH_16ft		mac		gkH_16ft_lvl   , a16ft
	aH_8ft		mac		gkH_8ft_lvl    , a8ft
	aH_5_13ft		mac		gkH_5_13ft_lvl , a5_13ft
	aH_4ft		mac		gkH_4ft_lvl    , a4ft
	aH_2_23ft		mac		gkH_2_23ft_lvl , a2_23ft
	aH_2ft		mac		gkH_2ft_lvl    , a2ft
	aH_1_35ft		mac		gkH_1_35ft_lvl , a1_35ft
	aH_1_23ft		mac		gkH_1_23ft_lvl , a1_23ft
	aH_1ft		mac		gkH_1ft_lvl    , a1ft

	aH_ftSum		sum		aH_16ft,aH_8ft,aH_5_13ft,aH_4ft,aH_2_23ft,aH_2ft,aH_1_35ft,aH_1_23ft,aH_1ft
	aH_env		madsr	i(gk_H_Att),0,1,0.01
	aH_env		=		(gkSplit > ikey ? aNull:aH_env)
	kH_perc_Harm	=		gkH_perc_Harm

	aH_perc		=		(kH_perc_Harm > 2 ? a2_23ft:a4ft)
	aH_perc_env	madsr	0.01,i(gk_H_perc_Dec),0,0.01
	aH_perc_env	=		(gkSplit > ikey ? aNull:aH_perc_env)
	aH_ftSumOut	=		(aH_ftSum + gkH_leak*aftSum)*aH_env*gkH_lvl + (gkH_perc_lvl*aH_perc)*aH_perc_env

	;DRAWBARS LOW
	aL_16ft		mac		gkL_16ft_lvl   ,a16ft
	aL_8ft		mac		gkL_8ft_lvl    ,a8ft
	aL_5_13ft		mac		gkL_5_13ft_lvl ,a5_13ft
	aL_4ft		mac		gkL_4ft_lvl    ,a4ft
	aL_2_23ft		mac		gkL_2_23ft_lvl ,a2_23ft
	aL_2ft		mac		gkL_2ft_lvl    ,a2ft
	aL_1_35ft		mac		gkL_1_35ft_lvl ,a1_35ft
	aL_1_23ft		mac		gkL_1_23ft_lvl ,a1_23ft
	aL_1ft		mac		gkL_1ft_lvl    ,a1ft

	aL_ftSum		sum		aL_16ft,aL_8ft,aL_5_13ft,aL_4ft,aL_2_23ft,aL_2ft,aL_1_35ft,aL_1_23ft,aL_1ft
	aL_env		madsr	i(gk_L_Att),0,1,0.01
	aL_env		=		(gkSplit > ikey ? aL_env:aNull)
	kL_perc_Harm	=		gkL_perc_Harm

	aL_perc		=		(kL_perc_Harm > 2 ? a2_23ft:a4ft)
	aL_perc_env	madsr	0.01,i(gk_L_perc_Dec),0,0.01
	aL_percEnv	=		(gkSplit > ikey ? aL_perc_env:aNull)
	aL_ftSumOut	=		(aL_ftSum + gkL_leak*aftSum)*aL_env*gkL_lvl + (gkL_perc_lvl*aL_perc)*aL_perc_env

	;mix&output
	aout			sum		aL_ftSumOut,aH_ftSumOut
	gasig		=		gkMain_PreEff*aout + gasig
endin

instr	3	;Effects
	;Get and display preset nb

	aSignal		=		gasig
	;;Scanner
	kSc_LpOut		tonek	gkSc_C,gkSc_Acc
	kSc_Fst2		=		kSc_LpOut*gkSc_Fst
	kSc_Freq		=		(kSc_Fst2 > gkSc_Slw ? kSc_Fst2:gkSc_Slw)
	kSc_sine		oscil	gkSc_Depth,kSc_Freq,1

	aSc_dlt1		interp	(1-kSc_sine)*gkSc_Delay
	aSc_dlt2		interp	(1+kSc_sine)*gkSc_Delay
	aSc_Dl1		vdelay	aSignal,aSc_dlt1,60
	aSc_Dl2		vdelay	aSignal,aSc_dlt2,60

	aSc_Out		=		gkfx_Scan*(aSc_Dl1+aSc_Dl2)+(1-gkfx_Scan)*aSignal

	;;Distortion
	aSat_In		butterlp	aSc_Out*gkDist_Drive,gkDist_Cutoff

	kLp			=		2.5*(1-gkAsymm)
	kLn			=		-2.5*(1+gkAsymm)

	aLp			upsamp	kLp
	aLn			upsamp	kLn

	;now some a-rate conditionals with tables
	;Positive
	aSat_In		=		4*tanh(gkSoft_Drive*aSat_In);trick to avoid overflow of the original Sync Modular module (-4,4)
	arel1		table	aSat_In,10,1,.5,0
	aSat1		=		(arel1)*(((((-4*kLp)+aSat_In)*aSat_In)))/(-4*kLp)+(1-arel1)*aSat_In

	arel2		table	aSat_In-2*kLp,10,1,.5,0
	aSat2		=		(arel2)*aLp+(1-arel2)*aSat1

	;Negative
	arel3		table	aSat2,10,1,.5,0
	aSat3		=		(1-arel1)*(((((-4*kLn)+aSat2)*aSat2)))/(-4*kLn)+(arel3)*aSat2

	arel4		table	aSat2-2*kLn,10,1,.5,0
	aSat4		=		(1-arel4)*aLp+(arel4)*aSat3
	aDist_Out		mac		gkDist_postGain*gkfx_Dist,aSat4,(1-gkfx_Dist),aSc_Out

	;;Feedback delay
	;aFlanger_dlt interp gkFlanger_dlt
	aFlanger_dlt	upsamp	gkFlanger_dlt
	aFlanger		flanger	aDist_Out, aFlanger_dlt, gkFlanger_fdbk ,1
	aFlanger_Out	dcblock	gkfx_Del*aFlanger+(1-gkfx_Del)*aDist_Out
	aFlanger_Out	mac		gkfx_Del,aFlanger,(1-gkfx_Del),aDist_Out

	;;Freverb reverb
	aRvb_Free		nreverb	aFlanger_Out, gkRvb_time, gkRvb_Attn, 0, 8, 71, 4, 72
	aRvb_Out		mac		gkfx_Rev,aRvb_Free,(1-gkfx_Rev),aFlanger_Out

	;;Rotary Speaker Effect
	;SPEED/ACCEL
	kL_Horn		tonek	gkL_Fst*gkSlowFast+gkL_Slw*(1-gkSlowFast),gkL_Acc
	kH_Horn		tonek	gkH_Fst*gkSlowFast+gkH_Slw*(1-gkSlowFast),gkH_Acc

	kH			oscil	1, kH_Horn,1
	kL			oscil	1, kL_Horn,1

	;ATTEN
	aLP,aHP,aBP1	svfilter	aDist_Out, gkFq_Sep, .7,1
	aBP1			=		.3*aBP1
	aO1			=		(kH+gkaM)*(aLP+aBP1)
	aO2			=		(kL+gkaM)*(aHP+aBP1)

	kCL			=		gkL_Att2
	kCH			=		gkH_Att2

	;HP FILTERS
	kHQ			=		1+500*gkHQ
	kLQ			=		1+500*gkLQ

	aLP2, aHP2, aBP2 svfilter aO2, gkHCut, kHQ,1
	aLP3, aHP3, aBP3 svfilter aO1, gkLCut, kLQ,1

	aDS			=		aO1 + (gkLow*(kL-1)*aHP3)
	aDD			=		aO1 + (gkLow*(-1-kL)*aHP3)
	aHS			=		aO2 + (gkHigh*(-1-kH)*aHP2)
	aHD			=		aO2 + (gkHigh*(kH-1)*aHP2)

	;DOPPLER
	kH_Horn		=		(1/kH_Horn+1)*gkH_Doppler
	kL_Horn		=		(1/kL_Horn+1)*gkL_Doppler

	;SEPARATOR1
	kLCL1		=		kL*kCL
	kDL1			=		1-kLCL1
	kSL1			=		kLCL1+1
	kHCH1		=		kH*kCH
	kDH1			=		1-kHCH1
	kSH1			=		kHCH1+1

	;SEPARATOR2
	kLCL2		=		kL*kL_Horn
	kDL2			=		1-kLCL2
	kSL2			=		kLCL2+1
	kHCH2		=		kH*kH_Horn
	kDH2			=		1-kHCH2
	kSH2			=		kHCH2+1

	;DELAYS
	;interpolating upsamplers (works faster but adds noise)
	aDL2			interp	kDL2
	aDH2			interp	kDH2
	aSL2			interp	kSL2
	aSH2			interp	kSH2

	aD1			vdelay	aDD*kDL1, 1.5*aSL2, 3
	aD2			vdelay	aHD*kDH1, 1.5*aSH2, 3
	aD3			vdelay	aDS*kSL1, 1.5*aDL2, 3
	aD4			vdelay	aHS*kSH1, 1.5*aDH2, 3

	aLeslie_Dry	=		(1-gkfx_Rot)*aDist_Out
	aLeslie_L		mac		gkfx_Rot,(aD1+aD2),1,aLeslie_Dry
	aLeslie_R		mac		gkfx_Rot,(aD3+aD4),1,aLeslie_Dry

	gkirms		init		1000
	aout_L		=		gkirms*(aLeslie_L + aRvb_Out)*gkMain_Vol
	aout_R		=		gkirms*(aLeslie_R + aRvb_Out)*gkMain_Vol
	galevel		=		aLeslie_L + aRvb_Out

				outs		aout_L,aout_R
	gasig		=		0
endin

instr 10	;Param Display 

	Parameter_Display	gkL_16ft_lvl
	Parameter_Display	gkL_8ft_lvl
	Parameter_Display	gkL_5_13ft_lvl
	Parameter_Display	gkL_4ft_lvl
	
	Parameter_Display	gkL_2_23ft_lvl
	Parameter_Display	gkL_2ft_lvl
	Parameter_Display	gkL_1_35ft_lvl
	Parameter_Display	gkL_1_23ft_lvl
	Parameter_Display	gkL_1ft_lvl
	Parameter_Display	gk_L_Att
	Parameter_Display	gkL_leak
	Parameter_Display	gkL_lvl
	Parameter_Display	gk_L_perc_Dec
	Parameter_Display	gkL_perc_Harm
	Parameter_Display	gkL_perc_lvl
	Parameter_Display	gkOct_Lo
	Parameter_Display	gkH_16ft_lvl
	Parameter_Display	gkH_8ft_lvl
	Parameter_Display	gkH_5_13ft_lvl
	Parameter_Display	gkH_4ft_lvl
	Parameter_Display	gkH_2_23ft_lvl
	Parameter_Display	gkH_2ft_lvl
	Parameter_Display	gkH_1_35ft_lvl
	Parameter_Display	gkH_1_23ft_lvl
	Parameter_Display	gkH_1ft_lvl
	Parameter_Display	gk_H_Att
	Parameter_Display	gkH_leak
	Parameter_Display	gkH_lvl
	Parameter_Display	gk_H_perc_Dec
	Parameter_Display	gkH_perc_Harm
	Parameter_Display	gkH_perc_lvl
	Parameter_Display	gkOct_Hi
	Parameter_Display	gkTune
	Parameter_Display	gkDetl
	Parameter_Display	gkDet_L1
	Parameter_Display	gkMain_PreEff
	Parameter_Display	gkfx_Scan
	Parameter_Display	gkfx_Dist
	Parameter_Display	gkfx_Rot
	Parameter_Display	gkfx_Del
	Parameter_Display	gkfx_Rev
	Parameter_Display	gkSlowFast
	Parameter_Display	gkSplit
	Parameter_Display	gkMain_Vol
	Parameter_Display	gkSc_C
	Parameter_Display	gkSc_Acc
	Parameter_Display	gkSc_Fst
	Parameter_Display	gkSc_Slw
	Parameter_Display	gkSc_Depth
	Parameter_Display	gkSc_Delay
	Parameter_Display	gkSoft_Drive
	Parameter_Display	gkDist_Drive
	Parameter_Display	gkDist_Cutoff
	Parameter_Display	gkAsymm
	Parameter_Display	gkDist_postGain
	Parameter_Display	gkFlanger_dlt
	Parameter_Display	gkFlanger_fdbk
	Parameter_Display	gkRvb_time
	Parameter_Display	gkRvb_Attn
	Parameter_Display	gkH_Slw
	Parameter_Display	gkL_Slw
	Parameter_Display	gkH_Fst
	Parameter_Display	gkL_Fst
	Parameter_Display	gkH_Acc
	Parameter_Display	gkL_Acc
	Parameter_Display	gkFq_Sep
	Parameter_Display	gkaM
	Parameter_Display	gkH_Att2
	Parameter_Display	gkL_Att2
	Parameter_Display	gkHCut
	Parameter_Display	gkLCut
	Parameter_Display	gkHQ
	Parameter_Display	gkLQ
	Parameter_Display	gkHigh
	Parameter_Display	gkLow
	Parameter_Display	gkH_Doppler
	Parameter_Display	gkL_Doppler
endin

</CsInstruments>
<CsScore>
f 1 0 8193 10 1
f 2 0 8193 10 2 4 0 3 5 2

;distortion
f 6 0 8193 7 -.8 934 -.79 934 -.77 934 -.64 1034 -.48 520 .47 2300 .48 1536 .48
f 7 0 4097 4 6 1
;relay
f 10 0 32 7 0 16 0 0 1 16 1
; freeverb time constants, as direct (negative) sample, with arbitrary gains
f 71 0 16   -2  -1116 -1188 -1277 -1356 -1422 -1491 -1557 -1617  0.8  0.79  0.78  0.77  0.76  0.75  0.74  0.73
f 72 0 16   -2  -556 -441 -341 -225 0.7  0.72  0.74  0.76

i 1 0 3600	;GUI
i 3 0 3600	;Effects
i 10 0 3600	;Param Display
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>1092</width>
 <height>450</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>175</r>
  <g>119</g>
  <b>70</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>648</width>
  <height>432</height>
  <uuid>{6f0b57cb-1e58-4218-80cf-59249662ff5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>DirectHammond</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>654</x>
  <y>189</y>
  <width>426</width>
  <height>180</height>
  <uuid>{022b54d7-9c1d-4d55-a2f3-6fe961a509d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Leslie</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>654</x>
  <y>2</y>
  <width>150</width>
  <height>180</height>
  <uuid>{20e7c88b-7b7b-4aa9-a760-cc0d8f0c6802}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Scanner</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>660</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{35d0414a-408b-4ee4-a4fb-f38019dfa6f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>C</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>C</objectName>
  <x>660</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{941145af-5130-494b-bd18-6afb7f1daea6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.89999998</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>706</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{4741f352-3888-40fe-b851-b60f89b5a362}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Acc</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Acc</objectName>
  <x>706</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{8772001c-4803-427f-8e97-da0278383e78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.20000005</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>752</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{43f7da39-02c3-45dd-9c0c-39e16f11604e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Fst</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Fst</objectName>
  <x>752</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{900de65b-4cb0-43e0-8be8-9bdf383f1da6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>5.00000000</maximum>
  <value>2.29999995</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>808</x>
  <y>2</y>
  <width>150</width>
  <height>180</height>
  <uuid>{f76500c7-7bf2-4c67-8083-cc1af5b6c7a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Distortion</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>962</x>
  <y>2</y>
  <width>57</width>
  <height>180</height>
  <uuid>{4deb5b53-bfca-464e-811f-a3af68b0542a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Delay</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1023</x>
  <y>2</y>
  <width>57</width>
  <height>180</height>
  <uuid>{abdb9239-64ab-47b3-8bc1-2d318eee120e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Reverb</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Delay</objectName>
  <x>752</x>
  <y>104</y>
  <width>45</width>
  <height>45</height>
  <uuid>{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>20.00000000</minimum>
  <maximum>30.00000000</maximum>
  <value>0.30000001</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>752</x>
  <y>146</y>
  <width>45</width>
  <height>25</height>
  <uuid>{8819b190-b007-4904-852b-1122e02796b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Delay</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Depth</objectName>
  <x>706</x>
  <y>104</y>
  <width>45</width>
  <height>45</height>
  <uuid>{e050cd68-6a1c-46c7-aeca-056ca8903edd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.05000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>706</x>
  <y>146</y>
  <width>45</width>
  <height>25</height>
  <uuid>{204f4e3d-df10-4600-8ef6-ea4c88b35609}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Depth</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Slw</objectName>
  <x>660</x>
  <y>104</y>
  <width>45</width>
  <height>45</height>
  <uuid>{22710c60-83fe-49c8-85bd-48b4e83d24a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.99500000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>660</x>
  <y>146</y>
  <width>45</width>
  <height>25</height>
  <uuid>{0d78dae2-c6bf-4124-b53a-be9df3e1bb92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Slw</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>814</x>
  <y>146</y>
  <width>45</width>
  <height>25</height>
  <uuid>{308bd1a9-e8bd-4fdd-9487-e053eb212bc7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Asym</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Asymm</objectName>
  <x>814</x>
  <y>104</y>
  <width>45</width>
  <height>45</height>
  <uuid>{607df0cb-5c71-4b28-87ef-48b4db04e0c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>0.99000000</maximum>
  <value>0.10000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>860</x>
  <y>146</y>
  <width>45</width>
  <height>33</height>
  <uuid>{516faba2-85c7-48e9-8cdc-29b9a9eb7627}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Post
Gain</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>postGain</objectName>
  <x>860</x>
  <y>104</y>
  <width>45</width>
  <height>45</height>
  <uuid>{94e78f6e-9647-4b29-b42e-12392d43d243}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.12500000</minimum>
  <maximum>8.00000000</maximum>
  <value>1.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Cutoff</objectName>
  <x>906</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{b29f025c-3961-4556-a99d-f4f0ba79a812}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>250.00000000</minimum>
  <maximum>4000.00000000</maximum>
  <value>1000.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>906</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{601d5d87-ece6-4e2f-87b3-daae92230a95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Cutoff</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Drive</objectName>
  <x>860</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <value>0.10000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>860</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{afead70e-4c40-4230-bd35-cf2835096f76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Drive</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Soft</objectName>
  <x>814</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{91421fab-60e7-4d9a-b74c-066e72306a2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.06250000</minimum>
  <maximum>0.25000000</maximum>
  <value>0.12500000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>814</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{81c02e46-fc01-4df0-9b67-c7922e6ed9c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Soft</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>967</x>
  <y>146</y>
  <width>45</width>
  <height>25</height>
  <uuid>{feeaa0de-51d6-4163-bc51-b099012ea69d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Fdbk</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Fdbk</objectName>
  <x>967</x>
  <y>104</y>
  <width>45</width>
  <height>45</height>
  <uuid>{123e0436-9770-41ef-a9e3-555144e8e8b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-0.99900000</minimum>
  <maximum>0.99900000</maximum>
  <value>-0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1029</x>
  <y>146</y>
  <width>45</width>
  <height>33</height>
  <uuid>{d15df7cf-0297-45a3-b5ed-33541112b9c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Freq
Att</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>frq_Att</objectName>
  <x>1029</x>
  <y>104</y>
  <width>45</width>
  <height>45</height>
  <uuid>{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>660</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{e534bb84-0c74-4adf-abc5-fb216b803a64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>L Slow</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Slow</objectName>
  <x>660</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{a105b464-1a7a-447d-b639-001eeaae053c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>15.00000000</maximum>
  <value>2.48400000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Slow</objectName>
  <x>660</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{d6d78f07-18b2-417d-a47b-82c7d718928d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.20000000</minimum>
  <maximum>16.00000000</maximum>
  <value>0.33000001</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>660</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{d850ccb0-3ca5-4407-8558-2135093702e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>H Slow</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Size</objectName>
  <x>1029</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{82ef0d5f-c09c-4a12-aaad-62491c7b5706}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.05000000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1029</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{4036e7d6-d39f-4dc5-a445-e3b2675ba2cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Size</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Delay</objectName>
  <x>967</x>
  <y>36</y>
  <width>45</width>
  <height>45</height>
  <uuid>{05c3e194-a578-4515-84f8-16ec034702d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000001</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>967</x>
  <y>78</y>
  <width>45</width>
  <height>25</height>
  <uuid>{d5389edc-72b0-4236-9c99-a83bc9b5755b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Delay</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>706</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{0ce0affc-6404-48c6-aff7-32b90daff0da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>H Fast</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Fast</objectName>
  <x>706</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.20000000</minimum>
  <maximum>16.00000000</maximum>
  <value>9.72999954</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Fast</objectName>
  <x>706</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>15.00000000</maximum>
  <value>9.63600000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>706</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{a7b653a8-2ada-40a2-abb5-54a7c6ccb608}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>L Fast</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>752</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{6353adb2-c731-4980-b660-7aa9bbef5204}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>H Acc</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Acc</objectName>
  <x>752</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.10000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Acc</objectName>
  <x>752</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.11000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>752</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{55bf24a8-697c-4173-8626-65edbbc0a124}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>L Acc</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>844</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{7d6c026a-e1da-43fe-a931-f5a01097f46e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>L Att</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Att</objectName>
  <x>844</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{5f18ed65-974d-413e-bfda-fc86e33d1a28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.42000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Att</objectName>
  <x>844</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{c9e38516-b219-4fb4-bb80-acf1ac41f839}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20999999</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>844</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{72d9bbb6-ca7d-4113-a664-08b37c7329ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>H Att</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>798</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{baf8783e-737d-42d5-88b7-338924a73f4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Fq Sep</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Fq_Sep</objectName>
  <x>798</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>100.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>1638.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>aM</objectName>
  <x>798</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{890e82a9-c10e-49c9-9764-300800695570}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.72000003</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>798</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{2d1ab23f-9162-4612-962c-3349969c7b90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>aM</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>982</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{2c993f20-41d4-411a-b133-38cfc824b424}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Low</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Low</objectName>
  <x>982</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{c4921c07-6725-444d-b0a4-5df427d7b3fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.92000002</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>High</objectName>
  <x>982</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{de3c486b-90d7-453f-9dbc-a0fe0480e62f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>982</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{8e6db087-592a-458b-81a8-3da071fafea7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>High</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>936</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{164b4552-5120-42b2-a4a5-0f773d146716}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>LQ</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Q</objectName>
  <x>936</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{e2f90086-0c79-466d-90df-408dfaa9cf79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00100000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.87000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Q</objectName>
  <x>936</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00100000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.86000001</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>936</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{5abfb4cd-2218-4363-a7e0-f43b4c819815}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>HQ</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>890</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{bc0b9512-a1a1-4bd2-a30f-a704c2713dc7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>H Cut</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Cut</objectName>
  <x>890</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>20.00000000</minimum>
  <maximum>6000.00000000</maximum>
  <value>5153.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Cut</objectName>
  <x>890</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{5aa4297c-73e9-4061-aad1-ea9a207a88da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>20.00000000</minimum>
  <maximum>6000.00000000</maximum>
  <value>2599.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>890</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{d62dc552-e86a-43ae-87c9-952068396d7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>L Cut</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1028</x>
  <y>266</y>
  <width>45</width>
  <height>25</height>
  <uuid>{bd84302b-08e0-4ba7-9f1b-4f383825b73c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>H Dop</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Doppler</objectName>
  <x>1028</x>
  <y>224</y>
  <width>45</width>
  <height>45</height>
  <uuid>{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.23000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Doppler</objectName>
  <x>1028</x>
  <y>292</y>
  <width>45</width>
  <height>45</height>
  <uuid>{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.17000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1028</x>
  <y>334</y>
  <width>45</width>
  <height>25</height>
  <uuid>{8a9216db-363e-4b0c-89d9-142bc17ff079}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>L Dop</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>272</x>
  <y>403</y>
  <width>150</width>
  <height>28</height>
  <uuid>{bf57cb88-d70b-4d7e-bf50-6cdb90dac47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Slow / Fast Rot</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBController" version="2">
  <objectName>Slow_Fast_Rot</objectName>
  <x>184</x>
  <y>388</y>
  <width>319</width>
  <height>16</height>
  <uuid>{b857d620-2b70-47b3-b492-538619494684}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.51999998</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>520</x>
  <y>360</y>
  <width>54</width>
  <height>25</height>
  <uuid>{10859dab-c112-439e-ae01-9f8be5a2ea81}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Split</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>Split</objectName>
  <x>522</x>
  <y>334</y>
  <width>50</width>
  <height>20</height>
  <uuid>{30a14c00-dbaf-4433-9200-0c7d4361ebac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <color>
   <r>75</r>
   <g>37</g>
   <b>16</b>
  </color>
  <bgcolor mode="background">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>128</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Main_Vol</objectName>
  <x>582</x>
  <y>314</y>
  <width>60</width>
  <height>60</height>
  <uuid>{7dae00b2-bec2-491f-85f6-6aa83f119dd5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>582</x>
  <y>373</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5831dd19-ad8a-4d7a-ac44-9f17a5375f68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Main Vol</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Rev</objectName>
  <x>453</x>
  <y>320</y>
  <width>45</width>
  <height>45</height>
  <uuid>{1d360c47-eb02-4897-ac50-6f90034d7c6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>449</x>
  <y>360</y>
  <width>54</width>
  <height>24</height>
  <uuid>{2576af13-bde9-4dd5-a97d-a494a6e53909}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Rev</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>290</x>
  <y>360</y>
  <width>54</width>
  <height>24</height>
  <uuid>{45c2e010-68bb-4c7d-8a32-1be29b79e87b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Dist</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Dist</objectName>
  <x>295</x>
  <y>320</y>
  <width>45</width>
  <height>45</height>
  <uuid>{4efcd795-31b5-4fe3-b3d1-8272af90e321}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.64999998</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Scan</objectName>
  <x>241</x>
  <y>320</y>
  <width>45</width>
  <height>45</height>
  <uuid>{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000001</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>237</x>
  <y>360</y>
  <width>54</width>
  <height>24</height>
  <uuid>{cb217849-25d6-4e21-b05b-d16f275a0405}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Scan</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>396</x>
  <y>360</y>
  <width>54</width>
  <height>24</height>
  <uuid>{cbcf72e2-d836-4b98-8f0a-56fce616b886}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Del</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Del</objectName>
  <x>401</x>
  <y>320</y>
  <width>45</width>
  <height>45</height>
  <uuid>{5091b6d6-bb33-431d-8a35-178b7763f444}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.15000001</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Rot</objectName>
  <x>348</x>
  <y>320</y>
  <width>45</width>
  <height>45</height>
  <uuid>{9649693a-0bc8-4bdb-8643-e3c168c61ba8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>343</x>
  <y>360</y>
  <width>54</width>
  <height>24</height>
  <uuid>{d5baace4-0eb4-4937-a78c-ab8206c64bb4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Rot</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>115</x>
  <y>384</y>
  <width>54</width>
  <height>24</height>
  <uuid>{43acaa67-0873-4a73-947e-246b5ee00c8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Mix</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Mix</objectName>
  <x>119</x>
  <y>344</y>
  <width>45</width>
  <height>45</height>
  <uuid>{9109801a-4542-4afb-b178-35d53da78265}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>PreEff</objectName>
  <x>189</x>
  <y>320</y>
  <width>45</width>
  <height>45</height>
  <uuid>{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00100000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.99500000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>184</x>
  <y>360</y>
  <width>54</width>
  <height>24</height>
  <uuid>{f91b5222-7bc4-42f8-8e1d-2c418220112b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Pre Eff</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>384</y>
  <width>54</width>
  <height>40</height>
  <uuid>{61638fe0-00b1-4d1d-988c-af2244e5c799}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Master Tune</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>Master_Tune</objectName>
  <x>13</x>
  <y>344</y>
  <width>45</width>
  <height>45</height>
  <uuid>{c45d38a2-d323-4bac-a797-f644405b8f17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.94400000</minimum>
  <maximum>1.05900000</maximum>
  <value>1.00000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Det_L</objectName>
  <x>66</x>
  <y>344</y>
  <width>45</width>
  <height>45</height>
  <uuid>{3eb1737c-3615-460b-9f9c-d7ad040b926c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.99000000</minimum>
  <maximum>1.01000000</maximum>
  <value>0.99500000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>62</x>
  <y>384</y>
  <width>54</width>
  <height>24</height>
  <uuid>{695c5d44-6846-4f76-a407-2c1fdd7055fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Det L</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>330</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{d90d1c8d-b831-4767-9d36-b096d7180a4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_16ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>353</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{9e85d9ae-6015-4903-ad8f-43cec1860b6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_8ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>376</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_5_13ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>399</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{5a76d789-df79-42b1-aa4e-d41055b6193f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_4ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>422</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{de7259ae-3233-4d74-a178-6f3b5982c4ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_2_23ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>445</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{539c687e-f75a-472f-8363-45e500210800}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_2ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>468</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{b6a6250e-6be9-4720-b764-3474d71417db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_1_35ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>491</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_1_23ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>514</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{a5cc3c82-71f7-4333-a558-b604081908dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>H_1ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Attack</objectName>
  <x>537</x>
  <y>44</y>
  <width>45</width>
  <height>45</height>
  <uuid>{9779e251-8c30-49f3-a90e-d5fd3c2d765e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00100000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.10000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>530</x>
  <y>84</y>
  <width>60</width>
  <height>24</height>
  <uuid>{c269c3b4-6b45-4c43-9272-54cb55aa07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Attack</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>530</x>
  <y>154</y>
  <width>60</width>
  <height>24</height>
  <uuid>{0f4c0680-4af5-4d75-86ea-f17e9e110661}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Leak</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Leak</objectName>
  <x>537</x>
  <y>114</y>
  <width>45</width>
  <height>45</height>
  <uuid>{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.05000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>530</x>
  <y>224</y>
  <width>60</width>
  <height>24</height>
  <uuid>{9e374068-25d7-459f-9e97-0b8cb7b2769e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Level</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Level</objectName>
  <x>537</x>
  <y>184</y>
  <width>45</width>
  <height>45</height>
  <uuid>{9dff87ee-af44-4f32-8e9a-01b5e1f18213}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Perc_lvl</objectName>
  <x>595</x>
  <y>184</y>
  <width>45</width>
  <height>45</height>
  <uuid>{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>588</x>
  <y>224</y>
  <width>60</width>
  <height>24</height>
  <uuid>{49f20846-37c3-4e0e-abe9-2e55f0eaeedf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Perc</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>588</x>
  <y>154</y>
  <width>60</width>
  <height>24</height>
  <uuid>{9bdd9003-c791-4de3-a4fa-d183afa4ea53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>2nd / 3rd</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>588</x>
  <y>84</y>
  <width>60</width>
  <height>24</height>
  <uuid>{7d707afc-3324-43df-a9dc-5425baee793d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Decay</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>H_Dec</objectName>
  <x>595</x>
  <y>44</y>
  <width>45</width>
  <height>45</height>
  <uuid>{b772e106-c439-431a-a0ec-9c2b5e3cee30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>H_Harm</objectName>
  <x>597</x>
  <y>128</y>
  <width>40</width>
  <height>20</height>
  <uuid>{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <color>
   <r>75</r>
   <g>37</g>
   <b>16</b>
  </color>
  <bgcolor mode="background">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>2</minimum>
  <maximum>3</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>324</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{c455ca61-649c-46f2-b939-3159650ed392}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>16</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>348</x>
  <y>244</y>
  <width>25</width>
  <height>25</height>
  <uuid>{14c5961d-fa26-4e39-a438-47102198ddb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>8</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>394</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{b8e36dbe-c5a5-4408-95fe-45cb2b3c114c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>4</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>372</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{659681d9-0b97-47c0-b1e1-f1278e80c675}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 5
1/3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>464</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{4ba8ecc4-0439-44cc-9d55-320018eb306f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 1
3/5</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>486</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{97e7da92-0789-4244-beb3-d16956f9ce10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 1
1/3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>441</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{f323691a-4943-43aa-b961-9d369530ba4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>2</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>418</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{023ebff0-14e3-483c-b4c8-5574e21d6739}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 2
2/3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>510</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{65effc6a-ada8-4b41-9248-de6c0a3a157d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>401</x>
  <y>274</y>
  <width>131</width>
  <height>26</height>
  <uuid>{3af04d9b-568e-441e-b946-fda5990d2f62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Upper Drawbars</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>H_Oct</objectName>
  <x>328</x>
  <y>276</y>
  <width>40</width>
  <height>20</height>
  <uuid>{1a4bcc5a-5252-4610-8e27-8c61de18da4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>75</r>
   <g>37</g>
   <b>16</b>
  </color>
  <bgcolor mode="background">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>3</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>365</x>
  <y>276</y>
  <width>35</width>
  <height>25</height>
  <uuid>{98b1a73b-e772-4070-b649-471de4eb86bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Oct</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>48</x>
  <y>276</y>
  <width>35</width>
  <height>25</height>
  <uuid>{46f3fa94-5429-4e84-961a-1e1379fa70d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Oct</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>L_Oct</objectName>
  <x>11</x>
  <y>276</y>
  <width>40</width>
  <height>20</height>
  <uuid>{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>75</r>
   <g>37</g>
   <b>16</b>
  </color>
  <bgcolor mode="background">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>3</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>84</x>
  <y>274</y>
  <width>131</width>
  <height>26</height>
  <uuid>{62459cbe-d814-4f3b-9241-0b4044f471da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Lower Drawbars</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>193</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{5d0834fa-7a82-445f-b864-df96d3e92616}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>101</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{22dddc81-02fb-4285-aac4-ea66a62f557d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 2
2/3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>124</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{30a7b069-ba7e-40f7-8dbd-1b1648486fb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>2</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>169</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{ff29d785-e9c7-430d-86b9-334607c2928b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 1
1/3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>147</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{833b766c-cd53-4808-ba1f-07d5f01a4857}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 1
3/5</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>55</x>
  <y>244</y>
  <width>25</width>
  <height>35</height>
  <uuid>{2da6af72-b15f-4b44-8e49-6d5cd0d4b217}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> 5
1/3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>77</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{eb38a6ad-d1e9-4408-a6a2-10b2347531e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>4</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>31</x>
  <y>244</y>
  <width>25</width>
  <height>20</height>
  <uuid>{24d17df1-7aac-45a7-a98f-fe6769812d74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>8</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>244</y>
  <width>25</width>
  <height>24</height>
  <uuid>{3f445cd2-e727-4f7d-bb72-c74b7b7edb94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>16</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>L_Harm</objectName>
  <x>279</x>
  <y>128</y>
  <width>40</width>
  <height>20</height>
  <uuid>{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <color>
   <r>75</r>
   <g>37</g>
   <b>16</b>
  </color>
  <bgcolor mode="background">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>2</minimum>
  <maximum>3</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Dec</objectName>
  <x>277</x>
  <y>44</y>
  <width>45</width>
  <height>45</height>
  <uuid>{15b3c085-2ff5-44ce-a0a1-aa002e569658}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>270</x>
  <y>84</y>
  <width>60</width>
  <height>24</height>
  <uuid>{07658d3f-8e03-4af9-bdbe-5499a83543a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Decay</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>270</x>
  <y>154</y>
  <width>60</width>
  <height>24</height>
  <uuid>{452bf16c-c33c-4e9f-bc5c-396fb41be262}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>2nd / 3rd</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>270</x>
  <y>224</y>
  <width>60</width>
  <height>24</height>
  <uuid>{1fc90d60-15dd-4ae5-84e6-177c1f7cdee4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Perc</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Perc_lvl</objectName>
  <x>277</x>
  <y>184</y>
  <width>45</width>
  <height>45</height>
  <uuid>{e4020b31-cbe3-4748-b9be-d2f576e66e26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Level</objectName>
  <x>220</x>
  <y>184</y>
  <width>45</width>
  <height>45</height>
  <uuid>{dadf0ab2-230b-4705-8045-4f4e05ded4bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>213</x>
  <y>224</y>
  <width>60</width>
  <height>24</height>
  <uuid>{48eb2d7a-60d3-497f-bde6-3533dae17c55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Level</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Leak</objectName>
  <x>220</x>
  <y>114</y>
  <width>45</width>
  <height>45</height>
  <uuid>{6f149edd-ce76-49d7-97fd-618ec37caebf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.05000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>213</x>
  <y>154</y>
  <width>60</width>
  <height>24</height>
  <uuid>{8a4c7ff0-a8f3-4f89-b2f0-a1054b2dace2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Leak</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>213</x>
  <y>84</y>
  <width>60</width>
  <height>24</height>
  <uuid>{d316f389-3d06-4ddb-b32b-e7fac075d342}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Attack</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>L_Attack</objectName>
  <x>220</x>
  <y>44</y>
  <width>45</width>
  <height>45</height>
  <uuid>{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00100000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.10000000</value>
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
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>197</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{bd531a5d-8ba1-4d8d-baee-459264eeebd7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_1ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>174</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{3c4c1c03-ce64-4181-8a47-11a4ee257f21}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_1_23ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>151</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{a4464103-db31-436c-9569-1513180460d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_1_35ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>128</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{1a04acf0-e986-426b-bfc4-02edf11103f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_2ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>105</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{be6d8121-449e-49e7-acbc-ccfb44d4b741}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_2_23ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>82</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{ae39e4aa-3778-4132-83ad-19459fcfb876}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_4ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>59</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{8245fc61-f8cf-4baa-a707-d30a4f806b7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_5_13ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>36</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{4f50eed9-d322-487a-bf1c-d5ca60760050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>L_8ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>13</x>
  <y>44</y>
  <width>16</width>
  <height>200</height>
  <uuid>{265cd469-08ad-4306-ae64-efbea12df390}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>L_16ft_lvl</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>654</x>
  <y>377</y>
  <width>426</width>
  <height>57</height>
  <uuid>{b0fccdd2-2481-4924-8680-efc787131c50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>P_Display</objectName>
  <x>675</x>
  <y>400</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a35092a1-5ea8-47f2-a8dc-76ed63e66215}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.170</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>56</r>
   <g>27</g>
   <b>11</b>
  </color>
  <bgcolor mode="background">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>950</x>
  <y>400</y>
  <width>60</width>
  <height>25</height>
  <uuid>{1caec808-8af1-41d9-bf7c-ee44b114e06a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Stop</objectName>
  <x>1012</x>
  <y>400</y>
  <width>60</width>
  <height>25</height>
  <uuid>{41279448-5551-40e3-b866-09a59f536ae1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>_SetPresetIndex</objectName>
  <x>781</x>
  <y>400</y>
  <width>150</width>
  <height>25</height>
  <uuid>{fcff35be-96c2-418f-8e79-ecae149d9e16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Organ1</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ2</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ3</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ4</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ5</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ6</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ7</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ8</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ9</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ10</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Organ11</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Free</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Free</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>670</x>
  <y>376</y>
  <width>98</width>
  <height>27</height>
  <uuid>{908af92b-6404-4adf-97f4-096bcc732801}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Param value</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>780</x>
  <y>376</y>
  <width>61</width>
  <height>27</height>
  <uuid>{dde2fb34-f23c-4abd-94e2-2bc312b74300}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Presets</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </color>
  <bgcolor mode="nobackground">
   <r>241</r>
   <g>226</g>
   <b>185</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>954</x>
  <y>408</y>
  <width>10</width>
  <height>10</height>
  <uuid>{3c3da0e6-3ac9-4699-8fb0-78eed2f2755d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>Csound_On</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>-1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="Organ 1" number="0" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >0.89999998</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.99500000</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.10000000</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >1.00000000</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >1000.00000000</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >0.10000000</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.12500000</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.50000000</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >9.72999954</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >7.42999983</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.00000000</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.00000000</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.00000000</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.51999998</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.51999998</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >1.00000000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.20000000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.64999998</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.30000001</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.15000001</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.50000000</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.50000000</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >0.99500000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.50000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.50000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >0.50000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.50000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.50000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.50000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.50000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.50000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.50000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.10000000</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.05000000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.50000000</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.50000000</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.50000000</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >2.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >1.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.50000000</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.50000000</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.50000000</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.05000000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.10000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.50000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.50000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.50000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.50000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.50000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.50000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >0.50000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >0.50000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >0.50000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >1.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >1.000</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >0.00000000</value>
</preset>
<preset name="Organ 2" number="1" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.99500000</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.63800001</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >2.33178997</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >3998.32006836</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >2.71070004</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.16179299</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >3.81299996</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >4.91200018</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.23999023</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.50976563</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.20996094</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.25470999</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.47000000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.01500000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.64899999</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.12200000</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.50000000</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.71899998</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.98629999</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.98629999</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.41780001</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.25342500</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00196750</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01100000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.66299999</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.16800000</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.17665701</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >3.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >1.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.13139801</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.25299999</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.51099998</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.05000000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00204523</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.19178000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >1.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >0.98629999</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.47000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.470</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >1.00000000</value>
</preset>
<preset name="Organ 3" number="2" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.99500000</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.53799999</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >2.01300001</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >3999.10009766</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >0.80900002</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.09320000</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >9.72999954</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >7.42999983</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.23999023</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.50976563</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.20996094</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.51999998</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.66700000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.12600000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.81000000</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.89999998</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.02500000</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.84399998</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >0.99500000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.98629999</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.97939998</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >0.99315101</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.41780001</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00100000</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01100000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.47799999</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.34500000</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.06978000</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >3.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >2.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >0.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.50000000</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.50000000</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.57499999</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.05000000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00700000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >1.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >1.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.17000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.170</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >1.00000000</value>
</preset>
<preset name="Organ 4" number="3" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.99500000</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.63800001</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >2.33179998</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >3998.30004883</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >2.71070004</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.16179000</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >3.81299996</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >4.91200018</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.23999023</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.50976563</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.20996094</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.25470999</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.76400000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.01500000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.64899999</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.12200000</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.50000000</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.71899998</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00300002</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.98629999</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.98629999</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.41780001</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.25342500</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00196700</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01100000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.66299999</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.16800000</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.17665000</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >3.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >1.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.13140000</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.25299999</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.51099998</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.05000000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00204520</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.19178000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >1.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >0.98629999</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.17000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.170</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >2.00000000</value>
</preset>
<preset name="Organ 5" number="4" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.11599994</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05900000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.57349998</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.78899997</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >4.16363001</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >545.20001221</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >1.75326002</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.16179299</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.10000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >1.50999999</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >3.17100000</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.23999023</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.38699999</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >0.73500001</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.50976563</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.20996094</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.61600000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.50000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.12264000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.56900001</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.01500000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.10700000</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.88999999</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.10500000</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.71899998</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.98629999</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.98629999</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >1.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00196700</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01100000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.66299999</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.59200001</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.52195001</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >3.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >2.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >1.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.13140000</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.25299999</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.51099998</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.05000000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00204520</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.19178100</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.94520497</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.36301401</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >0.41780001</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >0.39726001</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >0.98629999</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.50000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.500</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >2.00000000</value>
</preset>
<preset name="Organ 6" number="5" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.52456999</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.11599994</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.03000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.35375899</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.22300000</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >4.16363001</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >2653.12011719</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >0.96536201</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.16179299</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.10000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >2.48900008</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >13.66199970</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >9.58500004</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >1.90499997</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.47998047</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.76200002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >0.73500001</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.00518000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.00853000</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >247.46600342</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >165.46200562</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.11600000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.11400000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.50943398</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.88800001</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.01500000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.10700000</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.68500000</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.54799998</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.71899998</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00100005</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.98629999</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.98629999</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >1.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00151170</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01100000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.88300002</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.30599999</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.24154000</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >3.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >2.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >3.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.02205100</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.26499999</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.51099998</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.05000000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00137380</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >1.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >1.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >0.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.11400000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.114</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >4.00000000</value>
</preset>
<preset name="Organ 7" number="6" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.52456999</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.11599994</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.28287801</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.04400000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.12650000</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.01000000</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >3.20674992</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >1669.15002441</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >0.96536201</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.16179299</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.85900003</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.57099998</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.10000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.20000000</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >4.20300007</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.28287801</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >2.36500001</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >4.07600021</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >1.90499997</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.87400001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.77100003</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >489.51000977</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >0.21400000</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.76200002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >0.73500001</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.00518000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.00853000</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >247.47000122</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >165.46200562</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.07000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.05100000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.28287801</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.09433960</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.47999999</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.12600000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.36000001</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >1.00000000</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.05200000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.99000001</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >1.00000000</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00399995</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >1.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >1.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >1.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >1.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >1.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >1.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >1.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >1.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00151170</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.08200000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.88300002</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.82999998</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.24154000</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >2.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >2.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.13139801</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.74299997</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.51099998</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.08100000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00137380</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >1.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >1.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >1.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >1.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >1.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.47999999</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.480</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >5.00000000</value>
</preset>
<preset name="Organ 8" number="7" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.99500000</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.01000000</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >1.10099995</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >2761.38989258</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >1.64804006</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.09320970</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >9.72999954</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >7.42999983</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.16003418</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.33984375</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.13989258</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.86792499</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >1.00000000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.00000000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.42899999</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.00000000</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.32400000</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.39500001</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00300002</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.98629999</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.00684932</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00684932</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00400000</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.05900000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.06900000</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.90600002</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.18197601</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >2.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >0.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.02466270</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.61900002</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.09800000</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.07700000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00709850</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >1.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >0.15753400</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >1.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >1.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >1.000</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >6.00000000</value>
</preset>
<preset name="Organ 9" number="8" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.99500000</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.01000000</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >1.10099995</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >2760.88989258</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >1.64804006</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.09320970</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >9.72999954</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >7.42999983</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.16003418</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.33984375</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.13989258</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.86792499</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >0.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.66700000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.00000000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.00000000</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.00000000</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.00000000</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.71600002</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00199997</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >1.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >1.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.00684932</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >1.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00684932</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00400000</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01200000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.47099999</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.00000000</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.18197601</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >2.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >1.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.02466270</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.00000000</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.52200001</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.00400000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00709850</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.26712301</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.47260299</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.69178098</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.55479503</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >0.84931499</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >0.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.17000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.170</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >0.00000000</value>
</preset>
<preset name="Organ 10" number="9" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.18028501</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.01000000</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >2.93456006</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >2760.88989258</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >1.64804006</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.09320970</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >9.72999954</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >7.42999983</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.16003418</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.33984375</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.13989258</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.60377401</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >59.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.81000000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.00000000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.84500003</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.61900002</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.37599999</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.71600002</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00199997</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >1.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >1.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >1.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >1.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00684900</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.78082198</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.00000000</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00400000</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01200000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.33000001</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.65499997</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >0.18197601</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >3.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >1.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >0.02466270</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.65499997</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.37700000</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.00400000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00709850</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >1.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >1.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >1.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.17000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.170</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >5.00000000</value>
</preset>
<preset name="Organ 11" number="10" >
<value id="{941145af-5130-494b-bd18-6afb7f1daea6}" mode="1" >-1.00000000</value>
<value id="{8772001c-4803-427f-8e97-da0278383e78}" mode="1" >1.20000005</value>
<value id="{900de65b-4cb0-43e0-8be8-9bdf383f1da6}" mode="1" >2.29999995</value>
<value id="{88f52924-3c7b-45a0-b2fc-8b8b88bc8605}" mode="1" >0.30000001</value>
<value id="{e050cd68-6a1c-46c7-aeca-056ca8903edd}" mode="1" >0.05000000</value>
<value id="{22710c60-83fe-49c8-85bd-48b4e83d24a7}" mode="1" >0.18028501</value>
<value id="{607df0cb-5c71-4b28-87ef-48b4db04e0c2}" mode="1" >0.01000000</value>
<value id="{94e78f6e-9647-4b29-b42e-12392d43d243}" mode="1" >2.93456006</value>
<value id="{b29f025c-3961-4556-a99d-f4f0ba79a812}" mode="1" >2760.88989258</value>
<value id="{ec0bc92d-8e83-49c2-9e49-9b8c9d819dee}" mode="1" >1.64804006</value>
<value id="{91421fab-60e7-4d9a-b74c-066e72306a2f}" mode="1" >0.09320970</value>
<value id="{123e0436-9770-41ef-a9e3-555144e8e8b4}" mode="1" >-0.80299997</value>
<value id="{5dd4fde8-c1d6-4e99-b04a-ed88401d2da3}" mode="1" >0.20000000</value>
<value id="{a105b464-1a7a-447d-b639-001eeaae053c}" mode="1" >0.16000000</value>
<value id="{d6d78f07-18b2-417d-a47b-82c7d718928d}" mode="1" >0.33000001</value>
<value id="{82ef0d5f-c09c-4a12-aaad-62491c7b5706}" mode="1" >1.50000000</value>
<value id="{05c3e194-a578-4515-84f8-16ec034702d7}" mode="1" >0.30000001</value>
<value id="{454cf4a2-3d00-4b97-8c64-06e1bb3357c8}" mode="1" >9.72999954</value>
<value id="{5fff4d8a-9353-41c9-b4af-d5a97f382dc0}" mode="1" >7.42999983</value>
<value id="{55ac001c-2fb5-49c0-9b97-f03b4d9c5b31}" mode="1" >0.10000000</value>
<value id="{bd86f11d-2385-4aa6-9f38-a42629e1f5a9}" mode="1" >0.11000000</value>
<value id="{5f18ed65-974d-413e-bfda-fc86e33d1a28}" mode="1" >0.27000001</value>
<value id="{c9e38516-b219-4fb4-bb80-acf1ac41f839}" mode="1" >0.20999999</value>
<value id="{2f5bc266-3ed7-4e8a-aaa3-409e35b3c3c1}" mode="1" >1638.16003418</value>
<value id="{890e82a9-c10e-49c9-9764-300800695570}" mode="1" >1.72000003</value>
<value id="{c4921c07-6725-444d-b0a4-5df427d7b3fb}" mode="1" >0.92000002</value>
<value id="{de3c486b-90d7-453f-9dbc-a0fe0480e62f}" mode="1" >1.00000000</value>
<value id="{e2f90086-0c79-466d-90df-408dfaa9cf79}" mode="1" >0.87000000</value>
<value id="{8d69d49c-21b6-461b-8e8a-ead8fa86a01c}" mode="1" >0.86000001</value>
<value id="{ce5d6e24-3711-48fe-8b4e-f7ecee2bfc5f}" mode="1" >5153.33984375</value>
<value id="{5aa4297c-73e9-4061-aad1-ea9a207a88da}" mode="1" >2599.13989258</value>
<value id="{86bdd436-a0f5-4b3c-9dea-cf5c0ec7c7eb}" mode="1" >0.23000000</value>
<value id="{9eb1d2b3-d4ff-4fd6-be6d-b47736f35563}" mode="1" >0.17000000</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="1" >0.30000001</value>
<value id="{33af5ea3-d9c4-4c49-91cc-53f9d5a4cb9c}" mode="2" >0.00000000</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="1" >0.84905702</value>
<value id="{b857d620-2b70-47b3-b492-538619494684}" mode="2" >0.00000000</value>
<value id="{30a14c00-dbaf-4433-9200-0c7d4361ebac}" mode="1" >59.00000000</value>
<value id="{7dae00b2-bec2-491f-85f6-6aa83f119dd5}" mode="1" >0.81000000</value>
<value id="{1d360c47-eb02-4897-ac50-6f90034d7c6d}" mode="1" >0.00000000</value>
<value id="{4efcd795-31b5-4fe3-b3d1-8272af90e321}" mode="1" >0.84500003</value>
<value id="{8dd9a7b7-5ad4-4f56-89ba-dd7b6fb28173}" mode="1" >0.61900002</value>
<value id="{5091b6d6-bb33-431d-8a35-178b7763f444}" mode="1" >0.00000000</value>
<value id="{9649693a-0bc8-4bdb-8643-e3c168c61ba8}" mode="1" >0.37599999</value>
<value id="{9109801a-4542-4afb-b178-35d53da78265}" mode="1" >0.71600002</value>
<value id="{6a9e5a11-fd1e-4206-a2e2-98562f8c1b1f}" mode="1" >0.99500000</value>
<value id="{c45d38a2-d323-4bac-a797-f644405b8f17}" mode="1" >1.00000000</value>
<value id="{3eb1737c-3615-460b-9f9c-d7ad040b926c}" mode="1" >1.00199997</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="1" >0.00000000</value>
<value id="{d90d1c8d-b831-4767-9d36-b096d7180a4a}" mode="2" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="1" >0.00000000</value>
<value id="{9e85d9ae-6015-4903-ad8f-43cec1860b6f}" mode="2" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="1" >0.00000000</value>
<value id="{46cbb6bb-adee-4bb8-bb76-b8bb263690a4}" mode="2" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="1" >0.00000000</value>
<value id="{5a76d789-df79-42b1-aa4e-d41055b6193f}" mode="2" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="1" >0.00000000</value>
<value id="{de7259ae-3233-4d74-a178-6f3b5982c4ae}" mode="2" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="1" >0.00000000</value>
<value id="{539c687e-f75a-472f-8363-45e500210800}" mode="2" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="1" >0.00000000</value>
<value id="{b6a6250e-6be9-4720-b764-3474d71417db}" mode="2" >0.00684900</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="1" >0.00000000</value>
<value id="{8063b633-d09e-40bb-a0ee-1d0a2ae85e04}" mode="2" >0.78082198</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="1" >0.00000000</value>
<value id="{a5cc3c82-71f7-4333-a558-b604081908dc}" mode="2" >0.93835598</value>
<value id="{9779e251-8c30-49f3-a90e-d5fd3c2d765e}" mode="1" >0.00400000</value>
<value id="{62f3ce4a-72bc-4cc6-a8d2-9de625e8b565}" mode="1" >0.01200000</value>
<value id="{9dff87ee-af44-4f32-8e9a-01b5e1f18213}" mode="1" >0.33000001</value>
<value id="{3af8bdb1-45be-4cef-9b3f-79e3ef2d3069}" mode="1" >0.32699999</value>
<value id="{b772e106-c439-431a-a0ec-9c2b5e3cee30}" mode="1" >1.50717998</value>
<value id="{0edff3b6-bc4c-4b0b-ae9a-42c4a81c94de}" mode="1" >3.00000000</value>
<value id="{1a4bcc5a-5252-4610-8e27-8c61de18da4c}" mode="1" >1.00000000</value>
<value id="{b1d7e878-e675-47b9-93f4-b2b82ad00ebe}" mode="1" >1.00000000</value>
<value id="{9b4768a8-6295-4cb4-81aa-7e6739ed8ab3}" mode="1" >2.00000000</value>
<value id="{15b3c085-2ff5-44ce-a0a1-aa002e569658}" mode="1" >1.43292999</value>
<value id="{e4020b31-cbe3-4748-b9be-d2f576e66e26}" mode="1" >0.65499997</value>
<value id="{dadf0ab2-230b-4705-8045-4f4e05ded4bb}" mode="1" >0.37700000</value>
<value id="{6f149edd-ce76-49d7-97fd-618ec37caebf}" mode="1" >0.00400000</value>
<value id="{fe8b1a3b-c72b-441d-be08-c68b2fe08c80}" mode="1" >0.00709850</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="1" >0.00000000</value>
<value id="{bd531a5d-8ba1-4d8d-baee-459264eeebd7}" mode="2" >1.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="1" >0.00000000</value>
<value id="{3c4c1c03-ce64-4181-8a47-11a4ee257f21}" mode="2" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="1" >0.00000000</value>
<value id="{a4464103-db31-436c-9569-1513180460d1}" mode="2" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="1" >0.00000000</value>
<value id="{1a04acf0-e986-426b-bfc4-02edf11103f8}" mode="2" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="1" >0.00000000</value>
<value id="{be6d8121-449e-49e7-acbc-ccfb44d4b741}" mode="2" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="1" >0.00000000</value>
<value id="{ae39e4aa-3778-4132-83ad-19459fcfb876}" mode="2" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="1" >0.00000000</value>
<value id="{8245fc61-f8cf-4baa-a707-d30a4f806b7b}" mode="2" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="1" >0.00000000</value>
<value id="{4f50eed9-d322-487a-bf1c-d5ca60760050}" mode="2" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="1" >0.00000000</value>
<value id="{265cd469-08ad-4306-ae64-efbea12df390}" mode="2" >0.00000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="1" >0.17000000</value>
<value id="{a35092a1-5ea8-47f2-a8dc-76ed63e66215}" mode="4" >0.170</value>
<value id="{1caec808-8af1-41d9-bf7c-ee44b114e06a}" mode="4" >0</value>
<value id="{41279448-5551-40e3-b866-09a59f536ae1}" mode="4" >0</value>
<value id="{fcff35be-96c2-418f-8e79-ecae149d9e16}" mode="1" >0.00000000</value>
</preset>
</bsbPresets>
