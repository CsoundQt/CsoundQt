;Written by Iain McCurdy, 2008

;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	used latched value type button and removed instr 10 to 15 to replace FLbutton


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 1		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0,0,4096,10,1	;SINE WAVE
gkphs	init		0

;FUNCTION TABLE FOR STORAGE OF SEQUENCE DATA FOR SOUND 1
gi1		ftgen	0,0,128,-2,	0,	0.25, .001,	0,\
							0,	0.5,	.001,	0,\
							0,	0.75, .001,	0,\
							0,	1,	.001,	0,\
							0,	1.25, .001,	0,\
							0,	1.5,	.001,	0,\
							0,	1.75, .001,	0,\
							0,	2,	.001,	0,\
							0,	2.25, .001,	0,\
							0,	2.5,	.001,	0,\
							0,	2.75, .001,	0,\
							0,	3,	.001,	0,\
							0,	3.25, .001,	0,\
							0,	3.5,	.001,	0,\
							0,	3.75, .001,	0,\
							0,	4,	.001,	0,\
							-1,	4,	-1,	-1

gi2		ftgen	0,0,128,-2,0			;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi3		ftgen	0,0,128,-2,0			;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi4		ftgen	0,0,128,-2,0			;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi5		ftgen	0,0,128,-2,0			;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1
gi6		ftgen	0,0,128,-2,0			;EMPTY TABLES INITIALLY. CONTENTS WILL BE COPIED FROM TABLE gi1


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkMasterGain	invalue	"Master"
		gkBPM		invalue	"Tempo"

#define	ROW1(COUNT)
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

		;SLIDERS
		gk$COUNTGain	invalue	"Gain$COUNT"
		#

		$ROW1(1)
		$ROW1(2)
		$ROW1(3)
		$ROW1(4)
		$ROW1(5)
		$ROW1(6)

	endif
endin

instr	1	; NOTE TRIGGERING INSTRUMENT
	kBPS		=		gkBPM/60							;CONVERT BEATS PER MINUTE TO BEATS PER SECOND
	isubdiv	=		4								;NUMBER OF SUBDIVISIONS OF THE BEAT
	kphs		phasor	kBPS/isubdiv						;CREATE MOVING PHASE VALUE 

	ktrigger	metro	10
	if ktrigger == 1 then
			outvalue	"Phase", kphs
	endif

	ktimpnt	=		kphs * isubdiv						;RESCALE POINTER
	kp1		init		0								;INITIALISE P-FIELD VALUES OUTPUT BY timedseq
	kp2		init		0					               ;INITIALISE P-FIELD VALUES OUTPUT BY timedseq
	kp3		init		0         						;INITIALISE P-FIELD VALUES OUTPUT BY timedseq
	kp4		init		0         						;INITIALISE P-FIELD VALUES OUTPUT BY timedseq
	
	ktrig	timedseq		ktimpnt,gi1, kp1, kp2,kp3, kp4						;CREATE NOTE TRIGGERS AND P-FIELDS FOR SOUND 1 FROM FUNCTION TABLE gi01 
	;		OPCODE	 	TRIGGER | MINTIM | MAXNUM | INSNUM | WHEN | DUR | P4 | P5
			schedkwhen 	ktrig,      0,       0,        2,     0,    kp3,  kp4,  1	;TRIGGER INTERROGATION INSTRUMENT
	
	ktrig	timedseq		ktimpnt,gi2, kp1, kp2,kp3, kp4						;CREATE NOTE TRIGGERS AND P-FIELDS FOR SOUND 2 FROM FUNCTION TABLE gi02 
	;		OPCODE 		TRIGGER | MINTIM | MAXNUM | INSNUM | WHEN | DUR | P4 | P5
			schedkwhen	ktrig,       0,       0,      2,       0,   kp3,   kp4, 2
	
	ktrig	timedseq		ktimpnt,gi3, kp1, kp2,kp3, kp4						;CREATE NOTE TRIGGERS AND P-FIELDS FOR SOUND 3 FROM FUNCTION TABLE gi03 
	;		OPCODE 		TRIGGER | MINTIM | MAXNUM | INSNUM | WHEN | DUR | P4 | P5
			schedkwhen	ktrig,       0,       0,      2,       0,   kp3,   kp4, 3
	
	ktrig	timedseq		ktimpnt,gi4, kp1, kp2,kp3, kp4						;CREATE NOTE TRIGGERS AND P-FIELDS FOR SOUND 4 FROM FUNCTION TABLE gi04 
	;		OPCODE 		TRIGGER | MINTIM | MAXNUM | INSNUM | WHEN | DUR | P4 | P5
			schedkwhen 	ktrig,       0,       0,      2,       0,   kp3,   kp4, 4
	
	ktrig	timedseq		ktimpnt,gi5, kp1, kp2,kp3, kp4						;CREATE NOTE TRIGGERS AND P-FIELDS FOR SOUND 5 FROM FUNCTION TABLE gi05 
	;		OPCODE 		TRIGGER | MINTIM | MAXNUM | INSNUM | WHEN | DUR | P4 | P5
			schedkwhen	ktrig,       0,       0,      2,       0,   kp3,   kp4, 5
	
	ktrig	timedseq		ktimpnt,gi6, kp1, kp2,kp3, kp4						;CREATE NOTE TRIGGERS AND P-FIELDS FOR SOUND 6 FROM FUNCTION TABLE gi06 
	;		OPCODE 		TRIGGER | MINTIM | MAXNUM | INSNUM | WHEN | DUR | P4 | P5
			schedkwhen 	ktrig,       0,       0,      2,       0,   kp3,   kp4, 6
