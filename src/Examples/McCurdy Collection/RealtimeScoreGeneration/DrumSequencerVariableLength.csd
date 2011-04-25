;Written by Iain McCurdy, 2008

;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	used latched value type button and removed macro WRITE_VAL to replace FLbutton


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;FUNCTION TABLE FOR STORAGE OF SEQUENCE DATA FOR SOUND 1
gi1		ftgen	0, 0, 256, -2,	0,	0.25,	.001,	0,\
							0,	0.5,	.001,	0,\
							0,	0.75,	.001,	0,\
							0,	1,	.001,	0,\
							0,	1.25,	.001,	0,\
							0,	1.5,	.001,	0,\
							0,	1.75,	.001,	0,\
							0,	2,	.001,	0,\
							0,	2.25,	.001,	0,\
							0,	2.5,	.001,	0,\
							0,	2.75,	.001,	0,\
							0,	3,	.001,	0,\
							0,	3.25,	.001,	0,\
							0,	3.5,	.001,	0,\
							0,	3.75,	.001,	0,\
							0,	4,	.001,	0,\
							0,	4.25,	.001,	0,\
							0,	4.5,	.001,	0,\
							0,	4.75,	.001,	0,\
							0,	5,	.001,	0,\
							0,	5.25,	.001,	0,\
							0,	5.5,	.001,	0,\
							0,	5.75,	.001,	0,\
							0,	6,	.001,	0,\
							0,	6.25,	.001,	0,\
							0,	6.5,	.001,	0,\
							0,	6.75,	.001,	0,\
							0,	7,	.001,	0,\
							0,	7.25,	.001,	0,\
							0,	7.5,	.001,	0,\
							0,	7.75,	.001,	0,\
							0,	8,	.001,	0,\
							-1,	8,	-1,	-1

gi2		ftgen	0, 0, 256, -2, 0		;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi3		ftgen	0, 0, 256, -2, 0		;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi4		ftgen	0, 0, 256, -2, 0		;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi5		ftgen	0, 0, 256, -2, 0		;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi6		ftgen	0, 0, 256, -2, 0		;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1

		zakinit	8, 8					;INITIALISE ZAK SPACE (8 A-RATE, 8 K-RATE)

giRvbSndChn	=	1					;ZAK CHANNEL NUMBER USED FOR REVERB SEND
giDlySndChn	=	3					;ZAK CHANNEL NUMBER USED FOR REVERB SEND

		seed		0


instr	200	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then

