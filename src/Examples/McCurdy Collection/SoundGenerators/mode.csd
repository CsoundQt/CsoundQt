;Written by Iain McCurdy, 2010


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 32		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


			zakinit	3,3								;INITIALISE ZAK SPACE (3 A-RATE AND 3 K-RATE VARIABLES)
			massign	0,1								;ALL MIDI NOTES DIRECTED TO INSTRUMENT 1

gkQ			init		0.0

gisine		ftgen	0,0,131072,10,1					;FUNCTION TABLE THAT STORES A SINGLE CYCLE OF A SINE WAVE

;TABLES FOR EXP SLIDER
giExp1		ftgen	0, 0, 129, -25, 0, 20.0, 128, 5000.0
giExp2		ftgen	0, 0, 129, -25, 0, 10.0, 128, 10000.0
giExp3		ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0

;FUNCTION TABLES STORING MODAL FREQUENCY RATIOS===================================================================================================================================
;single
girtos1		ftgen	0,0,2, -2,	1,	1

;dahina
girtos2		ftgen	0,0,-6,-2,	1,	2.89,	4.95,	6.99,	8.01,	9.02

;banyan
girtos3		ftgen	0,0,-6,-2,	1, 	2.0, 	3.01, 	4.01, 	4.69, 	5.63

;xylophone
girtos4		ftgen	0,0,-6,-2,	1, 	3.932, 	9.538,	16.688,	24.566,	31.147

;tibetan bowl (180mm)
girtos5		ftgen	0,0,-7,-2,	1, 	2.77828,	5.18099, 	8.16289,	11.66063,	15.63801,	19.99

;spinel sphere with diameter of 3.6675mm
girtos6		ftgen	0,0,-24,-2,	1,	1.026513174725,	1.4224916858532,	1.4478690202098,	1.4661959580455,	1.499452545408,	1.7891839345101,	1.8768994627782,	1.9645945254541,	1.9786543873113,	2.0334612432847,	2.1452852391916,	2.1561524686621,	2.2533435661294,	2.2905090816065,	2.3331798413917,	2.4567715528268,	2.4925556408289,	2.5661806088514,	2.6055768738808,	2.6692760296751,	2.7140956766436,	2.7543617293425,	2.7710411870043 

;pot lid
girtos7		ftgen	0,0,-6,-2,	1, 	3.2, 	6.23, 	6.27, 	9.92, 	14.15

;red cedar wood plate
girtos8		ftgen	0,0,-4,-2,	1, 	1.47, 	2.09, 	2.56

;tubular bell
girtos9		ftgen	0,0,-10,-2,	272/437,	538/437,	874/437,	1281/437,	1755/437,	2264/437,	2813/437,	3389/437,	4822/437,	5255/437

;redwood wood plate
girtos10		ftgen	0,0,-4,-2,	1, 1.47, 2.11, 2.57

;douglas fir wood plate
girtos11		ftgen	0,0,-4,-2,	1, 1.42, 2.11, 2.47

;uniform wooden bar
girtos12		ftgen	0,0,-6,-2,	1, 2.572, 4.644, 6.984, 9.723, 12

;uniform aluminum bar
girtos13		ftgen	0,0,-6,-2,	1, 2.756, 5.423, 8.988, 13.448, 18.680

;vibraphone 1
girtos14		ftgen	0,0,-6,-2,	1, 3.984, 10.668, 17.979, 23.679, 33.642

;vibraphone 2
girtos15		ftgen	0,0,-6,-2,	1, 3.997, 9.469, 15.566, 20.863, 29.440

;Chalandi plates
girtos16		ftgen	0,0,-5,-2,	1, 1.72581, 5.80645, 7.41935, 13.91935

;tibetan bowl (152 mm)
girtos17		ftgen	0,0,-7,-2,	1, 2.66242, 4.83757, 7.51592, 10.64012, 14.21019, 18.14027

;tibetan bowl (140 mm)
girtos18		ftgen	0,0,-5,-2,	1, 2.76515, 5.12121, 7.80681, 10.78409

;wine glass
girtos19		ftgen	0,0,-5,-2,	1, 2.32, 4.25, 6.63, 9.38

;small handbell
girtos20		ftgen	0,0,-22,-2,	1, 1.0019054878049, 1.7936737804878, 1.8009908536585, 2.5201981707317, 2.5224085365854, 2.9907012195122, 2.9940548780488, 3.7855182926829, 3.8061737804878, 4.5689024390244, 4.5754573170732, 5.0296493902439, 5.0455030487805, 6.0759908536585, 5.9094512195122, 6.4124237804878, 6.4430640243902, 7.0826219512195, 7.0923780487805, 7.3188262195122, 7.5551829268293 

;user definable
girtos21		ftgen	0,0,-24,-2,	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24

;TABLE OF SCALING FACTORS FOR INDIVIDUAL Q VALUES
giQs			ftgen	0,0,-24,-2,	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
;TABLE OF SCALING FACTORS FOR INDIVIDUAL AMP VALUES
giAmps		ftgen	0,0,-24,-2,	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1


;TECHNIQUE OF ITERATION WITHIN A UDO WAS INSPIRED BY STEVEN YI'S ARTICLE IN SUMMER 2006 CSOUND JOURNAL - THANKS STEVEN!
;USER DEFINED OPCODES=============================================================================================================================================================


opcode	modemodule, 0, akiii	;MODE UDO (K-RATE BASE FREQUENCY) - USED FOR NON-MIDI MODE 
	ain, kbase, icount, ialgfn, imodes  xin						;NAME INPUT VARIABLES
	krto		table	icount-1, ialgfn						;READ FREQUENCY RATIO FOR CURRENT MODE ACCORDING TO ITERATION COUNTER
	kfrq		=		krto * kbase							;DERIVE MODAL FREQUENCY FROM PRODUCT OF RATIO AND BASE FREQUENCY

	if	kfrq > 14000 || krto = 0	goto	SKIP						;LIMIT MODAL FREQUENCY UPPER LIMIT TO PREVENT EXPLOSIONS BY SKIPPING CODE IF MAXIMUM VALUE IS EXCEEDED (WITH A LITTLE HEADROOM)
		kQ		table	icount-1, giQs
		kAmp		table	icount-1, giAmps
		a1		mode		ain, kfrq, gkQ*kQ					;CREATE MODE SIGNAL
				zawm		a1*kAmp, 0						;MIX MODE SIGNAL INTO THE ACCUMULATING ZAK AUDIO CHANNEL 
		icount	=	icount + 1							;INCREMENT COUNTER IN PREPARTION FOR NEXT MODE
		if	icount <= imodes	then							;IF ALL THE MODES IN THIS CURRENT INSTRUMENT HAVE NOT YET BEEN CREATED...
			modemodule	ain, kbase, icount, ialgfn, imodes		;...CALL modemodule UDO AGAIN WITH INCREMENTED COUNTER
		endif											;END OF CONDITIONAL BRANCHING
	SKIP:												;LABEL 'SKIP'
endop													;END OF UDO

