;Written by Iain McCurdy,

;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817
;	RATTLES AND RUBBERS DOESN'T SEEM TO WORK AT PRESENT IN CSOUND


;Notes on modifications from original csd:
;	Add tables for exp slider
;	Init instrument added

;	Info panel:
;    			                     prepiano
;	---------------------------------------------------------------------------------------------------------------------------
;	The prepiano opcode implements a physical model of a Cagian prepared piano. The user has control of the base frequency of
;	a string (or group of strings), the number of strings beneath the hammer, the amount of detuning between a group of
;	strings, the stiffness of the strings, the time for a note to decay by 30 dB, the amount of high frequency damping that
;	occurs during a note's decay, the mass of the hammer, the frequency of the hammer's natural vibrations, the location
;	along the string's length at which the hammer strikes and the velocity of the hammer as it moves to strike the string.
;	The user can choose the method of restraint applied to the string independently for its left and right extremities.
;	Choosing 'clamped' reflects the normal method of binding a piano string, 'pivoting' reflects the method used to bind a
;	note on a marimba and 'free' means that the string extremity is not bound at all.
;	To imbue the sound with some movement the author has imagined the sound being received by a pick-up that moves to
;	and from along the length of the string. 'Scanning Spread' controls the amplitude of this movement and 'Scanning
;	Frequency' controls the frequency of this movement. The methods of Cagian piano preparation that are implemented
;	in this opcode are the addition of hard objects that vibrate in sympathy with the string but are not firmly attached to
;	it rattles and soft objects that damp the string (rubbers). For rattles the user is able to define its position along the
;	string, the mass/density ratio between rattle and string, its frequency and its length.
;	For rubbers the user can define position, mass/density ratio, frequency and loss.
;	By using function tables for the definition of rubbers and rattles it is possible to have any amount of them applied to
;	the same string. Unfortunately the rattles and rubbers part of the Csound implementation of this physical model do not
;	appear to work so I have only supplied user control for one rattle and one rubber (which don't work anyway).
;	As with many physical models we have the opportunity to specify conditions that would not be possible in the real
;	world, for this reason it is easily to produce mathematical procedures that quickly 'blow up' and produce extremely loud
;	and distorted sounds. Approach parameter changes with caution and protect your ears and speakers.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)


;DEFINE FUNCTION TABLES FOR RATTLES AND RUBBERS
;	 						COUNT | POSITION | MASS DENSITY RATIO OF RATTLE/STRING | FREQUENCY OF RATTLE | VERTICAL LENGTH OF THE RATTLE/ RUBBER LOSS
girattles	ftgen	0, 0, 8, -2,	1,		.6,				.1,						100,					10
girubbers	ftgen	0, 0, 8, -2,	1,		.7,				.1,						500,					.1

;TABLE FOR EXP SLIDER
giExp1	ftgen	0, 0, 129, -25, 0, 20.0, 128, 10000.0
giExp2	ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0


instr	100	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkrattle1		invalue	"Rattle"
		gkposRat1		invalue	"posRat"
		gkMDRRat1		invalue	"MDRRat"
		gkFrqRat1		invalue	"FrqRat"
		gkLenRat1		invalue	"LenRat"

		gkrubber1		invalue	"Rubber"
		gkposRub1		invalue	"posRub"
		gkMDRRub1		invalue	"MDRRub"
		gkFrqRub1		invalue	"FrqRub"
		gkLosRub1		invalue	"LosRub"

		kfreqS		invalue	"StrFreq"
		gkfreqS		tablei	kfreqS, giExp1, 1
					outvalue	"StrFreq_Value", gkfreqS
		gkD			invalue	"Detuning"
		gkK			invalue	"Stiffness"
		gkT30		invalue	"30DT"
		gkB			invalue	"HFLoss"
		gkmass		invalue	"HammerMass"
		kfreqH		invalue	"HammerFreq"
		gkfreqH		tablei	kfreqH, giExp2, 1
					outvalue	"HammerFreq_Value", gkfreqH
		gkinit		invalue	"HammerInitPos"
		gkpos		invalue	"HammerPosStr"
		gkvel		invalue	"StringVel"
		gksfreq		invalue	"ScanFreq"
		gksspread		invalue	"ScanFreqSpread"
		gkOutGain		invalue	"OutGain"
		gkNS			invalue	"NumbStr"
		gkbcL		invalue	"bcL"
		gkbcR		invalue	"bcR"
	endif
endin