endin

instr	2	;INTERROGATE EVENT AND DETERMINE WHETHER A SOUND SHOULD BE PLAYED OR NOT
	if	p4=1	then										;IF EVENT VARIABLE IS '1'...
		event_i	"i", p1+p5, 0, p3						;...PLAY A SOUND
	endif											;END OF CONDITIONAL BRANCH
endin

instr	3	;SOUND 1 - BASS DRUM
	p3		=		.2																;DEFINE DURATION FOR THIS SOUND
	aenv		expon	1,p3,0.001														;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	kcps		expon	200,p3,20															;PITCH GLISSANDO
	;OUTPUT	OPCODE	AMPLITUDE                             | FREQUENCY | FUNCTION_TABLE
	asig		oscil	aenv*i(gk1Gain)*i(gkMasterGain)*1.6,     kcps,       gisine 				;OSCILLATOR
			outs		asig, asig														;SEND AUDIO TO OUTPUTS
endin

instr	4	;SOUND 2 - KALIMBA (BAR MODEL)
	p3		=		2.6																;DEFINE DURATION FOR THIS SOUND
	asig 	barmodel	1, 1, 80, 1, 0, 2.6, 0.5, 6000, 0.07									;KALIMBA SOUND CREATED USING barmodel OPCODE (SEE CSOUND MANUAL FOR MORE INFO.)
			outs		asig*i(gk2Gain)*i(gkMasterGain), asig*i(gk2Gain)*i(gkMasterGain) 			;SEND AUDIO TO OUTPUTS AND ATTENUATE  USING GAIN CONTROLS
endin

instr	5	;SOUND 3 - SNARE
	p3		=		0.3																;DEFINE DURATION FOR THIS SOUND
	aenv		expon	1,p3,0.001														;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	anse		noise	1, 0 															;CREATE NOISE COMPONENT FOR SNARE DRUM SOUND
	kcps		expon	400,p3,20															;CREATE TONE COMPONENT FREQUENCY GLISSANDO FOR SNARE DRUM SOUND
	ajit		randomi	0.2,1.8,10000														;JITTER ON FREQUENCY FOR TONE COMPONENT
	atne		oscil	aenv*i(gk3Gain)*i(gkMasterGain),kcps*ajit,gisine							;CREATE TONE COMPONENT
	asig		sum		anse*0.5, atne*5													;MIX NOISE AND TONE SOUND COMPONENTS
	ares 	vcomb 	asig, 0.02, 0.0035, .1												;PASS SIGNAL THROUGH ACOMB FILTER TO CREATE STATIC HARMONIC RESONANCE
			outs		ares*aenv*i(gk3Gain)*i(gkMasterGain), ares*aenv*i(gk3Gain)*i(gkMasterGain)		;SEND AUDIO TO OUTPUTS, APPLY ENVELOPE AND ATTENTUATE USING GAIN CONTROLS 
endin