opcode	modemodulei, 0, aiiii	;MODE UDO (I-RATE BASE FREQUENCY) - USED FOR MIDI MODE 
	ain, ibase, icount, ialgfn, imodes  xin						;NAME INPUT VARIABLES
	irto		table	icount-1, ialgfn						;READ FREQUENCY RATIO FOR CURRENT MODE ACCORDING TO ITERATION COUNTER
	ifrq		=		irto * ibase							;DERIVE MODAL FREQUENCY FROM PRODUCT OF RATIO AND BASE FREQUENCY

	if	ifrq > 14000	goto	SKIP								;LIMIT MODAL FREQUENCY UPPER LIMIT TO PREVENT EXPLOSIONS BY SKIPPING CODE IF MAXIMUM VALUE IS EXCEEDED (WITH A LITTLE HEADROOM)
		a1		mode		ain, ifrq, gkQ						;CREATE MODE SIGNAL
				zawm		a1, 0							;MIX MODE SIGNAL INTO THE ACCUMULATING ZAK AUDIO CHANNEL 
		icount	=	icount + 1							;INCREMENT COUNTER IN PREPARTION FOR NEXT MODE
		if	icount <= imodes	then							;IF ALL THE MODES IN THIS CURRENT INSTRUMENT HAVE NOT YET BEEN CREATED...
			modemodulei	ain, ibase, icount, ialgfn, imodes		;...CALL modemodule UDO AGAIN WITH INCREMENTED COUNTER
		endif											;END OF CONDITIONAL BRANCHING
	SKIP:												;LABEL 'SKIP'
endop

opcode	dopplerUDO, aa, akkk	;DOPPLER UDO
	ain, krate, kDopDep, kPanDep  xin							;NAME INPUT VARIABLES
			setksmps	1									;CONTROL RATE WITHIN UDO IS 1
	ioffset	init		ksmps/sr								;DELAY OFFSET TIME
	adlt		oscil	kDopDep,krate,gisine					;MODULATING DELAY TIME
	kpan		oscil	kPanDep,krate,gisine					;MODULATING PANNING VARIABLE
	abuf		delayr	(0.01)+ioffset							;SET FOR MAXIMUM POSSIBLE DELAY TIME
	atap		deltap3	adlt+kDopDep+ioffset					;TAP THE DELAY BUFFER
			delayw	ain									;WRITE AUDIO INTO DELAY BUFFER
	a1,a2	pan2		atap, kpan + 0.5 + kPanDep				;PAN AUDIO FROM DELAY TAP
			xout		a1, a2								;SEND AUDIO TO CALLER INSTRUMENT
endop													;END OF UDO