instr	1	;(ALWAYS ON - SEE SCORE) PLAYS FILE AND SENSES FADER MOVEMENT AND RESTARTS INSTR 2 FOR I-RATE CONTROLLERS
		
	;;;THE FOLLOWING LINES OF CODE UPDATE THE FUNCTION TABLE CONTENTS FOR RATTLES AND RUBBERS - UNFORTUNATELY THIS FEATURE DOESN'T SEEM TO WORK AT PRESENT IN CSOUND
#define		VAR		#gkrattle1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+2, 0, .001, $VAR
	
#define		VAR		#gkposRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+3, 0, .001, $VAR
	
#define		VAR		#gkMDRRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+4, 0, .001, $VAR
	
#define		VAR		#gkFrqRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+5, 0, .001, $VAR
	
#define		VAR		#gkLenRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+6, 0, .001, $VAR
	
#define		VAR		#gkrubber1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+7, 0, .001, $VAR
	
#define		VAR		#gkposRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+8, 0, .001, $VAR
	
#define		VAR		#gkMDRRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+9, 0, .001, $VAR
	
#define		VAR		#gkFrqRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+10, 0, .001, $VAR
	
#define		VAR		#gkLosRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+11, 0, .001, $VAR
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ktrigger		changed	gkfreqS, gkD, gkK, gkT30, gkB, gkmass, gkfreqH, gkinit, gkpos, gkvel, gksfreq, gksspread, gkNS, gkrattle1, gkposRat1, gkMDRRat1, gkFrqRat1, gkLenRat1, gkrubber1, gkposRub1, gkMDRRub1, gkFrqRub1, gkLosRub1	;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
;						TRIGGER  | IMINTIM | IMAXNUM | IINSNUM | IWHEN | IDUR (-1 MEANS A NOTE OF INFINITE DURATION)
			schedkwhen	ktrigger,     0,        0,        2,        0,    -1					;RESTART INSTRUMENT 2 WITH A SUSTAINED (HELD) NOTE WHENEVER kSwitch=1
endin

instr	2	;SOUND PRODUCING INSTRUMENT
	;OUTPUTS	OPCODE	BASE-FREQ  | NUM_OF_STRINGS | DETUNING | STIFFNESS | 30 DB DECAY TIME | HIGH_FREQUENCY_LOSS | LEFT_BOUNDARY_CONDITION | RIGHT_BOUNDARY_CONDITION | HAMMER_MASS | HAMMER_FREQUENCY | HAMMER_INITIAL_POSITION | POSITION_ALONG_STRING | HAMMER_VELOCITY | SCANNING_FREQ | SCANNING_FREQ_SPREAD | RATTLES_FUNCTION_TABLE | RUBBERS_FUNCTION_TABLE             
	al, ar	prepiano 	i(gkfreqS),     i(gkNS),       i(gkD),     i(gkK),      i(gkT30),             i(gkB),                 gkbcL+1,                   gkbcR+1,            i(gkmass),     i(gkfreqH),             i(gkinit),              i(gkpos),            i(gkvel),       i(gksfreq),        i(gksspread),            girattles,               girubbers
			outs		al * gkOutGain, ar * gkOutGain
endin

instr	3,4,5,6,7		;UPDATE RATTLES FUNCTION TABLE
	tableiw 	p4, p1-3, girattles
endin

instr	8,9,10,11,12	;UPDATE RUBBERS FUNCTION TABLE
	tableiw 	p4, p1-8, girubbers
endin