#define	ROW(COUNT)	
		#
		;TABLES UPDATE
		gk$COUNT_01	invalue	"b$COUNT_01"		;BUTTON VALUE
		kTrig$COUNT_01	changed	gk$COUNT_01
		if kTrig$COUNT_01 == 1 then
			tablew	gk$COUNT_01, ((1-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_02	invalue	"b$COUNT_02"		;BUTTON VALUE
		kTrig$COUNT_02	changed	gk$COUNT_02
		if kTrig$COUNT_02 == 1 then
			tablew	gk$COUNT_02, ((2-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_03	invalue	"b$COUNT_03"		;BUTTON VALUE
		kTrig$COUNT_03	changed	gk$COUNT_03
		if kTrig$COUNT_03 == 1 then
			tablew	gk$COUNT_03, ((3-1)*4)+3, gi$COUNT 
		endif
		
		gk$COUNT_04	invalue	"b$COUNT_04"		;BUTTON VALUE
		kTrig$COUNT_04	changed	gk$COUNT_04
		if kTrig$COUNT_04 == 1 then
			tablew	gk$COUNT_04, ((4-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_05	invalue	"b$COUNT_05"		;BUTTON VALUE
		kTrig$COUNT_05	changed	gk$COUNT_05
		if kTrig$COUNT_05 == 1 then
			tablew	gk$COUNT_05, ((5-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_06	invalue	"b$COUNT_06"		;BUTTON VALUE
		kTrig$COUNT_06	changed	gk$COUNT_06
		if kTrig$COUNT_06 == 1 then
			tablew	gk$COUNT_06, ((6-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_07	invalue	"b$COUNT_07"		;BUTTON VALUE
		kTrig$COUNT_07	changed	gk$COUNT_07
		if kTrig$COUNT_07 == 1 then
			tablew	gk$COUNT_07, ((7-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_08	invalue	"b$COUNT_08"		;BUTTON VALUE
		kTrig$COUNT_08	changed	gk$COUNT_08
		if kTrig$COUNT_08 == 1 then
			tablew	gk$COUNT_08, ((8-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_09	invalue	"b$COUNT_09"		;BUTTON VALUE
		kTrig$COUNT_09	changed	gk$COUNT_09
		if kTrig$COUNT_09 == 1 then
			tablew	gk$COUNT_09, ((9-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_10	invalue	"b$COUNT_10"		;BUTTON VALUE
		kTrig$COUNT_10	changed	gk$COUNT_10
		if kTrig$COUNT_10 == 1 then
			tablew	gk$COUNT_10, ((10-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_11	invalue	"b$COUNT_11"		;BUTTON VALUE
		kTrig$COUNT_11	changed	gk$COUNT_11
		if kTrig$COUNT_11 == 1 then
			tablew	gk$COUNT_11, ((11-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_12	invalue	"b$COUNT_12"		;BUTTON VALUE
		kTrig$COUNT_12	changed	gk$COUNT_12
		if kTrig$COUNT_12 == 1 then
			tablew	gk$COUNT_12, ((12-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_13	invalue	"b$COUNT_13"		;BUTTON VALUE
		kTrig$COUNT_13	changed	gk$COUNT_13
		if kTrig$COUNT_13 == 1 then
			tablew	gk$COUNT_13, ((13-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_14	invalue	"b$COUNT_14"		;BUTTON VALUE
		kTrig$COUNT_14	changed	gk$COUNT_14
		if kTrig$COUNT_14 == 1 then
			tablew	gk$COUNT_14, ((14-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_15	invalue	"b$COUNT_15"		;BUTTON VALUE
		kTrig$COUNT_15	changed	gk$COUNT_15
		if kTrig$COUNT_15 == 1 then
			tablew	gk$COUNT_15, ((15-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_16	invalue	"b$COUNT_16"		;BUTTON VALUE
		kTrig$COUNT_16	changed	gk$COUNT_16
		if kTrig$COUNT_16 == 1 then
			tablew	gk$COUNT_16, ((16-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_17	invalue	"b$COUNT_17"		;BUTTON VALUE
		kTrig$COUNT_17	changed	gk$COUNT_17
		if kTrig$COUNT_17 == 1 then
			tablew	gk$COUNT_17, ((17-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_18	invalue	"b$COUNT_18"		;BUTTON VALUE
		kTrig$COUNT_18	changed	gk$COUNT_18
		if kTrig$COUNT_18 == 1 then
			tablew	gk$COUNT_18, ((18-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_19	invalue	"b$COUNT_19"		;BUTTON VALUE
		kTrig$COUNT_19	changed	gk$COUNT_19
		if kTrig$COUNT_19 == 1 then
			tablew	gk$COUNT_19, ((19-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_20	invalue	"b$COUNT_20"		;BUTTON VALUE
		kTrig$COUNT_20	changed	gk$COUNT_20
		if kTrig$COUNT_20 == 1 then
			tablew	gk$COUNT_20, ((20-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_21	invalue	"b$COUNT_21"		;BUTTON VALUE
		kTrig$COUNT_21	changed	gk$COUNT_21
		if kTrig$COUNT_21 == 1 then
			tablew	gk$COUNT_21, ((21-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_22	invalue	"b$COUNT_22"		;BUTTON VALUE
		kTrig$COUNT_22	changed	gk$COUNT_22
		if kTrig$COUNT_22 == 1 then
			tablew	gk$COUNT_22, ((22-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_23	invalue	"b$COUNT_23"		;BUTTON VALUE
		kTrig$COUNT_23	changed	gk$COUNT_23
		if kTrig$COUNT_23 == 1 then
			tablew	gk$COUNT_23, ((23-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_24	invalue	"b$COUNT_24"		;BUTTON VALUE
		kTrig$COUNT_24	changed	gk$COUNT_24
		if kTrig$COUNT_24 == 1 then
			tablew	gk$COUNT_24, ((24-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_25	invalue	"b$COUNT_25"		;BUTTON VALUE
		kTrig$COUNT_25	changed	gk$COUNT_25
		if kTrig$COUNT_25 == 1 then
			tablew	gk$COUNT_25, ((25-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_26	invalue	"b$COUNT_26"		;BUTTON VALUE
		kTrig$COUNT_26	changed	gk$COUNT_26
		if kTrig$COUNT_26 == 1 then
			tablew	gk$COUNT_26, ((26-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_27	invalue	"b$COUNT_27"		;BUTTON VALUE
		kTrig$COUNT_27	changed	gk$COUNT_27
		if kTrig$COUNT_27 == 1 then
			tablew	gk$COUNT_27, ((27-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_28	invalue	"b$COUNT_28"		;BUTTON VALUE
		kTrig$COUNT_28	changed	gk$COUNT_28
		if kTrig$COUNT_28 == 1 then
			tablew	gk$COUNT_28, ((28-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_29	invalue	"b$COUNT_29"		;BUTTON VALUE
		kTrig$COUNT_29	changed	gk$COUNT_29
		if kTrig$COUNT_29 == 1 then
			tablew	gk$COUNT_29, ((29-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_30	invalue	"b$COUNT_30"		;BUTTON VALUE
		kTrig$COUNT_30	changed	gk$COUNT_30
		if kTrig$COUNT_30 == 1 then
			tablew	gk$COUNT_30, ((30-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_31	invalue	"b$COUNT_31"		;BUTTON VALUE
		kTrig$COUNT_31	changed	gk$COUNT_31
		if kTrig$COUNT_31 == 1 then
			tablew	gk$COUNT_31, ((31-1)*4)+3, gi$COUNT 
		endif

		gk$COUNT_32	invalue	"b$COUNT_32"		;BUTTON VALUE
		kTrig$COUNT_32	changed	gk$COUNT_32
		if kTrig$COUNT_32 == 1 then
			tablew	gk$COUNT_32, ((32-1)*4)+3, gi$COUNT 
		endif

		;SLIDERS
		gk$COUNTGain	invalue	"Gain$COUNT"
		gk$COUNTPch	invalue	"Transpose$COUNT"
		gk$COUNTDly	invalue	"Delay$COUNT"
		;COUNTERS
		gkLen$COUNT	invalue	"Cycle$COUNT"
		;CONTROLLERS
		gkphs$COUNT	invalue	"Phase$COUNT"
		#

		$ROW(1)
		$ROW(2)
		$ROW(3)
		$ROW(4)
		$ROW(5)
		$ROW(6)

		;SLIDERS
		gkRvbSnd		invalue	"RvbSend"
		gkfblvl		invalue	"RvbTime"
		gkfco		invalue	"RvbCutoff"
		gkDlySnd		invalue	"DelSend"
		gkDlyFB		invalue	"DelFB"
		;COUNTERS
		gkTempo		invalue	"Tempo"
		gkDelTim1		invalue	"DelayL"
		gkDelTim2		invalue	"DelayR"
		;KNOBS
		gkMasterGain	invalue	"Master"

	endif
endin

instr	1	; NOTE TRIGGERING INSTRUMENT
	kSwitch	changed	gkLen1, gkLen2, gkLen3, gkLen4, gkLen5, gkLen6 			;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then													;IF kSwitch=1, I.E. IF ANY OF THE ABOVE LISTED PARAMETERS HAVE CHANGED...
		reinit	START												;...PERFORM AN I-RATE PASS BEGINNING FROM THE GIVEN LABEL
	endif															;END OF CONDITIONAL BRANCHING
	START:															;A LABEL	
	kTempoRatio	=	gkTempo/60
	
	kp1			init	0
	kp2			init	0
	kp3			init	0
	kp4			init	0

#define	LOOP(COUNT)	
	#
	kphs$COUNT    	phasor		(kTempoRatio)/gkLen$COUNT
	gktimpnt$COUNT	=			kphs$COUNT * gkLen$COUNT
	ktrig		timedseq		gktimpnt$COUNT,gi$COUNT, kp1, kp2,kp3, kp4

	;			schedkwhen 	ktrigger, kmintim, kmaxnum, kinsnum,    kwhen,      kdur    p4    p5
				schedkwhen	ktrig,       0,        0,     2,     gk$COUNTDly,   kp3,   kp4, $COUNT#
	
	$LOOP(1)
	$LOOP(2)
	$LOOP(3)
	$LOOP(4)
	$LOOP(5)
	$LOOP(6)
	rireturn
endin

instr	2
	if	p4=1	then
		event_i	"i", p1+p5, 0, p3
	endif
endin

#define	KALIMBA(I'COUNT)
	#
	instr	$I
	p3	=	2.6		;DEFINE DURATION FOR THIS SOUND
	ivel		random	0.2,1
	asig 	barmodel	1, 1, i(gk$COUNTPch), 1, 0, 2.6, 0.5, 1000*ivel, 0.07		;KALIMBA SOUND CREATED USING barmodel OPCODE (SEE CSOUND MANUAL FOR MORE INFO.)
	asigL	=		asig*i(gk$COUNTGain)*i(gkMasterGain)*2					;DEFINE LEFT CHANNEL AUDIO
	asigR	=		asig*i(gk$COUNTGain)*i(gkMasterGain)*2					;DEFINE RIGHT CHANNEL AUDIO
			outs		asigL, asigR 										;SEND AUDIO TO OUTPUTS

			zawm		asigL*gkRvbSnd, giRvbSndChn
			zawm		asigR*gkRvbSnd, giRvbSndChn+1
			zawm		asigL*gkDlySnd, giDlySndChn
			zawm		asigR*gkDlySnd, giDlySndChn+1
	endin
	#	

$KALIMBA(3'1)
$KALIMBA(4'2)
$KALIMBA(5'3)
$KALIMBA(6'4)
$KALIMBA(7'5)
$KALIMBA(8'6)

instr	100	;COPY TABLE 1 TO ALL OTHER TABLES AND SET RANDOM INITIAL VALUES FOR SOME VALUATORS (PERFORMED ONCE AT THE BEGINNING OF THE PERFORMANCE)
		tableicopy	gi2, gi1
		tableicopy	gi3, gi1
		tableicopy	gi4, gi1
		tableicopy	gi5, gi1
		tableicopy	gi6, gi1
		event_i		"i", 102, 0, 0.001									;RANDOMISE SLIDERS
endin

instr	102	;RANDOMISE SLIDERS
#define	RANDOMIZE_SLIDERS(COUNT)
	#
	iPch$COUNT	random	25,300										;DEFINE RANDOM INITIAL VALUES FOR 'TRANSPOSE' SLIDERS
				outvalue	"Transpose$COUNT", iPch$COUNT						;SEND RANDOM 'TRANSPOSE' VALUES TO SLIDERS
	iLen$COUNTDec	random	1,3											;DEFINE RANDOM INITIAL VALUES FOR 'RANGE' COUNTERS
	iLen$COUNTInt	random	4,8                                     			;DEFINE RANDOM INITIAL VALUES FOR 'RANGE' COUNTERS
	iLen$COUNT	=		(int(iLen$COUNTDec)*0.5)+int(iLen$COUNTInt)			;DEFINE RANDOM INITIAL VALUES FOR 'RANGE' COUNTERS
				outvalue	"Cycle$COUNT", iLen$COUNT						;SEND RANDOM 'RANGE' VALUES TO COUNTERS
	iDly$COUNT	random	0, 0.03										;DEFINE RANDOM INITIAL VALUES FOR 'TRANSPOSE' SLIDERS
				outvalue	"Delay$COUNT", iDly$COUNT						;SEND RANDOM 'DELAY' VALUES TO SLIDERS
	#

$RANDOMIZE_SLIDERS(1)
$RANDOMIZE_SLIDERS(2)
$RANDOMIZE_SLIDERS(3)
$RANDOMIZE_SLIDERS(4)
$RANDOMIZE_SLIDERS(5)
$RANDOMIZE_SLIDERS(6)
endin	

instr	998	;DUAL TEMPO DELAY
	aL		zar		giDlySndChn
	aR		zar		giDlySndChn+1
	kSwitch	changed	gkTempo, gkDelTim1, gkDelTim2 						;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then													;IF kSwitch=1, I.E. IF ANY OF THE ABOVE LISTED PARAMETERS HAVE CHANGED...
		reinit		START											;...PERFORM AN I-RATE PASS BEGINNING FROM THE GIVEN LABEL
	endif															;END OF CONDITIONAL BRANCHING
	START:															;A LABEL	
	ideltimL	=		(15*i(gkDelTim1))/i(gkTempo)
	ideltimR	=		(15*i(gkDelTim2))/i(gkTempo)
	abuffer	delayr	ideltimL
	atapL	deltap	ideltimL
			delayw	aL + (atapL*gkDlyFB)
	abuffer	delayr	ideltimR
	atapR	deltap	ideltimR
			delayw	aR + (atapR*gkDlyFB)
			outs		atapL, atapR
endin

instr 	999	;REVERB
	aL			zar		giRvbSndChn
	aR			zar		giRvbSndChn+1
				denorm	aL, aR										;DENORMALIZE BOTH CHANNELS OF AUDIO SIGNAL
	arvbL, arvbR 	reverbsc 	aL, aR, gkfblvl, gkfco, sr  ;, i(gkpitchm), i(gkskip) 
				outs		arvbL, arvbR
				zacl		1,8
endin
	
instr	1000	;UPDATE LOOP INDICATORS
	ktrigger	metro	10												;IF PERFORMANCE ISSUES ARISE REDUCING THIS VALUE MIGHT HELP
	if (ktrigger == 1)	then
			outvalue	"Phase1", gktimpnt1
			outvalue	"Phase2", gktimpnt2
			outvalue	"Phase3", gktimpnt3
			outvalue	"Phase4", gktimpnt4
			outvalue	"Phase5",	gktimpnt5
			outvalue	"Phase6", gktimpnt6
	endif
endin

instr	1001	;INIT

			;BUTTONS
			outvalue	"b1_01"		, 1
			outvalue	"b5_03"		, 1
			outvalue	"b2_05"		, 1
			outvalue	"b6_07"		, 1
			outvalue	"b3_09"		, 1
			outvalue	"b1_11"		, 1
			outvalue	"b4_13"		, 1
			outvalue	"b2_15"		, 1
			outvalue	"b4_17"		, 1
			outvalue	"b5_19"		, 1
			outvalue	"b2_21"		, 1
			outvalue	"b6_23"		, 1
			outvalue	"b1_25"		, 1
			outvalue	"b3_27"		, 1
			outvalue	"b2_29"		, 1
			outvalue	"b5_31"		, 1

			outvalue	"RvbSend"		, 0.4
			outvalue	"RvbTime"		, .7
			outvalue	"RvbCutoff"	, 10000
			outvalue	"DelSend"		, 0.2
			outvalue	"DelFB"		, .4
			outvalue	"DelayL"		, 12
			outvalue	"DelayR"		, 20
			outvalue	"Tempo"		, 220
			outvalue	"Master"		, .8

			outvalue	"Transpose1"	, 100
			outvalue	"Transpose2"	, 100
			outvalue	"Transpose3"	, 100
			outvalue	"Transpose4"	, 100
			outvalue	"Transpose5"	, 100
			outvalue	"Transpose6"	, 100

			outvalue	"Gain1"		, 1
			outvalue	"Gain2"		, 1
			outvalue	"Gain3"		, 1
			outvalue	"Gain4"		, 1
			outvalue	"Gain5"		, 1
			outvalue	"Gain6"		, 1

			outvalue	"Cycle1"		, 8
			outvalue	"Cycle2"		, 8
			outvalue	"Cycle3"		, 8
			outvalue	"Cycle4"		, 8
			outvalue	"Cycle5"		, 8
			outvalue	"Cycle6"		, 8
endin
</CsInstruments>
<CsScore>
i 200 0 3600			;GUI
i 100 0 0
i 998 0 3600			;DELAY
i 999 0 3600			;REVERB
i 1000 0 3600			;LOOP INDICATORS
i 1001 0.01 0.01		;INIT
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
  <width>1100</width>
  <height>575</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>                    Looping Sequencer With Individually Variable Length Loops</label>
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
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>287</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Send</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <objectName>RvbSend</objectName>
  <x>8</x>
  <y>265</y>
  <width>460</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RvbSend</objectName>
  <x>408</x>
  <y>287</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.400</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>402</y>
  <width>1092</width>
  <height>173</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This example expands on the design from the 'Simple Drum Sequencer' example. Besides expanding the basic loop length to 8 beats (32 semiquavers) the principle innovation is that the user can shorten the range of the loop for each sound. The moving green bars representing current loop position for each sound should help clarify exactly what is happening. Each beat is divided into four semiquavers so that 0.25 in the 'Cycle Length' value represents 1 semiquaver, a value of 1 represents 1 beat. If changes are made to cycle lengths, all loops will restart in order to resync. Notes that are outside the range of the loop for that sound will not be played. The sounds produced are kalimba-like sounds produced using Stefan Bilbao's 'barmodel' physical model. The pitch of each of the six sounds can be modified using the transpose sliders, they can be randomised on mass using the 'Randomize!' button and are in fact randomised automatically upon startup. The 'Delay' sliders allow each sound to be individually delayed by a small amount with respect to the others. This is intended to allow the creation of 'flam'-like gestures. A reverb effect (making use of the 'reverbsc' opcode) is included. A tempo synced delay effect is also included. Reverb times for the left and right channel are defined separately in semiquavers.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <y>10</y>
  <width>80</width>
  <height>26</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_01</objectName>
  <x>8</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e0d98327-53d4-45ac-8ca9-90d7c81b9abf}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_02</objectName>
  <x>22</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e34b7695-1411-4ebe-845c-8479f0cd6236}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_03</objectName>
  <x>36</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{deb8a71e-282b-4ff3-b319-ed6c9eb487ff}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_04</objectName>
  <x>50</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{2d4f45cd-61b1-47d0-b34d-b3b833eb99be}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_05</objectName>
  <x>69</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{14f87907-305f-4523-85b1-ef3b90e9290b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_06</objectName>
  <x>83</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{7dad608d-e194-4d05-8355-763b61b1140b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_07</objectName>
  <x>97</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3ae1333d-f2ec-4fff-b76e-d1b2ae7b69b3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_08</objectName>
  <x>111</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5aab1f61-3538-4087-bb69-229d195b8abb}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_09</objectName>
  <x>130</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{57115402-7c0a-4d58-a7c0-6921036520e7}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_10</objectName>
  <x>144</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{962914e8-a1b1-40e7-94e8-a6928dadbb05}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_11</objectName>
  <x>158</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e9e68a9d-773f-41bf-9c53-18709747d3f2}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_12</objectName>
  <x>172</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{108cea69-cc86-4271-986e-ab64c4441516}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_13</objectName>
  <x>191</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b3fe6a56-7815-41b7-9fbb-6cc773c106e3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_14</objectName>
  <x>205</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{6a5c3d2d-533f-49e0-8ca3-771bc6c833d9}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_15</objectName>
  <x>219</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{35b69a77-2a13-41a3-b89a-d60f9d703f04}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_16</objectName>
  <x>233</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{042cae7c-d764-4b9d-bb1b-a37f9bd193fb}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_17</objectName>
  <x>252</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{afbcb646-24c2-4635-ae97-f5711ffbd1e2}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_18</objectName>
  <x>266</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{7e63df9e-f27d-4c14-ab7e-c5194b03a269}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_19</objectName>
  <x>280</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a25e5d0c-0fa8-43c0-8b4a-295600ff824b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_20</objectName>
  <x>294</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b99769da-4a13-4fd0-a56e-3632dff9fa4f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_21</objectName>
  <x>313</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ce393610-824f-4ee6-945a-01e5481697ca}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_22</objectName>
  <x>327</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{d64cf679-83ad-4b7a-b185-9dd15e5d0b9b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_23</objectName>
  <x>341</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{33cad89c-1c3e-4c1b-9461-0d0700e7b2ac}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_24</objectName>
  <x>355</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{34da1ec2-30d3-435e-9666-62c0d0c54ff7}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_25</objectName>
  <x>374</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1380eff6-88fd-4fc0-9107-bd642e0f4bfe}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_26</objectName>
  <x>388</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f5e483ff-ff0d-4bf5-9db0-0c873dd74451}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_27</objectName>
  <x>402</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{edf90f66-5c14-4e89-94e0-7f66dc2cd48b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_28</objectName>
  <x>416</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f9e1c776-87e3-49fc-8e04-046ead2d87d5}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_29</objectName>
  <x>435</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{03a0de35-410b-4cc8-a495-e53411e6e261}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_30</objectName>
  <x>449</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{61578a6f-68dd-41bc-b005-f07d296d8370}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_31</objectName>
  <x>463</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{d4f5fbab-cf6b-4f2f-8ac7-6db8d5d4eb4c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_32</objectName>
  <x>477</x>
  <y>66</y>
  <width>16</width>
  <height>16</height>
  <uuid>{0cbb6633-4b84-47b0-8c4f-48ffb731b64e}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Phase1</objectName>
  <x>8</x>
  <y>85</y>
  <width>485</width>
  <height>6</height>
  <uuid>{c805b7f7-4837-4ecf-80ab-d20527ec3af1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>8.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>2.42731738</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_01</objectName>
  <x>8</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{466f6f3e-19ce-4127-8066-58f0acf681cf}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_02</objectName>
  <x>22</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{9489c14e-3304-418f-ae2a-582b81c39652}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_03</objectName>
  <x>36</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{fa686912-e64a-4c8d-82e9-070ce8e8f3db}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_04</objectName>
  <x>50</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{2c2e1632-80d0-4aa0-b79a-5c93e0033b59}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_05</objectName>
  <x>69</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{49cc7d17-6287-409b-842d-7a6e2ca0f4c3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_06</objectName>
  <x>83</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5f544eea-d621-4eb9-a39b-53764d54c0a1}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_07</objectName>
  <x>97</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{64e54194-310f-41ce-8ed3-2a3082b51484}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_08</objectName>
  <x>111</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{be9e0fbf-cf81-4231-bcce-e0ccce57af08}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_09</objectName>
  <x>130</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{bc6c60d3-f469-44a4-a778-a5a9f1c9d4d8}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_10</objectName>
  <x>144</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{9a6cf0f9-0577-49af-88d3-77cf6da550aa}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_11</objectName>
  <x>158</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{00ab751a-4f1d-4dbe-98c5-55f3827eb53e}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_12</objectName>
  <x>172</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{83429edf-248b-4978-9049-7c7631e47ce3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_13</objectName>
  <x>191</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a24c1cb1-dbb3-4178-a952-d7e53b742772}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_14</objectName>
  <x>205</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{49c0adba-c545-4633-9bd2-81fa22bb6cd0}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_15</objectName>
  <x>219</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{51c7fde2-38b3-4453-a1bc-95992648bbef}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_16</objectName>
  <x>233</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{7e58c1d2-882e-4468-b308-2cd448b9b8cd}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_17</objectName>
  <x>252</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ff88b2f3-0ca6-4aec-89ad-2c674a9fe1f3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_18</objectName>
  <x>266</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{717c7f6e-15cc-487d-9e94-bebbac89d9f7}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_19</objectName>
  <x>280</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{dc27da2d-f612-49a1-a9bf-e766af122b7b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_20</objectName>
  <x>294</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{33ad7ed7-02a9-46f8-a417-dd2954cb67ab}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_21</objectName>
  <x>313</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{580f19d7-8f81-4503-888e-72715d470842}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_22</objectName>
  <x>327</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{156d6455-f34c-446f-8e21-eb564a19bc84}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_23</objectName>
  <x>341</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{23c8103a-7f7a-419f-afc4-489f5cd609c5}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_24</objectName>
  <x>355</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a74dd030-843d-453b-a464-8c3b95167fe0}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_25</objectName>
  <x>374</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{2fdc5b9e-6086-43d4-a6f8-d548b56890c0}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_26</objectName>
  <x>388</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{39a062af-5e05-4df1-ae77-24903d6609db}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_27</objectName>
  <x>402</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{2cc59e4b-d52b-4030-b5d2-a5066f9f5cb1}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_28</objectName>
  <x>416</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{dd26b81b-192a-4328-b3fc-564d4ba7f350}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_29</objectName>
  <x>435</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{8afd7288-83f3-4b43-a3ea-33b192139fd3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_30</objectName>
  <x>449</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e23278bb-5a36-4936-bc93-772bc570c65e}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_31</objectName>
  <x>463</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{7b0d829e-ff65-498a-b9e5-1b6126620824}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_32</objectName>
  <x>477</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{59653cd9-bdb0-44b2-91db-2923b571eae0}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Phase2</objectName>
  <x>8</x>
  <y>117</y>
  <width>485</width>
  <height>6</height>
  <uuid>{6d6f60d4-ee09-4f65-be61-b9ee333409df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>8.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>6.42731810</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_01</objectName>
  <x>8</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{9310a4ba-e420-4a23-ba75-d1ec223de8f3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_02</objectName>
  <x>22</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{129cbb74-f667-4172-bc02-98f2c2262201}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_03</objectName>
  <x>36</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1fe654a9-720f-4df0-befd-0101147e4874}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_04</objectName>
  <x>50</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5b1f28c4-af08-4430-b960-3345d9dad3c6}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_05</objectName>
  <x>69</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5047e8ec-fc03-44ce-a51e-3f1893cb737e}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_06</objectName>
  <x>83</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f7704f0c-ba72-4c2d-bd25-17ff82e9beac}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_07</objectName>
  <x>97</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{34b705cc-3286-42e6-b96e-fcaaa8c802ef}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_08</objectName>
  <x>111</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5819c496-bb2f-4db8-91ea-cef8c4fb23ef}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_09</objectName>
  <x>130</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1db54791-aa1f-4d0c-808d-ad7159147e62}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_10</objectName>
  <x>144</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{2d9537a8-4fc6-4d70-bd4e-b64aa8aaa38a}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_11</objectName>
  <x>158</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{9bc44a82-0356-4789-831d-e664b0514eb5}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_12</objectName>
  <x>172</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e86c3a8a-16bf-4fd3-89f4-68cd349fde3b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_13</objectName>
  <x>191</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ff75b6e8-e2b3-46f1-89c4-293db41fec83}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_14</objectName>
  <x>205</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b9087786-b2a3-497f-bd7e-5219726e157f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_15</objectName>
  <x>219</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{d93b290b-e0bf-4fdd-9c1a-ecf26e19e0aa}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_16</objectName>
  <x>233</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{100384e2-c1f8-4eb4-a088-0e0769bde890}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_17</objectName>
  <x>252</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f9863d33-a600-4693-82c1-b03ee4e5b2c6}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_18</objectName>
  <x>266</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1dc708e7-e748-4410-bab4-f8ae212de9ed}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_19</objectName>
  <x>280</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{70e89fa7-cf00-4fc9-8358-fb182020edb3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_20</objectName>
  <x>294</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{52eca5dc-b91a-4e32-95a5-bc69a25e7752}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_21</objectName>
  <x>313</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{8fd3dcb0-fc46-4fe6-a886-4fba296ff70e}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_22</objectName>
  <x>327</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5fddfa0a-e5f6-4178-b7f6-b54ff4ee133b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_23</objectName>
  <x>341</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e6e9a495-ce5a-4b61-b9e2-101b076a6ab4}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_24</objectName>
  <x>355</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b514a3b9-0464-4252-a945-7039207b6f64}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_25</objectName>
  <x>374</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c68b979f-e1c5-46d0-be12-e3f3c2b7ae40}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_26</objectName>
  <x>388</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{832a3d31-b6ed-457c-b23b-77bf2da8ca4a}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_27</objectName>
  <x>402</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3f2b4a16-db0d-46ba-beb2-39bd62ef4c10}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_28</objectName>
  <x>416</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3a9870b9-9c17-4f37-9b73-46ba231bc6aa}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_29</objectName>
  <x>435</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a17a6442-56bc-4f76-8267-982ff0bbcdbf}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_30</objectName>
  <x>449</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{8bd8d89a-566c-4411-ac87-49c20a65d200}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_31</objectName>
  <x>463</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{7dca826a-f559-45a9-92ca-72c372b499ab}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_32</objectName>
  <x>477</x>
  <y>130</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e755171b-8073-48b8-ad20-1cb0ea368089}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Phase3</objectName>
  <x>8</x>
  <y>149</y>
  <width>485</width>
  <height>6</height>
  <uuid>{24ad48d7-576c-4dcc-b67f-5cb1f27f4970}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>8.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>6.42731810</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_01</objectName>
  <x>8</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{7db6ca86-c4b5-417b-a5db-299ccc215041}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_02</objectName>
  <x>22</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{26a453d0-1d7d-4c54-b524-b97178b9556a}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_03</objectName>
  <x>36</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3f779521-b9b8-42e9-9d54-fe5eb7d2c2e4}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_04</objectName>
  <x>50</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{d431479f-e815-45c7-9761-1cbd0a0037b6}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_05</objectName>
  <x>69</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5cf11534-0206-4171-9d37-1591b2de4870}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_06</objectName>
  <x>83</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3dd5b88a-5bbb-4eae-a6ca-f90bb1fa75b0}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_07</objectName>
  <x>97</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{46dce909-3c25-41c0-ac17-ea8ac8ea6220}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_08</objectName>
  <x>111</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{340356d9-08f7-4b6e-a80a-e59676409b75}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_09</objectName>
  <x>130</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ad84b6e6-0e9f-4826-9397-08e5fe9b9171}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_10</objectName>
  <x>144</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{474bbad6-a051-409d-a6b4-51d6607c0fe2}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_11</objectName>
  <x>158</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{01821513-13fc-4941-9a59-ecf75d877520}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_12</objectName>
  <x>172</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{482080c7-ba51-42b3-a776-c30277456b12}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_13</objectName>
  <x>191</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{735eadda-eac2-498f-8800-01dcee516fa9}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_14</objectName>
  <x>205</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c7134cf5-f77f-4646-b5ea-bd14c33e07e3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_15</objectName>
  <x>219</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{73741b81-357b-4d71-a627-e269b89cefc8}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_16</objectName>
  <x>233</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1495c3a7-f864-4fbd-96ad-a4c44d079c70}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_17</objectName>
  <x>252</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b27bfc51-96ad-4993-bc6d-1b3ac308977b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_18</objectName>
  <x>266</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{41297926-5d87-439f-9260-2b0b1b3e7297}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_19</objectName>
  <x>280</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{20cff291-a4e2-4255-9178-f8241737d67d}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_20</objectName>
  <x>294</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1d4019ba-c770-4661-b2ab-a5a037863274}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_21</objectName>
  <x>313</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{eed9a08a-0ea1-4c46-aee4-24c3bdc03d4c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_22</objectName>
  <x>327</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b98b3daa-d2a7-4c9b-be20-a7fda87e55e3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_23</objectName>
  <x>341</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{8d52a484-6a73-4be3-9b56-1c6dbb4a2e23}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_24</objectName>
  <x>355</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{665c8940-23b5-4ab4-be6d-a35a76c24381}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_25</objectName>
  <x>374</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ac949cc6-56de-45ac-a067-4a3b1b7638ff}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_26</objectName>
  <x>388</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{343598c1-5720-4541-b92b-2eb0aaf8952a}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_27</objectName>
  <x>402</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3d292f9a-7a6c-4e1f-84b4-4a86e4e3ec9c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_28</objectName>
  <x>416</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{73a80c78-0d72-40ba-b8fb-bab64ac0b47b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_29</objectName>
  <x>435</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ef99f346-6fa4-49bb-90e9-78661e29acf8}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_30</objectName>
  <x>449</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{352588ab-eb32-4194-8378-bde660b44851}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_31</objectName>
  <x>463</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b4508e12-d50e-4d0e-8b9f-70b4d1f616cf}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_32</objectName>
  <x>477</x>
  <y>162</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c93fa9a3-88e8-4c68-a24a-c978f37faa47}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Phase4</objectName>
  <x>8</x>
  <y>181</y>
  <width>485</width>
  <height>6</height>
  <uuid>{bbe69e47-5532-4c78-bf77-bd0806de8d9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>8.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>2.92731857</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_01</objectName>
  <x>8</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{406813a8-8f1c-45ab-9c0e-52e50bb2523b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_02</objectName>
  <x>22</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{76c5c22d-8698-4c86-b20e-bb3bc48ba11d}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_03</objectName>
  <x>36</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{6b205f01-9257-41c4-b960-fbe4b0f9f948}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_04</objectName>
  <x>50</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{95879c0c-0bc9-41d8-ac05-05661391d2ce}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_05</objectName>
  <x>69</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{59fa33f7-3f20-455a-83ea-0870ebede8cc}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_06</objectName>
  <x>83</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{0885ce2b-834c-40cb-b700-07e0fb9aa16c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_07</objectName>
  <x>97</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{dd572ad2-2dff-44c3-8040-2ebfc331b8e3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_08</objectName>
  <x>111</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{0069f6d3-8fa9-4def-99a0-5c4284469f73}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_09</objectName>
  <x>130</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{05d8ebd9-ff7c-44a5-b90f-bfca4064d0e9}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_10</objectName>
  <x>144</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{6d9db04c-cf68-4db2-9a81-61e5b62c1ca0}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_11</objectName>
  <x>158</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a3d10f55-501f-4979-b5eb-5ecb6a28dafb}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_12</objectName>
  <x>172</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{809aa4de-e111-44a3-8442-b1619af6b86e}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_13</objectName>
  <x>191</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c7f1358e-cc70-47b3-be7b-8139491d3e76}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_14</objectName>
  <x>205</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{29fa6ed0-6b2d-4741-9d86-c70f373df69b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_15</objectName>
  <x>219</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{42ab06cb-08f8-43dc-9a59-aacde5e174f5}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_16</objectName>
  <x>233</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1a16ac6a-0443-4a0a-adea-2f8895a54424}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_17</objectName>
  <x>252</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a4601b56-aa3e-4268-9128-5d8047150756}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_18</objectName>
  <x>266</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{419903f6-52db-418c-be0f-3623bccc34c4}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_19</objectName>
  <x>280</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3db21774-50ca-47e0-ac8f-fd09765a7db4}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_20</objectName>
  <x>294</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{50eb0bba-f57d-4226-9696-9579b55747f8}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_21</objectName>
  <x>313</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{9f229770-9924-48c9-b321-2fe37a4c30ed}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_22</objectName>
  <x>327</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b88669ff-8eb1-4068-be23-bae386dfec7c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_23</objectName>
  <x>341</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{19233b90-27d5-499b-ae88-55445b92e81c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_24</objectName>
  <x>355</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{28f4bd0c-b500-40ef-bd4c-2ffa3901a64e}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_25</objectName>
  <x>374</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3c35a41d-9563-4edb-a460-14a621c7ee9f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_26</objectName>
  <x>388</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{12cfab2b-16f0-480b-9cb9-4095d569032a}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_27</objectName>
  <x>402</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{d8db795e-8a58-4cf1-9e4a-cfc0d585bb12}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_28</objectName>
  <x>416</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{2660caa1-470b-4a59-a30a-bacd62b2850b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_29</objectName>
  <x>435</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ff86539d-a33b-4893-a4eb-098d7e79f751}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_30</objectName>
  <x>449</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{d451c1b9-ebd8-4c48-9ada-d67be8779d2f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_31</objectName>
  <x>463</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{00c7cf20-7894-4608-bed7-47c324390bfa}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_32</objectName>
  <x>477</x>
  <y>194</y>
  <width>16</width>
  <height>16</height>
  <uuid>{4d1c2eb9-a7df-4268-88cc-42b8705fcb12}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Phase5</objectName>
  <x>8</x>
  <y>213</y>
  <width>485</width>
  <height>6</height>
  <uuid>{ed21902f-baeb-49f6-b3b4-0cdccf6f6fe7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>8.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>2.42731738</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_01</objectName>
  <x>8</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{8129afea-11a9-4137-b681-895b01028071}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_02</objectName>
  <x>22</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{95153b14-fec9-48c4-8b26-cc0f87acbc36}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_03</objectName>
  <x>36</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a103e794-d3bc-4d32-ac9a-f6fda3046c48}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_04</objectName>
  <x>50</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{89146815-e0b5-4709-90c9-1957559e5bc4}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_05</objectName>
  <x>69</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1d4477fe-84a2-4ada-b1b0-25785e0ce053}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_06</objectName>
  <x>83</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{19a0bf7a-0d37-492c-883c-596a3fe0c42c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_07</objectName>
  <x>97</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a654f771-cee2-4eac-8e68-a2e23ab28c90}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_08</objectName>
  <x>111</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{575bd58d-1cd7-43c2-bc26-2e424f11a14c}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_09</objectName>
  <x>130</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{2cbf1035-4904-4d18-8b66-e8953f97b2ba}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_10</objectName>
  <x>144</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{92875694-ac1d-4b42-b31c-fc168cd05840}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_11</objectName>
  <x>158</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{60ec5c91-9991-4acb-af43-63aa7658024f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_12</objectName>
  <x>172</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5bd4ded7-6391-4424-b7c7-46e1fec06464}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_13</objectName>
  <x>191</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{336682ce-5f0f-4c05-83a0-bef8e69efc09}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_14</objectName>
  <x>205</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{83b606a0-dfbc-42fd-8ec1-a159ae814d55}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_15</objectName>
  <x>219</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{54c71d34-3408-4584-8f22-36199703f2e7}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_16</objectName>
  <x>233</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{9aac7a35-b925-4c35-80b0-70f8a2b19b6f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_17</objectName>
  <x>252</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b577ce0b-bf03-4ba6-9a65-8564912793a5}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_18</objectName>
  <x>266</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f129cddf-9854-4462-9630-5776e4f3b74f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_19</objectName>
  <x>280</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{85f2339a-9e88-42fb-ad0b-18f3ddab503f}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_20</objectName>
  <x>294</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{17cfa9e5-1dd1-4ffb-98e2-b84b7be32ad2}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_21</objectName>
  <x>313</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b6cfec2a-7120-4ff1-90af-699d812dbb71}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_22</objectName>
  <x>327</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{deffae90-e624-4375-8e67-19b16f1f7d13}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_23</objectName>
  <x>341</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f86a9e02-d551-4716-8bf4-f5fb874d2339}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_24</objectName>
  <x>355</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{573b7428-91d6-4369-bf58-fc1ec94e27f0}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_25</objectName>
  <x>374</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{3b6be76b-71a5-4cfa-a57d-48e7f6b02952}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_26</objectName>
  <x>388</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{5104a6f5-c16e-444c-b45d-e54d8f0cb284}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_27</objectName>
  <x>402</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b02d62ad-dca3-45ea-a7eb-ec77d6f45eb9}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_28</objectName>
  <x>416</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{dcecd73e-1574-4a86-b515-5836cbfb952d}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_29</objectName>
  <x>435</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c748b610-bcd3-4696-98d4-4e0630b6132b}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_30</objectName>
  <x>449</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{4b65b14c-2e70-4abc-8a21-c89084bb5b07}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_31</objectName>
  <x>463</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b1377fdb-b4bd-436c-82e4-e92a0a9af8a3}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_32</objectName>
  <x>477</x>
  <y>226</y>
  <width>16</width>
  <height>16</height>
  <uuid>{ace0cd67-a8ea-4945-ba1d-b9d5c2e67bee}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Phase6</objectName>
  <x>8</x>
  <y>245</y>
  <width>485</width>
  <height>6</height>
  <uuid>{de735a57-5ee9-40eb-abb7-493e6e396e60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>8.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.92731690</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
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
  <x>8</x>
  <y>41</y>
  <width>50</width>
  <height>25</height>
  <uuid>{ce031bf3-27d3-4f87-bf63-dd26d49d7497}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>69</x>
  <y>41</y>
  <width>50</width>
  <height>25</height>
  <uuid>{2ed7fe04-e9d4-4687-a4ca-c9261a5ad2d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>130</x>
  <y>41</y>
  <width>50</width>
  <height>25</height>
  <uuid>{fe29f849-dd8a-4734-991a-93653e2c0b16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>191</x>
  <y>42</y>
  <width>50</width>
  <height>25</height>
  <uuid>{361f49ca-de84-400a-b6c5-698aa12db8aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>252</x>
  <y>41</y>
  <width>50</width>
  <height>25</height>
  <uuid>{3cbd1a52-b714-4bad-9443-4de8646a59de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>313</x>
  <y>42</y>
  <width>50</width>
  <height>25</height>
  <uuid>{e417a667-3c4c-4098-8dff-3bfe67f5858c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>374</x>
  <y>41</y>
  <width>50</width>
  <height>25</height>
  <uuid>{ea421b55-45fb-416c-b972-53774de8db9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>435</x>
  <y>41</y>
  <width>50</width>
  <height>25</height>
  <uuid>{f94eaf23-aab3-4ca2-b20e-b02a755bd082}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>90</x>
  <y>10</y>
  <width>80</width>
  <height>26</height>
  <uuid>{3ec62cce-84d1-4781-ab0a-6189f9be68f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Randomize</text>
  <image>/</image>
  <eventLine>i 102 0 0.001</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Tempo</objectName>
  <x>230</x>
  <y>10</y>
  <width>54</width>
  <height>26</height>
  <uuid>{a73e949b-37c6-4ceb-9048-4d1b01561f3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <maximum>999</maximum>
  <randomizable group="0">false</randomizable>
  <value>220</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>11</y>
  <width>60</width>
  <height>30</height>
  <uuid>{75d8a74f-dbf7-405b-a4db-7e4440227227}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <objectName>Gain1</objectName>
  <x>503</x>
  <y>67</y>
  <width>170</width>
  <height>27</height>
  <uuid>{7fe81691-70ec-4282-9a2a-9cc5a9c6aa5c}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Transpose1</objectName>
  <x>742</x>
  <y>67</y>
  <width>170</width>
  <height>27</height>
  <uuid>{10ab0c67-4d18-4cdf-9b41-a1d2fc6199f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>25.00000000</minimum>
  <maximum>300.00000000</maximum>
  <value>207.07405090</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay1</objectName>
  <x>917</x>
  <y>67</y>
  <width>170</width>
  <height>27</height>
  <uuid>{29552893-1218-4400-a821-82a9e3ab1ee1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.02242109</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Cycle1</objectName>
  <x>678</x>
  <y>67</y>
  <width>60</width>
  <height>27</height>
  <uuid>{82ba499f-6f1b-461b-9837-52fd9cc6c4e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>5.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain2</objectName>
  <x>503</x>
  <y>98</y>
  <width>170</width>
  <height>27</height>
  <uuid>{cad3da27-3df0-4a5c-84c2-d2126137572b}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Transpose2</objectName>
  <x>742</x>
  <y>98</y>
  <width>170</width>
  <height>27</height>
  <uuid>{efa36d95-6b3b-4f63-919e-554f6664efec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>25.00000000</minimum>
  <maximum>300.00000000</maximum>
  <value>258.73852539</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay2</objectName>
  <x>917</x>
  <y>98</y>
  <width>170</width>
  <height>27</height>
  <uuid>{c32d3471-c00c-4bbb-983f-f9b18c640407}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.01556092</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Cycle2</objectName>
  <x>678</x>
  <y>98</y>
  <width>60</width>
  <height>27</height>
  <uuid>{83746c05-1c36-41e7-b310-bbe574493461}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>6.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain3</objectName>
  <x>503</x>
  <y>130</y>
  <width>170</width>
  <height>27</height>
  <uuid>{daab465a-5249-409e-ba93-b7c17f2b24ef}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Transpose3</objectName>
  <x>742</x>
  <y>130</y>
  <width>170</width>
  <height>27</height>
  <uuid>{5ec2ee39-3396-4241-872f-fac8cd1940b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>25.00000000</minimum>
  <maximum>300.00000000</maximum>
  <value>286.77276611</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay3</objectName>
  <x>917</x>
  <y>130</y>
  <width>170</width>
  <height>27</height>
  <uuid>{11db9f2a-8c2e-4d86-b25d-9daa402a3b30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00105907</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Cycle3</objectName>
  <x>678</x>
  <y>130</y>
  <width>60</width>
  <height>27</height>
  <uuid>{e1f48976-3ee3-44ec-9497-9ac1796d9f06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>6.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain4</objectName>
  <x>503</x>
  <y>162</y>
  <width>170</width>
  <height>27</height>
  <uuid>{a93be628-1544-46f7-8747-1a95d9feddd6}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Transpose4</objectName>
  <x>742</x>
  <y>162</y>
  <width>170</width>
  <height>27</height>
  <uuid>{2daee707-eba3-4e52-a4e4-235881e89e50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>25.00000000</minimum>
  <maximum>300.00000000</maximum>
  <value>72.86204529</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay4</objectName>
  <x>917</x>
  <y>162</y>
  <width>170</width>
  <height>27</height>
  <uuid>{a159be9d-8911-4182-82e6-cde9514b612f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00559661</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Cycle4</objectName>
  <x>678</x>
  <y>162</y>
  <width>60</width>
  <height>27</height>
  <uuid>{22479c32-cf5f-430f-bdbd-1d55eb32dbba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain5</objectName>
  <x>503</x>
  <y>194</y>
  <width>170</width>
  <height>27</height>
  <uuid>{baa2bfd0-8b1f-418b-abe1-1751b0ad79c6}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Transpose5</objectName>
  <x>742</x>
  <y>194</y>
  <width>170</width>
  <height>27</height>
  <uuid>{e0645640-8fa0-479d-a7c0-ef40c1dcd031}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>25.00000000</minimum>
  <maximum>300.00000000</maximum>
  <value>270.69818115</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay5</objectName>
  <x>917</x>
  <y>194</y>
  <width>170</width>
  <height>27</height>
  <uuid>{75a4910a-b2f5-4ba4-8ad4-87b3ffcf8b68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.01900059</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Cycle5</objectName>
  <x>678</x>
  <y>194</y>
  <width>60</width>
  <height>27</height>
  <uuid>{c86aaa79-c9ed-4066-ab93-11e40a920ce2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>5.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain6</objectName>
  <x>503</x>
  <y>226</y>
  <width>170</width>
  <height>27</height>
  <uuid>{92dccd93-a81b-4440-a666-9d3944400c22}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Transpose6</objectName>
  <x>742</x>
  <y>226</y>
  <width>170</width>
  <height>27</height>
  <uuid>{fae03a24-23ce-41f6-91ca-2a47ceeefab7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>25.00000000</minimum>
  <maximum>300.00000000</maximum>
  <value>241.10981750</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay6</objectName>
  <x>917</x>
  <y>226</y>
  <width>170</width>
  <height>27</height>
  <uuid>{12b91cb3-0a19-4ff2-882d-d8cb89ac8f3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00889438</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Cycle6</objectName>
  <x>678</x>
  <y>226</y>
  <width>60</width>
  <height>27</height>
  <uuid>{585aaa8a-36cb-40e6-a108-a33216932860}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>777</x>
  <y>43</y>
  <width>100</width>
  <height>25</height>
  <uuid>{35c715b1-7877-433b-b7ce-a792d5ae7a4d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transpose</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <x>940</x>
  <y>43</y>
  <width>120</width>
  <height>25</height>
  <uuid>{013f94f2-a46d-4191-a2f7-f12ee81e12c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay (0 - 0.1 s)</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <x>540</x>
  <y>43</y>
  <width>100</width>
  <height>25</height>
  <uuid>{7c945fd6-92be-427f-bceb-ab7630e97198}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <x>657</x>
  <y>43</y>
  <width>100</width>
  <height>25</height>
  <uuid>{d604a2a6-123b-4883-9e29-bf844e323419}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cycle Range</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <y>333</y>
  <width>220</width>
  <height>30</height>
  <uuid>{a79e966a-f875-4240-9f22-44a0a2fde9ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <objectName>RvbTime</objectName>
  <x>8</x>
  <y>311</y>
  <width>460</width>
  <height>27</height>
  <uuid>{774f68ec-19bc-4a55-9a46-523c4f691bc3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RvbTime</objectName>
  <x>408</x>
  <y>333</y>
  <width>60</width>
  <height>30</height>
  <uuid>{374358b4-4923-4722-a810-00f8348a4757}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.700</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>378</y>
  <width>220</width>
  <height>30</height>
  <uuid>{c585910c-5c7b-4b62-a1ee-621ef36f2471}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Filter Cutoff</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <objectName>RvbCutoff</objectName>
  <x>8</x>
  <y>356</y>
  <width>460</width>
  <height>27</height>
  <uuid>{6c2049fd-2453-4586-9e58-7fa6ed2c3f24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>20.00000000</minimum>
  <maximum>20000.00000000</maximum>
  <value>10000.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RvbCutoff</objectName>
  <x>408</x>
  <y>378</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e13cb450-7bfd-4035-b9c1-48b342dafb8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10000.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>503</x>
  <y>287</y>
  <width>220</width>
  <height>30</height>
  <uuid>{46b3098d-2d8a-41ff-8a9f-f113d48715e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Send</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <objectName>DelSend</objectName>
  <x>503</x>
  <y>265</y>
  <width>460</width>
  <height>27</height>
  <uuid>{2ada7bfe-15cb-4d69-ab5f-9b4345480ecc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DelSend</objectName>
  <x>903</x>
  <y>287</y>
  <width>60</width>
  <height>30</height>
  <uuid>{878936ab-0051-40f0-b47b-2669f4387f17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>503</x>
  <y>333</y>
  <width>220</width>
  <height>30</height>
  <uuid>{42e4795f-cf6e-4757-be63-c2570266d891}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Feedback</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <objectName>DelFB</objectName>
  <x>503</x>
  <y>311</y>
  <width>460</width>
  <height>27</height>
  <uuid>{2f0070a0-4431-470b-a38e-7d0e52e2c096}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DelFB</objectName>
  <x>903</x>
  <y>333</y>
  <width>60</width>
  <height>30</height>
  <uuid>{09e055ba-3e6d-429c-bb71-553883c7d68d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.400</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>DelayL</objectName>
  <x>589</x>
  <y>362</y>
  <width>50</width>
  <height>27</height>
  <uuid>{fdb65ab4-90b1-4893-a07e-662cf7259fea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>12</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>509</x>
  <y>364</y>
  <width>80</width>
  <height>27</height>
  <uuid>{a063b258-0c50-4391-aa2a-ccedcf10962c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay L</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>DelayR</objectName>
  <x>748</x>
  <y>362</y>
  <width>50</width>
  <height>27</height>
  <uuid>{f418902f-8559-4a3b-b3e8-70abec9d6edf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>20</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>668</x>
  <y>364</y>
  <width>80</width>
  <height>27</height>
  <uuid>{e6d42881-d69f-4ee0-932c-9ec0eee1921a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay R</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Master</objectName>
  <x>997</x>
  <y>270</y>
  <width>80</width>
  <height>80</height>
  <uuid>{65c8795c-6a2a-4322-a853-754ed13bf542}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>987</x>
  <y>350</y>
  <width>100</width>
  <height>40</height>
  <uuid>{1fa5fdb4-b075-4621-8e64-adef7ec31a27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Master
Gain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