instr	6	;SOUND 4 - CLOSED HI-HAT
			turnoff2	7,0,0															;TURN OFF ALL INSTANCES OF instr 7 (OPEN HI-HAT)
	p3		=		0.1																;DEFINE DURATION FOR THIS SOUND
	aenv		expon	1,p3,0.001														;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	asig		noise	aenv*i(gk4Gain)*i(gkMasterGain), 0										;CREATE SOUND FOR CLOSED HI-HAT
	asig		buthp	asig, 7000														;HIGHPASS FILTER SOUND
			outs		asig, asig														;SEND AUDIO TO OUTPUTS
endin

instr	7	;SOUND 5 - OPEN HI-HAT
	p3		=		1																;DEFINE DURATION FOR THIS SOUND
	aenv		expon	1,p3,0.001														;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	asig		noise	aenv*i(gk5Gain)*i(gkMasterGain), 0										;CREATE SOUND FOR CLOSED HI-HAT
	asig		buthp	asig, 7000														;HIGHPASS FILTER SOUND	
			outs		asig, asig														;SEND AUDIO TO OUTPUTS
endin

instr	8	;SOUND 6 - TAMBOURINE
	p3		=		0.5																;DEFINE DURATION FOR THIS SOUND
	asig		tambourine	i(gk6Gain)*i(gkMasterGain)*0.3,0.01 ,32, 0.47, 0, 2300 , 5600, 8000		;TAMBOURINE SOUND CREATED USING tambourine PHYSICAL MODELLING OPCODE (SEE CSOUND MANUAL FOR MORE INFO.)
			outs		asig, asig														;SEND AUDIO TO OUTPUTS
endin

instr	100	;COPY TABLE 1 TO ALL OTHER TABLES (PERFORMED ONCE AT THE BEGINNING OF THE PERFORMANCE)
		tableicopy	gi2, gi1
		tableicopy	gi3, gi1
		tableicopy	gi4, gi1
		tableicopy	gi5, gi1
		tableicopy	gi6, gi1
endin

instr	101	;SET INITIAL PATTERN, init Gain sliders and BPM
		outvalue	"b1_01"	,1
		outvalue	"b1_04"	,1
		outvalue	"b1_09"	,1
		outvalue	"b1_11"	,1
		outvalue	"b1_14"	,1

		outvalue	"b2_05"	,1
		outvalue	"b2_16"	,1

		outvalue	"b3_05"	,1
		outvalue	"b3_08"	,1
		outvalue	"b3_13"	,1
		outvalue	"b3_15"	,1

		outvalue	"b4_01"	,1
		outvalue	"b4_02"	,1
		outvalue	"b4_04"	,1
		outvalue	"b4_05"	,1
		outvalue	"b4_06"	,1
		outvalue	"b4_09"	,1
		outvalue	"b4_10"	,1
		outvalue	"b4_12"	,1
		outvalue	"b4_13"	,1
		outvalue	"b4_14"	,1

		outvalue	"b5_03"	,1
		outvalue	"b5_07"	,1
		outvalue	"b5_11"	,1
		outvalue	"b5_15"	,1

		outvalue	"b6_01"	,1
		outvalue	"b6_03"	,1
		outvalue	"b6_05"	,1
		outvalue	"b6_07"	,1
		outvalue	"b6_09"	,1
		outvalue	"b6_11"	,1
		outvalue	"b6_13"	,1
		outvalue	"b6_15"	,1

		outvalue	"Gain1"	, 0.7
		outvalue	"Gain2"	, 0.7
		outvalue	"Gain3"	, 0.7
		outvalue	"Gain4"	, 0.7
		outvalue	"Gain5"	, 0.7
		outvalue	"Gain6"	, 0.7

		outvalue	"Tempo"	, 100
		outvalue	"Master"	, .5
endin

instr	102	;CLEAR ALL PATTERNS
#define	ROW2(COUNT)
		#
		outvalue	"b$COUNT_01"	,0
		outvalue	"b$COUNT_02"	,0
		outvalue	"b$COUNT_03"	,0
		outvalue	"b$COUNT_04"	,0
		outvalue	"b$COUNT_05"	,0
		outvalue	"b$COUNT_06"	,0
		outvalue	"b$COUNT_07"	,0
		outvalue	"b$COUNT_08"	,0
		outvalue	"b$COUNT_09"	,0
		outvalue	"b$COUNT_10"	,0
		outvalue	"b$COUNT_11"	,0
		outvalue	"b$COUNT_12"	,0
		outvalue	"b$COUNT_13"	,0
		outvalue	"b$COUNT_14"	,0
		outvalue	"b$COUNT_15"	,0
		outvalue	"b$COUNT_16"	,0
		#

		$ROW2(1)
		$ROW2(2)
		$ROW2(3)
		$ROW2(4)
		$ROW2(5)
		$ROW2(6)