instr	200	;INIT
		outvalue	"StrFreq"			, 0.26
		outvalue	"NumbStr"			, 3
		outvalue	"Detuning"		, 0
		outvalue	"Stiffness"		, 1
		outvalue	"30DT"			, 3
		outvalue	"HFLoss"			, .002
		outvalue	"bcL"			, 2
		outvalue	"bcR"			, 2
		outvalue	"HammerMass"		, 1
		outvalue	"HammerFreq"		, 0.8
		outvalue	"HammerInitPos"	, -.01
		outvalue	"HammerPosStr"		, .09
		outvalue	"StringVel"		, 50
		outvalue	"ScanFreq"		, 0
		outvalue	"ScanFreqSpread"	, .1
		outvalue	"OutGain"			, .5

		outvalue	"Rattle"			, 1
		outvalue	"posRat"			, .6
		outvalue	"MDRRat"			, .1
		outvalue	"FrqRat"			, 100
		outvalue	"LenRat"			, .1

		outvalue	"Rubber"			, 1
		outvalue	"posRub"			, .7
		outvalue	"MDRRub"			, .1
		outvalue	"FrqRub"			, 500
		outvalue	"LosRub"			, .1
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1		0		3600
i 100	0		3600		;GUI
i 200	0		0.1		;INIT
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
  <width>1023</width>
  <height>607</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>prepiano</label>
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
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>77</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>String Frequency (i-rate)</label>
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
  <objectName>StrFreq</objectName>
  <x>8</x>
  <y>57</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>StrFreq_Value</objectName>
  <x>448</x>
  <y>77</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.662</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>14</y>
  <width>120</width>
  <height>30</height>
  <uuid>{e40c02c1-81d8-4459-938d-9e77ae8e081e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Note On / Off</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>518</x>
  <y>418</y>
  <width>500</width>
  <height>100</height>
  <uuid>{a21b6db2-5090-4663-b2de-b6685e7f2d95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Physical model of a Cageian prepared piano.
Algorithm written by Stefan Bilbao.
Opcode ported for Csound by John ffitch.
Example written by Iain McCurdy.</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>167</y>
  <width>220</width>
  <height>30</height>
  <uuid>{126e87c3-8382-48d7-9f69-d7ffccf30307}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Stiffness (i-rate)</label>
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
  <objectName>Stiffness</objectName>
  <x>8</x>
  <y>147</y>
  <width>500</width>
  <height>27</height>
  <uuid>{436e054c-3a03-4bcb-95be-d3d4182eb85c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-100.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Stiffness</objectName>
  <x>448</x>
  <y>167</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e0681007-f414-48ae-84d9-0fbba93c58c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <y>122</y>
  <width>220</width>
  <height>30</height>
  <uuid>{a87b27cc-bc96-4b29-9677-682e316d9b4d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Detuning (i-rate)</label>
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
  <objectName>Detuning</objectName>
  <x>8</x>
  <y>102</y>
  <width>500</width>
  <height>27</height>
  <uuid>{86b4ad35-b12a-4ab9-b344-09172118e0b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Detuning</objectName>
  <x>448</x>
  <y>122</y>
  <width>60</width>
  <height>30</height>
  <uuid>{92311d9a-da30-4af3-84f6-0c49a990db9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <y>212</y>
  <width>220</width>
  <height>30</height>
  <uuid>{8dfbef14-56ca-4b84-b240-6d04bb2c1ae1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>30 dB Decay time (i-rate)</label>
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
  <objectName>30DT</objectName>
  <x>8</x>
  <y>192</y>
  <width>500</width>
  <height>27</height>
  <uuid>{690f907d-2cd9-47de-a7dc-327507391fb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>30.00000000</maximum>
  <value>3.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>30DT</objectName>
  <x>448</x>
  <y>212</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3e957d6d-7cfe-478b-8a7a-8533fe10751f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3.000</label>
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
  <y>257</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d586223e-5a9a-4e2d-86c8-7b43d306bd5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>High Frequency Loss (i-rate)</label>
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
  <objectName>HFLoss</objectName>
  <x>8</x>
  <y>237</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a118f008-d3cd-4b4b-8382-0b95756b7f05}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>HFLoss</objectName>
  <x>448</x>
  <y>257</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c03464a4-fd79-4a65-aa5a-598495964bfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.002</label>
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
  <y>302</y>
  <width>220</width>
  <height>30</height>
  <uuid>{fdfdf2ac-ef3f-4331-a400-59d9a5daa767}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Hammer Mass (i-rate)</label>
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
  <objectName>HammerMass</objectName>
  <x>8</x>
  <y>282</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d17a0978-b780-493c-9a30-3dc8d5883146}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>HammerMass</objectName>
  <x>448</x>
  <y>302</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5dcc1d22-735c-4bea-b699-077117f98c5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <y>392</y>
  <width>220</width>
  <height>30</height>
  <uuid>{71e6a282-2ab6-46f6-a0ed-b85f1c7e15b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Hammer Initial Position (i-rate)</label>
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
  <objectName>HammerInitPos</objectName>
  <x>8</x>
  <y>372</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88eb1332-f82d-41d1-81e6-708c546d9d32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>-0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>HammerInitPos</objectName>
  <x>448</x>
  <y>392</y>
  <width>60</width>
  <height>30</height>
  <uuid>{49e9d58a-f523-4036-8232-4e5bf01a6e7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.010</label>
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
  <y>347</y>
  <width>220</width>
  <height>30</height>
  <uuid>{87f26ca4-2db8-4185-8c84-4e1ce3d54704}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Hammer Frequency (i-rate)</label>
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
  <objectName>HammerFreq</objectName>
  <x>8</x>
  <y>327</y>
  <width>500</width>
  <height>27</height>
  <uuid>{42134457-b4cf-4163-889a-6e8bdbf7a18d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>HammerFreq_Value</objectName>
  <x>448</x>
  <y>347</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a369d53f-a407-4760-a01c-da504cd12a24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5025.538</label>
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
  <y>437</y>
  <width>220</width>
  <height>30</height>
  <uuid>{02e28cb2-13c2-4711-bcc7-ab0064b94720}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Hammer Position Along String (i-rate)</label>
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
  <objectName>HammerPosStr</objectName>
  <x>8</x>
  <y>417</y>
  <width>500</width>
  <height>27</height>
  <uuid>{63b8e4cc-0721-4001-854a-cd1a1702a526}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00400000</minimum>
  <maximum>0.99600000</maximum>
  <value>0.09000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>HammerPosStr</objectName>
  <x>448</x>
  <y>437</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f4e74c63-a005-4dc3-a458-670b14fcd5a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.090</label>
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
  <y>482</y>
  <width>220</width>
  <height>30</height>
  <uuid>{11774312-f30e-47e2-82ad-91aacc0655e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Normalised String Velocity (i-rate)</label>
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
  <objectName>StringVel</objectName>
  <x>8</x>
  <y>462</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c0712931-0b9f-41e0-89f6-423c7168d3d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>50.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>StringVel</objectName>
  <x>448</x>
  <y>482</y>
  <width>60</width>
  <height>30</height>
  <uuid>{350c87da-03d7-4b73-a0e4-a070f47db9e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>50.000</label>
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
  <y>527</y>
  <width>220</width>
  <height>30</height>
  <uuid>{ce3fc0e6-e898-401a-b231-b0630597b627}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Scanning Frequency (i-rate)"</label>
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
  <objectName>ScanFreq</objectName>
  <x>8</x>
  <y>507</y>
  <width>500</width>
  <height>27</height>
  <uuid>{170052ec-d982-474d-a790-941d150a418b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ScanFreq</objectName>
  <x>448</x>
  <y>527</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4692ad47-e4f8-44b8-a8b9-3092572406c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <x>517</x>
  <y>572</y>
  <width>220</width>
  <height>30</height>
  <uuid>{bfea4810-1819-47d0-9e54-c621b9457a65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <objectName>OutGain</objectName>
  <x>517</x>
  <y>552</y>
  <width>500</width>
  <height>27</height>
  <uuid>{1219981f-96c7-4c4e-b323-5618efbc38b1}</uuid>
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
  <objectName>OutGain</objectName>
  <x>957</x>
  <y>572</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f8220f0d-67a3-4996-8fd3-df2d68dbd348}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <y>572</y>
  <width>220</width>
  <height>30</height>
  <uuid>{59341b34-9c0e-4350-9a12-720655f5e414}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Scanning Frequency Spread (i-rate)</label>
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
  <objectName>ScanFreqSpread</objectName>
  <x>8</x>
  <y>552</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c85f37ac-5428-491d-bfa1-3ab2a861ecc9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ScanFreqSpread</objectName>
  <x>448</x>
  <y>572</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0471d44f-9ed3-4663-a728-362d11727168}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
  <x>518</x>
  <y>115</y>
  <width>500</width>
  <height>100</height>
  <uuid>{3f0f6653-bb33-47c7-8d04-8e91d69f9e45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rattle 1</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>613</x>
  <y>164</y>
  <width>80</width>
  <height>50</height>
  <uuid>{d1b644c3-0c6c-4d73-827d-0e89b7ca09b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Position</label>
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
  <x>713</x>
  <y>164</y>
  <width>80</width>
  <height>50</height>
  <uuid>{4f6ecb39-332e-4821-85a5-a019a092ff94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mass
Density
Ratio</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>posRat</objectName>
  <x>613</x>
  <y>136</y>
  <width>80</width>
  <height>30</height>
  <uuid>{5e98811a-ff43-4250-a418-c4a414d1c396}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.6</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>MDRRat</objectName>
  <x>713</x>
  <y>136</y>
  <width>80</width>
  <height>30</height>
  <uuid>{898bdcc6-e952-49f2-9b51-9b58e406639d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>813</x>
  <y>164</y>
  <width>80</width>
  <height>50</height>
  <uuid>{29f045a1-7728-4b6a-9ff6-de076ef00be6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>FrqRat</objectName>
  <x>813</x>
  <y>136</y>
  <width>80</width>
  <height>30</height>
  <uuid>{55c018d2-2a51-4ee6-a4a1-5a01cf61188a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <minimum>0</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>100</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>913</x>
  <y>164</y>
  <width>80</width>
  <height>50</height>
  <uuid>{dec8c13d-881c-48df-a101-fd8fe40eed7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Length</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>LenRat</objectName>
  <x>913</x>
  <y>136</y>
  <width>80</width>
  <height>30</height>
  <uuid>{52ba9f86-1994-497b-89b6-777a49c7a995}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>518</x>
  <y>337</y>
  <width>500</width>
  <height>68</height>
  <uuid>{48beae5a-470d-4a21-89d7-b610b999079d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Boundary Condition</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>671</x>
  <y>358</y>
  <width>40</width>
  <height>30</height>
  <uuid>{ed09a043-e2d8-4158-bc76-b3378f199768}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>L</label>
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
  <x>858</x>
  <y>358</y>
  <width>40</width>
  <height>30</height>
  <uuid>{6a0c7846-df6c-4af2-9619-665491d0e5ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>R</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>bcL</objectName>
  <x>712</x>
  <y>358</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d9ae99ca-c298-4362-8e65-77791e8352ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Clamped</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pivoting</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Free</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>bcR</objectName>
  <x>899</x>
  <y>358</y>
  <width>100</width>
  <height>30</height>
  <uuid>{918a69f2-09e7-42e7-97fd-e2b550f11677}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Clamped</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pivoting</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Free</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>590</x>
  <y>60</y>
  <width>120</width>
  <height>30</height>
  <uuid>{a3ad4fa4-3aa7-4dc9-a785-579406e79709}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Strings</label>
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
  <objectName>NumbStr</objectName>
  <x>713</x>
  <y>56</y>
  <width>50</width>
  <height>30</height>
  <uuid>{ddb7a386-dde5-446d-b3a6-b61bdd1f2533}</uuid>
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
  <minimum>2</minimum>
  <maximum>50</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Rattle</objectName>
  <x>545</x>
  <y>151</y>
  <width>16</width>
  <height>16</height>
  <uuid>{77710ef6-e1b6-4dee-baa2-c7aa4c401729}</uuid>
  <visible>true</visible>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>514</x>
  <y>166</y>
  <width>80</width>
  <height>30</height>
  <uuid>{60ad5f87-337d-4fe2-a7c0-86e1af01dc14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
  <x>518</x>
  <y>225</y>
  <width>500</width>
  <height>100</height>
  <uuid>{aadf418c-5f4b-40f1-bbb1-a310a2946c15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rubber 1</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>613</x>
  <y>274</y>
  <width>80</width>
  <height>50</height>
  <uuid>{d5d999c9-634c-4357-8d95-1a11e33b079e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Position</label>
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
  <x>713</x>
  <y>274</y>
  <width>80</width>
  <height>50</height>
  <uuid>{9d7246c4-496d-454a-b28f-8ab7f035157e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mass
Density
Ratio</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>posRub</objectName>
  <x>613</x>
  <y>246</y>
  <width>80</width>
  <height>30</height>
  <uuid>{f98230c1-1b5c-413b-bdc0-e5d404d1ea60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>MDRRub</objectName>
  <x>713</x>
  <y>246</y>
  <width>80</width>
  <height>30</height>
  <uuid>{9dd539c6-ce85-4d65-8552-e1b51e4bc74d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>813</x>
  <y>274</y>
  <width>80</width>
  <height>50</height>
  <uuid>{fa4a4597-7015-4c11-9e6b-65a3fae5f4a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>FrqRub</objectName>
  <x>813</x>
  <y>246</y>
  <width>80</width>
  <height>30</height>
  <uuid>{3a933db9-04fa-4bb0-9d23-3de214efd82e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <minimum>0</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>500</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>913</x>
  <y>274</y>
  <width>80</width>
  <height>50</height>
  <uuid>{4684fd72-91e0-467e-98ab-16b3aba3b37d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loss</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>LosRub</objectName>
  <x>913</x>
  <y>246</y>
  <width>80</width>
  <height>30</height>
  <uuid>{42076dc7-1734-42c5-a31e-f3d2bc40d00b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Rubber</objectName>
  <x>545</x>
  <y>261</y>
  <width>16</width>
  <height>16</height>
  <uuid>{42cced17-179c-4511-bd64-b8defb66530f}</uuid>
  <visible>true</visible>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>514</x>
  <y>276</y>
  <width>80</width>
  <height>30</height>
  <uuid>{bbaec2dc-9e4a-43bd-b67e-3230e57047bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
