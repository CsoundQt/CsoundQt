;Writen by Iain McCurdy

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Use Pitch Bend wheel
; Use Mod wheel (CC#01) for VIBRATO AMPLITUDE
; Use MIDI CC#74 for VIBRATO FREQUENCY
; Use MIDI CC#71 for FILTER BASE FREQUENCY
; Use MIDI CC#91 for FILTER RESONANCE

;Notes on modifications from original csd:
;	Use Preset 0 for INIT
;	Macro MIDI_CC and MIDI CC number change


;my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;INITIALISE GLOBAL VARIABLES
gaSend		init		0

;INITIALISE MIDI CONTROLERS
;				CH | CC | VAL
		initc7	1,    1,   0		;VIBRATO AMPLITUDE
		initc7	1,    74,  .25		;VIBRATO FREQUENCY
		initc7	1,    71,  .5		;FILTER BASE FREQUENCY
		initc7	1,    91,  .5/.9	;FILTER RESONANCE


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkRes		invalue	"FilterReso"
		gkBaseFrq		invalue	"FilterFreq"
		gkDlyAmt		invalue	"DelaySend"
		gkDlyTim		invalue	"DelayTime"
		gkDlyFB		invalue	"DelayFeedback"

		gkgliss		invalue	"PortTim"
		gkamp		invalue	"Amp"
		gktrmdep		invalue	"TremAmt"
		gkvibdep		invalue	"VibAmt"
		gkmodfreq		invalue	"ModFrq"
		gkpw			invalue	"PW"
		gkleak		invalue	"Leak"
		gknyx		invalue	"Harms"
		gkmul		invalue	"Mul"

		gkPStrLev		invalue	"P_StrLev"
		gkPAttTim		invalue	"P_AttTim"
		gkPAttLev		invalue	"P_AttLev"
		gkPDecTim		invalue	"P_DecTim"
		gkPRelTim		invalue	"P_RelTim"
		gkPRelLev		invalue	"P_RelLev"

		gkFAttTim		invalue	"F_AttTim"
		gkFAttLev		invalue	"F_AttLev"
		gkFDecTim		invalue	"F_DecTim"
		gkFSusLev		invalue	"F_SusLev"
		gkFRelTim		invalue	"F_RelTim"
		gkFRelLev		invalue	"F_RelLev"
		gkFEnvAmt		invalue	"F_EnvAmt"

		gkAAttTim		invalue	"A_AttTim"
		gkAAttLev		invalue	"A_AttLev"
		gkADecTim		invalue	"A_DecTim"
		gkASusLev		invalue	"A_SusLev"
		gkARelTim		invalue	"A_RelTim"
		gkARelLev		invalue	"A_RelLev"

		gkBendRnge	invalue	"Bend_Range"
		gkwave		invalue	"Waveform"
		gkwave		=		gkwave + 1
		gkharm		invalue	"Nb_Harms"
		gklh			invalue	"Lowest_Harm"
	endif

;UPDATING DUAL MODE MIDI/GUI VALUATORS
#define	MIDI_CC(NAME'WIDGET'Chan'CC'min'Max)
#
	k$NAME		ctrl7	$Chan,$CC,$min,$Max							;READ MIDI CONTROLLER
	ktrig$NAME	changed	k$NAME									;CREATE A TRIGGER PULSE IF MIDI CONTROLLER IS MOVED
	if ktrig$NAME = 1 then
		outvalue	"$WIDGET", k$NAME									;UPDATE VALUATOR IF MIDI CONTROLLER HAS BEEN MOVED
	endif
#

$MIDI_CC(modfreq'ModFrq'1'74'0'20)

$MIDI_CC(BaseFrq'FilterFreq'1'71'4'14)

$MIDI_CC(Res'FilterReso'1'91'0'1)

endin
	
instr	1	;RECEIVES MIDI NOTE INPUT - TRIGGERS ONE NOTE AT A TIME
	;READ VALUES FOR FREQUENCY FROM A MIDI KEYBOARD 
	icps		cpsmidi
	
	;PITCH BEND INFORMATION IS READ
	iSemitoneBendRange 	init	i(gkBendRnge)								;PITCH BEND RANGE IN SEMITONES
	imin 		= 		0										;EQUILIBRIUM POSITION
	imax 		= 		iSemitoneBendRange * .0833333					;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend		pchbend	imin, imax								;PITCH BEND VARIABLE (IN oct FORMAT)
	gkbendmlt		=		cpsoct(8+kbend)/cpsoct(8.00)					;CREATE A MULTIPLIER THAT WHEN MULTIPLIED TO THE FREQUENCY OF AN OSCILLATOR WILL IMPLEMENT PITCH BEND
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	iporttime		=		.03										;VALUE USED AS PORTAMENTO TIME FOR OTHER VALUATORS
	kporttime		linseg	0,(.001),iporttime,(1),iporttime				;RAMPING UP VARIABLE IS CREATED THAT WILL BE USED AT PORTAMENTO TIME
	kpw			portk	gkpw, kporttime							;PORTAMENTO IS APPLIED TO gkpw VARIABLE
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	kmodwhl		ctrl7	1,1,0,1
	imodwave		=		1
	kmod			oscil	1, gkmodfreq, imodwave
	gkvib		=		(kmod * kmodwhl * gkvibdep) + 1
	gktrm		=		1 - (kmod * .5 * gktrmdep * kmodwhl) - (gktrmdep * .5 * kmodwhl)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	;AMPLITUDE ENVELOPE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	aAEnv		linsegr	0, i(gkAAttTim), i(gkAAttLev), i(gkADecTim), i(gkASusLev), i(gkARelTim), i(gkARelLev)
	
	;PITCH MULTIPLIER ENVELOPE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	kPEnv		linsegr	i(gkPStrLev), i(gkPAttTim), i(gkPAttLev), i(gkPDecTim), 1, i(gkPRelTim), i(gkPRelLev)
	
	if	gkwave==4	goto	SKIP1	;IF gkwave=4 (I.E. 'BUZZ') JUMP TO LABEL 'SKIP1'
	
	;VCO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifn			=		1										;FUNCTION TABLE FOR A SINE WAVE THAT WILL BE USED BY VCO
	imaxd		=		1										;MAXIMUM DELAY TIME				
	asig			vco	 	gkamp*gktrm*0.3, icps*gkvib*kPEnv*gkbendmlt, i(gkwave), kpw, ifn, imaxd, i(gkleak), i(gknyx);, 0, 0
	goto	ESCAPE1		;JUMP TO LABEL 'ESCAPE1'
	
	;GBUZZ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SKIP1:			;LABEL 'SKIP1'
	;OUTPUT		OPCODE	AMPLITUDE     |         FREQUENCY         | NO.OF_HARMONICS | LOWEST_HARMONIC | POWER | FUNCTION_TABLE
	asig			gbuzz 	gkamp*gktrm,    icps*gkvib*kPEnv*gkbendmlt,      gkharm,            gklh,        gkmul,       2
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ESCAPE1:		;LABEL 'ESCAPE1'
	
	;FILTER ENVELOPE - ALL LEVELS ARE GIVEN IN OCT FORMAT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	kFEnv		linsegr	0, i(gkFAttTim), i(gkFAttLev), i(gkFDecTim), i(gkFSusLev), i(gkFRelTim), i(gkFRelLev)
	
	kBaseFrq		lineto	gkBaseFrq, kporttime						;APPLY LINETO SMOOTHING TO gkBaseFrq (CUTOFF FREQUENCY) VARIABLE
	kCFoct		=		(kFEnv*gkFEnvAmt) + kBaseFrq					;FINAL FILTER CUTOFF VALUE (IN CPS) INCORPORATING THE FILTER ENVELOPE AND THE FILTER BASE LEVEL
	kCFoct		limit	kCFoct, 4, 14								;LIMIT FILTER CUTOFF RANGE - THIS PREVENTS THE POSSIBILITY OF CRASHES OR NASTY NOISES DUE TO MASSIVELY OUT OF RANGE CUTOFF RANGES
	kCFcps		=		cpsoct(kCFoct)								;CONVERT CUTOFF VALUE FROM AN OCT FORMAT VALUE INTO A CPS VALUE
	
	;CREATE A FILTERED VERSION OF THE OSCILLATOR SIGNAL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	aFilt		moogladder asig, kCFcps, gkRes
	
	aFilt		=		aFilt * aAEnv								;APPLY AMPLITUDE ENVELOPE
	
	;SEND FILTERED SIGNAL TO OUTPUT
				outs		aFilt, aFilt
	gaSend		=		gaSend+(aFilt*gkDlyAmt)						;CREATE AN EFFECTS SEND AUDIO SIGNAL WHICH IS SENT TO THE DELAY EFFECT INSTRUMENT
endin
	
instr	3	; PING PONG DELAY
	imaxdelay		=		2									;MAXIMUM DELAY TIME
	
	;LEFT CHANNEL OFFSETTING DELAY (NO FEEDBACK!)
	aBuffer		delayr	imaxdelay*.5
	aLeftOffset	deltap3	gkDlyTim*.5
				delayw	gaSend
			
	;LEFT CHANNEL DELAY WITH FEEDBACK
	aFBsigL		init		0
	aBuffer		delayr	imaxdelay
	aDlySigL		deltap3	gkDlyTim
				delayw	aLeftOffset+aFBsigL
	aFBsigL		=		aDlySigL * gkDlyFB
	
	;RIGHT CHANNEL DELAY WITH FEEDBACK
	aFBsigR		init		0
	aBuffer		delayr	imaxdelay
	aDlySigR		deltap3	gkDlyTim
				delayw	gaSend+aFBsigR
	aFBsigR		=		aDlySigR * gkDlyFB
	
				outs		aDlySigL+aLeftOffset, aDlySigR			;SEND DELAY OUTPUT SIGNALS TO THE SPEAKERS
	gaSend		=		0									;RESET EFFECTS SEND GLOBAL AUDIO VARIABLE TO PREVENT STUCK VALUES WHEN INSTR 1 STOPS PLAYING
endin

instr	4	; INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
f 1 0 131072 10 1  		;A SINE WAVE - USED BY BOTH THE VIBRATO AND THE vco
f 2 0 65536 9 1 1 90  	;COSINE WAVE (USED BY GBUZZ)

i  3 0 3600			;INSTRUMENT 3 PLAYS FOR 1 HOUR
i 10 0 3600			;INSTRUMENT 10 PLAYS FOR 1 HOUR

i  4 0.1 0			;init
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>275</x>
 <y>165</y>
 <width>1104</width>
 <height>656</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>170</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>589</x>
  <y>2</y>
  <width>511</width>
  <height>654</height>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>596</x>
  <y>327</y>
  <width>495</width>
  <height>292</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------
This example is merely a polyphonic version of the monophonic synthe of the previous example.

Additional MIDI controllers are:
* CC#74 - Low frequency modulation frequency
* CC#71 - Lowpass filter cutoff frequency
* CC#91 - Resonance of the filter

Additionally the signal is passed through a stereo ping-pong delay.
Pitch bend is implemented, the depth of which can be set by the user in the interface.</label>
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
  <x>2</x>
  <y>2</y>
  <width>586</width>
  <height>654</height>
  <uuid>{9cb1f282-09da-4c18-87db-ffd36d585a0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Polyphonic MIDI Synth</label>
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
  <x>595</x>
  <y>44</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2e52a7a7-dc13-405e-896d-db2a7431d8dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Resonance</label>
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
  <objectName>FilterReso</objectName>
  <x>595</x>
  <y>27</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6ab84e0f-82a7-4b9c-af23-35bd7d9b7fa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.55400002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FilterReso</objectName>
  <x>1035</x>
  <y>44</y>
  <width>60</width>
  <height>30</height>
  <uuid>{99d6bf8b-3c85-4911-a29a-7dd678a940ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.554</label>
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
  <x>595</x>
  <y>91</y>
  <width>180</width>
  <height>30</height>
  <uuid>{a8da19ef-d61e-452d-af2c-a79924c6890d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Base Freq</label>
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
  <objectName>FilterFreq</objectName>
  <x>595</x>
  <y>74</y>
  <width>500</width>
  <height>27</height>
  <uuid>{be1cab81-da6b-442b-bcc8-22c97579c797}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>14.00000000</maximum>
  <value>7.46000004</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FilterFreq</objectName>
  <x>1035</x>
  <y>91</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9596f9bd-afff-4b1f-8c39-be869c440d66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.460</label>
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
  <x>595</x>
  <y>138</y>
  <width>180</width>
  <height>30</height>
  <uuid>{e646ae5a-1978-4b35-a55b-1c92c731a64a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Send Level</label>
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
  <objectName>DelaySend</objectName>
  <x>595</x>
  <y>121</y>
  <width>500</width>
  <height>27</height>
  <uuid>{62fc68cb-e133-4202-8b11-1367e23ed833}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.89999998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DelaySend</objectName>
  <x>1035</x>
  <y>138</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ba6bd246-c54c-48aa-844b-8bbd9a6d042c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.900</label>
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
  <x>595</x>
  <y>185</y>
  <width>180</width>
  <height>30</height>
  <uuid>{176b8dbf-8ba1-4489-95dc-30095dc766d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time</label>
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
  <objectName>DelayTime</objectName>
  <x>595</x>
  <y>168</y>
  <width>500</width>
  <height>27</height>
  <uuid>{20c53bec-f5cf-46d6-81b7-f2f9574d567e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.90152001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DelayTime</objectName>
  <x>1035</x>
  <y>185</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f9658342-cd32-4d15-90b6-a27b75042579}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.902</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>PortTim</objectName>
  <x>27</x>
  <y>48</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9363e763-bb36-44ba-8ac0-0f2070b01373}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>98</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5f8f80e6-5b40-4cc7-ac28-508147d5fa8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Port Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PortTim</objectName>
  <x>12</x>
  <y>117</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0d05b746-1c53-4e25-be57-f1a3c95cc3d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Amp</objectName>
  <x>106</x>
  <y>48</y>
  <width>50</width>
  <height>50</height>
  <uuid>{47ff35ac-5321-4947-bb3a-ee8078db24e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>91</x>
  <y>98</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a863b802-531b-4ab8-9aca-303d93e49d6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp</objectName>
  <x>91</x>
  <y>117</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3279f2f0-6e71-4b29-96f9-f1a91d12a437}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>TremAmt</objectName>
  <x>185</x>
  <y>48</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d62793df-fa15-4f02-a6be-3944d7f0f305}</uuid>
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
  <x>170</x>
  <y>98</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ef9150f8-4db7-46f4-8409-0f354018012f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Trem Amt</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>TremAmt</objectName>
  <x>170</x>
  <y>117</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c6bae124-bbc9-4f73-a9d0-77519b1a7614}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>VibAmt</objectName>
  <x>264</x>
  <y>48</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0fb6f80c-917c-412e-8e0f-991ae88cc4a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>249</x>
  <y>98</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6aa74a1a-2ac0-4099-acad-763de90685d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vib Amt</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>VibAmt</objectName>
  <x>249</x>
  <y>117</y>
  <width>80</width>
  <height>25</height>
  <uuid>{637c8476-d646-4e4e-bca3-23131e1357b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ModFrq</objectName>
  <x>343</x>
  <y>48</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f2566508-ed80-46d1-b7e6-b120c84ec148}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>5.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>328</x>
  <y>98</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7b439a7c-c09f-42db-956b-3217e8494137}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mod Frq</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ModFrq</objectName>
  <x>328</x>
  <y>117</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4e61d438-a693-46dc-9123-c55340979ba7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.000</label>
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
  <x>5</x>
  <y>140</y>
  <width>242</width>
  <height>126</height>
  <uuid>{a7bdd266-ed0e-435b-a203-59df50cc1b4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VCO Parameters</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>PW</objectName>
  <x>27</x>
  <y>170</y>
  <width>50</width>
  <height>50</height>
  <uuid>{2f433df0-f080-44e7-8301-0c6f598174ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>220</y>
  <width>80</width>
  <height>25</height>
  <uuid>{792ccc7e-001b-4436-ab0c-fbe35d414f56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>P W</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PW</objectName>
  <x>12</x>
  <y>239</y>
  <width>80</width>
  <height>25</height>
  <uuid>{05743879-71cf-45b2-951d-12cb1caafc5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Leak</objectName>
  <x>106</x>
  <y>170</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c032310a-964e-4a00-b82a-9cdd17444469}</uuid>
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
  <x>91</x>
  <y>220</y>
  <width>80</width>
  <height>25</height>
  <uuid>{817e6e1a-c509-4daa-8e23-63808fb2946c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Leak</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Leak</objectName>
  <x>91</x>
  <y>239</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8d4f9c52-5030-4932-90f4-bf44867ba3e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Harms</objectName>
  <x>185</x>
  <y>170</y>
  <width>50</width>
  <height>50</height>
  <uuid>{13cb751c-8cb4-414f-b7a1-8ae7bc3bddda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>220</y>
  <width>80</width>
  <height>25</height>
  <uuid>{30f6aea0-ce47-4661-bc14-dad1b37ed564}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Harms</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Harms</objectName>
  <x>170</x>
  <y>239</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ecf4f7c7-6b5a-451f-984b-d498aae226a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <x>250</x>
  <y>140</y>
  <width>194</width>
  <height>126</height>
  <uuid>{3bb9003a-ad1d-45f5-842a-8efda4f06246}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Buzz Parameters</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Mul</objectName>
  <x>264</x>
  <y>170</y>
  <width>50</width>
  <height>50</height>
  <uuid>{fd648862-f782-4d88-b8ae-fb6c62481205}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>249</x>
  <y>220</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7e183d69-9139-4c64-afcf-3f006374d425}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mul</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Mul</objectName>
  <x>252</x>
  <y>239</y>
  <width>80</width>
  <height>25</height>
  <uuid>{75b3d136-dbb4-4f2a-a077-5c7cea11207a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Waveform</objectName>
  <x>448</x>
  <y>185</y>
  <width>120</width>
  <height>30</height>
  <uuid>{39f46d5e-4b8e-4b4d-bce6-2c853995e6ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Saw</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>PW/Square</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tri/Saw/Ramp</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Buzz</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>448</x>
  <y>164</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e48a36b8-c6a9-4ea8-947d-898cd4943ab7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Waveform:</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>312</x>
  <y>168</y>
  <width>70</width>
  <height>40</height>
  <uuid>{3b18ffde-55d0-4513-94df-3488248cd20c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number
of Harms</label>
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
  <x>312</x>
  <y>208</y>
  <width>70</width>
  <height>40</height>
  <uuid>{d7def1d9-d295-4d41-947b-77bf8b8e7f13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Lowest
Harm</label>
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
  <objectName>Nb_Harms</objectName>
  <x>381</x>
  <y>170</y>
  <width>50</width>
  <height>30</height>
  <uuid>{862cc885-0de0-4e51-b4fa-931bee727ef6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
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
  <minimum>1</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>30</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Lowest_Harm</objectName>
  <x>381</x>
  <y>211</y>
  <width>50</width>
  <height>30</height>
  <uuid>{372d7774-3e63-4098-a097-718f71d66571}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
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
  <minimum>1</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>427</x>
  <y>59</y>
  <width>80</width>
  <height>30</height>
  <uuid>{67e47696-0b77-4578-b32e-01910595a79a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bend Range</label>
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
  <objectName>Bend_Range</objectName>
  <x>508</x>
  <y>58</y>
  <width>50</width>
  <height>30</height>
  <uuid>{cc747994-be4b-457d-a5b6-37a1ac4bd55f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
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
  <maximum>24</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>269</y>
  <width>580</width>
  <height>126</height>
  <uuid>{84ff34d7-b6d0-453d-b021-39ed267e77ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Envelope</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>P_StrLev</objectName>
  <x>27</x>
  <y>301</y>
  <width>50</width>
  <height>50</height>
  <uuid>{5aa3bf31-1e76-4346-ae24-6eeb6cef03c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.12500000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.06250000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>351</y>
  <width>80</width>
  <height>25</height>
  <uuid>{54899561-ec6c-452b-8506-9d8ba511a707}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Str Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>P_StrLev</objectName>
  <x>12</x>
  <y>370</y>
  <width>80</width>
  <height>25</height>
  <uuid>{beec7d48-f34c-4bcd-b65d-3d393aedb6bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.062</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>P_AttTim</objectName>
  <x>106</x>
  <y>301</y>
  <width>50</width>
  <height>50</height>
  <uuid>{71b426ce-7e88-43c6-b921-29596c15f2dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>91</x>
  <y>351</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3127429c-e451-45b6-8946-897c3c1ccee2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Att Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>P_AttTim</objectName>
  <x>91</x>
  <y>370</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2d4b8a1b-8197-4617-9ec0-65e06b9ad7d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>P_AttLev</objectName>
  <x>185</x>
  <y>301</y>
  <width>50</width>
  <height>50</height>
  <uuid>{8205af74-a20b-4587-b081-d56d7b1fb2d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.12500000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00625002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>351</y>
  <width>80</width>
  <height>25</height>
  <uuid>{37996591-9820-408d-b980-ee39ac3de877}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Att Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>P_AttLev</objectName>
  <x>170</x>
  <y>370</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c2096019-bd04-4fc6-b3b2-b585008efbef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.006</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>P_DecTim</objectName>
  <x>264</x>
  <y>301</y>
  <width>50</width>
  <height>50</height>
  <uuid>{81475777-60aa-47b7-9502-3fbe37a08476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>249</x>
  <y>351</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c183f4d3-ddc3-48ea-996c-8d7cd20e13d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dec Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>P_DecTim</objectName>
  <x>249</x>
  <y>370</y>
  <width>80</width>
  <height>25</height>
  <uuid>{bacefa16-81c0-4003-b8e9-c28512673dd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>P_RelTim</objectName>
  <x>343</x>
  <y>301</y>
  <width>50</width>
  <height>50</height>
  <uuid>{111711ea-a0d0-458a-ab61-e04af93c8154}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>328</x>
  <y>351</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d499f7b6-91e7-4df0-abcc-15e9472793c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rel Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>P_RelTim</objectName>
  <x>328</x>
  <y>370</y>
  <width>80</width>
  <height>25</height>
  <uuid>{814457a5-aab4-4a0c-b020-52a97dbbee96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>P_RelLev</objectName>
  <x>429</x>
  <y>301</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ff31e69f-3ba8-462d-b556-a380dc8906cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.12500000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00625002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>414</x>
  <y>351</y>
  <width>80</width>
  <height>25</height>
  <uuid>{228d5e4d-97f5-4af7-b25b-361066299474}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rel Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>P_RelLev</objectName>
  <x>414</x>
  <y>370</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2b306d18-118c-4cf8-9f1e-07a5db2f18a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.006</label>
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
  <x>5</x>
  <y>397</y>
  <width>580</width>
  <height>126</height>
  <uuid>{d543940b-8b15-470f-8b79-0a9ede5999e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Envelope</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>F_AttTim</objectName>
  <x>27</x>
  <y>429</y>
  <width>50</width>
  <height>50</height>
  <uuid>{db4f7ca9-8b1b-449b-92f7-de108be883f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d82fe33c-8c03-4cd9-a119-74d23cb9e602}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Att Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>F_AttTim</objectName>
  <x>12</x>
  <y>498</y>
  <width>80</width>
  <height>25</height>
  <uuid>{17f570ed-e47d-4074-b3d1-ecfb70625157}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>F_AttLev</objectName>
  <x>106</x>
  <y>429</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d2dfe3a6-e9fb-4bdf-bf1b-3b526a795a43}</uuid>
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
  <x>91</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2cbdea0f-e8ad-47b3-80e3-7f462a8e7fa4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Att Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>F_AttLev</objectName>
  <x>91</x>
  <y>498</y>
  <width>80</width>
  <height>25</height>
  <uuid>{35dd3b91-3785-4881-ad19-bbf5723b5564}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>F_DecTim</objectName>
  <x>185</x>
  <y>429</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6a1a8855-2c34-4eef-80bf-0b29c10a7778}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{31a18545-1b2a-476c-b3bf-7f555a947762}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dec Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>F_DecTim</objectName>
  <x>170</x>
  <y>498</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e08cec08-5798-4a8d-bd0c-241c3e77d02f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>F_SusLev</objectName>
  <x>264</x>
  <y>429</y>
  <width>50</width>
  <height>50</height>
  <uuid>{b6d66b09-2f71-4cef-98a7-04ca2c3532fa}</uuid>
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
  <x>249</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6086b570-0363-4f05-bd72-3cd8a76e14e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sus Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>F_SusLev</objectName>
  <x>249</x>
  <y>498</y>
  <width>80</width>
  <height>25</height>
  <uuid>{75c58326-1ae1-4d89-a568-c5ebf0b61528}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>F_RelTim</objectName>
  <x>343</x>
  <y>429</y>
  <width>50</width>
  <height>50</height>
  <uuid>{fa9984d4-cc1c-40fc-8986-d8550698abfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.10000980</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>328</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5f1873e3-7404-4de8-a1b4-5d13acb282a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rel Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>F_RelTim</objectName>
  <x>328</x>
  <y>498</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ff46fa7d-624b-44db-a8e8-7b4d62921e07}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>F_RelLev</objectName>
  <x>429</x>
  <y>429</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a338d789-e562-426b-961f-29d969d11978}</uuid>
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
  <x>414</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ff00b6b2-5a79-4f17-a342-9a37c3fce568}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rel Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>F_RelLev</objectName>
  <x>414</x>
  <y>498</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b2a04c60-0d81-4f92-894b-b39530ac3bd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>F_EnvAmt</objectName>
  <x>508</x>
  <y>429</y>
  <width>50</width>
  <height>50</height>
  <uuid>{4a4855bd-552c-4457-822c-b7cc32769abc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>4.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>493</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{bdf87cb0-86eb-49e9-85d8-97e108e87836}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Env Amt</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>F_EnvAmt</objectName>
  <x>493</x>
  <y>498</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f1bf7fe4-f2ee-48f1-8c47-5685b5a194de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.000</label>
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
  <x>5</x>
  <y>525</y>
  <width>580</width>
  <height>126</height>
  <uuid>{b58b06c0-f027-45e0-906a-2215f929525e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Envelope</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>A_AttTim</objectName>
  <x>27</x>
  <y>557</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c5a7c96f-d446-417d-8a37-0b9a561a6deb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>607</y>
  <width>80</width>
  <height>25</height>
  <uuid>{49f17cd9-f3bd-4816-b39b-0ec90c0758c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Att Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>A_AttTim</objectName>
  <x>12</x>
  <y>626</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d6a2daa8-99bc-4261-8493-39031c83acbf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>A_AttLev</objectName>
  <x>106</x>
  <y>557</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ebb59143-2435-44fa-b60c-a8d54720ebad}</uuid>
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
  <x>91</x>
  <y>607</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f54253d5-e7d8-4043-8200-65f90f7bbb77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Att Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>A_AttLev</objectName>
  <x>91</x>
  <y>626</y>
  <width>80</width>
  <height>25</height>
  <uuid>{cb40d646-2c17-40f9-a065-8a53b41e9c8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>A_DecTim</objectName>
  <x>185</x>
  <y>557</y>
  <width>50</width>
  <height>50</height>
  <uuid>{31f7d13f-5323-4f9b-8b27-11f537a122f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>607</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d93cf229-a9ec-40a2-bb3a-219b599beba5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dec Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>A_DecTim</objectName>
  <x>170</x>
  <y>626</y>
  <width>80</width>
  <height>25</height>
  <uuid>{dd24f72d-8023-44ce-a89a-d1ae9c986a45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>A_SusLev</objectName>
  <x>264</x>
  <y>557</y>
  <width>50</width>
  <height>50</height>
  <uuid>{45e38734-343a-4885-8c32-18c541374a70}</uuid>
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
  <x>249</x>
  <y>607</y>
  <width>80</width>
  <height>25</height>
  <uuid>{878b5de8-1b62-4464-a1ff-091f47001cd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sus Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>A_SusLev</objectName>
  <x>249</x>
  <y>626</y>
  <width>80</width>
  <height>25</height>
  <uuid>{81fe2fb1-798b-4d0f-9eef-baa9719348aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>A_RelTim</objectName>
  <x>343</x>
  <y>557</y>
  <width>50</width>
  <height>50</height>
  <uuid>{016cadb8-b167-42f2-bdf5-4d7e3f7b8fb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00001000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00001000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>328</x>
  <y>607</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3dd689e6-1066-42b0-b708-a561f24c6750}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rel Time</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>A_RelTim</objectName>
  <x>328</x>
  <y>626</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5b6a82e4-eeba-44e0-851c-01458ca06dcf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>A_RelLev</objectName>
  <x>429</x>
  <y>557</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6a063c1c-9b54-4e15-a02a-52c5cd08171f}</uuid>
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
  <x>414</x>
  <y>607</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e5e679b6-6fe4-4ec5-801a-c72b361b1fb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rel Level</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>A_RelLev</objectName>
  <x>414</x>
  <y>626</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b716e89a-b8db-439e-a0e8-5ded0960f892}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <x>595</x>
  <y>232</y>
  <width>180</width>
  <height>30</height>
  <uuid>{35919991-31d9-4f26-88cd-0f2cc478e29b}</uuid>
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
  <objectName>DelayFeedback</objectName>
  <x>595</x>
  <y>215</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8e0f8ed5-c7b5-48ea-ba35-1e15b4995d9c}</uuid>
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
  <objectName>DelayFeedback</objectName>
  <x>1035</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{081ee69a-ca5f-4e21-8033-bd3353700c6a}</uuid>
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
  <x>696</x>
  <y>302</y>
  <width>283</width>
  <height>39</height>
  <uuid>{7fd45f09-9587-4f7a-94b6-e330239072da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Polyphonic MIDI Synth</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{6ab84e0f-82a7-4b9c-af23-35bd7d9b7fa2}" mode="1" >0.55400002</value>
<value id="{99d6bf8b-3c85-4911-a29a-7dd678a940ed}" mode="1" >0.55400002</value>
<value id="{99d6bf8b-3c85-4911-a29a-7dd678a940ed}" mode="4" >0.554</value>
<value id="{be1cab81-da6b-442b-bcc8-22c97579c797}" mode="1" >7.46000004</value>
<value id="{9596f9bd-afff-4b1f-8c39-be869c440d66}" mode="1" >7.46000004</value>
<value id="{9596f9bd-afff-4b1f-8c39-be869c440d66}" mode="4" >7.460</value>
<value id="{62fc68cb-e133-4202-8b11-1367e23ed833}" mode="1" >0.89999998</value>
<value id="{ba6bd246-c54c-48aa-844b-8bbd9a6d042c}" mode="1" >0.89999998</value>
<value id="{ba6bd246-c54c-48aa-844b-8bbd9a6d042c}" mode="4" >0.900</value>
<value id="{20c53bec-f5cf-46d6-81b7-f2f9574d567e}" mode="1" >0.90152001</value>
<value id="{f9658342-cd32-4d15-90b6-a27b75042579}" mode="1" >0.90152001</value>
<value id="{f9658342-cd32-4d15-90b6-a27b75042579}" mode="4" >0.902</value>
<value id="{9363e763-bb36-44ba-8ac0-0f2070b01373}" mode="1" >0.01000000</value>
<value id="{0d05b746-1c53-4e25-be57-f1a3c95cc3d1}" mode="1" >0.01000000</value>
<value id="{0d05b746-1c53-4e25-be57-f1a3c95cc3d1}" mode="4" >0.010</value>
<value id="{47ff35ac-5321-4947-bb3a-ee8078db24e1}" mode="1" >0.20000000</value>
<value id="{3279f2f0-6e71-4b29-96f9-f1a91d12a437}" mode="1" >0.20000000</value>
<value id="{3279f2f0-6e71-4b29-96f9-f1a91d12a437}" mode="4" >0.200</value>
<value id="{d62793df-fa15-4f02-a6be-3944d7f0f305}" mode="1" >0.00000000</value>
<value id="{c6bae124-bbc9-4f73-a9d0-77519b1a7614}" mode="1" >0.00000000</value>
<value id="{c6bae124-bbc9-4f73-a9d0-77519b1a7614}" mode="4" >0.000</value>
<value id="{0fb6f80c-917c-412e-8e0f-991ae88cc4a3}" mode="1" >0.10000000</value>
<value id="{637c8476-d646-4e4e-bca3-23131e1357b2}" mode="1" >0.10000000</value>
<value id="{637c8476-d646-4e4e-bca3-23131e1357b2}" mode="4" >0.100</value>
<value id="{f2566508-ed80-46d1-b7e6-b120c84ec148}" mode="1" >5.00000000</value>
<value id="{4e61d438-a693-46dc-9123-c55340979ba7}" mode="1" >5.00000000</value>
<value id="{4e61d438-a693-46dc-9123-c55340979ba7}" mode="4" >5.000</value>
<value id="{2f433df0-f080-44e7-8301-0c6f598174ef}" mode="1" >0.50000000</value>
<value id="{05743879-71cf-45b2-951d-12cb1caafc5c}" mode="1" >0.50000000</value>
<value id="{05743879-71cf-45b2-951d-12cb1caafc5c}" mode="4" >0.500</value>
<value id="{c032310a-964e-4a00-b82a-9cdd17444469}" mode="1" >0.00000000</value>
<value id="{8d4f9c52-5030-4932-90f4-bf44867ba3e4}" mode="1" >0.00000000</value>
<value id="{8d4f9c52-5030-4932-90f4-bf44867ba3e4}" mode="4" >0.000</value>
<value id="{13cb751c-8cb4-414f-b7a1-8ae7bc3bddda}" mode="1" >0.50000000</value>
<value id="{ecf4f7c7-6b5a-451f-984b-d498aae226a4}" mode="1" >0.50000000</value>
<value id="{ecf4f7c7-6b5a-451f-984b-d498aae226a4}" mode="4" >0.500</value>
<value id="{fd648862-f782-4d88-b8ae-fb6c62481205}" mode="1" >1.00000000</value>
<value id="{75b3d136-dbb4-4f2a-a077-5c7cea11207a}" mode="1" >1.00000000</value>
<value id="{75b3d136-dbb4-4f2a-a077-5c7cea11207a}" mode="4" >1.000</value>
<value id="{39f46d5e-4b8e-4b4d-bce6-2c853995e6ae}" mode="1" >0.00000000</value>
<value id="{862cc885-0de0-4e51-b4fa-931bee727ef6}" mode="1" >30.00000000</value>
<value id="{372d7774-3e63-4098-a097-718f71d66571}" mode="1" >1.00000000</value>
<value id="{cc747994-be4b-457d-a5b6-37a1ac4bd55f}" mode="1" >2.00000000</value>
<value id="{5aa3bf31-1e76-4346-ae24-6eeb6cef03c9}" mode="1" >1.06250000</value>
<value id="{beec7d48-f34c-4bcd-b65d-3d393aedb6bd}" mode="1" >1.06250000</value>
<value id="{beec7d48-f34c-4bcd-b65d-3d393aedb6bd}" mode="4" >1.062</value>
<value id="{71b426ce-7e88-43c6-b921-29596c15f2dc}" mode="1" >0.00001000</value>
<value id="{2d4b8a1b-8197-4617-9ec0-65e06b9ad7d8}" mode="1" >0.00001000</value>
<value id="{2d4b8a1b-8197-4617-9ec0-65e06b9ad7d8}" mode="4" >0.000</value>
<value id="{8205af74-a20b-4587-b081-d56d7b1fb2d4}" mode="1" >1.00625002</value>
<value id="{c2096019-bd04-4fc6-b3b2-b585008efbef}" mode="1" >1.00625002</value>
<value id="{c2096019-bd04-4fc6-b3b2-b585008efbef}" mode="4" >1.006</value>
<value id="{81475777-60aa-47b7-9502-3fbe37a08476}" mode="1" >0.00001000</value>
<value id="{bacefa16-81c0-4003-b8e9-c28512673dd1}" mode="1" >0.00001000</value>
<value id="{bacefa16-81c0-4003-b8e9-c28512673dd1}" mode="4" >0.000</value>
<value id="{111711ea-a0d0-458a-ab61-e04af93c8154}" mode="1" >0.00001000</value>
<value id="{814457a5-aab4-4a0c-b020-52a97dbbee96}" mode="1" >0.00001000</value>
<value id="{814457a5-aab4-4a0c-b020-52a97dbbee96}" mode="4" >0.000</value>
<value id="{ff31e69f-3ba8-462d-b556-a380dc8906cd}" mode="1" >1.00625002</value>
<value id="{2b306d18-118c-4cf8-9f1e-07a5db2f18a7}" mode="1" >1.00625002</value>
<value id="{2b306d18-118c-4cf8-9f1e-07a5db2f18a7}" mode="4" >1.006</value>
<value id="{db4f7ca9-8b1b-449b-92f7-de108be883f4}" mode="1" >0.00001000</value>
<value id="{17f570ed-e47d-4074-b3d1-ecfb70625157}" mode="1" >0.00001000</value>
<value id="{17f570ed-e47d-4074-b3d1-ecfb70625157}" mode="4" >0.000</value>
<value id="{d2dfe3a6-e9fb-4bdf-bf1b-3b526a795a43}" mode="1" >1.00000000</value>
<value id="{35dd3b91-3785-4881-ad19-bbf5723b5564}" mode="1" >1.00000000</value>
<value id="{35dd3b91-3785-4881-ad19-bbf5723b5564}" mode="4" >1.000</value>
<value id="{6a1a8855-2c34-4eef-80bf-0b29c10a7778}" mode="1" >0.00001000</value>
<value id="{e08cec08-5798-4a8d-bd0c-241c3e77d02f}" mode="1" >0.00001000</value>
<value id="{e08cec08-5798-4a8d-bd0c-241c3e77d02f}" mode="4" >0.000</value>
<value id="{b6d66b09-2f71-4cef-98a7-04ca2c3532fa}" mode="1" >1.00000000</value>
<value id="{75c58326-1ae1-4d89-a568-c5ebf0b61528}" mode="1" >1.00000000</value>
<value id="{75c58326-1ae1-4d89-a568-c5ebf0b61528}" mode="4" >1.000</value>
<value id="{fa9984d4-cc1c-40fc-8986-d8550698abfa}" mode="1" >0.10000980</value>
<value id="{ff46fa7d-624b-44db-a8e8-7b4d62921e07}" mode="1" >0.10000980</value>
<value id="{ff46fa7d-624b-44db-a8e8-7b4d62921e07}" mode="4" >0.100</value>
<value id="{a338d789-e562-426b-961f-29d969d11978}" mode="1" >0.00000000</value>
<value id="{b2a04c60-0d81-4f92-894b-b39530ac3bd3}" mode="1" >0.00000000</value>
<value id="{b2a04c60-0d81-4f92-894b-b39530ac3bd3}" mode="4" >0.000</value>
<value id="{4a4855bd-552c-4457-822c-b7cc32769abc}" mode="1" >4.00000000</value>
<value id="{f1bf7fe4-f2ee-48f1-8c47-5685b5a194de}" mode="1" >4.00000000</value>
<value id="{f1bf7fe4-f2ee-48f1-8c47-5685b5a194de}" mode="4" >4.000</value>
<value id="{c5a7c96f-d446-417d-8a37-0b9a561a6deb}" mode="1" >0.00001000</value>
<value id="{d6a2daa8-99bc-4261-8493-39031c83acbf}" mode="1" >0.00001000</value>
<value id="{d6a2daa8-99bc-4261-8493-39031c83acbf}" mode="4" >0.000</value>
<value id="{ebb59143-2435-44fa-b60c-a8d54720ebad}" mode="1" >1.00000000</value>
<value id="{cb40d646-2c17-40f9-a065-8a53b41e9c8e}" mode="1" >1.00000000</value>
<value id="{cb40d646-2c17-40f9-a065-8a53b41e9c8e}" mode="4" >1.000</value>
<value id="{31f7d13f-5323-4f9b-8b27-11f537a122f0}" mode="1" >0.00001000</value>
<value id="{dd24f72d-8023-44ce-a89a-d1ae9c986a45}" mode="1" >0.00001000</value>
<value id="{dd24f72d-8023-44ce-a89a-d1ae9c986a45}" mode="4" >0.000</value>
<value id="{45e38734-343a-4885-8c32-18c541374a70}" mode="1" >1.00000000</value>
<value id="{81fe2fb1-798b-4d0f-9eef-baa9719348aa}" mode="1" >1.00000000</value>
<value id="{81fe2fb1-798b-4d0f-9eef-baa9719348aa}" mode="4" >1.000</value>
<value id="{016cadb8-b167-42f2-bdf5-4d7e3f7b8fb8}" mode="1" >0.00001000</value>
<value id="{5b6a82e4-eeba-44e0-851c-01458ca06dcf}" mode="1" >0.00001000</value>
<value id="{5b6a82e4-eeba-44e0-851c-01458ca06dcf}" mode="4" >0.000</value>
<value id="{6a063c1c-9b54-4e15-a02a-52c5cd08171f}" mode="1" >0.00000000</value>
<value id="{b716e89a-b8db-439e-a0e8-5ded0960f892}" mode="1" >0.00000000</value>
<value id="{b716e89a-b8db-439e-a0e8-5ded0960f892}" mode="4" >0.000</value>
<value id="{8e0f8ed5-c7b5-48ea-ba35-1e15b4995d9c}" mode="1" >0.20000000</value>
<value id="{081ee69a-ca5f-4e21-8033-bd3353700c6a}" mode="1" >0.20000000</value>
<value id="{081ee69a-ca5f-4e21-8033-bd3353700c6a}" mode="4" >0.200</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>