opcode	reverbsr, aa, aakk		;REVERB UDO (USE OF A UDO FOR REVERB IS TO ALLOW THE SETTING OF A K-RATE INDEPENDENT OF THE GLOBAL K-RATE
				setksmps	1								;CONTROL RATE WITHIN UDO IS 1
	ainsigL, ainsigR, kfblvl, kfco	xin						;NAME INPUT VARIABLES
	arvbL, arvbR 	reverbsc	ainsigL, ainsigR, kfblvl, kfco		;USE reverbsc OPCODE
				xout		arvbL, arvbR						;SEND AUDIO TO CALLER INSTRUMENT
endop													;END OF UDO
;=================================================================================================================================================================================

instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkinput	invalue	"Input"
		gksound	invalue	"Sound"
		gkmodes	invalue	"Modes"
		gkDopOn	invalue	"Doppler"

		;MODAL FREQUENCY RATIO INPUT BOXES FOR USER DEFINABLE ALGORITHM (ALGORITHM 21)
		gkrto1	invalue	"Ratio01"
		gkrto2	invalue	"Ratio02"
		gkrto3	invalue	"Ratio03"
		gkrto4	invalue	"Ratio04"
		gkrto5	invalue	"Ratio05"
		gkrto6	invalue	"Ratio06"
		gkrto7	invalue	"Ratio07"
		gkrto8	invalue	"Ratio08"
		gkrto9	invalue	"Ratio09"
		gkrto10	invalue	"Ratio10"
		gkrto11	invalue	"Ratio11"
		gkrto12	invalue	"Ratio12"
		gkrto13	invalue	"Ratio13"
		gkrto14	invalue	"Ratio14"
		gkrto15	invalue	"Ratio15"
		gkrto16	invalue	"Ratio16"
		gkrto17	invalue	"Ratio17"
		gkrto18	invalue	"Ratio18"
		gkrto19	invalue	"Ratio19"
		gkrto20	invalue	"Ratio20"
		gkrto21	invalue	"Ratio21"
		gkrto22	invalue	"Ratio22"
		gkrto23	invalue	"Ratio23"
		gkrto24	invalue	"Ratio24"

		gkrto1	=	gkrto1 * 0.01
		gkrto2	=	gkrto2 * 0.01
		gkrto3	=	gkrto3 * 0.01
		gkrto4	=	gkrto4 * 0.01
		gkrto5	=	gkrto5 * 0.01
		gkrto6	=	gkrto6 * 0.01
		gkrto7	=	gkrto7 * 0.01
		gkrto8	=	gkrto8 * 0.01
		gkrto9	=	gkrto9 * 0.01
		gkrto10	=	gkrto10 * 0.01
		gkrto11	=	gkrto11 * 0.01
		gkrto12	=	gkrto12 * 0.01
		gkrto13	=	gkrto13 * 0.01
		gkrto14	=	gkrto14 * 0.01
		gkrto15	=	gkrto15 * 0.01
		gkrto16	=	gkrto16 * 0.01
		gkrto17	=	gkrto17 * 0.01
		gkrto18	=	gkrto18 * 0.01
		gkrto19	=	gkrto19 * 0.01
		gkrto20	=	gkrto20 * 0.01
		gkrto21	=	gkrto21 * 0.01
		gkrto22	=	gkrto22 * 0.01
		gkrto23	=	gkrto23 * 0.01
		gkrto24	=	gkrto24 * 0.01

		;SLIDERS
		kbase	invalue	"BaseFreq"
		gkbase	tablei	kbase, giExp1, 1
				outvalue	"BaseFreq_Value", gkbase
		kQ		invalue	"Q"
		gkQ		tablei	kQ, giExp2, 1
				outvalue	"Q_Value", gkQ
		gkdensity	invalue	"Density"
		kPinkLP	invalue	"LPF"
		gkPinkLP	tablei	kPinkLP, giExp3, 1
				outvalue	"LPF_Value", gkPinkLP
		kPinkHP	invalue	"HPF"
		gkPinkHP	tablei	kPinkHP, giExp3, 1
				outvalue	"HPF_Value", gkPinkHP
		gkDopRate	invalue	"Rate"
		gkDopDep	invalue	"DopplerDepth"
		gkPanDep	invalue	"PanDepth"
		gkRvbSnd	invalue	"RvbSend"
		gkRvbSze	invalue	"RvbSize"
		gkOutGain	invalue	"OutGain"

		;Q sliders
		gkQ1		invalue	"Q01"
		gkQ2		invalue	"Q02"
		gkQ3		invalue	"Q03"
		gkQ4		invalue	"Q04"
		gkQ5		invalue	"Q05"
		gkQ6		invalue	"Q06"
		gkQ7		invalue	"Q07"
		gkQ8		invalue	"Q08"
		gkQ9		invalue	"Q09"
		gkQ10	invalue	"Q10"
		gkQ11	invalue	"Q11"
		gkQ12	invalue	"Q12"
		gkQ13	invalue	"Q13"
		gkQ14	invalue	"Q14"
		gkQ15	invalue	"Q15"
		gkQ16	invalue	"Q16"
		gkQ17	invalue	"Q17"
		gkQ18	invalue	"Q18"
		gkQ19	invalue	"Q19"
		gkQ20	invalue	"Q20"
		gkQ21	invalue	"Q21"
		gkQ22	invalue	"Q22"
		gkQ23	invalue	"Q23"
		gkQ24	invalue	"Q24"

		;Amp sliders
		gkAmp1	invalue	"Amp01"
		gkAmp2	invalue	"Amp02"
		gkAmp3	invalue	"Amp03"
		gkAmp4	invalue	"Amp04"
		gkAmp5	invalue	"Amp05"
		gkAmp6	invalue	"Amp06"
		gkAmp7	invalue	"Amp07"
		gkAmp8	invalue	"Amp08"
		gkAmp9	invalue	"Amp09"
		gkAmp10	invalue	"Amp10"
		gkAmp11	invalue	"Amp11"
		gkAmp12	invalue	"Amp12"
		gkAmp13	invalue	"Amp13"
		gkAmp14	invalue	"Amp14"
		gkAmp15	invalue	"Amp15"
		gkAmp16	invalue	"Amp16"
		gkAmp17	invalue	"Amp17"
		gkAmp18	invalue	"Amp18"
		gkAmp19	invalue	"Amp19"
		gkAmp20	invalue	"Amp20"
		gkAmp21	invalue	"Amp21"
		gkAmp22	invalue	"Amp22"
		gkAmp23	invalue	"Amp23"
		gkAmp24	invalue	"Amp24"

		ktrig1	changed	gksound		;IF SOUND CHOICE CHANGES GENERATE A MOMENTARY '1' (BANG)
		if	ktrig1=1	then
			reinit	RESTART
		endif
		RESTART:
		if		i(gksound)==0	then		;Single
			iBase	=	0.5077195	;330
			iQ		=	0.6666600	;1000
		elseif	i(gksound)==1	then		;Dahina
			iBase	=	0.3648900	;150
			iQ		=	0.2329580	;50
		elseif	i(gksound)==2	then		;Banyan
			iBase	=	0.5183400	;350
			iQ		=	0.5491000	;444
		elseif	i(gksound)==3	then		;Xylophone
			iBase	=	0.3765900	;160
			iQ		=	0.4336500	;200
		elseif	i(gksound)==4	then		;Tibetan Bowl (180mm)
			iBase	=	0.4350800	;221
			iQ		=	0.7808000	;2200
		elseif	i(gksound)==5	then		;Spinel Sphere
			iBase	=	0.7079800	;997.25
			iQ		=	0.3010000	;80
		elseif	i(gksound)==6	then		;Pot Lid
			iBase	=	0.4574400	;250
			iQ		=	0.7254200	;1500
		elseif	i(gksound)==7	then		;Red Cedar Wood Plate
			iBase	=	0.6439000	;700
			iQ		=	0.3333200	;100
		elseif	i(gksound)==8	then		;Tubular Bell
			iBase	=	0.5585450	;437
			iQ		=	0.7669800	;2000
		elseif	i(gksound)==9	then		;Redwood Wood Plate
			iBase	=	0.7084800	;1000
			iQ		=	0.3333200	;100
		elseif	i(gksound)==10	then		;Douglas Fir Wood Plate
			iBase	=	0.7415300	;1200
			iQ		=	0.3920000	;150
		elseif	i(gksound)==11	then		;Uniform Wooden Bar
			iBase	=	0.6439000	;700
			iQ		=	0.4923900	;300
		elseif	i(gksound)==12	then		;Uniform Aluminium Bar
			iBase	=	0.5060400	;327
			iQ		=	0.6666600	;1000
		elseif	i(gksound)==13	then		;Vibraphone 1
			iBase	=	0.5598000	;440
			iQ		=	0.7669800	;2000
		elseif	i(gksound)==14	then		;Vibraphone 2
			iBase	=	0.5598000	;440
			iQ		=	0.7669800	;2000
		elseif	i(gksound)==15	then		;Chalandi Plates
			iBase	=	0.2049000	;62
			iQ		=	0.5662750	;500
		elseif	i(gksound)==16	then		;Tibetan Bowl (152mm)
			iBase	=	0.4987000	;314
			iQ		=	0.7808000	;2200
		elseif	i(gksound)==17	then		;Tibetan Bowl (140mm)
			iBase	=	0.5928300	;528
			iQ		=	0.7808000	;2200
		elseif	i(gksound)==18	then		;Wine Glass
			iBase	=	0.7048270	;980
			iQ		=	0.7253370	;1500
		elseif	i(gksound)==19	then		;Small Hand Bell
			iBase	=	0.7577000	;1312
			iQ		=	0.7992690	;2500
		elseif	i(gksound)==20	then		;User
			iBase	=	0.7577000	;User value
			iQ		=	0.7992690	;User value
		endif

		gialgfn	init		girtos1+i(gksound)				;MODAL ALGORITHM FUNCTION TABLE NUMBER
		gimodes	=		ftlen(gialgfn)					;FIND THE NUMBER OF MODES IN CURRENT INSTRUMENT FROM FUNCTION TABLE

				event_i	"i", 11, 0, 0.01, iBase, iQ, gimodes
	endif
endin

instr	11	;outvalue_i
			outvalue	"BaseFreq"	, p4
			outvalue	"Q"			, p5
			outvalue	"Modes"		, p6
			turnoff
endin

instr	12	;INIT
;Init of Modal Ratios
	outvalue	"Ratio01",  100			;scale is x 100 in Scroll Number box
	outvalue	"Ratio02",  200
	outvalue	"Ratio03",  300
	outvalue	"Ratio04",  400
	outvalue	"Ratio05",  500
	outvalue	"Ratio06",  600
	outvalue	"Ratio07",  700
	outvalue	"Ratio08",  800
	outvalue	"Ratio09",  900
	outvalue	"Ratio10", 1000
	outvalue	"Ratio11", 1100
	outvalue	"Ratio12", 1200
	outvalue	"Ratio13", 1300
	outvalue	"Ratio14", 1400
	outvalue	"Ratio15", 1500
	outvalue	"Ratio16", 1600
	outvalue	"Ratio17", 1700
	outvalue	"Ratio18", 1800
	outvalue	"Ratio19", 1900
	outvalue	"Ratio20", 2000
	outvalue	"Ratio21", 2100
	outvalue	"Ratio22", 2200
	outvalue	"Ratio23", 2300
	outvalue	"Ratio24", 2400

;Init of Q sliders
	outvalue	"Q01", 1.0
	outvalue	"Q02", 1.0
	outvalue	"Q03", 1.0
	outvalue	"Q04", 1.0
	outvalue	"Q05", 1.0
	outvalue	"Q06", 1.0
	outvalue	"Q07", 1.0
	outvalue	"Q08", 1.0
	outvalue	"Q09", 1.0
	outvalue	"Q10", 1.0
	outvalue	"Q11", 1.0
	outvalue	"Q12", 1.0
	outvalue	"Q13", 1.0
	outvalue	"Q14", 1.0
	outvalue	"Q15", 1.0
	outvalue	"Q16", 1.0
	outvalue	"Q17", 1.0
	outvalue	"Q18", 1.0
	outvalue	"Q19", 1.0
	outvalue	"Q20", 1.0
	outvalue	"Q21", 1.0
	outvalue	"Q22", 1.0
	outvalue	"Q23", 1.0
	outvalue	"Q24", 1.0

;Init of Amp  Ratios
	outvalue	"Amp01", 1.0
	outvalue	"Amp02", 1.0
	outvalue	"Amp03", 1.0
	outvalue	"Amp04", 1.0
	outvalue	"Amp05", 1.0
	outvalue	"Amp06", 1.0
	outvalue	"Amp07", 1.0
	outvalue	"Amp08", 1.0
	outvalue	"Amp09", 1.0
	outvalue	"Amp10", 1.0
	outvalue	"Amp11", 1.0
	outvalue	"Amp12", 1.0
	outvalue	"Amp13", 1.0
	outvalue	"Amp14", 1.0
	outvalue	"Amp15", 1.0
	outvalue	"Amp16", 1.0
	outvalue	"Amp17", 1.0
	outvalue	"Amp18", 1.0
	outvalue	"Amp19", 1.0
	outvalue	"Amp20", 1.0
	outvalue	"Amp21", 1.0
	outvalue	"Amp22", 1.0
	outvalue	"Amp23", 1.0
	outvalue	"Amp24", 1.0

	outvalue	"Sound"		, 4
	outvalue	"Density"		, 1
	outvalue	"Rate"		, 0.5
	outvalue	"DopplerDepth"	, 0.0001
	outvalue	"PanDepth"	, 0.1
	outvalue	"RvbSend"		, 0.3
	outvalue	"RvbSize"		, 0.8
	outvalue	"OutGain"		, 0.5
	outvalue	"LPF"		, 1.0	;20000 Hz
	outvalue	"HPF"		, 0.0	;20 Hz
endin

instr	99	;WRITE VALUES TO TABLES
	;DEFINE MACRO CONTAINING CODE FOR WRITING GUI VARIABLES INTO TABLE 
#define	WRITE_TO_TABLE(N)
	#
	tablew	gkQ$N, $N-1, giQs						;WRITE GUI SLIDER VARIABLE INTO TABLE
	tablew	gkAmp$N, $N-1, giAmps					;WRITE GUI SLIDER VARIABLE INTO TABLE
	tablew	gkrto$N, $N-1, girtos21					;WRITE GUI SLIDER VARIABLE INTO TABLE
	#
	$WRITE_TO_TABLE(1) 
	$WRITE_TO_TABLE(2) 
	$WRITE_TO_TABLE(3) 
	$WRITE_TO_TABLE(4) 
	$WRITE_TO_TABLE(5) 
	$WRITE_TO_TABLE(6) 
	$WRITE_TO_TABLE(7) 
	$WRITE_TO_TABLE(8) 
	$WRITE_TO_TABLE(9) 
	$WRITE_TO_TABLE(10)
	$WRITE_TO_TABLE(11)
	$WRITE_TO_TABLE(12)
	$WRITE_TO_TABLE(13)
	$WRITE_TO_TABLE(14)
	$WRITE_TO_TABLE(15)
	$WRITE_TO_TABLE(16)
	$WRITE_TO_TABLE(17)
	$WRITE_TO_TABLE(18)
	$WRITE_TO_TABLE(19)
	$WRITE_TO_TABLE(20)
	$WRITE_TO_TABLE(21)
	$WRITE_TO_TABLE(22)
	$WRITE_TO_TABLE(23)
	$WRITE_TO_TABLE(24)
endin

instr	1	;MIDI ACTIVATED INSTRUMENT
	kamp		init		1											;CONSTANT STRIKE AMPLITUDE
	apulse	mpulse	kamp, 0										;STRIKE IMPULSE
	icfoct	veloc	8,13											;SET CUTOFF FREQUENCY FOR FILTERING STRIKE IMPULSE ACCORDING TO KEY VELOCITY
	apulse	butlp	apulse,cpsoct(icfoct)							;FILTER STRIKE IMPULSE

	ibase	cpsmidi												;BASE FREQUENCY FOR MODE RESONATORS DERIVED FROM MIDI NOTE NUMBER
	icount	init		1											;INITIALIZE COUNTER USED INB COUNTING OUT THE REQUIRED NUMBER OF MODES
			modemodulei	apulse, ibase, icount, gialgfn, gimodes			;CALL modemodule USER DEFINED OPCODE
	aout		zar		0											;READ FROM ACCUMULATED ZAK CHANNEL
	idur		init		(i(gkQ)/ibase)*2								;ESTIMATE NOTE DURATION
			xtratim	idur											;EXTEND NOTE BEYOND MIDI NOTE OFF
	aout		=		(aout*gkOutGain) / gimodes

	if	gkDopOn=1	then												;IF 'Doppler' SWITCH IS 'ON'... 
		a1,a2	dopplerUDO	aout, gkDopRate, gkDopDep, gkPanDep		;CALL 'dopplerUDO' UDO
				outs			a1,a2								;SEND AUDIO TO OUTPUTS                                                
				zawm			a1*gkRvbSnd, 1							;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (LEFT CHANNEL) 
				zawm			a2*gkRvbSnd, 2                     		;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (RIGHT CHANNEL)
	else                                               				     ;OTHERWISE...                                                         
				outs			aout, aout							;SEND AUDIO TO OUTPUTS                                                
				zawm			aout*gkRvbSnd, 1						;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (LEFT CHANNEL) 
				zawm			aout*gkRvbSnd, 2						;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (RIGHT CHANNEL)
	endif														;END OF CONDITIONAL BRANCH                                            
			zacl		0, 0	
endin

instr	2	;GUI MODE RESONATORS INSTRUMENT (CALLS A UDO MULTIPLE TIMES ACCORDING TO THE NUMBER OF MODES IN THE SELECTED MODE ALGORITHM)
	kporttime		linseg	0,0.01,0.01								;CREATE A RAMPING UP ENVELOPE
	if 	gkinput==0	then
		;GENERATE AN IMPULSE SIGNAL===============================================================================================================================================
		kintvl	random	0.05, 0.3									;RANDOMIZED INTERVAL BETWEEN STRIKES
		kamp		init		1										;CONSTANT STRIKE AMPLITUDE
		apulse	mpulse	 kamp, kintvl*(1/gkdensity)					;STRIKE IMPULSE
		kcfoct	randomi	4,12,5									;RANDOMIZE CUTOFF FREQUENCY FOR FILTERING STRIKE IMPULSE
		apulse	butlp	apulse,cpsoct(kcfoct)						;FILTER STRIKE IMPULSE
		;=========================================================================================================================================================================
	else
		apulse	pinkish	0.1										;A PINK NOISE SIGNAL
		kPinkLP	portk	gkPinkLP, kporttime							;SMOOTH GUI SLIDER VARIABLE
		kPinkHP	portk	gkPinkHP, kporttime							;SMOOTH GUI SLIDER VARIABLE
		apulse	butlp	apulse, kPinkLP							;APPLY FILTER TO PINK NOISE SIGNAL
		apulse	buthp	apulse, kPinkHP							;APPLY FILTER TO PINK NOISE SIGNAL
	endif

	kbase	portk	gkbase, kporttime								;APPLY PORTAMENTO SMOOTHING TO GUI SLIDER VARIABLE

	ktrig	changed	gksound										;IF SOUND CHOICE CHANGES GENERATE A MOMENTARY '1' (BANG)
	if	ktrig=1	then												;IF A TRIGGER HAS BEEN GENERATED...
		reinit	RESTART											;BEGIN A REINITIALIZATION PASS FROM LABEL RESTART
	endif														;END OF CONDITIONAL BRANCHING
	RESTART:														;LABEL 'RESTART'
	icount	init		1											;INITIALIZE COUNTER USED INB COUNTING OUT THE REQUIRED NUMBER OF MODES
			modemodule	apulse, kbase, icount, gialgfn, gimodes			;CALL modemodule USER DEFINED OPCODE
	aout		zar		0											;READ FROM ACCUMULATED ZAK CHANNEL
	aout		=		(aout * gkOutGain) / gimodes						;RESCALE AMPLITUDE OF AUDIO SIGNAL ACCORDING TO NUMBER OF MODES PRESENT AND RESCALE ALSO ACCORDING TO 'Output Gain' SLIDER
			rireturn												;RETURN FROM REINITIALIZATION PASS
	if	gkDopOn=1	then												;IF 'Doppler' SWITCH IS 'ON'...                                       
		a1,a2	dopplerUDO	aout, gkDopRate, gkDopDep, gkPanDep		;CALL 'dopplerUDO' UDO                                           
			outs		a1,a2										;SEND AUDIO TO OUTPUTS                                                
			zawm		a1 * gkRvbSnd, 1								;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (LEFT CHANNEL) 
			zawm		a2 * gkRvbSnd, 2								;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (RIGHT CHANNEL)
	else															;OTHERWISE...                                                         
			outs		aout, aout									;SEND AUDIO TO OUTPUTS                                                
			zawm		aout * gkRvbSnd, 1								;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (LEFT CHANNEL) 
			zawm		aout * gkRvbSnd, 2								;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (RIGHT CHANNEL)
	endif														;END OF CONDITIONAL BRANCH                                            
			zacl		0, 0											;CLEAR ZAK AUDIO CHANNELS FROM 0 - 0                                  
endin

instr	1000	;REVERB	
	ainL			zar		1										;READ IN AUDIO FROM ZAK CHANNELS
	ainR			zar		2										;READ IN AUDIO FROM ZAK CHANNELS
				denorm	ainL, ainR								;...DENORMALIZE BOTH CHANNELS OF AUDIO SIGNAL
	arvbL, arvbR 	reverbsr 	ainL, ainR, gkRvbSze, 10000					;CREATE REVERBERATED SIGNAL (USING UDO DEFINED ABOVE)
				outs		arvbL, arvbR								;SEND AUDIO TO OUTPUTS
				zacl		1,2										;CLEAR ZAK AUDIO CHANNELS
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0.0	   3600	;GUI
i 12		0.0     0.01	;INIT

i 99 	0.0     3600	;UPDATE FUNCTION TABLES FOR INDIVIDUAL Q CONTROL AND AMPLITUDE CONTROL
i 1000	0.0     3600	;REVERB
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>67</x>
 <y>30</y>
 <width>1054</width>
 <height>703</height>
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
  <height>720</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>mode</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>8</x>
  <y>243</y>
  <width>160</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Base Frequency (Hz)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>BaseFreq_Value</objectName>
  <x>448</x>
  <y>243</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>221.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>BaseFreq</objectName>
  <x>8</x>
  <y>227</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2a8dc6e2-12f4-443d-af9b-59e4373cc24b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.43508000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>281</y>
  <width>150</width>
  <height>30</height>
  <uuid>{4fa545c6-e2f1-4387-8c9f-4a9dd388bb42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Q</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q_Value</objectName>
  <x>448</x>
  <y>281</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b0ad1916-b43e-44c2-be40-bca29f5cb1f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2200.056</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q</objectName>
  <x>8</x>
  <y>265</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9069e547-5638-4568-896f-980087c61de0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.78080000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>557</x>
  <y>52</y>
  <width>120</width>
  <height>26</height>
  <uuid>{ada34c8d-83fe-4eae-b207-ac7e38c5251f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No. of Modes :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>3</x>
  <y>476</y>
  <width>50</width>
  <height>27</height>
  <uuid>{7db371e5-4bd3-46a9-a5e3-0aea92940a6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>OutGain</objectName>
  <x>53</x>
  <y>476</y>
  <width>456</width>
  <height>27</height>
  <uuid>{c22c8f1f-06e2-4f93-90ef-76b20501e47f}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>310</y>
  <width>250</width>
  <height>150</height>
  <uuid>{56796b55-f924-40e9-ac1e-20eb7186c3bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Doppler On </label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>260</x>
  <y>310</y>
  <width>250</width>
  <height>150</height>
  <uuid>{60a7d221-fb7e-440a-8a38-be39910dc4db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Doppler</objectName>
  <x>86</x>
  <y>317</y>
  <width>16</width>
  <height>16</height>
  <uuid>{270b5abb-7151-480a-b70e-0a3d973e2528}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Q01</objectName>
  <x>555</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{e0294fcf-d069-40f2-9c37-e3bc87549cdb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>555</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{a565a1be-c6aa-43d2-8618-b598c3cfc37b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>01</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp01</objectName>
  <x>555</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ac888e11-4d96-4271-9508-ba5376125397}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>555</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{91856af2-a771-4f23-b6a7-7e6b46ed2668}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>01</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q02</objectName>
  <x>574</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{27fdbee5-484d-4759-a506-e65aa17ab01c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>574</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{51e9b772-0a3d-4191-bb92-42316ac28aa0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>02</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp02</objectName>
  <x>574</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{dd508ae3-be10-4080-90ca-75a940e747eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>574</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{84786841-3759-42a5-bd1a-b0aa86ee7000}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>02</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q03</objectName>
  <x>593</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{6d369355-4c67-4282-9cfa-f0475bf895ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>593</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{29bf30a7-d24d-46b2-85db-46c0a0134ed4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>03</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp03</objectName>
  <x>593</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{38057981-98da-41c8-9130-cf7ef8552756}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>593</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{023ba3eb-76a1-424c-9a77-869ac2cfa6a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>03</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q04</objectName>
  <x>612</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{5e42deaf-40f2-42de-b916-88562094688b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>612</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{8e5b6156-cbde-49f4-8588-ee21f3c0ff49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>04</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp04</objectName>
  <x>612</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{40746029-e636-4a3d-9a40-a397dc62e63b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>612</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{8ebc1030-658b-422e-8eb4-eefe3c8dcd44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>04</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q05</objectName>
  <x>631</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ff2fa335-262e-4c52-bc5b-a8ca33562dd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>631</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{83cb4fc0-f330-4f5b-bd9c-069aa3d294e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>05</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp05</objectName>
  <x>631</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{faba411b-9e62-4dc5-a9fa-0eb82d12aa00}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>631</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{2e06b74f-0455-4620-99dc-c59b322bdab8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>05</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q06</objectName>
  <x>650</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{d3c9df25-f45a-4302-a7c1-5e68d232d9ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>650</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{0e0bee25-4482-4afd-ab1b-bc6cf03c220b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>06</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp06</objectName>
  <x>650</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{eac41a99-c99e-4084-bf57-ffa32b5c4708}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>650</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{e4289389-533f-4256-bbec-48b5e5a9d168}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>06</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q07</objectName>
  <x>669</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{603e90bf-b7b7-4ad5-b851-88733f3271fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>669</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{310a46c4-c815-40bd-90f9-ebdd19089d1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>07</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp07</objectName>
  <x>669</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{94aee6e1-602c-4670-9b5a-719f1549d3b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>669</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{b51ea71e-4e8b-4aa6-b3e0-440f9401c938}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>07</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q08</objectName>
  <x>688</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{287aba45-6485-47ef-b00a-4230b748fa23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>688</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{f0d357df-7e29-44a2-ac46-b3b15f34fa03}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>08</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp08</objectName>
  <x>688</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{7c47a834-6a4a-439d-bf04-82ee2dd54270}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>688</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{a4c5ec4e-fa77-4334-82c1-c6ed813e950c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>08</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q09</objectName>
  <x>707</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{b08b59f5-0703-4e15-8fe9-98e27d866988}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>707</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{51741bb4-62fe-4ac0-bef7-0eac02be3e1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>09</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp09</objectName>
  <x>707</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{25bb64d2-dc39-4bd0-a959-1e55b1fcba98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>707</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{b75b7158-5344-4fe7-a886-eb14ea585b48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>09</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q10</objectName>
  <x>726</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{fc5d7210-9372-416b-95f2-79cecfdfc30d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>726</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{d6e99483-72d3-470c-870f-ec9041a97f54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>10</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp10</objectName>
  <x>726</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{94f71afa-c638-434f-9a51-3317e1c70014}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>726</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{f0ac287d-5d32-44c2-a530-80c810510050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>10</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q11</objectName>
  <x>745</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{8ffdfcd6-1212-45f8-811e-e2b7ee540e98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>745</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{8510c88e-b1ea-4d8b-878c-57245ef29107}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>11</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp11</objectName>
  <x>745</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{4df7c0ed-1889-4def-91f1-edf8ff2e4946}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>745</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{54b51bfd-1481-45cb-b8c3-b1cc332ba987}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>11</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q12</objectName>
  <x>764</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ef6a0087-7f23-4faf-9470-dee21aee3d8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>764</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{6016b613-2080-4223-be73-4e2a9799aa9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>12</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp12</objectName>
  <x>764</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{d4da60eb-db6a-4fb3-9039-2bbe49366913}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>764</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{e7a33e18-7970-4706-a238-7de592df2a53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>12</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q13</objectName>
  <x>783</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{9eae7f62-d6e5-4286-8eee-5b9393a757cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>783</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{6be85753-c2d8-48e7-acbd-cde62d9fae77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>13</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp13</objectName>
  <x>783</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ad7bf934-0f1c-4ca3-9528-e82a00de855f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>783</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{2d539d0d-9040-4c69-a39d-cfd66e769a96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>13</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q14</objectName>
  <x>802</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{21a873a8-2197-4293-ae8e-670d987960bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>802</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{ac82ae8e-8d31-45ee-9072-d29d5f0383fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>14</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp14</objectName>
  <x>802</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{dbd98807-afde-48d1-a1bc-31036422840e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>802</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{a9d3331d-5531-49f9-bbe1-95e407e8fc35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>14</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q15</objectName>
  <x>821</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{fc84db99-5b7a-43d9-b556-fe946a6c6d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>821</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{a5e2be04-8bca-4d0c-ab8d-79136ec65c8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>15</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp15</objectName>
  <x>821</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{e4100fa6-bdf2-4814-b4f8-140bb4077984}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>821</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{e12efa88-c883-43aa-a913-fd529d3c3715}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>15</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q16</objectName>
  <x>840</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{3310bd75-80ce-4a3e-a345-1d6e49804341}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>840</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{5c1587f4-b6e4-4256-bd0c-900b9ae81094}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>16</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp16</objectName>
  <x>840</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{ca1c8a4f-3d96-4e91-8ddd-8e06318a49a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>840</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{d733fd8e-ee75-4d92-ae24-e2e56f707e18}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>16</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q17</objectName>
  <x>859</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{c989177b-99d2-49c7-b85d-c1dc75b5179d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>859</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{d318029f-12bf-49d2-85fa-524a236ec4ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>17</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp17</objectName>
  <x>859</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{11ebfe42-2f0b-404c-ad6b-7cb91baa1a55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>859</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{902f366e-c348-4ba6-8a22-5261be839723}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>17</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q18</objectName>
  <x>878</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{c3cae3ec-9ec8-4689-b49c-07a52d04dfb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>878</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{0ed73845-9b9a-4773-8449-8f13494f5c83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>18</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp18</objectName>
  <x>878</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{3f8b65c1-8a90-411a-949b-fa67b26bc177}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>878</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{8fdda769-433c-41db-bc04-6a89ca72a79a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>18</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q19</objectName>
  <x>897</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{a5c32908-93ee-4469-9600-dd8ab2747e7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>897</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{13702325-51b6-4f40-bafe-51ab4b8cddb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>19</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp19</objectName>
  <x>897</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{d6f7cb0a-5467-4511-8273-06d636cb62f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>897</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{5a4c4ebf-7291-4445-86d1-f6a1d34193e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>19</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q20</objectName>
  <x>916</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{f39ee50f-7584-478c-9f8c-2ed244070b46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>916</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{e4dfc580-3953-454d-a71d-b8d56a2d4d6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>20</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp20</objectName>
  <x>916</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{dc2e205e-90ce-4035-b6f2-ac47e6c8e3a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>916</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{73982eb0-5186-46da-a681-15ef18f17f5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>20</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q21</objectName>
  <x>935</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{312b1a40-4bcc-43c7-8f42-093f23b4897d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>935</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{87032196-52b1-4d7f-8aa3-9e56e62aa084}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>21</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp21</objectName>
  <x>935</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{532b73fd-3c06-469c-b11b-cb00036969f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>935</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{5fae417b-dc5c-4dae-9d18-b3b4db7c42ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>21</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q22</objectName>
  <x>954</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{6294c6dc-0b04-4d3f-a518-7a158e83ff05}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>954</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{7df731a7-960f-4bdb-a58f-0272fe88fb68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>22</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp22</objectName>
  <x>954</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{3ffcb426-564f-4c1a-b3e6-7dc5cda7c84f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>954</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{a28b8d62-1f53-4c88-aa98-ecb659e90ffe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>22</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q23</objectName>
  <x>973</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{8bc8e523-bf6d-47c8-a319-6e99c66d5143}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>973</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{4dc8fbf3-0faf-4457-b6df-f0ebf447247b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>23</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp23</objectName>
  <x>973</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{268ef71a-dfe8-44c4-bc5b-b2d98381160d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>973</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{c03d10a2-0aaa-47ab-8ffc-ae39d536bd6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>23</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Q24</objectName>
  <x>992</x>
  <y>111</y>
  <width>19</width>
  <height>100</height>
  <uuid>{30c48354-5d47-4789-8742-e20e0b7b9499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>992</x>
  <y>211</y>
  <width>20</width>
  <height>22</height>
  <uuid>{fa5576b9-afcf-4b06-bd99-868806604f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>24</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amp24</objectName>
  <x>992</x>
  <y>233</y>
  <width>19</width>
  <height>100</height>
  <uuid>{0aff2b19-d512-44a0-8b74-850166fa4795}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>992</x>
  <y>333</y>
  <width>20</width>
  <height>22</height>
  <uuid>{3cafc97e-a2a3-42ec-8a4c-f7008e614f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>24</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>509</x>
  <y>209</y>
  <width>50</width>
  <height>30</height>
  <uuid>{558493b1-e8d1-4075-9292-f3399da7cd6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Qs:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>509</x>
  <y>331</y>
  <width>50</width>
  <height>30</height>
  <uuid>{07b9ac3a-82af-43ef-bcbb-908b74d94139}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amps:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>12</x>
  <y>356</y>
  <width>150</width>
  <height>30</height>
  <uuid>{f12a5663-3e0d-4fa3-a13b-d400b616724c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Rate</objectName>
  <x>12</x>
  <y>340</y>
  <width>240</width>
  <height>27</height>
  <uuid>{9be0be34-ef7c-4251-9c80-d250c369cb79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>394</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7e261478-6a4d-4693-830b-9fdebbefe1a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Doppler Depth</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>DopplerDepth</objectName>
  <x>12</x>
  <y>378</y>
  <width>240</width>
  <height>27</height>
  <uuid>{f9d29ab6-8491-42e6-b140-3cb980b0402d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>0.00500000</maximum>
  <value>0.00010000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>432</y>
  <width>150</width>
  <height>30</height>
  <uuid>{5d1d7737-1319-49d1-bea2-bb9bb3ce8996}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pan Depth</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>PanDepth</objectName>
  <x>12</x>
  <y>416</y>
  <width>240</width>
  <height>27</height>
  <uuid>{e1fce506-e576-49ff-849e-3dedb55336e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>264</x>
  <y>356</y>
  <width>150</width>
  <height>30</height>
  <uuid>{2e8617ea-d5f9-4de6-9ba4-c1c0a657e699}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Send</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RvbSend</objectName>
  <x>264</x>
  <y>340</y>
  <width>240</width>
  <height>27</height>
  <uuid>{54dd3c6c-b5b3-4c10-9d33-66d568e9205f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>264</x>
  <y>394</y>
  <width>150</width>
  <height>30</height>
  <uuid>{d2e593d7-5475-473f-a2b0-28169c2684d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Size</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RvbSize</objectName>
  <x>264</x>
  <y>378</y>
  <width>240</width>
  <height>27</height>
  <uuid>{12d14032-8cd0-4dcb-839c-251aa31b95b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>625</x>
  <y>360</y>
  <width>320</width>
  <height>30</height>
  <uuid>{6ab18846-3016-4a55-9a6a-78a49edfdf3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>User Definable Modal Ratios x100 (Sound Algorithm 21)</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio01</objectName>
  <x>555</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{b60dfd01-8aea-47fb-8ef2-f1e2495ff43c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>100.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>555</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{a8acf092-4fc3-46ad-b0f2-8167a980e3e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>01</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio02</objectName>
  <x>593</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{5c0b9d3f-be0e-4c60-b478-598b82bebb50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>200.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>593</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{d238e56d-0502-46a7-a4ae-6ac33df02a3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>02</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio03</objectName>
  <x>631</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{a16607e4-f5f0-4fef-9afc-b092fd30edac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>300.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>631</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{4b93282e-68e9-4eb2-aee3-6628a19665a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>03</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio04</objectName>
  <x>669</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{3ecf8a94-2cbe-45ac-bacc-85dfcb2d4e40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>400.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>669</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{5519581e-1b00-4342-9532-163fdc112821}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>04</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio05</objectName>
  <x>707</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{549dce96-fc01-423f-9b85-2f7af4547b77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>500.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>707</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{ef491485-b2d0-48e8-a33e-d86ff607d7fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>05</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio06</objectName>
  <x>745</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{43566d33-093f-4a06-86c9-352b8142d1fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>600.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>745</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{dab000ab-dbe0-4418-9d9c-4ce3f716074b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>06</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio07</objectName>
  <x>783</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{2b8f0bb3-f602-41b8-8234-207b7996fc42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>700.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>783</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{17dbbbd7-2db7-4955-8efe-d201e7d82cd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>07</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio08</objectName>
  <x>821</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{edbd475e-5bd1-4da3-996b-7632e4f049f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>800.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>821</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{e729e152-4bdf-4d10-bcf1-1af4cff7dca0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>08</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio09</objectName>
  <x>859</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{2a46c17b-d834-425f-9109-b059caf555f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>900.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>859</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{c9281463-d5e0-43ec-b021-6422b6096c83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>09</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio10</objectName>
  <x>897</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{41d11b53-14b3-4459-b2b2-44b93341ad78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1000.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>897</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{7e63f854-6b40-424d-b12d-6e35a4b48e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>10</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio11</objectName>
  <x>935</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{54d1ee2e-aed7-4829-8605-cc592877acec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1100.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>935</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{875b286b-af89-4ca4-88b1-7895a19a9976}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>11</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio12</objectName>
  <x>973</x>
  <y>382</y>
  <width>38</width>
  <height>25</height>
  <uuid>{43dee353-4026-424c-93a3-ad83af33e07b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1200.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>973</x>
  <y>406</y>
  <width>38</width>
  <height>22</height>
  <uuid>{246b47f0-3a41-4795-bd4d-336bb5512160}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>12</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio13</objectName>
  <x>555</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{af3d900b-6e2a-472b-a128-613fd216e592}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1300.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>555</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{d631f22d-b2f2-4791-98a4-2d1fe887ba8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>13</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio14</objectName>
  <x>593</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{f793a19e-da6a-4b61-ba3a-8e5598bc275e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1400.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>593</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{5d4cce68-b923-411c-a054-a75943d3b991}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>14</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio15</objectName>
  <x>631</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{bd56ad53-226f-435a-a472-9cce0ad114ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1500.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>631</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{b9f977e9-e85d-48a8-9e02-5083cdd1c332}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>15</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio16</objectName>
  <x>669</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{e11c5473-e7bf-43ae-a874-f3722ee84883}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1600.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>669</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{ace589fa-e426-42c8-9a47-97c48e2d3dff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>16</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio17</objectName>
  <x>707</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{035a3c46-c3e4-40ba-8de3-4a4b0eae30f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1700.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>707</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{367eabe1-4c08-43ff-9bc7-0c868e7cba43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>17</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio18</objectName>
  <x>745</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{84760613-5c64-4f18-9c5b-fa1fb1b658cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1800.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>745</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{97427ce7-c38a-40ae-aa1e-10f0d668a00c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>18</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio19</objectName>
  <x>783</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{85054724-52c9-4332-9d79-89f91faa3d7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>1900.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>783</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{cfce9853-e234-4d69-8fee-506b6c889326}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>19</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio20</objectName>
  <x>821</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{e59da8be-409b-41a3-98e7-8f2060204c26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>2000.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>821</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{2080a56e-4f8e-4ea3-91da-2e205a85f81d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>20</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio21</objectName>
  <x>859</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{c694c42c-d360-4ee5-9439-551d7cc120bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>2100.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>859</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{09e64380-a721-48fd-b97e-2977a7f5533f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>21</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio22</objectName>
  <x>897</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{088046b4-98a1-4f74-9a18-91b87c2d38ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>2200.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>897</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{cc8d05d1-8473-40db-8f7d-c0985b7f3a17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>22</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio23</objectName>
  <x>935</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{cbf5bd9f-3de7-47ca-b223-bb7a67fc0e20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>2300.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>935</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{e8d29fa8-970e-4acf-9b75-83ed7fbc1072}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>23</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio24</objectName>
  <x>973</x>
  <y>428</y>
  <width>38</width>
  <height>25</height>
  <uuid>{f14ad635-5cb9-4c61-a3f1-3a2c45d60105}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <value>2400.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>973</x>
  <y>452</y>
  <width>38</width>
  <height>22</height>
  <uuid>{9f54a04e-7279-4b3c-a40b-e29d19576bdc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>24</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Sound</objectName>
  <x>350</x>
  <y>50</y>
  <width>220</width>
  <height>26</height>
  <uuid>{074eae0e-bc82-412e-a2ba-290354ad87b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Single</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Dahina</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Banyan</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Xylophone</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tibetan Bowl (180mm)</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Spinel Sphere</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pot Lid</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Red Cedar Wood Plate</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tubular Bell</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Redwood Wood Plate</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Douglas Fir Wood Plate</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Uniform Wooden Bar</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Uniform Aluminium Bar</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Vibraphone 1</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Vibraphone 2</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Chalandi Plates</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tibetan Bowl (152mm)</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tibetan Bowl (140mm)</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Wine Glass</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Small Hand Bell</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>User</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>4</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Modes</objectName>
  <x>676</x>
  <y>50</y>
  <width>40</width>
  <height>26</height>
  <uuid>{1d2d893d-5d8a-4b92-b316-d70ad559f967}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <value>7.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>50.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>127</y>
  <width>160</width>
  <height>30</height>
  <uuid>{b066c36d-a132-4a1a-aee4-e421b02bca48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Impulse Density</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Density</objectName>
  <x>448</x>
  <y>127</y>
  <width>60</width>
  <height>30</height>
  <uuid>{262729b5-3e13-43d4-af01-99d1e8aabf34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Density</objectName>
  <x>8</x>
  <y>111</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f4910f7d-2341-46e1-aa20-a4d3db351c24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.06250000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>165</y>
  <width>160</width>
  <height>30</height>
  <uuid>{5a8c0afb-17da-4ca7-a331-f3ef38db1431}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pink Noise LP Filter</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LPF_Value</objectName>
  <x>448</x>
  <y>165</y>
  <width>60</width>
  <height>30</height>
  <uuid>{12d2c823-daba-4a56-9f0c-462a6c951992}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20000.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LPF</objectName>
  <x>8</x>
  <y>149</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5442ecac-367f-413c-a49e-5f42a2727519}</uuid>
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
  <y>204</y>
  <width>160</width>
  <height>30</height>
  <uuid>{d1ad1809-ed86-4ecd-b6c9-15b4c9686e35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pink Noise HP Filter</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>HPF_Value</objectName>
  <x>448</x>
  <y>204</y>
  <width>60</width>
  <height>30</height>
  <uuid>{39d4f770-c1eb-4c2d-9b6d-41b78e8955f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>HPF</objectName>
  <x>8</x>
  <y>188</y>
  <width>500</width>
  <height>27</height>
  <uuid>{37911dd5-758c-4ec8-9871-ce3f5cd67670}</uuid>
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
  <x>5</x>
  <y>502</y>
  <width>1023</width>
  <height>215</height>
  <uuid>{5e4b9a15-5452-40be-b5c2-55fc7313eae5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Mode is a filtering opcode which is intended to be used as a resonator for modal synthesis. An imitation of an acoustic sound will normally employ five or more instances of mode resonating at different frequencies to represent the different partials of the sound. In this example, as the user selects different presets using the counter, an instrument is is created with the appropriate number of mode resonators for that sound. The number of instances of mode employed is also displayed. (For more information on coding dynamic iteration of opcodes see Steven Yi's article 'Control Flow - Part II' in the summer 2006 issue of the Csound Journal.) The frequency ratios needed for each preset are stored in function tables. 'Q' or resonance of the resonators is controlled globally using a single slider. The base frequency to which all mode resonators relate is also controlled by a single slider. These resonators need to be agitated by some sort of excitation signal, in this example the first option 'Impulses' sends an aleatoric stream of filtered clicks into the resonators - this suggests that the object is being with a hard beater. The second option 'Pink Noise' imitates the object being blown or scraped. With imagination it is possible to imitate the object being hit with softer beaters, bowed etc. The density of the impulses can be varied using the 'Density' slider. The pink noise signal can be filtered before entering the resonators using the LPF (lowpass filter) and HPF (highpass filter) controls. The excitation impluse is a click, filtered according to note velocity. Additionally the sound can be processed through a doppler effect and a reverb. Most of the tables of modal frequencies have been taken from the appendix of the Csound Manual. As well as the global control of Q and amplitude for all modes in a sound algorithm, individual controls for each mode are also provided by the two banks of small vertical sliders. These act as multipliers (within the range 0-1) upon the global value. In the case of Q a value of zero is not allowed so the minimum is slightly above zero. Sound algorithm 21 is a user definable algorithm, the modal frequency ratios of which can be set by the two rows of value input boxes at the lower end of the GUI.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>10</x>
  <y>50</y>
  <width>120</width>
  <height>26</height>
  <uuid>{c691b0f3-1f6d-4885-ba24-96ba01690580}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Impulse</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pink Noise</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>10</x>
  <y>10</y>
  <width>120</width>
  <height>26</height>
  <uuid>{667886e0-4296-46a6-98ff-be4e024a36cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