endin
</CsInstruments>
<CsScore>
i  10 0	3600		;GUI

i 100 0 0			;TRIGGER INITIALISATION PASS IN INSTR 100 AT THE BEGINNING OF THE PERFORMANCE
i 101 0 0			;SET INITIAL PATTERN
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>592</x>
 <y>125</y>
 <width>1087</width>
 <height>237</height>
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
  <width>520</width>
  <height>230</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Phase</objectName>
  <x>94</x>
  <y>48</y>
  <width>246</width>
  <height>8</height>
  <uuid>{c805b7f7-4837-4ecf-80ab-d20527ec3af1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.29167607</xValue>
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
  <x>168</x>
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
  <x>346</x>
  <y>59</y>
  <width>170</width>
  <height>27</height>
  <uuid>{7fe81691-70ec-4282-9a2a-9cc5a9c6aa5c}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain2</objectName>
  <x>346</x>
  <y>86</y>
  <width>170</width>
  <height>27</height>
  <uuid>{cad3da27-3df0-4a5c-84c2-d2126137572b}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain3</objectName>
  <x>346</x>
  <y>113</y>
  <width>170</width>
  <height>27</height>
  <uuid>{daab465a-5249-409e-ba93-b7c17f2b24ef}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain4</objectName>
  <x>346</x>
  <y>140</y>
  <width>170</width>
  <height>27</height>
  <uuid>{a93be628-1544-46f7-8747-1a95d9feddd6}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain5</objectName>
  <x>346</x>
  <y>167</y>
  <width>170</width>
  <height>27</height>
  <uuid>{baa2bfd0-8b1f-418b-abe1-1751b0ad79c6}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain6</objectName>
  <x>346</x>
  <y>194</y>
  <width>170</width>
  <height>27</height>
  <uuid>{92dccd93-a81b-4440-a666-9d3944400c22}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>379</x>
  <y>36</y>
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
  <x>244</x>
  <y>12</y>
  <width>100</width>
  <height>27</height>
  <uuid>{1fa5fdb4-b075-4621-8e64-adef7ec31a27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Master</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>62</y>
  <width>90</width>
  <height>27</height>
  <uuid>{799f606d-0dc8-4d56-876e-8d19ad2bfa0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Kick</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>197</y>
  <width>90</width>
  <height>27</height>
  <uuid>{a069b7b4-9f26-4533-b22b-2284f2251bab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tambourine</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>170</y>
  <width>90</width>
  <height>27</height>
  <uuid>{5839d8c6-d9fe-4409-a105-223ebc326540}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>H.H. Open</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>143</y>
  <width>90</width>
  <height>27</height>
  <uuid>{a300072a-9261-407f-af73-77f6ea5f8bd8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>H.H. Closed</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>116</y>
  <width>90</width>
  <height>27</height>
  <uuid>{eedb6f2a-9f20-4d12-b5e3-2b081ebe178b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Snare</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>89</y>
  <width>90</width>
  <height>27</height>
  <uuid>{95ca45ce-d1cc-4857-8bcf-577ab9688bfb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Kalimba</label>
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
  <objectName>Master</objectName>
  <x>346</x>
  <y>10</y>
  <width>170</width>
  <height>27</height>
  <uuid>{dde9c0e0-feb6-4cea-8aa8-1280db717ed9}</uuid>
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
  <x>523</x>
  <y>2</y>
  <width>553</width>
  <height>230</height>
  <uuid>{793616e9-fcef-413e-8cea-62f867ee7fe0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Simple Drum Sequencer </label>
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
  <x>526</x>
  <y>18</y>
  <width>547</width>
  <height>212</height>
  <uuid>{85ea7331-9e49-47fd-a9fd-6deefcf11558}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------
This example demonstrates how to contruct a simple looping drum sequencer. Sequence data (i.e. play/don't play) is stored is GEN 2 function tables. This data is retrieved and played the 'timedseq' and 'schedkwhen' opcodes. Each time a sequence event is changed the function table corresponding to that sound is updated with the new data. Tempo is adjustable and there is a gain control for each sound as well as a master gain control. An additional feature is that sound 4 (closed hi-hat) will cut off sound 5 (open hi-hat) as would happen with a real hi-hat. Sounds are produced using either simple synthesis or one of Csound's physical modelling opcodes. Obviously there are numererous programs and plugins that perform a similar task but this example at least serves to prove that this can be done in Csound and there remains to possibility to expand this technique into something much more unique.
</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Tempo</objectName>
  <x>230</x>
  <y>10</y>
  <width>54</width>
  <height>26</height>
  <uuid>{8de111c2-b353-4fa7-bb5d-1899fc8aed93}</uuid>
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
  <value>100</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>90</x>
  <y>10</y>
  <width>80</width>
  <height>26</height>
  <uuid>{87532365-175f-42d5-9a79-95db88d67a73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Clear All</text>
  <image>/</image>
  <eventLine>i 102 0 0.01</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>94</x>
  <y>60</y>
  <width>62</width>
  <height>158</height>
  <uuid>{cf038cc8-fdc0-4fd5-827d-bf86758ac3ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>155</x>
  <y>60</y>
  <width>62</width>
  <height>158</height>
  <uuid>{3a375fc3-ccec-4468-8880-d39414cc6b03}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>216</x>
  <y>60</y>
  <width>62</width>
  <height>158</height>
  <uuid>{1689408d-186b-4b53-a285-f0b29a902643}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>277</x>
  <y>60</y>
  <width>62</width>
  <height>158</height>
  <uuid>{73e6f290-3b31-4935-897d-067ec76a98e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_01</objectName>
  <x>98</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{ce8d1df6-7aed-4eb6-b661-34bf1ce85c5a}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_02</objectName>
  <x>112</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{0e777ba7-3410-4845-a21f-886bdba4e628}</uuid>
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
  <x>126</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{87a0bd4c-bdcc-4e76-85af-fea30330efdc}</uuid>
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
  <x>140</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{fa42994e-6a12-45f7-9a03-b435581fd70f}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_05</objectName>
  <x>159</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{9255c6d7-8592-4f3a-980d-c31958074667}</uuid>
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
  <x>173</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{67f1edce-6fbe-46da-bac5-35f5467bda14}</uuid>
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
  <x>187</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{ff2dcede-72c6-4558-b71e-1599220d1ad6}</uuid>
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
  <x>201</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{47ff1b6f-eb9c-4f5c-890b-6982ad558174}</uuid>
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
  <x>220</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{1e7a81aa-21f0-4567-aa7e-585a69e0b3c5}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_10</objectName>
  <x>234</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{4ac3b878-7434-440d-916c-e9f5964f3c2b}</uuid>
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
  <x>248</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{80ed7782-3799-43dd-b8d2-20d63528ac12}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_12</objectName>
  <x>262</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{e0e96f32-b40f-496a-989a-322807069c75}</uuid>
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
  <x>281</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{f6e854b0-4847-4531-a9b6-01c58e7f8bd9}</uuid>
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
  <x>295</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{bad9d9e5-49b3-43e3-a621-b0b10a220150}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b1_15</objectName>
  <x>309</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{90fcb57a-0484-4e0a-87cc-5e1f7d81ba76}</uuid>
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
  <x>323</x>
  <y>66</y>
  <width>12</width>
  <height>12</height>
  <uuid>{c92e9ed8-d3aa-4825-84af-fdeaa6381cf7}</uuid>
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
  <objectName>b2_01</objectName>
  <x>98</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{1f9c3e28-04d7-42ce-98b4-bb9d08d9c106}</uuid>
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
  <x>112</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{bc415054-ec7b-4a80-bad8-866ce4f24de7}</uuid>
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
  <x>126</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{b3488f04-e5c8-47e3-a513-9c38391d2ae6}</uuid>
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
  <x>140</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{84bba0a1-3eae-4f83-9049-d78ecae906dd}</uuid>
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
  <x>159</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{1c934054-4fdf-41f2-b57e-73a817f16b31}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b2_06</objectName>
  <x>173</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{52f72206-60cc-4bbb-8e9f-6a6a62c6e7d4}</uuid>
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
  <x>187</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{6bfdfa60-d7a5-456f-929a-d565abf70fc5}</uuid>
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
  <x>201</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{978d7acc-f95b-4397-bb6d-cc57b31d610b}</uuid>
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
  <x>220</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{f1ea5972-21a0-46d3-820a-36a9fbcb8e3d}</uuid>
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
  <x>234</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{02f8493b-a6e5-4ba7-9f67-58efc594f37c}</uuid>
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
  <x>248</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{bee9fdd0-d65a-4aa2-8d6d-28eb110d51f7}</uuid>
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
  <x>262</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{05b12f9a-03f1-4859-841b-ba09a0c82f66}</uuid>
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
  <x>281</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{a37e8bc3-8a5a-4555-bc62-10e4f3610f0f}</uuid>
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
  <x>295</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{d041c432-b707-4e3a-b033-5d3f4c627643}</uuid>
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
  <x>309</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{30299b92-e228-4b81-9784-810cab650261}</uuid>
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
  <x>323</x>
  <y>92</y>
  <width>12</width>
  <height>12</height>
  <uuid>{5323b54b-5eaf-41cb-ac4f-bd68d2fa57d1}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_01</objectName>
  <x>98</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{355cd186-7e4d-419e-a67d-ff1c41b7f209}</uuid>
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
  <x>112</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{bed09d2d-9572-4779-bf09-569e3933558c}</uuid>
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
  <x>126</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{c3a9cde7-ff4f-4c11-b0e5-ed0dbbf93866}</uuid>
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
  <x>140</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{83e2161f-05d6-43d4-b205-b3b889a8feb0}</uuid>
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
  <x>159</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{2b822cfd-01b8-4f73-be5d-e09723cc4d92}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_06</objectName>
  <x>173</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{d2b1c66a-4665-4b69-8de4-6fd0caffb4bb}</uuid>
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
  <x>187</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{fd87970f-2a0f-4048-988a-5a337fcdb9ea}</uuid>
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
  <x>201</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{1be94c56-f9a6-42a7-9846-d8bd04d608e9}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_09</objectName>
  <x>220</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{8a0ba066-10dc-4308-8609-d018d9a0150c}</uuid>
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
  <x>234</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{8fe24a2a-c622-4e0e-9ac9-871940c87ab5}</uuid>
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
  <x>248</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{61aff54a-62a8-4c29-8f79-d4c038e1b952}</uuid>
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
  <x>262</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{1f465e2f-425f-421c-9c0e-fa3b84837bdd}</uuid>
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
  <x>281</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{54d62e02-b7f9-4032-bb79-db63a5354fdb}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_14</objectName>
  <x>295</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{7a6f22ac-10e7-434f-a6b0-aa3dda949bdd}</uuid>
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
  <x>309</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{f41feed7-ad59-43ba-94ad-68fa26352e02}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b3_16</objectName>
  <x>323</x>
  <y>119</y>
  <width>12</width>
  <height>12</height>
  <uuid>{91e641eb-d441-4625-bf59-25f749a95bf2}</uuid>
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
  <objectName>b4_01</objectName>
  <x>98</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{8feed011-e74f-4b27-a0b2-ffbcc586dfe3}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_02</objectName>
  <x>112</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{16255632-2ef5-4f3f-b0a6-d580da5d3c18}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_03</objectName>
  <x>126</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{b8c47df7-0663-4af1-a82b-f42389c5fbdc}</uuid>
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
  <x>140</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{f7c5fdc9-bb8b-42f9-8133-57b39357ae0b}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_05</objectName>
  <x>159</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{3f428cd2-a71d-47bc-b3b0-09e87a98eb89}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_06</objectName>
  <x>173</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{6741defa-188b-45d4-b99d-15a77e2b32c9}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_07</objectName>
  <x>187</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{33daa0ea-6a06-45e1-8beb-a381a09a37c7}</uuid>
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
  <x>201</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{d502900b-ec7e-4c6c-a18d-ac34a27e688d}</uuid>
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
  <x>220</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{66fe5e86-f7a4-49f5-b677-36a9046b58b1}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_10</objectName>
  <x>234</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{f1a1bb45-d5ea-4b22-819c-677407f2a154}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_11</objectName>
  <x>248</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{692f5def-e081-4870-bcf6-5457aca8e6a4}</uuid>
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
  <x>262</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{2d88faef-6f59-4684-a06e-f23eb5268f5b}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_13</objectName>
  <x>281</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{0aef476d-d124-45e8-a600-6344a2fa3abe}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_14</objectName>
  <x>295</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{3941f152-5f52-4310-87a5-c8acb4b5809e}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b4_15</objectName>
  <x>309</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{dccfb348-6615-46b4-bc46-0469edf7fdd9}</uuid>
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
  <x>323</x>
  <y>147</y>
  <width>12</width>
  <height>12</height>
  <uuid>{055638b6-405e-4555-bed9-55160d4817da}</uuid>
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
  <objectName>b5_01</objectName>
  <x>98</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{2f2241c7-3fdd-4f7a-8655-acfd95478894}</uuid>
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
  <x>112</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{424f7f63-b503-41b1-8db2-2514c77ed38a}</uuid>
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
  <x>126</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{92a89b33-fb02-44a0-8bdf-de7aa384724a}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_04</objectName>
  <x>140</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{e07753a0-63cb-4cc4-bbca-b3feeaf215ed}</uuid>
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
  <x>159</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{d7b45bd3-380e-4abf-9472-ff181d524518}</uuid>
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
  <x>173</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{108763b6-df3d-4b0b-91c6-9b6e7e418f7d}</uuid>
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
  <x>187</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{0ee71ff1-9f88-463b-a9b9-a1500d5369da}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_08</objectName>
  <x>201</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{42e941ec-cde1-40e6-9642-39bc8b1780f8}</uuid>
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
  <x>220</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{889287d2-c5f8-4bac-9254-59da7a1e67ad}</uuid>
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
  <x>234</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{2816988c-d63f-42f3-94e3-17801a06a95a}</uuid>
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
  <x>248</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{556837c1-53e7-4f79-96dc-892e6c5fc76d}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_12</objectName>
  <x>262</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{309909dc-8ee0-45b1-9141-b31231ba5ae0}</uuid>
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
  <x>281</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{45c9c804-dddb-4647-bdfd-b605eba8f237}</uuid>
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
  <x>295</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{8cfa2c24-9a4a-4dae-9506-978cdac83586}</uuid>
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
  <x>309</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{6a38e4e4-105e-446f-914d-74d800aa81e8}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b5_16</objectName>
  <x>323</x>
  <y>172</y>
  <width>12</width>
  <height>12</height>
  <uuid>{2d93a5ae-9b07-4f39-a9ca-4ec61cdbaa88}</uuid>
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
  <objectName>b6_01</objectName>
  <x>98</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{133726a9-8bf7-4e85-986c-255fb1f5fc1b}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_02</objectName>
  <x>112</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{431f14c0-2f9e-4ef1-952f-3658008a2ae4}</uuid>
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
  <x>126</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{d146299a-e12e-4901-9bff-6d120833cdae}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_04</objectName>
  <x>140</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{bde61ba2-f697-4153-a1d4-e89a8c7e5555}</uuid>
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
  <x>159</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{f4f79600-c08b-487a-a1a6-a12a0cfd6abd}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_06</objectName>
  <x>173</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{ce82549e-927b-4af0-955f-d226ca4d9c58}</uuid>
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
  <x>187</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{8ebd0823-c297-4156-b4f8-63a0c6fa6ea4}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_08</objectName>
  <x>201</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{658d65fa-a1d0-4035-b868-8e54c19c6faa}</uuid>
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
  <x>220</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{ef081c4b-87d8-481c-9aa3-382c3cc73180}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_10</objectName>
  <x>234</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{3340e9ff-c720-4591-9295-78bc790c60c7}</uuid>
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
  <x>248</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{266a7ebf-acd8-4142-9b3b-734678016cad}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_12</objectName>
  <x>262</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{286686f4-98f2-4fb3-ad86-3c37fa3dfe6b}</uuid>
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
  <x>281</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{8555bfc8-de1e-416f-8065-c7a7814c7648}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_14</objectName>
  <x>295</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{7557db22-c5ce-42f9-8fd7-355d4cce9a14}</uuid>
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
  <x>309</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{9c6b87ad-ac32-4cea-91c1-98485f4be9ad}</uuid>
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
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>b6_16</objectName>
  <x>323</x>
  <y>199</y>
  <width>12</width>
  <height>12</height>
  <uuid>{8a9e80d1-e43c-43d2-8126-f006785ae67d}</uuid>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
